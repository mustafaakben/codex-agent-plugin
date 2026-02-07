---
name: codex
description: Delegate a coding task to OpenAI Codex CLI. Checks project config and runs via MCP or exec mode.
argument-hint: '"task description" [mode:mcp|exec|interactive] [complexity:simple|medium|complex|critical]'
arguments:
  - name: task
    description: The coding task to delegate to Codex
    required: true
  - name: mode
    description: "Interaction mode: mcp (default), exec, or interactive"
    required: false
  - name: complexity
    description: "Task complexity: simple, medium, complex, critical"
    required: false
allowed-tools:
  - mcp__codex-native__codex
  - mcp__codex-native__codex-reply
  - Bash
  - Read
  - Write
  - Glob
---

# Codex Task Delegation

## Inputs

- Task: `$ARGUMENTS.task`
- Mode: `$ARGUMENTS.mode` (default `mcp`)
- Complexity: `$ARGUMENTS.complexity` (default `medium`)

## Bootstrap policy

Before running Codex, check for `.codex/config.toml`.

If missing:
1. Explain what files will be created.
2. Ask for confirmation.
3. Create `.codex/config.toml` only after confirmation.

## Curated MCPs

Use these verified MCP names when relevant:
- `context7`
- `playwright`
- `postgres`
- `filesystem`
- `github`

If enabling MCPs is required, ask before modifying config.

## Complexity mapping

- `simple`: `gpt-5.2-codex`, reasoning `medium`
- `medium`: `gpt-5.2-codex`, reasoning `high`
- `complex`: `gpt-5.2-codex`, reasoning `xhigh`
- `critical`: `gpt-5.1-codex-max`, reasoning `xhigh`

## Modes

### `mcp` (default)
Use `mcp__codex-native__codex`.
Capture `threadId` and use `mcp__codex-native__codex-reply` for follow-ups.

### `exec`
Use `codex exec` with explicit model/sandbox/JSON flags.

### `interactive`
Recommend running:

```bash
codex --model gpt-5.2-codex --sandbox workspace-write
```

## Output

Return:
- status
- model/reasoning used
- files changed
- MCPs enabled (if any)
- `threadId` (if applicable)
