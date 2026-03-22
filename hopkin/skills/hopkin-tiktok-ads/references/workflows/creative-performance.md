# Creative / Video Performance Report Workflow

## When to Use

Use this workflow to analyze TikTok video and creative performance, compare creative variants in A/B tests, understand video engagement patterns, identify top-performing creatives, and optimize video content strategy. This is TikTok's unique strength as a video-first advertising platform.

## Required Information

- **Advertiser ID** — Numeric string (e.g., `"7012345678901234567"`)
- **Date range** — `start_date` and `end_date` in `YYYY-MM-DD` format
- **Optional:** Campaign IDs, ad group IDs, or ad IDs to narrow analysis

## Detailed Workflow

### Step 1: Get Creative Report

Start with `tiktok_ads_get_creative_report` for video-specific metrics across all creatives:

```json
{
  "tool": "tiktok_ads_get_creative_report",
  "parameters": {
    "reason": "Getting creative-level performance with video metrics for February 2026",
    "advertiser_id": "7012345678901234567",
    "start_date": "2026-02-01",
    "end_date": "2026-02-28"
  }
}
```

This returns video engagement metrics that are not available in the standard performance report.

### Step 2: Get Ad-Level Performance

Use `tiktok_ads_get_performance_report` at the ad level for cost and delivery metrics:

```json
{
  "tool": "tiktok_ads_get_performance_report",
  "parameters": {
    "reason": "Getting ad-level cost and delivery metrics to combine with creative data",
    "advertiser_id": "7012345678901234567",
    "level": "ad",
    "start_date": "2026-02-01",
    "end_date": "2026-02-28"
  }
}
```

### Step 3: List Ads for Creative Details

Use `tiktok_ads_list_ads` to get creative configuration details (video URLs, thumbnails, CTAs):

```json
{
  "tool": "tiktok_ads_list_ads",
  "parameters": {
    "reason": "Listing ad creative details to understand what content each ad uses",
    "advertiser_id": "7012345678901234567",
    "campaign_ids": ["1801234567890123"]
  }
}
```

### Step 4: Preview Top Performers

Use `tiktok_ads_preview_ads` to generate preview links for the top-performing creatives:

```json
{
  "tool": "tiktok_ads_preview_ads",
  "parameters": {
    "reason": "Generating preview links for top 3 performing ads to share with the team",
    "advertiser_id": "7012345678901234567",
    "ad_ids": ["1901234567890123", "1901234567890124", "1901234567890125"]
  }
}
```

## TikTok Video Metrics Explained

TikTok provides a rich set of video-specific metrics that are critical for understanding creative performance:

### Playback Metrics
- **`video_play_actions`** — Total number of times the video started playing (includes replays)
- **`video_watched_2s`** — Number of times the video was watched for at least 2 seconds; measures initial hook effectiveness
- **`video_watched_6s`** — Number of times the video was watched for at least 6 seconds; measures sustained interest
- **`average_video_play`** — Average duration (in seconds) each video play lasted
- **`average_video_play_per_user`** — Average watch time per unique user (accounts for replays)

### Social Engagement Metrics
- **`likes`** — Number of likes on the ad; indicates content appeal
- **`shares`** — Number of shares; strong signal of content virality and resonance
- **`comments`** — Number of comments; indicates conversation-driving content
- **`follows`** — Number of new follows gained from the ad; unique to TikTok and measures brand follow-through beyond the ad interaction

### Profile & Interaction Metrics
- **`profile_visits`** — Number of times users visited the advertiser's TikTok profile after seeing the ad; a unique TikTok metric that indicates brand curiosity and consideration

## Video Completion Funnel

Analyze the video completion funnel to identify where viewers drop off:

```
Impressions
  -> video_play_actions (Play Rate = plays / impressions)
    -> video_watched_2s (2s Rate = 2s views / plays)
      -> video_watched_6s (6s Rate = 6s views / plays)
        -> Completed views (Completion Rate)
```

**How to interpret the funnel:**
- **Low Play Rate** — Thumbnail or ad placement may not be compelling enough to trigger a play
- **Low 2s Rate** — The video hook (first 2 seconds) is not capturing attention; test different openings
- **Drop-off between 2s and 6s** — The content is not sustaining interest after the hook; improve the value proposition delivery
- **Low Completion Rate** — Video may be too long or loses momentum; consider shorter formats or tighter editing

## Creative A/B Testing

When comparing creative variants, use this approach:

### 1. Identify Test Ads

```json
{
  "tool": "tiktok_ads_list_ads",
  "parameters": {
    "reason": "Listing all ads in the A/B test ad group to identify variants",
    "advertiser_id": "7012345678901234567",
    "adgroup_ids": ["1851234567890123"]
  }
}
```

### 2. Compare Performance

```json
{
  "tool": "tiktok_ads_get_performance_report",
  "parameters": {
    "reason": "Comparing ad-level performance for creative A/B test variants",
    "advertiser_id": "7012345678901234567",
    "level": "ad",
    "start_date": "2026-02-01",
    "end_date": "2026-02-28",
    "adgroup_ids": ["1851234567890123"]
  }
}
```

### 3. Compare Video Engagement

```json
{
  "tool": "tiktok_ads_get_creative_report",
  "parameters": {
    "reason": "Comparing video engagement metrics across A/B test creatives",
    "advertiser_id": "7012345678901234567",
    "start_date": "2026-02-01",
    "end_date": "2026-02-28"
  }
}
```

### A/B Test Evaluation Criteria

| Metric | What It Tells You |
|---|---|
| CTR | Which creative drives more clicks |
| video_watched_2s rate | Which hook is more effective |
| video_watched_6s rate | Which content sustains attention |
| Completion rate | Which video holds viewers to the end |
| shares | Which content resonates enough to share |
| follows | Which creative builds lasting brand connection |
| cost_per_conversion | Which creative drives cheapest conversions |

## Best Practices for TikTok Creative

1. **Hook in the first 2 seconds** — TikTok's fast-scrolling format means you have roughly 2 seconds to capture attention; always check `video_watched_2s` rates
2. **Keep videos short** — 15-30 second videos typically perform best on TikTok; longer videos need exceptionally strong content to maintain engagement
3. **Native feel matters** — Ads that look like organic TikTok content (vertical video, trending sounds, authentic style) consistently outperform polished brand content
4. **Monitor creative fatigue** — TikTok audiences consume content rapidly; refresh creatives every 7-14 days or when you see declining engagement rates
5. **Track follows and profile visits** — These unique TikTok metrics indicate whether your ad is building lasting brand presence, not just driving one-time clicks
6. **Use social engagement as a quality signal** — High shares and comments indicate the content resonates with the audience and may benefit from increased budget
7. **Test multiple hooks** — Create variants with different first 2-3 seconds to identify the most effective opening
8. **Leverage completion rate for retargeting** — Users who watch most of a video are high-intent; suggest retargeting audiences based on video view percentage

## See Also

- **references/workflows/campaign-performance.md** — Campaign-level performance analysis
- **references/workflows/audience-insights.md** — Audience demographic analysis
- **references/workflows/common-actions.md** — Write operations and optimization guidance
