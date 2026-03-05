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
      "url": "https://meta.mcp.hopkin.ai/mcp",
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
   This returns `authenticated`, `user_id`, `email`, `expires_at`, and a status message.

2. **If not authenticated:** Inform the user they need to connect their Meta Ads account via Hopkin. Direct them to https://app.hopkin.ai to complete the OAuth flow, then pause execution until they confirm it is done.

3. **Re-verify:** Call `meta_ads_check_auth_status` again to confirm the connection is active.

---

## Core Tools

> **Important:** Every Hopkin tool call requires a `reason` (string) parameter for audit trail.

### Authentication Tools

#### meta_ads_ping
Check that the Hopkin Meta Ads MCP is reachable.

**Parameters:**
- `reason` (string, required) — Reason for the call

#### meta_ads_check_auth_status
Check whether the user has authenticated their Meta Ads account. Returns user profile info (user_id, email, expires_at) when authenticated.

**Parameters:**
- `reason` (string, required) — Reason for the call

> Only call this when another tool returns an authentication error — do NOT call proactively on every request.

---

### Account Tools

#### meta_ads_list_ad_accounts
List all ad accounts accessible to the authenticated user. Supports search by name, status filtering, single/multi-account lookup by ID, and pagination. Pass `account_id` to look up a specific account.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, optional) — Look up a specific account by ID
- `account_ids` (array, optional) — Look up multiple specific accounts by ID (max 50)
- `search` (string, optional) — Filter accounts by name (case-insensitive partial match)
- `status` (number, optional) — Filter by account status
- `limit` (number, optional) — Max results per page (1–100, default 20)
- `cursor` (string, optional) — Pagination cursor from previous response
- `refresh` (boolean, optional) — Force fresh data from Meta API (bypasses cache)

**Example:**
```json
{
  "tool": "meta_ads_list_ad_accounts",
  "parameters": {
    "reason": "Finding the user's ad accounts to identify the correct one"
  }
}
```

---

### Campaign Tools

#### meta_ads_list_campaigns
List campaigns for an ad account. Supports status filtering, name search, single/multi-campaign lookup by ID, and pagination. Pass `campaign_id` to look up a specific campaign.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Ad account ID
- `campaign_id` (string, optional) — Look up a specific campaign by ID
- `campaign_ids` (array, optional) — Look up multiple specific campaigns by ID (max 50)
- `status` (array, optional) — Filter by status (e.g., `["ACTIVE", "PAUSED"]`)
- `search` (string, optional) — Filter by name (case-insensitive partial match)
- `limit` (number, optional) — Max results per page (1–100)
- `cursor` (string, optional) — Pagination cursor from previous response

**Example:**
```json
{
  "tool": "meta_ads_list_campaigns",
  "parameters": {
    "reason": "Listing active campaigns for performance analysis",
    "account_id": "act_123456789",
    "status": ["ACTIVE"]
  }
}
```

---

### Ad Set Tools

#### meta_ads_list_adsets
List ad sets for an account or campaign. Supports campaign filtering, status filtering, name search, single/multi-adset lookup by ID, and pagination. Pass `adset_id` to look up a specific ad set.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Ad account ID
- `adset_id` (string, optional) — Look up a specific ad set by ID
- `adset_ids` (array, optional) — Look up multiple specific ad sets by ID (max 50)
- `campaign_id` (string, optional) — Filter by campaign
- `status` (array, optional) — Filter by status (e.g., `["ACTIVE", "PAUSED"]`)
- `search` (string, optional) — Filter by name (case-insensitive partial match)
- `limit` (number, optional) — Max results per page (1–100)
- `cursor` (string, optional) — Pagination cursor from previous response

---

### Ad Tools

#### meta_ads_list_ads
List ads for an account, campaign, or ad set. Supports adset filtering, status filtering, name search, single/multi-ad lookup by ID, and pagination. Pass `ad_id` to look up a specific ad.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Ad account ID
- `ad_id` (string, optional) — Look up a specific ad by ID
- `ad_ids` (array, optional) — Look up multiple specific ads by ID (max 50)
- `campaign_id` (string, optional) — Filter by campaign
- `adset_id` (string, optional) — Filter by ad set
- `status` (array, optional) — Filter by status (e.g., `["ACTIVE", "PAUSED"]`)
- `search` (string, optional) — Filter by name (case-insensitive partial match)
- `limit` (number, optional) — Max results per page (1–100)
- `cursor` (string, optional) — Pagination cursor from previous response

---

### Analytics Tools

#### meta_ads_get_performance_report
**Recommended for account, campaign, and adset-level reporting.** Returns a comprehensive performance funnel with pre-built metrics.

This tool always includes a full funnel of metrics: impressions, reach, frequency, spend, clicks, cpc, cpm, ctr, unique_clicks, actions, action_values, conversions, purchase_roas, and quality rankings. Use `meta_ads_get_insights` if you need date presets or custom fields. **For ad creative analysis, use `meta_ads_get_ad_creative_report` instead.**

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Ad account ID
- `time_range` (object, required) — Date range with `since` and `until` (YYYY-MM-DD format)
- `level` (string, optional) — Aggregation level: `"account"` (default), `"campaign"`, `"adset"`, or `"ad"`
- `time_increment` (number or string, optional) — Time grouping: `1` for daily, `7` for weekly, `"monthly"`, `"all_days"` for a single row over the entire range
- `breakdowns` (array, optional) — Segment data by dimension (e.g., `["age", "gender"]`). Pass multiple values in a single call to get cross-tabulated rows — do NOT make separate calls per dimension.
- `filtering` (array, optional) — Filters as `[{field, operator, value}]`

**Example:**
```json
{
  "tool": "meta_ads_get_performance_report",
  "parameters": {
    "reason": "Generating campaign performance report for client review",
    "account_id": "act_123456789",
    "level": "campaign",
    "time_range": {"since": "2026-01-01", "until": "2026-01-31"}
  }
}
```

#### meta_ads_get_ad_creative_report
**Recommended for ad creative analysis.** Ad-level performance report with full funnel metrics and creative asset information (type, URL, thumbnail). Use this instead of `meta_ads_get_performance_report` with `level: "ad"` for any creative analysis workflow.

Supports two grouping modes via the `level` parameter:
- **`ad_name`** (default): aggregates all ads sharing the same name across ad sets, returns a representative `ad_id` (highest impressions) that can be passed directly to `meta_ads_preview_ads` — ideal for comparing the same creative running in multiple ad sets. Omits non-aggregatable fields (`frequency`, quality rankings, ROAS).
- **`ad_id`**: one row per ad — use when comparing distinct individual ads.

All conversion types are shown individually, not collapsed into a single number. Always fetches fresh data.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Ad account ID
- `time_range` (object, required) — Date range with `since` and `until` (YYYY-MM-DD format)
- `level` (string, optional) — Grouping mode: `"ad_name"` (default) or `"ad_id"`
- `time_increment` (number or string, optional) — Time grouping: `1` for daily, `7` for weekly, `"monthly"`, `"all_days"` for a single row over the entire range
- `breakdowns` (array, optional) — Segment data by dimension (e.g., `["age", "gender"]`). Available: age, gender, country, region, device_platform, publisher_platform, platform_position, impression_device, dma
- `filtering` (array, optional) — Filters as `[{field, operator, value}]`

**Returns:**
- `ad_id` — the ad ID (or representative ad_id in `ad_name` mode)
- `ad_name` — the ad name
- `ad_count` — number of ads aggregated (only in `ad_name` mode)
- `asset_type` — `'image'` | `'video'` | `'unknown'`
- `asset_url` — GCS URL to the creative asset
- `thumbnail_url` — GCS URL to thumbnail (videos only)
- Full delivery, engagement, action, and conversion metrics

**Example — Creative round analysis by name:**
```json
{
  "tool": "meta_ads_get_ad_creative_report",
  "parameters": {
    "reason": "Getting creative performance for round analysis",
    "account_id": "act_123456789",
    "level": "ad_name",
    "time_range": {"since": "2026-01-01", "until": "2026-01-31"}
  }
}
```

**Example — Individual ad comparison:**
```json
{
  "tool": "meta_ads_get_ad_creative_report",
  "parameters": {
    "reason": "Comparing individual ads for A/B analysis",
    "account_id": "act_123456789",
    "level": "ad_id",
    "time_range": {"since": "2026-01-01", "until": "2026-01-31"},
    "filtering": [{"field": "campaign.id", "operator": "EQUAL", "value": "123456789"}]
  }
}
```

#### meta_ads_get_insights
Flexible insights tool for custom metric and breakdown combinations. Supports date presets and a wide range of breakdown dimensions.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Ad account ID
- `date_preset` (string, optional) — Date range preset (e.g., `"last_7d"`, `"last_30d"`, `"last_90d"`, `"this_month"`)
- `time_range` (object, optional) — Custom date range with `since` and `until` (YYYY-MM-DD)
- `time_increment` (number or string, optional) — Time grouping: `1` for daily, `7` for weekly, `"monthly"`
- `level` (string, optional) — Aggregation level: `"account"`, `"campaign"`, `"adset"`, `"ad"`
- `fields` (array, optional) — Specific metrics to retrieve (defaults to standard set)
- `breakdowns` (array, optional) — Breakdown dimensions (e.g., `["age", "gender"]`, `["country"]`, `["device_platform"]`)
- `action_breakdowns` (array, optional) — Action breakdown dimensions
- `filtering` (array, optional) — Filters as `[{field, operator, value}]`

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
**MCP App** — Renders a visual UI with actual ad creative content (images/videos) and a configurable metrics overlay. This is distinct from tabular data tools: it returns an interactive visual panel, not a data table. Proactively offer this whenever the user asks "what do my ads look like", wants to review creative quality, or is doing A/B creative comparison.

Use `meta_ads_get_ad_creative_report` to get ad metrics and representative ad IDs in a single call, then pass them to this tool. The `ad_id` values from the creative report (including representative IDs in `ad_name` mode) work directly here — no separate `meta_ads_list_ads` call needed.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Ad account ID (with or without `act_` prefix)
- `ads` (array, required) — List of 1–20 ads to preview, each with:
  - `ad_id` (string, required) — The ad ID to preview
  - `metrics` (object, optional) — Key-value pairs of metric name to value (e.g., `{"spend": "150.00", "ctr": "2.5%"}`)
- `metric_labels` (object, optional) — Display labels for metric keys (e.g., `{"spend": "Spend", "ctr": "Click Rate"}`)

**Example — Single ad preview:**
```json
{
  "tool": "meta_ads_preview_ads",
  "parameters": {
    "reason": "Previewing winning ad creative for client report",
    "account_id": "act_123456789",
    "ads": [
      {"ad_id": "23842453456789"}
    ]
  }
}
```

**Example — Multiple ads with metrics overlay:**
```json
{
  "tool": "meta_ads_preview_ads",
  "parameters": {
    "reason": "Comparing top and bottom creative performers for A/B analysis",
    "account_id": "act_123456789",
    "ads": [
      {"ad_id": "23842453456789", "metrics": {"spend": "450.00", "ctr": "3.2%", "cpa": "$12.50"}},
      {"ad_id": "23842453456790", "metrics": {"spend": "380.00", "ctr": "1.1%", "cpa": "$45.00"}}
    ],
    "metric_labels": {"spend": "Spend", "ctr": "CTR", "cpa": "CPA"}
  }
}
```

---

### Preference Tools

Preference tools let you store and retrieve persistent key-value observations about ad entities. Preferences survive across conversations and are automatically attached to entity-listing responses as `_stored_preferences`. Use them to remember user choices, default accounts, reporting preferences, and analytical observations.

#### meta_ads_store_preference
Store a persistent preference or observation about a Meta ad entity.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `entity_type` (string, required) — Type of entity: `"ad_account"`, `"campaign"`, `"ad_set"`, or `"ad"`
- `entity_id` (string, required) — The Meta entity ID (e.g., `"act_123456"`, `"23842453456789"`)
- `key` (string, required) — Preference key (e.g., `"default_account_id"`, `"preferred_conversion_metric"`)
- `value` (any, required) — Preference value — string, number, boolean, or JSON object
- `source` (string, optional) — Who set this: `"agent"` (default), `"user"`, or `"system"`
- `note` (string, optional) — Context about why this preference was set

**Example — Store default account ID:**
```json
{
  "tool": "meta_ads_store_preference",
  "parameters": {
    "reason": "User confirmed act_123456789 as their primary account",
    "entity_type": "ad_account",
    "entity_id": "default",
    "key": "default_account_id",
    "value": "act_123456789",
    "source": "user",
    "note": "User selected from account list at session start"
  }
}
```

**Example — Store preferred metric for a campaign:**
```json
{
  "tool": "meta_ads_store_preference",
  "parameters": {
    "reason": "User wants ROAS as primary metric for this campaign",
    "entity_type": "campaign",
    "entity_id": "23842453456789",
    "key": "preferred_conversion_metric",
    "value": "purchase_roas"
  }
}
```

#### meta_ads_get_preferences
Get all stored preferences for a Meta ad entity.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `entity_type` (string, required) — Type of entity: `"ad_account"`, `"campaign"`, `"ad_set"`, or `"ad"`
- `entity_id` (string, required) — The Meta entity ID

> Note: Preferences are also automatically attached to entity-listing tool responses as `_stored_preferences`, so you often do not need to call this explicitly.

**Example — Check for stored default account:**
```json
{
  "tool": "meta_ads_get_preferences",
  "parameters": {
    "reason": "Checking for stored default account at session start",
    "entity_type": "ad_account",
    "entity_id": "default"
  }
}
```

#### meta_ads_delete_preference
Delete a specific stored preference by key.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `entity_type` (string, required) — Type of entity: `"ad_account"`, `"campaign"`, `"ad_set"`, or `"ad"`
- `entity_id` (string, required) — The Meta entity ID
- `key` (string, required) — The preference key to delete

**Example:**
```json
{
  "tool": "meta_ads_delete_preference",
  "parameters": {
    "reason": "User wants to clear their saved default account",
    "entity_type": "ad_account",
    "entity_id": "default",
    "key": "default_account_id"
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
- `feedback_type` (string, required) — Type of feedback: `"new_tool"`, `"improvement"`, `"bug"`, `"workflow_gap"`
- `title` (string, required) — Concise title (5–200 characters)
- `description` (string, required) — Detailed description of what is needed and why (20–2000 characters)
- `current_workaround` (string, optional) — How you are currently working around this limitation
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
    "current_workaround": "Directed user to Meta Ads Manager to update budget manually",
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
    "feedback_type": "new_tool",
    "title": "Combined campaign + ad set performance in one call",
    "description": "User asked for a full account overview. I had to call get_performance_report twice (once at campaign level, once at adset level) and manually merge results. A single tool that returns hierarchical campaign > ad set > ad data would have been significantly faster.",
    "current_workaround": "Called get_performance_report at campaign level, then again at adset level, and merged results manually",
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
1. Use `meta_ads_get_ad_creative_report` with `level: "ad_name"` (default) to get creative metrics and representative ad IDs in a single call — no need to first call `meta_ads_list_ads`
2. Use `meta_ads_preview_ads` with the `ad_id` values from the creative report and their metrics to render the visual creative UI with metrics overlay
3. Compare creative variations and identify top performers

> In `ad_name` mode, `meta_ads_get_ad_creative_report` returns a representative `ad_id` per creative name that can be passed directly to `meta_ads_preview_ads`. Use `level: "ad_id"` if you need to compare distinct individual ads rather than aggregated creative names.

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
2. Call `meta_ads_developer_feedback` with `feedback_type: "new_tool"` or `"improvement"` describing what would have been faster
3. Do NOT block the user's request — submit feedback after delivering the answer

### Pattern 7: Session Start with Preferences
**When:** At the beginning of any new session before asking the user for account information.

**Workflow:**
1. Call `meta_ads_get_preferences` with `entity_type: "ad_account"` and `entity_id: "default"` to check for a stored default account
2. If a `default_account_id` preference exists, use it and tell the user: "Using your saved account [X]. Use a different one? Let me know."
3. If no stored preference exists, call `meta_ads_list_ad_accounts` and present a numbered list if multiple accounts are found
4. After the user selects an account (or if they want to save a different one), offer to store it with `meta_ads_store_preference`

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

Hopkin list tools use cursor-based pagination:

- **`limit`** (1–100) — Number of results per page (default 20)
- **`cursor`** — Cursor string returned in the response to fetch the next page

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
    "cursor": "cursor_from_previous_response"
  }
}
```

---

## Error Handling

### Common Error Types

- **Authentication errors** — User not authenticated or session expired. Call `meta_ads_check_auth_status` to confirm, then direct the user to https://app.hopkin.ai to reconnect their Meta Ads account.
- **Invalid parameters** — Check parameter names and formats (e.g., account_id must start with "act_")
- **Rate limiting** — Wait and retry with exponential backoff
- **Account not found** — Verify account ID and user access

### Error Handling Best Practices

1. **Always check auth first** — If tools return auth errors, run `meta_ads_check_auth_status`; if not authenticated, direct the user to https://app.hopkin.ai to reconnect their account
2. **Validate inputs** — Ensure account IDs start with "act_", dates are YYYY-MM-DD
3. **Handle pagination** — Don't assume all results are in the first page
4. **Provide clear messages** — Translate errors into user-friendly guidance

---

**Document Version:** 2.1
**Last Updated:** 2026-03-04
**Service:** Hopkin Meta Ads MCP (https://app.hopkin.ai)
