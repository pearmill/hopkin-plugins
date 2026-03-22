# Audience Insights Workflow

## When to Use

Use this workflow to analyze audience demographics, understand which age groups, genders, and regions drive the best performance, optimize targeting based on demographic data, and identify high-value audience segments for TikTok Ads campaigns.

## Required Information

- **Advertiser ID** — Numeric string (e.g., `"7012345678901234567"`)
- **Date range** — `start_date` and `end_date` in `YYYY-MM-DD` format
- **Optional:** Campaign IDs or ad group IDs to filter to specific entities

## Detailed Workflow

### Step 1: Age Breakdown

Use `tiktok_ads_get_insights` with `report_type: "AUDIENCE"` and the `age` dimension:

```json
{
  "tool": "tiktok_ads_get_insights",
  "parameters": {
    "reason": "Getting age-based audience breakdown for February 2026",
    "advertiser_id": "7012345678901234567",
    "report_type": "AUDIENCE",
    "dimensions": ["age"],
    "start_date": "2026-02-01",
    "end_date": "2026-02-28"
  }
}
```

TikTok age groups are typically: 13-17, 18-24, 25-34, 35-44, 45-54, 55+.

### Step 2: Gender Breakdown

```json
{
  "tool": "tiktok_ads_get_insights",
  "parameters": {
    "reason": "Getting gender-based audience breakdown for February 2026",
    "advertiser_id": "7012345678901234567",
    "report_type": "AUDIENCE",
    "dimensions": ["gender"],
    "start_date": "2026-02-01",
    "end_date": "2026-02-28"
  }
}
```

### Step 3: Country / Region Breakdown

```json
{
  "tool": "tiktok_ads_get_insights",
  "parameters": {
    "reason": "Getting country-level audience breakdown for February 2026",
    "advertiser_id": "7012345678901234567",
    "report_type": "AUDIENCE",
    "dimensions": ["country_code"],
    "start_date": "2026-02-01",
    "end_date": "2026-02-28"
  }
}
```

### Step 4: Cross-Dimension Analysis

Combine dimensions for more granular insights:

```json
{
  "tool": "tiktok_ads_get_insights",
  "parameters": {
    "reason": "Getting age x gender cross-dimensional audience breakdown",
    "advertiser_id": "7012345678901234567",
    "report_type": "AUDIENCE",
    "dimensions": ["age", "gender"],
    "start_date": "2026-02-01",
    "end_date": "2026-02-28"
  }
}
```

This reveals segments like "Females 18-24" or "Males 25-34" that may perform differently.

### Step 5: Campaign-Specific Audience Analysis

Filter to a specific campaign to understand its audience composition:

```json
{
  "tool": "tiktok_ads_get_insights",
  "parameters": {
    "reason": "Audience demographics for the conversion campaign specifically",
    "advertiser_id": "7012345678901234567",
    "report_type": "AUDIENCE",
    "dimensions": ["age", "gender"],
    "start_date": "2026-02-01",
    "end_date": "2026-02-28",
    "campaign_ids": ["1801234567890123"]
  }
}
```

## Understanding TikTok Demographics

### TikTok's Audience Profile
- TikTok skews younger than most platforms: 18-34 is typically the largest audience segment
- The 25-34 age group often has the highest spending power and conversion rates
- Gender distribution varies by vertical (e.g., beauty skews female, gaming skews male)
- Geographic performance varies with local TikTok adoption rates

### Key Metrics to Compare Across Segments
- **CTR** — Which demographics engage most with the ads
- **CPC / CPM** — Which segments are most cost-efficient to reach
- **Conversion rate** — Which audiences convert best
- **Video completion rate** — Which demographics watch videos longest
- **Cost per conversion** — Which segments deliver the best ROI

## Audience Performance Indices

Calculate performance indices to identify over- and under-performing segments:

**Performance Index = Segment Conversion Rate / Overall Conversion Rate**

| Index Value | Interpretation |
|---|---|
| > 1.5 | Segment significantly outperforms average; consider increasing investment |
| 1.0 - 1.5 | Segment performs above average; maintain or slightly increase |
| 0.7 - 1.0 | Segment performs near average; maintain current targeting |
| 0.5 - 0.7 | Segment underperforms; consider reducing investment |
| < 0.5 | Segment significantly underperforms; consider excluding or testing new creative |

Apply this index to each age group, gender, and region to identify where to focus.

## Targeting Optimization Recommendations

Based on audience analysis, recommend these actions:

### High-Performing Segments
- Suggest increasing bid or budget allocation for top segments
- Recommend creating dedicated ad groups targeting these segments with tailored creative
- Consider building lookalike audiences based on high-performing segments

### Underperforming Segments
- Suggest reducing bid or excluding underperforming age groups or regions
- Recommend testing different creative approaches for these segments before excluding entirely
- Consider whether the underperformance is due to targeting mismatch or creative mismatch

### Geographic Insights
- Identify regions with high spend but low conversion rates
- Flag regions with low delivery that may need higher bids or broader targeting
- Recommend dayparting adjustments based on regional time zones

### Age-Based Recommendations
- Younger segments (18-24) often respond better to trending sounds, fast-paced editing, and UGC-style content
- Older segments (35+) may respond better to clear value propositions and straightforward messaging
- Tailor creative strategy per age segment based on performance data

## Best Practices

1. **Analyze at campaign level** — Audience composition can vary significantly between campaigns with different objectives; always filter by campaign when possible
2. **Cross-reference dimensions** — Age alone or gender alone tells a partial story; cross-dimensional analysis (age x gender) reveals actionable segments
3. **Use sufficient data** — Demographic breakdowns split data into many segments; ensure you have enough total impressions and conversions for statistically meaningful comparisons
4. **Account for TikTok's audience** — TikTok's user base skews younger; low performance among 55+ may simply reflect platform demographics rather than targeting issues
5. **Track changes over time** — Run audience reports at regular intervals to detect shifts in audience composition or performance trends
6. **Combine with creative data** — Pair audience insights with creative performance data from the creative report to understand which creatives work best for which audiences

## See Also

- **references/workflows/campaign-performance.md** — Campaign-level performance analysis
- **references/workflows/creative-performance.md** — Video and creative performance analysis
- **references/workflows/common-actions.md** — Write operations and optimization guidance
