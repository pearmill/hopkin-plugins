---
name: hopkin-google-ads
description: Generate Google Ads performance reports and analytics using the Hopkin Google Ads MCP. Includes prerequisite checks, authentication flow, report generation workflows, keyword analysis, and developer feedback for unsupported write operations.
---

# Google Ads Reports Skill

## Introduction

This skill enables Claude to build comprehensive reports and perform analysis on Google Ads campaigns via the Hopkin Google Ads MCP. Use this skill when you need to:

- Generate performance reports across campaigns, ad groups, or individual ads
- Analyze campaign metrics, ROAS, and spending patterns
- Understand keyword performance and search term opportunities
- Track budget pacing and costs
- Analyze ad creative effectiveness

The skill provides structured workflows for common Google Ads reporting tasks, with built-in best practices for data analysis and presentation.

## Prerequisites

Before using this skill, verify that the Hopkin Google Ads MCP is configured and the user is authenticated.

### Check for MCP Availability

To verify the Hopkin Google Ads MCP is available:

1. Check for `google_ads_` prefixed tools in your available tools (e.g., `google_ads_check_auth_status`, `google_ads_list_accounts`)
2. If found, the Hopkin Google Ads MCP is properly configured

### If Hopkin Google Ads MCP Is Not Installed

If no `google_ads_` prefixed tools are available:

1. **Inform the user** that the Hopkin Google Ads MCP is required to use this skill
2. **Direct them to sign up** at https://app.hopkin.ai
3. **Provide setup instructions:**

> The Hopkin Google Ads MCP is not configured. To use this skill:
>
> 1. Sign up at **https://app.hopkin.ai**
> 2. Add the hosted MCP to your Claude configuration:
>
> ```json
> {
>   "mcpServers": {
>     "hopkin-google-ads": {
>       "type": "url",
>       "url": "https://google.mcp.hopkin.ai/mcp",
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

After confirming the MCP is available, authenticate the user's Google Ads account:

1. **Check auth status:** Call `google_ads_check_auth_status` to see if the user is already authenticated
2. **If not authenticated:** Inform the user that they need to connect their Google Ads account via https://app.hopkin.ai and follow the OAuth flow there

### Quick Start with Preferences

At the start of any session, call `google_ads_get_preferences` with `entity_type: "ad_account"` and `entity_id: "global"` to check if the user has a stored default customer ID (and `login_customer_id` if applicable). If preferences are found, use them automatically without asking the user. After the user selects or confirms an account, offer to store it as a preference for future sessions using `google_ads_store_preference`.

### Required Information

Before generating reports, confirm you have:

- **Customer ID** — The Google Ads account to query (format: 1234567890, without hyphens). If the user mentions a client name, use `google_ads_list_accounts` to find their account.
- **Date Range** — Time period for data (use presets like LAST_7_DAYS, LAST_30_DAYS, or custom date range)

### Manager (MCC) Accounts

Some Google Ads users manage multiple client accounts through a Manager (MCC) account. When this is the case:

- **What `login_customer_id` is:** The MCC/manager account ID used to authenticate access to a child (client) account. It tells the API which manager account is making the request on behalf of the child account.
- **How to detect if it's needed:** If `google_ads_list_accounts` returns accounts with a `managerCustomerId` field, or if `google_ads_list_mcc_child_accounts` returns results, or if the user says they manage client accounts.
- **Which tools accept it:** `google_ads_list_campaigns`, `google_ads_list_ad_groups`, `google_ads_list_ads`, `google_ads_get_insights`, `google_ads_get_performance_report`, `google_ads_get_conversion_actions`, `google_ads_get_keyword_performance`, `google_ads_get_search_terms_report`
- **What happens without it:** Permission errors when trying to query accounts managed under an MCC. The error message will hint that `login_customer_id` is required.

## Available MCP Tools

### Authentication
- `google_ads_check_auth_status` — Check if user is authenticated; only call when another tool returns an auth error
- `google_ads_ping` — Health check; verify the MCP server is reachable

### Accounts
- `google_ads_list_accounts` — List accessible Google Ads accounts; child accounts include `managerCustomerId` indicating the MCC parent
- `google_ads_list_mcc_child_accounts` — List child accounts under a Manager (MCC) account

### Campaigns
- `google_ads_list_campaigns` — List campaigns for an account

### Ad Groups
- `google_ads_list_ad_groups` — List ad groups for a campaign or account

### Ads
- `google_ads_list_ads` — List ads for an account, campaign, or ad group

### Analytics
- `google_ads_get_performance_report` — **Recommended.** Full-funnel report with funnel metrics (impressions, clicks, cost, ROAS) plus conversion breakdown by conversion action name — runs two queries in parallel
- `google_ads_get_geo_performance` — Geographic performance breakdown by country, city, region, metro, or other geo levels. Uses `geographic_view` resource with automatic geo name resolution. Runs a parallel conversion breakdown query. **Only tool that supports geographic segments** — do not use `google_ads_get_insights` for geo data.
- `google_ads_get_insights` — Custom analytics: full control over metrics, segments, and GAQL; use when `google_ads_get_performance_report` does not cover the required custom query

### Conversion Actions
- `google_ads_get_conversion_actions` — List conversion actions by status — foundational for understanding what conversions are tracked before interpreting ROAS or conversion metrics

> **Guidance:** Before analyzing conversion metrics or ROAS for any account, call `google_ads_get_conversion_actions` to establish which conversion actions are active and which are included in the aggregate "Conversions" metric.

### Keywords
- `google_ads_get_keyword_performance` — Keyword metrics with quality scores, match type filtering, and ordering
- `google_ads_get_search_terms_report` — Search terms report with status filtering and ordering

### Visualization
- `google_ads_render_chart` — **MCP App.** Renders interactive data visualization charts. Supports bar, scatter, timeseries, funnel, waterfall, and choropleth chart types. Use after fetching data with analytics tools to present visual reports. Always render charts when presenting performance trends, campaign comparisons, or geographic data — do not substitute a table or text summary when a chart is requested.

### Preferences
- `google_ads_store_preference` — Store a persistent preference or observation for a Google Ads entity (account, campaign, ad group, or ad)
- `google_ads_get_preferences` — Retrieve all stored preferences for a Google Ads entity
- `google_ads_delete_preference` — Delete a specific stored preference by key

### Feedback
- `google_ads_developer_feedback` — Submit feature requests and workflow gap reports

> **Note:** Every tool call requires a `reason` (string) parameter for audit trail.

## Core Capabilities

This skill supports four primary report types and a developer feedback workflow for write operations.

### Report Types

1. **Geographic Performance Reports** — Location-based performance by country, city, region, metro, or other geo levels
2. **Campaign Performance Reports** — Overall campaign metrics, spending, ROAS, and performance analysis
3. **Keyword Analysis Reports** — Keyword performance, quality scores, search terms, and optimization opportunities
4. **Ad Performance Reports** — Individual ad performance, RSA analysis, and creative effectiveness
5. **Budget & Spend Reports** — Budget tracking, spend pacing, cost analysis, and forecasting

### Data Visualization

After fetching report data, proactively render charts to make insights more accessible. Use `google_ads_render_chart` to visualize data — always pair charts with a summary table and textual insights.

**When to use each chart type:**
- **Campaign/entity comparisons** → bar chart (spend, ROAS, conversions by campaign)
- **Trends over time** → timeseries chart (daily/weekly spend, CTR, conversions)
- **Conversion funnel** → funnel chart (impressions → clicks → conversions → purchases)
- **Metric correlations** → scatter chart (spend vs ROAS, CPC vs CTR)
- **Budget breakdown** → waterfall chart (spend by campaign with CPA coloring)
- **Geographic performance** → choropleth chart (US state-level spend or conversions)

Charts enhance the report — they don't replace the analysis. Always include written insights alongside visualizations.

### Write Operations (Unsupported — Developer Feedback)

The Hopkin Google Ads MCP is **read-only**. When a user requests write operations (create campaign, update budget, pause ads, etc.):

1. **Inform the user** that write operations are not yet available via Hopkin
2. **Submit a feature request** by calling `google_ads_developer_feedback` with:
   - `feedback_type: "workflow_gap"`
   - `title`: Description of the write operation requested
   - `description`: What the user was trying to do
   - `current_workaround`: How you worked around the limitation (if applicable)
   - `priority`: Based on user's urgency
3. **Provide guidance** on performing the action manually via Google Ads

### Proactive Efficiency Feedback

Whenever you complete a task and believe there should have been a faster or more efficient way to get the answer — for example, if you had to make multiple tool calls that could have been a single call, or if a dedicated tool for the workflow would have saved time — call `google_ads_developer_feedback` with:
- `feedback_type: "new_tool"` or `"improvement"`
- `title`: Brief description of the missing capability
- `description`: Explain what you were trying to accomplish, the steps you had to take, and how a new or improved tool could have made it faster
- `current_workaround`: The steps you took to work around the limitation
- `priority`: `"medium"`

This helps the Hopkin team prioritize building tools that make common workflows more efficient.

### User Feedback to Skill Developers

Users can provide feedback about this skill directly through the Hopkin Google Ads MCP. If a user wants to suggest improvements, report issues, or request new capabilities, call `google_ads_developer_feedback` on their behalf with the appropriate `feedback_type` (`new_tool`, `improvement`, `bug`, or `workflow_gap`) and include their feedback in the `description`.

## Report Workflows

### Geographic Performance Report

Analyze campaign performance across geographic locations — countries, cities, regions, metros, and more. Identify top-performing geographies, underperforming regions, and geo-targeting opportunities.

**Primary tool:** `google_ads_get_geo_performance` — dedicated tool for geographic data using the `geographic_view` resource with automatic geo name resolution

**See detailed workflow:** **references/workflows/geo-performance.md**

---

### Campaign Performance Report

Analyze overall campaign performance, compare campaigns across an account, identify top and bottom performers, understand ROAS and conversion metrics, and evaluate campaign effectiveness.

**Primary tool:** `google_ads_get_performance_report` with `level: "CAMPAIGN"` — provides full-funnel metrics plus per-conversion-action breakdowns in a single call

**See detailed workflow:** **references/workflows/campaign-performance.md**

---

### Keyword Analysis Report

Evaluate keyword performance, analyze search terms, understand quality scores, identify negative keyword opportunities, and optimize keyword bidding strategies.

**Primary tools:** `google_ads_get_keyword_performance` + `google_ads_get_search_terms_report`

**See detailed workflow:** **references/workflows/keyword-analysis.md**

---

### Ad Performance Report

Examine individual ad effectiveness, analyze RSA (Responsive Search Ad) asset performance, identify best-performing ad copy, and understand creative impact on conversions.

**Primary tools:** `google_ads_list_ads` + `google_ads_get_insights` with `level: "AD"`

**See detailed workflow:** **references/workflows/ad-performance.md**

---

### Budget & Spend Report

Monitor budget utilization and spending patterns, forecast end-of-period spend, identify budget-constrained campaigns, analyze cost efficiency, and ensure optimal budget allocation.

**Primary tools:** `google_ads_list_campaigns` for budgets + `google_ads_get_insights` with `segments: ["date"]` for daily trends

**See detailed workflow:** **references/workflows/budget-spend.md**

---

## Workflow Process

1. **Account Selection**: If no customer ID provided, use `google_ads_list_accounts` first and ask user which account to analyze
2. **Date Range**: Default to last 30 days if not specified
3. **Report Type Selection**: Determine which report type matches user intent
4. **Report Generation**: Use the appropriate Hopkin MCP tool
5. **Output Formatting**: Present data in clear tables with insights and actionable recommendations

## Best Practices

### Date Range Considerations

- **Short-term (1-7 days):** Recent changes, daily monitoring, quick checks
- **Medium-term (7-30 days):** Standard for performance evaluation, trend analysis
- **Long-term (30-90+ days):** Seasonal patterns, lifecycle analysis, strategic planning
- Account for conversion attribution delays (up to 7-30 days for some conversion types)

### Metric Selection Guidelines

Choose metrics appropriate to campaign goal:
- **Brand Awareness:** Impressions, reach, impression share, CPM
- **Traffic:** Clicks, CTR, CPC
- **Conversions:** Conversions, conversion value, ROAS, cost per conversion, conversion rate
- **Keywords:** Quality score, search impression share, top-of-page rate

### Geographic Analysis Best Practices

- **Use the dedicated tool:** Geographic segments (`geo_target_city`, `geo_target_region`, etc.) are only available on the `geographic_view` resource. Always use `google_ads_get_geo_performance` — never attempt geographic breakdowns via `google_ads_get_insights`.
- **One geo level per query:** Combining multiple geo levels (e.g., country + city) in a single query causes silent data loss in the Google Ads API. Run separate queries for each geo level.
- **Mind the location type:** Results include both `LOCATION_OF_PRESENCE` (user physically there) and `AREA_OF_INTEREST` (user searching about the location). Distinguish between these when making targeting recommendations — physical presence is more reliable for local businesses.
- **Use campaign filters for granularity:** At city/metro level, data can be sparse. Filter to a specific `campaign_id` to reduce noise and focus the analysis.
- **Limit appropriately:** Sub-country geo levels can return many rows. Use the `limit` parameter (up to 200) and note that results are ordered by cost descending by default, surfacing the highest-spend locations first.

### Customer ID Formatting

**CRITICAL:** Google Ads customer IDs must be without hyphens:
- **Correct:** `1234567890`
- **Incorrect:** `123-456-7890`

When users provide customer IDs with hyphens, remove them before making API calls.

### Report Formatting Preferences

- Use tables for multi-row data with consistent columns
- Use currency symbols for monetary values (e.g., $1,234.56)
- Use percentage format for rates (e.g., 2.45% CTR)
- Use thousands separators for large numbers (e.g., 1,234,567)
- Round appropriately: currency to 2 decimals, percentages to 2 decimals, counts to integers
- Sort meaningfully by cost, ROAS, conversions, or most relevant metric
- Include totals, averages, and report metadata (date range, customer ID, timestamp)

### Error Handling Patterns

When errors occur:

1. **Check authentication** — Run `google_ads_check_auth_status`; if not authenticated, direct the user to connect their account at https://app.hopkin.ai
2. **Validate inputs** — Ensure customer ID is 10 digits with no hyphens
3. **Inspect error messages** — Hopkin errors include specific guidance
4. **Retry with adjusted parameters** — Try shorter date ranges or simpler queries
5. **Consult troubleshooting guide** — See references/troubleshooting.md

---

## Troubleshooting

For detailed troubleshooting guidance, see **references/troubleshooting.md**.

Common quick fixes:

- **"MCP server not found"** — Verify Hopkin MCP configuration and token
- **"Not authenticated"** — Run `google_ads_check_auth_status`; direct user to connect their account at https://app.hopkin.ai
- **"Invalid customer ID"** — Remove hyphens from customer ID (use 1234567890, not 123-456-7890)
- **"Account not found"** — Verify customer ID and account access
- **"No data available"** — Check date range and campaign activity during period

---

## Additional Resources

For more detailed information:

- **references/mcp-tools-reference.md** — Complete Hopkin MCP tool documentation, parameters, and usage examples
- **references/troubleshooting.md** — Comprehensive error solutions and debugging steps
- **references/workflows/campaign-performance.md** — Detailed campaign performance report workflow
- **references/workflows/geo-performance.md** — Detailed geographic performance report workflow
- **references/workflows/keyword-analysis.md** — Detailed keyword analysis report workflow
- **references/workflows/ad-performance.md** — Detailed ad performance report workflow
- **references/workflows/budget-spend.md** — Detailed budget & spend report workflow

---

**Skill Version:** 2.2
**Last Updated:** 2026-03-05
**Requires:** Hopkin Google Ads MCP (https://app.hopkin.ai)
