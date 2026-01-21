# Campaign Performance Report

## Overview
Generate campaign-level performance metrics including impressions, clicks, conversions, cost, and ROAS.

## Primary Tool
Use `get_campaign_performance` for standard reports, or `run_gaql` for custom queries.

## Required Parameters
- **customer_id**: Google Ads account ID
- **start_date**: Report start date (YYYY-MM-DD)
- **end_date**: Report end date (YYYY-MM-DD)

## Using get_campaign_performance

The `get_campaign_performance` tool returns standard metrics. Call it with:
```
customer_id: "1234567890"
start_date: "2024-01-01"
end_date: "2024-01-31"
```

## GAQL Query Templates

### Standard Campaign Performance
```sql
SELECT
  campaign.id,
  campaign.name,
  campaign.status,
  campaign.advertising_channel_type,
  metrics.impressions,
  metrics.clicks,
  metrics.ctr,
  metrics.average_cpc,
  metrics.cost_micros,
  metrics.conversions,
  metrics.conversions_value,
  metrics.cost_per_conversion
FROM campaign
WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
  AND campaign.status != 'REMOVED'
ORDER BY metrics.cost_micros DESC
```

### Campaign Performance with ROAS
```sql
SELECT
  campaign.id,
  campaign.name,
  metrics.cost_micros,
  metrics.conversions_value,
  metrics.conversions,
  metrics.clicks,
  metrics.impressions
FROM campaign
WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
  AND campaign.status = 'ENABLED'
ORDER BY metrics.conversions_value DESC
```
*Calculate ROAS as: conversions_value / (cost_micros / 1,000,000)*

### Campaign Performance by Day
```sql
SELECT
  segments.date,
  campaign.name,
  metrics.impressions,
  metrics.clicks,
  metrics.cost_micros,
  metrics.conversions
FROM campaign
WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
ORDER BY segments.date DESC, metrics.cost_micros DESC
```

### Search vs Display vs Shopping Breakdown
```sql
SELECT
  campaign.advertising_channel_type,
  metrics.impressions,
  metrics.clicks,
  metrics.cost_micros,
  metrics.conversions,
  metrics.conversions_value
FROM campaign
WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
  AND campaign.status = 'ENABLED'
```

### Performance Max Campaigns
```sql
SELECT
  campaign.id,
  campaign.name,
  metrics.impressions,
  metrics.clicks,
  metrics.conversions,
  metrics.conversions_value,
  metrics.cost_micros
FROM campaign
WHERE campaign.advertising_channel_type = 'PERFORMANCE_MAX'
  AND segments.date BETWEEN '{start_date}' AND '{end_date}'
```

## Brand vs Non-Brand Segmentation

When presenting campaign performance, consider segmenting by brand vs non-brand if relevant to the user's goals.

### Identifying Campaign Types by Name

**Brand campaign indicators:**
- Full words: "Brand", "Branded", "Trademark", "TM"
- Abbreviations: "B" as prefix/suffix (e.g., "B - Search", "Search - B")
- The client's actual brand name or product names
- Misspellings of the brand name

**Non-Brand campaign indicators:**
- Full words: "Non-Brand", "NonBrand", "Non Brand", "Generic"
- Abbreviations: "NB" (e.g., "NB - Search", "Search NB", "NB_Exact", "NB_Phrase")
- "Competitor", "Comp", "Conquest" campaigns
- Category or feature terms without brand mentions

**Other campaign types:**
- "Core" = Core non-brand campaigns
- "Competitor" / "Comp" = Competitor-targeting (subset of non-brand)
- "DSA" = Dynamic Search Ads (may be brand or non-brand)

### Brand vs Non-Brand Summary Table

When segmentation is requested, present:

| Segment | Spend | Conv | CPA | ROAS | % of Total |
|---------|-------|------|-----|------|------------|
| Brand | $X | X | $X | X.Xx | X% |
| Non-Brand | $X | X | $X | X.Xx | X% |
| - Core NB | $X | X | $X | X.Xx | X% |
| - Competitor | $X | X | $X | X.Xx | X% |
| **Total** | $X | X | $X | X.Xx | 100% |

## Output Formatting

Present results in a table format:

| Campaign | Status | Impressions | Clicks | CTR | Cost | Conversions | ROAS |
|----------|--------|-------------|--------|-----|------|-------------|------|
| [name] | [status] | [impressions] | [clicks] | [ctr]% | $[cost] | [conv] | [roas]x |

### Key Calculations
- **Cost**: `cost_micros / 1,000,000` (converts micros to currency)
- **ROAS**: `conversions_value / cost` (return on ad spend)
- **CTR**: Usually returned as decimal, multiply by 100 for percentage
- **CPC**: `average_cpc / 1,000,000` (converts micros to currency)

## Insights to Provide

After presenting data, analyze:
1. **Top performers**: Campaigns with best ROAS or lowest CPA
2. **Underperformers**: High spend with low conversions
3. **Trends**: Compare to previous period if data available
4. **Recommendations**: Pause underperformers, increase budget on winners
