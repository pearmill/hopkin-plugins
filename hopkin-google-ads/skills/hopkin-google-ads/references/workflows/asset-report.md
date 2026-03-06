# Asset Report

## Overview
Analyze individual asset performance across hierarchy levels — RSA headline/description effectiveness, PMax asset group creative performance, and account-wide asset analysis. Identify top-performing assets, underperformers, policy issues, and creative optimization opportunities.

## Primary Tool
- `google_ads_get_asset_report` — Multi-level asset performance with metrics, performance labels, optional conversion breakdowns, and optional change history

## Hierarchy Levels
- **AD_GROUP** — RSA/App/Demand Gen assets via `ad_group_ad_asset_view`. Includes `performance_label` (BEST, GOOD, LOW, LEARNING). Also queries `ad_group_asset` to fill gaps for non-RSA asset types.
- **CAMPAIGN** — Standard campaign assets (`campaign_asset`) + PMax asset groups (`asset_group_asset`). Specifying CAMPAIGN automatically includes ASSET_GROUP queries.
- **CUSTOMER** — Account-wide assets (`customer_asset`)
- **ASSET_GROUP** — PMax asset groups only (`asset_group_asset`)

When `levels` is omitted, all levels are queried in parallel.

## Common Use Cases

### Use Case 1: RSA Asset Performance (Headlines & Descriptions)

Analyze text asset effectiveness for Responsive Search Ads with performance labels.

```json
{
  "tool": "google_ads_get_asset_report",
  "parameters": {
    "reason": "Analyzing RSA headline and description performance",
    "customer_id": "1234567890",
    "date_preset": "LAST_30_DAYS",
    "levels": ["AD_GROUP"],
    "field_types": ["HEADLINE", "DESCRIPTION"],
    "order_by": "impressions",
    "limit": 50
  }
}
```

### Use Case 2: PMax Asset Performance

Analyze assets within Performance Max campaigns.

```json
{
  "tool": "google_ads_get_asset_report",
  "parameters": {
    "reason": "Reviewing PMax asset group performance",
    "customer_id": "1234567890",
    "date_preset": "LAST_30_DAYS",
    "levels": ["CAMPAIGN"],
    "order_by": "cost",
    "limit": 50
  }
}
```

### Use Case 3: All Assets Overview

Broad view of asset performance across the entire account.

```json
{
  "tool": "google_ads_get_asset_report",
  "parameters": {
    "reason": "Account-wide asset performance overview",
    "customer_id": "1234567890",
    "date_preset": "LAST_30_DAYS",
    "order_by": "impressions",
    "limit": 100
  }
}
```

### Use Case 4: Specific Campaign Assets

Filter to assets associated with particular campaigns.

```json
{
  "tool": "google_ads_get_asset_report",
  "parameters": {
    "reason": "Reviewing assets for specific campaigns",
    "customer_id": "1234567890",
    "date_preset": "LAST_7_DAYS",
    "campaign_ids": ["123456789", "987654321"],
    "order_by": "conversions"
  }
}
```

### Use Case 5: With Conversion Breakdown

Include per-conversion-action breakdown for detailed conversion attribution.

```json
{
  "tool": "google_ads_get_asset_report",
  "parameters": {
    "reason": "Asset performance with conversion action breakdown",
    "customer_id": "1234567890",
    "date_preset": "LAST_30_DAYS",
    "include_conversion_breakdown": true,
    "order_by": "conversions",
    "limit": 30
  }
}
```

### Use Case 6: With Change History

Include when assets were added and last modified (useful for audits).

```json
{
  "tool": "google_ads_get_asset_report",
  "parameters": {
    "reason": "Asset audit with change history",
    "customer_id": "1234567890",
    "date_preset": "LAST_30_DAYS",
    "include_change_history": true
  }
}
```

## Output Formatting

### RSA Asset Performance Table
| Asset | Type | Field Type | Performance | Impressions | Clicks | CTR | Cost |
|-------|------|------------|-------------|-------------|--------|-----|------|
| [text] | TEXT | HEADLINE | BEST | [imp] | [clicks] | [ctr]% | $[cost] |

### Performance Label Meanings
- **BEST** — Top-performing asset; keep and replicate the pattern
- **GOOD** — Above average performance
- **LOW** — Below average; consider replacing with new copy
- **LEARNING** — Insufficient data to rate; allow more time
- *(empty)* — Not applicable for this asset type (e.g., sitelinks, images)

### Asset Type Coverage
- **TEXT assets**: Headlines, descriptions, long headlines, business names
- **IMAGE assets**: Marketing images, portrait images, logos, landscape logos
- **VIDEO assets**: YouTube videos
- **EXTENSION assets**: Sitelinks, callouts, structured snippets, calls, prices, promotions

## Insights to Provide

1. **Top Performers**: Assets with BEST label or highest impressions/conversions
2. **Underperformers**: Assets labeled LOW — recommend replacement copy
3. **Coverage Gaps**: Asset types with few assets limiting RSA rotation
4. **Policy Issues**: Assets with non-APPROVED policy status requiring attention
5. **PMax Asset Groups**: Which asset groups drive the most volume and conversions
6. **Creative Diversity**: Whether ad groups have sufficient variety in headlines/descriptions
7. **Change History**: Recently added vs long-standing assets (when `include_change_history` is used)

## Pagination

Asset reports use cursor-based pagination. For large accounts, page through results:

```json
{
  "tool": "google_ads_get_asset_report",
  "parameters": {
    "reason": "Fetching next page of asset results",
    "customer_id": "1234567890",
    "date_preset": "LAST_30_DAYS",
    "cursor": "<nextCursor from previous response>"
  }
}
```

## Notes

- **Video metrics are not available** — Google Ads API prohibits video metrics on asset resources
- **Conversion breakdown is opt-in** — Set `include_conversion_breakdown: true` only when per-action detail is needed; it significantly increases response size
- **Change history uses a 29-day window** — Regardless of the report date range
- **AD_GROUP level is most granular** — It's the only level that provides `performance_label` for RSA assets
