# Codex CLI Reference

Complete reference for OpenAI Codex CLI commands and options.

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

# API Key via environment variable (recommended for CI/CD)
CODEX_API_KEY=sk-... codex exec "task"

# Logout
codex logout
```

## Global Flags

| Flag | Short | Values | Description |
|------|-------|--------|-------------|
| `--model` | `-m` | string | Override model (e.g., gpt-5.2-codex) |
| `--sandbox` | `-s` | read-only, workspace-write, danger-full-access | Sandbox policy |
| `--cd` | `-C` | path | Set working directory |
| `--config` | `-c` | key=value | Override config values |
| `--profile` | `-p` | string | Load config profile |
| `--full-auto` | | boolean | Low-friction mode |
| `--add-dir` | | path | Grant additional directory access |
| `--image` | `-i` | path | Attach image to prompt |
| `--search` | | boolean | Enable web search |
| `--ask-for-approval` | `-a` | untrusted, on-failure, on-request, never | Approval timing |

## Commands

### codex (Interactive TUI)

Launch interactive terminal UI:

```bash
codex [prompt]
codex --model gpt-5.2-codex "Create a REST API"
```

### codex exec (Non-Interactive)

Run without interaction:

```bash
codex exec "prompt" [options]
codex exec "Fix the bug" --json --output-last-message result.md
```

**Exec-specific flags:**
| Flag | Description |
|------|-------------|
| `--json` | Output newline-delimited JSON events |
| `--output-last-message` / `-o` | Write final message to file |
| `--output-schema` | JSON Schema for response validation |
| `--skip-git-repo-check` | Allow outside git repos |
| `--color` | Control ANSI output (always, never, auto) |

### codex mcp-server

Run as MCP server (experimental):

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
| approval-policy | string | no | untrusted, on-request, on-failure, never |
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

### codex resume

Continue previous session:

```bash
codex resume
codex resume --id <session-id>
```

### codex mcp

Manage MCP servers:

```bash
codex mcp add <name> -- <command>
codex mcp remove <name>
codex mcp list
```

### codex features

Manage feature flags:

```bash
codex features list
codex features enable <feature>
codex features disable <feature>
```

### codex completion

Generate shell completions:

```bash
codex completion bash
codex completion zsh
codex completion fish
codex completion powershell
```

## Configuration File

Location: `~/.codex/config.toml` (global) or `.codex/config.toml` (project)

```toml
# Model settings
model = "gpt-5.2-codex"
# model_reasoning_effort = "medium"

# Execution settings
sandbox = "workspace-write"
approval_policy = "on-request"

# MCP Servers
[mcp_servers.context7]
command = "npx"
args = ["-y", "@upstash/context7-mcp"]
startup_timeout_sec = 10
tool_timeout_sec = 60
enabled = true
enabled_tools = []  # Allow-list
disabled_tools = []  # Deny-list

# HTTP MCP Server
[mcp_servers.api]
url = "https://api.example.com/mcp"
bearer_token_env_var = "API_TOKEN"

# SSE MCP Server
[mcp_servers.github]
type = "sse"
url = "https://mcp.github.com/sse"

# Feature flags
[features]
search = true
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
| on-failure | After a command fails |
| on-request | Only when agent requests |
| never | No approval needed |

## Models

### Recommended
| Model | Best For |
|-------|----------|
| gpt-5.2-codex | Most advanced agentic coding (default, recommended) |
| gpt-5.1-codex-max | Long-horizon, complex agentic tasks |
| gpt-5.1-codex-mini | Smaller, cost-effective option |

### Alternative
| Model | Best For |
|-------|----------|
| gpt-5.1-codex | Previous version, succeeded by gpt-5.1-codex-max |
| gpt-5-codex | Older version, succeeded by gpt-5.1-codex |
| gpt-5-codex-mini | Budget option, older generation |

### General Purpose
| Model | Best For |
|-------|----------|
| gpt-5.2 | Best general agentic model across domains |
| gpt-5.1 | Previous general model |
| gpt-5 | Original reasoning model |

## Environment Variables

| Variable | Description |
|----------|-------------|
| CODEX_API_KEY | API key for CI/CD (recommended for automation) |
| OPENAI_API_KEY | Alternative API key variable |
| CODEX_CONFIG_PATH | Custom config location |
| NO_COLOR | Disable colored output |

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Configuration error |
| 3 | Authentication error |
| 4 | Rate limit exceeded |
