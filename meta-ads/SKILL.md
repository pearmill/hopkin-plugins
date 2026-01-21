---
name: meta-ads
description: Guide for building reports and performing actions on Meta Ads using the Meta Ads MCP server. Includes prerequisite checks, report generation workflows, and campaign management operations.
---

# Meta Ads Skill

## Introduction

This skill enables Claude to build comprehensive reports and perform actions on Meta Ads campaigns. Use this skill when you need to:

- Generate performance reports across campaigns, ad sets, or individual ads
- Analyze campaign metrics, ROI, and spending patterns
- Understand audience demographics and behavior
- Track budget pacing and forecasting
- Manage campaign operations (create, update, pause/resume)
- Optimize ad performance based on data insights

The skill provides structured workflows for common Meta Ads reporting and management tasks, with built-in best practices for data analysis and presentation.

## Prerequisites

Before using this skill, verify that the Meta Ads MCP server is installed and configured.

### Check for MCP Availability

To verify the Meta Ads MCP server is available:

1. List available MCP servers in the current environment
2. Confirm that a Meta Ads MCP server is present (common names: "pipeboard-meta-ads", "meta-ads", "facebook-ads", "meta-advertising")
3. Test the connection by attempting to list available tools from the MCP server

### If Meta Ads MCP Is Not Installed

If the Meta Ads MCP server is not available:

1. **Inform the user** that the Meta Ads MCP server is required to use this skill
2. **Guide the user** to install and configure recommended MCP server
3. **Provide setup instructions**
4. **Pause execution** until the user confirms MCP installation is complete
5. **Re-verify** MCP availability after user confirmation

### Required Information

Before generating reports or performing actions, confirm you have:

- **Ad Account ID** - The Meta Ads account to query (format: act_XXXXXXXXXXXXX). If the user mentions a client name, search for their ad account by name first before asking the user to provide search terms.
- **Date Range** - Time period for data (or use presets like last_7d, last_30d)
- **Access Permissions** - Verify the MCP has appropriate read/write permissions

## Core Capabilities

This skill supports four primary report types and various campaign management operations.

### Report Types

1. **Campaign Performance Reports** - Overall campaign metrics, spending, and ROI analysis
2. **Ad Creative Performance Reports** - Individual ad performance and A/B testing insights
3. **Audience Insights Reports** - Demographics, interests, and behavior breakdowns
4. **Budget & Pacing Reports** - Budget tracking, spend pacing, and forecasting

### Management Operations

- Create new campaigns, ad sets, and ads
- Update campaign budgets and bid strategies
- Pause, resume, or archive campaigns and ads
- Modify targeting parameters
- Optimize performance based on insights

## Report Workflows

### Campaign Performance Report

Analyze overall campaign performance, compare campaigns across an account, identify top and bottom performers, and understand ROI across different campaign objectives.

**See detailed workflow:** **references/workflows/campaign-performance.md**

---

### Ad Creative Performance Report

Evaluate individual ad creative effectiveness, conduct A/B testing analysis, identify best-performing ad formats, and understand which creative elements drive engagement and conversions.

**See detailed workflow:** **references/workflows/ad-creative-performance.md**

---

### Audience Insights Report

Understand who engages with your ads, analyze demographic performance, discover high-value audience segments, optimize targeting strategies, and inform creative direction.

**See detailed workflow:** **references/workflows/audience-insights.md**

---

### Budget & Pacing Report

Monitor budget utilization and spending pace, forecast end-of-period spend, identify budget constraints or underspend issues, and ensure even delivery throughout campaign duration.

**See detailed workflow:** **references/workflows/budget-pacing.md**

---

## Common Actions

Beyond reporting, this skill supports campaign management operations through the Meta Ads MCP server.

### Creating Campaigns

Create new campaigns with proper configuration including name, objective, special ad categories, and initial status.

**See detailed workflow:** **references/workflows/common-actions.md#creating-campaigns**

### Updating Budgets

Modify campaign or ad set budgets (daily or lifetime) based on performance or business needs.

**See detailed workflow:** **references/workflows/common-actions.md#updating-budgets**

### Pausing and Resuming Ads

Temporarily stop or restart ad delivery for campaigns, ad sets, or individual ads.

**See detailed workflow:** **references/workflows/common-actions.md#pausing-and-resuming-ads**

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

1. **Check MCP connection** - Verify the MCP server is responsive
2. **Validate inputs** - Ensure Ad Account ID, date ranges, and IDs are correctly formatted
3. **Review permissions** - Confirm MCP has necessary access rights
4. **Inspect error messages** - Meta API errors often include specific guidance
5. **Retry with adjusted parameters** - Try smaller date ranges or fewer breakdowns
6. **Consult troubleshooting guide** - See references/troubleshooting.md

---

## Troubleshooting

For detailed troubleshooting guidance, see **references/troubleshooting.md**.

Common quick fixes:

- **"MCP server not found"** - Verify MCP installation and configuration
- **"Invalid access token"** - Token may be expired; regenerate from Meta Business Suite
- **"Insufficient permissions"** - MCP needs appropriate scopes
- **"Account not found"** - Verify Ad Account ID format (starts with "act_")
- **"Rate limit exceeded"** - Wait and retry; reduce request frequency
- **"No data available"** - Check date range and campaign activity during period

---

## Additional Resources

For more detailed information:

- **references/report-types.md** - Complete metric definitions, breakdown options, field descriptions
- **references/mcp-tools-reference.md** - Specific MCP server tools, parameters, and usage examples
- **references/troubleshooting.md** - Comprehensive error solutions and debugging steps
- **references/workflows/campaign-performance.md** - Detailed campaign performance report workflow
- **references/workflows/ad-creative-performance.md** - Detailed ad creative report workflow
- **references/workflows/audience-insights.md** - Detailed audience insights report workflow
- **references/workflows/budget-pacing.md** - Detailed budget & pacing report workflow
- **references/workflows/common-actions.md** - Detailed management action workflows

---

**Skill Version:** 1.0
**Last Updated:** 2026-01-19
**Requires:** Meta Ads MCP Server
