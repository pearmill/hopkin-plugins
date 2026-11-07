# Campaign Performance Report

## Overview

Compare campaigns in a Microsoft Advertising account: spend, clicks, conversions, revenue, cost per conversion and ROAS, with the conversion definition stated. Use it for "which campaigns are working", "where is spend wasted" and weekly or monthly reviews.

For a single account total, use `microsoft_ads_get_account_summary` instead.

---

## Step 1: Pick the Account

Call `microsoft_ads_list_accounts` (with `search` when the user names a client). Note the account's **currency**. For an agency-managed account, note the `customer_id` too and pass it on every call.

```json
{
  "tool": "microsoft_ads_list_accounts",
  "parameters": {
    "search": "acme",
    "reason": "Finding the Microsoft Ads account for the campaign performance report"
  }
}
```

If more than one account matches, list them and ask.

---

## Step 2: Check What Counts as a Conversion

`conversions` covers only goals marked "Include in Conversions". If the user's target metric is a goal outside that set (a non-bidding lead goal, for example), the bidding-set figure understates it. Two ways to check:

- `microsoft_ads_get_uet_tag_health` lists every goal with `excludeFromBidding` (true means the goal is **not** in `conversions`) and whether it is still recording
- The report's own `goal_breakdown` (on by default) shows per-goal totals

When the goals the user cares about are excluded from bidding, pass `include_all_conversions: true` and report from `all_conversions`.

---

## Step 3: Pull the Campaign Report

```json
{
  "tool": "microsoft_ads_get_performance_report",
  "parameters": {
    "account_id": "123456789",
    "level": "Campaign",
    "date_preset": "LastThreeMonths",
    "aggregation": "Summary",
    "reason": "Campaign comparison for the last three months"
  }
}
```

- `aggregation: "Summary"` gives one row per campaign. Use `Daily` or `Weekly` for a trend chart
- `campaign_type: ["Search"]` (or `Shopping`, `PerformanceMax`, `Audience`) narrows to one channel
- Follow `nextCursor` with identical parameters if the account has more campaigns than one page holds
- The call takes 5 to 30 seconds: Microsoft builds the report in the background

---

## Step 4: Add Context

- **Budgets and bid strategies:** `microsoft_ads_list_campaigns` gives each campaign's `dailyBudget`, `biddingScheme` and targets (`targetCpa`, `targetRoas` as a ratio, where 7.25 = 725%)
- **Budget-limited campaigns:** `microsoft_ads_get_impression_share` shows the share lost to budget versus to rank
- **Sudden changes:** `microsoft_ads_get_activities` for the days before a shift

---

## Step 5: Analyze

Compute from the rows, guarding against zero denominators:

- **Cost per conversion** = spend ÷ conversions
- **ROAS** = revenue ÷ spend
- **Conversion rate** = conversions ÷ clicks

Flag:

- Campaigns with meaningful spend and no conversions
- Campaigns far above the account's average cost per conversion
- Campaigns losing a large share of impressions to budget while converting efficiently (candidates for more budget)
- Campaigns losing impressions to rank (bids, Quality Score or ad quality)

---

## Step 6: Present

1. One-paragraph answer first: the best and worst campaigns and the main recommendation
2. A table sorted by spend: campaign, type, spend, clicks, CTR, conversions, cost per conversion, revenue, ROAS
3. A chart with `microsoft_ads_render_chart` (bar for comparison, timeseries for trends)
4. The date range, currency and which conversion definition you used

Any change the user wants to make (budgets, pausing, bids) happens in Microsoft Advertising; this MCP is read-only.
