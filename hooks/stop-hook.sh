#!/bin/bash

# Nelson Muntz Stop Hook (v3.3.1) - AGGRESSIVE VALIDATION + STRICT CONTENT CHECKING
# In-session looping with mandatory verification, self-review, and quality gates
#
# Key Features:
#   - Fresh context each iteration (via stop hook blocking)
#   - Mandatory planning phase
#   - AGGRESSIVE two-stage validation (not just instructions - ENFORCED)
#   - Self-review requirement before completion
#   - Handoff verification before exit
#   - HA-HA mode for peak performance

set -euo pipefail

# Read hook input from stdin (advanced stop hook API)
HOOK_INPUT=$(cat)

# Check for Nelson loop state file
NELSON_STATE_FILE=".claude/nelson-loop.local.md"
NELSON_HANDOFF_FILE=".claude/nelson-handoff.local.md"
NELSON_VERIFICATION_FILE=".claude/nelson-verification.local.md"

if [[ ! -f "$NELSON_STATE_FILE" ]]; then
  # No active loop - allow exit
  exit 0
fi

# Parse markdown frontmatter (YAML between ---) and extract values
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$NELSON_STATE_FILE")

# Extract fields
ACTIVE=$(echo "$FRONTMATTER" | grep '^active:' | sed 's/active: *//')
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//')
MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//')
HA_HA_MODE=$(echo "$FRONTMATTER" | grep '^ha_ha_mode:' | sed 's/ha_ha_mode: *//')
COMPLETION_PROMISE=$(echo "$FRONTMATTER" | grep '^completion_promise:' | sed 's/completion_promise: *//' | sed 's/^"\(.*\)"$/\1/')
VERIFICATION_PENDING=$(echo "$FRONTMATTER" | grep '^verification_pending:' | sed 's/verification_pending: *//' || echo "false")

# Check if loop is active
if [[ "$ACTIVE" != "true" ]]; then
  rm "$NELSON_STATE_FILE" 2>/dev/null || true
  rm "$NELSON_HANDOFF_FILE" 2>/dev/null || true
  rm "$NELSON_VERIFICATION_FILE" 2>/dev/null || true
  exit 0
fi

# Validate numeric fields
if [[ ! "$ITERATION" =~ ^[0-9]+$ ]]; then
  echo "Nelson loop: State file corrupted (invalid iteration: $ITERATION)" >&2
  rm "$NELSON_STATE_FILE"
  exit 0
fi

if [[ ! "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
  echo "Nelson loop: State file corrupted (invalid max_iterations: $MAX_ITERATIONS)" >&2
  rm "$NELSON_STATE_FILE"
  exit 0
fi

# Check if max iterations reached
if [[ $MAX_ITERATIONS -gt 0 ]] && [[ $ITERATION -ge $MAX_ITERATIONS ]]; then
  echo ""
  echo "HA-HA! Nelson loop: Max iterations ($MAX_ITERATIONS) reached."
  echo ""
  rm "$NELSON_STATE_FILE"
  rm "$NELSON_HANDOFF_FILE" 2>/dev/null || true
  rm "$NELSON_VERIFICATION_FILE" 2>/dev/null || true
  exit 0
fi

# Get transcript path from hook input
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path')

if [[ ! -f "$TRANSCRIPT_PATH" ]]; then
  echo "Nelson loop: Transcript not found at $TRANSCRIPT_PATH" >&2
  rm "$NELSON_STATE_FILE"
  exit 0
fi

# Read last assistant message from transcript
if ! grep -q '"role":"assistant"' "$TRANSCRIPT_PATH"; then
  echo "Nelson loop: No assistant messages found" >&2
  rm "$NELSON_STATE_FILE"
  exit 0
fi

LAST_LINE=$(grep '"role":"assistant"' "$TRANSCRIPT_PATH" | tail -1)
if [[ -z "$LAST_LINE" ]]; then
  echo "Nelson loop: Failed to extract assistant message" >&2
  rm "$NELSON_STATE_FILE"
  exit 0
fi

LAST_OUTPUT=$(echo "$LAST_LINE" | jq -r '
  .message.content |
  map(select(.type == "text")) |
  map(.text) |
  join("\n")
' 2>&1)

if [[ -z "$LAST_OUTPUT" ]]; then
  echo "Nelson loop: Assistant message empty" >&2
  rm "$NELSON_STATE_FILE"
  exit 0
fi

# ============================================================
# AGGRESSIVE VALIDATION SYSTEM (v3.3.0)
# ============================================================

# Check for VERIFIED completion (after verification challenge passed)
if echo "$LAST_OUTPUT" | grep -q "<nelson-verified>VERIFICATION_COMPLETE</nelson-verified>"; then
  # Check that verification file exists and has required sections WITH CONTENT
  if [[ -f "$NELSON_VERIFICATION_FILE" ]]; then
    VERIFICATION_FAILURES=""

    # === STRICT VALIDATION: Tests section must have actual results ===
    if ! grep -q "## Tests" "$NELSON_VERIFICATION_FILE"; then
      VERIFICATION_FAILURES="${VERIFICATION_FAILURES}\n- Missing '## Tests' section"
    else
      # Check for actual test output indicators (numbers, pass/fail keywords)
      TESTS_SECTION=$(sed -n '/## Tests/,/## /p' "$NELSON_VERIFICATION_FILE" | head -20)
      if ! echo "$TESTS_SECTION" | grep -qiE '(pass|fail|[0-9]+ (test|spec|assertion))'; then
        VERIFICATION_FAILURES="${VERIFICATION_FAILURES}\n- Tests section lacks actual test output (need pass/fail counts)"
      fi
    fi

    # === STRICT VALIDATION: Edge Cases must have at least 3 items ===
    if ! grep -q "## Edge Cases" "$NELSON_VERIFICATION_FILE"; then
      VERIFICATION_FAILURES="${VERIFICATION_FAILURES}\n- Missing '## Edge Cases' section"
    else
      # Count numbered or bulleted items in Edge Cases section
      EDGE_CASES_SECTION=$(sed -n '/## Edge Cases/,/## /p' "$NELSON_VERIFICATION_FILE")
      EDGE_CASE_COUNT=$(echo "$EDGE_CASES_SECTION" | grep -cE '^[0-9]+\.|^- |^\* ' || echo "0")
      if [[ "$EDGE_CASE_COUNT" -lt 3 ]]; then
        VERIFICATION_FAILURES="${VERIFICATION_FAILURES}\n- Edge Cases needs 3+ items (found: $EDGE_CASE_COUNT)"
      fi
    fi

    # === STRICT VALIDATION: Self-Review must have actual content ===
    if ! grep -q "## Self-Review" "$NELSON_VERIFICATION_FILE"; then
      VERIFICATION_FAILURES="${VERIFICATION_FAILURES}\n- Missing '## Self-Review' section"
    else
      SELF_REVIEW_SECTION=$(sed -n '/## Self-Review/,/## /p' "$NELSON_VERIFICATION_FILE")
      # Check for required self-review fields
      if ! echo "$SELF_REVIEW_SECTION" | grep -qiE '(weak|criticism|debt|todo)'; then
        VERIFICATION_FAILURES="${VERIFICATION_FAILURES}\n- Self-Review lacks required analysis (weakness, criticism, debt, todos)"
      fi
    fi

    # === STRICT VALIDATION: Build section must exist ===
    if ! grep -q "## Build" "$NELSON_VERIFICATION_FILE"; then
      VERIFICATION_FAILURES="${VERIFICATION_FAILURES}\n- Missing '## Build' section"
    else
      BUILD_SECTION=$(sed -n '/## Build/,/## /p' "$NELSON_VERIFICATION_FILE")
      if ! echo "$BUILD_SECTION" | grep -qiE '(success|pass|complete|built)'; then
        VERIFICATION_FAILURES="${VERIFICATION_FAILURES}\n- Build section lacks success confirmation"
      fi
    fi

    # === STRICT VALIDATION: Git Status section ===
    if ! grep -q "## Git Status" "$NELSON_VERIFICATION_FILE"; then
      VERIFICATION_FAILURES="${VERIFICATION_FAILURES}\n- Missing '## Git Status' section"
    fi

    # If all validations passed, allow exit
    if [[ -z "$VERIFICATION_FAILURES" ]]; then
      echo ""
      echo "HA-HA! Nelson loop: VERIFIED completion after $ITERATION iterations!"
      echo "All quality gates passed. Work verified."
      echo ""
      rm "$NELSON_STATE_FILE"
      rm "$NELSON_HANDOFF_FILE" 2>/dev/null || true
      rm "$NELSON_VERIFICATION_FILE" 2>/dev/null || true
      exit 0
    else
      # REJECT - verification file doesn't meet standards
      NEXT_ITERATION=$((ITERATION + 1))

      TEMP_FILE="${NELSON_STATE_FILE}.tmp.$$"
      sed "s/^iteration: .*/iteration: $NEXT_ITERATION/" "$NELSON_STATE_FILE" > "$TEMP_FILE"
      mv "$TEMP_FILE" "$NELSON_STATE_FILE"

      REJECT_PROMPT="
## 🔴 VERIFICATION REJECTED - ITERATION $NEXT_ITERATION

Your verification file doesn't meet quality standards. HA-HA!

**FAILURES DETECTED:**
$(echo -e "$VERIFICATION_FAILURES")

**REQUIREMENTS:**
1. **## Tests** - Must contain actual test output with pass/fail counts
   Example: 'Tests: 15 passed, 0 failed' or actual test runner output

2. **## Edge Cases** - Must list at least 3 numbered/bulleted edge cases
   Example:
   1. Empty input: handled with validation
   2. Network timeout: retry with exponential backoff
   3. Concurrent requests: mutex lock on shared state

3. **## Self-Review** - Must analyze: weakness, potential criticism, tech debt, TODOs
   Example:
   - Weakest part: Error messages could be more descriptive
   - Criticism: Should add retry logic for database connections
   - Tech debt: None introduced
   - TODOs: 0 remaining

4. **## Build** - Must confirm build succeeded
   Example: 'npm run build: SUCCESS (no errors)'

5. **## Git Status** - Must show commit status
   Example: 'Uncommitted: 0, Last commit: abc123 feat: add auth'

**FIX YOUR VERIFICATION FILE** at .claude/nelson-verification.local.md

Then output: <nelson-verified>VERIFICATION_COMPLETE</nelson-verified>

Nelson is not impressed. Try again!
"

      jq -n \
        --arg prompt "$REJECT_PROMPT" \
        --arg msg "🔴 VERIFICATION REJECTED | Fix failures and resubmit" \
        '{
          "decision": "block",
          "reason": $prompt,
          "systemMessage": $msg
        }'

      exit 0
    fi
  else
    # No verification file - reject with instructions
    NEXT_ITERATION=$((ITERATION + 1))

    TEMP_FILE="${NELSON_STATE_FILE}.tmp.$$"
    sed "s/^iteration: .*/iteration: $NEXT_ITERATION/" "$NELSON_STATE_FILE" > "$TEMP_FILE"
    mv "$TEMP_FILE" "$NELSON_STATE_FILE"

    NO_FILE_PROMPT="
## 🔴 VERIFICATION REJECTED - NO FILE FOUND

You claimed verification complete but there's no verification file!

**CREATE:** .claude/nelson-verification.local.md

**REQUIRED SECTIONS:**
- ## Tests (with actual pass/fail output)
- ## Build (with success confirmation)
- ## Edge Cases (3+ items)
- ## Self-Review (weakness, criticism, debt, todos)
- ## Git Status (commit info)

Then output: <nelson-verified>VERIFICATION_COMPLETE</nelson-verified>

Don't try to cheat Nelson. HA-HA!
"

    jq -n \
      --arg prompt "$NO_FILE_PROMPT" \
      --arg msg "🔴 NO VERIFICATION FILE | Create .claude/nelson-verification.local.md first" \
      '{
        "decision": "block",
        "reason": $prompt,
        "systemMessage": $msg
      }'

    exit 0
  fi
fi

# Check for completion claim (first attempt - triggers verification challenge)
COMPLETION_CLAIMED=false

if [[ "$COMPLETION_PROMISE" != "null" ]] && [[ -n "$COMPLETION_PROMISE" ]]; then
  PROMISE_TEXT=$(echo "$LAST_OUTPUT" | perl -0777 -pe 's/.*?<promise>(.*?)<\/promise>.*/$1/s; s/^\s+|\s+$//g; s/\s+/ /g' 2>/dev/null || echo "")
  if [[ -n "$PROMISE_TEXT" ]] && [[ "$PROMISE_TEXT" = "$COMPLETION_PROMISE" ]]; then
    COMPLETION_CLAIMED=true
  fi
fi

if echo "$LAST_OUTPUT" | grep -q "<nelson-complete>ALL_FEATURES_COMPLETE</nelson-complete>"; then
  COMPLETION_CLAIMED=true
fi

# If completion claimed, check if this is a verified completion or needs verification
if [[ "$COMPLETION_CLAIMED" == "true" ]]; then
  # Check git status for uncommitted changes
  GIT_STATUS=""
  if command -v git &> /dev/null && [[ -d ".git" ]]; then
    UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$UNCOMMITTED" -gt 0 ]]; then
      GIT_STATUS="
⚠️ WARNING: $UNCOMMITTED uncommitted changes detected!
   You MUST commit all work before completion can be verified.
"
    fi
  fi

  # Trigger verification challenge (don't exit - force self-review)
  NEXT_ITERATION=$((ITERATION + 1))

  # Update state to mark verification pending
  TEMP_FILE="${NELSON_STATE_FILE}.tmp.$$"
  sed "s/^iteration: .*/iteration: $NEXT_ITERATION/" "$NELSON_STATE_FILE" | \
    sed "s/^verification_pending: .*/verification_pending: true/" > "$TEMP_FILE"

  # Add verification_pending if not present
  if ! grep -q "^verification_pending:" "$TEMP_FILE"; then
    sed -i.bak "s/^ha_ha_mode:.*/&\nverification_pending: true/" "$TEMP_FILE"
    rm "${TEMP_FILE}.bak" 2>/dev/null || true
  fi

  mv "$TEMP_FILE" "$NELSON_STATE_FILE"

  VERIFICATION_PROMPT="
## 🔴 VERIFICATION CHALLENGE - ITERATION $NEXT_ITERATION

You claimed completion, but Nelson doesn't trust easily. HA-HA!
$GIT_STATUS
### MANDATORY VERIFICATION STEPS

You MUST complete ALL of these before I'll let you out:

**1. RUN TESTS (Required)**
\`\`\`bash
# Run the test suite - paste actual output
npm test  # or appropriate test command
\`\`\`

**2. BUILD CHECK (Required)**
\`\`\`bash
# Verify build succeeds - paste actual output
npm run build  # or appropriate build command
\`\`\`

**3. EDGE CASE AUDIT (Required)**
List 3+ edge cases you considered:
- Edge case 1: [what could go wrong?] → [how did you handle it?]
- Edge case 2: ...
- Edge case 3: ...

**4. SELF-REVIEW CRITIQUE (Required)**
Re-read your code changes and answer honestly:
- What's the weakest part of this implementation?
- What would a senior engineer criticize?
- Is there any technical debt introduced?
- Are there any TODO comments left behind?

**5. WRITE VERIFICATION FILE**
Create .claude/nelson-verification.local.md with:
\`\`\`markdown
# Verification Report - Iteration $ITERATION

## Tests
- Command run: [actual command]
- Result: [PASS/FAIL with count]
- Failures: [list any, or 'None']

## Build
- Command run: [actual command]
- Result: [SUCCESS/FAIL]

## Edge Cases
1. [edge case]: [how handled]
2. [edge case]: [how handled]
3. [edge case]: [how handled]

## Self-Review
- Weakest part: [honest assessment]
- Potential criticism: [what would be flagged]
- Tech debt: [any introduced, or 'None']
- TODOs remaining: [count and list, or 'None']

## Git Status
- Uncommitted changes: [count, should be 0]
- Last commit: [hash and message]
\`\`\`

---

**TO PASS VERIFICATION:**
1. Complete ALL sections above
2. All tests must PASS
3. Build must SUCCEED
4. No uncommitted changes
5. Output: <nelson-verified>VERIFICATION_COMPLETE</nelson-verified>

**IF ISSUES FOUND:**
- Fix them first
- Re-run verification
- Do NOT claim completion until ALL checks pass

Nelson is watching. HA-HA!
"

  jq -n \
    --arg prompt "$VERIFICATION_PROMPT" \
    --arg msg "🔴 VERIFICATION CHALLENGE | Tests + Build + Self-Review required | <nelson-verified>VERIFICATION_COMPLETE</nelson-verified>" \
    '{
      "decision": "block",
      "reason": $prompt,
      "systemMessage": $msg
    }'

  exit 0
fi

# ============================================================
# NORMAL ITERATION (no completion claimed)
# ============================================================

# Check if handoff was updated this iteration
HANDOFF_UPDATED=false
if [[ -f "$NELSON_HANDOFF_FILE" ]]; then
  # Check if handoff mentions current iteration
  if grep -q "Iteration $ITERATION" "$NELSON_HANDOFF_FILE"; then
    HANDOFF_UPDATED=true
  fi
fi

# Build validation warning if handoff not updated
VALIDATION_WARNING=""
if [[ "$HANDOFF_UPDATED" != "true" ]]; then
  VALIDATION_WARNING="
!! HANDOFF NOT UPDATED !!
   You MUST update .claude/nelson-handoff.local.md before completing.
   Include: what you did, what's pending, next steps.
"
fi

# Not complete - continue loop
NEXT_ITERATION=$((ITERATION + 1))

# Extract prompt (everything after the closing ---)
PROMPT_TEXT=$(awk '/^---$/{i++; next} i>=2' "$NELSON_STATE_FILE")

if [[ -z "$PROMPT_TEXT" ]]; then
  echo "Nelson loop: No prompt text found in state file" >&2
  rm "$NELSON_STATE_FILE"
  exit 0
fi

# Update iteration in state file
TEMP_FILE="${NELSON_STATE_FILE}.tmp.$$"
sed "s/^iteration: .*/iteration: $NEXT_ITERATION/" "$NELSON_STATE_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$NELSON_STATE_FILE"

# Build system message based on mode
if [[ "$HA_HA_MODE" == "true" ]]; then
  MODE_LABEL="HA-HA MODE"
else
  MODE_LABEL="Nelson"
fi

# Build iteration prompt with protocol reminder
if [[ "$HA_HA_MODE" == "true" ]]; then
  ITERATION_PROMPT="
## HA-HA MODE - ITERATION $NEXT_ITERATION
$VALIDATION_WARNING
### ITERATION PROTOCOL (MANDATORY)

**PHASE 1: PLAN (Do this FIRST!)**
1. Read handoff: cat .claude/nelson-handoff.local.md
2. Think hard about current state and what's done
3. Select ONE feature/task to complete this iteration
4. Write brief plan to .claude/nelson-scratchpad.local.md

**PHASE 2: WORK (Single-feature focus)**
1. Implement the ONE selected feature
2. Do NOT touch other features
3. Commit working code: git commit -m \"feat: description\"

**PHASE 3: VERIFY (Before claiming completion)**
⚠️ WARNING: Nelson v3.3.0 has AGGRESSIVE verification!
- If you claim completion, you will face a VERIFICATION CHALLENGE
- Tests MUST pass, build MUST succeed
- Self-review and edge case audit REQUIRED
- No uncommitted changes allowed

**PHASE 4: HANDOFF (REQUIRED before exit)**
Update .claude/nelson-handoff.local.md with:
- What was completed this iteration
- What's still pending
- Exact next steps

**HA-HA MODE EXTRAS:**
- Pre-flight research MANDATORY before coding
- Multi-dimensional ultrathink (4 levels)
- Wall-Breaker protocol on obstacles
- 5-attempt escalation ladder

---

### YOUR TASK

$PROMPT_TEXT

---

**COMPLETION SIGNALS:**
- Normal: <nelson-complete>ALL_FEATURES_COMPLETE</nelson-complete>
$(if [[ "$COMPLETION_PROMISE" != "null" ]]; then echo "- Promise: <promise>$COMPLETION_PROMISE</promise>"; fi)

⚠️ These trigger VERIFICATION CHALLENGE - be ready!

**START: Read handoff -> Plan -> Select ONE feature -> Work**
"
else
  ITERATION_PROMPT="
## Nelson Muntz - Iteration $NEXT_ITERATION
$VALIDATION_WARNING
### ITERATION PROTOCOL (MANDATORY)

**PHASE 1: PLAN**
1. Read handoff: cat .claude/nelson-handoff.local.md
2. Think about current state and what's done
3. Select ONE feature/task to complete this iteration

**PHASE 2: WORK**
1. Implement the ONE selected feature
2. Do NOT touch other features
3. Commit working code

**PHASE 3: VERIFY**
⚠️ WARNING: Nelson v3.3.0 has AGGRESSIVE verification!
- If you claim completion, you will face a VERIFICATION CHALLENGE
- Tests MUST pass, build MUST succeed
- Self-review and edge case audit REQUIRED

**PHASE 4: HANDOFF (REQUIRED)**
Update .claude/nelson-handoff.local.md before exit

---

### YOUR TASK

$PROMPT_TEXT

---

**COMPLETION SIGNALS:**
- <nelson-complete>ALL_FEATURES_COMPLETE</nelson-complete>
$(if [[ "$COMPLETION_PROMISE" != "null" ]]; then echo "- <promise>$COMPLETION_PROMISE</promise>"; fi)

⚠️ These trigger VERIFICATION CHALLENGE - be ready!

**START: Read handoff -> Plan -> Work**
"
fi

# Build system message
SYSTEM_MSG="$MODE_LABEL iteration $NEXT_ITERATION | Read handoff first! | Completion triggers VERIFICATION CHALLENGE"

# Output JSON to block the stop and feed prompt back
jq -n \
  --arg prompt "$ITERATION_PROMPT" \
  --arg msg "$SYSTEM_MSG" \
  '{
    "decision": "block",
    "reason": $prompt,
    "systemMessage": $msg
  }'

exit 0
