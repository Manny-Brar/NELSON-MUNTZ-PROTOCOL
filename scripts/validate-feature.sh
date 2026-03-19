#!/bin/bash

# =============================================================================
# Nelson Muntz v5.0 — Three-Stage Feature Validation Script
# =============================================================================
#
# Performs three-stage validation on the current feature:
#   Stage 1: Spec Compliance - Did we implement what was asked?
#   Stage 2: Quality Check - Is the code good? (tests, lint, build)
#   Stage 3: Red-Team Review - Automated adversarial checks (v5.0)
#
# Plus v5.0 compound learning prompt and drift score.
# All three stages must pass for a feature to be marked as complete.
#
# Usage:
#   ./validate-feature.sh [OPTIONS]
#
# Options:
#   --feature-id FX        Feature ID to validate (default: current)
#   --state-dir DIR        State directory (default: .claude/ralph-v3)
#   --skip-spec            Skip spec compliance check
#   --skip-quality         Skip quality check
#   --skip-redteam         Skip red-team review (v5.0)
#   --verbose              Show detailed output
#
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

STATE_DIR=".claude/ralph-v3"
FEATURE_ID=""
SKIP_SPEC=false
SKIP_QUALITY=false
SKIP_REDTEAM=false
VERBOSE=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Test commands (can be overridden via quality-check.json)
TEST_CMD="npm run test"
LINT_CMD="npm run lint"
BUILD_CMD="npm run build"
TYPE_CHECK_CMD="npx tsc --noEmit"

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

log() {
  echo -e "${BLUE}[Nelson]${NC} $1"
}

success() {
  echo -e "${GREEN}[✓]${NC} $1"
}

fail() {
  echo -e "${RED}[✗]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[!]${NC} $1"
}

verbose() {
  if [[ "$VERBOSE" == "true" ]]; then
    echo -e "${CYAN}[...]${NC} $1"
  fi
}

timestamp() {
  date -u +%Y-%m-%dT%H:%M:%SZ
}

# Check if command exists
cmd_exists() {
  command -v "$1" &> /dev/null
}

# Run command and capture result
run_check() {
  local cmd="$1"
  local name="$2"

  verbose "Running: $cmd"

  local output
  local exit_code

  if output=$(eval "$cmd" 2>&1); then
    exit_code=0
  else
    exit_code=$?
  fi

  if [[ "$VERBOSE" == "true" ]]; then
    echo "$output" | head -20
  fi

  return $exit_code
}

# Update JSON file with jq
update_json() {
  local file="$1"
  local filter="$2"
  local temp_file="${file}.tmp.$$"

  jq "$filter" "$file" > "$temp_file" && mv "$temp_file" "$file"
}

# -----------------------------------------------------------------------------
# Parse Arguments
# -----------------------------------------------------------------------------

parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      --feature-id)
        FEATURE_ID="$2"
        shift 2
        ;;
      --state-dir)
        STATE_DIR="$2"
        shift 2
        ;;
      --skip-spec)
        SKIP_SPEC=true
        shift
        ;;
      --skip-quality)
        SKIP_QUALITY=true
        shift
        ;;
      --skip-redteam)
        SKIP_REDTEAM=true
        shift
        ;;
      --verbose|-v)
        VERBOSE=true
        shift
        ;;
      -h|--help)
        show_help
        exit 0
        ;;
      *)
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
  done
}

show_help() {
  cat << 'HELP'
Nelson Muntz v5.0 - Three-Stage Feature Validation

USAGE:
  validate-feature.sh [OPTIONS]

OPTIONS:
  --feature-id FX    Feature ID to validate (default: current in_progress feature)
  --state-dir DIR    State directory (default: .claude/ralph-v3)
  --skip-spec        Skip spec compliance check
  --skip-quality     Skip quality check
  --skip-redteam     Skip red-team review (v5.0 Stage 3)
  --verbose, -v      Show detailed output
  -h, --help         Show this help

STAGES:
  Stage 1: Spec Compliance
    - Checks if all requirements in spec-check.json are marked as implemented
    - Fails if any requirement is not implemented

  Stage 2: Quality Check
    - Runs tests (npm run test)
    - Runs linter (npm run lint)
    - Runs build (npm run build)
    - Runs type check (npx tsc --noEmit)
    - Fails if any check fails

  Stage 3: Red-Team Review (v5.0)
    - Checks for common security issues (console.log leaks, TODO/FIXME, hardcoded secrets)
    - Checks for error handling gaps
    - Reports findings by severity (CRITICAL/HIGH/MEDIUM/LOW)
    - Fails on any CRITICAL finding

  Compound Learning (v5.0):
    - After validation, shows drift score
    - Prompts for pattern/anti-pattern extraction

OUTPUTS:
  - Updates validation/spec-check.json with results
  - Updates validation/quality-check.json with results
  - Shows red-team findings and drift score
  - Returns exit code 0 if all stages pass, 1 otherwise

HELP
}

# -----------------------------------------------------------------------------
# Stage 1: Spec Compliance Check
# -----------------------------------------------------------------------------

check_spec_compliance() {
  log "Stage 1: Spec Compliance Check"

  local spec_file="$STATE_DIR/validation/spec-check.json"

  if [[ ! -f "$spec_file" ]]; then
    warn "No spec-check.json found - creating template"
    mkdir -p "$(dirname "$spec_file")"
    cat > "$spec_file" << 'EOF'
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
    return 1
  fi

  # Get current feature
  local current_feature
  current_feature=$(jq -r '.current_feature // empty' "$spec_file")

  if [[ -z "$current_feature" ]]; then
    warn "No current feature set in spec-check.json"
    return 1
  fi

  # Check all requirements
  local requirements
  local implemented
  local all_pass=true

  requirements=$(jq -r '.requirements[]' "$spec_file" 2>/dev/null || echo "")
  implemented=$(jq -r '.implemented' "$spec_file")

  if [[ -z "$requirements" ]]; then
    warn "No requirements defined for feature $current_feature"
    return 1
  fi

  echo ""
  echo "Feature: $current_feature"
  echo "Requirements:"

  while IFS= read -r req; do
    if [[ -z "$req" ]]; then continue; fi

    local status
    status=$(echo "$implemented" | jq -r --arg req "$req" '.[$req] // false')

    if [[ "$status" == "true" ]]; then
      success "  $req"
    else
      fail "  $req"
      all_pass=false
    fi
  done <<< "$requirements"

  echo ""

  # Update spec-check.json
  if [[ "$all_pass" == "true" ]]; then
    update_json "$spec_file" ".spec_passes = true | .last_checked = \"$(timestamp)\""
    success "Spec compliance: PASS"
    return 0
  else
    update_json "$spec_file" ".spec_passes = false | .last_checked = \"$(timestamp)\""
    fail "Spec compliance: FAIL"
    return 1
  fi
}

# -----------------------------------------------------------------------------
# Stage 2: Quality Check
# -----------------------------------------------------------------------------

check_quality() {
  log "Stage 2: Quality Check"

  local quality_file="$STATE_DIR/validation/quality-check.json"

  if [[ ! -f "$quality_file" ]]; then
    warn "No quality-check.json found - creating template"
    mkdir -p "$(dirname "$quality_file")"
    cat > "$quality_file" << 'EOF'
{
  "version": "3.0.0",
  "tests": {"pass": null, "count": 0, "failures": 0, "command": "npm run test"},
  "lint": {"pass": null, "errors": 0, "warnings": 0, "command": "npm run lint"},
  "build": {"pass": null, "command": "npm run build"},
  "type_check": {"pass": null, "errors": 0, "command": "npx tsc --noEmit"},
  "quality_passes": false,
  "last_checked": null
}
EOF
  fi

  # Read commands from config
  TEST_CMD=$(jq -r '.tests.command // "npm run test"' "$quality_file")
  LINT_CMD=$(jq -r '.lint.command // "npm run lint"' "$quality_file")
  BUILD_CMD=$(jq -r '.build.command // "npm run build"' "$quality_file")
  TYPE_CHECK_CMD=$(jq -r '.type_check.command // "npx tsc --noEmit"' "$quality_file")

  local all_pass=true
  local tests_pass=true
  local lint_pass=true
  local build_pass=true
  local type_pass=true

  echo ""

  # Run tests
  echo -n "Running tests... "
  if run_check "$TEST_CMD" "tests"; then
    success "PASS"
    update_json "$quality_file" '.tests.pass = true'
  else
    fail "FAIL"
    update_json "$quality_file" '.tests.pass = false'
    tests_pass=false
    all_pass=false
  fi

  # Run lint
  echo -n "Running linter... "
  if run_check "$LINT_CMD" "lint"; then
    success "PASS"
    update_json "$quality_file" '.lint.pass = true'
  else
    fail "FAIL"
    update_json "$quality_file" '.lint.pass = false'
    lint_pass=false
    all_pass=false
  fi

  # Run build
  echo -n "Running build... "
  if run_check "$BUILD_CMD" "build"; then
    success "PASS"
    update_json "$quality_file" '.build.pass = true'
  else
    fail "FAIL"
    update_json "$quality_file" '.build.pass = false'
    build_pass=false
    all_pass=false
  fi

  # Run type check (optional, may not exist)
  if [[ -f "tsconfig.json" ]] || [[ -f "jsconfig.json" ]]; then
    echo -n "Running type check... "
    if run_check "$TYPE_CHECK_CMD" "type_check"; then
      success "PASS"
      update_json "$quality_file" '.type_check.pass = true'
    else
      fail "FAIL"
      update_json "$quality_file" '.type_check.pass = false'
      type_pass=false
      all_pass=false
    fi
  else
    verbose "Skipping type check (no tsconfig.json)"
    update_json "$quality_file" '.type_check.pass = null'
  fi

  echo ""

  # Update quality-check.json
  if [[ "$all_pass" == "true" ]]; then
    update_json "$quality_file" ".quality_passes = true | .last_checked = \"$(timestamp)\""
    success "Quality check: PASS"
    return 0
  else
    update_json "$quality_file" ".quality_passes = false | .last_checked = \"$(timestamp)\""
    fail "Quality check: FAIL"
    return 1
  fi
}

# -----------------------------------------------------------------------------
# Stage 3: Red-Team Review (v5.0)
# -----------------------------------------------------------------------------

check_redteam() {
  log "Stage 3: Red-Team Review (v5.0)"

  local findings=0
  local critical=0
  local high=0
  local medium=0
  local low=0

  echo ""

  # Check for console.log/console.debug left in production code
  local console_count=0
  if cmd_exists grep; then
    console_count=$(grep -r "console\.\(log\|debug\)" --include="*.ts" --include="*.js" --include="*.tsx" --include="*.jsx" src/ app/ lib/ 2>/dev/null | grep -v "node_modules" | grep -v ".test." | grep -v ".spec." | wc -l | tr -d ' ' || echo "0")
  fi
  if [[ "$console_count" -gt 0 ]]; then
    warn "MEDIUM: $console_count console.log/debug statements in production code"
    medium=$((medium + 1))
    findings=$((findings + 1))
  else
    success "No console.log leaks in production code"
  fi

  # Check for TODO/FIXME/HACK/XXX comments
  local todo_count=0
  if cmd_exists grep; then
    todo_count=$(grep -rn "TODO\|FIXME\|HACK\|XXX" --include="*.ts" --include="*.js" --include="*.tsx" --include="*.jsx" --include="*.py" src/ app/ lib/ 2>/dev/null | grep -v "node_modules" | wc -l | tr -d ' ' || echo "0")
  fi
  if [[ "$todo_count" -gt 0 ]]; then
    warn "LOW: $todo_count TODO/FIXME/HACK comments found"
    low=$((low + 1))
    findings=$((findings + 1))
  else
    success "No TODO/FIXME/HACK comments"
  fi

  # Check for hardcoded secrets patterns
  local secret_count=0
  if cmd_exists grep; then
    secret_count=$(grep -rnE "(password|secret|api_key|apikey|token)\s*[:=]\s*['\"][^'\"]{8,}" --include="*.ts" --include="*.js" --include="*.tsx" --include="*.py" --include="*.env.example" src/ app/ lib/ 2>/dev/null | grep -v "node_modules" | grep -vi "process\.env" | grep -vi "example\|placeholder\|changeme\|your_" | wc -l | tr -d ' ' || echo "0")
  fi
  if [[ "$secret_count" -gt 0 ]]; then
    fail "CRITICAL: $secret_count potential hardcoded secrets found"
    critical=$((critical + 1))
    findings=$((findings + 1))
  else
    success "No hardcoded secrets detected"
  fi

  # Check for missing error handling (catch blocks with no content)
  local empty_catch=0
  if cmd_exists grep; then
    empty_catch=$(grep -rnE "catch\s*\([^)]*\)\s*\{[\s]*\}" --include="*.ts" --include="*.js" --include="*.tsx" src/ app/ lib/ 2>/dev/null | grep -v "node_modules" | wc -l | tr -d ' ' || echo "0")
  fi
  if [[ "$empty_catch" -gt 0 ]]; then
    warn "HIGH: $empty_catch empty catch blocks (swallowed errors)"
    high=$((high + 1))
    findings=$((findings + 1))
  else
    success "No empty catch blocks"
  fi

  # Check for files that are too large (>500 lines, potential complexity)
  local large_files=0
  if cmd_exists find && cmd_exists wc; then
    large_files=$(find src/ app/ lib/ -name "*.ts" -o -name "*.js" -o -name "*.tsx" 2>/dev/null | while read -r f; do
      lines=$(wc -l < "$f" 2>/dev/null | tr -d ' ')
      if [[ "$lines" -gt 500 ]]; then echo "$f"; fi
    done | wc -l | tr -d ' ' || echo "0")
  fi
  if [[ "$large_files" -gt 0 ]]; then
    warn "LOW: $large_files files exceed 500 lines (consider splitting)"
    low=$((low + 1))
    findings=$((findings + 1))
  else
    success "No overly large files"
  fi

  echo ""
  echo "Red-Team Summary: $findings findings (Critical:$critical High:$high Medium:$medium Low:$low)"

  # Fail only on CRITICAL findings
  if [[ "$critical" -gt 0 ]]; then
    fail "Red-team review: FAIL (critical findings)"
    return 1
  elif [[ "$findings" -gt 0 ]]; then
    warn "Red-team review: PASS with warnings ($findings non-critical findings)"
    return 0
  else
    success "Red-team review: PASS (clean)"
    return 0
  fi
}

# -----------------------------------------------------------------------------
# v5.0: Drift Score & Compound Learning Prompt
# -----------------------------------------------------------------------------

show_drift_and_compound() {
  log "v5.0: Drift & Compound Learning"
  echo ""

  # Calculate drift score from edit tracker
  local drift=0
  local tracker=".claude/nelson-edit-tracker.local.json"

  if [[ -f "$tracker" ]] && cmd_exists jq; then
    local ec fc
    ec=$(jq '.edit_count // 0' "$tracker" 2>/dev/null || echo "0")
    fc=$(jq '.files_touched | length' "$tracker" 2>/dev/null || echo "0")

    [[ "$ec" -gt 30 ]] && drift=$((drift + 2))
    [[ "$ec" -gt 20 ]] && [[ "$ec" -le 30 ]] && drift=$((drift + 1))
    [[ "$fc" -gt 8 ]] && drift=$((drift + 2))
    [[ "$fc" -gt 5 ]] && [[ "$fc" -le 8 ]] && drift=$((drift + 1))

    echo "Drift Score: $drift/10 (edits:$ec files:$fc)"
    if [[ "$drift" -ge 7 ]]; then
      fail "CIRCUIT BREAKER TERRITORY — consider fresh context"
    elif [[ "$drift" -ge 5 ]]; then
      warn "WARNING — elevated drift, monitor closely"
    else
      success "Drift within healthy range"
    fi
  else
    echo "Drift Score: N/A (no edit tracker)"
  fi

  echo ""
  echo "Compound Learning Reminder:"
  echo "  Extract at least ONE of:"
  echo "    - Pattern: what worked and why (reusable)"
  echo "    - Anti-pattern: what failed and why (preventable)"
  echo "  Document in handoff compound learning section."
  echo ""
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

main() {
  parse_args "$@"

  echo ""
  echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║       Nelson Muntz v5.0 - Three-Stage Validation          ║${NC}"
  echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
  echo ""

  local spec_result=0
  local quality_result=0
  local redteam_result=0

  # Stage 1: Spec Compliance
  if [[ "$SKIP_SPEC" != "true" ]]; then
    if ! check_spec_compliance; then
      spec_result=1
    fi
  else
    warn "Skipping spec compliance check"
  fi

  # Stage 2: Quality Check
  if [[ "$SKIP_QUALITY" != "true" ]]; then
    if ! check_quality; then
      quality_result=1
    fi
  else
    warn "Skipping quality check"
  fi

  # Stage 3: Red-Team Review (v5.0)
  if [[ "$SKIP_REDTEAM" != "true" ]]; then
    if ! check_redteam; then
      redteam_result=1
    fi
  else
    warn "Skipping red-team review"
  fi

  # v5.0: Drift score and compound learning prompt
  show_drift_and_compound

  # Final result
  echo "═══════════════════════════════════════════════════════════"

  if [[ $spec_result -eq 0 ]] && [[ $quality_result -eq 0 ]] && [[ $redteam_result -eq 0 ]]; then
    success "THREE-STAGE VALIDATION PASSED - Feature ready for commit"
    echo ""
    echo "HA-HA! Feature validated across all three stages."
    exit 0
  else
    fail "VALIDATION FAILED"
    if [[ $spec_result -ne 0 ]]; then
      echo "  - Stage 1 Spec compliance: FAILED"
    fi
    if [[ $quality_result -ne 0 ]]; then
      echo "  - Stage 2 Quality check: FAILED"
    fi
    if [[ $redteam_result -ne 0 ]]; then
      echo "  - Stage 3 Red-team review: FAILED (critical findings)"
    fi
    echo ""
    echo "Fix the issues and try again."
    exit 1
  fi
}

main "$@"
