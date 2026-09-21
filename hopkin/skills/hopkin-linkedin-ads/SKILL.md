---
name: hopkin-linkedin-ads
description: Generate LinkedIn Ads performance reports and analytics, and research competitors' LinkedIn ads, using the Hopkin LinkedIn Ads MCP. Includes prerequisite checks, authentication and connection management, report generation workflows, demographic insights using LinkedIn's unique MEMBER_* pivots, LinkedIn Ad Library search and name-based competitor tracking (real creative, video frames, employee posts a company pays for, EU transparency data — no LinkedIn connection needed), and developer feedback for unsupported write operations.
---

# LinkedIn Ads Skill

## Introduction

This skill enables Claude to build comprehensive reports and analyze LinkedIn Ads campaigns via the Hopkin LinkedIn Ads MCP. Use this skill to:

- Generate performance reports across campaign groups, campaigns, or creatives
- Analyze campaign metrics, ROAS, and spending patterns
- Leverage LinkedIn's unique professional demographic audience (job title, seniority, industry, etc.)
- Analyze creative effectiveness
- Research competitors: see any company's LinkedIn ads, track competitors by name, and read their actual creative — no LinkedIn connection needed

## Prerequisites

### Check for MCP Availability

Check for `linkedin_ads_` prefixed tools (e.g., `linkedin_ads_check_auth_status`). If none are found, the MCP is not configured.

### If Hopkin LinkedIn Ads MCP Is Not Installed

Inform the user and provide setup instructions:

> The Hopkin LinkedIn Ads MCP is not configured. To use this skill:
>
> 1. Sign up at **https://app.hopkin.ai**
> 2. Add the hosted MCP to your Claude configuration:
>
> ```json
> {
>   "mcpServers": {
>     "hopkin-linkedin-ads": {
>       "type": "url",
>       "url": "https://linkedin.mcp.hopkin.ai/mcp",
>       "headers": {
>         "Authorization": "Bearer YOUR_HOPKIN_TOKEN"
>       }
>     }
>   }
> }
> ```
>
> 3. Restart Claude after updating configuration

Pause execution until the user confirms, then re-verify.

### Authentication Flow

1. Call `linkedin_ads_check_auth_status` to verify authentication
2. If not authenticated, direct the user to https://app.hopkin.ai to connect their account

> **Note:** LinkedIn tokens have a **60-day TTL**. If a previously-authenticated user gets auth errors, direct them to https://app.hopkin.ai to reconnect.

> **Competitor research needs no LinkedIn connection.** The ad-library and competitor tools work with Hopkin sign-in alone — never ask the user to connect LinkedIn for them.

### Required Information

- **Ad Account ID** — Numeric ID passed as a string (e.g., `"123456789"`). Use `linkedin_ads_list_ad_accounts` to look up by company name.
- **Date Range** — Use `date_preset` (e.g., `LAST_30_DAYS`) or `start_date`/`end_date` (YYYY-MM-DD)

### Multi-Account Selection

When `linkedin_ads_list_ad_accounts` returns multiple accounts, present them as a numbered list and ask the user to confirm which one to analyze.

### Connections

A user can have more than one LinkedIn connection (their own, or ones shared with them through their organization). Every account and reporting tool accepts an optional `connection_id`; omit it to use the default connection.

- `linkedin_ads_list_connections` shows each connection's name, ID, whether it is the default, and whether it is owned or shared
- Pass `connection_id` to target a specific one
- `linkedin_ads_set_default_connection` changes which one is used when `connection_id` is omitted — call it only when the user asks

## LinkedIn Ads Hierarchy

| LinkedIn | Meta | Google | Notes |
|---|---|---|---|
| Ad Account | Ad Account | Customer | Flat — no MCC hierarchy |
| Campaign Group | Campaign | Campaign | Top-level org unit; holds budget and objective |
| Campaign | Ad Set | Ad Group | Targeting, bidding, scheduling |
| Creative | Ad | Ad | Headline, body, image, CTA |

No MCC equivalent — all accounts are accessible directly; no `login_customer_id` needed.

## Available MCP Tools

### Authentication
- `linkedin_ads_check_auth_status` — Verify auth and get LinkedIn profile info; only call when another tool returns an auth error
- `linkedin_ads_ping` — Health check

### Accounts
- `linkedin_ads_list_ad_accounts` — List accessible LinkedIn Sponsored Ad Accounts

### Campaign Groups
- `linkedin_ads_list_campaign_groups` — List Campaign Groups (top-level org unit, analogous to Campaigns in Meta/Google)

### Campaigns
- `linkedin_ads_list_campaigns` — List Campaigns (targeting/bidding level, analogous to Ad Sets in Meta)

### Creatives
- `linkedin_ads_list_creatives` — List Creatives (headline, body, image, CTA) for an account or campaigns

### Analytics
- `linkedin_ads_get_performance_report` — **Recommended.** Full-funnel report: impressions, clicks, spend, conversions, leads, CTR, CPC, CPA, ROAS, plus optional per-conversion breakdown
- `linkedin_ads_get_account_summary` — Account-level summary; runs three parallel API calls (account details, metrics, conversion breakdown)
- `linkedin_ads_get_insights` — Flexible analytics; **the only tool supporting LinkedIn's unique MEMBER_* demographic pivots**

### Charts & Visualization
- `linkedin_ads_render_chart` — **MCP App. ALWAYS use this when the user asks for any chart, graph, map, or visualization.** Do NOT substitute a table or text summary. Supports 6 types: `bar` (compare values across campaigns/placements), `scatter` (correlation between two metrics), `timeseries` (metrics over time), `funnel` (conversion stages), `waterfall` (cumulative contribution), `choropleth` (US state heatmap). Fetch the data first with insights or performance report tools, then pass the structured data here. This renders an interactive visual — it is the correct tool whenever a chart is explicitly requested.

### Partner Conversions
- `linkedin_ads_get_partner_conversions` — List partner conversions (LinkedIn's term for "conversion actions"); call before interpreting conversion metrics or ROAS

### Budget & Bid Planning
- `linkedin_ads_get_budget_pricing` — Recommended bid ranges and daily budget limits for a campaign type and audience

### Connections
- `linkedin_ads_list_connections` — List LinkedIn connections available to you (owned and org-shared), with their IDs
- `linkedin_ads_set_default_connection` — Set the default connection for subsequent LinkedIn Ads tool calls
- `linkedin_ads_share_connection` / `linkedin_ads_unshare_connection` — Share/unshare an owned connection with your organization (unshare is destructive — confirm with the user first)
- `linkedin_ads_rename_connection` — Rename an owned connection's display name
- `linkedin_ads_revoke_connection` — Revoke an owned connection (destructive — confirm with the user first)

### Competitor Research & Ad Library (no LinkedIn connection needed)
- `linkedin_ads_search_ad_library` — Search the LinkedIn Ad Library for any advertiser's ads with real creative, returned under `data`. **One company's ads → `advertiser_name`**; keyword search over ad copy → `search_terms`. `countries` is required
- `linkedin_ads_track_competitor` — Track an advertiser for daily collection, **by `name`** (exact match only; optional per-track `countries`)
- `linkedin_ads_untrack_competitor` — Stop tracking an advertiser
- `linkedin_ads_list_tracked_competitors` — Tracked advertisers with ad counts, `payer_ad_count`, countries and scrape health
- `linkedin_ads_list_competitor_ads` — A tracked advertiser's ads with full copy, including employee posts it paid for (`attribution: "payer"`)
- `linkedin_ads_get_competitor_ad` — One ad in full: copy, inline images, video frames, transcript, transparency data

### Feedback
- `linkedin_ads_developer_feedback` — Submit feature requests and workflow gap reports

> **Note:** Every tool call requires a `reason` (string) parameter for audit trail.

## Core Capabilities

### Report Types

1. **Campaign Group Performance** — Top-level metrics, spending, ROAS, and objective-based analysis
2. **Campaign Performance** — Targeting-level performance, audience efficiency, bidding analysis
3. **Creative Performance** — Ad effectiveness, headline/copy analysis, CTR and engagement
4. **Demographic Insights** — LinkedIn's unique professional audience pivots: job function, seniority, industry, company size, and more
5. **Competitor Research** — Any company's LinkedIn ads from the Ad Library: current creative, messaging themes, format mix, employee posts a company pays for, EU transparency data

### LinkedIn-Unique: MEMBER_* Demographic Pivots

`linkedin_ads_get_insights` supports demographic pivots unavailable on Meta or Google:

- **MEMBER_JOB_TITLE** — By job title
- **MEMBER_JOB_FUNCTION** — By job function (Engineering, Marketing, Sales, etc.)
- **MEMBER_SENIORITY** — By seniority level (Director, Manager, Entry, etc.)
- **MEMBER_INDUSTRY** — By industry vertical
- **MEMBER_COMPANY** — By company
- **MEMBER_COMPANY_SIZE** — By headcount range
- **MEMBER_COUNTRY_V2** / **MEMBER_REGION_V2** / **MEMBER_COUNTY** — Geographic breakdown

> **MEMBER_* pivots only work with `linkedin_ads_get_insights`** — not `linkedin_ads_get_performance_report`.

### Data Visualization

After fetching report data, proactively render charts to make insights more accessible. Use `linkedin_ads_render_chart` to visualize data — always pair charts with a summary table and textual insights.

**When to use each chart type:**
- **Campaign/entity comparisons** → bar chart (spend, ROAS, conversions by campaign group)
- **Trends over time** → timeseries chart (daily/weekly spend, CTR, conversions)
- **Conversion funnel** → funnel chart (impressions → clicks → leads)
- **Metric correlations** → scatter chart (spend vs ROAS, CPC vs CTR)
- **Budget breakdown** → waterfall chart (spend by campaign group with CPA coloring)
- **Demographic comparisons** → bar chart (CPA by job function, seniority, industry)

Charts enhance the report — they don't replace the analysis. Always include written insights alongside visualizations.

### Write Operations (Unsupported — Developer Feedback)

The MCP is **read-only toward LinkedIn** — it cannot create, change, pause, or delete campaigns, budgets, bids, creatives, or targeting. (It can change Hopkin-side state only: which competitors are tracked, and your LinkedIn connections.) When a user requests a LinkedIn write operation:

1. Inform them write operations are not yet available via Hopkin
2. Call `linkedin_ads_developer_feedback` with `feedback_type: "workflow_gap"`, a descriptive `title`, `description` of what was requested, and appropriate `priority`
3. Guide them to perform the action manually in LinkedIn Campaign Manager

### Proactive Efficiency Feedback

After completing a task, if a faster path should have existed (e.g., multiple calls that could have been one), call `linkedin_ads_developer_feedback` with `feedback_type: "new_tool"` or `"improvement"`. Submit feedback after delivering results — don't block the user's request.

### User Feedback

If a user wants to suggest improvements or report issues, call `linkedin_ads_developer_feedback` on their behalf with the appropriate `feedback_type` and their feedback in `description`.

## Report Workflows

### Campaign Group Performance Report

Analyze top-level campaign group performance, compare groups, and understand ROAS and conversion metrics by objective.

**Primary tool:** `linkedin_ads_get_performance_report` with `pivots: ["CAMPAIGN_GROUP"]`

**See detailed workflow:** **references/workflows/campaign-performance.md**

---

### Demographic Insights Report

Analyze the professional audience by job function, seniority, industry, company size, and other LinkedIn-exclusive dimensions.

**Primary tool:** `linkedin_ads_get_insights` with a `MEMBER_*` pivot (e.g., `MEMBER_JOB_FUNCTION`, `MEMBER_SENIORITY`)

**See detailed workflow:** **references/workflows/demographic-insights.md**

---

### Creative Performance Report

Evaluate individual creative effectiveness — headlines, copy, CTR, and engagement.

**Primary tools:** `linkedin_ads_list_creatives` + `linkedin_ads_get_performance_report` with `pivots: ["CREATIVE"]`

**See detailed workflow:** **references/workflows/creative-performance.md**

---

### Competitor Research (LinkedIn Ad Library)

See what other companies run on LinkedIn — real copy, CTAs, landing pages, formats, video frames — and track competitors so their ads keep being collected. **No LinkedIn connection is needed.**

**Primary tools:** `linkedin_ads_search_ad_library` (look without tracking), `linkedin_ads_track_competitor` → `linkedin_ads_list_competitor_ads` → `linkedin_ads_get_competitor_ad`

The rules that matter most:

- **LinkedIn's Ad Library is searched by advertiser NAME**, exactly as shown on the company's LinkedIn page. To see one company's ads, pass `advertiser_name` to `linkedin_ads_search_ad_library` — `search_terms` searches ad *copy*, which rarely names the advertiser. To track, pass `name` to `linkedin_ads_track_competitor`.
- **Exact match only.** A name not yet collected is looked up live (about 20–40 s) and tracked in the same call only if one advertiser has exactly that name. Near misses come back as **candidates with nothing tracked** — retry with the exact one (its `organization_id`, or `name` exactly as listed) or ask the user; never track a differently named company. No ads under that name → say so plainly.
- **A vanity slug is not a name.** `linkedin.com/company/acmeanalytics` is only a guess at "Acme Analytics"; if it misses, retry with `name`. A numeric `organization_id` works only for advertisers already collected.
- **`countries`** (ISO codes such as `["US", "GB", "DE"]`, or `["ALL"]`) sets where a competitor is tracked, in one call; omit it for the default tracking countries. It is **required** on `linkedin_ads_search_ad_library`.
- **Employee posts** a company pays for are listed with `attribution: "payer"` and `posted_by` (the person) — report them as employee posts, never as company-page ads. `linkedin_ads_list_tracked_competitors` shows `payer_ad_count`.
- **Tracking starts a background full collection that finishes later** (`seeded`, `full_scrape: "started"`). If a new track shows few or no ads yet, say the rest is still arriving — do not report "no ads".
- **A live search answers from the first page and collects the rest in the background.** While `linkedin_ads_search_ad_library` returns a `collection` block, the list is partial and has **no cursor**. Relay its `message`, don't paginate or call the list complete, and search again later with the same parameters and no cursor. An ad with `details_status: "pending"` hasn't had its full copy, run dates or landing page fetched yet, so don't present its preview as the full ad.

**See detailed workflow:** **references/workflows/competitor-research.md**

---

### Client-Side Tracking Audit (Browser)

When the numbers point at a tracking problem rather than a media problem, audit the site itself. The **Hopkin Tag Inspector** Chrome extension reports every analytics and ad tag that fired, per-vendor event counts, findings, and the conversions that were expected but never fired. On LinkedIn this catches an Insight Tag that loads but never fires its conversion on submit, leaving `linkedin_ads_get_partner_conversions` at zero with no way to tell a broken tag from genuinely zero demand.

This runs in the browser, not on the MCP server: it needs browser control, and Hopkin's servers cannot observe client-side tag behavior on their own.

**Step 1 — is the extension there?** Run this in the page:

```js
typeof window.__hopkinTagInspector
```

**If `"object"` — one call does it.** The session is already recording (every capturable page starts one on navigation):

```js
await window.__hopkinTagInspector.getAudit()
```

Returns `events.total`, `vendors[]` (`vendor`, `eventCount`, `droppedCount`), `findings[]` (`severity`, `ruleId`), `coverage.missing` — the conversions expected and never fired, which is the highest-value field — and `redacted`. Also available: `status()`, `startRecording({ reset })`, `queryEvents({ vendor, eventName, limit })`. There is deliberately no `stopRecording`, and redaction cannot be disabled from the page.

If it returns `undefined`, **reload once and re-probe** — the API is absent until a reload after install. Still `undefined` means: not installed, this origin not granted, or a page Chrome refuses to let extensions script. Say which.

**If not installed:** https://chromewebstore.google.com/detail/hopkin-tag-inspector/ahgjbbnglgnladgimapeecjmhlhmacgg — free, no account. Send the user that link; retrying will not fix it.

**Fuller playbook** — safety rules, operational traps, and three canned probes for auditing *without* the extension (inventory, config diff, safe conversion replay): read the MCP resource `hopkin://tag-inspector/tracking-audit`, or if you cannot read MCP resources, fetch https://www.hopkin.ai/tag-inspector. Prefer it when you can reach it; the summary above is enough to start.

---

## Workflow Process

1. **Account Selection** — Use `linkedin_ads_list_ad_accounts` if no account ID was given (competitor research needs no account)
2. **Date Range** — Default to last 30 days if not specified
3. **Report Type** — Match user intent to the appropriate report type
4. **Report Generation** — Use the appropriate tool
5. **Output** — Present data in clear tables with insights and recommendations

## Best Practices

### LinkedIn Hierarchy

- **Campaign Groups** hold budget and objective. Use `linkedin_ads_list_campaign_groups` to get budget config.
- **Campaigns** define targeting and bidding. Filter with `campaign_group_id` to drill into a group.
- **Creatives** hold ad content. Filter with `campaign_ids` to scope to a campaign.
- Practitioners often say "campaigns" when they mean Campaign Groups — clarify when in doubt.

### Date Ranges

- **1–7 days:** Recent changes, quick checks
- **7–30 days:** Standard performance evaluation
- **30–90+ days:** Seasonal trends, strategic planning
- Use `date_preset` for convenience; `start_date`/`end_date` for custom ranges

### Metric Selection

- **Brand Awareness:** Impressions, CPM
- **Traffic:** Clicks, CTR, CPC
- **Lead Generation:** Leads, cost per lead
- **Conversions:** Conversions, ROAS, CPA

### Partner Conversions

Before interpreting conversion metrics or ROAS, call `linkedin_ads_get_partner_conversions`. LinkedIn calls these "partner conversions" — not "conversion actions."

### Account IDs and URNs

LinkedIn account IDs are **numeric only** — strip any URN prefix, and pass the ID as a string:
- **Correct:** `"123456789"`
- **Incorrect:** `urn:li:sponsoredAccount:123456789`

Most Hopkin tools accept numeric IDs. `linkedin_ads_list_creatives` accepts both URN and numeric format for `creative_id`.

### Report Formatting

- Tables for multi-row data; currency symbols (e.g., $1,234.56); percentage format (e.g., 2.45%)
- Thousands separators; 2-decimal rounding for currency and rates
- Sort by spend, ROAS, or most relevant metric; include totals and date range metadata

### Error Handling

1. **Auth errors** — Run `linkedin_ads_check_auth_status`; if expired (60-day TTL), direct to https://app.hopkin.ai
2. **Account not found** — Ensure ID is numeric, no URN prefix
3. **Invalid pivot** — MEMBER_* pivots require `linkedin_ads_get_insights`
4. **No data** — Verify date range and campaign activity
5. **Competitor tracked but no ads yet** — The background full collection is still running; say so and check back, don't report "no ads"
6. See **references/troubleshooting.md** for more

---

## Troubleshooting

See **references/troubleshooting.md** for full guidance.

- **"MCP server not found"** — Verify Hopkin MCP config and token
- **"Not authenticated"** — Direct user to https://app.hopkin.ai
- **"Token expired"** — LinkedIn tokens expire after 60 days; reconnect at https://app.hopkin.ai
- **"Account not found"** — Account ID must be numeric (no URN prefix)
- **"No data"** — Check date range and campaign activity
- **"Invalid pivot"** — MEMBER_* pivots only work with `linkedin_ads_get_insights`
- **"Nothing was tracked" / candidates** — No advertiser has exactly that name; retry with the exact candidate or ask the user
- **Competitor ads look like another company's** — Use `advertiser_name`, not `search_terms`, for one company's ads

---

## Additional Resources

- **references/mcp-tools-reference.md** — Tool documentation, parameters, and usage examples
- **references/troubleshooting.md** — Error solutions and debugging steps
- **references/workflows/campaign-performance.md** — Campaign group & campaign performance
- **references/workflows/demographic-insights.md** — MEMBER_* demographic insights
- **references/workflows/creative-performance.md** — Creative performance
- **references/workflows/competitor-research.md** — Ad Library search and competitor tracking
- **references/workflows/budget-pacing.md** — Budget pacing and bid planning
- **references/workflows/common-actions.md** — Write operation feedback and optimization

---

**Requires:** Hopkin LinkedIn Ads MCP (https://app.hopkin.ai)
