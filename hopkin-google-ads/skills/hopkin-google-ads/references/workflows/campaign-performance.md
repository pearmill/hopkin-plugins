# Campaign Performance Report

## Overview
Generate campaign-level performance metrics including impressions, clicks, conversions, cost, and ROAS.

## Primary Tool
Use `google_ads_get_performance_report` with `level: "CAMPAIGN"` for campaign performance reports. This tool runs two parallel queries in a single call:

1. **Funnel metrics** — impressions, clicks, cost, CTR, avg CPC, CPM, conversions (total), conversion value, cost per conversion, conversion rate, search impression share
2. **Conversion breakdown** — per-conversion-action conversions, value, and value/conversion segmented by `conversion_action_name`, grouped by campaign ID

This gives a complete picture of both top-level delivery metrics and the specific conversion actions driving results, without needing a separate `google_ads_get_insights` call.

Use `google_ads_get_insights` only when you need custom metric selection, specialized GAQL, or segments not supported by `google_ads_get_performance_report`.

## Required Parameters
- **customer_id**: Google Ads account ID (format: 1234567890, no hyphens)
- **Date range**: Use `date_preset` (e.g., `"LAST_30_DAYS"`) or `date_range` with `start_date` and `end_date`

## Using google_ads_get_performance_report

```json
{
  "tool": "google_ads_get_performance_report",
  "parameters": {
    "reason": "Generating campaign performance report for last 30 days",
    "customer_id": "1234567890",
    "level": "CAMPAIGN",
    "date_preset": "LAST_30_DAYS"
  }
}
```

**With custom date range:**
```json
{
  "tool": "google_ads_get_performance_report",
  "parameters": {
    "reason": "Analyzing campaign performance for January 2026",
    "customer_id": "1234567890",
    "level": "CAMPAIGN",
    "date_range": {"start_date": "2026-01-01", "end_date": "2026-01-31"}
  }
}
```

**With daily breakdown:**
```json
{
  "tool": "google_ads_get_performance_report",
  "parameters": {
    "reason": "Getting daily campaign performance trends",
    "customer_id": "1234567890",
    "level": "CAMPAIGN",
    "date_preset": "LAST_30_DAYS",
    "segments": ["date"]
  }
}
```

**MCC managed account:**
```json
{
  "tool": "google_ads_get_performance_report",
  "parameters": {
    "reason": "Campaign performance for client managed under MCC",
    "customer_id": "1234567890",
    "login_customer_id": "9999999999",
    "level": "CAMPAIGN",
    "date_preset": "LAST_30_DAYS"
  }
}
```

## Brand vs Non-Brand Segmentation

When presenting campaign performance, consider segmenting by brand vs non-brand if relevant to the user's goals.

### Identifying Campaign Types by Name

**Brand campaign indicators:**
- Full words: "Brand", "Branded", "Trademark", "TM"
- Abbreviations: "B" as prefix/suffix (e.g., "B - Search", "Search - B")
- The client's actual brand name or product names

**Non-Brand campaign indicators:**
- Full words: "Non-Brand", "NonBrand", "Non Brand", "Generic"
- Abbreviations: "NB" (e.g., "NB - Search", "Search NB", "NB_Exact")
- "Competitor", "Comp", "Conquest" campaigns

### Brand vs Non-Brand Summary Table

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

## Insights to Provide

After presenting data, analyze:
1. **Top performers**: Campaigns with best ROAS or lowest CPA
2. **Underperformers**: High spend with low conversions
3. **Trends**: Compare to previous period if data available
4. **Recommendations**: Pause underperformers, increase budget on winners
