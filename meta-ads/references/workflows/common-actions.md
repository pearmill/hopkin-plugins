# Common Actions Workflows

This document provides detailed workflows for common Meta Ads management operations beyond reporting.

## Table of Contents

1. [Creating Campaigns](#creating-campaigns)
2. [Updating Budgets](#updating-budgets)
3. [Pausing and Resuming Ads](#pausing-and-resuming-ads)
4. [Performance Optimization Recommendations](#performance-optimization-recommendations)

---

## Creating Campaigns

### When to Use

Use this workflow when creating a new advertising campaign from scratch.

### Required Information

Before creating a campaign, confirm you have:

**Essential Parameters:**
- **Campaign name** - Descriptive name (e.g., "Q1 2026 Product Launch")
- **Objective** - Campaign goal from Meta's objective types
- **Ad Account ID** - Target account (format: act_XXXXXXXXXXXXX)

**Optional Parameters:**
- **Special ad categories** - Required for certain industries (credit, employment, housing)
- **Status** - Initial state (ACTIVE or PAUSED) - recommended to start PAUSED
- **Budget** - Daily or lifetime budget
- **Bid strategy** - How to optimize bidding
- **Start/end dates** - Campaign schedule

### Campaign Objectives

Choose the appropriate objective based on business goal:

**Awareness Objectives:**
- **OUTCOME_AWARENESS** - Maximize reach and brand awareness
- **REACH** - Show ads to maximum number of people
- **BRAND_AWARENESS** - Increase brand recall

**Consideration Objectives:**
- **OUTCOME_ENGAGEMENT** - Increase post engagement (likes, comments, shares)
- **OUTCOME_TRAFFIC** - Drive traffic to website or app
- **APP_INSTALLS** - Drive app downloads
- **VIDEO_VIEWS** - Maximize video views
- **LEAD_GENERATION** - Collect leads via forms
- **MESSAGES** - Encourage messaging conversations

**Conversion Objectives:**
- **OUTCOME_LEADS** - Drive lead generation events
- **OUTCOME_SALES** - Drive purchase events
- **CONVERSIONS** - Optimize for specific conversion events
- **CATALOG_SALES** - Promote products from catalog
- **STORE_TRAFFIC** - Drive foot traffic to physical stores

### Detailed Workflow

#### Step 1: Confirm Required Parameters

Gather all necessary information:
```
Campaign Configuration:
- Name: "Spring Sale 2026"
- Objective: OUTCOME_SALES
- Ad Account: act_123456789
- Special Categories: None (or CREDIT, EMPLOYMENT, HOUSING if applicable)
- Initial Status: PAUSED (to review before activating)
```

#### Step 2: Use MCP Campaign Creation Tool

Call the MCP server's campaign creation tool with parameters:

**Example Request Pattern:**
```
Tool: create_campaign
Parameters:
  - account_id: "act_123456789"
  - name: "Spring Sale 2026"
  - objective: "OUTCOME_SALES"
  - status: "PAUSED"
  - special_ad_categories: [] (empty array if none)
```

**Optional Budget Parameters:**
- daily_budget: "5000" (in cents, so $50.00/day)
- lifetime_budget: "50000" (in cents, so $500.00 total)

Note: Choose either daily_budget OR lifetime_budget, not both.

#### Step 3: Capture Campaign ID

The response will include the newly created campaign_id:
```
Response:
  - campaign_id: "123456789012345"
  - success: true
```

Store this ID for reference and return it to the user.

#### Step 4: Create Ad Sets and Ads (Optional)

If the user has provided targeting and creative details, proceed to create:

**Ad Set Creation:**
- Requires: campaign_id, name, targeting, budget, optimization goal
- Set audience targeting (location, age, gender, interests, etc.)
- Configure placement and bidding

**Ad Creation:**
- Requires: adset_id, name, creative specification
- Upload or link to creative assets
- Set ad copy (headline, description, CTA)

#### Step 5: Return Campaign Details

Provide the user with:
- Campaign ID
- Campaign name
- Initial status
- Next steps (create ad sets, review settings, activate)

**Example Response:**
```
✓ Campaign created successfully

Campaign Details:
- ID: 123456789012345
- Name: Spring Sale 2026
- Objective: Sales (OUTCOME_SALES)
- Status: PAUSED
- Ad Account: act_123456789

Next Steps:
1. Create ad sets with targeting and budget
2. Create ads with creative
3. Review all settings
4. Change status to ACTIVE to begin delivery
```

### Best Practices

1. **Start paused** - Create campaigns in PAUSED status to review before spending
2. **Descriptive naming** - Use clear, searchable names with dates or identifiers
3. **Choose correct objective** - Objective determines optimization and available features
4. **Set special categories** - Required by law for certain ad types
5. **Plan structure** - Decide campaign → ad set → ad hierarchy before creating

---

## Updating Budgets

### When to Use

Use this workflow to modify budgets for existing campaigns or ad sets based on performance or business needs.

### Required Information

- **Object ID** - campaign_id or adset_id to update
- **Budget type** - daily_budget or lifetime_budget
- **New budget amount** - In cents/smallest currency unit
- **Ad Account ID** - For verification

### Detailed Workflow

#### Step 1: Identify Target Object

Determine which campaign or ad set to update:
```
Target: Campaign "Summer Sale 2026"
Campaign ID: 123456789012345
Current Budget: $100/day
New Budget: $150/day
```

#### Step 2: Determine Budget Type

Identify whether the object uses:
- **Daily budget** - Maximum spend per day, campaign runs ongoing
- **Lifetime budget** - Total spend across campaign duration

You can only update the budget type that's currently in use (cannot switch from daily to lifetime via simple update).

#### Step 3: Calculate Budget in Cents

Convert dollar amount to cents (or smallest currency unit):
```
$150.00 per day = 15000 cents
$500.00 lifetime = 50000 cents
```

#### Step 4: Use MCP Update Tool

Call the MCP server's update tool:

**Example for Campaign Budget Update:**
```
Tool: update_campaign
Parameters:
  - campaign_id: "123456789012345"
  - daily_budget: "15000"
```

**Example for Ad Set Budget Update:**
```
Tool: update_adset
Parameters:
  - adset_id: "987654321098765"
  - daily_budget: "15000"
```

#### Step 5: Verify Update

Check the response for success confirmation:
```
Response:
  - success: true
  - daily_budget: "15000"
```

#### Step 6: Optionally Fetch Updated Data

To confirm the change is reflected, fetch the campaign or ad set data:
```
Tool: get_campaign
Parameters:
  - campaign_id: "123456789012345"
  - fields: ["id", "name", "daily_budget", "status"]
```

Verify the returned daily_budget matches the new value.

#### Step 7: Communicate Change

Inform the user of the successful update:
```
✓ Budget updated successfully

Campaign: Summer Sale 2026
Previous Budget: $100.00/day
New Budget: $150.00/day
Status: Active (change effective immediately)

Expected Impact:
- Increased daily spend capacity
- Potentially higher delivery volume
- Campaign may exit learning phase faster (if applicable)
```

### Budget Update Considerations

**When Increasing Budget:**
- May trigger learning phase reset if increase is >20%
- Delivery will increase to spend new budget
- Monitor pacing to ensure efficient spend

**When Decreasing Budget:**
- Delivery will slow to stay within new budget
- May become "budget constrained"
- Check if campaign can still meet objectives with lower budget

**Account-Level Budget Limits:**
- Individual campaign budgets are subject to account spending limits
- Increasing campaign budget won't help if account limit is reached

### Best Practices

1. **Gradual changes** - Increase/decrease budgets gradually (<20% at a time) to avoid learning phase reset
2. **Monitor after changes** - Watch performance closely for 24-48 hours after budget change
3. **Document reasons** - Note why budget was changed (performance, business need, testing)
4. **Coordinate with pacing** - Check pacing report before adjusting to understand current utilization
5. **Consider timing** - Budget changes during peak hours may have immediate impact

---

## Pausing and Resuming Ads

### When to Use

Use this workflow to temporarily stop or restart ad delivery for campaigns, ad sets, or individual ads.

### Required Information

- **Object ID(s)** - campaign_id, adset_id, or ad_id to modify
- **Desired status** - PAUSED, ACTIVE, or ARCHIVED
- **Reason** - Why the change is being made (for documentation)

### Status Options

**PAUSED:**
- Stops delivery temporarily
- Can be reactivated later
- No spend while paused
- Metrics and history preserved

**ACTIVE:**
- Resumes delivery (or starts for new objects)
- Requires valid payment method and no blocks
- Begins spending budget

**ARCHIVED:**
- Permanently archives the object
- Cannot be reactivated (irreversible)
- Useful for cleanup and organization
- Metrics preserved but object cannot be edited

### Detailed Workflow

#### Step 1: Identify Object(s) to Modify

Determine what to pause/resume:
```
Action: Pause
Object Type: Campaign
Campaign Name: "Old Summer Sale"
Campaign ID: 123456789012345
Current Status: ACTIVE
New Status: PAUSED
Reason: Campaign ended, product no longer available
```

#### Step 2: Understand Hierarchy Effects

**Pausing a Campaign:**
- All child ad sets are paused
- All child ads are paused
- Entire campaign stops spending

**Pausing an Ad Set:**
- All child ads within that ad set are paused
- Other ad sets in campaign continue running

**Pausing an Ad:**
- Only that specific ad stops
- Other ads in ad set continue running

**Reactivating:**
- Must reactivate each level separately
- Activating campaign does NOT automatically activate paused ad sets/ads
- Must reactivate ad sets, then ads individually

#### Step 3: Use MCP Update Tool

Call the appropriate update tool:

**For Campaigns:**
```
Tool: update_campaign
Parameters:
  - campaign_id: "123456789012345"
  - status: "PAUSED"
```

**For Ad Sets:**
```
Tool: update_adset
Parameters:
  - adset_id: "987654321098765"
  - status: "PAUSED"
```

**For Ads:**
```
Tool: update_ad
Parameters:
  - ad_id: "567890123456789"
  - status: "PAUSED"
```

#### Step 4: Confirm Status Change

Verify the response indicates success:
```
Response:
  - success: true
  - status: "PAUSED"
  - id: "123456789012345"
```

#### Step 5: Verify No Delivery Issues (When Reactivating)

If setting status to ACTIVE, check for potential blocks:
- Payment method valid
- No account restrictions
- No policy violations
- Ad creative approved

The response may include delivery status or warnings if issues exist.

#### Step 6: Communicate Change

Inform the user of the status change:

**For Pausing:**
```
✓ Campaign paused successfully

Campaign: Old Summer Sale
Previous Status: ACTIVE
New Status: PAUSED
Effective: Immediately

Impact:
- Ad delivery has stopped
- No further spend will occur
- All child ad sets and ads are also paused
- Metrics and data remain accessible
```

**For Resuming:**
```
✓ Campaign activated successfully

Campaign: Spring Sale 2026
Previous Status: PAUSED
New Status: ACTIVE
Effective: Immediately

Impact:
- Ad delivery will begin shortly (may take a few minutes)
- Spending will resume based on budget settings
- Campaign may enter learning phase if paused for >7 days
- Monitor performance closely for first 24 hours
```

### Common Scenarios

**Pause for Creative Refresh:**
1. Pause campaign or ad set
2. Create new ads with fresh creative
3. Archive or pause old ads
4. Resume campaign with new ads

**Pause for Budget Reallocation:**
1. Pause underperforming campaigns
2. Increase budget on high performers
3. Monitor for 24-48 hours
4. Decide whether to resume or archive paused campaigns

**Pause for Seasonal End:**
1. Pause campaign at end of season
2. Review final performance
3. Archive if not reusing
4. Or keep paused for next season reactivation

**Emergency Pause:**
1. Immediately pause if issue detected (wrong creative, broken link, etc.)
2. Investigate and fix issue
3. Test fix
4. Reactivate once resolved

### Best Practices

1. **Document reasons** - Note why objects were paused for future reference
2. **Use pause, not archive** - Unless certain you won't need it again
3. **Check before reactivating** - Verify no issues during paused period
4. **Expect learning phase** - Reactivating after >7 days may trigger learning reset
5. **Communicate timing** - Status changes are immediate but delivery may take minutes to adjust

---

## Performance Optimization Recommendations

### When to Use

Use these recommendations when analyzing reports to identify and address performance issues.

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

- **references/mcp-tools-reference.md** - Specific MCP tools for campaign management
- **references/troubleshooting.md** - Common issues when performing actions
- **references/report-types.md** - Metrics to monitor after making changes
