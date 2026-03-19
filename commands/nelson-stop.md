---
description: "Stop Nelson Muntz loop and clean up state files"
allowed-tools: ["Bash(rm .claude/nelson-loop.local.md)", "Bash(rm .claude/nelson-handoff.local.md)", "Bash(rm .claude/nelson-verification.local.md)", "Bash(rm .claude/nelson-edit-tracker.local.json)"]
---

# Nelson Stop (v5.0)

Stop the active Nelson Muntz loop and clean up state files.

```!
if [ -f .claude/nelson-loop.local.md ]; then
  rm .claude/nelson-loop.local.md
  rm -f .claude/nelson-handoff.local.md
  rm -f .claude/nelson-verification.local.md
  rm -f .claude/nelson-edit-tracker.local.json
  echo ""
  echo "HA-HA! Nelson loop stopped."
  echo ""
  echo "Cleaned up: state, handoff, verification, and edit tracker files."
  echo "Start a new one with /nelson-muntz:nelson or /nelson:ha-ha"
else
  echo ""
  echo "No active Nelson loop to stop."
  echo ""
fi
```

## What Happens

1. Removes the loop state file
2. Removes handoff, verification, and edit tracker files
3. Stop hook will no longer intercept exit
4. Session can end normally

## Starting a New Loop

```bash
# Standard mode
/nelson-muntz:nelson "Build a REST API" --max-iterations 20

# HA-HA mode (Peak Performance)
/nelson:ha-ha "Build OAuth authentication" --max-iterations 30
```

## Note

This in-session loop has no resume feature. The loop is either active or stopped. To continue work, start a new loop with the same prompt.
