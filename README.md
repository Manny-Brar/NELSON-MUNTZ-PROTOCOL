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

## Installation (2 Commands)

**Using Claude's official plugin system** *(recommended)*:

```bash
# Step 1: Add my marketplace
claude plugin marketplace add https://github.com/Manny-Brar/NELSON-MUNTZ-PROTOCOL

# Step 2: Install me
claude plugin install nelson-muntz@nelson-muntz-marketplace
```

Then restart Claude Code. That's it. Don't make it complicated.

### Verify I'm Here

In Claude Code, type:
```
/nelson-muntz:help
```

If you see the help menu, I'm ready to beat up your bugs. 🥊

### Uninstall (If You're A Quitter)

```bash
claude plugin uninstall nelson-muntz@nelson-muntz-marketplace
claude plugin marketplace remove nelson-muntz-marketplace
```

### Update Me

```bash
claude plugin update nelson-muntz@nelson-muntz-marketplace
```

---

## How To Summon Me

**Want me to build something? Say the magic words:**
```bash
/nelson "Build a REST API with user authentication"
```

**Got something hard? Bring out the big guns — HA-HA Mode:**
```bash
/ha-ha "Build OAuth + JWT + MFA authentication system"
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

**Natural Language:** Just say "use ha-ha mode" or "activate ha-ha mode" and I'll start up.

---

## All Options

| Option | Default | Description |
|--------|---------|-------------|
| `--max-iterations N` | unlimited | Stop after N iterations (safety limit) |
| `--completion-promise "TEXT"` | none | Stop when this text appears in `<promise>` tags |
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

### Monitor Progress
```bash
# Check loop status
/nelson-status

# View state file
cat .claude/nelson-loop.local.md

# View handoff
cat .claude/nelson-handoff.local.md
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

| Thing | Ralph Wiggum v2 | Me (Nelson v3.3) |
|-------|-----------------|------------------|
| Architecture | Same in-session hooks | Same, but with STRUCTURE |
| Planning | Optional | MANDATORY. Phase 1, every time. |
| Validation | One check | Two stages. Spec AND quality. Both must pass. |
| Handoff | Optional notes | REQUIRED. Loop warns if not updated! |
| Protocol | Loose guidelines | 4-phase mandatory protocol |
| Failure handling | Tries forever (dumb) | 3 strikes (5 in HA-HA), you're blocked |
| Focus | Gets distracted | ONE feature. Period. |
| Quality Gates | Trust-based | **AGGRESSIVE VERIFICATION CHALLENGE** |
| Completion | Just say you're done | **Must pass tests, build, self-review, edge cases** |
| Exit Gate | None | Verification file required with proof |

---

## Quick Start

```bash
# Start a development loop
/nelson "Build a REST API with authentication" \
  --max-iterations 30 \
  --completion-promise "ALL TESTS PASS"

# Monitor progress
/nelson-status
cat .claude/nelson-handoff.local.md

# Stop if needed
/nelson-stop
```

---

## How It Works (v3.3 - Aggressive Validation)

### Architecture Change

**v3.0 used external CLI loops.** That's old news.

**v3.2 uses in-session Stop hooks.** Works in VS Code extension. No external bash loops needed.

```
Old Way (v3.0):  claude --print spawns → external bash loop → spawns again
New Way (v3.2):  Stop hook intercepts exit → feeds prompt back → same session
```

### The Structured Iteration Protocol

Every iteration follows a **mandatory 4-phase protocol**. No shortcuts.

```
┌─────────────────────────────────────────────────────────────┐
│              ITERATION PROTOCOL (MANDATORY)                  │
│                                                              │
│   PHASE 1: PLAN (Start of every iteration)                  │
│   ├─ Read handoff: cat .claude/nelson-handoff.local.md      │
│   ├─ Think hard about current state                         │
│   ├─ Select ONE feature to complete this iteration          │
│   └─ Write plan to .claude/nelson-scratchpad.local.md       │
│                                                              │
│   PHASE 2: WORK (Single-feature focus)                      │
│   ├─ Implement the ONE selected feature                     │
│   ├─ Do NOT touch other features                            │
│   └─ Commit working code                                    │
│                                                              │
│   PHASE 3: VERIFY (Before claiming completion)              │
│   ├─ Stage 1: Spec Check - Does it match requirements?      │
│   ├─ Stage 2: Quality Check - Tests pass? Build works?      │
│   └─ BOTH stages must pass!                                 │
│                                                              │
│   PHASE 4: HANDOFF (Before every exit)                      │
│   ├─ Update .claude/nelson-handoff.local.md                 │
│   ├─ What was completed, what's pending, next steps         │
│   └─ Loop warns if handoff not updated!                     │
└─────────────────────────────────────────────────────────────┘
```

### The Loop Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    In-Session Loop                           │
│                                                              │
│   1. /nelson or /ha-ha starts loop                          │
│      ├─ Creates state file: .claude/nelson-loop.local.md    │
│      ├─ Creates handoff: .claude/nelson-handoff.local.md    │
│      ├─ Outputs prompt with protocol instructions           │
│      └─ Activates stop hook                                  │
│                                                              │
│   2. Follow the 4-phase protocol                            │
│      ├─ PLAN: Read handoff, select ONE task                 │
│      ├─ WORK: Implement with focus                          │
│      ├─ VERIFY: Two-stage validation                        │
│      └─ HANDOFF: Update handoff file                        │
│                                                              │
│   3. Try to exit (natural session end)                       │
│      ├─ Stop hook intercepts                                 │
│      ├─ Checks if handoff was updated                       │
│      ├─ Checks completion conditions                         │
│      └─ If not complete: feeds prompt back with warning     │
│                                                              │
│   4. Loop continues until:                                   │
│      ├─ <nelson-complete>ALL_FEATURES_COMPLETE</nelson-complete>  │
│      ├─ <promise>YOUR_PROMISE</promise> detected             │
│      └─ Max iterations reached                               │
│                                                              │
│   5. Loop complete                                           │
│      ├─ Hook allows exit                                     │
│      ├─ State files removed                                  │
│      └─ HA-HA!                                               │
└─────────────────────────────────────────────────────────────┘
```

### State Files

```
.claude/
├── nelson-loop.local.md      # YAML frontmatter + prompt
├── nelson-handoff.local.md   # REQUIRED - updated every iteration
└── nelson-scratchpad.local.md # Optional planning notes
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

### 8. VERIFICATION CHALLENGE (v3.3.0 - THE BIG ONE)

**You think you're done? PROVE IT.**

When you claim completion (`<nelson-complete>ALL_FEATURES_COMPLETE</nelson-complete>`), I don't just let you go. I throw a **VERIFICATION CHALLENGE** at you:

```
🔴 VERIFICATION CHALLENGE - ITERATION N

You claimed completion, but Nelson doesn't trust easily. HA-HA!

MANDATORY VERIFICATION STEPS:

1. RUN TESTS (Required)
   - Actually run npm test (or your test command)
   - Paste the real output
   - All tests must PASS

2. BUILD CHECK (Required)
   - Run npm run build
   - Must succeed without errors

3. EDGE CASE AUDIT (Required)
   - List 3+ edge cases you considered
   - How did you handle each one?

4. SELF-REVIEW CRITIQUE (Required)
   - What's the weakest part?
   - What would a senior engineer criticize?
   - Any tech debt introduced?
   - Any TODO comments left behind?

5. WRITE VERIFICATION FILE
   - Create .claude/nelson-verification.local.md
   - Include proof for all sections above
```

**Only THEN can you output:**
```
<nelson-verified>VERIFICATION_COMPLETE</nelson-verified>
```

**The hook checks the verification file for:**
- `## Tests` section (with actual output)
- `## Edge Cases` section (with 3+ cases)
- `## Self-Review` section (honest assessment)

**No proof = No exit.** HA-HA!

This prevents:
- Claiming done when tests fail
- Skipping edge case consideration
- Avoiding self-review
- Leaving uncommitted changes

---

## Commands

| Command | Description |
|---------|-------------|
| `/nelson "prompt"` | Start loop (standard mode) |
| `/ha-ha "prompt"` | Start loop (HA-HA Peak Performance mode) |
| `/nelson-status` | Check status |
| `/nelson-stop` | Stop loop |

---

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `--max-iterations N` | unlimited | Stop after N iterations |
| `--completion-promise "TEXT"` | none | Stop when TEXT in `<promise>` tags |
| `--ha-ha` | false | Enable HA-HA Mode |

---

## HA-HA Mode — When I Get Serious

Regular Nelson is tough. **HA-HA Mode** is when I take off the vest and actually try.

### Summon Maximum Power

```bash
/nelson "Complex authentication system" --ha-ha --max-iterations 50
# Or just yell it
/ha-ha "Build OAuth + JWT + MFA"
```

### What Changes When I Get Mad

| Regular Me | HA-HA Mode Me |
|------------|---------------|
| Think before punching | Think 4 different ways before punching |
| Research after failing twice | Research BEFORE I even start |
| 3 strikes you're out | 5 attempts with research between each |
| One validation check | Aggressive checking + I review my own work |
| Remember patterns | Full pattern library like a nerd |
| Normal handoff | Detailed report so next iteration is armed |

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

- **[GSD (Get Shit Done)](https://github.com/kogumauk/get-shit-done-plus)** - Fresh context, task management
- **[Multi-Agent Ralph](https://github.com/alfredolopez80/multi-agent-ralph-loop)** - Ultrathink, two-stage review
- **[Ralph Orchestrator](https://github.com/mikeyobrien/ralph-orchestrator)** - Git checkpoints, scratchpad
- **[Anthropic Harness](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)** - The smart people at Anthropic figured out the pattern
- **[Original Ralph](https://ghuntley.com/ralph/)** - Geoffrey Huntley started it. I finished it.

---

## My Rules (Don't Break 'Em)

Yeah, I'm *"a riddle wrapped in an enigma wrapped in a vest."* But my rules ain't complicated:

1. **Fresh Context > Old Garbage** — *"Smell you later!"* to whatever you remember from 10 hours ago
2. **Think First > Punch First** — Even I know you gotta plan before you swing
3. **One Problem > Many Problems** — Beat up ONE thing at a time. Don't be greedy.
4. **Prove It > Trust Me Bro** — *"Stop hitting yourself!"* — run the tests
5. **Keep Punching > Give Up** — Persistence beats talent. I would know.
6. **Clean Handoff > Giant Brain Dump** — Next iteration should know exactly where to swing

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

                    MUNTZ v3.3
       AGGRESSIVE VALIDATION + VERIFICATION CHALLENGE

      "Others try. We triumph. HA-HA!" 🥊
```

---

*Now go beat up some bugs. Smell you later!*
