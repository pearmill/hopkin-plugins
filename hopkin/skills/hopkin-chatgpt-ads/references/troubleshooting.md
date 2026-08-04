# ChatGPT Ads Skill — Troubleshooting Guide

Diagnostics for the Hopkin ChatGPT Ads MCP. Several entries below describe behavior verified against the live API that contradicts the vendor documentation.

## Table of Contents

- [MCP Server Issues](#mcp-server-issues)
- [Authentication Problems](#authentication-problems)
- [Empty or Wrong Report Data](#empty-or-wrong-report-data)
- [Delivery Problems](#delivery-problems)
- [API Error Types](#api-error-types)
- [Common Mistakes](#common-mistakes)

---

## MCP Server Issues

### MCP Server Not Found

**Symptom:** No `chatgpt_ads_` prefixed tools are available.

**Resolution:**
1. Confirm the user has signed up at https://app.hopkin.ai
2. Confirm the MCP is registered at `https://chatgpt.mcp.hopkin.ai/mcp` with a valid bearer token
3. Restart Claude after any configuration change

---

## Authentication Problems

### No Connection Yet

**Symptom:** Tools report that no ChatGPT Ads connection is available.

ChatGPT Ads has **no OAuth**. The user must paste an API key:

1. Issue a key in **ChatGPT Ads Manager → Settings** (https://ads.openai.com)
2. Paste it at https://app.hopkin.ai → Connections → ChatGPT Ads
3. Name the connection something recognizable

The key is validated against the platform before being stored, so an invalid key is rejected at paste time rather than failing later.

### Stored Key Rejected (401)

**Symptom:** A tool fails with an authentication error.

The key was revoked or rotated on the platform. **There is no refresh path** — keys cannot be renewed. The user must issue a new key and reconnect.

> The error message deliberately does not include the rejected key. The platform echoes the key (middle-masked) in its own 401 text; Hopkin replaces that message so no part of a real credential reaches logs or tool output. This is expected, not a loss of diagnostic detail — the `code` field carries the signal.

### Permission Errors on a Shared Connection

Shared connections are read-only for recipients and cannot be renamed, re-shared, or revoked by them. Those operations are owner-only. Ask the owner.

---

## Empty or Wrong Report Data

### A Report Returned 200 With Zero Rows

The most common cause is a **date window that does not align to the account's local day**. Windows are interpreted in the account's timezone; a misaligned window returns HTTP 200 with an empty row set rather than an error, so it looks like "no data" when it is really "wrong window".

**Resolution:**
1. Call `chatgpt_ads_get_ad_account` to get the account timezone
2. Express `date_since` / `date_until` as plain `YYYY-MM-DD` dates
3. Ensure the window does not end today — see below

### The Window Cannot End in the Future

The platform rejects a window whose end is in the future, and "today" is evaluated in the **account's** timezone — which may still be yesterday relative to the user. The default window is therefore the **last 30 complete days ending yesterday**.

If a user asks for "including today", explain that the platform only reports complete days.

### Metrics Are Missing From the Response

If a report comes back with impressions but no clicks or spend, the request did not specify an explicit field projection. The live API's default projection is **`impressions` only** — the vendor quickstart showing a fuller default is stale. Request the fields you need explicitly.

### Metric Names Look Inconsistent

The row entity's own metrics are **unprefixed** (`spend`, `clicks`). When a `segment` is applied, the segment's metrics are **prefixed** (`product_spend`). Both can appear in one response. Read the key names rather than assuming a naming scheme.

---

## Delivery Problems

### Ads Are Active But Not Serving

Check `review_status`, not just `status`. An ad that is `active` still cannot serve until it is approved. `chatgpt_ads_list_ads` returns both; filter with `review_status` to find ads that are in review or rejected.

Other things to check, in order:
1. Ad review status (above)
2. Parent ad group and campaign status — a paused parent stops everything beneath it
3. Campaign flight dates
4. Budget — remember budgets are in **micros**

### Nothing Is Returned for "list all my ads"

There is no account-wide or campaign-wide ad listing. `list_ads` requires an `ad_group_id` (or explicit `ad_ids`). Traverse campaigns → ad groups → ads.

This is a deliberate omission: an account-wide listing would be O(campaigns × ad groups) requests against a rate limit counted per IP shared across users.

---

## API Error Types

### Rate Limiting (429)

Limits are 600 requests/minute per endpoint and 1,200 overall, counted **per ad account and per IP**. Because the egress IP is shared, another user's activity can contribute.

**Do not retry in a tight loop.** Back off, reduce the breadth of traversal, and prefer cached results (omit `refresh: true`).

There are no rate-limit headers on responses, so remaining quota cannot be reported.

### 404 That Means "Not Enabled"

The conversions endpoints answer **404** for accounts that are not enabled for conversion tracking. This is not a missing entity and not a malformed request.

Report the delivery data you do have and state that conversion reporting is not enabled for the account.

### 400 on Insights

Two frequent causes:
1. **A window ending in the future** — see above
2. **An invalid field name** — the platform's message lists the valid fields; read it rather than guessing

One specific case: `metadata.readable_time` is invalid when `time_granularity` is `none`, and it fails the entire request rather than being ignored.

---

## Common Mistakes

### Reporting Micros as Currency

Campaign budgets and bids are **integer micros**; `spend`, `cpc`, `cpm` from insights are **decimals already in account currency**. Presenting a micros budget as a currency amount overstates it by 1,000,000×. Convert explicitly and name the currency.

### Assuming USD or UTC

Both come from `chatgpt_ads_get_ad_account`. Never assume.

### Claiming Conversions Are a Metric

Insights exposes exactly six metrics and conversions is not among them. Conversions require `include_conversions: true` and arrive as whole-window totals with no time bucketing.

### Dividing by Zero for Cost per Conversion

Cost per conversion is not returned; it is derived as `spend / conversions`. Guard the zero case explicitly — reporting an infinite or NaN cost is a failure.

### Presenting Bucketed Audience Sizes as Exact

Custom audience sizes are range strings such as `"5000-10000"`. Do not render them as precise numbers.

### Reporting Raw Audience IDs

Campaign targeting returns bare opaque IDs. Resolve them to names with `chatgpt_ads_list_custom_audiences` before reporting.

### Guessing IDs

Every ID must come from a prior call. IDs are interpolated into request paths and are format-validated, but a well-formed guess can still address the wrong entity.

Do not infer meaning from ID prefixes either — they differ from the documentation (conversion event settings have no `ces_` prefix; sources use `cds_`, not `clidsrc_`).

### Calling Auth Check Proactively

`chatgpt_ads_check_auth_status` is for use **after** a failure. Calling it first wastes a request against a shared rate limit.

### Expecting Revoke to Invalidate the Key

`chatgpt_ads_revoke_connection` deletes Hopkin's stored copy only. The key stays valid on the platform until deleted in ChatGPT Ads Manager.
