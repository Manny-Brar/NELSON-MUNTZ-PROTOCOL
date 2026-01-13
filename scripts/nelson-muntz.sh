#!/bin/bash

# =============================================================================
# Nelson Muntz - Peak Performance AI Development Loop
# =============================================================================
#
# The evolved successor to Ralph Wiggum. Fresh context every iteration,
# ultrathink integration, two-stage validation, and the 3-fix rule.
#
# Key Innovations:
#   - Fresh 200k context each iteration (no context rot)
#   - Ultrathink protocol for extended reasoning
#   - Two-stage validation (spec compliance + quality)
#   - 3-fix rule (escalate after 3 failed attempts)
#   - Git checkpointing on feature completion
#   - Initializer/Executor prompt split
#   - Single-feature focus enforcement
#   - Clean state gate at exit
#
# Usage:
#   nelson-muntz.sh start "PROMPT" [OPTIONS]
#   nelson-muntz.sh status
#   nelson-muntz.sh stop
#   nelson-muntz.sh resume
#
# Options:
#   --max-iterations N       Maximum iterations (default: unlimited)
#   --completion-promise TXT Promise phrase to signal completion
#   --model MODEL            Claude model (default: claude-opus-4-5-20250514)
#   --delay N                Seconds between iterations (default: 3)
#   --background             Run loop in background
#
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
STATE_DIR=".claude/ralph-v3"
PID_FILE=".claude/nelson-muntz.pid"
LOG_FILE=".claude/nelson-muntz.log"

# Default settings
MODEL="claude-opus-4-5-20250514"
DELAY=3
MAX_ITERATIONS=0
COMPLETION_PROMISE=""
BACKGROUND=false
HA_HA_MODE=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

log() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
  echo -e "${BLUE}[Nelson]${NC} $1"
  echo "$msg" >> "$LOG_FILE"
}

success() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $1"
  echo -e "${GREEN}[Nelson]${NC} $1"
  echo "$msg" >> "$LOG_FILE"
}

warn() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] WARN: $1"
  echo -e "${YELLOW}[Nelson]${NC} $1"
  echo "$msg" >> "$LOG_FILE"
}

error() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1"
  echo -e "${RED}[Nelson ERROR]${NC} $1" >&2
  echo "$msg" >> "$LOG_FILE"
}

haha() {
  echo -e "${MAGENTA}HA-HA!${NC}"
}

timestamp() {
  date -u +%Y-%m-%dT%H:%M:%SZ
}

# -----------------------------------------------------------------------------
# State Management
# -----------------------------------------------------------------------------

is_running() {
  if [[ -f "$PID_FILE" ]]; then
    local pid
    pid=$(cat "$PID_FILE")
    if kill -0 "$pid" 2>/dev/null; then
      return 0
    fi
  fi
  return 1
}

get_config_value() {
  local key="$1"
  local default="${2:-}"

  if [[ -f "$STATE_DIR/config.json" ]]; then
    jq -r ".$key // \"$default\"" "$STATE_DIR/config.json"
  else
    echo "$default"
  fi
}

set_config_value() {
  local key="$1"
  local value="$2"

  if [[ -f "$STATE_DIR/config.json" ]]; then
    local temp_file="${STATE_DIR}/config.json.tmp.$$"
    jq ".$key = $value | .last_updated = \"$(timestamp)\"" "$STATE_DIR/config.json" > "$temp_file"
    mv "$temp_file" "$STATE_DIR/config.json"
  fi
}

get_iteration() {
  get_config_value "iteration" "0"
}

get_features_summary() {
  if [[ -f "$STATE_DIR/features.json" ]]; then
    jq -r '.summary | "Total: \(.total), Completed: \(.completed), Blocked: \(.blocked), Pending: \(.pending)"' "$STATE_DIR/features.json"
  else
    echo "No features defined"
  fi
}

check_all_features_complete() {
  if [[ -f "$STATE_DIR/features.json" ]]; then
    local total completed blocked
    total=$(jq -r '.summary.total' "$STATE_DIR/features.json")
    completed=$(jq -r '.summary.completed' "$STATE_DIR/features.json")
    blocked=$(jq -r '.summary.blocked' "$STATE_DIR/features.json")

    # All features are either completed or blocked
    if [[ $((completed + blocked)) -ge $total ]] && [[ $total -gt 0 ]]; then
      return 0
    fi
  fi
  return 1
}

check_completion_promise() {
  local promise="$1"

  if [[ -z "$promise" ]]; then
    return 1
  fi

  # Check handoff.md for promise tag
  if [[ -f "$STATE_DIR/handoff.md" ]]; then
    if grep -q "<promise>$promise</promise>" "$STATE_DIR/handoff.md"; then
      return 0
    fi
  fi

  return 1
}

# -----------------------------------------------------------------------------
# Prompt Building
# -----------------------------------------------------------------------------

build_iteration_prompt() {
  local iteration="$1"
  local mode="${2:-standard}"
  local prompt_file

  if [[ $iteration -eq 1 ]]; then
    prompt_file="$PLUGIN_DIR/prompts/initializer.md"
  else
    prompt_file="$PLUGIN_DIR/prompts/executor.md"
  fi

  if [[ ! -f "$prompt_file" ]]; then
    error "Prompt file not found: $prompt_file"
    exit 1
  fi

  local prompt_content
  prompt_content=$(cat "$prompt_file")

  # Substitute iteration number
  prompt_content="${prompt_content//\{\{ITERATION\}\}/$iteration}"

  # Add ultrathink protocol
  local ultrathink
  ultrathink=$(cat "$PLUGIN_DIR/prompts/ultrathink.md")

  # HA-HA Mode additions
  local ha_ha_content=""
  local auto_research=""
  local mode_banner=""

  if [[ "$mode" == "ha-ha" ]]; then
    if [[ -f "$PLUGIN_DIR/prompts/ha-ha-mode.md" ]]; then
      ha_ha_content=$(cat "$PLUGIN_DIR/prompts/ha-ha-mode.md")
    fi
    if [[ -f "$PLUGIN_DIR/prompts/auto-research-protocol.md" ]]; then
      auto_research=$(cat "$PLUGIN_DIR/prompts/auto-research-protocol.md")
    fi
    mode_banner="🎯 HA-HA MODE ACTIVE - PEAK PERFORMANCE ENABLED 🎯"
  else
    mode_banner="Standard Nelson Mode"
  fi

  cat << EOF
$ultrathink

---

$prompt_content

---

EOF

  # Add HA-HA mode content if enabled
  if [[ "$mode" == "ha-ha" ]]; then
    cat << EOF
---

$ha_ha_content

---

$auto_research

---

EOF
  fi

  cat << EOF
## Current Iteration: $iteration

**Mode:** $mode_banner
**State Directory:** $STATE_DIR
**Model:** $MODEL
**Started:** $(timestamp)

Remember:
- Read ALL state files FIRST
- Engage ultrathink protocol
- Single feature focus
- Clean state at exit
- Update handoff.md
EOF

  # Additional HA-HA mode reminders
  if [[ "$mode" == "ha-ha" ]]; then
    cat << EOF

**HA-HA MODE REQUIREMENTS:**
- Pre-flight research MANDATORY before coding
- Multi-dimensional thinking (4 levels)
- Wall-Breaker protocol on any obstacle
- Auto-research on failures
- 5-attempt escalation (not 3)
- Comprehensive iteration report required
EOF
  fi
}

# -----------------------------------------------------------------------------
# Git Operations
# -----------------------------------------------------------------------------

git_checkpoint() {
  local feature_id="$1"
  local iteration="$2"
  local description="${3:-Feature completed}"

  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    warn "Not a git repository - skipping checkpoint"
    return 0
  fi

  log "Creating git checkpoint for $feature_id"

  git add -A

  # Check if there are changes to commit
  if git diff --cached --quiet; then
    log "No changes to commit"
    return 0
  fi

  git commit -m "feat($feature_id): $description

Nelson Muntz iteration $iteration
Model: $MODEL
Timestamp: $(timestamp)"

  success "Git checkpoint created"

  # Update stats
  local commits
  commits=$(get_config_value "stats.git_commits" "0")
  set_config_value "stats.git_commits" "$((commits + 1))"
}

# -----------------------------------------------------------------------------
# Main Loop
# -----------------------------------------------------------------------------

run_loop() {
  log "Starting Nelson Muntz loop..."
  echo $$ > "$PID_FILE"

  local max_iterations completion_promise delay

  max_iterations=$(get_config_value "max_iterations" "0")
  completion_promise=$(get_config_value "completion_promise" "")
  delay="$DELAY"

  while true; do
    # Check if loop should stop
    if [[ ! -f "$STATE_DIR/config.json" ]]; then
      warn "State directory removed. Stopping."
      break
    fi

    local active
    active=$(get_config_value "active" "true")
    if [[ "$active" != "true" ]]; then
      log "Loop marked inactive. Stopping."
      break
    fi

    # Get current iteration
    local iteration
    iteration=$(get_iteration)
    iteration=$((iteration + 1))

    # Check max iterations
    if [[ $max_iterations -gt 0 ]] && [[ $iteration -gt $max_iterations ]]; then
      success "Max iterations ($max_iterations) reached."
      set_config_value "active" "false"
      break
    fi

    # Check completion promise
    if [[ -n "$completion_promise" ]] && check_completion_promise "$completion_promise"; then
      success "Completion promise detected: $completion_promise"
      haha
      set_config_value "active" "false"
      break
    fi

    # Check if all features complete
    if [[ $iteration -gt 1 ]] && check_all_features_complete; then
      success "All features complete!"
      haha
      set_config_value "active" "false"
      break
    fi

    # Update iteration count
    set_config_value "iteration" "$iteration"
    set_config_value "stats.total_iterations" "$iteration"

    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}║           ITERATION $iteration                                      ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""

    log "Features: $(get_features_summary)"

    # Determine mode
    local mode="standard"
    local ha_ha_active
    ha_ha_active=$(get_config_value "ha_ha_mode" "false")
    if [[ "$ha_ha_active" == "true" ]]; then
      mode="ha-ha"
    fi

    # Build prompt
    local prompt
    prompt=$(build_iteration_prompt "$iteration" "$mode")

    # Run Claude with fresh context
    log "Spawning fresh Claude session (Opus 4.5)..."

    local start_time
    start_time=$(date +%s)

    # Run claude CLI
    if ! claude --model "$MODEL" --print "$prompt" 2>&1 | tee -a "$LOG_FILE"; then
      warn "Claude session exited with error"
    fi

    local end_time duration
    end_time=$(date +%s)
    duration=$((end_time - start_time))

    log "Iteration $iteration completed in ${duration}s"

    # Check for feature completion and create git checkpoint
    if [[ -f "$STATE_DIR/features.json" ]]; then
      local completed_feature
      completed_feature=$(jq -r '.features[] | select(.status == "completed" and .passes == true) | .id' "$STATE_DIR/features.json" | tail -1)

      if [[ -n "$completed_feature" ]]; then
        local feature_desc
        feature_desc=$(jq -r --arg id "$completed_feature" '.features[] | select(.id == $id) | .description' "$STATE_DIR/features.json")
        git_checkpoint "$completed_feature" "$iteration" "$feature_desc"
      fi
    fi

    # Delay between iterations
    log "Waiting ${delay}s before next iteration..."
    sleep "$delay"
  done

  rm -f "$PID_FILE"
  success "Nelson Muntz loop ended."
}

# -----------------------------------------------------------------------------
# Commands
# -----------------------------------------------------------------------------

cmd_start() {
  if is_running; then
    error "Nelson loop already running (PID: $(cat "$PID_FILE"))"
    exit 1
  fi

  # Parse start arguments
  local prompt=""

  while [[ $# -gt 0 ]]; do
    case $1 in
      --max-iterations)
        MAX_ITERATIONS="$2"
        shift 2
        ;;
      --completion-promise)
        COMPLETION_PROMISE="$2"
        shift 2
        ;;
      --model)
        MODEL="$2"
        shift 2
        ;;
      --delay)
        DELAY="$2"
        shift 2
        ;;
      --background|-b)
        BACKGROUND=true
        shift
        ;;
      --ha-ha|--haha)
        HA_HA_MODE=true
        shift
        ;;
      -*)
        error "Unknown option: $1"
        exit 1
        ;;
      *)
        if [[ -z "$prompt" ]]; then
          prompt="$1"
        else
          prompt="$prompt $1"
        fi
        shift
        ;;
    esac
  done

  if [[ -z "$prompt" ]]; then
    error "No prompt provided"
    echo "Usage: nelson-muntz.sh start \"PROMPT\" [OPTIONS]"
    exit 1
  fi

  # Initialize log file
  mkdir -p .claude
  echo "=== Nelson Muntz Session Started: $(timestamp) ===" > "$LOG_FILE"

  # Initialize state
  log "Initializing state..."
  "$SCRIPT_DIR/init-v3-state.sh" "$prompt" \
    --max-iterations "$MAX_ITERATIONS" \
    --model "$MODEL" \
    ${COMPLETION_PROMISE:+--completion-promise "$COMPLETION_PROMISE"} \
    ${HA_HA_MODE:+--ha-ha}

  echo ""
  echo -e "${MAGENTA}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${MAGENTA}║                                                            ║${NC}"
  echo -e "${MAGENTA}║   ███╗   ██╗███████╗██╗     ███████╗ ██████╗ ███╗   ██╗    ║${NC}"
  echo -e "${MAGENTA}║   ████╗  ██║██╔════╝██║     ██╔════╝██╔═══██╗████╗  ██║    ║${NC}"
  echo -e "${MAGENTA}║   ██╔██╗ ██║█████╗  ██║     ███████╗██║   ██║██╔██╗ ██║    ║${NC}"
  echo -e "${MAGENTA}║   ██║╚██╗██║██╔══╝  ██║     ╚════██║██║   ██║██║╚██╗██║    ║${NC}"
  echo -e "${MAGENTA}║   ██║ ╚████║███████╗███████╗███████║╚██████╔╝██║ ╚████║    ║${NC}"
  echo -e "${MAGENTA}║   ╚═╝  ╚═══╝╚══════╝╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝    ║${NC}"
  echo -e "${MAGENTA}║                                                            ║${NC}"
  echo -e "${MAGENTA}║                    MUNTZ v3.0                              ║${NC}"
  echo -e "${MAGENTA}║           Peak Performance Development Loop                ║${NC}"
  echo -e "${MAGENTA}║                                                            ║${NC}"
  echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════╝${NC}"
  echo ""

  # Show HA-HA mode banner if active
  if [[ "$HA_HA_MODE" == "true" ]]; then
    echo ""
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  🎯  HA-HA MODE ACTIVE - PEAK PERFORMANCE ENABLED  🎯     ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
  fi

  log "Configuration:"
  echo "  Mode:                $(if [[ "$HA_HA_MODE" == "true" ]]; then echo "HA-HA (Peak Performance)"; else echo "Standard"; fi)"
  echo "  Prompt:              $(echo "$prompt" | head -c 60)..."
  echo "  Model:               $MODEL"
  echo "  Max Iterations:      $(if [[ $MAX_ITERATIONS -gt 0 ]]; then echo $MAX_ITERATIONS; else echo "Unlimited"; fi)"
  echo "  Completion Promise:  ${COMPLETION_PROMISE:-None}"
  echo "  Delay:               ${DELAY}s"
  if [[ "$HA_HA_MODE" == "true" ]]; then
    echo "  Max Attempts:        5 (HA-HA escalation)"
    echo "  Pre-Research:        MANDATORY"
    echo "  Auto-Research:       ON (wall-breaker)"
  else
    echo "  Max Attempts:        3 (standard)"
  fi
  echo ""

  if [[ "$BACKGROUND" == "true" ]]; then
    nohup "$0" _run_loop > /dev/null 2>&1 &
    echo $! > "$PID_FILE"
    success "Loop started in background (PID: $!)"
    echo ""
    echo "Monitor with:"
    echo "  tail -f $LOG_FILE"
    echo "  nelson-muntz.sh status"
  else
    run_loop
  fi
}

cmd_status() {
  echo ""
  echo -e "${CYAN}═══ Nelson Muntz Status ═══${NC}"
  echo ""

  if is_running; then
    success "Status: RUNNING (PID: $(cat "$PID_FILE"))"
  else
    if [[ -f "$STATE_DIR/config.json" ]]; then
      local active
      active=$(get_config_value "active" "false")
      if [[ "$active" == "true" ]]; then
        warn "Status: STOPPED (can resume)"
      else
        log "Status: COMPLETED"
      fi
    else
      log "Status: NOT INITIALIZED"
      return
    fi
  fi

  if [[ -f "$STATE_DIR/config.json" ]]; then
    echo ""
    local ha_ha_status
    ha_ha_status=$(get_config_value "ha_ha_mode" "false")
    if [[ "$ha_ha_status" == "true" ]]; then
      echo -e "${YELLOW}Mode:                HA-HA (Peak Performance)${NC}"
    else
      echo "Mode:                Standard"
    fi
    echo "Iteration:           $(get_iteration)"
    echo "Max Iterations:      $(get_config_value "max_iterations" "Unlimited")"
    echo "Model:               $(get_config_value "model" "unknown")"
    echo "Completion Promise:  $(get_config_value "completion_promise" "None")"
    echo "Started:             $(get_config_value "started_at" "unknown")"
    echo "Last Updated:        $(get_config_value "last_updated" "unknown")"
    echo ""
    echo "Features: $(get_features_summary)"
    echo ""
    echo "Git Commits:         $(get_config_value "stats.git_commits" "0")"
    if [[ "$ha_ha_status" == "true" ]]; then
      echo ""
      echo -e "${YELLOW}HA-HA Mode Enhancements Active:${NC}"
      echo "  - Pre-flight research mandatory"
      echo "  - Multi-dimensional thinking (4 levels)"
      echo "  - Wall-Breaker auto-research"
      echo "  - 5-attempt escalation"
    fi
  fi

  echo ""
  echo "Log file: $LOG_FILE"
  echo "State:    $STATE_DIR"
  echo ""
}

cmd_stop() {
  if is_running; then
    local pid
    pid=$(cat "$PID_FILE")
    log "Stopping Nelson loop (PID: $pid)..."
    kill "$pid" 2>/dev/null || true
    rm -f "$PID_FILE"
    set_config_value "active" "false"
    success "Loop stopped."
  else
    log "No running loop to stop."
  fi
}

cmd_resume() {
  if is_running; then
    error "Loop already running."
    exit 1
  fi

  if [[ ! -f "$STATE_DIR/config.json" ]]; then
    error "No state to resume. Use 'start' to begin a new loop."
    exit 1
  fi

  set_config_value "active" "true"
  log "Resuming Nelson loop..."
  run_loop
}

show_help() {
  cat << 'HELP'
Nelson Muntz - Peak Performance AI Development Loop

USAGE:
  nelson-muntz.sh start "PROMPT" [OPTIONS]
  nelson-muntz.sh status
  nelson-muntz.sh stop
  nelson-muntz.sh resume

COMMANDS:
  start    Initialize and start a new loop
  status   Show current loop status
  stop     Stop the running loop
  resume   Resume a stopped loop

OPTIONS (for start):
  --max-iterations N       Maximum iterations (default: unlimited)
  --completion-promise TXT Promise phrase to signal completion
  --model MODEL            Claude model (default: claude-opus-4-5-20250514)
  --delay N                Seconds between iterations (default: 3)
  --background, -b         Run loop in background
  --ha-ha                  Enable HA-HA Mode (Peak Performance)

STANDARD FEATURES:
  - Fresh 200k context each iteration (no context rot)
  - Ultrathink protocol for extended reasoning
  - Two-stage validation (spec + quality)
  - 3-fix rule (auto-escalate after 3 failures)
  - Git checkpointing on feature completion
  - Single-feature focus enforcement
  - Clean state gate at exit

HA-HA MODE FEATURES (--ha-ha):
  - ALL standard features PLUS:
  - Pre-flight research MANDATORY before coding
  - Multi-dimensional thinking (4 ultrathink levels)
  - Wall-Breaker protocol with auto web search
  - 5-attempt escalation (extended from 3)
  - Parallel exploration of approaches
  - Self-reflection checkpoints
  - Pattern recognition and library building
  - Comprehensive iteration reports

WHEN TO USE HA-HA MODE:
  - Complex, multi-component features
  - Unfamiliar technologies
  - Critical system components
  - When standard mode keeps failing

EXAMPLES:
  # Standard mode
  nelson-muntz.sh start "Build a REST API" --max-iterations 30

  # HA-HA Mode for complex tasks
  nelson-muntz.sh start "Build OAuth + JWT + MFA auth system" --ha-ha

  # HA-HA Mode with completion promise
  nelson-muntz.sh start "Add real-time sync" \
    --ha-ha \
    --completion-promise "ALL TESTS PASS" \
    --max-iterations 50

  # Run in background
  nelson-muntz.sh start "Refactor module" --ha-ha --background

  # Check status
  nelson-muntz.sh status

  # Stop loop
  nelson-muntz.sh stop

MONITORING:
  tail -f .claude/nelson-muntz.log    # Watch live log
  cat .claude/ralph-v3/handoff.md     # See latest handoff
  cat .claude/ralph-v3/features.json  # Check feature status
  cat .claude/ralph-v3/scratchpad.md  # Research notes (HA-HA mode)

HA-HA!
HELP
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

main() {
  case "${1:-}" in
    start)
      shift
      cmd_start "$@"
      ;;
    status)
      cmd_status
      ;;
    stop)
      cmd_stop
      ;;
    resume)
      cmd_resume
      ;;
    _run_loop)
      # Internal command for background execution
      run_loop
      ;;
    -h|--help|help|"")
      show_help
      ;;
    *)
      error "Unknown command: $1"
      echo "Use 'nelson-muntz.sh --help' for usage."
      exit 1
      ;;
  esac
}

main "$@"
