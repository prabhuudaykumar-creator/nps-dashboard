# DEPLOY — GitHub + Supabase

This dashboard is a **cloud build**: it contains no data and no PII. After a user signs in, it pulls only the domains they're allowed to see from Supabase (enforced by Row-Level Security). Do the Supabase side first, then host the page.

## A. Supabase (data + logins) — do this first

1. **Create a project** at supabase.com (region: Mumbai/Singapore).
2. **Run the setup SQL:** SQL Editor → New query → paste all of `setup/supabase_access_setup.sql` → Run. This creates the `user_access` and `nps_feedback` tables, the domain-scoping security rule, and seeds all 59 employees.
3. **Import the data:** Table Editor → `nps_feedback` → Import data from CSV → upload `data/nps_feedback_for_supabase.csv` (15,181 rows).
4. **Create the logins:** Authentication → Users → invite each employee by email (they set their own password). Emails must match the seeded `user_access` rows.
5. **Copy your keys:** Project Settings → API Keys → copy the **Project URL** and the **publishable key**.

## B. Put your keys in the page

Open `index.html`, find the config block near the bottom of the script:

```js
const SUPABASE_URL = 'https://YOURPROJECT.supabase.co';
const SUPABASE_KEY = 'sb_publishable_XXXXXXXXXXXX';
```

Replace both with your values and save. (The publishable key is safe to ship in the page; RLS is what protects the data.)

## C. GitHub

```
git add index.html
git commit -m "Configure Supabase keys"
git remote add origin https://github.com/<you>/nps-dashboard.git   # first time only
git branch -M main
git push -u origin main
```

## D. Go live (pick one)

- **Vercel:** vercel.com → Add New → Project → import the repo → Framework **Other** → Deploy.
- **GitHub Pages:** repo Settings → Pages → deploy from `main` / root.
- **Cloudflare Pages:** connect the repo, or drag `index.html`.

Because the login protects the data, a public URL is fine — signed-out visitors get nothing, and each signed-in user only receives their permitted domains.

## E. Verify

Open the live URL, sign in as an **All domains** user (see the full picture), then as a **Cab**-only user (should see only Cab). If a Cab user can see other domains, re-check that account's row in `user_access` and that RLS is enabled on `nps_feedback`.

---

### Notes
- `setup/` and `data/` are git-ignored on purpose — the SQL seed contains staff emails and the CSV is the dataset. They're for configuring Supabase, not for hosting. Keep them private.
- The full offline dashboard with all data embedded (`NPS_Dashboard_Internal_Full_v24.html`) is for internal use only and must **not** be hosted publicly — it contains passenger Pax Mobile/Email.
- Updating data later: re-import into `nps_feedback` (or append). No redeploy needed. Updating access: edit rows in `user_access`.
