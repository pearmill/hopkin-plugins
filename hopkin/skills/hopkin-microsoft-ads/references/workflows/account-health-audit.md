# Account Health Audit

## Overview

Check the things that quietly break a Microsoft Advertising account: disapproved or limited ads, keywords and extensions; UET tags and conversion goals that stopped recording; and URL tracking that is missing or inconsistent. All of it is read live, never from cache.

---

## Step 1: Policy (Editorial) Status

```json
{
  "tool": "microsoft_ads_list_campaigns",
  "parameters": {
    "account_id": "123456789",
    "status": ["Active"],
    "include_policy_issues": true,
    "include_url_tracking": true,
    "reason": "Account health audit: disapprovals and URL tracking"
  }
}
```

- `include_policy_issues` attaches every ad and keyword in the returned campaigns that is **Disapproved** (not serving), **ActiveLimited** (approved in some markets only) or **Inactive** (under review), with Microsoft's reasons and appeal status
- Asking for `include_url_tracking` in the same call costs nothing extra: both share one scan
- The scan walks every ad group on the page live (about 10 to 30 seconds). If it reports itself truncated, narrow with `campaign_ids` or a smaller `limit` and say which campaigns were not checked
- Performance Max asset groups are not covered

For a single ad group, use `microsoft_ads_list_ads` or `microsoft_ads_list_keywords` with `include_policy_issues: true`.

---

## Step 2: Ad Extensions

```json
{
  "tool": "microsoft_ads_list_ad_extensions",
  "parameters": {
    "account_id": "123456789",
    "editorial_status": ["Disapproved", "ActiveLimited", "Inactive"],
    "reason": "Finding disapproved or limited ad extensions"
  }
}
```

- One row per attachment (approval is per attachment), with the level, campaign or ad group, reasons and whether it is serving
- `counts` covers everything scanned, whatever the filter
- If `scan.truncated` is true, `scan.truncatedReasons` says why; if `scan.campaignTypesNotScanned` is set, those types were not checked. Unchecked is not clean

---

## Step 3: Conversion Tracking (UET)

```json
{
  "tool": "microsoft_ads_get_uet_tag_health",
  "parameters": {
    "account_id": "123456789",
    "reason": "Checking UET tags and conversion goals are recording"
  }
}
```

- `summary.healthy` and `summary.issues` answer the question directly; each issue has a plain-language `problem`
- Tag status: **Active** (receiving events), **Unverified** (never received one, probably not installed), **Inactive** (stopped receiving events)
- Goal status: RecordingConversions, NoRecentConversions, TagUnverified, TagInactive, InactiveDueToTagUnavailable. Paused goals are counted but not listed as issues
- `excludeFromBidding: true` means the goal is not in the `conversions` column bidding optimizes toward
- Goals that read from no tag (offline, app installs, in-store) are in `otherConversionGoals`
- It reports status, not volume. For conversion counts per goal, use `goal_breakdown` from `microsoft_ads_get_account_summary` or `microsoft_ads_get_performance_report`

To confirm the tag fires on the site itself, run the Tag Inspector check described in the skill's Client-Side Tracking Audit section.

---

## Step 4: URL Tracking

From the Step 1 response:

- `urlTrackingScan.account`: the account-level tracking template, final URL suffix, and MSCLKID and UTM auto-tagging settings
- Each campaign's `urlTracking`: every ad group, ad and keyword that sets its own tracking template, custom parameters, final URL suffix or keyword final URL. Anything not listed inherits
- A `null` URL field means "inherits from the parent", never "untagged"

Look for: no account-level template or suffix and no auto-tagging (clicks arrive untagged), overrides that drop UTM parameters the account level sets, and inconsistent `utm_campaign` values.

`microsoft_ads_get_account_summary` also returns the account URL settings as `account_url_options`, when you need only those.

---

## Step 5: Report

Group findings by severity:

1. **Not serving or not measuring:** disapproved ads and keywords on active campaigns, Unverified or Inactive UET tags, bidding goals not recording
2. **Partly limited:** ActiveLimited items, Inactive (under review) items, disapproved extensions
3. **Hygiene:** URL tracking gaps and inconsistencies

For each, name the campaign and ad group, quote Microsoft's reason, and give the fix. State any scan bounds that were hit. Fixes happen in Microsoft Advertising; this MCP is read-only.
