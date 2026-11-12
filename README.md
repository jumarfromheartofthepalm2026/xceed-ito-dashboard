# Xceed ITO — Market Study Dashboard

Live dashboard for Xceed ITO's market study, vendor partnership tracker, and go-to-market strategy.

🔗 **Live URL:** `https://<your-username>.github.io/xceed-ito-dashboard/`

---

## How to update the vendor tracker

1. Open `vendor-data.json` in GitHub (click the file → pencil icon ✏️)
2. Find the vendor you want to update
3. Change the `status`, `statusKey`, `details`, or `commitment` fields
4. Click **Commit changes**
5. The dashboard updates live within 1–2 minutes for everyone

### Status keys (use exactly as written)

| statusKey | Meaning |
|-----------|---------|
| `registered-testing` | Active partnership, in testing |
| `waiting-vendor-feedback` | Application sent, waiting for vendor |
| `waiting-vendor-issue` | Application blocked, needs fixing |
| `waiting-xceed` | Vendor is ready — Xceed must act |
| `not-applied-urgent` | Not registered yet — critical gap |
| `on-hold` | Paused, revisit later |
| `dropped` | Not a fit, no further action |
| `not-contacted` | No action taken yet |

---

## Files

| File | Purpose |
|------|---------|
| `index.html` | The dashboard (do not edit manually) |
| `vendor-data.json` | **Edit this file to update the dashboard** |

---

## Setup (one-time)

1. Create a GitHub account at github.com
2. Create a new **private** repository named `xceed-ito-dashboard`
3. Upload both `index.html` and `vendor-data.json`
4. Go to **Settings → Pages → Source: Deploy from branch → main → / (root)**
5. Wait 2 minutes → your live URL is ready
