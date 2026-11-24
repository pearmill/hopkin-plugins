# Hopkin Plugin for Claude

**Stop switching tabs. Get your ad performance inside Claude.**

Hopkin connects your Meta, Google, Microsoft Ads, LinkedIn, Reddit, TikTok, ChatGPT Ads, Mailchimp, Google Search Console, and Google Analytics accounts directly to Claude — so you can ask questions, pull reports, and surface insights without touching a dashboard.

## What You Can Do

Ask Claude things like:

- *"Which Meta campaigns are above target CPA this week?"*
- *"Compare Google vs Meta spend and ROAS for the last 30 days."*
- *"Rank my creatives by CPA and show demographic breakdowns."*
- *"Flag any campaigns that underspent their budget this month."*
- *"How are my LinkedIn Ads performing compared to Meta this quarter?"*
- *"Which subreddits are driving the most conversions for my Reddit campaigns?"*

Claude answers with real data from your accounts — no copy-pasting, no pivot tables, no dashboard fatigue.

## Install in 30 Seconds

Add the Hopkin plugin marketplace to Claude Code, then install:

```bash
/plugin marketplace add https://github.com/pearmill/hopkin-plugins.git
/plugin install hopkin@hopkin-plugins
```

One install gives you all supported platforms. After installing, Claude will walk you through a one-time OAuth login at [app.hopkin.ai](https://app.hopkin.ai/?utm_source=claude-plugin&utm_medium=readme&utm_content=readme). Hopkin reads campaign data from the ad platforms and does not change your ad accounts. A few tools do write: they rename, share, set the default for or revoke your Hopkin connections, track or untrack competitors, turn on creative intelligence for an ad account, send feedback to Hopkin, and create a Stripe checkout link when the organization owner asks to pay.

## Why Hopkin

Most ad teams repeat the same workflows every week: morning performance checks, cross-platform comparisons, creative ranking, client reporting. Hopkin turns those into one-line questions.

- **Cross-platform in one conversation** — pull Meta, Google, Microsoft, LinkedIn, Reddit, TikTok, ChatGPT Ads, and Mailchimp data side by side
- **Creative performance** — rank ads by CPA or ROAS with demographic breakdowns
- **Budget tracking** — spot underspend and overspend across 60+ accounts at once
- **Trend analysis** — 3, 6, or 12-month views on demand
- **Community insights** — see which subreddits drive the best Reddit Ads performance
- **Secure by design** — OAuth sign-in, and no tool changes your campaigns, budgets or ads

## Supported Platforms

| Platform | Skill |
|---|---|
| Meta (Facebook/Instagram) | hopkin-meta-ads |
| Google Ads | hopkin-google-ads |
| Microsoft Ads (Bing) | hopkin-microsoft-ads |
| LinkedIn Ads | hopkin-linkedin-ads |
| Reddit Ads | hopkin-reddit-ads |
| TikTok Ads | hopkin-tiktok-ads |
| ChatGPT Ads (OpenAI Ads) | hopkin-chatgpt-ads |
| Mailchimp | hopkin-mailchimp |
| Google Search Console | hopkin-google-search-console |
| Google Analytics (GA4) | hopkin-google-analytics |

## Feedback to Hopkin

Every Hopkin server has a `*_developer_feedback` tool (for example `meta_ads_developer_feedback`). It sends a short description of a missing capability or fault to Hopkin. Claude sends it only when you ask it to, or after asking you and getting a yes. It does not send your conversation, its history or a summary of it.

## Get an Account

The plugin requires a Hopkin account. Sign up at [hopkin.ai](https://hopkin.ai).
