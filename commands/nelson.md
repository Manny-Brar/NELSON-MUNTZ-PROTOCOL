---
description: "Start Nelson Muntz peak performance development loop"
argument-hint: "PROMPT [--max-iterations N] [--completion-promise TEXT]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-nelson-loop.sh:*)"]
hide-from-slash-command-tool: "true"
---

# Nelson Muntz - Peak Performance Development Loop

Execute the Nelson Muntz loop:

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-nelson-loop.sh" $ARGUMENTS
```

## What is Nelson Muntz?

Nelson Muntz is a peak performance AI development loop with:

- **In-Session Looping** - Stop hook intercepts exit, feeds prompt back
- **Ultrathink Integration** - Extended reasoning before every action
- **Two-Stage Validation** - Spec compliance + quality checks
- **3-Fix Rule** - Auto-escalate after 3 failed attempts
- **Single-Feature Focus** - ONE feature per iteration, enforced
- **Clean State Gate** - Cannot exit with broken code

## Usage

```bash
# Start new loop
/nelson "Build a REST API with auth" --max-iterations 30

# With completion promise
/nelson "Add user authentication" --completion-promise "ALL TESTS PASS"

# For complex tasks, use HA-HA mode
/ha-ha "Build OAuth authentication system"
```

## Options

| Option | Description |
|--------|-------------|
| `--max-iterations N` | Stop after N iterations (default: unlimited) |
| `--completion-promise TXT` | Text that signals completion |
| `--ha-ha` | Enable HA-HA Mode (Peak Performance) |

## Completion Signals

To complete the loop, output one of:

```
<nelson-complete>ALL_FEATURES_COMPLETE</nelson-complete>
```

Or if you set a completion promise:

```
<promise>YOUR_PROMISE_TEXT</promise>
```

## State File

```
.claude/nelson-loop.local.md    # YAML frontmatter + prompt
```

## Monitoring

```bash
# Check state
head -10 .claude/nelson-loop.local.md

# Check status
/nelson-status

# Stop loop
/nelson-stop
```

## How It Works

1. **Setup Phase**
   - Creates state file with prompt and settings
   - Activates stop hook

2. **Iteration Loop**
   - Work on the task
   - When you try to exit, stop hook intercepts
   - Feeds prompt back for next iteration
   - Your work persists in files

3. **Completion**
   - Output completion signal
   - Hook allows exit
   - HA-HA!

## Standard vs HA-HA Mode

| Standard Nelson | HA-HA Mode |
|-----------------|------------|
| Ultrathink | Multi-dimensional thinking (4 levels) |
| Research on 2nd failure | Pre-research MANDATORY |
| 3-fix rule | 5-attempt escalation |
| Standard validation | Aggressive validation + self-review |

Use `/ha-ha` for complex, multi-component features or unfamiliar technologies.

## HA-HA!

Nelson Muntz is named after the bully from The Simpsons who famously says "HA-HA!" when something fails. In this context, the HA-HA comes when we successfully complete - because we've conquered the problem!
