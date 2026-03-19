# Nelson Muntz Protocol

![Nelson Muntz Banner](NELSON_MUNTZ.gif)

**HA-HA!** Your AI agent choked on context again? Pathetic.

![Nelson Muntz Protocol](NELSON_MUNTZ_2.png)

> *"Who hath summoned me?"*

---

## 🥊 Listen Up, Nerds

So your fancy AI agent gets confused after 50k tokens? Can't remember what it was doing? Keeps making the same dumb mistakes? **HA-HA!**

That's because you're using some wimpy single-session setup that gets tired and stupid.

Me? I show up with a **fresh 200k tokens every single iteration**. While your agent is drooling in the corner, mine is cracking knuckles and shipping features.

**When context rot tries to mess with me:** *"Smell you later!"* 👋

**When scope creep sneaks in:** Gets beat up. I only work on ONE thing at a time.

**When the same bug shows up twice:** *"Stop hitting yourself!"* — That's what the 3-fix rule is for.

**When I finally ship:** ***HA-HA!*** 🥊

---

## 🚀 Quick Install (ONE COMMAND!)

**Add Nelson's memory system to ANY project:**

```bash
curl -fsSL https://raw.githubusercontent.com/Manny-Brar/NELSON-MUNTZ-PROTOCOL/main/install.sh | bash
```

That's it. Done. Memory system installed. **HA-HA!**

### What This Does:
- Creates `.nelson/` directory with all files
- Installs `better-sqlite3` for vector search
- Initializes the memory database
- Indexes ALL your `.md` files (CLAUDE.md, docs/, README.md)
- Sets up git hooks for auto re-indexing
- Creates template files for MEMORY.md and patterns
- **Auto-adds Nelson section to CLAUDE.md** (or creates one if missing)

### Options:
```bash
# Skip git hooks
curl -fsSL .../install.sh | bash -s -- --skip-hooks

# Force re-index everything
curl -fsSL .../install.sh | bash -s -- --force
```

---

## Installation (Claude Plugin)

For the development loop commands (`/nelson`, `/ha-ha`), also install as a Claude plugin:

### Step 1: Clone to Claude Plugins Directory

```bash
mkdir -p ~/.claude/plugins
cd ~/.claude/plugins
git clone https://github.com/Manny-Brar/NELSON-MUNTZ-PROTOCOL.git
```

### Step 2: Restart Claude Code

Close and reopen Claude Code (or VS Code with Claude extension) to load the plugin.

### Step 3: Verify Installation

In Claude Code, type:
```
/nelson-help
```

If you see the help menu, you're ready! 🎉

---

## How To Summon Me

**Want me to build something? Say the magic words:**
```bash
/nelson "Build a REST API with user authentication" --max-iterations 20
```

**Got something hard? Bring out the big guns — HA-HA Mode:**
```bash
/ha-ha "Build OAuth + JWT + MFA authentication system" --max-iterations 16
```

**Both formats work — shorthand or fully qualified:**
```bash
# Shorthand
/ha-ha "Complex task" --max-iterations 16

# Fully qualified (plugin-name:command-name)
/nelson-muntz:ha-ha "Complex task" --max-iterations 16
/nelson-muntz:nelson "Build REST API" --max-iterations 20
```

**Wanna see me work?**
```bash
/nelson-status
```

**Need me to stop? (wimp)**
```bash
/nelson-stop
```

---

## All Commands

| Command | Description |
|---------|-------------|
| `/nelson "prompt"` | Start loop in standard mode |
| `/ha-ha "prompt"` | Start loop in HA-HA (peak performance) mode |
| `/nelson-status` | Check current loop status |
| `/nelson-stop` | Stop running loop |
| `/help` | Show help documentation |

**Fully qualified format:** `/nelson-muntz:command-name "prompt" --options`

---

## All Options

| Option | Default | Description |
|--------|---------|-------------|
| `--max-iterations N` | 16 (max: 36) | Stop after N iterations (0 = unlimited) |
| `--completion-promise "TEXT"` | none | Stop when this text appears in output |
| `--model MODEL` | opus | Claude model to use |
| `--delay N` | 3 | Seconds to wait between iterations |
| `--background` | false | Run loop in background |
| `--ha-ha` | false | Enable HA-HA peak performance mode |
| `--parallel` | false | **v5.0:** Enable worktree-isolated parallel agents |

---

## Usage Examples

### Basic (Routine Tasks)
```bash
# Simple feature with safety limit
/nelson "Add a logout button to the navbar" --max-iterations 10
```

### With Completion Promise
```bash
# Stop when all tests pass
/nelson "Fix the authentication bug" --completion-promise "ALL TESTS PASS"
```

### Complex Tasks (HA-HA Mode)
```bash
# Full HA-HA mode for complex features
/ha-ha "Build multi-tenant calendar OAuth integration" --max-iterations 30
```

### Production-Critical
```bash
# Maximum safety for critical systems
/ha-ha "Refactor payment webhook handler" \
  --completion-promise "ALL TESTS PASS" \
  --max-iterations 40
```

### Background Mode
```bash
# Run in background, check progress later
/nelson "Update all API endpoints" --background --max-iterations 20

# Check progress anytime
/nelson-status
tail -f .claude/nelson-muntz.log
```

---

## When to Use What

| Situation | Command | Options |
|-----------|---------|---------|
| Simple bug fix | `/nelson` | `--max-iterations 10` |
| Routine feature | `/nelson` | `--max-iterations 20` |
| Complex feature | `/ha-ha` | `--max-iterations 30` |
| Critical system | `/ha-ha` | `--max-iterations 40 --completion-promise "..."` |
| Unfamiliar tech | `/ha-ha` | (HA-HA does mandatory pre-research) |
| Standard Nelson keeps failing | `/ha-ha` | (5-attempt escalation vs 3-fix rule) |

---

## Why Me?

Look, I'm the most feared kid at Springfield Elementary. When I laugh at your broken code, you KNOW it's broken.

But here's the thing — I only say **"HA-HA!"** when someone else fails. When YOUR code ships? That's MY victory. And I get to laugh at all the OTHER developers still stuck in context rot.

### How I Handle Problems

| Your Problem | What I Do |
|--------------|-----------|
| Context rot after 50k tokens | *"Smell you later!"* — I start fresh every time, dweeb |
| Scope creep sneaking in | I punch it. One feature. That's it. Don't get greedy. |
| Same bug appearing twice | *"Stop hitting yourself!"* — 3 strikes and I mark it blocked |
| Task too complicated | *"Aw, crud..."* — I break it into pieces and research each one |
| Feature actually ships | ***"HA-HA!"*** — Git commit, victory lap |

> *"I like to cry at the ocean, because only there do my tears seem small."*
>
> — Me, debugging production issues at 3am. What? I got layers.

---

## Why I'm Better Than Ralph Wiggum

Ralph's nice and all, but the kid eats paste. Here's why I'm the upgrade:

| Thing | Ralph Wiggum v1 | Nelson v4 | Me (Nelson v5) |
|-------|-----------------|-----------|----------------|
| Context | Same session | Fresh 200k + memory | Fresh 200k + **tiered L0/L1/L2 loading (87% less tokens)** |
| Thinking | Basic prompts | Ultrathink (4 levels) | **5-level ULTRATHINK** (incl. compound analysis) |
| Validation | One check | Two stages | **Three stages: spec + quality + adversarial red-team** |
| Failure handling | Tries forever | 3 strikes | 3 strikes (5 in HA-HA) + **auto-research between** |
| Git | Manual | Auto-commit | Auto-commit + **compound learning artifacts** |
| Focus | Gets distracted | ONE feature | ONE feature + **drift detection (circuit breaker at 7+)** |
| Memory | Forgets everything | Persistent + vector DB | Persistent + **Obsidian graph + GEPA consolidation** |
| Learning | None | Tracks patterns | **Compound engineering — each iteration makes next easier** |
| Agents | One only | One only | **Planner-Worker-Judge multi-agent with worktree isolation** |
| Model | Whatever | Opus 4.5 | **Opus 4.6.** The newest. The best. |

---

## Quick Start

```bash
# Start a development loop
/nelson "Build a REST API with authentication" \
  --max-iterations 30 \
  --completion-promise "ALL TESTS PASS"

# Monitor
/nelson-status
tail -f .claude/nelson-muntz.log

# Stop if needed
/nelson-stop
```

---

## How It Works

### The Loop (v5.1 Harness-Engineered)

```
┌─────────────────────────────────────────────────────────────┐
│              NELSON v5.1 HARNESS ENGINE                      │
│                                                              │
│   SCAFFOLDING (before first prompt):                        │
│   ├─ Tiered context loading (L0 → L1 → L2)                 │
│   ├─ Tool auto-detection (Obsidian, GWS, jq)               │
│   ├─ Edit tracker initialization (drift scoring)            │
│   └─ Identity + memory hydration                            │
│                                                              │
│   Iteration 1 (Initializer):                                │
│   ├─ 5-level ULTRATHINK planning                            │
│   ├─ Set up scaffolding                                     │
│   ├─ Decompose into features → features.json                │
│   ├─ Order features for compound value                      │
│   └─ Write handoff for iteration 2                          │
│                                                              │
│   Iteration 2+ (Executor):                                  │
│   ├─ BOOT: Tiered L0/L1/L2 context loading                 │
│   ├─ PLAN: 5-level ULTRATHINK                               │
│   ├─ WORK: Single-feature focus                             │
│   ├─ VERIFY: Three-stage validation                         │
│   │   ├─ Stage 1: Spec compliance                           │
│   │   ├─ Stage 2: Quality (tests/lint/build)                │
│   │   └─ Stage 3: Adversarial red-team review               │
│   ├─ COMPOUND: Extract pattern/anti-pattern                 │
│   ├─ Git checkpoint (if passes)                             │
│   ├─ DRIFT CHECK: Score 0-10, circuit break at 7+           │
│   └─ HANDOFF: Write with compound learning transfer         │
│                                                              │
│   Loop until:                                               │
│   ├─ All features complete (verification challenge)         │
│   ├─ Completion promise detected                            │
│   ├─ Max iterations reached                                 │
│   └─ Circuit breaker triggers fresh context                 │
└─────────────────────────────────────────────────────────────┘
```

### State Files

```
.claude/
├── nelson-loop.local.md           # Loop state (YAML + prompt)
├── nelson-handoff.local.md        # Iteration handoff
├── nelson-scratchpad.local.md     # Persistent notes
├── nelson-verification.local.md   # Validation results
├── nelson-edit-tracker.local.json # v5: Edit tracking for drift
└── nelson-debug.log               # Debug log
```

### Skills

```
skills/
├── nelson-protocol-v5.md       # v5 core: harness architecture, tiered loading
├── nelson-validate.md          # Two-stage validation (three-stage in HA-HA)
├── nelson-handoff.md           # Handoff document generation
├── nelson-decompose.md         # Feature decomposition
├── nelson-wall-breaker.md      # Auto-research on obstacles
├── nelson-compound-learning.md # v5: Each iteration makes next easier
├── nelson-drift-detection.md   # v5: Drift scoring + circuit breakers
├── nelson-self-evolving-eval.md# v5: GEPA-inspired skill evolution
├── nelson-integrations-v5.md   # v5: Obsidian + GWS integration
├── frontend-ui-ux.md           # Peak performance UI/UX design
└── database-supabase.md        # Postgres/Supabase with RLS
```

---

## Key Features

### 1. Fresh Context Every Iteration

No context rot. Each iteration gets a clean 200k token window:

```
Iteration 1: [Fresh 200k] → State files persist
Iteration 2: [Fresh 200k] → State files persist
Iteration N: [Fresh 200k] → State files persist
```

### 2. Ultrathink Protocol

Before ANY action:
1. Read ALL state files
2. "think hard" about current state
3. "ultrathink" about optimal approach
4. Document reasoning in scratchpad.md

### 3. Two-Stage Validation

**Stage 1 - Spec Compliance:**
```json
{
  "requirements": ["JWT auth", "Refresh tokens", "Tests"],
  "implemented": {
    "JWT auth": true,
    "Refresh tokens": true,
    "Tests": false
  },
  "spec_passes": false
}
```

**Stage 2 - Quality Check:**
```json
{
  "tests": {"pass": true, "count": 15, "failures": 0},
  "lint": {"pass": true, "errors": 0},
  "build": {"pass": true},
  "quality_passes": true
}
```

Feature passes ONLY when BOTH stages pass.

### 4. 3-Fix Rule

After 3 failed attempts on same feature:
1. Mark as "blocked"
2. Document why
3. Move to next feature

Prevents infinite loops on impossible problems.

### 5. Single-Feature Focus

**IRON RULE:** One feature per iteration.

- Select highest-priority incomplete feature
- Complete it fully OR mark as blocked
- Do NOT touch other features
- Do NOT "quickly fix" unrelated issues

### 6. Git Checkpointing

On feature completion:
```bash
git commit -m "feat(F1): User authentication - Nelson iter 5"
```

Automatic, clean commit history.

### 7. Clean State Gate

Cannot exit iteration with:
- Failing tests
- Lint errors
- Build failures
- Missing handoff

---

## Commands

| Command | Description |
|---------|-------------|
| `/nelson "prompt"` | Start new loop (standard mode) |
| `/ha-ha "prompt"` | Start new loop (HA-HA Peak Performance mode) |
| `/nelson-status` | Check status |
| `/nelson-stop` | Stop loop |
| `/nelson-resume` | Resume stopped loop |
| `/nelson-help` | Show help |

---

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `--max-iterations` | unlimited | Stop after N iterations |
| `--completion-promise` | none | Text signaling completion |
| `--model` | opus | Claude model |
| `--delay` | 3 | Seconds between iterations |
| `--background` | false | Run in background |
| `--ha-ha` | false | Enable HA-HA Mode (Peak Performance) |

---

## HA-HA Mode — When I Get Serious

Regular Nelson is tough. **HA-HA Mode** is when I take off the vest and actually try.

### Summon Maximum Power

```bash
/nelson "Complex authentication system" --ha-ha --max-iterations 50
# Or just yell it
/ha-ha "Build OAuth + JWT + MFA"
```

### What Changes When I Get Mad (v5.1)

| Regular Me | HA-HA Mode Me (v5.1) |
|------------|----------------------|
| Work on features one at a time | **Phase-Gate Engine: decompose → 4-gate cycle per phase** |
| Think before punching | Think **5 different ways** including compound analysis |
| Research after failing twice | Research BEFORE I even start |
| 3 strikes you're out | 5 attempts with research between each |
| Two-stage validation | **Three-stage: spec + quality + I RED-TEAM MY OWN CODE** |
| Remember patterns | **Compound learning — each punch makes the next one stronger** |
| No drift awareness | **Drift score 0-10, circuit breaker at 7+** |
| Ad-hoc docs | **Mandatory doc gate: ALL docs, cross-references** |
| One agent | **Planner-Worker-Judge-Scout multi-agent** (with `--parallel`) |

### HA-HA Mode Protocol Stack (v5.1)

```
┌─────────────────────────────────────────────────────────────────┐
│  PHASE 0: STRATEGIC DECOMPOSITION + BOOT                         │
│  Decompose request into phases (ULTRATHINK) → Self-assess plan  │
│  Tiered L0/L1/L2 loading, tool detection, identity              │
├─────────────────────────────────────────────────────────────────┤
│  PER-PHASE GATE CYCLE (repeats for each phase):                  │
│    Gate A: EXECUTE all tasks                                     │
│    Gate B: SELF-ASSESS (research best practices, fix gaps)       │
│    Gate C: TEST (all tests pass before advancing)                │
│    Gate D: DOCUMENT (ALL affected docs + cross-references)       │
├─────────────────────────────────────────────────────────────────┤
│  WITHIN EACH PHASE, these protocols are available:               │
├─────────────────────────────────────────────────────────────────┤
│  PRE-FLIGHT RESEARCH                                             │
│  Search best practices, documentation, patterns BEFORE coding   │
├─────────────────────────────────────────────────────────────────┤
│  MULTI-DIMENSIONAL THINKING (5 LEVELS)                           │
│  Standard → Deep → Adversarial → Meta → Compound Analysis       │
├─────────────────────────────────────────────────────────────────┤
│  WALL-BREAKER PROTOCOL                                           │
│  Auto web search on ANY obstacle                                │
├─────────────────────────────────────────────────────────────────┤
│  THREE-STAGE VALIDATION                                          │
│  Spec + quality + adversarial red-team review                   │
├─────────────────────────────────────────────────────────────────┤
│  COMPOUND LEARNING                                               │
│  Extract pattern/anti-pattern, refine skills (GEPA-inspired)    │
├─────────────────────────────────────────────────────────────────┤
│  DRIFT DETECTION                                                 │
│  Score 0-10, circuit breaker at 7+, fresh context recovery      │
├─────────────────────────────────────────────────────────────────┤
│  PHASE 8: SELF-REFLECTION CHECKPOINTS                            │
│  Stop and verify at key decision points                         │
├─────────────────────────────────────────────────────────────────┤
│  PHASE 9: NO-SURRENDER PERSISTENCE                               │
│  5-attempt escalation, never retry without new info             │
└─────────────────────────────────────────────────────────────────┘
```

### Wall-Breaker — When I Hit A Wall, I Break It

Some wimpy agents just give up when they hit a problem. Not me.

```
🔴 ERROR WALL      → I search what the heck that error means
🟠 KNOWLEDGE WALL  → I look up how to do it (yeah, I can Google)
🟡 DESIGN WALL     → I compare approaches like a responsible adult
🟢 DEPENDENCY WALL → I find alternatives or mark it blocked
🔵 COMPLEXITY WALL → I break it into smaller pieces and beat each one up
```

Everything I find goes in `scratchpad.md` so future me ain't starting from zero.

### When To Use Which Version of Me

**Bring out HA-HA Mode when:**
- The task is actually hard
- You don't know the tech
- It's important and can't break
- Regular me keeps failing (fine, I'll admit it happens)

**Regular me is fine for:**
- Easy stuff
- Stuff you've done before
- Boring routine work

---

## Where I Learned This Stuff

Yeah I can read. Stole the best ideas from these nerds:

**v5.1 Sources (the real smart stuff):**
- **[Anthropic Harness Engineering](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)** — The harness paper that changed everything
- **[Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)** — "Find the smallest set of high-signal tokens"
- **[GEPA (ICLR 2026)](https://arxiv.org/abs/2507.19457)** — Reflective prompt evolution. Self-improving skills. Big brain stuff.
- **[Compound Engineering](https://every.to/guides/compound-engineering)** — "Each unit of work makes the next easier"
- **[OpenViking L0/L1/L2](https://github.com/volcengine/OpenViking)** — Tiered context loading. 80% token savings. Yeah.
- **[Factory AI Signals](https://factory.ai/news/factory-signals)** — Self-improving agent architecture

**OG Sources (where this all started):**
- **[GSD (Get Shit Done)](https://github.com/kogumauk/get-shit-done-plus)** — Fresh context, task management
- **[Multi-Agent Ralph](https://github.com/alfredolopez80/multi-agent-ralph-loop)** — Ultrathink, two-stage review
- **[Ralph Orchestrator](https://github.com/mikeyobrien/ralph-orchestrator)** — Git checkpoints, scratchpad
- **[Original Ralph](https://ghuntley.com/ralph/)** — Geoffrey Huntley started it. I finished it. HA-HA!

---
## My Rules (Don't Break 'Em)

Yeah, I'm *"a riddle wrapped in an enigma wrapped in a vest."* But my rules ain't complicated:

1. **The Harness Is the Hard Part** — I'm not just an agent. I'm an engineered system. Respect the harness.
2. **Fresh Context > Old Garbage** — *"Smell you later!"* to whatever you remember from 10 hours ago
3. **Think First > Punch First** — Five levels of thinking before I swing. FIVE.
4. **One Problem > Many Problems** — Beat up ONE thing at a time. Don't be greedy.
5. **Prove It Three Ways** — *"Stop hitting yourself!"* — spec check, quality check, AND red-team review
6. **Compound > Repeat** — Each punch makes the next punch stronger. That's compound learning.
7. **Detect Drift > Fight Drift** — When I'm getting dumb, I stop and get a fresh context. Smart.
8. **Clean Handoff > Giant Brain Dump** — Next iteration should know exactly where to swing

---

## License

MIT

---

## HA-HA!

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
         The Agent Isn't the Hard Part.
              The Harness Is.

      "Others try. We triumph. HA-HA!" 🥊
```

---

## ⚡ v5.1: Harness Engineering + Phase-Gate Execution

**What's the big deal?** I'm not just an agent anymore. I'm a **harness-engineered system** with a **Phase-Gate Execution Engine**. Every request in HA-HA mode gets strategically decomposed into phases, each with mandatory Execute → Self-Assess → Test → Document gates.

> *"The same model can swing from 42% to 78% success based solely on the surrounding harness."*
> — Yeah, that's me with the harness on. HA-HA!

### The Phase-Gate Engine (v5.1)

Every HA-HA mode request automatically runs through this:

```
1. DECOMPOSE request into strategic multi-phase plan (5-level ULTRATHINK)
2. SELF-ASSESS the plan (gaps, risks, enhancements) → revise
3. FOR EACH PHASE:
   A. EXECUTE all tasks in the phase
   B. SELF-ASSESS critically (research best practices, identify gaps/improvements)
   C. TEST everything (all tests must pass before advancing)
   D. DOCUMENT all changes (ALL affected docs, cross-references)
   → Phase gate must pass before next phase begins
```

No phase advances without passing all 4 gates. No exceptions.

### What's New (v4 → v5.1)

| v4.0 | v5.1 |
|------|------|
| Work on features one at a time | **Phase-Gate Engine: strategic multi-phase decomposition** |
| Load all context at startup | **Tiered L0/L1/L2 loading (87% less tokens!)** |
| 4-level ULTRATHINK | **5-level ULTRATHINK (+ compound analysis)** |
| Two-stage validation | **Three-stage: spec + quality + adversarial red-team review** |
| Pattern recognition | **Compound learning engine (each iteration easier)** |
| No drift awareness | **Drift detection + circuit breaker at score 7+** |
| Single agent | **Planner-Worker-Judge-Scout multi-agent with worktrees** |
| Flat file search | **Obsidian graph memory + GWS workspace (optional)** |
| Static skills | **Self-evolving skills (GEPA-inspired)** |
| No structured doc process | **Mandatory doc gate with cross-reference awareness** |

---

## 🧠 Memory & Intelligence System

I remember stuff across sessions. And in v5.1, my memory is **tiered, graph-relational, and self-consolidating.**

### Memory Components

```
.nelson/
├── NELSON_SOUL.md          # Identity (loaded at L0 every session)
├── MEMORY.md               # Long-term knowledge (loaded at L0, first 40 lines)
├── context-loader.md       # Tiered L0/L1/L2 retrieval protocol
├── memory.db               # SQLite + FTS5 vector search
├── obsidian-bridge.cjs     # Obsidian vault bridge (optional)
├── consolidate.cjs         # GEPA-inspired memory consolidation
├── memory/
│   └── YYYY-MM-DD.md       # Daily session logs
└── patterns/
    ├── successes.md         # Patterns that work
    └── failures.md          # Anti-patterns to avoid
```

### Tiered Loading (87% Token Savings)

```
L0 (~300 tokens):  Handoff, loop state, identity core, memory index — ALWAYS
L1 (~2K tokens):   Task-relevant search, recent scratchpad — SELECTIVE
L2 (variable):     Full skill files, full docs — ON-DEMAND at trigger points
```

### 5-Level ULTRATHINK

```
Level 1 - Standard:    "What needs to happen?"
Level 2 - Deep:        "What are the edge cases?"
Level 3 - Adversarial: "What could go wrong?"
Level 4 - Meta:        "Is this even the right approach?"
Level 5 - Compound:    "How does this make my NEXT punch stronger?"
```

### Three-Stage Validation

| Stage | What | Fails When |
|-------|------|-----------|
| 1. Spec | All requirements implemented? | Any requirement missing |
| 2. Quality | Tests/lint/build/types pass? | Any check fails |
| 3. Red-Team | How would I break this? | CRITICAL security finding |

### The v5.1 Oath

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

## 📖 Comprehensive Usage Guide

Want the full details? Check out **[NELSON_PROTOCOL_GUIDE.md](NELSON_PROTOCOL_GUIDE.md)** — covers:

- **Session Lifecycle** — Startup, ULTRATHINK cycle, session end
- **Memory System** — What goes where, search commands, indexing
- **Token Optimization** — On-demand retrieval, compressed CLAUDE.md
- **Tool Discovery** — MCP/skill indexing and recommendations
- **Best Practices** — 5 key practices for maximum effectiveness
- **Command Reference** — Every command in one place
- **Troubleshooting** — Common issues and fixes

*That document is the nerd version. This README is for people who like to punch first.*

---

*Now go beat up some bugs. Smell you later!*
