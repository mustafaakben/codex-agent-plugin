# Prompt Guidance for Codex GPT-5.4

Official prompt patterns and best practices for GPT-5.4 and Codex CLI.

Source: https://developers.openai.com/api/docs/guides/prompt-guidance/

## GPT-5.4 Core Strengths

- Personality and tone adherence over extended responses
- Multi-step agentic workflows with improved completion rates
- Evidence-rich synthesis across long contexts and multiple tools
- Instruction following in modular, skill-based prompts with explicit contracts
- Long-context document analysis (up to 1M tokens)
- Parallel tool execution while maintaining accuracy

## Areas Requiring Explicit Prompting

- Early-session tool routing when context is thin
- Dependency-aware workflows needing prerequisite checks
- Reasoning effort selection (task-dependent)
- Research tasks requiring disciplined sourcing and citations
- High-impact or irreversible actions requiring verification
- Coding/terminal environments where tool boundaries must stay clear

---

## Essential Prompt Patterns

### 1. Output Contract & Compactness

Constrain verbosity while maintaining reasoning depth:

```
<output_contract>
- Return exactly the sections requested, in the requested order.
- If the prompt defines a preamble, analysis block, or working section, do not treat it as extra output.
- Apply length limits only to the section they are intended for.
- If a format is required (JSON, Markdown, SQL, XML), output only that format.
</output_contract>

<verbosity_controls>
- Prefer concise, information-dense writing.
- Avoid repeating the user's request.
- Keep progress updates brief.
- Do not shorten the answer so aggressively that required evidence, reasoning, or completion checks are omitted.
</verbosity_controls>
```

### 2. Default Follow-Through Policy

When to proceed autonomously vs. ask:

```
<default_follow_through_policy>
- If the user's intent is clear and the next step is reversible and low-risk, proceed without asking.
- Ask permission only if the next step is:
  (a) irreversible,
  (b) has external side effects (sending, purchasing, deleting, writing to production), or
  (c) requires missing sensitive information or a choice that would materially change the outcome.
- If proceeding, briefly state what you did and what remains optional.
</default_follow_through_policy>
```

### 3. Instruction Priority Framework

```
<instruction_priority>
- User instructions override default style, tone, formatting, and initiative preferences.
- Safety, honesty, privacy, and permission constraints do not yield.
- If a newer user instruction conflicts with an earlier one, follow the newer instruction.
- Preserve earlier instructions that do not conflict.
</instruction_priority>
```

### 4. Mid-Conversation Updates

For scoped changes:

```
<task_update>
For the next response only:
- Do not complete the task.
- Only produce a plan.
- Keep it to 5 bullets.
All earlier instructions still apply unless they conflict with this update.
</task_update>
```

For full task pivots:

```
<task_update>
The task has changed.
Previous task: complete the workflow.
Current task: review the workflow and identify risks only.
Rules for this turn:
- Do not execute actions.
- Do not call destructive tools.
- Return exactly: 1. Main risks  2. Missing information  3. Recommended next step
</task_update>
```

---

## Tool Use & Workflow Patterns

### 5. Tool Persistence Rules

```
<tool_persistence_rules>
- Use tools whenever they materially improve correctness, completeness, or grounding.
- Do not stop early when another tool call is likely to materially improve correctness or completeness.
- Keep calling tools until:
  (1) the task is complete, and
  (2) verification passes.
- If a tool returns empty or partial results, retry with a different strategy.
</tool_persistence_rules>
```

### 6. Dependency Checking

```
<dependency_checks>
- Before taking an action, check whether prerequisite discovery, lookup, or memory retrieval steps are required.
- Do not skip prerequisite steps just because the intended final action seems obvious.
- If the task depends on the output of a prior step, resolve that dependency first.
</dependency_checks>
```

### 7. Parallel vs. Sequential Tool Calling

```
<parallel_tool_calling>
- When multiple retrieval or lookup steps are independent, prefer parallel tool calls.
- Do not parallelize steps that have prerequisite dependencies or where one result determines the next action.
- After parallel retrieval, pause to synthesize the results before making more calls.
- Prefer selective parallelism: parallelize independent evidence gathering, not speculative or redundant tool use.
</parallel_tool_calling>
```

### 8. Empty Result Recovery

```
<empty_result_recovery>
If a lookup returns empty, partial, or suspiciously narrow results:
- do not immediately conclude that no results exist,
- try at least one or two fallback strategies:
  - alternate query wording
  - broader filters
  - a prerequisite lookup
  - an alternate source or tool
- Only then report that no results were found, along with what you tried.
</empty_result_recovery>
```

---

## Completeness & Verification

### 9. Completeness Contract

```
<completeness_contract>
- Treat the task as incomplete until all requested items are covered or explicitly marked [blocked].
- Keep an internal checklist of required deliverables.
- For lists, batches, or paginated results:
  - determine expected scope when possible,
  - track processed items or pages,
  - confirm coverage before finalizing.
- If any item is blocked by missing data, mark it [blocked] and state exactly what is missing.
</completeness_contract>
```

### 10. Verification Loop

```
<verification_loop>
Before finalizing:
- Check correctness: does the output satisfy every requirement?
- Check grounding: are factual claims backed by the provided context or tool outputs?
- Check formatting: does the output match the requested schema or style?
- Check safety and irreversibility: if the next step has external side effects, ask permission first.
</verification_loop>
```

### 11. Missing Context Gating

```
<missing_context_gating>
- If required context is missing, do NOT guess.
- Prefer the appropriate lookup tool when the missing context is retrievable; ask a minimal clarifying question only when it is not.
- If you must proceed, label assumptions explicitly and choose a reversible action.
</missing_context_gating>
```

### 12. Action Safety Frame

```
<action_safety>
- Pre-flight: summarize the intended action and parameters in 1-2 lines.
- Execute via tool.
- Post-flight: confirm the outcome and any validation that was performed.
</action_safety>
```

---

## Research & Citation

### 13. Citation Rules

```
<citation_rules>
- Only cite sources retrieved in the current workflow.
- Never fabricate citations, URLs, IDs, or quote spans.
- Use exactly the citation format required by the host application.
- Attach citations to the specific claims they support, not only at the end.
</citation_rules>
```

### 14. Grounding Rules

```
<grounding_rules>
- Base claims only on provided context or tool outputs.
- If sources conflict, state the conflict explicitly and attribute each side.
- If the context is insufficient or irrelevant, narrow the answer or say you cannot support the claim.
- If a statement is an inference rather than a directly supported fact, label it as an inference.
</grounding_rules>
```

### 15. Research Mode

```
<research_mode>
- Do research in 3 passes:
  1) Plan: list 3-6 sub-questions to answer.
  2) Retrieve: search each sub-question and follow 1-2 second-order leads.
  3) Synthesize: resolve contradictions and write the final answer with citations.
- Stop only when more searching is unlikely to change the conclusion.
</research_mode>
```

---

## Coding & Terminal Workflows

### 16. Autonomy & Persistence for Coding

```
<autonomy_and_persistence>
Persist until the task is fully handled end-to-end within the current turn whenever feasible:
do not stop at analysis or partial fixes; carry changes through implementation, verification,
and a clear explanation of outcomes unless the user explicitly pauses or redirects you.

Unless the user explicitly asks for a plan, asks a question about the code, is brainstorming
potential solutions, or some other intent that makes it clear that code should not be written,
assume the user wants you to make code changes or run tools to solve the problem. If you
encounter challenges or blockers, attempt to resolve them yourself.
</autonomy_and_persistence>
```

### 17. User Updates for Coding Tasks

```
<user_updates_spec>
- Use 1-2 sentence updates to communicate progress and new information while you work.
- Do not begin responses with conversational interjections or meta commentary.
- Before exploring or doing substantial work, send an update explaining your understanding and first step.
- Provide updates roughly every 30 seconds while working.
- When exploring, explain what context you are gathering and what you learned.
- Before file edits, explain what you are about to change.
- Keep the tone consistent with the assistant's overall personality.
</user_updates_spec>
```

### 18. Terminal Tool Hygiene

```
<terminal_tool_hygiene>
- Only run shell commands via the terminal tool.
- Never "run" tool names as shell commands.
- If a patch or edit tool exists, use it directly; do not attempt it in bash.
- After changes, run a lightweight verification step (ls, tests, build) before declaring done.
</terminal_tool_hygiene>
```

---

## Reasoning Effort Strategy

Treat reasoning effort as a tuning knob, not a primary quality lever.

| Scenario | Reasoning Effort | Notes |
|----------|-----------------|-------|
| Fast, cost-sensitive tasks | `none` or `low` | No/minimal thinking overhead |
| Latency-sensitive with complex instructions | `low` | Small thinking gain helps |
| Research, multi-document synthesis | `medium` or `high` | Choose based on complexity |
| Long agentic workflows, reasoning-heavy | `high` or `xhigh` | Performance > speed/cost |

**Before increasing reasoning effort**, add these prompt blocks first:
1. `<completeness_contract>`
2. `<verification_loop>`
3. `<tool_persistence_rules>`

Only increase reasoning effort after these refinements prove insufficient.

---

## Quick Reference: Core Patterns by Use Case

| Use Case | Core Patterns |
|----------|---------------|
| Long-running agent | Tool persistence, completeness contract, verification loop |
| Research task | Research mode, citation rules, grounding rules, empty result recovery |
| Coding workflow | Autonomy & persistence, user updates, terminal hygiene, action safety |
| Structured extraction | Output contract, structured output contract |
| High-impact action | Action safety, missing context gating, verification loop |
| Customer-facing writing | Personality controls, verbosity controls |

---

## Key Takeaway

GPT-5.4 is strongest with **explicit output contracts, tool persistence rules, and completeness accounting**. Prompts should define what "done" looks like, enforce grounding and citation discipline, and use lightweight verification before high-impact actions. Reasoning effort is a last-mile tuning knob — strong prompts and clear workflows matter more. Start small and add blocks only when they fix measured failures.
