---
name: nelson-compound-learning
description: Compound engineering engine — each iteration makes the next easier through systematic pattern extraction, anti-pattern documentation, and institutional knowledge building
version: 5.0.0
---

# Nelson v5.0 — Compound Learning Engine

**"Each unit of work should make subsequent work easier, not harder."**

Inspired by [Compound Engineering](https://every.to/guides/compound-engineering) methodology.

---

## The Compound Principle

Traditional development accumulates **technical debt** — each feature makes the next harder. Compound engineering inverts this by extracting learnings that accelerate future work.

```
WITHOUT compound learning:
  Feature 1: 45 min → Feature 2: 50 min → Feature 3: 60 min (debt accumulates)

WITH compound learning:
  Feature 1: 45 min → Feature 2: 35 min → Feature 3: 20 min (knowledge accelerates)
```

---

## The Compound Loop

Every Nelson iteration follows this enhanced cycle:

```
PLAN → WORK → REVIEW → COMPOUND
                          │
                          ├─ Extract pattern
                          ├─ Document anti-pattern
                          ├─ Update institutional knowledge
                          ├─ Refine skill prompts
                          └─ Reduce next iteration's startup cost
```

---

## Phase 1: Pattern Extraction

After completing each feature, ask:

### Success Pattern Template
```markdown
## Pattern: [Descriptive Name]

**ID:** P-[YYYY-MM-DD]-[NN]
**Type:** success
**Confidence:** [high/medium/low]
**Reuse potential:** [high/medium/low]

### Context
When: [situation that triggers this pattern]
Project type: [web app, API, CLI, etc.]
Technology: [specific tech stack]

### Solution
[Concise description of what works]

### Implementation
```[language]
// Key code snippet showing the pattern
```

### Evidence
- File: [path:line]
- Commit: [hash]
- Tests: [which tests validate this]

### Connected Patterns
- Requires: [[pattern-name]] (prerequisite)
- Enhances: [[pattern-name]] (builds on)
- Conflicts: [[pattern-name]] (mutually exclusive)

### Compound Value
How this helps future iterations:
- [Specific time/effort saved]
- [Specific error prevented]
```

### Anti-Pattern Template
```markdown
## Anti-Pattern: [Descriptive Name]

**ID:** AP-[YYYY-MM-DD]-[NN]
**Type:** failure
**Severity:** [critical/moderate/minor]
**Recurrence risk:** [high/medium/low]

### Context
When: [situation where this trap appears]
Temptation: [why this seems like a good idea]

### The Trap
[What goes wrong and why]

### Root Cause
[The underlying reason this fails]

### Better Approach
[What to do instead, with evidence]

### Detection
How to recognize you're falling into this:
- [Signal 1]
- [Signal 2]

### Recovery
If you've already fallen in:
1. [Recovery step 1]
2. [Recovery step 2]
```

---

## Phase 2: Institutional Knowledge Updates

### When to Write to MEMORY.md

```
ALWAYS write when:
  ✅ Architecture decision made (and WHY)
  ✅ Gotcha discovered that isn't obvious from code
  ✅ Convention established that differs from defaults
  ✅ External service behavior learned (API quirks, rate limits)
  ✅ Performance characteristic discovered (bottleneck, optimization)

NEVER write when:
  ❌ Information derivable from reading current code
  ❌ Git history captures it (who changed what, when)
  ❌ Temporary state (current task, in-progress work)
  ❌ Already documented in CLAUDE.md
```

### Knowledge Decay Management

```
Every 5 iterations, review:
  1. Read MEMORY.md entries older than 5 sessions
  2. For each entry: Is this still true?
     - If yes: leave it
     - If outdated: update or remove
     - If uncertain: verify against current code
  3. Prune entries that duplicate what code shows
  4. Merge entries that overlap
  5. Keep MEMORY.md under 200 lines (for auto-loading)
```

---

## Phase 3: Skill Evolution

### Self-Improving Skills

After each iteration, if a skill file was used:

```
1. Did the skill's guidance help? (yes/no)
2. If yes:
   - Was there unnecessary content? → trim it
   - Was the ordering optimal? → reorder
   - Could examples be better? → improve
3. If no:
   - What was missing? → add it
   - What was misleading? → correct it
   - What was the actual solution? → document
4. Track skill effectiveness:
   - Uses: [count]
   - Helpful: [count]
   - Not helpful: [count]
   - Last refined: [date]
```

### Skill Refinement Protocol (GEPA-Inspired)

```
Step 1: Sample execution trace
  - What tool calls were made?
  - What results were returned?
  - What decisions were influenced by the skill?

Step 2: Reflect on trace
  - Where did the skill guide correctly?
  - Where did the agent deviate from skill guidance?
  - Where did the agent struggle despite skill guidance?

Step 3: Propose revision
  - Write specific change to skill content
  - Predict: will this help future iterations?
  - Estimate: how many tokens does this add/remove?

Step 4: Validate revision
  - Does the revision contradict other skills?
  - Does the revision add real value (not noise)?
  - Is it general enough to help across contexts?

Step 5: Apply or discard
  - If validated: update skill file
  - If uncertain: add as comment for human review
  - If rejected: document why it was rejected
```

---

## Phase 4: Metrics Tracking

### Iteration Metrics (Append to progress.md)

```markdown
## Iteration [N] Metrics

| Metric | Value |
|--------|-------|
| Duration | [minutes] |
| Feature | [name] |
| Status | [complete/partial/blocked] |
| Attempts | [1-5] |
| Walls hit | [count by type] |
| Research queries | [count] |
| Patterns extracted | [count] |
| Anti-patterns found | [count] |
| Compound value | [high/medium/low] |
| Drift score | [0-10] |
| Token estimate | [rough %] |
```

### Trend Analysis (Every 5 iterations)

```
Review metrics for trend:
  - Is duration decreasing? (compound learning working)
  - Is attempt count decreasing? (fewer retries needed)
  - Is wall frequency decreasing? (knowledge accumulating)
  - Is drift score stable? (harness working)

If trends are negative:
  - Review recent compound artifacts
  - Check if skills need refinement
  - Consider protocol adjustment
  - Document finding for meta-review
```

---

## Phase 5: Cross-Iteration Knowledge Transfer

### Handoff Enrichment

Standard handoff + compound section:

```markdown
## Compound Learning Transfer

### Patterns Discovered This Iteration
- [Pattern name] → documented in [location]
- Use when: [trigger condition]

### Anti-Patterns to Avoid
- [Anti-pattern name] → documented in [location]
- Watch for: [detection signal]

### Institutional Knowledge Added
- [Knowledge entry] → added to MEMORY.md
- Context: [why this matters]

### Skill Refinement Applied
- [Skill name] → [what changed]
- Reason: [why it was refined]

### Iteration Difficulty: [1-10]
- Why: [factors that made it easy/hard]
- For next iteration: [specific advice based on difficulty]
```

---

## Compound Learning Checklist

After EVERY feature completion:

```
□ Pattern extracted? (success or anti-pattern)
□ Institutional knowledge updated?
□ Skill file refined (if used)?
□ Metrics logged?
□ Handoff enriched with compound section?
□ Cross-iteration knowledge preserved?
```

If any item is NO: complete it before moving to next feature.

---

## The Compound Oath

```
Every feature I complete makes the next one easier.
Every pattern I extract prevents a future failure.
Every anti-pattern I document saves future time.
Every skill I refine improves future quality.

Knowledge compounds. Technical debt doesn't have to.
```

---

*Nelson v5.0 Compound Learning: Each unit of work makes subsequent work easier.*
