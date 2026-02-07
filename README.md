# agent-codex Plugin

A Claude Code plugin that integrates with OpenAI Codex CLI for delegation, review, and research workflows.

## What This Plugin Provides

- Commands for Codex delegation and configuration
- Agents for delegation, background work, and research
- Skills for Codex integration and MCP setup
- Hook prompts for safer Codex usage
- Bootstrap templates under `.codex/`

## Prerequisites

1. Install Codex CLI:

```bash
npm install -g @openai/codex
```

2. Authenticate:

```bash
codex login
```

3. Node.js is required for `npx`-based MCP servers.

## Installation

### Install from GitHub (recommended)

```bash
git clone https://github.com/mustafaakben/codex-agent-plugin.git
cd codex-agent-plugin
claude --plugin-dir .
```

### Plugin Cloud / Marketplace install

Add the marketplace source:
```bash
claude plugin marketplace add https://github.com/mustafaakben/codex-agent-plugin
claude plugin marketplace list
```

Install from this marketplace:

```bash
claude plugin install agent-codex@mustafaakben-marketplace
```

Update/uninstall:

```bash
claude plugin marketplace update mustafaakben-marketplace
claude plugin update agent-codex
claude plugin uninstall agent-codex
```

This repo includes `.claude-plugin/marketplace.json`, so marketplace install works directly from GitHub.

### Manual project layout (fallback)

If you manually place plugin files in a project, keep this structure:

```text
<plugin-root>/
  .claude-plugin/plugin.json
  commands/
  agents/
  skills/
  hooks/
  scripts/
  .mcp.json
```

## Commands

Installed plugins commonly expose namespaced commands. Use:

- `/agent-codex:codex <task>`
- `/agent-codex:codex-config [action]`
- `/agent-codex:codex-review [target] [focus]`
- `/agent-codex:codex-mcp-search <query>`
- `/agent-codex:codex-mcp-add <server>`

## Configuration Model

### Files shipped by this plugin repo

- `.codex/config.template.toml`
- `.codex/recommended-mcps.toml`

### File generated in target projects

- `.codex/config.toml`

`config.toml` is created when users explicitly initialize/approve bootstrap.

### Defaults

```toml
model = "gpt-5.2-codex"
model_reasoning_effort = "high"
sandbox = "workspace-write"
approval_policy = "on-request"
```

## Curated MCP Servers

The curated, verified set used in templates/docs:

- `context7`
- `playwright`
- `postgres`
- `filesystem`
- `github`

All are disabled by default in template config.

## Safety Behavior

- Do not auto-create `.codex/config.toml` at plugin activation.
- Ask for confirmation before creating or modifying project config files.
- Ask before enabling MCP blocks in config.

## Validation

Validate plugin manifest:

```bash
claude plugin validate .
```

## License

MIT (see `LICENSE`)
