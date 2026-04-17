# Performance Comparison Report

## When to Use

Use this workflow when you need to:

- Compare search performance between two time periods
- Identify whether site traffic is improving, stable, or declining
- Measure the impact of SEO changes, content updates, or algorithm updates
- Provide period-over-period metrics for stakeholder reporting
- Detect significant shifts in query rankings or click patterns

## Required Information

- **Site URL** — The Search Console property
- **Period Length** — Number of days per period (default: 28, range: 1-90)
- **End Date** — Optional; defaults to today minus 3 days (to account for data lag)

## Detailed Workflow

### Step 1: Run Performance Comparison

Call `google_search_console_compare_performance`:

```json
{
  "tool": "google_search_console_compare_performance",
  "site_url": "https://example.com/",
  "days": 28,
  "search_type": "web"
}
```

This compares the current 28-day period against the previous 28-day period (non-overlapping, adjacent).

### Step 2: Present Overall Trend

Start with the high-level trend classification and overall metrics:

**Trend: Improving / Stable / Declining**

| Metric | Current Period | Previous Period | Change | Change % |
|--------|---------------|-----------------|--------|----------|
| Clicks | ... | ... | +/- ... | +/- ...% |
| Impressions | ... | ... | +/- ... | +/- ...% |
| CTR | ...% | ...% | +/- ... pp | — |
| Avg Position | ... | ... | +/- ... | — |

- Trend is "improving" when clicks are up >10%, "declining" when down >10%, "stable" otherwise
- Use green/positive indicators for improvements and red/negative for declines

### Step 3: Compare Top Queries

Present side-by-side query comparison:

**Queries gaining traction:**
- Queries that appear in current top queries but not previous (new rankings)
- Queries with significant click increases

**Queries losing traction:**
- Queries that appear in previous top queries but not current
- Queries with significant click decreases

### Step 4: Analysis and Insights

Provide context for the changes:

- **Traffic growth drivers** — What's contributing to click increases (new content, improved rankings, seasonal trends)
- **Traffic decline causes** — What might explain decreases (lost rankings, seasonal drops, algorithm changes)
- **CTR changes** — If CTR changed significantly, it may indicate SERP feature changes or title/description improvements
- **Position shifts** — Aggregate position changes suggest overall authority trends

### Step 5: Recommendations

Based on the comparison:

- **Improving:** Identify what's working and suggest doubling down on successful strategies
- **Declining:** Prioritize investigation — check for technical issues, content staleness, or competitive pressure
- **Stable:** Look for optimization opportunities in high-opportunity queries

## Common Analysis Patterns

### Week-over-Week
Use `days: 7` for short-term monitoring. Good for detecting immediate impact of changes.

### Month-over-Month
Use `days: 28` (default) for standard performance reviews. The most common comparison period.

### Quarter-over-Quarter
Use `days: 90` for strategic reviews. Smooths out weekly fluctuations.

### Custom End Date
Set `current_end_date` to a specific date to anchor the comparison:

```json
{
  "tool": "google_search_console_compare_performance",
  "site_url": "https://example.com/",
  "days": 14,
  "current_end_date": "2026-03-31"
}
```

This compares Mar 18-31 vs Mar 4-17.

## Best Practices

- The tool automatically offsets by 3 days to avoid incomplete data — trust this default
- Position changes of less than 0.5 are generally not significant
- CTR changes should be interpreted alongside position changes (higher position naturally increases CTR)
- For algorithm update impact, compare the 14 days before and after the update date using `current_end_date`
- Always pair with `get_top_queries` for the current period to provide actionable next steps

## See Also

- **top-queries.md** — Detailed query analysis for the current period
- **search-analytics.md** — Custom dimension queries for deeper investigation
