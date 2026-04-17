# Google Search Console Skill - Troubleshooting Guide

This guide provides solutions to common issues encountered when using the Google Search Console skill with the Hopkin Google Search Console MCP.

## Table of Contents

1. [MCP Server Issues](#mcp-server-issues)
2. [Authentication Problems](#authentication-problems)
3. [Data Availability Issues](#data-availability-issues)
4. [Query and Parameter Errors](#query-and-parameter-errors)
5. [API Error Types](#api-error-types)
6. [Common Mistakes](#common-mistakes)

---

## MCP Server Issues

### MCP Server Not Found

**Symptoms:**
- No `google_search_console_` prefixed tools available
- Cannot execute Search Console operations

**Diagnosis:**
1. Check for `google_search_console_` prefixed tools in your available tools
2. If none are found, the Hopkin Google Search Console MCP is not configured

**Solution:** Follow the setup instructions in the Prerequisites section of SKILL.md. If already configured, verify the token is current and restart Claude.

---

## Authentication Problems

### Not Authenticated with Google Search Console

**Symptoms:**
- `google_search_console_check_auth_status` returns not authenticated
- Tools return authentication errors
- Cannot access site data

**Solution:** Direct the user to https://app.hopkin.ai to complete or redo the OAuth flow. If previously connected, the token may have expired.

### Missing Scopes

**Symptoms:**
- `google_search_console_check_auth_status` returns `needs_reconnect`
- Some tools work but others fail with permission errors

**Solution:** The user needs to reconnect their Google account at https://app.hopkin.ai to grant the required scopes (`mcp:tools`, `gsc:read`).

### Permission Errors on Specific Sites

**Symptoms:**
- Can authenticate but cannot access a specific property
- `list_sites` shows the property with `siteUnverifiedUser` permission level

**Solution:** The user needs to verify ownership or request access to the property in Google Search Console directly. Only `siteOwner`, `siteFullUser`, and `siteRestrictedUser` can query analytics data.

---

## Data Availability Issues

### No Data for Recent Dates

**Symptoms:**
- Analytics queries for the last 1-2 days return empty or very low numbers
- `firstIncompleteDate` is set in the response

**Causes & Solutions:**

1. **Normal data lag:** Search Console data has a 2-3 day lag. This is expected behavior. Use dates at least 3 days in the past for reliable data.
2. **Use the `compare_performance` tool:** It automatically applies a 3-day offset to avoid incomplete data.

### Empty Analytics Results

**Symptoms:**
- `get_search_analytics` returns zero rows
- No queries or pages appear

**Causes & Solutions:**

1. **No search traffic:** The site may not have received search traffic in the specified date range.
2. **Wrong site URL:** Verify the exact property URL (including protocol and trailing slash) with `google_search_console_list_sites`.
3. **Too narrow filters:** Relax dimension filters or remove them to see if data exists.
4. **Wrong search type:** Try `search_type: "web"` (default) before filtering by image, video, or news.

### Site Not Found in List

**Symptoms:**
- `google_search_console_list_sites` does not include the expected property

**Causes & Solutions:**

1. **Wrong Google account:** The user may have the property verified under a different Google account.
2. **Property not verified:** The property needs to be verified in Google Search Console.
3. **Cached results:** Try `refresh: true` to bypass the 15-minute cache.

---

## Query and Parameter Errors

### Invalid Dimension Combination

**Symptoms:**
- Error when using `searchAppearance` with other dimensions

**Solution:** The `searchAppearance` dimension cannot be combined with `query`, `page`, `device`, or `country`. It can only be combined with `date`. Run separate queries for search appearance data.

### Invalid Date Range

**Symptoms:**
- Error about date validation
- No results for expected date range

**Causes & Solutions:**

1. **start_date after end_date:** Ensure `start_date` is before or equal to `end_date`.
2. **Future dates:** Search Console does not have data for future dates.
3. **Date format:** Use YYYY-MM-DD format (e.g., `2026-04-15`).
4. **Range too long:** The API limits to 90 days per request for `get_search_analytics`.

### URL Inspection Quota Exceeded

**Symptoms:**
- `inspect_url` returns a quota error

**Solution:** URL inspection is limited to 2000 calls per day per property. Wait until the next day, or prioritize which URLs to inspect. Consider using `get_search_analytics` with `dimensions: ["page"]` for bulk page-level data instead.

---

## API Error Types

### Rate Limiting

**Symptoms:**
- 429 status code errors
- "Too many requests" messages

**Solutions:**
- Wait briefly and retry
- Reduce the frequency of tool calls
- Use caching (avoid `refresh: true` unless necessary)

### Invalid Parameters

**Symptoms:**
- 400 status code errors
- "Invalid" or "Bad Request" messages

**Solutions:**
- Verify all required parameters are provided
- Check that `site_url` matches exactly (from `list_sites`)
- Ensure dimension values are from the allowed set
- Verify date format is YYYY-MM-DD

### Server Errors

**Symptoms:**
- 500 status code errors
- Timeout errors

**Solutions:**
- Retry the request
- Check MCP server health with `google_search_console_ping`
- Try a simpler query (fewer dimensions, shorter date range)
- If persistent, report via `google_search_console_developer_feedback`

---

## Common Mistakes

### Using Wrong Site URL Format

- **URL prefix properties** require exact format: `https://example.com/` (with protocol and trailing slash)
- **Domain properties** use: `sc-domain:example.com`
- Always verify with `google_search_console_list_sites` to get the exact format

### Combining searchAppearance with Other Dimensions

The `searchAppearance` dimension is special — it cannot be combined with `query`, `page`, `device`, or `country`. Only combine it with `date`. Run separate queries for other dimension combinations.

### Expecting Real-Time Data

Search Console data is delayed by 2-3 days. Do not expect data from the last 48 hours to be complete. The `compare_performance` tool handles this automatically by offsetting the end date.

### Confusing Position Values

Position 1.0 is the best (top of search results). Higher numbers mean lower rankings. A position change from 8.0 to 4.0 is an **improvement** (moving up in results).

### Calling Auth Check Proactively

`google_search_console_check_auth_status` should only be called when another tool fails with an auth error. Do not call it proactively at the start of every session.

### Not Using Pagination for Large Result Sets

Default `row_limit` is 25. For comprehensive analysis, increase `row_limit` (up to 25,000) or paginate with `start_row`. Top queries analysis may miss important long-tail queries with the default limit.
