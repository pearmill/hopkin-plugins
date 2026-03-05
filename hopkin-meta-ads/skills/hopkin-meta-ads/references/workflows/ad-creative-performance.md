# Ad Creative Performance Report Workflow

## When to Use

Use this workflow to build comprehensive creative testing reports for Meta Ads campaigns. This workflow is designed for analyzing creative rounds/tests, identifying winning and losing concepts, and generating actionable insights for creative strategy.

This workflow is particularly useful when:
- Conducting creative A/B tests or creative rounds
- Evaluating performance of new creative concepts
- Identifying creative fatigue and refresh opportunities
- Building client-facing creative test reports
- Making data-driven decisions about creative scaling and iteration

## Primary Tools

- `meta_ads_get_ad_creative_report` — **Recommended for creative analysis.** Ad-level performance report with full funnel metrics plus creative asset info (asset_type, asset_url, thumbnail_url). Use `level: "ad_name"` (default) to aggregate ads by name across ad sets — returns a representative `ad_id` per creative that can be passed directly to `meta_ads_preview_ads`. Use `level: "ad_id"` to compare distinct individual ads.
- `meta_ads_preview_ads` — **Crown jewel of creative reporting.** An MCP App that renders a visual UI showing actual ad images/videos with a configurable metrics overlay — not tabular data. This is the definitive way to review creative quality. Proactively offer it whenever the user asks "what do my ads look like", wants to review creative quality, is doing A/B creative comparison, or when presenting winners/losers. The `ad_id` values from `meta_ads_get_ad_creative_report` can be passed directly — no need to call `meta_ads_list_ads` first.
- `meta_ads_get_insights` with `level: "ad"` — For custom fields or breakdowns not available in the creative report
- `meta_ads_list_ads` — Use only if you need to look up specific ad IDs before running `meta_ads_get_ad_creative_report` with `level: "ad_id"` filtering

## Required Information

Before starting this workflow, gather:

- **Ad Account ID** — format: act_XXXXXXXXXXXXX
- **Creative Round/Test Scope** — Which campaigns/ad sets are included in this test
- **Date Range** — Test start and end dates
- **Primary Success Metric** — Main metric to evaluate creative (CPA, ROAS, CPL, etc.)
- **Secondary Metrics** (optional) — Supporting metrics (CTR, CVR, CPC, etc.)
- **Benchmark** — Reference point for comparison (previous round, evergreen average, target)
- **Output Format** — Desired report format (Slides/PowerPoint, PDF, Excel, or combination)
  - If not specified by user, ask explicitly before building the report

## Detailed Workflow

### 1. Clarify Scope and Success Metric

Gather and confirm before pulling data:

1. **Identify test campaigns/ad sets** — Filter for patterns like "Creative Test", "CR1", "Round 3". Check project management tools for scope. If ambiguous, ask the user.
2. **Confirm date range** — Start: when meaningful spend began. End: when the test was called or a clean cut-off. Confirm with user if uncertain.
3. **Confirm primary success metric** — E-commerce: Purchases/CPA/ROAS. B2B/Lead Gen: CPL/HQL. Early-funnel: Landing page views/leads. Check Tracking Glossary and past reports. Ask if unclear.
4. **Confirm secondary metrics** — CTR, CPC, CVR, thumb-stop rate, 3-second views, etc.
5. **Confirm source of truth** — Meta only, backend only (Funnel/CRM), or both? Which takes precedence?
6. **Confirm output format** — Slides, PDF, Excel, or combination. Ask explicitly if not specified.
7. **Document scope** — Client, channel, round name, campaigns/ad sets, date range, primary metric + source, secondary metrics, output format.

### 2. Pull Creative-Level Data

**Objective:** Export and consolidate all performance data for analysis.

**Steps:**

1. **Export ad-level data using Hopkin MCP tools:**
   - Use `meta_ads_get_ad_creative_report` for comprehensive ad-level metrics with creative asset info:
     ```json
     {
       "tool": "meta_ads_get_ad_creative_report",
       "parameters": {
         "reason": "Getting creative performance data for creative test analysis",
         "account_id": "act_123456789",
         "level": "ad_name",
         "time_range": {"since": "2026-01-01", "until": "2026-01-31"}
       }
     }
     ```
   - Use `level: "ad_name"` (default) to aggregate ads sharing the same name across ad sets — the response includes a representative `ad_id` per creative for use with `meta_ads_preview_ads`
   - Use `level: "ad_id"` if you need one row per individual ad
   - Use `meta_ads_get_insights` only for custom fields or breakdowns not available in the creative report
   - The response includes these fields automatically:
     - **Ad Details:** ad_id, ad_name, ad_count (ad_name mode only)
     - **Creative Asset:** asset_type (image/video/unknown), asset_url (GCS URL), thumbnail_url (GCS URL, videos only)
     - **Engagement:** impressions, reach, clicks, ctr, cpc, cpm
     - **Spend:** spend
     - **All conversion types** individually with counts, costs, and values
     - **Secondary Events:** All action types with counts and values

2. **Pull additional creative metadata from Motion or BI (if available):**
   - Creative tags (concept names, hook types, angles, offers)
   - Mapping to Meta ad IDs/names
   - Creative preview URLs or thumbnails

3. **Combine into a single working table:**
   - One row per ad
   - Columns should include:
     - Campaign
     - Ad set
     - Ad name and/or creative ID
     - Format (UGC, static, carousel, video, etc.)
     - Optional: Concept/Angle, Hook tag, Offer tag
     - All performance metrics (impressions, reach, spend, clicks, CTR, CPC, primary conversions, CPA/CPL, secondary metrics)

4. **Sanity-check the data:**
   - Do campaign totals from your table match Meta/Funnel totals for this window?
   - Are all expected ads present?
   - Are there outliers that look like data errors (negative costs, 0 impressions but conversions)?

### 2.1. Download Creative Assets

**Always include visual examples of creatives in reports.** Stakeholders need to see what performed well/poorly.

1. **Use `meta_ads_preview_ads`** to render visual ad previews with metrics overlay. Pass `ad_id` values from `meta_ads_get_ad_creative_report` directly:
   ```json
   {
     "tool": "meta_ads_preview_ads",
     "parameters": {
       "reason": "Rendering creative visual preview with performance metrics",
       "account_id": "act_123456789",
       "ads": [
         {"ad_id": "23842453456789", "metrics": {"spend": "450.00", "cpa": "$12.50", "ctr": "3.2%"}},
         {"ad_id": "23842453456790", "metrics": {"spend": "380.00", "cpa": "$45.00", "ctr": "1.1%"}}
       ],
       "metric_labels": {"spend": "Spend", "cpa": "CPA", "ctr": "CTR"}
     }
   }
   ```

2. **Download assets** for all winners, top 2-3 losers, and notable creatives. For large rounds (>20 ads), prioritize top/bottom performers. Always download locally — Meta URLs expire.

3. **Special cases:** For carousel ads, download all cards. For video ads, get thumbnail via `thumbnail_url`. For UGC, verify rights before including in client reports.

### 3. Group Performance by Concept/Angle

**Objective:** Roll up ad-level data into creative concepts for clearer insights.

**Steps:**

1. **Create a "Concept" column:**
   - Tag each ad with a clear, human-readable concept/angle
   - Examples:
     - "3 Signs" listicle
     - "Sandbox advertorial"
     - "Freeze-Dried product intro"
     - "AI Intern value prop"
     - "50% Off Sale - UGC"

2. **Group and summarize by concept:**
   - For each concept, calculate:
     - Total spend
     - Total impressions
     - Total primary conversions
     - CPA/CPL on the primary metric
     - CTR, CVR where useful

3. **Keep both levels of detail:**
   - **Concept-level table:** For client-facing storytelling and high-level insights
   - **Ad-level table:** As a detailed appendix or internal reference sheet

### 3a. Visualize Creative Performance

Render a bar chart comparing creatives by CPA or CTR:

```json
{
  "tool": "meta_ads_render_chart",
  "parameters": {
    "reason": "Comparing creative concepts by CPA to identify top performers",
    "chart": {
      "type": "bar",
      "data": [
        {"label": "Social Proof Video", "values": {"cpa": 32.50, "spend": 2100}},
        {"label": "Product Demo", "values": {"cpa": 45.00, "spend": 1800}},
        {"label": "Testimonial Carousel", "values": {"cpa": 28.90, "spend": 1500}}
      ],
      "metric": {"field": "cpa", "label": "CPA ($)"},
      "colorBy": {"field": "spend", "label": "Spend ($)"},
      "sort": "asc"
    }
  }
}
```

For creative fatigue analysis, use a timeseries chart plotting CTR over time per creative.

### 4. Define Benchmarks and Winner Criteria

**Objective:** Establish clear, metric-aligned rules for labeling winners and losers.

**Steps:**

1. **Confirm or set the benchmark:**
   - Ask: "What should we use as the benchmark for [primary metric] in this round?"
   - Options to propose:
     - Last 30-day evergreen CPA/CPL on Meta
     - Client's target CPA/ROAS
     - Median/average CPA/CPL of all ads in this round

2. **Define volume thresholds:**
   - Set minimum conversions needed per ad/concept to call it:
     - **Winner:** e.g., ≥ 20 primary conversions
     - **Loser:** e.g., ≥ 10 primary conversions but worse than benchmark
     - **Inconclusive:** e.g., < 10 conversions
   - Adjust thresholds based on test size and conversion volume

3. **Define clear winner/loser rules:**
   - Example framework:
     - **Winner:**
       - ≥ 20 conversions on primary metric
       - CPA/CPL at least 20-30% better than benchmark
     - **Loser:**
       - ≥ 10 conversions
       - CPA/CPL significantly worse than benchmark (e.g., 30-50% higher)
     - **Inconclusive:**
       - Below minimum conversions
       - Or conflicting metrics (e.g., amazing CTR but no conversions yet)

4. **Document these rules in the report:**
   - Include a "Methodology" section showing how you defined winners/losers
   - This demonstrates rigor and prevents hand-waving

### 5. Label Winners, Losers, and Notable Creatives

**Objective:** Apply criteria to identify top and bottom performers.

**Steps:**

1. **Apply criteria to each ad/concept:**
   - Add a "Status" column with values:
     - "Winner"
     - "Loser"
     - "Inconclusive / Needs more data"

2. **Create summary lists:**

   **Winners list:**
   - Concept/ad name
   - Spend
   - Conversions on primary metric
   - CPA/CPL vs benchmark (e.g., "30% better than benchmark")

   **Losers list:**
   - Same fields
   - Note why it underperformed (high CPA, low CTR, poor CVR, etc.)

   **Notable / Promising but Under-spent:**
   - Concepts with good CPA or strong leading indicators (CTR, early CVR) but low spend or volume
   - These may warrant further testing

### 6. Analyze Why Winners Won and Losers Lost

**Objective:** Extract creative insights by reviewing the actual assets.

**Steps:**

1. **Review actual creative assets:**
   - For each key winner and loser, open the actual:
     - Video / static image / carousel
     - Primary text and headlines
     - Thumbnails and first 1-3 seconds of video
   - Use Motion or Meta Ads Manager creative preview

2. **Note patterns for winners:**

   **Hooks:**
   - How do they start?
   - Are they using numbers, questions, bold claims, social proof, etc.?

   **Angle:**
   - Problem/solution, testimonial, authority, urgency, educational, comparison, etc.

   **Visual style:**
   - UGC vs polished
   - Product-in-hand vs lifestyle
   - Text overlays and placement

   **Structure:**
   - Length and pacing
   - Where the CTA appears
   - Storytelling flow

3. **Note patterns for losers:**

   **Common failure points:**
   - Weak or slow hook (drop-off early in video)
   - Overly dense text or unclear message
   - Misaligned angle with audience (e.g., heavy discount messaging when brand wants premium positioning)
   - Bad creative-to-landing page promise match
   - Boring or low-quality visuals

4. **Write specific insight bullets:**
   - For each winner:
     - "Leading with a 3-item 'signs you need X' hook more than doubled CTR vs round average and delivered ~30% lower CPA."
   - For each meaningful loser:
     - "Price-first openers and heavy discount overlays had the lowest CTR and highest CPA, despite similar spend."

### 7. Turn Insights into Concrete Account Actions

**Objective:** Translate analysis into actionable next steps.

**Steps:**

1. **Immediate actions in Meta:**

   **For winners:**
   - Graduate to evergreen campaign(s)
   - Specify which campaign/ad set they move to
   - Define initial budget share or bid strategy

   **For losers:**
   - Pause or throttle spend
   - Specify where (campaign, ad set, or ad level)

2. **Plan next creative tests:**
   - Based on patterns above, define:
     - **New concepts to test:** e.g., more social proof-led ads
     - **Variations of winning concepts:** new hooks, new CTAs, new visuals
     - **Structural tests:** length variations, format changes, different placements

3. **Set expectations:**
   - Tie expected impact back to the primary metric:
     - "If winners capture ~50%+ of spend, we expect overall CPA to move toward [X]."
     - "We'll monitor early-stage metrics (CTR, link-to-LP CVR) in the first 3-5 days after changes."

### 8. Build the Client-Facing Report

**Report Structure:**

1. **Title & Context** — "Meta Creative Test Round [#] – [Client] – [Date Range]". Include objective, in-scope campaigns, primary/secondary metrics.

2. **Executive Summary** (1 page) — 3-5 bullets: what was tested, top winning concepts vs benchmark, biggest creative learning, actions taken, next round plans.

3. **Methodology** — How the round was defined, primary metric, source of truth, benchmarks, winner/loser criteria.

4. **Performance Overview** — Overall test performance vs evergreen/benchmark. Winners vs non-winners by spend, conversions, CPA/CPL.

5. **Winners Section** — For each winner, include:
   - **Creative visual** (required) — Use `meta_ads_preview_ads` or embed downloaded assets. Always download locally — Meta URLs expire.
   - **Key metrics** — Spend, conversions, CPA vs benchmark (e.g., "$12.50 CPA — 30% better than $18.00 benchmark")
   - **Why it worked** — Specific hook, angle, visual style insights referencing the creative
   - **Action taken** — Where graduated, with what budget

6. **Losers / Inconclusive** — For top 2-3 losers with sufficient volume:
   - **Creative visual** (required) — Show what didn't work
   - **Metrics** — Gap vs benchmark (e.g., "$45.00 CPA — 2.5x worse")
   - **What didn't work** — Specific failure points (weak hook, unclear message, bad creative-to-LP match)
   - **Inconclusive:** Note insufficient data; don't include visuals for these

7. **Next Steps** — Account changes already made, next test plans, client asks (UGC, approvals, etc.)

**Format tips:** Slides — limit to 3-5 bullets/slide, prominent creative visuals. PDF — embed images, keep <10MB. Excel — separate tabs (Summary, By Concept, By Ad, Charts, Raw Data), use conditional formatting.

### 9. QA and Present

**Before sharing, verify:**
- Primary metric used consistently across executive summary, charts, tables, and winner/loser calls
- All CPA/CPL/ROAS numbers labeled as platform or backend sourced
- Campaigns/ad sets and date range match agreed scope; totals align with dashboards
- All winners and top losers have creative visuals (downloaded, not external links)
- Not overselling small improvements; counterintuitive results explained

**When presenting:** Walk through objective → methodology → results → winners/losers → actions → next steps. Ask: "What surprised you?" and "Any additional metrics for next time?" Capture feedback for future rounds.

## Video-Specific Analysis

For video ads, include additional video performance metrics:

**Video Play Metrics:**
- video_plays_at_25_percent - Plays to 25% completion
- video_plays_at_50_percent - Plays to 50% completion
- video_plays_at_75_percent - Plays to 75% completion
- video_plays_at_100_percent - Plays to 100% completion
- video_avg_time_watched - Average watch time in seconds
- video_thruplay - Plays to completion or 15 seconds
- cost_per_thruplay - Cost per thruplay

**Video Hook Analysis:**
- Compare 3-second view rate across concepts
- Identify which hooks retain attention
- Analyze drop-off points to refine storytelling

## Best Practices

1. **Use `meta_ads_get_ad_creative_report`** as the primary data source — `level: "ad_name"` for concept comparison, `level: "ad_id"` for individual ads. Returned `ad_id` values work directly with `meta_ads_preview_ads`.
2. **Use `meta_ads_preview_ads`** for all creative reviews — renders visual UI with images/videos and metrics. Pass ad IDs from the creative report directly.
3. **Always include creative visuals** — Never present creative results without showing the ads. Download assets locally (Meta URLs expire).
4. **Confirm scope, metrics, and output format before pulling data** — Ambiguity leads to rework.
5. **Define benchmarks explicitly** — Don't rely on intuition for winner/loser calls. Ensure sufficient sample size before declaring winners.
6. **Be specific in insights** — "3-item listicle hooks doubled CTR" not "social proof works". Reference visible creative elements.
7. **Don't mix metrics** — Use same source (Meta vs backend) consistently throughout the report.
8. **Focus on winners and instructive losers** — Don't clutter with 20+ mediocre examples.

## See Also

- **references/report-types.md** - Complete creative metric definitions and video metrics
- **references/mcp-tools-reference.md** — Hopkin MCP tools reference
- **references/troubleshooting.md** — Common issues and solutions
