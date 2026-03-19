---
name: nelson-handoff
description: "Generate high-quality 5-section handoff documents for Nelson Muntz v5.0 iterations — with compound learning transfer and drift context"
version: 5.0.0
---

# Nelson Handoff — Iteration Handoff Protocol (v5.0)

## Purpose
Create clear, actionable 5-section handoff documents that enable the next iteration to continue seamlessly with zero ramp-up time — including compound learning transfer so each iteration starts smarter.

---

## HANDOFF QUALITY STANDARD

A good v5.0 handoff answers these 5 questions in <30 seconds of reading:
1. **What was accomplished?** (features, files, commits)
2. **What's the current state?** (tests, build, blockers)
3. **What's the immediate next step?** (specific, actionable, file-level)
4. **What critical context matters?** (decisions, gotchas, warnings)
5. **What compound learning transfers?** (patterns, anti-patterns, difficulty — v5.0)

---

## HANDOFF TEMPLATE (v5.0 — 5 Sections)

```markdown
# Nelson Muntz v5.0 — Iteration [N] Handoff

## 1. What Was Accomplished?
- **Feature:** F[X] — [name]
- **Result:** COMPLETED / IN_PROGRESS / BLOCKED
- **Files changed:**
  - `path/to/file.ts:45-67` — [what was added/changed]
  - `path/to/other.ts:12` — [what was modified]
- **Tests:** `test/file.test.ts` — added [N] tests for [what]
- **Commit:** [hash] `feat(F[X]): [description]`

## 2. What's the Current State?
- Features: [X/Y completed], [Z blocked]
- Tests: [X/Y passing]
- Build: [PASS/FAIL]
- Lint: [PASS/FAIL]
- Blockers: [none / specific blocker description]

## 3. What's the Immediate Next Step?
- **Task:** [exact description — one sentence]
- **Start at:** [file:line or "create new file at path"]
- **Approach:** [specific strategy — not vague]
- **Read first:** `[file to read]` — [why]

## 4. What Critical Context Matters?
- **Decision:** [key decision made] — because [WHY]
- **Gotcha:** [non-obvious thing the next iteration must know]
- **Avoid:** [specific thing NOT to do and why]

## 5. Compound Learning Transfer (v5.0)
- **Pattern extracted:** [name] — [one-sentence description]
  OR "None this iteration"
- **Anti-pattern found:** [name] — [one-sentence description]
  OR "None this iteration"
- **Insight for next iteration:** [specific advice that saves time]
- **Iteration difficulty:** [1-10] — [why this number]
- **Drift score at handoff:** [0-10]

---
*Handoff: [timestamp] | Next: Read this → Execute Section 3*
```

---

## HANDOFF ANTI-PATTERNS

### BAD Handoff Examples:

```markdown
# DON'T DO THIS

## What was done
Fixed the webhook.

## Next
Deploy it.
```

**Why bad:** Vague, no file references, no specifics, no context.

```markdown
# DON'T DO THIS

## What was done
I spent this iteration researching authentication patterns and reading
through various approaches. I looked at JWT, sessions, OAuth, and
considered the tradeoffs of each approach...
[500 more words of narrative]
```

**Why bad:** Too much prose, no actionable specifics, wastes next iteration's context.

---

## HANDOFF CHECKLIST

Before writing handoff, verify:

```
[ ] Section 1: Feature status clear, files listed with line numbers, commit hash
[ ] Section 2: Test/build/lint status current and accurate
[ ] Section 3: Next action is SPECIFIC, SINGLE, and references a file
[ ] Section 4: At least one decision or gotcha documented
[ ] Section 5: Compound learning — pattern OR anti-pattern extracted (v5.0)
[ ] Section 5: Iteration difficulty rated 1-10 with justification (v5.0)
[ ] No uncommitted changes remain
[ ] Handoff fits on one screen (< 60 lines)
```

---

## HANDOFF WRITING RULES

### Rule 1: Be Specific
- BAD: "Modified the auth file"
- GOOD: "Added JWT validation to `src/lib/auth.ts:45-67`"

### Rule 2: Be Actionable
- BAD: "Continue working on the feature"
- GOOD: "Run `npm test src/auth.test.ts` to verify JWT validation, then implement refresh token logic in `src/lib/auth.ts:70`"

### Rule 3: Be Concise
- Each bullet point: 1-2 sentences max
- Total handoff: Fits on one screen

### Rule 4: Reference Files
- Always include `file:line` for code changes
- Link to specific functions/classes

### Rule 5: Front-Load Critical Info
- Status and next action at TOP
- Details and context at BOTTOM

---

## STATE FILE LOCATIONS (v5.0)

All state files are in `.claude/` directory:
- `nelson-loop.local.md` — YAML frontmatter + prompt (L0: always load)
- `nelson-handoff.local.md` — THIS handoff document (L0: always load)
- `nelson-scratchpad.local.md` — Planning notes + reasoning trail (L1: selective)
- `nelson-verification.local.md` — Created during verification (L2: on-demand)
- `nelson-edit-tracker.local.json` — Edit metrics for drift scoring (v5.0)

---

## EMERGENCY HANDOFF

If context is almost exhausted or drift circuit breaker triggers, minimum viable handoff:

```markdown
# EMERGENCY HANDOFF — Iteration [N]

STATE: [working / broken / blocked]
FEATURE: F[X] — [Name]
LAST GOOD COMMIT: [hash]
NEXT ACTION: [one specific thing to do]
CRITICAL: [one sentence of must-know context]
AVOID: [what caused the problem / drift]
FILES: [changed files list]
DRIFT: [score if known]
```

**Emergency handoffs skip compound learning.** That's OK — survival is more important than learning in a crisis. Next iteration can extract patterns once stable.

---

*Write handoff BEFORE exiting iteration. No exceptions. HA-HA!*
