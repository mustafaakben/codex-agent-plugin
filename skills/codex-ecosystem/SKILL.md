---
name: Codex Ecosystem Setup
description: Use this skill to initialize Codex configuration and manage MCP servers in a project after confirming with the user.
---

# Codex Ecosystem Setup Skill

This skill handles bootstrap and MCP management for Codex projects.

## Bootstrap policy

Do not create or modify `.codex/` automatically on plugin activation.

Use this policy:
1. Check whether `.codex/config.toml` exists.
2. If missing, explain what will be created.
3. Ask for confirmation.
4. Create files only after confirmation.

## Bootstrap actions

When approved by the user:

```bash
mkdir -p .codex
cp "${CLAUDE_PLUGIN_ROOT}/.codex/config.template.toml" .codex/config.toml
cp "${CLAUDE_PLUGIN_ROOT}/.codex/recommended-mcps.toml" .codex/recommended-mcps.toml
```

If plugin-root files are unavailable, create `.codex/config.toml` with safe defaults:

```toml
model = "gpt-5.4"
model_reasoning_effort = "xhigh"
sandbox_mode = "workspace-write"
approval_policy = "on-request"
```

## Curated MCP set

Only the verified set is considered curated here:
- `context7`
- `playwright`
- `postgres`
- `filesystem`
- `github`

All are disabled by default in template config.

## MCP enablement workflow

1. Analyze task requirements.
2. Suggest relevant MCP(s).
3. Ask before changing `.codex/config.toml`.
4. Enable only requested MCP(s).
5. Remind about required environment variables.

## Notes

- Prefer minimal enablement.
- Use `recommended-mcps.toml` for server reference blocks.
- For non-curated MCPs, use `/codex-mcp-search` and manual user confirmation.

## References

- `skills/codex-integration/references/codex-prompt-guidance.md` — GPT-5.4 prompt patterns
- `skills/codex-integration/references/codex-cli-reference.md` — CLI commands and config
