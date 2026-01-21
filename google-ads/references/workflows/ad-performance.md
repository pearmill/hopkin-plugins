# Ad Performance Report

## Overview
Analyze ad creative performance, RSA asset effectiveness, and ad copy comparisons.

## Primary Tool
Use `get_ad_performance` for standard reports, or `run_gaql` for custom queries.

## Required Parameters
- **customer_id**: Google Ads account ID
- **start_date**: Report start date (YYYY-MM-DD)
- **end_date**: Report end date (YYYY-MM-DD)

## Using get_ad_performance

The `get_ad_performance` tool returns ad-level metrics. Call it with:
```
customer_id: "1234567890"
start_date: "2024-01-01"
end_date: "2024-01-31"
```

## GAQL Query Templates

### Ad Performance Overview
```sql
SELECT
  campaign.name,
  ad_group.name,
  ad_group_ad.ad.id,
  ad_group_ad.ad.type,
  ad_group_ad.status,
  ad_group_ad.ad.final_urls,
  metrics.impressions,
  metrics.clicks,
  metrics.ctr,
  metrics.average_cpc,
  metrics.cost_micros,
  metrics.conversions,
  metrics.conversions_value
FROM ad_group_ad
WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
  AND ad_group_ad.status != 'REMOVED'
ORDER BY metrics.impressions DESC
```

### Responsive Search Ad Headlines Performance
```sql
SELECT
  campaign.name,
  ad_group.name,
  ad_group_ad.ad.responsive_search_ad.headlines,
  ad_group_ad.ad.responsive_search_ad.descriptions,
  metrics.impressions,
  metrics.clicks,
  metrics.ctr,
  metrics.conversions
FROM ad_group_ad
WHERE ad_group_ad.ad.type = 'RESPONSIVE_SEARCH_AD'
  AND segments.date BETWEEN '{start_date}' AND '{end_date}'
  AND ad_group_ad.status = 'ENABLED'
ORDER BY metrics.impressions DESC
```

### RSA Asset Performance
```sql
SELECT
  asset.text_asset.text,
  asset.type,
  ad_group_ad_asset_view.performance_label,
  ad_group_ad_asset_view.field_type,
  metrics.impressions,
  metrics.clicks,
  metrics.ctr,
  metrics.conversions
FROM ad_group_ad_asset_view
WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
ORDER BY metrics.impressions DESC
```

### Ad Strength Analysis
```sql
SELECT
  campaign.name,
  ad_group.name,
  ad_group_ad.ad.id,
  ad_group_ad.ad.responsive_search_ad.headlines,
  ad_group_ad.ad_strength,
  metrics.impressions,
  metrics.clicks,
  metrics.conversions
FROM ad_group_ad
WHERE ad_group_ad.ad.type = 'RESPONSIVE_SEARCH_AD'
  AND ad_group_ad.status = 'ENABLED'
ORDER BY ad_group_ad.ad_strength DESC
```

### Display Ad Performance
```sql
SELECT
  campaign.name,
  ad_group.name,
  ad_group_ad.ad.type,
  ad_group_ad.ad.responsive_display_ad.marketing_images,
  metrics.impressions,
  metrics.clicks,
  metrics.ctr,
  metrics.conversions,
  metrics.cost_micros
FROM ad_group_ad
WHERE ad_group_ad.ad.type = 'RESPONSIVE_DISPLAY_AD'
  AND segments.date BETWEEN '{start_date}' AND '{end_date}'
ORDER BY metrics.impressions DESC
```

### Video Ad Performance
```sql
SELECT
  campaign.name,
  ad_group.name,
  ad_group_ad.ad.type,
  ad_group_ad.ad.video_ad.video.asset,
  metrics.impressions,
  metrics.video_views,
  metrics.video_view_rate,
  metrics.clicks,
  metrics.conversions,
  metrics.cost_micros
FROM ad_group_ad
WHERE ad_group_ad.ad.type IN ('VIDEO_AD', 'VIDEO_RESPONSIVE_AD')
  AND segments.date BETWEEN '{start_date}' AND '{end_date}'
ORDER BY metrics.video_views DESC
```

### Ads with Low CTR (Optimization Candidates)
```sql
SELECT
  campaign.name,
  ad_group.name,
  ad_group_ad.ad.id,
  ad_group_ad.ad.type,
  metrics.impressions,
  metrics.clicks,
  metrics.ctr,
  metrics.conversions
FROM ad_group_ad
WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
  AND ad_group_ad.status = 'ENABLED'
  AND metrics.impressions > 1000
  AND metrics.ctr < 0.02
ORDER BY metrics.impressions DESC
```

### Ad Performance by Device
```sql
SELECT
  segments.device,
  ad_group_ad.ad.type,
  metrics.impressions,
  metrics.clicks,
  metrics.ctr,
  metrics.cost_micros,
  metrics.conversions
FROM ad_group_ad
WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
ORDER BY segments.device
```

## Output Formatting

### Ad Performance Table
| Campaign | Ad Group | Ad Type | Status | Impressions | Clicks | CTR | Conv | Cost |
|----------|----------|---------|--------|-------------|--------|-----|------|------|
| [name] | [group] | [type] | [status] | [imp] | [clicks] | [ctr]% | [conv] | $[cost] |

### RSA Asset Performance Table
| Asset Text | Type | Performance | Impressions | Clicks | CTR |
|------------|------|-------------|-------------|--------|-----|
| [text] | Headline/Description | [Best/Good/Low] | [imp] | [clicks] | [ctr]% |

### Ad Strength Ratings
- **Excellent**: Optimal ad configuration
- **Good**: Well-configured, minor improvements possible
- **Average**: Room for improvement
- **Poor**: Needs significant optimization

## RSA Asset Performance Labels
- **BEST**: Top performing asset
- **GOOD**: Above average performance
- **LOW**: Below average, consider replacing
- **LEARNING**: Insufficient data
- **PENDING**: Not yet evaluated

## Insights to Provide

1. **Top Performers**: Ads with highest CTR and conversion rates
2. **Underperformers**: High-impression ads with low CTR (< 2%)
3. **RSA Opportunities**: Assets marked "LOW" that should be replaced
4. **Ad Strength Gaps**: Ads not at "Excellent" strength
5. **Device Variations**: Performance differences across mobile/desktop
6. **A/B Test Results**: Compare similar ads to identify winning variations
