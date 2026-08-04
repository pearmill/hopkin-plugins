# Conversion Analysis

## Overview

Reports conversion totals alongside delivery data and derives cost per conversion.

Two things make this different from every other platform's conversion reporting:

1. **Conversions are not an insights metric.** The six metrics are impressions, clicks, spend, ctr, cpc, cpm. Conversions come from a separate path.
2. **Conversion totals are whole-window only.** They carry no time bucketing, so they cannot be trended by day within a single request.

## Primary Tools

- `chatgpt_ads_get_insights` with `include_conversions: true`
- `chatgpt_ads_list_conversion_event_settings` — what is being counted, and the attribution window

## Step-by-Step Workflow

### Step 1: Establish Account Context

```
chatgpt_ads_get_ad_account(reason: "Get currency and timezone for conversion analysis")
```

Cost per conversion is a money value and needs the account currency.

### Step 2: Check What Is Being Counted

```
chatgpt_ads_list_conversion_event_settings(reason: "Identify configured conversion events and attribution windows")
```

This tells you what a "conversion" means for this account and over what attribution window — without it, a conversion count is uninterpretable.

**If this returns 404**, the account is not enabled for conversion tracking. That is a feature gate, not an error. Report the delivery data and say conversion reporting is not enabled.

### Step 3: Pull Insights With Conversions

```
chatgpt_ads_get_insights(
  aggregation_level: <campaign or ad>,
  include_conversions: true,
  date_since: "YYYY-MM-DD",
  date_until: "YYYY-MM-DD",
  reason: "..."
)
```

### Step 4: Derive Cost per Conversion

Not returned by the API. Compute it:

```
cost_per_conversion = spend / conversions
```

**Guard the zero case explicitly.** If conversions are zero, say cost per conversion cannot be computed. Reporting `∞`, `NaN`, or a blank is a failure.

### Step 5: Present

State the attribution window alongside the numbers — a conversion count without it invites misreading.

## Output Format

> **Account:** Acme (USD) · **Window:** 2026-07-04 – 2026-08-02
> **Conversion event:** Purchase · **Attribution:** 7-day click

| Campaign | Spend | Conversions | Cost / Conv. |
|---|---:|---:|---:|
| Summer Promo | USD 4,182.90 | 88 | USD 47.53 |
| Retargeting | USD 1,004.10 | 0 | Not computable (no conversions) |

## Analysis Guidelines

- **Do not trend conversions within a window.** Totals are whole-window. To compare periods, run separate requests per period and compare the totals.
- **Do not mix attribution windows.** If several events have different windows, report them separately rather than summing.
- **Zero conversions is a real answer**, especially over a short window or a small spend. Say so plainly rather than implying a tracking fault.
- **Do not claim insights returns conversions.** It does not; the merge happens on Hopkin's side via `include_conversions`.

## Common Failure Modes

| Symptom | Cause |
|---|---|
| 404 from conversion settings | Account not enabled for conversion tracking |
| Cost per conversion is infinite | Divided by zero conversions — guard it |
| Conversions do not vary by day | Expected; totals are whole-window by design |
| Conversion count seems high or low | Check the attribution window before drawing a conclusion |
