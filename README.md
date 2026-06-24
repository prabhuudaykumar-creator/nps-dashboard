# BLR Airport — NPS Analytics Dashboard

A self-contained, offline NPS (Net Promoter Score) analytics dashboard for Bengaluru (BLR) Airport feedback data. The entire app is a **single `index.html` file** — no server, no build step, no external dependencies or CDNs. Open it in any modern browser and it runs.

## What it does

- **Overview** — headline NPS, promoter/passive/detractor split, and breakdowns by domain, terminal, and movement type.
- **Action Center** — one clean table of negative detractor feedback that needs a response, with Pax User ID, outlet, issue, score, and a Pending/Closed status you can work through. Positive comments are excluded even when rated low.
- **Trend analysis** — day-wise and weekly NPS movement.
- **Segmentation** — performance by outlet, domain, terminal, and channel.
- **Feedback insights** — searchable feedback with sentiment and issue tagging.
- **Source data** — the underlying records (Pax User ID + feedback), searchable and exportable.

## Standard filter

One filter bar on every view: **Domain · Category · Outlet · Terminal (T1/T2)**. Selecting any combination re-scopes the entire dashboard.

## Data model (important)

- **One record per Pax User ID.** The raw feedback file repeats each survey across multiple rapid-fire question rows; those are collapsed so each passenger appears once with their most complete feedback. This removes duplicated/repeated feedback.
- **NPS is computed per unique passenger** from their mean rating (≥9 Promoter, 7–8 Passive, 0–6 Detractor). One vote per person.
- Rapid-fire question text is not shown; **Pax User ID + Feedback** are the primary fields.
- All aggregates (NPS, domain/terminal/outlet breakdowns, trends) are derived in-browser from the embedded records, so totals always reconcile to the sum of their parts.

## Updating the data

Use the **Upload data** button in the dashboard header and select an NPS export (`.xlsx` or `.csv`). Required columns: `Average of rating`, `Domain`, `submitted_on`. The dashboard auto-derives NPS category, dedupes to one row per `Pax User ID`, and rebuilds every view. Nothing is sent anywhere — processing happens entirely in your browser.

## Publishing

Because it's a static file, you can host it anywhere:

- **GitHub Pages** — Settings → Pages → deploy from branch → `/ (root)`. Serves `index.html` directly. ⚠️ Free GitHub Pages is **public**; this dashboard embeds feedback text, so use a private host if that data shouldn't be public.
- **Cloudflare Pages + Access** — recommended for a **private** internal dashboard (free for small teams, email-based login).
- **Netlify Drop** — drag-and-drop, fastest public option.

## Privacy / PII note

The raw NPS source file contains passenger contact details (**Pax Mobile, Pax Email**) and is therefore **excluded from this repository** via `.gitignore` (see the `data/` folder, which is not committed). The dashboard itself does **not** embed mobile numbers or emails — only Pax User ID (an opaque identifier), feedback text, ratings, outlet, terminal, and date. Review feedback text for sensitive content before publishing publicly.

## Repository contents

| Path | Description |
|------|-------------|
| `index.html` | The complete dashboard (this is the deliverable) |
| `docs/NPS_CaseManagement_PowerApps_Plan.md` | Plan for a SharePoint + Power Automate + Power BI case-management backend |
| `data/` | Source spreadsheets — **git-ignored** (contains PII) |

## Tech notes

- Vanilla HTML/CSS/JS, custom canvas charting, native XLSX/CSV parser — zero dependencies.
- Embedded data is dictionary-encoded (feedback and dates) to keep the file compact (~1.4 MB).
- Per-row notes and case statuses are saved in the browser's `localStorage` (device-local; not shared between users).
