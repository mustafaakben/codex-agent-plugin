# Codex CLI Reference

Complete reference for OpenAI Codex CLI (v0.114.0) commands and options.

## Installation

```bash
# NPM (recommended)
npm install -g @openai/codex

# Homebrew (macOS)
brew install --cask codex
```

## Authentication

```bash
# OAuth (interactive - recommended for local use)
codex login

# Device auth flow
codex login --device-auth

# API Key via stdin
printenv OPENAI_API_KEY | codex login --with-api-key

# API Key via environment variable (recommended for CI/CD)
CODEX_API_KEY=sk-... codex exec "task"

# Check login status
codex login status

# Logout
codex logout
```

## Global Flags

| Flag | Short | Values | Description |
|------|-------|--------|-------------|
| `--model` | `-m` | string | Override model (e.g., gpt-5.4) |
| `--sandbox` | `-s` | read-only, workspace-write, danger-full-access | Sandbox policy |
| `--cd` | `-C` | path | Set working directory |
| `--config` | `-c` | key=value (TOML) | Override config values (dot notation for nested) |
| `--profile` | `-p` | string | Load config profile |
| `--full-auto` | | | Low-friction mode (-a on-request + workspace-write) |
| `--add-dir` | | path | Grant additional directory write access |
| `--image` | `-i` | path(s) | Attach image(s) to prompt |
| `--search` | | | Enable live web search |
| `--ask-for-approval` | `-a` | untrusted, on-request, never | Approval timing (on-failure DEPRECATED) |
| `--enable` | | feature | Enable a feature flag |
| `--disable` | | feature | Disable a feature flag |
| `--oss` | | | Use local OSS provider (LM Studio / Ollama) |
| `--local-provider` | | lmstudio, ollama | Specify local provider |
| `--no-alt-screen` | | | Disable alternate screen (preserves scrollback) |
| `--dangerously-bypass-approvals-and-sandbox` | | | Skip ALL safety checks (DANGEROUS) |

## Commands

### codex (Interactive TUI)

Launch interactive terminal UI:

```bash
codex [prompt]
codex --model gpt-5.4 "Create a REST API"
codex -i screenshot.png "Fix this UI bug"
codex --full-auto "Refactor the auth module"
```

### codex exec (Non-Interactive)

Run without interaction:

```bash
codex exec "prompt" [options]
codex exec "Fix the bug" --json -o result.md
codex exec - < instructions.txt          # Read from stdin
codex exec "task" --ephemeral            # Don't persist session
```

**Exec-specific flags:**

| Flag | Short | Description |
|------|-------|-------------|
| `--json` | | Output newline-delimited JSON events |
| `--output-last-message` | `-o` | Write final message to file |
| `--output-schema` | | Path to JSON Schema for response validation |
| `--skip-git-repo-check` | | Allow outside git repos |
| `--ephemeral` | | Don't persist session files to disk |
| `--color` | | Control ANSI output (always, never, auto) |
| `--progress-cursor` | | Force cursor-based progress updates |

**Exec subcommands:**

```bash
codex exec resume [SESSION_ID]           # Resume previous exec session
codex exec resume --last                 # Resume most recent
codex exec review "Custom instructions"  # Non-interactive code review
```

### codex review (Code Review)

Run code review (interactive or non-interactive):

```bash
codex review                              # Interactive review
codex review --uncommitted                # Review uncommitted changes
codex review --base main                  # Review against branch
codex review --commit abc123              # Review specific commit
codex review --title "Add auth" "Focus on security"  # Custom instructions
```

**Review flags:**

| Flag | Description |
|------|-------------|
| `--uncommitted` | Review staged, unstaged, and untracked changes |
| `--base BRANCH` | Review changes against base branch |
| `--commit SHA` | Review changes from specific commit |
| `--title TITLE` | Optional commit title for review summary |

Non-interactive review via exec:

```bash
codex exec review --uncommitted --json -o review.md
codex exec review --base main -m gpt-5.4
```

### codex resume (Resume Session)

Continue previous interactive session:

```bash
codex resume                              # Show picker
codex resume SESSION_ID                   # Resume specific session
codex resume --last                       # Continue most recent
codex resume --all                        # Show all sessions (cross-cwd)
codex resume SESSION_ID "new prompt"      # Resume with new context
```

### codex fork (Fork Session)

Branch from a previous session:

```bash
codex fork                                # Show picker
codex fork SESSION_ID                     # Fork specific session
codex fork --last                         # Fork most recent
codex fork --all                          # Show all sessions
codex fork SESSION_ID "new prompt"        # Fork with new context
```

### codex mcp-server

Run as MCP server (stdio):

```bash
codex mcp-server
```

**Exposed Tools:**

**`codex`** - Start new conversation
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| prompt | string | YES | Initial prompt |
| model | string | no | Model override |
| sandbox | string | no | read-only, workspace-write, danger-full-access |
| approval-policy | string | no | untrusted, on-request, never |
| cwd | string | no | Working directory |
| profile | string | no | Config profile name |
| base-instructions | string | no | Custom instructions (replaces defaults) |
| include-plan-tool | boolean | no | Include plan tool |
| config | object | no | Config key-value overrides |

**`codex-reply`** - Continue conversation
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| prompt | string | YES | Next prompt |
| threadId | string | YES | Thread ID from previous response |
| conversationId | string | no | Deprecated alias for threadId |

### codex mcp (Manage MCP Servers)

```bash
codex mcp list                                          # List servers
codex mcp get <name>                                    # Show server config
codex mcp add <name> -- <command> [args...]              # Add STDIO server
codex mcp add <name> --url <url>                        # Add HTTP server
codex mcp add <name> --url <url> --bearer-token-env-var VAR  # HTTP with auth
codex mcp add <name> -- <cmd> --env KEY=VALUE           # With env vars
codex mcp remove <name>                                 # Remove server
codex mcp login <name>                                  # OAuth for HTTP servers
codex mcp logout <name>                                 # Remove OAuth credentials
```

### codex cloud (Cloud Tasks — EXPERIMENTAL)

```bash
codex cloud                                # Browse tasks TUI
codex cloud list                           # List tasks (--limit, --env, --cursor)
codex cloud exec --env ENV_ID "task"       # Submit task (--attempts 1-4, --branch)
codex cloud status TASK_ID                 # Check task status
codex cloud apply TASK_ID                  # Apply task diff locally
codex cloud diff TASK_ID                   # Show task diff
```

### codex apply (Apply Diff)

```bash
codex apply TASK_ID                        # Apply diff from Cloud task as git apply
```

### codex sandbox (Run in Sandbox)

```bash
codex sandbox windows -- <command>         # Windows restricted token
codex sandbox macos -- <command>           # macOS Seatbelt
codex sandbox linux -- <command>           # Linux Landlock+seccomp
codex sandbox <os> --full-auto -- <cmd>    # With workspace write access
```

### codex features (Feature Flags)

```bash
codex features list                        # List all features with stage & state
codex features enable <feature>            # Enable in config.toml
codex features disable <feature>           # Disable in config.toml
```

### codex completion (Shell Completions)

```bash
codex completion bash
codex completion zsh
codex completion fish
codex completion powershell
codex completion elvish
```

### codex login / codex logout

```bash
codex login                                # OAuth (default)
codex login --device-auth                  # Device auth flow
codex login --with-api-key                 # Read API key from stdin
codex login status                         # Show login status
codex logout                               # Remove credentials
```

### codex debug

```bash
codex debug app-server                     # Debug app server
```

## Configuration File

Location: `~/.codex/config.toml` (user) or `.codex/config.toml` (project)

Precedence (highest to lowest): CLI flags > profile > project config > user config > system config > defaults

```toml
# Model settings
model = "gpt-5.4"
model_reasoning_effort = "xhigh"
# model_reasoning_summary = "auto"       # auto | concise | detailed | none
# model_verbosity = "medium"             # low | medium | high
# model_context_window = 1000000
# model_auto_compact_token_limit = 900000

# Execution settings
sandbox_mode = "workspace-write"
approval_policy = "on-request"
# personality = "friendly"               # none | friendly | pragmatic
# web_search = "cached"                  # disabled | cached | live
# service_tier = "fast"

# MCP Servers — STDIO
[mcp_servers.context7]
command = "npx"
args = ["-y", "@upstash/context7-mcp"]
startup_timeout_sec = 10
tool_timeout_sec = 60
enabled = true
# required = false
# enabled_tools = []                     # Allow-list
# disabled_tools = []                    # Deny-list

# MCP Servers — HTTP
[mcp_servers.openai-docs]
url = "https://developers.openai.com/mcp"
# bearer_token_env_var = "TOKEN_VAR"
# http_headers = { "X-Custom" = "value" }

# Feature flags
[features]
# multi_agent = true
# js_repl = true
# fast_mode = true

# Profiles
[profiles.fast]
model = "gpt-5.4"
model_reasoning_effort = "low"

[profiles.thorough]
model = "gpt-5.4"
model_reasoning_effort = "xhigh"
```

## Sandbox Modes

| Mode | File Read | File Write | Commands | Network |
|------|-----------|------------|----------|---------|
| read-only | Yes | No | Limited | No |
| workspace-write | Yes | Workspace only | Workspace | Limited |
| danger-full-access | Yes | Anywhere | Any | Yes |

## Approval Policies

| Policy | When Approval Required |
|--------|------------------------|
| untrusted | Every potentially dangerous action |
| on-failure | **DEPRECATED** — prefer on-request or never |
| on-request | Only when agent requests |
| never | No approval needed |

## Models

### Recommended
| Model | Best For |
|-------|----------|
| gpt-5.4 | Flagship frontier model — coding, reasoning, tool use, agentic workflows (default, recommended) |
| gpt-5.3-codex | Industry-leading coding model for complex software engineering |
| gpt-5.3-codex-spark | Near-instant real-time coding iteration (ChatGPT Pro, research preview) |

### Legacy / Superseded
| Model | Status | Notes |
|-------|--------|-------|
| gpt-5.2-codex | Superseded | Replaced by gpt-5.3-codex |
| gpt-5.2 | Superseded | Replaced by gpt-5.4 |
| gpt-5.1-codex-max | Legacy | Long-horizon agentic coding |
| gpt-5.1-codex | Legacy | Replaced by gpt-5.1-codex-max |
| gpt-5-codex | Legacy | Original agentic variant |
| gpt-5-codex-mini | Legacy | Cost-effective, older generation |

## Environment Variables

| Variable | Description |
|----------|-------------|
| CODEX_API_KEY | API key for CI/CD (recommended for automation) |
| OPENAI_API_KEY | Alternative API key variable |
| CODEX_HOME | State/config directory (defaults to ~/.codex) |
| NO_COLOR | Disable colored output |

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Configuration error |
| 3 | Authentication error |
| 4 | Rate limit exceeded |
