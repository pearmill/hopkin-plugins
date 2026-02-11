# Google Ads Skill - Troubleshooting Guide

This guide provides solutions to common issues encountered when using the Google Ads skill with the Hopkin Google Ads MCP.

## Table of Contents

1. [MCP Server Issues](#mcp-server-issues)
2. [Authentication Problems](#authentication-problems)
3. [Permission Errors](#permission-errors)
4. [Data Availability Issues](#data-availability-issues)
5. [API Error Types](#api-error-types)
6. [Performance & Rate Limiting](#performance--rate-limiting)
7. [Data Quality Issues](#data-quality-issues)

---

## MCP Server Issues

### MCP Server Not Found

**Symptoms:**
- No `google_ads_` prefixed tools available
- Cannot execute Google Ads operations

**Diagnosis:**
1. Check for `google_ads_` prefixed tools in your available tools
2. If none are found, the Hopkin Google Ads MCP is not configured

**Solutions:**

#### Solution 1: Sign Up and Configure Hopkin

1. Sign up at **https://app.hopkin.ai**
2. Add the hosted MCP to your Claude configuration:

```json
{
  "mcpServers": {
    "hopkin-google-ads": {
      "type": "url",
      "url": "https://mcp.hopkin.ai/google-ads/mcp",
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
2. Verify the MCP URL is exactly: `https://mcp.hopkin.ai/google-ads/mcp`
3. Ensure the Authorization header format is: `Bearer YOUR_TOKEN` (with a space after Bearer)

#### Solution 3: Restart Claude

After installing or configuring the MCP server:
1. Completely quit Claude
2. Restart the application
3. Verify `google_ads_` tools appear in available tools

**Prevention:**
- Keep your Hopkin token up to date
- Verify MCP configuration before starting complex tasks

---

## Authentication Problems

### Not Authenticated with Google Ads

**Symptoms:**
- `google_ads_check_auth_status` returns not authenticated
- Tools return authentication errors
- Cannot access account data

**Solutions:**

#### Solution 1: Run the Authentication Flow

1. Call `google_ads_check_auth_status` to verify current status:
   ```json
   {
     "tool": "google_ads_check_auth_status",
     "parameters": {
       "reason": "Checking if user is authenticated"
     }
   }
   ```

2. If not authenticated, call `google_ads_get_login_url`:
   ```json
   {
     "tool": "google_ads_get_login_url",
     "parameters": {
       "reason": "Getting login URL for Google Ads authentication"
     }
   }
   ```

3. Present the returned URL to the user — they need to authenticate via Google's OAuth flow

4. After the user completes authentication, verify with `google_ads_get_user_info`:
   ```json
   {
     "tool": "google_ads_get_user_info",
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

### Wrong Customer ID

**Symptoms:**
- Error: "Invalid customer ID"
- Error: "Customer not found"
- Cannot access specific account

**Solutions:**

#### Solution 1: Verify Customer ID Format
- Must be 10 digits
- NO hyphens or dashes (use `1234567890`, not `123-456-7890`)
- NO "act_" prefix (that's Meta Ads format)
- Check for typos

#### Solution 2: List Available Accounts
Use `google_ads_list_accounts` to see which accounts the authenticated user can access:
```json
{
  "tool": "google_ads_list_accounts",
  "parameters": {
    "reason": "Listing available accounts to find the correct one"
  }
}
```

#### Solution 3: Use Manager Account
If accessing a client account through a manager account:
- Use `google_ads_list_mcc_child_accounts` to find child accounts
- Provide the `login_customer_id` parameter when accessing child accounts

---

## Permission Errors

### Insufficient Permissions

**Symptoms:**
- Error: "User doesn't have permission to access customer"
- Can list accounts but cannot access specific account

**Solutions:**

#### Solution 1: Re-authenticate
Run `google_ads_get_login_url` and have the user authenticate again, ensuring they grant access to the correct accounts.

#### Solution 2: Check Account Access
1. Log into Google Ads with admin access
2. Navigate to Tools & Settings → Setup → Access and security
3. Verify the authenticated email has appropriate access

#### Solution 3: Manager Account Access
If using a Manager Account (MCC):
1. Use `google_ads_list_mcc_child_accounts` to verify account linkage
2. Provide the `login_customer_id` parameter

---

## Data Availability Issues

### No Data Returned

**Symptoms:**
- Query succeeds but returns empty results
- No campaigns or ads shown

**Common Causes:**
1. Date range has no activity
2. Account has no active campaigns
3. Filters are too restrictive

**Solutions:**

#### Solution 1: Verify Date Range
1. Try broader date range (e.g., `LAST_30_DAYS`)
2. Ensure date range overlaps with campaign activity

#### Solution 2: Check Campaign Status
Use `google_ads_list_campaigns` to verify campaigns exist and are active:
```json
{
  "tool": "google_ads_list_campaigns",
  "parameters": {
    "reason": "Checking campaign status to troubleshoot missing data",
    "customer_id": "1234567890"
  }
}
```

#### Solution 3: Simplify Query
Remove optional filters and try with minimal parameters first.

### Missing Metrics

**Symptoms:**
- Some metrics return 0 or null
- Conversion data missing

**Solutions:**

#### Solution 1: Check Conversion Tracking Setup
1. Verify conversion actions are configured in Google Ads
2. Check that conversion tracking tags are installed
3. Allow time for conversion attribution

#### Solution 2: Attribution Windows
1. Conversions may not appear immediately
2. Recent data may be incomplete due to attribution delay
3. Use longer date ranges for conversion analysis

---

## API Error Types

### Common Error Types

#### Authentication Error
**Cause:** Session expired or authentication issue
**Solution:** Re-run auth flow: `google_ads_check_auth_status` → `google_ads_get_login_url`

#### Invalid Customer ID
**Cause:** Customer ID format incorrect or inaccessible
**Solution:** Remove hyphens (use 1234567890, not 123-456-7890), verify account access

#### Rate Limit Error
**Cause:** Too many API requests
**Solution:** Implement exponential backoff, reduce request frequency

#### Resource Not Found
**Cause:** Requested resource doesn't exist
**Solution:** Verify campaign/ad group IDs are correct

---

## Performance & Rate Limiting

### Slow Query Performance

**Solutions:**

#### Solution 1: Reduce Data Volume
1. Use shorter date ranges
2. Use `limit` parameter to restrict results
3. Use pagination instead of requesting all data at once

#### Solution 2: Simplify Queries
1. Minimize use of segments
2. Request only needed data
3. Filter to specific campaigns instead of account-wide queries

### Rate Limit Best Practices

1. **Implement Exponential Backoff** — On rate limit error, wait before retrying
2. **Avoid Repeated Identical Requests** — Cache results when possible
3. **Use Pagination** — Don't request all data at once; use `limit` and `nextCursor`

---

## Data Quality Issues

### Discrepancies Between Google Ads UI and API

**Common Causes & Solutions:**

#### Cause 1: Different Attribution Settings
Google Ads UI may use different attribution model than API defaults.

#### Cause 2: Time Zone Differences
API returns data in account time zone by default.

#### Cause 3: Data Freshness
Recent data (today, yesterday) may still be processing.

#### Cause 4: Filtering Differences
UI applies default filters (hides removed campaigns). Match UI filters in queries.

---

## Debugging Checklist

When encountering issues, work through this checklist:

- [ ] **MCP Connection**
  - [ ] Hopkin MCP is configured with valid token
  - [ ] `google_ads_` tools appear in available tools
  - [ ] Claude has been restarted after config changes

- [ ] **Authentication**
  - [ ] `google_ads_check_auth_status` returns authenticated
  - [ ] User has completed OAuth flow via `google_ads_get_login_url` if needed

- [ ] **Permissions**
  - [ ] User has access to target customer account
  - [ ] Customer ID is correctly formatted (10 digits, no hyphens)

- [ ] **Request Parameters**
  - [ ] All required parameters are provided (including `reason`)
  - [ ] Date ranges are valid
  - [ ] Customer ID is 10 digits with no hyphens

- [ ] **Data Availability**
  - [ ] Campaign/ad group was active during requested date range
  - [ ] Conversion tracking is configured (if requesting conversion data)

---

## Common Patterns Summary

**"Cannot access customer"**
→ Check: Customer ID format (no hyphens), authentication status, account access

**"No data returned"**
→ Check: Date range, campaign status, query filters

**"Not authenticated"**
→ Run: `google_ads_check_auth_status` → `google_ads_get_login_url` → user authenticates → `google_ads_get_user_info`

**"Rate limit exceeded"**
→ Check: Request frequency, implement backoff, reduce query scope

---

**Document Version:** 2.0
**Last Updated:** 2026-02-10
**Service:** Hopkin Google Ads MCP (https://app.hopkin.ai)
