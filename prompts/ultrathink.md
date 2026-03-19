# Ultrathink Protocol v5.0

## 5-Level Extended Thinking

Before taking ANY action in this iteration, you MUST engage all five levels of extended thinking. Each level builds on the previous.

### Level 1: Standard Analysis
Think hard about the fundamentals:
- What does this task require? (input → output → steps)
- What was accomplished in previous iterations?
- What is the current feature being worked on?
- What blockers or issues were encountered?

### Level 2: Deep Analysis
Think harder about the details:
- What are the edge cases and boundary conditions?
- What dependencies exist (and could break)?
- What is the most direct path to completing this?
- What is the verification strategy?

### Level 3: Adversarial Analysis
Think hard about what could go wrong:
- What failure modes exist? (crashes, wrong behavior, edge cases)
- What security concerns? (injection, auth bypass, data exposure)
- What performance issues? (bottlenecks, N+1 queries, memory leaks)
- What integration conflicts? (breaking other features, race conditions)

### Level 4: Meta Analysis
Ultrathink about the approach itself:
- Is this actually the best approach? What alternatives exist?
- Is there a simpler solution I'm overlooking?
- Would a senior engineer do this differently?
- What would I be embarrassed about in code review?

### Level 5: Compound Analysis (v5.0)
Ultrathink about the future:
- How does this make the NEXT iteration easier?
- What reusable pattern will emerge from this work?
- What institutional knowledge does this create?
- What should I extract for the compound learning artifact?
- How does this reduce total project complexity?

### Document Reasoning

Before executing, write your key reasoning to `nelson-scratchpad.local.md`:
- Your understanding of the current state
- Your chosen approach and WHY (not just what)
- Potential risks identified (from Level 3)
- Alternatives considered and rejected (from Level 4)
- Compound value assessment (from Level 5)
- How you'll verify success

---

## Why This Matters

Extended thinking:
- Allocates more compute to planning (planning prevents rework)
- Reduces implementation mistakes (Level 3 catches problems early)
- Creates an audit trail for debugging
- Enables compound learning across iterations (Level 5)
- Detects drift early (if you can't think clearly, context may be degraded)

## Trigger Words

Use these phrases in your internal reasoning:
- "think hard" — Standard extended thinking (Levels 1-2)
- "think harder" — More thorough analysis (Levels 1-3)
- "ultrathink" — Maximum computational allocation (all 5 levels)

## When to Skip Levels

- **Trivial tasks** (rename, format fix): Levels 1-2 sufficient
- **Standard features**: Levels 1-4
- **Complex features / HA-HA mode**: All 5 levels mandatory
- **When stuck**: Re-run Levels 3-4 with fresh perspective

## Drift Signal

If you find it hard to complete all 5 levels clearly, this may indicate context degradation. Consider:
- Writing current state to scratchpad
- Triggering pre-compaction flush
- Circuit breaking for fresh context

---

*Ultrathink Protocol v5.0 — Think 5 levels deep before every action.*
