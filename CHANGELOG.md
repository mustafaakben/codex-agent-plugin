# Changelog

## 1.1.0

### Model Updates
- Updated all model references from `gpt-5.2-codex` / `gpt-5.1-codex-max` to `gpt-5.4` (flagship frontier model).
- New complexity mapping: simple (low), medium (medium), complex (high), critical (xhigh) — all using `gpt-5.4`.
- Updated model tables with current recommended models (gpt-5.4, gpt-5.3-codex, gpt-5.3-codex-spark) and legacy/superseded list.

### Configuration Overhaul
- Renamed `sandbox` config key to `sandbox_mode` throughout.
- Marked `on-failure` approval policy as deprecated.
- Expanded `codex-config` supported keys: `sandbox_mode`, `personality`, `model_verbosity`, `model_context_window`, `web_search`.
- Comprehensive config template rewrite with all available settings organized by section: core model, execution, web search, developer customization, notifications, features, shell environment policy, sandbox fine-tuning, history, TUI, multi-agent, model providers, profiles, and projects.

### CLI Reference Rewrite
- Updated to Codex CLI v0.114.0.
- Added new commands: `codex review`, `codex fork`, `codex cloud`, `codex apply`, `codex sandbox`, `codex debug`.
- Added new global flags: `--enable`, `--disable`, `--oss`, `--local-provider`, `--full-auto`, `--no-alt-screen`, `--dangerously-bypass-approvals-and-sandbox`.
- Added new exec flags: `--ephemeral`, `--progress-cursor`.
- Expanded MCP management: `codex mcp get`, `codex mcp login/logout`, HTTP server support (`--url`, `--bearer-token-env-var`).
- Updated config section with new keys, HTTP MCP examples, and config precedence.

### MCP Updates
- Fixed GitHub MCP from SSE (`mcp.github.com/sse`) to HTTP (`api.githubcopilot.com/mcp/`).
- Added `openaiDeveloperDocs` HTTP MCP (`developers.openai.com/mcp`).
- Added `microsoft-learn` HTTP MCP (`learn.microsoft.com/api/mcp`).
- Added HTTP server support and OAuth login to `codex-mcp-add` command.

### Prompt Guidance (New)
- Added `codex-prompt-guidance.md` — comprehensive GPT-5.4 prompt patterns and best practices.
- Covers: output contracts, tool persistence, completeness contracts, verification loops, dependency checking, research mode, coding autonomy, reasoning effort strategy.
- Referenced from both `codex-integration` and `codex-ecosystem` skills.

### Command Updates
- `codex-review`: Updated to use native `codex review` command with `--uncommitted`, `--base`, `--commit` flags.
- `codex-mcp-add`: Added STDIO, HTTP, and OAuth server type documentation.

### Other
- Security hardening for `scripts/codex-wrapper.sh` (removed shell-injection path).
- Curated MCP list reduced to verified package references.
- Added `LICENSE`, `CONTRIBUTING.md`, and `RELEASE_CHECKLIST.md`.
- Removed local artifacts and stale report claims.

## 1.0.0

- Initial release of `agent-codex` plugin structure.
