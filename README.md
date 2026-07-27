# Wes & Gavin's Forever Home

A single static HTML page for Wes and Gavin to log floor plans found online, rate them, and track what each of them likes and doesn't like — so they can converge on the one they both love for their forever home.

- One file: `index.html` (HTML + CSS + JS, no build step, no framework).
- Data lives in [Supabase](https://supabase.com) (Postgres + Auth), free tier is plenty.
- Routing is hash-based (`#/floorplans/<uuid>`) so every floor plan, the add form, etc. get their own shareable/bookmarkable URL with zero server configuration — works on any static host, including GitHub Pages.
- Each floor plan tracks square footage, bedrooms, bathrooms, and garage size, plus a hero photo — either auto-fetched from the link or pasted in by hand (most listing sites block iframes and don't allow their raw HTML to be fetched cross-origin from the browser, so embedding the page directly isn't reliable — a prominent "Open original" link is always there instead).
- Filters on the dashboard narrow the list by minimum rating, bedrooms, bathrooms, garage size, and square footage.

## 1. Create a Supabase project

1. Go to [supabase.com](https://supabase.com) → New project (free tier).
2. Once it's created, open **SQL Editor** → New query, paste the contents of [`supabase/schema.sql`](supabase/schema.sql), and run it. This creates the tables and the row-level security policies that keep the data private to just the two of you.

## 2. Create your two accounts

Sign-up is intentionally not exposed in the app — you create exactly two accounts yourselves:

1. In the Supabase dashboard, go to **Authentication → Users → Add user**.
2. Create one user for Wes and one for Gavin (email + password each). Use "Auto Confirm User" so you don't need to click an email link.

The first time each of you signs into the app, it'll ask what name to display (e.g. "Wes") — that's stored automatically, no further setup needed.

## 3. Connect the app to your project

1. In Supabase: **Project Settings → API**.
2. Copy the **Project URL** and the **anon public** key.
3. Open `index.html`, find this block near the top of the `<script>` tag, and paste your values in:

```js
const SUPABASE_URL = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
```

The anon key is meant to be public (it ships in the page) — the SQL policies from step 1 are what actually restrict reads/writes to your two accounts.

## 4. Host it on GitHub Pages

This repo already has a `main` branch and a GitHub remote.

1. Commit and push `index.html` (and the rest of this repo) to `main`.
2. On GitHub: **Settings → Pages → Source → Deploy from a branch → `main` / `(root)`**.
3. Your app will be live at `https://<your-username>.github.io/Floor-Plan-Evaluator/`.

Because routing is hash-based (`#/...`), there's no extra GitHub Pages configuration needed — deep links and page refreshes just work.

## Using it

- **Add floor plan** — paste the public link from any floor plan or listing site, then click "Fetch preview" to try pulling its hero photo automatically. That only works on sites that support link-preview fetching (via a public API, since a static page can't scrape another site's HTML directly) — if it comes up empty, just paste an image URL into the "Image link" field instead. Fill in sqft, bedrooms, bathrooms, and garage size if you have them; title auto-fills from the domain if left blank.
- **Floor plan detail** — hero photo up top, "Open original" always visible to jump to the real listing; rate it 1–5 stars (you'll see your partner's rating right alongside yours); add notes under "What you like" / "What you don't like" — each note is tagged with your name so you can both see who said what.
- **Dashboard filters** — narrow the list by minimum rating, bedrooms, bathrooms, garage size, or square footage; combine as many as you like.
- **Dashboard sort** — best match (combined average, both-of-you-rated plans first), newest, or most liked. A plan gets a "you both love it" badge once you've both rated it 4★ or higher.
- Changes sync live between your two sessions (via Supabase Realtime) — no refresh needed to see your partner's latest rating or note.
