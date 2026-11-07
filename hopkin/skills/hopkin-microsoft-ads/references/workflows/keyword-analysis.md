# Keyword and Search Term Analysis

## Overview

Find the keywords that drive results, the ones held back by Quality Score, the search queries worth adding as keywords, and the queries to negate.

---

## Step 1: Scope

Confirm the account (`microsoft_ads_list_accounts`), the date range and whether to focus on specific campaigns. Search term data is thin over short windows; 30 days or more is a good default for negative keyword work.

---

## Step 2: Keyword Performance and Quality Score

```json
{
  "tool": "microsoft_ads_get_keyword_report",
  "parameters": {
    "account_id": "123456789",
    "date_preset": "LastFourWeeks",
    "aggregation": "Summary",
    "reason": "Keyword performance and Quality Score review"
  }
}
```

- `aggregation: "Summary"` returns one row per keyword instead of one per keyword per day, with far fewer pages
- The default page is 15 rows, sorted by impressions. Follow `nextCursor` (same parameters) for more; do not raise `limit` much, since large pages can exceed what the client accepts
- `include_quality_score` is on by default: `QualityScore` (1 to 10) and `ExpectedCtr`, `AdRelevance`, `LandingPageExperience` (AboveAverage, Average, BelowAverage)
- `goal_breakdown` is keyed by **ad group**, not keyword. Never present an ad group's goal split as a keyword's
- `microsoft_ads_list_keywords` does not carry Quality Score; use it for status, bids and editorial (policy) status

Read Quality Score components as the fix list:

| Component below average | Likely fix |
|---|---|
| ExpectedCtr | Ad copy, or a keyword too broad for its ads |
| AdRelevance | Ad group too broad; split it or rewrite ads around the keyword |
| LandingPageExperience | The landing page: relevance, speed, mobile |

---

## Step 3: Search Terms

```json
{
  "tool": "microsoft_ads_get_search_terms",
  "parameters": {
    "account_id": "123456789",
    "date_range": { "start": "2026-10-01", "end": "2026-10-31" },
    "reason": "Search terms for negative keyword and expansion review"
  }
}
```

- `date_range` is required for this tool
- Rows are sorted by impressions; `count` is the total. Follow `nextCursor` to cover every query when the question is about waste
- `conversions` is the bidding set; `include_all_conversions: true` adds every goal. There is no per-goal breakdown and no view-through count here

---

## Step 4: Existing Negatives

Before recommending a negative, check it is not already there:

- `microsoft_ads_list_negative_keywords` for negatives on campaigns and ad groups (`level`, `campaign_ids`)
- `microsoft_ads_list_negative_keyword_lists` for shared lists and the campaigns they apply to. A list cut short has `keywordsTruncated: true`; page through it with `list_id`

Microsoft negatives are Exact or Phrase.

---

## Step 5: Recommendations

- **Negative candidates:** queries with spend and no conversions over a meaningful number of clicks, or clearly irrelevant intent. Suggest the match type (Phrase for a recurring irrelevant word, Exact for one query)
- **Expansion candidates:** converting queries that are not yet keywords
- **Quality Score work:** high-spend keywords with a below-average component
- **Match type review:** compare performance by `bid_match_type` (`keyword_match_type` filter)

Present tables for each group with spend, clicks, conversions and cost per conversion in the account currency. Adding keywords or negatives happens in Microsoft Advertising; this MCP is read-only.
