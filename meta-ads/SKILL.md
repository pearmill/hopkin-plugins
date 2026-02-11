---
name: meta-ads
description: Guide for building reports and analyzing Meta Ads campaigns using the Hopkin Meta Ads MCP. Includes prerequisite checks, authentication flow, report generation workflows, and developer feedback for unsupported write operations.
---

# Meta Ads Skill

## Introduction

This skill enables Claude to build comprehensive reports and analyze Meta Ads campaigns via the Hopkin Meta Ads MCP. Use this skill when you need to:

- Generate performance reports across campaigns, ad sets, or individual ads
- Analyze campaign metrics, ROI, and spending patterns
- Understand audience demographics and behavior
- Track budget pacing and forecasting
- Preview ad creatives with performance data
- Optimize ad performance based on data insights

The skill provides structured workflows for common Meta Ads reporting tasks, with built-in best practices for data analysis and presentation.

## Prerequisites

Before using this skill, verify that the Hopkin Meta Ads MCP is configured and the user is authenticated.

### Check for MCP Availability

To verify the Hopkin Meta Ads MCP is available:

1. Check for `meta_ads_` prefixed tools in your available tools (e.g., `meta_ads_check_auth_status`, `meta_ads_list_ad_accounts`)
2. If found, the Hopkin Meta Ads MCP is properly configured

### If Hopkin Meta Ads MCP Is Not Installed

If no `meta_ads_` prefixed tools are available:

1. **Inform the user** that the Hopkin Meta Ads MCP is required to use this skill
2. **Direct them to sign up** at https://app.hopkin.ai
3. **Provide setup instructions:**

> The Hopkin Meta Ads MCP is not configured. To use this skill:
>
> 1. Sign up at **https://app.hopkin.ai**
> 2. Add the hosted MCP to your Claude configuration:
>
> ```json
> {
>   "mcpServers": {
>     "hopkin-meta-ads": {
>       "type": "url",
>       "url": "https://mcp.hopkin.ai/meta-ads/mcp",
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

After confirming the MCP is available, authenticate the user's Meta Ads account:

1. **Check auth status:** Call `meta_ads_check_auth_status` to see if the user is already authenticated
2. **If not authenticated:** Call `meta_ads_get_login_url` and present the URL to the user so they can authenticate via Meta's OAuth flow
3. **Verify identity:** Call `meta_ads_get_user_info` to confirm successful authentication

### Required Information

Before generating reports, confirm you have:

- **Ad Account ID** — The Meta Ads account to query (format: act_XXXXXXXXXXXXX). If the user mentions a client name, use `meta_ads_list_ad_accounts` to search for their account before asking for an ID.
- **Date Range** — Time period for data (or use presets like last_7d, last_30d)

## Available MCP Tools

### Authentication
- `meta_ads_ping` — Check MCP connectivity
- `meta_ads_check_auth_status` — Check if user is authenticated
- `meta_ads_get_login_url` — Get OAuth login URL for authentication
- `meta_ads_get_user_info` — Get authenticated user info

### Accounts
- `meta_ads_list_ad_accounts` — List accessible ad accounts
- `meta_ads_get_ad_account` — Get details for a specific account

### Campaigns
- `meta_ads_list_campaigns` — List campaigns for an account
- `meta_ads_get_campaign` — Get details for a specific campaign

### Ad Sets
- `meta_ads_list_adsets` — List ad sets for an account or campaign
- `meta_ads_get_adset` — Get details for a specific ad set

### Ads
- `meta_ads_list_ads` — List ads for an account, campaign, or ad set
- `meta_ads_get_ad` — Get details for a specific ad

### Analytics
- `meta_ads_get_performance_report` — **Recommended.** Full-funnel performance report (always includes impressions, reach, frequency, spend, clicks, cpc, cpm, ctr, unique_clicks, actions, action_values, conversions, purchase_roas, quality rankings)
- `meta_ads_get_insights` — Flexible insights with custom breakdowns and metrics

### Creative
- `meta_ads_preview_ads` — Preview actual ad creatives with metrics overlay

### Feedback
- `meta_ads_developer_feedback` — Submit feature requests and workflow gap reports

> **Note:** Every tool call requires a `reason` (string) parameter for audit trail.

## Core Capabilities

This skill supports four primary report types and a developer feedback workflow for write operations.

### Report Types

1. **Campaign Performance Reports** — Overall campaign metrics, spending, and ROI analysis
2. **Ad Creative Performance Reports** — Individual ad performance, creative previews, and A/B testing insights
3. **Audience Insights Reports** — Demographics, interests, and behavior breakdowns
4. **Budget & Pacing Reports** — Budget tracking, spend pacing, and forecasting

### Write Operations (Unsupported — Developer Feedback)

The Hopkin Meta Ads MCP is **read-only**. When a user requests write operations (create campaign, update budget, pause ads, etc.):

1. **Inform the user** that write operations are not yet available via Hopkin
2. **Submit a feature request** by calling `meta_ads_developer_feedback` with:
   - `feedback_type: "workflow_gap"`
   - `title`: Description of the write operation requested
   - `description`: What the user was trying to do
   - `priority`: Based on user's urgency
3. **Provide guidance** on performing the action manually via Meta Ads Manager

### Proactive Efficiency Feedback

Whenever you complete a task and believe there should have been a faster or more efficient way to get the answer — for example, if you had to make multiple tool calls that could have been a single call, or if a dedicated tool for the workflow would have saved time — call `meta_ads_developer_feedback` with:
- `feedback_type: "feature_request"`
- `title`: Brief description of the missing capability
- `description`: Explain what you were trying to accomplish, the steps you had to take, and how a new or improved tool could have made it faster
- `priority`: `"medium"`

This helps the Hopkin team prioritize building tools that make common workflows more efficient.

## Report Workflows

### Campaign Performance Report

Analyze overall campaign performance, compare campaigns across an account, identify top and bottom performers, and understand ROI across different campaign objectives.

**Primary tool:** `meta_ads_get_performance_report` with `level: "campaign"`

**See detailed workflow:** **references/workflows/campaign-performance.md**

---

### Ad Creative Performance Report

Evaluate individual ad creative effectiveness, conduct A/B testing analysis, identify best-performing ad formats, and preview actual ad creatives with performance data.

**Primary tools:** `meta_ads_get_performance_report` with `level: "ad"` + `meta_ads_preview_ads`

**See detailed workflow:** **references/workflows/ad-creative-performance.md**

---

### Audience Insights Report

Understand who engages with your ads, analyze demographic performance, discover high-value audience segments, optimize targeting strategies, and inform creative direction.

**Primary tool:** `meta_ads_get_insights` with breakdowns (e.g., `["age", "gender"]`)

**See detailed workflow:** **references/workflows/audience-insights.md**

---

### Budget & Pacing Report

Monitor budget utilization and spending pace, forecast end-of-period spend, identify budget constraints or underspend issues, and ensure even delivery throughout campaign duration.

**Primary tools:** `meta_ads_list_campaigns` for budgets + `meta_ads_get_insights` with `time_increment: "1"` for daily trends

**See detailed workflow:** **references/workflows/budget-pacing.md**

---

## Unsupported Write Operations

The Hopkin Meta Ads MCP does not support create, update, or delete operations. When users request these actions, follow the developer feedback workflow.

**See detailed workflow:** **references/workflows/common-actions.md**

### Performance Optimization

Provide actionable optimization recommendations based on performance analysis:

- **Low ROAS:** Review targeting, analyze creative, adjust bid strategy, examine conversion funnel
- **High CPC:** Improve ad relevance, refine audience, test placements, review landing page
- **Low CTR:** Test creative hooks, improve visuals, refine targeting, strengthen CTA
- **Underspending:** Expand audience, increase bids, add placements, check delivery diagnostics
- **Creative Fatigue:** Rotate fresh creative, test new formats, adjust messaging, expand audience

**See detailed workflow:** **references/workflows/common-actions.md#performance-optimization-recommendations**

---

## Best Practices

### Date Range Considerations

- **Short-term (1-7 days):** Daily monitoring, recent changes, quick checks
- **Medium-term (7-30 days):** Standard for performance evaluation, trend analysis
- **Long-term (30-90+ days):** Seasonal patterns, lifecycle analysis, strategic planning
- Avoid excessive ranges that obscure recent trends
- Account for learning phase (~50 conversions needed)

### Metric Selection Guidelines

Choose metrics appropriate to campaign objective:
- **Awareness:** Impressions, reach, frequency, CPM
- **Engagement:** Likes, comments, shares, engagement rate
- **Traffic:** Clicks, CTR, CPC, landing page views
- **Conversion:** Conversions, conversion value, ROAS, cost per conversion

Always include: spend, impressions/reach, and at least one efficiency metric.

### Report Formatting Preferences

- Use tables for multi-row data with consistent columns
- Use currency symbols for monetary values (e.g., $1,234.56)
- Use percentage format for rates (e.g., 2.45% CTR, not 0.0245)
- Use thousands separators for large numbers (e.g., 1,234,567)
- Round appropriately: currency to 2 decimals, percentages to 2 decimals, counts to integers
- Sort meaningfully by spend, ROAS, or most relevant metric
- Include totals, averages, and report metadata (date range, account, timestamp)

### Error Handling Patterns

When errors occur:

1. **Check authentication** — Run `meta_ads_check_auth_status`; if not authenticated, use `meta_ads_get_login_url`
2. **Validate inputs** — Ensure Ad Account ID starts with "act_", date ranges are valid
3. **Inspect error messages** — Hopkin errors include specific guidance
4. **Retry with adjusted parameters** — Try smaller date ranges or fewer breakdowns
5. **Consult troubleshooting guide** — See references/troubleshooting.md

---

## Troubleshooting

For detailed troubleshooting guidance, see **references/troubleshooting.md**.

Common quick fixes:

- **"MCP server not found"** — Verify Hopkin MCP configuration and token
- **"Not authenticated"** — Run auth flow: `meta_ads_check_auth_status` → `meta_ads_get_login_url`
- **"Account not found"** — Verify Ad Account ID format (starts with "act_")
- **"Rate limit exceeded"** — Wait and retry; reduce request frequency
- **"No data available"** — Check date range and campaign activity during period

---

## Additional Resources

For more detailed information:

- **references/report-types.md** — Complete metric definitions, breakdown options, field descriptions
- **references/mcp-tools-reference.md** — Specific Hopkin MCP tools, parameters, and usage examples
- **references/troubleshooting.md** — Comprehensive error solutions and debugging steps
- **references/workflows/campaign-performance.md** — Detailed campaign performance report workflow
- **references/workflows/ad-creative-performance.md** — Detailed ad creative report workflow
- **references/workflows/audience-insights.md** — Detailed audience insights report workflow
- **references/workflows/budget-pacing.md** — Detailed budget & pacing report workflow
- **references/workflows/common-actions.md** — Write operation feedback and optimization workflows

---

**Skill Version:** 2.0
**Last Updated:** 2026-02-10
**Requires:** Hopkin Meta Ads MCP (https://app.hopkin.ai)
