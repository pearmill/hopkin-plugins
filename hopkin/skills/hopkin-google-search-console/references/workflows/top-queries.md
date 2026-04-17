# Top Queries Report

## When to Use

Use this workflow when you need to:

- Identify the best-performing search queries for a site
- Find high-opportunity queries that could benefit from SEO optimization
- Analyze query performance for a specific page
- Compare query performance across devices
- Get a quick overview of what people search for to find the site

This is the recommended starting point for most SEO analysis tasks.

## Required Information

- **Site URL** — The Search Console property
- **Date Range** — Number of days (default: 28) or explicit start/end dates

## Detailed Workflow

### Step 1: Get Top Queries

Call `google_search_console_get_top_queries`:

```json
{
  "tool": "google_search_console_get_top_queries",
  "site_url": "https://example.com/",
  "days": 28,
  "row_limit": 50
}
```

### Step 2: Present Top Queries

Format the main queries in a table sorted by clicks:

| # | Query | Clicks | Impressions | CTR | Avg Position |
|---|-------|--------|-------------|-----|--------------|
| 1 | ... | ... | ... | ...% | ... |

Include totals and date range in the report metadata.

### Step 3: Highlight High-Opportunity Queries

The tool automatically identifies high-opportunity queries (position 4-20, impressions >100, CTR <5%). Present these prominently in a separate section:

**High-Opportunity Queries** — These queries already rank on page 1-2 but have room to improve:

| Query | Position | Impressions | CTR | Why It's an Opportunity |
|-------|----------|-------------|-----|------------------------|
| ... | 7.2 | 1,450 | 2.1% | Ranking page 1 but low CTR — improve title/meta description |

### Step 4: Actionable Recommendations

For each high-opportunity query, provide specific recommendations:

- **Position 4-10 (page 1, below fold):** Focus on improving content depth, internal linking, and page experience to move into top 3
- **Position 11-20 (page 2):** Significant content improvements needed — consider creating dedicated landing pages, improving topical authority
- **Low CTR with good position:** Title tag and meta description optimization — make them more compelling and relevant
- **High impressions, low clicks:** The query has volume but the listing isn't enticing — review SERP snippet

### Step 5: Page-Specific Analysis (if relevant)

If the user wants queries for a specific page:

```json
{
  "tool": "google_search_console_get_top_queries",
  "site_url": "https://example.com/",
  "page_filter": "https://example.com/blog/target-page",
  "days": 28
}
```

This reveals what queries drive traffic to a specific URL and helps optimize that page's content.

## Common Analysis Patterns

### Brand vs Non-Brand Queries
Separate brand queries (containing the company/product name) from non-brand queries to understand organic discovery vs brand search.

### Device-Specific Analysis
Run with `device: "mobile"` and `device: "desktop"` separately to identify mobile-specific ranking issues.

### Seasonal Comparison
Compare `days: 28` results across different months using explicit `start_date`/`end_date` to spot seasonal trends.

## Best Practices

- Start with `row_limit: 50` for a manageable overview, increase if needed
- Always highlight high-opportunity queries — these are the most actionable insights
- When presenting to non-technical users, focus on the recommendations rather than raw metrics
- Pair with `compare_performance` to add trend context

## See Also

- **search-analytics.md** — Custom dimension queries for deeper analysis
- **performance-comparison.md** — Period-over-period trend analysis
- **url-inspection.md** — Deep-dive into specific page indexing
