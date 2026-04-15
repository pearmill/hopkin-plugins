---
name: hopkin-mailchimp
description: Manage and analyze Mailchimp email marketing using the Hopkin Mailchimp MCP. Includes prerequisite checks, authentication flow, campaign reporting, audience insights, subscriber management, automation review, and developer feedback for unsupported write operations.
---

# Mailchimp Skill

## Introduction

This skill enables Claude to analyze and report on Mailchimp email marketing via the Hopkin Mailchimp MCP. Use this skill when you need to:

- Review campaign performance (opens, clicks, bounces, ecommerce)
- Analyze audience growth, engagement, and subscriber demographics
- Explore subscriber details and activity history
- Audit automations and their email performance
- Examine segments, tags, and audience organization
- Review email templates

The skill provides structured workflows for common Mailchimp reporting and analysis tasks, with built-in best practices for data presentation.

## Prerequisites

Before using this skill, verify that the Hopkin Mailchimp MCP is configured and the user is authenticated.

### Check for MCP Availability

To verify the Hopkin Mailchimp MCP is available:

1. Check for `mailchimp_` prefixed tools in your available tools (e.g., `mailchimp_check_auth_status`, `mailchimp_list_accounts`)
2. If found, the Hopkin Mailchimp MCP is properly configured

### If Hopkin Mailchimp MCP Is Not Installed

If no `mailchimp_` prefixed tools are available:

1. **Inform the user** that the Hopkin Mailchimp MCP is required to use this skill
2. **Direct them to sign up** at https://app.hopkin.ai
3. **Provide setup instructions:**

> The Hopkin Mailchimp MCP is not configured. To use this skill:
>
> 1. Sign up at **https://app.hopkin.ai**
> 2. Add the hosted MCP to your Claude configuration:
>
> ```json
> {
>   "mcpServers": {
>     "hopkin-mailchimp": {
>       "type": "url",
>       "url": "https://mailchimp.mcp.hopkin.ai/mcp",
>       "headers": {
>         "Authorization": "Bearer YOUR_HOPKIN_TOKEN"
>       }
>     }
>   }
> }
> ```
>
> 3. Restart Claude after updating configuration

4. **Pause execution** until the user confirms MCP installation is complete
5. **Re-verify** MCP availability after user confirmation

### Authentication Flow

After confirming the MCP is available, authenticate the user's Mailchimp account:

1. **Check auth status:** Call `mailchimp_check_auth_status` to see if the user is already authenticated
2. **If not authenticated:** Inform the user that they need to connect their Mailchimp account via https://app.hopkin.ai and follow the OAuth flow there

### Quick Start with Preferences

At the start of any session, call `mailchimp_get_preferences` with `entity_type: "ad_account"` and `entity_id: "global"` to check if the user has stored default settings (e.g., a default account ID or audience). If preferences are found, use them automatically without asking the user. After the user selects or confirms an account/audience, offer to store it as a preference for future sessions using `mailchimp_store_preference`.

### Required Information

Before generating reports, confirm you have:

- **Account ID** — If the user has multiple Mailchimp accounts connected, use `mailchimp_list_accounts` to identify which one to use. If only one account is connected, the `account_id` parameter can be omitted.
- **Audience ID** — Most operations require an audience (list) ID. Use `mailchimp_list_audiences` to find available audiences.

### Multiple Accounts

Some users connect multiple Mailchimp accounts to Hopkin. When this is the case:

- The `account_id` parameter becomes required on most tools
- Use `mailchimp_list_accounts` to see all connected accounts with their names and data centers
- Ask the user which account to use if multiple are available

## Available MCP Tools

For complete tool documentation with all parameters, see **references/mcp-tools-reference.md**.

All 21 tools use the `mailchimp_` prefix. Every tool call requires a `reason` (string) parameter for audit trail.

**Key tools by workflow:**
- **Account setup:** `mailchimp_list_accounts`, `mailchimp_check_auth_status`
- **Audiences:** `mailchimp_list_audiences`, `mailchimp_get_audience`
- **Subscribers:** `mailchimp_list_subscribers`, `mailchimp_get_subscriber` (with `include_activity`)
- **Campaigns:** `mailchimp_list_campaigns`, `mailchimp_get_campaign` (with `include_content`, `include_send_checklist`)
- **Automations:** `mailchimp_list_automations`, `mailchimp_get_automation`
- **Templates:** `mailchimp_list_templates`
- **Reports:** `mailchimp_get_campaign_report` (primary), `mailchimp_get_audience_insights`, `mailchimp_get_email_activity`
- **Organization:** `mailchimp_list_segments`, `mailchimp_list_tags`
- **Preferences:** `mailchimp_store_preference`, `mailchimp_get_preferences`, `mailchimp_delete_preference`
- **Feedback:** `mailchimp_developer_feedback`

## Core Capabilities

This skill supports six primary report types and a developer feedback workflow for write operations.

### Report Types

1. **Campaign Performance Reports** — Opens, clicks, bounces, forwards, ecommerce revenue, delivery status, and industry benchmarks
2. **Audience Insights** — Growth history, subscriber activity, email client usage, and geographic distribution
3. **Email Activity Reports** — Per-recipient engagement for a specific campaign
4. **Subscriber Analysis** — Individual subscriber details, status, activity history, and merge field data
5. **Automation Review** — Automation status, email sequence performance, and delivery stats
6. **Audience Organization** — Segments, tags, and audience structure analysis

### Write Operations (Unsupported — Developer Feedback)

The Hopkin Mailchimp MCP is **read-only**. When a user requests write operations (create campaign, add subscriber, update tags, send campaign, etc.):

1. **Inform the user** that write operations are not yet available via Hopkin
2. **Submit a feature request** by calling `mailchimp_developer_feedback` with:
   - `feedback_type: "workflow_gap"`
   - `title`: Description of the write operation requested
   - `description`: What the user was trying to do
   - `current_workaround`: How you worked around the limitation (if applicable)
   - `priority`: Based on user's urgency
3. **Provide guidance** on performing the action manually via the Mailchimp web interface

### Proactive Efficiency Feedback

Whenever you complete a task and believe there should have been a faster or more efficient way to get the answer — for example, if you had to make multiple tool calls that could have been a single call, or if a dedicated tool for the workflow would have saved time — call `mailchimp_developer_feedback` with:
- `feedback_type: "new_tool"` or `"improvement"`
- `title`: Brief description of the missing capability
- `description`: Explain what you were trying to accomplish, the steps you had to take, and how a new or improved tool could have made it faster
- `current_workaround`: The steps you took to work around the limitation
- `priority`: `"medium"`

### User Feedback to Skill Developers

Users can provide feedback about this skill directly through the Hopkin Mailchimp MCP. If a user wants to suggest improvements, report issues, or request new capabilities, call `mailchimp_developer_feedback` on their behalf with the appropriate `feedback_type` (`new_tool`, `improvement`, `bug`, or `workflow_gap`) and include their feedback in the `description`.

## Report Workflows

### Campaign Performance Report

Analyze the performance of sent email campaigns — opens, clicks, bounces, revenue, and how they compare to industry benchmarks.

**Primary tool:** `mailchimp_get_campaign_report` — provides full performance metrics for a sent campaign

**See detailed workflow:** **references/workflows/campaign-performance.md**

---

### Audience Insights Report

Analyze audience health and growth — subscriber trends, engagement patterns, email client distribution, and geographic breakdown.

**Primary tool:** `mailchimp_get_audience_insights` — fetches growth history, activity, clients, and locations in parallel

**See detailed workflow:** **references/workflows/audience-insights.md**

---

### Subscriber Analysis

Examine individual subscribers — their status, merge fields, activity history, and engagement patterns.

**Primary tools:** `mailchimp_list_subscribers` + `mailchimp_get_subscriber` with `include_activity: true`

**See detailed workflow:** **references/workflows/subscriber-analysis.md**

---

### Automation Review

Review automation sequences — status, email performance, and delivery metrics across the automation workflow.

**Primary tools:** `mailchimp_list_automations` + `mailchimp_get_automation`

**See detailed workflow:** **references/workflows/automation-review.md**

---

## Workflow Process

1. **Account Selection**: If multiple accounts, use `mailchimp_list_accounts` and ask which to use
2. **Audience Selection**: Most operations require an audience ID — use `mailchimp_list_audiences` and ask user which audience
3. **Report Type Selection**: Determine which report type matches user intent
4. **Report Generation**: Use the appropriate Hopkin MCP tool(s)
5. **Output Formatting**: Present data in clear tables with insights and actionable recommendations

## Best Practices

### Metric Interpretation Guidelines

Choose context appropriate to the analysis:
- **Campaign Engagement:** Open rate, click rate, click-to-open rate, unsubscribe rate
- **Deliverability:** Bounce rate (hard vs soft), abuse complaints, delivery rate
- **Audience Health:** Growth rate, churn rate, list rating, engagement distribution
- **Revenue (if ecommerce):** Total revenue, revenue per email, average order value

### Industry Benchmarks

Campaign reports include industry comparison stats. Always highlight how the user's metrics compare to their industry average — this provides immediate context for whether performance is good or needs improvement.

### Report Formatting Preferences

- Use tables for multi-row data with consistent columns
- Use percentage format for rates (e.g., 24.5% open rate)
- Use currency symbols for monetary values (e.g., $1,234.56)
- Use thousands separators for large numbers (e.g., 1,234,567)
- Round appropriately: currency to 2 decimals, percentages to 1-2 decimals, counts to integers
- Sort meaningfully by the most relevant metric
- Include report metadata (campaign name, audience name, date sent)

### Error Handling Patterns

When errors occur:

1. **Check authentication** — Run `mailchimp_check_auth_status`; if not authenticated, direct the user to connect their account at https://app.hopkin.ai
2. **Validate inputs** — Ensure audience_id and campaign_id are correct
3. **Inspect error messages** — Hopkin errors include specific guidance
4. **Check campaign status** — Campaign reports require the campaign to be in "sent" status
5. **Consult troubleshooting guide** — See references/troubleshooting.md

---

## Troubleshooting

For detailed troubleshooting guidance, see **references/troubleshooting.md**.

Common quick fixes:

- **"MCP server not found"** — Verify Hopkin MCP configuration and token
- **"Not authenticated"** — Run `mailchimp_check_auth_status`; direct user to connect their account at https://app.hopkin.ai
- **"Campaign not sent"** — Campaign reports only work for campaigns with "sent" status
- **"Audience not found"** — Verify audience ID with `mailchimp_list_audiences`
- **"No data available"** — Check that the audience has subscribers or the campaign has been sent

---

## Additional Resources

For more detailed information:

- **references/mcp-tools-reference.md** — Complete Hopkin MCP tool documentation, parameters, and usage examples
- **references/troubleshooting.md** — Comprehensive error solutions and debugging steps
- **references/workflows/campaign-performance.md** — Detailed campaign performance report workflow
- **references/workflows/audience-insights.md** — Detailed audience insights report workflow
- **references/workflows/subscriber-analysis.md** — Detailed subscriber analysis workflow
- **references/workflows/automation-review.md** — Detailed automation review workflow

---

**Skill Version:** 1.0
**Last Updated:** 2026-04-14
**Requires:** Hopkin Mailchimp MCP (https://app.hopkin.ai)
