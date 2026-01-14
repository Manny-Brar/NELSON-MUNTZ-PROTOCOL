---
description: "Stop Nelson Muntz loop"
allowed-tools: ["Bash(rm .claude/nelson-loop.local.md)"]
hide-from-slash-command-tool: "true"
---

# Nelson Stop

Stop the active Nelson Muntz loop.

```!
if [ -f .claude/nelson-loop.local.md ]; then
  rm .claude/nelson-loop.local.md
  echo ""
  echo "HA-HA! Nelson loop stopped."
  echo ""
  echo "The loop has been terminated."
  echo "Start a new one with /nelson or /ha-ha"
else
  echo ""
  echo "No active Nelson loop to stop."
  echo ""
fi
```

## What Happens

1. Removes the state file
2. Stop hook will no longer intercept exit
3. Session can end normally

## Starting a New Loop

```bash
# Standard mode
/nelson "Build a REST API" --max-iterations 20

# HA-HA mode (Peak Performance)
/ha-ha "Build OAuth authentication"
```

## Note

Unlike the previous CLI-based version, this in-session loop has no resume feature.
The loop is either active or stopped. To continue work, start a new loop with the same prompt.
