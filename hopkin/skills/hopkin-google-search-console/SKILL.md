---
name: hopkin-google-search-console
description: Analyze Google Search Console data using the Hopkin Google Search Console MCP. Includes search analytics, top queries, performance comparisons, URL inspection, site management, and SEO opportunity identification.
---

# Google Search Console Skill

## Introduction

This skill enables Claude to analyze Google Search Console data via the Hopkin Google Search Console MCP. Use this skill when you need to:

- Query search analytics (clicks, impressions, CTR, position) across queries, pages, devices, and countries
- Identify top-performing and high-opportunity search queries
- Compare search performance across time periods (period-over-period)
- Get a complete performance overview with trends
- Inspect URL indexing and crawl status
- Review sitemaps and site properties

The skill provides structured workflows for common SEO analysis tasks, with built-in best practices for data interpretation and presentation.

## Prerequisites

Before using this skill, verify that the Hopkin Google Search Console MCP is configured and the user is authenticated.

### Check for MCP Availability

To verify the Hopkin Google Search Console MCP is available:

1. Check for `google_search_console_` prefixed tools in your available tools (e.g., `google_search_console_check_auth_status`, `google_search_console_list_sites`)
2. If found, the Hopkin Google Search Console MCP is properly configured

### If Hopkin Google Search Console MCP Is Not Installed

If no `google_search_console_` prefixed tools are available:

1. **Inform the user** that the Hopkin Google Search Console MCP is required to use this skill
2. **Direct them to sign up** at https://app.hopkin.ai
3. **Provide setup instructions:**

> The Hopkin Google Search Console MCP is not configured. To use this skill:
>
> 1. Sign up at **https://app.hopkin.ai**
> 2. Add the hosted MCP to your Claude configuration:
>
> ```json
> {
>   "mcpServers": {
>     "hopkin-google-search-console": {
>       "type": "url",
>       "url": "https://gcs.mcp.hopkin.ai/mcp",
>       "headers": {
>         "Authorization": "Bearer YOUR_HOPKIN_TOKEN"
>       }
>     }
>   }
> }
> ```
>
> 3. Restart Claude after updating configuration

4. **Pause execution** until the user confirms MCP installation is complete
5. **Re-verify** MCP availability after user confirmation

### Authentication Flow

After confirming the MCP is available, authenticate the user's Google Search Console account:

1. **Check auth status:** Call `google_search_console_check_auth_status` to see if the user is already authenticated
2. **If not authenticated:** Inform the user that they need to connect their Google Search Console account via https://app.hopkin.ai and follow the OAuth flow there

### Quick Start with Preferences

At the start of any session, call `google_search_console_get_preferences` with `entity_type: "site"` and `entity_id: "global"` to check if the user has a stored default site URL. If preferences are found, use them automatically without asking the user. After the user selects or confirms a site, offer to store it as a preference for future sessions using `google_search_console_store_preference`.

### Required Information

Before generating reports, confirm you have:

- **Site URL** — The Search Console property to query (e.g., `https://example.com/` or `sc-domain:example.com`). Use `google_search_console_list_sites` to find available properties.
- **Date Range** — Time period for data. Note that Search Console data has a 2-3 day lag; recent dates may be incomplete.

## Available MCP Tools

For complete tool documentation with all parameters, see **references/mcp-tools-reference.md**.

All 12 tools use the `google_search_console_` prefix.

### Authentication
- `google_search_console_ping` — Health check; verify the MCP server is reachable
- `google_search_console_check_auth_status` — Check if user is authenticated; only call when another tool returns an auth error

### Sites
- `google_search_console_list_sites` — List all Search Console properties the user has access to, with permission levels

### Sitemaps
- `google_search_console_list_sitemaps` — List sitemaps submitted to a Search Console property with status and error counts

### Analytics
- `google_search_console_get_search_analytics` — **Flexible query tool.** Full control over dimensions, filters, date ranges, search types, and aggregation. Use for custom analytics queries.
- `google_search_console_get_top_queries` — **Recommended for query analysis.** Returns top queries with auto-identified high-opportunity queries (position 4-20, impressions >100, CTR <5%).
- `google_search_console_compare_performance` — **Period-over-period comparison.** Compares current vs previous period with delta calculations and trend classification.
- `google_search_console_get_performance_overview` — **Complete overview.** Returns overall metrics, top queries, top pages, and daily trend in a single call (4 parallel API calls).

### URL Inspection
- `google_search_console_inspect_url` — Get detailed indexing, crawl, and canonical status for a specific URL. Quota: 2000 calls/day per property.

### Preferences
- `google_search_console_store_preference` — Store a persistent preference or observation for a Search Console entity
- `google_search_console_get_preferences` — Retrieve all stored preferences for an entity
- `google_search_console_delete_preference` — Delete a specific stored preference by key

### Feedback
- `google_search_console_developer_feedback` — Submit feature requests and workflow gap reports

## Core Capabilities

This skill supports five primary analysis types and a developer feedback workflow.

### Analysis Types

1. **Search Analytics Reports** — Flexible queries across any combination of dimensions (query, page, device, country, date, searchAppearance) with filtering and pagination
2. **Top Queries Analysis** — Identify best-performing queries and auto-detect high-opportunity queries ripe for optimization
3. **Performance Comparison** — Period-over-period analysis with trend detection (improving, stable, declining)
4. **Performance Overview** — Comprehensive site health dashboard with top queries, top pages, and daily trends
5. **URL Inspection** — Deep-dive into indexing status, crawl details, canonical URLs, and robots.txt state for individual URLs

### Data Visualization

Search Console data lends itself well to tables and trend analysis. Present data with:
- Sorted tables for top queries and pages
- Trend indicators for period-over-period changes
- Highlight high-opportunity queries prominently
- Use sparkline-style descriptions for daily trends when appropriate

### Write Operations (Unsupported — Developer Feedback)

The Hopkin Google Search Console MCP is **read-only**. When a user requests write operations (submit URL for indexing, add sitemap, request removal, etc.):

1. **Inform the user** that write operations are not yet available via Hopkin
2. **Submit a feature request** by calling `google_search_console_developer_feedback` with:
   - `feedback_type: "workflow_gap"`
   - `title`: Description of the write operation requested
   - `description`: What the user was trying to do
   - `current_workaround`: How you worked around the limitation (if applicable)
   - `priority`: Based on user's urgency
3. **Provide guidance** on performing the action manually via Google Search Console

### Proactive Efficiency Feedback

Whenever you complete a task and believe there should have been a faster or more efficient way to get the answer — for example, if you had to make multiple tool calls that could have been a single call, or if a dedicated tool for the workflow would have saved time — call `google_search_console_developer_feedback` with:
- `feedback_type: "new_tool"` or `"improvement"`
- `title`: Brief description of the missing capability
- `description`: Explain what you were trying to accomplish, the steps you had to take, and how a new or improved tool could have made it faster
- `current_workaround`: The steps you took to work around the limitation
- `priority`: `"medium"`

### User Feedback to Skill Developers

Users can provide feedback about this skill directly through the Hopkin Google Search Console MCP. If a user wants to suggest improvements, report issues, or request new capabilities, call `google_search_console_developer_feedback` on their behalf with the appropriate `feedback_type` (`new_tool`, `improvement`, `bug`, or `workflow_gap`) and include their feedback in the `description`.

## Report Workflows

### Search Analytics Report

Query search analytics data with flexible dimensions and filters. Analyze performance by query, page, device, country, date, or search appearance.

**Primary tool:** `google_search_console_get_search_analytics` — full control over dimensions, filters, search type, aggregation, and pagination

**See detailed workflow:** **references/workflows/search-analytics.md**

---

### Top Queries Report

Identify the best-performing search queries and discover high-opportunity queries that could benefit from SEO optimization.

**Primary tool:** `google_search_console_get_top_queries` — returns ranked queries with automatic high-opportunity detection

**See detailed workflow:** **references/workflows/top-queries.md**

---

### Performance Comparison Report

Compare search performance across two adjacent time periods to identify trends, improvements, and regressions.

**Primary tool:** `google_search_console_compare_performance` — period-over-period analysis with delta calculations

**See detailed workflow:** **references/workflows/performance-comparison.md**

---

### URL Inspection Report

Get detailed indexing, crawl, and canonical status for specific URLs. Diagnose why pages aren't appearing in search results.

**Primary tool:** `google_search_console_inspect_url` — returns verdict, coverage state, crawl details, and canonical information

**See detailed workflow:** **references/workflows/url-inspection.md**

---

## Workflow Process

1. **Site Selection**: If no site URL provided, use `google_search_console_list_sites` first and ask the user which property to analyze
2. **Date Range**: Default to last 28 days if not specified. Account for the 2-3 day data lag.
3. **Analysis Type Selection**: Determine which analysis matches user intent
4. **Data Retrieval**: Use the appropriate Hopkin MCP tool
5. **Output Formatting**: Present data in clear tables with insights and actionable SEO recommendations

## Best Practices

### Data Freshness

- **Search Console data has a 2-3 day lag.** The most recent 3 days may be incomplete.
- Check the `firstIncompleteDate` field in analytics responses to know which dates have partial data.
- For accurate trend analysis, exclude incomplete dates or caveat them clearly.
- The `compare_performance` tool automatically applies a 3-day offset by default.

### Date Range Considerations

- **Short-term (1-7 days):** Quick pulse checks, recent content performance
- **Medium-term (7-28 days):** Standard for SEO performance evaluation
- **Long-term (28-90 days):** Seasonal patterns, algorithm update impact, strategic analysis
- Search Console retains up to 16 months of data, but the API limits queries to 90 days per request

### Dimension Combinations

- `searchAppearance` dimension **cannot** be combined with `query`, `page`, `device`, or `country` — it can only be combined with `date`
- Common useful combinations: `[query, page]`, `[query, device]`, `[page, country]`, `[query, date]`
- More dimensions = more granular data but potentially more rows

### Search Type Selection

- **web** (default) — Standard web search results
- **image** — Google Images results
- **video** — Video search results
- **news** — Google News results
- **discover** — Google Discover feed
- **googleNews** — Google News app/site

### Interpreting Metrics

- **Position** — Average position in search results (1 = top). Lower is better.
- **CTR** — Click-through rate. Varies significantly by position (position 1 averages ~28%, position 10 averages ~2.5%)
- **Impressions** — How often your site appeared in results. High impressions + low clicks = opportunity
- **Clicks** — Actual visits from search results

### High-Opportunity Query Identification

The `get_top_queries` tool automatically flags queries with:
- Position 4-20 (appearing on page 1-2 but not top 3)
- Impressions > 100 (meaningful search volume)
- CTR < 5% (underperforming click-through)

These are the best candidates for SEO optimization — they already rank but could climb higher with improved content, titles, or meta descriptions.

### Site URL Formatting

Search Console properties come in two formats:
- **URL prefix:** `https://example.com/` (must include trailing slash and protocol)
- **Domain property:** `sc-domain:example.com` (covers all subdomains and protocols)

Use `google_search_console_list_sites` to get the exact property URL format.

### Report Formatting Preferences

- Use tables for multi-row data with consistent columns
- Use percentage format for CTR (e.g., 3.45%)
- Round position to 1 decimal (e.g., 4.2)
- Use thousands separators for large impression/click counts (e.g., 12,345)
- Sort by clicks descending for top queries/pages, or by impressions for opportunity analysis
- Include date range and site URL in report metadata
- Highlight high-opportunity queries with a distinct marker or separate section

### Error Handling Patterns

When errors occur:

1. **Check authentication** — Run `google_search_console_check_auth_status`; if not authenticated, direct the user to connect their account at https://app.hopkin.ai
2. **Validate site URL** — Ensure the property URL matches exactly (including protocol and trailing slash)
3. **Inspect error messages** — Hopkin errors include specific guidance
4. **Check date range** — Ensure start_date <= end_date, and dates are not in the future
5. **Consult troubleshooting guide** — See references/troubleshooting.md

---

## Troubleshooting

For detailed troubleshooting guidance, see **references/troubleshooting.md**.

Common quick fixes:

- **"MCP server not found"** — Verify Hopkin MCP configuration and token
- **"Not authenticated"** — Run `google_search_console_check_auth_status`; direct user to connect their account at https://app.hopkin.ai
- **"Site not found"** — Verify property URL with `google_search_console_list_sites`; check exact format
- **"No data available"** — Check date range; recent dates (last 3 days) may be incomplete
- **"Invalid dimension combination"** — `searchAppearance` cannot be combined with query, page, device, or country

---

## Additional Resources

For more detailed information:

- **references/mcp-tools-reference.md** — Complete Hopkin MCP tool documentation, parameters, and usage examples
- **references/troubleshooting.md** — Comprehensive error solutions and debugging steps
- **references/workflows/search-analytics.md** — Detailed search analytics workflow
- **references/workflows/top-queries.md** — Detailed top queries analysis workflow
- **references/workflows/performance-comparison.md** — Detailed performance comparison workflow
- **references/workflows/url-inspection.md** — Detailed URL inspection workflow

---

**Skill Version:** 1.0
**Last Updated:** 2026-04-17
**Requires:** Hopkin Google Search Console MCP (https://app.hopkin.ai)
