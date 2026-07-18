# Troubleshooting — Hopkin Google Analytics MCP

## MCP Connection Issues

### "MCP server not found" / no `ga4_` tools available

1. Verify the MCP is configured in Claude:
   ```json
   {
     "mcpServers": {
       "hopkin-google-analytics": {
         "type": "http",
         "url": "https://ga4.mcp.hopkin.ai/mcp"
       }
     }
   }
   ```
2. Restart Claude after configuration changes
3. Call `ga4_ping` to verify the server is reachable

## Authentication Issues

### "Not authenticated" errors

1. Call `ga4_check_auth_status` to confirm the auth state
2. Direct the user to https://app.hopkin.ai to sign in and connect their Google account
3. Retry the original tool call after the user confirms

### 403 "insufficient scope" errors

GA4 access requires the `https://www.googleapis.com/auth/analytics.readonly` Google scope. Users who connected Google **before** GA4 support was added to Hopkin do not have this scope on their stored token.

**Fix:** the user must reconnect Google at **https://app.hopkin.ai/settings** to re-consent with the Analytics scope. Tools return a targeted reconnect message when this happens — relay it to the user.

### Wrong Google account / missing properties

- Call `ga4_list_connections` to see which Google connections are available (owned and org-shared)
- Use `ga4_set_default_connection` to switch the default, or pass `connection_id` on individual calls to pin a specific connection

## Data Issues

### "Property not found" or permission denied on a property

1. Verify the property ID with `ga4_list_account_summaries`
2. If the property was added recently, pass `refresh: true` to bypass the cached account list
3. Confirm the connected Google account actually has access to that property in GA4

### "Invalid dimension or metric" errors

1. Dimension/metric names are case-sensitive **API names** (`sessionDefaultChannelGroup`, `keyEvents`), not UI labels
2. Call `ga4_get_metadata` with a `search` term to find the correct API name
3. Custom dimensions/metrics are property-specific — always verify them via metadata
4. Some dimension/metric combinations are incompatible in the GA4 Data API; simplify the request or split it into multiple reports

### Realtime report rejects a dimension/metric that works in standard reports

The realtime API supports a much smaller set of dimensions and metrics. Stick to realtime-compatible names like `eventName`, `unifiedScreenName`, `country`, `deviceCategory` (dimensions) and `activeUsers`, `eventCount`, `keyEvents` (metrics).

### "No data" for recent dates

- GA4 standard reports lag by up to 24-48 hours; today (and sometimes yesterday) will be incomplete
- For current activity, use `ga4_run_realtime_report` (last 30 minutes only)
- Check the property's time zone via `ga4_get_property_details` — date boundaries follow the property time zone

### Numbers don't match the GA4 UI

- Confirm the same date range and time zone
- The GA4 UI may apply thresholding on small segments or use sampled/estimated data in some views
- `totalUsers` vs `activeUsers`: the GA4 UI's headline "Users" metric is `activeUsers`
- "Conversions" in older reports = `keyEvents` in current GA4

## Rate Limits

The GA4 Data API enforces per-property token quotas. If reports start failing with quota errors, reduce report frequency, request fewer dimension combinations, and consolidate multiple small reports into fewer larger ones (e.g. use multiple `date_ranges` in a single call instead of separate calls per period).
