---
name: hopkin-reddit-ads
description: Build reports and analyze Reddit Ads campaigns using the Hopkin Reddit Ads MCP. Includes prerequisite checks, authentication flow, campaign and ad group performance reporting, community (subreddit) breakdown insights, and custom audience analysis.
---

# Reddit Ads Skill

## Introduction

This skill enables Claude to build comprehensive reports and analyze Reddit Ads campaigns via the Hopkin Reddit Ads MCP. Use this skill to:

- Generate performance reports across campaigns, ad groups, and ads
- Analyze campaign metrics, spend, and conversion patterns
- Leverage Reddit's unique community (subreddit) breakdown for placement insights
- Analyze custom audience composition and targeting effectiveness

## Prerequisites

### Check for MCP Availability

Check for `reddit_ads_` prefixed tools (e.g., `reddit_ads_check_auth_status`). If none are found, the MCP is not configured.

### If Hopkin Reddit Ads MCP Is Not Installed

Inform the user and provide setup instructions:

> The Hopkin Reddit Ads MCP is not configured. To use this skill:
>
> 1. Sign up at **https://app.hopkin.ai**
> 2. Add the hosted MCP to your Claude configuration:
>
> ```json
> {
>   "mcpServers": {
>     "hopkin-reddit-ads": {
>       "type": "url",
>       "url": "https://reddit.mcp.hopkin.ai/mcp",
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

1. Call `reddit_ads_check_auth_status` to verify authentication
2. If not authenticated, direct the user to https://app.hopkin.ai to connect their Reddit Ads account

> **Note:** Reddit tokens have a **1-hour TTL** but auto-refresh server-side. If a previously-authenticated user gets auth errors, direct them to https://app.hopkin.ai to reconnect.

### Required Information

- **Ad Account ID** — Plain string ID (e.g., `t2_abc123`). Use `reddit_ads_list_ad_accounts` to look up accounts. No prefix conversion needed (unlike Meta's `act_` prefix).
- **Date Range** — Use `date_start`/`date_end` (YYYY-MM-DD format). There is no `date_preset` parameter.

### Multi-Account Selection

When `reddit_ads_list_ad_accounts` returns multiple accounts, present them as a numbered list and ask the user to confirm which account to use.

## Reddit Ads Hierarchy

| Reddit | Meta | Google | LinkedIn | Notes |
|---|---|---|---|---|
| Ad Account | Ad Account | Customer | Ad Account | Flat — no manager hierarchy |
| Campaign | Campaign | Campaign | Campaign Group | Top-level org unit; holds objective and budget |
| Ad Group | Ad Set | Ad Group | Campaign | Targeting, bidding, scheduling, subreddit targeting |
| Ad | Ad | Ad | Creative | Ad content and format |
| Custom Audience | Custom Audience | User List | — | Retargeting and lookalike audiences |

No MCC equivalent — all accounts are accessible directly; no `login_customer_id` needed.

## Available MCP Tools

### Authentication
- `reddit_ads_check_auth_status` — Verify auth and troubleshoot connection issues; only call when another tool returns an auth error, not proactively

### Accounts
- `reddit_ads_list_ad_accounts` — List accessible Reddit Ads accounts. Params: `account_id?`, `account_ids?`, `limit`, `cursor`, `refresh`, `reason`

### Campaigns
- `reddit_ads_list_campaigns` — List campaigns for an account. Params: `account_id` (required), `campaign_id?`, `campaign_ids?`, `status?` (ACTIVE/PAUSED/ARCHIVED), `search?`, `limit`, `cursor`, `refresh`, `reason`

### Ad Groups
- `reddit_ads_list_ad_groups` — List ad groups with targeting and bid strategy details. Params: `account_id` (required), `ad_group_id?`, `ad_group_ids?`, `campaign_id?`, `status?`, `limit`, `cursor`, `refresh`, `reason`

### Ads
- `reddit_ads_list_ads` — List ads. Params: `account_id` (required), `ad_id?`, `ad_ids?`, `ad_group_id?`, `status?`, `limit`, `cursor`, `refresh`, `reason`

### Custom Audiences
- `reddit_ads_list_custom_audiences` — List custom audiences for retargeting and lookalike targeting. Params: `account_id` (required), `audience_id?`, `audience_ids?`, `limit`, `cursor`, `refresh`, `reason`

### Analytics
- `reddit_ads_get_performance_report` — **Primary analytics tool.** Full-funnel report with breakdowns. Params: `account_id` (required), `date_start` (YYYY-MM-DD, required), `date_end` (YYYY-MM-DD, required), `campaign_ids?`, `ad_group_ids?`, `ad_ids?`, `breakdown?` (max 3 from: campaign, ad_group, ad, community, date, country, region, placement, device_os), `reason`
- `reddit_ads_get_account_summary` — Account-level summary. Params: `account_id` (required), `date_start` (YYYY-MM-DD, required), `date_end` (YYYY-MM-DD, required), `reason`

> **Note:** Every tool call requires a `reason` (string) parameter for audit trail.

## Core Capabilities

### Report Types

1. **Campaign Performance Reports** — Top-level campaign metrics, spending, and conversion analysis
2. **Ad Group Performance Reports** — Targeting-level performance including subreddit targeting info, bidding analysis
3. **Ad Creative Performance Reports** — Individual ad effectiveness, format analysis, engagement metrics
4. **Community (Subreddit) Insights** — Reddit-unique subreddit-level performance data; no equivalent on other platforms

### Reddit-Unique: Community Breakdown

`reddit_ads_get_performance_report` supports a `community` breakdown dimension that provides subreddit-level performance data — unavailable on any other ad platform:

- Use `breakdown: ["community"]` to see which subreddits drive the best results
- Combine with other breakdowns (max 3 total): e.g., `breakdown: ["community", "date"]` for subreddit trends over time
- Available breakdown dimensions: `campaign`, `ad_group`, `ad`, `community`, `date`, `country`, `region`, `placement`, `device_os`

> **Community breakdown is the only way to get subreddit-level data** — there is no separate `get_insights` tool.

### Reddit Engagement Metrics

Reddit ads behave like organic posts and include unique engagement metrics:

- **Upvotes / Downvotes** — Reddit's native voting signals
- **Comments** — Direct engagement on the ad post
- **Video metrics:** `video_started`, `video_watched_3s`, `video_watched_5s`, `video_watched_10s`, `video_watched_25%`, `video_watched_50%`, `video_watched_75%`, `video_watched_95%`, `video_watched_100%`
- **Web conversion types:** `purchase`, `add_to_cart`, `lead`, `page_visit`, `search`, `sign_up`, `view_content`

### Write Operations (Unsupported)

The MCP is **read-only**. When a user requests write operations (pause campaigns, adjust budgets, etc.):

1. Inform them write operations are not yet available via Hopkin
2. Guide them to perform the action manually in **Reddit Ads Manager**

> There is no `developer_feedback` tool for Reddit Ads yet. No feedback submission is available at this time.

## Report Workflows

### Campaign Performance Report

Analyze top-level campaign performance, compare campaigns, and understand conversion metrics by objective.

**Primary tool:** `reddit_ads_get_performance_report` with `breakdown: ["campaign"]`

**See detailed workflow:** **references/workflows/campaign-performance.md**

---

### Community (Subreddit) Insights Report

Analyze subreddit-level performance to understand which communities drive the best results — a Reddit-exclusive capability.

**Primary tool:** `reddit_ads_get_performance_report` with `breakdown: ["community"]`

**See detailed workflow:** **references/workflows/community-insights.md**

---

### Ad Group Performance Report

Evaluate ad group targeting effectiveness, bid strategy performance, and subreddit targeting configuration.

**Primary tools:** `reddit_ads_list_ad_groups` + `reddit_ads_get_performance_report` with `breakdown: ["ad_group"]`

**See detailed workflow:** **references/workflows/audience-targeting.md**

---

## Workflow Process

1. **Account Selection** — Use `reddit_ads_list_ad_accounts` to find and confirm the account
2. **Date Range** — Default to last 30 days if not specified; use `date_start`/`date_end` (YYYY-MM-DD)
3. **Report Type** — Match user intent to the appropriate report type
4. **Report Generation** — Use the appropriate tool with relevant breakdowns
5. **Output** — Present data in clear tables with insights and recommendations

## Best Practices

### Reddit Hierarchy

- **Campaigns** hold the objective and budget. Use `reddit_ads_list_campaigns` to get campaign config.
- **Ad Groups** define targeting, bidding, and subreddit placements. Filter with `campaign_id` to drill into a campaign.
- **Ads** hold ad content and format. Filter with `ad_group_id` to scope to an ad group.
- **Custom Audiences** define retargeting and lookalike segments. Use `reddit_ads_list_custom_audiences` to review audience composition.

### Date Ranges

- **1-7 days:** Recent changes, quick checks
- **7-30 days:** Standard performance evaluation
- **30-90+ days:** Seasonal trends, strategic planning
- Always use `date_start`/`date_end` in YYYY-MM-DD format — there is no `date_preset` parameter

### Metric Selection

- **Brand Awareness:** Impressions, CPM
- **Traffic:** Clicks, CTR, CPC
- **Conversions:** Conversions, ROAS, CPA
- **Engagement:** Upvotes, downvotes, comments (Reddit-unique)
- **Video:** View rates at various completion thresholds

### Budget Values

Reddit returns budget values in **micro units** — divide by 1,000,000 for actual currency amounts. For example, a value of `50000000` = $50.00.

### Rate Limiting and Caching

Reddit's API has an approximately **1 request/second** rate limit. Use the `refresh` parameter sparingly — cached data is returned by default. Only set `refresh: true` when you need the latest data and the user has indicated data may be stale.

### Account IDs

Reddit account IDs are **plain strings** — no prefix conversion needed (unlike Meta's `act_` prefix). Use them exactly as returned by `reddit_ads_list_ad_accounts`.

### Report Formatting

- Tables for multi-row data; currency symbols (e.g., $1,234.56); percentage format (e.g., 2.45%)
- Thousands separators; 2-decimal rounding for currency and rates
- Sort by spend, ROAS, or most relevant metric; include totals and date range metadata
- Remember to convert micro-unit budgets to readable currency values

### Error Handling

1. **Auth errors** — Run `reddit_ads_check_auth_status`; if auth fails, direct to https://app.hopkin.ai to reconnect
2. **Account not found** — Verify account ID with `reddit_ads_list_ad_accounts`
3. **Invalid breakdown** — Max 3 breakdown dimensions; must be from: campaign, ad_group, ad, community, date, country, region, placement, device_os
4. **No data** — Verify date range and campaign activity
5. See **references/troubleshooting.md** for more

### Key API Differences from Other Plugins

- Uses `date_start`/`date_end` (YYYY-MM-DD) — NOT `date_preset` or `start_date`/`end_date`
- Uses `breakdown` array — NOT `pivots`
- No `get_insights` tool — use `get_performance_report` with breakdowns for all analytics
- No demographic pivots (unlike LinkedIn's MEMBER_* dimensions)
- Account IDs are plain strings (no prefix like Meta's `act_`)
- No MCC/manager hierarchy (flat, like LinkedIn)

---

## Troubleshooting

See **references/troubleshooting.md** for full guidance.

- **"MCP server not found"** — Verify Hopkin MCP config and token
- **"Not authenticated"** — Direct user to https://app.hopkin.ai
- **"Token expired"** — Reddit tokens auto-refresh server-side (1-hour expiry); if persistent, reconnect at https://app.hopkin.ai
- **"Account not found"** — Verify account ID with `reddit_ads_list_ad_accounts`
- **"No data"** — Check date range and campaign activity
- **"Invalid breakdown"** — Max 3 dimensions; use valid values only
- **"Rate limited"** — Wait briefly and retry; avoid unnecessary `refresh: true` calls

---

## Additional Resources

- **references/mcp-tools-reference.md** — Tool documentation, parameters, and usage examples
- **references/troubleshooting.md** — Error solutions and debugging steps
- **references/workflows/campaign-performance.md** — Campaign performance reporting
- **references/workflows/community-insights.md** — Subreddit-level community insights
- **references/workflows/audience-targeting.md** — Ad group and audience targeting analysis
- **references/workflows/common-actions.md** — Common actions and optimization patterns

---

**Skill Version:** 1.0
**Last Updated:** 2026-03-16
**Requires:** Hopkin Reddit Ads MCP (https://app.hopkin.ai)
