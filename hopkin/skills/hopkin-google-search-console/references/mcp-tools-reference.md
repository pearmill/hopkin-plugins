# Google Search Console MCP Tools Reference — Hopkin

Complete parameter reference for all Hopkin Google Search Console MCP tools. For setup and authentication, see **SKILL.md**.

---

## Core Tools

### Authentication Tools

#### google_search_console_ping
Health check. Verify the MCP server is reachable and returns version/timestamp.

**Parameters:**
- `message` (string, optional, max 100 chars) — Optional message to echo back

#### google_search_console_check_auth_status
Check whether the user has authenticated their Google Search Console account. Only call this when another tool returns a permission or authentication error — do not call proactively.

**Parameters:** None

**Response includes:**
- `authenticated` (boolean) — Whether the user is authenticated
- `user_id` — User identifier
- `email` — Authenticated email
- `needs_reconnect` — Present if scope is missing

---

### Site Tools

#### google_search_console_list_sites
List all Google Search Console properties the user has access to. Results are cached for 15 minutes.

**Parameters:**
- `refresh` (boolean, optional, default: false) — Force fresh fetch, bypass cache

**Response includes:**
- Array of properties with `siteUrl` and `permissionLevel` (siteOwner, siteFullUser, siteRestrictedUser, siteUnverifiedUser)

#### google_search_console_list_sitemaps
List sitemaps submitted to a Google Search Console property.

**Parameters:**
- `site_url` (string, required) — Search Console property URL (e.g., `https://example.com/` or `sc-domain:example.com`)
- `refresh` (boolean, optional, default: false) — Force fresh fetch, bypass cache

**Response includes:**
- List of submitted sitemaps with path, last submission date, pending/error status, and error/warning counts

---

### Analytics Tools

#### google_search_console_get_search_analytics
Query Google Search Console search analytics data with flexible dimensions. The most versatile analytics tool — use when you need custom dimension combinations, filters, or pagination.

**Parameters:**
- `site_url` (string, required) — Search Console property URL
- `start_date` (string, required) — Start date in YYYY-MM-DD format
- `end_date` (string, required) — End date in YYYY-MM-DD format (must be >= start_date)
- `dimensions` (array of strings, optional) — Group by dimensions. Valid: `query`, `page`, `device`, `country`, `date`, `searchAppearance`. **Note:** `searchAppearance` cannot be combined with query, page, device, or country — only with `date`
- `search_type` (string, optional, default: `web`) — Valid: `web`, `image`, `video`, `news`, `discover`, `googleNews`
- `dimension_filter_groups` (array, optional) — Filter by dimension values
- `aggregate_by` (string, optional, default: `auto`) — Valid: `auto`, `byPage`, `byProperty`, `byNewsShowcasePanel`
- `row_limit` (integer, optional, default: 25) — Range: 1-25000
- `start_row` (integer, optional, default: 0) — Zero-based row offset for pagination

**Response includes:**
- Array of rows with `{ keys, clicks, impressions, ctr, position }`
- `rowCount` — Total number of rows
- `responseAggregationType` — How results were aggregated
- `firstIncompleteDate` — First date with potentially incomplete data

#### google_search_console_get_top_queries
Get top queries with clicks, impressions, CTR, and position. Automatically identifies high-opportunity queries (position 4-20, impressions >100, CTR <5%).

**Parameters:**
- `site_url` (string, required) — Search Console property URL
- `days` (integer, optional, default: 28) — Range: 1-90
- `start_date` (string, optional) — Explicit start date (YYYY-MM-DD), overrides `days`
- `end_date` (string, optional) — Explicit end date (YYYY-MM-DD), overrides `days`
- `page_filter` (string, optional) — Filter to queries for a specific URL (exact match)
- `device` (string, optional) — Valid: `desktop`, `mobile`, `tablet`
- `search_type` (string, optional, default: `web`) — Valid: `web`, `image`, `video`, `news`
- `row_limit` (integer, optional, default: 25)
- `start_row` (integer, optional, default: 0)

**Response includes:**
- `queries` — Array of query rows with clicks, impressions, CTR, position
- `highOpportunityQueries` — Queries with position 4-20, impressions >100, CTR <5%
- `site_url` — The queried property
- `dateRange` — The date range used

#### google_search_console_compare_performance
Compare current vs previous period performance (period-over-period analysis). Periods are adjacent and non-overlapping.

**Parameters:**
- `site_url` (string, required) — Search Console property URL
- `days` (integer, optional, default: 28) — Length of each period in days. Range: 1-90
- `current_end_date` (string, optional) — End date of current period (YYYY-MM-DD). Default: today minus 3 days
- `search_type` (string, optional, default: `web`) — Valid: `web`, `image`, `video`, `news`

**Response includes:**
- `currentPeriod` — Metrics for current period (clicks, impressions, ctr, position)
- `previousPeriod` — Metrics for previous period
- `delta` — Change values: clicks, clicksPct, impressions, impressionsPct, ctr, position
- `trend` — Classification: `improving` (clicks up >10%), `declining` (clicks down >10%), or `stable`
- `topQueries` — Top queries for current period
- `previousTopQueries` — Top queries for previous period
- `errors` — Any partial errors from sub-queries

#### google_search_console_get_performance_overview
Get complete search performance overview: overall metrics, top queries, top pages, daily trend. Makes 4 parallel API calls internally. Partial results are returned when sub-queries fail.

**Parameters:**
- `site_url` (string, required) — Search Console property URL
- `days` (integer, optional, default: 28) — Range: 1-90
- `search_type` (string, optional, default: `web`) — Valid: `web`, `image`, `video`, `news`

**Response includes:**
- `overall` — Aggregate metrics: startDate, endDate, clicks, impressions, ctr, position
- `topQueries` — Top 10 queries by clicks
- `topPages` — Top 10 pages by clicks
- `byDate` — Daily breakdown of metrics
- `dateRange` — The date range used
- `errors` — Any partial errors from sub-queries

---

### URL Inspection Tools

#### google_search_console_inspect_url
Get detailed indexing and crawl status for a specific URL. Quota: 2000 calls per day per property.

**Parameters:**
- `inspection_url` (string, required) — Fully-qualified URL to inspect. Must be under the `site_url` property.
- `site_url` (string, required) — Search Console property URL containing the inspection URL
- `language_code` (string, optional) — IETF BCP-47 language code for translated issue messages (e.g., `en-US`)

**Response includes:**
- `verdict` — PASS, FAIL, or NEUTRAL
- Coverage state (indexed, excluded, etc.)
- Robots.txt state
- Indexing state
- Page fetch state
- Last crawl time
- Crawled as (mobile/desktop)
- Google canonical URL
- User canonical URL
- Sitemap references

---

### Preference Tools

#### google_search_console_store_preference
Store a persistent preference or observation about a Search Console property.

**Parameters:**
- `entity_type` (string, required) — Type of entity (e.g., `site`, `query`)
- `entity_id` (string, required) — Entity identifier (e.g., `https://example.com/`)
- `key` (string, required, max 100 chars) — Preference key
- `value` (any, required) — Preference value (string, number, boolean, or JSON object)
- `source` (string, optional, default: `agent`) — Who set this: `agent`, `user`, `system`
- `note` (string, optional, max 500 chars) — Context about why preference was set

#### google_search_console_get_preferences
Retrieve stored preferences for a Search Console entity.

**Parameters:**
- `entity_type` (string, required) — Type of entity
- `entity_id` (string, required) — Entity identifier

#### google_search_console_delete_preference
Delete a stored preference for a Search Console entity.

**Parameters:**
- `entity_type` (string, required) — Type of entity
- `entity_id` (string, required) — Entity identifier
- `key` (string, required) — Preference key to delete

---

### Developer Feedback

#### google_search_console_developer_feedback
Submit feedback about missing tools, improvements, bugs, or workflow gaps.

**Parameters:**
- `feedback_type` (string, required) — Category: `new_tool`, `improvement`, `bug`, `workflow_gap`
- `title` (string, required) — Concise title (5-200 chars)
- `description` (string, required) — What is needed and why (20-2000 chars)
- `current_workaround` (string, optional) — Current workaround if any (max 1000 chars)
- `priority` (string, optional, default: `medium`) — Impact: `low`, `medium`, `high`
- `interface` (string, optional, default: `MCP`) — Valid: `MCP`, `CLI`

---

## Pagination

Analytics tools support row-based pagination via `start_row` and `row_limit`. Increment `start_row` by `row_limit` to page through results. Continue until returned rows are fewer than `row_limit`.

## Caching

- `list_sites` and `list_sitemaps` results are cached for 15 minutes
- Use `refresh: true` to bypass cache when fresh data is needed

## Error Handling

See **troubleshooting.md** for detailed error solutions.
