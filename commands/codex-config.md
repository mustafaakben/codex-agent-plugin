---
name: codex-config
description: Manage project Codex configuration and MCP enablement.
argument-hint: '[action:show|init|set|enable-mcp|disable-mcp|reset] [key] [value]'
arguments:
  - name: action
    description: "Action: show, init, set, enable-mcp, disable-mcp, reset"
    required: false
  - name: key
    description: "Configuration key or MCP server name"
    required: false
  - name: value
    description: "Value for the configuration key"
    required: false
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
---

# Codex Configuration Manager

## Actions

### `show` (default)
- Show project `.codex/config.toml` if present.
- Show global `~/.codex/config.toml` if present.
- List enabled vs commented MCP blocks.

### `init`
- Explain files to be created.
- Ask for confirmation.
- Create `.codex/config.toml` from `.codex/config.template.toml` after confirmation.

### `set`
- Update one key in `.codex/config.toml`.
- Supported keys: `model`, `sandbox`, `approval_policy`, `model_reasoning_effort`.

### `enable-mcp`
- Enable a curated MCP block by uncommenting it in `.codex/config.toml`.
- Curated set: `context7`, `playwright`, `postgres`, `filesystem`, `github`.
- Ask before file modification.

### `disable-mcp`
- Comment out the target MCP block.
- Ask before file modification.

### `reset`
- Backup existing config to `.codex/config.toml.bak`.
- Restore defaults from template.
- Ask before file modification.

## Notes

- Prefer minimal MCP enablement.
- For non-curated servers, use `/codex-mcp-search` and add manually.
