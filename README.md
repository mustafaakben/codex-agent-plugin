<p align="center">
  <img src="https://img.shields.io/badge/Claude_Code-Plugin-7C3AED?style=for-the-badge&logo=anthropic&logoColor=white" alt="Claude Code Plugin" />
  <img src="https://img.shields.io/badge/Codex_CLI-Integration-00A67E?style=for-the-badge&logo=openai&logoColor=white" alt="Codex CLI" />
  <img src="https://img.shields.io/github/v/tag/mustafaakben/codex-agent-plugin?style=for-the-badge&label=version&color=blue" alt="Version" />
  <img src="https://img.shields.io/github/license/mustafaakben/codex-agent-plugin?style=for-the-badge" alt="MIT License" />
  <img src="https://img.shields.io/github/stars/mustafaakben/codex-agent-plugin?style=for-the-badge&color=gold" alt="Stars" />
</p>

# agent-codex

**Delegate coding tasks from Claude Code to OpenAI Codex CLI.**

This plugin connects two AI coding agents. Claude handles orchestration, planning, and review. Codex handles execution in its own sandboxed environment. You get the strengths of both without switching terminals.

## What it does

- **`/codex <task>`** — Send a coding task to Codex CLI and get back the result
- **`/codex-review`** — Run Codex's native code review on your changes
- **`/codex-config`** — Bootstrap and manage `.codex/config.toml` per project
- **`/codex-mcp-add`** — Enable MCP servers (context7, playwright, GitHub, etc.) in your Codex config
- **`/codex-mcp-search`** — Find MCP servers on npm/GitHub when the curated list isn't enough
- **Three agent modes** — `codex-delegator` (full tasks), `codex-researcher` (read-only exploration), `codex-background` (async work)

## How it works

```
┌──────────────┐     MCP (codex-native)     ┌──────────────┐
│              │ ──── /codex <task> ───────► │              │
│  Claude Code │                             │  Codex CLI   │
│  (planning,  │ ◄─── result + threadId ──── │  (execution, │
│   review)    │                             │   sandbox)   │
│              │ ──── codex-reply ─────────► │              │
└──────────────┘     (follow-up via MCP)     └──────────────┘
```

The plugin registers Codex CLI as an MCP server (`codex mcp-server`). Claude Code calls it through standard MCP tool calls. A `threadId` comes back with each response so you can continue the same Codex session.

**Safety hooks** run on every session:
- **SessionStart** — Detects if `.codex/config.toml` exists; injects context accordingly
- **PreToolUse** — Blocks Codex MCP calls if config is missing (asks you to set up first)
- **PostToolUse** — Captures `threadId` for follow-ups; flags errors in Codex output

## Quick start

### 1. Install Codex CLI

```bash
npm install -g @openai/codex
codex login
```

### 2. Install the plugin

**From marketplace (recommended):**

```bash
# Add the marketplace source (one-time)
claude plugin marketplace add https://github.com/mustafaakben/codex-agent-plugin

# Install
claude plugin install agent-codex@mustafaakben-marketplace
```

**From source:**

```bash
git clone https://github.com/mustafaakben/codex-agent-plugin.git
cd codex-agent-plugin
claude --plugin-dir .
```

### 3. Initialize Codex in your project

```bash
# Inside Claude Code, run:
/codex-config init
```

This creates `.codex/config.toml` with defaults. The plugin will not create config files without your confirmation.

## Commands

| Command | What it does |
|---|---|
| `/codex <task>` | Delegate a coding task to Codex CLI |
| `/codex-config [init\|show\|set]` | Manage per-project Codex configuration |
| `/codex-review [target] [focus]` | Run Codex native code review (`codex review`) |
| `/codex-mcp-add <server>` | Enable an MCP server in `.codex/config.toml` |
| `/codex-mcp-search <query>` | Search npm/GitHub for MCP servers |

## Agent modes

| Agent | Use case | Tools available |
|---|---|---|
| `codex-delegator` | Full coding tasks with explicit config checks | Codex MCP, Bash, Read, Write, Grep, Glob |
| `codex-researcher` | Read-only codebase exploration | Codex MCP, Bash, Read, Grep, Glob |
| `codex-background` | Async work while you keep coding | Codex MCP, Bash, Read, Write, Grep, Glob |

## Default configuration

The generated `.codex/config.toml` starts with these defaults:

```toml
model = "gpt-5.4"
model_reasoning_effort = "xhigh"
sandbox_mode = "workspace-write"
approval_policy = "on-request"
```

Adjust via `/codex-config set <key> <value>` or edit the file directly.

## Curated MCP servers

These verified servers ship in the config template (all disabled by default):

| Server | Package | What it adds |
|---|---|---|
| context7 | `@anthropics/context7-mcp` | Up-to-date library docs |
| playwright | `@anthropics/playwright-mcp` | Browser automation |
| postgres | `@anthropics/postgres-mcp` | Database queries |
| filesystem | `@anthropics/filesystem-mcp` | File operations |
| github | `api.githubcopilot.com/mcp/` | GitHub API (HTTP MCP) |

Enable any of them with `/codex-mcp-add <server>`.

## Plugin structure

```
codex-agent-plugin/
├── .claude-plugin/
│   ├── plugin.json          # Plugin manifest (name, version, author)
│   └── marketplace.json     # Marketplace registration
├── .codex/
│   ├── config.template.toml # Template for project config
│   └── recommended-mcps.toml
├── agents/
│   ├── codex-delegator.md
│   ├── codex-researcher.md
│   └── codex-background.md
├── commands/
│   ├── codex.md
│   ├── codex-config.md
│   ├── codex-review.md
│   ├── codex-mcp-add.md
│   └── codex-mcp-search.md
├── hooks/
│   ├── hooks.json           # Hook definitions (SessionStart, PreToolUse, PostToolUse)
│   ├── session-start.sh     # Detects .codex/config.toml on session open
│   ├── pre-tool-use-codex.sh   # Guards Codex MCP calls
│   └── post-tool-use-codex.sh  # Captures threadId and errors
├── scripts/
│   ├── codex-wrapper.sh
│   └── codex-interactive.py
├── skills/
│   ├── codex-ecosystem/     # Codex setup and MCP management
│   └── codex-integration/   # Delegation patterns and CLI reference
├── .mcp.json                # MCP server registration (codex mcp-server)
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

## Troubleshooting

**"SessionStart:startup hook error"** — You're on an older version where hooks used `type: "prompt"` instead of `type: "command"`. Update the plugin:

```bash
claude plugin marketplace update mustafaakben-marketplace
claude plugin update agent-codex
```

**Codex MCP calls are blocked** — The PreToolUse hook blocks calls when `.codex/config.toml` is missing. Run `/codex-config init` to create it.

**"codex: command not found"** — Install Codex CLI globally: `npm install -g @openai/codex`

**threadId not captured** — Make sure you're on v1.1.1+ where PostToolUse hooks parse the response correctly.

## Requirements

- [Claude Code](https://claude.com/claude-code) v2.1.77+
- [OpenAI Codex CLI](https://github.com/openai/codex) v0.114.0+
- Node.js 20+ (for `npx`-based MCP servers)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). The short version: branch, make changes, run `claude plugin validate .`, open a PR.

## License

MIT — see [LICENSE](LICENSE).
