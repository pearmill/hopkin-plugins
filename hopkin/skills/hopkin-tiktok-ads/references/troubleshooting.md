# TikTok Ads Skill — Troubleshooting Guide

This guide provides solutions to common issues encountered when using the TikTok Ads skill with the Hopkin TikTok Ads MCP.

## Table of Contents

1. [MCP Server Issues](#mcp-server-issues)
2. [Authentication Problems](#authentication-problems)
3. [Permission Errors](#permission-errors)
4. [Data Availability Issues](#data-availability-issues)
5. [API Error Codes](#api-error-codes)
6. [Performance & Rate Limiting](#performance--rate-limiting)
7. [Data Quality Issues](#data-quality-issues)
8. [TikTok-Specific Conventions](#tiktok-specific-conventions)

---

## MCP Server Issues

### MCP Server Not Found

**Symptoms:**
- No `tiktok_ads_` prefixed tools available
- Cannot execute TikTok Ads operations

**Diagnosis:**
1. Check for `tiktok_ads_` prefixed tools in your available tools
2. If none are found, the Hopkin TikTok Ads MCP is not configured

**Solutions:**

#### Solution 1: Sign Up and Configure Hopkin

1. Sign up at **https://app.hopkin.ai**
2. Add the hosted MCP to your Claude configuration:

```json
{
  "mcpServers": {
    "hopkin-tiktok-ads": {
      "type": "url",
      "url": "https://tiktok.mcp.hopkin.ai/mcp",
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
2. Verify the MCP URL is exactly: `https://tiktok.mcp.hopkin.ai/mcp`
3. Ensure the Authorization header format is: `Bearer YOUR_TOKEN` (with a space after Bearer)

#### Solution 3: Restart Claude

After installing or configuring the MCP server:
1. Completely quit Claude
2. Restart the application
3. Verify `tiktok_ads_` tools appear in available tools

---

## Authentication Problems

### Not Authenticated with TikTok Ads

**Symptoms:**
- `tiktok_ads_check_auth_status` returns `authenticated: false`
- Tools return authentication errors
- Cannot access advertiser data

**Solutions:**

#### Solution 1: Run the Authentication Flow

1. Call `tiktok_ads_check_auth_status` to verify current status
2. If not authenticated, use `tiktok_ads_get_login_url` to get the OAuth URL
3. Alternatively, direct the user to connect their TikTok Ads account via https://app.hopkin.ai
4. After the user completes the OAuth flow, re-verify with `tiktok_ads_check_auth_status`

#### Solution 2: Token Refresh Issues

TikTok provider tokens may expire, but Hopkin automatically refreshes them. This process is transparent to the user.

**If auto-refresh fails:**
- `tiktok_ads_check_auth_status` will show `authenticated: false`
- Direct the user to https://app.hopkin.ai to reconnect their TikTok account
- After reconnection, re-verify with `tiktok_ads_check_auth_status`

---

## Permission Errors

### Insufficient TikTok Permissions

**Symptoms:**
- Can authenticate but cannot access advertiser data
- `tiktok_ads_check_auth_status` shows missing permissions

**Solutions:**

#### Solution 1: Re-authenticate with Correct Scopes

1. Direct the user to https://app.hopkin.ai
2. Ask them to disconnect and reconnect their TikTok account
3. Ensure they grant all requested permissions during the OAuth flow

#### Solution 2: Check Advertiser Access in TikTok Ads Manager

1. Log into TikTok Ads at https://ads.tiktok.com
2. Navigate to account settings
3. Verify the user has been granted access to the target advertiser account

### Advertiser Not Accessible

**Symptoms:**
- Error: "Advertiser not found" or "Access denied"
- Advertiser ID is correct but tools cannot access it

**Solutions:**

1. Use `tiktok_ads_list_advertisers` to confirm which advertisers the authenticated user can access
2. Verify the user has been granted access to the target advertiser in TikTok Ads Manager
3. Confirm the `advertiser_id` is correct — TikTok advertiser IDs are numeric strings (e.g., `7012345678901234567`)

---

## Data Availability Issues

### No Data Returned

**Symptoms:**
- Query succeeds but returns empty results
- No error message

**Common Causes:**
1. Date range has no campaign activity
2. Status filter excludes the target entities
3. Campaign or ad group IDs in filter don't match what's in the advertiser account

**Solutions:**

#### Solution 1: Verify Date Range

1. Check that campaigns were active during the requested date range
2. Try a broader date range (e.g., `LAST_90_DAYS` instead of `LAST_7_DAYS`)
3. Use either `date_preset` (e.g., `LAST_30_DAYS`) or explicit `start_date`/`end_date` in `YYYY-MM-DD` format
4. For `get_insights`, you can use `lifetime: true` to get all-time data

#### Solution 2: Check Status Filters

1. TikTok uses `ENABLE`, `DISABLE`, and `DELETE` as status values (not ACTIVE/PAUSED/ARCHIVED)
2. Default status filters may exclude disabled entities
3. For analytics tools, data is returned regardless of current status as long as there was activity in the date range

#### Solution 3: Verify Entity IDs

1. Use `tiktok_ads_list_campaigns` or `tiktok_ads_list_ad_groups` to get the correct IDs
2. TikTok IDs are numeric strings — ensure no extra characters or whitespace

### Video Metrics Not Showing

**Symptoms:**
- User requests video/creative performance data
- Standard performance report doesn't include video-specific metrics

**Cause:** Video-specific metrics (play duration, completion rates) may not appear in the standard `get_performance_report`. Use the dedicated creative report tool.

**Solution:** Use `tiktok_ads_get_creative_report` for video-specific metrics including average play duration, completion rates, and engagement by creative. You can filter by `campaign_id` or `adgroup_id`.

### No Demographic Data in Performance Report

**Symptoms:**
- User requests audience demographics (age, gender, country)
- Standard performance report doesn't include demographic breakdowns

**Solution:** Use `tiktok_ads_get_insights` with `report_type: "AUDIENCE"` and include demographic dimensions such as `age`, `gender`, or `country_code` in the `dimensions` array. The standard `get_performance_report` does not support demographic breakdowns.

---

## API Error Codes

### Common TikTok Ads API Errors

#### Unauthorized / 401
**Cause:** TikTok token expired or invalid.

**Solutions:**
- Call `tiktok_ads_check_auth_status` to confirm token status
- If not authenticated, use `tiktok_ads_get_login_url` or direct user to https://app.hopkin.ai to reconnect

#### Forbidden / 403
**Cause:** Insufficient permissions or attempting a write operation.

**Solutions:**
- Verify the user has access to the target advertiser account
- Re-authenticate via https://app.hopkin.ai
- Confirm this is a read operation (MCP is read-only)

#### Too Many Requests / 429
**Cause:** Rate limiting — TikTok API enforces request rate limits.

**Solutions:**
- Wait before retrying (use exponential backoff)
- Reduce request frequency
- Use broader queries instead of many narrow ones

#### Service Unavailable / 503
**Cause:** TikTok API is temporarily unavailable or overloaded.

**Solutions:**
- Wait 30-60 seconds and retry
- TikTok's API can be intermittently slow; patience is key

---

## Performance & Rate Limiting

### Rate Limits

TikTok enforces API rate limits per advertiser account. Exceeding these limits results in 429 errors.

**Best Practices:**
1. Plan your queries carefully — minimize the number of API calls needed
2. Use broad queries with filters rather than many narrow queries
3. Avoid running multiple analytics calls in rapid succession
4. If you hit a 429 error, wait before retrying with exponential backoff
5. Use `date_preset` parameters when possible to simplify requests

### Slow Response Times

**Solutions:**

1. Use specific date ranges rather than very long periods
2. Filter to specific campaigns or ad groups with `campaign_id` or `adgroup_id` parameters
3. Use `page_size` to limit result set size
4. For `get_insights`, limit the number of `dimensions` to only what is needed

---

## Data Quality Issues

### Discrepancies Between TikTok Ads Manager and API

**Common Causes & Solutions:**

#### Cause 1: Data Processing Delay
TikTok typically takes time for full data processing. Recent data (especially today and yesterday) may be incomplete. Allow sufficient time for data to finalize.

#### Cause 2: Time Zone Differences
TikTok Ads Manager may report in the advertiser's configured time zone. API data may use a different time zone baseline. When comparing exact day-level numbers, account for time zone offset.

#### Cause 3: Attribution Window Differences
TikTok's attribution model may differ between Ads Manager views and API responses. Verify attribution settings when comparing conversion data.

#### Cause 4: Metric Definitions
Some metrics may be calculated differently between the UI and API. For example, video view thresholds (2-second vs. 6-second views) may vary by report type.

---

## TikTok-Specific Conventions

### Advertiser ID Format

TikTok uses `advertiser_id` as the primary account identifier (not `account_id`). Advertiser IDs are **numeric strings** (e.g., `7012345678901234567`). Every tool that operates on account data requires `advertiser_id`.

### Ad Group Naming

TikTok uses `adgroup_id` — with **no underscore** between "ad" and "group". This differs from some other platforms that use `ad_group_id`. The same convention applies to `adgroup_ids` for array parameters.

### Status Values

TikTok uses these status values for campaigns, ad groups, and ads:
- `ENABLE` — Entity is active and running
- `DISABLE` — Entity is paused/disabled
- `DELETE` — Entity has been deleted

These differ from other platforms that may use `ACTIVE`, `PAUSED`, or `ARCHIVED`.

### Insights Data Levels

The `get_insights` tool requires a `data_level` parameter with TikTok-specific values:
- `AUCTION_CAMPAIGN` — Campaign-level data
- `AUCTION_ADGROUP` — Ad group-level data
- `AUCTION_AD` — Ad-level data

### Report Types

The `get_insights` tool supports two report types:
- `BASIC` (default) — Standard performance metrics
- `AUDIENCE` — Demographic breakdowns (age, gender, country, language, platform)

### No Preferences or Chart Tools

Unlike some other Hopkin MCP integrations, the TikTok Ads MCP does not include:
- Preference storage tools (no `store_preference`, `get_preferences`, `delete_preference`)
- Chart rendering tools (no `render_chart`)

Use `tiktok_ads_preview_ads` for visual ad previews.

---

## Debugging Checklist

When encountering issues, work through this checklist:

- [ ] **MCP Connection**
  - [ ] Hopkin MCP is configured with valid token
  - [ ] `tiktok_ads_` tools appear in available tools
  - [ ] Claude has been restarted after config changes

- [ ] **Authentication**
  - [ ] `tiktok_ads_check_auth_status` returns `authenticated: true`
  - [ ] TikTok token is valid (auto-refreshed by Hopkin)
  - [ ] User has completed OAuth flow via https://app.hopkin.ai

- [ ] **Permissions**
  - [ ] User has access to target advertiser account
  - [ ] User role in TikTok Ads allows read access

- [ ] **Request Parameters**
  - [ ] All required parameters are provided
  - [ ] `advertiser_id` is a numeric string (e.g., `7012345678901234567`)
  - [ ] `adgroup_id` has no underscore (not `ad_group_id`)
  - [ ] Status values use `ENABLE`/`DISABLE`/`DELETE` (not ACTIVE/PAUSED/ARCHIVED)
  - [ ] Date ranges use `YYYY-MM-DD` format or valid `date_preset` values
  - [ ] `data_level` uses `AUCTION_CAMPAIGN`/`AUCTION_ADGROUP`/`AUCTION_AD`

- [ ] **Rate Limiting**
  - [ ] Not exceeding TikTok API rate limits
  - [ ] Using exponential backoff on 429 errors
  - [ ] Using broad queries to minimize call count

- [ ] **Data Availability**
  - [ ] Campaign/ad group was active during requested date range
  - [ ] Status filter is not excluding target entities
  - [ ] Using `get_creative_report` for video-specific metrics
  - [ ] Using `get_insights` with `report_type: "AUDIENCE"` for demographic data

---

## Common Patterns Summary

**"MCP server not found"**
-> Check: Hopkin MCP configuration and token, restart Claude

**"Not authenticated"**
-> Run: `tiktok_ads_check_auth_status` -> Use `tiktok_ads_get_login_url` or direct user to https://app.hopkin.ai

**"Advertiser not found"**
-> Check: `advertiser_id` is a numeric string, user has advertiser access

**"No data returned"**
-> Check: Date range (use `date_preset` or `start_date`/`end_date`), entity status, campaign activity during period

**"No video metrics"**
-> Use: `tiktok_ads_get_creative_report` for video-specific metrics instead of `get_performance_report`

**"No demographic data"**
-> Use: `tiktok_ads_get_insights` with `report_type: "AUDIENCE"` and demographic `dimensions`

**"Status filter not working"**
-> Check: TikTok uses `ENABLE`/`DISABLE`/`DELETE` (not ACTIVE/PAUSED/ARCHIVED)

**"adgroup_id not recognized"**
-> Check: TikTok uses `adgroup_id` (no underscore) — not `ad_group_id`

**"Rate limit exceeded"**
-> Check: Request frequency, wait and retry with exponential backoff, use broader queries

---

**Document Version:** 1.0
**Last Updated:** 2026-03-22
**Service:** Hopkin TikTok Ads MCP (https://app.hopkin.ai)
