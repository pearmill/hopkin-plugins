---
name: hopkin-linkedin-ads
description: Generate LinkedIn Ads performance reports and analytics using the Hopkin LinkedIn Ads MCP. Includes prerequisite checks, authentication flow, report generation workflows, demographic insights using LinkedIn's unique MEMBER_* pivots, and developer feedback for unsupported write operations.
---

# LinkedIn Ads Skill

## Introduction

This skill enables Claude to build comprehensive reports and analyze LinkedIn Ads campaigns via the Hopkin LinkedIn Ads MCP. Use this skill to:

- Generate performance reports across campaign groups, campaigns, or creatives
- Analyze campaign metrics, ROAS, and spending patterns
- Leverage LinkedIn's unique professional demographic audience (job title, seniority, industry, etc.)
- Analyze creative effectiveness

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

### Quick Start with Preferences

At session start, call `linkedin_ads_get_preferences` with `entity_type: "ad_account"` and `entity_id: "default"`. If a `default_account_id` exists, use it automatically: "Using your saved account [X]. Use a different one? Let me know." Otherwise, look up the account ID.

### Required Information

- **Ad Account ID** — Numeric ID (e.g., `123456789`). Use `linkedin_ads_list_ad_accounts` to look up by company name.
- **Date Range** — Use `date_preset` (e.g., `LAST_30_DAYS`) or `start_date`/`end_date` (YYYY-MM-DD)

### Multi-Account Selection

When `linkedin_ads_list_ad_accounts` returns multiple accounts, present them as a numbered list, ask the user to confirm, then offer to save the selection via `linkedin_ads_store_preference` (`entity_type: "ad_account"`, `entity_id: "default"`, `key: "default_account_id"`).

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

### Preferences
- `linkedin_ads_store_preference` — Store a persistent preference for a LinkedIn Ads entity
- `linkedin_ads_get_preferences` — Retrieve stored preferences for an entity
- `linkedin_ads_delete_preference` — Delete a stored preference by key

### Visualization
- `linkedin_ads_render_chart` — **MCP App.** Renders interactive data visualization charts. Supports bar, scatter, timeseries, funnel, waterfall, and choropleth chart types. Use after fetching data with analytics tools to present visual reports. Always render charts when presenting performance trends, campaign comparisons, or demographic data — do not substitute a table or text summary when a chart is requested.

### Feedback
- `linkedin_ads_developer_feedback` — Submit feature requests and workflow gap reports

> **Note:** Every tool call requires a `reason` (string) parameter for audit trail.

## Core Capabilities

### Report Types

1. **Campaign Group Performance** — Top-level metrics, spending, ROAS, and objective-based analysis
2. **Campaign Performance** — Targeting-level performance, audience efficiency, bidding analysis
3. **Creative Performance** — Ad effectiveness, headline/copy analysis, CTR and engagement
4. **Demographic Insights** — LinkedIn's unique professional audience pivots: job function, seniority, industry, company size, and more

### LinkedIn-Unique: MEMBER_* Demographic Pivots

`linkedin_ads_get_insights` supports demographic pivots unavailable on Meta or Google:

- **MEMBER_JOB_TITLE** — By job title
- **MEMBER_JOB_FUNCTION** — By job function (Engineering, Marketing, Sales, etc.)
- **MEMBER_SENIORITY** — By seniority level (Director, Manager, Entry, etc.)
- **MEMBER_INDUSTRY** — By industry vertical
- **MEMBER_COMPANY** — By company
- **MEMBER_COMPANY_SIZE** — By headcount range
- **MEMBER_COUNTRY** / **MEMBER_REGION** — Geographic breakdown
- **MEMBER_AGE** — By age group

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

The MCP is **read-only**. When a user requests write operations:

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

## Workflow Process

1. **Account Selection** — Check preferences for stored default; use `linkedin_ads_list_ad_accounts` if needed
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

LinkedIn account IDs are **numeric only** — strip any URN prefix before API calls:
- **Correct:** `123456789`
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
5. See **references/troubleshooting.md** for more

---

## Troubleshooting

See **references/troubleshooting.md** for full guidance.

- **"MCP server not found"** — Verify Hopkin MCP config and token
- **"Not authenticated"** — Direct user to https://app.hopkin.ai
- **"Token expired"** — LinkedIn tokens expire after 60 days; reconnect at https://app.hopkin.ai
- **"Account not found"** — Account ID must be numeric (no URN prefix)
- **"No data"** — Check date range and campaign activity
- **"Invalid pivot"** — MEMBER_* pivots only work with `linkedin_ads_get_insights`

---

## Additional Resources

- **references/mcp-tools-reference.md** — Tool documentation, parameters, and usage examples
- **references/troubleshooting.md** — Error solutions and debugging steps
- **references/workflows/campaign-performance.md** — Campaign group & campaign performance
- **references/workflows/demographic-insights.md** — MEMBER_* demographic insights
- **references/workflows/creative-performance.md** — Creative performance
- **references/workflows/common-actions.md** — Write operation feedback and optimization

---

**Skill Version:** 1.1
**Last Updated:** 2026-03-05
**Requires:** Hopkin LinkedIn Ads MCP (https://app.hopkin.ai)
