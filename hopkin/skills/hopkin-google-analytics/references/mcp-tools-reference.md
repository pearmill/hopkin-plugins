# Hopkin Google Analytics MCP — Tool Reference

All tools use the `ga4_` prefix. The MCP is read-only against the GA4 Admin API (v1beta, plus v1alpha for attribution and enhanced measurement settings) and the GA4 Data API (v1beta).

Every tool accepts an optional `reason` (string) describing why the call is being made, and an optional `connection_id` (string) to pin a specific Google connection instead of the default.

---

## Health & Authentication

### ga4_ping

Health check; verifies the MCP server is reachable. No parameters.

### ga4_check_auth_status

Troubleshoot authentication issues. **Only use when another tool fails with a permission or auth error — do NOT call proactively.**

**Returns:** `authenticated` status, `user_id`, `email`, and a human-readable message.

---

## Discovery

### ga4_list_account_summaries

List every GA4 account and property visible to the connected Google account (Admin API accountSummaries). **Use this tool first** to discover which properties are available before calling other GA4 tools. Results are cached; pass `refresh: true` only when you need the latest list.

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `limit` | number | No | Max accounts per page (default 20, max 200) |
| `cursor` | string | No | Opaque pagination cursor from a previous response's `pagination.nextCursor` |
| `refresh` | boolean | No | Force a fresh fetch from the API, bypassing cache. Default: false |

**Returns:** `data` (accounts, each with account resource name, `display_name`, and `properties[]` of `{ property_id, display_name, property_type, parent }`), `count` (total accounts), `property_count` (total properties), `cached`, `synced_at`, and `pagination { hasMore, nextCursor }`.

### ga4_get_property_details

Setup-health snapshot for one GA4 property: property info, data streams (with enhanced measurement settings for web streams), key events, Google Ads links, attribution settings, and data retention settings. Sections that fail to load are returned with an error string instead of failing the whole call.

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `property_id` | string | Yes | GA4 property ID (numeric, e.g. `'123456789'`) or full resource name (`'properties/123456789'`) |

**Returns:** `property`, `data_streams`, `key_events`, `google_ads_links`, `attribution_settings`, `data_retention_settings` — each either the API payload or `{ error }`.

---

## Reporting

### ga4_run_report

Run a GA4 report (Data API runReport): arbitrary dimensions × metrics over one or more date ranges, with an optional simple dimension filter and ordering. Use `ga4_get_metadata` first to look up valid dimension/metric API names.

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `property_id` | string | Yes | GA4 property ID (numeric) or full resource name |
| `dimensions` | string[] | No | Up to 9 dimension API names (e.g. `sessionDefaultChannelGroup`, `date`) |
| `metrics` | string[] | Yes | 1-10 metric API names (e.g. `sessions`, `totalUsers`, `keyEvents`, `purchaseRevenue`) |
| `date_ranges` | array | Yes | 1-4 ranges of `{ start_date, end_date, name? }`. Dates are `YYYY-MM-DD` or relative (`30daysAgo`, `yesterday`, `today`) |
| `dimension_filter` | object | No | Single-field filter `{ field, values[], match_type?, case_sensitive?, negate? }` |
| `order_by` | object | No | `{ type: 'metric'\|'dimension', name, desc? }` |
| `limit` | number | No | Max rows, default 100, max 10000 |
| `offset` | number | No | Row offset for pagination |

**Returns:** `row_count` (total rows before pagination), `returned_rows`, and `rows` flattened as `{ dimension: value, metric: value }` objects. For a single date range: `metric_totals` (`{ metric: total }`). For multiple date ranges: `metric_totals_by_range` keyed by the dateRange dimension value (or the range's `name`).

**Example — sessions by channel (30 days):**

```json
{
  "property_id": "123456789",
  "dimensions": ["sessionDefaultChannelGroup"],
  "metrics": ["sessions", "totalUsers", "keyEvents"],
  "date_ranges": [{ "start_date": "30daysAgo", "end_date": "yesterday" }],
  "reason": "Channel mix overview for the last 30 days"
}
```

**Example — landing page revenue, filtered to Paid Search:**

```json
{
  "property_id": "123456789",
  "dimensions": ["landingPagePlusQueryString"],
  "metrics": ["sessions", "purchaseRevenue"],
  "date_ranges": [{ "start_date": "2024-01-01", "end_date": "2024-01-31" }],
  "dimension_filter": { "field": "sessionDefaultChannelGroup", "values": ["Paid Search"] },
  "order_by": { "type": "metric", "name": "purchaseRevenue" },
  "limit": 25,
  "reason": "Top paid-search landing pages by revenue"
}
```

### ga4_run_realtime_report

Run a GA4 realtime report (last 30 minutes of events). Primary use: verifying tags and key events fire after a tracking change, without waiting for standard processing lag.

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `property_id` | string | Yes | GA4 property ID (numeric) or full resource name |
| `dimensions` | string[] | No | Up to 9 realtime dimension API names (e.g. `eventName`, `unifiedScreenName`, `country`, `deviceCategory`) |
| `metrics` | string[] | Yes | 1-10 realtime metric API names (e.g. `activeUsers`, `eventCount`, `keyEvents`) |

Note: the realtime API supports a smaller set of dimensions and metrics than the standard report API.

**Example — verify events firing:**

```json
{
  "property_id": "123456789",
  "dimensions": ["eventName"],
  "metrics": ["eventCount"],
  "reason": "Confirm tags fire after a tracking change"
}
```

### ga4_get_metadata

List the dimensions and metrics available on a GA4 property (including custom definitions), so `ga4_run_report` calls use valid API names instead of guessing.

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `property_id` | string | Yes | GA4 property ID (numeric) or full resource name |
| `search` | string | No | Case-insensitive substring filter on API name / UI name (e.g. `'channel'`, `'revenue'`). Omit to list everything |

**Returns:** `dimension_count`, `metric_count`, and matching dimensions/metrics with `api_name`, `ui_name`, `category`, `type` (metrics), and `custom` flag.

---

## Connections

Connection tools manage which Google account's Analytics access is used. Only Google connections with the `analytics.readonly` scope are returned/used.

### ga4_list_connections

List the Google Analytics connections available to you — both ones you own and ones shared with you via an organization. Use this to discover connection IDs for set_default / share / rename / revoke.

### ga4_set_default_connection

Set the Google Analytics connection used by default for subsequent GA4 tool calls. The default is scoped to the calling actor (your user account, or the API key being used).

### ga4_share_connection

Share an owned Google Analytics connection with all members of your organization, so teammates can use it without reconnecting Google themselves. You must be the owner.

### ga4_unshare_connection

Stop sharing an owned Google Analytics connection with your organization. Teammates lose access immediately. You must be the owner. **Destructive — confirm with the user first.**

### ga4_rename_connection

Rename a Google Analytics connection.

### ga4_revoke_connection

Revoke a Google Analytics connection. **Destructive — confirm with the user first.**

---

## Feedback

### ga4_developer_feedback

Submit feedback about missing tools, improvements, bugs, or workflow gaps in the GA4 MCP toolset. Not for user-facing issues (auth errors, API errors).

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `feedback_type` | string | Yes | `new_tool`, `improvement`, `bug`, or `workflow_gap` |
| `title` | string | Yes | Short description (5-200 chars) |
| `description` | string | Yes | What is needed and why (20-2000 chars) |
| `current_workaround` | string | No | How you're working around the gap |
| `priority` | string | No | `low`, `medium` (default), `high` |

**Returns:** confirmation that feedback was recorded.
