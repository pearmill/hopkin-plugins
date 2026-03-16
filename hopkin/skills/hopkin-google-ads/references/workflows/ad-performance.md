# Ad Performance Report

## Overview
Analyze ad creative performance, RSA asset effectiveness, and ad copy comparisons.

## Primary Tools
- `google_ads_list_ads` — List ads for a campaign or ad group
- `google_ads_get_insights` with `level: "AD"` — Get ad-level performance metrics

## Required Parameters
- **customer_id**: Google Ads account ID (format: 1234567890, no hyphens)
- **Date range**: Use `date_preset` or `date_range`

## Fetching Ad Performance Data

### Step 1: List Ads
```json
{
  "tool": "google_ads_list_ads",
  "parameters": {
    "reason": "Listing ads for creative performance analysis",
    "customer_id": "1234567890",
    "campaign_id": "123456789"
  }
}
```

### Step 2: Get Ad-Level Insights
```json
{
  "tool": "google_ads_get_insights",
  "parameters": {
    "reason": "Getting ad-level performance metrics for creative analysis",
    "customer_id": "1234567890",
    "level": "AD",
    "date_preset": "LAST_30_DAYS",
    "campaign_id": "123456789"
  }
}
```

### Step 3: Device-Level Ad Performance
```json
{
  "tool": "google_ads_get_insights",
  "parameters": {
    "reason": "Analyzing ad performance by device",
    "customer_id": "1234567890",
    "level": "AD",
    "date_preset": "LAST_30_DAYS",
    "segments": ["device"]
  }
}
```

## Output Formatting

### Ad Performance Table
| Campaign | Ad Group | Ad Type | Status | Impressions | Clicks | CTR | Conv | Cost |
|----------|----------|---------|--------|-------------|--------|-----|------|------|
| [name] | [group] | [type] | [status] | [imp] | [clicks] | [ctr]% | [conv] | $[cost] |

### Ad Strength Ratings
- **Excellent**: Optimal ad configuration
- **Good**: Well-configured, minor improvements possible
- **Average**: Room for improvement
- **Poor**: Needs significant optimization

### RSA Asset Performance Labels
- **BEST**: Top performing asset
- **GOOD**: Above average performance
- **LOW**: Below average, consider replacing
- **LEARNING**: Insufficient data

## Insights to Provide

1. **Top Performers**: Ads with highest CTR and conversion rates
2. **Underperformers**: High-impression ads with low CTR (< 2%)
3. **RSA Opportunities**: Assets marked "LOW" that should be replaced
4. **Ad Strength Gaps**: Ads not at "Excellent" strength
5. **Device Variations**: Performance differences across mobile/desktop
6. **A/B Test Results**: Compare similar ads to identify winning variations
