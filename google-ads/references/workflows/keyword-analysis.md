# Search / Keyword & Audience Insights Report

## Overview

This guide explains how to generate a comprehensive keyword, search term, and audience insights report using the Google Ads MCP. The report helps identify top-performing keywords, find new keyword opportunities, flag negative keyword candidates, and surface actionable audience insights.

---

## Step 1: Determine Which Account to Use

1. Use `list_accounts` to retrieve all accessible Google Ads accounts.

2. Match the user's request to account names, labels, or metadata. For example, if the user says "Evvy search insights", look for accounts containing "Evvy".

3. **If one clearly relevant account exists:**
   - Propose it to the user for confirmation:
     > "I found a Google Ads account named 'Evvy – Google Ads'. Should I use this account for the report?"

4. **If multiple plausible accounts exist:**
   - List them briefly and ask which one to use.

5. After confirmation, use that account for all subsequent queries.

---

## Step 2: Determine Which Conversion Metric to Use

Before calculating CPA or ROAS, identify the correct conversion action.

### Query Conversion Actions
```sql
SELECT
  conversion_action.id,
  conversion_action.name,
  conversion_action.category,
  conversion_action.type,
  conversion_action.status,
  conversion_action.primary_for_goal
FROM conversion_action
WHERE conversion_action.status = 'ENABLED'
```

### Selection Logic

1. **If exactly one primary conversion action:** Use it for CPA and ROAS.

2. **If multiple primary conversion actions:** Prefer the most down-funnel one based on name:
   - Prefer: "Purchase", "Checkout Complete", "Sale"
   - Over: "Lead", "Sign up", "Add to cart"
   - If ambiguous, ask the user.

3. **If no primary conversions are set:** Ask the user, listing available conversion actions:
   > "This account has these conversion actions: Lead, Demo Booked, Add to Cart. Which should I use to calculate CPA and ROAS?"

4. Once chosen, use that conversion's `conversions` and `conversions_value` for all CPA/ROAS calculations.

---

## Step 3: Define Report Scope

Confirm or ask the user for:

### Date Range
- Examples: "last 7 days", "last 30 days", or specific dates
- Optional: comparison period (e.g., previous 7 or 30 days)

### Channel / Campaign Type
- Focus on **Search campaigns** for this report
- Optionally include PMax and Demand Gen in the audience section

### Brand vs Non-Brand
- Infer from campaign/keyword naming if the user wants this split
- If not requested, you may still detect it but don't need to present it

**Common naming patterns to identify Brand campaigns:**
- Full words: "Brand", "Branded", "Trademark", "TM"
- Abbreviations: "B" (when used as a prefix/suffix, e.g., "B - Search", "Search - B")
- The client's actual brand name or product names in the campaign name
- Misspellings of the brand name (often grouped with brand)

**Common naming patterns to identify Non-Brand campaigns:**
- Full words: "Non-Brand", "NonBrand", "Non Brand", "Nonbranded", "Generic"
- Abbreviations: "NB" (very common, e.g., "NB - Search", "Search NB", "NB_Exact")
- "Competitor", "Comp", "Conquest" (competitor campaigns are typically non-brand)
- Category or feature-based names without brand terms (e.g., "Vitamins - Exact", "Software Solutions")

**Additional campaign type indicators:**
- "Core" often indicates core non-brand campaigns
- "Competitor" or "Comp" indicates competitor-targeting campaigns
- "DSA" (Dynamic Search Ads) may be brand or non-brand depending on targeting
- "RLSA" may apply to both brand and non-brand

**When classification is ambiguous:**
- Check the keywords within the campaign for brand terms
- Ask the user for clarification if needed
- Default to grouping by campaign name patterns when unsure

Ask a short clarifying question if any scope info is missing, then proceed.

---

## Step 4: Gather Keyword Performance Data

Query keyword-level performance from Search campaigns.

### Keyword Performance Query
```sql
SELECT
  customer.id,
  campaign.id,
  campaign.name,
  ad_group.id,
  ad_group.name,
  ad_group_criterion.keyword.text,
  ad_group_criterion.keyword.match_type,
  ad_group_criterion.quality_info.quality_score,
  metrics.impressions,
  metrics.clicks,
  metrics.cost_micros,
  metrics.ctr,
  metrics.average_cpc,
  metrics.conversions,
  metrics.conversions_value,
  metrics.search_impression_share,
  metrics.search_budget_lost_impression_share,
  metrics.search_rank_lost_impression_share
FROM keyword_view
WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
  AND campaign.advertising_channel_type = 'SEARCH'
  AND ad_group_criterion.status = 'ENABLED'
ORDER BY metrics.cost_micros DESC
```

### Data to Collect Per Keyword
- Account/customer ID
- Campaign name and ID
- Ad group name and ID
- Keyword text
- Match type (exact, phrase, broad)
- Brand vs non-brand indicator (if tracking)
- Impressions, clicks, cost, CTR, average CPC
- Conversions (for chosen action)
- Conversion rate
- Conversion value (if available)
- Search impression share
- Lost impression share (rank and budget)
- Quality Score (if exposed)

### Calculated Metrics
- **CPA** = cost / conversions (leave undefined if conversions = 0)
- **ROAS** = conversions_value / cost (only if both available and cost > 0)

If a comparison period is included, run the same query for that range and calculate period-over-period changes.

---

## Step 5: Gather Search Term Data

Query search term performance for the same date range and Search campaigns.

### Search Terms Query
```sql
SELECT
  search_term_view.search_term,
  search_term_view.status,
  campaign.id,
  campaign.name,
  ad_group.id,
  ad_group.name,
  segments.keyword.info.text,
  segments.keyword.info.match_type,
  metrics.impressions,
  metrics.clicks,
  metrics.cost_micros,
  metrics.ctr,
  metrics.conversions,
  metrics.conversions_value
FROM search_term_view
WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
  AND campaign.advertising_channel_type = 'SEARCH'
ORDER BY metrics.cost_micros DESC
LIMIT 500
```

### Data to Collect Per Search Term
- Search term text
- Campaign and ad group (name and ID)
- Matched keyword and its match type (if available)
- Impressions, clicks, cost
- Conversions (for chosen action)
- Conversion rate
- Conversion value (if available)

Calculate CPA and ROAS using the same conversion definition.

### Uses for Search Term Data
- Find high-value queries to add as exact/phrase keywords
- Find irrelevant or poor-performing queries for negative keywords

---

## Step 6: Gather Audience Performance Data

Query audience segment performance for Search campaigns (optionally also PMax and Demand Gen).

### Audience Performance Query
```sql
SELECT
  campaign.id,
  campaign.name,
  ad_group.id,
  ad_group.name,
  ad_group_criterion.audience.audience_segment,
  ad_group_criterion.type,
  ad_group_criterion.bid_modifier,
  metrics.impressions,
  metrics.clicks,
  metrics.cost_micros,
  metrics.ctr,
  metrics.conversions,
  metrics.conversions_value
FROM ad_group_audience_view
WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
ORDER BY metrics.cost_micros DESC
```

### Data to Collect Per Audience
- Campaign and ad group (name and ID)
- Audience segment name (Customer Match list, in-market segment, etc.)
- Audience type (Customer Match, remarketing, in-market, affinity, custom)
- Observation vs targeting-only (if available)
- Impressions, clicks, cost
- Conversions (for main action)
- Conversion rate
- Conversion value (if available)

Calculate CPA and ROAS, then compare to account averages to identify outperformers and underperformers.

---

## Step 7: Analyze and Summarize the Data

### 7.1 Keyword Performance Analysis

**Summarize overall performance and by key segments:**
- Brand vs non-brand
- Major campaign groups (core non-brand, competitor, feature-based)

**Identify:**
- Keywords with sufficient conversions and good CPA/ROAS relative to target
- Keywords with substantial spend but few/no conversions or poor CPA

**Produce two lists:**
1. **Top performing keywords** (good CPA/ROAS, meaningful volume)
2. **Underperforming keywords** (high spend, low/no conversions) with recommendations (lower bid, restructure, pause)

### 7.2 Search Term Insights

**New keyword opportunities:**
- Queries with several conversions at or below overall non-brand CPA
- Queries showing strong intent for the product or ICP
- Recommend adding as exact or phrase match

**Negative keyword candidates:**
- Queries with meaningful spend but zero conversions
- Queries clearly irrelevant or outside the ICP
- Recommend blocking at campaign or account level

### 7.3 Audience Insights

**Compare each audience's CPA/ROAS to account average:**

- **Better than average:** Good candidates to lean into (higher bids, more coverage, tailored creative)
- **Worse than average:** Candidates to de-emphasize or exclude

**Note patterns such as:**
- Customer Match lists performing exceptionally well
- Broad affinity audiences not contributing
- Specific in-market segments strong for certain campaigns

---

## Step 8: Produce the Final Report

Format the report for a human reader (client or account owner). Should be easy to paste into Notion or similar tools.

### 8.1 Title and Context

**Title:**
> Search / Keyword & Audience Insights – [Client Name] – [Date Range]

**Context paragraph:**
- Which Google Ads account was used
- Date range (and comparison period if any)
- Which conversion action was used for CPA/ROAS

### 8.2 Executive Summary (3-5 bullets)

Plain-language summary of key findings. Example:

> - Non-brand search drove most conversions at a CPA slightly better than target; performance concentrated in a small set of high-intent keywords.
> - Several generic or off-target queries are consuming budget with no conversions and should be added as negative keywords.
> - Customer Match and in-market audiences for "[industry] software" show significantly better CPA than account average and should be prioritized.

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

**Audiences performing worse than average:**
| Audience | Type | CPA | vs Avg | Recommendation |
|----------|------|-----|--------|----------------|
| [name] | Affinity | $X | +40% | Reduce or exclude |

### 8.6 Recommendations and Next Steps

Prioritized action list for direct execution in Google Ads:

1. **Add exact match keywords** for [list of queries] and allocate more budget.
2. **Add negative keywords** for [list] at campaign or account level to cut wasted spend.
3. **Increase bids/budgets** for best-performing audience segments; reduce or remove low performers.
4. **Re-run this report** after 2-4 weeks to measure impact on CPA and ROAS.

---

## Key Calculations Reference

| Metric | Formula |
|--------|---------|
| Cost | `cost_micros / 1,000,000` |
| CPA | `cost / conversions` (undefined if conv = 0) |
| ROAS | `conversions_value / cost` (if both > 0) |
| CTR | Returned as decimal; multiply by 100 for % |
| Avg CPC | `average_cpc / 1,000,000` |
