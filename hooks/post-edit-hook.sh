#!/bin/bash

# Nelson Muntz PostToolUse Hook (v5.0.0)
# Tracks file edits for drift scoring and incremental validation
#
# Fires after Edit, Write, or MultiEdit tool calls
# Maintains .claude/nelson-edit-tracker.local.json for drift metrics
#
# Features:
#   - Edit count tracking (drift indicator)
#   - File spread tracking (scope creep detection)
#   - Timestamp logging for time-based drift scoring
#   - Lightweight — adds < 50ms overhead per edit

set -euo pipefail

# Only track if Nelson loop is active
NELSON_STATE_FILE=".claude/nelson-loop.local.md"
if [[ ! -f "$NELSON_STATE_FILE" ]]; then
  exit 0
fi

# Read hook input from stdin
HOOK_INPUT=$(cat)

# Extract tool info
TOOL_NAME=""
FILE_PATH=""
if command -v jq &> /dev/null; then
  TOOL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_name // empty' 2>/dev/null || echo "")
  FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // empty' 2>/dev/null || echo "")
fi

# Tracker file
TRACKER_FILE=".claude/nelson-edit-tracker.local.json"
mkdir -p .claude

# Initialize tracker if it doesn't exist
if [[ ! -f "$TRACKER_FILE" ]]; then
  echo '{"edit_count":0,"files_touched":[],"timestamps":[],"iteration_start":"'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"}' > "$TRACKER_FILE"
fi

# Update tracker
if command -v jq &> /dev/null; then
  CURRENT=$(cat "$TRACKER_FILE")
  TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

  # Increment edit count, add file and timestamp
  UPDATED=$(echo "$CURRENT" | jq \
    --arg file "$FILE_PATH" \
    --arg ts "$TIMESTAMP" \
    '
    .edit_count += 1 |
    .timestamps += [$ts] |
    (if $file != "" and ($file | IN(.files_touched[]?) | not) then
      .files_touched += [$file]
    else . end)
    ' 2>/dev/null || echo "$CURRENT")

  echo "$UPDATED" > "$TRACKER_FILE"

  # Check for scope creep warning (more than 8 unique files in one iteration)
  FILE_COUNT=$(echo "$UPDATED" | jq '.files_touched | length' 2>/dev/null || echo "0")
  EDIT_COUNT=$(echo "$UPDATED" | jq '.edit_count' 2>/dev/null || echo "0")

  # Log warning but don't block (PostToolUse can't block)
  if [[ "$FILE_COUNT" -gt 8 ]]; then
    echo "[Nelson v5 drift warning] $FILE_COUNT files touched this iteration — possible scope creep" >> .claude/nelson-debug.log 2>/dev/null || true
  fi

  if [[ "$EDIT_COUNT" -gt 30 ]]; then
    echo "[Nelson v5 drift warning] $EDIT_COUNT edits this iteration — high edit velocity" >> .claude/nelson-debug.log 2>/dev/null || true
  fi
fi

exit 0
