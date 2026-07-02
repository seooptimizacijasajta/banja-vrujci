// Vercel Edge Middleware — Basic-Auth gate in front of the admin panel.
//
// Required environment variables (set in Vercel project dashboard, NOT in code):
//   ADMIN_USER — username you choose for the admin login prompt
//   ADMIN_PASS — password you choose for the admin login prompt
//
// Until both env vars are set, this gate stays disabled (fails open) so you
// are never accidentally locked out of admin-16b01987.html. Once you set
// them in Vercel (Project Settings -> Environment Variables) and redeploy,
// the browser will prompt for that username/password before the admin page
// loads at all — on top of the existing Supabase magic-link login.

export const config = {
  matcher: '/admin-16b01987.html',
};

export default function middleware(request) {
  const user = process.env.ADMIN_USER;
  const pass = process.env.ADMIN_PASS;

  if (!user || !pass) {
    return; // not configured yet — let the request through unmodified
  }

  const authHeader = request.headers.get('authorization') || '';
  if (authHeader.startsWith('Basic ')) {
    try {
      const decoded = atob(authHeader.slice(6));
      const sep = decoded.indexOf(':');
      const u = decoded.slice(0, sep);
      const p = decoded.slice(sep + 1);
      if (u === user && p === pass) {
        return; // credentials match — continue to the admin page
      }
    } catch {
      // malformed header — fall through to 401
    }
  }

  return new Response('Potrebna je autentifikacija.', {
    status: 401,
    headers: { 'WWW-Authenticate': 'Basic realm="Banja Vrujci Admin"' },
  });
}
