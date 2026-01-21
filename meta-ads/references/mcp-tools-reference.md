# Meta Ads MCP Server Tools Reference

This document provides detailed reference information for the Meta Ads MCP server tools and their usage patterns.

> **Note:** This reference document will be customized based on your specific Meta Ads MCP server implementation. The examples below represent common patterns - actual tool names, parameters, and responses may vary based on your MCP server.

## Table of Contents

1. [MCP Server Overview](#mcp-server-overview)
2. [Authentication & Connection](#authentication--connection)
3. [Core Tools](#core-tools)
4. [Tool Usage Patterns](#tool-usage-patterns)
5. [Response Structures](#response-structures)
6. [Error Handling](#error-handling)

---

## MCP Server Overview

### Typical MCP Server Names
- `pipeboard-meta-ads`
- `meta-ads`
- `facebook-ads`
- `meta-advertising`

### Required Configuration

Most Meta Ads MCP servers require the following configuration:

```json
{
  "mcpServers": {
    "meta-ads": {
      "command": "npx",
      "args": ["-y", "@your-mcp-package/meta-ads"],
      "env": {
        "META_ACCESS_TOKEN": "your-access-token",
        "META_AD_ACCOUNT_ID": "act_123456789"
      }
    }
  }
}
```

**Required Credentials:**
- **Access Token** - Meta API access token with ads_read and/or ads_management permissions
- **Ad Account ID** - Target ad account (format: act_XXXXXXXXXXXXX)
- Optional: App ID, App Secret (depending on authentication method)

---

## Authentication & Connection

### Verifying MCP Connection

To verify the Meta Ads MCP is properly connected:

1. List available MCP servers
2. Confirm Meta Ads MCP is present in the list
3. Attempt to list available tools from the MCP
4. Execute a simple read-only operation (e.g., list campaigns)

### Permission Scopes

Common required scopes for Meta Ads API:
- **ads_read** - Read ad account data, campaigns, insights
- **ads_management** - Create, update, and delete ads
- **business_management** - Access business-level information

---

## Core Tools

> **Placeholder Section:** This section will be customized with your specific MCP server's tools. Below are common tool patterns found in Meta Ads MCP implementations.

### Campaign Management Tools

#### list_campaigns
List all campaigns in an ad account.

**Typical Parameters:**
- `account_id` (string, required) - Ad account ID (e.g., "act_123456789")
- `fields` (array, optional) - Fields to return (e.g., ["id", "name", "status", "objective"])
- `filtering` (array, optional) - Filter criteria
- `limit` (number, optional) - Maximum number of results

**Example Usage:**
```json
{
  "tool": "list_campaigns",
  "parameters": {
    "account_id": "act_123456789",
    "fields": ["id", "name", "status", "objective", "daily_budget", "lifetime_budget"],
    "filtering": [{"field": "status", "operator": "IN", "value": ["ACTIVE", "PAUSED"]}]
  }
}
```

**Typical Response:**
```json
{
  "data": [
    {
      "id": "123456789",
      "name": "Summer Sale 2026",
      "status": "ACTIVE",
      "objective": "OUTCOME_SALES",
      "daily_budget": null,
      "lifetime_budget": "1000000"
    }
  ],
  "paging": {
    "cursors": {
      "before": "...",
      "after": "..."
    }
  }
}
```

#### get_campaign
Get details for a specific campaign.

**Typical Parameters:**
- `campaign_id` (string, required) - Campaign ID
- `fields` (array, optional) - Fields to return

**Example Usage:**
```json
{
  "tool": "get_campaign",
  "parameters": {
    "campaign_id": "123456789",
    "fields": ["id", "name", "status", "objective", "created_time", "updated_time"]
  }
}
```

#### create_campaign
Create a new campaign.

**Typical Parameters:**
- `account_id` (string, required) - Ad account ID
- `name` (string, required) - Campaign name
- `objective` (string, required) - Campaign objective (e.g., "OUTCOME_SALES", "OUTCOME_LEADS")
- `status` (string, optional) - Initial status (default: "PAUSED")
- `special_ad_categories` (array, optional) - Special categories (e.g., ["CREDIT", "EMPLOYMENT", "HOUSING"])
- `daily_budget` (string, optional) - Daily budget in cents
- `lifetime_budget` (string, optional) - Lifetime budget in cents

**Example Usage:**
```json
{
  "tool": "create_campaign",
  "parameters": {
    "account_id": "act_123456789",
    "name": "Q1 Product Launch",
    "objective": "OUTCOME_SALES",
    "status": "PAUSED",
    "lifetime_budget": "500000"
  }
}
```

#### update_campaign
Update an existing campaign.

**Typical Parameters:**
- `campaign_id` (string, required) - Campaign ID to update
- Updates can include: `name`, `status`, `daily_budget`, `lifetime_budget`, etc.

**Example Usage:**
```json
{
  "tool": "update_campaign",
  "parameters": {
    "campaign_id": "123456789",
    "status": "ACTIVE",
    "daily_budget": "10000"
  }
}
```

### Insights & Reporting Tools

#### get_insights
Get performance insights for campaigns, ad sets, or ads.

**Typical Parameters:**
- `object_id` (string, required) - ID of campaign, ad set, or ad
- `level` (string, optional) - Aggregation level: "campaign", "adset", "ad"
- `date_preset` (string, optional) - Date range preset (e.g., "last_7d", "last_30d")
- `time_range` (object, optional) - Custom date range with `since` and `until` (YYYY-MM-DD)
- `fields` (array, optional) - Metrics to retrieve
- `breakdowns` (array, optional) - Breakdown dimensions (e.g., ["age", "gender"])
- `filtering` (array, optional) - Filter criteria
- `limit` (number, optional) - Result limit

**Example Usage - Campaign Insights:**
```json
{
  "tool": "get_insights",
  "parameters": {
    "object_id": "act_123456789",
    "level": "campaign",
    "date_preset": "last_30d",
    "fields": [
      "campaign_id",
      "campaign_name",
      "impressions",
      "clicks",
      "spend",
      "conversions",
      "conversion_values",
      "ctr",
      "cpc",
      "roas"
    ]
  }
}
```

**Example Usage - Demographic Breakdown:**
```json
{
  "tool": "get_insights",
  "parameters": {
    "object_id": "123456789",
    "level": "campaign",
    "date_preset": "last_7d",
    "fields": ["impressions", "clicks", "spend", "conversions"],
    "breakdowns": ["age", "gender"]
  }
}
```

**Example Usage - Custom Date Range:**
```json
{
  "tool": "get_insights",
  "parameters": {
    "object_id": "123456789",
    "level": "ad",
    "time_range": {
      "since": "2026-01-01",
      "until": "2026-01-15"
    },
    "fields": ["ad_id", "ad_name", "impressions", "clicks", "spend", "conversions"]
  }
}
```

**Typical Response:**
```json
{
  "data": [
    {
      "campaign_id": "123456789",
      "campaign_name": "Summer Sale 2026",
      "impressions": "452341",
      "clicks": "12456",
      "spend": "4521.23",
      "conversions": "234",
      "conversion_values": "19034.56",
      "ctr": "2.753",
      "cpc": "0.363",
      "roas": "4.21",
      "date_start": "2025-12-16",
      "date_stop": "2026-01-14"
    }
  ]
}
```

### Ad Set Management Tools

#### list_adsets
List ad sets for a campaign or account.

**Typical Parameters:**
- `campaign_id` or `account_id` (string, required)
- `fields` (array, optional)
- `filtering` (array, optional)
- `limit` (number, optional)

#### create_adset
Create a new ad set.

**Typical Parameters:**
- `campaign_id` (string, required)
- `name` (string, required)
- `optimization_goal` (string, required)
- `billing_event` (string, required)
- `bid_amount` (string, optional)
- `daily_budget` or `lifetime_budget` (string, required)
- `targeting` (object, required) - Targeting specification
- `start_time` (string, optional)
- `end_time` (string, optional)

### Ad Management Tools

#### list_ads
List ads for an ad set, campaign, or account.

**Typical Parameters:**
- `adset_id`, `campaign_id`, or `account_id` (string, required)
- `fields` (array, optional)
- `filtering` (array, optional)

#### create_ad
Create a new ad.

**Typical Parameters:**
- `adset_id` (string, required)
- `name` (string, required)
- `creative` (object, required) - Creative specification
- `status` (string, optional)

### Search & Discovery Tools

#### search_ad_accounts
Search for ad accounts accessible to the current user.

**Typical Parameters:**
- `query` (string, optional) - Search term
- `fields` (array, optional)

**Example Usage:**
```json
{
  "tool": "search_ad_accounts",
  "parameters": {
    "query": "Acme Corporation",
    "fields": ["id", "name", "account_id", "account_status", "currency"]
  }
}
```

---

## Tool Usage Patterns

### Pattern 1: Generate Campaign Performance Report

**Workflow:**
1. Use `list_campaigns` or `search_ad_accounts` to identify target campaigns
2. Use `get_insights` with `level: "campaign"` to fetch performance data
3. Sort and format results
4. Present report with summary statistics

### Pattern 2: Analyze Creative Performance

**Workflow:**
1. Use `list_ads` to get ads in a campaign or ad set
2. Use `get_insights` with `level: "ad"` to fetch ad-level performance
3. For video ads, request video-specific metrics
4. Compare creative variations
5. Identify top performers and creative fatigue

### Pattern 3: Demographic Analysis

**Workflow:**
1. Identify campaign/ad set to analyze
2. Use `get_insights` with `breakdowns: ["age", "gender"]`
3. Calculate segment performance metrics
4. Identify high-value segments
5. Provide targeting recommendations

### Pattern 4: Budget Pacing Analysis

**Workflow:**
1. Use `list_campaigns` with budget fields
2. Use `get_insights` with daily breakdown to see spend trend
3. Calculate pacing metrics (current vs. ideal)
4. Project final spend
5. Recommend budget adjustments

### Pattern 5: Create and Launch Campaign

**Workflow:**
1. Use `create_campaign` with initial settings
2. Use `create_adset` with targeting and budget
3. Use `create_ad` with creative specification
4. Use `update_campaign` to set status to "ACTIVE"
5. Confirm creation and return IDs

---

## Response Structures

### Standard Response Format

Most MCP tools return responses in this format:

```json
{
  "data": [...],  // Array of results or single object
  "paging": {     // Pagination info (if applicable)
    "cursors": {
      "before": "...",
      "after": "..."
    },
    "next": "https://..."
  }
}
```

### Insights Response Structure

```json
{
  "data": [
    {
      "campaign_id": "123456789",
      "campaign_name": "Campaign Name",
      "date_start": "2026-01-01",
      "date_stop": "2026-01-15",
      "impressions": "100000",
      "clicks": "2500",
      "spend": "500.00",
      "conversions": "50",
      // ... other metrics
    }
  ]
}
```

**Note:** Numeric values are often returned as strings to preserve precision.

### Error Response Structure

```json
{
  "error": {
    "message": "Error description",
    "type": "OAuthException",
    "code": 190,
    "error_subcode": 463,
    "fbtrace_id": "..."
  }
}
```

---

## Error Handling

### Common Error Codes

- **190** - Access token invalid or expired
- **200** - Permission denied
- **100** - Invalid parameter
- **80004** - Request limit reached (rate limiting)
- **17** - User request limit reached

### Error Handling Best Practices

1. **Check for error object** in response
2. **Parse error code and message** for specific issue
3. **Handle authentication errors** by prompting for token refresh
4. **Handle rate limits** by implementing retry logic with backoff
5. **Validate inputs** before making API calls
6. **Provide helpful error messages** to users

### Example Error Handling Pattern

```
If error.code == 190:
  → Token expired - guide user to regenerate access token

If error.code == 80004:
  → Rate limit exceeded - wait and retry after delay

If error.code == 100:
  → Invalid parameter - check input validation
  → Provide specific feedback on which parameter is invalid

If error.code == 200:
  → Permission denied - check token scopes and account access
```

---

## Customization Instructions

**To customize this reference for your specific MCP server:**

1. **Identify your MCP server name** - Check your Claude configuration
2. **List available tools** - Use MCP introspection to see all available tools
3. **Document tool signatures** - For each tool, note:
   - Tool name
   - Required parameters
   - Optional parameters
   - Parameter types and formats
   - Response structure
4. **Test each tool** - Execute sample requests to verify behavior
5. **Update this document** - Replace placeholder examples with actual tool definitions
6. **Add specific examples** - Include real examples from your MCP server

**Tool Discovery Commands:**
- List MCP servers (varies by Claude interface)
- List tools for a specific MCP server
- Get tool schema/signature

---

## Additional Notes

### Data Type Conventions

- **IDs:** String format (e.g., "123456789", "act_123456789")
- **Currency:** String format representing cents/smallest unit (e.g., "100000" = $1,000.00)
- **Dates:** ISO 8601 format (YYYY-MM-DD) or ISO timestamp
- **Metrics:** Often returned as strings to preserve decimal precision
- **Arrays:** Used for multi-value fields and breakdowns

### Field Naming Conventions

- **IDs:** `campaign_id`, `adset_id`, `ad_id`, `creative_id`
- **Names:** `campaign_name`, `adset_name`, `ad_name`
- **Status:** `status` (values: ACTIVE, PAUSED, DELETED, ARCHIVED)
- **Time:** `created_time`, `updated_time`, `start_time`, `end_time`
- **Budget:** `daily_budget`, `lifetime_budget` (in cents/smallest currency unit)

---

**Document Version:** 1.0 (Template)
**Last Updated:** 2026-01-19
**Status:** Awaiting customization with specific MCP server details

**To complete this reference, provide:**
- Your MCP server name
- List of available tools
- Example tool responses
- Any specific authentication requirements
