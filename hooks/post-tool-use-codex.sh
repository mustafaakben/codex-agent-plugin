#!/usr/bin/env bash
# PostToolUse hook for agent-codex plugin
# Inspects Codex tool output for threadId (enables follow-up queries)
# and error indicators. Returns additionalContext when relevant.

set -euo pipefail

INPUT=$(cat)

THREAD_ID=$(echo "$INPUT" | grep -o '"threadId"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*: *"//' | sed 's/"$//' || true)
HAS_ERROR=$(echo "$INPUT" | grep -qi '"error"\|"Error"\|"ERROR"' && echo "true" || echo "false")

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

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "$CONTEXT"
  }
}
EOF

exit 0
