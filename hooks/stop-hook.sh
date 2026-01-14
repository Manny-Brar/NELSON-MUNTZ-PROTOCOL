#!/bin/bash

# Nelson Muntz Stop Hook
# In-session looping with ultrathink, two-stage validation, and HA-HA mode
#
# Key Features:
#   - Fresh context each iteration (via stop hook blocking)
#   - HA-HA mode for peak performance
#   - Ultrathink protocol integration
#   - Two-stage validation (spec + quality)
#   - 3-fix rule (5 in HA-HA mode)
#   - Single-feature focus enforcement

set -euo pipefail

# Read hook input from stdin (advanced stop hook API)
HOOK_INPUT=$(cat)

# Check for Nelson loop state file
NELSON_STATE_FILE=".claude/nelson-loop.local.md"

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
    echo "All done!"
    echo ""
    rm "$NELSON_STATE_FILE"
    exit 0
  fi
fi

# Check for ALL_FEATURES_COMPLETE signal
if echo "$LAST_OUTPUT" | grep -q "<nelson-complete>ALL_FEATURES_COMPLETE</nelson-complete>"; then
  echo ""
  echo "HA-HA! Nelson loop: All features completed!"
  echo ""
  rm "$NELSON_STATE_FILE"
  exit 0
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
  SYSTEM_MSG="HA-HA MODE - Iteration $NEXT_ITERATION | Peak Performance | To complete: <promise>$COMPLETION_PROMISE</promise> or <nelson-complete>ALL_FEATURES_COMPLETE</nelson-complete>"
else
  SYSTEM_MSG="Nelson Iteration $NEXT_ITERATION | To complete: <promise>$COMPLETION_PROMISE</promise> or <nelson-complete>ALL_FEATURES_COMPLETE</nelson-complete>"
fi

# Add HA-HA mode banner if active
if [[ "$HA_HA_MODE" == "true" ]]; then
  PROMPT_TEXT="## HA-HA MODE ACTIVE - ITERATION $NEXT_ITERATION

**Peak Performance Protocol:**
1. Pre-flight research MANDATORY before coding
2. Multi-dimensional thinking (4 levels of ultrathink)
3. Wall-Breaker protocol on any obstacle
4. 5-attempt escalation (not 3)
5. Aggressive validation + self-review

**Previous iteration output available in transcript. Continue from where you left off.**

---

$PROMPT_TEXT"
else
  PROMPT_TEXT="## Nelson Muntz - Iteration $NEXT_ITERATION

**Continue the task. Your previous work is visible in files and git history.**

**Protocol:**
1. Engage ultrathink before acting
2. Single-feature focus
3. Two-stage validation (spec + quality)
4. 3-fix rule (escalate after 3 failures)

---

$PROMPT_TEXT"
fi

# Output JSON to block the stop and feed prompt back
jq -n \
  --arg prompt "$PROMPT_TEXT" \
  --arg msg "$SYSTEM_MSG" \
  '{
    "decision": "block",
    "reason": $prompt,
    "systemMessage": $msg
  }'

exit 0
