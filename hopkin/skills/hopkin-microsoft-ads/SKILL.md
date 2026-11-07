---
name: hopkin-microsoft-ads
description: Generate Microsoft Advertising (Bing Ads) account summaries, performance reports and audits using the Hopkin Microsoft Ads MCP. Covers Search, Shopping, Performance Max and Audience campaigns, with prerequisite checks, authentication flow, keyword and search term analysis, impression share, audience and demographic reports, policy and tracking audits, change history, and developer feedback for unsupported write operations.
---

# Microsoft Ads Reports Skill

## Introduction

This skill enables Claude to build reports and perform analysis on Microsoft Advertising (formerly Bing Ads) accounts via the Hopkin Microsoft Ads MCP. Use this skill when you need to:

- Summarize how a Microsoft Ads account performed over a period
- Report on campaigns, ad groups, ads and keywords, including Quality Score
- Analyze search terms and find negative keyword opportunities
- Check impression share lost to budget and to ad rank
- Break performance down by age, gender, location, device, day of week or hour, and by audience list
- Audit disapproved ads, keywords and ad extensions, UET tag health, and URL tracking
- See what changed in an account, when, and who changed it

It covers Search, Shopping, Performance Max and Audience (Microsoft Audience Network) campaigns.

**This MCP is read-only.** It can report on the account but cannot create, edit, pause or delete anything. See [Write Operations](#write-operations-unsupported--developer-feedback).

## Prerequisites

Before using this skill, verify that the Hopkin Microsoft Ads MCP is configured and the user is authenticated.

### Check for MCP Availability

1. Check for `microsoft_ads_` prefixed tools in your available tools (e.g. `microsoft_ads_list_accounts`, `microsoft_ads_get_account_summary`)
2. If found, the Hopkin Microsoft Ads MCP is properly configured

### If Hopkin Microsoft Ads MCP Is Not Installed

If no `microsoft_ads_` prefixed tools are available:

1. **Inform the user** that the Hopkin Microsoft Ads MCP is required to use this skill
2. **Direct them to sign up** at https://app.hopkin.ai/?utm_source=claude-plugin&utm_medium=skill&utm_content=microsoft-ads
3. **Provide setup instructions:**

> The Hopkin Microsoft Ads MCP is not configured. To use this skill:
>
> 1. Sign up at **https://app.hopkin.ai/?utm_source=claude-plugin&utm_medium=skill&utm_content=microsoft-ads**
> 2. Add the hosted MCP to your Claude configuration:
>
> ```json
> {
>   "mcpServers": {
>     "hopkin-microsoft-ads": {
>       "type": "url",
>       "url": "https://microsoft.mcp.hopkin.ai/mcp",
>       "headers": {
>         "Authorization": "Bearer YOUR_HOPKIN_TOKEN"
>       }
>     }
>   }
> }
> ```
>
> 3. Restart Claude after updating configuration

4. **Pause execution** until the user confirms MCP installation is complete
5. **Re-verify** MCP availability after user confirmation

### Authentication Flow

The user connects Microsoft Advertising through OAuth at https://app.hopkin.ai/?utm_source=claude-plugin&utm_medium=skill&utm_content=microsoft-ads (Connections, then Microsoft Ads). Both Microsoft accounts and Google-identity Microsoft Advertising logins work.

**Do NOT call `microsoft_ads_check_auth_status` proactively.** Call the tool you actually need. Only check auth when the user asks about their connection, or after another tool fails with an authentication or permission error (Microsoft fault codes 105 InvalidCredentials, 106 UserIsNotAuthorized, 109 AuthenticationTokenExpired). Code 117 is rate limiting, not auth: wait and retry.

### Required Information

Before generating reports, confirm you have:

- **Account ID** (`account_id`): the numeric Microsoft Advertising AccountId. Every reporting and entity tool needs it. If the user names a client or brand, find it with `microsoft_ads_list_accounts` (`search` matches name or ID).
- **Customer ID** (`customer_id`), only for agency-managed accounts: the manager (customer) that owns the account, Microsoft's equivalent of a Google Ads MCC (`login_customer_id`). `microsoft_ads_list_customers` lists them; pass the customer's ID to `microsoft_ads_list_accounts` to see its accounts.
- **Date range**: a `date_preset` (`Today`, `Yesterday`, `LastSevenDays`, `ThisWeek`, `LastWeek`, `LastFourWeeks`, `ThisMonth`, `LastMonth`, `LastThreeMonths`, `LastSixMonths`, `ThisYear`, `LastYear`) or a custom `date_range` `{ start, end }` in `YYYY-MM-DD`, never both. Most reports default to the last 30 days. `microsoft_ads_get_search_terms` requires `date_range`; `microsoft_ads_get_activities` takes `start_date` / `end_date` instead.

### Customers and Accounts

A **customer** is the manager or agency entity that owns ad accounts. Campaigns and spend live on **accounts**. A direct advertiser sees one customer (or none) and should go straight to `microsoft_ads_list_accounts`. When an agency user gets permission errors on an account, retry with its `customer_id`. When you present `microsoft_ads_list_customers` results, explain this hierarchy (the response carries a `hierarchy_note` for it).

## Available MCP Tools

### Authentication and Status
- `microsoft_ads_check_auth_status`: whether a Microsoft Ads connection exists, whether the server's developer token is configured, the signed-in user and their accounts. Call it for questions about the connection itself, or after an auth failure
- `microsoft_ads_ping`: health check; no authentication needed
- `microsoft_ads_get_billing_status`: call after any tool fails with a billing error (HTTP 402). It says why, gives the organization owner a link to pay, and says when to retry

### Accounts
- `microsoft_ads_list_customers`: manager (agency) customers the user can reach; always live
- `microsoft_ads_list_accounts`: ad accounts with name, ID, number, status and currency. Pass `account_id` to look up one account (there is no separate get-account tool), `customer_id` to list a customer's accounts. Use it for account "details" or "info"; do not follow it with a performance report unless metrics were asked for

### Campaign Structure
- `microsoft_ads_list_campaigns`: campaigns with status, type (Search, Shopping, PerformanceMax, Audience), budget, full bid strategy (`biddingScheme`, `biddingSchemeDetails`, `portfolioBidStrategy`), languages, time zone and URL tracking fields. Look up by `campaign_id` / `campaign_ids`, or filter by `status`, `campaign_type`, `search`. Three opt-in scans:
  - `include_policy_issues: true`: every ad and keyword in the returned campaigns that is Disapproved, ActiveLimited (approved in some markets only) or Inactive (under review), with Microsoft's reasons and appeal status. This is the account-wide disapproval check; combine it with `status: ["Active"]`
  - `include_url_tracking: true`: the account-wide UTM and tracking template audit. Account tracking template, final URL suffix, MSCLKID and UTM auto-tagging, plus every ad group, ad and keyword that sets its own tracking values
  - `include_criteria`: targeting settings per campaign (locations and exclusions with bid modifiers, location intent, radius, device bid adjustments, ad schedules, age and gender). Off by default because it costs one extra call per campaign
- `microsoft_ads_list_ad_groups`: ad groups for one or more campaigns; `campaign_ids` is required
- `microsoft_ads_list_ads`: ads for one or more ad groups; `ad_group_ids` is required. Filter by `ad_types` (ResponsiveSearch, ExpandedText, Responsive, DynamicSearch, Product), `status` or `editorial_status`; `include_policy_issues: true` adds the editorial reasons and appeal status
- `microsoft_ads_list_keywords`: keywords for one ad group (`ad_group_id` is required) with status, match type, bids and editorial status; `include_policy_issues: true` adds the reasons. It carries no Quality Score: use `microsoft_ads_get_keyword_report` for that
- `microsoft_ads_list_ad_extensions`: ad extensions (sitelinks, callouts, structured snippets, images, call, location, price, promotion and the rest) at account, campaign and ad group level, one row per attachment with its editorial status and reasons. `editorial_status: ["Disapproved", "ActiveLimited", "Inactive"]` answers "which extensions are disapproved or under review". Always live
- `microsoft_ads_list_audiences`: audience list definitions (remarketing, similar, customer and combined lists) with size and settings. In-market, custom and product audiences cannot be listed here; they appear only in `microsoft_ads_get_audience_segment_report`

### Reporting
- `microsoft_ads_get_account_summary`: **the tool for one account-level total**, for any preset or custom date range: impressions, clicks, spend, conversions, revenue, CTR, CPC and cost per conversion, plus a per-goal breakdown for the whole account. Also the only source of the account's URL options (`account_url_options`: tracking template, final URL suffix, MSCLKID and UTM auto-tagging)
- `microsoft_ads_get_performance_report`: **one row per campaign, ad group, ad or keyword** (`level`: Campaign by default, AdGroup, Ad, Keyword), with impressions, clicks, spend, CTR, average CPC, conversions, revenue and cost per conversion. `aggregation` is Daily by default; use `Summary` for one row per entity. Filter by `campaign_ids` or `campaign_type` (not at Keyword level)
- `microsoft_ads_get_keyword_report`: keyword performance with Quality Score (1 to 10) and its three components (ExpectedCtr, AdRelevance, LandingPageExperience: AboveAverage, Average or BelowAverage). Filter by `campaign_ids`, `ad_group_ids`, `keyword_match_type`. Default page size is 15 rows
- `microsoft_ads_get_search_terms`: the queries that triggered ads, with campaign, ad group, impressions, clicks, spend and conversions, sorted by impressions. `date_range` is required
- `microsoft_ads_get_impression_share`: impression share, share lost to budget and share lost to rank, per campaign or per ad group (`level: "AdGroup"`)
- `microsoft_ads_get_audience_report`: performance by **demographic, geography, device or time**. `breakdowns` must come from one group per call: demographics (`AgeGroup`, `Gender`), geo (`Location`), or campaign (`Device`, `DayOfWeek`, `HourOfDay`; DayOfWeek and HourOfDay cannot be combined). This is where geographic performance lives
- `microsoft_ads_get_audience_segment_report`: performance by **audience list or segment** (remarketing, in-market, custom, similar, product and combined), with bid adjustment and targeting setting
- `microsoft_ads_get_insights`: the escape hatch. Pick a `report_type` (CampaignPerformance, AdGroupPerformance, AdPerformance, KeywordPerformance, SearchQueryPerformance, AudiencePerformance) and exact `columns`. Use it only when the dedicated reports above do not cover the columns you need

### Negative Keywords
- `microsoft_ads_list_negative_keywords`: negatives added directly to campaigns and ad groups (`level`: Campaign, AdGroup or All). Microsoft negatives are Exact or Phrase
- `microsoft_ads_list_negative_keyword_lists`: shared negative keyword lists, their keywords and the campaigns they apply to. Pass `list_id` to page through every keyword of one list

### Tracking
- `microsoft_ads_get_uet_tag_health`: every UET tag's tracking status (Active, Unverified, Inactive) and every conversion goal's status (RecordingConversions, NoRecentConversions, TagUnverified, TagInactive, InactiveDueToTagUnavailable), with a `summary` of issues. It reports status, not volume: for conversion counts per goal, use a report's `goal_breakdown`

### Change History
- `microsoft_ads_get_activities`: what changed, when and by whom (budgets, bid strategy and targets, status, keywords, negatives, ads, extensions), with old and new values. Filter by `item_types` or `entity_ids`; `start_date` / `end_date` are UTC dates and default to the last 7 days

### Charts and Visualization
- `microsoft_ads_render_chart`: **MCP App. ALWAYS use it when the user asks for a chart, graph, map or visualization**, never a table instead. Supports `bar`, `scatter`, `timeseries`, `funnel`, `waterfall` and `choropleth` (US state heatmap). Fetch the data first with a report tool, then pass it here

### Connections

Tools accept an optional `connection_id`. `microsoft_ads_list_connections` lists them; call `microsoft_ads_set_default_connection`, `microsoft_ads_share_connection`, `microsoft_ads_unshare_connection`, `microsoft_ads_rename_connection` or `microsoft_ads_revoke_connection` only when the user asks.

### Feedback
- `microsoft_ads_developer_feedback`: report a missing tool, a needed improvement, a bug or a workflow gap

> **Note:** Every tool call requires a `reason` (string) parameter for the audit trail.

## Core Capabilities

### Pick the Right Report

| The user asks for | Use |
|---|---|
| How the account did overall, a total for any period, conversions by goal for the account | `microsoft_ads_get_account_summary` |
| A breakdown per campaign, ad group, ad or keyword | `microsoft_ads_get_performance_report` |
| Quality Score, or keyword performance with QS components | `microsoft_ads_get_keyword_report` |
| What people searched for | `microsoft_ads_get_search_terms` |
| Lost impression share, budget-limited campaigns | `microsoft_ads_get_impression_share` |
| Age, gender, location, device, day of week, hour of day | `microsoft_ads_get_audience_report` |
| Remarketing, in-market or custom audience performance | `microsoft_ads_get_audience_segment_report` |
| Columns none of the above return | `microsoft_ads_get_insights` |

A custom date range is never a reason to leave `microsoft_ads_get_account_summary` for the performance report: both take the same date inputs.

### Reports Are Asynchronous

Microsoft generates reports in the background (submit, poll, download). Expect **5 to 30 seconds per report call**; longer ranges, `Daily` aggregation and keyword-level reports are slower. Prefer `aggregation: "Summary"` when the user does not need a trend, and narrow `campaign_ids` on large accounts.

### Pagination

Reports and lists return one page at a time with `count` (the total across all pages) and a top-level `nextCursor` when more rows remain. To get the next page, repeat the call with **exactly the same parameters** plus `cursor` set to `nextCursor` (only `limit` may change). Later report pages re-read the same report rather than running a new one, so rows never repeat or go missing. `microsoft_ads_get_insights` reports the cursor as `pagination.nextCursor` instead. Leave `limit` unset on reports unless the user wants an exact count: the default page is sized to fit a response. `goal_breakdown` comes on the first page only.

### Conversions: Bidding Set vs All Goals

- `conversions` counts only the goals marked "Include in Conversions" in Microsoft Advertising (the bidding set). It reads Microsoft's `ConversionsQualified` column; the legacy `Conversions`, `ConversionRate`, `CostPerConversion` and `ReturnOnAdSpend` columns are rejected because Microsoft returns 0 for them.
- `include_all_conversions: true` adds an `all_conversions` block per row with every goal, including non-bidding and view-through goals. It is usually larger than `conversions`; say which one you report.
- `breakdown_by_goal` (on by default) adds `goal_breakdown`: per-goal conversions, revenue, view-through conversions and assists. Its grain is coarser than the rows: per account or campaign for most reports, per **ad group** for the keyword report (never per keyword). Do not present a parent's goal split as a keyword's or segment's own. Pass `breakdown_by_goal: false` when speed matters more.
- `microsoft_ads_get_search_terms` has no goal breakdown and no view-through count.
- Cost per conversion and ROAS can be derived from spend, conversions and revenue. Guard against zero conversions.

### Money and Units

Spend, CPC and revenue are already in the **account's currency** (not micros). Get the currency from `microsoft_ads_list_accounts` and state it. Campaign `targetRoas` in `biddingSchemeDetails` is a ratio (7.25 means 725%); `targetImpressionShare` is a percent.

### Campaign Types

Valid `campaign_type` values are `Search`, `Shopping`, `PerformanceMax` and `Audience`. `Video` is rejected. Reports cannot filter by type on Microsoft's side, so the tool filters the downloaded rows: `count` and `goal_breakdown` then cover only the matching campaigns. The keyword-level performance report has no type column; filter it with `campaign_ids`.

### The Hierarchy Must Be Traversed

Ad groups belong to campaigns, ads and keywords to ad groups, and the list tools need their parent IDs: `microsoft_ads_list_ad_groups` needs `campaign_ids`, `microsoft_ads_list_ads` needs `ad_group_ids`, `microsoft_ads_list_keywords` needs one `ad_group_id`. **Never guess an ID.** For performance at any level, the reports do not need this traversal.

### Inherited URL Settings

In URL tracking fields, `null` means "not set at this level, inherits from the parent", never "untagged". Only `include_url_tracking` on `microsoft_ads_list_campaigns` resolves the whole account; the account-level template and auto-tagging also come from `microsoft_ads_get_account_summary` (`account_url_options`).

### Live Scans Are Bounded

Policy, extension, URL tracking, UET, negative keyword and targeting data are always read live. Scans that walk many ad groups stop at a bound and say so (`truncated: true` with `truncatedReasons`). **Unchecked is not clean**: if a scan was truncated, report what was not checked and narrow the next call with `campaign_ids` or a smaller `limit`. Performance Max asset groups are not covered by the policy and extension scans.

### Change History Coverage

`microsoft_ads_get_activities` reads Microsoft's own change log, which keeps about 6 months; Hopkin archives it from the account's first sync, given as `coverage.complete_from`. Treat an empty result before that date as "not recorded", never "nothing changed". Changes appear about an hour after they are made. `changedBy` is the user's email, or "Administrator" for Microsoft's automatic changes (budget pauses and resumes, for example). Audience associations, Performance Max asset groups and conversion goals are not in the log.

### Data Visualization

After fetching data, render charts with `microsoft_ads_render_chart` and pair each with a table and written insights:

- **Campaign comparisons** → bar (spend, conversions, CPA by campaign)
- **Trends** → timeseries (daily spend, clicks, conversions)
- **Funnel** → funnel (impressions → clicks → conversions)
- **Correlations** → scatter (spend vs conversions, CPC vs CTR)
- **Budget breakdown** → waterfall (spend by campaign)
- **US states** → choropleth (from a `Location` breakdown)

### Write Operations (Unsupported — Developer Feedback)

The Hopkin Microsoft Ads MCP is **read-only by design**. When a user asks to create, edit, pause, enable or delete anything, change budgets or bids, add negatives, or upload conversions:

1. **Tell them plainly** that the change must be made in Microsoft Advertising (https://ads.microsoft.com) or Microsoft Advertising Editor
2. **Offer the analysis** that informs the change
3. **Call `microsoft_ads_developer_feedback`** with `feedback_type: "missing_tool"` and a `message` describing the operation they wanted and why

Keyword planning and forecasts, ad previews and any write path are deliberately not offered. Report them the same way rather than improvising.

### Proactive Efficiency Feedback

If a routine question took many calls (for example, walking every ad group to collect something a single report should return), call `microsoft_ads_developer_feedback` with `feedback_type: "workflow_gap"` or `"improvement"`, describing what you needed and the steps it took. When a tool returned wrong or incomplete data, use `feedback_type: "bug"` and set `tool_name`.

### User Feedback to Skill Developers

If the user wants to suggest an improvement or report a problem, call `microsoft_ads_developer_feedback` on their behalf with the matching `feedback_type` and their words in `message`.

## Report Workflows

### Account Overview

**Primary tool:** `microsoft_ads_get_account_summary`. One call answers "how did my account do": totals, derived rates and a per-goal conversion split. Add `include_all_conversions: true` when the user cares about non-bidding goals.

---

### Campaign Performance Report

Compare campaigns, find top and bottom performers, and spot spend without conversions.

**Primary tool:** `microsoft_ads_get_performance_report` with `level: "Campaign"` and `aggregation: "Summary"` (or `Daily` for a trend).

**See detailed workflow:** **references/workflows/campaign-performance.md**

---

### Keyword and Search Term Analysis

Quality Score, keyword efficiency, search queries worth adding, and queries to negate.

**Primary tools:** `microsoft_ads_get_keyword_report` + `microsoft_ads_get_search_terms`, cross-checked against `microsoft_ads_list_negative_keywords` and `microsoft_ads_list_negative_keyword_lists`.

**See detailed workflow:** **references/workflows/keyword-analysis.md**

---

### Impression Share and Budget

Find campaigns that are losing impressions to budget (raise budget or tighten targeting) versus rank (improve bids, Quality Score or ads).

**Primary tools:** `microsoft_ads_get_impression_share` + budgets and bid strategies from `microsoft_ads_list_campaigns`. The three share values roughly sum to 100%. Microsoft reports "< 10" and "> 90" as bands, which come back as 5 and 95: present them as "under 10%" and "over 90%". `null` means insufficient data, not zero.

---

### Audience, Demographic and Geographic Performance

**Primary tools:** `microsoft_ads_get_audience_report` for age, gender, location, device and time of day; `microsoft_ads_get_audience_segment_report` for audience lists. Split cross-group breakdowns (such as AgeGroup with Device) into separate calls. For `Location`, keep `order_by: "spend"` (the default): Microsoft returns geo rows ordered by location ID, so the default sort is what surfaces the top locations.

---

### Account Health Audit (Policy, Extensions, Tracking)

Disapproved or limited ads, keywords and extensions; UET tags and conversion goals that stopped recording; untagged or inconsistent URL tracking.

**Primary tools:** `microsoft_ads_list_campaigns` with `include_policy_issues` and `include_url_tracking`, `microsoft_ads_list_ad_extensions` with `editorial_status`, and `microsoft_ads_get_uet_tag_health`.

**See detailed workflow:** **references/workflows/account-health-audit.md**

---

### Change History Review

"Why did performance change?" often starts with "what changed?". Call `microsoft_ads_get_activities` for the window before the shift, then line the changes up against a `Daily` performance report. State the coverage start date.

---

### Client-Side Tracking Audit (Browser)

When the numbers point at a tracking problem rather than a media problem, audit the site itself. The **Hopkin Tag Inspector** Chrome extension reports every analytics and ad tag that fired, per-vendor event counts, findings, and the conversions that were expected but never fired. On Microsoft Ads it shows whether the UET tag actually fires on the page and sends the conversion events, which `microsoft_ads_get_uet_tag_health` can only infer from Microsoft's side.

This runs in the browser, not on the MCP server: it needs browser control, and Hopkin's servers cannot observe client-side tag behavior on their own.

**Step 1 — is the extension there?** Run this in the page:

```js
typeof window.__hopkinTagInspector
```

**If `"object"` — one call does it.** The session is already recording (every capturable page starts one on navigation):

```js
await window.__hopkinTagInspector.getAudit()
```

Returns `events.total`, `vendors[]` (`vendor`, `eventCount`, `droppedCount`), `findings[]` (`severity`, `ruleId`), `coverage.missing` — the conversions expected and never fired, which is the highest-value field — and `redacted`. Also available: `status()`, `startRecording({ reset })`, `queryEvents({ vendor, eventName, limit })`. There is deliberately no `stopRecording`, and redaction cannot be disabled from the page.

If it returns `undefined`, **reload once and re-probe** — the API is absent until a reload after install. Still `undefined` means: not installed, this origin not granted, or a page Chrome refuses to let extensions script. Say which.

**If not installed:** https://chromewebstore.google.com/detail/hopkin-tag-inspector/ahgjbbnglgnladgimapeecjmhlhmacgg — free, no account. Send the user that link; retrying will not fix it.

**Fuller playbook** — safety rules, operational traps, and three canned probes for auditing *without* the extension (inventory, config diff, safe conversion replay): read the MCP resource `hopkin://tag-inspector/tracking-audit`, or if you cannot read MCP resources, fetch https://www.hopkin.ai/tag-inspector. Prefer it when you can reach it; the summary above is enough to start.

---

## Workflow Process

1. **Account selection**: if no account ID was given, call `microsoft_ads_list_accounts` and ask which account to analyze. Note its currency
2. **Date range**: default to the last 30 days if not specified
3. **Report selection**: match the question to the table in [Pick the Right Report](#pick-the-right-report)
4. **Report generation**: follow `nextCursor` when the answer needs every row
5. **Output**: tables with the currency, window and conversion definition stated, then insights and recommendations

## Best Practices

### Metric Interpretation Guidelines

- **CTR**: clicks ÷ impressions. Low CTR with high impressions points at ad relevance or broad matching
- **CPC and spend**: in account currency; compare only within one currency
- **Conversions**: say whether the figure is the bidding set (`conversions`) or every goal (`all_conversions`)
- **Quality Score**: 1 to 10; read the components to find the fix (ExpectedCtr: ad copy, AdRelevance: keyword-to-ad fit, LandingPageExperience: the page)
- **Small denominators**: do not present a rate from a handful of clicks as a trend

### Date Range Considerations

- **1 to 7 days**: recent changes and daily checks
- **7 to 30 days**: standard performance evaluation
- **30 to 90+ days**: seasonality and strategy
- Recent days can still gain conversions as they are attributed; say so when the window ends yesterday

### Report Formatting Preferences

- Lead with the answer, then the table
- Currency with its code or symbol, e.g. `USD 1,234.56`; rates as percentages with two decimals
- Sort by what the question implies, usually spend descending
- Include the account, date range and totals
- Say plainly when the account has no data for the window

### Error Handling Patterns

1. **Authentication error** (codes 105, 106, 109): run `microsoft_ads_check_auth_status`; if the connection is missing or expired, the user reconnects Microsoft Ads at https://app.hopkin.ai/?utm_source=claude-plugin&utm_medium=skill&utm_content=microsoft-ads
2. **Permission error on an agency account**: retry with the owning `customer_id`
3. **Rate limit** (code 117, HTTP 429): back off, then retry; do not loop tightly
4. **Input error** (HTTP 422): the message names the field to fix, such as an invalid column for the report type or a filter the report cannot honor. Fix it and retry
5. **Billing error** (HTTP 402): call `microsoft_ads_get_billing_status`
6. **Report timeout**: narrow the date range or `campaign_ids`, or use `Summary` aggregation

---

## Troubleshooting

For detailed troubleshooting guidance, see **references/troubleshooting.md**.

Common quick fixes:

- **"MCP server not found"**: verify the Hopkin MCP configuration and token
- **"Not authenticated"**: run `microsoft_ads_check_auth_status`; reconnect at https://app.hopkin.ai/?utm_source=claude-plugin&utm_medium=skill&utm_content=microsoft-ads
- **"Account not found" or permission denied**: confirm the account ID with `microsoft_ads_list_accounts`, and pass `customer_id` for agency-managed accounts
- **Conversions are 0 but the UI shows some**: compare against `include_all_conversions`; the goals may be excluded from the bidding set
- **"No data available"**: check the date range and whether campaigns ran in it

---

## Additional Resources

- **references/troubleshooting.md**: error solutions and debugging steps
- **references/workflows/campaign-performance.md**: campaign performance report workflow
- **references/workflows/keyword-analysis.md**: keyword, Quality Score and search term workflow
- **references/workflows/account-health-audit.md**: policy, extension, UET and URL tracking audit
- Hopkin dashboard: https://app.hopkin.ai/?utm_source=claude-plugin&utm_medium=skill&utm_content=microsoft-ads
- Microsoft Advertising: https://ads.microsoft.com

---

**Requires:** Hopkin Microsoft Ads MCP (https://app.hopkin.ai/?utm_source=claude-plugin&utm_medium=skill&utm_content=microsoft-ads)
