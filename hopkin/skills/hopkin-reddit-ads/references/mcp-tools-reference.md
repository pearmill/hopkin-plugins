# Reddit Ads MCP Server Tools Reference — Hopkin

This document provides detailed reference information for the Hopkin Reddit Ads MCP tools and their usage patterns.

## Table of Contents

1. [MCP Server Overview](#mcp-server-overview)
2. [Authentication & Connection](#authentication--connection)
3. [Core Tools](#core-tools)
4. [Tool Usage Patterns](#tool-usage-patterns)
5. [Response Format](#response-format)
6. [Pagination](#pagination)
7. [Error Handling](#error-handling)
8. [Visualization Tools](#visualization-tools)
9. [Preference Tools](#preference-tools)
10. [Feedback & Health Tools](#feedback--health-tools)

---

## MCP Server Overview

### Hopkin Reddit Ads MCP

- **Service:** Hopkin — hosted MCP service
- **Sign up:** https://app.hopkin.ai
- **Type:** Hosted MCP (URL + auth token, no local installation)

### Required Configuration

Configure the Hopkin Reddit Ads MCP as a hosted MCP service in your Claude settings:

```json
{
  "mcpServers": {
    "hopkin-reddit-ads": {
      "type": "url",
      "url": "https://reddit.mcp.hopkin.ai/mcp",
      "headers": {
        "Authorization": "Bearer YOUR_HOPKIN_TOKEN"
      }
    }
  }
}
```

**Required Credentials:**
- **Hopkin Token** — Obtain from https://app.hopkin.ai after signing up

---

## Authentication & Connection

Hopkin uses OAuth. If a tool call fails with an auth error, call `reddit_ads_check_auth_status` to check. If not authenticated, direct the user to https://app.hopkin.ai to connect their Reddit Ads account. Reddit tokens expire after **1 hour** — Hopkin auto-refreshes tokens server-side, so users should not need to re-authenticate. If auth errors persist, direct the user to https://app.hopkin.ai to reconnect.

---

## Core Tools

> **Important:** Every Hopkin tool call requires a `reason` (string) parameter for audit trail.

### Authentication Tools

#### reddit_ads_check_auth_status
Troubleshoot authentication issues and get Reddit user profile info. Performs live validation against Reddit to confirm the provider token is still active.

**Parameters:**
- `reason` (string, required) — Reason for the call

**Returns:**
- `authenticated` (boolean)
- Reddit username
- Auth details (token status, refresh status)

> Only call this when another tool returns a permission or authentication error — do not call proactively on every request.

---

### Account Tools

#### reddit_ads_list_ad_accounts
List Reddit ad accounts accessible to the authenticated user. Reddit has **no manager/MCC account hierarchy** — all accounts are accessible directly.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, optional) — Fetch a single ad account by ID
- `account_ids` (array of strings, optional) — Fetch specific ad accounts by IDs (max 50)
- `limit` (number, optional) — Max accounts to return (default: 20, max: 100)
- `cursor` (string, optional) — Opaque pagination cursor from previous response
- `refresh` (boolean, optional) — Force fresh fetch from Reddit API (default: false)

**Example:**
```json
{
  "tool": "reddit_ads_list_ad_accounts",
  "parameters": {
    "reason": "Finding the user's Reddit Ads accounts"
  }
}
```

**Example — Single account lookup:**
```json
{
  "tool": "reddit_ads_list_ad_accounts",
  "parameters": {
    "reason": "Fetching details for a specific ad account",
    "account_id": "t2_abc123"
  }
}
```

---

### Campaign Tools

#### reddit_ads_list_campaigns
List campaigns for a Reddit ad account. Shows campaign name, status, objective, and budget (in micro units — divide by 1,000,000 for display currency).

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Reddit ad account ID
- `campaign_id` (string, optional) — Fetch a single campaign by ID
- `campaign_ids` (array of strings, optional) — Fetch specific campaigns by IDs (max 50)
- `status` (array of strings, optional) — Filter by status. Options: `ACTIVE`, `PAUSED`, `ARCHIVED`
- `search` (string, optional) — Case-insensitive search by campaign name
- `limit` (number, optional) — Max results (default: 20, max: 100)
- `cursor` (string, optional) — Opaque pagination cursor
- `refresh` (boolean, optional) — Force fresh fetch from Reddit API

**Example:**
```json
{
  "tool": "reddit_ads_list_campaigns",
  "parameters": {
    "reason": "Listing active campaigns for performance analysis",
    "account_id": "t2_abc123",
    "status": ["ACTIVE"]
  }
}
```

**Example — Search by name:**
```json
{
  "tool": "reddit_ads_list_campaigns",
  "parameters": {
    "reason": "Finding campaigns related to product launch",
    "account_id": "t2_abc123",
    "search": "product launch"
  }
}
```

---

### Ad Group Tools

#### reddit_ads_list_ad_groups
List ad groups for a Reddit ad account. Shows targeting configuration (including subreddit targeting), bid strategy, and campaign association.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Reddit ad account ID
- `ad_group_id` (string, optional) — Fetch a single ad group by ID
- `ad_group_ids` (array of strings, optional) — Fetch specific ad groups by IDs (max 50)
- `campaign_id` (string, optional) — Filter ad groups by parent campaign ID
- `status` (array of strings, optional) — Filter by status. Options: `ACTIVE`, `PAUSED`, `ARCHIVED`
- `limit` (number, optional) — Max results (default: 20, max: 100)
- `cursor` (string, optional) — Opaque pagination cursor
- `refresh` (boolean, optional) — Force fresh fetch from Reddit API

**Example:**
```json
{
  "tool": "reddit_ads_list_ad_groups",
  "parameters": {
    "reason": "Listing ad groups to review targeting configuration",
    "account_id": "t2_abc123",
    "status": ["ACTIVE"]
  }
}
```

**Example — Filter by parent campaign:**
```json
{
  "tool": "reddit_ads_list_ad_groups",
  "parameters": {
    "reason": "Listing ad groups under a specific campaign",
    "account_id": "t2_abc123",
    "campaign_id": "t3_campaign456"
  }
}
```

---

### Ad Tools

#### reddit_ads_list_ads
List ads for a Reddit ad account. Shows creative type, headline, click URL, post URL, and status.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Reddit ad account ID
- `ad_id` (string, optional) — Fetch a single ad by ID
- `ad_ids` (array of strings, optional) — Fetch specific ads by IDs (max 50)
- `ad_group_id` (string, optional) — Filter ads by parent ad group ID
- `status` (array of strings, optional) — Filter by status. Options: `ACTIVE`, `PAUSED`, `ARCHIVED`
- `limit` (number, optional) — Max results (default: 20, max: 100)
- `cursor` (string, optional) — Opaque pagination cursor
- `refresh` (boolean, optional) — Force fresh fetch from Reddit API

**Example:**
```json
{
  "tool": "reddit_ads_list_ads",
  "parameters": {
    "reason": "Listing active ads to review creative content",
    "account_id": "t2_abc123",
    "status": ["ACTIVE"]
  }
}
```

**Example — Filter by parent ad group:**
```json
{
  "tool": "reddit_ads_list_ads",
  "parameters": {
    "reason": "Listing ads under a specific ad group for creative analysis",
    "account_id": "t2_abc123",
    "ad_group_id": "t5_adgroup789"
  }
}
```

---

### Audience Tools

#### reddit_ads_list_custom_audiences
List custom audiences for targeting. Shows audience name, type, status, and size.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Reddit ad account ID
- `audience_id` (string, optional) — Fetch a single audience by ID
- `audience_ids` (array of strings, optional) — Fetch specific audiences by IDs (max 50)
- `limit` (number, optional) — Max results (default: 20, max: 100)
- `cursor` (string, optional) — Opaque pagination cursor
- `refresh` (boolean, optional) — Force fresh fetch from Reddit API

**Example:**
```json
{
  "tool": "reddit_ads_list_custom_audiences",
  "parameters": {
    "reason": "Reviewing available custom audiences for targeting",
    "account_id": "t2_abc123"
  }
}
```

---

### Analytics Tools

#### reddit_ads_get_performance_report
**Primary analytics tool.** Get a performance report with optional breakdowns and entity filters. Returns JSON text directly.

Supports up to 3 breakdown dimensions per request. The `community` breakdown provides subreddit-level performance data — Reddit's unique dimension for understanding which communities drive results.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Reddit ad account ID
- `date_start` (string, required) — Start date (YYYY-MM-DD)
- `date_end` (string, required) — End date (YYYY-MM-DD)
- `campaign_ids` (array of strings, optional) — Filter to specific campaign IDs
- `ad_group_ids` (array of strings, optional) — Filter to specific ad group IDs
- `ad_ids` (array of strings, optional) — Filter to specific ad IDs
- `breakdown` (array of strings, optional) — Dimensions to break down by (max 3). Options: `campaign`, `ad_group`, `ad`, `community`, `date`, `country`, `region`, `placement`, `device_os`

**Key Metrics Returned:**
- **Delivery:** impressions, clicks, CTR, CPC, CPM, spend
- **Engagement:** upvotes, downvotes, comments
- **Video:** video views, video completions, video view rates
- **Conversions:** conversion metrics (where configured)

**Example — Campaign-level breakdown:**
```json
{
  "tool": "reddit_ads_get_performance_report",
  "parameters": {
    "reason": "Generating campaign performance report for last 30 days",
    "account_id": "t2_abc123",
    "date_start": "2026-02-14",
    "date_end": "2026-03-16",
    "breakdown": ["campaign"]
  }
}
```

**Example — Subreddit (community) analysis:**
```json
{
  "tool": "reddit_ads_get_performance_report",
  "parameters": {
    "reason": "Analyzing which subreddits drive the best performance",
    "account_id": "t2_abc123",
    "date_start": "2026-02-14",
    "date_end": "2026-03-16",
    "breakdown": ["community"]
  }
}
```

**Example — Daily trend by campaign:**
```json
{
  "tool": "reddit_ads_get_performance_report",
  "parameters": {
    "reason": "Daily spend trend by campaign for budget pacing",
    "account_id": "t2_abc123",
    "date_start": "2026-02-14",
    "date_end": "2026-03-16",
    "breakdown": ["campaign", "date"]
  }
}
```

**Example — Device and placement breakdown:**
```json
{
  "tool": "reddit_ads_get_performance_report",
  "parameters": {
    "reason": "Analyzing performance by device and placement",
    "account_id": "t2_abc123",
    "date_start": "2026-02-14",
    "date_end": "2026-03-16",
    "breakdown": ["device_os", "placement"]
  }
}
```

**Example — Filter to specific campaigns:**
```json
{
  "tool": "reddit_ads_get_performance_report",
  "parameters": {
    "reason": "Performance report for specific campaigns",
    "account_id": "t2_abc123",
    "date_start": "2026-02-14",
    "date_end": "2026-03-16",
    "campaign_ids": ["campaign_001", "campaign_002"],
    "breakdown": ["ad_group"]
  }
}
```

---

#### reddit_ads_get_account_summary
Get a high-level account summary over a date range. Returns JSON text directly.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Reddit ad account ID
- `date_start` (string, required) — Start date (YYYY-MM-DD)
- `date_end` (string, required) — End date (YYYY-MM-DD)

**Example:**
```json
{
  "tool": "reddit_ads_get_account_summary",
  "parameters": {
    "reason": "Getting account-level summary to start a performance review session",
    "account_id": "t2_abc123",
    "date_start": "2026-02-14",
    "date_end": "2026-03-16"
  }
}
```

---

## Tool Usage Patterns

### Pattern 1: Session Start — Account Selection
**Workflow:**
1. Call `reddit_ads_list_ad_accounts` to list available accounts
2. If multiple accounts, present a numbered list and ask the user to select
3. If only one account, use it automatically and confirm with the user

### Pattern 2: Account Overview & Performance Report
**Workflow:**
1. Use `reddit_ads_get_account_summary` for a quick high-level overview
2. Use `reddit_ads_get_performance_report` with `breakdown: ["campaign"]` for campaign-level breakdown
3. Present report with summary statistics and insights

### Pattern 3: Community (Subreddit) Analysis — Reddit-Unique
**Workflow:**
1. Use `reddit_ads_get_performance_report` with `breakdown: ["community"]` for subreddit-level performance
2. Identify top-performing subreddits by CTR, CPC, and conversion metrics
3. Cross-reference with `reddit_ads_list_ad_groups` to review subreddit targeting configuration
4. Provide recommendations on which communities to prioritize or exclude

### Pattern 4: Creative Analysis
**Workflow:**
1. Use `reddit_ads_list_ads` to get ad creative content (headlines, click URLs, post URLs)
2. Use `reddit_ads_get_performance_report` with `breakdown: ["ad"]` for ad-level metrics
3. Join creative content with performance data by ad ID
4. Identify top performers and underperformers
5. Analyze engagement metrics (upvotes, downvotes, comments) unique to Reddit

### Pattern 5: Audience Review
**Workflow:**
1. Use `reddit_ads_list_custom_audiences` to list available audiences with name, type, and size
2. Cross-reference with `reddit_ads_list_ad_groups` to see which audiences are in use
3. Identify unused audiences or opportunities for audience expansion

### Pattern 6: Write Operation Requested
**Workflow:**
1. Inform the user that write operations (create, update, pause, delete) are not yet available via Hopkin
2. Provide guidance on how to perform the action manually via Reddit Ads Manager (https://ads.reddit.com)

---

## Response Format

Hopkin tools return responses in two formats depending on the tool type:

### List Tools (ad accounts, campaigns, ad groups, ads, audiences)

Responses include two parts:

#### content
Human-readable markdown text summarizing the results.

#### structuredContent
Machine-readable JSON data for programmatic processing.

**Example Response Structure:**
```json
{
  "content": "Found 3 active campaigns for account t2_abc123...",
  "structuredContent": {
    "data": [
      {
        "campaign_id": "campaign_001",
        "name": "Spring Product Launch",
        "status": "ACTIVE",
        "objective": "CONVERSIONS",
        "budget_micro": 50000000
      }
    ]
  }
}
```

### Reporting Tools (performance report, account summary)

Return **JSON text directly** — no structuredContent wrapper. Parse the returned text as JSON for programmatic processing.

---

## Pagination

Hopkin list tools use cursor-based pagination:

- **`limit`** (1–100) — Number of results per page (default: 20)
- **`cursor`** — Opaque cursor string returned in the response to fetch the next page

**Example — Paginating through campaigns:**
```json
// First page
{
  "tool": "reddit_ads_list_campaigns",
  "parameters": {
    "reason": "Listing campaigns page 1",
    "account_id": "t2_abc123",
    "limit": 50
  }
}

// Next page (using cursor from previous response)
{
  "tool": "reddit_ads_list_campaigns",
  "parameters": {
    "reason": "Listing campaigns page 2",
    "account_id": "t2_abc123",
    "limit": 50,
    "cursor": "cursor_from_previous_response"
  }
}
```

---

## Error Handling

### Common Error Types

- **Authentication errors** — User not authenticated or Reddit token failed to refresh. Call `reddit_ads_check_auth_status` to confirm, then direct the user to https://app.hopkin.ai to reconnect.
- **Rate limiting** — Reddit API rate limit is approximately 1 request per second. Wait and retry with exponential backoff.
- **Account not found** — Verify account ID and user access. Ensure the account ID format is correct.
- **No data** — The requested date range or entity filters returned no results. Broaden the date range or remove filters.

### Error Handling Best Practices

1. **Always check auth first** — If tools return auth errors, run `reddit_ads_check_auth_status` and direct the user to https://app.hopkin.ai to re-authenticate
2. **Respect rate limits** — Reddit's API enforces ~1 req/sec. Avoid rapid sequential calls; batch where possible using `*_ids` parameters
3. **Handle pagination** — Don't assume all results are in the first page
4. **Handle micro units** — Budget values are in micro units (divide by 1,000,000 for display currency)
5. **Provide clear messages** — Translate errors into user-friendly guidance

---

## Visualization Tools

### reddit_ads_render_chart
Render a data visualization chart as an interactive MCP App UI. **Always call this when the user requests a chart, graph, map, or visualization** — never substitute a table or text summary. Fetch performance data first with reporting tools, then pass the structured data here.

**Parameters:**
- `reason` (string, required) — Brief explanation of the insight being shown
- `chart` (object, required) — Chart configuration object containing:
  - `type` (string, required) — Chart type: `bar`, `scatter`, `timeseries`, `funnel`, `waterfall`, `choropleth`
  - Additional fields depend on chart type (datasets, axes, labels, etc.)

**Supported Chart Types:**
- `bar` — Bar chart for comparing values across categories
- `scatter` — Scatter plot for correlations (e.g., spend vs. conversions)
- `timeseries` — Time series for trends over date ranges
- `funnel` — Funnel chart for conversion stages
- `waterfall` — Waterfall chart for cumulative totals
- `choropleth` — Geographic map for country/region breakdowns

**Example — Timeseries chart:**
```json
{
  "tool": "reddit_ads_render_chart",
  "parameters": {
    "reason": "Showing daily spend trend for the last 30 days",
    "chart": {
      "type": "timeseries",
      "title": "Daily Spend",
      "data": [
        { "date": "2026-02-14", "spend": 123.45 },
        { "date": "2026-02-15", "spend": 98.76 }
      ]
    }
  }
}
```

> The chart renderer renders entirely client-side as an MCP App resource. No data is sent externally — all rendering happens in the UI bundle.

---

## Preference Tools

Preferences allow persistent, per-entity storage of recurring settings — metric preferences, alert thresholds, and analysis defaults. Preferences auto-attach to list tool responses as `_stored_preferences`.

### reddit_ads_store_preference
Store a persistent preference for a Reddit ad entity. Use when you infer a recurring preference from the conversation (e.g., a user always wants ROAS, not CTR).

**Parameters:**
- `reason` (string, required) — Reason for storing the preference
- `entity_type` (string, required) — Entity level: `ad_account`, `campaign`, `ad_set` (ad groups), or `ad`
- `entity_id` (string, required) — The entity's platform ID (e.g., `t2_abc123`)
- `key` (string, required) — Preference key (e.g., `preferred_conversion_metric`, `budget_alert_threshold`)
- `value` (any, required) — Value: string, number, boolean, or JSON object
- `source` (string, optional) — Who set it: `agent` (default), `user`, `system`
- `note` (string, optional) — Optional context about why this was set

**Example:**
```json
{
  "tool": "reddit_ads_store_preference",
  "parameters": {
    "reason": "User always asks for ROAS as the primary metric",
    "entity_type": "ad_account",
    "entity_id": "t2_abc123",
    "key": "preferred_conversion_metric",
    "value": "ROAS"
  }
}
```

---

### reddit_ads_get_preferences
Get all stored preferences for a Reddit ad entity.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `entity_type` (string, required) — Entity level: `ad_account`, `campaign`, `ad_set`, or `ad`
- `entity_id` (string, required) — The entity's platform ID

**Example:**
```json
{
  "tool": "reddit_ads_get_preferences",
  "parameters": {
    "reason": "Checking stored preferences before generating report",
    "entity_type": "ad_account",
    "entity_id": "t2_abc123"
  }
}
```

---

### reddit_ads_delete_preference
Delete a stored preference by key. No-op if it doesn't exist.

**Parameters:**
- `reason` (string, required) — Reason for deleting
- `entity_type` (string, required) — Entity level: `ad_account`, `campaign`, `ad_set`, or `ad`
- `entity_id` (string, required) — The entity's platform ID
- `key` (string, required) — The preference key to delete

**Example:**
```json
{
  "tool": "reddit_ads_delete_preference",
  "parameters": {
    "reason": "User no longer wants budget alerts",
    "entity_type": "campaign",
    "entity_id": "campaign_456",
    "key": "budget_alert_threshold"
  }
}
```

---

## Feedback & Health Tools

### reddit_ads_developer_feedback
Submit feedback about missing tools, improvements, bugs, or workflow gaps in the Reddit Ads MCP toolset. Use when the current tools cannot fulfill a user's request — not for user-facing auth or API errors.

**Parameters:**
- `reason` (string, required) — What triggered this feedback
- `feedback_type` (string, required) — Category: `new_tool`, `improvement`, `bug`, `workflow_gap`
- `title` (string, required) — Concise summary (5–200 characters)
- `description` (string, required) — What is needed and why (20–2000 characters)
- `priority` (string, optional) — `low`, `medium` (default), or `high`
- `current_workaround` (string, optional) — Current workaround, if any

**Example:**
```json
{
  "tool": "reddit_ads_developer_feedback",
  "parameters": {
    "reason": "User asked to pause 10 ad groups at once",
    "feedback_type": "workflow_gap",
    "title": "Bulk ad group status toggle",
    "description": "No way to pause or enable multiple ad groups at once. Must do one at a time via Reddit Ads Manager.",
    "priority": "high",
    "current_workaround": "Manually pause each ad group in Reddit Ads Manager"
  }
}
```

---

### reddit_ads_ping
Simple health check and connectivity test for the Reddit Ads MCP server.

**Parameters:**
- `reason` (string, required) — Reason for the ping
- `message` (string, optional) — Optional message to echo back

**Example:**
```json
{
  "tool": "reddit_ads_ping",
  "parameters": {
    "reason": "Verifying MCP server is reachable before starting session"
  }
}
```

---

**Document Version:** 1.1
**Last Updated:** 2026-03-16
**Service:** Hopkin Reddit Ads MCP (https://app.hopkin.ai)
