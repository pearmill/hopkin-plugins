# Audience Insights Report

## Overview
Analyze audience health and growth — subscriber trends, engagement patterns, email client distribution, and geographic breakdown.

## Primary Tool
Use `mailchimp_get_audience_insights` for audience-level analytics. This tool fetches multiple data sources in parallel:

- **Growth history:** Subscriber count over time, subscribes/unsubscribes per period
- **Activity:** Recent audience-level engagement metrics
- **Email clients:** Distribution of email clients used by subscribers
- **Locations:** Geographic distribution of subscribers

Each data source degrades gracefully — if one fails, the others still return.

## Required Parameters
- **audience_id**: The Mailchimp audience/list ID

## Step-by-Step Workflow

### Step 1: Identify the Audience

If the user hasn't specified an audience:

```json
{
  "tool": "mailchimp_list_audiences",
  "parameters": {
    "reason": "Finding audiences to analyze"
  }
}
```

Present the list with member counts and ratings. Ask the user which audience to analyze.

### Step 2: Get Audience Details

For baseline stats and settings:

```json
{
  "tool": "mailchimp_get_audience",
  "parameters": {
    "reason": "Getting audience baseline stats",
    "audience_id": "abc123"
  }
}
```

### Step 3: Get Audience Insights

```json
{
  "tool": "mailchimp_get_audience_insights",
  "parameters": {
    "reason": "Analyzing audience health and growth",
    "audience_id": "abc123",
    "include_growth_history": true,
    "include_activity": true,
    "include_clients": true,
    "include_locations": true
  }
}
```

### Step 4: Segment Analysis (Optional)

To understand audience structure:

```json
{
  "tool": "mailchimp_list_segments",
  "parameters": {
    "reason": "Reviewing audience segments",
    "audience_id": "abc123"
  }
}
```

### Step 5: Tag Overview (Optional)

To see how subscribers are organized:

```json
{
  "tool": "mailchimp_list_tags",
  "parameters": {
    "reason": "Reviewing audience tags",
    "audience_id": "abc123"
  }
}
```

## Output Format

### Audience Overview

| Metric | Value |
|--------|-------|
| Audience Name | {name} |
| Total Members | {count} |
| Subscribed | {count} |
| Unsubscribed | {count} |
| Cleaned | {count} |
| Open Rate | {rate}% |
| Click Rate | {rate}% |
| List Rating | {rating}/5 |

### Growth Trends

Present growth history as a trend summary:
- Net growth over the period
- Average subscribes/unsubscribes per month
- Any notable spikes or drops

### Email Client Distribution

| Client | Percentage |
|--------|-----------|
| Gmail | {pct}% |
| Apple Mail | {pct}% |
| Outlook | {pct}% |
| Other | {pct}% |

### Geographic Distribution

Top locations by subscriber count.

## Analysis Guidelines

1. **Assess list health:** A healthy list has low bounce rates, consistent growth, and high engagement
2. **Flag cleaning needs:** High cleaned/unsubscribed counts suggest list hygiene issues
3. **Email client insights:** Client distribution affects rendering — if most subscribers use mobile clients, email design should be mobile-first
4. **Geographic insights:** Location data informs send time optimization and content localization
5. **Growth trajectory:** Is the list growing, shrinking, or stagnant? What's driving the trend?
