---
description: "Nelson Muntz plugin help and documentation"
---

# Nelson Muntz v3.3.1 - Peak Performance Development Loop

**HA-HA!** Welcome to Nelson Muntz with AGGRESSIVE VALIDATION.

## What Is This?

Nelson Muntz is an **in-session AI development loop** that:
- Uses **Stop hooks** to intercept exit and continue automatically
- Enforces **mandatory 4-phase protocol** (Plan → Work → Verify → Handoff)
- Implements **aggressive verification challenge** on completion claims
- Enforces **single-feature focus** per iteration
- Provides **strict content validation** (not just section checks)
- Creates **git checkpoints** on feature completion

## Why "Nelson Muntz"?

Named after the bully from The Simpsons who says "HA-HA!" The HA-HA comes when we **succeed** after conquering problems through persistent iteration!

---

## Commands

| Command | Description |
|---------|-------------|
| `/nelson "prompt"` | Start a development loop (standard mode) |
| `/ha-ha "prompt"` | Start in HA-HA Mode (Peak Performance) |
| `/nelson-status` | Check loop status |
| `/nelson-stop` | Stop running loop |

---

## Quick Start

```bash
# Start a development loop
/nelson "Build a REST API with user authentication" \
  --max-iterations 30 \
  --completion-promise "ALL TESTS PASS"

# Monitor progress
/nelson-status
cat .claude/nelson-handoff.local.md

# Stop if needed
/nelson-stop
```

---

## How It Works (In-Session Hooks)

```
1. /nelson or /ha-ha creates state files
2. You work following the 4-phase protocol
3. When you try to exit, Stop hook intercepts
4. If not complete: Hook feeds prompt back
5. If completion claimed: VERIFICATION CHALLENGE triggered
6. If verification passes: Loop exits
```

### State Files

```
.claude/
├── nelson-loop.local.md        # YAML frontmatter + prompt
├── nelson-handoff.local.md     # REQUIRED - updated every iteration
├── nelson-scratchpad.local.md  # Optional planning notes
└── nelson-verification.local.md # Created during verification
```

---

## The 4-Phase Protocol (MANDATORY)

Every iteration follows this:

```
PHASE 1: PLAN
├─ Read handoff: cat .claude/nelson-handoff.local.md
├─ Think hard about current state
├─ Select ONE feature to complete
└─ Write plan to scratchpad

PHASE 2: WORK
├─ Implement the ONE selected feature
├─ Do NOT touch other features
└─ Commit working code

PHASE 3: VERIFY
├─ Stage 1: Spec Check - matches requirements?
├─ Stage 2: Quality Check - tests pass? build works?
└─ BOTH stages must pass!

PHASE 4: HANDOFF
├─ Update .claude/nelson-handoff.local.md
└─ What was completed, what's pending, next steps
```

---

## Verification Challenge (v3.3.1)

When you claim completion with `<nelson-complete>ALL_FEATURES_COMPLETE</nelson-complete>`:

**Hook does NOT just exit.** It triggers a VERIFICATION CHALLENGE:

1. **RUN TESTS** - Actually run them, paste real output
2. **BUILD CHECK** - Run build, confirm success
3. **EDGE CASE AUDIT** - List 3+ edge cases handled
4. **SELF-REVIEW** - Weakness, criticism, debt, TODOs
5. **WRITE VERIFICATION FILE** - Create .claude/nelson-verification.local.md

Then output: `<nelson-verified>VERIFICATION_COMPLETE</nelson-verified>`

### Strict Content Validation

The hook validates **content quality**:

| Section | Validation |
|---------|------------|
| `## Tests` | Must contain pass/fail keywords or test counts |
| `## Build` | Must contain "success/pass/complete" |
| `## Edge Cases` | Must have 3+ numbered/bulleted items |
| `## Self-Review` | Must mention weakness/criticism/debt/todos |
| `## Git Status` | Must exist |

**Weak verification?** REJECTED with specific failures. Fix and resubmit!

---

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `--max-iterations N` | unlimited | Stop after N iterations |
| `--completion-promise "TEXT"` | none | Stop when TEXT in `<promise>` tags |
| `--ha-ha` | false | Enable HA-HA Mode |

---

## HA-HA Mode - Peak Performance

**HA-HA Mode** adds extra protocols:

| Standard | HA-HA Mode |
|----------|------------|
| Ultrathink | Multi-dimensional thinking (4 levels) |
| Research on failure | Pre-research MANDATORY |
| 3-fix rule | 5-attempt escalation |
| Basic validation | Aggressive validation + self-review |

### HA-HA Mode Extras

1. **Pre-Flight Research** - Search best practices BEFORE coding
2. **Wall-Breaker Protocol** - Auto web search on ANY obstacle
3. **No-Surrender Persistence** - 5 attempts with research between

```bash
# Start HA-HA mode
/ha-ha "Build OAuth + JWT + MFA auth system"
```

---

## Completion Signals

The loop stops when:
1. `<nelson-verified>VERIFICATION_COMPLETE</nelson-verified>` after passing verification
2. `<promise>YOUR_PROMISE</promise>` after verification (if promise set)
3. Max iterations reached
4. Loop manually stopped with `/nelson-stop`

**Note:** `<nelson-complete>` triggers verification, doesn't exit!

---

## Monitoring

```bash
# Check status
/nelson-status

# View state file
cat .claude/nelson-loop.local.md

# View handoff
cat .claude/nelson-handoff.local.md

# Check if active
test -f .claude/nelson-loop.local.md && echo "ACTIVE" || echo "NOT ACTIVE"
```

---

## Philosophy

1. **Fresh Context > Accumulated Garbage** - Start clean each iteration
2. **Ultrathink > Quick Action** - Plan before executing
3. **Single Focus > Multitasking** - One feature at a time
4. **Prove It > Trust Me** - Verification required
5. **Clean Handoff > Giant Brain Dump** - Next iteration needs context

---

## HA-HA!

```
   ███╗   ██╗███████╗██╗     ███████╗ ██████╗ ███╗   ██╗
   ████╗  ██║██╔════╝██║     ██╔════╝██╔═══██╗████╗  ██║
   ██╔██╗ ██║█████╗  ██║     ███████╗██║   ██║██╔██╗ ██║
   ██║╚██╗██║██╔══╝  ██║     ╚════██║██║   ██║██║╚██╗██║
   ██║ ╚████║███████╗███████╗███████║╚██████╔╝██║ ╚████║
   ╚═╝  ╚═══╝╚══════╝╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝

                    MUNTZ v3.3.1
      STRICT CONTENT VALIDATION + REJECTION LOOP

      "Others try. We triumph. HA-HA!"
```
