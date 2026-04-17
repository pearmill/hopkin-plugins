# URL Inspection Report

## When to Use

Use this workflow when you need to:

- Check whether a specific URL is indexed by Google
- Diagnose why a page isn't appearing in search results
- Verify crawl status and last crawl time
- Check canonical URL resolution (Google's chosen canonical vs user-declared canonical)
- Verify robots.txt and indexing directives
- Confirm sitemap coverage for specific URLs

## Required Information

- **Inspection URL** — The fully-qualified URL to inspect (must be under the site property)
- **Site URL** — The Search Console property that contains the URL

## Detailed Workflow

### Step 1: Inspect the URL

Call `google_search_console_inspect_url`:

```json
{
  "tool": "google_search_console_inspect_url",
  "inspection_url": "https://example.com/blog/my-page",
  "site_url": "https://example.com/",
  "language_code": "en-US"
}
```

### Step 2: Present Indexing Status

Provide a clear summary of the URL's status:

**URL:** `https://example.com/blog/my-page`

| Aspect | Status | Details |
|--------|--------|---------|
| Verdict | PASS / FAIL / NEUTRAL | Overall indexing verdict |
| Coverage | Submitted and indexed / Excluded / etc. | Current coverage state |
| Robots.txt | Allowed / Blocked | Whether robots.txt allows crawling |
| Indexing | Allowed / Blocked (noindex) | Whether indexing directives allow indexing |
| Page Fetch | Successful / Failed | Whether Google could fetch the page |
| Crawl Date | YYYY-MM-DD | Last time Google crawled this URL |
| Crawler | Mobile / Desktop | Which Googlebot variant last crawled |

### Step 3: Canonical Analysis

Compare canonical URLs:

- **User-declared canonical:** What the page's `<link rel="canonical">` or HTTP header specifies
- **Google-selected canonical:** What Google chose as the canonical version

If these differ, explain the implications:
- Google may have found a better canonical (e.g., with/without trailing slash, www vs non-www)
- The page may be considered a duplicate of another URL
- This can affect which URL appears in search results

### Step 4: Sitemap Coverage

Note whether the URL is referenced in any submitted sitemaps. If not, recommend adding it.

### Step 5: Diagnosis and Recommendations

Based on the inspection results, provide specific guidance:

**If verdict is FAIL:**
- Check the coverage state for the specific exclusion reason
- Common exclusions: "Crawled - currently not indexed", "Discovered - currently not indexed", "Excluded by noindex tag", "Blocked by robots.txt"
- Provide specific fixes for each exclusion type

**If verdict is PASS but page isn't ranking:**
- The URL is indexed — the issue is ranking, not indexing
- Redirect to `get_top_queries` with `page_filter` to see what queries the page ranks for
- Suggest content and on-page SEO improvements

**If verdict is NEUTRAL:**
- The URL may be an alternate version (e.g., AMP, mobile)
- Check the canonical URL to find the primary version

## Common Diagnosis Patterns

### Page Not Indexed
1. Check robots.txt state — is crawling blocked?
2. Check indexing state — is there a noindex directive?
3. Check page fetch — can Google access the page?
4. Check coverage state for the specific reason

### Wrong Canonical Selected
1. Verify the user-declared canonical is correct
2. Check for duplicate content across URLs
3. Ensure internal links consistently point to the preferred URL
4. Check for redirect chains that might confuse canonicalization

### Page Not Being Crawled
1. Check last crawl date — it may just be delayed
2. Verify robots.txt isn't blocking the URL
3. Check if the page is linked from other crawled pages
4. Verify the page is in a submitted sitemap

## Quota Considerations

URL inspection is limited to **2000 calls per day per property**. For bulk page analysis:
- Use `google_search_console_get_search_analytics` with `dimensions: ["page"]` instead
- Reserve URL inspection for specific pages that need detailed diagnosis
- Prioritize pages with known issues or high-value content

## Best Practices

- Always present the verdict prominently — it's the most important signal
- Explain technical terms (robots.txt, canonical, noindex) if the user may not be familiar
- If the page is not indexed, provide a step-by-step fix plan
- Cross-reference with sitemap data from `google_search_console_list_sitemaps`
- For bulk indexing issues, check sitemaps first before inspecting individual URLs

## See Also

- **search-analytics.md** — Page-level performance data (use `dimensions: ["page"]`)
- **top-queries.md** — Query analysis for a specific page (use `page_filter`)
