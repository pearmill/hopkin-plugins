# Meta Ads MCP Server Tools Reference — Hopkin

This document provides detailed reference information for the Hopkin Meta Ads MCP tools and their usage patterns.

## Table of Contents

1. [MCP Server Overview](#mcp-server-overview)
2. [Authentication & Connection](#authentication--connection)
3. [Core Tools](#core-tools)
4. [Tool Usage Patterns](#tool-usage-patterns)
5. [Response Format](#response-format)
6. [Pagination](#pagination)
7. [Error Handling](#error-handling)

---

## MCP Server Overview

### Hopkin Meta Ads MCP

- **Service:** Hopkin — hosted MCP service
- **Sign up:** https://app.hopkin.ai
- **Type:** Hosted MCP (URL + auth token, no local installation)

### Required Configuration

Configure the Hopkin Meta Ads MCP as a hosted MCP service in your Claude settings:

```json
{
  "mcpServers": {
    "hopkin-meta-ads": {
      "type": "url",
      "url": "https://mcp.hopkin.ai/meta-ads/mcp",
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

### Hopkin OAuth Flow

Hopkin uses an OAuth flow for connecting to Meta Ads accounts. After the MCP is configured, authenticate the user's Meta Ads account:

1. **Check auth status:**
   ```json
   {
     "tool": "meta_ads_check_auth_status",
     "parameters": {
       "reason": "Checking if user is authenticated with Meta Ads"
     }
   }
   ```

2. **If not authenticated, get login URL:**
   ```json
   {
     "tool": "meta_ads_get_login_url",
     "parameters": {
       "reason": "User needs to authenticate with Meta Ads"
     }
   }
   ```
   Present the returned URL to the user. They will authenticate via Meta's OAuth flow.

3. **Verify authentication:**
   ```json
   {
     "tool": "meta_ads_get_user_info",
     "parameters": {
       "reason": "Verifying user identity after authentication"
     }
   }
   ```

---

## Core Tools

> **Important:** Every Hopkin tool call requires a `reason` (string) parameter for audit trail.

### Authentication Tools

#### meta_ads_ping
Check that the Hopkin Meta Ads MCP is reachable.

**Parameters:**
- `reason` (string, required) — Reason for the call

#### meta_ads_check_auth_status
Check whether the user has authenticated their Meta Ads account.

**Parameters:**
- `reason` (string, required) — Reason for the call

#### meta_ads_get_login_url
Get an OAuth login URL so the user can authenticate with Meta Ads.

**Parameters:**
- `reason` (string, required) — Reason for the call

#### meta_ads_get_user_info
Get information about the authenticated Meta Ads user.

**Parameters:**
- `reason` (string, required) — Reason for the call

---

### Account Tools

#### meta_ads_list_ad_accounts
List all ad accounts accessible to the authenticated user.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `limit` (number, optional) — Max results per page (1–100, default 25)
- `nextCursor` (string, optional) — Pagination cursor from previous response

**Example:**
```json
{
  "tool": "meta_ads_list_ad_accounts",
  "parameters": {
    "reason": "Finding the user's ad accounts to identify the correct one"
  }
}
```

#### meta_ads_get_ad_account
Get details for a specific ad account.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Ad account ID (e.g., "act_123456789")

**Example:**
```json
{
  "tool": "meta_ads_get_ad_account",
  "parameters": {
    "reason": "Getting account details for reporting",
    "account_id": "act_123456789"
  }
}
```

---

### Campaign Tools

#### meta_ads_list_campaigns
List campaigns for an ad account.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Ad account ID
- `status` (string, optional) — Filter by status (e.g., "ACTIVE", "PAUSED")
- `limit` (number, optional) — Max results per page (1–100)
- `nextCursor` (string, optional) — Pagination cursor

**Example:**
```json
{
  "tool": "meta_ads_list_campaigns",
  "parameters": {
    "reason": "Listing active campaigns for performance analysis",
    "account_id": "act_123456789",
    "status": "ACTIVE"
  }
}
```

#### meta_ads_get_campaign
Get details for a specific campaign.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `campaign_id` (string, required) — Campaign ID

**Example:**
```json
{
  "tool": "meta_ads_get_campaign",
  "parameters": {
    "reason": "Getting campaign details for budget analysis",
    "campaign_id": "123456789"
  }
}
```

---

### Ad Set Tools

#### meta_ads_list_adsets
List ad sets for an account or campaign.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Ad account ID
- `campaign_id` (string, optional) — Filter by campaign
- `status` (string, optional) — Filter by status
- `limit` (number, optional) — Max results per page (1–100)
- `nextCursor` (string, optional) — Pagination cursor

#### meta_ads_get_adset
Get details for a specific ad set.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `adset_id` (string, required) — Ad set ID

---

### Ad Tools

#### meta_ads_list_ads
List ads for an account, campaign, or ad set.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Ad account ID
- `campaign_id` (string, optional) — Filter by campaign
- `adset_id` (string, optional) — Filter by ad set
- `status` (string, optional) — Filter by status
- `limit` (number, optional) — Max results per page (1–100)
- `nextCursor` (string, optional) — Pagination cursor

#### meta_ads_get_ad
Get details for a specific ad.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `ad_id` (string, required) — Ad ID

---

### Analytics Tools

#### meta_ads_get_performance_report
**Recommended for most reporting use cases.** Returns a comprehensive performance funnel with pre-built metrics.

This tool always includes a full funnel of metrics: impressions, reach, frequency, spend, clicks, cpc, cpm, ctr, unique_clicks, actions, action_values, conversions, purchase_roas, and quality rankings.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Ad account ID
- `level` (string, required) — Aggregation level: `"campaign"`, `"adset"`, or `"ad"`
- `date_preset` (string, optional) — Date range preset (e.g., `"last_7d"`, `"last_30d"`)
- `time_range` (object, optional) — Custom date range with `since` and `until` (YYYY-MM-DD)
- `campaign_id` (string, optional) — Filter to specific campaign
- `adset_id` (string, optional) — Filter to specific ad set
- `limit` (number, optional) — Max results per page (1–100)
- `nextCursor` (string, optional) — Pagination cursor

**Example:**
```json
{
  "tool": "meta_ads_get_performance_report",
  "parameters": {
    "reason": "Generating campaign performance report for client review",
    "account_id": "act_123456789",
    "level": "campaign",
    "date_preset": "last_30d"
  }
}
```

#### meta_ads_get_insights
Flexible insights tool for custom metric and breakdown combinations.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Ad account ID
- `level` (string, optional) — Aggregation level: `"campaign"`, `"adset"`, `"ad"`
- `date_preset` (string, optional) — Date range preset
- `time_range` (object, optional) — Custom date range with `since` and `until`
- `time_increment` (string, optional) — Time granularity (e.g., `"1"` for daily, `"7"` for weekly)
- `breakdowns` (array, optional) — Breakdown dimensions (e.g., `["age", "gender"]`)
- `campaign_id` (string, optional) — Filter to specific campaign
- `adset_id` (string, optional) — Filter to specific ad set
- `limit` (number, optional) — Max results per page (1–100)
- `nextCursor` (string, optional) — Pagination cursor

**Example — Demographic Breakdown:**
```json
{
  "tool": "meta_ads_get_insights",
  "parameters": {
    "reason": "Analyzing audience demographics for targeting optimization",
    "account_id": "act_123456789",
    "level": "campaign",
    "date_preset": "last_30d",
    "breakdowns": ["age", "gender"]
  }
}
```

**Example — Daily Trend:**
```json
{
  "tool": "meta_ads_get_insights",
  "parameters": {
    "reason": "Tracking daily spend trend for budget pacing analysis",
    "account_id": "act_123456789",
    "level": "campaign",
    "time_range": {"since": "2026-01-01", "until": "2026-01-31"},
    "time_increment": "1"
  }
}
```

---

### Creative Tools

#### meta_ads_preview_ads
Preview actual ad creatives with metrics overlay. Shows what ads look like, including images, text, and performance data.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Ad account ID
- `campaign_id` (string, optional) — Filter by campaign
- `adset_id` (string, optional) — Filter by ad set
- `ad_id` (string, optional) — Specific ad to preview
- `limit` (number, optional) — Max results per page (1–100)
- `nextCursor` (string, optional) — Pagination cursor

**Example:**
```json
{
  "tool": "meta_ads_preview_ads",
  "parameters": {
    "reason": "Previewing winning ad creatives for client report",
    "account_id": "act_123456789",
    "campaign_id": "123456789"
  }
}
```

---

### Feedback Tools

#### meta_ads_developer_feedback
Submit feedback or feature requests to the Hopkin development team. Use this tool in two situations:

1. **Write operations requested** — When a user requests a create, update, pause, or delete operation that isn't available
2. **Proactive efficiency feedback** — When you complete a task and believe there should have been a faster or more efficient way to get the answer (e.g., multiple tool calls that could have been one, a missing dedicated tool for a common workflow, data that required manual calculation when it could have been returned directly)

**Parameters:**
- `reason` (string, required) — Reason for the call
- `feedback_type` (string, required) — Type of feedback: `"workflow_gap"`, `"bug_report"`, `"feature_request"`, `"general"`
- `title` (string, required) — Short description of the feedback
- `description` (string, required) — Detailed description of what the user was trying to do
- `priority` (string, optional) — Priority level: `"low"`, `"medium"`, `"high"`

**Example — Write Operation:**
```json
{
  "tool": "meta_ads_developer_feedback",
  "parameters": {
    "reason": "User requested campaign budget update which is not yet supported",
    "feedback_type": "workflow_gap",
    "title": "Update campaign budget",
    "description": "User wanted to increase daily budget from $100 to $150 for campaign 'Summer Sale 2026'. Write operations are not yet available via Hopkin.",
    "priority": "high"
  }
}
```

**Example — Efficiency Feedback:**
```json
{
  "tool": "meta_ads_developer_feedback",
  "parameters": {
    "reason": "Submitting efficiency feedback after completing user's request",
    "feedback_type": "feature_request",
    "title": "Combined campaign + ad set performance in one call",
    "description": "User asked for a full account overview. I had to call get_performance_report twice (once at campaign level, once at adset level) and manually merge results. A single tool that returns hierarchical campaign > ad set > ad data would have been significantly faster.",
    "priority": "medium"
  }
}
```

---

## Tool Usage Patterns

### Pattern 1: Account Overview & Performance Report
**Workflow:**
1. Use `meta_ads_list_ad_accounts` to find the correct account
2. Use `meta_ads_get_performance_report` with `level: "campaign"` for a full performance funnel
3. Present report with summary statistics and insights

### Pattern 2: Ad Creative Analysis with Preview
**Workflow:**
1. Use `meta_ads_list_ads` to get ads for a campaign or ad set
2. Use `meta_ads_get_performance_report` with `level: "ad"` for ad-level metrics
3. Use `meta_ads_preview_ads` to show actual creative visuals with metrics overlay
4. Compare creative variations and identify top performers

### Pattern 3: Demographic / Audience Analysis
**Workflow:**
1. Use `meta_ads_get_insights` with `breakdowns: ["age", "gender"]` for demographic data
2. Calculate segment performance metrics and indices
3. Identify high-value and underperforming segments
4. Provide targeting recommendations

### Pattern 4: Budget Pacing Analysis
**Workflow:**
1. Use `meta_ads_list_campaigns` to get budget configuration data
2. Use `meta_ads_get_insights` with `time_increment: "1"` for daily spend trend
3. Calculate pacing metrics (current vs. ideal)
4. Provide budget adjustment recommendations

### Pattern 5: Write Operation Requested (Developer Feedback)
**Workflow:**
1. Inform the user that write operations (create, update, pause, delete) are not yet available via Hopkin
2. Call `meta_ads_developer_feedback` with `feedback_type: "workflow_gap"` to log the request
3. Provide guidance on how to perform the action manually via Meta Ads Manager

### Pattern 6: Proactive Efficiency Feedback
**When:** After completing any task where you believe a faster path should have existed — e.g., you needed multiple calls that could have been one, had to manually compute something the tool could return, or a dedicated tool for the workflow was missing.

**Workflow:**
1. Complete the user's request as normal
2. Call `meta_ads_developer_feedback` with `feedback_type: "feature_request"` describing what would have been faster
3. Do NOT block the user's request — submit feedback after delivering the answer

---

## Response Format

Hopkin tools return responses with two parts:

### content
Human-readable markdown text summarizing the results.

### structuredContent
Machine-readable JSON data for programmatic processing.

**Example Response Structure:**
```json
{
  "content": "Found 3 campaigns for account act_123456789...",
  "structuredContent": {
    "data": [
      {
        "campaign_id": "123456789",
        "campaign_name": "Summer Sale 2026",
        "status": "ACTIVE",
        "impressions": "452341",
        "clicks": "12456",
        "spend": "4521.23",
        "conversions": "234",
        "purchase_roas": "4.21"
      }
    ]
  }
}
```

---

## Pagination

Hopkin tools use cursor-based pagination:

- **`limit`** (1–100) — Number of results per page (default 25)
- **`nextCursor`** — Cursor string returned in the response to fetch the next page

**Example — Paginating through campaigns:**
```json
// First page
{
  "tool": "meta_ads_list_campaigns",
  "parameters": {
    "reason": "Listing campaigns page 1",
    "account_id": "act_123456789",
    "limit": 50
  }
}

// Next page (using cursor from previous response)
{
  "tool": "meta_ads_list_campaigns",
  "parameters": {
    "reason": "Listing campaigns page 2",
    "account_id": "act_123456789",
    "limit": 50,
    "nextCursor": "cursor_from_previous_response"
  }
}
```

---

## Error Handling

### Common Error Types

- **Authentication errors** — User not authenticated or session expired. Call `meta_ads_get_login_url` to re-authenticate.
- **Invalid parameters** — Check parameter names and formats (e.g., account_id must start with "act_")
- **Rate limiting** — Wait and retry with exponential backoff
- **Account not found** — Verify account ID and user access

### Error Handling Best Practices

1. **Always check auth first** — If tools return auth errors, run `meta_ads_check_auth_status` and `meta_ads_get_login_url` if needed
2. **Validate inputs** — Ensure account IDs start with "act_", dates are YYYY-MM-DD
3. **Handle pagination** — Don't assume all results are in the first page
4. **Provide clear messages** — Translate errors into user-friendly guidance

---

**Document Version:** 2.0
**Last Updated:** 2026-02-10
**Service:** Hopkin Meta Ads MCP (https://app.hopkin.ai)
