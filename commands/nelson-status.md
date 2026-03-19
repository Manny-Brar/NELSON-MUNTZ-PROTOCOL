---
description: "Check Nelson Muntz loop status (v5.0 — includes drift score and edit metrics)"
allowed-tools: ["Bash(head *)", "Bash(cat *)", "Bash(jq *)", "Read(.claude/nelson-loop.local.md)", "Read(.claude/nelson-edit-tracker.local.json)"]
---

# Nelson Status (v5.0)

Check the current status of the Nelson Muntz loop.

```!
if [ -f .claude/nelson-loop.local.md ]; then
  echo "=== Nelson Muntz Status (v5.0) ==="
  echo ""
  # Extract values from YAML frontmatter
  ITERATION=$(sed -n '/^---$/,/^---$/p' .claude/nelson-loop.local.md | grep 'iteration:' | sed 's/iteration: *//')
  CURRENT_TASK=$(sed -n '/^---$/,/^---$/p' .claude/nelson-loop.local.md | grep 'current_task:' | sed 's/current_task: *//')
  TASK_COUNT=$(sed -n '/^---$/,/^---$/p' .claude/nelson-loop.local.md | grep 'task_count:' | sed 's/task_count: *//')
  MAX_ITER=$(sed -n '/^---$/,/^---$/p' .claude/nelson-loop.local.md | grep 'max_iterations:' | sed 's/max_iterations: *//')
  HA_HA=$(sed -n '/^---$/,/^---$/p' .claude/nelson-loop.local.md | grep 'ha_ha_mode:' | sed 's/ha_ha_mode: *//')
  STARTED=$(sed -n '/^---$/,/^---$/p' .claude/nelson-loop.local.md | grep 'started_at:' | sed 's/started_at: *//' | sed 's/"//g')
  echo "Status: ACTIVE"
  echo "Iteration: $ITERATION of $(if [ "$MAX_ITER" = "0" ]; then echo "unlimited"; else echo "$MAX_ITER"; fi)"
  if [ -n "$CURRENT_TASK" ] && [ -n "$TASK_COUNT" ]; then
    echo "Task: $CURRENT_TASK of $TASK_COUNT"
  fi
  echo "HA-HA Mode: $HA_HA"
  echo "Started: $STARTED"
  echo ""
  # v5.0: Show edit tracker metrics if available
  if [ -f .claude/nelson-edit-tracker.local.json ] && command -v jq &> /dev/null; then
    EDIT_COUNT=$(jq '.edit_count // 0' .claude/nelson-edit-tracker.local.json 2>/dev/null)
    FILE_COUNT=$(jq '.files_touched | length' .claude/nelson-edit-tracker.local.json 2>/dev/null)
    echo "--- v5.0 Metrics ---"
    echo "Edits this iteration: $EDIT_COUNT"
    echo "Files touched: $FILE_COUNT"
    # Simple drift score estimate
    DRIFT=0
    if [ "$EDIT_COUNT" -gt 30 ] 2>/dev/null; then DRIFT=$((DRIFT + 2)); elif [ "$EDIT_COUNT" -gt 20 ] 2>/dev/null; then DRIFT=$((DRIFT + 1)); fi
    if [ "$FILE_COUNT" -gt 8 ] 2>/dev/null; then DRIFT=$((DRIFT + 2)); elif [ "$FILE_COUNT" -gt 5 ] 2>/dev/null; then DRIFT=$((DRIFT + 1)); fi
    if [ "$ITERATION" -gt 10 ] 2>/dev/null; then DRIFT=$((DRIFT + 2)); elif [ "$ITERATION" -gt 5 ] 2>/dev/null; then DRIFT=$((DRIFT + 1)); fi
    echo "Drift Score: $DRIFT/10 $(if [ "$DRIFT" -ge 7 ]; then echo '⚡ CIRCUIT BREAKER'; elif [ "$DRIFT" -ge 5 ]; then echo '🟠 WARNING'; elif [ "$DRIFT" -ge 3 ]; then echo '🟡 WATCH'; else echo '🟢 HEALTHY'; fi)"
    echo ""
  fi
else
  echo "=== Nelson Muntz Status ==="
  echo ""
  echo "Status: NOT ACTIVE"
  echo ""
  echo "No active Nelson loop. Start one with:"
  echo "  /nelson-muntz:nelson \"Your task here\""
  echo "  /nelson-muntz:ha-ha \"Complex task here\""
fi
```

## What This Shows

- **Active State**: Whether a loop is currently running
- **Iteration Count**: Current iteration and task progress
- **Mode**: Standard or HA-HA Mode
- **Max Iterations**: Limit if set
- **v5.0 Metrics**: Edit count, files touched, drift score with status indicator

## Drift Score Guide

| Score | Status | Meaning |
|-------|--------|---------|
| 0-2 | 🟢 HEALTHY | No drift detected |
| 3-4 | 🟡 WATCH | Minor drift signals, monitor |
| 5-6 | 🟠 WARNING | Prepare for fresh context |
| 7+ | ⚡ CIRCUIT BREAKER | Auto-triggers recovery |

## Quick Status Commands

```bash
# Full status report
/nelson-muntz:nelson-status

# Just check if active
test -f .claude/nelson-loop.local.md && echo "ACTIVE" || echo "NOT ACTIVE"

# View edit tracker (v5.0)
cat .claude/nelson-edit-tracker.local.json | jq .
```
