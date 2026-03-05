# Hopkin Plugins for Claude

**Stop switching tabs. Get your ad performance inside Claude.**

Hopkin connects your Meta, Google, and LinkedIn Ads accounts directly to Claude — so you can ask questions, pull reports, and surface insights without touching a dashboard.

## What You Can Do

Ask Claude things like:

- *"Which Meta campaigns are above target CPA this week?"*
- *"Compare Google vs Meta spend and ROAS for the last 30 days."*
- *"Rank my creatives by CPA and show demographic breakdowns."*
- *"Flag any campaigns that underspent their budget this month."*
- *"How are my LinkedIn Ads performing compared to Meta this quarter?"*

Claude answers with real data from your accounts — no copy-pasting, no pivot tables, no dashboard fatigue.

## Install in 30 Seconds

Add the Hopkin plugin marketplace to Claude Code, then install the platforms you use:

```bash
/plugin marketplace add hopkin/hopkin-plugins
```

**Meta Ads:**
```bash
/plugin install hopkin-meta-ads@hopkin
```

**Google Ads:**
```bash
/plugin install hopkin-google-ads@hopkin
```

**LinkedIn Ads:**
```bash
/plugin install hopkin-linkedin-ads@hopkin
```

After installing, Claude will walk you through a one-time OAuth login at [app.hopkin.ai](https://app.hopkin.ai). No credentials are stored — read-only access only.

## Why Hopkin

Most ad teams repeat the same workflows every week: morning performance checks, cross-platform comparisons, creative ranking, client reporting. Hopkin turns those into one-line questions.

- **Cross-platform in one conversation** — pull Meta, Google, and LinkedIn data side by side
- **Creative performance** — rank ads by CPA or ROAS with demographic breakdowns
- **Budget tracking** — spot underspend and overspend across 60+ accounts at once
- **Trend analysis** — 3, 6, or 12-month views on demand
- **Secure by design** — OAuth only, read-only, no stored credentials

## Available Plugins

| Plugin | Platform | What it does |
|---|---|---|
| `hopkin-meta-ads` | Meta (Facebook/Instagram) | Campaign reports, creative analysis, budget monitoring |
| `hopkin-google-ads` | Google Ads | Keyword performance, search terms, campaign insights |
| `hopkin-linkedin-ads` | LinkedIn Ads | Campaign performance, audience insights, spend reporting |

## Get an Account

Plugins require a Hopkin account. Sign up at [hopkin.ai](https://hopkin.ai).
