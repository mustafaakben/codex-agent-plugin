#!/usr/bin/env bash
# SessionStart hook for agent-codex plugin
# Detects whether .codex/config.toml exists in the current project
# and injects the result into the session as additionalContext.

set -euo pipefail

CONFIG_FILE=".codex/config.toml"

if [ -f "$CONFIG_FILE" ]; then
  CONTEXT="This project has a .codex/config.toml file. Codex CLI is configured and ready to use. Delegate coding tasks via the Codex MCP tools or the /codex command."
else
  CONTEXT="This project does not have a .codex/config.toml file. If the user wants to use Codex CLI, ask for confirmation before creating or modifying project files. Use /codex-config or the codex-ecosystem skill to bootstrap the configuration."
fi

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "$CONTEXT"
  }
}
EOF

exit 0
