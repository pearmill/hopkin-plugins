# Meta Ads Report Types - Detailed Reference

This document provides comprehensive details for all Meta Ads report types supported by the meta-ads skill.

## Table of Contents

1. [Campaign Performance Reports](#campaign-performance-reports)
2. [Ad Creative Performance Reports](#ad-creative-performance-reports)
3. [Audience Insights Reports](#audience-insights-reports)
4. [Budget & Pacing Reports](#budget-pacing-reports)
5. [Date Presets](#date-presets)
6. [Breakdown Dimensions](#breakdown-dimensions)
7. [Common Fields Reference](#common-fields-reference)

---

## Campaign Performance Reports

### Overview

Campaign Performance Reports provide aggregated metrics at the campaign level, ideal for high-level performance analysis and campaign comparison.

### Available Metrics

#### Reach & Delivery Metrics
- **impressions** - Total number of times ads were displayed
- **reach** - Number of unique people who saw ads at least once
- **frequency** - Average number of times each person saw ads (impressions / reach)
- **delivery** - Delivery status indicator

#### Engagement Metrics
- **clicks** - Total clicks on ads (all clicks, not just link clicks)
- **link_clicks** - Clicks on links that drive to destinations on or off Meta properties
- **ctr** - Click-through rate (clicks / impressions * 100)
- **link_click_ctr** - Link click-through rate (link_clicks / impressions * 100)
- **unique_clicks** - Number of people who clicked
- **unique_link_clicks** - Number of people who clicked on links

#### Cost Metrics
- **spend** - Total amount spent (in account currency)
- **cpc** - Cost per click (spend / clicks)
- **cpm** - Cost per 1,000 impressions (spend / impressions * 1000)
- **cpp** - Cost per 1,000 people reached (spend / reach * 1000)
- **cost_per_unique_click** - Cost per unique click (spend / unique_clicks)

#### Conversion Metrics
- **conversions** - Total number of conversion events
- **conversion_value** - Total value of conversions
- **cost_per_conversion** - Average cost per conversion (spend / conversions)
- **roas** - Return on ad spend (conversion_value / spend)
- **website_purchases** - Number of website purchase events
- **purchase_value** - Total value of purchases
- **leads** - Number of lead generation events
- **add_to_cart** - Number of add-to-cart events
- **initiated_checkout** - Number of checkout initiation events

#### Campaign Attribute Fields
- **campaign_id** - Unique campaign identifier
- **campaign_name** - Campaign name
- **objective** - Campaign objective (e.g., OUTCOME_SALES, OUTCOME_LEADS)
- **status** - Campaign status (ACTIVE, PAUSED, DELETED, ARCHIVED)
- **daily_budget** - Daily budget in cents
- **lifetime_budget** - Lifetime budget in cents
- **start_time** - Campaign start time (ISO 8601)
- **end_time** - Campaign end time (ISO 8601)
- **created_time** - Campaign creation timestamp
- **updated_time** - Last update timestamp

### Sample Output Format

```
Campaign Performance Report
Date Range: 2026-01-01 to 2026-01-15
Ad Account: act_123456789

┌────────────────────┬─────────────┬────────┬────────┬──────────┬──────────┬─────────┬──────┬───────┐
│ Campaign Name      │ Status      │ Spend  │ Impr.  │ Clicks   │ Conv.    │ ROAS    │ CTR  │ CPC   │
├────────────────────┼─────────────┼────────┼────────┼──────────┼──────────┼─────────┼──────┼───────┤
│ Summer Sale 2026   │ ACTIVE      │ $4,521 │ 452K   │ 12,456   │ 234      │ 4.2x    │ 2.8% │ $0.36 │
│ Brand Awareness Q1 │ ACTIVE      │ $3,210 │ 891K   │ 8,932    │ 156      │ 3.8x    │ 1.0% │ $0.36 │
│ Product Launch     │ PAUSED      │ $2,109 │ 234K   │ 5,678    │ 89       │ 2.1x    │ 2.4% │ $0.37 │
└────────────────────┴─────────────┴────────┴────────┴──────────┴──────────┴─────────┴──────┴───────┘

Summary:
- Total Spend: $9,840
- Total Conversions: 479
- Average ROAS: 3.4x
- Average CTR: 2.1%
- Active Campaigns: 2 | Paused: 1
```

### Common Breakdowns

- **By date** - Daily performance trends
- **By objective** - Compare different campaign objectives
- **By status** - Active vs. paused performance

---

## Ad Creative Performance Reports

### Overview

Ad Creative Performance Reports provide metrics at the individual ad level, essential for creative testing, optimization, and understanding which messages resonate with audiences.

### Available Metrics

#### Creative Detail Fields
- **ad_id** - Unique ad identifier
- **ad_name** - Ad name
- **adset_id** - Parent ad set ID
- **adset_name** - Parent ad set name
- **campaign_id** - Parent campaign ID
- **campaign_name** - Parent campaign name
- **creative_id** - Unique creative identifier (same creative can be used in multiple ads)
- **status** - Ad status (ACTIVE, PAUSED, DELETED, ARCHIVED, IN_PROCESS, WITH_ISSUES)

#### Creative Elements (when available)
- **creative_type** - Type of creative (IMAGE, VIDEO, CAROUSEL, COLLECTION, etc.)
- **thumbnail_url** - URL to creative thumbnail
- **title** - Ad title/headline
- **body** - Ad body text/description
- **call_to_action_type** - CTA button type (LEARN_MORE, SHOP_NOW, SIGN_UP, etc.)
- **link_url** - Destination URL
- **video_duration** - Video length in seconds (for video ads)

#### Performance Metrics
All metrics from Campaign Performance Reports, plus:

- **inline_link_clicks** - Clicks on links in the ad creative
- **inline_link_click_ctr** - CTR for inline link clicks
- **outbound_clicks** - Clicks that take people off Meta properties
- **outbound_clicks_ctr** - CTR for outbound clicks

#### Engagement Metrics (Specific to Creative)
- **post_reactions** - Number of reactions (Like, Love, Haha, Wow, Sad, Angry)
- **post_comments** - Number of comments
- **post_shares** - Number of shares
- **post_saves** - Number of saves/bookmarks
- **page_likes** - Number of page likes from ad
- **photo_views** - Views of photo ads
- **engagement_rate** - (post_reactions + post_comments + post_shares) / impressions

#### Video Metrics (for video ads)
- **video_plays** - Number of video plays
- **video_plays_at_25_percent** - Videos played to 25% completion
- **video_plays_at_50_percent** - Videos played to 50% completion
- **video_plays_at_75_percent** - Videos played to 75% completion
- **video_plays_at_100_percent** - Videos played to 100% completion
- **video_play_completion_rate** - Percentage of videos played to 100%
- **video_avg_time_watched** - Average watch time in seconds
- **video_thruplay** - Videos played to completion or 15 seconds
- **cost_per_thruplay** - Cost per thruplay

### Sample Output Format

```
Ad Creative Performance Report
Campaign: Summer Sale 2026
Date Range: 2026-01-01 to 2026-01-15

┌──────────────────────┬──────────────┬────────┬────────┬────────┬──────┬───────┬──────────┬──────────┐
│ Ad Name              │ Type         │ Spend  │ Impr.  │ Clicks │ CTR  │ Conv. │ CPC      │ ROAS     │
├──────────────────────┼──────────────┼────────┼────────┼────────┼──────┼───────┼──────────┼──────────┤
│ 50% Off - Video A    │ VIDEO        │ $1,234 │ 123K   │ 3,456  │ 2.8% │ 67    │ $0.36    │ 4.5x     │
│ 50% Off - Image A    │ IMAGE        │ $1,123 │ 145K   │ 3,201  │ 2.2% │ 58    │ $0.35    │ 3.9x     │
│ 50% Off - Carousel   │ CAROUSEL     │ $1,089 │ 132K   │ 2,987  │ 2.3% │ 54    │ $0.36    │ 3.7x     │
│ Free Shipping - Vid  │ VIDEO        │ $892   │ 98K    │ 2,156  │ 2.2% │ 38    │ $0.41    │ 3.2x     │
└──────────────────────┴──────────────┴────────┴────────┴────────┴──────┴───────┴──────────┴──────────┘

Video Performance (Video ads only):
┌──────────────────────┬────────────┬──────────┬──────────┬──────────┬──────────┬──────────────┐
│ Ad Name              │ Plays      │ 25%      │ 50%      │ 75%      │ 100%     │ Avg. Watch   │
├──────────────────────┼────────────┼──────────┼──────────┼──────────┼──────────┼──────────────┤
│ 50% Off - Video A    │ 45,678     │ 38,234   │ 28,901   │ 19,234   │ 12,456   │ 18.3s        │
│ Free Shipping - Vid  │ 34,567     │ 29,123   │ 21,345   │ 13,456   │ 8,234    │ 15.7s        │
└──────────────────────┴────────────┴──────────┴──────────┴──────────┴──────────┴──────────────┘

Insights:
✓ Video A outperforms Image A with 15% higher ROAS despite similar creative concept
✓ "50% Off" messaging outperforms "Free Shipping" across all formats
✓ Video completion rate (27% for Video A) indicates strong creative engagement
```

### Common Breakdowns

- **By creative_type** - Compare image vs. video vs. carousel performance
- **By placement** - Feed vs. Stories vs. Reels vs. other placements
- **By device_platform** - Mobile vs. desktop vs. other
- **By date** - Track creative fatigue over time

---

## Audience Insights Reports

### Overview

Audience Insights Reports break down performance by demographic, geographic, and behavioral dimensions to identify high-performing audience segments.

### Breakdown Dimensions

#### Demographic Breakdowns
- **age** - Age ranges (13-17, 18-24, 25-34, 35-44, 45-54, 55-64, 65+)
- **gender** - Gender (male, female, unknown)
- **age_gender** - Combined age and gender (e.g., "male 25-34")

#### Geographic Breakdowns
- **country** - Country (ISO country codes, e.g., US, GB, CA)
- **region** - State/province/region
- **dma** - Designated Market Area (US only)
- **city** - City name

#### Device & Platform Breakdowns
- **device_platform** - Device type (mobile, desktop, other_mobile_devices, unknown)
- **platform** - Meta platform (facebook, instagram, messenger, audience_network)
- **placement** - Specific ad placement (feed, stories, reels, right_column, search, etc.)
- **publisher_platform** - Publisher platform grouping

#### Temporal Breakdowns
- **hourly_stats_aggregated_by_advertiser_time_zone** - Performance by hour of day
- **hourly_stats_aggregated_by_audience_time_zone** - Performance by audience hour

### Available Metrics

All standard performance metrics can be broken down by any dimension:
- Impressions, reach, frequency
- Clicks, CTR
- Spend, CPC, CPM
- Conversions, conversion value, ROAS

### Sample Output Format

```
Audience Insights Report - Demographics
Campaign: Summer Sale 2026
Date Range: 2026-01-01 to 2026-01-15
Breakdown: Age & Gender

┌─────────────┬────────┬────────────┬────────┬────────┬──────────┬──────────┬─────────┐
│ Age-Gender  │ Spend  │ Impr.      │ Clicks │ CTR    │ Conv.    │ CPA      │ ROAS    │
├─────────────┼────────┼────────────┼────────┼────────┼──────────┼──────────┼─────────┤
│ F 25-34     │ $1,234 │ 156K       │ 4,567  │ 2.9%   │ 89       │ $13.87   │ 5.2x    │
│ F 35-44     │ $987   │ 134K       │ 3,456  │ 2.6%   │ 67       │ $14.73   │ 4.8x    │
│ M 25-34     │ $856   │ 128K       │ 3,012  │ 2.4%   │ 54       │ $15.85   │ 4.1x    │
│ F 18-24     │ $789   │ 145K       │ 2,987  │ 2.1%   │ 45       │ $17.53   │ 3.6x    │
│ M 35-44     │ $654   │ 98K        │ 2,234  │ 2.3%   │ 38       │ $17.21   │ 3.7x    │
│ F 45-54     │ $501   │ 67K        │ 1,456  │ 2.2%   │ 23       │ $21.78   │ 2.9x    │
└─────────────┴────────┴────────────┴────────┴────────┴──────────┴──────────┴─────────┘

Geographic Performance - Top Markets
┌─────────────────┬────────┬────────────┬──────────┬─────────┬──────────────┐
│ Region          │ Spend  │ Impr.      │ Conv.    │ ROAS    │ % of Total   │
├─────────────────┼────────┼────────────┼──────────┼─────────┼──────────────┤
│ California      │ $1,456 │ 189K       │ 112      │ 4.8x    │ 32.2%        │
│ Texas           │ $987   │ 134K       │ 76       │ 4.5x    │ 21.8%        │
│ New York        │ $789   │ 98K        │ 58       │ 4.2x    │ 17.4%        │
│ Florida         │ $654   │ 87K        │ 45       │ 3.9x    │ 12.9%        │
│ Other           │ $635   │ 76K        │ 25       │ 2.8x    │ 15.7%        │
└─────────────────┴────────┴────────────┴──────────┴─────────┴──────────────┘

Insights:
✓ Female 25-34 is the highest performing segment (5.2x ROAS, 34.6% of conversions)
✓ Consider increasing budget allocation to F 25-44 age groups
✓ California drives 32% of spend but delivers strong ROAS - opportunity to scale
✓ F 45-54 shows lower performance - consider reducing spend or creative optimization
```

### Privacy Considerations

- Demographic breakdowns may be limited or unavailable for small audience sizes
- Some fields may be suppressed to protect user privacy
- "Unknown" category may appear when data is not available
- Cross-dimensional breakdowns (e.g., age + gender + location) may have more restrictions

---

## Budget & Pacing Reports

### Overview

Budget & Pacing Reports track budget utilization, spending velocity, and forecast future spend to ensure campaigns meet financial targets.

### Available Fields

#### Budget Settings
- **daily_budget** - Daily budget in cents (null if lifetime budget used)
- **lifetime_budget** - Total campaign budget in cents (null if daily budget used)
- **budget_remaining** - Remaining budget for lifetime budget campaigns
- **daily_budget_cap** - Maximum daily spend (for campaigns with lifetime budget)

#### Timing
- **start_time** - Campaign start timestamp (ISO 8601)
- **end_time** - Campaign end timestamp (ISO 8601, null for ongoing)
- **created_time** - Campaign creation timestamp
- **updated_time** - Last modification timestamp

#### Spend Data
- **spend** - Total spend to date
- **date_spend** - Spend broken down by date (for pacing analysis)

#### Delivery Status
- **delivery_status** - Current delivery status
- **delivery_info** - Information about delivery issues (if any)

### Calculated Pacing Metrics

These are typically calculated from the raw fields:

- **Days elapsed** - Days since campaign start
- **Days remaining** - Days until campaign end (for campaigns with end_time)
- **Total duration** - Total campaign length in days
- **Average daily spend** - Total spend / days elapsed
- **Budget utilization %** - (Spend / budget) * 100
- **Projected final spend** - Based on current pacing rate
- **Ideal daily spend** - Budget / total duration (for even pacing)
- **Current vs. ideal pace** - Comparison of actual to ideal pacing
- **Pacing status** - Ahead, on track, behind, or complete

### Sample Output Format

```
Budget & Pacing Report
Ad Account: act_123456789
Report Date: 2026-01-15

┌────────────────────┬──────────┬────────────┬────────┬──────────────┬──────────────┬─────────────┐
│ Campaign Name      │ Budget   │ Spend      │ Remain │ Days Running │ Days Left    │ Status      │
├────────────────────┼──────────┼────────────┼────────┼──────────────┼──────────────┼─────────────┤
│ Summer Sale 2026   │ $10,000  │ $6,234     │ $3,766 │ 15/30 days   │ 15 days      │ On Track    │
│ Brand Awareness Q1 │ $500/day │ $7,125     │ N/A    │ 15 days      │ Ongoing      │ Ahead       │
│ Product Launch     │ $5,000   │ $4,892     │ $108   │ 28/30 days   │ 2 days       │ Near End    │
└────────────────────┴──────────┴────────────┴────────┴──────────────┴──────────────┴─────────────┘

Detailed Pacing Analysis:

Campaign: Summer Sale 2026
├─ Budget Type: Lifetime Budget
├─ Total Budget: $10,000
├─ Spent to Date: $6,234 (62.3%)
├─ Budget Remaining: $3,766 (37.7%)
├─ Campaign Duration: Jan 1 - Jan 30 (30 days)
├─ Days Elapsed: 15 days (50%)
├─ Days Remaining: 15 days
├─ Average Daily Spend: $415.60
├─ Ideal Daily Spend: $333.33 (for even pacing)
├─ Current Pace: 12.4% ahead of ideal
├─ Projected Final Spend: $12,468 (24.7% over budget)
├─ Recommended Daily Spend: $251.07 (to stay within budget)
└─ Status: ⚠️  Pacing ahead - consider reducing spend rate

Campaign: Brand Awareness Q1
├─ Budget Type: Daily Budget
├─ Daily Budget: $500
├─ Total Spent: $7,125 (over 15 days)
├─ Average Daily Spend: $475.00
├─ Current Pace: 95% of daily budget
├─ Delivery Status: Active - spending below daily cap
└─ Status: ✓ Healthy pacing

Daily Spend Trend (Summer Sale 2026):
┌──────────┬────────┬────────────────┐
│ Date     │ Spend  │ Cumulative     │
├──────────┼────────┼────────────────┤
│ Jan 11   │ $423   │ $4,234         │
│ Jan 12   │ $456   │ $4,690         │
│ Jan 13   │ $412   │ $5,102         │
│ Jan 14   │ $487   │ $5,589         │
│ Jan 15   │ $645   │ $6,234         │
└──────────┴────────┴────────────────┘

Recommendations:
⚠️  Summer Sale 2026: Reduce daily spend to ~$251 to avoid exceeding budget
✓ Brand Awareness Q1: Healthy delivery, consider increasing budget if performance is strong
⚠️  Product Launch: Only $108 remaining for 2 days - campaign will likely end early
```

### Pacing Status Definitions

- **On Track:** Spending within ±10% of ideal pace
- **Ahead:** Spending >10% faster than ideal pace, may exhaust budget early
- **Behind:** Spending >10% slower than ideal pace, may not fully utilize budget
- **Near End:** Less than 10% of budget or duration remaining
- **Complete:** Budget exhausted or campaign ended
- **Underspending:** Active campaign spending <50% of available budget

---

## Date Presets

Common date range presets supported by Meta Ads API:

- **today** - Current day (advertiser time zone)
- **yesterday** - Previous day
- **this_week** - Current week (Sunday to today)
- **last_week** - Previous complete week
- **this_month** - Current month (1st to today)
- **last_month** - Previous complete month
- **last_3d** - Last 3 days (including today)
- **last_7d** - Last 7 days (including today)
- **last_14d** - Last 14 days (including today)
- **last_30d** - Last 30 days (including today)
- **last_90d** - Last 90 days (including today)
- **this_quarter** - Current quarter
- **last_quarter** - Previous quarter
- **this_year** - Current year (Jan 1 to today)
- **last_year** - Previous complete year
- **lifetime** - Entire campaign lifetime

**Custom Ranges:** Can specify exact start and end dates in YYYY-MM-DD format.

---

## Breakdown Dimensions

Complete list of available breakdown dimensions:

### Standard Breakdowns
- age
- gender
- country
- region
- dma (US only)
- placement
- platform
- device_platform
- publisher_platform

### Time Breakdowns
- hourly_stats_aggregated_by_advertiser_time_zone
- hourly_stats_aggregated_by_audience_time_zone

### Product Breakdowns (for catalog/dynamic ads)
- product_id

### Advanced Breakdowns
- impression_device
- platform_position
- publisher_platform

**Note:** Some breakdowns cannot be combined (e.g., cannot breakdown by both advertiser and audience time zone simultaneously). The MCP server will return an error if incompatible breakdowns are requested.

---

## Common Fields Reference

### Metric Definitions

#### Reach & Frequency
- **Impressions:** Count of ad displays (multiple per person possible)
- **Reach:** Unique people count who saw ads
- **Frequency:** Impressions / Reach (how many times each person saw ad on average)

#### Click Metrics
- **Clicks:** All clicks on ad (including reactions, comments, shares)
- **Link Clicks:** Clicks specifically on links to destinations
- **Unique Clicks:** Number of people who clicked (deduplicated)
- **CTR:** (Clicks / Impressions) * 100
- **Link Click CTR:** (Link Clicks / Impressions) * 100

#### Cost Metrics
- **Spend:** Total amount spent in account currency
- **CPC:** Cost Per Click (Spend / Clicks)
- **CPM:** Cost Per Mille/Thousand Impressions (Spend / Impressions * 1000)
- **CPP:** Cost Per Point (Spend / Reach * 1000)

#### Conversion Metrics
- **Conversions:** Total conversion events tracked
- **Conversion Value:** Total value of conversions in account currency
- **Cost Per Conversion:** Spend / Conversions
- **ROAS:** Return on Ad Spend (Conversion Value / Spend)

### Field Formatting

- **Currency:** Always in account currency; returned as decimal number (e.g., 12.34 for $12.34)
- **Percentages:** CTR and rates typically returned as decimals (0.0234 = 2.34%)
- **Counts:** Whole numbers for impressions, clicks, conversions
- **Timestamps:** ISO 8601 format (YYYY-MM-DDTHH:MM:SS±ZZZZ)
- **IDs:** String format (even if numeric)

---

**Document Version:** 1.0
**Last Updated:** 2026-01-19
