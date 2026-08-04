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
- `segment` (string, optional) — Segment breakdown; segment metrics come back **prefixed** (e.g. `product_spend`) while the row entity's own metrics are unprefixed (`spend`)
- `include_zero_impressions` (boolean, optional)
- `include_conversions` (boolean, optional) — Merge conversion totals for the whole window (no time bucketing)
- `limit` (integer, optional)
- `cursor` (string, optional)
- `connection_id` (string, optional)

**Defaults worth knowing:**
- The default window is the **last 30 complete days ending yesterday**, in the account's timezone.
- Money: `spend`, `cpc`, `cpm` are **decimals in the account currency** — unlike campaign budgets, which are micros.

#### chatgpt_ads_list_conversion_event_settings
List the conversion events configured for the account — what each counts, its attribution window, and which campaigns use it. Use it to interpret the totals from `include_conversions`.

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

These write to Hopkin's own records, never to the ChatGPT Ads platform.

#### chatgpt_ads_list_connections
List the connections available to you — both owned and shared with you by your organization. Shows display name, id, and which is your default.

**Parameters:**
- `reason` (string, required)

#### chatgpt_ads_set_default_connection
Set which connection other tools use when `connection_id` is omitted.

**Parameters:**
- `connection_id` (string, required) — From `chatgpt_ads_list_connections`; do not guess
- `reason` (string, required)

#### chatgpt_ads_rename_connection
Change a connection's display name. Owner-only.

**Parameters:**
- `connection_id` (string, required)
- `reason` (string, required)

#### chatgpt_ads_share_connection
Share an owned connection with your organization so teammates can report on that ad account. Owner-only.

> The ChatGPT Ads API has **no reduced-scope keys**, so sharing grants full read access to the whole ad account. Confirm the user understands this before sharing.

**Parameters:**
- `connection_id` (string, required)
- `reason` (string, required)

#### chatgpt_ads_unshare_connection
Stop sharing an owned connection with your organization. Owner-only.

**Parameters:**
- `connection_id` (string, required)
- `reason` (string, required)

#### chatgpt_ads_revoke_connection
Remove a stored connection. Owner-only.

> This deletes **Hopkin's stored copy of the API key only**. The key remains valid on the ChatGPT Ads platform — the API has no revocation endpoint — so to fully revoke it the user must also delete it in ChatGPT Ads Manager → Settings. Always say this when revoking.

**Parameters:**
- `connection_id` (string, required)
- `reason` (string, required)

---

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
