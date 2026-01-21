# Campaign Performance Report Workflow

## When to Use

Use this workflow to analyze overall campaign performance, compare campaigns across an account, identify top and bottom performers, and understand ROI across different campaign objectives.

## Required Information

- **Ad Account ID** - format: act_XXXXXXXXXXXXX
- **Date range** - or preset: today, yesterday, last_7d, last_30d, last_90d, lifetime
- **Optional:** Campaign IDs to filter specific campaigns

## Detailed Workflow

### Step 1: Fetch Campaign Data

Use the Meta Ads MCP to fetch campaign-level data for the specified account and date range.

### Step 2: Request Key Performance Metrics

Include the following metrics in your request:

**Reach & Engagement Metrics:**
- impressions - Total ad displays
- reach - Unique people who saw ads
- frequency - Average times each person saw ads
- clicks - Total clicks on ads
- ctr - Click-through rate (clicks / impressions * 100)

**Cost Metrics:**
- spend - Total amount spent
- cpc - Cost per click (spend / clicks)
- cpm - Cost per 1000 impressions (spend / impressions * 1000)
- cpp - Cost per 1000 people reached

**Conversion Metrics:**
- conversions - Total conversion events
- conversion_value - Total value of conversions
- cost_per_conversion - Average cost per conversion
- roas - Return on ad spend (conversion_value / spend)

**Campaign Details:**
- campaign_name
- campaign_id
- objective - Campaign objective type
- status - ACTIVE, PAUSED, DELETED, ARCHIVED
- daily_budget - Daily budget in cents
- lifetime_budget - Lifetime budget in cents

### Step 3: Sort and Organize

Sort campaigns by a relevant metric:
- **By spend** - To see where budget is allocated
- **By ROAS** - To identify most profitable campaigns
- **By conversions** - To see conversion leaders

### Step 4: Present in Tabular Format

Create a clear table with:
- **Column headers** for all metrics
- **Currency formatting** for spend and conversion_value (e.g., $1,234.56)
- **Percentage formatting** for CTR and ROAS (e.g., 2.45%, 3.8x)
- **Thousands separators** for large numbers (e.g., 1,234,567)
- **Date range** in the report title

**Example Table Structure:**
```
Campaign Performance Report
Date Range: [start_date] to [end_date]
Ad Account: [account_id]

| Campaign Name | Status | Spend | Impr. | Clicks | Conv. | ROAS | CTR | CPC |
|---------------|--------|-------|-------|--------|-------|------|-----|-----|
| ...           | ...    | ...   | ...   | ...    | ...   | ...  | ... | ... |
```

### Step 5: Add Summary Statistics

Calculate and display:
- **Total spend** across all campaigns
- **Average CTR** - Mean click-through rate
- **Average CPC** - Mean cost per click
- **Average ROAS** - Mean return on ad spend
- **Total conversions** - Sum of all conversions
- **Total conversion value** - Sum of all conversion values
- **Campaign count breakdown** - Number by status (active, paused, etc.)

**Example Summary:**
```
Summary:
- Total Spend: $12,345.67
- Total Conversions: 456
- Average ROAS: 3.8x
- Average CTR: 2.3%
- Active Campaigns: 8 | Paused: 3 | Completed: 2
```

### Step 6: Highlight Noteworthy Insights

Identify and call out:

**Top Performers:**
- Campaigns with highest ROAS
- Campaigns with most conversions
- Campaigns with best CTR

**Performance Issues:**
- Campaigns with declining performance (compare recent vs. earlier periods if data available)
- Campaigns spending budget but underperforming (low ROAS, high CPA)
- Campaigns with very low CTR or engagement

**Budget Concerns:**
- Campaigns approaching budget limits
- Campaigns underspending allocated budget
- Budget distribution inefficiencies

**Anomalies:**
- Unusual spikes or drops in key metrics
- Campaigns with extreme frequency values
- Significant variance in CPC across similar campaigns

**Example Insights:**
```
Key Insights:
✓ "Summer Sale 2026" is top performer with 5.2x ROAS and 42% of total conversions
✓ "Q1 Awareness" campaign has high spend ($3,200) but low ROAS (1.8x) - consider optimization
⚠ "Product Launch" campaign CTR declining from 3.1% to 1.9% over past week - possible creative fatigue
```

## Common Breakdowns

### By Date
Request daily or weekly performance to show trends over time:
- Identify performance patterns (weekday vs. weekend)
- Detect declining or improving trends
- Correlate with external events or changes

### By Campaign Objective
Group campaigns by objective type:
- OUTCOME_AWARENESS
- OUTCOME_ENGAGEMENT
- OUTCOME_LEADS
- OUTCOME_SALES
- OUTCOME_TRAFFIC

Compare performance within objective groups since different objectives have different success metrics.

### By Optimization Goal
Break down by optimization goal:
- IMPRESSIONS
- LINK_CLICKS
- CONVERSIONS
- VALUE

### By Campaign Status
Separate active, paused, and completed campaigns:
- Compare active campaign performance
- Analyze why paused campaigns were paused
- Review completed campaign results

## Best Practices

1. **Always include spend** - Essential for understanding investment and calculating efficiency
2. **Match metrics to objective** - Awareness campaigns: focus on reach/frequency; Conversion campaigns: focus on ROAS/CPA
3. **Use appropriate date ranges** - Avoid very long ranges that obscure recent trends
4. **Account for learning phase** - New campaigns (< 50 conversions) may have volatile data
5. **Provide context** - Compare to previous periods or benchmarks when possible
6. **Round appropriately** - Currency to 2 decimals, percentages to 2 decimals, counts to integers

## See Also

- **references/report-types.md** - Complete metric definitions and field descriptions
- **references/mcp-tools-reference.md** - Specific MCP tools for fetching campaign data
- **references/troubleshooting.md** - Common issues and solutions
