---
description: "Start Nelson Muntz peak performance development loop"
argument-hint: "PROMPT [--max-iterations N] [--completion-promise TEXT]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/nelson-muntz.sh:*)"]
hide-from-slash-command-tool: "true"
---

# Nelson Muntz - Peak Performance Development Loop

Execute the Nelson Muntz loop:

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/nelson-muntz.sh" start $ARGUMENTS
```

## What is Nelson Muntz?

Nelson Muntz is the evolved successor to Ralph Wiggum - a peak performance AI development loop with:

- **Fresh Context Every Iteration** - No context rot, 200k clean tokens per session
- **Ultrathink Integration** - Extended reasoning before every action
- **Two-Stage Validation** - Spec compliance + quality checks
- **3-Fix Rule** - Auto-escalate after 3 failed attempts
- **Git Checkpointing** - Automatic commits on feature completion
- **Single-Feature Focus** - ONE feature per iteration, enforced
- **Clean State Gate** - Cannot exit with broken code

## Usage

```bash
# Start new loop
/nelson "Build a REST API with auth" --max-iterations 30

# With completion promise
/nelson "Add user authentication" \
  --completion-promise "ALL TESTS PASS" \
  --max-iterations 50

# Run in background
/nelson "Refactor the module" --background
```

## Options

| Option | Description |
|--------|-------------|
| `--max-iterations N` | Stop after N iterations (default: unlimited) |
| `--completion-promise TXT` | Text that signals completion |
| `--model MODEL` | Claude model (default: claude-opus-4-5-20250514) |
| `--delay N` | Seconds between iterations (default: 3) |
| `--background` | Run in background |

## State Files

```
.claude/ralph-v3/
├── config.json         # Loop configuration
├── features.json       # Feature list with status
├── scratchpad.md       # Debug notes (persistent)
├── progress.md         # Iteration log (append-only)
├── handoff.md          # Context for next iteration
└── validation/
    ├── spec-check.json     # Requirements tracking
    └── quality-check.json  # Quality metrics
```

## Monitoring

```bash
# Watch live log
tail -f .claude/nelson-muntz.log

# Check status
/nelson-status

# Stop loop
/nelson-stop

# Check features
cat .claude/ralph-v3/features.json | jq '.summary'
```

## How It Works

1. **Iteration 1 (Initializer)**
   - Sets up project scaffolding
   - Decomposes task into features
   - Creates init.sh for subsequent iterations
   - Writes handoff for iteration 2

2. **Iteration 2+ (Executor)**
   - Reads handoff from previous iteration
   - Selects highest-priority feature
   - Implements single feature
   - Validates with two-stage check
   - Creates git checkpoint on success
   - Writes handoff for next iteration

3. **Completion**
   - When all features pass OR completion promise detected
   - Final status report
   - HA-HA!

## HA-HA!

Nelson Muntz is named after the bully from The Simpsons who famously says "HA-HA!" when something fails. In this context, the HA-HA comes when we successfully complete - because we've conquered the problem!
