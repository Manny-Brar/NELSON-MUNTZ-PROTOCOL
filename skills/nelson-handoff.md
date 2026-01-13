---
name: nelson-handoff
description: "Generate high-quality handoff documents for Nelson Muntz iterations"
---

# Nelson Handoff - Iteration Handoff Protocol

## Purpose
Create clear, actionable handoff documents that enable the next iteration to continue seamlessly with zero ramp-up time.

---

## HANDOFF QUALITY STANDARD

A good handoff answers these questions in <30 seconds of reading:
1. What was done this iteration?
2. What's the current state?
3. What should the next iteration do FIRST?
4. What gotchas or context is critical?

---

## HANDOFF TEMPLATE

```markdown
# Nelson Muntz - Iteration [N] Handoff

## Status Summary
- **Iteration:** [N]
- **Mode:** [Standard / HA-HA]
- **Feature Worked On:** F[X] - [Feature Name]
- **Result:** [COMPLETED / IN_PROGRESS / BLOCKED]
- **Git Commit:** [hash if committed]

## What Was Done

### Completed This Iteration
- [Specific action 1] → [file:line]
- [Specific action 2] → [file:line]
- [Specific action 3] → [file:line]

### Files Modified
| File | Changes |
|------|---------|
| `path/to/file.ts` | Added [what], lines [X-Y] |
| `path/to/other.ts` | Modified [what], line [Z] |

### Tests Added/Modified
- `test/file.test.ts` - Added [N] tests for [what]

## Current State

### Validation Status
- **Spec Compliance:** [PASS/FAIL] - [details]
- **Tests:** [PASS/FAIL] - [X/Y passing]
- **Lint:** [PASS/FAIL] - [error count]
- **Build:** [PASS/FAIL]

### Code State
- [ ] All changes committed
- [ ] No uncommitted work
- [ ] Tests passing
- [ ] No lint errors

## Next Iteration Instructions

### IMMEDIATE FIRST ACTION
> [Single, specific instruction - what to do FIRST]

### Priority Tasks
1. [Task 1 - specific and actionable]
2. [Task 2 - specific and actionable]
3. [Task 3 - specific and actionable]

### Files to Read First
1. `path/to/critical/file.ts` - [why]
2. `.claude/ralph-v3/features.json` - Check feature status

## Critical Context

### Gotchas / Warnings
- [Thing that might trip up next iteration]
- [Non-obvious behavior or constraint]

### Decisions Made
- [Decision 1]: Chose [X] over [Y] because [reason]
- [Decision 2]: [explanation]

### Research Notes (if any)
- [Finding 1] - Source: [URL or file]
- [Finding 2] - Source: [URL or file]

## Features Overview

| ID | Feature | Status | Progress |
|----|---------|--------|----------|
| F1 | [Name] | [status] | [X/Y steps] |
| F2 | [Name] | [status] | [X/Y steps] |
| ... | ... | ... | ... |

---

*Handoff generated: [timestamp]*
*Next iteration: Read this, then execute IMMEDIATE FIRST ACTION*
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
[ ] Feature status is clear (complete/in_progress/blocked)
[ ] All file changes documented with line numbers
[ ] Validation status is current and accurate
[ ] Next action is SPECIFIC and SINGLE
[ ] No uncommitted changes remain
[ ] Gotchas section includes anything non-obvious
[ ] Features overview is up to date
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

## PROGRESS.MD UPDATE

In addition to handoff.md, append to progress.md:

```markdown
### Iteration [N] - [timestamp]
**Feature:** F[X] - [Name]
**Result:** [COMPLETED / IN_PROGRESS / BLOCKED]
**Completed:** [1-2 sentence summary]
**Files:** [comma-separated list]
**Commit:** [hash or "none"]
**Next:** [1 sentence]
```

---

## EMERGENCY HANDOFF

If context is almost exhausted, minimum viable handoff:

```markdown
# Emergency Handoff - Iteration [N]

**Feature:** F[X] - [Name]
**Status:** [status]
**Last Action:** [what you just did]
**Next Action:** [what to do next]
**Files Changed:** [list]
**Commit:** [hash or "uncommitted - run git add -A && git commit"]
```

---

*Write handoff BEFORE exiting iteration. No exceptions.*
