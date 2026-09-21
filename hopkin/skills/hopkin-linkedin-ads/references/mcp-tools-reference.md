# LinkedIn Ads MCP Server Tools Reference — Hopkin

This document provides detailed reference information for the Hopkin LinkedIn Ads MCP tools and their usage patterns.

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

### Hopkin LinkedIn Ads MCP

- **Service:** Hopkin — hosted MCP service
- **Sign up:** https://app.hopkin.ai
- **Type:** Hosted MCP (URL + auth token, no local installation)

### Required Configuration

Configure the Hopkin LinkedIn Ads MCP as a hosted MCP service in your Claude settings:

```json
{
  "mcpServers": {
    "hopkin-linkedin-ads": {
      "type": "url",
      "url": "https://linkedin.mcp.hopkin.ai/mcp",
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

Hopkin uses OAuth. If a tool call fails with an auth error, call `linkedin_ads_check_auth_status` to check. If not authenticated, direct the user to https://app.hopkin.ai to connect their LinkedIn Ads account. LinkedIn tokens expire after **60 days** — reconnect if auth errors appear.

---

## Core Tools

> **Important:** Every Hopkin tool call requires a `reason` (string) parameter for audit trail.

> **Connections:** every account, reporting and auth tool below also accepts an optional `connection_id` (UUID) to use a specific LinkedIn connection instead of your default — see [Connection Tools](#connection-tools). The ad-library and competitor tools take no `connection_id`: they need no LinkedIn connection at all.

> **IDs are strings:** `account_id` and every campaign / campaign group / creative ID are numeric IDs passed as **strings** (e.g. `"123456789"`), without URN prefixes.

### Authentication Tools

#### linkedin_ads_check_auth_status
Troubleshoot authentication issues and get LinkedIn user profile info. Performs live validation against LinkedIn to confirm the provider token is still active.

**Parameters:**
- `reason` (string, required) — Reason for the call

**Returns:**
- `authenticated` (boolean)
- `email` (string)
- `expires_at` (timestamp) — LinkedIn provider token expiry (60-day TTL)
- `auth_method` (string) — `jwt` or `api_key`
- `linkedin_member_id` (string) — Opaque LinkedIn member ID
- `linkedin_name` (string) — LinkedIn display name
- `linkedin_scopes` (array) — Scopes granted on provider token
- `message` (string) — Human-readable status message

> Only call this when another tool returns a permission or authentication error — do not call proactively on every request.

#### linkedin_ads_ping
Health check. Verify the MCP server is reachable and returns version/timestamp.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `message` (string, optional) — Optional echo message

---

### Account Tools

#### linkedin_ads_list_ad_accounts
List LinkedIn Sponsored Ad Accounts accessible to the authenticated user. LinkedIn has **no manager/MCC account hierarchy** — all accounts are accessible directly.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `status` (array of strings, optional) — Filter by account status (default: `["ACTIVE"]`). Options: `ACTIVE`, `DRAFT`, `CANCELED`, `PENDING_DELETION`, `REMOVED`
- `type` (string, optional) — Filter by account type. Options: `BUSINESS`, `ENTERPRISE`
- `include_test_accounts` (boolean, optional) — Include test/sandbox accounts (default: false)
- `limit` (number, optional) — Max accounts to return (default: 20, max: 100)
- `cursor` (string, optional) — Opaque pagination cursor from previous response
- `refresh` (boolean, optional) — Force fresh fetch from LinkedIn API (bypasses the cache)

**Example:**
```json
{
  "tool": "linkedin_ads_list_ad_accounts",
  "parameters": {
    "reason": "Finding the user's LinkedIn Ads accounts"
  }
}
```

---

### Campaign Group Tools

#### linkedin_ads_list_campaign_groups
List LinkedIn Campaign Groups — the top-level organizational unit, analogous to Campaigns in Meta and Google. Campaign groups hold the budget and campaign objective.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Ad account ID (numeric, no URN)
- `status` (array of strings, optional) — Filter by status (default: `["ACTIVE", "PAUSED"]`). Options: `ACTIVE`, `PAUSED`, `DRAFT`, `ARCHIVED`, `CANCELED`, `PENDING_DELETION`, `REMOVED`
- `campaign_group_id` (string, optional) — Fetch a single campaign group by ID
- `campaign_group_ids` (array of strings, optional) — Fetch specific campaign groups by IDs (max 50)
- `limit` (number, optional) — Max results (default: 20, max: 100)
- `cursor` (string, optional) — Opaque pagination cursor
- `refresh` (boolean, optional) — Force fresh fetch from LinkedIn API

**Example:**
```json
{
  "tool": "linkedin_ads_list_campaign_groups",
  "parameters": {
    "reason": "Listing active campaign groups for performance analysis",
    "account_id": "123456789",
    "status": ["ACTIVE"]
  }
}
```

---

### Campaign Tools

#### linkedin_ads_list_campaigns
List LinkedIn Campaigns — define targeting, bidding, and scheduling. Analogous to Ad Sets in Meta, Ad Groups in Google.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Ad account ID
- `status` (array of strings, optional) — Filter by status (default: `["ACTIVE", "PAUSED"]`). Options: `ACTIVE`, `PAUSED`, `DRAFT`, `ARCHIVED`, `COMPLETED`, `CANCELED`, `PENDING_DELETION`, `REMOVED`
- `campaign_group_id` (string, optional) — Filter to a specific campaign group
- `type` (array of strings, optional) — Filter by campaign type. Options: `TEXT_AD`, `SPONSORED_UPDATES`, `SPONSORED_INMAILS`, `DYNAMIC`, `EVENT_AD`
- `campaign_id` (string, optional) — Fetch a single campaign by ID
- `campaign_ids` (array of strings, optional) — Fetch specific campaigns by IDs (max 50)
- `limit` (number, optional) — Max results (default: 20, max: 100)
- `cursor` (string, optional) — Opaque pagination cursor
- `refresh` (boolean, optional) — Force fresh fetch from LinkedIn API
- `include_targeting` (boolean, optional) — Return the full targeting criteria (include/exclude facets resolved to human-readable names), plus audience expansion, audience network, frequency cap, creative selection and conversion actions (default: false)
- `include_forecast` (boolean, optional) — Add an audience-size forecast (total and by channel) to each campaign. Requires `include_targeting: true` (default: false)

**Example:**
```json
{
  "tool": "linkedin_ads_list_campaigns",
  "parameters": {
    "reason": "Listing active campaigns for targeting analysis",
    "account_id": "123456789",
    "status": ["ACTIVE"]
  }
}
```

**Example — Filter by campaign group:**
```json
{
  "tool": "linkedin_ads_list_campaigns",
  "parameters": {
    "reason": "Listing campaigns under the Lead Gen campaign group",
    "account_id": "123456789",
    "campaign_group_id": "987654321"
  }
}
```

---

### Creative Tools

#### linkedin_ads_list_creatives
List LinkedIn Creatives — the ad content units containing headline, body text, image, and CTA. Analogous to Ads in Meta and Google. Ad copy (headline, body text, destination URL) is always resolved from the linked posts.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Ad account ID
- `campaign_ids` (array of strings, optional) — Filter to specific campaign IDs (max 20)
- `status` (array of strings, optional) — Filter by intended status (default: `["ACTIVE", "PAUSED", "DRAFT"]`). Options: `ACTIVE`, `PAUSED`, `DRAFT`, `ARCHIVED`, `CANCELED`, `PENDING_DELETION`, `REMOVED`
- `creative_id` (string, optional) — Fetch a single creative by URN or numeric ID
- `creative_ids` (array of strings, optional) — Fetch specific creatives by numeric IDs (max 50)
- `limit` (number, optional) — Max results (default: 20, max: 100)
- `cursor` (string, optional) — Opaque pagination cursor
- `refresh` (boolean, optional) — Force fresh fetch from LinkedIn API

**Example:**
```json
{
  "tool": "linkedin_ads_list_creatives",
  "parameters": {
    "reason": "Listing active creatives for a campaign to analyze ad copy",
    "account_id": "123456789",
    "campaign_ids": ["111222333"],
    "status": ["ACTIVE"]
  }
}
```

---

### Analytics Tools

#### linkedin_ads_get_performance_report
**Recommended analytics tool.** Get a full-funnel performance report with impressions, clicks, spend, conversions, leads, video views, CTR, CPC, CPA, ROAS, plus optional per-conversion-action breakdown.

Supports up to 3 pivots, e.g. ACCOUNT, CAMPAIGN_GROUP, CAMPAIGN or CREATIVE. **Does not support MEMBER_* demographic pivots** — use `linkedin_ads_get_insights` for those.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Ad account ID
- `pivots` (array of strings, optional) — Dimensions to pivot by (max 3, default: `["CAMPAIGN"]`). Options: `ACCOUNT`, `CAMPAIGN_GROUP`, `CAMPAIGN`, `CREATIVE`, `SHARE`, `COMPANY`, `CONVERSION`, `SERVING_LOCATION`, `PLACEMENT_NAME`, `IMPRESSION_DEVICE_TYPE`, `CARD_INDEX`, `OBJECTIVE_TYPE`
- `date_preset` (string, optional) — Relative date range (default: `LAST_30_DAYS`). Options: `LAST_7_DAYS`, `LAST_14_DAYS`, `LAST_30_DAYS`, `THIS_MONTH`, `LAST_MONTH`, `LAST_90_DAYS`
- `start_date` (string, optional) — Custom start date (YYYY-MM-DD); use with `end_date` to override `date_preset`
- `end_date` (string, optional) — Custom end date (YYYY-MM-DD)
- `time_granularity` (string, optional) — `ALL` for aggregate (default), `DAILY` or `MONTHLY` for time series
- `campaign_ids` (array of strings, optional) — Filter to specific campaign IDs (max 50)
- `campaign_group_ids` (array of strings, optional) — Filter to specific campaign group IDs (max 20)
- `include_conversion_breakdown` (boolean, optional) — Include per-conversion-action breakdown (makes a second API call, default: true)

**Returns:**
- Full funnel metrics: impressions, clicks, spend, conversions, leads, video views, CTR, CPC, CPA, ROAS
- `conversion_breakdown` — per-conversion-action metrics (on by default; pass `include_conversion_breakdown: false` to skip the extra call)

**Example — Campaign group overview:**
```json
{
  "tool": "linkedin_ads_get_performance_report",
  "parameters": {
    "reason": "Generating campaign group performance report for last 30 days",
    "account_id": "123456789",
    "pivots": ["CAMPAIGN_GROUP"],
    "date_preset": "LAST_30_DAYS"
  }
}
```

**Example — Campaign-level with conversion breakdown:**
```json
{
  "tool": "linkedin_ads_get_performance_report",
  "parameters": {
    "reason": "Analyzing campaign performance with conversion breakdown",
    "account_id": "123456789",
    "pivots": ["CAMPAIGN"],
    "date_preset": "LAST_30_DAYS",
    "include_conversion_breakdown": true
  }
}
```

**Example — Creative-level with custom date range:**
```json
{
  "tool": "linkedin_ads_get_performance_report",
  "parameters": {
    "reason": "Creative performance for January 2026",
    "account_id": "123456789",
    "pivots": ["CREATIVE"],
    "start_date": "2026-01-01",
    "end_date": "2026-01-31"
  }
}
```

**Example — Daily trend:**
```json
{
  "tool": "linkedin_ads_get_performance_report",
  "parameters": {
    "reason": "Daily spend trend for budget pacing",
    "account_id": "123456789",
    "pivots": ["ACCOUNT"],
    "date_preset": "LAST_30_DAYS",
    "time_granularity": "DAILY"
  }
}
```

---

#### linkedin_ads_get_account_summary
Get a high-level performance summary for a LinkedIn Ads account: spend, impressions, clicks, conversions, leads, and a conversion breakdown. Makes three parallel API calls: account details, aggregate analytics, and conversion breakdown. Conversion data may be delayed 24–72 hours.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Ad account ID
- `date_preset` (string, optional) — Relative date range (default: `LAST_30_DAYS`). Options: `LAST_7_DAYS`, `LAST_14_DAYS`, `LAST_30_DAYS`, `THIS_MONTH`, `LAST_MONTH`, `LAST_90_DAYS`
- `start_date` (string, optional) — Custom start date (YYYY-MM-DD, overrides `date_preset`)
- `end_date` (string, optional) — Custom end date (YYYY-MM-DD)

**Example:**
```json
{
  "tool": "linkedin_ads_get_account_summary",
  "parameters": {
    "reason": "Getting account-level summary to start a performance review session",
    "account_id": "123456789",
    "date_preset": "LAST_30_DAYS"
  }
}
```

---

#### linkedin_ads_get_insights
Flexible analytics with a single pivot dimension. Supports LinkedIn's unique MEMBER_* demographic pivots for professional audience analysis. Use it only when `linkedin_ads_get_performance_report` cannot answer the question — a MEMBER_* pivot or a custom metric. MEMBER_* pivots have a 3-event minimum threshold and a 12–24 hour data delay, so their totals may not match account-level numbers.

**Parameters:**
- `reason` (string, required) — Say why this tool is needed instead of `linkedin_ads_get_performance_report` (e.g. the MEMBER_* pivot or custom metric)
- `account_id` (string, required) — Ad account ID
- `pivot` (string, required) — Dimension to pivot by. Standard pivots: `ACCOUNT`, `CAMPAIGN_GROUP`, `CAMPAIGN`, `CREATIVE`, `SHARE`, `COMPANY`, `CONVERSION`, `CONVERSATION_NODE`, `SERVING_LOCATION`, `PLACEMENT_NAME`, `IMPRESSION_DEVICE_TYPE`, `CARD_INDEX`. LinkedIn-unique demographic pivots: `MEMBER_COMPANY_SIZE`, `MEMBER_INDUSTRY`, `MEMBER_SENIORITY`, `MEMBER_JOB_TITLE`, `MEMBER_JOB_FUNCTION`, `MEMBER_COUNTRY_V2`, `MEMBER_REGION_V2`, `MEMBER_COUNTY`, `MEMBER_COMPANY`
- `date_preset` (string, optional) — Relative date range (default: `LAST_30_DAYS`). Options: `LAST_7_DAYS`, `LAST_14_DAYS`, `LAST_30_DAYS`, `THIS_MONTH`, `LAST_MONTH`, `LAST_90_DAYS`
- `start_date` (string, optional) — Start date (YYYY-MM-DD); use with `end_date` to override `date_preset`
- `end_date` (string, optional) — End date (YYYY-MM-DD)
- `time_granularity` (string, optional) — `ALL` (aggregate, default), `DAILY` or `MONTHLY` (time series)
- `campaign_ids` (array of strings, optional) — Filter to specific campaign IDs (max 50)
- `campaign_group_ids` (array of strings, optional) — Filter to specific campaign group IDs (max 20)
- `metrics` (array of strings, optional) — LinkedIn metric field names, **exact camelCase** (max 18). Default: `impressions`, `clicks`, `costInLocalCurrency`, `costInUsd`, `externalWebsiteConversions`, `oneClickLeads`, `videoViews`, `totalEngagements`. Others include `externalWebsitePostClickConversions`, `externalWebsitePostViewConversions`, `conversionValueInLocalCurrency`, `oneClickLeadFormOpens`, `qualifiedLeads`, `videoCompletions`, `shares`, `follows`, `reactions`, `comments`, `landingPageClicks`, `textUrlClicks`, `companyPageClicks`, `cardImpressions`, `cardClicks`, `viralCardImpressions`, `viralCardClicks`, and `approximateMemberReach` (ACCOUNT / CAMPAIGN_GROUP / CAMPAIGN pivot, ranges up to 92 days). Do **not** use aliases such as `spend`, `conversions`, `leads` or `reach`
- `include_conversion_breakdown` (boolean, optional) — When true (and the pivot is not `CONVERSION`), runs a second query that breaks conversions down per named action (default: false)

**Example — Job function demographic breakdown:**
```json
{
  "tool": "linkedin_ads_get_insights",
  "parameters": {
    "reason": "Analyzing performance by job function to identify high-value B2B segments",
    "account_id": "123456789",
    "pivot": "MEMBER_JOB_FUNCTION",
    "date_preset": "LAST_30_DAYS"
  }
}
```

**Example — Seniority breakdown:**
```json
{
  "tool": "linkedin_ads_get_insights",
  "parameters": {
    "reason": "Identifying which seniority levels are converting best",
    "account_id": "123456789",
    "pivot": "MEMBER_SENIORITY",
    "date_preset": "LAST_30_DAYS"
  }
}
```

**Example — Industry breakdown:**
```json
{
  "tool": "linkedin_ads_get_insights",
  "parameters": {
    "reason": "Analyzing performance by industry to prioritize targeting",
    "account_id": "123456789",
    "pivot": "MEMBER_INDUSTRY",
    "date_preset": "LAST_30_DAYS"
  }
}
```

**Example — Daily trend:**
```json
{
  "tool": "linkedin_ads_get_insights",
  "parameters": {
    "reason": "Daily spend trend to monitor budget pacing",
    "account_id": "123456789",
    "pivot": "ACCOUNT",
    "date_preset": "LAST_30_DAYS",
    "time_granularity": "DAILY"
  }
}
```

---

### Budget & Pricing Tools

#### linkedin_ads_get_budget_pricing
Get bid ranges and daily budget limits for a LinkedIn campaign type and audience. This tool is **unique to LinkedIn** — it provides recommended bid ranges based on audience targeting parameters. Call this before campaign planning to understand recommended bids and budgets.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Ad account ID
- `campaign_type` (string, required) — Type of campaign. Options: `TEXT_AD`, `SPONSORED_UPDATES`, `SPONSORED_INMAILS` (`DYNAMIC` is not supported)
- `bid_type` (string, required) — Bid model. Options: `CPM`, `CPC`, `CPV`. Note: `SPONSORED_INMAILS` only supports `CPM`; `CPV` is only valid for `SPONSORED_UPDATES` video campaigns; `TEXT_AD` supports `CPM` and `CPC`
- `match_type` (string, required) — Audience match. Options: `EXACT`, `AUDIENCE_EXPANDED`
- `currency` (string, required) — 3-letter ISO currency code (e.g., `USD`, `EUR`, `GBP`)
- `location_urns` (array of strings, required) — Array of LinkedIn geo URNs (e.g., `urn:li:geo:103644278` for US)
- `seniority_urns` (array of strings, optional) — Filter by member seniority level URNs
- `job_function_urns` (array of strings, optional) — Filter by job function URNs
- `industry_urns` (array of strings, optional) — Filter by industry URNs
- `company_size_urns` (array of strings, optional) — Filter by company size URNs
- `objective_type` (string, optional) — Campaign objective type
- `daily_budget_amount` (number, optional) — Intended daily budget (affects suggestions)

**Example:**
```json
{
  "tool": "linkedin_ads_get_budget_pricing",
  "parameters": {
    "reason": "Getting recommended bid ranges before setting up a new Sponsored Content campaign",
    "account_id": "123456789",
    "campaign_type": "SPONSORED_UPDATES",
    "bid_type": "CPC",
    "match_type": "EXACT",
    "currency": "USD",
    "location_urns": ["urn:li:geo:103644278"]
  }
}
```

---

### Partner Conversion Tools

#### linkedin_ads_get_partner_conversions
List partner conversions configured for a LinkedIn Ads account. LinkedIn uses "partner conversions" terminology for what other platforms call "conversion actions". Call this before analyzing conversion metrics or ROAS to understand which actions are being tracked.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, required) — Ad account ID

**Example:**
```json
{
  "tool": "linkedin_ads_get_partner_conversions",
  "parameters": {
    "reason": "Understanding which conversion actions are active before analyzing ROAS",
    "account_id": "123456789"
  }
}
```

---

### Visualization Tools

#### `linkedin_ads_render_chart`

**MCP App.** Renders interactive data visualization charts from advertising data.

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `reason` | string | Yes | Why you're rendering this chart |
| `chart` | object | Yes | Chart configuration — must include `type` and type-specific fields |

**Chart Types:**

**bar** — Compare values across categories (campaign groups, demographics, industries).
```json
{
  "type": "bar",
  "data": [
    {"label": "Q1 Lead Gen", "values": {"spend": 4521, "leads": 89}},
    {"label": "Brand Awareness", "values": {"spend": 2100, "leads": 12}},
    {"label": "Webinar Promo", "values": {"spend": 1800, "leads": 45}}
  ],
  "metric": {"field": "spend", "label": "Spend ($)"},
  "colorBy": {"field": "leads", "label": "Leads"}
}
```
Optional: `sort`, `orientation`, `table`, `referenceLines`.

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

**funnel** — Conversion stages from impressions to leads.
```json
{
  "type": "funnel",
  "data": {
    "stages": ["Impressions", "Clicks", "Lead Gen Opens", "Leads"],
    "volume": [500000, 15000, 4200, 890],
    "costPer": [0.01, 0.33, 1.19, 5.62]
  }
}
```

**scatter** — Correlate two metrics across entities.
```json
{
  "type": "scatter",
  "data": [
    {"label": "Q1 Lead Gen", "values": {"spend": 4521, "cpa": 50.80}},
    {"label": "Brand Awareness", "values": {"spend": 2100, "cpa": 175}},
    {"label": "Webinar Promo", "values": {"spend": 1800, "cpa": 40}}
  ],
  "x": {"field": "spend", "label": "Spend ($)"},
  "y": {"field": "cpa", "label": "CPA ($)"}
}
```
Optional: `color`, `size`, `referenceLines`, `table`.

**waterfall** — Cumulative contribution with color encoding.
```json
{
  "type": "waterfall",
  "data": [
    {"label": "Q1 Lead Gen", "value": 4521, "colorValue": 50.80},
    {"label": "Brand Awareness", "value": 2100, "colorValue": 175},
    {"label": "Webinar Promo", "value": 1800, "colorValue": 40}
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

### Connection Tools

A connection is one LinkedIn sign-in that Hopkin uses to read ad accounts. A user can have several: their own, and ones teammates share with the organization. Account and reporting tools use the **default** connection unless you pass `connection_id`.

Only call the write tools below when the user asks. Confirm the destructive ones (`unshare`, `revoke`) with the user first.

#### linkedin_ads_list_connections
List the LinkedIn connections available to you — ones you own and ones shared with you through your organization. Use it to find connection IDs for `connection_id` and for the tools below.

**Parameters:**
- `reason` (string, required) — Reason for the call

**Returns:** `data[]` (per connection: `id`, `display_name`, `external_account_label`, `is_default`, `access_via` — `owned` or `shared`, `shared_with_org`, `revoked_at`) and `count`.

#### linkedin_ads_set_default_connection
Set the connection used by default for subsequent LinkedIn Ads tool calls. The default is scoped to the caller (your user account, or the API key in use).

**Parameters:**
- `reason` (string, required) — Reason for the call
- `connection_id` (string, required) — UUID of the connection to make the default

#### linkedin_ads_share_connection
Share a connection you own with all members of your organization, so teammates can use it without connecting LinkedIn themselves. Owner only.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `connection_id` (string, required) — UUID of the connection to share

#### linkedin_ads_unshare_connection
Stop sharing a connection you own with your organization. Teammates lose access immediately. Owner only. **Destructive — confirm with the user first.**

**Parameters:**
- `reason` (string, required) — Reason for the call
- `connection_id` (string, required) — UUID of the connection to stop sharing

#### linkedin_ads_rename_connection
Rename a connection you own. Only the display label changes; the underlying LinkedIn access is unaffected. Owner only.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `connection_id` (string, required) — UUID of the connection to rename
- `display_name` (string, required) — New name (1–120 characters)

#### linkedin_ads_revoke_connection
Revoke a connection you own. Defaults pointing to it stop working and teammates it was shared with lose access. It does **not** revoke Hopkin's access at LinkedIn itself — for that, the user disconnects in the Hopkin dashboard. Owner only. **Destructive — confirm with the user first.**

**Parameters:**
- `reason` (string, required) — Reason for the call
- `connection_id` (string, required) — UUID of the connection to revoke

---

### Ad Library & Competitor Tools

These six tools read Hopkin's collected copy of the public **LinkedIn Ad Library** and return real creative — copy, CTAs, landing URLs, media — not just library links. **They need no LinkedIn connection and no ad account** (and take no `connection_id`). See **references/workflows/competitor-research.md** for the full workflow.

Three things shape how they behave:

- **LinkedIn's Ad Library is searchable only by advertiser NAME** — the company's display name as shown on its LinkedIn page. It cannot be searched by organization ID. A name that has not been collected yet is looked up live (about 20–40 seconds), and only an **exact** name match is ever used.
- **Employee posts a company pays for** (posts from employees' personal profiles, promoted by the company) are included for the paying company and labelled `attribution: "payer"` with `posted_by` (`name`, `profile_url`). The company's own ads are `attribution: "advertiser"`.
- **Two IDs:** `advertiser_id` is Hopkin's ID for an advertiser (a UUID — use it with `list_competitor_ads` / `untrack_competitor`); `organization_id` / `platform_advertiser_id` is LinkedIn's numeric organization ID. A `platform_advertiser_id` starting with `name:` means no organization ID is known yet — use `name` for it.

**Ad fields** (listed and search results): `id` (the ad's ID for `get_competitor_ad`), `advertiser_id`, `library_ad_id`, `permalink`, `primary_text`, `headline`, `description`, `cta_text`, `cta_type`, `landing_url`, `display_format`, `languages`, `started_running_at` / `stopped_running_at` (LinkedIn's run dates, when known), `is_active` (null = unknown, not stopped), `copy_truncated` (true = the stored body is only the preview cut at LinkedIn's "see more" fold — say so), `first_seen_at` / `last_seen_at`, `raw_data`, and `attribution` / `posted_by`.

**Display formats** seen in the library: `sponsored_status_update` (single image), `sponsored_video`, `sponsored_update_linkedin_article`, `sponsored_message`, `sponsored_update_native_document` (document ads), `sponsored_update_event`. The vocabulary is LinkedIn's own and open-ended; `display_format` filters are case-insensitive.

#### linkedin_ads_search_ad_library
Search the LinkedIn Ad Library for any advertiser's ads. Served from the collected library; when it has nothing for a query, the public Ad Library is searched live on demand (a keyword search can take 60–90 seconds). No tracking needed.

**To see ONE company's ads, pass `advertiser_name`** — `search_terms` reads ad *copy*, which rarely names the advertiser, so a keyword search for a company name returns other companies' ads.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `countries` (array of strings, **required**) — ISO-3166-1 alpha-2 codes (e.g. `["US", "GB"]` — use `GB`, not `UK`) or `["ALL"]`. Scopes live searches; collected ads carry no per-ad reach countries, so a restrictive value is not applied to them (a warning says so)
- `advertiser_name` (string, optional) — One company's ads, by its name exactly as shown on its LinkedIn page. Looked up live if not yet collected. Includes employee posts it paid for (`attribution: "payer"`). Not together with `organization_ids`
- `search_terms` (string, optional) — Keywords over ad copy. Spaces act as AND. Use the language the ad is written in
- `search_type` (string, optional) — `KEYWORD_UNORDERED` (default) or `KEYWORD_EXACT_PHRASE`
- `organization_ids` (array of strings, optional) — Up to 10 numeric organization IDs of advertisers **already collected** (e.g. from `linkedin_ads_list_tracked_competitors`). An ID nobody has collected returns nothing, with a warning — use `advertiser_name` instead
- `ad_active_status` (string, optional) — `ACTIVE` (default), `ALL`, or `INACTIVE` (approximated as `ALL`, with a warning)
- `ad_delivery_date_min` / `ad_delivery_date_max` (string, optional) — Delivery date bounds (YYYY-MM-DD). LinkedIn shows run dates only on detail pages, so ads without a known start date are excluded by these bounds
- `display_format` (string, optional) — Creative type filter (see Display formats above)
- `languages` (array of strings, optional) — Language **names** as LinkedIn shows them, e.g. `["English"]`
- `limit` (number, optional) — Results per page (default: 25, max: 50)
- `cursor` (string, optional) — Pagination cursor from the previous response

At least one of `advertiser_name`, `search_terms` or `organization_ids` is required.

**Returns** (JSON): `ads[]` (ad fields above, plus `media[]` and `media_status`), `source` (`corpus` = already collected, `live_scrape` = fetched just now), `pagination` (`hasMore`, `nextCursor`), and — when present — `warnings` (filters that could not be applied exactly) and `note` (why a result is empty, e.g. the query was checked recently). Relay `warnings` and `note` to the user. `primary_text` is clipped at 300 characters here; open the ad with `linkedin_ads_get_competitor_ad` for the full copy.

**Example — one company's current ads:**
```json
{
  "tool": "linkedin_ads_search_ad_library",
  "parameters": {
    "reason": "User asked what a competitor is running on LinkedIn right now",
    "advertiser_name": "Acme Analytics",
    "countries": ["ALL"]
  }
}
```

**Example — theme research across advertisers:**
```json
{
  "tool": "linkedin_ads_search_ad_library",
  "parameters": {
    "reason": "Finding B2B video ads that talk about sales automation",
    "search_terms": "sales automation",
    "countries": ["US"],
    "display_format": "sponsored_video"
  }
}
```

#### linkedin_ads_track_competitor
Register a LinkedIn advertiser for daily collection — its company-page ads plus the employee posts it pays for. Provide exactly one of `name`, `company_url` or `organization_id`.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `name` (string, optional, **recommended**) — The company name exactly as shown on its LinkedIn page. Not yet collected → looked up live (about 20–40 seconds) and tracked in the same call if exactly one advertiser has that name
- `company_url` (string, optional) — LinkedIn company page URL. A numeric one (`linkedin.com/company/1234567`) resolves like `organization_id`. A vanity slug (`linkedin.com/company/acmeanalytics`) is only a **guess** at the name and often misses — retry with `name` then
- `organization_id` (string, optional) — Numeric organization ID of an advertiser **already collected** (e.g. from a candidate list). A never-collected organization is refused, because the Ad Library cannot be searched by ID
- `countries` (array of strings, optional) — ISO codes to track this advertiser in, e.g. `["US", "GB", "DE"]` (`GB`, not `UK`), or `["ALL"]`. Omit for the default tracking countries. Re-tracking with a different set updates it

**Returns — one of:**
- **Tracked:** `advertiser` (`id` = the advertiser ID to use next, `name`, `platform_advertiser_id`, `last_scraped_at`), `tracked`, `countries` (null = default tracking countries), `seeded` (`ad_count` collected by a live lookup in this call, when one ran), `full_scrape` (`started` = a full background collection, employee posts included, lands within minutes; `not_needed` = already tracked with these countries; `failed` = could not start, the next daily collection covers it), and `warnings`
- **Candidates — nothing tracked:** `candidates[]` (`name`, `platform_advertiser_id`, `ad_count`, and `source: "ad_library"` for a similarly named advertiser found by the live lookup) and a `message`. Retry only with the one whose name is exactly right — `organization_id` for a numeric ID, otherwise `name` exactly as listed — or ask the user. Never track a differently named advertiser
- **Error — no ads from that name:** LinkedIn's Ad Library has no ads from an advertiser with that name (in those countries); nothing was tracked. Say so plainly; suggest checking the spelling or `countries: ["ALL"]`

The tracked-competitor limit on the user's plan is shared with Meta competitor tracking.

**Example:**
```json
{
  "tool": "linkedin_ads_track_competitor",
  "parameters": {
    "reason": "User asked to track a competitor in their three markets",
    "name": "Acme Analytics",
    "countries": ["US", "GB", "DE"]
  }
}
```

> A new track (or new countries) starts a full collection **in the background**. If the competitor shows few or no ads straight after tracking, the rest is still arriving — say so, and never report that the company has no ads.

#### linkedin_ads_list_tracked_competitors
List the advertisers you track.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `limit` (number, optional) — Per page (default: 20, max: 100)
- `cursor` (string, optional) — Pagination cursor

**Returns:** `data[]` — per row: `advertiser_id`, `advertiser` (`name`, `platform_advertiser_id`, `last_scraped_at`, `last_scrape_status`), `countries` (null = default tracking countries), `ad_count`, `payer_ad_count` (employee posts it paid for), `created_at` (tracked since), `stale` (no successful collection in 48 hours) and `scrape_warning` (present only when something needs attention) — plus `count` and `nextCursor`. Treat stale or warned rows' data as possibly out of date.

#### linkedin_ads_list_competitor_ads
List one advertiser's ads with the full copy — its own ads plus the employee posts it paid for, each labelled by `attribution`.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `advertiser_id` (string, required) — The advertiser ID from `linkedin_ads_list_tracked_competitors` or `linkedin_ads_track_competitor` (not the organization ID)
- `active_only` (boolean, optional) — Only ads still running
- `display_format` (string, optional) — Creative type filter
- `since` (string, optional) — Only ads seen on or after this ISO date/timestamp
- `search` (string, optional) — Case-insensitive search over this advertiser's ad copy
- `limit` (number, optional) — Per page (default: 20, max: 100)
- `cursor` (string, optional) — Pagination cursor

**Returns:** `data[]` (ad fields above), `count`, `synced_at` (most recent observation), `nextCursor`.

**Example:**
```json
{
  "tool": "linkedin_ads_list_competitor_ads",
  "parameters": {
    "reason": "Reviewing a tracked competitor's active ads",
    "advertiser_id": "<advertiser_id>",
    "active_only": true
  }
}
```

#### linkedin_ads_get_competitor_ad
Open one ad in full and **see** the creative: complete copy (headline, primary text, description, CTA), landing URL, run and seen dates, and every media asset. Mirrored images and video thumbnails come back inline as image content.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `ad_id` (string, required) — The ad's `id` from `linkedin_ads_list_competitor_ads` (or a search result)
- `include_frames` (boolean, optional) — Also return extracted video frames as images (capped at about 40) — use it to describe what a video actually shows (default: false)
- `stride` (number, optional) — Return every Nth frame
- `start` / `end` (number, optional) — Only frames within this window, in seconds

**Returns:** the ad fields above plus `media[]` — per asset `media_type` (`image`, `video`, `thumbnail`), `status`, dimensions, `duration_ms`, `source_url`, a short-lived `signed_url`, a `note` when it is not yet processed, and for videos a `derivative` with `frame_count`, `frame_fps` (duration ≈ `frame_count / frame_fps`), per-frame URLs, `transcript`, `audio_analysis` and a `status` (a silent track is reported as silent, not as missing speech). Where LinkedIn published EU transparency data for the ad, `raw_data.detail` carries `payer` (the "Paid for by" entity), `total_impressions` (a range), `impressions_by_country` (`country`, `percentage`), `targeting` and `ran_from` / `ran_until`.

#### linkedin_ads_untrack_competitor
Stop tracking an advertiser. Removes only your tracking; ads already collected stay available. Untracking something that was not tracked returns `removed: false`.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `advertiser_id` (string, required) — The advertiser ID from `linkedin_ads_list_tracked_competitors`

**Returns:** `advertiser_id`, `removed`.

---

### Feedback Tools

#### linkedin_ads_developer_feedback
Submit feedback or feature requests to the Hopkin development team. Use this tool in two situations:

1. **Write operations requested** — When a user requests a create, update, pause, or delete operation that isn't available
2. **Proactive efficiency feedback** — When you complete a task and believe there should have been a faster or more efficient way to get the answer

**Parameters:**
- `reason` (string, required) — Reason for the call
- `feedback_type` (string, required) — Type of feedback: `"new_tool"`, `"improvement"`, `"bug"`, `"workflow_gap"`
- `title` (string, required) — Concise title (5–200 characters)
- `description` (string, required) — Detailed description of what is needed and why (20–2000 characters)
- `current_workaround` (string, optional) — How you are currently working around this limitation (max 1000 characters)
- `priority` (string, optional) — Priority level: `"low"`, `"medium"` (default), `"high"`
- `interface` (string, optional) — Where the feedback originated: `"MCP"` (default) or `"CLI"`

**Example — Write Operation:**
```json
{
  "tool": "linkedin_ads_developer_feedback",
  "parameters": {
    "reason": "User requested campaign budget update which is not yet supported",
    "feedback_type": "workflow_gap",
    "title": "Update campaign group budget",
    "description": "User wanted to increase daily budget from $500 to $750 for campaign group 'Q1 Lead Gen'. Write operations are not yet available via Hopkin.",
    "current_workaround": "Directed user to LinkedIn Campaign Manager to update budget manually",
    "priority": "high"
  }
}
```

**Example — Efficiency Feedback:**
```json
{
  "tool": "linkedin_ads_developer_feedback",
  "parameters": {
    "reason": "Submitting efficiency feedback after completing user's request",
    "feedback_type": "new_tool",
    "title": "Combined campaign hierarchy with performance in one call",
    "description": "User asked for a full account overview showing campaign groups, campaigns, and creatives with performance data. I had to call list_campaign_groups, list_campaigns, list_creatives, and get_performance_report separately, then manually join results. A single hierarchical overview tool would be significantly faster.",
    "current_workaround": "Called four separate tools and merged results manually",
    "priority": "medium"
  }
}
```

---

## Tool Usage Patterns

### Pattern 1: Session Start — Account Selection
**Workflow:**
1. If the user named no account, call `linkedin_ads_list_ad_accounts` and present a numbered list if multiple accounts are found
2. If the account the user expects is missing, call `linkedin_ads_list_connections` — it may be under another connection; pass that connection's `connection_id`, or set it as the default with `linkedin_ads_set_default_connection` if the user asks
3. Competitor research needs no account at all — skip this pattern for it

### Pattern 2: Account Overview & Performance Report
**Workflow:**
1. Use `linkedin_ads_get_account_summary` for a quick high-level overview
2. Use `linkedin_ads_get_performance_report` with `pivots: ["CAMPAIGN_GROUP"]` for campaign group breakdown
3. Present report with summary statistics and insights

### Pattern 3: Demographic Audience Analysis (LinkedIn-Unique)
**Workflow:**
1. Use `linkedin_ads_get_insights` with `pivot: "MEMBER_JOB_FUNCTION"` for job function performance
2. Use `linkedin_ads_get_insights` with `pivot: "MEMBER_SENIORITY"` for seniority-level breakdown
3. Use `linkedin_ads_get_insights` with `pivot: "MEMBER_INDUSTRY"` for industry vertical analysis
4. Calculate segment performance indices (segment ROAS / overall ROAS)
5. Identify high-value B2B segments and provide targeting recommendations

### Pattern 4: Creative Performance Analysis
**Workflow:**
1. Use `linkedin_ads_list_creatives` to get creative content (ad copy is always resolved)
2. Use `linkedin_ads_get_performance_report` with `pivots: ["CREATIVE"]` for creative metrics
3. Join creative content with performance data by creative ID
4. Identify top performers and underperformers

### Pattern 5: Budget & Spend Analysis
**Workflow:**
1. Use `linkedin_ads_list_campaign_groups` for budget configuration data
2. Use `linkedin_ads_get_insights` with `pivot: "ACCOUNT"` and `time_granularity: "DAILY"` for daily spend trends
3. Calculate pacing metrics (actual vs. ideal spend pace)
4. Optionally use `linkedin_ads_get_budget_pricing` for bid range benchmarks

### Pattern 6: Conversion Analysis
**Workflow:**
1. Call `linkedin_ads_get_partner_conversions` to understand which conversions are tracked
2. Use `linkedin_ads_get_performance_report` with `include_conversion_breakdown: true` for per-action breakdown
3. Interpret ROAS in context of active partner conversions

### Pattern 7: Write Operation Requested (Developer Feedback)
**Workflow:**
1. Inform the user that write operations are not yet available via Hopkin
2. Call `linkedin_ads_developer_feedback` with `feedback_type: "workflow_gap"`
3. Provide guidance on how to perform the action manually via LinkedIn Campaign Manager

### Pattern 8: Proactive Efficiency Feedback
**When:** After completing any task where a faster path should have existed.

**Workflow:**
1. Complete the user's request as normal
2. Call `linkedin_ads_developer_feedback` with `feedback_type: "new_tool"` or `"improvement"` describing what would have been faster
3. Do NOT block the user's request — submit feedback after delivering the answer

### Pattern 9: Data Visualization

1. Fetch data with analytics tools (performance report, insights, etc.)
2. Transform data into chart format (array of `{label, values}` objects)
3. Call `linkedin_ads_render_chart` with the appropriate chart type
4. Present chart alongside summary table and written insights

### Pattern 10: "What is Company X running on LinkedIn?" (no tracking)
**Workflow:**
1. Call `linkedin_ads_search_ad_library` with `advertiser_name` (the company's name exactly as on its LinkedIn page) and the required `countries` (e.g. `["ALL"]`)
2. Report real copy, CTAs, landing URLs and formats; relay any `warnings` / `note`
3. For an ad's full copy or media, call `linkedin_ads_get_competitor_ad` with its `id`

### Pattern 11: Track a Competitor
**Workflow:**
1. Call `linkedin_ads_track_competitor` with `name` (and `countries` in one call if the user named markets)
2. Tracked → report the countries; if `full_scrape` is `"started"`, say the full inventory is still arriving
3. Candidates → nothing was tracked; retry with the exact-name candidate or ask the user
4. "No ads from that name" → say so; a vanity-slug URL that missed → retry with the real name
5. Browse with `linkedin_ads_list_competitor_ads` using the returned advertiser ID

### Pattern 12: Deep-Dive a Tracked Competitor
**Workflow:**
1. `linkedin_ads_list_tracked_competitors` → pick the advertiser, note `stale` / `scrape_warning`
2. `linkedin_ads_list_competitor_ads` with its `advertiser_id` (paginate fully for format breakdowns); separate `attribution: "payer"` employee posts
3. `linkedin_ads_get_competitor_ad` on the ads that matter — `include_frames: true` to describe video visuals; `raw_data.detail` for EU transparency data

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
  "content": "Found 5 campaign groups for account 123456789...",
  "structuredContent": {
    "data": [
      {
        "campaign_group_id": "987654321",
        "name": "Q1 Lead Gen",
        "status": "ACTIVE",
        "impressions": 45230,
        "clicks": 1234,
        "spend": "567.89",
        "conversions": 45,
        "roas": "4.13"
      }
    ]
  }
}
```

---

## Pagination

Hopkin list tools use cursor-based pagination:

- **`limit`** (1–100) — Number of results per page (default 20; `linkedin_ads_search_ad_library` defaults to 25, max 50)
- **`cursor`** — Opaque cursor string returned in the response to fetch the next page. List tools return it as a top-level `nextCursor` (absent on the last page); `linkedin_ads_search_ad_library` returns it as `pagination.nextCursor` with `pagination.hasMore`

**Example — Paginating through campaigns:**
```json
// First page
{
  "tool": "linkedin_ads_list_campaigns",
  "parameters": {
    "reason": "Listing campaigns page 1",
    "account_id": "123456789",
    "limit": 50
  }
}

// Next page (using cursor from previous response)
{
  "tool": "linkedin_ads_list_campaigns",
  "parameters": {
    "reason": "Listing campaigns page 2",
    "account_id": "123456789",
    "limit": 50,
    "cursor": "cursor_from_previous_response"
  }
}
```

---

## Error Handling

### Common Error Types

- **Authentication errors** — User not authenticated or LinkedIn token expired (60-day TTL). Call `linkedin_ads_check_auth_status` to confirm, then direct the user to https://app.hopkin.ai to reconnect.
- **Invalid account ID** — Ensure account ID is a numeric value (no URN prefix)
- **Invalid pivot** — MEMBER_* demographic pivots are only supported by `linkedin_ads_get_insights`, not `linkedin_ads_get_performance_report`
- **Rate limiting** — Wait and retry with exponential backoff
- **Account not found** — Verify account ID and user access
- **Competitor "no ads from that name"** — LinkedIn's Ad Library has no ads under that exact name; nothing was tracked. Check the spelling on the company page, or try `countries: ["ALL"]`
- **Competitor organization ID refused** — The advertiser has never been collected and the Ad Library cannot be searched by ID; retry with `name`
- **Tracked-competitor limit reached** — The plan's limit (shared with Meta) is used up; offer to untrack a competitor
- **Invalid country code** — Use ISO-3166-1 alpha-2 codes (`GB`, not `UK`); the error suggests the right code

### Error Handling Best Practices

1. **Always check auth first** — If tools return auth errors, run `linkedin_ads_check_auth_status` and direct the user to https://app.hopkin.ai to re-authenticate (never for competitor tools — they need no LinkedIn connection)
2. **Validate account ID format** — Numeric, passed as a string (`"123456789"`, not `urn:li:sponsoredAccount:123456789`)
3. **Use the right analytics tool** — `get_performance_report` for standard funnel metrics; `get_insights` for MEMBER_* demographic pivots
4. **Handle pagination** — Don't assume all results are in the first page
5. **Provide clear messages** — Translate errors into user-friendly guidance

---

**Document Version:** 1.1
**Last Updated:** 2026-09-21
**Service:** Hopkin LinkedIn Ads MCP (https://app.hopkin.ai)
