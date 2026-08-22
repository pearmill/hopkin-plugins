---
name: hopkin-google-analytics
description: Analyze Google Analytics 4 (GA4) data using the Hopkin Google Analytics MCP. Includes account and property discovery, property setup health checks, flexible reporting with any dimensions and metrics, realtime reports for tag verification, and dimension/metric metadata lookup.
---

# Google Analytics (GA4) Skill

## Introduction

This skill enables Claude to analyze Google Analytics 4 data via the Hopkin Google Analytics MCP. Use this skill when you need to:

- Discover which GA4 accounts and properties a user has access to
- Audit a property's setup health (data streams, key events, Google Ads links, attribution, data retention)
- Run reports with any combination of dimensions and metrics over one or more date ranges
- Verify tags and key events fire in realtime after tracking changes
- Look up valid dimension/metric API names (including custom definitions) before building reports

The MCP is **read-only** — it wraps the GA4 Admin API and Data API for reporting and configuration inspection.

## Prerequisites

Before using this skill, verify that the Hopkin Google Analytics MCP is configured and the user is authenticated.

### Check for MCP Availability

To verify the Hopkin Google Analytics MCP is available:

1. Check for `ga4_` prefixed tools in your available tools (e.g., `ga4_list_account_summaries`, `ga4_run_report`)
2. If found, the Hopkin Google Analytics MCP is properly configured

### If Hopkin Google Analytics MCP Is Not Installed

If no `ga4_` prefixed tools are available:

1. **Inform the user** that the Hopkin Google Analytics MCP is required to use this skill
2. **Direct them to sign up** at https://app.hopkin.ai
3. **Provide setup instructions:**

> The Hopkin Google Analytics MCP is not configured. To use this skill:
>
> 1. Sign up at **https://app.hopkin.ai**
> 2. Add the hosted MCP to your Claude configuration:
>
> ```json
> {
>   "mcpServers": {
>     "hopkin-google-analytics": {
>       "type": "http",
>       "url": "https://ga4.mcp.hopkin.ai/mcp"
>     }
>   }
> }
> ```
>
> 3. Restart Claude after updating configuration

4. **Pause execution** until the user confirms MCP installation is complete
5. **Re-verify** MCP availability after user confirmation

### Authentication Flow

After confirming the MCP is available, authenticate the user's Google account:

1. **Just call the tool you need** — do not call `ga4_check_auth_status` proactively
2. **If a tool fails with an auth error:** call `ga4_check_auth_status` to diagnose, then direct the user to connect their Google account via https://app.hopkin.ai
3. **Insufficient scope:** GA4 requires the `analytics.readonly` Google scope. Users who connected Google **before** GA4 support was added must reconnect at https://app.hopkin.ai/settings to re-consent. Tools return a targeted reconnect message on 403 insufficient-scope errors.

### Required Information

Before generating reports, confirm you have:

- **Property ID** — The GA4 property to query (numeric, e.g. `123456789`, or full resource name `properties/123456789`). Use `ga4_list_account_summaries` to find available properties.
- **Date Range** — Time period for data. Dates are `YYYY-MM-DD` or relative (`30daysAgo`, `yesterday`, `today`).

## Available MCP Tools

For complete tool documentation with all parameters, see **references/mcp-tools-reference.md**.

All tools use the `ga4_` prefix.

### Health & Authentication
- `ga4_ping` — Health check; verify the MCP server is reachable
- `ga4_check_auth_status` — Check if user is authenticated; only call when another tool returns an auth error

### Discovery
- `ga4_list_account_summaries` — **Start here.** Every GA4 account and property visible to the connected Google account, with pagination and caching
- `ga4_get_property_details` — Setup-health snapshot for one property: property info, data streams (with enhanced measurement for web streams), key events, Google Ads links, attribution settings, data retention settings

### Reporting
- `ga4_run_report` — **Primary reporting tool.** Arbitrary dimensions × metrics over 1-4 date ranges, with optional dimension filter and ordering. Returns flattened rows plus metric totals
- `ga4_run_realtime_report` — Last-30-minutes report, mainly for verifying tags/key events after tracking changes
- `ga4_get_metadata` — Valid dimension/metric API names for a property (including custom definitions), with substring search

### Connections
- `ga4_list_connections` — List Google Analytics connections available to you (owned and org-shared)
- `ga4_set_default_connection` — Set the default connection for subsequent GA4 tool calls
- `ga4_share_connection` / `ga4_unshare_connection` — Share/unshare an owned connection with your organization
- `ga4_rename_connection` — Rename a connection
- `ga4_revoke_connection` — Revoke a connection (destructive)

### Feedback
- `ga4_developer_feedback` — Submit feature requests and workflow gap reports

## Core Capabilities

### Analysis Types

1. **Property Discovery** — Map out which GA4 accounts and properties the user can access
2. **Setup Health Audit** — Review data streams, key events, Google Ads links, attribution, and data retention for a property
3. **Custom Reports** — Any dimensions × metrics combination: traffic by channel, landing page revenue, conversion trends, geographic breakdowns, device splits
4. **Period Comparisons** — Pass 2-4 date ranges to `ga4_run_report` for period-over-period analysis in a single call
5. **Realtime Verification** — Confirm events and key events fire within the last 30 minutes after a tracking change

### Report Workflow Process

1. **Property Selection:** If no property specified, call `ga4_list_account_summaries` and ask the user which property to analyze. If they name a site/brand, match it against property display names.
2. **Metadata Lookup:** When unsure about dimension/metric API names, call `ga4_get_metadata` (use `search` to filter, e.g. `'channel'` or `'revenue'`) instead of guessing.
3. **Date Range:** Default to last 28 days (`{ start_date: '28daysAgo', end_date: 'yesterday' }`) if not specified. GA4 standard reports have a processing lag of up to 24-48 hours; exclude today for accurate numbers.
4. **Data Retrieval:** Use `ga4_run_report` with the appropriate dimensions, metrics, filter, and ordering.
5. **Output Formatting:** Present data in clear tables with insights and actionable recommendations.

### Common Report Recipes

- **Channel mix:** dimensions `[sessionDefaultChannelGroup]`, metrics `[sessions, totalUsers, keyEvents]`
- **Landing page performance:** dimensions `[landingPagePlusQueryString]`, metrics `[sessions, keyEvents, purchaseRevenue]`, order by sessions desc
- **Daily trend:** dimensions `[date]`, metrics `[sessions, totalUsers]`, order by dimension `date`
- **Paid traffic only:** add `dimension_filter: { field: 'sessionDefaultChannelGroup', values: ['Paid Search'] }`
- **Period-over-period:** pass two `date_ranges`; totals come back keyed per range in `metric_totals_by_range`
- **Geo breakdown:** dimensions `[country]` or `[city]`, metrics `[sessions, totalUsers, keyEvents]`
- **Device split:** dimensions `[deviceCategory]`, metrics `[sessions, keyEvents]`
- **Event audit:** dimensions `[eventName]`, metrics `[eventCount]`
- **Tag verification (realtime):** `ga4_run_realtime_report` with dimensions `[eventName]`, metrics `[eventCount]`

### Client-Side Tracking Audit (Browser)

When the numbers point at a tracking problem rather than a media problem, audit the site itself. The **Hopkin Tag Inspector** Chrome extension reports every analytics and ad tag that fired, per-vendor event counts, findings, and the conversions that were expected but never fired. For GA4 this catches the two failures a report structurally cannot show: a key event configured under a name the site never emits (an event name containing a space is rejected outright), and events arriving server-side with no campaign parameters, which GA4 then stamps as Direct.

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

### Write Operations (Unsupported — Developer Feedback)

The Hopkin Google Analytics MCP is **read-only**. When a user requests write operations (create key events, edit data streams, change retention settings, link Google Ads, etc.):

1. **Inform the user** that write operations are not yet available via Hopkin
2. **Submit a feature request** by calling `ga4_developer_feedback` with:
   - `feedback_type: "workflow_gap"`
   - `title`: Description of the write operation requested
   - `description`: What the user was trying to do
   - `current_workaround`: How you worked around the limitation (if applicable)
   - `priority`: Based on user's urgency
3. **Provide guidance** on performing the action manually in the GA4 admin UI

### Proactive Efficiency Feedback

Whenever you complete a task and believe there should have been a faster or more efficient way to get the answer — for example, if you had to make multiple tool calls that could have been a single call, or if a dedicated tool for the workflow would have saved time — call `ga4_developer_feedback` with:
- `feedback_type: "new_tool"` or `"improvement"`
- `title`: Brief description of the missing capability
- `description`: Explain what you were trying to accomplish, the steps you had to take, and how a new or improved tool could have made it faster
- `current_workaround`: The steps you took to work around the limitation
- `priority`: `"medium"`

### User Feedback to Skill Developers

Users can provide feedback about this skill directly through the Hopkin Google Analytics MCP. If a user wants to suggest improvements, report issues, or request new capabilities, call `ga4_developer_feedback` on their behalf with the appropriate `feedback_type` (`new_tool`, `improvement`, `bug`, or `workflow_gap`) and include their feedback in the `description`.

## Best Practices

### Data Freshness

- **GA4 standard reports lag by up to 24-48 hours.** Exclude today (and treat yesterday as potentially incomplete) for accurate trend analysis.
- Use `ga4_run_realtime_report` when the user needs to verify something happening right now — it covers only the last 30 minutes.
- `ga4_list_account_summaries` results are cached; pass `refresh: true` only when the user expects a newly-added property to appear.

### Report Construction

- **Validate API names first.** Dimension and metric names are case-sensitive API names (`sessionDefaultChannelGroup`, not "Default channel group"). Use `ga4_get_metadata` when uncertain — it also surfaces custom dimensions/metrics.
- **Limits:** up to 9 dimensions, 1-10 metrics, 1-4 date ranges per report. Default row limit 100, max 10,000; use `offset` for pagination.
- **Not all dimension/metric pairs are compatible.** If the API rejects a combination, simplify the request or split into multiple reports.
- **Key events vs conversions:** GA4 renamed "conversions" to "key events" — the metric is `keyEvents`. Interpret user requests for "conversions" accordingly.

### Interpreting Metrics

- **sessions** vs **totalUsers** vs **activeUsers** — sessions count visits; totalUsers counts distinct users; activeUsers counts engaged distinct users (GA4's headline user metric)
- **keyEvents** — count of key event (conversion) occurrences
- **purchaseRevenue** / **totalRevenue** — ecommerce revenue; check the property's currency via `ga4_get_property_details`
- **engagementRate** / **bounceRate** — complementary rates (bounceRate = 1 − engagementRate)

### Report Formatting Preferences

- Use tables for multi-row data with consistent columns
- Use thousands separators for large counts (e.g., 12,345)
- Round rates to 1-2 decimals and show as percentages
- Include property, date range, and any filters in report metadata
- Sort by the user's primary metric descending unless they ask otherwise
- For multi-range reports, show each period side by side with deltas

### Error Handling Patterns

When errors occur:

1. **Auth errors** — Run `ga4_check_auth_status`; if not authenticated, direct the user to connect their Google account at https://app.hopkin.ai
2. **403 insufficient scope** — The Google connection predates GA4 support; user must reconnect at https://app.hopkin.ai/settings to grant `analytics.readonly`
3. **Invalid dimension/metric** — Verify API names with `ga4_get_metadata`
4. **Property not found** — Verify the property ID with `ga4_list_account_summaries` (pass `refresh: true` if recently added)
5. **Consult troubleshooting guide** — See references/troubleshooting.md

---

## Troubleshooting

For detailed troubleshooting guidance, see **references/troubleshooting.md**.

Common quick fixes:

- **"MCP server not found"** — Verify Hopkin MCP configuration
- **"Not authenticated"** — Run `ga4_check_auth_status`; direct user to connect their account at https://app.hopkin.ai
- **"Insufficient scope" / 403** — Reconnect Google at https://app.hopkin.ai/settings to grant Analytics access
- **"Property not found"** — Verify property ID with `ga4_list_account_summaries`
- **"Invalid dimension or metric"** — Look up valid API names with `ga4_get_metadata`
- **"No data for today"** — GA4 standard reports lag up to 24-48h; use the realtime report for current activity

---

## Additional Resources

For more detailed information:

- **references/mcp-tools-reference.md** — Complete Hopkin MCP tool documentation, parameters, and usage examples
- **references/troubleshooting.md** — Comprehensive error solutions and debugging steps

---

**Requires:** Hopkin Google Analytics MCP (https://app.hopkin.ai)
