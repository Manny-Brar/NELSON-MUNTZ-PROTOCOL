#!/bin/bash

# =============================================================================
# Nelson Muntz - Two-Stage Feature Validation Script
# =============================================================================
#
# Performs two-stage validation on the current feature:
#   Stage 1: Spec Compliance - Did we implement what was asked?
#   Stage 2: Quality Check - Is the code good? (tests, lint, build)
#
# Both stages must pass for a feature to be marked as complete.
# This prevents wasted iteration on wrong implementations.
#
# Usage:
#   ./validate-feature.sh [OPTIONS]
#
# Options:
#   --feature-id FX        Feature ID to validate (default: current)
#   --state-dir DIR        State directory (default: .claude/ralph-v3)
#   --skip-spec            Skip spec compliance check
#   --skip-quality         Skip quality check
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
Nelson Muntz - Two-Stage Feature Validation

USAGE:
  validate-feature.sh [OPTIONS]

OPTIONS:
  --feature-id FX    Feature ID to validate (default: current in_progress feature)
  --state-dir DIR    State directory (default: .claude/ralph-v3)
  --skip-spec        Skip spec compliance check
  --skip-quality     Skip quality check
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

OUTPUTS:
  - Updates validation/spec-check.json with results
  - Updates validation/quality-check.json with results
  - Returns exit code 0 if both stages pass, 1 otherwise

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
# Main
# -----------------------------------------------------------------------------

main() {
  parse_args "$@"

  echo ""
  echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║         Nelson Muntz - Two-Stage Validation                ║${NC}"
  echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
  echo ""

  local spec_result=0
  local quality_result=0

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

  # Final result
  echo ""
  echo "═══════════════════════════════════════════════════════════"

  if [[ $spec_result -eq 0 ]] && [[ $quality_result -eq 0 ]]; then
    success "VALIDATION PASSED - Feature ready for commit"
    echo ""
    echo "HA-HA! Feature validated successfully."
    exit 0
  else
    fail "VALIDATION FAILED"
    if [[ $spec_result -ne 0 ]]; then
      echo "  - Spec compliance: FAILED"
    fi
    if [[ $quality_result -ne 0 ]]; then
      echo "  - Quality check: FAILED"
    fi
    echo ""
    echo "Fix the issues and try again."
    exit 1
  fi
}

main "$@"
