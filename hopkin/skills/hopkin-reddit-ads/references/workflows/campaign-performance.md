# Campaign Performance Report Workflow

## When to Use

Use this workflow to analyze Reddit Ads campaign and ad group performance, compare results across an account, identify top and bottom performers, evaluate engagement metrics (upvotes, downvotes, comments), and assess overall account health.

## Required Information

- **Ad Account ID** — Plain string (e.g., `"t2_abc123"`)
- **Date range** — `date_start` and `date_end` in `YYYY-MM-DD` format (required; Reddit has no `date_preset`)
- **Optional:** Campaign IDs or ad group IDs to filter to specific entities

## Reddit Ads Hierarchy

| Reddit Term | Analogous To | Contains |
|---|---|---|
| Campaign | Campaign (Meta), Campaign Group (LinkedIn) | Objective, Budget, Schedule |
| Ad Group | Ad Set (Meta), Campaign (LinkedIn) | Targeting, Bidding, Subreddit placement |
| Ad | Ad (Meta), Creative (LinkedIn) | Creative content, CTA |

When a user says "campaigns," they typically mean the top-level Campaign entity in Reddit.

## Detailed Workflow

### Step 1: Get Account Summary

Start with `reddit_ads_get_account_summary` for a high-level overview:

```json
{
  "tool": "reddit_ads_get_account_summary",
  "parameters": {
    "reason": "Getting account-level performance summary to orient analysis",
    "account_id": "t2_abc123",
    "date_start": "2026-02-01",
    "date_end": "2026-02-28"
  }
}
```

**Note:** `date_start` and `date_end` are required. Reddit does not support date presets.

### Step 2: Campaign-Level Breakdown

Use `reddit_ads_get_performance_report` with `breakdown: ["campaign"]` for campaign-level metrics:

```json
{
  "tool": "reddit_ads_get_performance_report",
  "parameters": {
    "reason": "Generating campaign performance report for February 2026",
    "account_id": "t2_abc123",
    "breakdown": ["campaign"],
    "date_start": "2026-02-01",
    "date_end": "2026-02-28"
  }
}
```

### Step 3: Ad Group Drill-Down

To see targeting-level breakdown within a specific campaign:

```json
{
  "tool": "reddit_ads_get_performance_report",
  "parameters": {
    "reason": "Breaking down performance by ad group within the awareness campaign",
    "account_id": "t2_abc123",
    "breakdown": ["ad_group"],
    "date_start": "2026-02-01",
    "date_end": "2026-02-28",
    "campaign_ids": ["campaign_123"]
  }
}
```

### Step 4: Ad-Level Analysis

For creative-level performance:

```json
{
  "tool": "reddit_ads_get_performance_report",
  "parameters": {
    "reason": "Ad-level performance breakdown to identify top creatives",
    "account_id": "t2_abc123",
    "breakdown": ["ad"],
    "date_start": "2026-02-01",
    "date_end": "2026-02-28",
    "campaign_ids": ["campaign_123"]
  }
}
```

### Step 5: Key Performance Metrics

The performance report includes these key metrics:

**Delivery Metrics:**
- `impressions` — Total ad displays
- `clicks` — Total clicks
- `ctr` — Click-through rate (clicks / impressions)

**Cost Metrics:**
- `spend` — Total amount spent (in micro units; divide by 1,000,000 for actual currency)
- `cpc` — Cost per click
- `cpm` — Cost per 1,000 impressions

**Reddit Engagement Metrics (Unique to Reddit):**
- `upvotes` — Number of upvotes on the promoted post
- `downvotes` — Number of downvotes on the promoted post
- `comments` — Number of comments on the promoted post

**Video Metrics (when applicable):**
- `video_views` — Total video views
- `video_completions` — Completed video plays
- `video_viewable_impressions` — Viewable video impressions

**Budget Note:** All budget and spend values from the Reddit API are in **micro units**. Divide by 1,000,000 to get the actual currency amount. For example, a spend value of `15000000` = $15.00.

### Step 6: Sort and Present

Sort campaigns by the most relevant metric based on the user's objective:
- **Traffic campaigns:** Sort by clicks, CTR, or CPC
- **Awareness campaigns:** Sort by impressions, CPM, or reach
- **Conversion campaigns:** Sort by conversions, CPA, or ROAS
- **Engagement campaigns:** Sort by upvotes, comments, or engagement rate

Present as a table with columns: Campaign, Status, Spend, Impressions, Clicks, CTR, CPC, Upvotes, Comments.

### Step 7: Add Summary Statistics

Calculate and display:
- **Total spend** across all campaigns (remember to convert from micro units)
- **Total impressions and clicks**
- **Average CTR** — Mean click-through rate
- **Average CPC/CPM** — Mean cost efficiency
- **Total engagement** — Upvotes, downvotes, comments
- **Engagement ratio** — (Upvotes - Downvotes) / Impressions

### Step 8: Highlight Insights

Identify and call out:

**Top Performers:**
- Campaigns with highest CTR
- Campaigns with most engagement (upvotes, comments) at lowest cost
- Campaigns with best CPC relative to objective

**Performance Issues:**
- Campaigns spending budget but underperforming (low CTR, high CPC)
- Campaigns with very low delivery (impressions too low for meaningful data)
- Campaigns with high downvote ratios (may indicate poor audience-content fit)

**Reddit-Specific Insights:**
- High upvote/comment ratios indicate strong community resonance
- High downvote ratios suggest the ad content or targeting needs adjustment
- Comment sentiment can provide qualitative feedback on creative effectiveness
- Subreddit-level performance (use `breakdown: ["community"]`) reveals audience fit

## Daily Trend Analysis

For trend analysis, add `"date"` to the breakdown:

```json
{
  "tool": "reddit_ads_get_performance_report",
  "parameters": {
    "reason": "Daily spend and performance trend for the account over February",
    "account_id": "t2_abc123",
    "breakdown": ["campaign", "date"],
    "date_start": "2026-02-01",
    "date_end": "2026-02-28"
  }
}
```

## Best Practices

1. **Always specify date ranges** — Reddit requires explicit `date_start` and `date_end` in `YYYY-MM-DD` format; there is no `date_preset` parameter
2. **Convert micro units** — All budget and spend values must be divided by 1,000,000 to get actual currency amounts
3. **Match metrics to objective** — Traffic: focus on clicks/CPC; Awareness: focus on impressions/CPM; Engagement: focus on upvotes/comments
4. **Account for data delay** — Reddit typically takes 24-48 hours for full data processing; avoid relying on today's or yesterday's data
5. **Respect rate limits** — Reddit enforces ~1 request per second; plan queries to minimize API calls
6. **Use engagement metrics** — Upvotes, downvotes, and comments are unique to Reddit and provide valuable signal about creative and targeting quality
7. **Leverage community breakdowns** — Use `breakdown: ["community"]` to understand which subreddits drive the best performance

## See Also

- **references/troubleshooting.md** — Common issues and solutions
- **references/workflows/community-insights.md** — Subreddit-level performance analysis
- **references/workflows/audience-targeting.md** — Audience and targeting analysis
- **references/workflows/common-actions.md** — Write operations and optimization guidance
