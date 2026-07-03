# Source Data

`nps_feedback_for_supabase.csv` — **17,270** NPS records (updated 2026-07-02), one row per Pax User ID + Outlet (a passenger who visited multiple outlets has one row per outlet, never averaged together).

**Data as of this refresh:** covers 2026-04-01 → 2026-06-30 · NPS 74.5 · 17,011 unique passengers · 156 outlets.

## Columns
| Column | Description |
|---|---|
| `pax_user_id` | Opaque passenger identifier |
| `outlet` | Store/outlet name |
| `avg_rating` | Average rating (0–10) across that passenger's rapid-fire responses at this outlet |
| `nps_category` | Promoter (9–10) / Passive (7–8) / Detractor (0–6) |
| `domain` | e.g. Retail, FnB, Cab, Lounge |
| `terminal` | T1 / T2 |
| `movement` | Arrival / Departure / etc. |
| `channel` | Feedback channel |
| `submitted_on` | Date |
| `feedback` | Free-text comment, where given |

## Privacy note
This file does **not** contain passenger Mobile numbers or Email addresses — those were deliberately excluded. It does contain free-text feedback comments, which is why this repository is kept **private**. Do not make this repository public without re-reviewing this file first.

## Source of truth
This is also the file loaded into the Supabase `nps_feedback` table (see `supabase-setup-DO-NOT-PUSH/` locally, not in this repo) for the live dashboard. If you regenerate or refresh the data, update both places.
