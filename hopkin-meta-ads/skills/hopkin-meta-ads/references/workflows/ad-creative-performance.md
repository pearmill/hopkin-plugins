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

**Objective:** Define exactly what you're analyzing and how you'll measure success.

**Steps:**

1. **Identify test campaigns/ad sets in Meta Ads Manager:**
   - Filter campaign and ad set names for patterns like "Creative Test", "CR1", "CR2", "R1", "Round 3", "Test", etc.
   - Sort by creation date and last significant edit to see the most recent test-type campaigns/ad sets
   - Note campaign IDs and ad set IDs in scope

2. **Check project management tools:**
   - Look for the latest "Creative Round" or "Creative Test" task in ClickUp, Gmail, or other project communication/management tools you have access to
   - Note which campaigns/ad sets are referenced for this account (or client)
   - Check for any specific instructions or context

3. **Verify the round is unambiguous:**
   - Ask yourself: "Is it obvious which campaigns/ad sets belong to the latest creative round?"
   - Ask yourself: "Is there more than one round being tested at the same time?"
   - If unclear, ask the user or GM/channel lead:
     - "For [Client], which campaigns/ad sets should we treat as the latest Meta creative round for this report?"
     - "What start and end dates should we use for that round?"

4. **Confirm the date range:**
   - **Start date:** When the first creative in this round went live and spend started meaningfully (not just a few dollars)
   - **End date:** When the team "called" the test, or a clean cut-off (e.g., yesterday or end of last week)
   - If in doubt, confirm with the user: "I'm planning to use [Start Date]–[End Date] for this round. Does that match the test window?"

5. **Confirm the primary success metric:**
   - Ask: "What should be the primary success metric for this creative round?"
   - Search project management tools for Tracking Glossary for this account/client to see what the metric(s) are called in Meta
   - Look for any past reports in Slack/Gmail for the performance metric to use
   - Common options based on client goals:
     - **E-commerce:** Purchases, CPA, ROAS
     - **B2B/Lead Gen:** Qualified leads (HQL, SQL), CPL, cost per trial
     - **Early-funnel:** Landing page views, leads, add-to-cart (if insufficient down-funnel volume)
   - If you aren't sure, ask the user for the appropriate primary success metric.

6. **Identify secondary metrics:**
   - Ask: "Are there any secondary metrics you want to see in this report?"
   - Common examples: CTR, CPC, CVR (click-to-conversion rate), thumb-stop rate, 3-second views, view-through conversions

7. **Confirm source of truth:**
   - Ask: "Should we pull the main performance numbers from Meta, from backend analytics (Funnel/BI/CRM), or show both?"
   - Ask: "If platform and backend disagree, which should we treat as the main reference?"
   - Document decision: Platform only (Meta), Backend only (Funnel/CRM), or Both with explanation

8. **Confirm output format:**
   - Ask: "What format would you like for this creative test report?"
   - Common options:
     - **Google Slides / PowerPoint** - For client presentations with visuals
     - **PDF** - For formal reports or email distribution
     - **Excel** - For data-heavy analysis with pivot tables
     - **Combination** - e.g., Slides for executive summary + Excel for detailed data
   - If not specified by user, ask explicitly: "I'll be preparing a creative test report for [Client]. What format works best for you - Slides, PDF, Excel, or something else?"
   - Document the chosen format and adjust report structure accordingly:
     - **Slides/PowerPoint:** Focus on visuals, charts, screenshots; limit text per slide
     - **PDF:** Professional formatting, clear sections, tables with good spacing
     - **Excel:** Multiple tabs for different views, pivot tables, sortable columns

9. **Document scope at top of report:**
   - Client and channel (Meta)
   - Test round name
   - Campaigns/ad sets in scope
   - Date range
   - Primary metric and its source of truth
   - Secondary metrics
   - Output format

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

**Objective:** Obtain actual creative assets (images/videos) for inclusion in the report.

**Critical:** Always include visual examples of creatives in reports. Stakeholders need to see what performed well/poorly, not just read about it.

**Steps:**

1. **Get creative previews via Hopkin:**
   - `meta_ads_preview_ads` is an MCP App that renders actual visual ad creative (images/videos) with a metrics overlay in an interactive UI — distinct from tabular data tools. It is the definitive way to let stakeholders see what the ads look like. Proactively offer it in any creative review context.
   - The `ad_id` values returned by `meta_ads_get_ad_creative_report` (including representative IDs in `ad_name` mode) can be passed directly — no need to call `meta_ads_list_ads` separately:
     ```json
     {
       "tool": "meta_ads_preview_ads",
       "parameters": {
         "reason": "Rendering creative visual preview with performance metrics for creative test report",
         "account_id": "act_123456789",
         "ads": [
           {"ad_id": "23842453456789", "metrics": {"spend": "450.00", "cpa": "$12.50", "ctr": "3.2%"}},
           {"ad_id": "23842453456790", "metrics": {"spend": "380.00", "cpa": "$45.00", "ctr": "1.1%"}}
         ],
         "metric_labels": {"spend": "Spend", "cpa": "CPA", "ctr": "CTR"}
       }
     }
     ```
   - For video ads, get both the video file and a thumbnail/poster frame. The `thumbnail_url` field in the creative report response provides a GCS-hosted thumbnail.

2. **Download assets for key creatives:**
   - **Download all winners** - Essential to show what worked
   - **Download top 2-3 losers** - Important to show what didn't work
   - **Download any notable/promising creatives** - Those with interesting patterns
   - For large creative rounds (>20 ads), prioritize top/bottom performers and skip middle-tier ads

3. **Format-specific asset handling:**

   **For Slides/PowerPoint reports:**
   - Download assets locally
   - Insert images/videos directly into slides
   - Do NOT link to external URLs
   - For videos: Use first frame as thumbnail with play indicator, or export key frames as images
   - Ensure images are high-resolution (at least 1920x1080 for full-slide images)

   **For PDF reports:**
   - Download assets locally
   - Embed images directly in document
   - For videos: Include representative thumbnail/screenshot with note "Video - see [link] for full asset"
   - Keep file size manageable (<10MB) - compress images if needed

   **For Excel reports:**
   - Download thumbnails/screenshots
   - Insert images in a dedicated "Creative Previews" tab
   - Link from data rows to preview images
   - Alternative: Include thumbnail URLs in a column (but note they may expire)

4. **Organize downloaded assets:**
   - Create a folder structure: `[Client]/[Round]/assets/`
   - Separate subfolders for winners, losers, and other
   - Keep original filenames + metadata for reference

5. **Handle special cases:**

   **Carousel ads:**
   - Download all cards/frames, not just the first one
   - Show key frames that illustrate the concept
   - Note which frame(s) performed best if data available

   **Dynamic/Catalog ads:**
   - Download representative examples
   - Show product variations if testing different products
   - Note the template/format rather than every single variation

   **UGC/Creator content:**
   - Ensure you have rights/permission to include in client reports
   - If sharing externally, verify creator agreements allow it
   - Consider blurring faces if privacy concerns exist

6. **Quality check:**
   - Verify all downloaded assets are readable/playable
   - Check file sizes are reasonable (compress if >5MB per image)
   - Ensure videos are in compatible formats (.mp4, .mov)
   - Confirm no corrupted or broken downloads

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

**Objective:** Present findings in a clear, actionable format tailored to the chosen output format.

**Format-Specific Considerations:**

**For Google Slides / PowerPoint:**
- Limit text per slide (max 3-5 bullets or 1 chart + brief explanation)
- Use visual hierarchy: large chart/screenshot + supporting text
- Include creative thumbnails/screenshots prominently
- Use consistent brand colors and formatting
- Create a clear slide flow: Context → Results → Winners → Losers → Actions → Next Steps
- Export key data tables as images or simplified charts

**For PDF:**
- Use clear section headers and page breaks
- Include table of contents with page numbers for longer reports
- Ensure tables are well-formatted with proper spacing and borders
- Embed creative preview images at appropriate size (not too large/small)
- Use consistent fonts and professional styling
- Consider adding footer with report date and version

**For Excel:**
- Create separate tabs for different views:
  - "Summary" - Executive overview with key metrics
  - "By Concept" - Concept-level performance
  - "By Ad" - Detailed ad-level data
  - "Charts" - Visualizations and graphs
  - "Raw Data" - Full export from Meta
- Use freeze panes to keep headers visible
- Apply conditional formatting to highlight winners/losers
- Add pivot tables for flexible data exploration
- Include filters and sorting on all data tables
- Document calculations in a "Methodology" tab

**Report Structure:**

#### 1. Title & Context
- "Meta Creative Test Round [#] – [Client] – [Date Range]"
- Short context:
  - Objective of the round
  - In-scope campaigns/ad sets
  - Primary and secondary metrics used

#### 2. Executive Summary (1 page)
- 3-5 bullets covering:
  - What was tested (channels, number of concepts, formats)
  - Top 1-2 winning concepts and their performance vs benchmark
  - The biggest creative learning (e.g., "social proof + X angle wins")
  - Actions already taken in the account
  - What's planned for the next round

#### 3. Methodology
- Brief explanation:
  - How you defined the round (campaigns/ad sets, date range)
  - Primary metric and source of truth (Meta vs Funnel)
  - Benchmarks and winner/loser criteria

#### 4. Performance Overview
- High-level chart/table:
  - Overall test performance vs evergreen/benchmark on primary metric
  - Winners vs non-winners breakdown:
    - Spend
    - Conversions
    - CPA/CPL

#### 5. Winners Section

**CRITICAL: Always include actual creative visuals for winners.**

For each key winner:

**Creative Visual (Required):**
- **Slides/PowerPoint:** Insert downloaded image/video on slide
  - Use large, prominent placement (half to full slide)
  - For videos: Use thumbnail + "Watch Video" indicator, or embed if presenting live
- **PDF:** Embed downloaded image
  - Size appropriately (3-5 inches wide/tall)
  - For videos: Use thumbnail + note "Video available at [link]"
- **Excel:** Link to image in Creative Previews tab
  - Or embed thumbnail in cell using Insert > Image

**Key metrics:**
- Spend, conversions, CPA/CPL vs benchmark
- CTR/CVR if they help explain performance
- Format as: "$12.50 CPA (30% better than $18.00 benchmark)"

**Why it worked** (1-3 bullets):
- Specific hook, angle, visual style insights
- Reference what's visible in the creative preview
- Examples:
  - "Opens with '3 signs you need X' listicle format - immediately hooks viewer"
  - "UGC format with creator holding product - feels authentic vs. polished brand content"
  - "First 3 seconds show transformation - high thumb-stop rate"
- Any quirks (e.g., best on mobile placements only, outperformed on Instagram vs. Facebook)

**Action taken:**
- Where it has been graduated and with what budget or bid strategy
- Example: "Moved to Evergreen campaign with 20% of daily budget ($200/day)"

#### 6. Losers / Inconclusive Section

**CRITICAL: Include creative visuals for top 2-3 losers to illustrate what didn't work.**

Focus on instructive underperformers:

**Creative Visual (Required for top losers):**
- Use same format as Winners section
- Include 2-3 worst performers that had sufficient spend/volume
- Skip showing every single losing creative - focus on instructive examples

**Metrics:**
- Show enough to illustrate the gap vs benchmark
- Format as: "$45.00 CPA (2.5x worse than $18.00 benchmark)"
- Include CTR/CVR if they help explain why it failed

**What didn't work** (1-2 bullets on failures and what to avoid):
- Reference what's visible in the creative preview
- Examples:
  - "Opens with slow brand logo intro - 3-second drop-off rate was 65%"
  - "Heavy text overlay makes product hard to see - low engagement"
  - "Generic 'Buy now' messaging with no differentiation - high CPC, low CVR"

**Inconclusive ads note:**
- For ads with insufficient data: "Low spend/volume—no strong conclusion yet. Keeping in mind for future tests with more budget."
- Do NOT include creative visuals for inconclusive ads (save space/focus)

#### 7. Next Steps & Requests
- **Account changes:**
  - What you'll change immediately (already in motion or done)
- **Next tests:**
  - Number of new concepts, planned launch date, main hypotheses
- **Client asks:**
  - Needed UGC / brand approvals / product info (e.g., "We need 2 new creator scripts focused on X benefit.")

### 9. QA Metrics and Alignment Before Sharing

**Objective:** Ensure accuracy and consistency before presenting to client.

**Steps:**

1. **Metric consistency check:**
   - Is the primary metric used consistently in:
     - Executive summary
     - Charts/tables
     - Winner/loser calls
   - Are all CPA/CPL/ROAS numbers clearly labeled as platform or backend sourced?

2. **Scope sanity check:**
   - Do the campaigns/ad sets and date range in the report match what you agreed on?
   - Do totals roughly align with what they see in their dashboards?

3. **Narrative consistency:**
   - Does the executive summary accurately reflect which concepts truly won by the primary metric?
   - Are you accurately representing the scale of impact (not overselling small improvements)?
   - Are any surprising or counterintuitive results clearly explained?

4. **Final clarifications if needed:**
   - If you discover issues (e.g., platform vs backend mismatch, weird spikes), check with the user:
     - "We're seeing [issue]. Do you want us to show both numbers and explain, or stick to [Meta/Funnel] for this round's report?"

5. **Format-specific QA:**

   **Universal - Creative Assets Check (ALL FORMATS):**
   - ✓ Do ALL winners have creative visuals included?
   - ✓ Do top 2-3 losers have creative visuals included?
   - ✓ Are creative visuals actual downloaded assets (not broken external links)?
   - ✓ Are images/videos high quality and clearly visible?
   - ✓ Are captions accurate and include key metrics?

   **For Slides/PowerPoint:**
   - Does each slide have a clear title?
   - Are images high-resolution and properly sized (min 1920x1080)?
   - Are creative visuals embedded (not linked externally)?
   - Is text readable (not too small)?
   - Do animations/transitions work if used?
   - Is the slide deck under 20 slides for executive summary?

   **For PDF:**
   - Do page breaks fall in logical places?
   - Are all images embedded and visible (test by opening PDF)?
   - Are creative visuals clear and appropriately sized?
   - Is the file size reasonable (<10MB)?
   - Does the table of contents have accurate page numbers?

   **For Excel:**
   - Do all formulas calculate correctly?
   - Are tabs labeled clearly?
   - Do filters and sorts work properly?
   - Are pivot tables refreshing correctly?
   - Is conditional formatting applied appropriately?
   - Are creative preview images visible in Creative Previews tab?

### 10. Present the Report and Capture Feedback

**Objective:** Share findings and gather input for future rounds.

**Steps:**

1. **Walk through the report:**
   - Objective → methodology → high-level results → winners/losers → what you've changed → what's next

2. **Ask for reactions:**
   - "What surprised you in these results?"
   - "Are there angles or products you want us to emphasize more (or less) in the next round?"
   - "Is there any additional metric or cut you'd like to see next time?"

3. **Feed learnings back:**
   - Update internal templates/SOPs with:
     - Any new preferred metrics or views
     - Client-specific preferences (e.g., "always show backend HQLs and CPA by geo")

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

1. **ALWAYS use `meta_ads_get_ad_creative_report` as the primary data source** — This is the dedicated tool for creative analysis. Use `level: "ad_name"` (default) to compare creative concepts across ad sets; use `level: "ad_id"` for individual ad comparisons. The returned `ad_id` values work directly with `meta_ads_preview_ads`.

2. **ALWAYS use `meta_ads_preview_ads` for creative review** — This MCP App renders a visual UI with actual images/videos and metrics side-by-side. It is the most powerful tool in this workflow. Use it:
   - Whenever the user asks "what do my ads look like" or wants to review creative
   - When presenting winners and losers — visual context makes insights actionable
   - For A/B creative comparisons — seeing the creative alongside the number is essential
   - Pass `ad_id` values from `meta_ads_get_ad_creative_report` directly — no need to call `meta_ads_list_ads` first

3. **ALWAYS include creative visuals in reports** - Never present creative test results without showing the actual ads
   - Winners and top losers must have images/videos included
   - Always download assets locally first before embedding in reports (Meta URLs expire)
   - Stakeholders need to see what worked/failed, not just read metrics
   - Creative insights are meaningless without seeing the creative

4. **Always confirm scope before pulling data** - Ambiguity leads to rework

5. **Align on metrics early** - Primary metric should be clear from the start

6. **Confirm output format upfront** - Ask what format they want (Slides, PDF, Excel) before building

7. **Define benchmarks explicitly** - Don't rely on intuition for winner/loser calls

8. **Review actual creatives, not just numbers** - The "why" comes from watching the ads
   - Watch videos fully, don't just look at thumbnails
   - Note first 3 seconds (hook quality), messaging, visual style, CTA placement

9. **Be specific in insights** - "Social proof hooks work" is weak; "3-item listicle hooks doubled CTR" is strong
   - Reference specific creative elements visible in the assets

10. **Connect actions to expectations** - Tell the client what should happen next

11. **QA rigorously** - Metric misalignment destroys credibility
    - Verify all creative assets are displaying correctly before sharing

12. **Capture feedback for next time** - Every round should improve your process

## Common Pitfalls to Avoid

- **Missing creative visuals** - NEVER present a creative test report without actual images/videos of the ads
  - Showing only metrics without visuals makes insights impossible to understand
  - Stakeholders can't learn what works if they can't see the creatives

- **Using Meta URLs directly in reports** - These expire and break
  - Always download assets locally first, then embed in your report
  - Test that all images/videos are displaying before sharing report

- **Showing every single ad** - Focus on winners and instructive losers
  - Don't clutter report with 20+ mediocre creative examples
  - Prioritize quality of insights over quantity of visuals

- **Calling winners too early** - Ensure sufficient sample size (conversions, spend)

- **Ignoring statistical significance** - Small differences may not be meaningful

- **Mixing metrics** - Don't switch between Meta and backend metrics mid-report

- **Overselling small wins** - 5% improvement is not "massive"

- **Forgetting creative fatigue** - Today's winner may be tomorrow's loser

- **Not documenting methodology** - Clients need to understand how you defined success

- **Not confirming output format** - Building the wrong format wastes time

## See Also

- **references/report-types.md** - Complete creative metric definitions and video metrics
- **references/mcp-tools-reference.md** — Hopkin MCP tools reference
- **references/troubleshooting.md** — Common issues and solutions
