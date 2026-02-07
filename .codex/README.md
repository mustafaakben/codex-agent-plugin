# .codex Configuration Directory

This directory contains templates used by the `agent-codex` plugin.

## What ships in this plugin repo

- `config.template.toml`: Template used to create a project-local `.codex/config.toml`
- `recommended-mcps.toml`: Curated MCP reference entries

## What is generated in user projects

The active file `.codex/config.toml` is created in the target project when the user asks to initialize Codex configuration.

## Default configuration

```toml
model = "gpt-5.2-codex"
model_reasoning_effort = "high"
sandbox = "workspace-write"
approval_policy = "on-request"
```

## Curated MCP servers in template

- `context7`
- `playwright`
- `postgres`
- `filesystem`
- `github`

All MCP entries are disabled by default and can be enabled when needed.

## Commands

- `/agent-codex:codex-config`
- `/agent-codex:codex-config init`
- `/agent-codex:codex-config enable-mcp <name>`
- `/agent-codex:codex-mcp-add <name>`

## Notes

- Always confirm before creating or modifying configuration files.
- Verify environment variables before enabling database or API MCP servers.
