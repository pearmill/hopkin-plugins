# Common Actions — Write Operations & Optimization Workflows

## Write Operations (Unsupported)

The Hopkin LinkedIn Ads MCP is **read-only**. When users request write operations, follow the workflow below.

### Write Operation Feedback Workflow

When a user requests a create, update, pause, or delete operation:

**Step 1: Inform the user**
> "Write operations (create, update, pause, delete) are not yet available via Hopkin's LinkedIn Ads MCP. I'll log this as a feature request."

**Step 2: Submit developer feedback**
```json
{
  "tool": "linkedin_ads_developer_feedback",
  "parameters": {
    "reason": "User requested a write operation not yet supported by the MCP",
    "feedback_type": "workflow_gap",
    "title": "[Brief description of the write operation]",
    "description": "User wanted to [specific action]. Write operations are not yet available via the Hopkin LinkedIn Ads MCP.",
    "current_workaround": "Directed user to LinkedIn Campaign Manager to perform action manually",
    "priority": "high"
  }
}
```

**Step 3: Guide the user to LinkedIn Campaign Manager**

Direct them to perform the action manually via LinkedIn Campaign Manager at https://www.linkedin.com/campaignmanager/

### Common Write Operations

All performed manually in LinkedIn Campaign Manager (https://www.linkedin.com/campaignmanager/):
- **Create Campaign Group/Campaign** — Campaign Manager → Create
- **Pause/Resume** — Toggle status switch on Campaign Group
- **Update Budget** — Edit pencil icon on Campaign Group budget
- **Create Creative** — Account Assets → Creatives, or within Campaign setup
- **Adjust Bids** — Edit Campaign → Bid section. Use `linkedin_ads_get_budget_pricing` for recommended ranges

---

## Performance Optimization Recommendations

After analyzing performance data, provide actionable recommendations based on these patterns:

### Low ROAS / High CPA

**Investigation steps:**
1. Use `linkedin_ads_get_insights` with `MEMBER_JOB_FUNCTION` and `MEMBER_SENIORITY` to identify inefficient audience segments
2. Use `linkedin_ads_get_performance_report` with `pivots: ["CREATIVE"]` to identify underperforming creatives
3. Call `linkedin_ads_get_partner_conversions` to verify conversion tracking is correct

**Recommendations:**
- Exclude audience segments with CPA > 2× target (use demographic insights to identify)
- Pause creatives with CPA significantly above account average
- Review conversion tracking — verify partner conversions are correctly configured
- Check if the landing page experience matches the ad promise
- Narrow targeting to highest-converting job functions/industries identified via `MEMBER_*` pivots

### Low CTR

**Investigation steps:**
1. Compare creative CTR with `linkedin_ads_get_performance_report` at `CREATIVE` pivot
2. Check seniority and job function with `MEMBER_SENIORITY` and `MEMBER_JOB_FUNCTION` — are you reaching the right audience?

**Recommendations:**
- Test new headlines — question-based vs. benefit-led vs. data-driven
- Refresh images — LinkedIn Sponsored Content competes with organic feed posts
- Ensure creative is relevant to target audience's specific pain points
- For Text Ads: test different thumbnail images (high-contrast, people vs. product)
- Review audience targeting — too broad may dilute relevance

**LinkedIn CTR Benchmarks:**
- Text Ads: ~0.025%–0.08%
- Sponsored Content: ~0.4%–0.6% average; 1%+ is strong; 2%+ is excellent
- Message Ads open rate: ~30%–50%

### Budget Not Spending (Underspend)

**Investigation steps:**
1. Use `linkedin_ads_list_campaign_groups` and `linkedin_ads_list_campaigns` to check status
2. Use `linkedin_ads_get_budget_pricing` to compare current bids to recommended ranges

**Recommendations:**
- Increase bids — LinkedIn's minimum competitive CPC is often $2–$5+ for professional audiences
- Expand audience — add more job functions, industries, or geographic regions
- Check creative approval status in Campaign Manager
- Verify the campaign group is active and not paused

### Creative Fatigue

**Signs:** CTR declining over time while impressions remain stable; frequency increasing

**Investigation:**
1. Use `linkedin_ads_get_performance_report` with `pivots: ["CREATIVE"]` and `time_granularity: "DAILY"` to track CTR trend over time
2. If CTR has dropped 30%+ over 2+ weeks with consistent delivery, fatigue is likely

**Recommendations:**
- Introduce new creative variations (at least 2–3 per campaign)
- Rotate creative assets every 4–6 weeks for most LinkedIn audiences
- Test new messaging angles or visual approaches
- Consider refreshing to seasonal or timely content

### High Frequency

**What it means:** LinkedIn does not natively provide frequency in all analytics tools, but if you're seeing declining CTR and high spend with a small audience, frequency is likely rising.

**Recommendations:**
- Expand audience to reduce frequency
- Rotate creatives more frequently
- Check if audience size is large enough for the allocated budget

---

## Optimization Workflows by Campaign Objective

### Lead Generation Optimization

**Primary metric:** Cost per lead (CPL)

1. **Benchmark current CPL:** Use `linkedin_ads_get_performance_report` at CAMPAIGN_GROUP level
2. **Identify audience efficiency:** Use `MEMBER_JOB_FUNCTION` and `MEMBER_SENIORITY` to find lowest-CPL segments
3. **Creative analysis:** Use `CREATIVE` pivot to find lowest-CPL creatives
4. **LinkedIn Lead Gen Form optimization:** If using native forms, check form completion rate in Campaign Manager (not available in MCP analytics); high drop-off may indicate form is too long
5. **Guidance:** For manual form optimization, direct user to Campaign Manager → Creatives → Lead Gen Forms

### Brand Awareness Optimization

**Primary metric:** CPM (cost per 1,000 impressions), Impression share

1. **Benchmark CPM:** Use `linkedin_ads_get_performance_report` with ACCOUNT pivot
2. **Industry breakdown:** Use `MEMBER_INDUSTRY` to see where impressions are being served
3. **Geographic analysis:** Use `MEMBER_COUNTRY` to see which markets are driving volume
4. **Budget bidding:** Use `linkedin_ads_get_budget_pricing` with `bid_type: "CPM"` to validate CPM competitiveness

### Website Traffic Optimization

**Primary metric:** CPC, CTR

1. **Creative CTR:** Use `CREATIVE` pivot to find highest-CTR ads
2. **Audience CTR:** Use `MEMBER_JOB_FUNCTION` and `MEMBER_COMPANY_SIZE` to find segments with best CTR
3. **Bid optimization:** Use `linkedin_ads_get_budget_pricing` with `bid_type: "CPC"` to validate bids are in recommended range

---

## Proactive Efficiency Feedback

After completing tasks, if a faster workflow would have been possible, submit feedback:

```json
{
  "tool": "linkedin_ads_developer_feedback",
  "parameters": {
    "reason": "Proactive efficiency feedback after completing user's request",
    "feedback_type": "new_tool",
    "title": "[Missing capability]",
    "description": "User asked for [goal]. I needed to [multiple steps]. A tool that [solution] would save [time/effort].",
    "current_workaround": "Called [N] tools and merged results manually",
    "priority": "medium"
  }
}
```

**Common efficiency gaps to report:**
- Having to join `list_creatives` with `get_performance_report` manually to get creative copy + metrics
- Needing multiple `MEMBER_*` pivot calls to get a full demographic picture (no combined pivot)
- Needing to call `list_campaign_groups` + analytics to get budget + performance in one view

---

## See Also

- **references/mcp-tools-reference.md** — Complete Hopkin MCP tools reference
- **references/workflows/campaign-performance.md** — Campaign performance analysis
- **references/workflows/demographic-insights.md** — Audience optimization via MEMBER_* pivots
- **references/workflows/creative-performance.md** — Creative analysis and optimization
- **references/workflows/budget-pacing.md** — Budget and bid optimization
- **references/troubleshooting.md** — Common issues and solutions
