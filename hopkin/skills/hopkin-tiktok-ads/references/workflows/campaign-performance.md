# Campaign Performance Report Workflow

## When to Use

Use this workflow to analyze TikTok Ads campaign, ad group, and ad performance, compare results across an account, identify top and bottom performers, evaluate cost efficiency, and assess overall account health.

## Required Information

- **Advertiser ID** — Numeric string (e.g., `"7012345678901234567"`)
- **Date range** — `start_date` and `end_date` in `YYYY-MM-DD` format
- **Optional:** Campaign IDs, ad group IDs, or ad IDs to filter to specific entities

## TikTok Ads Hierarchy

| TikTok Term | Analogous To | Contains |
|---|---|---|
| Campaign | Campaign (Meta), Campaign (Reddit) | Objective, Budget, Schedule |
| Ad Group | Ad Set (Meta), Ad Group (Reddit) | Targeting, Bidding, Placement, Schedule |
| Ad | Ad (Meta), Ad (Reddit) | Creative (video/image), CTA, Landing page |

When a user says "campaigns," they typically mean the top-level Campaign entity in TikTok.

## Detailed Workflow

### Step 1: Campaign-Level Performance

Start with `tiktok_ads_get_performance_report` at the campaign level for a high-level overview:

```json
{
  "tool": "tiktok_ads_get_performance_report",
  "parameters": {
    "reason": "Getting campaign-level performance report for February 2026",
    "advertiser_id": "7012345678901234567",
    "level": "campaign",
    "start_date": "2026-02-01",
    "end_date": "2026-02-28"
  }
}
```

This returns all campaigns with their aggregate performance metrics for the specified date range.

### Step 2: Ad Group Drill-Down

Drill down into a specific campaign to see ad group performance:

```json
{
  "tool": "tiktok_ads_get_performance_report",
  "parameters": {
    "reason": "Breaking down performance by ad group within the conversion campaign",
    "advertiser_id": "7012345678901234567",
    "level": "adgroup",
    "start_date": "2026-02-01",
    "end_date": "2026-02-28",
    "campaign_ids": ["1801234567890123"]
  }
}
```

### Step 3: Ad-Level Analysis

For creative-level performance within a specific ad group:

```json
{
  "tool": "tiktok_ads_get_performance_report",
  "parameters": {
    "reason": "Ad-level performance breakdown to identify top-performing creatives",
    "advertiser_id": "7012345678901234567",
    "level": "ad",
    "start_date": "2026-02-01",
    "end_date": "2026-02-28",
    "campaign_ids": ["1801234567890123"]
  }
}
```

### Step 4: Key Performance Metrics

The performance report includes these key metrics:

**Delivery Metrics:**
- `impressions` — Total ad displays
- `clicks` — Total clicks
- `ctr` — Click-through rate (clicks / impressions)
- `reach` — Unique users who saw the ad

**Cost Metrics:**
- `spend` — Total amount spent
- `cpc` — Cost per click
- `cpm` — Cost per 1,000 impressions

**Conversion Metrics:**
- `conversions` — Total conversion events
- `conversion_rate` — Conversions / clicks
- `cost_per_conversion` — Spend / conversions

**Video Metrics:**
- `video_play_actions` — Total video plays
- `video_watched_2s` — Views of 2 seconds or more
- `video_watched_6s` — Views of 6 seconds or more
- `average_video_play` — Average watch time per play

### Step 5: Sort and Present

Sort campaigns by the most relevant metric based on the user's objective:
- **Traffic campaigns:** Sort by clicks, CTR, or CPC
- **Awareness campaigns:** Sort by impressions, CPM, or reach
- **Conversion campaigns:** Sort by conversions, cost_per_conversion, or conversion_rate
- **Video Views campaigns:** Sort by video_play_actions, video_watched_6s, or average_video_play
- **App Install campaigns:** Sort by conversions (installs) or cost_per_conversion (CPI)

Present as a table with columns: Campaign, Status, Spend, Impressions, Clicks, CTR, CPC, Conversions, Cost/Conv.

### Step 6: Summary Statistics

Calculate and display:
- **Total spend** across all campaigns
- **Total impressions and clicks**
- **Average CTR** — Mean click-through rate
- **Average CPC/CPM** — Mean cost efficiency
- **Total conversions** and average cost per conversion
- **Total video plays** and average completion rate (if video campaigns)

### Step 7: Highlight Insights

Identify and call out:

**Top Performers:**
- Campaigns with highest CTR
- Campaigns with best conversion rate at lowest cost
- Campaigns with strongest video engagement

**Performance Issues:**
- Campaigns spending budget but underperforming (low CTR, high CPC)
- Campaigns with very low delivery (impressions too low for meaningful data)
- Campaigns with high spend but low conversions

**TikTok-Specific Insights:**
- High video completion rates indicate strong creative resonance
- Low 2-second view rates suggest the hook (first 2 seconds) needs improvement
- Profile visit rates can signal brand interest beyond the immediate ad interaction
- Social engagement (likes, comments, shares) indicates content virality potential

## Daily Trend Analysis

For trend analysis, use `tiktok_ads_get_insights` with a time dimension:

```json
{
  "tool": "tiktok_ads_get_insights",
  "parameters": {
    "reason": "Daily spend and performance trend for the account over February",
    "advertiser_id": "7012345678901234567",
    "report_type": "BASIC",
    "dimensions": ["stat_time_day"],
    "start_date": "2026-02-01",
    "end_date": "2026-02-28"
  }
}
```

This provides day-by-day metrics to identify trends, pacing issues, or performance spikes.

## Best Practices

1. **Use appropriate date ranges** — TikTok supports `YYYY-MM-DD` format for `start_date` and `end_date`; ensure your range covers enough data for meaningful analysis
2. **Match metrics to objective** — Traffic: focus on clicks/CPC; Awareness: focus on impressions/CPM/reach; Conversions: focus on conversions/CPA; Video Views: focus on video completion metrics
3. **Account for learning phase** — New TikTok campaigns typically need 50 conversions to exit the learning phase; performance data during this period may be volatile
4. **TikTok video engagement matters** — Unlike other platforms, TikTok is video-first; always check video-specific metrics (completion rate, 2s/6s views) alongside standard delivery metrics
5. **Consider creative fatigue** — TikTok audiences consume content quickly; creative typically fatigues faster than on other platforms (7-14 days is common)
6. **Check by placement** — TikTok serves ads across multiple placements (TikTok, Pangle, etc.); performance can vary significantly by placement

## See Also

- **references/workflows/creative-performance.md** — Video and creative performance analysis
- **references/workflows/audience-insights.md** — Audience demographic analysis
- **references/workflows/common-actions.md** — Write operations and optimization guidance
