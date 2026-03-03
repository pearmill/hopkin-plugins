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

### Hopkin OAuth Flow

Hopkin uses an OAuth flow for connecting to LinkedIn Ads accounts. After the MCP is configured, authenticate the user's LinkedIn Ads account:

1. **Check auth status:**
   ```json
   {
     "tool": "linkedin_ads_check_auth_status",
     "parameters": {
       "reason": "Checking if user is authenticated with LinkedIn Ads"
     }
   }
   ```

2. **If not authenticated:** Direct the user to connect their LinkedIn Ads account at https://app.hopkin.ai. The OAuth flow is completed through the Hopkin web app, not through an MCP tool.

> **Token TTL:** LinkedIn provider tokens expire after **60 days**. If the user was previously authenticated but tools are returning auth errors, direct them to https://app.hopkin.ai to reconnect.

---

## Core Tools

> **Important:** Every Hopkin tool call requires a `reason` (string) parameter for audit trail.

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
- `status` (string, optional) — Filter by account status (default: `ACTIVE`). Options: `ACTIVE`, `CANCELLED`, `DRAFT`, `PENDING_DELETION`, `REMOVED`
- `type` (string, optional) — Filter by account type. Options: `BUSINESS`, `ENTERPRISE`
- `include_test_accounts` (boolean, optional) — Include test/sandbox accounts (default: false)
- `limit` (number, optional) — Max accounts to return (default: 25, max: 100)
- `cursor` (string, optional) — Opaque pagination cursor from previous response
- `refresh` (boolean, optional) — Force fresh fetch from LinkedIn API (bypasses 5-min cache)

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
- `account_id` (number, required) — Ad account ID (numeric, no URN)
- `status` (array of strings, optional) — Filter by status (default: `["ACTIVE", "PAUSED"]`). Options: `ACTIVE`, `PAUSED`, `ARCHIVED`, `CANCELED`, `DRAFT`, `PENDING`
- `campaign_group_id` (string, optional) — Fetch a single campaign group by ID
- `campaign_group_ids` (array of strings, optional) — Fetch specific campaign groups by IDs
- `limit` (number, optional) — Max results (default: 20, max: 100)
- `cursor` (string, optional) — Opaque pagination cursor
- `refresh` (boolean, optional) — Force fresh fetch from LinkedIn API

**Example:**
```json
{
  "tool": "linkedin_ads_list_campaign_groups",
  "parameters": {
    "reason": "Listing active campaign groups for performance analysis",
    "account_id": 123456789,
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
- `account_id` (number, required) — Ad account ID
- `status` (array of strings, optional) — Filter by status (default: `["ACTIVE", "PAUSED"]`). Options: `ACTIVE`, `PAUSED`, `ARCHIVED`, `CANCELED`, `DRAFT`
- `campaign_group_id` (string, optional) — Filter to a specific campaign group
- `type` (array of strings, optional) — Filter by campaign type. Options: `SPONSORED_UPDATES`, `TEXT_AD`, `SPONSORED_INMAILS`, `DYNAMIC`
- `campaign_id` (string, optional) — Fetch a single campaign by ID
- `campaign_ids` (array of strings, optional) — Fetch specific campaigns by IDs
- `limit` (number, optional) — Max results (default: 20, max: 100)
- `cursor` (string, optional) — Opaque pagination cursor
- `refresh` (boolean, optional) — Force fresh fetch from LinkedIn API

**Example:**
```json
{
  "tool": "linkedin_ads_list_campaigns",
  "parameters": {
    "reason": "Listing active campaigns for targeting analysis",
    "account_id": 123456789,
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
    "account_id": 123456789,
    "campaign_group_id": "987654321"
  }
}
```

---

### Creative Tools

#### linkedin_ads_list_creatives
List LinkedIn Creatives — the ad content units containing headline, body text, image, and CTA. Analogous to Ads in Meta and Google.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (number, required) — Ad account ID
- `campaign_ids` (array of strings, optional) — Filter to specific campaign IDs
- `status` (string, optional) — Filter by intended status. Options: `ACTIVE`, `PAUSED`, `ARCHIVED`, `CANCELED`, `DRAFT`
- `resolve_content` (boolean, optional) — When true, resolves each creative's ad copy: headline, body text, and destination URL (default: true)
- `creative_id` (string, optional) — Fetch a single creative by URN or numeric ID
- `creative_ids` (array of strings, optional) — Fetch specific creatives by numeric IDs
- `limit` (number, optional) — Max results (default: 25, max: 100)
- `cursor` (string, optional) — Opaque pagination cursor
- `refresh` (boolean, optional) — Force fresh fetch from LinkedIn API

**Example:**
```json
{
  "tool": "linkedin_ads_list_creatives",
  "parameters": {
    "reason": "Listing active creatives for a campaign to analyze ad copy",
    "account_id": 123456789,
    "campaign_ids": ["111222333"],
    "status": "ACTIVE",
    "resolve_content": true
  }
}
```

---

### Analytics Tools

#### linkedin_ads_get_performance_report
**Recommended analytics tool.** Get a full-funnel performance report with impressions, clicks, spend, conversions, leads, video views, CTR, CPC, CPA, ROAS, plus optional per-conversion-action breakdown.

Supports pivots at ACCOUNT, CAMPAIGN, CAMPAIGN_GROUP, or CREATIVE level. **Does not support MEMBER_* demographic pivots** — use `linkedin_ads_get_insights` for those.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (number, required) — Ad account ID
- `pivots` (array of strings, required) — Dimensions to pivot by (max 3). Options: `ACCOUNT`, `CAMPAIGN`, `CAMPAIGN_GROUP`, `CREATIVE`
- `date_preset` (string, optional) — Relative date range. Options: `TODAY`, `YESTERDAY`, `LAST_7_DAYS`, `LAST_14_DAYS`, `LAST_30_DAYS`, `LAST_90_DAYS`, `THIS_MONTH`, `LAST_MONTH`. Required if `start_date`/`end_date` not provided.
- `start_date` (string, optional) — Custom start date (YYYY-MM-DD). Required if `date_preset` not provided.
- `end_date` (string, optional) — Custom end date (YYYY-MM-DD)
- `time_granularity` (string, optional) — `ALL` for aggregate (default) or `DAILY` for time series
- `campaign_ids` (array of strings, optional) — Filter to specific campaign IDs
- `campaign_group_ids` (array of strings, optional) — Filter to specific campaign group IDs
- `include_conversion_breakdown` (boolean, optional) — Include per-conversion-action breakdown (makes a second API call, default: false)

**Returns:**
- Full funnel metrics: impressions, clicks, spend, conversions, leads, video views, CTR, CPC, CPA, ROAS
- Optional `conversion_breakdown` — per-conversion-action metrics when `include_conversion_breakdown: true`

**Example — Campaign group overview:**
```json
{
  "tool": "linkedin_ads_get_performance_report",
  "parameters": {
    "reason": "Generating campaign group performance report for last 30 days",
    "account_id": 123456789,
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
    "account_id": 123456789,
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
    "account_id": 123456789,
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
    "account_id": 123456789,
    "pivots": ["ACCOUNT"],
    "date_preset": "LAST_30_DAYS",
    "time_granularity": "DAILY"
  }
}
```

---

#### linkedin_ads_get_account_summary
Get a high-level performance summary for a LinkedIn Ads account. Makes three parallel API calls: account details, aggregate analytics, and conversion breakdown.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (number, required) — Ad account ID
- `date_preset` (string, optional) — Relative date range (default: `LAST_30_DAYS`). Options: `TODAY`, `YESTERDAY`, `LAST_7_DAYS`, `LAST_14_DAYS`, `LAST_30_DAYS`, `LAST_90_DAYS`, `THIS_MONTH`, `LAST_MONTH`
- `start_date` (string, optional) — Custom start date (YYYY-MM-DD, overrides `date_preset`)
- `end_date` (string, optional) — Custom end date (YYYY-MM-DD)

**Example:**
```json
{
  "tool": "linkedin_ads_get_account_summary",
  "parameters": {
    "reason": "Getting account-level summary to start a performance review session",
    "account_id": 123456789,
    "date_preset": "LAST_30_DAYS"
  }
}
```

---

#### linkedin_ads_get_insights
Flexible analytics with custom pivot dimensions. Supports LinkedIn's unique MEMBER_* demographic pivots for professional audience analysis. Use when `linkedin_ads_get_performance_report` does not cover the required analysis (primarily for demographic breakdowns).

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (number, required) — Ad account ID
- `pivot` (string, required) — Dimension to pivot by. Standard pivots: `ACCOUNT`, `CAMPAIGN`, `CAMPAIGN_GROUP`, `CREATIVE`. LinkedIn-unique demographic pivots: `MEMBER_COMPANY`, `MEMBER_COUNTRY`, `MEMBER_REGION`, `MEMBER_JOB_TITLE`, `MEMBER_JOB_FUNCTION`, `MEMBER_INDUSTRY`, `MEMBER_SENIORITY`, `MEMBER_COMPANY_SIZE`, `MEMBER_AGE`
- `date_preset` (string, optional) — Relative date range. Options: `TODAY`, `YESTERDAY`, `LAST_7_DAYS`, `LAST_14_DAYS`, `LAST_30_DAYS`, `LAST_90_DAYS`, `THIS_MONTH`, `LAST_MONTH`
- `start_date` (string, optional) — Start date (YYYY-MM-DD)
- `end_date` (string, optional) — End date (YYYY-MM-DD)
- `time_granularity` (string, optional) — `ALL` (aggregate, default) or `DAILY` (time series)
- `campaign_ids` (array of strings, optional) — Filter to specific campaign IDs
- `campaign_group_ids` (array of strings, optional) — Filter to specific campaign group IDs
- `metrics` (array of strings, optional) — Specific metrics to include (default: impressions, clicks, spend, CTR, CPC, conversions)

**Example — Job function demographic breakdown:**
```json
{
  "tool": "linkedin_ads_get_insights",
  "parameters": {
    "reason": "Analyzing performance by job function to identify high-value B2B segments",
    "account_id": 123456789,
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
    "account_id": 123456789,
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
    "account_id": 123456789,
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
    "account_id": 123456789,
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
- `account_id` (number, required) — Ad account ID
- `campaign_type` (string, required) — Type of campaign. Options: `TEXT_AD`, `SPONSORED_UPDATES`, `SPONSORED_INMAILS`
- `bid_type` (string, required) — Bid model. Options: `CPM`, `CPC`, `CPV`. Note: `SPONSORED_INMAILS` only supports `CPM`; `SPONSORED_UPDATES` supports all three; `TEXT_AD` supports `CPM` and `CPC`
- `currency` (string, required) — 3-letter ISO currency code (e.g., `USD`, `EUR`, `GBP`)
- `location_urns` (array of strings, required) — Array of LinkedIn geo URNs (e.g., `urn:li:geo:103644278` for US)
- `match_type` (string, optional) — Audience match precision. Options: `EXACT`, `BROAD` (default: `EXACT`)
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
    "account_id": 123456789,
    "campaign_type": "SPONSORED_UPDATES",
    "bid_type": "CPC",
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
- `account_id` (number, required) — Ad account ID

**Example:**
```json
{
  "tool": "linkedin_ads_get_partner_conversions",
  "parameters": {
    "reason": "Understanding which conversion actions are active before analyzing ROAS",
    "account_id": 123456789
  }
}
```

---

### Preference Tools

Preferences allow persistent storage of settings and observations across sessions. Entity listing tools (e.g., `linkedin_ads_list_ad_accounts`) automatically attach stored preferences to each entity in the response as `_stored_preferences`. Use preferences to remember user choices, default accounts, and analytical observations.

**Session start pattern:** At the start of a session, call `linkedin_ads_get_preferences` with `entity_type: "ad_account"` and `entity_id: "default"` to retrieve stored defaults (e.g., `default_account_id`). If found, use them automatically.

**After account selection:** Offer to store the selected account using `linkedin_ads_store_preference` so it is available in future sessions.

#### linkedin_ads_store_preference
Store a persistent preference or observation for a LinkedIn Ads entity.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `entity_type` (string, required) — Entity type: `"ad_account"`, `"campaign_group"`, `"campaign"`, `"ad_set"` (maps to LinkedIn Campaign), or `"ad"` (maps to Creative)
- `entity_id` (string, required) — LinkedIn entity ID (bare numeric ID, not URN). Use `"default"` for account-level defaults.
- `key` (string, required) — Preference key (e.g., `"default_account_id"`, `"preferred_conversion_metric"`)
- `value` (any, required) — The preference value — string, number, boolean, or object
- `source` (string, optional) — Who set this: `"agent"` (default), `"user"`, or `"system"`
- `note` (string, optional) — Context about why this preference was set

**Example — Store default account:**
```json
{
  "tool": "linkedin_ads_store_preference",
  "parameters": {
    "reason": "User confirmed this is their default LinkedIn Ads account",
    "entity_type": "ad_account",
    "entity_id": "default",
    "key": "default_account_id",
    "value": "123456789",
    "note": "Set after user confirmed account selection"
  }
}
```

#### linkedin_ads_get_preferences
Retrieve all stored preferences for a LinkedIn Ads entity.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `entity_type` (string, required) — Entity type: `"ad_account"`, `"campaign_group"`, `"campaign"`, `"ad_set"`, or `"ad"`
- `entity_id` (string, required) — LinkedIn entity ID (use `"default"` for account-level defaults)

**Example:**
```json
{
  "tool": "linkedin_ads_get_preferences",
  "parameters": {
    "reason": "Checking for stored default account ID at session start",
    "entity_type": "ad_account",
    "entity_id": "default"
  }
}
```

#### linkedin_ads_delete_preference
Delete a specific stored preference by key.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `entity_type` (string, required) — Entity type: `"ad_account"`, `"campaign_group"`, `"campaign"`, `"ad_set"`, or `"ad"`
- `entity_id` (string, required) — LinkedIn entity ID
- `key` (string, required) — The preference key to delete

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
- `current_workaround` (string, optional) — How you are currently working around this limitation
- `priority` (string, optional) — Priority level: `"low"`, `"medium"`, `"high"`

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
1. Call `linkedin_ads_get_preferences` with `entity_type: "ad_account"` and `entity_id: "default"` to check for a stored default account
2. If found, use it and tell the user: "Using your saved account [X]. Use a different one? Let me know."
3. If not found, call `linkedin_ads_list_ad_accounts` and present a numbered list if multiple accounts are found
4. After account selection, offer to save with `linkedin_ads_store_preference`

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
1. Use `linkedin_ads_list_creatives` with `resolve_content: true` to get creative content
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

- **`limit`** (1–100) — Number of results per page (default 20–25 depending on tool)
- **`cursor`** — Opaque cursor string returned in the response to fetch the next page

**Example — Paginating through campaigns:**
```json
// First page
{
  "tool": "linkedin_ads_list_campaigns",
  "parameters": {
    "reason": "Listing campaigns page 1",
    "account_id": 123456789,
    "limit": 50
  }
}

// Next page (using cursor from previous response)
{
  "tool": "linkedin_ads_list_campaigns",
  "parameters": {
    "reason": "Listing campaigns page 2",
    "account_id": 123456789,
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

### Error Handling Best Practices

1. **Always check auth first** — If tools return auth errors, run `linkedin_ads_check_auth_status` and direct the user to https://app.hopkin.ai to re-authenticate
2. **Validate account ID format** — Numeric only (123456789, not urn:li:sponsoredAccount:123456789)
3. **Use the right analytics tool** — `get_performance_report` for standard funnel metrics; `get_insights` for MEMBER_* demographic pivots
4. **Handle pagination** — Don't assume all results are in the first page
5. **Provide clear messages** — Translate errors into user-friendly guidance

---

**Document Version:** 1.0
**Last Updated:** 2026-03-02
**Service:** Hopkin LinkedIn Ads MCP (https://app.hopkin.ai)
