# Delivery Performance Report

## Overview

Reports spend, impressions, clicks, CTR, CPC and CPM for a ChatGPT Ads account over a date window, at account, campaign, ad group, or ad granularity.

These six metrics are the **only** ones the API exposes. There is no conversions metric here — see **conversion-analysis.md**.

## Primary Tool

`chatgpt_ads_get_insights` — returns raw JSON so rows can be parsed and re-aggregated.

## Required Context Before Reporting

`chatgpt_ads_get_ad_account` — for **currency** and **timezone**. Every money value is in the account's currency and every date is interpreted in the account's timezone. Do not assume USD or UTC.

## Step-by-Step Workflow

### Step 1: Establish Account Context

```
chatgpt_ads_get_ad_account(reason: "Get currency and timezone for performance report")
```

Record `currency` and `timezone`. If the user has multiple connections, confirm which account first with `chatgpt_ads_list_ad_accounts`.

### Step 2: Determine the Date Window

- Default: the **last 30 complete days ending yesterday**, in the account timezone
- The window **cannot end in the future** — a window ending today is rejected
- Translate relative phrasing ("last two weeks") into explicit `YYYY-MM-DD` bounds

If the user asks to include today, explain that the platform reports complete days only.

### Step 3: Choose Aggregation

| Question | `aggregation_level` |
|---|---|
| "How did the account do?" | account |
| "Which campaigns performed best?" | campaign |
| "Which ad groups are efficient?" | ad group |
| "Which ads spent the most?" | ad |

Use `time_granularity` only when the user wants a trend over time. For a single summary per entity, leave it at `none`.

### Step 4: Request the Report

```
chatgpt_ads_get_insights(
  aggregation_level: <level>,
  date_since: "YYYY-MM-DD",
  date_until: "YYYY-MM-DD",
  sort: <spend descending, for "top" questions>,
  reason: "..."
)
```

Request the fields the question needs explicitly. The live default projection is **`impressions` only**.

### Step 5: Present

Report actual figures from the response. Never fill gaps with invented numbers — if a metric is absent, say so.

## Output Format

State the window and timezone, then the table.

> **Account:** Acme (USD, America/Los_Angeles)
> **Window:** 2026-07-04 – 2026-08-02 (last 30 complete days)

| Campaign | Spend | Impressions | Clicks | CTR | CPC |
|---|---:|---:|---:|---:|---:|
| Summer Promo | USD 4,182.90 | 512,004 | 3,204 | 0.63% | USD 1.31 |

## Analysis Guidelines

- **Rank before interpreting.** For "which spent most", sort and name the top entity with its figure.
- **Respect denominators.** Do not present a CTR derived from a few dozen impressions as a trend.
- **Currency discipline.** `spend`, `cpc`, `cpm` are decimals already in account currency. Campaign *budgets* are integer micros (1,000,000 = 1 unit) — never mix the two in one column.
- **Zero rows is a finding.** An empty result over a window the user believes was active usually means a misaligned window, not an idle account. See troubleshooting.

## Common Failure Modes

| Symptom | Cause |
|---|---|
| 200 with zero rows | Window misaligned to the account's local day |
| Only impressions returned | No explicit field projection requested |
| 400 rejecting the request | Window ends in the future, or an invalid field name |
| Spend looks 1,000,000× too large | A micros budget was reported as currency |
