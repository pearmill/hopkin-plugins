# Google Ads Skill - Troubleshooting Guide

This guide provides solutions to common issues encountered when using the Google Ads skill with the Google Ads MCP server.

## Table of Contents

1. [MCP Server Issues](#mcp-server-issues)
2. [Authentication Problems](#authentication-problems)
3. [Permission Errors](#permission-errors)
4. [Data Availability Issues](#data-availability-issues)
5. [GAQL Query Errors](#gaql-query-errors)
6. [API Error Types](#api-error-types)
7. [Performance & Rate Limiting](#performance--rate-limiting)
8. [Data Quality Issues](#data-quality-issues)

---

## MCP Server Issues

### MCP Server Not Found

**Symptoms:**
- Error: "MCP server not found"
- Google Ads tools are not available
- Cannot execute Google Ads operations

**Diagnosis:**
1. List available MCP servers in your environment
2. Check if the Google Ads MCP server appears in the list
3. Verify the MCP server name (typically: `google-ads`)

**Solutions:**

#### Solution 1: Install the MCP Server
If the MCP server is not installed:

1. Install the MCP server from the repository
2. Installation command:
   ```bash
   npm install -g @cohnen/mcp-google-ads
   ```
3. Or use with npx (no installation needed)

#### Solution 2: Configure Claude Desktop
Add MCP server to your Claude Desktop configuration:

**Location of config file:**
- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`

**Example configuration:**
```json
{
  "mcpServers": {
    "google-ads": {
      "command": "npx",
      "args": ["-y", "@cohnen/mcp-google-ads"],
      "env": {
        "GOOGLE_ADS_CLIENT_ID": "your-client-id.apps.googleusercontent.com",
        "GOOGLE_ADS_CLIENT_SECRET": "your-client-secret",
        "GOOGLE_ADS_DEVELOPER_TOKEN": "your-developer-token",
        "GOOGLE_ADS_REFRESH_TOKEN": "your-refresh-token",
        "GOOGLE_ADS_CUSTOMER_ID": "1234567890"
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

**Prevention:**
- Keep MCP server packages up to date
- Verify MCP configuration before starting complex tasks
- Document working MCP configuration for reference

---

## Authentication Problems

### OAuth Authentication Errors

**Symptoms:**
- Error: "AUTHENTICATION_ERROR"
- Error: "Invalid credentials"
- Cannot access account data

**Common Causes:**
1. Refresh token has expired or been revoked
2. Client ID or Client Secret is incorrect
3. Developer token is invalid or suspended
4. OAuth credentials mismatch

**Solutions:**

#### Solution 1: Generate New OAuth Credentials

**For OAuth2 Refresh Token:**
1. Go to Google Cloud Console (console.cloud.google.com)
2. Navigate to APIs & Services → Credentials
3. Create or select OAuth 2.0 Client ID
4. Download credentials (client_id and client_secret)
5. Use OAuth Playground or command-line tool to generate refresh token:
   - OAuth Playground: https://developers.google.com/oauthplayground
   - Select "Google Ads API v17" scope
   - Authorize and exchange code for refresh token
6. Update your MCP server configuration
7. Restart Claude Desktop

**OAuth Scopes Required:**
- `https://www.googleapis.com/auth/adwords`

#### Solution 2: Verify Developer Token

**Get Developer Token:**
1. Go to Google Ads (ads.google.com)
2. Navigate to Tools & Settings → Setup → API Center
3. Copy your developer token
4. For production use, developer token must be approved by Google
5. For testing, use the developer token in test mode

**Developer Token States:**
- **Pending:** Can access test accounts only
- **Approved:** Can access all accounts
- **Suspended:** Review violation reason and appeal

#### Solution 3: Check Credentials in Configuration

1. Verify all credentials are copied correctly (no extra spaces or line breaks)
2. Client ID should end with `.apps.googleusercontent.com`
3. Developer token format: typically starts with letters/numbers
4. Refresh token: long string, often starts with `1//`
5. Customer ID: 10 digits, no hyphens (e.g., `1234567890`)

**Prevention:**
- Store credentials securely (use environment variables, never commit to git)
- Document credential generation process
- Use service account for production deployments
- Keep track of developer token approval status

### Wrong Customer ID

**Symptoms:**
- Error: "INVALID_CUSTOMER_ID"
- Error: "Customer not found"
- Cannot access specific account

**Solutions:**

#### Solution 1: Verify Customer ID Format
Ensure the Customer ID is correctly formatted:
- Must be 10 digits
- NO hyphens or dashes (use `1234567890`, not `123-456-7890`)
- NO "act_" prefix (that's Meta Ads format)
- Check for typos or extra characters

#### Solution 2: Confirm Account Access
1. Log into Google Ads (ads.google.com)
2. Check the account selector - verify you can access the target account
3. Find the Customer ID in the top right corner (format: 123-456-7890)
4. Remove hyphens before using in API (→ 1234567890)

#### Solution 3: Use Manager Account ID
If accessing a client account through a manager account:
1. You may need to specify the manager account ID
2. Ensure your OAuth credentials have access to the manager account
3. The customer ID should be the client account ID, not the manager ID

---

## Permission Errors

### Insufficient Permissions

**Symptoms:**
- Error: "AUTHORIZATION_ERROR"
- Error: "User doesn't have permission to access customer"
- Can list accounts but cannot access specific account

**Solutions:**

#### Solution 1: Grant Account Access

1. Log into Google Ads with admin access
2. Navigate to Tools & Settings → Setup → Access and security
3. Add the email associated with your OAuth credentials
4. Grant appropriate access level:
   - **Admin:** Full control (recommended for API access)
   - **Standard:** Can view and edit campaigns
   - **Read only:** Can only view data

#### Solution 2: Manager Account Access

If using a Manager Account (MCC):
1. Ensure the OAuth email has access to the manager account
2. Manager account must be linked to client accounts
3. Grant API access at the manager level
4. Use proper customer ID (client account, not manager account)

#### Solution 3: Developer Token Approval

For production accounts:
1. Developer token must be approved by Google
2. Unapproved tokens only work with test accounts
3. Apply for developer token approval:
   - Go to Google Ads → Tools & Settings → API Center
   - Click "Request basic access" or "Request standard access"
   - Complete the application form
   - Wait for Google approval (can take several days)

**Prevention:**
- Always request appropriate access upfront
- Document required permissions for different operations
- Test with test accounts before using production tokens
- Keep track of developer token approval status

---

## Data Availability Issues

### No Data Returned

**Symptoms:**
- Query succeeds but returns empty results
- No campaigns or ads shown
- Response is valid but contains no data

**Common Causes:**
1. Date range has no activity
2. Account has no active campaigns
3. GAQL query filters are too restrictive
4. Requesting data for deleted/removed resources

**Solutions:**

#### Solution 1: Verify Date Range

1. Check campaign start and end dates
2. Ensure date range overlaps with campaign activity
3. Try broader date range (e.g., `DURING LAST_30_DAYS`)
4. Use `ALL_TIME` date range to see all data

**Common Date Segments:**
```sql
-- Good for recent data
segments.date DURING LAST_7_DAYS

-- Good for broader view
segments.date DURING LAST_30_DAYS

-- For specific range
segments.date BETWEEN '2026-01-01' AND '2026-01-15'

-- All available data
segments.date DURING ALL_TIME
```

#### Solution 2: Check Campaign Status

1. Verify campaigns are not all REMOVED or PAUSED
2. Add status filter to GAQL query:
   ```sql
   WHERE campaign.status IN ('ENABLED', 'PAUSED')
   ```
3. Use `list_accounts` to verify account access
4. Check in Google Ads UI that campaigns exist

#### Solution 3: Simplify Query

1. Start with basic query to verify data exists
2. Remove all WHERE clauses
3. Remove complex breakdowns
4. Request minimal fields first
5. Add complexity incrementally

**Basic test query:**
```sql
SELECT campaign.id, campaign.name
FROM campaign
```

#### Solution 4: Verify Resource Names

1. Ensure you're querying the correct resource (`campaign`, `ad_group`, etc.)
2. Check that field names are valid for the resource
3. Review GAQL documentation for valid fields

### Missing Metrics

**Symptoms:**
- Some metrics return 0 or null
- Conversion data missing
- Expected fields not populated

**Solutions:**

#### Solution 1: Check Conversion Tracking Setup

1. Verify conversion actions are configured in Google Ads
2. Check that conversion tracking tags are installed
3. Confirm conversions are being recorded in UI
4. Allow time for conversion attribution (up to several days)

#### Solution 2: Verify Metrics Are Applicable

1. Some metrics only available at certain levels
2. Video metrics require video campaigns
3. Shopping metrics require Shopping campaigns
4. Check field compatibility in GAQL documentation

#### Solution 3: Attribution Windows

1. Conversions may not appear immediately
2. Default attribution window varies by conversion type
3. Recent data may be incomplete due to attribution delay
4. Use longer date ranges for conversion analysis

---

## GAQL Query Errors

### GAQL Syntax Errors

**Symptoms:**
- Error: "QUERY_ERROR"
- Error: "Invalid query"
- Query fails with syntax error message

**Common Issues & Solutions:**

#### Issue 1: Invalid Field Names

**Error:** "Field 'field_name' is not recognized"

**Solutions:**
- Check spelling of field names (case-sensitive)
- Verify field exists for the resource
- Use correct prefix (e.g., `campaign.name`, not just `name`)
- Review GAQL field reference: https://developers.google.com/google-ads/api/fields/v17/overview

**Example:**
```sql
-- Wrong
SELECT name, impressions FROM campaign

-- Correct
SELECT campaign.name, metrics.impressions FROM campaign
```

#### Issue 2: Missing Required Fields

**Error:** "Field 'field_name' is required when querying resource"

**Solution:**
- Include required fields in SELECT clause
- For segmentation queries, include `segments.date`
- Some resources require specific fields

**Example:**
```sql
-- Wrong
SELECT metrics.impressions FROM campaign

-- Correct
SELECT campaign.id, metrics.impressions FROM campaign
WHERE segments.date DURING LAST_7_DAYS
```

#### Issue 3: Invalid WHERE Clause

**Error:** "Invalid WHERE clause"

**Solutions:**
- Use correct operators: `=`, `!=`, `>`, `<`, `>=`, `<=`, `IN`, `NOT IN`, `LIKE`
- Use single quotes for string values
- Check field types (string vs. number vs. enum)
- Date segments must use `DURING` or `BETWEEN`

**Examples:**
```sql
-- Correct string comparison
WHERE campaign.status = 'ENABLED'

-- Correct IN clause
WHERE campaign.status IN ('ENABLED', 'PAUSED')

-- Correct numeric comparison
WHERE metrics.clicks > 100

-- Correct date range
WHERE segments.date DURING LAST_30_DAYS
```

#### Issue 4: Invalid Field Combinations

**Error:** "Field cannot be selected with the given set of fields"

**Solutions:**
- Some fields cannot be selected together
- Metrics and segments must align
- Check field compatibility in documentation
- Split into separate queries if needed

#### Issue 5: ORDER BY Errors

**Error:** "ORDER BY field must be in SELECT"

**Solutions:**
- Field in ORDER BY must appear in SELECT clause
- Use DESC for descending, ASC for ascending (default)

**Example:**
```sql
-- Wrong
SELECT campaign.name, metrics.clicks
FROM campaign
ORDER BY metrics.impressions DESC

-- Correct
SELECT campaign.name, metrics.clicks, metrics.impressions
FROM campaign
ORDER BY metrics.impressions DESC
```

### GAQL Best Practices

1. **Always include date segments for metrics:**
   ```sql
   WHERE segments.date DURING LAST_30_DAYS
   ```

2. **Use LIMIT to prevent large responses:**
   ```sql
   LIMIT 100
   ```

3. **Request only needed fields:**
   ```sql
   SELECT campaign.id, campaign.name, metrics.clicks
   -- Don't use SELECT * equivalent
   ```

4. **Test queries incrementally:**
   - Start simple
   - Add fields one at a time
   - Add WHERE clauses gradually
   - Verify each step works

5. **Use proper resource names:**
   - `campaign` (not `campaigns`)
   - `ad_group` (not `adgroup` or `ad_groups`)
   - `keyword_view` (for keyword data)
   - `search_term_view` (for search query data)

---

## API Error Types

### Common Error Types

#### AUTHENTICATION_ERROR
**Cause:** Invalid or expired credentials

**Solutions:**
- Regenerate OAuth refresh token
- Verify client ID and client secret
- Check developer token validity
- See [Authentication Problems](#authentication-problems) section

#### AUTHORIZATION_ERROR
**Cause:** Insufficient permissions

**Solutions:**
- Grant account access
- Upgrade developer token approval
- See [Permission Errors](#permission-errors) section

#### QUERY_ERROR
**Cause:** Invalid GAQL query

**Solutions:**
- Review query syntax
- Check field names and types
- See [GAQL Query Errors](#gaql-query-errors) section

#### INVALID_CUSTOMER_ID
**Cause:** Customer ID format incorrect or inaccessible

**Solutions:**
- Remove hyphens from customer ID (use 1234567890, not 123-456-7890)
- Verify account access
- Check that account exists

#### RATE_LIMIT_ERROR
**Cause:** Too many API requests

**Solutions:**
- Implement exponential backoff
- Reduce request frequency
- See [Performance & Rate Limiting](#performance--rate-limiting) section

#### RESOURCE_NOT_FOUND
**Cause:** Requested resource doesn't exist

**Solutions:**
- Verify campaign/ad group IDs are correct
- Check that resources haven't been removed
- Ensure customer ID is correct

---

## Performance & Rate Limiting

### Slow Query Performance

**Symptoms:**
- Queries take a long time to complete
- Timeouts
- Delayed responses

**Solutions:**

#### Solution 1: Reduce Data Volume

1. Use shorter date ranges (7-30 days instead of ALL_TIME)
2. Request fewer fields
3. Use LIMIT clause to restrict results
4. Avoid requesting all campaigns if only analyzing a few

**Example:**
```sql
-- Better performance
SELECT campaign.id, campaign.name, metrics.clicks
FROM campaign
WHERE segments.date DURING LAST_7_DAYS
LIMIT 100

-- Slower
SELECT campaign.id, campaign.name, metrics.clicks, metrics.impressions,
       metrics.cost_micros, metrics.conversions, metrics.ctr,
       metrics.average_cpc, campaign.status, campaign.start_date,
       campaign.end_date, campaign.advertising_channel_type
FROM campaign
WHERE segments.date DURING ALL_TIME
```

#### Solution 2: Avoid Complex Segmentation

1. Minimize use of segments (each adds processing time)
2. Use aggregated data when possible
3. Request segmented data only when necessary

#### Solution 3: Optimize Query Structure

1. Filter early with WHERE clauses
2. Request only required resources
3. Use specific campaigns/ad groups instead of account-wide queries

### Rate Limits

**Google Ads API Rate Limits:**
- **Basic access:** 15,000 operations per day
- **Standard access:** Much higher limits
- **Concurrent requests:** Limited per account

**Rate Limit Error:**
```
RATE_LIMIT_ERROR: Too many requests
```

**Solutions:**

#### Solution 1: Implement Exponential Backoff

When rate limit is hit:
1. Wait before retrying
2. Double wait time with each retry
3. Example: 1s, 2s, 4s, 8s, 16s, 32s
4. Give up after 5-6 retries

#### Solution 2: Reduce Request Frequency

1. Batch operations when possible
2. Cache results locally
3. Avoid repeated identical queries
4. Space out requests over time

#### Solution 3: Upgrade to Standard Access

For production use with higher volume:
1. Apply for Standard Access in API Center
2. Provide business information
3. Describe API use case
4. Wait for Google approval

**Prevention:**
- Monitor API quota usage in Google Cloud Console
- Implement client-side rate limiting
- Use webhooks or scheduled jobs instead of frequent polling
- Cache frequently accessed data

---

## Data Quality Issues

### Discrepancies Between Google Ads UI and API

**Symptoms:**
- Numbers don't match between Google Ads UI and API responses
- Metrics seem inconsistent
- Totals don't align

**Common Causes & Solutions:**

#### Cause 1: Different Attribution Settings

**Solution:**
- Google Ads UI may use different attribution model than default API
- Check attribution model in account settings
- Conversion counting may differ (all conversions vs. converted clicks)

#### Cause 2: Time Zone Differences

**Solution:**
- Google Ads UI uses account time zone
- API returns data in account time zone by default
- Ensure date ranges align with account time zone
- Daylight saving time can cause discrepancies

#### Cause 3: Data Freshness

**Solution:**
- UI may show more recent data than API
- API data can have a delay of a few hours
- Recent data (today, yesterday) may still be processing
- Comparing historical data (3+ days old) should match closely

#### Cause 4: Filtering Differences

**Solution:**
- UI applies default filters (hides removed campaigns)
- API returns all data unless explicitly filtered
- Match UI filters in GAQL queries:
  ```sql
  WHERE campaign.status != 'REMOVED'
  ```

#### Cause 5: Conversion Attribution Windows

**Solution:**
- Conversions may be attributed differently
- Default: conversions within attribution window
- UI may show "All conversions" vs. "Conversions"
- Use `metrics.all_conversions` vs. `metrics.conversions`

### Cost Micros Confusion

**Symptoms:**
- Cost values seem wrong (1000x too large)
- Calculations don't match expected amounts

**Solution:**

Google Ads API returns costs in **micros** (millionths of currency unit):
- `cost_micros: 1000000` = 1.00 USD/EUR/etc.
- To convert: `cost_micros / 1,000,000 = actual_cost`

**Example:**
```
cost_micros: 5670000
Actual cost: 5670000 / 1000000 = $5.67
```

When doing calculations, remember to convert:
```
ROAS = (conversion_value) / (cost_micros / 1000000)
CPC = (cost_micros / 1000000) / clicks
```

---

## Debugging Checklist

When encountering issues, work through this checklist:

- [ ] **MCP Connection**
  - [ ] MCP server is installed and configured
  - [ ] MCP server appears in available servers list
  - [ ] Claude Desktop has been restarted after config changes

- [ ] **Authentication**
  - [ ] Client ID and Client Secret are correct
  - [ ] Refresh token is valid
  - [ ] Developer token is valid and approved (for production)
  - [ ] All credentials are properly formatted (no extra spaces)

- [ ] **Permissions**
  - [ ] OAuth email has access to target customer account
  - [ ] Account access level is sufficient (Admin recommended)
  - [ ] Customer ID is correctly formatted (10 digits, no hyphens)

- [ ] **GAQL Query**
  - [ ] Field names are spelled correctly
  - [ ] Required fields are included
  - [ ] WHERE clauses use correct syntax
  - [ ] Date segments are specified for metrics
  - [ ] Resource name is correct

- [ ] **Data Availability**
  - [ ] Campaign/ad group was active during requested date range
  - [ ] Resources have not been removed
  - [ ] Conversion tracking is configured (if requesting conversion data)
  - [ ] Sufficient data exists for the query

- [ ] **Rate Limits**
  - [ ] Not exceeding API quota
  - [ ] Implementing retry logic with backoff
  - [ ] Caching results when appropriate

---

## Getting Additional Help

If you've worked through this troubleshooting guide and still have issues:

1. **Check Google Ads API Documentation**
   - https://developers.google.com/google-ads/api/docs/start
   - Review API changelog for recent changes
   - Check for known issues or deprecations

2. **Review GAQL Documentation**
   - https://developers.google.com/google-ads/api/docs/query/overview
   - GAQL field reference: https://developers.google.com/google-ads/api/fields/v17/overview
   - GAQL grammar: https://developers.google.com/google-ads/api/docs/query/grammar

3. **MCP Server Documentation**
   - GitHub repository: https://github.com/cohnen/mcp-google-ads
   - Review GitHub issues for similar problems
   - Check for MCP server updates

4. **Google Ads API Forum**
   - Google Ads API Forum: https://groups.google.com/g/adwords-api
   - Stack Overflow (tag: google-ads-api)
   - Google Ads API Slack community

5. **Enable Debug Logging**
   - Enable verbose logging in MCP server (if available)
   - Review Claude Desktop logs
   - Use Google Ads API logging features
   - Capture full error responses for analysis

---

## Common Patterns Summary

**"Cannot access customer"**
→ Check: Customer ID format (no hyphens), account access, OAuth permissions

**"No data returned"**
→ Check: Date range, campaign status, GAQL query filters

**"Query error"**
→ Check: Field names, required fields, WHERE clause syntax, date segments

**"Authentication error"**
→ Check: Refresh token, client credentials, developer token

**"Rate limit exceeded"**
→ Check: API quota usage, implement backoff, reduce request frequency

**"Cost values wrong"**
→ Check: Convert cost_micros to currency (divide by 1,000,000)

---

**Document Version:** 1.0
**Last Updated:** 2026-01-21
**MCP Server:** cohnen/mcp-google-ads
**Google Ads API Version:** v17
