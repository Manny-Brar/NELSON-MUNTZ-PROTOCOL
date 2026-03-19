#!/bin/bash

# Nelson Muntz In-Session Loop Setup (v5.0.0)
# Harness-engineered loop initialization with drift detection, compound learning, and tool auto-detection
#
# Enhanced with:
#   - Mandatory planning phase
#   - Three-stage validation gates (spec + quality + red-team review)
#   - Structured handoff requirements with compound learning transfer
#   - Quality enforcement before completion
#   - v5.0: --parallel flag for worktree-isolated parallel agents
#   - v5.0: Drift detection initialization (edit tracker)
#   - v5.0: Tool auto-detection (Obsidian MCP, GWS CLI)
#   - v5.0: Compound learning setup
#   - v5.0: Enhanced state file with v5 fields
#
# v5.0.0 Changes:
#   - NEW: --parallel flag for worktree-isolated parallel execution
#   - NEW: Auto-detect Obsidian MCP (port 22360) and GWS CLI
#   - NEW: Initialize edit tracker for drift scoring
#   - NEW: v5 fields in state file (protocol_version, parallel_mode, tools_detected)
#   - NEW: Updated iteration protocol display with three-stage validation
#   - NEW: Compound learning in HA-HA mode extras
#   - PRESERVED: All v3.x backwards compatibility
#
# v3.10.0 Changes (preserved):
#   - FIX: Handle empty PROMPT_PARTS array with set -u
#
# v3.9.0 Changes (preserved):
#   - FIX: Disable glob expansion to handle ? and * in prompts
#   - FIX: Proper handling of special characters (!, ?, ", etc.)
#
# v3.8.0 Changes (preserved):
#   - NEW: Bracket-delimited task lists for flexible formatting
#
# v3.5.0 Changes (preserved):
#   - Default iterations: 16 (was unlimited)
#   - Maximum cap: 36 iterations
#   - 0 = unlimited (for advanced users who need extended loops)

# Disable glob expansion to prevent ? and * from being interpreted
set -f
set -euo pipefail

# Iteration limit constants (v3.5.0)
DEFAULT_ITERATIONS=16
MAX_ITERATIONS_CAP=36

# Parse arguments
PROMPT_PARTS=()
MAX_ITERATIONS=$DEFAULT_ITERATIONS
COMPLETION_PROMISE="null"
HA_HA_MODE=false
PARALLEL_MODE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      cat << 'HELP_EOF'
Nelson Muntz - Harness-Engineered Development Loop (v5.0.0)

USAGE:
  /nelson [PROMPT...] [OPTIONS]
  /ha-ha [PROMPT...] [OPTIONS]
  /nelson-muntz:ha-ha [PROMPT...] [OPTIONS]

ARGUMENTS:
  PROMPT...    Task to accomplish (can be multiple words)

TASK LIST FORMAT (use brackets for multiple tasks):
  Use ( ) to wrap your task list with flexible formatting:

  Examples:
    /nelson-muntz:ha-ha ( task1, task2, task3 ) --max-iterations 20
    /ha-ha ( task1, task2, task3 )
    /nelson ( task one, task two, task three )

  Parsing rules:
    - Newlines create separate tasks
    - Commas create separate tasks
    - Number prefixes (1., 2.) are cleaned up
    - Whitespace is trimmed
    - Empty entries are ignored

OPTIONS:
  --max-iterations <n>           Maximum iterations (default: 16, max: 36)
                                 Use 0 for unlimited (advanced)
  --completion-promise '<text>'  Promise phrase (USE QUOTES for multi-word)
  --ha-ha                        Enable HA-HA Mode (Peak Performance)
  --parallel                     Enable worktree-isolated parallel agents (v5.0)
  -h, --help                     Show this help

ITERATION PROTOCOL (v5.0):
  1. BOOT    - Tiered L0/L1/L2 context loading
  2. PLAN    - 5-level ULTRATHINK, select ONE feature
  3. WORK    - Implement with single-feature focus
  4. VERIFY  - Three-stage validation (spec + quality + red-team)
  5. COMPOUND - Extract pattern/anti-pattern (v5.0)
  6. HANDOFF  - Write structured handoff with compound learning

V5.0 FEATURES:
  - Drift detection with circuit breaker (score >= 7)
  - Compound learning (each iteration makes next easier)
  - Tiered context loading (L0/L1/L2 progressive disclosure)
  - Three-stage validation (spec + quality + adversarial red-team)
  - Tool auto-detection (Obsidian MCP, GWS CLI)

COMPLETION SIGNALS:
  - <promise>YOUR_PHRASE</promise>
  - <nelson-complete>ALL_FEATURES_COMPLETE</nelson-complete>

EXAMPLES:
  /nelson Build a REST API --max-iterations 20
  /nelson-muntz:ha-ha Build OAuth authentication system --max-iterations 30
  /ha-ha ( fix the login bug, add logout button, update tests )
  /nelson --parallel "Complex multi-file feature" --max-iterations 20

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
      # Apply cap (0 = unlimited is allowed for advanced users)
      if [[ $MAX_ITERATIONS -gt $MAX_ITERATIONS_CAP ]]; then
        echo "⚠️  Warning: Capping iterations at $MAX_ITERATIONS_CAP (requested: $MAX_ITERATIONS)" >&2
        MAX_ITERATIONS=$MAX_ITERATIONS_CAP
      fi
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
    --parallel)
      PARALLEL_MODE=true
      shift
      ;;
    *)
      PROMPT_PARTS+=("$1")
      shift
      ;;
  esac
done

# Handle empty array safely with set -u
PROMPT="${PROMPT_PARTS[*]:-}"

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

# ============================================================
# v5.0: Tool Auto-Detection
# ============================================================
TOOLS_DETECTED=""

# Check for Obsidian MCP (WebSocket on port 22360)
if command -v nc &> /dev/null && nc -z localhost 22360 2>/dev/null; then
  TOOLS_DETECTED="${TOOLS_DETECTED}obsidian,"
fi

# Check for GWS CLI
if command -v gws &> /dev/null; then
  TOOLS_DETECTED="${TOOLS_DETECTED}gws,"
fi

# Check for jq (needed for drift scoring)
if command -v jq &> /dev/null; then
  TOOLS_DETECTED="${TOOLS_DETECTED}jq,"
fi

# Trim trailing comma
TOOLS_DETECTED="${TOOLS_DETECTED%,}"

# ============================================================
# v5.0: Initialize Edit Tracker (for drift scoring)
# ============================================================
cat > .claude/nelson-edit-tracker.local.json <<TRACKER_EOF
{"edit_count":0,"files_touched":[],"timestamps":[],"iteration_start":"$(date -u +%Y-%m-%dT%H:%M:%SZ)"}
TRACKER_EOF

# Quote completion promise for YAML
if [[ -n "$COMPLETION_PROMISE" ]] && [[ "$COMPLETION_PROMISE" != "null" ]]; then
  COMPLETION_PROMISE_YAML="\"$COMPLETION_PROMISE\""
else
  COMPLETION_PROMISE_YAML="null"
fi

# Parse tasks from prompt using bracket syntax or numbered list
# Supports: ( task1, task2 ) or ( task1\ntask2 ) or numbered lists
TASK_COUNT=0
TASK_LIST=""
FORMATTED_TASK_LIST=""

# Function to parse tasks from content (handles commas, newlines, numbers)
parse_tasks() {
  local content="$1"
  local tasks=()

  # Replace newlines with a unique delimiter, then commas, to split
  # This handles: "task1, task2\ntask3" -> ["task1", "task2", "task3"]
  while IFS= read -r line; do
    # Split by comma
    IFS=',' read -ra parts <<< "$line"
    for part in "${parts[@]}"; do
      # Trim whitespace
      part=$(echo "$part" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
      # Remove number prefix (1., 2., etc.)
      part=$(echo "$part" | sed 's/^[0-9]*\.[[:space:]]*//')
      # Remove dash/bullet prefix (-, *, •)
      part=$(echo "$part" | sed 's/^[-*•][[:space:]]*//')
      # Skip empty
      if [[ -n "$part" ]]; then
        tasks+=("$part")
      fi
    done
  done <<< "$content"

  # Output tasks, one per line
  printf '%s\n' "${tasks[@]}"
}

# Check if prompt contains bracket-delimited task list: ( ... )
if [[ "$PROMPT" == *"("*")"* ]]; then
  # Extract content between first ( and last ) using bash parameter expansion
  # This handles multi-line content properly
  TEMP="${PROMPT#*(}"  # Remove everything up to and including first (
  BRACKET_CONTENT="${TEMP%)}"  # Remove the trailing )
  # Also remove any trailing ) that might remain
  BRACKET_CONTENT="${BRACKET_CONTENT%)*}"

  if [[ -n "$BRACKET_CONTENT" ]]; then
    # Parse the tasks from bracket content
    TASK_LIST=$(parse_tasks "$BRACKET_CONTENT")
    TASK_COUNT=$(echo "$TASK_LIST" | grep -c . || echo 0)

    # Create numbered formatted list for display
    i=1
    while IFS= read -r task; do
      if [[ -n "$task" ]]; then
        FORMATTED_TASK_LIST+="${i}. ${task}"$'\n'
        ((i++))
      fi
    done <<< "$TASK_LIST"

    # Remove trailing newline
    FORMATTED_TASK_LIST=$(echo "$FORMATTED_TASK_LIST" | sed '/^$/d')
  fi

# Fallback: Check for traditional numbered tasks (1. something, 2. something)
elif echo "$PROMPT" | grep -qE '^[[:space:]]*[0-9]+\.[[:space:]]+'; then
  TASK_LIST=$(echo "$PROMPT" | grep -E '^[[:space:]]*[0-9]+\.[[:space:]]+' | sed 's/^[[:space:]]*//')
  TASK_COUNT=$(echo "$TASK_LIST" | wc -l | tr -d ' ')
  FORMATTED_TASK_LIST="$TASK_LIST"
fi

# Default to 1 task if no task list found
if [[ $TASK_COUNT -eq 0 ]]; then
  TASK_COUNT=1
  FORMATTED_TASK_LIST="1. $PROMPT"
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
parallel_mode: $PARALLEL_MODE
protocol_version: "5.0.0"
tools_detected: "$TOOLS_DETECTED"
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
$FORMATTED_TASK_LIST

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
                 ITERATION PROTOCOL v5.0 (MANDATORY)
═══════════════════════════════════════════════════════════════════

PHASE 1: BOOT (Tiered context loading)
┌─────────────────────────────────────────────────────────────────┐
│ L0: Read handoff: cat .claude/nelson-handoff.local.md           │
│ L0: Read state: cat .claude/nelson-loop.local.md                │
│ L1: Skim scratchpad (first 30 lines only)                       │
│ L2: Load full skill files ONLY when triggered                   │
└─────────────────────────────────────────────────────────────────┘

PHASE 2: PLAN (5-level ULTRATHINK)
┌─────────────────────────────────────────────────────────────────┐
│ 1. Standard: What needs to be done?                             │
│ 2. Deep: Edge cases and dependencies?                           │
│ 3. Adversarial: What could go wrong?                            │
│ 4. Meta: Is this the best approach?                             │
│ 5. Compound: How does this make NEXT iteration easier?          │
│ Select ONE feature/task to complete this iteration              │
└─────────────────────────────────────────────────────────────────┘

PHASE 3: WORK (Single-feature focus)
┌─────────────────────────────────────────────────────────────────┐
│ 1. Implement the ONE selected feature                           │
│ 2. Do NOT touch other features                                  │
│ 3. Do NOT "quickly fix" unrelated issues                        │
│ 4. Commit working code: git commit -m "feat: description"       │
└─────────────────────────────────────────────────────────────────┘

PHASE 4: VERIFY (Three-stage validation)
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
│ Stage 3 - Red-Team Review (v5.0):                               │
│   □ How would I break this?                                     │
│   □ What assumptions could be wrong?                            │
│   □ What would a hostile reviewer flag?                         │
│                                                                 │
│ ⚠️  ALL THREE stages must pass before claiming done!             │
└─────────────────────────────────────────────────────────────────┘

PHASE 5: COMPOUND (Extract learning — v5.0)
┌─────────────────────────────────────────────────────────────────┐
│ Extract at least ONE of:                                        │
│   • Pattern: what worked and why (reusable)                     │
│   • Anti-pattern: what failed and why (preventable)             │
│ Document in handoff compound learning section                   │
└─────────────────────────────────────────────────────────────────┘

PHASE 6: HANDOFF (Before every exit)
┌─────────────────────────────────────────────────────────────────┐
│ MUST update .claude/nelson-handoff.local.md with:               │
│   1. What was accomplished (files, commits)                     │
│   2. Current state (tests, build status)                        │
│   3. Immediate next step (specific, actionable)                 │
│   4. Critical context (decisions, gotchas)                      │
│   5. Compound learning transfer (v5.0)                          │
│                                                                 │
│ ⚠️  Loop will NOT exit without updated handoff!                  │
└─────────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════
                       COMPLETION RULES
═══════════════════════════════════════════════════════════════════

To complete the loop, you MUST:
  1. Verify ALL features are done (three-stage validation)
  2. Update handoff with final status + compound learning
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
                          YOUR TASKS
═══════════════════════════════════════════════════════════════════

$FORMATTED_TASK_LIST

═══════════════════════════════════════════════════════════════════

EOF

if [[ "$HA_HA_MODE" == "true" ]]; then
  cat <<'EOF'
HA-HA MODE v5.0 EXTRAS:
  • Pre-flight research MANDATORY before coding
  • Multi-dimensional thinking (5 levels — includes compound analysis)
  • Wall-Breaker protocol on ANY obstacle
  • 5-attempt escalation (not 3)
  • Three-stage validation (spec + quality + adversarial red-team)
  • Compound learning extraction REQUIRED each iteration
  • Drift detection active (circuit breaker at score >= 7)

EOF
fi

# v5.0: Show detected tools
if [[ -n "$TOOLS_DETECTED" ]]; then
  cat <<EOF
v5.0 TOOLS DETECTED: $TOOLS_DETECTED
EOF
fi

if [[ "$PARALLEL_MODE" == "true" ]]; then
  cat <<'EOF'
PARALLEL MODE: Worktree isolation enabled for parallel agents

EOF
fi

cat <<EOF
▶ START: Read handoff → Plan → Select ONE feature → Begin work

EOF
