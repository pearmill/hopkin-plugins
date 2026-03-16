# Common Actions Workflows

This document covers write operation handling and performance optimization recommendations for Meta Ads.

## Table of Contents

1. [Unsupported Write Operations](#unsupported-write-operations)
2. [Performance Optimization Recommendations](#performance-optimization-recommendations)

---

## Unsupported Write Operations

The Hopkin Meta Ads MCP is **read-only**. The following operations are **not available**:

- Creating campaigns, ad sets, or ads
- Updating budgets or bid strategies
- Pausing, resuming, or archiving campaigns/ad sets/ads
- Modifying targeting parameters
- Updating ad creative

### When a User Requests a Write Operation

When a user asks to create, update, pause, delete, or otherwise modify Meta Ads objects, follow this workflow:

#### Step 1: Inform the User

Let the user know that write operations are not yet available via the Hopkin Meta Ads MCP:

> Write operations (create, update, pause, delete) are not yet available through the Hopkin Meta Ads MCP. I've submitted a feature request on your behalf so the team knows this capability is needed.

#### Step 2: Submit Developer Feedback

Call `meta_ads_developer_feedback` to log the request as a workflow gap:

```json
{
  "tool": "meta_ads_developer_feedback",
  "parameters": {
    "reason": "User requested a write operation that is not yet supported",
    "feedback_type": "workflow_gap",
    "title": "[Description of the write operation]",
    "description": "[What the user was trying to do, including specific details like campaign names, budget amounts, status changes, etc.]",
    "priority": "[low/medium/high based on user's urgency]"
  }
}
```

**Examples of write operation feedback:**

**Creating a campaign:**
```json
{
  "reason": "User wants to create a new campaign",
  "feedback_type": "workflow_gap",
  "title": "Create new campaign",
  "description": "User wanted to create a new Sales campaign named 'Spring Sale 2026' with a $100/day budget in account act_123456789.",
  "priority": "high"
}
```

**Updating a budget:**
```json
{
  "reason": "User wants to update campaign budget",
  "feedback_type": "workflow_gap",
  "title": "Update campaign budget",
  "description": "User wanted to increase daily budget from $100 to $150 for campaign 'Summer Sale 2026' (ID: 123456789).",
  "priority": "high"
}
```

**Pausing a campaign:**
```json
{
  "reason": "User wants to pause a campaign",
  "feedback_type": "workflow_gap",
  "title": "Pause campaign",
  "description": "User wanted to pause campaign 'Old Summer Sale' (ID: 123456789) because the promotion has ended.",
  "priority": "medium"
}
```

#### Step 3: Provide Manual Guidance

Guide the user on how to perform the action manually via Meta Ads Manager:

**For Creating Campaigns:**
> To create this campaign manually:
> 1. Go to [Meta Ads Manager](https://adsmanager.facebook.com)
> 2. Click "+ Create" to start a new campaign
> 3. Select your campaign objective
> 4. Configure your ad set targeting, budget, and schedule
> 5. Add your ad creative
> 6. Review and publish

**For Updating Budgets:**
> To update the budget manually:
> 1. Go to [Meta Ads Manager](https://adsmanager.facebook.com)
> 2. Find the campaign/ad set you want to update
> 3. Click the budget column to edit inline, or click into the campaign settings
> 4. Update the daily or lifetime budget
> 5. Save changes

**For Pausing/Resuming:**
> To pause or resume manually:
> 1. Go to [Meta Ads Manager](https://adsmanager.facebook.com)
> 2. Find the campaign, ad set, or ad
> 3. Toggle the status switch to pause or activate

---

## Performance Optimization Recommendations

### When to Use

Use these recommendations when analyzing reports to identify and address performance issues. These are purely advisory — no write tool calls are needed.

### Low ROAS (Return on Ad Spend)

**Symptoms:**
- ROAS below target or industry benchmark
- Spending budget but not generating proportional revenue
- Conversion value doesn't justify ad spend

**Recommended Actions:**

1. **Review Targeting:**
   - Is audience too broad or poorly defined?
   - Are you reaching people likely to convert?
   - Consider narrowing to higher-intent audiences
   - Review audience insights to identify high-performing segments

2. **Analyze Creative Performance:**
   - Are ads compelling and relevant?
   - Test new creative variations
   - Check creative fatigue (declining CTR)
   - Align creative with audience interests

3. **Adjust Bid Strategy:**
   - May be bidding too high for low-value conversions
   - Consider switching to value optimization
   - Adjust target ROAS in bid strategy

4. **Examine Conversion Funnel:**
   - Is landing page optimized?
   - Are there drop-off points in checkout?
   - Check for technical issues preventing conversions
   - Consider conversion rate optimization (CRO) on website

### High CPC (Cost Per Click)

**Symptoms:**
- CPC significantly above account or industry average
- Budget depleting quickly with fewer clicks
- High competition for target audience

**Recommended Actions:**

1. **Improve Ad Relevance:**
   - Ensure ad copy matches user intent
   - Improve relevance score/quality ranking
   - Better alignment between ad and landing page

2. **Refine Audience:**
   - May be targeting overly competitive audience
   - Narrow or adjust targeting to reduce competition
   - Test lookalike audiences or interest refinement

3. **Test Different Placements:**
   - Some placements may be more expensive
   - Test automatic vs. manual placement
   - Exclude high-cost, low-value placements

4. **Review Landing Page Experience:**
   - Slow landing pages increase costs
   - Poor mobile experience raises CPC
   - Improve page speed and user experience

### Low CTR (Click-Through Rate)

**Symptoms:**
- CTR below industry benchmarks
- High impressions but few clicks
- Ads being shown but not engaging users

**Recommended Actions:**

1. **Test New Creative Hooks:**
   - Stronger headlines that grab attention
   - More compelling value propositions
   - Address pain points or desires directly
   - Use urgency or scarcity when appropriate

2. **Improve Visual Appeal:**
   - Test different images or videos
   - Ensure creative stands out in feed
   - Use high-quality, professional assets
   - Consider different ad formats (video vs. image vs. carousel)

3. **Refine Targeting:**
   - May be showing to uninterested audience
   - Narrow to more relevant audience segments
   - Exclude audiences unlikely to engage
   - Test different interest or behavioral targets

4. **Strengthen Call-to-Action:**
   - Test different CTA buttons
   - Make desired action clearer
   - Provide compelling reason to click
   - Consider offers or incentives

### Campaigns Underspending Budget

**Symptoms:**
- Not spending full allocated budget
- Daily budget cap not being reached
- "Budget underutilized" status

**Recommended Actions:**

1. **Expand Audience Size:**
   - Target audience may be too small
   - Broaden targeting criteria (age, location, interests)
   - Add lookalike audiences
   - Test expansion into new segments

2. **Increase Bid Amounts:**
   - Bids may be too low to compete in auction
   - Raise bids to increase competitiveness
   - Consider switching to higher bid strategy

3. **Add More Ad Placements:**
   - Enable automatic placements
   - Manually add more placement options
   - Include Audience Network, Stories, Reels

4. **Check Delivery Diagnostics:**
   - Review delivery issues in Meta Ads Manager
   - Address any restrictions or warnings
   - Verify creative is approved
   - Check for account-level limits

### Creative Fatigue

**Symptoms:**
- CTR declining over time
- Frequency increasing without reach growth
- Engagement metrics dropping
- ROAS or conversion rate decreasing

**Recommended Actions:**

1. **Rotate in Fresh Creative:**
   - Create new ads with different creative
   - Test entirely new concepts
   - Update visuals and copy
   - Keep successful hooks, refresh execution

2. **Test New Formats:**
   - Switch from image to video (or vice versa)
   - Try carousel or collection ads
   - Experiment with different aspect ratios
   - Use Stories or Reels format

3. **Adjust Messaging and Offers:**
   - Change value proposition angle
   - Introduce new offers or promotions
   - Seasonal or timely messaging
   - Address different pain points

4. **Expand or Refresh Audience:**
   - Add new audience segments
   - Exclude people who've seen ads many times
   - Create lookalike audiences of recent converters
   - Test cold audiences

### General Optimization Principles

1. **Test One Variable at a Time:**
   - Change creative OR targeting, not both simultaneously
   - Isolate what's causing improvement or decline

2. **Allow Learning Phase:**
   - Give campaigns 50+ conversions to exit learning
   - Avoid major changes during learning

3. **Use Data-Driven Decisions:**
   - Base recommendations on actual performance data
   - Compare to benchmarks and past performance
   - Ensure statistical significance before concluding

4. **Monitor After Changes:**
   - Watch performance for 24-48 hours after optimization
   - Be ready to roll back if performance declines
   - Document what worked and what didn't

---

## See Also

- **references/mcp-tools-reference.md** — Hopkin MCP tools reference
- **references/troubleshooting.md** — Common issues when using the MCP
- **references/report-types.md** — Metrics to monitor after making changes
