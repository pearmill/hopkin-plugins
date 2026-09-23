# Competitor Research Workflow (LinkedIn Ad Library)

## When to Use

Use this workflow when the user wants to see what **another company** is running on LinkedIn: current ads, new creative, messaging themes, format mix, employee posts a company pays to promote, or the EU transparency data LinkedIn publishes for an ad. It also covers tracking competitors so their ads keep being collected.

These tools read Hopkin's collected copy of the public LinkedIn Ad Library. **None of them needs a LinkedIn ad account or connection.** Never ask the user to connect LinkedIn, and never send them to a browser, to answer a competitor question.

## Tools

| Tool | Use it to |
|---|---|
| `linkedin_ads_search_ad_library` | See one company's ads by name (`advertiser_name`), or search ad copy by keyword (`search_terms`). No tracking needed |
| `linkedin_ads_track_competitor` | Start (or update) daily tracking of an advertiser, by **organization ID** when you have it, else by **name** |
| `linkedin_ads_list_tracked_competitors` | See who is tracked, their ad counts, countries and scrape health |
| `linkedin_ads_list_competitor_ads` | Browse a tracked advertiser's ads, with the full copy |
| `linkedin_ads_get_competitor_ad` | Open one ad: complete copy, media inline, video frames, transcript, transparency data |
| `linkedin_ads_untrack_competitor` | Stop tracking an advertiser |

## Key Concepts

### Advertisers are addressed by organization ID, else by NAME

LinkedIn's Ad Library can look up an advertiser two ways: by its numeric **organization ID** (exact), or by its **display name**, the way it appears on its LinkedIn company page ("Acme Analytics"), which is a fuzzy search. So:

- **To track, prefer `organization_id`** on `linkedin_ads_track_competitor`: the number in `linkedin.com/company/<id>`, or in an Ad Library URL's `companyIds=`. Or pass the URL the user pasted as `company_url`: a numeric company URL, or an Ad Library URL with one `companyIds=`, resolves exactly like the ID. An organization nobody has collected yet is **looked up live** (about 20–40 seconds) and tracked in the same call under its real name. An ID with no ads gets a plain "no ads" answer, and nothing is tracked.
- **When you only have a name, pass `name`** to `linkedin_ads_track_competitor`. To see one company's ads without tracking, pass **`advertiser_name`** to `linkedin_ads_search_ad_library`.
- A name nobody has collected yet is also looked up live. Only an **exact** name match is used. Similarly named advertisers come back as candidates. They are never tracked or shown as if they were the company. Short or generic names ("Remote") can surface only lookalikes: ask the user for the organization ID or the company's LinkedIn URL, or find it, and track by ID.
- **A company-page vanity slug is not a name.** `linkedin.com/company/acmeanalytics` gives the slug `acmeanalytics`, which is only a guess at the name and often matches nothing, while "Acme Analytics" does. If a URL-based track finds nothing, retry with the organization ID or with `name` set to the company's real name. If you know neither, ask the user.

### Two kinds of ID

| Field | What it is | Where you use it |
|---|---|---|
| `advertiser_id` (the **Advertiser ID** line) | Hopkin's ID for the advertiser, a UUID | `list_competitor_ads`, `untrack_competitor` |
| `organization_id` / `platform_advertiser_id` | LinkedIn's numeric organization ID | `track_competitor` `organization_id` (any organization), `search_ad_library` `organization_ids` |
| ad `id` | Hopkin's ID for one ad | `get_competitor_ad` `ad_id` |

A candidate or tracked row whose `platform_advertiser_id` starts with `name:` has no LinkedIn organization ID yet. Retry it with `name`, not `organization_id`.

### `search_terms` reads ad copy, not the advertiser

`search_terms` is a keyword search over ad **copy** (primary text, headline, description). Ads rarely mention their own advertiser's name, so a keyword search for a company name returns other companies' ads. **For "what is Company X running", use `advertiser_name`.** Keep `search_terms` for theme or topic research across advertisers ("which B2B ads mention 'free trial'").

### Employee posts a company pays for ("payer" ads)

On LinkedIn a company can pay to promote posts from its employees' **personal profiles** (thought-leader ads). These are included for the paying company and labelled on every listed ad:

- `attribution: "advertiser"`: the company's own ad, from its company page
- `attribution: "payer"`: an employee's post the company **paid for**. `posted_by` names the person (`name`, `profile_url`)

Always keep the two apart. Never present an employee post as a company-page ad, and name who posted it. `linkedin_ads_list_tracked_competitors` reports `payer_ad_count` (employee posts it paid for) next to `ad_count`.

### Background full scrapes finish later

When a track is new, or its countries change, `linkedin_ads_track_competitor` starts a **full collection in the background**, including the employee posts the company pays for. It lands within minutes, not in the same call. Right after tracking:

- `seeded.ad_count` says how many ads the live lookup already collected in this call
- `full_scrape: "started"` means the rest is still arriving

If a freshly tracked competitor shows few or **zero ads**, say the full collection is still running and to check back shortly. **Do not report "they have no ads."** Never claim the full history is already loaded.

## Detailed Workflow

### Scenario A: "What is Acme Analytics running on LinkedIn?" (no tracking)

```json
{
  "tool": "linkedin_ads_search_ad_library",
  "parameters": {
    "reason": "User wants to see one company's current LinkedIn ads without tracking it",
    "advertiser_name": "Acme Analytics",
    "countries": ["ALL"]
  }
}
```

- `countries` is **required**: ISO codes such as `["US", "GB"]` (use `GB`, not `UK`), or `["ALL"]`.
- `ad_active_status` defaults to `ACTIVE`. Pass `ALL` to include stopped ads. `INACTIVE` cannot be filtered exactly: it returns everything and says so in `warnings`.
- For "new this month", add `ad_delivery_date_min` (e.g. `"2026-09-01"`). LinkedIn only shows run dates on an ad's detail page, so ads without a known start date are excluded by the date bounds. Relay that caveat when it appears in `warnings`.
- Filter by format with `display_format` and by language with `languages` (language **names** such as `"English"`).
- Pass either `advertiser_name` or `organization_ids`, not both.

The result is JSON. The ads are in `data`. The other fields are `source` (`"corpus"` = already collected, `"live_scrape"` = fetched just now) and `pagination` (`hasMore`, `nextCursor`). `collection`, `warnings` and `note` appear when they apply. **Relay `warnings` and `note`.** A `note` explains an empty result, for example that the name was checked recently and nothing matched. A warning that only the first page was collected means the list is incomplete. Say so.

**When `collection` is present, the list is only the first results.** When a search has to go to the live Ad Library (typically a keyword search nothing has collected yet), it answers from the first page of results. It then collects the rest in the background, usually in about 3–5 minutes. While that runs, the response carries `collection` (`status: "in_progress"`, `started_at`, `message`) and **no cursor**. `pagination.hasMore` is then `false` even though more ads are coming, so it does **not** mean the list is complete. Later searches with the same parameters also carry `collection` until the background run finishes, sometimes with an empty `data`. That means the ads haven't landed yet, not that there are none. When you see `collection`:

- Relay its `message`, and tell the user these are only the first results.
- **Don't** paginate, and don't conclude the list is complete or that there are no more ads.
- For the full set, call again later with the **same parameters and no cursor**.

**Each LinkedIn search result has a `details_status`.** An ad's full copy, run dates, CTA and landing page come only from its detail page:

- `"complete"`: the detail page was read.
- `"pending"`: it hasn't been read yet. The background collection may still fill it in. Until then, don't present the preview copy as the full text. Don't say the ad has no run dates or landing page either: they just haven't been fetched. Search again after the collection finishes, or say the details are still loading.
- `"unavailable"`: it wasn't read and won't be. `copy_truncated` tells you whether the copy is only a preview. Missing run dates here mean unknown, not absent.

Search results also clip `primary_text` at 300 characters (ending in `…`). To quote the **full** stored copy, open the ad with `linkedin_ads_get_competitor_ad` using its `id`.

### Scenario B: Track a competitor

With the organization ID (or a pasted `linkedin.com/company/<id>` or Ad Library `companyIds=` URL, as `company_url`):

```json
{
  "tool": "linkedin_ads_track_competitor",
  "parameters": {
    "reason": "User asked to start tracking a competitor whose LinkedIn organization ID we have",
    "organization_id": "1234567",
    "countries": ["US", "GB", "DE"]
  }
}
```

With only a name:

```json
{
  "tool": "linkedin_ads_track_competitor",
  "parameters": {
    "reason": "User asked to start tracking a competitor",
    "name": "Acme Analytics",
    "countries": ["US", "GB", "DE"]
  }
}
```

- `countries` sets where this advertiser is tracked: ISO codes, or `["ALL"]`. **Omit it for the default tracking countries.** Several markets go in **one** call. Re-tracking with a different set updates it.
- The tracked-competitor limit on the user's plan is **shared with Meta**. If it's reached, relay the error and offer to untrack someone.

Read the response and report it truthfully. There are five outcomes:

| Outcome | What you see | What to tell the user / do next |
|---|---|---|
| **Tracked** | "Now Tracking: …" with **Advertiser ID**, **Organization ID**, **Countries**, and `seeded`, `full_scrape`, `warnings` when present | Say it is tracked and in which countries. If `full_scrape` is `"started"`, the full inventory (employee posts included) is still arriving. `"not_needed"` means it was already tracked with those countries. `"failed"` means the next daily collection covers it: relay the warning |
| **Candidates** ("Nothing Was Tracked") | `candidates[]` (`name`, `platform_advertiser_id`, `ad_count`, and `source: "ad_library"` for a similarly named advertiser found live) | **Nothing was tracked.** Retry only with the advertiser whose name is **exactly** what the user meant: `organization_id` when it has a numeric ID, otherwise `name` exactly as listed. If none is an exact match, ask the user for the organization ID or the company's LinkedIn URL. Never track a differently named company |
| **No ads from that name** | An error saying LinkedIn's Ad Library has no ads from an advertiser with that name, and nothing was tracked | Say so plainly. Suggest checking the exact spelling on the company page, retrying with the organization ID, or retrying with `countries: ["ALL"]`. Do not track a lookalike or invent ads |
| **No ads from that organization** | An error saying LinkedIn's Ad Library has no ads from that organization ID, and nothing was tracked | Say so plainly. Suggest checking the ID, or retrying with `countries: ["ALL"]`. Do not fall back to tracking a similarly named company |
| **Vanity-slug miss** | The "no ads" or candidates response, plus a note that the company-page slug is not necessarily the name | Retry with the organization ID, or with `name` set to the company's real name ("Acme Analytics", not "acmeanalytics"), or ask the user |

If the call errors because the live lookup failed or timed out, **nothing was tracked**. Say it failed and that it's worth retrying shortly. A failed lookup is not evidence that the company has no ads.

### Scenario C: Browse a tracked competitor's ads

1. **Find the advertiser ID**

```json
{
  "tool": "linkedin_ads_list_tracked_competitors",
  "parameters": { "reason": "Finding the tracked competitor's advertiser ID" }
}
```

Each row has `advertiser_id`, an `advertiser` object (`name`, `platform_advertiser_id` = the organization ID, `last_scraped_at`, `last_scrape_status`), `countries` (null = default tracking countries), `ad_count`, `payer_ad_count` and `created_at` (tracked since). Rows with no successful collection in 48 hours are flagged `stale`. A problem status carries a `scrape_warning`. The statuses are `blocked`, `schema_error` and `empty`, plus `partial` (only the first page is stored and the rest is still being collected) and `incomplete` (only the first page is stored and collecting the rest never started). For flagged rows, say the data may be out of date.

2. **List their ads**

```json
{
  "tool": "linkedin_ads_list_competitor_ads",
  "parameters": {
    "reason": "Reviewing a tracked competitor's active video creative",
    "advertiser_id": "<advertiser_id from step 1>",
    "active_only": true,
    "display_format": "sponsored_video"
  }
}
```

Filters: `active_only`, `display_format`, `since` (seen on/after a date), `search` (full text over this advertiser's ad copy), and `limit` / `cursor`. Formats seen in the library include `sponsored_status_update` (single image), `sponsored_video`, `sponsored_update_linkedin_article`, `sponsored_message`, `sponsored_update_native_document` (document ads) and `sponsored_update_event`. The list is LinkedIn's own and open-ended. For a format breakdown, paginate through **all** pages before counting.

3. **Open one ad in full**

```json
{
  "tool": "linkedin_ads_get_competitor_ad",
  "parameters": {
    "reason": "Reading the full copy and media of the competitor's latest ad",
    "ad_id": "<ad id from step 2>"
  }
}
```

This returns the complete copy (headline, primary text, description, CTA), landing URL, run and seen dates, and every media asset. Images and video thumbnails come back **inline as images you can see**.

- **To describe what a video actually shows**, pass `include_frames: true`. Extracted frames come back as images, capped at about 40. Use `start` / `end` (seconds) and `stride` to page through long videos. The structured result also carries `frame_count` / `frame_fps` (duration ≈ `frame_count / frame_fps`), the voiceover `transcript`, and an audio analysis.
- Media not yet processed falls back to source URLs with a note. A silent audio track is reported as silent, not as missing speech.

### Scenario D: Employee posts a company pays for

1. Make sure the company is tracked (Scenario B). Payer coverage comes from the full background collection.
2. `linkedin_ads_list_competitor_ads` with its `advertiser_id`
3. Pick out the ads with `attribution: "payer"` and report each one's `posted_by.name` (the employee) as an employee post the company paid for.

If the company was just tracked and none are listed yet, say the employee posts will appear once the background collection finishes. Don't say there are none.

### Scenario E: Who paid for an ad, and where it was shown (EU transparency data)

For ads delivered in the EU, LinkedIn publishes a transparency block, stored on the ad's `raw_data.detail` in the structured result of `linkedin_ads_get_competitor_ad` (and on search results):

- `payer`: the "Paid for by" legal entity
- `total_impressions`: an impression range, e.g. `"5k-10k"`
- `impressions_by_country`: `[{ "country", "percentage" }]`
- `targeting`: the targeting facets LinkedIn disclosed
- `ran_from` / `ran_until`: the run dates

Quote these values as given. If an ad has no such block (it wasn't delivered in the EU, or its detail page hasn't been collected), say that. Don't invent figures, and don't claim LinkedIn publishes no transparency data.

### Scenario F: Stop tracking

```json
{
  "tool": "linkedin_ads_untrack_competitor",
  "parameters": {
    "reason": "User no longer wants to track this competitor",
    "advertiser_id": "<advertiser_id>"
  }
}
```

This removes only the user's tracking. Ads already collected stay available. Untracking something that wasn't tracked returns `removed: false`, which is not an error. To confirm, call `linkedin_ads_list_tracked_competitors` again.

## Reporting Rules

1. **Show real creative, not links.** Quote headlines, primary text, CTAs and landing URLs, and name the format. A list of Ad Library links is not an answer.
2. **One advertiser means one advertiser.** When the user asked about a company, every ad you describe must be that company's own ad or an employee post it paid for, labelled as such. Never mix in lookalike advertisers.
3. **Say when copy is incomplete.** If an ad has `copy_truncated: true`, its stored body is only the preview cut at LinkedIn's "see more" fold. Say so for that ad instead of presenting it as the full text. The same applies to a search result with `details_status: "pending"`: its detail page hasn't been read yet.
4. **Say when data is still arriving.** A new track, `full_scrape: "started"`, a search response with `collection`, or a `stale` row means "more is coming" or "may be out of date", not "nothing exists" or "that's everything".
5. **Relay `warnings`, `note` and `collection.message`** from `linkedin_ads_search_ad_library` whenever they explain a filter, a partial list or an empty result.
6. **Dates**: `first_seen_at` / `last_seen_at` are when the ad was observed. `started_running_at` / `stopped_running_at` are LinkedIn's run dates, when known. A null run date on an ad whose `details_status` isn't `"complete"` means not fetched, not absent. A null `is_active` means unknown, not stopped.

## Common Mistakes

| Mistake | Instead |
|---|---|
| `search_terms: "Acme Analytics"` to see Acme's ads | `advertiser_name: "Acme Analytics"` |
| Tracking by vanity slug and stopping when it misses | Retry with `name` set to the real company name |
| Tracking a candidate whose name is only similar | Exact name only; otherwise ask the user |
| Calling `track_competitor` once per country | One call with `countries: ["US", "GB", "DE"]` |
| Passing the organization ID to `list_competitor_ads` | Pass the Hopkin `advertiser_id` |
| "They have no ads" right after tracking | "The full collection is still running — check back in a few minutes" |
| Treating a search with `collection` as the complete list, or hunting for a cursor | Relay `collection.message`; call again later with the same parameters and no cursor |
| Quoting a `details_status: "pending"` preview as the full ad | Say the full copy and dates are still being fetched |
| Asking the user to connect a LinkedIn account | None of these tools needs one |

## See Also

- **references/mcp-tools-reference.md**: full parameters and response fields for every tool
- **references/workflows/creative-performance.md**: the user's own creative performance, to compare against competitors
- **references/troubleshooting.md**: common issues and solutions
