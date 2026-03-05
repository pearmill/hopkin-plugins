# Campaign Performance Report Workflow

## When to Use

Use this workflow to analyze overall campaign performance, compare campaigns across an account, identify top and bottom performers, and understand ROI across different campaign objectives.

## Required Information

- **Ad Account ID** — format: act_XXXXXXXXXXXXX
- **Date range** — or preset: today, yesterday, last_7d, last_30d, last_90d, lifetime
- **Optional:** Campaign IDs to filter specific campaigns

## Detailed Workflow

### Step 1: Find the Account and Fetch Campaign Performance

Use `meta_ads_list_ad_accounts` to identify the correct account (if needed), then use `meta_ads_get_performance_report` to get campaign-level performance data.

`meta_ads_get_performance_report` is the **recommended tool** for campaign performance reports because it always includes a comprehensive funnel of metrics: impressions, reach, frequency, spend, clicks, cpc, cpm, ctr, unique_clicks, actions, action_values, conversions, purchase_roas, and quality rankings.

**Example:**
```json
{
  "tool": "meta_ads_get_performance_report",
  "parameters": {
    "reason": "Generating campaign performance report for client review",
    "account_id": "act_123456789",
    "level": "campaign",
    "date_preset": "last_30d"
  }
}
```

**With custom date range:**
```json
{
  "tool": "meta_ads_get_performance_report",
  "parameters": {
    "reason": "Analyzing campaign performance for January 2026",
    "account_id": "act_123456789",
    "level": "campaign",
    "time_range": {"since": "2026-01-01", "until": "2026-01-31"}
  }
}
```

### Step 2: Key Performance Metrics

The performance report includes these metrics automatically:

**Reach & Engagement Metrics:**
- impressions — Total ad displays
- reach — Unique people who saw ads
- frequency — Average times each person saw ads
- clicks — Total clicks on ads
- ctr — Click-through rate
- unique_clicks — Number of unique clickers

**Cost Metrics:**
- spend — Total amount spent
- cpc — Cost per click
- cpm — Cost per 1000 impressions

**Conversion Metrics:**
- conversions — Total conversion events
- actions — All tracked actions
- action_values — Values of tracked actions
- purchase_roas — Return on ad spend

**Quality:**
- quality_rankings — Ad quality indicators

### Step 3: Sort and Organize

Sort campaigns by a relevant metric:
- **By spend** — To see where budget is allocated
- **By ROAS** — To identify most profitable campaigns
- **By conversions** — To see conversion leaders

### Step 4: Present in Tabular Format

Present as a table with columns: Campaign Name, Status, Spend, Impressions, Clicks, Conversions, ROAS, CTR, CPC. Use currency formatting, percentage formatting, and thousands separators.

### Step 4a: Visualize with Charts

Render a bar chart comparing campaigns by spend or ROAS:

```json
{
  "tool": "meta_ads_render_chart",
  "parameters": {
    "reason": "Comparing campaign performance by spend and ROAS",
    "chart": {
      "type": "bar",
      "data": [
        {"label": "Prospecting - LAL", "values": {"spend": 4521, "roas": 5.2}},
        {"label": "Retargeting", "values": {"spend": 1800, "roas": 8.1}},
        {"label": "Brand Awareness", "values": {"spend": 2100, "roas": 1.1}}
      ],
      "metric": {"field": "spend", "label": "Spend ($)"},
      "colorBy": {"field": "roas", "label": "ROAS"}
    }
  }
}
```

For daily trend analysis, use a timeseries chart with daily spend data from Step 3. Present charts alongside the summary table and written insights.

### Step 5: Add Summary Statistics

Calculate and display:
- **Total spend** across all campaigns
- **Average CTR** — Mean click-through rate
- **Average CPC** — Mean cost per click
- **Average ROAS** — Mean return on ad spend
- **Total conversions** — Sum of all conversions
- **Total conversion value** — Sum of all conversion values
- **Campaign count breakdown** — Number by status (active, paused, etc.)

### Step 6: Highlight Noteworthy Insights

Identify and call out:

**Top Performers:**
- Campaigns with highest ROAS
- Campaigns with most conversions
- Campaigns with best CTR

**Performance Issues:**
- Campaigns with declining performance
- Campaigns spending budget but underperforming (low ROAS, high CPA)
- Campaigns with very low CTR or engagement

**Budget Concerns:**
- Campaigns approaching budget limits
- Campaigns underspending allocated budget
- Budget distribution inefficiencies

## Common Breakdowns

### By Date
Request daily or weekly performance using `meta_ads_get_insights` with `time_increment: "1"`:

```json
{
  "tool": "meta_ads_get_insights",
  "parameters": {
    "reason": "Getting daily campaign performance trends",
    "account_id": "act_123456789",
    "level": "campaign",
    "date_preset": "last_30d",
    "time_increment": "1"
  }
}
```

### By Campaign Objective
Group campaigns by objective type when presenting results.

### By Campaign Status
Separate active, paused, and completed campaigns.

## Best Practices

1. **Always include spend** — Essential for understanding investment and calculating efficiency
2. **Match metrics to objective** — Awareness campaigns: focus on reach/frequency; Conversion campaigns: focus on ROAS/CPA
3. **Use appropriate date ranges** — Avoid very long ranges that obscure recent trends
4. **Account for learning phase** — New campaigns (< 50 conversions) may have volatile data
5. **Provide context** — Compare to previous periods or benchmarks when possible
6. **Round appropriately** — Currency to 2 decimals, percentages to 2 decimals, counts to integers

## See Also

- **references/report-types.md** — Complete metric definitions and field descriptions
- **references/mcp-tools-reference.md** — Hopkin MCP tools reference
- **references/troubleshooting.md** — Common issues and solutions
