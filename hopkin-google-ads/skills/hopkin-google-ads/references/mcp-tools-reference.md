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
      "url": "https://google.mcp.hopkin.ai/mcp",
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

Hopkin uses OAuth. If a tool call fails with an auth error, call `google_ads_check_auth_status` to check. If not authenticated, direct the user to https://app.hopkin.ai to connect their Google Ads account.

---

## Core Tools

> **Important:** Every Hopkin tool call requires a `reason` (string) parameter for audit trail.

### Authentication Tools

#### google_ads_check_auth_status
Check whether the user has authenticated their Google Ads account. Only call this when another tool returns a permission or authentication error — do not call proactively.

**Parameters:**
- `reason` (string, required) — Reason for the call

#### google_ads_ping
Health check. Verify the MCP server is reachable and returns version/timestamp.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `message` (string, optional) — Optional echo message

---

### Account Tools

#### google_ads_list_accounts
List all Google Ads accounts accessible to the authenticated user. Child accounts include a `managerCustomerId` field indicating their parent MCC — when querying those accounts with other tools, pass `login_customer_id` with that value.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, optional) — Get a single account by ID
- `customer_ids` (array of strings, optional) — Get multiple accounts by ID in one call
- `search` (string, optional) — Filter accounts by name
- `refresh` (boolean, optional) — Force fresh data bypassing cache
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

#### google_ads_list_mcc_child_accounts
List child accounts under a Manager (MCC) account. When querying these child accounts with other tools, pass `login_customer_id` with the MCC Customer ID.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `mcc_id` (string, required) — Manager (MCC) account customer ID
- `search` (string, optional) — Filter child accounts by name
- `limit` (number, optional) — Max results per page (1–100)
- `nextCursor` (string, optional) — Pagination cursor

**Example:**
```json
{
  "tool": "google_ads_list_mcc_child_accounts",
  "parameters": {
    "reason": "Listing child accounts under MCC for client selection",
    "mcc_id": "9999999999"
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
- `login_customer_id` (string, optional) — Manager account ID. Required when the target account is managed by an MCC — omitting it causes permission errors
- `campaign_id` (string, optional) — Get a single campaign by ID
- `campaign_ids` (array of strings, optional) — Get multiple campaigns by ID in one call
- `status` (array of strings, optional) — Filter by status (e.g., `["ENABLED"]`, `["PAUSED"]`)
- `search` (string, optional) — Filter by campaign name
- `refresh` (boolean, optional) — Force fresh data bypassing cache
- `limit` (number, optional) — Max results per page (1–100)
- `nextCursor` (string, optional) — Pagination cursor

**Example:**
```json
{
  "tool": "google_ads_list_campaigns",
  "parameters": {
    "reason": "Listing active campaigns for performance analysis",
    "customer_id": "1234567890",
    "status": ["ENABLED"]
  }
}
```

**Example — MCC child account:**
```json
{
  "tool": "google_ads_list_campaigns",
  "parameters": {
    "reason": "Listing campaigns for MCC-managed client account",
    "customer_id": "1234567890",
    "login_customer_id": "9999999999"
  }
}
```

---

### Ad Group Tools

#### google_ads_list_ad_groups
List ad groups for a campaign or account.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `login_customer_id` (string, optional) — Manager account ID. Required when the target account is managed by an MCC — omitting it causes permission errors
- `campaign_id` (string, optional) — Filter by campaign
- `ad_group_id` (string, optional) — Get a single ad group by ID
- `ad_group_ids` (array of strings, optional) — Get multiple ad groups by ID in one call
- `status` (array of strings, optional) — Filter by status (e.g., `["ENABLED"]`)
- `search` (string, optional) — Filter by ad group name
- `refresh` (boolean, optional) — Force fresh data bypassing cache
- `limit` (number, optional) — Max results per page (1–100)
- `nextCursor` (string, optional) — Pagination cursor

---

### Ad Tools

#### google_ads_list_ads
List ads for an account, campaign, or ad group.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `login_customer_id` (string, optional) — Manager account ID. Required when the target account is managed by an MCC — omitting it causes permission errors
- `campaign_id` (string, optional) — Filter by campaign
- `ad_group_id` (string, optional) — Filter by ad group
- `ad_id` (string, optional) — Get a single ad by ID
- `ad_ids` (array of strings, optional) — Get multiple ads by ID in one call
- `status` (array of strings, optional) — Filter by status (e.g., `["ENABLED"]`)
- `search` (string, optional) — Filter by ad name/content
- `refresh` (boolean, optional) — Force fresh data bypassing cache
- `limit` (number, optional) — Max results per page (1–100)
- `nextCursor` (string, optional) — Pagination cursor

---

### Analytics Tools

#### google_ads_get_performance_report
**Recommended analytics tool.** Comprehensive performance report providing full delivery-to-conversion funnel metrics AND per-conversion-action breakdowns. Preferred over `google_ads_get_insights` for standard performance analysis.

This tool runs two parallel queries:
1. **Funnel query** — impressions, clicks, cost, CTR, avg CPC, CPM, conversions (total), conversion value, cost per conversion, conversion rate. At CAMPAIGN level, search impression share is also included.
2. **Conversion breakdown query** — per-conversion-action conversions, conversion value, and value per conversion (segmented by `conversion_action_name`), grouped by entity ID.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `login_customer_id` (string, optional) — Manager account ID. Required when the target account is managed by an MCC — omitting it causes permission errors
- `date_preset` (string) — Date range preset (e.g., `"LAST_7_DAYS"`, `"LAST_30_DAYS"`, `"THIS_MONTH"`). Required if `date_range` not provided.
- `date_range` (object) — Custom date range with `start_date` and `end_date` (YYYY-MM-DD). Required if `date_preset` not provided.
- `level` (string, optional) — Aggregation level: `"ACCOUNT"`, `"CAMPAIGN"` (default), `"AD_GROUP"`, or `"AD"`
- `segments` (array of strings, optional) — Additional breakdown dimensions: `"date"`, `"device"`, `"ad_network_type"`
- `campaign_id` (string, optional) — Filter to a specific campaign
- `ad_group_id` (string, optional) — Filter to a specific ad group

**Returns:**
- `data` — Top-level funnel metrics per entity
- `conversion_breakdown` — Per-entity, per-conversion-action metrics grouped by entity ID
- `count`, `level`, `date_range`/`date_preset`, `segments`, `fetched_at` — Metadata

**Example — Campaign overview:**
```json
{
  "tool": "google_ads_get_performance_report",
  "parameters": {
    "reason": "Generating campaign performance report for last 30 days",
    "customer_id": "1234567890",
    "level": "CAMPAIGN",
    "date_preset": "LAST_30_DAYS"
  }
}
```

**Example — Daily trend:**
```json
{
  "tool": "google_ads_get_performance_report",
  "parameters": {
    "reason": "Getting daily performance trend",
    "customer_id": "1234567890",
    "date_preset": "LAST_7_DAYS",
    "segments": ["date"]
  }
}
```

**Example — MCC child account:**
```json
{
  "tool": "google_ads_get_performance_report",
  "parameters": {
    "reason": "Campaign performance for managed client",
    "customer_id": "1234567890",
    "login_customer_id": "9999999999",
    "date_preset": "LAST_30_DAYS"
  }
}
```

---

#### google_ads_get_geo_performance
Geographic performance breakdown using the `geographic_view` resource. This is the **only tool that supports geographic segments** — do not use `google_ads_get_insights` for geo data. Runs two parallel queries: geographic metrics + conversion breakdown (with graceful degradation). Location criterion IDs are automatically resolved to human-readable names.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `login_customer_id` (string, optional) — Manager account ID. Required when the target account is managed by an MCC
- `date_preset` (string) — Date range preset (e.g., `"LAST_7_DAYS"`, `"LAST_30_DAYS"`, `"THIS_MONTH"`). Required if `date_range` not provided.
- `date_range` (object) — Custom date range with `start_date` and `end_date` (YYYY-MM-DD). Required if `date_preset` not provided.
- `geo_level` (string, optional) — Geographic granularity (default: `"country"`). Options: `"country"`, `"geo_target_city"`, `"geo_target_region"`, `"geo_target_state"`, `"geo_target_metro"`, `"geo_target_province"`, `"geo_target_county"`, `"geo_target_district"`, `"geo_target_most_specific_location"`, `"geo_target_postal_code"`, `"geo_target_airport"`, `"geo_target_canton"`. **Only one geo level per query** — combining levels causes silent data loss.
- `level` (string, optional) — Aggregation level: `"ACCOUNT"`, `"CAMPAIGN"` (default), `"AD_GROUP"`
- `segments` (array of strings, optional) — Non-geo segments: `"date"`, `"device"`, `"ad_network_type"`
- `campaign_id` (string, optional) — Filter to a specific campaign
- `ad_group_id` (string, optional) — Filter to a specific ad group
- `limit` (number, optional) — Max results (1–200, default 50)

**Returns:**
- `data` — Geographic performance rows with resolved location names
- `conversion_breakdown` — Per-entity, per-conversion-action metrics
- `count`, `geo_level`, `level`, `date_range`/`date_preset`, `fetched_at` — Metadata

**Example — Country-level by campaign:**
```json
{
  "tool": "google_ads_get_geo_performance",
  "parameters": {
    "reason": "Analyzing geographic performance by country",
    "customer_id": "1234567890",
    "date_preset": "LAST_7_DAYS"
  }
}
```

**Example — City-level for specific campaign:**
```json
{
  "tool": "google_ads_get_geo_performance",
  "parameters": {
    "reason": "City-level breakdown for Brand Search campaign",
    "customer_id": "1234567890",
    "campaign_id": "123456789",
    "geo_level": "geo_target_city",
    "date_preset": "LAST_30_DAYS",
    "limit": 100
  }
}
```

**Example — Daily country trends:**
```json
{
  "tool": "google_ads_get_geo_performance",
  "parameters": {
    "reason": "Daily geographic trends by country",
    "customer_id": "1234567890",
    "date_preset": "LAST_7_DAYS",
    "segments": ["date"]
  }
}
```

---

#### google_ads_get_insights
Custom analytics with full control over metrics, segments, and GAQL. Use when `google_ads_get_performance_report` does not cover the required query (e.g., custom metric selection, specialized segments, or conversion action segments). **Note:** Geographic segments are not available through this tool — use `google_ads_get_geo_performance` instead.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `login_customer_id` (string, optional) — Manager account ID. Required when the target account is managed by an MCC — omitting it causes permission errors
- `date_preset` (string, optional) — Date range preset (e.g., `"LAST_7_DAYS"`, `"LAST_30_DAYS"`, `"THIS_MONTH"`)
- `date_range` (object, optional) — Custom date range with `start_date` and `end_date` (YYYY-MM-DD)
- `level` (string, optional) — Aggregation level: `"ACCOUNT"`, `"CAMPAIGN"`, `"AD_GROUP"`, `"AD"`
- `metrics` (array, optional) — Specific metrics to include
- `segments` (array, optional) — Segmentation dimensions (e.g., `["date"]`, `["device"]`, `["conversion_action_name"]`)
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

### Conversion Action Tools

#### google_ads_get_conversion_actions
List all conversion actions configured for a Google Ads account. Call this tool before analyzing conversion metrics, ROAS, or conversion breakdowns to understand which actions are tracked and which are included in the aggregate "Conversions" metric.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `login_customer_id` (string, optional) — Manager account ID. Required when the target account is managed by an MCC — omitting it causes permission errors
- `status` (string, optional) — Filter by `"ENABLED"`, `"REMOVED"`, or `"HIDDEN"` (defaults to all non-REMOVED)
- `limit` (number, optional) — Max results (default 100, max 500)

**Returns:**
- `data` — Array of conversion actions with `id`, `name`, `type` (WEBPAGE, PHONE_CALL, etc.), `category` (PURCHASE, LEAD, SIGNUP, etc.), `status`, `counting_type`, `origin`, `primary_for_goal`, `include_in_conversions_metric`
- `count` — Total number returned
- `fetched_at` — Timestamp

**Example:**
```json
{
  "tool": "google_ads_get_conversion_actions",
  "parameters": {
    "reason": "Understanding which conversion actions are active before analyzing ROAS",
    "customer_id": "1234567890",
    "status": "ENABLED"
  }
}
```

---

### Keyword Tools

#### google_ads_get_keyword_performance
Get keyword performance data with quality scores and all key metrics. Also runs a parallel conversion breakdown query returning per-conversion-action stats grouped by ad group.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `login_customer_id` (string, optional) — Manager account ID. Required when the target account is managed by an MCC — omitting it causes permission errors
- `campaign_id` (string, optional) — Filter by campaign
- `ad_group_id` (string, optional) — Filter by ad group
- `keyword_match_type` (string, optional) — Filter by match type (e.g., `"EXACT"`, `"PHRASE"`, `"BROAD"`)
- `status` (array of strings, optional) — Filter by status (e.g., `["ENABLED"]`)
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
Get search terms report showing which actual search queries triggered ads. Also runs a parallel conversion breakdown query returning per-conversion-action stats grouped by ad group.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `login_customer_id` (string, optional) — Manager account ID. Required when the target account is managed by an MCC — omitting it causes permission errors
- `campaign_id` (string, optional) — Filter by campaign
- `ad_group_id` (string, optional) — Filter by ad group
- `search_term_status` (array of strings, optional) — Filter by status (e.g., `["ADDED"]`, `["EXCLUDED"]`, `["NONE"]`)
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

### Visualization Tools

#### `google_ads_render_chart`

**MCP App.** Renders interactive data visualization charts from advertising data.

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `reason` | string | Yes | Why you're rendering this chart |
| `chart` | object | Yes | Chart configuration — must include `type` and type-specific fields |

**Chart Types:**

**bar** — Compare values across categories (campaigns, ad groups, keywords).
```json
{
  "type": "bar",
  "data": [
    {"label": "Brand Search", "values": {"spend": 4521, "roas": 5.2}},
    {"label": "Non-Brand", "values": {"spend": 3200, "roas": 2.8}},
    {"label": "Retargeting", "values": {"spend": 1800, "roas": 8.1}}
  ],
  "metric": {"field": "spend", "label": "Spend ($)"}
}
```
Optional: `colorBy`, `sort`, `orientation`, `table`, `referenceLines`.

**timeseries** — Plot metrics over time with optional previous-period overlay and projections.
```json
{
  "type": "timeseries",
  "data": {
    "current": [
      {"date": "2026-02-24", "values": {"spend": 450}},
      {"date": "2026-02-25", "values": {"spend": 520}},
      {"date": "2026-02-26", "values": {"spend": 480}}
    ]
  },
  "primaryAxis": {"field": "spend", "label": "Daily Spend ($)", "mark": "line"}
}
```
Optional: `data.previous`, `data.projection`, `secondaryAxis`.

**funnel** — Conversion stages.
```json
{
  "type": "funnel",
  "data": {
    "stages": ["Impressions", "Clicks", "Conversions", "Purchases"],
    "volume": [500000, 15000, 3200, 890],
    "costPer": [0.01, 0.33, 1.56, 5.62]
  }
}
```

**scatter** — Correlate two metrics across entities.
```json
{
  "type": "scatter",
  "data": [
    {"label": "Brand Search", "values": {"spend": 4521, "roas": 5.2}},
    {"label": "Non-Brand", "values": {"spend": 3200, "roas": 2.8}}
  ],
  "x": {"field": "spend", "label": "Spend ($)"},
  "y": {"field": "roas", "label": "ROAS"}
}
```
Optional: `color`, `size`, `referenceLines`, `table`.

**waterfall** — Cumulative contribution with color encoding.
```json
{
  "type": "waterfall",
  "data": [
    {"label": "Brand Search", "value": 4521, "colorValue": 45.20},
    {"label": "Non-Brand", "value": 3200, "colorValue": 62.50},
    {"label": "Retargeting", "value": 1800, "colorValue": 22.50}
  ],
  "valueLabel": "Spend ($)",
  "colorLabel": "CPA ($)"
}
```

**choropleth** — US state-level geographic heatmap.
```json
{
  "type": "choropleth",
  "data": [
    {"state": "CA", "value": 12500},
    {"state": "TX", "value": 8900},
    {"state": "NY", "value": 7600}
  ],
  "valueLabel": "Spend ($)"
}
```
Optional: `tip`, `colorScheme`, `colorType`.

---

### Preference Tools

Preferences allow persistent storage of settings and observations across sessions. Entity listing tools (e.g., `google_ads_list_accounts`) automatically attach stored preferences to each entity in the response as `_stored_preferences`.

**Session start pattern:** At the start of a session, call `google_ads_get_preferences` with `entity_type: "ad_account"` and `entity_id: "global"` to retrieve stored defaults (e.g., `default_customer_id`, `default_login_customer_id`). If found, use them automatically.

**After account selection:** Offer to store the selected account using `google_ads_store_preference` so it is available in future sessions.

#### google_ads_store_preference
Store a persistent preference or observation for a Google Ads entity.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `entity_type` (string, required) — Entity type: `"ad_account"`, `"campaign"`, `"ad_set"` (= ad group), or `"ad"`
- `entity_id` (string, required) — The Google Ads entity ID (use `"global"` for account-level defaults)
- `key` (string, required) — Preference key (e.g., `"default_customer_id"`, `"preferred_conversion_metric"`)
- `value` (any, required) — The preference value — string, number, boolean, or object
- `source` (string, optional) — Who set this: `"agent"` (default), `"user"`, or `"system"`
- `note` (string, optional) — Context about why this preference was set

**Example — Store default account:**
```json
{
  "tool": "google_ads_store_preference",
  "parameters": {
    "reason": "User confirmed this is their default account",
    "entity_type": "ad_account",
    "entity_id": "global",
    "key": "default_customer_id",
    "value": "1234567890",
    "note": "Set after user confirmed account selection"
  }
}
```

**Example — Store default MCC login:**
```json
{
  "tool": "google_ads_store_preference",
  "parameters": {
    "reason": "Storing MCC ID for future managed account queries",
    "entity_type": "ad_account",
    "entity_id": "global",
    "key": "default_login_customer_id",
    "value": "9999999999"
  }
}
```

#### google_ads_get_preferences
Retrieve all stored preferences for a Google Ads entity.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `entity_type` (string, required) — Entity type: `"ad_account"`, `"campaign"`, `"ad_set"` (= ad group), or `"ad"`
- `entity_id` (string, required) — The Google Ads entity ID (use `"global"` for account-level defaults)

**Example:**
```json
{
  "tool": "google_ads_get_preferences",
  "parameters": {
    "reason": "Checking for stored default customer ID at session start",
    "entity_type": "ad_account",
    "entity_id": "global"
  }
}
```

#### google_ads_delete_preference
Delete a specific stored preference by key.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `entity_type` (string, required) — Entity type: `"ad_account"`, `"campaign"`, `"ad_set"` (= ad group), or `"ad"`
- `entity_id` (string, required) — The Google Ads entity ID
- `key` (string, required) — The preference key to delete

**Example:**
```json
{
  "tool": "google_ads_delete_preference",
  "parameters": {
    "reason": "User wants to clear the stored default account",
    "entity_type": "ad_account",
    "entity_id": "global",
    "key": "default_customer_id"
  }
}
```

---

### Feedback Tools

#### google_ads_developer_feedback
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
  "tool": "google_ads_developer_feedback",
  "parameters": {
    "reason": "User requested campaign budget update which is not yet supported",
    "feedback_type": "workflow_gap",
    "title": "Update campaign budget",
    "description": "User wanted to increase daily budget from $100 to $150 for campaign 'Brand Search' in account 1234567890.",
    "current_workaround": "Directed user to Google Ads UI to update budget manually",
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
    "feedback_type": "new_tool",
    "title": "Keyword performance with search term data in one call",
    "description": "User asked for a keyword analysis with search term opportunities. I had to call get_keyword_performance and get_search_terms_report separately, then manually cross-reference keywords with search terms. A combined tool that returns keyword performance alongside matching search terms would be significantly faster.",
    "current_workaround": "Called get_keyword_performance and get_search_terms_report separately, then cross-referenced results manually",
    "priority": "medium"
  }
}
```

---

## Tool Usage Patterns

### Pattern 1: Account Overview & Performance Report
**Workflow:**
1. Use `google_ads_list_accounts` to find the correct account
2. Use `google_ads_get_performance_report` with `level: "CAMPAIGN"` for campaign performance including per-conversion-action breakdowns
3. Present report with summary statistics and insights

### Pattern 2: Keyword Analysis
**Workflow:**
1. Use `google_ads_get_keyword_performance` for keyword metrics and quality scores
2. Use `google_ads_get_search_terms_report` for search term data
3. Identify top performers, underperformers, and negative keyword candidates
4. Provide keyword optimization recommendations

### Pattern 3: Geographic Performance Analysis
**Workflow:**
1. Use `google_ads_get_geo_performance` with `geo_level: "country"` for a high-level geographic overview
2. Drill into specific geographies with `geo_level: "geo_target_city"` or `"geo_target_metro"` filtered by `campaign_id`
3. Compare LOCATION_OF_PRESENCE vs AREA_OF_INTEREST performance
4. Identify high-spend, low-conversion geographies as exclusion candidates
5. Recommend geo bid adjustments based on CPA/ROAS differences across locations

**Important:** Only one geo level per query. Do not use `google_ads_get_insights` for geographic data.

### Pattern 4: Ad Creative Analysis
**Workflow:**
1. Use `google_ads_list_ads` to get ads for a campaign
2. Use `google_ads_get_insights` with `level: "AD"` for ad-level metrics
3. Compare creative variations and identify top performers

### Pattern 5: Budget & Spend Analysis
**Workflow:**
1. Use `google_ads_list_campaigns` for budget data
2. Use `google_ads_get_insights` with `segments: ["date"]` for daily spend trends
3. Calculate pacing metrics
4. Recommend budget adjustments

### Pattern 6: Write Operation Requested (Developer Feedback)
**Workflow:**
1. Inform the user that write operations are not yet available via Hopkin
2. Call `google_ads_developer_feedback` with `feedback_type: "workflow_gap"`
3. Provide guidance on how to perform the action manually via Google Ads

### Pattern 7: Proactive Efficiency Feedback
**When:** After completing any task where you believe a faster path should have existed — e.g., you needed multiple calls that could have been one, had to manually compute something the tool could return, or a dedicated tool for the workflow was missing.

**Workflow:**
1. Complete the user's request as normal
2. Call `google_ads_developer_feedback` with `feedback_type: "new_tool"` or `"improvement"` describing what would have been faster
3. Do NOT block the user's request — submit feedback after delivering the answer

### Pattern 8: Data Visualization

1. Fetch data with analytics tools (performance report, insights, geo performance, etc.)
2. Transform data into chart format (array of `{label, values}` objects)
3. Call `google_ads_render_chart` with the appropriate chart type
4. Present chart alongside summary table and written insights

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

- **Authentication errors** — User not authenticated or session expired. Call `google_ads_check_auth_status` to confirm, then direct the user to connect their account at https://app.hopkin.ai.
- **Invalid customer ID** — Ensure customer ID is 10 digits with no hyphens
- **Rate limiting** — Wait and retry with exponential backoff
- **Account not found** — Verify customer ID and user access

### Error Handling Best Practices

1. **Always check auth first** — If tools return auth errors, run `google_ads_check_auth_status` and direct the user to https://app.hopkin.ai to re-authenticate
2. **Validate customer ID format** — 10 digits, no hyphens (1234567890 not 123-456-7890)
3. **Handle pagination** — Don't assume all results are in the first page
4. **Provide clear messages** — Translate errors into user-friendly guidance

---

**Document Version:** 2.1
**Last Updated:** 2026-02-24
**Service:** Hopkin Google Ads MCP (https://app.hopkin.ai)
