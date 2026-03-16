# Audience Insights Report Workflow

## When to Use

Use this workflow to understand who engages with your ads, analyze demographic performance, discover high-value audience segments, optimize targeting strategies, and inform creative direction based on audience characteristics.

## Required Information

- **Ad Account ID** — format: act_XXXXXXXXXXXXX
- **Date range** — Time period for analysis
- **Desired breakdown dimensions** — age, gender, location, device, etc.

## Detailed Workflow

### Step 1: Fetch Performance Data with Demographic Breakdowns

Use `meta_ads_get_insights` with one or more breakdown dimensions applied.

**Important:** Not all breakdowns can be combined. Start with single breakdowns, then try combinations if needed.

**Example — Age & Gender Breakdown:**
```json
{
  "tool": "meta_ads_get_insights",
  "parameters": {
    "reason": "Analyzing audience demographics for targeting optimization",
    "account_id": "act_123456789",
    "level": "campaign",
    "date_preset": "last_30d",
    "breakdowns": ["age", "gender"]
  }
}
```

**Example — Geographic Breakdown:**
```json
{
  "tool": "meta_ads_get_insights",
  "parameters": {
    "reason": "Analyzing geographic performance to identify top markets",
    "account_id": "act_123456789",
    "level": "campaign",
    "date_preset": "last_30d",
    "breakdowns": ["country"]
  }
}
```

**Example — Platform & Device Breakdown:**
```json
{
  "tool": "meta_ads_get_insights",
  "parameters": {
    "reason": "Comparing performance across platforms and devices",
    "account_id": "act_123456789",
    "level": "campaign",
    "date_preset": "last_30d",
    "breakdowns": ["device_platform"]
  }
}
```

### Step 2: Select Breakdown Dimensions

Choose appropriate dimensions based on analysis goals:

**Demographics:**
- **age** — Age ranges (13-17, 18-24, 25-34, 35-44, 45-54, 55-64, 65+)
- **gender** — Gender (male, female, unknown)

**Location:**
- **country** — Country codes (US, GB, CA, etc.)
- **region** — State/province/region within country
- **dma** — Designated Market Area (US only)

**Device & Platform:**
- **device_platform** — Device type (mobile, desktop, other_mobile_devices)
- **platform** — Meta platform (facebook, instagram, messenger, audience_network)
- **placement** — Specific placement (feed, stories, reels, right_column, etc.)

### Step 3: Present Data Hierarchically

Organize data for easy analysis:

Present as a table with columns: Segment (e.g., "F 25-34"), Spend, Impressions, Clicks, CTR, Conversions, CPA, ROAS. Sort by highest performing segment.

### Step 3a: Visualize Audience Segments

Render a bar chart showing performance by demographic segment:

```json
{
  "tool": "meta_ads_render_chart",
  "parameters": {
    "reason": "Visualizing CPA by age-gender segment to identify high-value audiences",
    "chart": {
      "type": "bar",
      "data": [
        {"label": "F 25-34", "values": {"cpa": 13.87, "spend": 1234}},
        {"label": "F 35-44", "values": {"cpa": 14.73, "spend": 987}},
        {"label": "M 25-34", "values": {"cpa": 15.85, "spend": 856}},
        {"label": "M 35-44", "values": {"cpa": 18.20, "spend": 720}}
      ],
      "metric": {"field": "cpa", "label": "CPA ($)"},
      "sort": "asc"
    }
  }
}
```

Use scatter charts to correlate spend vs. ROAS across audience segments for scaling decisions.

### Step 4: Calculate Segment Performance Metrics

**Share Analysis:**
```
Share of Spend vs. Share of Conversions:
- F 25-34: 27.3% of spend → 34.6% of conversions (Efficient)
- M 45-54: 18.5% of spend → 12.1% of conversions (Inefficient)
```

**Index Comparison:**
```
Index = (Segment ROAS / Overall ROAS) * 100

- F 25-34: Index 139 (39% better than average)
- M 45-54: Index 76 (24% worse than average)
```

### Step 5: Provide Actionable Insights

**Highest Performing Segments:**
- Which demographics drive best ROAS?
- Which geos are most efficient?
- Which devices/platforms perform best?

**Underperforming Segments:**
- Which segments to exclude from targeting?
- Which to reduce budget allocation?
- Which need creative optimization?

**Example Insights Section:**
```
Key Insights:

Demographics:
✓ Female 25-34 is the highest performing segment (5.2x ROAS, 34.6% of conversions)
✓ Female 25-44 age groups account for 58% of total conversions - primary audience
⚠ Male 45+ segments show weak performance (1.8x ROAS) - consider excluding or reducing

Geography:
✓ California drives 32% of spend with strong 4.8x ROAS - opportunity to scale
⚠ Florida underperforming at 2.1x ROAS - review creative/targeting fit

Devices:
✓ Mobile drives 78% of conversions at lower CPA than desktop
✓ Instagram placement outperforming Facebook Feed by 31%
```

## Common Analysis Patterns

### Age and Gender Performance Matrix

```
               | Female      | Male        | Unknown     |
---------------|-------------|-------------|-------------|
18-24          | 3.2x ROAS   | 2.8x ROAS   | 2.1x ROAS   |
25-34          | 5.2x ROAS ★ | 4.1x ROAS   | 3.4x ROAS   |
35-44          | 4.8x ROAS   | 3.7x ROAS   | 2.9x ROAS   |
45-54          | 2.9x ROAS   | 2.3x ROAS   | 1.8x ROAS   |
55+            | 2.1x ROAS   | 1.9x ROAS   | 1.6x ROAS   |
```

## Privacy Limitations

Be aware of privacy-related restrictions:

1. **Small Sample Sizes:** Breakdowns with very few people may be suppressed
2. **Cross-Dimensional Limits:** Not all dimension combinations are available
3. **Unknown Categories:** Some users may not have demographic data

If data is suppressed, aggregate to a higher level (e.g., region instead of city).

## Best Practices

1. **Start broad, then narrow** — Begin with age/gender, then add location or device
2. **Use appropriate sample sizes** — Small samples may not be statistically significant
3. **Compare to overall** — Always show segment performance vs. total campaign performance
4. **Consider seasonality** — Demographic patterns may vary by time of year
5. **Test before scaling** — Validate insights with small budget adjustments before major changes
6. **Combine with creative insights** — Match creative to high-performing demographics
7. **Monitor over time** — Audience performance can shift; re-analyze regularly

## See Also

- **references/report-types.md** — Complete breakdown dimension reference and privacy details
- **references/mcp-tools-reference.md** — Hopkin MCP tools reference
- **references/troubleshooting.md** — Common issues with demographic data
