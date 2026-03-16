---
name: codex-review
description: Run AI-powered code review using Codex CLI.
argument-hint: '[target:uncommitted|branch|commit] [focus:general|security|performance|style]'
arguments:
  - name: target
    description: "Review target: uncommitted (default), branch, or commit SHA"
    required: false
  - name: focus
    description: "Review focus: general, security, performance, style"
    required: false
allowed-tools:
  - Bash
  - Read
  - Grep
---

# Codex Code Review

## Inputs

- Target: `$ARGUMENTS.target` (default `uncommitted`)
- Focus: `$ARGUMENTS.focus` (default `general`)

## Execution guidance

- Use the native `codex review` command (preferred) or `codex exec review` for non-interactive output.
- Common patterns:
  - `codex review --uncommitted` — review uncommitted changes
  - `codex review --base main` — review against a branch
  - `codex review --commit SHA` — review a specific commit
  - `codex exec review --uncommitted --json -o review.md` — non-interactive with JSON output
- Include concrete findings and actionable fixes.

## Output sections

1. Review summary
2. Critical issues
3. Recommendations
4. Positive observations
5. Prioritized action items

If no changes are present, return "No changes detected for review."
