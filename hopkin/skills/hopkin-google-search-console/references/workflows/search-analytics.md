# Search Analytics Report

## When to Use

Use this workflow when you need flexible, custom search analytics queries — for example:

- Breaking down performance by specific dimensions (query + page, device + country, etc.)
- Filtering to specific queries, pages, or devices
- Analyzing non-web search types (image, video, news, discover)
- Paginating through large result sets
- Examining search appearance features (rich results, AMP, etc.)

For simpler "show me top queries" requests, prefer `google_search_console_get_top_queries` instead.

## Required Information

- **Site URL** — The Search Console property (e.g., `https://example.com/` or `sc-domain:example.com`)
- **Date Range** — Start and end dates in YYYY-MM-DD format
- **Dimensions** — What to group by (query, page, device, country, date, searchAppearance)

## Detailed Workflow

### Step 1: Verify Site Access

If the site URL is not confirmed, list available properties:

```json
{
  "tool": "google_search_console_list_sites"
}
```

### Step 2: Query Search Analytics

Call `google_search_console_get_search_analytics` with the appropriate parameters:

```json
{
  "tool": "google_search_console_get_search_analytics",
  "site_url": "https://example.com/",
  "start_date": "2026-03-15",
  "end_date": "2026-04-14",
  "dimensions": ["query", "page"],
  "search_type": "web",
  "row_limit": 50
}
```

### Step 3: Present Results

Format the data in a sorted table. Choose the sort column based on the user's intent:
- **Traffic analysis** — Sort by clicks descending
- **Visibility analysis** — Sort by impressions descending
- **Ranking analysis** — Sort by position ascending (best first)
- **Opportunity analysis** — Sort by impressions descending, highlight rows with low CTR

Example table format:

| Query | Page | Clicks | Impressions | CTR | Position |
|-------|------|--------|-------------|-----|----------|
| ... | ... | ... | ... | ...% | ... |

### Step 4: Analysis and Insights

Provide actionable insights based on the data:

- **Top performers** — Which queries/pages drive the most traffic
- **Rising queries** — Queries with high impressions but low clicks (optimization opportunities)
- **Device differences** — If device dimension is included, note mobile vs desktop variations
- **Country insights** — If country dimension is included, highlight geographic patterns

### Step 5: Pagination (if needed)

If the user needs more data, paginate:

```json
{
  "tool": "google_search_console_get_search_analytics",
  "site_url": "https://example.com/",
  "start_date": "2026-03-15",
  "end_date": "2026-04-14",
  "dimensions": ["query"],
  "row_limit": 50,
  "start_row": 50
}
```

## Common Analysis Patterns

### Query + Page Analysis
Dimensions: `["query", "page"]` — Reveals which pages rank for which queries. Useful for identifying keyword cannibalization (multiple pages ranking for the same query).

### Daily Trend Analysis
Dimensions: `["date"]` — Shows daily fluctuations. Useful for spotting algorithm updates, seasonal patterns, or the impact of content changes.

### Device Breakdown
Dimensions: `["device"]` — Compares desktop, mobile, and tablet performance. Important for mobile-first indexing analysis.

### Country Performance
Dimensions: `["country"]` — Geographic breakdown. Useful for international SEO strategy.

### Search Appearance
Dimensions: `["searchAppearance"]` or `["searchAppearance", "date"]` — Shows performance of rich results, AMP pages, and other SERP features. **Cannot** be combined with query, page, device, or country.

## Dimension Filter Examples

Filter to a specific page:
```json
{
  "dimension_filter_groups": [{
    "filters": [{
      "dimension": "page",
      "operator": "equals",
      "expression": "https://example.com/blog/post-1"
    }]
  }]
}
```

Filter to queries containing a keyword:
```json
{
  "dimension_filter_groups": [{
    "filters": [{
      "dimension": "query",
      "operator": "contains",
      "expression": "keyword"
    }]
  }]
}
```

## See Also

- **top-queries.md** — Simplified top queries with automatic opportunity detection
- **performance-comparison.md** — Period-over-period trend analysis
