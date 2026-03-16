# Budget & Spend Report

## Overview
Track budget utilization, daily/monthly spend, pacing analysis, and cost breakdowns.

## Primary Tools
- `google_ads_list_campaigns` — Get campaign budget data and status
- `google_ads_get_insights` — Get performance metrics with date segments for spend trends

## Required Parameters
- **customer_id**: Google Ads account ID (format: 1234567890, no hyphens)
- **Date range**: Use `date_preset` or `date_range`

## Fetching Budget & Spend Data

### Step 1: Get Campaign Budgets
```json
{
  "tool": "google_ads_list_campaigns",
  "parameters": {
    "reason": "Getting campaign budget configuration for pacing analysis",
    "customer_id": "1234567890",
    "status": "ENABLED"
  }
}
```

### Step 2: Get Daily Spend Trend
```json
{
  "tool": "google_ads_get_insights",
  "parameters": {
    "reason": "Getting daily spend data for budget pacing calculations",
    "customer_id": "1234567890",
    "level": "CAMPAIGN",
    "date_range": {"start_date": "2026-01-01", "end_date": "2026-01-31"},
    "segments": ["date"]
  }
}
```

### Step 3: Spend by Device
```json
{
  "tool": "google_ads_get_insights",
  "parameters": {
    "reason": "Analyzing spend efficiency by device type",
    "customer_id": "1234567890",
    "level": "CAMPAIGN",
    "date_preset": "LAST_30_DAYS",
    "segments": ["device"]
  }
}
```

## Brand vs Non-Brand Spend Analysis

When analyzing budgets, consider segmenting by brand vs non-brand:

### Identifying Campaign Types

**Brand campaign indicators:**
- "Brand", "Branded", "TM", or "B" prefix/suffix
- The client's brand name or product names

**Non-Brand campaign indicators:**
- "NB", "Non-Brand", "NonBrand", "Generic"
- "Competitor", "Comp", "Conquest"

### Brand vs Non-Brand Spend Table

| Segment | Daily Budget | Spent | % of Total | Lost IS (Budget) |
|---------|--------------|-------|------------|------------------|
| Brand | $X | $X | X% | X% |
| Non-Brand | $X | $X | X% | X% |

## Budget Pacing Calculations

### Daily Budget Pacing
```
Days in Month: [total days]
Days Elapsed: [days passed]
Monthly Budget: $[budget]

Expected Spend: (Monthly Budget / Days in Month) × Days Elapsed
Actual Spend: $[current spend]
Pacing: (Actual Spend / Expected Spend) × 100%

Status:
- < 90%: Underspending
- 90-110%: On track
- > 110%: Overspending
```

### Remaining Daily Budget
```
Remaining Budget = Monthly Budget - Actual Spend
Remaining Days = Days in Month - Days Elapsed
Recommended Daily = Remaining Budget / Remaining Days
```

## Output Formatting

### Budget Overview Table
| Campaign | Daily Budget | Spent (Period) | Budget Used | Lost IS (Budget) |
|----------|--------------|----------------|-------------|------------------|
| [name] | $[budget] | $[cost] | [%] | [%] |

### Pacing Summary
| Metric | Value |
|--------|-------|
| Period Budget | $X,XXX |
| Spent to Date | $X,XXX |
| Expected Spend | $X,XXX |
| Pacing | XX% |
| Status | On Track / Over / Under |

## Visualize Budget Trends

Render a timeseries chart with daily spend data:

```json
{
  "tool": "google_ads_render_chart",
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

## Insights to Provide

1. **Pacing Status**: Over/under budget against expected spend
2. **Budget-Limited Campaigns**: Campaigns losing impression share due to budget
3. **Inefficient Spend**: High cost with low conversions
4. **Time-Based Patterns**: Best/worst performing days
5. **Device Efficiency**: Cost-per-conversion by device type
