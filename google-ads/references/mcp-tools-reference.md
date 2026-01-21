# Google Ads MCP Server Tools Reference

This document provides detailed reference information for the Google Ads MCP server tools and their usage patterns.

> **Note:** This reference document is based on the mcp-google-ads server implementation. Tool names, parameters, and responses are specific to this MCP server.

## Table of Contents

1. [MCP Server Overview](#mcp-server-overview)
2. [Authentication & Connection](#authentication--connection)
3. [Core Tools](#core-tools)
4. [Tool Usage Patterns](#tool-usage-patterns)
5. [Response Structures](#response-structures)
6. [Error Handling](#error-handling)

---

## MCP Server Overview

### MCP Server Name
- **Repository:** https://github.com/cohnen/mcp-google-ads
- **Typical name:** `google-ads`

### Required Configuration

The Google Ads MCP server requires the following configuration:

```json
{
  "mcpServers": {
    "google-ads": {
      "command": "npx",
      "args": ["-y", "@cohnen/mcp-google-ads"],
      "env": {
        "GOOGLE_ADS_CLIENT_ID": "your-client-id",
        "GOOGLE_ADS_CLIENT_SECRET": "your-client-secret",
        "GOOGLE_ADS_DEVELOPER_TOKEN": "your-developer-token",
        "GOOGLE_ADS_REFRESH_TOKEN": "your-refresh-token",
        "GOOGLE_ADS_CUSTOMER_ID": "1234567890"
      }
    }
  }
}
```

**Required Credentials:**
- **Client ID** - OAuth2 client ID
- **Client Secret** - OAuth2 client secret
- **Developer Token** - Google Ads API developer token
- **Refresh Token** - OAuth2 refresh token
- **Customer ID** - Optional default customer ID (format: 1234567890, without hyphens)

---

## Authentication & Connection

### Verifying MCP Connection

To verify the Google Ads MCP is properly connected:

1. Check for the `list_accounts` tool in your available tools
2. Execute `list_accounts` to confirm API connectivity
3. Verify you can access account data

### Permission Scopes

Required OAuth scopes for Google Ads API:
- **https://www.googleapis.com/auth/adwords** - Full access to Google Ads

---

## Core Tools

### Account Management Tools

#### list_accounts
List all accessible Google Ads accounts.

**Parameters:** None required

**Example Usage:**
```json
{
  "tool": "list_accounts"
}
```

**Typical Response:**
```json
{
  "accounts": [
    {
      "customerId": "1234567890",
      "descriptiveName": "My Business Account",
      "currencyCode": "USD",
      "timeZone": "America/New_York"
    }
  ]
}
```

---

### Campaign Management & Reporting Tools

#### get_campaign_performance
Get campaign performance metrics for a specific account and time period.

**Parameters:**
- `customer_id` (string, required) - Google Ads customer ID (format: 123-456-7890 or 1234567890)
- `start_date` (string, required) - Start date in YYYY-MM-DD format
- `end_date` (string, required) - End date in YYYY-MM-DD format

**Example Usage:**
```json
{
  "tool": "get_campaign_performance",
  "parameters": {
    "customer_id": "1234567890",
    "start_date": "2026-01-01",
    "end_date": "2026-01-15"
  }
}
```

**Typical Response:**
```json
{
  "campaigns": [
    {
      "campaignId": "123456789",
      "campaignName": "Brand Awareness - Winter 2026",
      "status": "ENABLED",
      "impressions": "45230",
      "clicks": "1234",
      "cost": "567.89",
      "conversions": "45",
      "conversionValue": "2345.67",
      "ctr": "2.73%",
      "averageCpc": "0.46",
      "costPerConversion": "12.62",
      "roas": "4.13"
    }
  ]
}
```

---

#### get_ad_performance
Analyze ad creative performance.

**Parameters:**
- `customer_id` (string, required) - Google Ads customer ID
- `start_date` (string, required) - Start date in YYYY-MM-DD format
- `end_date` (string, required) - End date in YYYY-MM-DD format
- `campaign_id` (string, optional) - Filter by specific campaign

**Example Usage:**
```json
{
  "tool": "get_ad_performance",
  "parameters": {
    "customer_id": "1234567890",
    "start_date": "2026-01-01",
    "end_date": "2026-01-15",
    "campaign_id": "123456789"
  }
}
```

**Typical Response:**
```json
{
  "ads": [
    {
      "adGroupId": "987654321",
      "adGroupName": "Product - Shoes",
      "adId": "456789123",
      "adType": "RESPONSIVE_SEARCH_AD",
      "impressions": "12345",
      "clicks": "456",
      "cost": "123.45",
      "conversions": "23",
      "ctr": "3.69%",
      "averageCpc": "0.27"
    }
  ]
}
```

---

### Custom Query Tool

#### execute_gaql_query / run_gaql
Execute custom GAQL (Google Ads Query Language) queries for advanced reporting and analysis.

**Parameters:**
- `customer_id` (string, required) - Google Ads customer ID
- `query` (string, required) - GAQL query string

**Example Usage - Campaign with Metrics:**
```json
{
  "tool": "run_gaql",
  "parameters": {
    "customer_id": "1234567890",
    "query": "SELECT campaign.id, campaign.name, campaign.status, metrics.impressions, metrics.clicks, metrics.cost_micros, metrics.conversions FROM campaign WHERE segments.date DURING LAST_30_DAYS"
  }
}
```

**Example Usage - Keyword Performance:**
```json
{
  "tool": "run_gaql",
  "parameters": {
    "customer_id": "1234567890",
    "query": "SELECT ad_group_criterion.keyword.text, ad_group_criterion.quality_info.quality_score, metrics.impressions, metrics.clicks, metrics.ctr, metrics.average_cpc FROM keyword_view WHERE segments.date DURING LAST_7_DAYS ORDER BY metrics.impressions DESC LIMIT 50"
  }
}
```

**Example Usage - Search Terms Report:**
```json
{
  "tool": "run_gaql",
  "parameters": {
    "customer_id": "1234567890",
    "query": "SELECT search_term_view.search_term, metrics.impressions, metrics.clicks, metrics.ctr, metrics.conversions FROM search_term_view WHERE segments.date DURING LAST_30_DAYS ORDER BY metrics.impressions DESC"
  }
}
```

**Typical Response:**
```json
{
  "results": [
    {
      "campaign": {
        "id": "123456789",
        "name": "Brand Campaign",
        "status": "ENABLED"
      },
      "metrics": {
        "impressions": "45230",
        "clicks": "1234",
        "costMicros": "567890000",
        "conversions": "45"
      }
    }
  ],
  "fieldMask": "campaign.id,campaign.name,campaign.status,metrics.impressions,metrics.clicks,metrics.costMicros,metrics.conversions",
  "totalResultsCount": "15"
}
```

---

## Tool Usage Patterns

### Pattern 1: Account Overview
**Workflow:**
1. Use `list_accounts` to see all accessible accounts
2. Use `get_campaign_performance` for each account to get high-level metrics
3. Present summary with key performance indicators

### Pattern 2: Campaign Performance Analysis
**Workflow:**
1. Use `get_campaign_performance` with desired date range
2. Sort campaigns by key metrics (ROAS, conversions, spend)
3. Identify top performers and underperformers
4. Provide optimization recommendations

### Pattern 3: Ad Creative Analysis
**Workflow:**
1. Use `get_ad_performance` for the target period
2. Group ads by campaign or ad group
3. Compare creative variations (headlines, descriptions, assets)
4. Identify creative fatigue and high performers
5. Recommend creative optimizations

### Pattern 4: Keyword Analysis
**Workflow:**
1. Use `run_gaql` to query keyword_view with quality_score and performance metrics
2. Identify high-cost, low-quality keywords
3. Find high-performing keywords for bid increases
4. Analyze search terms to find new keyword opportunities
5. Recommend keyword optimizations

### Pattern 5: Budget & Spend Analysis
**Workflow:**
1. Use `get_campaign_performance` to get spend data
2. Use `run_gaql` to query daily spend trends
3. Calculate budget pacing (actual vs. projected)
4. Identify budget-constrained campaigns
5. Recommend budget reallocation

### Pattern 6: Custom Deep-Dive Analysis
**Workflow:**
1. Identify specific question or metric to analyze
2. Construct GAQL query with appropriate resources and segments
3. Use `run_gaql` to execute custom query
4. Parse and analyze results
5. Present insights with actionable recommendations

---

## Response Structures

### Standard List Response

```json
{
  "accounts": [...],
  "campaigns": [...],
  "ads": [...]
}
```

### GAQL Query Response

```json
{
  "results": [
    {
      // Resource fields (campaign, ad_group, etc.)
      "campaign": { "id": "...", "name": "..." },
      // Metrics
      "metrics": { "impressions": "...", "clicks": "..." },
      // Segments (optional)
      "segments": { "date": "..." }
    }
  ],
  "fieldMask": "campaign.id,campaign.name,metrics.impressions",
  "totalResultsCount": "42"
}
```

**Note:**
- Numeric values may be returned as strings or numbers
- Cost values are in micros (1,000,000 micros = 1 currency unit)
- Percentages may be decimals (0.0273 = 2.73%) or formatted strings

---

## Error Handling

### Common Error Types

- **AUTHENTICATION_ERROR** - Invalid credentials or expired token
- **AUTHORIZATION_ERROR** - Insufficient permissions for the operation
- **INVALID_CUSTOMER_ID** - Customer ID format incorrect or inaccessible
- **QUERY_ERROR** - Invalid GAQL query syntax
- **RATE_LIMIT_ERROR** - API rate limit exceeded
- **RESOURCE_NOT_FOUND** - Requested campaign/ad/resource doesn't exist

### Error Handling Best Practices

1. **Validate customer ID format** - Remove hyphens if present (123-456-7890 → 1234567890)
2. **Check date formats** - Ensure YYYY-MM-DD format
3. **Validate GAQL syntax** - Test queries with simple SELECT statements first
4. **Handle authentication errors** - Guide user to refresh credentials
5. **Implement retry logic** - For rate limit errors with exponential backoff
6. **Provide clear error messages** - Translate technical errors to user-friendly messages

### Example Error Handling Pattern

```
If error contains "AUTHENTICATION_ERROR":
  → Credentials invalid or expired - check MCP configuration

If error contains "INVALID_CUSTOMER_ID":
  → Customer ID format incorrect - ensure format is 1234567890 (no hyphens)

If error contains "QUERY_ERROR":
  → GAQL syntax error - review query structure and field names
  → Check GAQL documentation for valid resources and fields

If error contains "RATE_LIMIT":
  → API rate limit exceeded - implement exponential backoff
  → Reduce query frequency or batch requests
```

---

## Additional Notes

### Data Type Conventions

- **Customer IDs:** String or number format, 10 digits, no hyphens (e.g., "1234567890")
- **Campaign/Ad IDs:** String format (e.g., "123456789")
- **Currency:**
  - `cost_micros`: Micros format (1,000,000 micros = 1.00 currency unit)
  - `cost`: Decimal format (e.g., "123.45")
- **Dates:** ISO format (YYYY-MM-DD)
- **Metrics:** Often strings to preserve precision, may include units or % symbols

### GAQL Query Essentials

**Basic Structure:**
```sql
SELECT [fields] FROM [resource] WHERE [conditions] ORDER BY [field] LIMIT [number]
```

**Common Resources:**
- `campaign` - Campaign-level data
- `ad_group` - Ad group-level data
- `ad_group_ad` - Ad-level data
- `keyword_view` - Keyword performance
- `search_term_view` - Search query data
- `geo_target_constant` - Geographic targeting

**Common Date Segments:**
- `segments.date DURING LAST_7_DAYS`
- `segments.date DURING LAST_30_DAYS`
- `segments.date DURING THIS_MONTH`
- `segments.date BETWEEN '2026-01-01' AND '2026-01-15'`

**Useful Metrics:**
- `metrics.impressions`
- `metrics.clicks`
- `metrics.cost_micros`
- `metrics.conversions`
- `metrics.conversions_value`
- `metrics.ctr`
- `metrics.average_cpc`

---

**Document Version:** 1.0
**Last Updated:** 2026-01-21
**MCP Server:** cohnen/mcp-google-ads
**Status:** Production ready

**Reference Links:**
- MCP Repository: https://github.com/cohnen/mcp-google-ads
- Google Ads API Documentation: https://developers.google.com/google-ads/api/docs/start
- GAQL Reference: https://developers.google.com/google-ads/api/docs/query/overview
