# NPS Case-Management Layer — Build Plan (Items 4, 5, 8, 11)

These four requirements need **shared, persistent state and automated communication**, which a single offline HTML file cannot provide. The right home — given you already have **Microsoft 365** — is **SharePoint (data) + Power Automate (automation) + Power Apps / Power BI (interface)**. Everything below uses tools in your existing M365 licence.

## Why these can't live in the dashboard
| Item | Why it needs a backend |
|---|---|
| 4. Self-learning from outcomes | Must store issue → action → outcome history across users & time |
| 5. Automated call/email | A file can *draft* a mailto, but cannot *send* or *schedule* |
| 8. Action plan + SLA tracking | Multiple people update one shared tracker; needs a database |
| 11. Mandatory response + reminders | Needs server-side status tracking and timed notifications |

---

## Step 1 — Create the data store (SharePoint List: "NPS_Cases")
Create one SharePoint list with these columns:
- **CaseID** (auto ID)
- **Date**, **Store**, **Domain**, **Terminal** (from feedback)
- **Rating**, **NPS_Category**
- **Feedback** (multi-line text)
- **IssueCategory** (choice: Staff, Cleanliness, Food, Pricing, Queue, Facilities, Other)
- **SuggestedAction** (text)
- **ResponsibleTeam** (choice)
- **Owner** (Person)
- **Status** (choice: Open / In Progress / Responded / Resolved / Overdue)
- **TargetResolution** (date)
- **ResponseText** (multi-line)
- **Outcome** (choice: Resolved / Unresolved) ← powers item 4
- **CreatedOn**, **ClosedOn**

## Step 2 — Load detractor cases automatically (item 11)
Use **Power Automate**: a scheduled flow (or triggered on new survey row) that:
1. Reads new detractor feedback (from the same Excel/source or a connected list).
2. Creates a row in **NPS_Cases** with Status = **Open** and a **TargetResolution** date (e.g., +48h).
This makes a response **mandatory** by design — every detractor becomes a tracked case.

## Step 3 — SLA tracking & reminders (items 8 + 11)
Add a **recurring Power Automate flow** (run daily):
- Find cases where Status ≠ Resolved and TargetResolution < today → set Status = **Overdue**.
- Send a reminder email to the **Owner** for Open/Overdue cases.
- Optional: escalate to a manager if Overdue > X days.

## Step 4 — Automated email/response (item 5)
In the same flow, when a case is created or marked for response:
- Use the **response-script templates** from the dashboard's Action Center as the email body (merge {Store}, {Feedback}).
- Send via **Office 365 Outlook** connector to the store/partner.
- Log the sent text into **ResponseText** and set Status = **Responded**.

## Step 5 — The action tracker interface (item 8)
Two options (pick one):
- **Power Apps Canvas App**: a simple screen listing cases, filterable by store/status, where owners update Status, Owner, ResponseText. Best for partners on mobile.
- **Power BI dashboard**: an "Action Tracker" page with Open vs Closed, Overdue count, average resolution time, SLA-compliance % (DAX measures over NPS_Cases). Best for management visibility.

## Step 6 — Self-learning recommendations (item 4)
Once cases accumulate **Outcome** data:
- In Power BI, compute *resolution rate per (IssueCategory × Action)* — i.e., which action resolved the most cases.
- Show "Recommended action (based on past success rate)" by ranking actions by their historical Resolved %.
- This is a measure/visual, not ML — transparent and good enough to start. (A true ML model can come later via Azure, but isn't needed for v1.)

---

## Recommended rollout order
1. SharePoint list + auto-create detractor cases (items 11, 8 foundation).
2. Power BI Action Tracker page (item 8 visibility).
3. Reminder/escalation flow (items 11, 8 SLA).
4. Automated response email using the dashboard's scripts (item 5).
5. Outcome capture → success-rate recommendations (item 4).

## How it connects to what you already have
- The **HTML dashboard** = real-time analytics, patterns, suggested actions, scripts (already built).
- The **Power BI report** (from NPS_PowerBI_Data.xlsx) = per-user views + the Action Tracker page.
- **SharePoint + Power Automate** = the persistent case/SLA/automation engine.

All three read the same NPS data and reinforce each other — analytics → action → tracking → learning.
