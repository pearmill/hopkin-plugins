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

## Performance Reports via `meta_ads_get_performance_report`

### Overview

The `meta_ads_get_performance_report` tool is the **recommended tool for most reporting use cases**. It always includes a comprehensive funnel of pre-built metrics, so you don't need to specify which fields to retrieve.

### Included Metrics (Always Present)

Every call to `meta_ads_get_performance_report` automatically includes:
- **impressions** — Total number of ad displays
- **reach** — Unique people who saw ads
- **frequency** — Average times each person saw ads
- **spend** — Total amount spent
- **clicks** — Total clicks on ads
- **cpc** — Cost per click
- **cpm** — Cost per 1,000 impressions
- **ctr** — Click-through rate
- **unique_clicks** — Number of unique clickers
- **actions** — All tracked actions
- **action_values** — Values of tracked actions
- **conversions** — Total conversion events
- **purchase_roas** — Return on ad spend
- **quality_rankings** — Ad quality indicators

### When to Use

Use `meta_ads_get_performance_report` for:
- Campaign performance overview reports
- Ad-level performance comparison
- Quick full-funnel analysis
- Any reporting where you want comprehensive metrics without specifying fields

Use `meta_ads_get_insights` instead when you need:
- Custom breakdowns (age, gender, geography, device, placement)
- Daily/weekly time increments for trend analysis
- Specific metric combinations not covered by the performance report

### Parameters

- `reason` (string, required) — Audit trail reason
- `account_id` (string, required) — Ad account ID (act_XXXXXXXXXXXXX)
- `level` (string, required) — `"campaign"`, `"adset"`, or `"ad"`
- `date_preset` (string, optional) — e.g., `"last_7d"`, `"last_30d"`
- `time_range` (object, optional) — `{"since": "YYYY-MM-DD", "until": "YYYY-MM-DD"}`
- `campaign_id` (string, optional) — Filter to specific campaign
- `adset_id` (string, optional) — Filter to specific ad set

---

## Campaign Performance Reports

### Overview

Campaign Performance Reports provide aggregated metrics at the campaign level, ideal for high-level performance analysis and campaign comparison.

### Key Metrics

Includes all standard metrics (see Common Fields Reference below) plus campaign attributes: campaign_id, campaign_name, objective, status, daily_budget, lifetime_budget, start_time, end_time.

### Output

Present as a table with columns: Campaign Name, Status, Spend, Impressions, Clicks, Conversions, ROAS, CTR, CPC. Include a summary row with totals and averages.

---

## Ad Creative Performance Reports

### Overview

Ad Creative Performance Reports provide metrics at the individual ad level, essential for creative testing, optimization, and understanding which messages resonate with audiences.

### Key Metrics

Includes all standard metrics plus:
- **Creative details:** ad_id, ad_name, adset_id/name, campaign_id/name, creative_id, status, creative_type, thumbnail_url, title, body, call_to_action_type, link_url
- **Engagement:** post_reactions, post_comments, post_shares, post_saves, engagement_rate
- **Video (when applicable):** video_plays, video_plays_at_25/50/75/100_percent, video_avg_time_watched, video_thruplay, cost_per_thruplay

### Output

Present as a table with columns: Ad Name, Type, Spend, Impressions, Clicks, CTR, Conversions, CPC, ROAS. For video ads, include a separate table with video completion metrics (25%/50%/75%/100% play rates, avg watch time).

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

### Output

Present as a table with columns: Segment (e.g., "F 25-34"), Spend, Impressions, Clicks, CTR, Conversions, CPA, ROAS. For geographic breakdowns, include % of Total column. Add "Share of Spend vs. Share of Conversions" analysis to identify efficient/inefficient segments.

**Note:** Demographic breakdowns may be suppressed for small audience sizes. "Unknown" may appear for missing data.

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

### Output

Present a summary table with columns: Campaign Name, Budget (daily or lifetime), Spend to Date, Remaining, Days Running/Left, Pacing Status. For each campaign, calculate: budget utilization %, average daily spend, ideal daily spend, projected final spend, and recommended adjustments.

**Pacing Status:** On Track (±10% of ideal), Ahead (>10% faster), Behind (>10% slower), Near End (<10% remaining), Underspending (<50% of available).

---

## Date Presets

Common presets: `today`, `yesterday`, `this_week`, `last_week`, `this_month`, `last_month`, `last_3d`, `last_7d`, `last_14d`, `last_30d`, `last_90d`, `this_quarter`, `last_quarter`, `this_year`, `last_year`, `lifetime`. Custom ranges use `time_range` with `since`/`until` in YYYY-MM-DD format.

---

## Breakdown Dimensions

- **Demographic:** age, gender, age_gender (combined)
- **Geographic:** country, region, dma (US only), city
- **Device/Platform:** device_platform, platform, placement, publisher_platform
- **Time:** hourly_stats_aggregated_by_advertiser_time_zone, hourly_stats_aggregated_by_audience_time_zone

Some breakdowns cannot be combined. The MCP server returns an error for incompatible combinations.

---

## Common Fields Reference

- **Impressions/Reach/Frequency** — Ad displays, unique viewers, avg views per person
- **Clicks/Link Clicks/Unique Clicks** — All clicks, link-only clicks, deduplicated clickers
- **CTR** — Clicks / Impressions × 100
- **Spend/CPC/CPM** — Total cost, cost per click, cost per 1K impressions
- **Conversions/Conversion Value/ROAS** — Events, value, return on ad spend
- **Cost Per Conversion** — Spend / Conversions

**Formatting:** Currency as decimals (12.34 = $12.34), percentages as decimals (0.0234 = 2.34%), IDs as strings, timestamps as ISO 8601.

---

**Document Version:** 2.0
**Last Updated:** 2026-02-10
