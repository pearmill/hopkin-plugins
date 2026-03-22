# Common Actions — Write Operations & Optimization Workflows

## Write Operations (Unsupported)

The Hopkin TikTok Ads MCP is **read-only**. When users request write operations, follow the workflow below.

### Write Operation Workflow

When a user requests a create, update, pause, or delete operation:

**Step 1: Inform the user**
> "Write operations (create, update, pause, delete) are not yet available via Hopkin's TikTok Ads MCP. You'll need to make this change directly in TikTok Ads Manager."

**Step 2: Guide the user to TikTok Ads Manager**

Direct them to perform the action manually via TikTok Ads Manager at https://ads.tiktok.com

**Note:** There is no `tiktok_ads_developer_feedback` tool available. If a write operation would be valuable, note it for future consideration but do not attempt to call a feedback tool.

### Common Write Operations

All performed manually in TikTok Ads Manager (https://ads.tiktok.com):

- **Create Campaign** — Ads Manager -> Create -> Campaign
- **Pause/Resume Campaign** — Toggle status in Campaign list view
- **Adjust Budget** — Edit Campaign -> Budget & Schedule section
- **Create Ad Group** — Within Campaign -> Add Ad Group
- **Update Targeting** — Edit Ad Group -> Targeting section (demographics, interests, behaviors)
- **Create Ad** — Within Ad Group -> Create Ad (upload video, add text, CTA)
- **Adjust Bids** — Edit Ad Group -> Bidding & Optimization section
- **Manage Audiences** — Assets -> Audiences (custom audiences, lookalikes)
- **Manage Creative Assets** — Assets -> Creative (video library, templates)

---

## Performance Optimization Recommendations

After analyzing performance data, provide actionable recommendations based on these patterns:

### Low CTR

**Investigation steps:**
1. Use `tiktok_ads_get_performance_report` with `level: "ad"` to identify underperforming creatives
2. Use `tiktok_ads_get_creative_report` to check video engagement metrics
3. Review ad group targeting with `tiktok_ads_list_adgroups` to assess audience fit

```json
{
  "tool": "tiktok_ads_get_performance_report",
  "parameters": {
    "reason": "Identifying ads with low CTR for creative optimization",
    "advertiser_id": "7012345678901234567",
    "level": "ad",
    "start_date": "2026-02-01",
    "end_date": "2026-02-28"
  }
}
```

**Recommendations:**
- Test new video creative with a stronger hook in the first 2 seconds
- Ensure ads feel native to TikTok (vertical video, authentic style, trending elements)
- Review targeting — broad targeting may include uninterested audiences
- Test different CTAs and landing page messaging

**TikTok CTR Benchmarks:**
- In-feed ads: ~0.5%-1.5% average; 2%+ is strong
- TopView ads: typically higher CTR due to premium placement
- Spark Ads (boosted organic): often outperform standard in-feed due to native feel

### High CPC

**Investigation steps:**
1. Compare CPC across ad groups with `tiktok_ads_get_performance_report` at `level: "adgroup"`
2. Check audience overlap between ad groups
3. Review bid strategy settings

```json
{
  "tool": "tiktok_ads_get_performance_report",
  "parameters": {
    "reason": "Comparing CPC across ad groups to find expensive segments",
    "advertiser_id": "7012345678901234567",
    "level": "adgroup",
    "start_date": "2026-02-01",
    "end_date": "2026-02-28"
  }
}
```

**Recommendations:**
- Shift budget to ad groups with lower CPC
- Test broader targeting to expand the auction pool
- Refresh creative to improve relevance score
- Consider switching from manual to automatic bidding (or vice versa)
- Test different optimization goals (e.g., optimize for clicks vs. landing page views)

### Low Video Engagement

**Investigation steps:**
1. Use `tiktok_ads_get_creative_report` to check video completion funnel
2. Identify where viewers drop off (2s, 6s, completion)
3. Compare engagement across creatives

```json
{
  "tool": "tiktok_ads_get_creative_report",
  "parameters": {
    "reason": "Analyzing video engagement funnel to identify drop-off points",
    "advertiser_id": "7012345678901234567",
    "start_date": "2026-02-01",
    "end_date": "2026-02-28"
  }
}
```

**Drop-off analysis:**
- **Low play rate (plays / impressions):** Thumbnail or initial frame is not compelling
- **Low 2s view rate:** Hook is weak; test different opening sequences
- **Drop-off between 2s and 6s:** Content does not deliver on the hook's promise; front-load value
- **Low completion rate:** Video too long or loses momentum; try shorter cuts (15s vs 30s)

**Recommendations:**
- Redesign the first 2 seconds with a stronger attention hook
- Front-load the value proposition — don't save the payoff for the end
- Test shorter video lengths (9-15 seconds often outperform longer formats)
- Use text overlays and captions (many users watch without sound)
- Test trending sounds and music to boost engagement

### Budget Underspend

**Investigation steps:**
1. Use `tiktok_ads_list_campaigns` to check campaign status and budget settings
2. Use `tiktok_ads_list_adgroups` to verify ad groups are active
3. Check targeting breadth and bid competitiveness

```json
{
  "tool": "tiktok_ads_list_campaigns",
  "parameters": {
    "reason": "Checking campaign status and budget settings for underspending campaigns",
    "advertiser_id": "7012345678901234567"
  }
}
```

**Recommendations:**
- Expand targeting (broader age range, additional interests, more placements)
- Increase bid amounts to be more competitive in the auction
- Verify all ads are approved and not in review
- Check that Automatic Creative Optimization (ACO) is not limiting delivery
- Ensure the ad group schedule aligns with the target audience's active hours
- Verify conversion tracking is set up correctly (required for conversion-optimized campaigns)

---

## Cross-Platform Comparison Guidance

When users manage ads across multiple platforms, help them compare TikTok performance in context:

### TikTok vs. Meta (Facebook/Instagram)

| Dimension | TikTok | Meta |
|---|---|---|
| Primary format | Short-form vertical video | Mixed (image, video, carousel, Stories) |
| Targeting approach | Interest, behavior, demographic, lookalike | Interest, behavior, demographic, lookalike |
| Audience skew | Younger (18-34 dominant) | Broader age distribution |
| Engagement signals | Likes, shares, comments, follows, profile visits | Likes, comments, shares, saves |
| Creative style | Native, authentic, UGC-style, trending audio | Polished or native, platform-dependent |
| Video emphasis | Video-first (required for most formats) | Video optional (image ads common) |
| Learning phase | ~50 conversions | ~50 conversions |
| Unique strength | Video engagement depth, viral potential | Scale, retargeting sophistication |

### TikTok vs. Google Ads

| Dimension | TikTok | Google |
|---|---|---|
| Primary targeting | Interest, behavior, demographic | Keywords, audiences, topics |
| Funnel position | Top-to-mid funnel (awareness, consideration) | Full funnel (search captures high intent) |
| Creative format | Short-form vertical video | Text, display, video (YouTube), shopping |
| Engagement signals | Video metrics, social engagement | CTR, quality score, view rate |
| Audience discovery | Algorithm-driven (For You page) | Intent-driven (search queries) |
| Unique strength | Creative storytelling, younger audiences | Intent capture, search dominance |

### TikTok vs. Reddit Ads

| Dimension | TikTok | Reddit |
|---|---|---|
| Primary targeting | Interest, behavior, demographic | Subreddits, interests, keywords |
| Audience type | Entertainment-seeking, trend-driven | Community-based, discussion-driven |
| Engagement signals | Likes, shares, comments, follows | Upvotes, downvotes, comments |
| Creative style | Native video, trending audio, authentic | Native text/image, conversational, value-driven |
| Video emphasis | Video required for most formats | Video optional |
| Demographic data | Age, gender, country via AUDIENCE reports | Not available via API |
| Budget format | Standard currency | Micro units (divide by 1,000,000) |
| Unique strength | Video engagement, viral reach | Niche community targeting, authentic engagement |

### Cross-Platform Analysis Tips

1. **Normalize metrics** — When comparing CPC or CPM across platforms, ensure you're comparing similar objectives and audiences
2. **Account for platform strengths** — TikTok excels at video engagement and younger audiences; don't expect it to match Google's intent signals or Reddit's community depth
3. **Consider engagement quality** — TikTok's follows and profile visits indicate lasting brand impact, unlike one-time click metrics
4. **Funnel position matters** — TikTok typically drives upper-funnel awareness; pair with search or retargeting on other platforms for full-funnel coverage
5. **Creative is not portable** — Ads that work on Meta or Google rarely work on TikTok without significant adaptation to the platform's native style

---

## Optimization Workflow by Campaign Objective

### Traffic Optimization

**Primary metrics:** CPC, CTR

1. **Benchmark CPC:** Use `tiktok_ads_get_performance_report` with `level: "campaign"` to establish baselines
2. **Creative analysis:** Use `level: "ad"` and `tiktok_ads_get_creative_report` to find highest-CTR ads
3. **Audience analysis:** Use `tiktok_ads_get_insights` with `report_type: "AUDIENCE"` to find most cost-efficient demographics
4. **Guidance:** Direct user to TikTok Ads Manager to pause underperforming ad groups and increase budget on top performers

### App Install Optimization

**Primary metrics:** Cost per install (CPI), Install rate

1. **Benchmark CPI:** Use `tiktok_ads_get_performance_report` with `level: "campaign"` for cost-per-conversion data
2. **Creative impact:** Use `level: "ad"` to identify which creatives drive the most installs
3. **Audience fit:** Use `tiktok_ads_get_insights` with `report_type: "AUDIENCE"` to find demographics with highest install rates
4. **Guidance:** Focus on creatives that demonstrate the app experience; in-app footage and UGC reviews perform well

### Conversion Optimization

**Primary metrics:** Cost per conversion, Conversion rate

1. **Campaign comparison:** Use `tiktok_ads_get_performance_report` with `level: "campaign"` to compare conversion efficiency
2. **Ad group analysis:** Use `level: "adgroup"` to compare targeting strategies
3. **Creative impact:** Use `level: "ad"` and `tiktok_ads_get_creative_report` to identify top-converting creatives
4. **Guidance:** Ensure the pixel/events API is tracking correctly; allow campaigns to exit the learning phase (~50 conversions) before making major changes

### Brand Awareness Optimization

**Primary metrics:** CPM, Reach, Video views

1. **Benchmark CPM:** Use `tiktok_ads_get_performance_report` with `level: "campaign"` to establish reach efficiency
2. **Video engagement:** Use `tiktok_ads_get_creative_report` to measure how deeply audiences engage with the brand message
3. **Audience reach:** Use `tiktok_ads_get_insights` with `report_type: "AUDIENCE"` to check demographic reach distribution
4. **Guidance:** Maximize reach through broad targeting; focus on video completion rates to ensure the brand message is seen

### Video Views Optimization

**Primary metrics:** Cost per view, Video completion rate, Average watch time

1. **View efficiency:** Use `tiktok_ads_get_performance_report` with `level: "campaign"` for cost-per-view data
2. **Completion analysis:** Use `tiktok_ads_get_creative_report` to compare completion funnels across creatives
3. **Audience engagement:** Use `tiktok_ads_get_insights` with `report_type: "AUDIENCE"` to find demographics that watch longest
4. **Guidance:** Optimize for 6-second views as a quality signal; test different video lengths and hook styles

---

## See Also

- **references/workflows/campaign-performance.md** — Campaign-level performance analysis
- **references/workflows/creative-performance.md** — Video and creative performance analysis
- **references/workflows/audience-insights.md** — Audience demographic analysis
