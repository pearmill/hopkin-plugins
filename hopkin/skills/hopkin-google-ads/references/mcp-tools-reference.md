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

#### google_ads_get_billing_status
Call this after a tool call fails with a billing error (HTTP 402) before retrying. It explains why, gives the organization owner a link to pay (a member gets the owner's contact instead), and says when to retry.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `checkout_tier` (string, optional) — Organization owner only: also create a checkout link for this plan (`starter` or `pro`)

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
List campaigns for a Google Ads account. Each row also carries the campaign's serving settings: `networkSettings` under Google's names (`targetSearchNetwork` is the search partners setting, `targetContentNetwork` is the Display Network, `targetPartnerSearchNetwork` is the Google Partner Network, not search partners), `aiMax` `{ enabled, bundlingRequired }` (Search campaigns only), `assetAutomation[]`, and `finalUrlExpansion` `{ status, effective, source }`, where `source` is `explicit` (the campaign's own setting), `google_default` (Google's default: off for Search, on for Performance Max) or `unset` (an AI Max Search campaign that sets nothing, so `effective` is `null`). It also carries URL tracking (`tracking_url_template`, `final_url_suffix`, `url_custom_parameters`). A `null` setting means Google returned nothing or the setting does not apply, never "off". Ad schedules are never capped, but they come back only with `include_criteria` `"summary"` (the default) or `"full"`: there, a campaign with no `adSchedules` runs at all hours, unless `warnings` names it as a campaign whose criteria could not be fetched. `include_criteria` `"none"` omits `adSchedules` from every campaign, so a missing schedule there means not fetched, never "runs at all hours". For when and by whom a setting changed, use `google_ads_get_activities`.

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
- `segments` (array of strings, optional) — Additional breakdown dimensions: `"date"`, `"device"`, `"ad_network_type"` (use `ad_network_type` for Performance Max channel breakdown)
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
- `segments` (array, optional) — Segmentation dimensions (e.g., `["date"]`, `["device"]`, `["ad_network_type"]`, `["conversion_action_name"]`)
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

#### google_ads_get_auto_applied_recommendations
Check which recommendation types Google is automatically applying to the account. Returns a list of auto-applied recommendation types (e.g., auto-adjusted bids, expanded keywords, upgraded campaigns). Important for auditing automated account changes.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `login_customer_id` (string, optional) — Manager account ID for MCC-managed accounts

**Example:**
```json
{
  "tool": "google_ads_get_auto_applied_recommendations",
  "parameters": {
    "reason": "Auditing which recommendations Google auto-applies to this account",
    "customer_id": "1234567890"
  }
}
```

---

#### google_ads_get_asset_report
Asset-level performance report across multiple hierarchy levels. Returns per-asset metrics with optional conversion action breakdowns and change history.

**Hierarchy levels:**
- `AD_GROUP` — RSA/App/Demand Gen assets via `ad_group_ad_asset_view` (includes `performance_label`) + `ad_group_asset` for gap-filling
- `CAMPAIGN` — Standard campaigns via `campaign_asset` + PMax asset groups via `asset_group_asset` (automatically included when CAMPAIGN is specified)
- `CUSTOMER` — Account-wide assets via `customer_asset`
- `ASSET_GROUP` — PMax-only via `asset_group_asset`

When `levels` is omitted, all levels are queried. Conversion breakdown is always fetched alongside main metrics unless disabled.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `login_customer_id` (string, optional) — Manager account ID. Required when the target account is managed by an MCC
- `date_preset` (string) — Date range preset (e.g., `"LAST_7_DAYS"`, `"LAST_30_DAYS"`, `"THIS_MONTH"`). Required if `date_range` not provided.
- `date_range` (object) — Custom date range with `start_date` and `end_date` (YYYY-MM-DD). Required if `date_preset` not provided.
- `levels` (array of strings, optional) — Hierarchy levels to query: `"CUSTOMER"`, `"CAMPAIGN"`, `"AD_GROUP"`, `"ASSET_GROUP"`. Defaults to all levels.
- `campaign_ids` (array of strings, optional) — Filter to specific campaign IDs
- `ad_group_ids` (array of strings, optional) — Filter to specific ad group IDs
- `asset_ids` (array of strings, optional) — Filter to specific asset IDs
- `asset_types` (array of strings, optional) — Filter by asset type: `TEXT`, `IMAGE`, `YOUTUBE_VIDEO`, `MEDIA_BUNDLE`, `SITELINK`, `CALLOUT`, `STRUCTURED_SNIPPET`, `CALL`, `PRICE`, `PROMOTION`, `LEAD_FORM`, etc.
- `field_types` (array of strings, optional) — Filter by field type: `HEADLINE`, `DESCRIPTION`, `LONG_HEADLINE`, `BUSINESS_NAME`, `MARKETING_IMAGE`, `PORTRAIT_MARKETING_IMAGE`, `LOGO`, `YOUTUBE_VIDEO`, `SITELINK`, `CALLOUT`, `STRUCTURED_SNIPPET`, `CALL`, `PRICE`, etc.
- `order_by` (string, optional) — Sort metric: `impressions` (default), `clicks`, `cost`, `conversions`, `ctr`
- `limit` (number, optional) — Max rows to return, 1–1000 (default 20)
- `include_change_history` (boolean, optional) — Include `added_at`/`last_modified_at` from `change_event` resource (default false). Uses a 29-day window.
- `include_conversion_breakdown` (boolean, optional) — Include per-conversion-action breakdown on each asset row (default false). When false, significantly reduces response size.
- `cursor` (string, optional) — Opaque pagination cursor from a previous response

**Returns:**
- `assets` — Array of `AssetReportRow` with `asset_id`, `asset_name`, `asset_type`, `content`, `field_type`, `performance_label`, `impressions`, `clicks`, `cost`, `ctr`, `cpc`, `conversions`, `conversion_rate`, `view_through_conversions`, `association_level`, `association_status`, `is_pmax`, hierarchy IDs/names, policy fields, optional `added_at`/`last_modified_at`, optional `conversion_breakdown`
- `count` — Number of assets in this page
- `nextCursor` — Opaque cursor for next page (absent if no more pages)
- `date_range`, `filters`, `order_by`, `limit`, `include_conversion_breakdown`, `fetched_at` — Metadata

**Note:** Video metrics are not available (prohibited by Google Ads API on asset resources).

**Example — All assets last 30 days:**
```json
{
  "tool": "google_ads_get_asset_report",
  "parameters": {
    "reason": "Review asset performance across all levels",
    "customer_id": "1234567890",
    "date_preset": "LAST_30_DAYS"
  }
}
```

**Example — Top headlines by impressions:**
```json
{
  "tool": "google_ads_get_asset_report",
  "parameters": {
    "reason": "Find top-performing headlines",
    "customer_id": "1234567890",
    "date_preset": "LAST_7_DAYS",
    "field_types": ["HEADLINE"],
    "order_by": "impressions",
    "limit": 20
  }
}
```

**Example — PMax asset groups:**
```json
{
  "tool": "google_ads_get_asset_report",
  "parameters": {
    "reason": "Analyze PMax asset group performance",
    "customer_id": "1234567890",
    "date_preset": "LAST_30_DAYS",
    "levels": ["CAMPAIGN"]
  }
}
```

**Example — With change history:**
```json
{
  "tool": "google_ads_get_asset_report",
  "parameters": {
    "reason": "Asset performance with change dates",
    "customer_id": "1234567890",
    "date_preset": "LAST_30_DAYS",
    "include_change_history": true
  }
}
```

---

### Keyword Tools

#### google_ads_list_keywords
List keywords with their approval (policy) status, across the whole account or one campaign or ad group. Each row has the keyword text, match type, status, `approval_status` (APPROVED, DISAPPROVED, PENDING_REVIEW, UNDER_REVIEW), `disapproval_reasons` (Google's own wording, e.g. "Destination not working"), `system_serving_status` (ELIGIBLE, or RARELY_SERVED for low search volume), `final_urls`, and the campaign and ad group ids, names and statuses. Keywords in removed campaigns and ad groups are left out; keywords in paused ones are included. Always fetches live data, never cached. Negative keywords are not listed; use `google_ads_list_negative_keywords`. For clicks, cost, conversions and Quality Score use `google_ads_get_keyword_performance`.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `login_customer_id` (string, optional) — Manager account ID. Required when the target account is managed by an MCC — omitting it causes permission errors
- `campaign_id` (string, optional) — Only keywords in this campaign
- `ad_group_id` (string, optional) — Only keywords in this ad group
- `approval_status` (array of strings, optional) — `DISAPPROVED`, `UNDER_REVIEW`, `PENDING_REVIEW`, `APPROVED`
- `system_serving_status` (array of strings, optional) — `RARELY_SERVED` or `ELIGIBLE`
- `status` (array of strings, optional) — `ENABLED`, `PAUSED`, `REMOVED` (default `ENABLED` and `PAUSED`; removed keywords carry no approval or serving status)
- `match_type` (array of strings, optional) — `EXACT`, `PHRASE`, `BROAD`
- `limit` (number, optional) — Keywords per page (1–200, default 50)
- `cursor` (string, optional) — The `nextCursor` value from the previous response, with otherwise identical parameters

**Example — keywords with policy problems:**
```json
{
  "tool": "google_ads_list_keywords",
  "parameters": {
    "reason": "Daily check for disapproved keywords",
    "customer_id": "1234567890",
    "approval_status": ["DISAPPROVED", "UNDER_REVIEW", "PENDING_REVIEW"]
  }
}
```

#### google_ads_get_keyword_performance
Get keyword performance data with quality scores and all key metrics. Also runs a parallel conversion breakdown query returning per-conversion-action stats grouped by ad group. Supports `ad_network_type` segment for network-level breakdown. Only keywords that served appear; for approval status use `google_ads_list_keywords`.

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
Get search terms report showing which actual search queries triggered ads, with each query's keyword status. The default rows come from `search_term_view` and **never include Performance Max campaigns**. Supports `ad_network_type` segment for network-level breakdown. The per-conversion-action breakdown is opt-in (`include_conversion_breakdown: true`, or `conversion_action_name` in `segments`) and keyed by search term text; if a breakdown query fails, that breakdown comes back empty and `warnings` says why. Google does not disclose every term for privacy.

**Performance Max search terms:** with `include_pmax_search_terms: true`, rows come from `campaign_search_term_view` instead: one row per campaign and query, with no ad group, carrying `campaign_search_term_view_search_term`, `segments_search_term_targeting_status`, `segments_search_term_match_type`, `campaign_id`, `campaign_name`, impressions, clicks, cost and conversions. It works account-wide or with `campaign_id`.
- `search_term_status` filters on the targeting status: `["NONE", "ADDED"]` leaves out queries already negated (EXCLUDED, ADDED_EXCLUDED)
- `include_conversion_breakdown: true` gives per-action conversions keyed by query text
- The response adds a `coverage` block: `search_terms` (the totals of every matching query, all pages, not just this one), `campaigns_search_network` (the PMax campaigns' own totals on Google Search and search partners) and `campaigns_all_networks`, each with impressions, clicks, cost, conversions and conversions_value. A campaign figure is left out, with a `warnings` entry, when its query fails
- These are search queries only, and Google withholds low-volume ones, so they never add up to the campaign totals. Report `coverage.search_terms.cost` as a share of the campaign figures, never claim the visible queries are all PMax spend, and do not treat the gap as missing data
- `ad_group_id`, `include_landing_pages`, `pmax_search_categories` and keyword segments (`keyword.*`, `match_type`) are refused with a 422: Performance Max has no ad groups or keywords. Call again without them
- For grouped search categories (themes) rather than queries, use `pmax_search_categories: true` instead

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `login_customer_id` (string, optional) — Manager account ID. Required when the target account is managed by an MCC — omitting it causes permission errors
- `date_preset` / `date_range` — One of the two is required
- `campaign_id` (string, optional) — Filter by campaign
- `ad_group_id` (string, optional) — Filter by ad group (refused with `include_pmax_search_terms`)
- `search_term_status` (array of strings, optional) — Filter by status: `ADDED`, `EXCLUDED`, `ADDED_EXCLUDED`, `NONE`
- `order_by` (string, optional) — Sort by `impressions`, `clicks`, `cost`, `conversions` or `ctr` (descending)
- `include_conversion_breakdown` (boolean, optional, default false) — Conversion breakdown by conversion action, keyed by search term text
- `include_landing_pages` (boolean, optional, default false) — Final URLs per ad group (refused with `include_pmax_search_terms`)
- `include_pmax_search_terms` (boolean, optional, default false) — Individual Performance Max queries plus the `coverage` block
- `pmax_search_categories` (boolean, optional, default false) — Performance Max grouped search categories (themes), not individual queries
- `segments` (array of strings, optional) — e.g. `ad_network_type`, `device`
- `limit` (number, optional) — Rows per page (1–1000, default 40)
- `cursor` (string, optional) — The `nextCursor` value from the previous response, with the same filters

**Example:**
```json
{
  "tool": "google_ads_get_search_terms_report",
  "parameters": {
    "reason": "Finding negative keyword candidates from search terms",
    "customer_id": "1234567890",
    "campaign_id": "123456789",
    "date_preset": "LAST_30_DAYS",
    "order_by": "cost",
    "limit": 100
  }
}
```

**Example — Performance Max queries not yet negated:**
```json
{
  "tool": "google_ads_get_search_terms_report",
  "parameters": {
    "reason": "Find PMax queries to negate",
    "customer_id": "1234567890",
    "campaign_id": "5555555555",
    "date_preset": "LAST_30_DAYS",
    "include_pmax_search_terms": true,
    "search_term_status": ["NONE", "ADDED"],
    "order_by": "cost"
  }
}
```

#### google_ads_list_negative_keywords
List negative keywords at campaign or ad-group level. Use for search term audit workflows — cross-reference with search terms report to identify wasteful queries. Filter by match type or scope to a specific level.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `login_customer_id` (string, optional) — Manager account ID for MCC-managed accounts
- `campaign_id` (string, optional) — Filter to a specific campaign
- `ad_group_id` (string, optional) — Filter to a specific ad group
- `level` (string, optional) — Scope: `CAMPAIGN`, `AD_GROUP`, or `ALL` (default: `ALL`)
- `match_type` (string, optional) — Filter by match type (e.g., `EXACT`, `PHRASE`, `BROAD`)
- `limit` (number, optional) — Max results per page (1–100)
- `cursor` (string, optional) — Pagination cursor

**Example:**
```json
{
  "tool": "google_ads_list_negative_keywords",
  "parameters": {
    "reason": "Auditing negative keywords for search term optimization",
    "customer_id": "1234567890",
    "campaign_id": "111222333",
    "level": "CAMPAIGN"
  }
}
```

#### google_ads_list_negative_keyword_lists
List shared negative keyword lists and their associations. Shows which campaigns use each shared list and optionally includes the keywords in each list.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `login_customer_id` (string, optional) — Manager account ID for MCC-managed accounts
- `list_id` (string, optional) — Fetch a specific list by ID
- `include_keywords` (boolean, optional) — Include the keywords in each list (default: false)
- `include_campaign_associations` (boolean, optional) — Include campaigns using each list (default: false)
- `limit` (number, optional) — Max results per page (1–100)
- `cursor` (string, optional) — Pagination cursor

**Example:**
```json
{
  "tool": "google_ads_list_negative_keyword_lists",
  "parameters": {
    "reason": "Auditing shared negative keyword lists across campaigns",
    "customer_id": "1234567890",
    "include_keywords": true,
    "include_campaign_associations": true
  }
}
```

---

### Landing Page Tools

#### google_ads_get_landing_page_report
Landing page performance from the `landing_page_view` resource: clicks, impressions, cost, conversions and `speed_score` grouped by landing page URL, with per-conversion-action breakdowns included automatically. `speed_score` is Google's mobile landing page speed score, 1–10 with 10 fastest, measured from mobile ad clicks. It is on every row and is `null` when Google has no measurement for that row (common on rows with little mobile traffic); `null` means not measured, not slow. It is the only landing page quality signal Google Ads still reports. Preferred tool for all landing page analysis.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `login_customer_id` (string, optional) — Manager account ID. Required when the target account is managed by an MCC — omitting it causes permission errors
- `date_preset` (string, optional) — e.g. `"LAST_30_DAYS"`; or `date_range` (`start_date`, `end_date`)
- `segments` (array of strings, optional) — `date`, `device`, `ad_network_type`
- `campaign_id` (string, optional) — Filter by campaign
- `ad_group_id` (string, optional) — Filter by ad group
- `url_contains` (string, optional) — Filter by URL substring
- `order_by` (string, optional) — `impressions`, `clicks` (default), `cost`, `conversions`, `ctr`
- `limit` (number, optional) — Rows per page (1–1000, default 25)
- `cursor` (string, optional) — The `nextCursor` value from the previous response, with every other parameter unchanged

**Example:**
```json
{
  "tool": "google_ads_get_landing_page_report",
  "parameters": {
    "reason": "Product page performance",
    "customer_id": "1234567890",
    "date_preset": "LAST_30_DAYS",
    "url_contains": "/products/"
  }
}
```

---

### Activity Tools

#### google_ads_get_activities
Retrieve change history (audit log) for a Google Ads account. Shows what changed, when it changed, which user made the change, and which fields were modified. Uses the `change_event` resource — data is always fetched fresh (no caching).

**Limitations:**
- Only changes within the past 30 days are available (Google Ads API limit)
- Not all changes appear here — some automated or system-generated changes do not produce `change_event` entries
- Changes may take up to 3 minutes to appear after they are made

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `login_customer_id` (string, optional) — Manager account ID. Required when the target account is managed by an MCC
- `start_date` (string, optional) — Start date in YYYY-MM-DD format (defaults to 7 days ago; must be within past 30 days)
- `end_date` (string, optional) — End date in YYYY-MM-DD format (defaults to today)
- `resource_type` (string, optional) — Filter to a specific resource type: `AD`, `AD_GROUP`, `AD_GROUP_AD`, `AD_GROUP_CRITERION`, `CAMPAIGN`, `CAMPAIGN_BUDGET`, `CAMPAIGN_CRITERION`, `ASSET`, `ASSET_SET`
- `asset_ids` (array of strings, optional) — Filter to specific asset IDs (numeric). Automatically sets `resource_type` to `ASSET`. e.g. `["123456789", "987654321"]`
- `limit` (number, optional) — Max results per page (1–1000, default 50)
- `cursor` (string, optional) — Opaque pagination cursor from a previous response

**Returns:**
- `data` — Array of change events, each with:
  - `changeDatetime`, `changeResourceType`, `resourceChangeOperation`, `changeResourceName`, `changedFields`, `userEmail`, `clientType`
  - `description` (string, optional) — Human-readable summary for `CAMPAIGN_CRITERION` events (e.g., "Canada added to geo targeting (inclusion)"). When present, use this directly.
  - `criterionNegative` (boolean, optional) — For `CAMPAIGN_CRITERION` events: `false` = inclusion, `true` = exclusion. Authoritative — do NOT infer from `changedFields`.
  - `criterionType` (string, optional) — e.g., `"LOCATION"`, `"KEYWORD"`, `"PLACEMENT"`
  - `criterionDisplayName` (string, optional) — Human-readable name, e.g., `"Canada"`, `"running shoes"`
- `date_range` — The start/end dates queried
- `pagination` — `{hasMore, nextCursor}`
- `fetched_at` — ISO timestamp

**Example — Recent account activity:**
```json
{
  "tool": "google_ads_get_activities",
  "parameters": {
    "reason": "Review recent account changes",
    "customer_id": "1234567890"
  }
}
```

**Example — Campaign changes only:**
```json
{
  "tool": "google_ads_get_activities",
  "parameters": {
    "reason": "See recent campaign edits",
    "customer_id": "1234567890",
    "resource_type": "CAMPAIGN"
  }
}
```

**Example — Specific asset activity:**
```json
{
  "tool": "google_ads_get_activities",
  "parameters": {
    "reason": "Check recent changes to specific assets",
    "customer_id": "1234567890",
    "asset_ids": ["123456789", "987654321"]
  }
}
```

**Example — Custom date range:**
```json
{
  "tool": "google_ads_get_activities",
  "parameters": {
    "reason": "February activity audit",
    "customer_id": "1234567890",
    "start_date": "2026-02-01",
    "end_date": "2026-02-28"
  }
}
```

---

### Audience Tools

#### google_ads_list_audiences
List audience lists (user lists): Customer Match, remarketing, rule-based, similar and lookalike segments, with name, type, size (Search and Display), membership status and match rate.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `login_customer_id` (string, optional) — Manager account ID for MCC-managed accounts
- `type` (array, optional) — Filter by audience type, e.g. `CRM_BASED`, `REMARKETING`, `RULE_BASED`, `LOOKALIKE`
- `membership_status` (string, optional) — `OPEN` or `CLOSED`
- `search` (string, optional) — Case-insensitive name filter
- `limit` (number, optional) — Lists per page (default 20, max 100)
- `cursor` (string, optional) — The `nextCursor` value from the previous response, with every other parameter unchanged
- `connection_id` (string, optional) — Use a specific connection instead of the default. Call `google_ads_list_connections` to discover IDs.

#### google_ads_get_audience_report
Performance by audience and demographic: answers "lookalike vs custom segment vs remarketing — which performs?" and "which age groups / genders convert?" in one call. Each row carries the campaign and ad group, criterion type and status, the resolved audience name and subtype, bid modifier, impressions, clicks, cost, CTR, average CPC, conversions, conversion value, cost per conversion and ROAS, with a per-conversion-action breakdown. Rows are ranked by cost; returns JSON.

Audiences in one ad group overlap, so audience rows do not add up to the ad group total (demographic buckets do). Performance Max has no rows: its audiences are signals, not targeting, so use `google_ads_get_asset_report` with `include_audience_signals: true`.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `login_customer_id` (string, optional) — Manager account ID for MCC-managed accounts
- `dimensions` (array, optional) — `AUDIENCE` (default), `AGE_RANGE`, `GENDER`, `PARENTAL_STATUS`, `INCOME_RANGE`; several at once tag each row with `dimension`
- `level` (string, optional) — `AD_GROUP` (default) or `CAMPAIGN`
- `date_preset` (string, optional) — Default `LAST_30_DAYS`; or `date_range` (`start_date`, `end_date`)
- `segments` (array, optional) — `date` and/or `device`
- `campaign_ids` / `ad_group_ids` (array, optional) — Restrict to these IDs (up to 100; `ad_group_ids` at `AD_GROUP` level only)
- `criterion_types` (array, optional) — Restrict to these audience criterion types
- `include_zero_activity` (boolean, optional) — Include attached audiences with no impressions, to check whether an audience serves at all
- `include_all_conversions` (boolean, optional) — Add all conversions and view-through conversions
- `include_video_metrics` (boolean, optional) — Add video views, view rate, CPV and quartiles (YouTube, Video, Demand Gen)
- `limit` / `cursor` (optional) — Pagination; pass `nextCursor` back with every other parameter unchanged
- `connection_id` (string, optional) — Use a specific connection instead of the default. Call `google_ads_list_connections` to discover IDs.

---

### Keyword Planning Tools

#### google_ads_generate_keyword_ideas
Keyword suggestions from seed keywords and/or a URL (yours or a competitor's), with average monthly searches, competition level and estimated bid ranges.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `login_customer_id` (string, optional) — Manager account ID for MCC-managed accounts
- `keywords` (array, optional) — Seed keywords (max 20). Provide `keywords`, `url`, or both
- `url` (string, optional) — Seed URL
- `language` (string, optional) — ISO 639-1 code (default `"en"`)
- `geo_targets` (array, optional) — ISO 3166-1 alpha-2 country codes (default `["US"]`)
- `network` (string, optional) — `GOOGLE_SEARCH` (default) or `GOOGLE_SEARCH_AND_PARTNERS`
- `include_adult_keywords` (boolean, optional) — Default false
- `include_monthly_volumes` (boolean, optional) — Add per-month search volume history
- `limit` (number, optional) — Ideas per page (1–1000, default 50)
- `cursor` (string, optional) — The `nextCursor` value from the previous response
- `connection_id` (string, optional) — Use a specific connection instead of the default. Call `google_ads_list_connections` to discover IDs.

**Example:**
```json
{
  "tool": "google_ads_generate_keyword_ideas",
  "parameters": {
    "reason": "Finding keyword ideas for a new running shoes campaign",
    "customer_id": "1234567890",
    "keywords": ["running shoes", "athletic footwear"],
    "include_monthly_volumes": true
  }
}
```

#### google_ads_get_keyword_historical_metrics
Historical search metrics (average monthly searches, competition, bid estimates) for keywords you already have. Unlike keyword ideas, it returns metrics for exactly the keywords given.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `login_customer_id` (string, optional) — Manager account ID for MCC-managed accounts
- `keywords` (array, required) — 1–200 keywords
- `language` (string, optional) — ISO 639-1 code (default `"en"`)
- `geo_targets` (array, optional) — ISO 3166-1 alpha-2 country codes (default `["US"]`)
- `network` (string, optional) — `GOOGLE_SEARCH` (default) or `GOOGLE_SEARCH_AND_PARTNERS`
- `include_monthly_volumes` (boolean, optional) — Add month-by-month search volume
- `connection_id` (string, optional) — Use a specific connection instead of the default. Call `google_ads_list_connections` to discover IDs.

#### google_ads_generate_keyword_forecast_metrics
Forecasts campaign performance for a keyword set under a budget and bidding strategy: projected impressions, clicks, cost, CTR, conversions and CPA. Amounts are in micros (10000000 = $10).

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `login_customer_id` (string, optional) — Manager account ID for MCC-managed accounts
- `keywords` (array, required) — 1–200 keywords, each with `text`, optional `match_type` and optional `max_cpc_bid_micros`
- `daily_budget_micros` (integer, required) — Daily budget in micros
- `bidding_strategy` (string, optional) — `MANUAL_CPC` (default), `MAXIMIZE_CLICKS` or `MAXIMIZE_CONVERSIONS`
- `default_max_cpc_bid_micros` (integer, optional) — Required for `MANUAL_CPC`; per-keyword bids override it
- `max_cpc_bid_ceiling_micros` (integer, optional) — Bid ceiling for `MAXIMIZE_CLICKS`
- `language` (string, optional) — ISO 639-1 code (default `"en"`)
- `geo_targets` (array, optional) — ISO 3166-1 alpha-2 country codes (default `["US"]`)
- `network` (string, optional) — `GOOGLE_SEARCH` (default) or `GOOGLE_SEARCH_AND_PARTNERS`
- `forecast_start_date` / `forecast_end_date` (string, optional) — YYYY-MM-DD; defaults to tomorrow through 30 days later
- `negative_keywords` (array, optional) — Keyword texts to exclude
- `conversion_rate` (number, optional) — Expected conversion rate (0–1)
- `currency_code` (string, optional) — ISO 4217; defaults to the account currency
- `connection_id` (string, optional) — Use a specific connection instead of the default. Call `google_ads_list_connections` to discover IDs.

#### google_ads_generate_ad_group_themes
Suggests which existing ad group each keyword belongs in, with recommended match types, and flags ad groups it cannot use.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `login_customer_id` (string, optional) — Manager account ID for MCC-managed accounts
- `keywords` (array, required) — 1–2000 keywords
- `ad_groups` (array, required) — Ad group resource names, e.g. `"customers/1234567890/adGroups/111222333"`
- `connection_id` (string, optional) — Use a specific connection instead of the default. Call `google_ads_list_connections` to discover IDs.

---

### URL Tracking Tools

#### google_ads_get_url_tracking_config
Complete URL and UTM tracking configuration across every hierarchy level (account, campaign, ad group, ad, keyword and asset) in one call. Preferred tool for any UTM or tracking audit; do not chain list tools for this. Returns each entity's own tracking template, final URL suffix, custom parameters and final URLs, plus the effective value resolved through Google's precedence chain (account → campaign → ad group → ad → keyword) and the level that set it. An unset field is `null`, never omitted, so "no tracking template here" is verifiable. The `coverage` block counts entities scanned at each level across the whole account, not just the returned page.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `login_customer_id` (string, optional) — Manager account ID for MCC-managed accounts
- `levels` (array, optional) — Levels to scan (default all six; `ACCOUNT` is always included)
- `scope` (string, optional) — `"all"` (default) returns every entity with its effective config; `"overrides"` returns only entities that set their own values
- `campaign_ids` / `ad_group_ids` (array, optional) — Restrict the scan to these entities and their descendants
- `status` (array, optional) — Entity status filter (default `["ENABLED"]`)
- `limit` (number, optional) — Rows per page (default 200, max 1000)
- `cursor` (string, optional) — The `nextCursor` value from the previous response
- `connection_id` (string, optional) — Use a specific connection instead of the default. Call `google_ads_list_connections` to discover IDs.

---

### Creative Preview Tools

#### google_ads_preview_ads
**MCP App.** Renders ads with their creative (images, YouTube thumbnails) and a configurable metrics overlay in a visual UI. Offer it when the user asks what their ads look like or is comparing creative.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `customer_id` (string, required) — Google Ads customer ID
- `login_customer_id` (string, optional) — Manager account ID for MCC-managed accounts
- `ads` (array, required) — 1–20 ads to preview, each `{ ad_id, metrics? }` (metrics: key → display value, e.g. `{ "spend": "150.00" }`)
- `metric_labels` (object, optional) — Display labels for metric keys
- `connection_id` (string, optional) — Use a specific connection instead of the default. Call `google_ads_list_connections` to discover IDs.

---

### Connection Tools

A user can have more than one Google connection: their own, or ones shared with them through their organization. Every account and reporting tool accepts an optional `connection_id`; omit it to use the default connection.

#### google_ads_list_connections
List the connections available to the user, owned and shared, with each one's ID, name and whether it is the default.

**Parameters:**
- `reason` (string, required) — Reason for the call

#### google_ads_set_default_connection
Set the connection used when `connection_id` is omitted. The default is scoped to the caller (the user account, or the API key in use). Call it only when the user asks.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `connection_id` (string, required) — UUID of the connection

#### google_ads_share_connection
Share an owned connection with every member of the user's organization. Owner only.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `connection_id` (string, required) — UUID of the connection

#### google_ads_unshare_connection
Stop sharing an owned connection; teammates lose access immediately. Owner only.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `connection_id` (string, required) — UUID of the connection

#### google_ads_rename_connection
Change an owned connection's display name. The grant and account are unaffected. Owner only.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `connection_id` (string, required) — UUID of the connection
- `display_name` (string, required) — New name

#### google_ads_revoke_connection
Revoke (soft-delete) an owned connection. Defaults pointing to it are invalidated and shared members lose access. The grant at Google is not revoked; the user disconnects in the dashboard for that. Owner only; confirm with the user first.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `connection_id` (string, required) — UUID of the connection

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
2. Use `google_ads_get_search_terms_report` for search term data (`include_pmax_search_terms: true` for Performance Max queries, which the default rows leave out)
3. Use `google_ads_list_keywords` for policy status (disapproved, under review, rarely served)
4. Identify top performers, underperformers, and negative keyword candidates
5. Provide keyword optimization recommendations

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

**Document Version:** 2.3
**Last Updated:** 2026-03-22
**Service:** Hopkin Google Ads MCP (https://app.hopkin.ai)
