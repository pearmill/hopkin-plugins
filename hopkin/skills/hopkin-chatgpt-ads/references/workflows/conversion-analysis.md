# Conversion Analysis

## Overview

Reports conversions alongside delivery data: daily or monthly trends, order counts and revenue per conversion event, cost per conversion, and day-by-day reconciliation against store orders (e.g. Shopify).

Three things make this different from other platforms' conversion reporting:

1. **Conversions are not an insights metric.** The six metrics are impressions, clicks, spend, ctr, cpc, cpm. Conversions arrive in a separate `conversions` block next to the delivery rows.
2. **`conversions` counts the goal event, not orders.** The goal event is the conversion event setting the account optimizes for (often `lead_created`). Order counts and revenue live in the per-event breakdown, `attributed_events`, under `order_created`.
3. **The attribution date basis changes which events are reported.** `conversion_time` matches how a store dates its orders but reliably reports only the goal event; `ad_event_time` (the default) covers every event.

## Primary Tools

- `chatgpt_ads_get_insights` with `include_conversions: true` (or any attribution option)
- `chatgpt_ads_list_conversion_event_settings` — which event is the goal, and its configured attribution window

## Step-by-Step Workflow

### Step 1: Establish Account Context

```
chatgpt_ads_get_ad_account(reason: "Get currency and timezone for conversion analysis")
```

Cost per conversion and order revenue are money values and need the account currency. Days are in the account timezone, which matters when matching against store orders.

If the user has several ChatGPT Ads accounts, `chatgpt_ads_list_ad_accounts` first and pick the one they mean (for orders, the one that records `order_created`), providing its `connection_id`.

### Step 2: Check What Is Being Counted

```
chatgpt_ads_list_conversion_event_settings(reason: "Identify the goal conversion event and its attribution window")
```

This tells you what the goal-event `conversions` count means. Without it, that count is uninterpretable.

**If this returns 404**, the account is not enabled for conversion tracking. That is a feature gate, not an error. Report the delivery data and say conversion reporting is not enabled.

### Step 3: Pull Insights With Conversions — One Call

```
chatgpt_ads_get_insights(
  level: "ad_account",
  aggregation_level: <omit for account totals, or "campaign" / "ad">,
  time_granularity: "daily",          # or "monthly", or "none" for window totals
  include_conversions: true,
  event_names: ["order_created"],     # optional: narrow the per-event list
  date_since: "YYYY-MM-DD",
  date_until: "YYYY-MM-DD",
  reason: "..."
)
```

One call returns every day in the window. **Never loop one call per day.**

Optional attribution overrides (each implies `include_conversions`):
- `attribution_time_basis: "conversion_time"` — count on the conversion day instead of the click/impression day
- `attribution_window_days: 7 | 14 | 30` — click-through window (default 30)
- `view_through_attribution_window_days: 0 | 1` — `0` excludes view-through (default 1)

Read the settings actually applied from `conversions.attribution` and state them.

### Step 4: Read the Conversions Block

- `conversions.data[]` — rows per entity per `date` (daily) or `month` (monthly)
- `conversions` / `click_through_conversions` / `view_through_conversions` — the goal event
- `order_created_attributed_sales` — order revenue, a decimal **string** in the account currency
- `attributed_events[]` — one entry per event name with `attributed_event_count` (e.g. the number of orders for `order_created`) and `attributed_event_value_amount`

Conversion rows can exist for days or entities with no delivery row (conversions attributed to earlier clicks). Join on entity + date, not by position.

Conversions come on the **first page** only. If you page through delivery rows, keep the conversions from page 1.

### Step 5: Derive Cost per Conversion

Not returned by the API. Compute it:

```
cost_per_conversion = spend / conversions        # goal event
cost_per_order      = spend / order_created count
```

**Guard the zero case explicitly.** If the count is zero, say the cost cannot be computed. Reporting `∞`, `NaN`, or a blank is a failure.

### Step 6: Present

State the attribution basis and windows alongside the numbers. A conversion count without them invites misreading.

## Output Format

> **Account:** Acme (USD) · **Window:** 2026-10-20 – 2026-10-22
> **Goal event:** lead_created · **Attribution:** ad-event time, 30-day click / 1-day view

| Day | Spend | Orders | Order revenue | Cost / order |
|---|---:|---:|---:|---:|
| 2026-10-20 | USD 52.00 | 1 | USD 120.00 | USD 52.00 |
| 2026-10-21 | USD 64.00 | 2 | USD 250.00 | USD 32.00 |
| 2026-10-22 | USD 48.00 | 0 | USD 0.00 | Not computable (no orders) |

## Reconciling Against Store Orders

1. Pull daily rows with `event_names: ["order_created"]` on the default `ad_event_time` basis. That gives a per-day order count and revenue.
2. Match each day's revenue to the store's order totals for that day (account timezone).
3. If the user asks for conversion-time numbers, run `conversion_time` too. If `order_created` is missing (the tool warns `conversion_events_missing`), say so; do not report zero orders.
4. Per-order IDs are not available from the API, so matching is by day and amount.

## Analysis Guidelines

- **Do not present the goal-event count as orders.** Use the `order_created` event count.
- **Do not mix attribution settings** across numbers you compare. Say which basis and windows each figure uses.
- **Zero conversions is a real answer**, especially over a short window or a small spend. Say so plainly rather than implying a tracking fault.
- **Absence under conversion time is not zero.** A warned-missing event is a reporting gap.
- **Do not claim insights returns conversions.** It does not; the conversions block is added by Hopkin via `include_conversions`.

## Common Failure Modes

| Symptom | Cause |
|---|---|
| 404 from conversion settings | Account not enabled for conversion tracking |
| Cost per conversion is infinite | Divided by zero conversions — guard it |
| `conversions` differs from the order count | Expected; `conversions` is the goal event, orders are `order_created` |
| `order_created` missing under conversion time | API limitation; use `ad_event_time` for orders |
| No conversions on page 2 | They come on page 1 only (`conversions_on_first_page`) |
| `include_conversions` with `segment` rejected | Conversions are per entity, not per device/country — use two calls |
| Conversion count seems high or low | Check the attribution windows before drawing a conclusion |
