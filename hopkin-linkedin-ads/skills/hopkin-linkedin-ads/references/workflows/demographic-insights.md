# Demographic Insights Report Workflow

## When to Use

Use this workflow to leverage LinkedIn's unique professional audience data. Analyze ad performance by job function, seniority, industry, company size, job title, geographic region, and age. This is LinkedIn's most powerful differentiator — professional demographic data unavailable on Meta or Google.

## Required Information

- **Ad Account ID** — Numeric (e.g., `123456789`)
- **Date range** — Preset or custom (minimum 14–30 days recommended for meaningful sample sizes)
- **Desired pivot dimension** — One MEMBER_* pivot per call

## LinkedIn's Unique MEMBER_* Pivots

These pivots are exclusive to `linkedin_ads_get_insights` and represent LinkedIn's core value proposition for B2B advertising:

| Pivot | What It Measures | B2B Use Case |
|---|---|---|
| `MEMBER_JOB_FUNCTION` | Job function (Marketing, Engineering, Sales, etc.) | Identify which functions respond best |
| `MEMBER_SENIORITY` | Seniority level (Director, Manager, Entry, etc.) | Optimize for decision-maker level |
| `MEMBER_INDUSTRY` | Industry vertical (Technology, Finance, Healthcare, etc.) | Find highest-ROI verticals |
| `MEMBER_COMPANY_SIZE` | Company headcount range (1-10, 11-50, etc.) | Target right company size segments |
| `MEMBER_JOB_TITLE` | Specific job title | Most granular targeting signal |
| `MEMBER_COMPANY` | Specific company | ABM performance analysis |
| `MEMBER_COUNTRY` | Country | Geographic performance |
| `MEMBER_REGION` | Region/state/province | Sub-country geographic detail |
| `MEMBER_AGE` | Age group | Demographic age analysis |

> **Important:** MEMBER_* pivots only work with `linkedin_ads_get_insights`. Do NOT use `linkedin_ads_get_performance_report` for demographic analysis.

## Detailed Workflow

### Step 1: Fetch Overall Performance as Baseline

Before analyzing demographics, establish baseline performance metrics:

```json
{
  "tool": "linkedin_ads_get_performance_report",
  "parameters": {
    "reason": "Establishing baseline account performance before demographic analysis",
    "account_id": 123456789,
    "pivots": ["ACCOUNT"],
    "date_preset": "LAST_30_DAYS"
  }
}
```

Note the overall CTR, CPA, and ROAS to use as index benchmarks.

### Step 2: Job Function Analysis

Identify which professional functions are most responsive:

```json
{
  "tool": "linkedin_ads_get_insights",
  "parameters": {
    "reason": "Analyzing ad performance by job function to identify high-value B2B segments",
    "account_id": 123456789,
    "pivot": "MEMBER_JOB_FUNCTION",
    "date_preset": "LAST_30_DAYS"
  }
}
```

### Step 3: Seniority Level Analysis

Understand which decision-making levels drive the most value:

```json
{
  "tool": "linkedin_ads_get_insights",
  "parameters": {
    "reason": "Identifying which seniority levels convert best to optimize targeting",
    "account_id": 123456789,
    "pivot": "MEMBER_SENIORITY",
    "date_preset": "LAST_30_DAYS"
  }
}
```

Common LinkedIn seniority levels:
- **Entry** — Individual contributors, just starting careers
- **Associate** — Junior-level professionals
- **Senior** — Mid-to-senior individual contributors
- **Manager** — People managers
- **Director** — Department/functional leads
- **VP** — Vice Presidents
- **CXO** — C-suite executives
- **Owner** — Business owners
- **Partner** — Partners (consulting, legal, etc.)

### Step 4: Industry Vertical Analysis

Find which industries offer the best ROI:

```json
{
  "tool": "linkedin_ads_get_insights",
  "parameters": {
    "reason": "Analyzing performance by industry to prioritize targeting",
    "account_id": 123456789,
    "pivot": "MEMBER_INDUSTRY",
    "date_preset": "LAST_30_DAYS"
  }
}
```

### Step 5: Company Size Analysis

Determine if SMB, mid-market, or enterprise targets perform differently:

```json
{
  "tool": "linkedin_ads_get_insights",
  "parameters": {
    "reason": "Analyzing performance by company size to identify ideal customer profile",
    "account_id": 123456789,
    "pivot": "MEMBER_COMPANY_SIZE",
    "date_preset": "LAST_30_DAYS"
  }
}
```

Common LinkedIn company size ranges:
- 1-10 employees
- 11-50 employees
- 51-200 employees
- 201-500 employees
- 501-1000 employees
- 1001-5000 employees
- 5001-10000 employees
- 10001+ employees

### Step 6: Filter to Specific Campaigns

For granular analysis, filter to a specific campaign:

```json
{
  "tool": "linkedin_ads_get_insights",
  "parameters": {
    "reason": "Job function breakdown for the Director+ targeting campaign",
    "account_id": 123456789,
    "pivot": "MEMBER_JOB_FUNCTION",
    "date_preset": "LAST_30_DAYS",
    "campaign_ids": ["111222333"]
  }
}
```

## Presenting Demographic Data

### Index Comparison

Calculate a performance index for each segment relative to the overall account:

```
Index = (Segment Metric / Overall Metric) × 100

Example:
Overall CPA: $50
Marketing Function CPA: $35
Marketing Function Index: (35/50) × 100 = 70 (30% more efficient)

Engineering Function CPA: $75
Engineering Function Index: (75/50) × 100 = 150 (50% less efficient)
```

### Table Structure

Present each pivot as a table with columns: Segment, Spend, Impressions, Clicks, CTR, Leads, CPA, Index. Sort by the primary metric (usually CPA or leads).

## Actionable Insights

- **High-performing segments** (index > 100) — Increase bids/budget, create segment-specific creative
- **Underperforming segments** (index < 50) — Consider excluding from targeting or reducing bids
- **High spend, low conversions** — Review creative relevance for that segment
- **High impressions, low CTR** — Ad copy may not resonate with that audience

## Privacy & Data Limitations

LinkedIn demographic data has some important caveats:

1. **Minimum thresholds:** LinkedIn suppresses data for very small audience segments to protect member privacy. If a row is missing, the segment had too few members.
2. **Self-reported data:** LinkedIn demographics rely on what members report in their profiles. Some profiles may be outdated or incomplete.
3. **Unknown/Other categories:** Some members may fall into "Other" categories if their profile data is ambiguous.
4. **Data sampling:** MEMBER_* demographic data uses profile data at the time of ad impression, which may not perfectly match actual audience targeting.

## Best Practices

1. **Run each MEMBER_* pivot separately** — Each call returns one pivot dimension; run multiple calls for a complete picture
2. **Use 30+ days of data** — Short windows may have insufficient data for meaningful segment conclusions
3. **Compare against baseline** — Always show segment performance vs. overall account average using an index
4. **Focus on top spenders** — Prioritize segments with meaningful spend ($200+) before drawing conclusions
5. **Combine with campaign context** — Filter to specific campaigns when a campaign has distinct targeting (e.g., if you have a campaign already targeting Directors, the seniority breakdown will be skewed)
6. **B2B attribution context** — LinkedIn campaigns often drive awareness and consideration; not all value shows up as immediate conversions

## Visualize Demographic Data

Render bar charts for each demographic dimension analyzed:

**Job Function:**
```json
{
  "tool": "linkedin_ads_render_chart",
  "parameters": {
    "reason": "Visualizing CPA by job function to identify high-value B2B segments",
    "chart": {
      "type": "bar",
      "data": [
        {"label": "Finance", "values": {"cpa": 40.45, "spend": 890}},
        {"label": "Marketing", "values": {"cpa": 50.00, "spend": 2100}},
        {"label": "Engineering", "values": {"cpa": 80.00, "spend": 1200}},
        {"label": "Operations", "values": {"cpa": 98.00, "spend": 980}}
      ],
      "metric": {"field": "cpa", "label": "CPA ($)"},
      "sort": "asc"
    }
  }
}
```

**Seniority:**
```json
{
  "tool": "linkedin_ads_render_chart",
  "parameters": {
    "reason": "Visualizing CPA by seniority level to optimize for decision-makers",
    "chart": {
      "type": "bar",
      "data": [
        {"label": "CXO", "values": {"cpa": 42.86, "leads": 28}},
        {"label": "VP", "values": {"cpa": 46.67, "leads": 45}},
        {"label": "Director", "values": {"cpa": 50.75, "leads": 67}},
        {"label": "Manager", "values": {"cpa": 100, "leads": 18}}
      ],
      "metric": {"field": "cpa", "label": "CPA ($)"},
      "sort": "asc"
    }
  }
}
```

Render a chart for each MEMBER_* pivot analyzed. Charts make demographic comparisons immediately visual and actionable.

## See Also

- **references/mcp-tools-reference.md** — Complete Hopkin MCP tools reference
- **references/workflows/campaign-performance.md** — Campaign-level performance workflow
- **references/troubleshooting.md** — Troubleshooting demographic data issues
