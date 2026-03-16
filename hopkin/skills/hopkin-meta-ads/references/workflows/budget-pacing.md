# Budget & Pacing Report Workflow

## When to Use

Use this workflow to monitor budget utilization and spending pace, forecast end-of-period spend, identify budget constraints or underspend issues, plan budget adjustments, and ensure even delivery throughout campaign duration.

## Required Information

- **Ad Account ID** — format: act_XXXXXXXXXXXXX
- **Date range** — Preferably including future dates to show remaining budget period
- **Campaign IDs or Ad Set IDs** — Objects to analyze

## Detailed Workflow

### Step 1: Fetch Budget and Campaign Data

Use `meta_ads_list_campaigns` to get campaign budget configuration and status:

```json
{
  "tool": "meta_ads_list_campaigns",
  "parameters": {
    "reason": "Getting campaign budgets and status for pacing analysis",
    "account_id": "act_123456789",
    "status": "ACTIVE"
  }
}
```

### Step 2: Fetch Daily Spend Trend

Use `meta_ads_get_insights` with `time_increment: "1"` for daily spend data:

```json
{
  "tool": "meta_ads_get_insights",
  "parameters": {
    "reason": "Getting daily spend data for budget pacing calculations",
    "account_id": "act_123456789",
    "level": "campaign",
    "time_range": {"since": "2026-01-01", "until": "2026-01-31"},
    "time_increment": "1"
  }
}
```

### Step 3: Calculate Pacing Metrics

Compute the following metrics from the raw data:

**Time Calculations:**
```
Days Elapsed = Current Date - Start Date
Days Remaining = End Date - Current Date (if end date exists)
Total Duration = End Date - Start Date (for lifetime budget campaigns)
```

**Spend Rate:**
```
Average Daily Spend = Total Spend / Days Elapsed
```

**Budget Utilization:**
```
Utilization % = (Total Spend / Total Budget) * 100
```

**Projected Spend:**
```
Projected Final Spend = Average Daily Spend * Total Duration
```

**Ideal Daily Spend:**
```
Ideal Daily Spend = Total Budget / Total Duration
```

**Pacing Status Classification:**
- **On Track:** Spending within ±10% of ideal pace
- **Ahead:** Spending >10% faster than ideal, risk of early budget exhaustion
- **Behind:** Spending >10% slower than ideal, may not fully utilize budget
- **Near End:** Less than 10% of budget or duration remaining
- **Underspending:** Active campaign spending <50% of expected pace

### Step 4: Present Budget Overview

Present as a table with columns: Campaign Name, Budget (daily or lifetime), Spend to Date, Remaining, Days Running/Left, Pacing Status.

### Step 5: Provide Detailed Pacing Analysis

For each campaign, show detailed breakdown with calculated metrics.

### Step 6: Show Daily Spend Trend

Display spend progression over time from the `meta_ads_get_insights` daily data.

### Step 6a: Visualize Budget Trends

Render a timeseries chart with daily spend data to show pacing visually:

```json
{
  "tool": "meta_ads_render_chart",
  "parameters": {
    "reason": "Showing daily spend trend for budget pacing analysis",
    "chart": {
      "type": "timeseries",
      "data": {
        "current": [
          {"date": "2026-03-01", "values": {"spend": 1250}},
          {"date": "2026-03-02", "values": {"spend": 1180}},
          {"date": "2026-03-03", "values": {"spend": 1320}}
        ]
      },
      "primaryAxis": {"field": "spend", "label": "Daily Spend ($)", "mark": "line"}
    }
  }
}
```

Use a waterfall chart to show spend contribution by campaign with CPA color encoding.

### Step 7: Provide Recommendations

**For Campaigns Pacing Ahead:**
- Reduce daily budget cap
- Adjust bid amounts downward
- Narrow audience to reduce delivery volume

**For Campaigns Pacing Behind:**
- Increase daily budget cap
- Raise bid amounts to increase competitiveness
- Expand audience targeting
- Add more ad placements
- Check delivery diagnostics for restrictions

**For Budget Reallocation:**
- Identify high-performing campaigns that could scale with more budget
- Identify low-performing campaigns to reduce or pause
- Suggest specific budget transfers

## Troubleshooting Pacing Issues

**Campaign Not Spending:**
1. Check delivery status
2. Verify audience size
3. Review bid amounts
4. Check budget caps
5. Look for account-level spending limits

**Overspending:**
1. Daily budget cap may be set too high
2. Lifetime budget pacing not properly managed
3. Multiple ad sets competing for budget

## Best Practices

1. **Compare spend to performance** — Don't just look at pacing; consider ROAS and conversion volume
2. **Account for day-of-week patterns** — Weekends may spend differently than weekdays
3. **Consider learning phase** — New campaigns may pace differently while in learning
4. **Check delivery status** — Campaigns not spending may have delivery restrictions
5. **Monitor frequently** — Check pacing at least 2-3 times per week for active campaigns
6. **Adjust proactively** — Don't wait until budget is exhausted to make changes

## See Also

- **references/report-types.md** — Budget field definitions and calculations
- **references/mcp-tools-reference.md** — Hopkin MCP tools reference
- **references/troubleshooting.md** — Common budget and delivery issues
