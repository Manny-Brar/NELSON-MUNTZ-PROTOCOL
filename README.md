# Nelson Muntz Protocol

![Nelson Muntz Banner](NELSON_MUNTZ.gif)

**HA-HA!** Your AI agent choked on context again? Pathetic.

![Nelson Muntz Protocol](NELSON_MUNTZ_2.png)

> *"Who hath summoned me?"*

```
   ███╗   ██╗███████╗██╗     ███████╗ ██████╗ ███╗   ██╗
   ████╗  ██║██╔════╝██║     ██╔════╝██╔═══██╗████╗  ██║
   ██╔██╗ ██║█████╗  ██║     ███████╗██║   ██║██╔██╗ ██║
   ██║╚██╗██║██╔══╝  ██║     ╚════██║██║   ██║██║╚██╗██║
   ██║ ╚████║███████╗███████╗███████║╚██████╔╝██║ ╚████║
   ╚═╝  ╚═══╝╚══════╝╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝

                    MUNTZ v5.1
         Harness-Engineered Development
         Phase-Gate Execution Engine

      "Others try. We triumph. HA-HA!" 🥊
```

> **This is THE ORIGINAL Nelson Muntz Protocol** by [Manny Brar](https://github.com/Manny-Brar). Copycats have popped up — imitation is flattery, but **there's only one Nelson.** HA-HA!

---

## What Is This?

Nelson Muntz is a **harness-engineered AI development loop** for [Claude Code](https://claude.com/code). It wraps your AI agent in a system that:

- Spawns **fresh 1M token context** every iteration (no context rot, ever)
- Decomposes tasks into **strategic multi-phase plans** with mandatory quality gates
- Thinks **5 levels deep** before touching code (ULTRATHINK protocol)
- Validates with **3 stages** including adversarial red-team review
- **Compounds knowledge** — each iteration makes the next one faster
- Detects **agent drift** and circuit breaks before quality degrades
- Can deploy **4 specialized subagents** for complex work

The agent isn't the hard part. **The harness is.** And this is the harness.

---

## Install

### Memory System (any project)

```bash
curl -fsSL https://raw.githubusercontent.com/Manny-Brar/NELSON-MUNTZ-PROTOCOL/main/install.sh | bash
```

This creates `.nelson/` with the memory database, search engine, patterns library, and auto-indexing.

### Claude Code Plugin (for the loop commands)

```bash
mkdir -p ~/.claude/plugins
cd ~/.claude/plugins
git clone https://github.com/Manny-Brar/NELSON-MUNTZ-PROTOCOL.git
```

Restart Claude Code. Verify with `/nelson-muntz:help`.

---

## How to Use Nelson (Triggers)

### Standard Mode — Routine Work

```bash
/nelson-muntz:nelson "Add a logout button" --max-iterations 10
```

Standard mode: fresh context each iteration, single-feature focus, two-stage validation, 3-fix rule. Good for straightforward tasks.

### HA-HA Mode — Peak Performance

```bash
/nelson-muntz:ha-ha "Build OAuth + JWT + MFA authentication" --max-iterations 30
```

HA-HA mode activates **everything**: Phase-Gate Engine, 5-level ULTRATHINK, three-stage validation with red-team review, compound learning, drift detection, auto-research, and the full 5-attempt escalation ladder.

**This is the recommended mode for any non-trivial work.**

### Overnight Autonomous Loop

```bash
/nelson-muntz:ha-ha "Build complete payment processing system" --max-iterations 30
```

Set it and walk away. Nelson will decompose, research, build, validate, document, and loop until done or iteration limit hit. Keep your terminal open.

### All Invocation Formats

```bash
# HA-HA Mode (recommended)
/nelson-muntz:ha-ha "task" --max-iterations 30

# Standard Mode
/nelson-muntz:nelson "task" --max-iterations 20

# With task list
/nelson-muntz:ha-ha "( task1, task2, task3 )" --max-iterations 20

# With completion promise
/nelson-muntz:nelson "Fix auth" --completion-promise "ALL TESTS PASS"

# With parallel agents (worktree isolation)
/nelson-muntz:ha-ha "Complex multi-file feature" --max-iterations 20 --parallel
```

### Monitor & Control

```bash
/nelson-muntz:nelson-status    # Check iteration, drift score, progress
/nelson-muntz:nelson-stop      # Stop the loop
```

---

## Commands & Options

| Command | What It Does |
|---------|-------------|
| `/nelson-muntz:ha-ha "task"` | Start HA-HA Mode (peak performance, all v5.1 features) |
| `/nelson-muntz:nelson "task"` | Start Standard Mode |
| `/nelson-muntz:nelson-status` | Check loop status + drift score |
| `/nelson-muntz:nelson-stop` | Stop the loop and clean up |
| `/nelson-muntz:help` | Full help documentation |

| Option | Default | What It Does |
|--------|---------|-------------|
| `--max-iterations N` | 16 | Stop after N iterations (max: 36, use 0 for unlimited) |
| `--completion-promise "TEXT"` | none | Stop when this text appears in output |
| `--parallel` | false | Enable worktree-isolated parallel agents |
| `--model MODEL` | opus | Claude model to use |
| `--ha-ha` | false | Enable HA-HA mode (on `/nelson` command) |

---

## When to Use What

| Situation | Use | Why |
|-----------|-----|-----|
| Simple bug fix | `/nelson-muntz:nelson` `--max-iterations 10` | Quick, focused, no overhead |
| Routine feature | `/nelson-muntz:nelson` `--max-iterations 20` | Standard validation is enough |
| Complex feature | `/nelson-muntz:ha-ha` `--max-iterations 30` | Phase-gate + research + red-team |
| Critical system | `/nelson-muntz:ha-ha` `--max-iterations 30 --completion-promise "..."` | Maximum safety |
| Unfamiliar tech | `/nelson-muntz:ha-ha` | Mandatory pre-research before coding |
| Overnight build | `/nelson-muntz:ha-ha` `--max-iterations 30` | Set it and sleep |
| Standard mode keeps failing | `/nelson-muntz:ha-ha` | 5-attempt escalation vs 3-fix |

---

## How It Works

### The Phase-Gate Engine (HA-HA Mode)

Every HA-HA request automatically runs through this:

```
1. DECOMPOSE → Strategic multi-phase plan (5-level ULTRATHINK)
2. SELF-ASSESS → Evaluate plan for gaps, risks → revise
3. FOR EACH PHASE:
   Gate A: EXECUTE all tasks
   Gate B: SELF-ASSESS (research best practices, fix gaps)
   Gate C: TEST (all tests pass before advancing)
   Gate D: DOCUMENT (ALL affected docs, cross-references)
4. REPEAT → Next phase only after all 4 gates pass
```

No shortcuts. No skipping gates. No advancing with broken code.

### The Iteration Loop

```
┌─────────────────────────────────────────────────────────────┐
│              NELSON v5.1 HARNESS ENGINE                      │
│                                                              │
│   BOOT: Tiered L0/L1/L2 context loading                    │
│   PLAN: 5-level ULTRATHINK                                  │
│   WORK: Single-feature focus                                │
│   VERIFY: Three-stage validation                            │
│     ├─ Stage 1: Spec compliance                             │
│     ├─ Stage 2: Quality (tests/lint/build)                  │
│     └─ Stage 3: Adversarial red-team review                 │
│   COMPOUND: Extract pattern/anti-pattern                    │
│   DRIFT CHECK: Score 0-10, circuit break at 7+              │
│   HANDOFF: Compound learning transfer → next iteration      │
│                                                              │
│   Fresh 1M context every iteration.                       │
│   State persists in files. Knowledge compounds.             │
└─────────────────────────────────────────────────────────────┘
```

### 5-Level ULTRATHINK

Before writing a single line of code:

```
Level 1 — Standard:    What needs to happen?
Level 2 — Deep:        What are the edge cases and dependencies?
Level 3 — Adversarial: What could go wrong? How would I break this?
Level 4 — Meta:        Is this the best approach? Simpler alternatives?
Level 5 — Compound:    How does this make the NEXT iteration easier?
```

### Wall-Breaker Protocol

When I hit a wall, I don't sit there crying. I research.

```
🔴 ERROR WALL      → Search exact error message + solutions
🟠 KNOWLEDGE WALL  → Search tutorials + official docs
🟡 DESIGN WALL     → Compare approaches, pick the winner
🟢 DEPENDENCY WALL → Find alternatives or mark blocked
🔵 COMPLEXITY WALL → Decompose into smaller pieces, beat each one
```

### Drift Detection

Agents get dumber over time. I detect it and circuit break.

| Score | Status | Action |
|-------|--------|--------|
| 0-2 | HEALTHY | Continue |
| 3-4 | WATCH | Monitor closely |
| 5-6 | WARNING | Prepare for fresh context |
| 7+ | CIRCUIT BREAKER | Auto-recovery with behavioral anchors |

### Multi-Agent Orchestration

For complex tasks, deploy specialized subagents:

| Agent | Model | Role |
|-------|-------|------|
| `nelson-planner` | Sonnet | Read-only analysis + implementation plan |
| `nelson-worker` | Opus | Implement single feature from plan |
| `nelson-judge` | Opus | Three-stage adversarial validation |
| `nelson-scout` | Haiku | Fast web research + intelligence |

See `skills/nelson-orchestrator.md` for the 5 coordination patterns.

---

## Memory System

```
.nelson/
├── NELSON_SOUL.md       # Identity (loaded every session)
├── MEMORY.md            # Long-term knowledge
├── memory.db            # SQLite + FTS5 search
├── memory/              # Daily session logs
├── patterns/            # Success patterns + anti-patterns
├── consolidate.cjs      # Memory consolidation tool
└── obsidian-bridge.cjs  # Obsidian graph bridge (optional)
```

### Tiered Loading (87% Token Savings)

```
L0 (~300 tokens):  Handoff, loop state, identity core — ALWAYS
L1 (~2K tokens):   Task-relevant search, recent scratchpad — SELECTIVE
L2 (variable):     Full skill files, full docs — ON-DEMAND only
```

---

## Skills & Agents

### Core Skills

| Skill | Purpose |
|-------|---------|
| `nelson-phase-gate` | Phase-Gate Execution Engine (master protocol) |
| `nelson-protocol-v5` | Core v5 harness architecture |
| `nelson-validate` | Three-stage validation protocol |
| `nelson-handoff` | 5-section handoff with compound transfer |
| `nelson-compound-learning` | Pattern extraction + compound engineering |
| `nelson-drift-detection` | Drift scoring + circuit breaker |
| `nelson-wall-breaker` | Auto-research on obstacles |
| `nelson-orchestrator` | Multi-agent coordination patterns |
| `nelson-self-evolving-eval` | GEPA-inspired skill evolution |
| `nelson-decompose` | Feature decomposition |

### Domain Skills

| Skill | Purpose |
|-------|---------|
| `frontend-ui-ux` | Peak performance UI/UX design |
| `database-supabase` | Postgres/Supabase with RLS |

---

## Best Practices

**DO:**
- Always use `--max-iterations` as a safety net
- Use HA-HA mode for anything complex or unfamiliar
- Let Nelson research before coding (don't skip pre-flight)
- Keep your terminal open for overnight runs
- Check `/nelson-status` for drift scores during long runs

**DON'T:**
- Don't interrupt mid-iteration (let it finish the gate cycle)
- Don't set unlimited iterations on untested tasks
- Don't skip the documentation gate (it's mandatory for a reason)
- Don't use standard mode when HA-HA mode keeps finding issues

---

## My Rules

1. **The Harness Is the Hard Part** — I'm an engineered system, not just an agent
2. **Fresh Context > Old Garbage** — *"Smell you later!"* to context rot
3. **Think Five Ways Before Punching** — ULTRATHINK isn't optional
4. **Prove It Three Ways** — Spec + quality + red-team. Every time.
5. **Compound > Repeat** — Each iteration makes the next one stronger
6. **Detect Drift > Fight Drift** — Circuit break before failure cascades
7. **Document Everything** — If it's not documented, it didn't happen
8. **One Feature, One Phase, One Gate at a Time** — Discipline wins

---

## Research Credits

**v5.1 Sources:**
- **[Anthropic: Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)**
- **[Anthropic: Context Engineering for AI Agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)**
- **[GEPA: Reflective Prompt Evolution (ICLR 2026 Oral)](https://arxiv.org/abs/2507.19457)**
- **[Compound Engineering (Every, Inc.)](https://every.to/guides/compound-engineering)**
- **[OpenViking L0/L1/L2 Tiered Context](https://github.com/volcengine/OpenViking)**
- **[Factory AI Signals: Self-Improving Agents](https://factory.ai/news/factory-signals)**

**Origins:**
- **[Ralph Wiggum Technique (Geoffrey Huntley)](https://ghuntley.com/ralph/)** — Started it. I finished it.
- **[GSD](https://github.com/kogumauk/get-shit-done-plus)** — Fresh context patterns
- **[Anthropic Harness Pattern](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)** — Initializer/executor split

---

## Full Documentation

- **[V5-QUICK-REFERENCE.md](V5-QUICK-REFERENCE.md)** — One-page cheat sheet
- **[NELSON_PROTOCOL_GUIDE.md](NELSON_PROTOCOL_GUIDE.md)** — Comprehensive technical guide
- **[V6-KNOWLEDGE-ENGINE-PLAN.md](V6-KNOWLEDGE-ENGINE-PLAN.md)** — What's coming next
- **[CONTRIBUTING.md](CONTRIBUTING.md)** — How to contribute

---

## License

MIT

---

## The Oath

```
I will DECOMPOSE strategically into phases.
I will ASSESS my plan before I begin.
I will pass every GATE: Execute → Assess → Test → Document.
I will THINK five levels deep before every action.
I will VALIDATE three ways before claiming completion.
I will COMPOUND — each iteration makes the next easier.
I will DETECT drift before it causes failure.
I will DOCUMENT everything, cross-referencing all affected docs.

The harness is the hard part. The agent follows.
```

---

*Now go beat up some bugs. Smell you later!* 🥊

---

> **This is the ORIGINAL Nelson Muntz Protocol.** Created by [Manny Brar](https://github.com/Manny-Brar). Accept no substitutes. Copycats get the HA-HA treatment. **HA-HA!** 🥊
