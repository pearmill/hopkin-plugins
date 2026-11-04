# ChatGPT Ads MCP Tools Reference — Hopkin

Complete parameter reference for all Hopkin ChatGPT Ads MCP tools. For setup and authentication, see **SKILL.md**.

This MCP is **read-only**. No tool creates, updates, or deletes anything on the ChatGPT Ads platform. The connection tools write only to Hopkin's own records.

---

## Core Tools

> **Important:** Every Hopkin tool call requires a `reason` (string) parameter for audit trail.

> **Connection selection:** Platform-facing tools accept an optional `connection_id`. Omit it to use your default connection. Get valid ids from `chatgpt_ads_list_connections` — never guess one.

### Authentication Tools

#### chatgpt_ads_check_auth_status
Check whether a ChatGPT Ads API key is connected and still accepted by the platform. **Do not call proactively** — call the tool you actually need, and use this only after another tool fails with a permission or authentication error.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `connection_id` (string, optional) — Which connection to check

#### chatgpt_ads_ping
Health check. Returns server status, version, and timestamp. Does not contact the ChatGPT Ads API.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `message` (string, optional) — Optional echo message

---

### Account Tools

#### chatgpt_ads_list_ad_accounts
List the ChatGPT Ads accounts you can reach.

Each API key is scoped to exactly one ad account and the platform has no account-listing endpoint, so this lists your **connected accounts** — it makes no upstream call. Shows the connection's display name, which may differ from the platform's own account name.

**Parameters:**
- `reason` (string, required) — Reason for the call

#### chatgpt_ads_get_ad_account
Get details of the ChatGPT Ads account: name, status, **currency**, **timezone**, website, and review status.

Call this before reporting any money or date value. Spend is in the account's currency and date windows are interpreted in the account's timezone.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `connection_id` (string, optional) — Which connection to use

---

### Structure Tools

> The API has **no account-wide ad group or ad listing**. Traverse campaigns → ad groups → ads.

#### chatgpt_ads_list_campaigns
List campaigns, with optional status and name filtering.

Budgets and bids are **integer micros** (1,000,000 micros = 1 unit of account currency). Targeting may include `targeting.custom_audiences.ids` as bare opaque IDs — resolve them with `chatgpt_ads_list_custom_audiences`.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `limit` (integer, optional) — Page size
- `cursor` (string, optional) — Opaque pagination cursor from a previous response; do not construct one
- `refresh` (boolean, optional) — Bypass cache and fetch synchronously
- `campaign_ids` (array of string, optional) — Resolve specific campaigns by ID
- `status` (string, optional) — Filter by status
- `search` (string, optional) — Filter by name substring
- `connection_id` (string, optional)

#### chatgpt_ads_list_ad_groups
List ad groups in a campaign.

**Parameters:**
- `campaign_id` (string, **required**) — Obtain from `chatgpt_ads_list_campaigns`; never guess
- `reason` (string, required)
- `limit` (integer, optional)
- `cursor` (string, optional)
- `refresh` (boolean, optional)
- `ad_group_ids` (array of string, optional) — Resolve specific ad groups by ID
- `status` (string, optional)
- `search` (string, optional)
- `connection_id` (string, optional)

#### chatgpt_ads_list_ads
List ads in an ad group, including creative and **review status**.

Either `ad_group_id` or `ad_ids` is required. An ad may be `active` yet still not serve if its `review_status` is not approved.

**Parameters:**
- `reason` (string, required)
- `ad_group_id` (string, conditionally required) — Obtain from `chatgpt_ads_list_ad_groups`
- `ad_ids` (array of string, conditionally required) — Resolve specific ads by ID
- `limit` (integer, optional)
- `cursor` (string, optional)
- `refresh` (boolean, optional)
- `status` (string, optional)
- `review_status` (string, optional) — Filter by review state
- `search` (string, optional)
- `connection_id` (string, optional)

---

### Reporting Tools

#### chatgpt_ads_get_insights
Delivery reporting: `impressions`, `clicks`, `spend`, `ctr`, `cpc`, `cpm`. **These six are the only metrics the API exposes** — there is no conversions metric here.

Returns raw JSON rather than markdown, so the rows can be parsed and re-aggregated.

**Parameters:**
- `reason` (string, required)
- `level` (string, optional) — Scope of the report
- `entity_id` (string, optional) — Restrict to one entity at that level
- `aggregation_level` (string, optional) — Row granularity (account / campaign / ad group / ad)
- `time_granularity` (string, optional) — Time bucketing; `none` returns one row per entity
- `date_since` (string, optional) — `YYYY-MM-DD`
- `date_until` (string, optional) — `YYYY-MM-DD`; **cannot be in the future** (account timezone)
- `fields` (array of string, optional) — Explicit metric projection
- `filters` (optional) — Row filters
- `sort` (optional) — e.g. spend descending
- `segment` (string, optional) — `product`, `country` or `device` breakdown. The innermost grouping's metrics are **unprefixed**: on a segmented request `spend` is the per-segment value and `campaign_spend` the enclosing entity's total. Cannot be combined with conversions
- `include_zero_impressions` (boolean, optional)
- `include_conversions` (boolean, optional) — Add a separate `conversions` block (see below)
- `attribution_time_basis` (string, optional) — `ad_event_time` (default: counted on the click/impression day) or `conversion_time` (counted on the day the conversion happened). Under `conversion_time` only the goal event is reliably reported; `order_created` and other non-goal events can be missing
- `attribution_window_days` (integer, optional) — Click-through window: `7`, `14` or `30` (default 30)
- `view_through_attribution_window_days` (integer, optional) — View-through window: `0` (exclude view-through) or `1` (default)
- `event_names` (array of string, optional) — Narrow the per-event breakdown, e.g. `["order_created"]`. Any of these four implies `include_conversions`
- `limit` (integer, optional)
- `cursor` (string, optional)
- `connection_id` (string, optional)

**Defaults worth knowing:**
- The default window is the **last 30 complete days ending yesterday**, in the account's timezone.
- Money: `spend`, `cpc`, `cpm` are **decimals in the account currency** — unlike campaign budgets, which are micros.

**The `conversions` block** (a sibling of `data`, not merged into delivery rows):
- `conversions.data` — one row per entity per **day** (`date`) for a daily report, per **month** (`month`) for monthly, or for the whole window when `time_granularity` is `none` or `hourly` (hourly warns). Each row: `conversions` (the goal event — the conversion event setting the account optimizes for), `click_through_conversions`, `view_through_conversions`, `order_created_attributed_sales` (a **decimal string** in the account currency), and `attributed_events[]`.
- `attributed_events[]` — per `event_name`: `attributed_event_count`, `attributed_event_value_amount`, `attributed_event_value_count`, click/view split, and `conversion_event_setting_breakdowns` on the goal event. The **order count is the `order_created` entry's `attributed_event_count`** — not `conversions`, which counts the goal event and can differ.
- `conversions.attribution` — the settings actually applied (`attribution_time_basis`, `attribution_window_days`, `view_through_attribution_window_days`); `conversions.currency`; `conversions.time_granularity`.
- Conversions come on the **first page only**; later pages carry a `conversions_on_first_page` warning. They cover every entity in scope, so they can include entities (and days) with no delivery row — join on entity + date rather than assuming one per delivery row.
- A `conversion_events_missing` warning means a requested event came back in no row — absence, not a confirmed zero.

#### chatgpt_ads_list_conversion_event_settings
List the conversion events configured for the account — what each counts, its attribution window, and which campaigns use it. Use it to interpret the goal-event `conversions` count from `include_conversions`.

A 404 here usually means conversion tracking is **not enabled** for the account, not that the request was malformed.

**Parameters:**
- `reason` (string, required)
- `limit` (integer, optional)
- `cursor` (string, optional)
- `connection_id` (string, optional)

#### chatgpt_ads_list_custom_audiences
List custom audiences — name, status, and how many identifiers matched.

Primary use is resolving identity: campaigns return `targeting.custom_audiences.ids` as bare IDs. Sizes are **bucketed range strings** (e.g. `"5000-10000"`), never exact counts.

**Parameters:**
- `reason` (string, required)
- `custom_audience_ids` (array of string, optional) — Resolve specific audiences by ID
- `limit` (integer, optional)
- `cursor` (string, optional)
- `connection_id` (string, optional)

---

### Connection Management Tools

Tools accept an optional `connection_id`. `chatgpt_ads_list_connections` lists them; call `chatgpt_ads_set_default_connection` only when the user asks.

### Feedback Tool

#### chatgpt_ads_developer_feedback
Submit feedback about missing tools, improvements, bugs, or workflow gaps in the ChatGPT Ads MCP toolset. Not for user-facing issues such as auth or API errors.

**Parameters:**
- `feedback_type` (string, required) — `new_tool`, `improvement`, `bug`, or `workflow_gap`
- `title` (string, required)
- `description` (string, required)
- `reason` (string, required)
- `current_workaround` (string, optional)
- `priority` (string, optional)
- `interface` (string, optional) — Use `"skill"` when the gap is in this skill rather than the MCP

---

## Pagination

List tools use opaque cursors. Pass `limit` and `cursor`; read `nextCursor` from the response and pass it back to get the next page. Cursors are not constructible — never build one by hand. When `nextCursor` is absent, there are no more pages.
