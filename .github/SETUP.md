# GitHub Workflow Setup Guide

This guide walks you through setting up the automated skill release workflow that detects changes, packages skills, creates GitHub releases, and integrates with Notion and Slack.

## Overview

The workflow automatically:
1. Detects changes to skill directories when pushed to main
2. Reads current version from `.version` file and bumps it automatically
3. Packages skills using package-skill.sh
4. Creates GitHub releases with changelog
5. Commits the updated version back to the repository
6. Uploads release info to Notion database
7. Sends notifications to Slack

## Version Management

Versions are managed automatically by the workflow:
- Each skill has a `.version` file in its directory (e.g., `google-ads/.version`)
- The file contains a single line with the version number (e.g., `1.2.0`)
- When changes are detected, the workflow automatically bumps the minor version (e.g., `1.2.0` → `1.3.0`)
- If no `.version` file exists, it starts with `1.0.0`
- The updated version is committed back to the repository with message `chore: bump {skill} version to {version} [skip ci]`

**Important**: The `[skip ci]` tag in the commit message prevents the workflow from triggering again when the `.version` file is committed, avoiding an infinite loop. The workflow only processes actual skill content changes, not version file updates.

## Prerequisites

- Repository admin access
- Notion workspace access
- Slack workspace admin access

## Setup Steps

### 1. Configure Notion Integration

#### Create Notion Integration
1. Go to [Notion Integrations](https://www.notion.so/my-integrations)
2. Click "New integration"
3. Configure:
   - Name: `Pearmill Skills Release Bot`
   - Associated workspace: Select your workspace
   - Type: Internal integration
   - Capabilities: Check "Insert content"
4. Click "Submit"
5. Copy the **Internal Integration Token** (starts with `secret_`)

#### Share Database with Integration
1. Open your Notion database at: https://notion.so/2efade1c60188049a0f8ea158d9313c5
2. Click the "..." menu in the top right
3. Scroll to "Connections" → Click "Connect to"
4. Search for and select "Pearmill Skills Release Bot"
5. Click "Confirm"

#### Verify Database Properties
Ensure your database has these properties:
- **Name** (Title type)
- **Version** (Text type)
- **Release Date** (Date type)
- **GitHub URL** (URL type)
- **Download URL** (URL type)

### 2. Configure Slack Integration

#### Create Incoming Webhook
1. Go to [Slack API](https://api.slack.com/apps)
2. Click "Create New App" → "From scratch"
3. Configure:
   - App Name: `Skill Release Notifications`
   - Workspace: Select your workspace
4. Click "Create App"
5. Navigate to "Incoming Webhooks" in the sidebar
6. Toggle "Activate Incoming Webhooks" to **On**
7. Click "Add New Webhook to Workspace"
8. Select the channel where notifications should be posted (e.g., `#releases` or `#engineering`)
9. Click "Allow"
10. Copy the **Webhook URL** (starts with `https://hooks.slack.com/services/`)

### 3. Configure GitHub Secrets

#### Add Repository Secrets
1. Go to your repository on GitHub
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click "New repository secret"
4. Add these secrets:

**NOTION_API_KEY**
- Name: `NOTION_API_KEY`
- Secret: Paste the Notion Internal Integration Token from Step 1
- Click "Add secret"

**SLACK_WEBHOOK_URL**
- Name: `SLACK_WEBHOOK_URL`
- Secret: Paste the Slack Webhook URL from Step 2
- Click "Add secret"

Note: The `GITHUB_TOKEN` is automatically provided by GitHub Actions.

#### Verify Secrets
After adding, you should see:
- `NOTION_API_KEY` ✓
- `SLACK_WEBHOOK_URL` ✓

### 4. Workflow Permissions

Ensure the workflow has permissions to create releases:

1. Go to **Settings** → **Actions** → **General**
2. Scroll to "Workflow permissions"
3. Select "Read and write permissions"
4. Check "Allow GitHub Actions to create and approve pull requests"
5. Click "Save"

## Testing the Workflow

### Option 1: Manual Trigger (Recommended for Initial Testing)

1. Go to **Actions** tab in your repository
2. Select "Detect and Release Skills" workflow
3. Click "Run workflow"
4. Select branch: `main`
5. Enter skill name (e.g., `google-ads`) or leave empty for auto-detection
6. Click "Run workflow"

### Option 2: Test with Skill Change

1. Create a test branch:
   ```bash
   git checkout -b test-release-workflow
   ```

2. Make a change to any skill file:
   ```bash
   # Edit any file in a skill directory, for example:
   echo "# Test update" >> google-ads/SKILL.md
   ```

3. Commit and push:
   ```bash
   git add google-ads/SKILL.md
   git commit -m "test: trigger release workflow for google-ads"
   git push origin test-release-workflow
   ```

4. Merge to main (or create PR and merge):
   ```bash
   git checkout main
   git merge test-release-workflow
   git push origin main
   ```

5. The workflow will:
   - Detect the change to `google-ads`
   - Read or create `google-ads/.version` (starting with `1.0.0` if new)
   - Bump the version to `1.1.0`
   - Create the release
   - Commit the updated `.version` file back to main

### Verification Checklist

After triggering the workflow, verify:

- [ ] **GitHub Actions**: Workflow runs successfully
  - Check: Actions tab → Latest workflow run shows ✓
  - Verify: Both `detect-changes` and `release-skill` jobs complete

- [ ] **Version File**: Version file created and committed
  - Check: `{skill}/.version` file exists in repository
  - Verify: Contains version number (e.g., `1.1.0`)
  - Verify: Commit message shows `chore: bump {skill} version to {version} [skip ci]`

- [ ] **GitHub Release**: Release created with correct assets
  - Check: Releases page shows new release
  - Verify: Tag format is `{skill-name}-v{version}` (e.g., `google-ads-v1.1.0`)
  - Verify: ZIP file is attached as asset
  - Verify: Changelog shows commit history

- [ ] **Notion**: Entry created in database
  - Check: Open database https://notion.so/2efade1c60188049a0f8ea158d9313c5
  - Verify: New row with skill name, version, release date
  - Verify: GitHub URL and Download URL are clickable and correct

- [ ] **Slack**: Notification received in channel
  - Check: Notification posted in configured channel
  - Verify: Contains skill name, version, download link
  - Verify: Changelog preview is visible
  - Verify: Links to GitHub release and Notion work

- [ ] **Idempotency**: Re-running workflow doesn't duplicate release
  - Manually trigger workflow again with same skill
  - Verify: Workflow detects existing tag and skips release steps

## Troubleshooting

### Workflow Fails at "Upload to Notion"

**Symptom**: Error like `Could not find database with ID`

**Solution**:
1. Verify database ID is correct: `2efade1c60188049a0f8ea158d9313c5`
2. Confirm integration is connected to database (Step 1)
3. Check NOTION_API_KEY secret is set correctly

### Workflow Fails at "Send Slack notification"

**Symptom**: Error like `url_verification_failed`

**Solution**:
1. Verify SLACK_WEBHOOK_URL secret is set correctly
2. Check webhook URL is still active in Slack app settings
3. Ensure the channel still exists

### Workflow Doesn't Trigger on Push

**Symptom**: No workflow run after pushing changes

**Solution**:
1. Verify changes are in monitored paths:
   - `*/SKILL.md`
   - `*/references/**`
   - `*/.claude/**`
2. Confirm push is to `main` branch
3. Check workflow file is in `.github/workflows/` on main branch

### Version File Issues

**Symptom**: Error reading or writing `.version` file

**Solution**:
1. Ensure `.version` file contains only the version number (e.g., `1.2.0`)
2. Check file is not corrupted or contains extra whitespace
3. If missing, the workflow will automatically create it starting with `1.0.0`
4. Verify workflow has write permissions to commit changes (see Workflow Permissions section)

### Duplicate Releases Created

**Symptom**: Multiple releases for same version

**Solution**:
1. This shouldn't happen due to idempotency check
2. If it occurs, manually delete duplicate releases:
   ```bash
   gh release delete {skill}-v{version} --yes
   git push --delete origin {skill}-v{version}
   ```
3. Check workflow logs to see why tag check failed

### Package File Not Found

**Symptom**: Error `Package file not created`

**Solution**:
1. Verify `package-skill.sh` exists and is executable
2. Check script runs successfully locally:
   ```bash
   ./package-skill.sh google-ads 1.0.0
   ```
3. Ensure `releases/` directory is in .gitignore (shouldn't be committed)

## Maintenance

### Updating Notion Database Properties

If you need to add/modify Notion properties:

1. Update database schema in Notion
2. Modify workflow file at `.github/workflows/detect-and-release-skills.yml`
3. Find the "Upload to Notion" step
4. Update the properties JSON in the curl request

### Changing Slack Message Format

To customize Slack notifications:

1. Edit workflow file at `.github/workflows/detect-and-release-skills.yml`
2. Find the "Send Slack notification" step
3. Modify the Block Kit JSON structure
4. Test with [Block Kit Builder](https://app.slack.com/block-kit-builder)

### Adding More Trigger Paths

To monitor additional directories:

1. Edit workflow file
2. Update the `paths:` section under `on: push:`
3. Add new glob patterns (e.g., `*/docs/**`)

## Support

If you encounter issues not covered here:

1. Check workflow run logs in Actions tab for detailed error messages
2. Review recent changes to workflow file
3. Verify all secrets are still valid and haven't expired
4. Test integrations independently (Notion API, Slack webhook)

## Rollback Procedure

If the workflow causes issues:

1. **Disable automatic triggers**:
   ```yaml
   # Comment out in workflow file:
   # on:
   #   push:
   #     branches:
   #       - main

   # Keep only manual trigger:
   on:
     workflow_dispatch:
   ```

2. **Delete problematic release**:
   ```bash
   gh release delete {skill}-v{version} --yes
   git push --delete origin {skill}-v{version}
   ```

3. **Fix issues and re-test** with manual trigger

4. **Re-enable automatic trigger** once validated
