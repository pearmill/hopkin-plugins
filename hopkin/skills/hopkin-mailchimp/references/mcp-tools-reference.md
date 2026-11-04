# Mailchimp MCP Tools Reference — Hopkin

Complete parameter reference for all Hopkin Mailchimp MCP tools. For setup and authentication, see **SKILL.md**.

---

## Core Tools

> **Important:** Every Hopkin tool call requires a `reason` (string) parameter for audit trail.

### Authentication Tools

#### mailchimp_check_auth_status
Check whether the user has authenticated their Mailchimp account. Only call this when another tool returns a permission or authentication error — do not call proactively.

**Parameters:**
- `reason` (string, required) — Reason for the call

#### mailchimp_ping
Health check. Verify the MCP server is reachable and returns version/timestamp.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `message` (string, optional) — Optional echo message

---

### Account Tools

#### mailchimp_list_accounts
List all Mailchimp accounts connected for the authenticated user. Returns account IDs, names, data centers, and login emails.

**Parameters:**
- `reason` (string, required) — Reason for the call

---

### Audience Tools

#### mailchimp_list_audiences
List all audiences (lists) in the Mailchimp account with name search and pagination. Returns member count, open rate, click rate, and list rating for each audience.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, optional) — Mailchimp account ID. Required when multiple accounts are connected.
- `search` (string, optional) — Filter audiences by name (case-insensitive substring match)
- `limit` (number, optional, default: 20) — Maximum results (1-100)
- `cursor` (string, optional) — Pagination cursor from a previous response
- `refresh` (boolean, optional, default: false) — Force a fresh fetch bypassing cache

#### mailchimp_get_audience
Get detailed information about a specific Mailchimp audience (list), including stats, settings, and campaign defaults.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, optional) — Mailchimp account ID
- `audience_id` (string, required) — The Mailchimp audience (list) ID

---

### Subscriber Tools

#### mailchimp_list_subscribers
List subscribers (members) of a Mailchimp audience with status filtering, email search, and pagination.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, optional) — Mailchimp account ID
- `audience_id` (string, required) — The Mailchimp audience (list) ID
- `status` (array of strings, optional) — Filter by status: `subscribed`, `unsubscribed`, `cleaned`, `pending`, `transactional`
- `search` (string, optional) — Search by email address or name
- `limit` (number, optional, default: 20) — Maximum results (1-100)
- `cursor` (string, optional) — Pagination cursor

#### mailchimp_get_subscriber
Get detailed information about a specific subscriber by email address or MD5 hash. Optionally includes recent activity feed.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, optional) — Mailchimp account ID
- `audience_id` (string, required) — The Mailchimp audience (list) ID
- `email_or_hash` (string, required) — Email address or MD5 subscriber hash
- `include_activity` (boolean, optional, default: false) — Include recent activity feed

---

### Campaign Tools

#### mailchimp_list_campaigns
List campaigns in the Mailchimp account with status filtering, title search, and pagination.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, optional) — Mailchimp account ID
- `status` (array of strings, optional) — Filter by status: `save`, `paused`, `schedule`, `sending`, `sent`, `canceled`, `canceling`, `archived`
- `search` (string, optional) — Filter by title (case-insensitive substring match)
- `limit` (number, optional, default: 20) — Maximum results (1-100)
- `cursor` (string, optional) — Pagination cursor
- `refresh` (boolean, optional, default: false) — Force fresh fetch bypassing cache

#### mailchimp_get_campaign
Get detailed information about a specific Mailchimp campaign. Optionally includes content preview and send checklist.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, optional) — Mailchimp account ID
- `campaign_id` (string, required) — The Mailchimp campaign ID
- `include_content` (boolean, optional, default: false) — Include HTML/text content preview (truncated to 5000 chars)
- `include_send_checklist` (boolean, optional, default: false) — Include the send checklist

---

### Automation Tools

#### mailchimp_list_automations
List automations (classic automations / customer journeys) with status filtering, title search, and pagination.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, optional) — Mailchimp account ID
- `status` (array of strings, optional) — Filter by status: `save`, `paused`, `sending`
- `search` (string, optional) — Filter by title (case-insensitive substring match)
- `limit` (number, optional, default: 20) — Maximum results (1-100)
- `cursor` (string, optional) — Pagination cursor
- `refresh` (boolean, optional, default: false) — Force fresh fetch bypassing cache

#### mailchimp_get_automation
Get detailed information about a specific automation including all associated emails with their delivery stats.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, optional) — Mailchimp account ID
- `automation_id` (string, required) — The Mailchimp automation ID

---

### Template Tools

#### mailchimp_list_templates
List email templates with type filtering, name search, and pagination.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, optional) — Mailchimp account ID
- `search` (string, optional) — Filter by name (case-insensitive substring match)
- `type` (string, optional) — Filter by type: `user`, `base`, `gallery`
- `limit` (number, optional, default: 20) — Maximum results (1-100)
- `cursor` (string, optional) — Pagination cursor
- `refresh` (boolean, optional, default: false) — Force fresh fetch bypassing cache

---

### Reporting Tools

#### mailchimp_get_campaign_report
Get a detailed performance report for a sent Mailchimp campaign. Includes opens, clicks, bounces, forwards, ecommerce, delivery status, and industry comparison stats.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, optional) — Mailchimp account ID
- `campaign_id` (string, required) — The Mailchimp campaign ID. Campaign must be in "sent" status.

**Response includes:**
- Opens: total opens, unique opens, open rate
- Clicks: total clicks, unique clicks, click rate, click-to-open rate
- Bounces: hard bounces, soft bounces, syntax errors
- Forwards: forward count, forward opens
- Ecommerce: total orders, total revenue, total spent
- Delivery: emails sent, delivered, delivery rate
- Industry stats: open rate, click rate, bounce rate (for comparison)
- Unsubscribes, abuse reports

#### mailchimp_get_audience_insights
Get insights for a Mailchimp audience including growth history, activity, email clients, and geographic locations.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, optional) — Mailchimp account ID
- `audience_id` (string, required) — The Mailchimp audience/list ID
- `include_growth_history` (boolean, optional, default: true) — Include growth history data
- `include_activity` (boolean, optional, default: true) — Include activity data
- `include_clients` (boolean, optional, default: true) — Include email client data
- `include_locations` (boolean, optional, default: true) — Include geographic location data

#### mailchimp_get_email_activity
Get email activity (opens, clicks, bounces) for individual recipients of a sent campaign.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, optional) — Mailchimp account ID
- `campaign_id` (string, required) — The Mailchimp campaign ID
- `limit` (number, optional, default: 20) — Maximum results (1-100)
- `cursor` (string, optional) — Pagination cursor

---

### Segment Tools

#### mailchimp_list_segments
List segments for a Mailchimp audience with optional type filtering and pagination.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, optional) — Mailchimp account ID
- `audience_id` (string, required) — The Mailchimp audience/list ID
- `type` (string, optional) — Filter by type: `saved`, `static`, `fuzzy`
- `limit` (number, optional, default: 20) — Maximum results (1-100)
- `cursor` (string, optional) — Pagination cursor

---

### Tag Tools

#### mailchimp_list_tags
List tags for a Mailchimp audience with pagination.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `account_id` (string, optional) — Mailchimp account ID
- `audience_id` (string, required) — The Mailchimp audience/list ID
- `limit` (number, optional, default: 20) — Maximum results (1-100)
- `cursor` (string, optional) — Pagination cursor

---

### Developer Feedback

#### mailchimp_developer_feedback
Submit feedback about missing tools, improvements, or workflow gaps.

**Parameters:**
- `reason` (string, required) — Reason for the call
- `feedback_type` (string, required) — Category: `new_tool`, `improvement`, `bug`, `workflow_gap`
- `title` (string, required) — Concise title (5-200 chars)
- `description` (string, required) — What is needed and why (20-2000 chars)
- `current_workaround` (string, optional) — Current workaround if any
- `priority` (string, optional, default: `medium`) — Impact: `low`, `medium`, `high`

---

## Pagination

List tools support cursor-based pagination. Pass the `cursor` from a previous response to get the next page. Continue until no cursor is returned.

## Error Handling

See **troubleshooting.md** for detailed error solutions.
