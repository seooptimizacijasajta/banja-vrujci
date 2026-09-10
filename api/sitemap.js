// Vercel Node.js Serverless Function — GET /api/sitemap
// Generates a live XML sitemap by querying Supabase.
// Responds to /sitemap.xml via redirect in vercel.json.
// Listings/pages with published=false are automatically excluded.

const SUPABASE_URL = 'https://eckotcmqbpoftcseqzsa.supabase.co';
const SUPABASE_KEY = 'sb_publishable_0NrJlQyn97I7v6IKCLVUdw_uzvKVA4U';
const BASE = 'https://www.vrujci.org';

// Category title → URL slug mapping (must match vercel.json rewrites)
const CAT_SLUGS = {
  'Vile': 'banja-vrujci-vile',
  'Apartmani': 'apartmani-banja-vrujci',
  'Hoteli': 'banja-vrujci-hoteli',
  'Privatni smeštaj': 'banja-vrujci-privatni-smestaj',
  'Vikendice': 'banja-vrujci-vikendice',
  'Sobe': 'banja-vrujci-sobe',
};

// Pages served under /info-servis/
const INFO_SERVIS_PAGES = new Set(['video', 'info-servis', 'kontakt-info', 'vreme', 'linkovi-partnera']);

async function sb(path) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/${path}`, {
    headers: { apikey: SUPABASE_KEY, Authorization: `Bearer ${SUPABASE_KEY}` },
  });
  if (!res.ok) throw new Error(`Supabase ${res.status}: ${path}`);
  return res.json();
}

function url(loc, { priority = '0.5', changefreq = 'monthly', lastmod } = {}) {
  return `  <url>
    <loc>${loc}</loc>${lastmod ? `\n    <lastmod>${lastmod}</lastmod>` : ''}
    <changefreq>${changefreq}</changefreq>
    <priority>${priority}</priority>
  </url>`;
}

function date(ts) { return ts ? ts.slice(0, 10) : undefined; }

module.exports = async (_req, res) => {
  try {
    const [listings, pages, categories, posts] = await Promise.all([
      sb('listings?select=slug,category,updated_at&published=eq.true&order=sort_order.asc,id.asc'),
      sb('pages?select=slug,updated_at&published=eq.true&order=sort_order.asc,id.asc'),
      sb('categories?select=slug,updated_at&order=sort_order.asc'),
      sb('posts?select=slug,published_at&order=published_at.desc'),
    ]);

    const urls = [];

    // ── Homepage
    urls.push(url(`${BASE}/`, { priority: '1.0', changefreq: 'weekly' }));

    // ── All-listings hub
    urls.push(url(`${BASE}/banja-vrujci-smestaj/`, { priority: '0.9', changefreq: 'weekly' }));

    // ── Map page
    urls.push(url(`${BASE}/banja-vrujci-smestaj-mapa/`, { priority: '0.7', changefreq: 'monthly' }));

    // ── Category index pages
    for (const cat of categories) {
      urls.push(url(`${BASE}/${cat.slug}/`, { priority: '0.8', changefreq: 'weekly', lastmod: date(cat.updated_at) }));
    }

    // ── Individual listing pages (skip category hub slugs — they ARE the category pages)
    const catSlugsSet = new Set(Object.values(CAT_SLUGS));
    for (const l of listings) {
      const catSlug = CAT_SLUGS[l.category];
      if (!catSlug) continue;
      if (catSlugsSet.has(l.slug)) continue; // skip hub listings (slug = category URL)
      urls.push(url(`${BASE}/${catSlug}/${l.slug}/`, { priority: '0.7', changefreq: 'monthly', lastmod: date(l.updated_at) }));
    }

    // ── Info-servis pages
    const SKIP_PAGES = new Set(['banja-vrujci-smestaj', 'banja-vrujci-smestaj-mapa']);
    for (const p of pages) {
      if (SKIP_PAGES.has(p.slug)) continue; // already added above
      let loc;
      if (p.slug === 'info-servis') {
        loc = `${BASE}/info-servis/`; // the index itself
      } else if (INFO_SERVIS_PAGES.has(p.slug)) {
        loc = `${BASE}/info-servis/${p.slug}/`;
      } else {
        loc = `${BASE}/${p.slug}/`;
      }
      urls.push(url(loc, { priority: '0.6', changefreq: 'monthly', lastmod: date(p.updated_at) }));
    }

    // ── Blog posts
    for (const p of posts) {
      urls.push(url(`${BASE}/blog/${p.slug}/`, { priority: '0.6', changefreq: 'monthly', lastmod: date(p.published_at) }));
    }

    const xml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls.join('\n')}
</urlset>`;

    res.setHeader('Content-Type', 'application/xml; charset=utf-8');
    res.setHeader('Cache-Control', 's-maxage=3600, stale-while-revalidate=86400');
    return res.status(200).send(xml);
  } catch (err) {
    console.error('Sitemap generation error:', err);
    return res.status(500).send('<!-- sitemap error -->');
  }
};
