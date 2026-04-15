# Subscriber Analysis

## Overview
Examine individual subscribers — their status, merge fields, activity history, and engagement patterns.

## Primary Tools
- `mailchimp_list_subscribers` — Find subscribers by status or search
- `mailchimp_get_subscriber` — Get full details with optional activity feed

## Step-by-Step Workflow

### Step 1: Identify the Audience

```json
{
  "tool": "mailchimp_list_audiences",
  "parameters": {
    "reason": "Finding audience for subscriber lookup"
  }
}
```

### Step 2: Find Subscribers

**By email or name:**
```json
{
  "tool": "mailchimp_list_subscribers",
  "parameters": {
    "reason": "Searching for specific subscriber",
    "audience_id": "abc123",
    "search": "user@example.com"
  }
}
```

**By status:**
```json
{
  "tool": "mailchimp_list_subscribers",
  "parameters": {
    "reason": "Listing unsubscribed members",
    "audience_id": "abc123",
    "status": ["unsubscribed"],
    "limit": 50
  }
}
```

### Step 3: Get Subscriber Details

```json
{
  "tool": "mailchimp_get_subscriber",
  "parameters": {
    "reason": "Getting full subscriber profile",
    "audience_id": "abc123",
    "email_or_hash": "user@example.com",
    "include_activity": true
  }
}
```

## Output Format

### Subscriber Profile

| Field | Value |
|-------|-------|
| Email | {email} |
| Status | {status} |
| Rating | {rating}/5 |
| Signup Date | {date} |
| Last Changed | {date} |
| Language | {language} |
| Location | {city, country} |

### Merge Fields

Display any custom merge fields (first name, last name, company, etc.) stored for the subscriber.

### Recent Activity

| Date | Action | Details |
|------|--------|---------|
| {date} | Opened | {campaign name} |
| {date} | Clicked | {URL in campaign} |

## Analysis Guidelines

1. **Engagement rating:** Mailchimp rates subscribers 1-5 based on engagement. Low ratings suggest inactive subscribers.
2. **Activity patterns:** Look for open/click trends — active openers vs never-engagers.
3. **Status transitions:** Note if a subscriber has been cleaned or unsubscribed, and when.
4. **Segment membership:** Cross-reference with segments to understand subscriber categorization.

## Bulk Analysis

For audience-wide subscriber analysis:

1. Use `mailchimp_list_subscribers` with different status filters to understand distribution
2. Compare counts across statuses: subscribed, unsubscribed, cleaned, pending
3. Use `mailchimp_get_audience_insights` for aggregate engagement metrics rather than checking individual subscribers
