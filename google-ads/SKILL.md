---
name: google-ads
description: Generate Google Ads performance reports and analytics using the Google Ads MCP server. Includes prerequisite checks, report generation workflows, and campaign analysis operations.
---

# Google Ads Reports Skill

## Introduction

This skill enables Claude to build comprehensive reports and perform analysis on Google Ads campaigns. Use this skill when you need to:

- Generate performance reports across campaigns, ad groups, or individual ads
- Analyze campaign metrics, ROAS, and spending patterns
- Understand keyword performance and search term opportunities
- Track budget pacing and costs
- Analyze ad creative effectiveness
- Execute custom GAQL queries for advanced analysis

The skill provides structured workflows for common Google Ads reporting tasks, with built-in best practices for data analysis and presentation.

## Prerequisites

Before using this skill, verify that the Google Ads MCP server is installed and configured.

### Check for MCP Availability

To verify the Google Ads MCP server is available:

1. Check for the `list_accounts` tool in your available tools
2. This confirms the Google Ads MCP server is properly configured
3. Test the connection by attempting to list accounts

### If Google Ads MCP Is Not Installed

If the Google Ads MCP server is not available:

1. **Inform the user** that the Google Ads MCP server is required to use this skill
2. **Provide installation instructions:**

> The Google Ads MCP is not configured. To use this skill, install the MCP server:
>
> **Repository**: https://github.com/cohnen/mcp-google-ads
>
> Follow the setup instructions to configure your Google Ads API credentials and add the MCP to your Claude configuration.

3. **Pause execution** until the user confirms MCP installation is complete
4. **Re-verify** MCP availability after user confirmation

### Required Information

Before generating reports, confirm you have:

- **Customer ID** - The Google Ads account to query (format: 1234567890, without hyphens)
- **Date Range** - Time period for data (start_date and end_date in YYYY-MM-DD format)
- **Access Permissions** - Verify the MCP has appropriate API access

## Core Capabilities

This skill supports four primary report types for comprehensive Google Ads analysis.

### Report Types

1. **Campaign Performance Reports** - Overall campaign metrics, spending, ROAS, and performance analysis
2. **Keyword Analysis Reports** - Keyword performance, quality scores, search terms, and optimization opportunities
3. **Ad Performance Reports** - Individual ad performance, RSA asset analysis, and creative effectiveness
4. **Budget & Spend Reports** - Budget tracking, spend pacing, cost analysis, and forecasting

## Available MCP Tools

- `list_accounts` - List all accessible Google Ads accounts
- `get_campaign_performance` - Get campaign metrics for an account and time period
- `get_ad_performance` - Analyze ad creative performance
- `execute_gaql_query` / `run_gaql` - Execute custom GAQL (Google Ads Query Language) queries

## Report Workflows

### Campaign Performance Report

Analyze overall campaign performance, compare campaigns across an account, identify top and bottom performers, understand ROAS and conversion metrics, and evaluate campaign effectiveness.

**Use case:** Campaign metrics, performance overview, ROAS analysis

**See detailed workflow:** **references/workflows/campaign-performance.md**

---

### Keyword Analysis Report

Evaluate keyword performance, analyze search terms, understand quality scores, identify negative keyword opportunities, and optimize keyword bidding strategies.

**Use case:** Keywords, search terms, quality score analysis

**See detailed workflow:** **references/workflows/keyword-analysis.md**

---

### Ad Performance Report

Examine individual ad effectiveness, analyze RSA (Responsive Search Ad) asset performance, identify best-performing ad copy, and understand creative impact on conversions.

**Use case:** Ad copy, RSA assets, creative effectiveness

**See detailed workflow:** **references/workflows/ad-performance.md**

---

### Budget & Spend Report

Monitor budget utilization and spending patterns, forecast end-of-period spend, identify budget-constrained campaigns, analyze cost efficiency, and ensure optimal budget allocation.

**Use case:** Budget, spend, pacing, cost analysis

**See detailed workflow:** **references/workflows/budget-spend.md**

---

## Quick Start Examples

### List All Accounts
```
Use the list_accounts tool to show all accessible Google Ads accounts.
```

### Campaign Performance (Last 30 Days)
```
Use get_campaign_performance with:
- customer_id: [account ID without hyphens]
- start_date: [30 days ago in YYYY-MM-DD]
- end_date: [today in YYYY-MM-DD]
```

### Custom GAQL Query
```
Use run_gaql or execute_gaql_query with:
- customer_id: [account ID without hyphens]
- query: [GAQL query string]
```

## Workflow Process

1. **Account Selection**: If no customer ID provided, use `list_accounts` first and ask user which account to analyze
2. **Date Range**: Default to last 30 days if not specified (start_date and end_date in YYYY-MM-DD format)
3. **Report Type Selection**: Determine which report type matches user intent based on the Report Types table
4. **Report Generation**: Use the appropriate MCP tool or construct GAQL query based on workflow reference
5. **Output Formatting**: Present data in clear tables with insights and actionable recommendations

## Best Practices

### Date Range Considerations

- **Short-term (1-7 days):** Recent changes, daily monitoring, quick checks
- **Medium-term (7-30 days):** Standard for performance evaluation, trend analysis
- **Long-term (30-90+ days):** Seasonal patterns, lifecycle analysis, strategic planning
- Account for conversion attribution delays (up to 7-30 days for some conversion types)
- Recent data (today, yesterday) may be incomplete due to processing delays

### Metric Selection Guidelines

Choose metrics appropriate to campaign goal:
- **Brand Awareness:** Impressions, reach, impression share, CPM
- **Traffic:** Clicks, CTR, CPC
- **Conversions:** Conversions, conversion value, ROAS, cost per conversion, conversion rate
- **Keywords:** Quality score, search impression share, top-of-page rate

Always include: cost (or cost_micros), impressions, and at least one efficiency metric (CTR, ROAS, etc.)

### GAQL Query Best Practices

1. **Always include date segments for metrics:**
   ```sql
   WHERE segments.date DURING LAST_30_DAYS
   ```

2. **Use LIMIT to prevent large responses:**
   ```sql
   LIMIT 100
   ```

3. **Request only needed fields:**
   ```sql
   SELECT campaign.id, campaign.name, metrics.clicks
   ```

4. **Use proper resource names:**
   - `campaign` (not `campaigns`)
   - `ad_group` (not `adgroup`)
   - `keyword_view` (for keyword data)
   - `search_term_view` (for search query data)

### Report Formatting Preferences

- Use tables for multi-row data with consistent columns
- Convert cost_micros to currency (divide by 1,000,000) and format with currency symbols (e.g., $1,234.56)
- Use percentage format for rates (e.g., 2.45% CTR)
- Use thousands separators for large numbers (e.g., 1,234,567)
- Round appropriately: currency to 2 decimals, percentages to 2 decimals, counts to integers
- Sort meaningfully by cost, ROAS, conversions, or most relevant metric
- Include totals, averages, and report metadata (date range, customer ID, timestamp)

### Customer ID Formatting

**CRITICAL:** Google Ads API requires customer IDs without hyphens:
- **Correct:** `1234567890`
- **Incorrect:** `123-456-7890`

When users provide customer IDs with hyphens, remove them before making API calls.

### Common Parameters

- **customer_id**: Google Ads account ID (format: 1234567890, without hyphens)
- **start_date**: YYYY-MM-DD format
- **end_date**: YYYY-MM-DD format
- **query**: GAQL query string for custom reports

### Error Handling Patterns

When errors occur:

1. **Check MCP connection** - Verify the MCP server is responsive and tools are available
2. **Validate inputs** - Ensure customer ID is formatted correctly (no hyphens), dates are YYYY-MM-DD
3. **Review permissions** - Confirm API access to the customer account
4. **Inspect error messages** - Google Ads API errors often include specific guidance
5. **Check GAQL syntax** - Verify field names, resource names, and query structure
6. **Retry with adjusted parameters** - Try shorter date ranges or simpler queries
7. **Consult troubleshooting guide** - See references/troubleshooting.md

---

## Troubleshooting

For detailed troubleshooting guidance, see **references/troubleshooting.md**.

Common quick fixes:

- **"MCP server not found"** - Verify MCP installation and configuration
- **"AUTHENTICATION_ERROR"** - Check OAuth credentials and refresh token
- **"INVALID_CUSTOMER_ID"** - Remove hyphens from customer ID (use 1234567890, not 123-456-7890)
- **"AUTHORIZATION_ERROR"** - Verify account access and developer token approval
- **"QUERY_ERROR"** - Check GAQL syntax, field names, and required fields
- **"No data available"** - Check date range and campaign activity during period
- **"Cost values wrong"** - Convert cost_micros to currency (divide by 1,000,000)

---

## Additional Resources

For more detailed information:

- **references/mcp-tools-reference.md** - Complete MCP tool documentation, parameters, GAQL examples
- **references/troubleshooting.md** - Comprehensive error solutions and debugging steps
- **references/workflows/campaign-performance.md** - Detailed campaign performance report workflow
- **references/workflows/keyword-analysis.md** - Detailed keyword analysis report workflow
- **references/workflows/ad-performance.md** - Detailed ad performance report workflow
- **references/workflows/budget-spend.md** - Detailed budget & spend report workflow

---

**Skill Version:** 1.0
**Last Updated:** 2026-01-21
**Requires:** Google Ads MCP Server (cohnen/mcp-google-ads)
