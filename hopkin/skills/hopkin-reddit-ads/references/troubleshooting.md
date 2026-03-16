# Reddit Ads Skill — Troubleshooting Guide

This guide provides solutions to common issues encountered when using the Reddit Ads skill with the Hopkin Reddit Ads MCP.

## Table of Contents

1. [MCP Server Issues](#mcp-server-issues)
2. [Authentication Problems](#authentication-problems)
3. [Permission Errors](#permission-errors)
4. [Data Availability Issues](#data-availability-issues)
5. [API Error Codes](#api-error-codes)
6. [Performance & Rate Limiting](#performance--rate-limiting)
7. [Data Quality Issues](#data-quality-issues)

---

## MCP Server Issues

### MCP Server Not Found

**Symptoms:**
- No `reddit_ads_` prefixed tools available
- Cannot execute Reddit Ads operations

**Diagnosis:**
1. Check for `reddit_ads_` prefixed tools in your available tools
2. If none are found, the Hopkin Reddit Ads MCP is not configured

**Solutions:**

#### Solution 1: Sign Up and Configure Hopkin

1. Sign up at **https://app.hopkin.ai**
2. Add the hosted MCP to your Claude configuration:

```json
{
  "mcpServers": {
    "hopkin-reddit-ads": {
      "type": "url",
      "url": "https://reddit.mcp.hopkin.ai/mcp",
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
2. Verify the MCP URL is exactly: `https://reddit.mcp.hopkin.ai/mcp`
3. Ensure the Authorization header format is: `Bearer YOUR_TOKEN` (with a space after Bearer)

#### Solution 3: Restart Claude

After installing or configuring the MCP server:
1. Completely quit Claude
2. Restart the application
3. Verify `reddit_ads_` tools appear in available tools

---

## Authentication Problems

### Not Authenticated with Reddit Ads

**Symptoms:**
- `reddit_ads_check_auth_status` returns `authenticated: false`
- Tools return authentication errors
- Cannot access ad account data

**Solutions:**

#### Solution 1: Run the Authentication Flow

1. Call `reddit_ads_check_auth_status` to verify current status
2. If not authenticated, direct the user to connect their Reddit Ads account via https://app.hopkin.ai
3. After the user completes the OAuth flow, re-verify with `reddit_ads_check_auth_status`

#### Solution 2: Reddit Token Auto-Refresh

Reddit provider tokens expire after **1 hour**, but Hopkin automatically refreshes them. This process is transparent to the user.

**If auto-refresh fails:**
- `reddit_ads_check_auth_status` will show `authenticated: false`
- Direct the user to https://app.hopkin.ai to reconnect their Reddit account
- After reconnection, re-verify with `reddit_ads_check_auth_status`

---

## Permission Errors

### Insufficient Reddit Permissions

**Symptoms:**
- Can authenticate but cannot access ad account data
- `reddit_ads_check_auth_status` shows missing permissions

**Solutions:**

#### Solution 1: Re-authenticate with Correct Scopes

1. Direct the user to https://app.hopkin.ai
2. Ask them to disconnect and reconnect their Reddit account
3. Ensure they grant all requested permissions during the OAuth flow

#### Solution 2: Check Account Access in Reddit Ads Manager

1. Log into Reddit Ads at https://ads.reddit.com
2. Navigate to account settings
3. Verify the user has been granted access to the target ad account

### Account Not Accessible

**Symptoms:**
- Error: "Account not found" or "Access denied"
- Account ID is correct but tools cannot access it

**Solutions:**

1. Use `reddit_ads_list_ad_accounts` to confirm which accounts the authenticated user can access
2. Verify the user has been granted access to the target account in Reddit Ads Manager
3. Confirm the account ID is correct (plain string, no special prefix or format)

---

## Data Availability Issues

### No Data Returned

**Symptoms:**
- Query succeeds but returns empty results
- No error message

**Common Causes:**
1. Date range has no campaign activity
2. Status filter excludes the target entities
3. Campaign or ad group IDs in filter don't match what's in the account

**Solutions:**

#### Solution 1: Verify Date Range

1. Check that campaigns were active during the requested date range
2. Try a broader date range (e.g., 90 days instead of 7 days)
3. Reddit uses `date_start` and `date_end` in `YYYY-MM-DD` format — there is no `date_preset` parameter

#### Solution 2: Check Status Filters

1. Default status filters may exclude paused or archived entities
2. Add additional statuses to the filter if older data is needed
3. For analytics tools, data is returned regardless of current status as long as there was activity in the date range

#### Solution 3: Verify Entity IDs

1. Use `reddit_ads_list_campaigns` or `reddit_ads_list_ad_groups` to get the correct IDs
2. Reddit account IDs are plain strings — no URN format or special prefix

### No Demographic Breakdowns Available

**Symptoms:**
- User requests audience demographics (age, gender, etc.)
- No demographic pivot or breakdown is available

**Cause:** Reddit Ads does not support MEMBER_* demographic breakdowns like LinkedIn does. Reddit does not expose audience demographic data through its advertising API.

**Solution:** Use `breakdown: ["community"]` to analyze performance by subreddit instead. This is Reddit's primary audience segmentation dimension. For targeting analysis, use `reddit_ads_list_ad_groups` to review targeting configuration.

### Budget Values Look Wrong

**Symptoms:**
- Budget values are extremely large numbers
- Spend amounts don't match expected values

**Cause:** Reddit Ads API returns budget values in **micro units**. Divide by 1,000,000 to get the actual currency amount.

**Example:** A budget value of `50000000` = $50.00

---

## API Error Codes

### Common Reddit Ads API Errors

#### Service Unavailable / 503
**Cause:** Reddit API is temporarily unavailable or overloaded.

**Solutions:**
- Wait 30-60 seconds and retry
- Reddit's API can be intermittently slow; patience is key

#### Too Many Requests / 429
**Cause:** Rate limiting — Reddit enforces approximately **1 request per second**.

**Solutions:**
- Wait before retrying (at least 1-2 seconds between requests)
- Reduce request frequency — this is very important for Reddit
- Use broader queries instead of many narrow ones

#### Unauthorized / 401
**Cause:** Reddit token expired or invalid.

**Solutions:**
- Call `reddit_ads_check_auth_status` to confirm token status
- Hopkin auto-refreshes Reddit tokens (1-hour expiry), but if refresh fails, direct user to https://app.hopkin.ai to reconnect

#### Forbidden / 403
**Cause:** Insufficient permissions or attempting a write operation.

**Solutions:**
- Verify the user has access to the target ad account
- Re-authenticate via https://app.hopkin.ai
- Confirm this is a read operation (MCP is read-only)

---

## Performance & Rate Limiting

### Rate Limit: ~1 Request Per Second

Reddit enforces a rate limit of approximately **1 request per second**. This is stricter than most other ad platforms.

**Best Practices:**
1. Plan your queries carefully — minimize the number of API calls needed
2. Use broad queries with filters rather than many narrow queries
3. Avoid running multiple analytics calls in rapid succession
4. If you hit a 429 error, wait at least 2 seconds before retrying

### Slow Response Times

**Solutions:**

1. Use specific date ranges rather than very long periods
2. Filter to specific campaigns or ad groups with `campaign_ids` or `ad_group_ids` parameters
3. Reduce result set size where possible
4. Avoid simultaneous analytics calls — run one at a time due to rate limits

---

## Data Quality Issues

### Discrepancies Between Reddit Ads Manager and API

**Common Causes & Solutions:**

#### Cause 1: Data Processing Delay
Reddit typically takes **24-48 hours** for full data processing. Recent data (especially today and yesterday) may be incomplete. Check with Reddit's documentation for the most current processing timeline.

#### Cause 2: Time Zone Differences
Reddit Ads Manager may report in the account's time zone. API data may use UTC. When comparing exact day-level numbers, account for time zone offset.

#### Cause 3: Budget Micro Units
Reddit API returns budget values in micro units (divide by 1,000,000). If your spend numbers look 1,000,000x too large, apply this conversion.

#### Cause 4: Attribution Window Differences
Reddit's attribution model may differ from what's displayed in Ads Manager. Verify attribution settings when comparing conversion data.

---

## Debugging Checklist

When encountering issues, work through this checklist:

- [ ] **MCP Connection**
  - [ ] Hopkin MCP is configured with valid token
  - [ ] `reddit_ads_` tools appear in available tools
  - [ ] Claude has been restarted after config changes

- [ ] **Authentication**
  - [ ] `reddit_ads_check_auth_status` returns `authenticated: true`
  - [ ] Reddit token is valid (auto-refreshed by Hopkin, 1-hour expiry)
  - [ ] User has completed OAuth flow via https://app.hopkin.ai

- [ ] **Permissions**
  - [ ] User has access to target ad account
  - [ ] User role in Reddit Ads allows read access

- [ ] **Request Parameters**
  - [ ] All required parameters are provided
  - [ ] Account ID is a plain string (no URN format)
  - [ ] Date ranges use `date_start` and `date_end` in `YYYY-MM-DD` format (no `date_preset`)
  - [ ] Budget values are interpreted in micro units (divide by 1,000,000)

- [ ] **Rate Limiting**
  - [ ] Not exceeding ~1 request per second
  - [ ] Waiting appropriately between API calls
  - [ ] Using broad queries to minimize call count

- [ ] **Data Availability**
  - [ ] Campaign/ad group was active during requested date range
  - [ ] Status filter is not excluding target entities
  - [ ] Allowing 24-48 hours for full data processing on recent dates

---

## Common Patterns Summary

**"MCP server not found"**
-> Check: Hopkin MCP configuration and token, restart Claude

**"Not authenticated"**
-> Run: `reddit_ads_check_auth_status` -> Direct user to https://app.hopkin.ai

**"Account not found"**
-> Check: Account ID is a plain string, user has account access

**"No data returned"**
-> Check: Date range (use `date_start`/`date_end`), campaign status, campaign activity during period

**"Budget values look wrong"**
-> Check: Reddit uses micro units — divide by 1,000,000

**"No demographic data"**
-> Reddit does not support demographic breakdowns — use `breakdown: ["community"]` for subreddit analysis instead

**"Rate limit exceeded"**
-> Check: Request frequency (~1 req/sec limit), wait and retry, use broader queries

---

**Document Version:** 1.0
**Last Updated:** 2026-03-16
**Service:** Hopkin Reddit Ads MCP (https://app.hopkin.ai)
