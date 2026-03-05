# Search / Keyword & Audience Insights Report

## Overview

This guide explains how to generate a comprehensive keyword, search term, and audience insights report using the Hopkin Google Ads MCP. The report helps identify top-performing keywords, find new keyword opportunities, flag negative keyword candidates, and surface actionable audience insights.

---

## Step 1: Determine Which Account to Use

1. Use `google_ads_list_accounts` to retrieve all accessible Google Ads accounts:
   ```json
   {
     "tool": "google_ads_list_accounts",
     "parameters": {
       "reason": "Finding the correct Google Ads account for keyword analysis"
     }
   }
   ```

2. Match the user's request to account names or metadata.

3. **If one clearly relevant account exists:** Propose it to the user for confirmation.

4. **If multiple plausible accounts exist:** List them and ask which one to use.

---

## Step 2: Determine Which Conversion Metric to Use

Before calculating CPA or ROAS, identify the correct conversion action.

### Selection Logic

1. **If exactly one primary conversion action:** Use it for CPA and ROAS.
2. **If multiple primary conversion actions:** Prefer the most down-funnel one (Purchase > Lead > Add to Cart).
3. **If unclear:** Ask the user which conversion action to use.

---

## Step 3: Define Report Scope

Confirm or ask the user for:

### Date Range
- Examples: "last 7 days", "last 30 days", or specific dates

### Channel / Campaign Type
- Focus on **Search campaigns** for this report

### Brand vs Non-Brand
- Infer from campaign/keyword naming if the user wants this split

**Common naming patterns to identify Brand campaigns:**
- Full words: "Brand", "Branded", "Trademark", "TM"
- Abbreviations: "B" (when used as a prefix/suffix)
- The client's actual brand name

**Common naming patterns to identify Non-Brand campaigns:**
- Full words: "Non-Brand", "NonBrand", "Generic"
- Abbreviations: "NB" (e.g., "NB - Search", "NB_Exact")
- "Competitor", "Comp", "Conquest"

---

## Step 4: Gather Keyword Performance Data

Use `google_ads_get_keyword_performance` to get keyword-level data with quality scores and all key metrics:

```json
{
  "tool": "google_ads_get_keyword_performance",
  "parameters": {
    "reason": "Gathering keyword performance data for analysis",
    "customer_id": "1234567890",
    "campaign_id": "123456789",
    "order_by": "cost",
    "limit": 100
  }
}
```

**Filter by match type:**
```json
{
  "tool": "google_ads_get_keyword_performance",
  "parameters": {
    "reason": "Analyzing exact match keyword performance",
    "customer_id": "1234567890",
    "keyword_match_type": "EXACT",
    "order_by": "conversions",
    "limit": 50
  }
}
```

### Data Available Per Keyword
- Campaign and ad group
- Keyword text and match type
- Impressions, clicks, cost, CTR, CPC
- Conversions, conversion value
- Quality Score
- Search impression share

### Calculated Metrics
- **CPA** = cost / conversions (leave undefined if conversions = 0)
- **ROAS** = conversions_value / cost (only if both available and cost > 0)

---

## Step 5: Gather Search Term Data

Use `google_ads_get_search_terms_report` to see which actual queries triggered ads:

```json
{
  "tool": "google_ads_get_search_terms_report",
  "parameters": {
    "reason": "Analyzing search terms for keyword opportunities and negative candidates",
    "customer_id": "1234567890",
    "campaign_id": "123456789",
    "order_by": "cost",
    "limit": 100
  }
}
```

**Filter by status:**
```json
{
  "tool": "google_ads_get_search_terms_report",
  "parameters": {
    "reason": "Finding search terms not yet added as keywords",
    "customer_id": "1234567890",
    "search_term_status": "NONE",
    "order_by": "conversions",
    "limit": 50
  }
}
```

### Uses for Search Term Data
- Find high-value queries to add as exact/phrase keywords
- Find irrelevant or poor-performing queries for negative keywords

---

## Step 6: Gather Audience Performance Data

Use `google_ads_get_insights` with segments for audience-level data:

```json
{
  "tool": "google_ads_get_insights",
  "parameters": {
    "reason": "Analyzing audience performance for targeting optimization",
    "customer_id": "1234567890",
    "level": "CAMPAIGN",
    "date_preset": "LAST_30_DAYS",
    "segments": ["device"]
  }
}
```

---

## Step 7: Analyze and Summarize the Data

### 7.1 Keyword Performance Analysis

**Summarize overall performance and by key segments:**
- Brand vs non-brand
- Major campaign groups

**Produce two lists:**
1. **Top performing keywords** (good CPA/ROAS, meaningful volume)
2. **Underperforming keywords** (high spend, low/no conversions) with recommendations

### 7.2 Search Term Insights

**New keyword opportunities:**
- Queries with several conversions at or below overall non-brand CPA
- Queries showing strong intent for the product
- Recommend adding as exact or phrase match

**Negative keyword candidates:**
- Queries with meaningful spend but zero conversions
- Queries clearly irrelevant or outside the ICP
- Recommend blocking at campaign or account level

### 7.3 Audience Insights

**Compare each audience's CPA/ROAS to account average:**
- **Better than average:** Good candidates to lean into
- **Worse than average:** Candidates to de-emphasize or exclude

---

## Step 8: Produce the Final Report

### 8.1 Title and Context

**Title:**
> Search / Keyword & Audience Insights – [Client Name] – [Date Range]

**Context paragraph:**
- Which Google Ads account was used
- Date range
- Which conversion action was used for CPA/ROAS

### 8.2 Executive Summary (3-5 bullets)

Plain-language summary of key findings.

### 8.3 Keyword Performance Section

**Overall metrics table:**
| Metric | Brand | Non-Brand | Total |
|--------|-------|-----------|-------|
| Spend | $X | $X | $X |
| Conversions | X | X | X |
| CPA | $X | $X | $X |
| ROAS | X.Xx | X.Xx | X.Xx |

**Top performing keywords (5-15):**
| Keyword | Match Type | Spend | Conv | CPA | Notes |
|---------|------------|-------|------|-----|-------|
| [text] | Exact | $X | X | $X | [context] |

**Underperforming keywords:**
| Keyword | Spend | Conv | CPA | Recommendation |
|---------|-------|------|-----|----------------|
| [text] | $X | 0 | — | Pause or lower bid |

### 8.4 Search Term Insights Section

**New keyword opportunities:**
| Search Term | Conv | CPA | Recommendation |
|-------------|------|-----|----------------|
| [query] | X | $X | Add as exact match |

**Negative keyword suggestions:**
| Search Term | Spend | Conv | Reason to Block |
|-------------|-------|------|-----------------|
| [query] | $X | 0 | Irrelevant/outside ICP |

### 8.5 Audience Insights Section

**Audiences performing better than average:**
| Audience | Type | CPA | vs Avg | Recommendation |
|----------|------|-----|--------|----------------|
| [name] | Customer Match | $X | -25% | Increase emphasis |

### 8.6 Recommendations and Next Steps

Prioritized action list:

1. **Add exact match keywords** for high-performing search terms
2. **Add negative keywords** to cut wasted spend
3. **Adjust bids/budgets** for best-performing audience segments
4. **Re-run this report** after 2-4 weeks to measure impact

## Visualize Keyword Performance

Render a scatter chart plotting keywords by spend vs. conversions:

```json
{
  "tool": "google_ads_render_chart",
  "parameters": {
    "reason": "Plotting keywords by spend vs conversions to identify scaling opportunities",
    "chart": {
      "type": "scatter",
      "data": [
        {"label": "project management software", "values": {"spend": 2500, "conversions": 45, "impressions": 12000}},
        {"label": "task management tool", "values": {"spend": 1800, "conversions": 38, "impressions": 9500}},
        {"label": "team collaboration app", "values": {"spend": 950, "conversions": 12, "impressions": 15000}}
      ],
      "x": {"field": "spend", "label": "Spend ($)"},
      "y": {"field": "conversions", "label": "Conversions"},
      "size": {"field": "impressions", "label": "Impressions"}
    }
  }
}
```

Use bar charts for top keyword performance by CPA or ROAS.
