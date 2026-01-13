---
description: "Check Nelson Muntz loop status"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/nelson-muntz.sh:*)", "Read(.claude/ralph-v3/*)", "Read(.claude/nelson-muntz.log)"]
hide-from-slash-command-tool: "true"
---

# Nelson Status

Check the current status of the Nelson Muntz loop.

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/nelson-muntz.sh" status
```

## What This Shows

- **Running State**: Whether the loop is active, stopped, or completed
- **Iteration Count**: Current iteration number
- **Feature Summary**: Total, completed, blocked, pending
- **Configuration**: Model, max iterations, completion promise
- **Git Stats**: Number of checkpoints created

## Quick Status Commands

```bash
# Full status report
/nelson-status

# Just check if running
test -f .claude/nelson-muntz.pid && echo "RUNNING" || echo "NOT RUNNING"

# Check latest handoff
cat .claude/ralph-v3/handoff.md

# Check feature progress
cat .claude/ralph-v3/features.json | jq '.summary'

# View recent log entries
tail -20 .claude/nelson-muntz.log
```
