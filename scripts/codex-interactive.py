#!/usr/bin/env python3
"""
Codex Interactive Session Manager

Python subsystem for managing Codex CLI sessions, enabling:
- Process-local session management
- Async communication
- Multi-turn conversations
- Background task coordination
"""

import subprocess
import json
import os
import threading
from typing import Optional, Dict, Any, List
from dataclasses import dataclass, field
from datetime import datetime
import uuid


@dataclass
class CodexSession:
    """Represents a Codex conversation session."""
    session_id: str
    thread_id: Optional[str] = None
    created_at: datetime = field(default_factory=datetime.now)
    last_accessed: datetime = field(default_factory=datetime.now)
    turns: List[Dict[str, Any]] = field(default_factory=list)
    model: str = "gpt-5.4"
    sandbox: str = "workspace-write"


class CodexManager:
    """Manages Codex CLI interactions and sessions."""

    def __init__(self, working_dir: Optional[str] = None):
        self.working_dir = working_dir or os.getcwd()
        self.sessions: Dict[str, CodexSession] = {}
        self._check_codex_installed()

    def _check_codex_installed(self) -> bool:
        """Check if Codex CLI is installed."""
        try:
            result = subprocess.run(
                ["codex", "--version"],
                capture_output=True,
                text=True,
                timeout=10
            )
            return result.returncode == 0
        except (subprocess.TimeoutExpired, FileNotFoundError):
            print("Warning: Codex CLI not found. Install with: npm i -g @openai/codex")
            return False

    def create_session(
        self,
        model: str = "gpt-5.4",
        sandbox: str = "workspace-write"
    ) -> CodexSession:
        """Create a new Codex session."""
        session_id = str(uuid.uuid4())[:8]
        session = CodexSession(
            session_id=session_id,
            model=model,
            sandbox=sandbox
        )
        self.sessions[session_id] = session
        return session

    def get_session(self, session_id: str) -> Optional[CodexSession]:
        """Get an existing session by ID."""
        return self.sessions.get(session_id)

    def execute(
        self,
        prompt: str,
        session_id: Optional[str] = None,
        model: Optional[str] = None,
        reasoning_effort: str = "high",  # Default: high reasoning
        sandbox: Optional[str] = None,
        timeout: int = 300
    ) -> Dict[str, Any]:
        """
        Execute a Codex command.

        Args:
            prompt: The task/prompt to execute
            session_id: Optional session ID for multi-turn
            model: Model to use (defaults to session or gpt-5.4)
            reasoning_effort: minimal|low|medium|high|xhigh
            sandbox: read-only|workspace-write|danger-full-access
            timeout: Execution timeout in seconds

        Returns:
            Dict with status, output, and metadata
        """
        # Get or create session
        session = None
        if session_id:
            session = self.get_session(session_id)

        # Build command (prompt is positional argument, NOT -p flag)
        cmd = ["codex", "exec", prompt]
        cmd.extend(["--model", model or (session.model if session else "gpt-5.4")])
        cmd.extend(["-c", f'model_reasoning_effort="{reasoning_effort}"'])
        cmd.extend(["--sandbox", sandbox or (session.sandbox if session else "workspace-write")])
        cmd.append("--json")
        cmd.append("--skip-git-repo-check")

        # Execute
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=timeout,
                cwd=self.working_dir
            )

            # Parse output
            output = result.stdout
            error = result.stderr

            # Try to extract thread_id from JSON output
            thread_id = None
            try:
                for line in output.split('\n'):
                    if line.strip():
                        data = json.loads(line)
                        if 'threadId' in data:
                            thread_id = data['threadId']
                            break
            except json.JSONDecodeError:
                pass

            # Update session if exists
            if session:
                session.last_accessed = datetime.now()
                session.turns.append({
                    "prompt": prompt,
                    "output": output,
                    "timestamp": datetime.now().isoformat()
                })
                if thread_id:
                    session.thread_id = thread_id

            return {
                "status": "success" if result.returncode == 0 else "error",
                "output": output,
                "error": error,
                "return_code": result.returncode,
                "thread_id": thread_id,
                "session_id": session.session_id if session else None
            }

        except subprocess.TimeoutExpired:
            return {
                "status": "timeout",
                "error": f"Command timed out after {timeout} seconds",
                "session_id": session.session_id if session else None
            }
        except Exception as e:
            return {
                "status": "error",
                "error": str(e),
                "session_id": session.session_id if session else None
            }

    def execute_async(
        self,
        prompt: str,
        callback: Optional[callable] = None,
        **kwargs
    ) -> str:
        """
        Execute a Codex command asynchronously.

        Args:
            prompt: The task/prompt to execute
            callback: Optional callback function(result)
            **kwargs: Additional arguments for execute()

        Returns:
            Task ID for tracking
        """
        task_id = str(uuid.uuid4())[:8]

        def run_task():
            result = self.execute(prompt, **kwargs)
            result["task_id"] = task_id
            if callback:
                callback(result)
            return result

        thread = threading.Thread(target=run_task, daemon=True)
        thread.start()

        return task_id

    def review(
        self,
        target: str = "uncommitted",
        focus: str = "general",
        model: str = "gpt-5.4",
        timeout: int = 300
    ) -> Dict[str, Any]:
        """
        Run a code review using Codex.

        Args:
            target: "uncommitted", branch name, or commit SHA
            focus: general|security|performance|style
            model: Model to use
            timeout: Execution timeout

        Returns:
            Review results
        """
        focus_prompts = {
            "general": "code quality, bugs, best practices",
            "security": "security vulnerabilities, input validation, OWASP top 10",
            "performance": "performance issues, algorithm complexity, memory usage",
            "style": "code style, naming conventions, formatting"
        }

        prompt = f"""Review the {target} changes. Focus on: {focus_prompts.get(focus, focus)}

Provide:
1. Summary of changes
2. Critical issues (if any)
3. Recommendations
4. Positive observations"""

        return self.execute(
            prompt=prompt,
            model=model,
            reasoning_effort="high",
            sandbox="read-only",
            timeout=timeout
        )

    def list_sessions(self) -> List[Dict[str, Any]]:
        """List all active sessions."""
        return [
            {
                "session_id": s.session_id,
                "thread_id": s.thread_id,
                "created_at": s.created_at.isoformat(),
                "last_accessed": s.last_accessed.isoformat(),
                "turns": len(s.turns),
                "model": s.model
            }
            for s in self.sessions.values()
        ]

    def cleanup_old_sessions(self, max_age_hours: int = 24):
        """Remove sessions older than max_age_hours."""
        cutoff = datetime.now()
        to_remove = []

        for session_id, session in self.sessions.items():
            age = (cutoff - session.last_accessed).total_seconds() / 3600
            if age > max_age_hours:
                to_remove.append(session_id)

        for session_id in to_remove:
            del self.sessions[session_id]

        return len(to_remove)


def main():
    """CLI interface for the Codex manager."""
    import argparse

    parser = argparse.ArgumentParser(description="Codex Interactive Session Manager")
    subparsers = parser.add_subparsers(dest="command", help="Commands")

    # Execute command
    exec_parser = subparsers.add_parser("exec", help="Execute a Codex task")
    exec_parser.add_argument("prompt", help="The task prompt")
    exec_parser.add_argument("-m", "--model", default="gpt-5.4", help="Model to use")
    exec_parser.add_argument("-r", "--reasoning", default="medium",
                            choices=["minimal", "low", "medium", "high", "xhigh"])
    exec_parser.add_argument("-s", "--sandbox", default="workspace-write")
    exec_parser.add_argument("-t", "--timeout", type=int, default=300)
    exec_parser.add_argument("--session", help="Session ID for multi-turn")

    # Review command
    review_parser = subparsers.add_parser("review", help="Run code review")
    review_parser.add_argument("-t", "--target", default="uncommitted",
                               help="What to review")
    review_parser.add_argument("-f", "--focus", default="general",
                               choices=["general", "security", "performance", "style"])

    # Sessions command
    subparsers.add_parser("sessions", help="List active sessions")

    args = parser.parse_args()

    manager = CodexManager()

    if args.command == "exec":
        result = manager.execute(
            prompt=args.prompt,
            session_id=args.session,
            model=args.model,
            reasoning_effort=args.reasoning,
            sandbox=args.sandbox,
            timeout=args.timeout
        )
        print(json.dumps(result, indent=2, default=str))

    elif args.command == "review":
        result = manager.review(
            target=args.target,
            focus=args.focus
        )
        print(json.dumps(result, indent=2, default=str))

    elif args.command == "sessions":
        sessions = manager.list_sessions()
        print(json.dumps(sessions, indent=2))

    else:
        parser.print_help()


if __name__ == "__main__":
    main()
