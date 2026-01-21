---
name: google-ads
description: Generate Google Ads performance reports and analytics
---

# Google Ads Reports Skill

## MCP Availability Check

First, verify the Google Ads MCP is installed by checking for the `list_accounts` tool in your available tools.

**If the MCP tools are NOT available**, inform the user:

> The Google Ads MCP is not configured. To use this skill, install the MCP server:
>
> **Repository**: https://github.com/cohnen/mcp-google-ads
>
> Follow the setup instructions to configure your Google Ads API credentials and add the MCP to your Claude configuration.

**If the MCP tools ARE available**, proceed with the user's request.

## Available MCP Tools

- `list_accounts` - List all accessible Google Ads accounts
- `get_campaign_performance` - Get campaign metrics for an account and time period
- `get_ad_performance` - Analyze ad creative performance
- `execute_gaql_query` / `run_gaql` - Execute custom GAQL (Google Ads Query Language) queries

## Report Types

Route to the appropriate reference based on user intent:

| User Intent | Reference File |
|-------------|----------------|
| Campaign metrics, performance overview, ROAS | `campaign-performance.md` |
| Keywords, search terms, quality score | `keyword-analysis.md` |
| Ad copy, RSA assets, creative effectiveness | `ad-performance.md` |
| Budget, spend, pacing, costs | `budget-spend.md` |

## Quick Start Examples

### List All Accounts
```
Use the list_accounts tool to show all accessible Google Ads accounts.
```

### Campaign Performance (Last 30 Days)
```
Use get_campaign_performance with:
- customer_id: [account ID]
- start_date: [30 days ago in YYYY-MM-DD]
- end_date: [today in YYYY-MM-DD]
```

### Custom GAQL Query
```
Use run_gaql or execute_gaql_query with:
- customer_id: [account ID]
- query: [GAQL query string]
```

## Workflow

1. **Account Selection**: If no account ID provided, use `list_accounts` first and ask user which account to analyze
2. **Date Range**: Default to last 30 days if not specified
3. **Report Generation**: Use the appropriate tool or GAQL query
4. **Output Formatting**: Present data in clear tables with insights and recommendations

## Common Parameters

- **customer_id**: Google Ads account ID (format: 123-456-7890 or 1234567890)
- **start_date**: YYYY-MM-DD format
- **end_date**: YYYY-MM-DD format
- **query**: GAQL query string for custom reports
