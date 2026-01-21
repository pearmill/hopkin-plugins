# Meta Ads Skill - Troubleshooting Guide

This guide provides solutions to common issues encountered when using the Meta Ads skill with the Meta Ads MCP server.

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
- Error: "MCP server not found"
- Meta Ads tools are not available
- Cannot execute Meta Ads operations

**Diagnosis:**
1. List available MCP servers in your environment
2. Check if a Meta Ads MCP server appears in the list
3. Verify the MCP server name (common names: pipeboard-meta-ads, meta-ads, facebook-ads)

**Solutions:**

#### Solution 1: Install the MCP Server
If the MCP server is not installed:

1. Identify the correct Meta Ads MCP server package for your setup
2. Install the MCP server following its documentation
3. Common installation methods:
   - NPM package: `npm install -g @package/meta-ads-mcp`
   - Direct installation through Claude Desktop settings
   - Docker container (if applicable)

#### Solution 2: Configure Claude Desktop
Add MCP server to your Claude Desktop configuration:

**Location of config file:**
- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`

**Example configuration:**
```json
{
  "mcpServers": {
    "meta-ads": {
      "command": "npx",
      "args": ["-y", "@your-package/meta-ads-mcp"],
      "env": {
        "META_ACCESS_TOKEN": "your-access-token-here",
        "META_AD_ACCOUNT_ID": "act_123456789"
      }
    }
  }
}
```

#### Solution 3: Restart Claude
After installing or configuring the MCP server:
1. Completely quit Claude Desktop
2. Restart the application
3. Verify the MCP server appears in available servers

#### Solution 4: Check MCP Server Process
Verify the MCP server process is running:
- Check system processes for the MCP server
- Review Claude Desktop logs for MCP connection errors
- Ensure no port conflicts exist

**Prevention:**
- Keep MCP server packages up to date
- Verify MCP configuration before starting complex tasks
- Document working MCP configuration for reference

---

## Authentication Problems

### Invalid Access Token (Error 190)

**Symptoms:**
- Error: "Invalid OAuth access token"
- Error code: 190
- Cannot access ad account data

**Common Causes:**
1. Access token has expired
2. Access token was revoked
3. Access token lacks required permissions
4. Token was copied incorrectly (whitespace, truncation)

**Solutions:**

#### Solution 1: Generate New Access Token
1. Go to Meta Business Suite (business.facebook.com)
2. Navigate to Business Settings → Users → System Users (or your user)
3. Generate a new access token with required permissions:
   - `ads_read` - For reading ad data
   - `ads_management` - For creating/updating ads
   - `business_management` - For account access
4. Set appropriate expiration (60 days or never expire for development)
5. Copy the new token carefully (no extra spaces or line breaks)
6. Update your MCP server configuration with the new token
7. Restart Claude Desktop

#### Solution 2: Verify Token Permissions
1. Use Meta's Access Token Debugger: https://developers.facebook.com/tools/debug/accesstoken/
2. Paste your access token
3. Check "Scopes" section - verify it includes `ads_read` or `ads_management`
4. If scopes are missing, regenerate token with correct permissions

#### Solution 3: Check Token Expiration
1. In Access Token Debugger, check "Expires" field
2. If expired or expiring soon, generate a new token
3. For production use, implement token refresh logic
4. For development, use longer-lived tokens

**Prevention:**
- Use system user tokens (don't expire) instead of personal tokens
- Set calendar reminders before token expiration
- Document token generation process
- Store tokens securely (never commit to git)

### Wrong Ad Account Access

**Symptoms:**
- Error: "Account not found" or "Permission denied"
- Can see some accounts but not the target account
- Error code: 200 or 10

**Solutions:**

#### Solution 1: Verify Ad Account ID Format
Ensure the Ad Account ID is correctly formatted:
- Must start with `act_`
- Example: `act_123456789` (not just `123456789`)
- Check for typos or extra characters

#### Solution 2: Confirm Account Access
1. Log into Meta Business Suite
2. Navigate to Ads Manager
3. Check the account switcher - verify you can access the target account
4. If account is not listed, you need to request access

#### Solution 3: Grant Access to System User
If using a system user token:
1. Go to Business Settings → System Users
2. Select your system user
3. Click "Add Assets"
4. Add the target ad account with appropriate permissions (Advertiser or Analyst)
5. Generate a new access token
6. Update MCP configuration

#### Solution 4: Check Account Status
1. Verify the ad account is not disabled or suspended
2. Check for account restrictions in Meta Business Suite
3. Ensure billing is set up (for active campaigns)

---

## Permission Errors

### Insufficient Permissions (Error 200)

**Symptoms:**
- Error: "Insufficient permissions for this action"
- Error code: 200
- Can read data but cannot create/update

**Solutions:**

#### Solution 1: Upgrade Token Scopes
If you can read but not write:
1. Current token may have only `ads_read`
2. Generate new token with `ads_management` scope
3. Update MCP configuration
4. Restart Claude

#### Solution 2: Increase Account Role
1. Go to Business Settings → Ad Accounts
2. Find your user or system user
3. Upgrade role from "Analyst" to "Advertiser" or "Admin"
4. Role permissions:
   - **Analyst:** Read-only access, can view reports
   - **Advertiser:** Can create and edit ads, view reports
   - **Admin:** Full control including billing and permissions

#### Solution 3: Check Business Manager Access
1. Verify you're in the correct Business Manager
2. Some ad accounts may be owned by different businesses
3. Request access from the account owner if needed

**Prevention:**
- Always request appropriate permissions upfront
- Document required permissions for different operations
- Use least-privilege principle (only request what you need)

---

## Data Availability Issues

### No Data Returned

**Symptoms:**
- Query succeeds but returns empty results
- `data: []` in response
- No error message

**Common Causes:**
1. Date range has no activity
2. Filters are too restrictive
3. Campaign was not active during specified period
4. Metrics not applicable to object type

**Solutions:**

#### Solution 1: Verify Date Range
1. Check campaign start_time and end_time
2. Ensure date range overlaps with campaign activity
3. Try "lifetime" date preset to see all data
4. Use broader date range (e.g., last_30d instead of today)

#### Solution 2: Remove Filters
1. Start with no filters to see all data
2. Add filters incrementally to identify which is too restrictive
3. Check filter syntax (field names, operators, values)

#### Solution 3: Check Object Status
1. Verify campaign/ad set/ad status is ACTIVE or PAUSED (not DELETED or ARCHIVED)
2. Deleted objects may not return data
3. Use `filtering` parameter to include/exclude statuses

#### Solution 4: Verify Metrics Are Available
1. Some metrics only available at certain levels (e.g., video metrics only for video ads)
2. Conversion metrics require pixel setup
3. Check that requested fields are valid for the object type

### Incomplete Data

**Symptoms:**
- Some expected fields are missing
- Data seems lower than expected
- Breakdowns return partial results

**Solutions:**

#### Solution 1: Account for Attribution Windows
1. Conversion data may be delayed due to attribution windows
2. Recent data (last 1-2 days) may be incomplete
3. Use longer date ranges for conversion analysis
4. Check attribution settings for account

#### Solution 2: Privacy Thresholds
1. Small audience sizes may have suppressed demographic data
2. Some breakdowns unavailable due to privacy restrictions
3. Aggregate data at higher level if detailed breakdowns are missing

#### Solution 3: Request Specific Fields
1. Default field sets may not include all desired data
2. Explicitly request all needed fields in `fields` parameter
3. Check field compatibility (some fields cannot be requested together)

---

## API Error Codes

### Error Code Reference

#### Error 100: Invalid Parameter
**Cause:** Malformed request, invalid field name, or incorrect value

**Solutions:**
- Verify all field names are spelled correctly
- Check parameter formats (dates as YYYY-MM-DD, IDs as strings)
- Review API documentation for valid values
- Validate JSON syntax if sending complex objects

**Example:**
```
Error: "Invalid parameter"
Field: "date_preset"
Value: "last7days"
Fix: Use "last_7d" instead
```

#### Error 190: Access Token Invalid
**Cause:** Token expired, revoked, or malformed

**Solutions:** See [Invalid Access Token](#invalid-access-token-error-190) section above

#### Error 200: Permission Denied
**Cause:** Insufficient permissions for operation

**Solutions:** See [Insufficient Permissions](#insufficient-permissions-error-200) section above

#### Error 80004: API Request Limit Reached
**Cause:** Rate limiting - too many requests in short period

**Solutions:**
- Wait before retrying (exponential backoff recommended)
- Reduce request frequency
- Batch multiple operations when possible
- Check rate limit headers in responses
- Consider upgrading API tier if consistently hitting limits

**Rate Limit Guidelines:**
- Default: 200 calls per hour per user
- Marketing API: Higher limits for approved apps
- Use batch requests to combine multiple operations

#### Error 17: User Request Limit Reached
**Cause:** Too many requests from this user

**Solutions:**
- Similar to Error 80004
- May indicate need for system user instead of personal token
- Check for infinite loops or repeated failed requests

#### Error 2635: Account Temporarily Unavailable
**Cause:** Ad account is disabled, in review, or restricted

**Solutions:**
- Check ad account status in Meta Business Suite
- Review any notifications or warnings
- Contact Meta support if account was unexpectedly disabled
- Wait if account is under review

---

## Performance & Rate Limiting

### Slow Response Times

**Symptoms:**
- Requests take a long time to complete
- Timeouts
- Delayed results

**Solutions:**

#### Solution 1: Reduce Data Volume
1. Use shorter date ranges
2. Request fewer fields
3. Limit result count with `limit` parameter
4. Use pagination for large result sets

#### Solution 2: Avoid Complex Breakdowns
1. Multiple breakdowns significantly increase processing time
2. Use single breakdown when possible
3. Request breakdowns separately instead of combined

#### Solution 3: Use Date Presets
1. Presets (last_7d, last_30d) may be faster than custom ranges
2. Meta may cache common preset queries

#### Solution 4: Optimize Request Timing
1. Avoid peak hours if possible
2. Distribute requests over time instead of bursts
3. Use asynchronous requests for large reports

### Rate Limit Best Practices

**Prevention Strategies:**

1. **Implement Exponential Backoff**
   - On rate limit error, wait before retrying
   - Double wait time with each retry
   - Example: 1s, 2s, 4s, 8s, 16s

2. **Cache Results**
   - Store frequently accessed data locally
   - Avoid repeated identical requests
   - Use appropriate cache TTL (time-to-live)

3. **Batch Operations**
   - Combine multiple operations when API supports it
   - Request multiple objects in single call
   - Use batch endpoints where available

4. **Monitor Rate Limits**
   - Track request counts
   - Check rate limit headers in responses
   - Implement client-side rate limiting

---

## Data Quality Issues

### Discrepancies Between Meta Ads Manager and API

**Symptoms:**
- Numbers don't match between Ads Manager UI and API responses
- Totals don't add up
- Metrics seem inconsistent

**Common Causes & Solutions:**

#### Cause 1: Different Attribution Settings
**Solution:** Ensure API requests use same attribution window as Ads Manager
- Default attribution: 7-day click, 1-day view
- Check account attribution settings
- Specify attribution window in API requests if supported

#### Cause 2: Time Zone Differences
**Solution:**
- Ads Manager uses ad account time zone
- API may use UTC or different time zone
- Specify time zone in requests
- Use `time_increment` parameter for daily breakdowns

#### Cause 3: Filtering Differences
**Solution:**
- Ads Manager may apply default filters (e.g., hide deleted campaigns)
- API returns all data unless explicitly filtered
- Match Ads Manager filters in API requests

#### Cause 4: Data Freshness
**Solution:**
- Ads Manager may show more recent data
- API data may have slight delay (up to a few hours)
- Recent data (today, yesterday) may still be processing

#### Cause 5: Unique vs. Total Metrics
**Solution:**
- Ensure comparing same metric (clicks vs. unique_clicks)
- Check if Ads Manager shows unique or total
- Request correct metric field in API

### Missing Conversion Data

**Symptoms:**
- Conversion fields are 0 or null
- Expected conversions not showing
- Conversion metrics unavailable

**Solutions:**

#### Solution 1: Verify Pixel Setup
1. Check Meta Pixel is installed on website
2. Verify pixel is firing correctly (use Meta Pixel Helper browser extension)
3. Confirm conversion events are configured
4. Check pixel ID matches ad account

#### Solution 2: Check Conversion Event Configuration
1. Go to Events Manager in Meta Business Suite
2. Verify custom conversion events are set up
3. Check event parameters and matching rules
4. Test events with Pixel Helper or Test Events tool

#### Solution 3: Attribution Window
1. Conversions may not appear immediately
2. Default attribution: 7-day click, 1-day view
3. Recent traffic may not have converted yet
4. Check if conversions appear for older date ranges

#### Solution 4: Aggregation Event Measurement
1. For iOS 14.5+, check Aggregated Event Measurement setup
2. Verify domain verification
3. Configure priority events (maximum 8)
4. Allow 72 hours for data modeling

---

## Debugging Checklist

When encountering issues, work through this checklist:

- [ ] **MCP Connection**
  - [ ] MCP server is installed and configured
  - [ ] MCP server appears in available servers list
  - [ ] Claude Desktop has been restarted after config changes

- [ ] **Authentication**
  - [ ] Access token is valid (check with Token Debugger)
  - [ ] Token has required scopes (ads_read, ads_management)
  - [ ] Token is not expired
  - [ ] Token is correctly formatted in config (no extra spaces)

- [ ] **Permissions**
  - [ ] User/system user has access to target ad account
  - [ ] Role is appropriate for operation (Analyst vs. Advertiser)
  - [ ] Ad account ID is correctly formatted (act_XXXXX)

- [ ] **Request Parameters**
  - [ ] All required parameters are provided
  - [ ] Parameter values are valid and correctly formatted
  - [ ] Field names are spelled correctly
  - [ ] Date ranges are valid and logical

- [ ] **Data Availability**
  - [ ] Campaign/ad was active during requested date range
  - [ ] Object has not been deleted
  - [ ] Sufficient data exists for requested breakdowns
  - [ ] Requested metrics are applicable to object type

- [ ] **Rate Limits**
  - [ ] Not making too many requests in short period
  - [ ] Implementing retry logic with backoff
  - [ ] Using appropriate batch sizes

---

## Getting Additional Help

If you've worked through this troubleshooting guide and still have issues:

1. **Check Meta Developer Documentation**
   - https://developers.facebook.com/docs/marketing-apis
   - Review API changelog for recent changes
   - Check for known issues or service outages

2. **Review Meta API Error Reference**
   - https://developers.facebook.com/docs/graph-api/using-graph-api/error-handling
   - Detailed error code explanations
   - API-specific troubleshooting

3. **MCP Server Documentation**
   - Check your specific MCP server's documentation
   - Review MCP server GitHub issues
   - Check for MCP server updates

4. **Meta Developer Community**
   - Meta Developers Community forum
   - Stack Overflow (tag: facebook-graph-api)
   - Meta Business Help Center

5. **Enable Debug Logging**
   - Enable verbose logging in MCP server (if available)
   - Review Claude Desktop logs
   - Capture full error responses for analysis

---

## Common Patterns Summary

**"Cannot access ad account"**
→ Check: Ad account ID format, token permissions, account access

**"No data returned"**
→ Check: Date range, campaign status, filters

**"Permission denied"**
→ Check: Token scopes, account role, Business Manager access

**"Rate limit exceeded"**
→ Check: Request frequency, implement backoff, batch operations

**"Invalid parameter"**
→ Check: Field names, value formats, API documentation

---

**Document Version:** 1.0
**Last Updated:** 2026-01-19
