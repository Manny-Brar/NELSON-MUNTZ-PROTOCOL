---
description: "Start Nelson Muntz harness-engineered development loop (v5.0)"
argument-hint: "PROMPT [--max-iterations N] [--completion-promise TEXT] [--parallel]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-nelson-loop.sh:*)"]
---

# Nelson Muntz - Harness-Engineered Development Loop (v5.0)

Execute the Nelson Muntz loop:

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-nelson-loop.sh" ${ARGUMENTS}
```

## What is Nelson Muntz?

Nelson Muntz is a harness-engineered AI development loop — the agent isn't the hard part, the harness is:

- **Fresh Context Every Iteration** — No context rot, 1M clean tokens per session
- **Ultrathink Integration** — Extended reasoning before every action
- **Two-Stage Validation** — Spec compliance + quality checks (3-stage in HA-HA mode)
- **3-Fix Rule** — Auto-escalate after 3 failed attempts
- **Git Checkpointing** — Automatic commits on feature completion
- **Single-Feature Focus** — ONE feature per iteration, enforced
- **Clean State Gate** — Cannot exit with broken code
- **Drift Detection** (v5.0) — Active monitoring with circuit breaker at score >= 7
- **Compound Learning** (v5.0) — Each iteration makes the next easier
- **Tiered Context Loading** (v5.0) — L0/L1/L2 progressive disclosure, ~80% token savings

## Usage

```bash
# Start new loop
/nelson-muntz:nelson "Build a REST API with auth" --max-iterations 30

# With completion promise
/nelson-muntz:nelson "Add user authentication" \
  --completion-promise "ALL TESTS PASS" \
  --max-iterations 50

# With bracket-delimited task list
/nelson-muntz:nelson "( task1, task2, task3 )" --max-iterations 10

# For peak performance, use HA-HA mode instead:
/nelson-muntz:ha-ha "Complex task" --max-iterations 30
```

## Options

| Option | Description | Default |
|--------|-------------|---------|
| `--max-iterations N` | Stop after N iterations | 16 (max: 36) |
| `--completion-promise TXT` | Text that signals completion | none |
| `--model MODEL` | Claude model | opus |
| `--delay N` | Seconds between iterations | 3 |
| `--background` | Run in background | false |
| `--ha-ha` | Enable HA-HA Mode (all v5 enhancements) | false |
| `--parallel` | Enable worktree-isolated parallel agents (v5.0) | false |

## State Files

```
.claude/
├── nelson-loop.local.md          # Loop state (YAML frontmatter + prompt)
├── nelson-handoff.local.md       # Iteration handoff
├── nelson-scratchpad.local.md    # Persistent notes
├── nelson-verification.local.md  # Validation results
├── nelson-edit-tracker.local.json # v5.0: Edit tracking for drift scoring
└── nelson-debug.log              # Debug log
```

## Monitoring

```bash
# Check status (includes drift score in v5)
/nelson-muntz:nelson-status

# Stop loop
/nelson-muntz:nelson-stop

# Watch debug log
tail -f .claude/nelson-debug.log
```

## How It Works

1. **Iteration 1 (Initializer)**
   - Boot sequence: tiered context loading (v5.0)
   - Sets up project scaffolding
   - Decomposes task into features
   - Writes handoff for iteration 2

2. **Iteration 2+ (Executor)**
   - Reads handoff from previous iteration
   - Selects highest-priority feature
   - Implements single feature
   - Validates with two-stage check (three-stage in HA-HA)
   - Creates git checkpoint on success
   - Compound learning: extracts patterns (v5.0)
   - Drift check: circuit breaker if score >= 7 (v5.0)
   - Writes handoff for next iteration

3. **Completion**
   - When all features pass OR completion promise detected
   - Verification challenge (must pass quality gates)
   - Final status report
   - HA-HA!

## HA-HA!

Nelson Muntz is named after the bully from The Simpsons who famously says "HA-HA!" when something fails. In this context, the HA-HA comes when we successfully complete — because we've conquered the problem!
