#!/bin/bash

# =============================================================================
# Ralph v3.0 - State Initialization Script
# =============================================================================
#
# Creates the state directory and initial files for Ralph v3.0 fresh-context
# loops. This script is run once when starting a new Ralph loop.
#
# State Directory Structure:
#   .claude/ralph-v3/
#   ├── config.json          # Settings, iteration tracking
#   ├── features.json        # Structured feature list (JSON for reliability)
#   ├── scratchpad.md        # Debug notes, partial solutions
#   ├── progress.md          # Iteration log (append-only)
#   ├── handoff.md           # Context for next session (rewritten each iter)
#   ├── init.sh              # Per-project init script (created by initializer)
#   └── validation/
#       ├── spec-check.json  # Requirements compliance tracking
#       └── quality-check.json # Test/lint/build results
#
# Usage:
#   ./init-v3-state.sh "PROMPT" [OPTIONS]
#
# Options:
#   --max-iterations N       Maximum iterations (default: 0 = unlimited)
#   --completion-promise TXT Promise phrase to signal completion
#   --state-dir DIR          State directory (default: .claude/ralph-v3)
#
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR=".claude/ralph-v3"
PROMPT=""
MAX_ITERATIONS=0
COMPLETION_PROMISE=""
MODEL="opus"
HA_HA_MODE=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

log() {
  echo -e "${BLUE}[Ralph v3]${NC} $1"
}

success() {
  echo -e "${GREEN}[Ralph v3]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[Ralph v3]${NC} $1"
}

error() {
  echo -e "${RED}[Ralph v3 ERROR]${NC} $1" >&2
}

timestamp() {
  date -u +%Y-%m-%dT%H:%M:%SZ
}

# Escape string for JSON
json_escape() {
  local str="$1"
  # Escape backslashes, double quotes, and newlines
  str="${str//\\/\\\\}"
  str="${str//\"/\\\"}"
  str="${str//$'\n'/\\n}"
  str="${str//$'\r'/\\r}"
  str="${str//$'\t'/\\t}"
  echo "$str"
}

# -----------------------------------------------------------------------------
# Show Help
# -----------------------------------------------------------------------------

show_help() {
  cat << 'HELP'
Ralph v3.0 - State Initialization

USAGE:
  init-v3-state.sh "PROMPT" [OPTIONS]

ARGUMENTS:
  PROMPT              The task to accomplish (required)

OPTIONS:
  --max-iterations N       Maximum iterations before stopping (default: unlimited)
  --completion-promise TXT Promise phrase that signals completion
  --state-dir DIR          Custom state directory (default: .claude/ralph-v3)
  --model MODEL            Claude model to use (default: opus)
  -h, --help               Show this help message

STATE FILES CREATED:
  config.json         Settings and iteration tracking
  features.json       Structured feature list (empty, filled by initializer)
  scratchpad.md       Debug notes and partial solutions
  progress.md         Iteration log (append-only)
  handoff.md          Context for next session
  validation/         Two-stage validation directory
    spec-check.json   Requirements compliance
    quality-check.json Test/lint/build results

EXAMPLES:
  # Basic usage
  init-v3-state.sh "Build a REST API with auth" --max-iterations 30

  # With completion promise
  init-v3-state.sh "Add user authentication" \
    --completion-promise "ALL TESTS PASS" \
    --max-iterations 20

HELP
}

# -----------------------------------------------------------------------------
# Parse Arguments
# -----------------------------------------------------------------------------

parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help)
        show_help
        exit 0
        ;;
      --max-iterations)
        if [[ -z "${2:-}" ]] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
          error "--max-iterations requires a number"
          exit 1
        fi
        MAX_ITERATIONS="$2"
        shift 2
        ;;
      --completion-promise)
        if [[ -z "${2:-}" ]]; then
          error "--completion-promise requires a text argument"
          exit 1
        fi
        COMPLETION_PROMISE="$2"
        shift 2
        ;;
      --state-dir)
        if [[ -z "${2:-}" ]]; then
          error "--state-dir requires a directory path"
          exit 1
        fi
        STATE_DIR="$2"
        shift 2
        ;;
      --model)
        if [[ -z "${2:-}" ]]; then
          error "--model requires a model name"
          exit 1
        fi
        MODEL="$2"
        shift 2
        ;;
      --ha-ha|--haha)
        HA_HA_MODE=true
        shift
        ;;
      -*)
        error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
      *)
        # Collect non-option arguments as prompt
        if [[ -z "$PROMPT" ]]; then
          PROMPT="$1"
        else
          PROMPT="$PROMPT $1"
        fi
        shift
        ;;
    esac
  done

  # Validate required arguments
  if [[ -z "$PROMPT" ]]; then
    error "No prompt provided"
    echo ""
    echo "Usage: init-v3-state.sh \"PROMPT\" [OPTIONS]"
    echo "Use --help for more information"
    exit 1
  fi
}

# -----------------------------------------------------------------------------
# Create State Directory and Files
# -----------------------------------------------------------------------------

create_state_directory() {
  log "Creating state directory: $STATE_DIR"
  mkdir -p "$STATE_DIR"
  mkdir -p "$STATE_DIR/validation"
}

create_config_json() {
  log "Creating config.json"

  local promise_json="null"
  if [[ -n "$COMPLETION_PROMISE" ]]; then
    promise_json="\"$(json_escape "$COMPLETION_PROMISE")\""
  fi

  # HA-HA mode settings
  local max_attempts=3
  if [[ "$HA_HA_MODE" == "true" ]]; then
    max_attempts=5
  fi

  cat > "$STATE_DIR/config.json" << EOF
{
  "version": "3.0.0",
  "mode": "fresh-context",
  "ha_ha_mode": $HA_HA_MODE,
  "active": true,
  "iteration": 0,
  "max_iterations": $MAX_ITERATIONS,
  "completion_promise": $promise_json,
  "model": "$MODEL",
  "started_at": "$(timestamp)",
  "last_updated": "$(timestamp)",
  "prompt": "$(json_escape "$PROMPT")",
  "settings": {
    "git_checkpoint": true,
    "git_checkpoint_on": "feature_completion",
    "ultrathink": true,
    "single_feature_focus": true,
    "clean_state_required": true,
    "max_feature_attempts": $max_attempts,
    "pre_research_mandatory": $HA_HA_MODE,
    "auto_research_on_failure": $HA_HA_MODE,
    "wall_breaker_protocol": $HA_HA_MODE,
    "multi_dimensional_thinking": $HA_HA_MODE
  },
  "stats": {
    "total_iterations": 0,
    "features_completed": 0,
    "features_blocked": 0,
    "git_commits": 0,
    "research_queries": 0,
    "walls_broken": 0
  }
}
EOF
}

create_features_json() {
  log "Creating features.json"

  local promise_json="null"
  if [[ -n "$COMPLETION_PROMISE" ]]; then
    promise_json="\"$(json_escape "$COMPLETION_PROMISE")\""
  fi

  cat > "$STATE_DIR/features.json" << EOF
{
  "version": "3.0.0",
  "created_at": "$(timestamp)",
  "last_updated": "$(timestamp)",
  "original_prompt": "$(json_escape "$PROMPT")",
  "features": [],
  "summary": {
    "total": 0,
    "completed": 0,
    "blocked": 0,
    "in_progress": 0,
    "pending": 0
  },
  "completion_criteria": {
    "all_features_pass": false,
    "completion_promise": $promise_json,
    "minimum_features": 1
  }
}
EOF
}

create_scratchpad() {
  log "Creating scratchpad.md"

  cat > "$STATE_DIR/scratchpad.md" << EOF
# Ralph v3.0 Scratchpad

## Purpose
This file persists across all iterations. Use it for:
- Debug notes and error analysis
- Partial solutions and ideas
- Things that didn't work and why
- Important discoveries

## Session Started: $(timestamp)

### Original Task
$PROMPT

---

## Notes

<!-- Add your debugging notes, learnings, and partial solutions below -->
<!-- Each iteration can read previous notes and add new ones -->
<!-- This is your persistent memory across fresh contexts -->

EOF
}

create_progress_log() {
  log "Creating progress.md"

  cat > "$STATE_DIR/progress.md" << EOF
# Ralph v3.0 Progress Log

## Session Started: $(timestamp)

### Original Task
$PROMPT

### Completion Criteria
$(if [[ -n "$COMPLETION_PROMISE" ]]; then echo "Promise: $COMPLETION_PROMISE"; else echo "No completion promise set"; fi)
Max Iterations: $(if [[ $MAX_ITERATIONS -gt 0 ]]; then echo $MAX_ITERATIONS; else echo "Unlimited"; fi)

---

## Iteration Log

<!-- Each iteration appends its summary here -->
<!-- Format:
### Iteration N - TIMESTAMP
**Feature:** FX - Description
**Result:** COMPLETED / BLOCKED / IN_PROGRESS
**Completed:** [what was done]
**Files Modified:** [list]
**Next:** [what comes next]
-->

EOF
}

create_handoff() {
  log "Creating handoff.md"

  cat > "$STATE_DIR/handoff.md" << EOF
# Ralph v3.0 Handoff Document

## Current Status
- **Iteration:** 0 (Starting)
- **Status:** INITIALIZATION PENDING
- **Mode:** Fresh Context

## Original Task
$PROMPT

## Completion Criteria
- **Promise:** $(if [[ -n "$COMPLETION_PROMISE" ]]; then echo "$COMPLETION_PROMISE"; else echo "None set"; fi)
- **Max Iterations:** $(if [[ $MAX_ITERATIONS -gt 0 ]]; then echo $MAX_ITERATIONS; else echo "Unlimited"; fi)

## Immediate Next Actions (for Iteration 1 - Initializer)

The first iteration uses the **Initializer Prompt** which should:

1. **Read this handoff document** to understand the task
2. **Engage ultrathink protocol** to plan the approach
3. **Create project scaffolding** if needed
4. **Decompose task into features** and populate features.json
5. **Create init.sh** for subsequent iterations
6. **Set up validation directory** and baseline files
7. **Write comprehensive handoff** for iteration 2

## Context for Initializer

This is a fresh Ralph v3.0 loop. You have:
- Clean 200k token context window
- Full state directory structure created
- Empty features.json to populate
- Scratchpad for notes

Your job is to SET UP the environment, not implement features.

## Files in State Directory
\`\`\`
$STATE_DIR/
├── config.json         # Loop configuration
├── features.json       # Feature list (YOU populate this)
├── scratchpad.md       # Debug notes (append as needed)
├── progress.md         # Progress log (append each iteration)
├── handoff.md          # This file (rewrite each iteration)
└── validation/
    ├── spec-check.json     # Requirements tracking
    └── quality-check.json  # Quality metrics
\`\`\`

---

*This document will be rewritten by each iteration to provide clean context to the next.*
EOF
}

create_validation_files() {
  log "Creating validation files"

  # Spec check
  cat > "$STATE_DIR/validation/spec-check.json" << EOF
{
  "version": "3.0.0",
  "current_feature": null,
  "requirements": [],
  "implemented": {},
  "spec_passes": false,
  "last_checked": null,
  "notes": ""
}
EOF

  # Quality check
  cat > "$STATE_DIR/validation/quality-check.json" << EOF
{
  "version": "3.0.0",
  "tests": {
    "pass": null,
    "count": 0,
    "failures": 0,
    "command": "npm run test"
  },
  "lint": {
    "pass": null,
    "errors": 0,
    "warnings": 0,
    "command": "npm run lint"
  },
  "build": {
    "pass": null,
    "command": "npm run build"
  },
  "type_check": {
    "pass": null,
    "errors": 0,
    "command": "npx tsc --noEmit"
  },
  "quality_passes": false,
  "last_checked": null
}
EOF
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

main() {
  parse_args "$@"

  echo ""
  echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║           Ralph v3.0 - State Initialization                ║${NC}"
  echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
  echo ""

  # Create all state files
  create_state_directory
  create_config_json
  create_features_json
  create_scratchpad
  create_progress_log
  create_handoff
  create_validation_files

  echo ""
  success "State initialized successfully!"
  echo ""

  # Show HA-HA mode banner
  if [[ "$HA_HA_MODE" == "true" ]]; then
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  🎯  HA-HA MODE ENABLED - PEAK PERFORMANCE  🎯              ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
  fi

  echo "Configuration:"
  echo "  Mode:                 $(if [[ "$HA_HA_MODE" == "true" ]]; then echo "HA-HA (Peak Performance)"; else echo "Standard"; fi)"
  echo "  State Directory:      $STATE_DIR"
  echo "  Model:                $MODEL"
  echo "  Max Iterations:       $(if [[ $MAX_ITERATIONS -gt 0 ]]; then echo $MAX_ITERATIONS; else echo "Unlimited"; fi)"
  echo "  Completion Promise:   $(if [[ -n "$COMPLETION_PROMISE" ]]; then echo "$COMPLETION_PROMISE"; else echo "None"; fi)"
  if [[ "$HA_HA_MODE" == "true" ]]; then
    echo "  Max Attempts:         5 (HA-HA escalation)"
    echo "  Pre-Research:         MANDATORY"
    echo "  Auto-Research:        ON"
    echo "  Wall-Breaker:         ENABLED"
  fi
  echo ""
  echo "State Files Created:"
  echo "  $STATE_DIR/"
  ls -la "$STATE_DIR/" | tail -n +4 | awk '{print "    " $NF}'
  echo "  $STATE_DIR/validation/"
  ls -la "$STATE_DIR/validation/" | tail -n +4 | awk '{print "      " $NF}'
  echo ""
  echo "Prompt:"
  echo "  $(echo "$PROMPT" | head -c 100)$(if [[ ${#PROMPT} -gt 100 ]]; then echo "..."; fi)"
  echo ""
}

main "$@"
