---
description: "Nelson Muntz plugin help and documentation"
---

# Nelson Muntz - Peak Performance Development Loop

**HA-HA!** Welcome to Nelson Muntz, the evolved successor to Ralph Wiggum.

## What Is This?

Nelson Muntz is an AI development loop system that:
- Spawns **fresh Claude sessions** for each iteration (no context rot)
- Uses **Opus 4.5** for peak performance
- Implements **ultrathink protocol** for extended reasoning
- Enforces **single-feature focus** per iteration
- Provides **two-stage validation** (spec + quality)
- Applies the **3-fix rule** (escalate after 3 failures)
- Creates **git checkpoints** on feature completion

## Why "Nelson Muntz"?

Named after the bully from The Simpsons who says "HA-HA!" when things fail. Here, the HA-HA comes when we **succeed** - because we've conquered the problem through persistent iteration!

---

## Commands

| Command | Description |
|---------|-------------|
| `/nelson "prompt"` | Start a new development loop (standard mode) |
| `/ha-ha "prompt"` | Start in HA-HA Mode (Peak Performance) |
| `/nelson-status` | Check loop status |
| `/nelson-stop` | Stop running loop |
| `/help` | Show this help |

### Invocation Formats

Both of these formats work:

```bash
# Shorthand (when command name is unique)
/ha-ha "Build OAuth authentication" --max-iterations 16

# Fully qualified (plugin-name:command-name)
/nelson-muntz:ha-ha "Build OAuth authentication" --max-iterations 16
/nelson-muntz:nelson "Build REST API" --max-iterations 20
```

---

## Quick Start

```bash
# Start a development loop (use quotes around prompt)
/nelson "Build a REST API with user authentication" --max-iterations 30

# Or with completion promise
/nelson "Build a REST API" --max-iterations 30 --completion-promise "ALL TESTS PASS"

# HA-HA Mode for complex tasks
/ha-ha "Build OAuth + JWT authentication" --max-iterations 20

# Fully qualified format also works
/nelson-muntz:ha-ha "Complex task" --max-iterations 16

# Monitor progress
/nelson-status

# Stop if needed
/nelson-stop
```

---

## Key Innovations

### 1. Fresh Context Every Iteration

Each iteration gets a clean 200k token context window. No accumulated garbage, no context rot, no degraded performance.

```
Iteration 1: Fresh 200k context
     ↓ (state files persist)
Iteration 2: Fresh 200k context
     ↓ (state files persist)
Iteration N: Fresh 200k context
```

### 2. Ultrathink Protocol

Before ANY action, Claude engages extended thinking:
- "think hard" about current state
- "ultrathink" about optimal approach
- Document reasoning in scratchpad.md

### 3. Two-Stage Validation

**Stage 1: Spec Compliance**
- Did we implement what was asked?
- Are all requirements satisfied?

**Stage 2: Quality Check**
- Do tests pass?
- Does lint pass?
- Does build succeed?

Both stages must pass for a feature to be complete.

### 4. 3-Fix Rule

If a feature fails 3 times:
1. Mark it as "blocked"
2. Document why it failed
3. Move to next feature

Prevents infinite loops on impossible problems.

### 5. Initializer/Executor Split

**Iteration 1 (Initializer):**
- Set up project scaffolding
- Decompose task into features
- Create init.sh for subsequent iterations
- NO implementation

**Iteration 2+ (Executor):**
- Read handoff from previous iteration
- Work on ONE feature
- Validate and checkpoint
- Write handoff for next iteration

### 6. Single-Feature Focus

Each iteration works on exactly ONE feature:
- Select highest-priority incomplete feature
- Complete it fully OR mark as blocked
- Do NOT touch other features
- Do NOT "quickly fix" unrelated issues

### 7. Clean State Gate

Cannot exit iteration with broken code:
- All tests must pass
- No lint errors
- Build must succeed
- Handoff must be written

---

## State Files

```
.claude/ralph-v3/
├── config.json         # Loop configuration
├── features.json       # Feature list with status
├── scratchpad.md       # Debug notes (persistent across all iterations)
├── progress.md         # Iteration log (append-only)
├── handoff.md          # Context for next iteration (rewritten each iter)
├── init.sh             # Project init script (created by initializer)
└── validation/
    ├── spec-check.json     # Requirements tracking
    └── quality-check.json  # Test/lint/build results
```

---

## Skills

Nelson Muntz includes specialized skills for common operations:

### Nelson-Specific Skills

| Skill | Purpose |
|-------|---------|
| `nelson-validate` | Two-stage validation protocol (spec + quality) |
| `nelson-handoff` | Generate high-quality iteration handoffs |
| `nelson-decompose` | Feature decomposition for initialization |
| `nelson-wall-breaker` | Auto-research protocol when hitting obstacles |

### Domain Skills

| Skill | Purpose |
|-------|---------|
| `frontend-ui-ux` | Peak performance UI/UX with anti-slop design |
| `database-supabase` | Postgres/Supabase with RLS and multi-tenant patterns |

### Using Skills

Skills are prompt templates that guide specific operations. Use them during Nelson iterations:

```
When hitting a wall:
"I'm invoking the nelson-wall-breaker skill to research this error"

When validating a feature:
"I'm using the nelson-validate skill for two-stage validation"

When building UI:
"I'm applying the frontend-ui-ux skill for this component"
```

Skills are in: `~/.claude/plugins/repos/anthropics-claude-code/plugins/nelson-muntz/skills/`

---

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `--max-iterations` | unlimited | Stop after N iterations |
| `--completion-promise` | none | Text that signals completion |
| `--model` | opus | Claude model to use |
| `--delay` | 3 | Seconds between iterations |
| `--background` | false | Run loop in background |
| `--ha-ha` | false | Enable HA-HA Mode (Peak Performance) |

---

## HA-HA Mode - Peak Performance

**HA-HA Mode** is the ultimate configuration with all enhancements enabled.

### Quick Start (HA-HA Mode)

```bash
# Use the dedicated command
/ha-ha "Build OAuth + JWT + MFA auth system"

# Or use the flag
/nelson "Complex task" --ha-ha --max-iterations 50
```

### What HA-HA Mode Adds

| Standard | HA-HA Mode |
|----------|------------|
| Ultrathink | Multi-dimensional thinking (4 levels) |
| Research on 2nd failure | Pre-research MANDATORY |
| 3-fix rule | 5-attempt escalation |
| Basic validation | Aggressive validation + self-review |

### HA-HA Mode Protocols

1. **Pre-Flight Research** - Search best practices BEFORE coding
2. **Multi-Dimensional Thinking** - 4 levels including adversarial & meta
3. **Parallel Exploration** - Evaluate multiple approaches
4. **Wall-Breaker Protocol** - Auto web search on ANY obstacle
5. **Aggressive Validation** - Pre, incremental, and post checks
6. **Self-Reflection Checkpoints** - Verify at key decision points
7. **Pattern Recognition** - Learn from previous iterations
8. **No-Surrender Persistence** - 5 attempts with research between

### Wall-Breaker Auto-Research

When hitting walls, Nelson automatically searches for solutions:

```
🔴 ERROR WALL      → Search error + solutions
🟠 KNOWLEDGE WALL  → Search tutorials + docs
🟡 DESIGN WALL     → Search comparisons
🟢 DEPENDENCY WALL → Search alternatives
🔵 COMPLEXITY WALL → Decompose + research
```

### When to Use HA-HA Mode

**Use HA-HA Mode for:**
- Complex, multi-component features
- Unfamiliar technologies
- Critical system components
- When standard mode keeps failing

---

## Monitoring

```bash
# Watch live log
tail -f .claude/nelson-muntz.log

# Check iteration progress
cat .claude/ralph-v3/config.json | jq '.iteration, .stats'

# Check feature status
cat .claude/ralph-v3/features.json | jq '.summary'

# Read latest handoff
cat .claude/ralph-v3/handoff.md

# See what was done
cat .claude/ralph-v3/progress.md

# Check validation status
cat .claude/ralph-v3/validation/quality-check.json
```

---

## Completion Signals

The loop stops when:
1. All features in `features.json` have `passes: true` or `status: blocked`
2. Completion promise is detected in handoff.md: `<promise>YOUR_PROMISE</promise>`
3. Max iterations is reached
4. Loop is manually stopped

---

## Best Practices

### Writing Good Prompts

**Good:**
```
Build a REST API with:
- User registration (email, password, validation)
- JWT authentication
- Protected endpoints
- Unit tests for all endpoints

Success criteria: All tests pass, no lint errors.
```

**Bad:**
```
Make an API
```

### Setting Iteration Limits

Always set `--max-iterations` as a safety net:
```bash
/nelson "Complex task" --max-iterations 50
```

### Using Completion Promises

For clear end conditions:
```bash
/nelson "Fix the auth bug" --completion-promise "ALL TESTS PASS"
```

---

## Philosophy

1. **Fresh Context > Accumulated Garbage** - Start clean each iteration
2. **Ultrathink > Quick Action** - Plan before executing
3. **Single Focus > Multitasking** - One feature at a time
4. **Validation > Assumption** - Two-stage checks
5. **Persistence > Perfection** - Keep iterating until done
6. **Clean Handoff > Complete History** - Next iteration only needs context

---

## Credits

- **Ralph Wiggum** - The original technique by Geoffrey Huntley
- **GSD (Get Shit Done)** - Context engineering inspiration
- **Multi-Agent Ralph** - Ultrathink and quality gates
- **Ralph Orchestrator** - Git checkpointing and scratchpad
- **Anthropic Harness** - Initializer/executor pattern

---

## HA-HA!

You've reached the end of the help. Now go build something!

```
         ╭─────────────────╮
         │     HA-HA!      │
         ╰────────┬────────╯
                  │
               ╭──┴──╮
               │ :-) │
               ╰─────╯
```
