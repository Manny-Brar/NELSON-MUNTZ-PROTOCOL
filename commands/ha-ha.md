---
description: "Activate HA-HA Mode - Peak Performance Development Loop"
argument-hint: "PROMPT [--max-iterations N] [--completion-promise TEXT]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-nelson-loop.sh:*)"]
hide-from-slash-command-tool: "true"
---

# Nelson Muntz - HA-HA Mode

Execute the Nelson Muntz loop in HA-HA (Peak Performance) mode:

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-nelson-loop.sh" --ha-ha $ARGUMENTS
```

## What is HA-HA Mode?

HA-HA Mode is Nelson Muntz with EVERY enhancement enabled:

| Standard Nelson | HA-HA Mode |
|-----------------|------------|
| Ultrathink | Multi-dimensional thinking (4 levels) |
| Research on 2nd failure | Pre-research MANDATORY |
| 3-fix rule | 5-attempt escalation with research |
| Single validation | Aggressive validation + self-review |
| Basic pattern tracking | Full pattern library |
| Standard handoff | Comprehensive iteration reports |

## Usage

```bash
# Start HA-HA Mode loop
/ha-ha "Build a complete authentication system with OAuth, JWT, and MFA"

# With options
/ha-ha "Complex task" --max-iterations 50

# With completion promise
/ha-ha "Add OAuth flow" --completion-promise "ALL TESTS PASS"
```

## HA-HA Mode Protocol Stack

When HA-HA Mode is active, these protocols execute:

### Phase 0: Pre-Flight Research
- Search best practices before writing any code
- Review official documentation
- Analyze existing patterns in codebase

### Phase 1: Multi-Dimensional Thinking
- Level 1: Standard ultrathink
- Level 2: Deep ultrathink
- Level 3: Adversarial ultrathink (what could go wrong?)
- Level 4: Meta ultrathink (is this the best approach?)

### Phase 2: Wall-Breaker Protocol
- Classify any obstacle by type
- Execute wall-specific research protocol
- Document breakthrough and prevention

### Phase 3: Aggressive Validation
- Pre-implementation checks
- Incremental validation (after every change)
- Two-stage post-implementation
- Self-review against best practices

### Phase 4: No-Surrender Persistence
- 5-attempt escalation ladder
- Mandatory research between attempts
- Never retry without new information

## Wall-Breaker Auto-Research

HA-HA Mode automatically searches when hitting walls:

```
ERROR WALL      Search error message + solutions
KNOWLEDGE WALL  Search tutorials + documentation
DESIGN WALL     Search approach comparisons
DEPENDENCY WALL Search alternatives
COMPLEXITY WALL Decompose + research sub-problems
```

## Completion Signals (v3.3.1)

HA-HA Mode uses the same **two-stage completion flow** with stricter validation:

### Stage 1: Claim Completion
```
<nelson-complete>ALL_FEATURES_COMPLETE</nelson-complete>
```
**This triggers the Verification Challenge** - does NOT exit.

### Stage 2: Verification Challenge (STRICT)
You must:
1. Run tests and paste REAL output (must show pass/fail counts)
2. Run build and confirm success
3. List 3+ edge cases handled (bulleted)
4. Write critical self-review (weaknesses, debt, TODOs)
5. Create `.claude/nelson-verification.local.md`

Then output:
```
<nelson-verified>VERIFICATION_COMPLETE</nelson-verified>
```

Or if you set a completion promise (after verification):
```
<promise>YOUR_PROMISE_TEXT</promise>
```

**Content is validated:** Weak sections get REJECTED with specific failures.

## Monitoring

```bash
# Check state
head -10 .claude/nelson-loop.local.md

# Check status
/nelson-status

# Stop loop (if needed)
/nelson-stop
```

## The HA-HA Oath

```
I will not write code without research.
I will not commit without validation.
I will not surrender without exhausting options.
I will not repeat failures without learning.

When I succeed, I say: "HA-HA!"
```

---

**HA-HA Mode: Peak Performance. No Compromises.**
