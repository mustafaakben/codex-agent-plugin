# Release Checklist

1. Update `.claude-plugin/plugin.json` version.
2. Verify manifest: `claude plugin validate .`
3. Verify scripts:
   - `bash -n scripts/codex-wrapper.sh`
   - `python3 -m py_compile scripts/codex-interactive.py`
4. Confirm README command examples and install instructions.
5. Confirm no local-only files are included.
6. Update `CHANGELOG.md`.
7. Tag release and publish.
