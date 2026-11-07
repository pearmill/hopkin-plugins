# Microsoft Ads Skill - Troubleshooting Guide

Solutions to common issues when using the Microsoft Ads skill with the Hopkin Microsoft Ads MCP.

## Table of Contents

1. [MCP Server Issues](#mcp-server-issues)
2. [Authentication Problems](#authentication-problems)
3. [Permission Errors](#permission-errors)
4. [Report Issues](#report-issues)
5. [Conversion Discrepancies](#conversion-discrepancies)
6. [Incomplete Scans](#incomplete-scans)
7. [API Error Types](#api-error-types)

---

## MCP Server Issues

### MCP Server Not Found

**Symptoms:**
- No `microsoft_ads_` prefixed tools available

**Solutions:**

#### Solution 1: Sign Up and Configure Hopkin

1. Sign up at **https://app.hopkin.ai/?utm_source=claude-plugin&utm_medium=skill&utm_content=microsoft-ads**
2. Add the hosted MCP to your Claude configuration:

```json
{
  "mcpServers": {
    "hopkin-microsoft-ads": {
      "type": "url",
      "url": "https://microsoft.mcp.hopkin.ai/mcp",
      "headers": {
        "Authorization": "Bearer YOUR_HOPKIN_TOKEN"
      }
    }
  }
}
```

3. Restart Claude after updating configuration

#### Solution 2: Verify Configuration

If the MCP is configured but tools aren't appearing:
1. Check that the Hopkin token is correct and not expired
2. Verify the MCP URL is exactly: `https://microsoft.mcp.hopkin.ai/mcp`
3. Ensure the Authorization header format is: `Bearer YOUR_TOKEN` (with a space after Bearer)
4. If you use the Hopkin plugin, update it: Microsoft Ads joined the plugin in version 1.27.0

#### Solution 3: Restart Claude

After installing the MCP or updating the plugin, quit and restart Claude, then check that `microsoft_ads_` tools appear.

---

## Authentication Problems

### No Microsoft Ads Connection

**Symptoms:** a tool says no Microsoft Ads connection is available, or `microsoft_ads_check_auth_status` reports none.

**Solution:** the user connects Microsoft Advertising at https://app.hopkin.ai/?utm_source=claude-plugin&utm_medium=skill&utm_content=microsoft-ads (Connections, then Microsoft Ads) and completes Microsoft's OAuth sign-in. Microsoft accounts and Google-identity logins to Microsoft Advertising both work.

### Token Expired or Rejected

**Symptoms:** fault codes **105** (InvalidCredentials), **106** (UserIsNotAuthorized) or **109** (AuthenticationTokenExpired), or an HTTP 401.

**Solution:**
1. Run `microsoft_ads_check_auth_status` to confirm
2. If the connection is expired or revoked, reconnect Microsoft Ads at https://app.hopkin.ai/?utm_source=claude-plugin&utm_medium=skill&utm_content=microsoft-ads
3. Retry the original call

### Developer Token Not Configured

`microsoft_ads_check_auth_status` also reports whether the server's Microsoft Ads developer token is configured. If it is not, no data tool can work and the user cannot fix it: report it through `microsoft_ads_developer_feedback` with `feedback_type: "bug"` and tell the user it is a Hopkin-side issue.

---

## Permission Errors

### Account Not Accessible

**Symptoms:** permission denied or "account not found" for an account the user can see in Microsoft Advertising.

**Solutions:**
1. Confirm the ID with `microsoft_ads_list_accounts`. Use the numeric **AccountId**, not the account number shown in the UI (for example `F123ABCD`)
2. For an agency-managed account, pass the owning `customer_id`. `microsoft_ads_list_customers` lists the user's customers; `microsoft_ads_list_accounts` with `customer_id` lists that customer's accounts
3. If the user has several Microsoft Ads connections, check `microsoft_ads_list_connections` and pass the right `connection_id`

### Connection Not Usable

**Symptoms:** HTTP 403 naming a `connection_id`.

The connection was revoked, or the user is no longer a member of the organization it was shared with. Call `microsoft_ads_list_connections` and use one of the listed IDs, or omit `connection_id` to use the default.

---

## Report Issues

### Reports Are Slow

Microsoft builds reports in the background: 5 to 30 seconds per call is normal. Speed them up with:
- `aggregation: "Summary"` instead of `Daily`
- A shorter date range
- `campaign_ids` to narrow the scope
- `breakdown_by_goal: false` when the per-goal split is not needed (it runs a second report)

### Report Timed Out

Narrow the date range or the campaigns and retry. For search terms on a large account, split the window into smaller ranges.

### Fewer Rows Than Expected

- Check for `nextCursor` in the response (`pagination.nextCursor` on `microsoft_ads_get_insights`) and follow it with identical parameters
- `count` is the total across all pages; compare it with the rows you have
- A `campaign_type` filter is applied to downloaded rows, so `count` covers matching campaigns only

### "Cursor Rejected"

A cursor is bound to the exact parameters of the call that produced it. Reuse it with the same parameters (only `limit` may change). Report cursors expire after about 24 hours; start again without a cursor.

### "Invalid Column" From get_insights

Columns are validated per `report_type`, and names differ between report types. The error lists the valid values. Pick from that list, or use the dedicated report tool for the question.

### Campaign Type "Video" Rejected

Microsoft has no `Video` campaign type in these reports. Use `Search`, `Shopping`, `PerformanceMax` or `Audience`.

### Geographic Rows Look Random

Microsoft returns `Location` rows in location ID order. Keep `order_by: "spend"` (the default on `microsoft_ads_get_audience_report`) so the top locations come first.

### Cannot Combine Breakdowns

`microsoft_ads_get_audience_report` serves demographics (`AgeGroup`, `Gender`), geo (`Location`) and campaign breakdowns (`Device`, `DayOfWeek`, `HourOfDay`) from three different Microsoft reports. Use one group per call, and never `DayOfWeek` with `HourOfDay`.

---

## Conversion Discrepancies

### Conversions Lower Than the Microsoft Advertising UI

The tools' `conversions` counts only goals marked "Include in Conversions". The UI may be showing **All conversions**.
- Pass `include_all_conversions: true` and compare `all_conversions`
- Check `goal_breakdown`, and `excludeFromBidding` on each goal in `microsoft_ads_get_uet_tag_health`

### Goal Breakdown Does Not Match the Rows

`goal_breakdown` is reported at a coarser grain than the rows: account or campaign for most reports, ad group for the keyword report. It is not a per-keyword or per-segment split. It also appears on the first page only.

### Conversions Dropped to Zero

Run `microsoft_ads_get_uet_tag_health`. A tag that is Inactive or a goal that shows NoRecentConversions or TagInactive explains it. Then check the site with the Tag Inspector (see the skill's Client-Side Tracking Audit).

### Recent Days Look Low

Conversions can still be attributed to recent clicks. Compare complete periods, and note when a window ends yesterday.

---

## Incomplete Scans

Policy (`include_policy_issues`), URL tracking (`include_url_tracking`) and extension scans walk ad groups live and stop at a time, size or throttling bound.

- `truncated: true` and `truncatedReasons` say a scan stopped early
- `scan.campaignTypesNotScanned` on `microsoft_ads_list_ad_extensions` names campaign types Microsoft would not list

**Unchecked is not clean.** Report what was not checked, then narrow with `campaign_ids`, a smaller `limit`, or `association_levels`, and run again.

Performance Max asset groups are never covered by these scans.

### Change History Is Empty

`microsoft_ads_get_activities` is complete only from `coverage.complete_from`. An empty result before that date means "not recorded", not "no changes". Changes take about an hour to appear. Audience associations, Performance Max asset groups and conversion goals are not in Microsoft's change log at all.

---

## API Error Types

| Code or status | Meaning | Action |
|---|---|---|
| 105, 106, 109 / HTTP 401 | Authentication failed or expired | `microsoft_ads_check_auth_status`, then reconnect |
| 117 / HTTP 429 | Rate limited (CallRateExceeded) | Wait, then retry; avoid tight loops |
| HTTP 402 | Billing required | `microsoft_ads_get_billing_status` |
| HTTP 403 | No access to the account or connection | Check `customer_id` and `connection_id` |
| HTTP 404 | Entity not found | Re-list the parent to get valid IDs |
| HTTP 422 | Invalid input | Read the message; it names the field to fix |

If a tool returns data that looks wrong, call `microsoft_ads_developer_feedback` with `feedback_type: "bug"`, the `tool_name` and what you expected.

---

## Quick Checklist

- [ ] Hopkin MCP is configured with a valid token
- [ ] Microsoft Ads is connected at app.hopkin.ai
- [ ] Numeric `account_id` from `microsoft_ads_list_accounts`
- [ ] `customer_id` passed for agency-managed accounts
- [ ] Date range valid (`date_preset` or `date_range`, not both)
- [ ] Every page followed when the answer needs every row
- [ ] Conversion definition stated (bidding set or all goals)
