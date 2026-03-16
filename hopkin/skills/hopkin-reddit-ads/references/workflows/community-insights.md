# Community Insights — Subreddit-Level Analysis Workflow

## When to Use

Use this workflow to analyze performance by subreddit (community), identify which subreddits drive the best results, track subreddit performance trends over time, and optimize community targeting. This is a **Reddit-unique** capability — no other ad platform offers this level of community-level performance data.

## Required Information

- **Ad Account ID** — Plain string (e.g., `"t2_abc123"`)
- **Date range** — `date_start` and `date_end` in `YYYY-MM-DD` format
- **Optional:** Campaign IDs or ad group IDs to narrow the analysis

## Why Community Insights Matter

Reddit's advertising strength lies in its community structure. Users self-select into subreddits based on genuine interests, creating high-intent audiences. Analyzing performance by subreddit reveals:

- Which communities resonate with your ad content
- Where your budget is most efficiently spent
- Which subreddits drive engagement (upvotes, comments) vs. clicks
- Opportunities to expand or refine subreddit targeting

## Detailed Workflow

### Step 1: Subreddit Performance Overview

Use `reddit_ads_get_performance_report` with `breakdown: ["community"]` to see performance by subreddit:

```json
{
  "tool": "reddit_ads_get_performance_report",
  "parameters": {
    "reason": "Analyzing performance by subreddit to identify top-performing communities",
    "account_id": "t2_abc123",
    "breakdown": ["community"],
    "date_start": "2026-02-01",
    "date_end": "2026-02-28"
  }
}
```

This returns metrics broken down by each subreddit where ads were served.

### Step 2: Subreddit Trends Over Time

Combine breakdowns to see how subreddit performance changes over time:

```json
{
  "tool": "reddit_ads_get_performance_report",
  "parameters": {
    "reason": "Tracking subreddit performance trends over time",
    "account_id": "t2_abc123",
    "breakdown": ["community", "date"],
    "date_start": "2026-02-01",
    "date_end": "2026-02-28"
  }
}
```

Use this to identify:
- Subreddits with improving or declining performance
- Day-of-week patterns in specific communities
- Seasonal trends in community engagement

### Step 3: Campaign-by-Community Analysis

See which campaigns perform best on which subreddits:

```json
{
  "tool": "reddit_ads_get_performance_report",
  "parameters": {
    "reason": "Cross-referencing campaign performance with subreddit placement",
    "account_id": "t2_abc123",
    "breakdown": ["community", "campaign"],
    "date_start": "2026-02-01",
    "date_end": "2026-02-28"
  }
}
```

This helps answer:
- "Which campaigns work best in r/technology vs r/gaming?"
- "Should we run different creative strategies for different subreddits?"
- "Are certain campaign objectives better suited to specific communities?"

### Step 4: Review Subreddit Targeting Configuration

Use `reddit_ads_list_ad_groups` to see how subreddit targeting is configured per ad group:

```json
{
  "tool": "reddit_ads_list_ad_groups",
  "parameters": {
    "reason": "Reviewing subreddit targeting configuration for each ad group",
    "account_id": "t2_abc123",
    "campaign_id": "campaign_123"
  }
}
```

Ad groups contain targeting information, including which subreddits are targeted. Cross-reference this with the community performance data to assess targeting effectiveness.

### Step 5: Analyze Reddit Engagement Metrics

Reddit's unique engagement metrics provide deep insight into community reception:

**Upvotes** — Positive community response. High upvotes indicate content that resonates with the subreddit's culture and interests.

**Downvotes** — Negative community response. High downvotes suggest poor content-community fit, overly promotional content, or misaligned targeting.

**Comments** — Active engagement. Comments indicate the ad sparked discussion. Review comment volume alongside performance metrics to gauge content quality.

**Key Engagement Ratios:**
- **Upvote Ratio:** Upvotes / (Upvotes + Downvotes) — Aim for >70%
- **Comment Rate:** Comments / Impressions — Higher is better for engagement campaigns
- **Engagement Rate:** (Upvotes + Comments) / Impressions — Overall community reception

### Step 6: Present Community Insights

Present as a table sorted by the most relevant metric:

| Subreddit | Impressions | Clicks | CTR | CPC | Upvotes | Downvotes | Comments | Spend |
|---|---|---|---|---|---|---|---|---|
| r/technology | 50,000 | 1,200 | 2.4% | $0.85 | 340 | 45 | 28 | $1,020 |
| r/gaming | 35,000 | 600 | 1.7% | $1.10 | 180 | 90 | 15 | $660 |

**Remember:** Spend values from the API are in micro units — divide by 1,000,000.

## Best Practices

1. **Compare engagement across communities** — A subreddit with lower CTR but higher upvotes and comments may indicate strong brand-building potential
2. **Watch the downvote ratio** — High downvotes in a subreddit signal that ad content does not fit the community; consider adjusting creative or removing that community from targeting
3. **Use community data for targeting decisions** — Expand targeting to subreddits with strong organic engagement; narrow targeting away from subreddits with poor performance
4. **Respect community culture** — Reddit users are sensitive to overly promotional content; subreddits with high engagement often respond to authentic, value-driven creative
5. **Monitor trends, not just snapshots** — Use `["community", "date"]` breakdowns to track whether community performance is improving or declining over time
6. **Cross-reference with ad group targeting** — Use `reddit_ads_list_ad_groups` to understand which subreddits are explicitly targeted vs. algorithmically expanded
7. **Respect rate limits** — Reddit enforces ~1 request per second; plan your community analysis queries efficiently

## See Also

- **references/workflows/campaign-performance.md** — Overall campaign performance analysis
- **references/workflows/audience-targeting.md** — Audience and targeting analysis
- **references/workflows/common-actions.md** — Write operations and optimization guidance
- **references/troubleshooting.md** — Common issues and solutions
