# Budget & Spend Report Workflow

## When to Use

Use this workflow to monitor LinkedIn Ads budget utilization and spending pace, forecast end-of-period spend, identify budget-constrained or underspending campaigns, analyze cost efficiency trends, and get bid range recommendations for campaign planning.

## Required Information

- **Ad Account ID** — Numeric (e.g., `123456789`)
- **Date range** — Current billing period or month is most common
- **Optional:** Campaign group IDs to focus on specific groups

## Detailed Workflow

### Step 1: Get Campaign Group Budget Configuration

Use `linkedin_ads_list_campaign_groups` to get budget and schedule information:

```json
{
  "tool": "linkedin_ads_list_campaign_groups",
  "parameters": {
    "reason": "Getting budget configuration for all active campaign groups",
    "account_id": 123456789,
    "status": ["ACTIVE"]
  }
}
```

This returns budget type, daily budget, total budget, start/end dates, and current status for each campaign group.

### Step 2: Get Daily Spend Trend

Use `linkedin_ads_get_insights` with `time_granularity: "DAILY"` for day-by-day spend data:

```json
{
  "tool": "linkedin_ads_get_insights",
  "parameters": {
    "reason": "Getting daily spend trend for budget pacing analysis",
    "account_id": 123456789,
    "pivot": "ACCOUNT",
    "date_preset": "THIS_MONTH",
    "time_granularity": "DAILY"
  }
}
```

**For campaign-group-level daily breakdown:**
```json
{
  "tool": "linkedin_ads_get_performance_report",
  "parameters": {
    "reason": "Daily spend per campaign group for pacing analysis",
    "account_id": 123456789,
    "pivots": ["CAMPAIGN_GROUP"],
    "date_preset": "THIS_MONTH",
    "time_granularity": "DAILY"
  }
}
```

### Step 3: Get Account Summary

Use `linkedin_ads_get_account_summary` for a snapshot of current period performance:

```json
{
  "tool": "linkedin_ads_get_account_summary",
  "parameters": {
    "reason": "Getting account-level spend summary for the current month",
    "account_id": 123456789,
    "date_preset": "THIS_MONTH"
  }
}
```

### Step 4: Calculate Pacing Metrics

Using the daily spend data, calculate budget pacing:

```
Days in Month: 31
Days Elapsed: 12
Days Remaining: 19

Total Monthly Budget: $30,000
Ideal Daily Rate: $30,000 / 31 = $967.74/day
Actual Spend to Date: $13,500

Ideal Spend to Date: $967.74 × 12 = $11,613
Actual Spend to Date: $13,500

Pacing %: ($13,500 / $11,613) × 100 = 116%  → Overpacing (spending 16% ahead of pace)

Projected Month-End Spend:
  Average daily spend: $13,500 / 12 = $1,125
  Projected total: $1,125 × 31 = $34,875  → Will overspend by ~$4,875
```

**Pacing interpretation:**
- **< 85%:** Underpacing — campaigns may not spend budget; review bids, targeting, or daily caps
- **85%–115%:** On track — healthy pacing within normal variance
- **> 115%:** Overpacing — will exceed budget before month end; consider reducing daily caps

### Step 5: Get Bid Range Recommendations (Optional)

For new campaigns or budget planning, use `linkedin_ads_get_budget_pricing` to understand recommended bids:

```json
{
  "tool": "linkedin_ads_get_budget_pricing",
  "parameters": {
    "reason": "Getting recommended CPC bid range for new Sponsored Content campaign targeting US professionals",
    "account_id": 123456789,
    "campaign_type": "SPONSORED_UPDATES",
    "bid_type": "CPC",
    "currency": "USD",
    "location_urns": ["urn:li:geo:103644278"],
    "daily_budget_amount": 150
  }
}
```

This returns recommended minimum and maximum bid amounts for the specified audience and budget. LinkedIn bids are typically $2–$15+ CPC depending on audience, with more competitive/senior audiences commanding higher bids.

**With audience targeting parameters:**
```json
{
  "tool": "linkedin_ads_get_budget_pricing",
  "parameters": {
    "reason": "Bid ranges for Director+ level targeting in the US tech industry",
    "account_id": 123456789,
    "campaign_type": "SPONSORED_UPDATES",
    "bid_type": "CPC",
    "currency": "USD",
    "location_urns": ["urn:li:geo:103644278"],
    "seniority_urns": ["urn:li:seniority:7", "urn:li:seniority:8"],
    "industry_urns": ["urn:li:industry:96"],
    "daily_budget_amount": 200
  }
}
```

### Step 6: Present Budget Report

**Example Report Structure:**
```
LinkedIn Ads Budget & Pacing Report
Ad Account: 123456789
Report Date: March 2, 2026
Period: March 2026 (1–31)

Account Summary:
  Spend to Date (March 1–2): $2,450
  Projected Month-End Spend: $37,975
  Monthly Budget: $30,000
  Pacing: 127% (Overpacing ⚠)

Campaign Group Budgets:
| Campaign Group       | Daily Budget | Spent (Mar 1-2) | Avg Daily | Pacing |
|----------------------|-------------|-----------------|-----------|--------|
| Q1 Lead Gen          | $750         | $1,650          | $825      | 110%   |
| Brand Awareness Q1   | $500         | $800            | $400      | 80%    |

Recommendations:
→ Q1 Lead Gen is overpacing by 10% — within acceptable range, monitor closely
→ Brand Awareness Q1 is underpacing (80%) — check bid competitiveness or audience size
```

## Common Budget Scenarios

### Budget Running Out Early

**Signs:** Daily spend is near daily cap early in the day; declining impression volume in afternoon

**Investigation:**
1. Check daily budgets in `linkedin_ads_list_campaign_groups`
2. Compare actual average daily spend vs. daily budget — if actual > daily budget, LinkedIn is managing delivery
3. Check if campaign schedule is restricting delivery hours

**Recommendations:**
- Increase daily budget if ROI justifies more spend
- Adjust bid strategy to spread delivery more evenly (LinkedIn's budget pacing algorithm)
- Use campaign start/end dates with total budget instead of daily budget for more predictable spend

### Budget Underspending

**Signs:** Pacing < 85%; campaigns are not spending allocated budget

**Common Causes:**
1. **Bids too low** — LinkedIn requires competitive bids to win auctions; use `linkedin_ads_get_budget_pricing` to check recommended ranges
2. **Audience too narrow** — Target audience is very small; LinkedIn may run out of eligible impressions
3. **Campaign paused or in draft** — Check campaign and campaign group status
4. **Ad approval pending** — New creatives may be under review

**Investigation:**
```json
{
  "tool": "linkedin_ads_list_campaigns",
  "parameters": {
    "reason": "Checking campaign status for underspending campaign groups",
    "account_id": 123456789,
    "status": ["ACTIVE", "PAUSED", "DRAFT"]
  }
}
```

**Recommendations:**
- Increase bids toward the recommended range from `linkedin_ads_get_budget_pricing`
- Expand targeting (add job functions, industries, or geographic regions)
- Review creative approvals in LinkedIn Campaign Manager

### Month-End Budget Forecast

To forecast remaining spend for the month:

```
Days remaining in period: [N]
Average daily spend over last 7 days: [avg_daily]
Projected additional spend: avg_daily × N
Projected month-end total: spend_to_date + projected_additional
```

## LinkedIn-Specific Budget Considerations

### Campaign Group vs. Campaign Budgets
- LinkedIn budgets are typically set at the **Campaign Group** level (like Google Campaign-level budgets)
- Individual Campaigns within a group compete for the Campaign Group budget
- Unlike Meta (where budgets can be at ad set level), LinkedIn's Campaign Group budget controls total spend

### Daily Budget vs. Total Budget
- **Daily Budget:** Spend up to X per day; LinkedIn will try to hit this amount each day
- **Total Budget:** Spend up to X total over the campaign's lifetime; LinkedIn paces delivery accordingly

### LinkedIn's Budget Pacing Algorithm
LinkedIn paces daily spend throughout the day to avoid front-loading. Actual daily spend may be up to 20% above the daily budget cap on high-performing days (LinkedIn's standard allowance), but averages out over time.

## Best Practices

1. **Use THIS_MONTH preset** — For pacing analysis, use the current calendar month as the reference period
2. **Get partner conversions first** — Before recommending budget changes, understand ROAS by calling `linkedin_ads_get_partner_conversions`
3. **LinkedIn bid floors are high** — LinkedIn CPCs are typically $2–$15+ (vs. $0.50–$2 on Meta). If bids are too low, campaigns won't deliver. Always validate bids against `linkedin_ads_get_budget_pricing`
4. **Account for weekday bias** — LinkedIn impressions are highest on weekdays (professional audience). Weekend CPMs can be lower; budget may not spend evenly across all 7 days
5. **Minimum daily budget** — LinkedIn typically requires a minimum $10/day per campaign. Below this threshold, delivery becomes unreliable

## See Also

- **references/mcp-tools-reference.md** — Complete Hopkin MCP tools reference
- **references/workflows/campaign-performance.md** — Campaign-level ROAS and efficiency analysis
- **references/troubleshooting.md** — Common issues with budget delivery
