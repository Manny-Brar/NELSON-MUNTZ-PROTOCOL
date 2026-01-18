---
description: "Check Nelson Muntz loop status"
allowed-tools: ["Bash(head *)", "Read(.claude/nelson-loop.local.md)"]
---

# Nelson Status

Check the current status of the Nelson Muntz loop.

```!
if [ -f .claude/nelson-loop.local.md ]; then
  echo "=== Nelson Muntz Status ==="
  echo ""
  head -10 .claude/nelson-loop.local.md
  echo ""
  echo "State file: .claude/nelson-loop.local.md"
  echo ""
  # Extract values from YAML frontmatter
  ITERATION=$(sed -n '/^---$/,/^---$/p' .claude/nelson-loop.local.md | grep 'iteration:' | sed 's/iteration: *//')
  MAX_ITER=$(sed -n '/^---$/,/^---$/p' .claude/nelson-loop.local.md | grep 'max_iterations:' | sed 's/max_iterations: *//')
  HA_HA=$(sed -n '/^---$/,/^---$/p' .claude/nelson-loop.local.md | grep 'ha_ha_mode:' | sed 's/ha_ha_mode: *//')
  echo "Current Iteration: $ITERATION"
  echo "Max Iterations: $(if [ "$MAX_ITER" = "0" ]; then echo "unlimited"; else echo "$MAX_ITER"; fi)"
  echo "HA-HA Mode: $HA_HA"
else
  echo "=== Nelson Muntz Status ==="
  echo ""
  echo "Status: NOT ACTIVE"
  echo ""
  echo "No active Nelson loop. Start one with:"
  echo "  /nelson \"Your task here\""
  echo "  /ha-ha \"Complex task here\""
fi
```

## What This Shows

- **Active State**: Whether a loop is currently running
- **Iteration Count**: Current iteration number
- **Mode**: Standard or HA-HA Mode
- **Max Iterations**: Limit if set

## Quick Status Commands

```bash
# Full status report
/nelson-status

# Just check if active
test -f .claude/nelson-loop.local.md && echo "ACTIVE" || echo "NOT ACTIVE"

# View full state file
cat .claude/nelson-loop.local.md
```
