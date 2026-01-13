# Nelson Muntz Protocol

![Nelson Muntz Banner](NELSON_MUNTZ.gif)

**Peak Performance AI Development Loop** - Fresh context every iteration. No more context rot.

![Nelson Muntz Protocol](NELSON_MUNTZ_2.png)

---

## Installation (3 Steps)

### Step 1: Clone to Claude Plugins Directory

```bash
# Create plugins directory if it doesn't exist
mkdir -p ~/.claude/plugins

# Clone the repo
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

## Simple Usage

**Start a development loop:**
```bash
/nelson "Build a REST API with user authentication"
```

**For complex tasks, use HA-HA Mode:**
```bash
/ha-ha "Build OAuth + JWT + MFA authentication system"
```

**Check progress:**
```bash
/nelson-status
```

**Stop the loop:**
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
| `/nelson-resume` | Resume a stopped loop |
| `/nelson-help` | Show help documentation |

---

## All Options

| Option | Default | Description |
|--------|---------|-------------|
| `--max-iterations N` | unlimited | Stop after N iterations (safety limit) |
| `--completion-promise "TEXT"` | none | Stop when this text appears in output |
| `--model MODEL` | claude-opus-4-5-20250514 | Claude model to use |
| `--delay N` | 3 | Seconds to wait between iterations |
| `--background` | false | Run loop in background |
| `--ha-ha` | false | Enable HA-HA peak performance mode |

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

## Why Nelson Muntz?

Named after the bully from The Simpsons who says "HA-HA!" - but here the HA-HA comes when we **succeed**, because we've conquered the problem through persistent iteration!

---

## Key Innovations Over Ralph Wiggum

| Feature | Ralph Wiggum v1 | Nelson Muntz v3 |
|---------|-----------------|-----------------|
| Context | Same session (rots) | Fresh 200k each iteration |
| Thinking | Basic prompts | Ultrathink protocol |
| Validation | Single check | Two-stage (spec + quality) |
| Failure handling | Infinite retry | 3-fix rule |
| Git | Manual | Auto-checkpoint on feature |
| Focus | Prone to scope creep | Single-feature enforced |
| State | Minimal | Full tracking system |
| Model | Any | Opus 4.5 default |

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

### The Loop

```
┌─────────────────────────────────────────────────────────────┐
│                    External Bash Loop                        │
│                                                              │
│   Iteration 1 (Initializer):                                │
│   ├─ Read handoff (original prompt)                         │
│   ├─ Engage ultrathink                                      │
│   ├─ Set up scaffolding                                     │
│   ├─ Decompose into features → features.json                │
│   ├─ Create init.sh                                         │
│   └─ Write handoff for iteration 2                          │
│                                                              │
│   Iteration 2+ (Executor):                                  │
│   ├─ Run init.sh                                            │
│   ├─ Read handoff (context from previous)                   │
│   ├─ Engage ultrathink                                      │
│   ├─ Select ONE feature                                     │
│   ├─ Implement feature                                      │
│   ├─ Two-stage validation                                   │
│   │   ├─ Stage 1: Spec compliance                           │
│   │   └─ Stage 2: Quality (tests/lint/build)                │
│   ├─ Git checkpoint (if passes)                             │
│   ├─ Update features.json                                   │
│   └─ Write handoff for next iteration                       │
│                                                              │
│   Loop until:                                               │
│   ├─ All features complete                                  │
│   ├─ Completion promise detected                            │
│   └─ Max iterations reached                                 │
└─────────────────────────────────────────────────────────────┘
```

### State Files

```
.claude/ralph-v3/
├── config.json         # Loop configuration and stats
├── features.json       # Structured feature list
├── scratchpad.md       # Debug notes (cumulative)
├── progress.md         # Iteration log (append-only)
├── handoff.md          # Context for next iteration
├── init.sh             # Project init script
└── validation/
    ├── spec-check.json     # Requirements tracking
    └── quality-check.json  # Test/lint/build results
```

### Skills

```
skills/
├── nelson-validate.md      # Two-stage validation protocol
├── nelson-handoff.md       # Handoff document generation
├── nelson-decompose.md     # Feature decomposition
├── nelson-wall-breaker.md  # Auto-research on obstacles
├── frontend-ui-ux.md       # Peak performance UI/UX design
└── database-supabase.md    # Postgres/Supabase with RLS
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
| `--model` | claude-opus-4-5-20250514 | Claude model |
| `--delay` | 3 | Seconds between iterations |
| `--background` | false | Run in background |
| `--ha-ha` | false | Enable HA-HA Mode (Peak Performance) |

---

## HA-HA Mode - Peak Performance

**HA-HA Mode** is the ultimate configuration that activates every enhancement simultaneously.

### Enable HA-HA Mode

```bash
/nelson "Complex authentication system" --ha-ha --max-iterations 50
# Or use the dedicated command
/ha-ha "Build OAuth + JWT + MFA"
```

### What HA-HA Mode Adds

| Standard Nelson | HA-HA Mode |
|-----------------|------------|
| Ultrathink | Multi-dimensional thinking (4 levels) |
| Research on 2nd failure | Pre-research MANDATORY |
| 3-fix rule | 5-attempt escalation with research |
| Single validation | Aggressive validation + self-review |
| Basic pattern tracking | Full pattern library |
| Standard handoff | Comprehensive iteration reports |

### HA-HA Mode Protocol Stack

```
┌─────────────────────────────────────────────────────────────────┐
│  PHASE 0: PRE-FLIGHT RESEARCH                                   │
│  Search best practices, documentation, patterns BEFORE coding   │
├─────────────────────────────────────────────────────────────────┤
│  PHASE 1: MULTI-DIMENSIONAL THINKING                            │
│  4 levels of ultrathink including adversarial & meta            │
├─────────────────────────────────────────────────────────────────┤
│  PHASE 2: PARALLEL EXPLORATION                                  │
│  Evaluate multiple approaches before committing                 │
├─────────────────────────────────────────────────────────────────┤
│  PHASE 3: WALL-BREAKER PROTOCOL                                 │
│  Auto web search on ANY obstacle                                │
├─────────────────────────────────────────────────────────────────┤
│  PHASE 4: AGGRESSIVE VALIDATION                                 │
│  Pre, incremental, and post validation + self-review            │
├─────────────────────────────────────────────────────────────────┤
│  PHASE 5: SELF-REFLECTION CHECKPOINTS                           │
│  Stop and verify at key decision points                         │
├─────────────────────────────────────────────────────────────────┤
│  PHASE 6: PATTERN RECOGNITION                                   │
│  Learn from previous iterations, build pattern library          │
├─────────────────────────────────────────────────────────────────┤
│  PHASE 7: NO-SURRENDER PERSISTENCE                              │
│  5-attempt escalation, never retry without new info             │
└─────────────────────────────────────────────────────────────────┘
```

### Wall-Breaker Auto-Research

When Nelson hits ANY wall in HA-HA Mode:

```
🔴 ERROR WALL      → Search error message + solutions
🟠 KNOWLEDGE WALL  → Search tutorials + documentation
🟡 DESIGN WALL     → Search approach comparisons
🟢 DEPENDENCY WALL → Search alternatives
🔵 COMPLEXITY WALL → Decompose + research sub-problems
```

All research is documented in `scratchpad.md` for future iterations.

### When to Use HA-HA Mode

**Use HA-HA Mode for:**
- Complex, multi-component features
- Unfamiliar technologies
- Critical system components
- When standard Nelson keeps failing

**Standard Nelson is fine for:**
- Simple bug fixes
- Well-understood patterns
- Routine implementations

---

## Research Sources

This implementation synthesizes best practices from:

- **[GSD (Get Shit Done)](https://github.com/kogumauk/get-shit-done-plus)** - Hierarchical docs, XML tasks, fresh context per task
- **[Multi-Agent Ralph](https://github.com/alfredolopez80/multi-agent-ralph-loop)** - Ultrathink, two-stage review, 3-fix rule
- **[Ralph Orchestrator](https://github.com/mikeyobrien/ralph-orchestrator)** - Token tracking, git checkpointing, scratchpad
- **[Anthropic Harness](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)** - Initializer/executor split, JSON features
- **[Original Ralph](https://ghuntley.com/ralph/)** - The foundational technique by Geoffrey Huntley

---

## Philosophy

1. **Fresh Context > Accumulated Garbage**
2. **Ultrathink > Quick Action**
3. **Single Focus > Multitasking**
4. **Validation > Assumption**
5. **Persistence > Perfection**
6. **Clean Handoff > Complete History**

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

                    MUNTZ v3.0
         Peak Performance Development Loop
```
