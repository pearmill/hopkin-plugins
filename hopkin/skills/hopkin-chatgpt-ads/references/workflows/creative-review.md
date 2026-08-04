# Creative & Review Audit

## Overview

Determines which ads are actually eligible to serve, and why any are not. The key insight: **`status` and `review_status` are different gates.** An ad can be `active` and still never serve because it has not been approved.

## Primary Tools

- `chatgpt_ads_list_campaigns`
- `chatgpt_ads_list_ad_groups` — requires `campaign_id`
- `chatgpt_ads_list_ads` — requires `ad_group_id` or `ad_ids`

## Required Traversal

The API has **no account-wide or campaign-wide ad listing**. There is no shortcut: campaigns → ad groups → ads. Never guess an ID to skip a level.

## Step-by-Step Workflow

### Step 1: List Campaigns

```
chatgpt_ads_list_campaigns(reason: "Find campaigns to audit creative review status")
```

Note each campaign's `id` and `status`. A paused campaign stops everything beneath it, which is often the real answer.

### Step 2: List Ad Groups Per Campaign

```
chatgpt_ads_list_ad_groups(campaign_id: "<real id from step 1>", reason: "...")
```

Scope this. Auditing every campaign in a large account multiplies requests against a rate limit counted per IP. If the user named a campaign, use only that one.

### Step 3: List Ads Per Ad Group

```
chatgpt_ads_list_ads(ad_group_id: "<real id from step 2>", reason: "...")
```

Use `review_status` to filter directly when looking for problems.

### Step 4: Classify

For each ad, record:

- `status` — active / paused
- `review_status` — approved / in_review / rejected
- Which ad group and campaign it belongs to

An ad is servable only when its own status is active, its review is approved, **and** every parent is active.

## Output Format

Lead with the count of ads that cannot serve, then the detail.

> 3 of 14 ads are not eligible to serve: 1 rejected, 2 still in review.

| Ad | Campaign / Ad Group | Status | Review | Servable |
|---|---|---|---|---|
| Hero A | Summer Promo / Broad | active | rejected | No — rejected |
| Hero B | Summer Promo / Broad | active | in_review | Not yet |
| Hero C | Summer Promo / Retarget | paused | approved | No — paused |

## Diagnostic Order

When asked "why isn't this delivering?", check in this order and stop at the first failure:

1. **Ad review status** — not approved means it cannot serve regardless of anything else
2. **Ad status** — paused
3. **Ad group status** — paused
4. **Campaign status** — paused
5. **Campaign flight dates** — window ended or not started
6. **Budget** — remember budgets are **integer micros**, so a budget that looks enormous may be small once converted

## Notes

- Ads carry no parent ID from the platform; the campaign and ad group context comes from the query you made, so keep track of it as you traverse.
- Do not report a rejection reason you did not receive. If the response gives only a review state, report the state.
- Fixing any of this requires ChatGPT Ads Manager — this MCP is read-only. Offer the diagnosis, then say where to make the change.
