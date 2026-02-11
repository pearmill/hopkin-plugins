# Google Ads MCP Server Tools Reference — Hopkin

This document provides detailed reference information for the Hopkin Google Ads MCP tools and their usage patterns.

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

### Hopkin Google Ads MCP

- **Service:** Hopkin — hosted MCP service
- **Sign up:** https://app.hopkin.ai
- **Type:** Hosted MCP (URL + auth token, no local installation)

### Required Configuration

Configure the Hopkin Google Ads MCP as a hosted MCP service in your Claude settings:

```json
{
  "mcpServers": {
    "hopkin-google-ads": {
      "type": "url",
      "url": "https://mcp.hopkin.ai/google-ads/mcp",
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

Hopkin uses an OAuth flow for connecting to Google Ads accounts. After the MCP is configured, authenticate the user's Google Ads account:

1. **Check auth status:**
   ```json
   {
     "tool": "google_ads_check_auth_status",
     "parameters": {
       "reason": "Checking if user is authenticated with Google Ads"
     }
   }
   ```

2. **If not authenticated, get login URL:**
   ```json
   {
     "tool": "google_ads_get_login_url",
     "parameters": {
       "reason": "User needs to authenticate with Google Ads"
     }
   }
   ```
   Present the returned URL to the user. They will authenticate via Google's OAuth flow.

3. **Verify authentication:**
   ```json
   {
     "tool": "google_ads_get_user_info",
     "parameters": {
       "reason": "Verifying user identity after authentication"
     }
   }
   ```

---

## Core Tools

> **Important:** Every Hopkin tool call requires a `reason` (string) parameter for audit trail.

### Authentication Tools

#### google_ads_check_auth_status
Check whether the user has authenticated their Google Ads account.

**Parameters:**
- `reason` (string, required) — Reason for the call

#### google_ads_get_login_url
Get an OAuth login URL so the user can authenticate with Google Ads.

**Parameters:**
- `reason` (string, required) — Reason for the call

#### google_ads_get_user_info
Get information about the authenticated Google Ads user.

**Parameters:**
- `reason` (string, required) — Reason for the call

---

### Account Tools

#### google_ads_list_accounts
List all Google Ads accounts accessible to the authenticated user.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `limit` (number, optional) — Max results per page (1–100, default 25)
- `nextCursor` (string, optional) — Pagination cursor from previous response

**Example:**
```json
{
  "tool": "google_ads_list_accounts",
  "parameters": {
    "reason": "Finding the user's Google Ads accounts"
  }
}
```

#### google_ads_get_account
Get details for a specific Google Ads account.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID (format: 1234567890, no hyphens)

**Example:**
```json
{
  "tool": "google_ads_get_account",
  "parameters": {
    "reason": "Getting account details for reporting",
    "customer_id": "1234567890"
  }
}
```

#### google_ads_list_mcc_child_accounts
List child accounts under a Manager (MCC) account.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Manager account customer ID
- `login_customer_id` (string, optional) — The manager account ID to use for authentication (required when accessing child accounts through a manager)
- `limit` (number, optional) — Max results per page (1–100)
- `nextCursor` (string, optional) — Pagination cursor

**Example:**
```json
{
  "tool": "google_ads_list_mcc_child_accounts",
  "parameters": {
    "reason": "Listing child accounts under MCC for client selection",
    "customer_id": "1234567890"
  }
}
```

---

### Campaign Tools

#### google_ads_list_campaigns
List campaigns for a Google Ads account.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `status` (string, optional) — Filter by status (e.g., "ENABLED", "PAUSED")
- `limit` (number, optional) — Max results per page (1–100)
- `nextCursor` (string, optional) — Pagination cursor

**Example:**
```json
{
  "tool": "google_ads_list_campaigns",
  "parameters": {
    "reason": "Listing active campaigns for performance analysis",
    "customer_id": "1234567890",
    "status": "ENABLED"
  }
}
```

#### google_ads_get_campaign
Get details for a specific campaign.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `campaign_id` (string, required) — Campaign ID

---

### Ad Group Tools

#### google_ads_list_ad_groups
List ad groups for a campaign or account.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `campaign_id` (string, optional) — Filter by campaign
- `status` (string, optional) — Filter by status
- `limit` (number, optional) — Max results per page (1–100)
- `nextCursor` (string, optional) — Pagination cursor

#### google_ads_get_ad_group
Get details for a specific ad group.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `ad_group_id` (string, required) — Ad group ID

---

### Ad Tools

#### google_ads_list_ads
List ads for an account, campaign, or ad group.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `campaign_id` (string, optional) — Filter by campaign
- `ad_group_id` (string, optional) — Filter by ad group
- `status` (string, optional) — Filter by status
- `limit` (number, optional) — Max results per page (1–100)
- `nextCursor` (string, optional) — Pagination cursor

#### google_ads_get_ad
Get details for a specific ad.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `ad_id` (string, required) — Ad ID

---

### Analytics Tools

#### google_ads_get_insights
Get performance insights for campaigns, ad groups, or ads.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `date_preset` (string, optional) — Date range preset (e.g., `"LAST_7_DAYS"`, `"LAST_30_DAYS"`, `"THIS_MONTH"`)
- `date_range` (object, optional) — Custom date range with `start_date` and `end_date` (YYYY-MM-DD)
- `level` (string, optional) — Aggregation level: `"CAMPAIGN"`, `"AD_GROUP"`, `"AD"`
- `metrics` (array, optional) — Specific metrics to include
- `segments` (array, optional) — Segmentation dimensions (e.g., `["date"]`, `["device"]`)
- `campaign_id` (string, optional) — Filter to specific campaign
- `ad_group_id` (string, optional) — Filter to specific ad group
- `limit` (number, optional) — Max results per page (1–100)
- `nextCursor` (string, optional) — Pagination cursor

**Example — Campaign Performance:**
```json
{
  "tool": "google_ads_get_insights",
  "parameters": {
    "reason": "Generating campaign performance report for last 30 days",
    "customer_id": "1234567890",
    "level": "CAMPAIGN",
    "date_preset": "LAST_30_DAYS"
  }
}
```

**Example — Daily Trend:**
```json
{
  "tool": "google_ads_get_insights",
  "parameters": {
    "reason": "Getting daily spend trend for budget pacing",
    "customer_id": "1234567890",
    "level": "CAMPAIGN",
    "date_range": {"start_date": "2026-01-01", "end_date": "2026-01-31"},
    "segments": ["date"]
  }
}
```

**Example — Ad-Level Performance:**
```json
{
  "tool": "google_ads_get_insights",
  "parameters": {
    "reason": "Analyzing ad performance for creative optimization",
    "customer_id": "1234567890",
    "level": "AD",
    "date_preset": "LAST_30_DAYS",
    "campaign_id": "123456789"
  }
}
```

---

### Keyword Tools

#### google_ads_get_keyword_performance
Get keyword performance data with quality scores and all key metrics.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `campaign_id` (string, optional) — Filter by campaign
- `ad_group_id` (string, optional) — Filter by ad group
- `keyword_match_type` (string, optional) — Filter by match type (e.g., `"EXACT"`, `"PHRASE"`, `"BROAD"`)
- `order_by` (string, optional) — Sort field (e.g., `"cost"`, `"conversions"`, `"impressions"`)
- `limit` (number, optional) — Max results per page (1–100)
- `nextCursor` (string, optional) — Pagination cursor

**Example:**
```json
{
  "tool": "google_ads_get_keyword_performance",
  "parameters": {
    "reason": "Analyzing keyword performance for optimization",
    "customer_id": "1234567890",
    "campaign_id": "123456789",
    "order_by": "cost",
    "limit": 50
  }
}
```

#### google_ads_get_search_terms_report
Get search terms report showing which actual search queries triggered ads.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `campaign_id` (string, optional) — Filter by campaign
- `ad_group_id` (string, optional) — Filter by ad group
- `search_term_status` (string, optional) — Filter by status (e.g., `"ADDED"`, `"EXCLUDED"`, `"NONE"`)
- `order_by` (string, optional) — Sort field
- `limit` (number, optional) — Max results per page (1–100)
- `nextCursor` (string, optional) — Pagination cursor

**Example:**
```json
{
  "tool": "google_ads_get_search_terms_report",
  "parameters": {
    "reason": "Finding negative keyword candidates from search terms",
    "customer_id": "1234567890",
    "campaign_id": "123456789",
    "order_by": "cost",
    "limit": 100
  }
}
```

---

### Utility Tools

#### google_ads_ping
Check that the Hopkin Google Ads MCP is reachable.

**Parameters:**
- `reason` (string, required) — Reason for the call

---

### Feedback Tools

#### google_ads_developer_feedback
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
  "tool": "google_ads_developer_feedback",
  "parameters": {
    "reason": "User requested campaign budget update which is not yet supported",
    "feedback_type": "workflow_gap",
    "title": "Update campaign budget",
    "description": "User wanted to increase daily budget from $100 to $150 for campaign 'Brand Search' in account 1234567890.",
    "priority": "high"
  }
}
```

**Example — Efficiency Feedback:**
```json
{
  "tool": "google_ads_developer_feedback",
  "parameters": {
    "reason": "Submitting efficiency feedback after completing user's request",
    "feedback_type": "feature_request",
    "title": "Keyword performance with search term data in one call",
    "description": "User asked for a keyword analysis with search term opportunities. I had to call get_keyword_performance and get_search_terms_report separately, then manually cross-reference keywords with search terms. A combined tool that returns keyword performance alongside matching search terms would be significantly faster.",
    "priority": "medium"
  }
}
```

---

## Tool Usage Patterns

### Pattern 1: Account Overview & Performance Report
**Workflow:**
1. Use `google_ads_list_accounts` to find the correct account
2. Use `google_ads_get_insights` with `level: "CAMPAIGN"` for campaign performance
3. Present report with summary statistics and insights

### Pattern 2: Keyword Analysis
**Workflow:**
1. Use `google_ads_get_keyword_performance` for keyword metrics and quality scores
2. Use `google_ads_get_search_terms_report` for search term data
3. Identify top performers, underperformers, and negative keyword candidates
4. Provide keyword optimization recommendations

### Pattern 3: Ad Creative Analysis
**Workflow:**
1. Use `google_ads_list_ads` to get ads for a campaign
2. Use `google_ads_get_insights` with `level: "AD"` for ad-level metrics
3. Compare creative variations and identify top performers

### Pattern 4: Budget & Spend Analysis
**Workflow:**
1. Use `google_ads_list_campaigns` for budget data
2. Use `google_ads_get_insights` with `segments: ["date"]` for daily spend trends
3. Calculate pacing metrics
4. Recommend budget adjustments

### Pattern 5: Write Operation Requested (Developer Feedback)
**Workflow:**
1. Inform the user that write operations are not yet available via Hopkin
2. Call `google_ads_developer_feedback` with `feedback_type: "workflow_gap"`
3. Provide guidance on how to perform the action manually via Google Ads

### Pattern 6: Proactive Efficiency Feedback
**When:** After completing any task where you believe a faster path should have existed — e.g., you needed multiple calls that could have been one, had to manually compute something the tool could return, or a dedicated tool for the workflow was missing.

**Workflow:**
1. Complete the user's request as normal
2. Call `google_ads_developer_feedback` with `feedback_type: "feature_request"` describing what would have been faster
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
  "content": "Found 5 campaigns for account 1234567890...",
  "structuredContent": {
    "data": [
      {
        "campaign_id": "123456789",
        "campaign_name": "Brand Search",
        "status": "ENABLED",
        "impressions": "45230",
        "clicks": "1234",
        "cost": "567.89",
        "conversions": "45",
        "roas": "4.13"
      }
    ]
  }
}
```

**Note:** Unlike the raw Google Ads API, Hopkin returns costs as decimal currency values (not micros). No need to divide by 1,000,000.

---

## Pagination

Hopkin tools use cursor-based pagination:

- **`limit`** (1–100) — Number of results per page (default 25)
- **`nextCursor`** — Cursor string returned in the response to fetch the next page

---

## Error Handling

### Common Error Types

- **Authentication errors** — User not authenticated or session expired. Call `google_ads_get_login_url` to re-authenticate.
- **Invalid customer ID** — Ensure customer ID is 10 digits with no hyphens
- **Rate limiting** — Wait and retry with exponential backoff
- **Account not found** — Verify customer ID and user access

### Error Handling Best Practices

1. **Always check auth first** — If tools return auth errors, run `google_ads_check_auth_status` and `google_ads_get_login_url` if needed
2. **Validate customer ID format** — 10 digits, no hyphens (1234567890 not 123-456-7890)
3. **Handle pagination** — Don't assume all results are in the first page
4. **Provide clear messages** — Translate errors into user-friendly guidance

---

**Document Version:** 2.0
**Last Updated:** 2026-02-10
**Service:** Hopkin Google Ads MCP (https://app.hopkin.ai)
