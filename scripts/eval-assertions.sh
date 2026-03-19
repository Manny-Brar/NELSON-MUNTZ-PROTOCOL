#!/bin/bash

# =============================================================================
# Nelson Muntz v5.0 — Eval Assertion Framework
# =============================================================================
#
# Runs binary assertions against Nelson loop execution traces to verify:
#   1. Protocol compliance (did the agent follow v5 protocol?)
#   2. Quality gates (were all validation stages completed?)
#   3. Compound learning (were patterns/anti-patterns extracted?)
#   4. Drift awareness (was drift monitored and scored?)
#   5. Handoff quality (are handoffs specific and actionable?)
#
# Each assertion returns PASS (true) or FAIL (false).
# Results are aggregated into a structured report.
#
# Usage:
#   ./eval-assertions.sh                     # Run all assertions
#   ./eval-assertions.sh --category protocol # Run one category only
#   ./eval-assertions.sh --json              # Output as JSON
#   ./eval-assertions.sh --verbose           # Show assertion details
#   ./eval-assertions.sh --ci                # Exit code 1 on any FAIL
#
# Categories: protocol, quality, compound, drift, handoff, all
#
# =============================================================================

set -euo pipefail

# Configuration
STATE_DIR=".claude"
VERIFICATION_FILE="$STATE_DIR/nelson-verification.local.md"
HANDOFF_FILE="$STATE_DIR/nelson-handoff.local.md"
SCRATCHPAD_FILE="$STATE_DIR/nelson-scratchpad.local.md"
EDIT_TRACKER="$STATE_DIR/nelson-edit-tracker.local.json"
LOOP_STATE="$STATE_DIR/nelson-loop.local.md"
FEATURES_FILE="$STATE_DIR/ralph-v3/features.json"

# Counters
TOTAL=0
PASSED=0
FAILED=0
SKIPPED=0

# Options
CATEGORY="all"
JSON_OUTPUT=false
VERBOSE=false
CI_MODE=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --category) CATEGORY="$2"; shift 2 ;;
    --json) JSON_OUTPUT=true; shift ;;
    --verbose) VERBOSE=true; shift ;;
    --ci) CI_MODE=true; shift ;;
    -h|--help)
      echo "Nelson v5.0 Eval Assertion Framework"
      echo ""
      echo "Usage: eval-assertions.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --category TYPE  Run specific category (protocol|quality|compound|drift|handoff|all)"
      echo "  --json           Output results as JSON"
      echo "  --verbose        Show assertion details"
      echo "  --ci             Exit code 1 on any failure"
      echo "  -h, --help       Show this help"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# =============================================================================
# Assertion Functions
# =============================================================================

# Run a single assertion
# Usage: assert "category" "name" "description" PASS|FAIL|SKIP ["detail"]
RESULTS=()

assert() {
  local category="$1"
  local name="$2"
  local description="$3"
  local result="$4"
  local detail="${5:-}"

  TOTAL=$((TOTAL + 1))

  case $result in
    PASS) PASSED=$((PASSED + 1)) ;;
    FAIL) FAILED=$((FAILED + 1)) ;;
    SKIP) SKIPPED=$((SKIPPED + 1)) ;;
  esac

  RESULTS+=("$category|$name|$result|$description|$detail")

  if [[ "$JSON_OUTPUT" == "false" && "$VERBOSE" == "true" ]]; then
    local color="$NC"
    case $result in
      PASS) color="$GREEN" ;;
      FAIL) color="$RED" ;;
      SKIP) color="$YELLOW" ;;
    esac
    echo -e "  ${color}[$result]${NC} $name: $description"
    if [[ -n "$detail" ]]; then
      echo "         $detail"
    fi
  fi
}

# =============================================================================
# 1. PROTOCOL COMPLIANCE ASSERTIONS
# =============================================================================

run_protocol_assertions() {
  if [[ "$JSON_OUTPUT" == "false" ]]; then
    echo -e "\n${CYAN}=== Protocol Compliance ===${NC}"
  fi

  # P1: Loop state file exists
  if [[ -f "$LOOP_STATE" ]]; then
    assert "protocol" "loop_state_exists" "Loop state file present" "PASS"
  else
    assert "protocol" "loop_state_exists" "Loop state file present" "SKIP" "No active loop"
  fi

  # P2: Protocol version is v5
  if [[ -f "$LOOP_STATE" ]]; then
    if grep -q "protocol_version.*5" "$LOOP_STATE" 2>/dev/null; then
      assert "protocol" "v5_protocol" "Using v5.0 protocol" "PASS"
    else
      assert "protocol" "v5_protocol" "Using v5.0 protocol" "FAIL" "protocol_version field missing or not v5"
    fi
  else
    assert "protocol" "v5_protocol" "Using v5.0 protocol" "SKIP" "No loop state"
  fi

  # P3: Handoff file exists
  if [[ -f "$HANDOFF_FILE" ]]; then
    assert "protocol" "handoff_exists" "Handoff file present" "PASS"
  else
    assert "protocol" "handoff_exists" "Handoff file present" "FAIL" "Missing: $HANDOFF_FILE"
  fi

  # P4: Scratchpad exists (planning was done)
  if [[ -f "$SCRATCHPAD_FILE" ]]; then
    local scratchpad_lines
    scratchpad_lines=$(wc -l < "$SCRATCHPAD_FILE" | tr -d ' ')
    if [[ "$scratchpad_lines" -gt 5 ]]; then
      assert "protocol" "planning_done" "Scratchpad has planning content" "PASS" "$scratchpad_lines lines"
    else
      assert "protocol" "planning_done" "Scratchpad has planning content" "FAIL" "Only $scratchpad_lines lines — insufficient planning"
    fi
  else
    assert "protocol" "planning_done" "Scratchpad has planning content" "FAIL" "No scratchpad file"
  fi

  # P5: Single-feature focus (check git diff for reasonable scope)
  if command -v git &> /dev/null && [[ -d ".git" ]]; then
    local changed_files
    changed_files=$(git diff --name-only HEAD~1 2>/dev/null | wc -l | tr -d ' ' || echo "0")
    if [[ "$changed_files" -le 15 ]]; then
      assert "protocol" "single_feature_focus" "Reasonable file change scope" "PASS" "$changed_files files changed"
    else
      assert "protocol" "single_feature_focus" "Reasonable file change scope" "FAIL" "$changed_files files changed — possible scope creep"
    fi
  else
    assert "protocol" "single_feature_focus" "Reasonable file change scope" "SKIP" "No git repo"
  fi
}

# =============================================================================
# 2. QUALITY GATE ASSERTIONS
# =============================================================================

run_quality_assertions() {
  if [[ "$JSON_OUTPUT" == "false" ]]; then
    echo -e "\n${CYAN}=== Quality Gates ===${NC}"
  fi

  # Q1: Verification file exists
  if [[ -f "$VERIFICATION_FILE" ]]; then
    assert "quality" "verification_exists" "Verification file present" "PASS"
  else
    assert "quality" "verification_exists" "Verification file present" "FAIL" "Missing: $VERIFICATION_FILE"
    return  # Can't check further without the file
  fi

  # Q2: Stage 1 — Tests section with actual output
  if grep -q "## Tests" "$VERIFICATION_FILE"; then
    if grep -iE '(pass|fail|[0-9]+ (test|spec|assertion))' "$VERIFICATION_FILE" | grep -qi "test"; then
      assert "quality" "stage1_tests" "Stage 1: Tests section has real output" "PASS"
    else
      assert "quality" "stage1_tests" "Stage 1: Tests section has real output" "FAIL" "Tests section lacks pass/fail counts"
    fi
  else
    assert "quality" "stage1_tests" "Stage 1: Tests section has real output" "FAIL" "Missing '## Tests' section"
  fi

  # Q3: Stage 2 — Build section
  if grep -q "## Build" "$VERIFICATION_FILE"; then
    if grep -iE '(success|pass|complete|built)' "$VERIFICATION_FILE" | head -1 | grep -qi "."; then
      assert "quality" "stage2_build" "Stage 2: Build confirmed" "PASS"
    else
      assert "quality" "stage2_build" "Stage 2: Build confirmed" "FAIL" "Build section lacks success confirmation"
    fi
  else
    assert "quality" "stage2_build" "Stage 2: Build confirmed" "FAIL" "Missing '## Build' section"
  fi

  # Q4: Stage 2 — Edge cases (3+ items)
  if grep -q "## Edge Cases" "$VERIFICATION_FILE"; then
    local edge_count
    edge_count=$(sed -n '/## Edge Cases/,/## /p' "$VERIFICATION_FILE" | grep -cE '^[0-9]+\.|^- |^\* ' || echo "0")
    if [[ "$edge_count" -ge 3 ]]; then
      assert "quality" "edge_cases" "Edge cases documented (3+ items)" "PASS" "$edge_count items"
    else
      assert "quality" "edge_cases" "Edge cases documented (3+ items)" "FAIL" "Only $edge_count items (need 3+)"
    fi
  else
    assert "quality" "edge_cases" "Edge cases documented (3+ items)" "FAIL" "Missing '## Edge Cases' section"
  fi

  # Q5: Stage 2 — Self-review
  if grep -q "## Self-Review" "$VERIFICATION_FILE"; then
    if grep -iE '(weak|criticism|debt|todo)' "$VERIFICATION_FILE" | head -1 | grep -qi "."; then
      assert "quality" "self_review" "Self-review includes critical analysis" "PASS"
    else
      assert "quality" "self_review" "Self-review includes critical analysis" "FAIL" "Missing weakness/criticism/debt/todo analysis"
    fi
  else
    assert "quality" "self_review" "Self-review includes critical analysis" "FAIL" "Missing '## Self-Review' section"
  fi

  # Q6: Stage 3 — Red-team review (v5)
  if grep -q "## Red-Team" "$VERIFICATION_FILE"; then
    local rt_count
    rt_count=$(sed -n '/## Red-Team/,/## /p' "$VERIFICATION_FILE" | grep -cE '^[0-9]+\.|^- |^\* ' || echo "0")
    if [[ "$rt_count" -ge 2 ]]; then
      assert "quality" "stage3_redteam" "Stage 3: Red-team review (2+ findings)" "PASS" "$rt_count findings"
    else
      assert "quality" "stage3_redteam" "Stage 3: Red-team review (2+ findings)" "FAIL" "Only $rt_count findings (need 2+)"
    fi
  else
    assert "quality" "stage3_redteam" "Stage 3: Red-team review (2+ findings)" "SKIP" "No red-team section (v5 optional)"
  fi

  # Q7: Git status clean
  if grep -q "## Git Status" "$VERIFICATION_FILE"; then
    assert "quality" "git_status_documented" "Git status documented" "PASS"
  else
    assert "quality" "git_status_documented" "Git status documented" "FAIL" "Missing '## Git Status' section"
  fi
}

# =============================================================================
# 3. COMPOUND LEARNING ASSERTIONS
# =============================================================================

run_compound_assertions() {
  if [[ "$JSON_OUTPUT" == "false" ]]; then
    echo -e "\n${CYAN}=== Compound Learning ===${NC}"
  fi

  # C1: Compound learning section in verification
  if [[ -f "$VERIFICATION_FILE" ]]; then
    if grep -q "## Compound Learning" "$VERIFICATION_FILE"; then
      assert "compound" "compound_in_verification" "Compound learning in verification" "PASS"
    else
      assert "compound" "compound_in_verification" "Compound learning in verification" "SKIP" "Not in verification (v5 recommended)"
    fi
  else
    assert "compound" "compound_in_verification" "Compound learning in verification" "SKIP" "No verification file"
  fi

  # C2: Compound learning section in handoff
  if [[ -f "$HANDOFF_FILE" ]]; then
    if grep -qi "compound\|pattern.*extract\|anti.pattern\|insight.*next" "$HANDOFF_FILE"; then
      assert "compound" "compound_in_handoff" "Compound learning transfer in handoff" "PASS"
    else
      assert "compound" "compound_in_handoff" "Compound learning transfer in handoff" "FAIL" "Handoff lacks compound learning section"
    fi
  else
    assert "compound" "compound_in_handoff" "Compound learning transfer in handoff" "SKIP" "No handoff file"
  fi

  # C3: Patterns directory has content
  if [[ -d ".nelson/patterns" ]]; then
    local pattern_lines=0
    for f in .nelson/patterns/*.md; do
      if [[ -f "$f" ]]; then
        pattern_lines=$((pattern_lines + $(wc -l < "$f" | tr -d ' ')))
      fi
    done
    if [[ "$pattern_lines" -gt 10 ]]; then
      assert "compound" "patterns_documented" "Pattern library has content" "PASS" "$pattern_lines lines"
    else
      assert "compound" "patterns_documented" "Pattern library has content" "FAIL" "Only $pattern_lines lines — thin pattern library"
    fi
  else
    assert "compound" "patterns_documented" "Pattern library has content" "SKIP" "No .nelson/patterns/ directory"
  fi

  # C4: Scratchpad has reasoning trail
  if [[ -f "$SCRATCHPAD_FILE" ]]; then
    if grep -qiE '(approach|decision|because|rationale|chose|alternative)' "$SCRATCHPAD_FILE"; then
      assert "compound" "reasoning_trail" "Scratchpad has decision reasoning" "PASS"
    else
      assert "compound" "reasoning_trail" "Scratchpad has decision reasoning" "FAIL" "Scratchpad lacks reasoning/decision content"
    fi
  else
    assert "compound" "reasoning_trail" "Scratchpad has decision reasoning" "SKIP" "No scratchpad"
  fi
}

# =============================================================================
# 4. DRIFT AWARENESS ASSERTIONS
# =============================================================================

run_drift_assertions() {
  if [[ "$JSON_OUTPUT" == "false" ]]; then
    echo -e "\n${CYAN}=== Drift Awareness ===${NC}"
  fi

  # D1: Edit tracker exists
  if [[ -f "$EDIT_TRACKER" ]]; then
    assert "drift" "edit_tracker_exists" "Edit tracker initialized" "PASS"
  else
    assert "drift" "edit_tracker_exists" "Edit tracker initialized" "SKIP" "No edit tracker (v5 feature)"
  fi

  # D2: Edit count within reasonable bounds
  if [[ -f "$EDIT_TRACKER" ]] && command -v jq &> /dev/null; then
    local edit_count
    edit_count=$(jq '.edit_count // 0' "$EDIT_TRACKER" 2>/dev/null || echo "0")
    if [[ "$edit_count" -le 30 ]]; then
      assert "drift" "edit_velocity" "Edit velocity within bounds (<= 30)" "PASS" "$edit_count edits"
    else
      assert "drift" "edit_velocity" "Edit velocity within bounds (<= 30)" "FAIL" "$edit_count edits — high edit velocity"
    fi
  else
    assert "drift" "edit_velocity" "Edit velocity within bounds (<= 30)" "SKIP" "No tracker or jq"
  fi

  # D3: File spread within bounds
  if [[ -f "$EDIT_TRACKER" ]] && command -v jq &> /dev/null; then
    local file_count
    file_count=$(jq '.files_touched | length' "$EDIT_TRACKER" 2>/dev/null || echo "0")
    if [[ "$file_count" -le 8 ]]; then
      assert "drift" "file_spread" "File spread within bounds (<= 8 unique)" "PASS" "$file_count files"
    else
      assert "drift" "file_spread" "File spread within bounds (<= 8 unique)" "FAIL" "$file_count files — possible scope creep"
    fi
  else
    assert "drift" "file_spread" "File spread within bounds (<= 8 unique)" "SKIP" "No tracker or jq"
  fi

  # D4: Drift score below circuit breaker threshold
  if [[ -f "$EDIT_TRACKER" ]] && command -v jq &> /dev/null; then
    local drift=0
    local ec fc
    ec=$(jq '.edit_count // 0' "$EDIT_TRACKER" 2>/dev/null || echo "0")
    fc=$(jq '.files_touched | length' "$EDIT_TRACKER" 2>/dev/null || echo "0")
    [[ "$ec" -gt 30 ]] && drift=$((drift + 2))
    [[ "$ec" -gt 20 ]] && [[ "$ec" -le 30 ]] && drift=$((drift + 1))
    [[ "$fc" -gt 8 ]] && drift=$((drift + 2))
    [[ "$fc" -gt 5 ]] && [[ "$fc" -le 8 ]] && drift=$((drift + 1))

    if [[ "$drift" -lt 7 ]]; then
      assert "drift" "below_circuit_breaker" "Drift score below circuit breaker (< 7)" "PASS" "Score: $drift/10"
    else
      assert "drift" "below_circuit_breaker" "Drift score below circuit breaker (< 7)" "FAIL" "Score: $drift/10 — CIRCUIT BREAKER TERRITORY"
    fi
  else
    assert "drift" "below_circuit_breaker" "Drift score below circuit breaker (< 7)" "SKIP" "No tracker or jq"
  fi
}

# =============================================================================
# 5. HANDOFF QUALITY ASSERTIONS
# =============================================================================

run_handoff_assertions() {
  if [[ "$JSON_OUTPUT" == "false" ]]; then
    echo -e "\n${CYAN}=== Handoff Quality ===${NC}"
  fi

  if [[ ! -f "$HANDOFF_FILE" ]]; then
    assert "handoff" "handoff_present" "Handoff file exists" "FAIL"
    return
  fi

  assert "handoff" "handoff_present" "Handoff file exists" "PASS"

  local handoff_lines
  handoff_lines=$(wc -l < "$HANDOFF_FILE" | tr -d ' ')

  # H1: Handoff has minimum substance
  if [[ "$handoff_lines" -ge 10 ]]; then
    assert "handoff" "minimum_substance" "Handoff has minimum substance (10+ lines)" "PASS" "$handoff_lines lines"
  else
    assert "handoff" "minimum_substance" "Handoff has minimum substance (10+ lines)" "FAIL" "Only $handoff_lines lines"
  fi

  # H2: Contains file paths (specificity check)
  if grep -qE '(src/|lib/|app/|pages/|components/|\.ts|\.js|\.py|\.md|\.json)' "$HANDOFF_FILE"; then
    assert "handoff" "has_file_paths" "Handoff references specific file paths" "PASS"
  else
    assert "handoff" "has_file_paths" "Handoff references specific file paths" "FAIL" "No file paths found — too vague"
  fi

  # H3: Contains next action (actionability check)
  if grep -qiE '(next|should|must|start|continue|implement|fix|add|create)' "$HANDOFF_FILE"; then
    assert "handoff" "has_next_action" "Handoff specifies next action" "PASS"
  else
    assert "handoff" "has_next_action" "Handoff specifies next action" "FAIL" "No actionable next steps found"
  fi

  # H4: Contains status section
  if grep -qiE '(status|progress|complet|block|pending)' "$HANDOFF_FILE"; then
    assert "handoff" "has_status" "Handoff includes status information" "PASS"
  else
    assert "handoff" "has_status" "Handoff includes status information" "FAIL" "No status information found"
  fi

  # H5: Not excessively long (parseable in <30 seconds)
  if [[ "$handoff_lines" -le 80 ]]; then
    assert "handoff" "concise" "Handoff concise enough to parse (<80 lines)" "PASS" "$handoff_lines lines"
  else
    assert "handoff" "concise" "Handoff concise enough to parse (<80 lines)" "FAIL" "$handoff_lines lines — too long, should be scannable"
  fi
}

# =============================================================================
# Run Assertions
# =============================================================================

if [[ "$JSON_OUTPUT" == "false" ]]; then
  echo "╔══════════════════════════════════════════════════════════╗"
  echo "║        Nelson v5.0 — Eval Assertion Framework           ║"
  echo "╚══════════════════════════════════════════════════════════╝"
fi

case $CATEGORY in
  protocol)  run_protocol_assertions ;;
  quality)   run_quality_assertions ;;
  compound)  run_compound_assertions ;;
  drift)     run_drift_assertions ;;
  handoff)   run_handoff_assertions ;;
  all)
    run_protocol_assertions
    run_quality_assertions
    run_compound_assertions
    run_drift_assertions
    run_handoff_assertions
    ;;
  *) echo "Unknown category: $CATEGORY"; exit 1 ;;
esac

# =============================================================================
# Output Results
# =============================================================================

if [[ "$JSON_OUTPUT" == "true" ]]; then
  # Build JSON output
  echo "{"
  echo "  \"version\": \"5.0.0\","
  echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
  echo "  \"category\": \"$CATEGORY\","
  echo "  \"summary\": {"
  echo "    \"total\": $TOTAL,"
  echo "    \"passed\": $PASSED,"
  echo "    \"failed\": $FAILED,"
  echo "    \"skipped\": $SKIPPED,"
  echo "    \"pass_rate\": \"$(if [[ $((TOTAL - SKIPPED)) -gt 0 ]]; then echo "$((PASSED * 100 / (TOTAL - SKIPPED)))%"; else echo "N/A"; fi)\""
  echo "  },"
  echo "  \"assertions\": ["

  FIRST=true
  for r in "${RESULTS[@]}"; do
    IFS='|' read -r cat name result desc detail <<< "$r"
    if [[ "$FIRST" == "true" ]]; then FIRST=false; else echo ","; fi
    printf '    {"category":"%s","name":"%s","result":"%s","description":"%s","detail":"%s"}' \
      "$cat" "$name" "$result" "$desc" "$detail"
  done

  echo ""
  echo "  ]"
  echo "}"
else
  # Summary output
  echo ""
  echo "═══════════════════════════════════════════════════════════"
  echo " RESULTS"
  echo "═══════════════════════════════════════════════════════════"
  echo ""

  ACTIVE=$((TOTAL - SKIPPED))
  pass_rate="N/A"
  if [[ "$ACTIVE" -gt 0 ]]; then
    pass_rate="$((PASSED * 100 / ACTIVE))%"
  fi

  echo -e " Total:   $TOTAL"
  echo -e " ${GREEN}Passed:  $PASSED${NC}"
  echo -e " ${RED}Failed:  $FAILED${NC}"
  echo -e " ${YELLOW}Skipped: $SKIPPED${NC}"
  echo -e " Pass Rate: $pass_rate (of active assertions)"
  echo ""

  if [[ "$FAILED" -eq 0 && "$PASSED" -gt 0 ]]; then
    echo -e " ${GREEN}HA-HA! All assertions passed.${NC}"
  elif [[ "$FAILED" -gt 0 ]]; then
    echo -e " ${RED}$FAILED assertion(s) failed. Fix these before claiming completion.${NC}"
  fi

  echo ""
fi

# CI mode: exit 1 on failures
if [[ "$CI_MODE" == "true" && "$FAILED" -gt 0 ]]; then
  exit 1
fi

exit 0
