# Audience & Targeting Analysis Workflow

## When to Use

Use this workflow to review and analyze audience targeting configuration, evaluate custom audience inventory, compare audience performance across ad groups, and optimize targeting strategy for Reddit Ads campaigns.

## Required Information

- **Ad Account ID** — Plain string (e.g., `"t2_abc123"`)
- **Date range** — `date_start` and `date_end` in `YYYY-MM-DD` format (for performance cross-referencing)
- **Optional:** Campaign IDs or ad group IDs to narrow the analysis

## Reddit Targeting Types

Reddit offers several targeting dimensions:

| Targeting Type | Description | Key Notes |
|---|---|---|
| **Subreddit / Community** | Target specific subreddits | Most info-dense; unique to Reddit |
| **Interest** | Target by interest category | 152 predefined categories |
| **Keyword** | Target by keyword in post titles | Captures intent signals |
| **Custom Audiences** | Upload or build audience lists | Customer list, retargeting, lookalike |
| **Location** | Geographic targeting | Country, region, metro |
| **Device** | Target by device type | Desktop, mobile, app |

## Detailed Workflow

### Step 1: Review Custom Audience Inventory

Use `reddit_ads_list_custom_audiences` to see all available audiences:

```json
{
  "tool": "reddit_ads_list_custom_audiences",
  "parameters": {
    "reason": "Reviewing all custom audiences available in the account",
    "account_id": "t2_abc123"
  }
}
```

This returns all custom audiences with their type, size, and status. Reddit custom audience types include:

- **Customer List** — Uploaded email or device ID lists
- **Retargeting** — Users who visited your site, viewed a page, or took an action
- **Lookalike** — Audiences similar to a seed audience

**Lookalike Audience Requirements:**
- Retargeting seed: minimum **10,000 users**
- Customer list seed: minimum **1,000 users**

### Step 2: Review Ad Group Targeting Configuration

Use `reddit_ads_list_ad_groups` to see targeting settings per ad group:

```json
{
  "tool": "reddit_ads_list_ad_groups",
  "parameters": {
    "reason": "Reviewing targeting configuration for all ad groups in the campaign",
    "account_id": "t2_abc123",
    "campaign_id": "campaign_123"
  }
}
```

Ad groups contain the full targeting configuration, including:
- Subreddit/community targeting (which subreddits are selected)
- Interest targeting categories
- Keyword targeting lists
- Custom audience assignments
- Location and device targeting
- Bid and budget settings

**Subreddit targeting is the most information-dense** — it tells you exactly which communities the ads are reaching.

### Step 3: Cross-Reference Audiences with Performance

Filter performance reports by ad group to compare how different targeting strategies perform:

```json
{
  "tool": "reddit_ads_get_performance_report",
  "parameters": {
    "reason": "Comparing performance across ad groups with different targeting strategies",
    "account_id": "t2_abc123",
    "breakdown": ["ad_group"],
    "date_start": "2026-02-01",
    "date_end": "2026-02-28",
    "campaign_ids": ["campaign_123"]
  }
}
```

To compare specific ad groups:

```json
{
  "tool": "reddit_ads_get_performance_report",
  "parameters": {
    "reason": "Comparing performance of interest-targeted vs subreddit-targeted ad groups",
    "account_id": "t2_abc123",
    "breakdown": ["ad_group"],
    "date_start": "2026-02-01",
    "date_end": "2026-02-28",
    "ad_group_ids": ["adgroup_456", "adgroup_789"]
  }
}
```

### Step 4: Analyze Community-Level Targeting Effectiveness

Use the community breakdown to see which targeted subreddits deliver results:

```json
{
  "tool": "reddit_ads_get_performance_report",
  "parameters": {
    "reason": "Analyzing which targeted subreddits drive the best performance",
    "account_id": "t2_abc123",
    "breakdown": ["community"],
    "date_start": "2026-02-01",
    "date_end": "2026-02-28",
    "campaign_ids": ["campaign_123"]
  }
}
```

Cross-reference the subreddit performance data with the ad group targeting configuration from Step 2 to identify:
- Which explicitly targeted subreddits are performing well
- Which subreddits are underperforming despite being targeted
- Opportunities to add high-performing subreddits to other ad groups

### Step 5: Present Targeting Analysis

Create a comparison view:

**By Targeting Strategy (Ad Group Level):**

| Ad Group | Targeting Type | Impressions | Clicks | CTR | CPC | Upvotes | Spend |
|---|---|---|---|---|---|---|---|
| Interest - Tech | Interest | 40,000 | 800 | 2.0% | $1.00 | 120 | $800 |
| Subreddit - Tech | Community | 25,000 | 750 | 3.0% | $0.80 | 200 | $600 |
| Keyword - SaaS | Keyword | 15,000 | 450 | 3.0% | $0.90 | 80 | $405 |
| Retargeting | Custom | 5,000 | 400 | 8.0% | $0.50 | 60 | $200 |

**By Custom Audience:**

| Audience | Type | Size | Status | Ad Groups Using |
|---|---|---|---|---|
| Site Visitors 30d | Retargeting | 25,000 | Active | 2 |
| Email Subscribers | Customer List | 8,500 | Active | 1 |
| Lookalike - Converters | Lookalike | 500,000 | Active | 3 |

**Remember:** Spend values from the API are in micro units — divide by 1,000,000.

## Targeting Optimization Recommendations

### Subreddit Targeting

- **Expand:** Add subreddits similar to top performers
- **Narrow:** Remove subreddits with high spend but low engagement (especially those with high downvote ratios)
- **Test:** Create separate ad groups for broad interest targeting vs. specific subreddit targeting to compare

### Interest Targeting

Reddit offers **152 interest categories**. When analyzing:
- Compare interest-targeted ad groups against subreddit-targeted ones
- Interest targeting typically reaches broader audiences but may be less precise
- Use interest targeting for discovery, then refine to specific subreddits

### Keyword Targeting

- Review which keywords drive clicks vs. impressions
- Keyword targeting captures intent from post titles — useful for product-specific campaigns
- Combine with subreddit targeting for maximum precision

### Custom Audiences

- **Retargeting:** Typically highest CTR and lowest CPC; ensure pixel is properly configured
- **Customer Lists:** Good for re-engagement; minimum 1,000 users for lookalike creation
- **Lookalike:** Broader reach than retargeting; monitor performance closely as audience quality can vary

## Best Practices

1. **Start with subreddit analysis** — Community targeting is Reddit's strongest signal; always review subreddit performance first
2. **Compare targeting strategies** — Run parallel ad groups with different targeting types to identify the most efficient approach
3. **Check audience sizes** — Ensure custom audiences meet minimum requirements (10K for retargeting lookalikes, 1K for customer list lookalikes)
4. **Layer targeting dimensions** — Combine subreddit targeting with interest or keyword targeting for refined audiences
5. **Monitor engagement metrics** — Upvotes and downvotes are strong signals of audience-content fit; high downvotes indicate targeting mismatch
6. **Respect rate limits** — Reddit enforces ~1 request per second; batch your targeting analysis queries efficiently

## See Also

- **references/workflows/community-insights.md** — Deep subreddit-level performance analysis
- **references/workflows/campaign-performance.md** — Overall campaign performance analysis
- **references/workflows/common-actions.md** — Write operations and optimization guidance
- **references/troubleshooting.md** — Common issues and solutions
