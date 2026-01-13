---
description: "Stop Nelson Muntz loop"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/nelson-muntz.sh:*)", "Bash(rm .claude/nelson-muntz.pid)"]
hide-from-slash-command-tool: "true"
---

# Nelson Stop

Stop the active Nelson Muntz loop.

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/nelson-muntz.sh" stop
```

## What Happens

1. Sends stop signal to running loop
2. Removes PID file
3. Marks loop as inactive in config.json
4. State files are preserved for later resume

## Resume Later

```bash
# Resume stopped loop
/nelson-resume

# Or via script directly
./.claude/plugins/repos/anthropics-claude-code/plugins/nelson-muntz/scripts/nelson-muntz.sh resume
```

## State Preserved

All state files are kept:
- `config.json` - Settings (marked inactive)
- `features.json` - Feature progress
- `handoff.md` - Context for resume
- `progress.md` - Full iteration history
- `scratchpad.md` - Debug notes

You can resume exactly where you left off.
