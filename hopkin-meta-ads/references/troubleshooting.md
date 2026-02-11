# Meta Ads Skill - Troubleshooting Guide

This guide provides solutions to common issues encountered when using the Meta Ads skill with the Hopkin Meta Ads MCP.

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
- No `meta_ads_` prefixed tools available
- Cannot execute Meta Ads operations

**Diagnosis:**
1. Check for `meta_ads_` prefixed tools in your available tools
2. If none are found, the Hopkin Meta Ads MCP is not configured

**Solutions:**

#### Solution 1: Sign Up and Configure Hopkin

1. Sign up at **https://app.hopkin.ai**
2. Add the hosted MCP to your Claude configuration:

```json
{
  "mcpServers": {
    "hopkin-meta-ads": {
      "type": "url",
      "url": "https://mcp.hopkin.ai/meta-ads/mcp",
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
2. Verify the MCP URL is exactly: `https://mcp.hopkin.ai/meta-ads/mcp`
3. Ensure the Authorization header format is: `Bearer YOUR_TOKEN` (with a space after Bearer)

#### Solution 3: Restart Claude

After installing or configuring the MCP server:
1. Completely quit Claude
2. Restart the application
3. Verify `meta_ads_` tools appear in available tools

**Prevention:**
- Keep your Hopkin token up to date
- Verify MCP configuration before starting complex tasks

---

## Authentication Problems

### Not Authenticated with Meta Ads

**Symptoms:**
- `meta_ads_check_auth_status` returns not authenticated
- Tools return authentication errors
- Cannot access ad account data

**Solutions:**

#### Solution 1: Run the Authentication Flow

1. Call `meta_ads_check_auth_status` to verify current status:
   ```json
   {
     "tool": "meta_ads_check_auth_status",
     "parameters": {
       "reason": "Checking if user is authenticated"
     }
   }
   ```

2. If not authenticated, call `meta_ads_get_login_url`:
   ```json
   {
     "tool": "meta_ads_get_login_url",
     "parameters": {
       "reason": "Getting login URL for Meta Ads authentication"
     }
   }
   ```

3. Present the returned URL to the user — they need to authenticate via Meta's OAuth flow

4. After the user completes authentication, verify with `meta_ads_get_user_info`:
   ```json
   {
     "tool": "meta_ads_get_user_info",
     "parameters": {
       "reason": "Verifying authentication after user login"
     }
   }
   ```

#### Solution 2: Session Expired

If the user was previously authenticated but the session has expired:
1. Re-run the authentication flow above
2. The user will need to authenticate again via the login URL

**Prevention:**
- Always check auth status at the beginning of a session
- If auth errors occur mid-session, re-authenticate immediately

### Wrong Ad Account Access

**Symptoms:**
- Error: "Account not found"
- Can see some accounts but not the target account

**Solutions:**

#### Solution 1: Verify Ad Account ID Format
- Must start with `act_`
- Example: `act_123456789` (not just `123456789`)
- Check for typos or extra characters

#### Solution 2: List Available Accounts
Use `meta_ads_list_ad_accounts` to see which accounts the authenticated user can access:
```json
{
  "tool": "meta_ads_list_ad_accounts",
  "parameters": {
    "reason": "Listing available accounts to find the correct one"
  }
}
```

#### Solution 3: Confirm Account Access in Meta
1. Log into Meta Business Suite
2. Navigate to Ads Manager
3. Check the account switcher — verify you can access the target account
4. If account is not listed, the user needs to request access

---

## Permission Errors

### Insufficient Permissions

**Symptoms:**
- Cannot access certain ad account data
- Limited functionality

**Solutions:**

#### Solution 1: Re-authenticate with Correct Permissions
1. Run `meta_ads_get_login_url` to get a new login URL
2. Have the user authenticate again, ensuring they grant all requested permissions

#### Solution 2: Check Account Role
1. Go to Business Settings → Ad Accounts
2. Find the user and check their role:
   - **Analyst:** Read-only access, can view reports
   - **Advertiser:** Can create and edit ads, view reports
   - **Admin:** Full control

---

## Data Availability Issues

### No Data Returned

**Symptoms:**
- Query succeeds but returns empty results
- No error message

**Common Causes:**
1. Date range has no activity
2. Filters are too restrictive
3. Campaign was not active during specified period

**Solutions:**

#### Solution 1: Verify Date Range
1. Check campaign start and end dates
2. Ensure date range overlaps with campaign activity
3. Try broader date range (e.g., `last_30d` instead of `last_7d`)
4. Use `lifetime` date preset to see all data

#### Solution 2: Check Campaign Status
1. Verify campaigns exist and have run during the date range
2. Use `meta_ads_list_campaigns` to check status:
   ```json
   {
     "tool": "meta_ads_list_campaigns",
     "parameters": {
       "reason": "Checking campaign status to troubleshoot missing data",
       "account_id": "act_123456789"
     }
   }
   ```

### Incomplete Data

**Symptoms:**
- Some expected fields are missing
- Data seems lower than expected

**Solutions:**

#### Solution 1: Account for Attribution Windows
1. Conversion data may be delayed due to attribution windows
2. Recent data (last 1-2 days) may be incomplete
3. Use longer date ranges for conversion analysis

#### Solution 2: Privacy Thresholds
1. Small audience sizes may have suppressed demographic data
2. Some breakdowns unavailable due to privacy restrictions
3. Aggregate data at higher level if detailed breakdowns are missing

---

## API Error Codes

### Error Code Reference

#### Error 100: Invalid Parameter
**Cause:** Malformed request, invalid field name, or incorrect value

**Solutions:**
- Verify all parameters are correct
- Check date formats (YYYY-MM-DD)
- Ensure account_id starts with "act_"
- Review API documentation for valid values

#### Error 190: Access Token Invalid
**Cause:** Session expired or authentication issue

**Solutions:**
- Re-run authentication flow: `meta_ads_check_auth_status` → `meta_ads_get_login_url`

#### Error 200: Permission Denied
**Cause:** Insufficient permissions for operation

**Solutions:**
- Re-authenticate with correct permissions
- Check account role in Meta Business Suite

#### Error 80004: API Request Limit Reached
**Cause:** Rate limiting — too many requests in short period

**Solutions:**
- Wait before retrying (exponential backoff recommended)
- Reduce request frequency
- Use broader queries instead of many narrow ones

---

## Performance & Rate Limiting

### Slow Response Times

**Solutions:**

#### Solution 1: Reduce Data Volume
1. Use shorter date ranges
2. Limit result count with `limit` parameter
3. Use pagination for large result sets

#### Solution 2: Avoid Complex Breakdowns
1. Multiple breakdowns significantly increase processing time
2. Use single breakdown when possible
3. Request breakdowns separately instead of combined

### Rate Limit Best Practices

1. **Implement Exponential Backoff** — On rate limit error, wait before retrying
2. **Avoid Repeated Identical Requests** — Cache results when possible
3. **Use Pagination** — Don't request all data at once; use `limit` and `nextCursor`

---

## Data Quality Issues

### Discrepancies Between Meta Ads Manager and API

**Common Causes & Solutions:**

#### Cause 1: Different Attribution Settings
Ensure API requests use same attribution window as Ads Manager (default: 7-day click, 1-day view).

#### Cause 2: Time Zone Differences
Ads Manager uses ad account time zone. API may use UTC.

#### Cause 3: Data Freshness
Recent data (today, yesterday) may still be processing.

#### Cause 4: Unique vs. Total Metrics
Ensure comparing same metric (clicks vs. unique_clicks).

---

## Debugging Checklist

When encountering issues, work through this checklist:

- [ ] **MCP Connection**
  - [ ] Hopkin MCP is configured with valid token
  - [ ] `meta_ads_` tools appear in available tools
  - [ ] Claude has been restarted after config changes

- [ ] **Authentication**
  - [ ] `meta_ads_check_auth_status` returns authenticated
  - [ ] User has completed OAuth flow via `meta_ads_get_login_url` if needed

- [ ] **Permissions**
  - [ ] User has access to target ad account
  - [ ] Ad account ID is correctly formatted (act_XXXXX)

- [ ] **Request Parameters**
  - [ ] All required parameters are provided (including `reason`)
  - [ ] Date ranges are valid
  - [ ] Account ID starts with "act_"

- [ ] **Data Availability**
  - [ ] Campaign/ad was active during requested date range
  - [ ] Sufficient data exists for requested breakdowns

---

## Common Patterns Summary

**"Cannot access ad account"**
→ Check: Ad account ID format, authentication status, account access

**"No data returned"**
→ Check: Date range, campaign status, filters

**"Not authenticated"**
→ Run: `meta_ads_check_auth_status` → `meta_ads_get_login_url` → user authenticates → `meta_ads_get_user_info`

**"Rate limit exceeded"**
→ Check: Request frequency, implement backoff, reduce query scope

---

**Document Version:** 2.0
**Last Updated:** 2026-02-10
**Service:** Hopkin Meta Ads MCP (https://app.hopkin.ai)
