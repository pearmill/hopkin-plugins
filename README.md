# Pearmill Skills

Collection of Claude Skills for common workflows and integrations.

## Available Skills

- **google-ads** - Google Ads performance reports and analytics
- **meta-ads** - Meta Ads reporting and campaign management skill

## Packaging Skills

Use the `package-skill.sh` script to create versioned zip archives of skills.

### Usage

```bash
./package-skill.sh <skill-name> [version]
```

### Examples

**Package with auto-detected version:**
```bash
./package-skill.sh meta-ads
```
The script will automatically extract the version from the skill's SKILL.md file.

**Package with specific version:**
```bash
./package-skill.sh meta-ads 1.0.1
```

**Package with custom version:**
```bash
./package-skill.sh meta-ads 2.0.0-beta
```

### Output

Packaged skills are saved to the `releases/` directory with the naming format:
```
releases/<skill-name>-v<version>.zip
```

Example: `releases/meta-ads-v1.0.zip`

### What Gets Packaged

The script includes:
- All skill files (SKILL.md, reference files, workflows, etc.)
- Preserves directory structure

The script excludes:
- `.git` directory
- `node_modules`
- `.DS_Store` files
- Python cache files (`__pycache__`, `*.pyc`)
- IDE configuration (`.vscode`, `.idea`)

### Version Detection

The script automatically detects the version from the skill's SKILL.md file by looking for:
```markdown
**Skill Version:** 1.0
```

If no version is found, it falls back to a timestamp-based version (e.g., `20260119-171900`).

## Directory Structure

```
pearmill-skills/
├── README.md                    # This file
├── package-skill.sh             # Packaging script
├── releases/                    # Packaged skill zip files
│   ├── google-ads-v1.0.zip
│   └── meta-ads-v1.0.zip
├── google-ads/                  # Google Ads skill
│   ├── SKILL.md
│   └── references/
│       ├── mcp-tools-reference.md
│       ├── troubleshooting.md
│       └── workflows/
│           ├── ad-performance.md
│           ├── budget-spend.md
│           ├── campaign-performance.md
│           └── keyword-analysis.md
└── meta-ads/                    # Meta Ads skill
    ├── SKILL.md
    └── references/
        ├── report-types.md
        ├── mcp-tools-reference.md
        ├── troubleshooting.md
        └── workflows/
            ├── campaign-performance.md
            ├── ad-creative-performance.md
            ├── audience-insights.md
            ├── budget-pacing.md
            └── common-actions.md
```

## Adding New Skills

1. Create a new directory with the skill name (e.g., `my-skill`)
2. Add a `SKILL.md` file with proper frontmatter and version
3. Add any reference documentation as needed
4. Package using `./package-skill.sh my-skill`
