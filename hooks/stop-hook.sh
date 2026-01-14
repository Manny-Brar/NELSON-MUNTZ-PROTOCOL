#!/bin/bash

# Nelson Muntz Stop Hook (v3.2.0)
# In-session looping with mandatory planning, validation gates, and handoff
#
# Key Features:
#   - Fresh context each iteration (via stop hook blocking)
#   - Mandatory planning phase
#   - Two-stage validation (spec + quality)
#   - Handoff verification before exit
#   - HA-HA mode for peak performance

set -euo pipefail

# Read hook input from stdin (advanced stop hook API)
HOOK_INPUT=$(cat)

# Check for Nelson loop state file
NELSON_STATE_FILE=".claude/nelson-loop.local.md"
NELSON_HANDOFF_FILE=".claude/nelson-handoff.local.md"

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

# Check if loop is active
if [[ "$ACTIVE" != "true" ]]; then
  rm "$NELSON_STATE_FILE" 2>/dev/null || true
  rm "$NELSON_HANDOFF_FILE" 2>/dev/null || true
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

# Check for completion promise
if [[ "$COMPLETION_PROMISE" != "null" ]] && [[ -n "$COMPLETION_PROMISE" ]]; then
  PROMISE_TEXT=$(echo "$LAST_OUTPUT" | perl -0777 -pe 's/.*?<promise>(.*?)<\/promise>.*/$1/s; s/^\s+|\s+$//g; s/\s+/ /g' 2>/dev/null || echo "")

  if [[ -n "$PROMISE_TEXT" ]] && [[ "$PROMISE_TEXT" = "$COMPLETION_PROMISE" ]]; then
    echo ""
    echo "HA-HA! Nelson loop: Detected <promise>$COMPLETION_PROMISE</promise>"
    echo "Iterations completed: $ITERATION"
    echo ""
    rm "$NELSON_STATE_FILE"
    rm "$NELSON_HANDOFF_FILE" 2>/dev/null || true
    exit 0
  fi
fi

# Check for ALL_FEATURES_COMPLETE signal
if echo "$LAST_OUTPUT" | grep -q "<nelson-complete>ALL_FEATURES_COMPLETE</nelson-complete>"; then
  echo ""
  echo "HA-HA! Nelson loop: All features completed after $ITERATION iterations!"
  echo ""
  rm "$NELSON_STATE_FILE"
  rm "$NELSON_HANDOFF_FILE" 2>/dev/null || true
  exit 0
fi

# === VALIDATION GATES ===

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
- Stage 1 - Spec Check: Does it match requirements?
- Stage 2 - Quality Check: Tests pass? Build works?
- BOTH stages must pass before claiming done!

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

To complete: <nelson-complete>ALL_FEATURES_COMPLETE</nelson-complete>
$(if [[ "$COMPLETION_PROMISE" != "null" ]]; then echo "Or: <promise>$COMPLETION_PROMISE</promise> (only if TRUE!)"; fi)

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
- Stage 1 - Spec Check: Does it match requirements?
- Stage 2 - Quality Check: Tests pass? Build works?

**PHASE 4: HANDOFF (REQUIRED)**
Update .claude/nelson-handoff.local.md before exit

---

### YOUR TASK

$PROMPT_TEXT

---

To complete: <nelson-complete>ALL_FEATURES_COMPLETE</nelson-complete>
$(if [[ "$COMPLETION_PROMISE" != "null" ]]; then echo "Or: <promise>$COMPLETION_PROMISE</promise> (only if TRUE!)"; fi)

**START: Read handoff -> Plan -> Work**
"
fi

# Build system message
SYSTEM_MSG="$MODE_LABEL iteration $NEXT_ITERATION | Read handoff first! | To complete: <nelson-complete>ALL_FEATURES_COMPLETE</nelson-complete>"

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
