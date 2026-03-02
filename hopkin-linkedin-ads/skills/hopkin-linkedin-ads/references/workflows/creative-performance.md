# Creative Performance Report Workflow

## When to Use

Use this workflow to evaluate LinkedIn ad creative effectiveness, compare different creatives within a campaign, identify best-performing headlines and ad copy, analyze engagement and CTR across creative variations, and inform future creative strategy.

## Required Information

- **Ad Account ID** — Numeric (e.g., `123456789`)
- **Date range** — Preset or custom (minimum 14 days recommended for reliable CTR data)
- **Optional:** Campaign IDs to filter to specific campaigns

## Detailed Workflow

### Step 1: List Creatives and Their Content

Use `linkedin_ads_list_creatives` with `resolve_content: true` to get both creative IDs and their actual ad copy:

```json
{
  "tool": "linkedin_ads_list_creatives",
  "parameters": {
    "reason": "Listing active creatives with ad copy content for creative analysis",
    "account_id": 123456789,
    "status": "ACTIVE",
    "resolve_content": true
  }
}
```

**Filter to a specific campaign:**
```json
{
  "tool": "linkedin_ads_list_creatives",
  "parameters": {
    "reason": "Listing creatives for the Q1 Lead Gen campaign",
    "account_id": 123456789,
    "campaign_ids": ["111222333"],
    "resolve_content": true
  }
}
```

This returns each creative with:
- `creative_id` — Numeric ID for joining with analytics
- `headline` — Ad headline
- `body_text` — Ad copy body
- `destination_url` — Landing page URL
- `status` — Current intended status

### Step 2: Get Creative Performance Metrics

Use `linkedin_ads_get_performance_report` with `pivots: ["CREATIVE"]`:

```json
{
  "tool": "linkedin_ads_get_performance_report",
  "parameters": {
    "reason": "Getting creative-level performance metrics for creative analysis",
    "account_id": 123456789,
    "pivots": ["CREATIVE"],
    "date_preset": "LAST_30_DAYS"
  }
}
```

**Filter to specific campaigns:**
```json
{
  "tool": "linkedin_ads_get_performance_report",
  "parameters": {
    "reason": "Creative performance for the Lead Gen campaign",
    "account_id": 123456789,
    "pivots": ["CREATIVE"],
    "date_preset": "LAST_30_DAYS",
    "campaign_ids": ["111222333"]
  }
}
```

### Step 3: Join Creative Content with Performance Data

Match creative IDs from `list_creatives` with the performance data from `get_performance_report` to create a unified view:

```
Creative Analysis Table:
Creative ID | Headline | Spend | Impressions | CTR | Leads | CPA
12345       | "Free Trial..." | $450 | 45,678 | 2.8% | 12 | $37.50
12346       | "Boost Revenue..." | $380 | 52,100 | 1.2% | 5 | $76.00
12347       | "See How..." | $620 | 89,450 | 3.4% | 19 | $32.63
```

### Step 4: Key Creative Metrics

**Engagement Metrics:**
- `impressions` — Total ad displays
- `clicks` — Total link clicks
- `ctr` — Click-through rate (primary indicator of creative resonance)

**Cost Efficiency Metrics:**
- `spend` — Total spend on this creative
- `cpc` — Cost per click (lower = more efficient click generation)
- `cpm` — Cost per 1,000 impressions (delivery efficiency)

**Conversion Metrics:**
- `conversions` — Downstream conversions attributed to creative
- `leads` — LinkedIn Lead Gen Form submissions (native LinkedIn conversion)
- `cpa` — Cost per acquisition
- `roas` — Return on ad spend (where conversion value is tracked)

**Video Metrics (for video creatives):**
- `video_views` — Number of video plays
- `video_completions` — Full video watches (strong engagement signal)
- Video completion rate = `video_completions` / `video_views`

### Step 5: Sort and Rank

Sort creatives by the primary KPI based on campaign objective:

- **Lead generation:** Sort by leads, then CPA
- **Website visits:** Sort by CTR, then CPC
- **Brand awareness:** Sort by impressions, then CPM
- **Video engagement:** Sort by video completion rate

### Step 6: Present Results

**Example Table:**
```
Creative Performance Report
Ad Account: 123456789
Date Range: Last 30 Days
Campaign: Q1 Lead Gen

| Headline (truncated)       | Spend  | Impr.  | CTR  | Leads | CPA    |
|----------------------------|--------|--------|------|-------|--------|
| "See How [Company] Boosted…"| $620   | 89,450 | 3.4% | 19    | $32.63 |
| "Free Trial — No CC…"      | $450   | 45,678 | 2.8% | 12    | $37.50 |
| "Boost Your Revenue by 30%…"| $380  | 52,100 | 1.2% | 5     | $76.00 |
```

### Step 7: Identify Insights

**Creative Winners:**
- Highest CTR — Ad copy that generates the most interest/clicks
- Lowest CPA — Most cost-efficient lead or conversion generators
- Best video completion rate — Most engaging video content

**Creative Fatigue Signals:**
- CTR declining over time while impressions remain stable
- Frequency increasing significantly (the same people seeing the same ad repeatedly)
- CPA rising while spend stays flat

**Copy Analysis Insights:**
- Do question-based headlines outperform statement headlines?
- Do benefit-led headlines outperform feature-led headlines?
- Do social proof elements (numbers, customer names) improve performance?
- Does CTA wording (Free Trial vs. Learn More vs. Download) affect conversion rate?

## LinkedIn Creative Best Practices

### Sponsored Content (Single Image)
- Recommended headline length: Under 70 characters
- Body text: 150 characters or less for mobile display
- Strong image with minimal text overlay
- Clear, single CTA

### Text Ads
- Headline: 25 characters max
- Description: 75 characters max
- Small 50×50 pixel thumbnail

### Sponsored InMail / Message Ads
- Subject line: 60 characters max (drives open rate)
- Body: 500 characters recommended; 1,000 max
- CTA button text: 20 characters max

### Video Ads
- Optimal length: 15–30 seconds for brand awareness; longer for consideration campaigns
- Include captions (most LinkedIn video is watched without sound)
- First 3 seconds must grab attention

## Common Analysis Patterns

### A/B Creative Analysis
When two creatives are directly competing:

1. Ensure both creatives have sufficient spend ($100+ each) before drawing conclusions
2. Compare CTR, CPA, and lead volume
3. Check if performance difference is statistically meaningful (not just noise)
4. Note if the audiences are identical — differences in targeting can skew creative comparisons

### Creative Lifecycle Analysis
Using `time_granularity: "DAILY"`:

```json
{
  "tool": "linkedin_ads_get_performance_report",
  "parameters": {
    "reason": "Tracking CTR trend for a creative to detect fatigue",
    "account_id": 123456789,
    "pivots": ["CREATIVE"],
    "date_preset": "LAST_30_DAYS",
    "time_granularity": "DAILY",
    "campaign_ids": ["111222333"]
  }
}
```

A steady CTR decline over time with stable impression volume is a strong creative fatigue signal.

## Best Practices

1. **Use `resolve_content: true`** — Always pass this when listing creatives to get actual ad copy, not just IDs
2. **Match creatives to campaigns** — Use `campaign_ids` filter in both tools for apples-to-apples comparison
3. **Account for learning period** — New creatives need 7–14 days and sufficient impressions before performance stabilizes
4. **Consider format differences** — Don't compare video CTR to static image CTR directly; they have different benchmarks
5. **Monitor frequency** — High ad frequency (5+) often correlates with CTR decline and creative fatigue
6. **LinkedIn CTR benchmarks** — LinkedIn average CTR is ~0.4–0.6%; 1%+ CTR is strong; 2%+ is excellent for Sponsored Content

## See Also

- **references/mcp-tools-reference.md** — Complete Hopkin MCP tools reference
- **references/workflows/campaign-performance.md** — Campaign-level performance workflow
- **references/workflows/demographic-insights.md** — Who's responding to your creatives by job function, seniority, etc.
- **references/troubleshooting.md** — Common issues and solutions
