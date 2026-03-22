---
name: hopkin-tiktok-ads
description: Build reports and analyze TikTok Ads campaigns using the Hopkin TikTok Ads MCP. Includes prerequisite checks, authentication flow, campaign and ad group performance reporting, video/creative performance analysis, audience demographic insights, and advertiser management.
---

# TikTok Ads Skill

## Introduction

This skill enables Claude to build comprehensive reports and analyze TikTok Ads campaigns via the Hopkin TikTok Ads MCP. Use this skill to:

- Generate performance reports across campaigns, ad groups, and ads
- Analyze video and creative performance with TikTok-specific engagement metrics
- Leverage TikTok's audience insights for demographic breakdowns by age, gender, and country
- Review advertiser account structure, budgets, and pacing

## Prerequisites

### Check for MCP Availability

Check for `tiktok_ads_` prefixed tools (e.g., `tiktok_ads_check_auth_status`). If none are found, the MCP is not configured.

### If Hopkin TikTok Ads MCP Is Not Installed

Inform the user and provide setup instructions:

> The Hopkin TikTok Ads MCP is not configured. To use this skill:
>
> 1. Sign up at **https://app.hopkin.ai**
> 2. Add the hosted MCP to your Claude configuration:
>
> ```json
> {
>   "mcpServers": {
>     "hopkin-tiktok-ads": {
>       "type": "url",
>       "url": "https://tiktok.mcp.hopkin.ai/mcp",
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

1. Call `tiktok_ads_check_auth_status` to verify authentication
2. If not authenticated, call `tiktok_ads_get_login_url` to get the TikTok OAuth login URL and direct the user to complete login
3. Alternatively, direct the user to https://app.hopkin.ai to connect their TikTok Ads account

> **Note:** If a previously-authenticated user gets auth errors, direct them to https://app.hopkin.ai to reconnect their TikTok account.

### Required Information

- **Advertiser ID** — TikTok's equivalent of an ad account ID. Use `tiktok_ads_list_advertisers` to look up advertisers.
- **Date Range** — Use `date_preset` (e.g., `LAST_7_DAYS`, `LAST_30_DAYS`) or `start_date`/`end_date` (YYYY-MM-DD format).

### Multi-Account Selection

When `tiktok_ads_list_advertisers` returns multiple advertisers, present them as a numbered list and ask the user to confirm which advertiser to use.

## TikTok Ads Hierarchy

| TikTok | Meta | Google | LinkedIn | Reddit |
|---|---|---|---|---|
| Advertiser | Ad Account | Customer | Ad Account | Ad Account |
| Campaign | Campaign | Campaign | Campaign Group | Campaign |
| Ad Group | Ad Set | Ad Group | Campaign | Ad Group |
| Ad | Ad | Ad | Creative | Ad |

No manager/MCC hierarchy — advertisers are accessed directly; no `login_customer_id` needed.

## Available MCP Tools

### Authentication
- `tiktok_ads_ping` — Health check and connectivity test. Params: `message?`, `reason`
- `tiktok_ads_check_auth_status` — Verify auth and troubleshoot connection issues; only call when another tool returns an auth error, not proactively. Params: `reason`
- `tiktok_ads_get_login_url` — Get TikTok OAuth login URL for user authentication. Params: `reason`
- `tiktok_ads_get_user_info` — Get authenticated user info. Params: `reason`

### Accounts
- `tiktok_ads_list_advertisers` — List accessible TikTok advertisers (ad accounts). Params: `advertiser_id?`, `limit?`, `cursor?`, `reason`
- `tiktok_ads_get_advertiser` — Get a single advertiser's details. Params: `advertiser_id` (required), `reason`

### Campaigns
- `tiktok_ads_list_campaigns` — List campaigns for an advertiser. Params: `advertiser_id` (required), `campaign_id?`, `campaign_ids?`, `status?` (ENABLE/DISABLE/DELETE), `search?`, `limit?`, `cursor?`, `reason`
- `tiktok_ads_get_campaign` — Get a single campaign. Params: `advertiser_id` (required), `campaign_id` (required), `reason`

### Ad Groups
- `tiktok_ads_list_ad_groups` — List ad groups with targeting and bid details. Params: `advertiser_id` (required), `adgroup_id?`, `adgroup_ids?`, `campaign_ids?`, `status?` (ENABLE/DISABLE/DELETE), `search?`, `limit?`, `cursor?`, `reason`
- `tiktok_ads_get_ad_group` — Get a single ad group. Params: `advertiser_id` (required), `adgroup_id` (required), `reason`

### Ads
- `tiktok_ads_list_ads` — List ads. Params: `advertiser_id` (required), `ad_id?`, `ad_ids?`, `campaign_ids?`, `adgroup_ids?`, `status?` (ENABLE/DISABLE/DELETE), `search?`, `limit?`, `cursor?`, `reason`
- `tiktok_ads_get_ad` — Get a single ad. Params: `advertiser_id` (required), `ad_id` (required), `reason`

### Analytics
- `tiktok_ads_get_performance_report` — **Primary analytics tool.** Performance report at campaign, ad group, or ad level. Params: `advertiser_id` (required), `level` (required: `campaign`, `adgroup`, or `ad`), `date_preset?`, `start_date?`, `end_date?`, `campaign_id?`, `adgroup_id?`, `page?`, `page_size?`, `reason`
- `tiktok_ads_get_insights` — **Custom reporting** with configurable dimensions and metrics. Supports AUDIENCE report type for demographic breakdowns. Params: `advertiser_id` (required), `report_type?` (BASIC/AUDIENCE), `data_level` (required), `dimensions` (required), `metrics?`, `start_date?`, `end_date?`, `lifetime?`, `page?`, `page_size?`, `reason`
- `tiktok_ads_get_creative_report` — **Video/creative performance** metrics including video completion rates and social engagement. Params: `advertiser_id` (required), `campaign_id?`, `adgroup_id?`, `start_date?`, `end_date?`, `page?`, `page_size?`, `reason`

### Creative
- `tiktok_ads_preview_ads` — MCP App: visual ad previews with optional metric overlays. Params: `advertiser_id` (required), `ads` (required: array of `{ad_id, metrics?}`), `metric_labels?`, `reason`

### Audiences
- `tiktok_ads_list_audiences` — List audiences for targeting. Params: `advertiser_id` (required), `limit?`, `cursor?`, `reason`

### Feedback
- `tiktok_ads_developer_feedback` — Submit feedback about missing tools, improvements, bugs, or workflow gaps in the MCP toolset. Not for user-facing auth/API errors. Params: `feedback_type` (new_tool|improvement|bug|workflow_gap), `title`, `description`, `priority?`, `current_workaround?`, `reason`

> **Note:** Every tool call requires a `reason` (string) parameter for audit trail.

## Core Capabilities

### Report Types

1. **Campaign Performance Reports** — Top-level campaign metrics, spending, and conversion analysis using `tiktok_ads_get_performance_report` with `level: "campaign"`
2. **Ad Group Performance Reports** — Targeting-level performance, bid strategy analysis using `tiktok_ads_get_performance_report` with `level: "adgroup"`
3. **Ad Performance Reports** — Individual ad effectiveness and engagement using `tiktok_ads_get_performance_report` with `level: "ad"`
4. **Video/Creative Analysis** — TikTok-unique video engagement metrics via `tiktok_ads_get_creative_report`
5. **Audience Insights** — Demographic breakdowns (age, gender, country) via `tiktok_ads_get_insights` with `report_type: "AUDIENCE"`
6. **Budget & Pacing** — Budget utilization and spend pacing from campaign and ad group data

### TikTok-Unique: Video Performance Metrics

TikTok is a video-first platform, and `tiktok_ads_get_creative_report` provides video-specific metrics unavailable on most other platforms:

- **video_play_actions** — Total video play actions
- **video_watched_2s** — Video watched for at least 2 seconds
- **video_watched_6s** — Video watched for at least 6 seconds
- **profile_visits** — Users who visited the advertiser's profile after viewing the ad
- **likes** — Total likes on the ad
- **shares** — Total shares of the ad
- **comments** — Total comments on the ad

> Use `tiktok_ads_get_creative_report` to analyze which creatives and videos drive the highest engagement. This is essential for TikTok where creative quality directly determines ad performance.

### TikTok-Unique: Audience Insights

`tiktok_ads_get_insights` with `report_type: "AUDIENCE"` provides demographic breakdowns unavailable through the standard performance report:

- Break down performance by **age**, **gender**, **country**, and other audience dimensions
- Use the `dimensions` parameter to specify which demographic dimensions to include
- Set `data_level` to scope the report to campaign, ad group, or ad level
- Combine with date ranges to understand how audience composition shifts over time

> **Audience insights are only available through `get_insights`** with `report_type: "AUDIENCE"` — the standard `get_performance_report` does not support demographic breakdowns.

### Data Visualization

TikTok Ads MCP does **not** include a `render_chart` tool. When the user requests charts or visualizations:

1. Present data in well-formatted **markdown tables**
2. Highlight key trends and comparisons in the analysis narrative
3. Use clear formatting with currency symbols, percentages, and thousands separators

### Write Operations (Unsupported)

The MCP is **read-only**. When a user requests write operations (pause campaigns, adjust budgets, etc.):

1. Inform them write operations are not yet available via Hopkin
2. Guide them to perform the action manually in **TikTok Ads Manager**
3. Use `tiktok_ads_developer_feedback` with `feedback_type: "workflow_gap"` to report the gap to the development team

## Report Workflows

### Campaign Performance Report

Analyze top-level campaign performance, compare campaigns, and understand conversion metrics by objective.

**Primary tool:** `tiktok_ads_get_performance_report` with `level: "campaign"`

**See detailed workflow:** **references/workflows/campaign-performance.md**

---

### Video/Creative Analysis Report

Analyze video and creative performance to understand which content drives the best engagement and completion rates.

**Primary tool:** `tiktok_ads_get_creative_report`

**See detailed workflow:** **references/workflows/creative-performance.md**

---

### Audience Insights Report

Analyze audience demographics to understand which age groups, genders, and regions deliver the best results.

**Primary tool:** `tiktok_ads_get_insights` with `report_type: "AUDIENCE"`

**See detailed workflow:** **references/workflows/audience-insights.md**

---

### Ad Group Performance Report

Evaluate ad group targeting effectiveness, bid strategy performance, and budget allocation.

**Primary tools:** `tiktok_ads_list_ad_groups` + `tiktok_ads_get_performance_report` with `level: "adgroup"`

**See detailed workflow:** **references/workflows/common-actions.md#optimization-workflow-by-campaign-objective**

---

## Workflow Process

1. **Advertiser Selection** — Use `tiktok_ads_list_advertisers` to find and confirm the advertiser
2. **Date Range** — Default to last 30 days if not specified; use `date_preset` (e.g., `LAST_30_DAYS`) or `start_date`/`end_date` (YYYY-MM-DD)
3. **Report Type** — Match user intent to the appropriate report type and tool
4. **Report Generation** — Use the appropriate tool with relevant parameters
5. **Output** — Present data in clear tables with insights and recommendations

## Best Practices

### TikTok Hierarchy

- **Advertisers** are TikTok's ad accounts. Use `tiktok_ads_list_advertisers` to find them; the ID goes in `advertiser_id`.
- **Campaigns** hold the objective and budget. Use `tiktok_ads_list_campaigns` to get campaign config.
- **Ad Groups** define targeting, bidding, and scheduling. Filter with `campaign_ids` to drill into a campaign. Note: parameter names use `adgroup` (no underscore) — e.g., `adgroup_id`, `adgroup_ids`.
- **Ads** hold ad content, creative, and format. Filter with `adgroup_ids` to scope to an ad group.

### Date Ranges

- **1-7 days:** Recent changes, quick checks — use `date_preset: "LAST_7_DAYS"`
- **7-30 days:** Standard performance evaluation — use `date_preset: "LAST_30_DAYS"`
- **30-90+ days:** Seasonal trends, strategic planning — use `start_date`/`end_date` in YYYY-MM-DD format
- Two options: `date_preset` (e.g., `LAST_7_DAYS`, `LAST_30_DAYS`) OR `start_date`/`end_date` — do not mix both

### Metric Selection

- **Brand Awareness:** Impressions, reach, CPM
- **Traffic:** Clicks, CTR, CPC
- **Conversions:** Conversions, ROAS, CPA, cost_per_conversion
- **Video Engagement:** video_play_actions, video_watched_2s, video_watched_6s
- **Social Engagement:** likes, shares, comments, profile_visits

### Status Values

TikTok uses different status values than other platforms:

| TikTok | Meta | Google | Reddit |
|---|---|---|---|
| ENABLE | ACTIVE | ENABLED | ACTIVE |
| DISABLE | PAUSED | PAUSED | PAUSED |
| DELETE | DELETED | REMOVED | ARCHIVED |

### Pagination

TikTok uses **page-based pagination** (`page`, `page_size`) for analytics tools, and **cursor-based pagination** (`limit`, `cursor`) for list tools. Use the appropriate pagination style for each tool.

### Advertiser IDs

TikTok advertiser IDs are **numeric strings**. Use them exactly as returned by `tiktok_ads_list_advertisers`.

### Report Formatting

- Tables for multi-row data; currency symbols (e.g., $1,234.56); percentage format (e.g., 2.45%)
- Thousands separators; 2-decimal rounding for currency and rates
- Sort by spend, ROAS, or most relevant metric; include totals and date range metadata
- No chart rendering available — use tables and narrative analysis

## Error Handling

1. **Auth errors** — Run `tiktok_ads_check_auth_status`; if auth fails, use `tiktok_ads_get_login_url` or direct to https://app.hopkin.ai to reconnect
2. **Advertiser not found** — Verify advertiser ID with `tiktok_ads_list_advertisers`
3. **Invalid level** — `level` must be one of: `campaign`, `adgroup`, `ad`
4. **Invalid status** — Use `ENABLE`, `DISABLE`, or `DELETE` (not ACTIVE/PAUSED)
5. **No data** — Verify date range and campaign activity; try a broader date range
6. **Pagination issues** — Use `page`/`page_size` for analytics, `limit`/`cursor` for list tools
7. See **references/troubleshooting.md** for more

### Key API Differences from Other Plugins

- Uses `advertiser_id` — NOT `account_id` or `customer_id`
- Uses `adgroup_id` / `adgroup_ids` (no underscore) — NOT `ad_group_id`
- Uses `date_preset` or `start_date`/`end_date` — NOT `date_start`/`date_end`
- Status values are `ENABLE`/`DISABLE`/`DELETE` — NOT `ACTIVE`/`PAUSED`/`ARCHIVED`
- Has `get_insights` with AUDIENCE report type for demographic breakdowns — unique among Hopkin plugins
- Has `get_creative_report` for video-specific metrics — not available on all platforms
- No `render_chart` tool — present data as tables
- No preferences tools — no `store_preference`/`get_preferences`/`delete_preference`
- No MCC/manager hierarchy (flat, like Reddit and LinkedIn)

---

## Troubleshooting

See **references/troubleshooting.md** for full guidance.

- **"MCP server not found"** — Verify Hopkin MCP config and token at https://app.hopkin.ai
- **"Not authenticated"** — Use `tiktok_ads_get_login_url` or direct user to https://app.hopkin.ai
- **"Token expired"** — Direct user to reconnect at https://app.hopkin.ai
- **"Advertiser not found"** — Verify advertiser ID with `tiktok_ads_list_advertisers`
- **"No data"** — Check date range and campaign activity; TikTok may have reporting delays
- **"Invalid parameter"** — Check that `adgroup_id` (not `ad_group_id`) and status values (ENABLE/DISABLE/DELETE) are correct
- **"Rate limited"** — Wait briefly and retry; reduce page_size if fetching large datasets

---

## Additional Resources

- **references/mcp-tools-reference.md** — Tool documentation, parameters, and usage examples
- **references/troubleshooting.md** — Error solutions and debugging steps
- **references/workflows/campaign-performance.md** — Campaign performance reporting
- **references/workflows/creative-performance.md** — Video and creative performance analysis
- **references/workflows/audience-insights.md** — Audience demographic insights
- **references/workflows/common-actions.md** — Write operations, optimization patterns, and cross-platform comparison

---

**Skill Version:** 1.0
**Last Updated:** 2026-03-22
**Requires:** Hopkin TikTok Ads MCP (https://app.hopkin.ai)
