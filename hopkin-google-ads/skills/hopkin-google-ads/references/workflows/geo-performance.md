# Geographic Performance Report

## Overview
Analyze how campaigns perform across different geographic locations — countries, cities, regions, metros, states, and more. Identify top-performing geographies, spot underperforming regions, and inform geo-targeting decisions.

## Primary Tool
Use `google_ads_get_geo_performance` for all geographic analysis. This is a dedicated tool that queries the `geographic_view` resource, which is the **only** resource that supports geographic segments. Do NOT attempt to get geographic data through `google_ads_get_insights` — it will not work.

Like `google_ads_get_performance_report`, this tool runs two parallel queries:
1. **Geographic metrics** — impressions, clicks, cost, CTR, avg CPC, conversions, conversion value, cost per conversion, broken down by location
2. **Conversion breakdown** — per-conversion-action metrics grouped by entity, with graceful degradation if the secondary query fails

Location criterion IDs are automatically resolved to human-readable names (e.g., `2840` → `"United States"`, `geoTargetConstants/1014044` → `"San Francisco"`).

## Required Parameters
- **customer_id**: Google Ads account ID (format: 1234567890, no hyphens)
- **Date range**: Use `date_preset` (e.g., `"LAST_30_DAYS"`) or `date_range` with `start_date` and `end_date`

## Geo Levels

The `geo_level` parameter controls the geographic granularity. Only **one geo level per query** — combining geo levels causes silent data loss in the API.

| Geo Level | Description | Use When |
|-----------|-------------|----------|
| `country` (default) | Country-level breakdown | International accounts, market comparison |
| `geo_target_region` | Region/state-level | National campaigns, regional performance |
| `geo_target_state` | State-level | US-focused state analysis |
| `geo_target_metro` | Metro/DMA area | Urban market analysis |
| `geo_target_city` | City-level | Local campaigns, city targeting |
| `geo_target_postal_code` | Postal/ZIP code | Hyperlocal analysis |
| `geo_target_most_specific_location` | Most granular available | Maximum geographic detail |

Additional levels: `geo_target_province`, `geo_target_county`, `geo_target_district`, `geo_target_airport`, `geo_target_canton`

## Using google_ads_get_geo_performance

**Country-level by campaign (default):**
```json
{
  "tool": "google_ads_get_geo_performance",
  "parameters": {
    "reason": "Analyzing geographic performance by country for last 7 days",
    "customer_id": "1234567890",
    "date_preset": "LAST_7_DAYS"
  }
}
```

**City-level for a specific campaign:**
```json
{
  "tool": "google_ads_get_geo_performance",
  "parameters": {
    "reason": "City-level breakdown for Brand Search campaign",
    "customer_id": "1234567890",
    "campaign_id": "123456789",
    "geo_level": "geo_target_city",
    "date_preset": "LAST_30_DAYS",
    "limit": 100
  }
}
```

**Daily country trends:**
```json
{
  "tool": "google_ads_get_geo_performance",
  "parameters": {
    "reason": "Daily geographic trends by country",
    "customer_id": "1234567890",
    "date_preset": "LAST_7_DAYS",
    "segments": ["date"]
  }
}
```

**Account-level metro breakdown:**
```json
{
  "tool": "google_ads_get_geo_performance",
  "parameters": {
    "reason": "Metro area performance across all campaigns",
    "customer_id": "1234567890",
    "level": "ACCOUNT",
    "geo_level": "geo_target_metro",
    "date_preset": "LAST_30_DAYS"
  }
}
```

**MCC managed account:**
```json
{
  "tool": "google_ads_get_geo_performance",
  "parameters": {
    "reason": "Geographic performance for MCC-managed client",
    "customer_id": "1234567890",
    "login_customer_id": "9999999999",
    "date_preset": "LAST_30_DAYS"
  }
}
```

## Location Type

Results include a `location_type` field with two possible values:
- **LOCATION_OF_PRESENCE** — The user was physically in this location
- **AREA_OF_INTEREST** — The user showed interest in this location (e.g., searched for "hotels in Paris" from New York)

When analyzing geographic data, note both types. LOCATION_OF_PRESENCE is more reliable for local business targeting; AREA_OF_INTEREST captures demand signals from users elsewhere.

## Output Formatting

Present results in a table format:

| Country | Campaign | Location Type | Impr. | Clicks | Cost | CTR | Conv. | Conv. Value | CPA |
|---------|----------|---------------|-------|--------|------|-----|-------|-------------|-----|
| [name] | [name] | [type] | [n] | [n] | $[n] | [n]% | [n] | $[n] | $[n] |

For sub-country levels, replace the "Country" column with the appropriate geo level (City, Region, Metro, etc.).

## Insights to Provide

After presenting geographic data, analyze:
1. **Top geographies**: Locations with highest conversion volume or best ROAS
2. **Cost efficiency**: Compare CPA across locations — identify geographies where cost per conversion is significantly above or below average
3. **Opportunity areas**: Locations with high impressions but low conversions (possible landing page or targeting issues)
4. **Waste identification**: Locations with spend but zero or near-zero conversions — candidates for geo exclusions
5. **Location type split**: If both LOCATION_OF_PRESENCE and AREA_OF_INTEREST appear, compare performance between them
6. **Recommendations**: Suggest bid adjustments, geo exclusions, or expanded targeting based on findings
