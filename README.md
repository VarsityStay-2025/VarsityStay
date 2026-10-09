# VarsityStay — Phase 1 (Plain HTML/CSS/JS)

No build step, no npm required to run this — just HTML, CSS, and vanilla JS talking to Supabase.

## What's built (Week 1 foundation)

- Supabase schema: `profiles` (student/landlord roles), `properties`, `reservations` — with row-level security (see `supabase/migrations/0001_init.sql`)
- Student + landlord signup/login (role-based) — `signup.html`, `login.html`
- Homepage with search/filter bar — `index.html` (university, room type, exact budget value via slider, NSFAS toggle; distance shown in **minutes** not km once listings load)
- Live property listings pulling from the database — `properties.html`
- Property detail page — `property.html?id=...`
- Student dashboard ("My Stay") — `dashboard-student.html`
- Landlord dashboard ("My Listings") — `dashboard-landlord.html`

## What's stubbed / coming in Week 2

- "Book a Viewing" / "Reserve Room" buttons link to `book.html` / `reserve.html`, which don't exist yet — that's Week 2 (booking + payments)
- Landlords can't add/edit listings yet — also Week 2
- No payment integration yet (Paystack/PayFast) — Week 2

## Setup

1. Open `js/config.js` and replace `SUPABASE_URL` and `SUPABASE_ANON_KEY` with your real project's values (Supabase dashboard → Settings → API)
2. Push the schema: run `supabase/migrations/0001_init.sql` in your Supabase SQL Editor
3. Sign up as a landlord through the app first (open `signup.html`), so you have a real `profiles.id`
4. Edit `supabase/seed.sql`, replace `LANDLORD_UUID_HERE` with that landlord's real ID (Table Editor → profiles), then run it in the SQL Editor
5. Run it locally — any of these work:
   - Double-click `index.html` to open it directly in your browser, OR
   - `npx serve .` from this folder (avoids some browser file:// restrictions), then open the URL it gives you

## Deploying to Vercel

Even simpler than the Next.js version — this is now just static files:
1. Push this whole folder to GitHub
2. Import the repo in Vercel — no framework/build settings needed, it'll serve the HTML files as-is
3. Done. No environment variables needed either, since the Supabase URL/key are already in `js/config.js` (safe to be public — protected by Row Level Security, not secrecy)

## Notes

- `js/lib/supabase.js` is the Supabase client library, bundled locally rather than loaded from a CDN — one less external dependency that could go down or get blocked.
- `js/nav.js` renders the top nav on every page and automatically shows "Log In / Sign Up" vs "My Account" depending on whether someone's logged in.
- Design system matches the existing VarsityStay brand: navy `#0F172A`, royal blue `#2563EB`, orange `#F97316`, Sora (headings) + DM Sans (body) — see `css/styles.css`.
