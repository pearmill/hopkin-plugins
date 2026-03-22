# TikTok Ads MCP Server Tools Reference — Hopkin

This document provides detailed reference information for the Hopkin TikTok Ads MCP tools and their usage patterns.

## Table of Contents

1. [MCP Server Overview](#mcp-server-overview)
2. [Authentication & Connection](#authentication--connection)
3. [Core Tools](#core-tools)
4. [Tool Usage Patterns](#tool-usage-patterns)
5. [Response Format](#response-format)
6. [Pagination](#pagination)
7. [Error Handling](#error-handling)
8. [Feedback & Health Tools](#feedback--health-tools)

---

## MCP Server Overview

### Hopkin TikTok Ads MCP

- **Service:** Hopkin — hosted MCP service
- **Sign up:** https://app.hopkin.ai
- **Type:** Hosted MCP (URL + auth token, no local installation)

### Required Configuration

Configure the Hopkin TikTok Ads MCP as a hosted MCP service in your Claude settings:

```json
{
  "mcpServers": {
    "hopkin-tiktok-ads": {
      "type": "url",
      "url": "https://tiktok.mcp.hopkin.ai/mcp",
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

Hopkin uses OAuth. If a tool call fails with an auth error, call `tiktok_ads_check_auth_status` to check. If not authenticated, use `tiktok_ads_get_login_url` to get the OAuth URL or direct the user to https://app.hopkin.ai to connect their TikTok Ads account. If auth errors persist, direct the user to https://app.hopkin.ai to reconnect.

---

## Core Tools

> **Important:** Every Hopkin tool call requires a `reason` (string) parameter for audit trail.

### Authentication Tools

#### tiktok_ads_check_auth_status
Troubleshoot authentication issues and verify the TikTok Ads connection status. Performs live validation to confirm the provider token is still active.

**Parameters:**
- `reason` (string, required) — Reason for the call

**Returns:**
- `authenticated` (boolean)
- Auth details (token status)

> Only call this when another tool returns a permission or authentication error — do not call proactively on every request.

**Example:**
```json
{
  "tool": "tiktok_ads_check_auth_status",
  "parameters": {
    "reason": "Checking if TikTok Ads account is connected"
  }
}
```

---

#### tiktok_ads_get_login_url
Get the OAuth login URL for connecting a TikTok Ads account.

**Parameters:**
- `reason` (string, required) — Reason for the call

**Returns:**
- OAuth login URL for TikTok Ads

**Example:**
```json
{
  "tool": "tiktok_ads_get_login_url",
  "parameters": {
    "reason": "User needs to authenticate with TikTok Ads"
  }
}
```

---

#### tiktok_ads_get_user_info
Get information about the authenticated TikTok Ads user.

**Parameters:**
- `reason` (string, required) — Reason for the call

**Returns:**
- User profile information from TikTok

**Example:**
```json
{
  "tool": "tiktok_ads_get_user_info",
  "parameters": {
    "reason": "Retrieving authenticated user profile details"
  }
}
```

---

### Advertiser Tools

#### tiktok_ads_list_advertisers
List TikTok Ads advertisers accessible to the authenticated user. TikTok uses `advertiser_id` as the primary account identifier.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `advertiser_id` (string, optional) — Fetch a single advertiser by ID
- `limit` (number, optional) — Max advertisers to return
- `cursor` (string, optional) — Pagination cursor from previous response

**Example:**
```json
{
  "tool": "tiktok_ads_list_advertisers",
  "parameters": {
    "reason": "Finding the user's TikTok Ads advertiser accounts"
  }
}
```

**Example — Single advertiser lookup:**
```json
{
  "tool": "tiktok_ads_list_advertisers",
  "parameters": {
    "reason": "Fetching details for a specific advertiser",
    "advertiser_id": "7012345678901234567"
  }
}
```

---

#### tiktok_ads_get_advertiser
Get details for a single TikTok Ads advertiser.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `advertiser_id` (string, required) — TikTok advertiser ID

**Example:**
```json
{
  "tool": "tiktok_ads_get_advertiser",
  "parameters": {
    "reason": "Getting advertiser details for account setup",
    "advertiser_id": "7012345678901234567"
  }
}
```

---

### Campaign Tools

#### tiktok_ads_list_campaigns
List campaigns for a TikTok Ads advertiser. Shows campaign name, status, objective, and budget.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `advertiser_id` (string, required) — TikTok advertiser ID
- `campaign_id` (string, optional) — Fetch a single campaign by ID
- `campaign_ids` (array of strings, optional) — Fetch specific campaigns by IDs
- `status` (string, optional) — Filter by status. Options: `ENABLE`, `DISABLE`, `DELETE`
- `search` (string, optional) — Search by campaign name
- `limit` (number, optional) — Max results per page
- `cursor` (string, optional) — Pagination cursor

**Example:**
```json
{
  "tool": "tiktok_ads_list_campaigns",
  "parameters": {
    "reason": "Listing enabled campaigns for performance analysis",
    "advertiser_id": "7012345678901234567",
    "status": "ENABLE"
  }
}
```

**Example — Search by name:**
```json
{
  "tool": "tiktok_ads_list_campaigns",
  "parameters": {
    "reason": "Finding campaigns related to product launch",
    "advertiser_id": "7012345678901234567",
    "search": "product launch"
  }
}
```

---

#### tiktok_ads_get_campaign
Get details for a single TikTok Ads campaign.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `advertiser_id` (string, required) — TikTok advertiser ID
- `campaign_id` (string, required) — Campaign ID

**Example:**
```json
{
  "tool": "tiktok_ads_get_campaign",
  "parameters": {
    "reason": "Fetching campaign details for budget review",
    "advertiser_id": "7012345678901234567",
    "campaign_id": "1234567890123"
  }
}
```

---

### Ad Group Tools

#### tiktok_ads_list_ad_groups
List ad groups for a TikTok Ads advertiser. Shows targeting configuration, bid strategy, and campaign association. Note: TikTok uses `adgroup_id` (no underscore between "ad" and "group").

**Parameters:**
- `reason` (string, required) — Reason for the call
- `advertiser_id` (string, required) — TikTok advertiser ID
- `adgroup_id` (string, optional) — Fetch a single ad group by ID
- `adgroup_ids` (array of strings, optional) — Fetch specific ad groups by IDs
- `campaign_ids` (array of strings, optional) — Filter ad groups by parent campaign IDs
- `status` (string, optional) — Filter by status. Options: `ENABLE`, `DISABLE`, `DELETE`
- `search` (string, optional) — Search by ad group name
- `limit` (number, optional) — Max results per page
- `cursor` (string, optional) — Pagination cursor

**Example:**
```json
{
  "tool": "tiktok_ads_list_ad_groups",
  "parameters": {
    "reason": "Listing ad groups to review targeting configuration",
    "advertiser_id": "7012345678901234567",
    "status": "ENABLE"
  }
}
```

**Example — Filter by parent campaign:**
```json
{
  "tool": "tiktok_ads_list_ad_groups",
  "parameters": {
    "reason": "Listing ad groups under a specific campaign",
    "advertiser_id": "7012345678901234567",
    "campaign_ids": ["1234567890123"]
  }
}
```

---

#### tiktok_ads_get_ad_group
Get details for a single TikTok Ads ad group.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `advertiser_id` (string, required) — TikTok advertiser ID
- `adgroup_id` (string, required) — Ad group ID

**Example:**
```json
{
  "tool": "tiktok_ads_get_ad_group",
  "parameters": {
    "reason": "Fetching ad group details for targeting review",
    "advertiser_id": "7012345678901234567",
    "adgroup_id": "9876543210987"
  }
}
```

---

### Ad Tools

#### tiktok_ads_list_ads
List ads for a TikTok Ads advertiser. Shows creative content, status, and ad group/campaign association.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `advertiser_id` (string, required) — TikTok advertiser ID
- `ad_id` (string, optional) — Fetch a single ad by ID
- `ad_ids` (array of strings, optional) — Fetch specific ads by IDs
- `campaign_ids` (array of strings, optional) — Filter ads by campaign IDs
- `adgroup_ids` (array of strings, optional) — Filter ads by ad group IDs
- `status` (string, optional) — Filter by status. Options: `ENABLE`, `DISABLE`, `DELETE`
- `search` (string, optional) — Search by ad name
- `limit` (number, optional) — Max results per page
- `cursor` (string, optional) — Pagination cursor

**Example:**
```json
{
  "tool": "tiktok_ads_list_ads",
  "parameters": {
    "reason": "Listing active ads to review creative content",
    "advertiser_id": "7012345678901234567",
    "status": "ENABLE"
  }
}
```

**Example — Filter by parent ad group:**
```json
{
  "tool": "tiktok_ads_list_ads",
  "parameters": {
    "reason": "Listing ads under a specific ad group for creative analysis",
    "advertiser_id": "7012345678901234567",
    "adgroup_ids": ["9876543210987"]
  }
}
```

---

### Audience Tools

#### tiktok_ads_list_audiences
List audiences for a TikTok Ads advertiser. Shows audience name, type, and status.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `advertiser_id` (string, required) — TikTok advertiser ID
- `limit` (number, optional) — Max results per page
- `cursor` (string, optional) — Pagination cursor

**Example:**
```json
{
  "tool": "tiktok_ads_list_audiences",
  "parameters": {
    "reason": "Reviewing available audiences for targeting",
    "advertiser_id": "7012345678901234567"
  }
}
```

---

### Analytics Tools

#### tiktok_ads_get_performance_report
**Primary analytics tool.** Get a performance report for campaigns, ad groups, or ads over a date range. Returns performance metrics at the specified level.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `advertiser_id` (string, required) — TikTok advertiser ID
- `level` (string, required) — Report level: `campaign`, `adgroup`, `ad`
- `date_preset` (string, optional) — Predefined date range. Options: `LAST_7_DAYS`, `LAST_14_DAYS`, `LAST_30_DAYS`, `LAST_90_DAYS`, etc.
- `start_date` (string, optional) — Start date (`YYYY-MM-DD`). Use with `end_date` instead of `date_preset`.
- `end_date` (string, optional) — End date (`YYYY-MM-DD`). Use with `start_date` instead of `date_preset`.
- `campaign_id` (string, optional) — Filter to a specific campaign
- `adgroup_id` (string, optional) — Filter to a specific ad group
- `page` (number, optional) — Page number for pagination (1-based)
- `page_size` (number, optional) — Results per page

**Key Metrics Returned:**
- **Delivery:** impressions, clicks, CTR, CPC, CPM, spend
- **Engagement:** likes, shares, comments, follows
- **Video:** video views, video completions, video view rates (2s, 6s, 100%)
- **Conversions:** conversion metrics (where configured)

**Example — Campaign-level report with date preset:**
```json
{
  "tool": "tiktok_ads_get_performance_report",
  "parameters": {
    "reason": "Generating campaign performance report for last 30 days",
    "advertiser_id": "7012345678901234567",
    "level": "campaign",
    "date_preset": "LAST_30_DAYS"
  }
}
```

**Example — Ad group level with custom date range:**
```json
{
  "tool": "tiktok_ads_get_performance_report",
  "parameters": {
    "reason": "Ad group performance for Q1 analysis",
    "advertiser_id": "7012345678901234567",
    "level": "adgroup",
    "start_date": "2026-01-01",
    "end_date": "2026-03-22"
  }
}
```

**Example — Filtered to a specific campaign:**
```json
{
  "tool": "tiktok_ads_get_performance_report",
  "parameters": {
    "reason": "Ad-level performance for specific campaign",
    "advertiser_id": "7012345678901234567",
    "level": "ad",
    "date_preset": "LAST_14_DAYS",
    "campaign_id": "1234567890123"
  }
}
```

---

#### tiktok_ads_get_insights
**Custom reporting tool.** Get detailed insights with flexible dimensions and metrics. Supports AUDIENCE report type for demographic breakdowns (age, gender, country).

**Parameters:**
- `reason` (string, required) — Reason for the call
- `advertiser_id` (string, required) — TikTok advertiser ID
- `report_type` (string, optional) — Report type: `BASIC` (default) or `AUDIENCE`
- `data_level` (string, required) — Data aggregation level: `AUCTION_CAMPAIGN`, `AUCTION_ADGROUP`, `AUCTION_AD`
- `dimensions` (array of strings, required) — Breakdown dimensions. Options include: `stat_time_day`, `campaign_id`, `adgroup_id`, `ad_id`, `age`, `gender`, `country_code`, `ac`, `language`, `platform`, `placement`
- `metrics` (array of strings, optional) — Specific metrics to return. If omitted, default metrics are returned.
- `start_date` (string, optional) — Start date (`YYYY-MM-DD`)
- `end_date` (string, optional) — End date (`YYYY-MM-DD`)
- `lifetime` (boolean, optional) — If `true`, returns lifetime data instead of date-range data
- `page` (number, optional) — Page number for pagination (1-based)
- `page_size` (number, optional) — Results per page

**Example — Daily campaign trend:**
```json
{
  "tool": "tiktok_ads_get_insights",
  "parameters": {
    "reason": "Daily spend trend by campaign for the last 30 days",
    "advertiser_id": "7012345678901234567",
    "data_level": "AUCTION_CAMPAIGN",
    "dimensions": ["stat_time_day", "campaign_id"],
    "start_date": "2026-02-20",
    "end_date": "2026-03-22"
  }
}
```

**Example — Audience demographics (age and gender):**
```json
{
  "tool": "tiktok_ads_get_insights",
  "parameters": {
    "reason": "Analyzing audience demographics for targeting optimization",
    "advertiser_id": "7012345678901234567",
    "report_type": "AUDIENCE",
    "data_level": "AUCTION_CAMPAIGN",
    "dimensions": ["age", "gender"],
    "start_date": "2026-02-20",
    "end_date": "2026-03-22"
  }
}
```

**Example — Country-level breakdown:**
```json
{
  "tool": "tiktok_ads_get_insights",
  "parameters": {
    "reason": "Geographic performance analysis by country",
    "advertiser_id": "7012345678901234567",
    "report_type": "AUDIENCE",
    "data_level": "AUCTION_ADGROUP",
    "dimensions": ["country_code"],
    "start_date": "2026-02-20",
    "end_date": "2026-03-22"
  }
}
```

**Example — Lifetime ad-level data:**
```json
{
  "tool": "tiktok_ads_get_insights",
  "parameters": {
    "reason": "Lifetime performance data for all ads",
    "advertiser_id": "7012345678901234567",
    "data_level": "AUCTION_AD",
    "dimensions": ["ad_id"],
    "lifetime": true
  }
}
```

---

#### tiktok_ads_get_creative_report
Get creative and video performance metrics. Provides video-specific metrics like play duration, completion rates, and engagement by creative.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `advertiser_id` (string, required) — TikTok advertiser ID
- `campaign_id` (string, optional) — Filter to a specific campaign
- `adgroup_id` (string, optional) — Filter to a specific ad group
- `start_date` (string, optional) — Start date (`YYYY-MM-DD`)
- `end_date` (string, optional) — End date (`YYYY-MM-DD`)
- `page` (number, optional) — Page number for pagination (1-based)
- `page_size` (number, optional) — Results per page

**Key Metrics Returned:**
- **Video Performance:** average play duration, completion rate, play counts
- **Engagement:** likes, shares, comments, profile visits
- **Creative Details:** video thumbnails, creative type, duration

**Example — Creative report for a campaign:**
```json
{
  "tool": "tiktok_ads_get_creative_report",
  "parameters": {
    "reason": "Analyzing video creative performance for campaign optimization",
    "advertiser_id": "7012345678901234567",
    "campaign_id": "1234567890123",
    "start_date": "2026-02-20",
    "end_date": "2026-03-22"
  }
}
```

**Example — All creatives in a date range:**
```json
{
  "tool": "tiktok_ads_get_creative_report",
  "parameters": {
    "reason": "Reviewing all creative performance for the last month",
    "advertiser_id": "7012345678901234567",
    "start_date": "2026-02-20",
    "end_date": "2026-03-22"
  }
}
```

---

### Preview Tools

#### tiktok_ads_preview_ads
Render a visual preview of TikTok ads via MCP App UI. Shows ad creative alongside optional performance metrics.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `advertiser_id` (string, required) — TikTok advertiser ID
- `ads` (array of objects, required) — Array of ad objects to preview. Each object contains:
  - `ad_id` (string, required) — The ad ID to preview
  - `metrics` (object, optional) — Performance metrics to display alongside the preview
- `metric_labels` (object, optional) — Custom labels for metric keys

**Example — Preview a single ad:**
```json
{
  "tool": "tiktok_ads_preview_ads",
  "parameters": {
    "reason": "Previewing ad creative for review",
    "advertiser_id": "7012345678901234567",
    "ads": [
      { "ad_id": "5678901234567" }
    ]
  }
}
```

**Example — Preview multiple ads with metrics:**
```json
{
  "tool": "tiktok_ads_preview_ads",
  "parameters": {
    "reason": "Comparing top-performing ad creatives with metrics",
    "advertiser_id": "7012345678901234567",
    "ads": [
      {
        "ad_id": "5678901234567",
        "metrics": { "impressions": 125000, "ctr": 2.3, "spend": 450.00 }
      },
      {
        "ad_id": "5678901234568",
        "metrics": { "impressions": 98000, "ctr": 1.8, "spend": 320.00 }
      }
    ],
    "metric_labels": { "ctr": "CTR (%)", "spend": "Spend ($)" }
  }
}
```

---

## Tool Usage Patterns

### Pattern 1: Session Start — Advertiser Selection
**Workflow:**
1. Call `tiktok_ads_list_advertisers` to list available advertisers
2. If multiple advertisers, present a numbered list and ask the user to select
3. If only one advertiser, use it automatically and confirm with the user

### Pattern 2: Account Overview & Performance Report
**Workflow:**
1. Use `tiktok_ads_get_performance_report` with `level: "campaign"` for a campaign-level overview
2. Use `tiktok_ads_get_performance_report` with `level: "adgroup"` for deeper ad group analysis
3. Present report with summary statistics and insights

### Pattern 3: Audience Demographics — TikTok-Unique
**Workflow:**
1. Use `tiktok_ads_get_insights` with `report_type: "AUDIENCE"` and `dimensions: ["age", "gender"]` for demographic breakdowns
2. Use `tiktok_ads_get_insights` with `dimensions: ["country_code"]` for geographic analysis
3. Cross-reference with `tiktok_ads_list_ad_groups` to review targeting configuration
4. Provide recommendations on audience segments to prioritize

### Pattern 4: Creative & Video Analysis
**Workflow:**
1. Use `tiktok_ads_list_ads` to get ad creative content
2. Use `tiktok_ads_get_creative_report` for video-specific metrics (play duration, completion rates)
3. Use `tiktok_ads_get_performance_report` with `level: "ad"` for ad-level delivery metrics
4. Use `tiktok_ads_preview_ads` to visually preview top and bottom performers
5. Identify top performers and underperformers based on engagement and video metrics

### Pattern 5: Audience Review
**Workflow:**
1. Use `tiktok_ads_list_audiences` to list available audiences with name, type, and status
2. Cross-reference with `tiktok_ads_list_ad_groups` to see which audiences are in use
3. Identify unused audiences or opportunities for audience expansion

### Pattern 6: Write Operation Requested
**Workflow:**
1. Inform the user that write operations (create, update, pause, delete) are not yet available via Hopkin
2. Provide guidance on how to perform the action manually via TikTok Ads Manager (https://ads.tiktok.com)

---

## Response Format

Hopkin tools return responses in two formats depending on the tool type:

### List Tools (advertisers, campaigns, ad groups, ads, audiences)

Responses include two parts:

#### content
Human-readable markdown text summarizing the results.

#### structuredContent
Machine-readable JSON data for programmatic processing.

**Example Response Structure:**
```json
{
  "content": "Found 3 enabled campaigns for advertiser 7012345678901234567...",
  "structuredContent": {
    "data": [
      {
        "campaign_id": "1234567890123",
        "name": "Spring Product Launch",
        "status": "ENABLE",
        "objective": "CONVERSIONS",
        "budget": 500.00
      }
    ]
  }
}
```

### Reporting Tools (performance report, insights, creative report)

Return **JSON text directly** — no structuredContent wrapper. Parse the returned text as JSON for programmatic processing.

---

## Pagination

TikTok Ads analytics and reporting tools use **page-based pagination**:

- **`page`** (number) — Page number (1-based)
- **`page_size`** (number) — Number of results per page

**Example — Paginating through a performance report:**
```json
// First page
{
  "tool": "tiktok_ads_get_performance_report",
  "parameters": {
    "reason": "Fetching campaign report page 1",
    "advertiser_id": "7012345678901234567",
    "level": "campaign",
    "date_preset": "LAST_30_DAYS",
    "page": 1,
    "page_size": 20
  }
}

// Next page
{
  "tool": "tiktok_ads_get_performance_report",
  "parameters": {
    "reason": "Fetching campaign report page 2",
    "advertiser_id": "7012345678901234567",
    "level": "campaign",
    "date_preset": "LAST_30_DAYS",
    "page": 2,
    "page_size": 20
  }
}
```

List tools (advertisers, campaigns, ad groups, ads) may use **cursor-based pagination** with `limit` and `cursor` parameters.

---

## Error Handling

### Common Error Types

- **Authentication errors** — User not authenticated or TikTok token failed. Call `tiktok_ads_check_auth_status` to confirm, then direct the user to https://app.hopkin.ai to reconnect.
- **Rate limiting** — TikTok API enforces rate limits. Wait and retry with exponential backoff.
- **Advertiser not found** — Verify `advertiser_id` and user access. TikTok advertiser IDs are numeric strings (e.g., `7012345678901234567`).
- **No data** — The requested date range or entity filters returned no results. Broaden the date range or remove filters.

### Error Handling Best Practices

1. **Always check auth first** — If tools return auth errors, run `tiktok_ads_check_auth_status` and direct the user to https://app.hopkin.ai to re-authenticate
2. **Respect rate limits** — Avoid rapid sequential calls; batch where possible
3. **Handle pagination** — Don't assume all results are in the first page. Check for additional pages in response metadata.
4. **Use correct ID formats** — TikTok advertiser IDs are numeric strings; `adgroup_id` has no underscore between "ad" and "group"
5. **Provide clear messages** — Translate errors into user-friendly guidance

---

## Feedback & Health Tools

### tiktok_ads_developer_feedback
Submit feedback about missing tools, improvements, bugs, or workflow gaps in the TikTok Ads MCP toolset. Use when the current tools cannot fulfill a user's request — not for user-facing auth or API errors.

**Parameters:**
- `reason` (string, required) — What triggered this feedback
- `feedback_type` (string, required) — Category: `new_tool`, `improvement`, `bug`, `workflow_gap`
- `title` (string, required) — Concise summary (5-200 characters)
- `description` (string, required) — What is needed and why (20-2000 characters)
- `priority` (string, optional) — `low`, `medium` (default), or `high`
- `current_workaround` (string, optional) — Current workaround, if any

**Example:**
```json
{
  "tool": "tiktok_ads_developer_feedback",
  "parameters": {
    "reason": "User asked to pause multiple ad groups at once",
    "feedback_type": "workflow_gap",
    "title": "Bulk ad group status toggle",
    "description": "No way to pause or enable multiple ad groups at once. Must do one at a time via TikTok Ads Manager.",
    "priority": "high",
    "current_workaround": "Manually pause each ad group in TikTok Ads Manager"
  }
}
```

---

### tiktok_ads_ping
Simple health check and connectivity test for the TikTok Ads MCP server.

**Parameters:**
- `reason` (string, required) — Reason for the ping
- `message` (string, optional) — Optional message to echo back

**Example:**
```json
{
  "tool": "tiktok_ads_ping",
  "parameters": {
    "reason": "Verifying MCP server is reachable before starting session"
  }
}
```

---

**Document Version:** 1.0
**Last Updated:** 2026-03-22
**Service:** Hopkin TikTok Ads MCP (https://app.hopkin.ai)
