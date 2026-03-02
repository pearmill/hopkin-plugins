# Campaign Performance Report Workflow

## When to Use

Use this workflow to analyze LinkedIn Ads campaign group and campaign performance, compare results across an account, identify top and bottom performers, understand ROAS and conversion metrics by objective, and evaluate overall account health.

## Required Information

- **Ad Account ID** — Numeric (e.g., `123456789`)
- **Date range** — Preset (e.g., `LAST_30_DAYS`) or custom (`start_date`/`end_date`)
- **Optional:** Campaign group IDs or campaign IDs to filter to specific entities

## LinkedIn Hierarchy Reminder

| LinkedIn Term | Analogous To | Contains |
|---|---|---|
| Campaign Group | Campaign (Meta), Campaign (Google) | Budget, Objective |
| Campaign | Ad Set (Meta), Ad Group (Google) | Targeting, Bidding |
| Creative | Ad (Meta), Ad (Google) | Content, CTA |

When a user says "campaigns," clarify whether they mean Campaign Groups (top-level) or Campaigns (targeting level).

## Detailed Workflow

### Step 1: Get Account Summary (Optional Quick Overview)

For a quick high-level overview, start with `linkedin_ads_get_account_summary`:

```json
{
  "tool": "linkedin_ads_get_account_summary",
  "parameters": {
    "reason": "Getting account-level performance summary to orient analysis",
    "account_id": 123456789,
    "date_preset": "LAST_30_DAYS"
  }
}
```

This returns account details, aggregate metrics, and conversion breakdown in a single call.

### Step 2: Fetch Campaign Group Performance

Use `linkedin_ads_get_performance_report` with `pivots: ["CAMPAIGN_GROUP"]` for the top-level breakdown:

```json
{
  "tool": "linkedin_ads_get_performance_report",
  "parameters": {
    "reason": "Generating campaign group performance report for last 30 days",
    "account_id": 123456789,
    "pivots": ["CAMPAIGN_GROUP"],
    "date_preset": "LAST_30_DAYS"
  }
}
```

**With conversion breakdown:**
```json
{
  "tool": "linkedin_ads_get_performance_report",
  "parameters": {
    "reason": "Campaign group performance with per-conversion breakdown",
    "account_id": 123456789,
    "pivots": ["CAMPAIGN_GROUP"],
    "date_preset": "LAST_30_DAYS",
    "include_conversion_breakdown": true
  }
}
```

**With custom date range:**
```json
{
  "tool": "linkedin_ads_get_performance_report",
  "parameters": {
    "reason": "Campaign group performance for Q1 2026",
    "account_id": 123456789,
    "pivots": ["CAMPAIGN_GROUP"],
    "start_date": "2026-01-01",
    "end_date": "2026-03-31"
  }
}
```

### Step 3: Drill Into Campaign Level (If Needed)

To see targeting-level breakdown within a specific campaign group:

```json
{
  "tool": "linkedin_ads_get_performance_report",
  "parameters": {
    "reason": "Breaking down performance by campaign within the Lead Gen campaign group",
    "account_id": 123456789,
    "pivots": ["CAMPAIGN"],
    "date_preset": "LAST_30_DAYS",
    "campaign_group_ids": ["987654321"]
  }
}
```

### Step 4: Understand Conversion Context

Before interpreting ROAS or conversion numbers, understand what's being measured:

```json
{
  "tool": "linkedin_ads_get_partner_conversions",
  "parameters": {
    "reason": "Understanding which conversion actions are tracked for this account",
    "account_id": 123456789
  }
}
```

Also use `linkedin_ads_list_campaign_groups` to get budget and objective information:

```json
{
  "tool": "linkedin_ads_list_campaign_groups",
  "parameters": {
    "reason": "Getting budget and objective details for each campaign group",
    "account_id": 123456789,
    "status": ["ACTIVE", "PAUSED"]
  }
}
```

### Step 5: Key Performance Metrics

The performance report includes these key metrics:

**Delivery Metrics:**
- `impressions` — Total ad displays
- `clicks` — Total link clicks
- `ctr` — Click-through rate (clicks / impressions)

**Cost Metrics:**
- `spend` — Total amount spent
- `cpc` — Cost per click
- `cpm` — Cost per 1,000 impressions

**Conversion Metrics:**
- `conversions` — Total conversion events
- `leads` — LinkedIn Lead Gen Form submissions (LinkedIn-specific)
- `cpa` — Cost per action/conversion
- `roas` — Return on ad spend

**Video Metrics (when applicable):**
- `video_views` — Total video views
- `video_completions` — Completed video plays

### Step 6: Sort and Present

Sort campaign groups by the most relevant metric based on the user's objective:
- **Lead generation campaigns:** Sort by leads, cost per lead, or conversion rate
- **Brand awareness campaigns:** Sort by impressions, CPM, or reach
- **Website visit campaigns:** Sort by clicks, CTR, or CPC
- **Conversion campaigns:** Sort by conversions, ROAS, or CPA

**Example Table Structure:**
```
LinkedIn Campaign Group Performance Report
Date Range: [date_range]
Ad Account: [account_id]

| Campaign Group | Status | Spend | Impressions | Clicks | CTR  | Leads | CPA    | ROAS |
|----------------|--------|-------|-------------|--------|------|-------|--------|------|
| Q1 Lead Gen    | ACTIVE | $4,521| 234,567     | 5,678  | 2.4% | 89    | $50.80 | 3.2x |
| Brand Awareness| ACTIVE | $2,100| 567,890     | 3,456  | 0.6% | 12    | $175   | 1.1x |
| ...            | ...    | ...   | ...         | ...    | ...  | ...   | ...    | ...  |
```

### Step 7: Add Summary Statistics

Calculate and display:
- **Total spend** across all campaign groups
- **Total impressions and clicks**
- **Average CTR** — Mean click-through rate
- **Average CPC/CPA** — Mean cost efficiency
- **Total conversions/leads**
- **Overall ROAS** — Total conversion value / total spend

### Step 8: Highlight Insights

Identify and call out:

**Top Performers:**
- Campaign groups with highest ROAS
- Campaign groups with most leads/conversions at lowest CPA
- Campaign groups with best CTR relative to objective

**Performance Issues:**
- Campaign groups spending budget but underperforming (low ROAS, high CPA)
- Campaign groups with very low delivery (impressions too low for meaningful data)
- Budget-constrained campaign groups (running out of daily budget)

**LinkedIn-Specific Insights:**
- Compare Lead Gen Form performance vs. website conversion performance
- Identify campaign groups benefiting from LinkedIn's professional targeting
- Note if ROAS calculation includes LinkedIn Lead Gen Form values

## Daily Trend Analysis

For trend analysis, use `time_granularity: "DAILY"`:

```json
{
  "tool": "linkedin_ads_get_performance_report",
  "parameters": {
    "reason": "Daily spend trend for the account over the last 30 days",
    "account_id": 123456789,
    "pivots": ["ACCOUNT"],
    "date_preset": "LAST_30_DAYS",
    "time_granularity": "DAILY"
  }
}
```

## Best Practices

1. **Check partner conversions first** — Before interpreting ROAS, call `linkedin_ads_get_partner_conversions` to understand what's being measured
2. **Match metrics to objective** — Lead gen: focus on leads/CPA; Awareness: focus on impressions/CPM; Traffic: focus on clicks/CPC
3. **Account for LinkedIn Lead Gen Forms** — LinkedIn's native Lead Gen Forms often show higher conversion rates than website conversions; track both separately
4. **Use appropriate date ranges** — LinkedIn campaigns often need 30+ days for statistically meaningful data, especially for conversion campaigns
5. **Include campaign group names** — Use `linkedin_ads_list_campaign_groups` alongside analytics to get human-readable names
6. **Note B2B attribution complexity** — B2B purchase cycles are long; last-click attribution may undervalue top-of-funnel LinkedIn campaigns

## See Also

- **references/mcp-tools-reference.md** — Complete Hopkin MCP tools reference
- **references/workflows/demographic-insights.md** — LinkedIn's MEMBER_* audience pivots
- **references/troubleshooting.md** — Common issues and solutions
