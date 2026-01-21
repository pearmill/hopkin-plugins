# Audience Insights Report Workflow

## When to Use

Use this workflow to understand who engages with your ads, analyze demographic performance, discover high-value audience segments, optimize targeting strategies, and inform creative direction based on audience characteristics.

## Required Information

- **Ad Account ID** - format: act_XXXXXXXXXXXXX
- **Date range** - Time period for analysis
- **Campaign ID, Ad Set ID, or Ad ID** - Object to analyze
- **Desired breakdown dimensions** - age, gender, location, device, etc.

## Detailed Workflow

### Step 1: Fetch Performance Data with Demographic Breakdowns

Use the Meta Ads MCP to request performance data with one or more breakdown dimensions applied.

**Important:** Not all breakdowns can be combined. Start with single breakdowns, then try combinations if needed.

### Step 2: Select Breakdown Dimensions

Choose appropriate dimensions based on analysis goals:

**Demographics:**
- **age** - Age ranges (13-17, 18-24, 25-34, 35-44, 45-54, 55-64, 65+)
- **gender** - Gender (male, female, unknown)
- **age_gender** - Combined breakdown (e.g., "female 25-34", "male 18-24")

**Location:**
- **country** - Country codes (US, GB, CA, etc.)
- **region** - State/province/region within country
- **dma** - Designated Market Area (US only)
- **city** - City name

**Device & Platform:**
- **device_platform** - Device type (mobile, desktop, other_mobile_devices)
- **platform** - Meta platform (facebook, instagram, messenger, audience_network)
- **placement** - Specific placement (feed, stories, reels, right_column, etc.)
- **publisher_platform** - Grouped platform view

**Timing:**
- **hourly_stats_aggregated_by_advertiser_time_zone** - Performance by hour of day
- **hourly_stats_aggregated_by_audience_time_zone** - Performance by audience's hour

### Step 3: Request Segment Metrics

For each segment, include:

**Segment Identifier:**
- The breakdown value (e.g., "25-34", "Female", "California", "mobile")

**Reach Metrics:**
- impressions - Ad displays in this segment
- reach - Unique people in this segment

**Engagement Metrics:**
- clicks - Clicks from this segment
- ctr - Click-through rate for segment

**Cost Metrics:**
- spend - Amount spent reaching this segment
- cpc - Cost per click for segment

**Conversion Metrics:**
- conversions - Conversions from this segment
- conversion_value - Value from this segment
- roas - Return on ad spend for segment
- cost_per_conversion - CPA for segment

### Step 4: Present Data Hierarchically

Organize data for easy analysis:

**Single Dimension Example (Age & Gender):**
```
Audience Insights Report - Demographics
Campaign: [Campaign Name]
Date Range: [start_date] to [end_date]
Breakdown: Age & Gender

| Age-Gender | Spend  | Impr. | Clicks | CTR  | Conv. | CPA    | ROAS |
|------------|--------|-------|--------|------|-------|--------|------|
| F 25-34    | $1,234 | 156K  | 4,567  | 2.9% | 89    | $13.87 | 5.2x |
| F 35-44    | $987   | 134K  | 3,456  | 2.6% | 67    | $14.73 | 4.8x |
| M 25-34    | $856   | 128K  | 3,012  | 2.4% | 54    | $15.85 | 4.1x |
| ...        | ...    | ...   | ...    | ...  | ...   | ...    | ...  |
```

**Geographic Example:**
```
Geographic Performance - Top Markets

| Region      | Spend  | Impr. | Conv. | ROAS | % of Total |
|-------------|--------|-------|-------|------|------------|
| California  | $1,456 | 189K  | 112   | 4.8x | 32.2%      |
| Texas       | $987   | 134K  | 76    | 4.5x | 21.8%      |
| New York    | $789   | 98K   | 58    | 4.2x | 17.4%      |
| ...         | ...    | ...   | ...   | ...  | ...        |
```

**Multi-Level Hierarchy:**
When analyzing multiple dimensions, present hierarchically:
- Primary breakdown (e.g., age groups)
- Secondary breakdown within primary (e.g., gender within each age group)
- Sort by key metric at each level

### Step 5: Calculate Segment Performance Metrics

**Share Analysis:**
Calculate what percentage of total results each segment represents:

```
Share of Spend vs. Share of Conversions:
- F 25-34: 27.3% of spend → 34.6% of conversions (Efficient)
- M 45-54: 18.5% of spend → 12.1% of conversions (Inefficient)
```

This helps identify segments that over/under-deliver relative to investment.

**Index Comparison:**
Compare segment performance to overall average:

```
Index = (Segment ROAS / Overall ROAS) * 100

- F 25-34: Index 139 (39% better than average)
- M 45-54: Index 76 (24% worse than average)
```

Index > 100 = Above average performance
Index < 100 = Below average performance

**Concentration Metrics:**
Identify concentration of results:

```
Top 3 Segments Account For:
- 62% of total spend
- 71% of total conversions
- 68% of total conversion value
```

This shows how concentrated or distributed your performance is.

### Step 6: Provide Actionable Insights

**Highest Performing Segments:**
- Which demographics drive best ROAS?
- Which geos are most efficient?
- Which devices/platforms perform best?
- What times of day are most effective?

**Underperforming Segments:**
- Which segments to exclude from targeting?
- Which to reduce budget allocation?
- Which need creative optimization?

**Geographic Opportunities:**
- Which locations are untapped or under-invested?
- Which regions show strong performance but low spend?
- Which markets are saturated or inefficient?

**Device-Specific Optimizations:**
- Mobile vs. desktop performance differences
- Platform-specific creative needs (Instagram vs. Facebook)
- Placement optimization opportunities

**Temporal Patterns:**
- Best hours for ad delivery
- Day-of-week performance patterns
- Seasonality or event-driven trends

**Example Insights Section:**
```
Key Insights:

Demographics:
✓ Female 25-34 is the highest performing segment (5.2x ROAS, 34.6% of conversions)
✓ Female 25-44 age groups account for 58% of total conversions - primary audience
⚠ Male 45+ segments show weak performance (1.8x ROAS) - consider excluding or reducing

Geography:
✓ California drives 32% of spend with strong 4.8x ROAS - opportunity to scale
✓ Texas and New York also performing well - can increase investment
⚠ Florida underperforming at 2.1x ROAS - review creative/targeting fit

Devices:
✓ Mobile drives 78% of conversions at lower CPA than desktop
✓ Instagram placement outperforming Facebook Feed by 31%
⚠ Desktop shows high CPC ($2.14 vs. $0.87 mobile) - optimize or reduce

Timing:
✓ Peak performance hours: 7-9 AM and 7-10 PM (user timezone)
✓ Weekends show 23% higher CTR than weekdays
```

## Common Analysis Patterns

### Age and Gender Performance Matrix

Create a 2D view showing all age/gender combinations:

```
               | Female      | Male        | Unknown     |
---------------|-------------|-------------|-------------|
18-24          | 3.2x ROAS   | 2.8x ROAS   | 2.1x ROAS   |
25-34          | 5.2x ROAS ★ | 4.1x ROAS   | 3.4x ROAS   |
35-44          | 4.8x ROAS   | 3.7x ROAS   | 2.9x ROAS   |
45-54          | 2.9x ROAS   | 2.3x ROAS   | 1.8x ROAS   |
55+            | 2.1x ROAS   | 1.9x ROAS   | 1.6x ROAS   |

★ = Top performer
```

### Geographic Heatmap Analysis

Identify geographic patterns:
- Coastal vs. inland performance
- Urban vs. rural (using DMA data)
- Regional clusters of high/low performance
- International market opportunities

### Device and Platform Comparison

Cross-tabulate device with platform:

```
                | Facebook | Instagram | Messenger | Audience Net |
----------------|----------|-----------|-----------|--------------|
Mobile          | 4.2x     | 5.1x ★    | 3.2x      | 2.8x         |
Desktop         | 3.1x     | 2.9x      | N/A       | 2.1x         |
```

### Temporal Pattern Analysis

**Hour of Day:**
Identify when your audience is most responsive.

**Day of Week:**
Compare weekday vs. weekend performance.

**Time Zones:**
For national/international campaigns, compare advertiser time zone vs. audience time zone to optimize delivery.

### Combined Demographic Profiles

Identify specific audience personas:
- "Females 25-34 in urban areas using mobile Instagram" - High-value segment
- "Males 45+ in rural areas on desktop Facebook" - Low-value segment

## Privacy Limitations

Be aware of privacy-related restrictions:

1. **Small Sample Sizes:** Breakdowns with very few people may be suppressed
2. **Cross-Dimensional Limits:** Not all dimension combinations are available
3. **Unknown Categories:** Some users may not have demographic data
4. **Geographic Precision:** City-level data may be limited for small cities
5. **Aggregation Requirements:** Highly specific segments may be aggregated for privacy

If data is suppressed, aggregate to a higher level (e.g., region instead of city).

## Best Practices

1. **Start broad, then narrow** - Begin with age/gender, then add location or device
2. **Use appropriate sample sizes** - Small samples may not be statistically significant
3. **Compare to overall** - Always show segment performance vs. total campaign performance
4. **Consider seasonality** - Demographic patterns may vary by time of year
5. **Test before scaling** - Validate insights with small budget adjustments before major changes
6. **Combine with creative insights** - Match creative to high-performing demographics
7. **Monitor over time** - Audience performance can shift; re-analyze regularly

## See Also

- **references/report-types.md** - Complete breakdown dimension reference and privacy details
- **references/mcp-tools-reference.md** - Specific MCP tools for audience breakdowns
- **references/troubleshooting.md** - Common issues with demographic data
