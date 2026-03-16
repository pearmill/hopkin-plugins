# Common Actions — Write Operations & Optimization Workflows

## Write Operations (Unsupported)

The Hopkin Reddit Ads MCP is **read-only**. When users request write operations, follow the workflow below.

### Write Operation Workflow

When a user requests a create, update, pause, or delete operation:

**Step 1: Inform the user**
> "Write operations (create, update, pause, delete) are not yet available via Hopkin's Reddit Ads MCP. You'll need to make this change directly in Reddit Ads Manager."

**Step 2: Guide the user to Reddit Ads Manager**

Direct them to perform the action manually via Reddit Ads Manager at https://ads.reddit.com

**Note:** There is no `reddit_ads_developer_feedback` tool available. If a write operation would be valuable, note it for future consideration but do not attempt to call a feedback tool.

### Common Write Operations

All performed manually in Reddit Ads Manager (https://ads.reddit.com):

- **Create Campaign** — Ads Manager -> Create Campaign
- **Pause/Resume Campaign** — Toggle status in Campaign list view
- **Adjust Budget** — Edit Campaign -> Budget section (note: budgets in Reddit Ads Manager are in standard currency, not micro units)
- **Create Ad Group** — Within Campaign setup -> Add Ad Group
- **Update Targeting** — Edit Ad Group -> Targeting section
- **Create Ad** — Within Ad Group -> Create Ad
- **Adjust Bids** — Edit Ad Group -> Bid section
- **Manage Custom Audiences** — Audiences section in Ads Manager

---

## Performance Optimization Recommendations

After analyzing performance data, provide actionable recommendations based on these patterns:

### Low CTR

**Investigation steps:**
1. Use `reddit_ads_get_performance_report` with `breakdown: ["ad"]` to identify underperforming creatives
2. Use `breakdown: ["community"]` to check if certain subreddits have particularly low CTR
3. Review ad group targeting with `reddit_ads_list_ad_groups` to assess audience fit

**Recommendations:**
- Test new creative that feels native to Reddit (conversational tone, authentic messaging)
- Adjust subreddit targeting — remove communities with consistently low CTR
- Review headline copy — Reddit users respond to informative, non-promotional language
- Ensure the creative format matches the subreddit's content style (e.g., image-heavy communities benefit from visual ads)

**Reddit CTR Benchmarks:**
- Feed ads: ~0.3%-0.8% average; 1%+ is strong
- Conversation placement: typically lower CTR but higher engagement
- Video ads: CTR varies widely by creative quality

### High CPC / Low Efficiency

**Investigation steps:**
1. Compare CPC across ad groups with `breakdown: ["ad_group"]`
2. Review subreddit performance with `breakdown: ["community"]` to find expensive placements
3. Check custom audience performance by filtering to specific ad group IDs

**Recommendations:**
- Shift budget to ad groups and subreddits with lower CPC
- Test broader targeting to increase competition pool and potentially lower costs
- Review bid strategy — manual CPC bidding may offer more control
- Refresh creative to improve quality score and relevance

### High Downvote Ratio

**Investigation steps:**
1. Use `breakdown: ["community"]` to identify which subreddits have the most downvotes
2. Use `breakdown: ["ad"]` to identify which creatives receive the most downvotes
3. Review ad group targeting to assess audience-content alignment

**Recommendations:**
- Rethink creative messaging — Reddit users reject overtly promotional content
- Adjust subreddit targeting — the content may not fit certain community cultures
- Test "value-first" creative that provides useful information before the CTA
- Consider using Reddit's native ad formats that blend with organic content

### Low Engagement (Few Upvotes/Comments)

**Investigation steps:**
1. Compare engagement metrics across creatives with `breakdown: ["ad"]`
2. Analyze community-level engagement with `breakdown: ["community"]`

**Recommendations:**
- Create content that sparks discussion — ask questions, share insights, provide value
- Target subreddits where the topic is actively discussed
- Use conversational headlines that invite participation
- Test different creative formats (carousel, video, text-focused)

### Budget Not Spending (Underspend)

**Investigation steps:**
1. Use `reddit_ads_list_campaigns` to check campaign status and budget settings
2. Use `reddit_ads_list_ad_groups` to verify ad groups are active with valid targeting
3. Review targeting breadth — narrow targeting may limit delivery

**Recommendations:**
- Expand subreddit targeting to reach more communities
- Broaden interest or keyword targeting
- Increase bid amounts to be more competitive in the auction
- Verify all ad groups are approved and active in Reddit Ads Manager
- Check that target audience size is sufficient for the budget

---

## Cross-Platform Comparison Guidance

When users manage ads across multiple platforms, help them compare Reddit performance in context:

### Reddit vs. Meta (Facebook/Instagram)

| Dimension | Reddit | Meta |
|---|---|---|
| Primary targeting | Subreddits, interests, keywords | Demographics, interests, lookalikes |
| Engagement signals | Upvotes, downvotes, comments | Likes, comments, shares |
| Audience intent | Interest-based (community self-selection) | Behavior-based (algorithmic) |
| Creative style | Native, conversational, value-driven | Visual-first, broad appeal |
| Budget format | Micro units (API) | Standard currency |
| Date parameters | `date_start`/`date_end` | `date_preset` or `start_date`/`end_date` |

### Reddit vs. Google Ads

| Dimension | Reddit | Google |
|---|---|---|
| Primary targeting | Subreddits, interests | Keywords, audiences, topics |
| Funnel position | Mid-to-top funnel (awareness, consideration) | Full funnel (search captures intent) |
| Creative format | Promoted posts, video, carousel | Text ads, display, video, shopping |
| Engagement signals | Upvotes, downvotes, comments | CTR, quality score |

### Reddit vs. LinkedIn Ads

| Dimension | Reddit | LinkedIn |
|---|---|---|
| Primary targeting | Subreddits, interests, keywords | Job title, industry, company size |
| Audience type | Interest-based communities | Professional demographics |
| Demographic data | Not available via API | MEMBER_* pivots available |
| Engagement signals | Upvotes, downvotes, comments | Social actions, Lead Gen Forms |
| Token handling | Auto-refresh (1-hour expiry) | 60-day expiry (manual reconnect) |
| Budget format | Micro units (API) | Standard currency |

### Cross-Platform Analysis Tips

1. **Normalize metrics** — When comparing CPC or CPM across platforms, ensure you're comparing like-for-like (same conversion events, similar audiences)
2. **Account for platform strengths** — Reddit excels at reaching niche interest communities; don't expect it to match Meta's scale or Google's intent signals
3. **Consider engagement quality** — Reddit's upvotes and comments indicate genuine audience interest, which may translate to higher downstream conversion quality
4. **Budget unit conversion** — Reddit API uses micro units (divide by 1,000,000); ensure all platforms are in the same currency unit when comparing

---

## Optimization Workflow by Campaign Objective

### Traffic Optimization

**Primary metric:** CPC, CTR

1. **Benchmark CPC:** Use `reddit_ads_get_performance_report` with `breakdown: ["campaign"]`
2. **Creative analysis:** Use `breakdown: ["ad"]` to find highest-CTR ads
3. **Community analysis:** Use `breakdown: ["community"]` to find most cost-efficient subreddits
4. **Guidance:** Direct user to Reddit Ads Manager to pause underperforming ad groups and increase budget on top performers

### Awareness Optimization

**Primary metric:** CPM, Impressions

1. **Benchmark CPM:** Use account summary to establish baseline
2. **Community reach:** Use `breakdown: ["community"]` to see which subreddits provide the most reach
3. **Trend analysis:** Use `breakdown: ["campaign", "date"]` to track delivery pace
4. **Guidance:** For maximum reach, suggest broader targeting across related subreddits

### Conversions Optimization

**Primary metric:** CPA, Conversion Rate

1. **Campaign comparison:** Use `breakdown: ["campaign"]` to compare conversion efficiency
2. **Targeting analysis:** Use `breakdown: ["ad_group"]` to compare targeting strategies
3. **Creative impact:** Use `breakdown: ["ad"]` to identify top-converting creatives
4. **Guidance:** Focus budget on ad groups with lowest CPA; suggest testing lookalike audiences built from converters

### Engagement Optimization

**Primary metric:** Upvotes, Comments, Engagement Rate

1. **Creative engagement:** Use `breakdown: ["ad"]` to find most-engaged creatives
2. **Community engagement:** Use `breakdown: ["community"]` to find most responsive subreddits
3. **Trend analysis:** Use `breakdown: ["community", "date"]` to track engagement trends
4. **Guidance:** High-engagement content often works best when it feels organic to the subreddit

---

## See Also

- **references/workflows/campaign-performance.md** — Campaign performance analysis
- **references/workflows/community-insights.md** — Subreddit-level performance analysis
- **references/workflows/audience-targeting.md** — Audience and targeting analysis
- **references/troubleshooting.md** — Common issues and solutions
