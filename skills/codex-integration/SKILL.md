---
name: Codex Integration
description: Use this skill when delegating complex coding tasks to OpenAI Codex CLI and coordinating work between Claude and Codex.
---

# Codex Integration Skill

This skill defines delegation patterns for Codex-assisted coding.

## Pre-check

Before Codex operations:
1. Check for `.codex/config.toml`.
2. If missing, ask user before bootstrapping.
3. Bootstrap using `skills/codex-ecosystem/SKILL.md` guidance after confirmation.

## Default configuration

```toml
model = "gpt-5.2-codex"
model_reasoning_effort = "high"
sandbox = "workspace-write"
approval_policy = "on-request"
```

## When to delegate

Delegate when tasks are multi-file, long-running, architecture-heavy, or require deep analysis.

## Interaction modes

### MCP mode
Use `mcp__codex-native__codex` and `mcp__codex-native__codex-reply` for interactive multi-turn work.

### Headless mode
Use `codex exec` for one-off scripted tasks.

### Background mode
Use background execution for long tasks and summarize results after completion.

## Session handling

- `threadId` should be preserved for follow-up calls.
- Session bookkeeping in `scripts/codex-interactive.py` is process-local and in-memory.

## Model selection

- Simple: `gpt-5.2-codex` + medium reasoning
- Medium: `gpt-5.2-codex` + high reasoning
- Complex: `gpt-5.2-codex` + xhigh reasoning
- Critical/security: `gpt-5.1-codex-max` + xhigh reasoning

## Best practices

1. Keep prompts specific.
2. Validate outputs before applying.
3. Ask before enabling MCP servers or writing config files.
4. Enable only MCPs needed for the current task.

## References

- `references/codex-cli-reference.md`
- `examples/delegation-patterns.md`
- `skills/codex-ecosystem/SKILL.md`
