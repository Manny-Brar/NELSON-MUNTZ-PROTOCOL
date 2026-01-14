#!/bin/bash

# Nelson Muntz In-Session Loop Setup (v3.3.1)
# Creates state file for stop hook-based looping in VS Code
#
# Enhanced with:
#   - Mandatory planning phase
#   - Two-stage validation gates
#   - Structured handoff requirements
#   - Quality enforcement before completion

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
Nelson Muntz - In-Session Development Loop (v3.3.1)

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

ITERATION PROTOCOL:
  1. PLAN   - Read handoff, understand state, select ONE feature
  2. WORK   - Implement with single-feature focus
  3. VERIFY - Two-stage validation (spec + quality)
  4. HANDOFF - Write structured handoff for next iteration

COMPLETION SIGNALS:
  - <promise>YOUR_PHRASE</promise>
  - <nelson-complete>ALL_FEATURES_COMPLETE</nelson-complete>

EXAMPLES:
  /nelson Build a REST API --max-iterations 20
  /ha-ha Build OAuth authentication system
  /nelson --completion-promise 'ALL TESTS PASS' Add user auth

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

# Parse tasks from prompt (look for numbered list: 1. Task, 2. Task, etc.)
# If no numbered list found, treat entire prompt as single task
TASK_COUNT=0
TASK_LIST=""

# Check if prompt contains numbered tasks (1. something, 2. something)
if echo "$PROMPT" | grep -qE '^\s*[0-9]+\.\s+'; then
  # Extract numbered items
  TASK_LIST=$(echo "$PROMPT" | grep -E '^\s*[0-9]+\.\s+' | sed 's/^\s*//')
  TASK_COUNT=$(echo "$TASK_LIST" | wc -l | tr -d ' ')
fi

# Default to 1 task if no numbered list found
if [[ $TASK_COUNT -eq 0 ]]; then
  TASK_COUNT=1
fi

cat > .claude/nelson-loop.local.md <<EOF
---
active: true
iteration: 1
current_task: 1
task_count: $TASK_COUNT
max_iterations: $MAX_ITERATIONS
completion_promise: $COMPLETION_PROMISE_YAML
ha_ha_mode: $HA_HA_MODE
started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
---

$PROMPT
EOF

# Create initial handoff template
cat > .claude/nelson-handoff.local.md <<EOF
# Nelson Handoff - Iteration 0 (Initial)

## Progress
- Iteration: 1 of $(if [[ $MAX_ITERATIONS -gt 0 ]]; then echo $MAX_ITERATIONS; else echo "unlimited"; fi)
- Task: 1 of $TASK_COUNT
- Status: Starting fresh

## Task List
$PROMPT

## Next Should
1. Read this handoff
2. Work on Task 1
3. Complete it fully before moving to next task
4. Update this handoff with progress

## Completion Criteria
$(if [[ "$COMPLETION_PROMISE" != "null" ]]; then echo "Promise: $COMPLETION_PROMISE"; else echo "Signal: ALL_FEATURES_COMPLETE"; fi)

## Important
- One "iteration" = completing ALL $TASK_COUNT tasks once
- Complete tasks in order: 1 → 2 → ... → $TASK_COUNT → (next iteration)
EOF

# Output activation message with protocol
if [[ "$HA_HA_MODE" == "true" ]]; then
  cat <<'PROTOCOL_EOF'

╔══════════════════════════════════════════════════════════════════╗
║                    HA-HA MODE ACTIVATED                          ║
╚══════════════════════════════════════════════════════════════════╝

PROTOCOL_EOF
else
  cat <<'PROTOCOL_EOF'

╔══════════════════════════════════════════════════════════════════╗
║                 NELSON MUNTZ LOOP ACTIVATED                      ║
╚══════════════════════════════════════════════════════════════════╝

PROTOCOL_EOF
fi

cat <<EOF
Iteration: 1 of $(if [[ $MAX_ITERATIONS -gt 0 ]]; then echo $MAX_ITERATIONS; else echo "unlimited"; fi)
Task: 1 of $TASK_COUNT
Completion promise: $(if [[ "$COMPLETION_PROMISE" != "null" ]]; then echo "$COMPLETION_PROMISE"; else echo "none"; fi)

NOTE: One "iteration" = completing ALL $TASK_COUNT tasks once.

═══════════════════════════════════════════════════════════════════
                    ITERATION PROTOCOL (MANDATORY)
═══════════════════════════════════════════════════════════════════

PHASE 1: PLAN (Start of every iteration)
┌─────────────────────────────────────────────────────────────────┐
│ 1. Read handoff: cat .claude/nelson-handoff.local.md            │
│ 2. Think hard about current state and what's done               │
│ 3. Select ONE feature/task to complete this iteration           │
│ 4. Write brief plan to .claude/nelson-scratchpad.local.md       │
└─────────────────────────────────────────────────────────────────┘

PHASE 2: WORK (Single-feature focus)
┌─────────────────────────────────────────────────────────────────┐
│ 1. Implement the ONE selected feature                           │
│ 2. Do NOT touch other features                                  │
│ 3. Do NOT "quickly fix" unrelated issues                        │
│ 4. Commit working code: git commit -m "feat: description"       │
└─────────────────────────────────────────────────────────────────┘

PHASE 3: VERIFY (Before claiming completion)
┌─────────────────────────────────────────────────────────────────┐
│ Stage 1 - Spec Check:                                           │
│   □ Does implementation match requirements?                     │
│   □ Are all acceptance criteria met?                            │
│                                                                 │
│ Stage 2 - Quality Check:                                        │
│   □ Do tests pass? (run them!)                                  │
│   □ Does build succeed?                                         │
│   □ Is code clean? (no TODOs, no hacks)                         │
│                                                                 │
│ ⚠️  BOTH stages must pass before claiming done!                  │
└─────────────────────────────────────────────────────────────────┘

PHASE 4: HANDOFF (Before every exit)
┌─────────────────────────────────────────────────────────────────┐
│ MUST update .claude/nelson-handoff.local.md with:               │
│   - What was completed this iteration                           │
│   - What's still pending                                        │
│   - Any blockers or issues                                      │
│   - Exact next steps for next iteration                         │
│                                                                 │
│ ⚠️  Loop will NOT exit without updated handoff!                  │
└─────────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════
                       COMPLETION RULES
═══════════════════════════════════════════════════════════════════

To complete the loop, you MUST:
  1. Verify ALL features are done (two-stage validation)
  2. Update handoff with final status
  3. Output completion signal:

EOF

if [[ "$COMPLETION_PROMISE" != "null" ]]; then
  cat <<EOF
     <promise>$COMPLETION_PROMISE</promise>
     (ONLY if the statement is genuinely TRUE!)

     OR: <nelson-complete>ALL_FEATURES_COMPLETE</nelson-complete>
EOF
else
  cat <<EOF
     <nelson-complete>ALL_FEATURES_COMPLETE</nelson-complete>
EOF
fi

cat <<EOF

⚠️  FALSE completion signals will be detected and rejected!
    The loop continues until work is ACTUALLY complete.

═══════════════════════════════════════════════════════════════════
                          YOUR TASK
═══════════════════════════════════════════════════════════════════

$PROMPT

═══════════════════════════════════════════════════════════════════

EOF

if [[ "$HA_HA_MODE" == "true" ]]; then
  cat <<'EOF'
HA-HA MODE EXTRAS:
  • Pre-flight research MANDATORY before coding
  • Multi-dimensional thinking (4 levels of ultrathink)
  • Wall-Breaker protocol on ANY obstacle
  • 5-attempt escalation (not 3)
  • Aggressive self-review before completion

EOF
fi

cat <<EOF
▶ START: Read handoff → Plan → Select ONE feature → Begin work

EOF
