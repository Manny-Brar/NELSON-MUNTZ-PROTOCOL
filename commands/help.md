---
description: "Nelson Muntz plugin help and documentation (v5.0)"
---

# Nelson Muntz v5.0 — Harness-Engineered Development Loop

**HA-HA!** Welcome to Nelson Muntz v5.0 — now with harness engineering.

## What Is This?

Nelson Muntz is a **harness-engineered** AI development loop. The agent isn't the hard part — the harness is:

- Spawns **fresh context** for each iteration (no context rot, no drift)
- Uses **Opus 4.6** for peak performance
- Implements **5-level ULTRATHINK** protocol for extended reasoning
- Enforces **single-feature focus** per iteration
- Provides **three-stage validation** (spec + quality + adversarial red-team)
- Applies the **3-fix rule** (5-fix in HA-HA mode)
- Creates **git checkpoints** on feature completion
- **v5.0: Drift detection** with circuit breaker at score >= 7
- **v5.0: Compound learning** — each iteration makes the next easier
- **v5.0: Tiered context loading** — L0/L1/L2 progressive disclosure (~80% token savings)
- **v5.0: Multi-agent support** — Planner-Worker-Judge pattern with worktree isolation
- **v5.0: Self-evolving evaluation** — GEPA-inspired skill refinement from execution traces

## Why "Nelson Muntz"?

Named after the bully from The Simpsons who says "HA-HA!" when things fail. Here, the HA-HA comes when we **succeed** — because we've conquered the problem through persistent iteration!

---

## Commands

| Command | Description |
|---------|-------------|
| `/nelson-muntz:nelson "prompt"` | Start a new development loop (standard mode) |
| `/nelson-muntz:ha-ha "prompt"` | Start in HA-HA Mode (Peak Performance) |
| `/nelson-muntz:nelson-status` | Check loop status |
| `/nelson-muntz:nelson-stop` | Stop running loop |
| `/nelson-muntz:help` | Show this help |

### Invocation Format

Use the fully qualified `plugin-name:command-name` format:

```bash
# HA-HA Mode (Peak Performance)
/nelson-muntz:ha-ha "Build OAuth authentication" --max-iterations 16

# Standard Nelson loop
/nelson-muntz:nelson "Build REST API" --max-iterations 20

# With bracket-delimited task list
/nelson-muntz:ha-ha "( task1, task2, task3 )" --max-iterations 10
```

---

## Quick Start

```bash
# Start a development loop (use quotes around prompt)
/nelson-muntz:nelson "Build a REST API with user authentication" --max-iterations 30

# Or with completion promise
/nelson-muntz:nelson "Build a REST API" --max-iterations 30 --completion-promise "ALL TESTS PASS"

# HA-HA Mode for complex tasks
/nelson-muntz:ha-ha "Build OAuth + JWT authentication" --max-iterations 20

# With bracket-delimited task list (flexible formatting)
/nelson-muntz:ha-ha "( fix login bug, add tests, update docs )" --max-iterations 10

# Monitor progress
/nelson-muntz:nelson-status

# Stop if needed
/nelson-muntz:nelson-stop
```

---

## Key Innovations

### 1. Fresh Context Every Iteration

Each iteration gets a clean 1M token context window. No accumulated garbage, no context rot, no degraded performance.

```
Iteration 1: Fresh 1M context → Tiered L0/L1/L2 loading
     ↓ (state files + compound learning persist)
Iteration 2: Fresh 1M context → Smarter loading (patterns from iter 1)
     ↓ (knowledge compounds)
Iteration N: Fresh 1M context → Fastest iteration (maximum knowledge)
```

### 2. Ultrathink Protocol (5 Levels)

Before ANY action, Claude engages extended thinking:
- Level 1: Standard analysis
- Level 2: Deep analysis (edge cases, dependencies)
- Level 3: Adversarial analysis (what could go wrong?)
- Level 4: Meta analysis (is this the best approach?)
- Level 5: **Compound analysis** (how does this make the next iteration easier?)

### 3. Three-Stage Validation

**Stage 1: Spec Compliance** — Did we implement what was asked?
**Stage 2: Quality Check** — Do tests, lint, build, types pass?
**Stage 3: Adversarial Red-Team Review** (v5.0) — How would I break this?

All stages must pass for a feature to be complete.

### 4. 3-Fix Rule (5-Fix in HA-HA)

If a feature fails 3 times (5 in HA-HA mode):
1. Mark it as "blocked"
2. Document why it failed
3. Move to next feature

Prevents infinite loops on impossible problems.

### 5. Initializer/Executor Split

**Iteration 1 (Initializer):** Scaffold, decompose, plan — NO implementation
**Iteration 2+ (Executor):** Read handoff → ONE feature → validate → compound learn → handoff

### 6. Drift Detection & Circuit Breaker (v5.0)

Active monitoring of agent behavioral degradation:
- Edit count, file spread, time elapsed, iteration count
- Drift score 0-10 calculated each iteration
- Circuit breaker at score >= 7 triggers fresh context recovery
- Research shows 4x failure rate when doubling session duration

### 7. Compound Learning Engine (v5.0)

Each iteration extracts and preserves knowledge:
- Success patterns documented for reuse
- Anti-patterns documented for prevention
- Skills refined based on execution traces (GEPA-inspired)
- Institutional knowledge accumulates across sessions

### 8. Tiered Context Loading (v5.0)

Progressive disclosure minimizes token waste:
- **L0**: Metadata scan (~100 tokens) — titles, descriptions
- **L1**: Overview loading (~500 tokens) — relevant summaries
- **L2**: Full content — on-demand only when needed
- ~80-90% reduction in startup context overhead

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

### Core Protocol Skills

| Skill | Purpose |
|-------|---------|
| `nelson-protocol-v5` | Core v5 protocol: harness architecture, tiered loading, multi-agent |
| `nelson-validate` | Two-stage validation protocol (three-stage in HA-HA) |
| `nelson-handoff` | Generate high-quality iteration handoffs |
| `nelson-decompose` | Feature decomposition for initialization |
| `nelson-wall-breaker` | Auto-research protocol when hitting obstacles |

### v5.0 Enhancement Skills

| Skill | Purpose |
|-------|---------|
| `nelson-compound-learning` | Compound engineering: pattern extraction, skill evolution |
| `nelson-drift-detection` | Drift scoring, circuit breakers, recovery strategies |
| `nelson-self-evolving-eval` | GEPA-inspired evaluation: trace analysis, ASI extraction |
| `nelson-integrations-v5` | Obsidian graph memory + GWS workspace orchestration |

### Domain Skills

| Skill | Purpose |
|-------|---------|
| `frontend-ui-ux` | Peak performance UI/UX with anti-slop design |
| `database-supabase` | Postgres/Supabase with RLS and multi-tenant patterns |

---

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `--max-iterations` | 16 (max: 36) | Stop after N iterations (0 = unlimited) |
| `--completion-promise` | none | Text that signals completion |
| `--model` | opus | Claude model to use |
| `--delay` | 3 | Seconds between iterations |
| `--background` | false | Run loop in background |
| `--ha-ha` | false | Enable HA-HA Mode (all v5 enhancements) |
| `--parallel` | false | Enable worktree-isolated parallel agents (v5.0) |

---

## HA-HA Mode — Peak Performance (v5.0)

**HA-HA Mode** is the ultimate harness-engineered configuration with all v5 enhancements enabled.

### Quick Start (HA-HA Mode)

```bash
# Primary v5 format
/nelson-muntz:ha-ha "Build OAuth + JWT + MFA auth system" --max-iterations 30

# Also works: plugin-qualified format
/nelson-muntz:ha-ha "Complex task" --max-iterations 50

# Or use the flag on standard nelson
/nelson-muntz:nelson "Complex task" --ha-ha --max-iterations 50
```

### What HA-HA Mode Adds

| Standard | HA-HA Mode (v5.0) |
|----------|-------------------|
| Ultrathink | Multi-dimensional thinking (5 levels incl. compound) |
| Research on 2nd failure | Pre-research MANDATORY |
| 3-fix rule | 5-attempt escalation |
| Two-stage validation | Three-stage (spec + quality + red-team) |
| Basic tracking | Compound learning engine |
| No drift detection | Active drift scoring + circuit breaker |

### HA-HA Mode Protocols

1. **Boot Sequence** — Tiered L0/L1/L2 context loading, skill discovery
2. **Pre-Flight Research** — Search best practices BEFORE coding
3. **Multi-Dimensional Thinking** — 5 levels including adversarial, meta, & compound
4. **Parallel Exploration** — Evaluate multiple approaches, worktree isolation
5. **Wall-Breaker Protocol** — Auto web search on ANY obstacle
6. **Three-Stage Validation** — Spec + quality + adversarial red-team review
7. **Self-Reflection Checkpoints** — Verify at key decision points
8. **Compound Learning** — Extract patterns, refine skills, compound knowledge
9. **Drift Detection** — Active scoring, circuit breaker at 7+
10. **No-Surrender Persistence** — 5 attempts with research between

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
/nelson-muntz:nelson "Complex task" --max-iterations 50
```

### Using Completion Promises

For clear end conditions:
```bash
/nelson-muntz:nelson "Fix the auth bug" --completion-promise "ALL TESTS PASS"
```

---

## Philosophy

1. **The Harness Is the Hard Part** — Infrastructure outperforms raw model capability
2. **Fresh Context > Accumulated Garbage** — Start clean each iteration
3. **Ultrathink > Quick Action** — Plan before executing (5 levels)
4. **Single Focus > Multitasking** — One feature at a time
5. **Three-Stage Validation > Assumption** — Spec + quality + red-team
6. **Compound Learning > Repetition** — Each iteration makes the next easier
7. **Detect Drift > Fight Drift** — Circuit break before failure cascades
8. **Clean Handoff > Complete History** — Next iteration only needs context

---

## Credits

- **Ralph Wiggum** — The original technique by Geoffrey Huntley
- **Anthropic Harness** — "Effective Harnesses for Long-Running Agents"
- **Context Engineering** — Anthropic's context engineering guide
- **GEPA** — Genetic-Pareto reflective prompt evolution (ICLR 2026)
- **Compound Engineering** — Every, Inc. methodology
- **OpenViking** — L0/L1/L2 tiered context loading
- **Factory AI Signals** — Self-improving agent architecture

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
