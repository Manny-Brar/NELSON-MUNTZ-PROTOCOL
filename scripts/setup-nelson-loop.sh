#!/bin/bash

# Nelson Muntz In-Session Loop Setup
# Creates state file for stop hook-based looping in VS Code
#
# Unlike the external CLI loop, this works WITHIN your Claude Code session
# by using a stop hook that intercepts exit and feeds the prompt back.

set -euo pipefail

# Parse arguments
PROMPT_PARTS=()
MAX_ITERATIONS=0
COMPLETION_PROMISE="null"
HA_HA_MODE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      cat << 'HELP_EOF'
Nelson Muntz - In-Session Development Loop

USAGE:
  /nelson [PROMPT...] [OPTIONS]
  /ha-ha [PROMPT...] [OPTIONS]

ARGUMENTS:
  PROMPT...    Task to accomplish (can be multiple words)

OPTIONS:
  --max-iterations <n>           Maximum iterations (default: unlimited)
  --completion-promise '<text>'  Promise phrase (USE QUOTES for multi-word)
  --ha-ha                        Enable HA-HA Mode (Peak Performance)
  -h, --help                     Show this help

HA-HA MODE FEATURES:
  - Pre-flight research MANDATORY before coding
  - Multi-dimensional thinking (4 levels)
  - Wall-Breaker protocol with auto web search
  - 5-attempt escalation (extended from 3)
  - Comprehensive iteration reports

COMPLETION SIGNALS:
  - <promise>YOUR_PHRASE</promise>
  - <nelson-complete>ALL_FEATURES_COMPLETE</nelson-complete>

EXAMPLES:
  /nelson Build a REST API --max-iterations 20
  /ha-ha Build OAuth authentication system
  /nelson --completion-promise 'ALL TESTS PASS' Add user auth

STOPPING:
  Only by reaching --max-iterations, detecting promise, or ALL_FEATURES_COMPLETE.
  The loop runs until completion!

HA-HA!
HELP_EOF
      exit 0
      ;;
    --max-iterations)
      if [[ -z "${2:-}" ]] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
        echo "Error: --max-iterations requires a number" >&2
        exit 1
      fi
      MAX_ITERATIONS="$2"
      shift 2
      ;;
    --completion-promise)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --completion-promise requires text" >&2
        exit 1
      fi
      COMPLETION_PROMISE="$2"
      shift 2
      ;;
    --ha-ha|--haha)
      HA_HA_MODE=true
      shift
      ;;
    *)
      PROMPT_PARTS+=("$1")
      shift
      ;;
  esac
done

PROMPT="${PROMPT_PARTS[*]}"

if [[ -z "$PROMPT" ]]; then
  echo "Error: No prompt provided" >&2
  echo "" >&2
  echo "Examples:" >&2
  echo "  /nelson Build a REST API with auth" >&2
  echo "  /ha-ha Build OAuth + JWT authentication" >&2
  echo "" >&2
  echo "For help: /nelson --help" >&2
  exit 1
fi

# Create state file
mkdir -p .claude

# Quote completion promise for YAML
if [[ -n "$COMPLETION_PROMISE" ]] && [[ "$COMPLETION_PROMISE" != "null" ]]; then
  COMPLETION_PROMISE_YAML="\"$COMPLETION_PROMISE\""
else
  COMPLETION_PROMISE_YAML="null"
fi

cat > .claude/nelson-loop.local.md <<EOF
---
active: true
iteration: 1
max_iterations: $MAX_ITERATIONS
completion_promise: $COMPLETION_PROMISE_YAML
ha_ha_mode: $HA_HA_MODE
started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
---

$PROMPT
EOF

# Output activation message
if [[ "$HA_HA_MODE" == "true" ]]; then
  cat <<EOF

 HA-HA MODE ACTIVATED

 Iteration: 1
 Max iterations: $(if [[ $MAX_ITERATIONS -gt 0 ]]; then echo $MAX_ITERATIONS; else echo "unlimited"; fi)
 Completion promise: $(if [[ "$COMPLETION_PROMISE" != "null" ]]; then echo "$COMPLETION_PROMISE"; else echo "none"; fi)

 PEAK PERFORMANCE PROTOCOL:
   Pre-flight research MANDATORY
   Multi-dimensional thinking (4 levels)
   Wall-Breaker protocol enabled
   5-attempt escalation ladder
   Aggressive validation + self-review

 The stop hook is now active. When you try to exit, the prompt
 will be fed back for the next iteration. Your work persists in files.

 To complete: output <nelson-complete>ALL_FEATURES_COMPLETE</nelson-complete>
$(if [[ "$COMPLETION_PROMISE" != "null" ]]; then echo " Or: <promise>$COMPLETION_PROMISE</promise>"; fi)

 Monitor: head -10 .claude/nelson-loop.local.md

HA-HA!

EOF
else
  cat <<EOF

Nelson Muntz Loop Activated

Iteration: 1
Max iterations: $(if [[ $MAX_ITERATIONS -gt 0 ]]; then echo $MAX_ITERATIONS; else echo "unlimited"; fi)
Completion promise: $(if [[ "$COMPLETION_PROMISE" != "null" ]]; then echo "$COMPLETION_PROMISE"; else echo "none"; fi)

PROTOCOL:
  Engage ultrathink before acting
  Single-feature focus
  Two-stage validation (spec + quality)
  3-fix rule (escalate after 3 failures)

The stop hook is now active. When you try to exit, the prompt
will be fed back for the next iteration. Your work persists in files.

To complete: output <nelson-complete>ALL_FEATURES_COMPLETE</nelson-complete>
$(if [[ "$COMPLETION_PROMISE" != "null" ]]; then echo "Or: <promise>$COMPLETION_PROMISE</promise>"; fi)

Monitor: head -10 .claude/nelson-loop.local.md

EOF
fi

echo "$PROMPT"
echo ""

# Show completion requirements
if [[ "$COMPLETION_PROMISE" != "null" ]]; then
  echo "================================================================"
  echo "COMPLETION REQUIREMENTS"
  echo "================================================================"
  echo ""
  echo "To complete this loop, output EXACTLY:"
  echo "  <promise>$COMPLETION_PROMISE</promise>"
  echo ""
  echo "STRICT REQUIREMENTS:"
  echo "  The statement MUST be completely TRUE"
  echo "  Do NOT output false statements to exit"
  echo "  The loop is designed to continue until genuine completion"
  echo ""
  echo "Or signal all features done:"
  echo "  <nelson-complete>ALL_FEATURES_COMPLETE</nelson-complete>"
  echo "================================================================"
fi
