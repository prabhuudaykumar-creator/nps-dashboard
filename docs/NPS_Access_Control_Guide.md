# NPS Dashboard — Domain-Based Login & Access Control

This guide sets up per-user logins where each employee sees **only the domains they're allowed to**, based on `Employee_List.xlsx`. Access is enforced by the database (Supabase Row-Level Security), so it's real security — not just a hidden screen.

## Why this architecture

The dashboard is a single HTML file with all data embedded. A client-side password could hide domains on screen, but a logged-in user could still read everything via "View Source". To genuinely restrict what each person can access, the data lives in Supabase and the **server** returns only each user's permitted rows. Once that's true, the page can be hosted anywhere (even publicly) because unauthenticated visitors get nothing.

## The access model (from your employee list)

| Scope in Employee_List | People | Domains granted |
|---|---|---|
| All domains | 16 | everything (admin) |
| Cab | 26 | Cab |
| Retail | 4 | Retail |
| 080Cafe/ TransitHotel/ SpaSalon/ Lounge | 4 | 080Cafe, TransitHotel, SpaSalon, Lounge |
| FnB | 4 | FnB |
| DutyFree | 3 | Duty Free |
| CBB | 2 | CBB |

Two reconciliations were applied: `DutyFree` → `Duty Free`, and the combined scope unlocks its four domains.

---

## Steps

### 1. Create the Supabase project
supabase.com → New project → pick a region (Mumbai/Singapore) and a strong DB password.

### 2. Create tables + security rules + seed the access list
SQL Editor → New query → paste the entire contents of **`supabase_access_setup.sql`** → Run. This creates:
- `user_access` — one row per employee (email, admin flag, allowed domains), already seeded with all 59 people.
- `nps_feedback` — the data table.
- The **RLS policy** that returns a feedback row only if the signed-in user is an admin, or the row's domain is in their `allowed_domains`.

### 3. Load the NPS data
Table Editor → `nps_feedback` → Import data from CSV → upload **`nps_feedback_for_supabase.csv`** (15,181 rows). Column names already match the table.

### 4. Create the 59 login accounts
Authentication → Users. Two options:
- **Invite by email** (recommended): each person gets a link to set their own password. Their email must exactly match the one in `user_access`.
- **Add user + temporary password**: you set a password and share it; ask them to change it on first login.

Either way, the email is the link between the login and the access row — so keep them identical (all lowercase, `@bialairport.com`).

### 5. Connect the dashboard to Supabase
In the dashboard, add the Supabase client and a login gate. On successful login:
- Fetch the user's row from `user_access` to know their scope.
- Fetch `nps_feedback` — RLS automatically returns only their permitted rows.
- Feed those rows into the dashboard's existing `recomputeAll()` so every view is already scoped.

```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script>
const db = supabase.createClient('https://YOURPROJECT.supabase.co','sb_publishable_xxx');

async function login(email, password){
  const { error } = await db.auth.signInWithPassword({ email, password });
  if (error) { alert('Login failed'); return; }
  const { data: rows } = await db.from('nps_feedback').select('*');  // only allowed domains come back
  // map rows into the dashboard's field names, then:
  // recomputeAll(mappedRows); rebuildAll();
}
</script>
```

Because RLS does the filtering, an admin automatically receives all domains and a Cab user receives only Cab — no client-side domain logic is required for security.

### 6. Host it
Deploy the page (Vercel / Cloudflare Pages / GitHub Pages). The login protects the data, so a public URL is acceptable. For an extra perimeter, put it behind Cloudflare Access too.

---

## Maintaining access later
- **New employee / changed scope:** add or edit their row in `user_access` (Table Editor), and create their auth user. No dashboard change needed.
- **Revoke access:** delete the auth user, or set `allowed_domains = '{}'` and `is_admin = false`.
- Re-running the seed file is safe — it upserts on email.

## Files in this package
- `supabase_access_setup.sql` — schema + RLS + all 59 seeded access rows
- `nps_feedback_for_supabase.csv` — the data to import (15,181 rows)
- `user_access_seed.csv` — human-readable view of who gets what (for review/editing)
