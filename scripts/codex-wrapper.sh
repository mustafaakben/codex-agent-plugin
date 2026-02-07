#!/bin/bash
# Codex CLI Wrapper Script
# Provides convenient execution with complexity-based model selection

set -euo pipefail

# Default values (gpt-5.2-codex with high reasoning)
MODEL="gpt-5.2-codex"
REASONING="high"
SANDBOX="workspace-write"
TIMEOUT=300

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

usage() {
    cat << EOF2
Codex CLI Wrapper - Simplified execution with smart defaults

USAGE:
    $(basename "$0") [OPTIONS] "prompt"

OPTIONS:
    -c, --complexity    Task complexity: simple|medium|complex|critical
                        Automatically sets model and reasoning effort
    -m, --model         Override model (gpt-5.2-codex, gpt-5.1-codex-max, gpt-5.1-codex-mini, etc.)
    -r, --reasoning     Override reasoning effort (minimal|low|medium|high|xhigh)
    -s, --sandbox       Sandbox mode (read-only|workspace-write|danger-full-access)
    -o, --output        Output file path (optional)
    -t, --timeout       Timeout in seconds (default: 300)
    -b, --background    Run in background
    -h, --help          Show this help message

COMPLEXITY PRESETS:
    simple      gpt-5.2-codex with medium reasoning (quick fixes)
    medium      gpt-5.2-codex with high reasoning (features) [DEFAULT]
    complex     gpt-5.2-codex with xhigh reasoning (architecture)
    critical    gpt-5.1-codex-max with xhigh reasoning (security-critical)

EXAMPLES:
    $(basename "$0") "Fix the typo in README.md"
    $(basename "$0") -c complex "Refactor the authentication system"
    $(basename "$0") -c critical -s read-only "Security audit of user input handling"
    $(basename "$0") -b -o ./codex-output.json "Generate comprehensive tests"

EOF2
    exit 0
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Set complexity-based defaults
set_complexity() {
    case $1 in
        simple)
            MODEL="gpt-5.2-codex"
            REASONING="medium"
            ;;
        medium)
            MODEL="gpt-5.2-codex"
            REASONING="high"  # Default
            ;;
        complex)
            MODEL="gpt-5.2-codex"
            REASONING="xhigh"
            ;;
        critical)
            MODEL="gpt-5.1-codex-max"
            REASONING="xhigh"
            ;;
        *)
            log_error "Unknown complexity: $1"
            exit 1
            ;;
    esac
}

resolve_timeout_bin() {
    if command -v timeout >/dev/null 2>&1; then
        echo "timeout"
        return
    fi

    if command -v gtimeout >/dev/null 2>&1; then
        echo "gtimeout"
        return
    fi

    echo ""
}

# Parse arguments
BACKGROUND=false
OUTPUT_FILE=""
PROMPT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--complexity)
            if [[ $# -lt 2 ]]; then
                log_error "Missing value for $1"
                exit 1
            fi
            set_complexity "$2"
            shift 2
            ;;
        -m|--model)
            if [[ $# -lt 2 ]]; then
                log_error "Missing value for $1"
                exit 1
            fi
            MODEL="$2"
            shift 2
            ;;
        -r|--reasoning)
            if [[ $# -lt 2 ]]; then
                log_error "Missing value for $1"
                exit 1
            fi
            REASONING="$2"
            shift 2
            ;;
        -s|--sandbox)
            if [[ $# -lt 2 ]]; then
                log_error "Missing value for $1"
                exit 1
            fi
            SANDBOX="$2"
            shift 2
            ;;
        -o|--output)
            if [[ $# -lt 2 ]]; then
                log_error "Missing value for $1"
                exit 1
            fi
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -t|--timeout)
            if [[ $# -lt 2 ]]; then
                log_error "Missing value for $1"
                exit 1
            fi
            TIMEOUT="$2"
            shift 2
            ;;
        -b|--background)
            BACKGROUND=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        --)
            shift
            while [[ $# -gt 0 ]]; do
                if [[ -z "$PROMPT" ]]; then
                    PROMPT="$1"
                else
                    PROMPT+=" $1"
                fi
                shift
            done
            ;;
        -* )
            log_error "Unknown option: $1"
            exit 1
            ;;
        *)
            if [[ -z "$PROMPT" ]]; then
                PROMPT="$1"
            else
                PROMPT+=" $1"
            fi
            shift
            ;;
    esac

done

# Validate prompt
if [[ -z "$PROMPT" ]]; then
    log_error "No prompt provided"
    usage
fi

# Check if codex is installed
if ! command -v codex >/dev/null 2>&1; then
    log_error "Codex CLI not found. Install with: npm i -g @openai/codex"
    exit 1
fi

# Build command using argv array to avoid shell-injection vulnerabilities
CMD=(
    codex exec "$PROMPT"
    --model "$MODEL"
    -c "model_reasoning_effort=\"$REASONING\""
    --sandbox "$SANDBOX"
    --json
    --skip-git-repo-check
)

TIMEOUT_BIN="$(resolve_timeout_bin)"
if [[ -z "$TIMEOUT_BIN" ]]; then
    log_warn "No timeout binary found (timeout/gtimeout). Running without timeout enforcement."
fi

run_codex() {
    if [[ -n "$TIMEOUT_BIN" ]]; then
        "$TIMEOUT_BIN" "$TIMEOUT" "${CMD[@]}"
    else
        "${CMD[@]}"
    fi
}

# Log execution details
log_info "Executing Codex task"
log_info "Model: $MODEL"
log_info "Reasoning: $REASONING"
log_info "Sandbox: $SANDBOX"

# Execute
if [[ "$BACKGROUND" == true ]]; then
    # Background execution
    if [[ -z "$OUTPUT_FILE" ]]; then
        OUTPUT_FILE="$(mktemp "${TMPDIR:-/tmp}/codex-XXXXXX.json")"
    fi

    log_info "Running in background..."
    log_info "Output: $OUTPUT_FILE"

    (
        run_codex > "$OUTPUT_FILE" 2>&1
    ) &
    PID=$!

    echo "$PID" > "${OUTPUT_FILE}.pid"
    log_info "PID: $PID"
    log_info "Check status: ps -p $PID"
    log_info "View output: cat $OUTPUT_FILE"
else
    # Foreground execution
    if [[ -n "$OUTPUT_FILE" ]]; then
        run_codex | tee "$OUTPUT_FILE"
    else
        run_codex
    fi
fi
