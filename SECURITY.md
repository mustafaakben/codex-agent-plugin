# Security policy

## Reporting a vulnerability

If you find a security issue in this plugin, please **do not open a public issue**. Instead, email mustafaakben@users.noreply.github.com with:

- A description of the vulnerability
- Steps to reproduce
- The impact you've identified

You should receive a response within 72 hours.

## Scope

This plugin runs shell scripts via Claude Code hooks and delegates tasks to Codex CLI via MCP. The main attack surfaces are:

- **Hook scripts** (`hooks/*.sh`) — these run with the same permissions as Claude Code
- **MCP server registration** (`.mcp.json`) — defines how Codex CLI is invoked
- **Config template** (`.codex/config.template.toml`) — defaults applied to new projects

## Design principles

- The plugin never creates or modifies project files without explicit user confirmation
- Codex MCP calls are blocked by a PreToolUse hook if `.codex/config.toml` doesn't exist
- All hook scripts use `set -euo pipefail` and avoid shell injection vectors
- No secrets are stored in plugin files; Codex CLI manages its own authentication
