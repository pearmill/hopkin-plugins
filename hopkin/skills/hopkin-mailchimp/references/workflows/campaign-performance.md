# Campaign Performance Report

## Overview
Analyze the performance of sent Mailchimp email campaigns — opens, clicks, bounces, ecommerce revenue, and industry benchmarks.

## Primary Tool
Use `mailchimp_get_campaign_report` for campaign performance reports. This tool returns comprehensive metrics in a single call:

- **Opens:** total opens, unique opens, open rate
- **Clicks:** total clicks, unique clicks, click rate, click-to-open rate
- **Bounces:** hard bounces, soft bounces, syntax errors
- **Forwards:** forward count, forward opens
- **Ecommerce:** total orders, total revenue, total spent
- **Delivery:** emails sent, delivered, delivery rate
- **Industry stats:** open rate, click rate, bounce rate (for comparison)
- **Unsubscribes and abuse reports**

## Required Parameters
- **campaign_id**: The Mailchimp campaign ID (campaign must be in "sent" status)

## Step-by-Step Workflow

### Step 1: Identify the Campaign

If the user hasn't specified a campaign:

```json
{
  "tool": "mailchimp_list_campaigns",
  "parameters": {
    "reason": "Finding sent campaigns to report on",
    "status": ["sent"],
    "limit": 10
  }
}
```

Present the list and ask the user which campaign to analyze. If they mention a campaign by name, use the `search` parameter.

### Step 2: Get Campaign Details (Optional)

For additional context about the campaign:

```json
{
  "tool": "mailchimp_get_campaign",
  "parameters": {
    "reason": "Getting campaign details for context",
    "campaign_id": "abc123def4",
    "include_content": false,
    "include_send_checklist": false
  }
}
```

### Step 3: Generate the Report

```json
{
  "tool": "mailchimp_get_campaign_report",
  "parameters": {
    "reason": "Generating campaign performance report",
    "campaign_id": "abc123def4"
  }
}
```

### Step 4: Analyze Per-Recipient Activity (Optional)

For deeper engagement analysis:

```json
{
  "tool": "mailchimp_get_email_activity",
  "parameters": {
    "reason": "Analyzing per-recipient engagement",
    "campaign_id": "abc123def4",
    "limit": 50
  }
}
```

## Output Format

Present results in a structured format:

### Campaign Summary Table

| Metric | Value |
|--------|-------|
| Campaign | {campaign name} |
| Sent | {send date} |
| Audience | {audience name} |
| Emails Sent | {count} |

### Engagement Metrics

| Metric | Value | Industry Avg |
|--------|-------|-------------|
| Open Rate | {rate}% | {industry}% |
| Click Rate | {rate}% | {industry}% |
| Click-to-Open Rate | {rate}% | — |
| Bounce Rate | {rate}% | {industry}% |
| Unsubscribe Rate | {rate}% | — |

### Deliverability

| Metric | Count |
|--------|-------|
| Delivered | {count} |
| Hard Bounces | {count} |
| Soft Bounces | {count} |
| Abuse Reports | {count} |

### Ecommerce (if applicable)

| Metric | Value |
|--------|-------|
| Total Orders | {count} |
| Total Revenue | ${amount} |
| Revenue per Email | ${amount} |

## Analysis Guidelines

1. **Compare to industry:** Always highlight how metrics compare to industry averages
2. **Flag concerns:** Call out high bounce rates (>2%), high unsubscribe rates (>0.5%), or abuse complaints
3. **Highlight wins:** Note when open/click rates exceed industry averages
4. **Suggest improvements:** Based on metrics, suggest actionable next steps (e.g., subject line testing for low open rates, CTA optimization for low click rates)

## Multi-Campaign Comparison

To compare multiple campaigns:

1. Use `mailchimp_list_campaigns` with `status: ["sent"]` to get recent campaigns
2. Call `mailchimp_get_campaign_report` for each campaign
3. Present a comparison table with key metrics side by side

| Campaign | Open Rate | Click Rate | Unsubs | Revenue |
|----------|-----------|------------|--------|---------|
| Campaign A | 24.5% | 3.2% | 5 | $1,234 |
| Campaign B | 21.8% | 2.8% | 3 | $987 |
