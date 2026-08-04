# Account & Targeting Review

## Overview

Summarizes how an account is set up: its settings, its campaign structure, and who its campaigns are actually targeting — including resolving opaque audience IDs into names.

## Primary Tools

- `chatgpt_ads_list_ad_accounts` / `chatgpt_ads_list_connections`
- `chatgpt_ads_get_ad_account`
- `chatgpt_ads_list_campaigns`
- `chatgpt_ads_list_custom_audiences`

## Step-by-Step Workflow

### Step 1: Identify the Account

```
chatgpt_ads_list_ad_accounts(reason: "Show which ChatGPT Ads accounts are reachable")
```

Each API key is scoped to exactly one ad account, so **a single result is correct and normal** — not a failure. A user with three ad accounts has three connections.

This lists connections, so the name shown is the one the user chose. It may differ from the platform's own account name.

### Step 2: Get Account Settings

```
chatgpt_ads_get_ad_account(reason: "Report account currency, timezone and review status")
```

Returns name, status, currency, timezone, website, and account review status.

**If the platform name differs from the connection name**, prefer the platform name in the report and mention the connection name for disambiguation — for example: *Flux AI (connected as "Flux")*.

### Step 3: Review Campaign Structure

```
chatgpt_ads_list_campaigns(reason: "Review campaign structure and targeting")
```

Record status, flight dates, budget (**integer micros**), and the `targeting` block.

### Step 4: Resolve Audience Targeting

Campaign targeting returns `targeting.custom_audiences.ids` as **bare opaque IDs**. Resolve them:

```
chatgpt_ads_list_custom_audiences(
  custom_audience_ids: ["<id>", "<id>"],
  reason: "Resolve audience IDs referenced in campaign targeting"
)
```

If no campaign references any audience, checking and saying so is the correct outcome — do not invent audience names.

To answer "what audiences exist", call the tool with no ID filter. An account with none is a valid answer.

## Output Format

> **Account:** Flux AI (connected as "Flux") · USD · America/Los_Angeles · Active

| Campaign | Status | Budget | Targeting |
|---|---|---:|---|
| Summer Promo | active | USD 500.00/day | US, CA · Audience: *Past Purchasers* |
| Retargeting | paused | USD 100.00/day | US · Audience: *Cart Abandoners* |

Note the budget conversion: a `500000000` micros budget is `USD 500.00`.

## Analysis Guidelines

- **Convert micros.** Budgets and bids are integer micros — 1,000,000 micros = 1 unit of account currency.
- **Report audience names, not IDs.** A raw ID is not an answer.
- **Audience sizes are buckets.** They come back as range strings such as `"5000-10000"`. Never present one as an exact count.
- **Some campaigns target by location only.** If a campaign has no custom audience, that is a fact about the campaign, not a gap to fill.
- **Do not parse IDs.** Prefixes differ from the documentation and carry no reliable meaning.

## Sharing Considerations

If the user wants a teammate to report on this account, `chatgpt_ads_share_connection` shares it with their organization.

> The ChatGPT Ads API has **no reduced-scope keys**, so sharing grants full read access to the entire ad account. Say this before sharing.

`chatgpt_ads_revoke_connection` deletes only Hopkin's stored copy of the key. The key stays valid on the platform until the user deletes it in ChatGPT Ads Manager → Settings.
