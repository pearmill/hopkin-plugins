# LinkedIn Ads Skill — Troubleshooting Guide

This guide provides solutions to common issues encountered when using the LinkedIn Ads skill with the Hopkin LinkedIn Ads MCP.

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
- No `linkedin_ads_` prefixed tools available
- Cannot execute LinkedIn Ads operations

**Diagnosis:**
1. Check for `linkedin_ads_` prefixed tools in your available tools
2. If none are found, the Hopkin LinkedIn Ads MCP is not configured

**Solutions:**

#### Solution 1: Sign Up and Configure Hopkin

1. Sign up at **https://app.hopkin.ai**
2. Add the hosted MCP to your Claude configuration:

```json
{
  "mcpServers": {
    "hopkin-linkedin-ads": {
      "type": "url",
      "url": "https://mcp.hopkin.ai/linkedin-ads/mcp",
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
2. Verify the MCP URL is exactly: `https://mcp.hopkin.ai/linkedin-ads/mcp`
3. Ensure the Authorization header format is: `Bearer YOUR_TOKEN` (with a space after Bearer)

#### Solution 3: Restart Claude

After installing or configuring the MCP server:
1. Completely quit Claude
2. Restart the application
3. Verify `linkedin_ads_` tools appear in available tools

---

## Authentication Problems

### Not Authenticated with LinkedIn Ads

**Symptoms:**
- `linkedin_ads_check_auth_status` returns `authenticated: false`
- Tools return authentication errors
- Cannot access ad account data

**Solutions:**

#### Solution 1: Run the Authentication Flow

1. Call `linkedin_ads_check_auth_status` to verify current status
2. If not authenticated, direct the user to connect their LinkedIn Ads account via https://app.hopkin.ai
3. After the user completes the OAuth flow, re-verify with `linkedin_ads_check_auth_status`

#### Solution 2: LinkedIn Token Expired (60-Day TTL)

LinkedIn provider tokens expire after **60 days**. Unlike Meta and Google, LinkedIn does not issue long-lived tokens.

**Signs:** User was previously authenticated but is now getting auth errors, and `linkedin_ads_check_auth_status` shows `authenticated: false` or an expired `expires_at` timestamp.

**Resolution:**
1. Inform the user: "Your LinkedIn connection has expired. LinkedIn tokens expire every 60 days."
2. Direct them to https://app.hopkin.ai to reconnect their LinkedIn account
3. After reconnection, re-verify with `linkedin_ads_check_auth_status`

**Prevention:**
- Remind users to reconnect before token expiry
- When `expires_at` is approaching (within 7 days), proactively inform the user

---

## Permission Errors

### Insufficient LinkedIn Scopes

**Symptoms:**
- Can authenticate but cannot access ad account data
- `linkedin_ads_check_auth_status` shows `linkedin_scopes` is missing expected permissions

**Solutions:**

#### Solution 1: Re-authenticate with Correct Scopes

1. Direct the user to https://app.hopkin.ai
2. Ask them to disconnect and reconnect their LinkedIn account
3. Ensure they grant all requested permissions during the OAuth flow

#### Solution 2: Check Account Role in LinkedIn Campaign Manager

1. Log into LinkedIn Campaign Manager
2. Navigate to Account Settings → Users
3. Verify the user's role:
   - **Viewer:** Read-only access to reporting
   - **Creative Manager:** Can manage creatives, view reporting
   - **Campaign Manager:** Can manage campaigns, view reporting
   - **Account Manager:** Full access

### Account Not Accessible

**Symptoms:**
- Error: "Account not found" or "Access denied"
- Account ID is correct but tools cannot access it

**Solutions:**

1. Use `linkedin_ads_list_ad_accounts` to confirm which accounts the authenticated user can access
2. Verify the user has been granted access to the target account in LinkedIn Campaign Manager
3. Confirm the account ID is correct (numeric, no URN prefix)

---

## Data Availability Issues

### No Data Returned

**Symptoms:**
- Query succeeds but returns empty results
- No error message

**Common Causes:**
1. Date range has no campaign activity
2. Status filter excludes the target entities (e.g., filtering for `ACTIVE` but campaigns are `PAUSED`)
3. Campaign group/campaign IDs in filter don't match what's in the account

**Solutions:**

#### Solution 1: Verify Date Range
1. Check that campaigns were active during the requested date range
2. Try a broader date range (e.g., `LAST_90_DAYS` instead of `LAST_7_DAYS`)
3. Use `linkedin_ads_list_campaign_groups` to check actual campaign dates

#### Solution 2: Check Status Filters
1. Default status filters for `linkedin_ads_list_campaign_groups` and `linkedin_ads_list_campaigns` are `["ACTIVE", "PAUSED"]`
2. Add `"ARCHIVED"` or `"CANCELED"` to the status filter if older data is needed
3. For analytics tools, data is returned regardless of current status as long as there was activity in the date range

#### Solution 3: Verify Campaign Group/Campaign IDs
1. Use `linkedin_ads_list_campaign_groups` to get the correct IDs
2. Ensure filters match the numeric IDs, not URNs

### Invalid Pivot for MEMBER_* Demographics

**Symptoms:**
- Error when using MEMBER_* pivot in `linkedin_ads_get_performance_report`
- No demographic data returned

**Cause:** MEMBER_* demographic pivots (`MEMBER_JOB_FUNCTION`, `MEMBER_SENIORITY`, etc.) are **only supported by `linkedin_ads_get_insights`**, not `linkedin_ads_get_performance_report`.

**Solution:** Use `linkedin_ads_get_insights` for any MEMBER_* demographic analysis:
```json
{
  "tool": "linkedin_ads_get_insights",
  "parameters": {
    "reason": "Demographic analysis by job function",
    "account_id": 123456789,
    "pivot": "MEMBER_JOB_FUNCTION",
    "date_preset": "LAST_30_DAYS"
  }
}
```

### Incomplete Conversion Data

**Symptoms:**
- Conversion numbers seem lower than expected
- ROAS appears lower than in LinkedIn Campaign Manager

**Solutions:**

1. Call `linkedin_ads_get_partner_conversions` to see which conversions are configured
2. Use `include_conversion_breakdown: true` in `linkedin_ads_get_performance_report` to see per-action breakdown
3. Account for LinkedIn's conversion attribution window (the default is 1-day for view-through and 30-day for click-through)
4. Recent data (last 1-3 days) may be incomplete due to attribution processing delays

---

## API Error Codes

### Common LinkedIn Marketing API Errors

#### Service Unavailable / 503
**Cause:** LinkedIn API is temporarily unavailable or overloaded.

**Solutions:**
- Wait 30–60 seconds and retry
- Use the `refresh: false` default to leverage cached data where possible

#### Too Many Requests / 429
**Cause:** Rate limiting — too many API requests in a short period.

**Solutions:**
- Wait before retrying (exponential backoff recommended)
- Reduce request frequency
- Use broader queries instead of many narrow ones

#### Unauthorized / 401
**Cause:** LinkedIn token expired or invalid.

**Solutions:**
- Call `linkedin_ads_check_auth_status` to confirm token status
- If expired (60-day TTL), direct user to https://app.hopkin.ai to reconnect

#### Forbidden / 403
**Cause:** Insufficient permissions or attempting a write operation.

**Solutions:**
- Verify the user's role in LinkedIn Campaign Manager
- Re-authenticate with correct scopes via https://app.hopkin.ai
- Confirm this is a read operation (MCP is read-only)

---

## Performance & Rate Limiting

### Slow Response Times

**Solutions:**

1. Use `date_preset` shortcuts instead of long custom date ranges
2. Filter to specific campaigns/campaign groups with `campaign_ids` or `campaign_group_ids` parameters
3. Reduce `limit` parameter to get smaller result pages
4. Avoid simultaneous analytics calls — run one at a time

### Rate Limit Best Practices

1. **Use caching** — Most list tools cache results for 5 minutes. Avoid calling `refresh: true` unless fresh data is specifically needed.
2. **Use pagination** — Don't request all data at once; use `limit` and `cursor`
3. **Use `date_preset`** — Prefer presets over custom date ranges where possible
4. **Batch by campaign group** — When analyzing multiple campaigns, filter by `campaign_group_id` to reduce result sets

---

## Data Quality Issues

### Discrepancies Between LinkedIn Campaign Manager and API

**Common Causes & Solutions:**

#### Cause 1: Attribution Window Differences
LinkedIn Campaign Manager default attribution: 1-day view-through + 30-day click-through. API may return different numbers if a different window is used.

#### Cause 2: Time Zone Differences
LinkedIn Campaign Manager reports in the account's time zone. API data may use UTC. When comparing exact day-level numbers, account for time zone offset.

#### Cause 3: Data Processing Delay
Recent data (especially today and yesterday) is still processing. LinkedIn typically takes 24–48 hours for full data processing. Use `LAST_7_DAYS` or older presets for more stable numbers.

#### Cause 4: Demographic Data Sampling
MEMBER_* demographic data (job title, industry, etc.) is based on LinkedIn member profile data which may not be 100% complete. Small audience segments may have suppressed or estimated data.

---

## Debugging Checklist

When encountering issues, work through this checklist:

- [ ] **MCP Connection**
  - [ ] Hopkin MCP is configured with valid token
  - [ ] `linkedin_ads_` tools appear in available tools
  - [ ] Claude has been restarted after config changes

- [ ] **Authentication**
  - [ ] `linkedin_ads_check_auth_status` returns `authenticated: true`
  - [ ] LinkedIn token has not expired (check `expires_at`, 60-day TTL)
  - [ ] User has completed OAuth flow via https://app.hopkin.ai

- [ ] **Permissions**
  - [ ] User has access to target ad account
  - [ ] User role in LinkedIn Campaign Manager allows read access

- [ ] **Request Parameters**
  - [ ] All required parameters are provided (including `reason`)
  - [ ] `account_id` is a numeric value (no URN prefix)
  - [ ] Date ranges are valid YYYY-MM-DD format
  - [ ] Using `linkedin_ads_get_insights` (not `get_performance_report`) for MEMBER_* pivots

- [ ] **Data Availability**
  - [ ] Campaign/creative was active during requested date range
  - [ ] Status filter is not excluding target entities
  - [ ] Sufficient data exists for requested pivot dimension

---

## Common Patterns Summary

**"MCP server not found"**
→ Check: Hopkin MCP configuration and token, restart Claude

**"Not authenticated"**
→ Run: `linkedin_ads_check_auth_status` → Direct user to https://app.hopkin.ai

**"Token expired"**
→ LinkedIn tokens expire every 60 days → Direct user to https://app.hopkin.ai to reconnect

**"Account not found"**
→ Check: Account ID is numeric (no URN prefix), user has account access

**"No data returned"**
→ Check: Date range, campaign status filters, campaign activity during period

**"Invalid pivot"**
→ Check: MEMBER_* pivots require `linkedin_ads_get_insights`, not `get_performance_report`

**"Rate limit exceeded"**
→ Check: Request frequency, implement backoff, use cached data where possible

---

**Document Version:** 1.0
**Last Updated:** 2026-03-02
**Service:** Hopkin LinkedIn Ads MCP (https://app.hopkin.ai)
