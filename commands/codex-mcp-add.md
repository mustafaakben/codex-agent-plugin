---
name: codex-mcp-add
description: Enable a curated MCP server in project Codex config, or add a custom server block.
argument-hint: '<server-name> ["custom command or url"]'
arguments:
  - name: server
    description: "Curated server name or custom server name"
    required: true
  - name: command
    description: "Custom stdio command or URL info for non-curated servers"
    required: false
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
---

# Enable MCP Server

## Curated servers

- `context7`
- `playwright`
- `postgres`
- `filesystem`
- `github`

## Workflow

1. Check `.codex/config.toml`.
2. If missing, explain bootstrap and ask for confirmation.
3. For curated names, uncomment existing block.
4. For custom names, append a new block only with user confirmation.
5. Summarize required environment variables.

## Environment variable reminders

- `postgres`: `DATABASE_URL`

## Output

Return:
- server name
- whether enabled or newly added
- config file changed
- any required env vars
