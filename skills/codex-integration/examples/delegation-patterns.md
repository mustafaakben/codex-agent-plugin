# Codex Delegation Patterns

Common patterns for delegating work to Codex CLI.

## Pattern 1: Simple Delegation

Single task, wait for result, integrate.

```
Claude receives: "Add input validation to the user form"

1. Assess: Medium complexity, single focus
2. Delegate via MCP:
   Tool: mcp__codex-native__codex
   prompt: "Add comprehensive input validation to the user registration form in src/components/UserForm.tsx. Validate email format, password strength (min 8 chars, 1 uppercase, 1 number), and required fields. Show inline error messages."
   model: "gpt-5.2-codex"
   sandbox: "workspace-write"

3. Review Codex output
4. Report to user with summary
```

## Pattern 2: Multi-Turn Session

Complex task requiring conversation.

```
Claude receives: "Help me refactor the authentication system"

1. Start session:
   Tool: mcp__codex-native__codex
   prompt: "Analyze the current authentication system in src/auth/. Identify areas for improvement regarding security, maintainability, and modern best practices."
   → Capture threadId: "abc123"

2. Follow-up based on analysis:
   Tool: mcp__codex-native__codex-reply
   threadId: "abc123"
   prompt: "Based on your analysis, implement JWT-based authentication with refresh tokens. Start with the token generation and validation utilities."

3. Continue as needed with same threadId
4. Synthesize all changes for user
```

## Pattern 3: Background Execution

Long task while Claude continues working.

```
Claude receives: "Generate comprehensive tests for the API and also fix the typo in README"

1. Start Codex in background:
   bash: codex exec "Generate unit tests for all endpoints in src/api/. Use Jest, aim for 80% coverage, include edge cases." --json > /tmp/codex-tests.json &

2. Meanwhile, fix README typo (simple task)

3. Check Codex results:
   bash: cat /tmp/codex-tests.json

4. Report both completed tasks to user
```

## Pattern 4: Complexity-Based Model Selection

Adjust model based on task complexity.

```
Simple task (typo fix):
  model: gpt-5.2-codex
  reasoning: minimal
  → Fast, sufficient

Medium task (new feature):
  model: gpt-5.2-codex
  reasoning: medium
  → Balanced

Complex task (architecture):
  model: gpt-5.2-codex
  reasoning: high
  → Deep thinking

Critical task (security audit):
  model: gpt-5.1-codex-max
  reasoning: high
  → Maximum accuracy
```

## Pattern 5: Code Review Delegation

Comprehensive review via Codex.

```
Claude receives: "Review my changes before I commit"

1. Check for uncommitted changes:
   bash: git status

2. Delegate review:
   bash: codex exec "Review the uncommitted changes in this repository. Focus on:
   - Security vulnerabilities
   - Performance issues
   - Code quality and maintainability
   - Best practices adherence
   Provide specific, actionable feedback." \
   --model gpt-5.2-codex \
   -c model_reasoning_effort="high" \
   --sandbox read-only \
   --json

3. Format and present findings
```

## Pattern 6: Research and Exploration

Use Codex to understand unfamiliar code.

```
Claude receives: "How does the payment processing work in this codebase?"

1. Delegate exploration:
   Tool: mcp__codex-native__codex
   prompt: "Explore and document the payment processing system in this codebase. Find:
   - Entry points for payment flows
   - Integration with payment providers
   - Error handling and retry logic
   - Security measures
   Create a comprehensive overview."
   sandbox: "read-only"

2. Codex explores, reads files, builds understanding
3. Claude receives documented analysis
4. Present to user with diagrams if helpful
```

## Pattern 7: Parallel Delegation

Multiple independent tasks in parallel.

```
Claude receives: "Set up linting, testing, and CI/CD for this project"

1. Start three Codex tasks in parallel:

   # Task 1: Linting
   codex exec "Set up ESLint and Prettier with sensible defaults for a TypeScript React project" --json > /tmp/lint.json &

   # Task 2: Testing
   codex exec "Set up Jest with React Testing Library for unit and integration tests" --json > /tmp/test.json &

   # Task 3: CI/CD
   codex exec "Create GitHub Actions workflow for lint, test, and deploy to Vercel" --json > /tmp/cicd.json &

2. Wait for all to complete
3. Integrate results, resolve any conflicts
4. Present unified setup to user
```

## Pattern 8: Iterative Refinement

Progressive improvement with feedback loops.

```
Claude receives: "Create a dashboard component"

1. Initial implementation:
   Tool: mcp__codex-native__codex
   prompt: "Create a React dashboard component with charts for user analytics"
   → Capture threadId

2. Review and refine:
   Tool: mcp__codex-native__codex-reply
   threadId: [captured]
   prompt: "Add responsive design and dark mode support"

3. Final polish:
   Tool: mcp__codex-native__codex-reply
   threadId: [captured]
   prompt: "Add loading states, error boundaries, and accessibility attributes"

4. Present final component with all iterations
```

## Pattern 9: Error Recovery

Handle failures gracefully.

```
Codex task fails:

1. Analyze error:
   - Rate limit? → Wait and retry
   - Auth error? → Guide user to re-auth
   - Task too complex? → Break down

2. Fallback strategies:
   - Simplify prompt
   - Use different model
   - Split into subtasks
   - Fall back to Claude handling

3. Always inform user of issues and resolution
```

## Pattern 10: Hybrid Claude-Codex

Split work between Claude and Codex.

```
Claude receives: "Implement user profile page with avatar upload"

1. Claude handles simple parts:
   - Create basic component structure
   - Set up routing

2. Delegate complex parts to Codex:
   - Avatar upload with S3 integration
   - Image processing/resizing
   - Form validation with complex rules

3. Claude integrates all pieces
4. Claude does final review and polish
```

## Anti-Patterns to Avoid

### Don't: Over-delegate
```
Bad: Delegate "fix typo in line 42"
Good: Handle simple fixes directly
```

### Don't: Under-specify
```
Bad: "Make it better"
Good: "Improve performance by implementing memoization for expensive computations in UserList component"
```

### Don't: Ignore Context
```
Bad: "Add a button"
Good: "Add a 'Save Draft' button to the PostEditor component that saves to localStorage every 30 seconds"
```

### Don't: Skip Validation
```
Bad: Blindly apply Codex output
Good: Review, test, then apply
```
