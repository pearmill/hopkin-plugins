# Pearmill Skills

Collection of Claude Skills for common workflows and integrations. Each skill is also a Claude Code plugin that ships with its MCP server.

## Available Skills

- **hopkin-meta-ads** - Meta Ads performance reports and analytics via Hopkin MCP
- **hopkin-google-ads** - Google Ads performance reports and analytics via Hopkin MCP

## Install as Claude Code Plugins

Add this repo as a plugin marketplace, then install individual plugins:

```bash
/plugin marketplace add pearmill/claude-skills
/plugin install hopkin-meta-ads@pearmill
/plugin install hopkin-google-ads@pearmill
```

Each plugin ships with the Hopkin MCP server configured automatically. Users authenticate through the MCP's built-in OAuth flow (via https://app.hopkin.ai).

## Packaging Skills

Use the `package-plugin.sh` script to create versioned zip archives of skills.

### Usage

```bash
./package-plugin.sh <skill-name> [version]
```

### Examples

**Package with auto-detected version:**
```bash
./package-plugin.sh hopkin-meta-ads
```

**Package with specific version:**
```bash
./package-plugin.sh hopkin-meta-ads 1.0.1
```

### Output

Packaged skills are saved to the `releases/` directory with the naming format:
```
releases/<skill-name>-v<version>.zip
```

## Directory Structure

```
pearmill-skills/
├── .claude-plugin/
│   └── marketplace.json             # Plugin marketplace catalog
├── README.md
├── package-plugin.sh                 # Packaging script
├── hopkin-meta-ads/                 # Meta Ads plugin
│   ├── .claude-plugin/
│   │   └── plugin.json              # Plugin manifest
│   ├── .mcp.json                    # MCP server config (remote URL)
│   ├── .version
│   └── skills/
│       └── hopkin-meta-ads/
│           ├── SKILL.md
│           └── references/
│               ├── mcp-tools-reference.md
│               ├── report-types.md
│               ├── troubleshooting.md
│               └── workflows/
└── hopkin-google-ads/               # Google Ads plugin
    ├── .claude-plugin/
    │   └── plugin.json
    ├── .mcp.json
    ├── .version
    └── skills/
        └── hopkin-google-ads/
            ├── SKILL.md
            └── references/
                ├── mcp-tools-reference.md
                ├── troubleshooting.md
                └── workflows/
```

## Adding New Skills

1. Create a new directory with the skill name (e.g., `my-skill`)
2. Create the plugin structure:
   - `.claude-plugin/plugin.json` with name, version, description
   - `.mcp.json` with the MCP server URL config
   - `skills/<skill-name>/SKILL.md` with the skill content
   - `skills/<skill-name>/references/` for reference documentation
3. Add the plugin to `.claude-plugin/marketplace.json`
4. Package using `./package-plugin.sh my-skill`
