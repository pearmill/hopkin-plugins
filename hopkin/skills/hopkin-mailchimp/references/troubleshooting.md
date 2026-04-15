# Mailchimp Skill - Troubleshooting Guide

This guide provides solutions to common issues encountered when using the Mailchimp skill with the Hopkin Mailchimp MCP.

## Table of Contents

1. [MCP Server Issues](#mcp-server-issues)
2. [Authentication Problems](#authentication-problems)
3. [Data Availability Issues](#data-availability-issues)
4. [API Error Types](#api-error-types)
5. [Common Mistakes](#common-mistakes)

---

## MCP Server Issues

### MCP Server Not Found

**Symptoms:**
- No `mailchimp_` prefixed tools available
- Cannot execute Mailchimp operations

**Diagnosis:**
1. Check for `mailchimp_` prefixed tools in your available tools
2. If none are found, the Hopkin Mailchimp MCP is not configured

**Solution:** Follow the setup instructions in the Prerequisites section of SKILL.md. If already configured, verify the token is current and restart Claude.

---

## Authentication Problems

### Not Authenticated with Mailchimp

**Symptoms:**
- `mailchimp_check_auth_status` returns not authenticated
- Tools return authentication errors
- Cannot access account data

**Solution:** Direct the user to https://app.hopkin.ai to complete or redo the OAuth flow. If previously connected, the token may have expired.

### Permission Errors

**Symptoms:**
- Tools return permission or access denied errors
- Can authenticate but cannot access specific data

**Solution:** Verify the correct `account_id` is being used (call `mailchimp_list_accounts`). The account may have restricted API permissions, or may need re-authentication via https://app.hopkin.ai.

---

## Data Availability Issues

### No Campaign Report Data

**Symptoms:**
- `mailchimp_get_campaign_report` returns empty or error
- Report metrics are all zeros

**Causes & Solutions:**

1. **Campaign not sent:** Reports are only available for campaigns with "sent" status. Check campaign status with `mailchimp_get_campaign`.
2. **Recently sent:** Reports may take a few minutes to populate after a campaign is sent. Wait and retry.
3. **Wrong campaign ID:** Verify the campaign ID using `mailchimp_list_campaigns`.

### No Audience Data

**Symptoms:**
- `mailchimp_list_audiences` returns empty
- Audience insights show no data

**Causes & Solutions:**

1. **No audiences created:** The Mailchimp account may not have any audiences yet.
2. **Wrong account:** If multiple accounts connected, verify the correct `account_id`.
3. **New audience:** A newly created audience may not have enough data for insights.

### Empty Subscriber Lists

**Symptoms:**
- `mailchimp_list_subscribers` returns no results
- Search returns no matches

**Causes & Solutions:**

1. **Wrong audience ID:** Verify audience_id with `mailchimp_list_audiences`.
2. **Status filter too restrictive:** Try without status filter, or check different statuses.
3. **Search term mismatch:** Search uses the Mailchimp search endpoint — try partial email or name.

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
- Check that IDs (audience_id, campaign_id, etc.) are correct
- Ensure status filter values are from the allowed set

### Server Errors

**Symptoms:**
- 500 status code errors
- Timeout errors

**Solutions:**
- Retry the request
- Check MCP server health with `mailchimp_ping`
- If persistent, report via `mailchimp_developer_feedback`

---

## Common Mistakes

### Using Wrong IDs

- **Audience ID vs Campaign ID:** These are different identifiers. Use `mailchimp_list_audiences` for audience IDs and `mailchimp_list_campaigns` for campaign IDs.
- **Account ID:** Only required when multiple accounts are connected. Use `mailchimp_list_accounts` to find the correct one.

### Requesting Reports for Unsent Campaigns

Campaign reports (`mailchimp_get_campaign_report`) only work for campaigns that have been sent. Check the campaign status first with `mailchimp_list_campaigns` filtering by `status: ["sent"]`.

### Not Specifying Account ID with Multiple Accounts

When a user has multiple Mailchimp accounts connected, the `account_id` parameter becomes required. If you get an ambiguous account error, call `mailchimp_list_accounts` and ask the user which account to use.

### Calling Auth Check Proactively

`mailchimp_check_auth_status` should only be called when another tool fails with an auth error. Do not call it proactively at the start of every session.
