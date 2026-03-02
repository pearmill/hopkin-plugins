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

### Example Table Structure

**Job Function Breakdown:**
```
LinkedIn Demographic Insights — Job Function
Ad Account: 123456789
Date Range: Last 30 Days

| Job Function  | Spend  | Impressions | Clicks | CTR  | Leads | CPA    | Index |
|---------------|--------|-------------|--------|------|-------|--------|-------|
| Marketing     | $2,100 | 89,450      | 2,340  | 2.6% | 42    | $50.00 | 100   |
| Technology    | $1,890 | 72,300      | 1,890  | 2.6% | 38    | $49.74 | 100   |
| Sales         | $1,450 | 65,200      | 1,120  | 1.7% | 18    | $80.56 | 62    |
| Operations    | $980   | 52,100      | 780    | 1.5% | 10    | $98.00 | 51    |
| Engineering   | $1,200 | 78,900      | 1,450  | 1.8% | 15    | $80.00 | 63    |
| Finance       | $890   | 48,300      | 910    | 1.9% | 22    | $40.45 | 124   |
```

**Seniority Level Breakdown:**
```
LinkedIn Demographic Insights — Seniority
Ad Account: 123456789
Date Range: Last 30 Days

| Seniority | Spend  | Clicks | CTR  | Leads | CPA    | Index |
|-----------|--------|--------|------|-------|--------|-------|
| Director  | $3,400 | 2,890  | 3.2% | 67    | $50.75 | 100   |
| VP        | $2,100 | 1,560  | 3.7% | 45    | $46.67 | 109   |
| CXO       | $1,200 | 890    | 3.4% | 28    | $42.86 | 118   |
| Manager   | $1,800 | 1,200  | 2.1% | 18    | $100   | 51    |
| Senior    | $1,100 | 650    | 1.4% | 8     | $137.5 | 37    |
```

## Providing Actionable Insights

### High-Performing Segments

Identify and amplify:
- Which job functions have the highest conversion rate and lowest CPA?
- Which seniority levels drive the most leads at best cost efficiency?
- Which industries are most receptive to the product/offer?

### Underperforming Segments

Flag for review or exclusion:
- Segments with index < 50 (more than 50% worse than average) — consider excluding from targeting
- Segments with very high spend but very low conversions — review creative relevance
- Segments with high impressions but very low CTR — ad copy may not resonate

### Targeting Optimization Recommendations

Based on the analysis:

1. **Increase bids for top-performing segments** — If Director-level is converting at 2x efficiency, consider increasing bids or budget for Director targeting
2. **Exclude low-performing segments** — Add exclusions for segments consistently showing poor performance
3. **Create segment-specific creative** — Develop tailored messaging for top-performing job functions or industries
4. **Adjust campaign targeting** — Narrow targeting to focus on validated high-value segments

## Example Insights Section

```
Key Insights — Job Function Analysis

High-Value Segments:
✓ Finance function: 124 index (24% more efficient than average) — $40 CPA vs $50 average
✓ Marketing function: 100 index — Largest volume driver, performing at par
✓ Technology function: 100 index — Strong volume with average efficiency

Underperforming Segments:
⚠ Operations function: 51 index (49% less efficient) — $98 CPA vs $50 average — consider excluding
⚠ Sales function: 62 index — Unexpectedly low conversion for a sales-oriented product

Targeting Recommendations:
→ Prioritize Finance and Marketing/Technology functions for budget allocation
→ Add Operations to exclusion list or reduce bids significantly
→ Test Finance-specific creative with messaging around ROI and cost savings
→ Review Sales messaging — may need to speak to different pain points for this function
```

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

## See Also

- **references/mcp-tools-reference.md** — Complete Hopkin MCP tools reference
- **references/workflows/campaign-performance.md** — Campaign-level performance workflow
- **references/troubleshooting.md** — Troubleshooting demographic data issues
