# Automation Review

## Overview
Review automation sequences — status, email performance, and delivery metrics across automation workflows.

## Primary Tools
- `mailchimp_list_automations` — List automations with status filtering
- `mailchimp_get_automation` — Get automation details with per-email delivery stats

## Step-by-Step Workflow

### Step 1: List Automations

**All active automations:**
```json
{
  "tool": "mailchimp_list_automations",
  "parameters": {
    "reason": "Listing active automations",
    "status": ["sending"]
  }
}
```

**All automations:**
```json
{
  "tool": "mailchimp_list_automations",
  "parameters": {
    "reason": "Listing all automations for review"
  }
}
```

### Step 2: Get Automation Details

```json
{
  "tool": "mailchimp_get_automation",
  "parameters": {
    "reason": "Reviewing automation performance",
    "automation_id": "abc123def4"
  }
}
```

This returns the automation details plus all associated emails with their delivery stats (opens, clicks, bounces per email in the sequence).

## Output Format

### Automation Summary

| Field | Value |
|-------|-------|
| Name | {automation name} |
| Status | {sending/paused/save} |
| Audience | {audience name} |
| Emails in Sequence | {count} |
| Created | {date} |

### Email Sequence Performance

| # | Subject | Sends | Opens | Open Rate | Clicks | Click Rate |
|---|---------|-------|-------|-----------|--------|------------|
| 1 | {subject} | {n} | {n} | {rate}% | {n} | {rate}% |
| 2 | {subject} | {n} | {n} | {rate}% | {n} | {rate}% |
| 3 | {subject} | {n} | {n} | {rate}% | {n} | {rate}% |

## Analysis Guidelines

1. **Drop-off analysis:** Compare engagement across emails in the sequence — a significant drop suggests optimization opportunity
2. **Status review:** Paused automations may need attention. Draft/save automations haven't been activated.
3. **Per-email performance:** Identify which emails in the sequence perform best/worst
4. **Audience alignment:** Verify the automation targets the intended audience
5. **Suggest improvements:** For underperforming emails, suggest subject line or content changes

## Multi-Automation Comparison

When reviewing all automations:

1. List all automations with `mailchimp_list_automations`
2. Call `mailchimp_get_automation` for each active automation
3. Present a summary table comparing key metrics across automations

| Automation | Status | Emails | Total Sends | Avg Open Rate |
|-----------|--------|--------|-------------|---------------|
| Welcome Series | Sending | 3 | 5,432 | 42.1% |
| Onboarding | Sending | 5 | 2,187 | 35.8% |
| Re-engagement | Paused | 2 | 876 | 18.4% |
