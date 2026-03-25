#!/usr/bin/env bash
# PostToolUse hook for agent-codex plugin
# Inspects Codex tool output for threadId (enables follow-up queries)
# and error indicators. Returns additionalContext when relevant.

set -euo pipefail
trap 'echo "{}" >&1' ERR

INPUT=$(cat)

THREAD_ID=$(echo "$INPUT" | jq -r '.threadId // empty' 2>/dev/null || true)
HAS_ERROR=$(echo "$INPUT" | jq -e '.error // empty' > /dev/null 2>&1 && echo "true" || echo "false")

CONTEXT=""

if [ -n "$THREAD_ID" ]; then
  CONTEXT="Codex returned threadId: ${THREAD_ID}. Use mcp__codex-native__codex-reply with this threadId for follow-up queries in the same Codex session."
fi

if [ "$HAS_ERROR" = "true" ]; then
  if [ -n "$CONTEXT" ]; then
    CONTEXT="${CONTEXT} The output also contains errors or warnings — review and report them to the user."
  else
    CONTEXT="The Codex output contains errors or warnings. Review the output and report any issues to the user."
  fi
fi

if [ -z "$CONTEXT" ]; then
  echo '{}'
  exit 0
fi

jq -n --arg ctx "$CONTEXT" '{
  hookSpecificOutput: {
    hookEventName: "PostToolUse",
    additionalContext: $ctx
  }
}'
