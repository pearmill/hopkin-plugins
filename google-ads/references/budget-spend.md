# Budget & Spend Report

## Overview
Track budget utilization, daily/monthly spend, pacing analysis, and cost breakdowns.

## Primary Tool
Use `run_gaql` or `execute_gaql_query` with budget-specific queries.

## Required Parameters
- **customer_id**: Google Ads account ID
- **query**: GAQL query string

## GAQL Query Templates

### Campaign Budget Overview
```sql
SELECT
  campaign.name,
  campaign.status,
  campaign_budget.amount_micros,
  campaign_budget.delivery_method,
  campaign_budget.period,
  campaign_budget.total_amount_micros,
  metrics.cost_micros,
  metrics.impressions,
  metrics.clicks,
  metrics.conversions
FROM campaign
WHERE campaign.status = 'ENABLED'
ORDER BY metrics.cost_micros DESC
```

### Daily Spend by Campaign
```sql
SELECT
  segments.date,
  campaign.name,
  metrics.cost_micros,
  metrics.impressions,
  metrics.clicks,
  metrics.conversions
FROM campaign
WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
ORDER BY segments.date DESC, metrics.cost_micros DESC
```

### Monthly Spend Summary
```sql
SELECT
  segments.month,
  metrics.cost_micros,
  metrics.impressions,
  metrics.clicks,
  metrics.conversions,
  metrics.conversions_value
FROM campaign
WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
ORDER BY segments.month DESC
```

### Cost by Campaign Type
```sql
SELECT
  campaign.advertising_channel_type,
  metrics.cost_micros,
  metrics.impressions,
  metrics.clicks,
  metrics.conversions,
  metrics.conversions_value
FROM campaign
WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
  AND campaign.status = 'ENABLED'
```

### Cost by Ad Group
```sql
SELECT
  campaign.name,
  ad_group.name,
  ad_group.status,
  metrics.cost_micros,
  metrics.impressions,
  metrics.clicks,
  metrics.conversions,
  metrics.average_cpc
FROM ad_group
WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
ORDER BY metrics.cost_micros DESC
LIMIT 50
```

### Budget Utilization (Campaigns Limited by Budget)
```sql
SELECT
  campaign.name,
  campaign_budget.amount_micros,
  metrics.cost_micros,
  metrics.search_budget_lost_impression_share,
  metrics.content_budget_lost_impression_share,
  metrics.impressions,
  metrics.conversions
FROM campaign
WHERE campaign.status = 'ENABLED'
  AND segments.date BETWEEN '{start_date}' AND '{end_date}'
ORDER BY metrics.search_budget_lost_impression_share DESC
```

### Spend by Device
```sql
SELECT
  segments.device,
  metrics.cost_micros,
  metrics.impressions,
  metrics.clicks,
  metrics.ctr,
  metrics.conversions,
  metrics.average_cpc
FROM campaign
WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
```

### Spend by Day of Week
```sql
SELECT
  segments.day_of_week,
  metrics.cost_micros,
  metrics.impressions,
  metrics.clicks,
  metrics.conversions
FROM campaign
WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
ORDER BY segments.day_of_week
```

### Spend by Hour of Day
```sql
SELECT
  segments.hour,
  metrics.cost_micros,
  metrics.impressions,
  metrics.clicks,
  metrics.conversions
FROM campaign
WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
ORDER BY segments.hour
```

### Geographic Spend Analysis
```sql
SELECT
  geographic_view.country_criterion_id,
  geographic_view.location_type,
  metrics.cost_micros,
  metrics.impressions,
  metrics.clicks,
  metrics.conversions
FROM geographic_view
WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
ORDER BY metrics.cost_micros DESC
LIMIT 20
```

### High Spend, Low Conversion Alerts
```sql
SELECT
  campaign.name,
  ad_group.name,
  metrics.cost_micros,
  metrics.clicks,
  metrics.conversions,
  metrics.impressions
FROM ad_group
WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
  AND metrics.cost_micros > 1000000
  AND metrics.conversions < 1
ORDER BY metrics.cost_micros DESC
```

## Brand vs Non-Brand Spend Analysis

When analyzing budgets, consider segmenting by brand vs non-brand to understand spend allocation.

### Identifying Campaign Types

**Brand campaign indicators:**
- "Brand", "Branded", "TM", or "B" prefix/suffix
- The client's brand name or product names

**Non-Brand campaign indicators:**
- "NB", "Non-Brand", "NonBrand", "Generic"
- "Competitor", "Comp", "Conquest"
- Category/feature terms without brand mentions

### Brand vs Non-Brand Spend Table

| Segment | Daily Budget | Spent | % of Total | Lost IS (Budget) |
|---------|--------------|-------|------------|------------------|
| Brand | $X | $X | X% | X% |
| Non-Brand | $X | $X | X% | X% |
| - Core NB | $X | $X | X% | X% |
| - Competitor | $X | $X | X% | X% |

## Budget Pacing Calculations

### Daily Budget Pacing
```
Days in Month: [total days]
Days Elapsed: [days passed]
Monthly Budget: $[budget]

Expected Spend: (Monthly Budget / Days in Month) × Days Elapsed
Actual Spend: $[current spend from query]
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

### Daily Spend Table
| Date | Campaign | Cost | Impressions | Clicks | Conversions |
|------|----------|------|-------------|--------|-------------|
| [date] | [name] | $[cost] | [imp] | [clicks] | [conv] |

### Pacing Summary
| Metric | Value |
|--------|-------|
| Period Budget | $X,XXX |
| Spent to Date | $X,XXX |
| Expected Spend | $X,XXX |
| Pacing | XX% |
| Status | On Track / Over / Under |

## Key Calculations

- **Cost**: `cost_micros / 1,000,000`
- **Daily Budget**: `amount_micros / 1,000,000`
- **Budget Utilization**: `(cost / budget) × 100`
- **Lost Impression Share**: Already returned as percentage

## Insights to Provide

1. **Pacing Status**: Over/under budget against expected spend
2. **Budget-Limited Campaigns**: High lost impression share due to budget
3. **Inefficient Spend**: High cost with low conversions
4. **Time-Based Patterns**: Best/worst performing days or hours
5. **Device Efficiency**: Cost-per-conversion by device type
6. **Geographic ROI**: Regions with best/worst spend efficiency
