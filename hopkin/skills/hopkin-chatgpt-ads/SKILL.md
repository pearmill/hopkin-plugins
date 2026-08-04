---
name: hopkin-chatgpt-ads
description: Analyze and report on ChatGPT Ads (OpenAI Ads) campaigns using the Hopkin ChatGPT Ads MCP. Includes prerequisite checks, API-key connection setup, campaign and creative traversal, delivery reporting, conversion analysis, audience resolution, and developer feedback for unsupported write operations.
---

# ChatGPT Ads Skill

## Introduction

This skill enables Claude to analyze and report on ChatGPT Ads (OpenAI Ads) campaigns via the Hopkin ChatGPT Ads MCP. Use this skill when you need to:

- Report on delivery performance — impressions, clicks, spend, CTR, CPC, CPM
- Review campaign, ad group, and ad structure
- Diagnose why ads are not delivering (review status, budgets, dates)
- Analyze conversions and derive cost per conversion
- Resolve custom audience targeting from bare IDs to names
- Manage which connected ad account is used

**This MCP is read-only.** It can report on the account but cannot create, edit, pause, or archive anything. See [Write Operations](#write-operations-unsupported--developer-feedback).

## Prerequisites

Before using this skill, verify that the Hopkin ChatGPT Ads MCP is configured and a key is connected.

### Check for MCP Availability

1. Check for `chatgpt_ads_` prefixed tools in your available tools (e.g. `chatgpt_ads_get_ad_account`, `chatgpt_ads_list_campaigns`)
2. If found, the Hopkin ChatGPT Ads MCP is properly configured

### If Hopkin ChatGPT Ads MCP Is Not Installed

If no `chatgpt_ads_` prefixed tools are available:

1. **Inform the user** that the Hopkin ChatGPT Ads MCP is required to use this skill
2. **Direct them to sign up** at https://app.hopkin.ai
3. **Provide setup instructions:**

> The Hopkin ChatGPT Ads MCP is not configured. To use this skill:
>
> 1. Sign up at **https://app.hopkin.ai**
> 2. Add the hosted MCP to your Claude configuration:
>
> ```json
> {
>   "mcpServers": {
>     "hopkin-chatgpt-ads": {
>       "type": "url",
>       "url": "https://chatgpt.mcp.hopkin.ai/mcp",
>       "headers": {
>         "Authorization": "Bearer YOUR_HOPKIN_TOKEN"
>       }
>     }
>   }
> }
> ```
>
> 3. Restart Claude after updating configuration

### Authentication Flow

ChatGPT Ads differs from every other Hopkin ads integration: **the platform has no OAuth.** Users authenticate by pasting an API key.

1. The user issues a key in **ChatGPT Ads Manager → Settings**
2. They paste it at **https://app.hopkin.ai** → Connections → ChatGPT Ads
3. They give the connection a name they will recognize (e.g. "Acme — House Account")

The key is validated against the platform before it is stored, then encrypted at rest.

**Do NOT call `chatgpt_ads_check_auth_status` proactively.** Call the tool you actually need. Only check auth after another tool fails with a permission or authentication error.

### One API Key = One Ad Account

There is no account-listing endpoint on the platform and no account-id parameter on any tool — **the key itself is the account scope**. A user with three ad accounts has three separate connections.

This means `chatgpt_ads_list_ad_accounts` lists the user's **connections**, not accounts fetched from the platform.

### Multiple Accounts

If the user has more than one connection:

- `chatgpt_ads_list_connections` shows each connection's display name, id, and which is the default
- Pass `connection_id` to target a specific one
- `chatgpt_ads_set_default_connection` changes which is used when `connection_id` is omitted

**Naming caveat:** a connection's display name is chosen by the user and may differ from the account's name on the platform. `chatgpt_ads_list_ad_accounts` shows the *connection* name; `chatgpt_ads_get_ad_account` shows the *platform* name. If they disagree, prefer the platform name when reporting and mention the connection name for disambiguation.

## Available MCP Tools

**Discovery**
- `chatgpt_ads_list_ad_accounts` — connections you can reach
- `chatgpt_ads_get_ad_account` — name, status, **currency**, **timezone**, review status

**Structure** (must be traversed top-down)
- `chatgpt_ads_list_campaigns`
- `chatgpt_ads_list_ad_groups` — requires `campaign_id`
- `chatgpt_ads_list_ads` — requires `ad_group_id` or `ad_ids`

**Reporting**
- `chatgpt_ads_get_insights` — the performance report
- `chatgpt_ads_list_conversion_event_settings`
- `chatgpt_ads_list_custom_audiences`

**Connections**
- `chatgpt_ads_list_connections`, `set_default_connection`, `rename_connection`, `share_connection`, `unshare_connection`, `revoke_connection`

**Utility**
- `chatgpt_ads_ping`, `chatgpt_ads_check_auth_status`, `chatgpt_ads_developer_feedback`

See **references/mcp-tools-reference.md** for full parameters.

## Core Capabilities

### Always Establish Currency and Timezone First

Call `chatgpt_ads_get_ad_account` before reporting money or dates. Every spend figure is in the **account's** currency, and every date window is interpreted in the **account's** timezone. Never assume USD or UTC.

### The Hierarchy Must Be Traversed

The API has **no account-wide ad group or ad listing**. `list_ad_groups` requires a `campaign_id`; `list_ads` requires an `ad_group_id` (or explicit `ad_ids`).

To answer "show me my ads", you must:

1. `chatgpt_ads_list_campaigns` → real campaign IDs
2. `chatgpt_ads_list_ad_groups(campaign_id)` → real ad group IDs
3. `chatgpt_ads_list_ads(ad_group_id)`

**Never invent an ID to skip a step.** A guessed ID either errors or, worse, silently reports on the wrong entity.

### Two Different Money Units

This is the single most common reporting error:

| Value | Unit |
|---|---|
| Campaign budgets, bids | **integer micros** — 1,000,000 micros = 1 unit of account currency |
| `spend`, `cpc`, `cpm` from insights | **decimals already in account currency** |

Presenting a micros budget as if it were dollars overstates it by a factor of a million. Convert explicitly and say which currency.

### Only Six Metrics Exist

`impressions`, `clicks`, `spend`, `ctr`, `cpc`, `cpm`. That is the complete list.

**There is no conversions metric in insights.** Conversions come from a separate path — set `include_conversions: true` — and arrive as **whole-window totals** with no time bucketing. Cost per conversion is not returned and must be derived as `spend / conversions`, with an explicit guard for zero conversions (never report an infinite or NaN cost).

### Review Status Gates Delivery

An ad can be `active` and still not serve if its `review_status` is not approved. When asked why something is not delivering, check `review_status` on the ads, not just `status`.

### Custom Audiences Resolve Identity

`chatgpt_ads_list_campaigns` returns `targeting.custom_audiences.ids` as **bare opaque IDs**. Use `chatgpt_ads_list_custom_audiences` with `custom_audience_ids` to turn those into names. Report names, not raw IDs.

Audience sizes come back as **bucketed range strings** (e.g. `"5000-10000"`). Never present a bucketed range as an exact count.

### Write Operations (Unsupported — Developer Feedback)

This MCP is read-only by design. If the user asks to create, edit, pause, activate, archive, or adjust budgets:

1. **Tell them plainly** that the ChatGPT Ads MCP is read-only and the change must be made in ChatGPT Ads Manager
2. **Offer the analysis** that would inform the change
3. **Call `chatgpt_ads_developer_feedback`** with `feedback_type: "new_tool"` describing the operation they wanted

Do not attempt a workaround. There is no write path.

### Proactive Efficiency Feedback

If you find yourself making many calls to answer a routine question — for example traversing every campaign and ad group just to list all ads — submit `chatgpt_ads_developer_feedback` with `feedback_type: "improvement"`. Note that an account-wide ad listing is deliberately absent because it would be O(campaigns × ad groups) against a shared rate limit, so propose a narrower aggregate rather than a blanket listing.

### User Feedback to Skill Developers

If the user reports a gap in this skill itself, call `chatgpt_ads_developer_feedback` with `interface: "skill"`.

## Report Workflows

Detailed procedures live in `references/workflows/`:

### Delivery Performance Report
Spend, impressions, clicks, CTR, CPC, CPM over a window, at account/campaign/ad-group/ad level.
→ **references/workflows/delivery-performance.md**

### Creative & Review Audit
Which ads are approved, in review, or rejected, and what is therefore eligible to serve.
→ **references/workflows/creative-review.md**

### Conversion Analysis
Conversion totals, configured events and attribution windows, derived cost per conversion.
→ **references/workflows/conversion-analysis.md**

### Account & Targeting Review
Account settings, campaign structure, and resolved audience targeting.
→ **references/workflows/account-targeting.md**

## Workflow Process

1. **Establish context** — `chatgpt_ads_get_ad_account` for currency and timezone
2. **Confirm scope** — which connection, which date window
3. **Traverse only as deep as the question requires**
4. **Pull the report** — `chatgpt_ads_get_insights`
5. **Resolve identities** — audience IDs to names where relevant
6. **Present** — tables, correct units, explicit window and timezone

## Best Practices

### Metric Interpretation Guidelines

- **CTR** — clicks ÷ impressions. Low CTR with high impressions points at creative or targeting relevance.
- **CPC / CPM** — always in account currency. Compare only within the same currency.
- **Spend with zero impressions** — should not occur; if seen, report it rather than explaining it away.
- **Impressions with zero clicks** — normal at low volume. Do not call it a problem without enough impressions to be meaningful.
- **Small denominators** — do not compute a rate from a handful of impressions and present it as a trend.

### Date Windows

- The default window is the **last 30 complete days ending yesterday**, computed in the account's timezone.
- **The window cannot end in the future.** A window ending today is rejected by the platform.
- Always state the window and timezone in the output.

### Report Formatting Preferences

- Lead with the answer, then the table
- Currency values: symbol or code plus the amount, e.g. `USD 1,234.56`
- Rates as percentages with one or two decimals
- Sort by whatever the question implies (usually spend descending)
- Say plainly when the account has no data, rather than presenting empty tables

### Error Handling Patterns

- **401 / auth error** → the stored key was rejected. The user must issue a new key in ChatGPT Ads Manager → Settings and reconnect at https://app.hopkin.ai. The key cannot be refreshed.
- **404 on conversions endpoints** → often means "feature not enabled for this account", not "missing". Report delivery data and say conversion reporting is not enabled.
- **429** → rate limited. Limits are counted per ad account *and* per IP. Back off; do not retry in a tight loop.
- **400 on insights** → usually an invalid field or a window ending in the future. The platform's message lists valid fields; read it.

## Troubleshooting

Common issues and their resolutions are documented in **references/troubleshooting.md**, including:

- MCP not found or not authenticated
- Empty reports that returned HTTP 200
- Ads that appear active but do not serve
- Micros-vs-currency confusion
- Conversion reporting not enabled
- Rate limiting

## Additional Resources

- **references/mcp-tools-reference.md** — full parameter reference for all 17 tools
- **references/troubleshooting.md** — diagnostic guide
- **references/workflows/** — step-by-step report procedures
- Hopkin dashboard — https://app.hopkin.ai
- ChatGPT Ads Manager — https://ads.openai.com
