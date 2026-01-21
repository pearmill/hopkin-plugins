# Budget & Pacing Report Workflow

## When to Use

Use this workflow to monitor budget utilization and spending pace, forecast end-of-period spend, identify budget constraints or underspend issues, plan budget adjustments, and ensure even delivery throughout campaign duration.

## Required Information

- **Ad Account ID** - format: act_XXXXXXXXXXXXX
- **Date range** - Preferably including future dates to show remaining budget period
- **Campaign IDs or Ad Set IDs** - Objects to analyze

## Detailed Workflow

### Step 1: Fetch Budget and Spend Data

Use the Meta Ads MCP to fetch campaign or ad set data including budget configuration and historical spend.

Request data at campaign level for high-level pacing or ad set level for detailed budget management.

### Step 2: Retrieve Budget Configuration and Spend

For each campaign or ad set, retrieve:

**Budget Settings:**
- daily_budget - Daily budget limit in cents (null if using lifetime budget)
- lifetime_budget - Total budget for campaign duration in cents (null if using daily budget)
- budget_remaining - Remaining budget for lifetime budget campaigns
- daily_budget_cap - Maximum daily spend for lifetime budget campaigns

**Timing:**
- start_time - Campaign/ad set start timestamp (ISO 8601)
- end_time - Campaign/ad set end timestamp (null for ongoing)
- created_time - When campaign/ad set was created
- updated_time - Last modification timestamp

**Spend Data:**
- spend - Total spend to date
- For pacing analysis: Request spend broken down by date (daily data points)

**Delivery Status:**
- status - ACTIVE, PAUSED, DELETED, ARCHIVED
- delivery_status - Current delivery state
- delivery_info - Details about delivery issues if any exist

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

OR for remaining period:
Projected Additional Spend = Average Daily Spend * Days Remaining
Projected Final Spend = Total Spend + Projected Additional Spend
```

**Ideal Daily Spend (for even pacing):**
```
Ideal Daily Spend = Total Budget / Total Duration

OR for remaining period:
Ideal Daily Spend = Budget Remaining / Days Remaining
```

**Pacing Comparison:**
```
Pacing Variance = ((Average Daily Spend - Ideal Daily Spend) / Ideal Daily Spend) * 100

Pacing Variance > +10% → Ahead of pace (may exhaust budget early)
Pacing Variance -10% to +10% → On track
Pacing Variance < -10% → Behind pace (may not use full budget)
```

**Pacing Status Classification:**
- **On Track:** Spending within ±10% of ideal pace
- **Ahead:** Spending >10% faster than ideal, risk of early budget exhaustion
- **Behind:** Spending >10% slower than ideal, may not fully utilize budget
- **Near End:** Less than 10% of budget or duration remaining
- **Complete:** Budget fully spent or campaign ended
- **Underspending:** Active campaign spending <50% of expected pace

### Step 4: Present Budget Overview

Create a summary table showing budget status:

```
Budget & Pacing Report
Ad Account: act_123456789
Report Date: 2026-01-15

| Campaign Name    | Budget    | Spend   | Remain  | Days Running | Days Left | Status     |
|------------------|-----------|---------|---------|--------------|-----------|------------|
| Summer Sale 2026 | $10,000   | $6,234  | $3,766  | 15/30 days   | 15 days   | On Track   |
| Brand Awareness  | $500/day  | $7,125  | N/A     | 15 days      | Ongoing   | Ahead      |
| Product Launch   | $5,000    | $4,892  | $108    | 28/30 days   | 2 days    | Near End   |
```

### Step 5: Provide Detailed Pacing Analysis

For each campaign, show detailed breakdown:

```
Campaign: Summer Sale 2026
├─ Budget Type: Lifetime Budget
├─ Total Budget: $10,000
├─ Spent to Date: $6,234 (62.3%)
├─ Budget Remaining: $3,766 (37.7%)
├─ Campaign Duration: Jan 1 - Jan 30 (30 days)
├─ Days Elapsed: 15 days (50%)
├─ Days Remaining: 15 days
├─ Average Daily Spend: $415.60
├─ Ideal Daily Spend: $333.33 (for even pacing)
├─ Current Pace: 12.4% ahead of ideal
├─ Projected Final Spend: $12,468 (24.7% over budget)
├─ Recommended Daily Spend: $251.07 (to stay within budget)
└─ Status: ⚠️  Pacing ahead - consider reducing spend rate
```

### Step 6: Show Daily Spend Trend

Display spend progression over time:

```
Daily Spend Trend (Summer Sale 2026):
| Date   | Daily Spend | Cumulative Spend | Budget Used |
|--------|-------------|------------------|-------------|
| Jan 11 | $423        | $4,234           | 42.3%       |
| Jan 12 | $456        | $4,690           | 46.9%       |
| Jan 13 | $412        | $5,102           | 51.0%       |
| Jan 14 | $487        | $5,589           | 55.9%       |
| Jan 15 | $645        | $6,234           | 62.3%       |
```

If possible, visualize as a simple chart or sparkline showing spend acceleration/deceleration.

### Step 7: Segment Analysis

Provide breakdown of budget allocation:

**By Status:**
```
Budget Allocation by Status:
- Active Campaigns: $15,250 (spending)
- Paused Campaigns: $3,200 (allocated but not spending)
- Total Allocated: $18,450
```

**Budget Distribution:**
```
Budget Distribution:
- Top 3 campaigns consume 67% of total budget
- 5 campaigns consuming <$100/day (may be underspending)
- 2 campaigns at risk of early exhaustion (>90% spent with >50% time remaining)
```

**Pacing Issues:**
```
Campaigns Requiring Attention:
✓ 4 campaigns on track
⚠️  2 campaigns pacing ahead (may end early)
⚠️  3 campaigns pacing behind (underutilizing budget)
```

### Step 8: Provide Recommendations

Based on pacing analysis, provide actionable recommendations:

**For Campaigns Pacing Ahead:**
- Reduce daily budget cap
- Adjust bid amounts downward
- Narrow audience to reduce delivery volume
- Consider extending campaign duration if possible

**For Campaigns Pacing Behind:**
- Increase daily budget cap
- Raise bid amounts to increase competitiveness
- Expand audience targeting
- Add more ad placements
- Check delivery diagnostics for restrictions

**For Budget Reallocation:**
- Identify high-performing campaigns that could scale with more budget
- Identify low-performing campaigns to reduce or pause
- Suggest specific budget transfers:
  ```
  Recommendations:
  ⚠️  Summer Sale 2026: Reduce daily spend to ~$251 to avoid exceeding budget
  ✓ Brand Awareness Q1: Healthy delivery, consider increasing budget if performance is strong
  ⚠️  Product Launch: Only $108 remaining for 2 days - campaign will likely end early
  💡 Reallocation Opportunity: Move $500 from "Low ROAS Campaign" to "High Performer Campaign"
  ```

**For Optimization:**
- Campaigns with strong ROAS that are underspending - opportunity to scale
- Campaigns overspending with weak ROAS - reduce or optimize
- Uneven pacing patterns - investigate cause (day-of-week, delivery issues)

## Common Views

### Daily Spend Trend Over Time

Show how spend progresses each day:
- Identifies acceleration or deceleration patterns
- Shows impact of optimization changes
- Highlights day-of-week spending patterns

### Budget Utilization by Campaign

Bar chart or table showing % of budget used for each campaign:
- Quick visual identification of over/under-spending
- Easy comparison across campaigns
- Prioritization for budget adjustments

### Forecasted Spend to End of Period

Projection showing:
- Current spend
- Projected remaining spend at current pace
- Expected final spend
- Comparison to budget

### Spend Distribution by Campaign Objective

Group budget allocation by objective type:
- How much going to awareness vs. conversion campaigns
- Whether allocation matches business priorities
- Opportunity to rebalance across objectives

## Best Practices

1. **Compare spend to performance** - Don't just look at pacing; consider ROAS and conversion volume
2. **Account for day-of-week patterns** - Weekends may spend differently than weekdays
3. **Consider learning phase** - New campaigns may pace differently while in learning
4. **Check delivery status** - Campaigns not spending may have delivery restrictions
5. **Monitor frequently** - Check pacing at least 2-3 times per week for active campaigns
6. **Adjust proactively** - Don't wait until budget is exhausted to make changes
7. **Document changes** - Track when and why budget adjustments were made

## Pacing Status Definitions

**On Track (±10%):**
- Spending aligned with budget and timeline
- No immediate action needed
- Continue monitoring

**Ahead (>10% fast):**
- Risk of early budget exhaustion
- May not reach campaign end date
- Action: Reduce daily cap or bids

**Behind (>10% slow):**
- Not utilizing available budget
- May miss opportunity
- Action: Increase bids, expand targeting, check delivery issues

**Near End (<10% remaining):**
- Campaign approaching completion
- Final optimization opportunity
- Prepare next campaign or refresh

**Underspending (<50% of expected):**
- Significant delivery issue or overly restrictive targeting
- Investigate: audience too narrow, bids too low, delivery restrictions
- Urgent action needed

## Troubleshooting Pacing Issues

**Campaign Not Spending:**
1. Check delivery status - look for "Learning Limited" or other restrictions
2. Verify audience size - ensure it's large enough
3. Review bid amounts - may be too low to compete
4. Check budget caps - daily cap may be set too low
5. Look for account-level spending limits

**Irregular Pacing:**
1. Day-of-week effects - some days naturally spend more
2. Auction competition changes - competitors' budgets may affect availability
3. Audience saturation - may have reached most of target audience
4. Creative fatigue - declining CTR reduces spend efficiency

**Overspending:**
1. Daily budget cap may be set too high or absent
2. Lifetime budget pacing not properly managed
3. Multiple ad sets within campaign competing for budget
4. Recent bid increase accelerating spend

## See Also

- **references/report-types.md** - Budget field definitions and calculations
- **references/mcp-tools-reference.md** - Specific MCP tools for budget management
- **references/troubleshooting.md** - Common budget and delivery issues
