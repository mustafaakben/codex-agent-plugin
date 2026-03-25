#!/usr/bin/env bash
# PreToolUse hook for agent-codex plugin
# Guards Codex MCP tool calls by checking whether .codex/config.toml exists.
# Returns "approve" if config is present, "block" with guidance if missing.

set -euo pipefail

CONFIG_FILE=".codex/config.toml"

if [ -f "$CONFIG_FILE" ]; then
  cat <<'EOF'
{
  "decision": "approve"
}
EOF
else
  cat <<'EOF'
{
  "decision": "block",
  "reason": "No .codex/config.toml found in this project. Ask the user for confirmation before bootstrapping Codex configuration. Use /codex-config or the codex-ecosystem skill to set it up."
}
EOF
fi

exit 0
