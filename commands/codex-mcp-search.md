---
name: codex-mcp-search
description: Search for MCP servers (typically on GitHub/npm) when curated servers are insufficient.
argument-hint: '<search query>'
arguments:
  - name: query
    description: Search term, e.g. "kubernetes", "redis", "graphql"
    required: true
allowed-tools:
  - WebSearch
  - WebFetch
  - Read
---

# MCP Server Search

Search for MCP servers matching `$ARGUMENTS.query`.

## Evaluation criteria

1. Active maintenance (recent updates)
2. Clear setup docs
3. Installability and package availability
4. Security posture and trustworthiness

## Output format

For each option include:
- repository URL
- install command or URL
- last update signal
- setup requirements (env vars/auth)

Then provide:
- best overall recommendation
- safest option
- easiest to integrate option

## Safety notes

- Prefer trusted maintainers.
- Avoid adding servers without reviewing setup and permissions.
- Ask before modifying `.codex/config.toml`.
