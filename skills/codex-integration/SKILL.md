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
model = "gpt-5.4"
model_reasoning_effort = "xhigh"
sandbox_mode = "workspace-write"
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

- Simple: `gpt-5.4` + low reasoning
- Medium: `gpt-5.4` + medium reasoning
- Complex: `gpt-5.4` + high reasoning
- Critical/security: `gpt-5.4` + xhigh reasoning

## Prompt guidance

When crafting prompts for Codex, follow the GPT-5.4 prompt patterns in `references/codex-prompt-guidance.md`. Key patterns:
- Use **output contracts** to constrain what and how much the model outputs.
- Use **tool persistence rules** so Codex doesn't stop early.
- Use **completeness contracts** for multi-step or batch tasks.
- Use **verification loops** before finalizing results.
- For coding tasks, apply **autonomy & persistence** — Codex should carry changes through implementation, not stop at analysis.

## Best practices

1. Keep prompts specific — follow prompt guidance patterns.
2. Validate outputs before applying.
3. Ask before enabling MCP servers or writing config files.
4. Enable only MCPs needed for the current task.
5. Use dependency checking for multi-step workflows.
6. Apply action safety frames for irreversible operations.

## References

- `references/codex-cli-reference.md` — CLI commands, flags, config
- `references/codex-prompt-guidance.md` — GPT-5.4 prompt patterns and best practices
- `examples/delegation-patterns.md` — delegation examples
- `skills/codex-ecosystem/SKILL.md` — bootstrap and MCP setup
