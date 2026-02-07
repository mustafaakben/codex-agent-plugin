# Contributing

## Workflow

1. Create a branch.
2. Make focused changes.
3. Run validation commands:

```bash
claude plugin validate .
bash -n scripts/codex-wrapper.sh
python3 -m py_compile scripts/codex-interactive.py
```

4. Update docs when behavior changes.
5. Open a PR with a clear summary.

## Standards

- Keep instructions accurate and reproducible.
- Avoid local-only artifacts in committed files.
- Prefer minimal, explicit defaults over speculative integrations.
