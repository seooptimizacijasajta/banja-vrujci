// Vercel Node.js Serverless Function — POST /api/contact
// Verifies a Cloudflare Turnstile token, then emails the message via Resend.
//
// Required environment variables (set in Vercel project dashboard, NOT in code):
//   TURNSTILE_SECRET_KEY  — secret key from your Cloudflare Turnstile widget
//   RESEND_API_KEY        — API key from your Resend account
//   RESEND_FROM           — (optional) verified "from" address, e.g.
//                            "Vrujci.org <kontakt@vrujci.org>". Defaults to the
//                            Resend sandbox sender, which only works for testing.

const RESEND_API_URL = 'https://api.resend.com/emails';
const TURNSTILE_VERIFY_URL = 'https://challenges.cloudflare.com/turnstile/v0/siteverify';
const TO_EMAIL = 'banjavrujci@gmail.com';
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function esc(s) {
  return String(s).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
}

module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST');
    return res.status(405).json({ ok: false, error: 'Method not allowed' });
  }

  let body = req.body;
  if (!body || typeof body === 'string') {
    try { body = JSON.parse(body || '{}'); } catch { body = {}; }
  }
  const { name, email, message, turnstileToken } = body || {};

  if (!name || !email || !message || !turnstileToken) {
    return res.status(400).json({ ok: false, error: 'Nedostaju podaci.' });
  }
  if (String(name).length > 200 || String(email).length > 200 || String(message).length > 5000) {
    return res.status(400).json({ ok: false, error: 'Podaci su previše dugi.' });
  }
  if (!EMAIL_RE.test(email)) {
    return res.status(400).json({ ok: false, error: 'Nevažeća email adresa.' });
  }

  const turnstileSecret = process.env.TURNSTILE_SECRET_KEY;
  if (!turnstileSecret) {
    console.error('Missing TURNSTILE_SECRET_KEY env var');
    return res.status(500).json({ ok: false, error: 'Server nije podešen (CAPTCHA). Kontaktirajte administratora.' });
  }

  try {
    const ip = (req.headers['x-forwarded-for'] || '').split(',')[0].trim();
    const verifyRes = await fetch(TURNSTILE_VERIFY_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        secret: turnstileSecret,
        response: turnstileToken,
        ...(ip ? { remoteip: ip } : {}),
      }),
    });
    const verifyData = await verifyRes.json();
    if (!verifyData.success) {
      return res.status(400).json({ ok: false, error: 'CAPTCHA provera nije uspela. Pokušajte ponovo.' });
    }
  } catch (err) {
    console.error('Turnstile verify failed', err);
    return res.status(502).json({ ok: false, error: 'Greška pri proveri CAPTCHA.' });
  }

  const resendKey = process.env.RESEND_API_KEY;
  if (!resendKey) {
    console.error('Missing RESEND_API_KEY env var');
    return res.status(500).json({ ok: false, error: 'Server nije podešen (email). Kontaktirajte administratora.' });
  }

  const fromAddr = process.env.RESEND_FROM || 'Vrujci.org kontakt forma <onboarding@resend.dev>';

  try {
    const emailRes = await fetch(RESEND_API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${resendKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: fromAddr,
        to: [TO_EMAIL],
        reply_to: email,
        subject: `Nova poruka sa kontakt forme — ${name}`,
        html: `<p><strong>Ime:</strong> ${esc(name)}</p><p><strong>Email:</strong> ${esc(email)}</p><p><strong>Poruka:</strong></p><p>${esc(message).replace(/\n/g, '<br>')}</p>`,
        text: `Ime: ${name}\nEmail: ${email}\n\nPoruka:\n${message}`,
      }),
    });
    if (!emailRes.ok) {
      const errText = await emailRes.text();
      console.error('Resend send failed', emailRes.status, errText);
      return res.status(502).json({ ok: false, error: 'Email nije mogao biti poslat.' });
    }
  } catch (err) {
    console.error('Resend send error', err);
    return res.status(502).json({ ok: false, error: 'Email nije mogao biti poslat.' });
  }

  return res.status(200).json({ ok: true });
};
