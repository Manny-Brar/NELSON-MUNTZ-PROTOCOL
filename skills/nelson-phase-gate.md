---
name: nelson-phase-gate
description: "Phase-Gate Execution Engine — automatically decomposes every HA-HA mode request into strategic multi-phase plans with mandatory self-assessment, research, testing, and documentation gates between each phase. This is the CORE execution protocol for HA-HA mode."
version: 5.1.0
---

# Nelson v5.1 — Phase-Gate Execution Engine

**"Every request becomes a multi-phase strategic operation. No phase advances without passing its gates."**

This protocol is **MANDATORY** in HA-HA mode. Every instruction received through Nelson HA-HA mode automatically triggers this engine. There are no exceptions.

---

## THE PHASE-GATE LOOP

Every request follows this meta-process:

```
┌─────────────────────────────────────────────────────────────────────┐
│                 PHASE-GATE EXECUTION ENGINE                          │
│                                                                      │
│  RECEIVE INSTRUCTION                                                 │
│       ↓                                                              │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  STEP 1: STRATEGIC DECOMPOSITION (ULTRATHINK)               │    │
│  │  Break request into multi-phase plan with detailed tasks     │    │
│  └──────────────────────────┬──────────────────────────────────┘    │
│                              ↓                                       │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  STEP 2: PLAN SELF-ASSESSMENT                               │    │
│  │  Critically evaluate plan for gaps, risks, enhancements     │    │
│  │  Revise plan based on findings                              │    │
│  └──────────────────────────┬──────────────────────────────────┘    │
│                              ↓                                       │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  FOR EACH PHASE:                                            │    │
│  │                                                             │    │
│  │    A. EXECUTE all tasks in this phase                       │    │
│  │         ↓                                                   │    │
│  │    B. SELF-ASSESS the completed phase                       │    │
│  │       • Identify gaps, hurdles, improvements                │    │
│  │       • Research best practices if needed                   │    │
│  │       • Work on any identified improvements                 │    │
│  │         ↓                                                   │    │
│  │    C. TEST everything in this phase                         │    │
│  │       • Run tests, apply fixes until all pass               │    │
│  │         ↓                                                   │    │
│  │    D. DOCUMENT this phase                                   │    │
│  │       • Update ALL relevant docs                            │    │
│  │       • Cross-reference overlapping workflows               │    │
│  │         ↓                                                   │    │
│  │    ✓ PHASE GATE: All 4 sub-steps pass → Next phase          │    │
│  │                                                             │    │
│  └──────────────────────────┬──────────────────────────────────┘    │
│                              ↓                                       │
│  REPEAT FOR EACH PHASE until all phases complete                     │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## STEP 1: STRATEGIC DECOMPOSITION

When ANY instruction is received in HA-HA mode, BEFORE writing a single line of code:

### 1A. Engage Full 5-Level ULTRATHINK on the Request

```
Level 1 — STANDARD: What does this request actually require?
  • What are the explicit requirements?
  • What are the IMPLICIT requirements (things not stated but expected)?
  • What is the end-state when this is "done"?

Level 2 — DEEP: What are the phases and dependencies?
  • What must happen FIRST (foundation work)?
  • What depends on what? (dependency graph)
  • What can be parallelized vs. must be sequential?
  • What are the edge cases at each stage?

Level 3 — ADVERSARIAL: What will go wrong?
  • Where are the highest-risk areas?
  • What are the most likely failure points per phase?
  • What external dependencies could block us?
  • What assumptions might be wrong?

Level 4 — META: Is this the right decomposition?
  • Are the phases sized correctly? (not too big, not too small)
  • Is the ordering optimal?
  • Am I over-engineering or under-engineering?
  • Would a principal engineer structure this differently?

Level 5 — COMPOUND: How does each phase build on the last?
  • Does Phase 1 create patterns that Phase 2 reuses?
  • Are phases ordered so knowledge compounds?
  • What institutional knowledge does each phase create?
```

### 1B. Produce the Strategic Phase Plan

Output format — write this to `nelson-scratchpad.local.md`:

```markdown
# Strategic Phase Plan: [Request Summary]

## Overview
- Total phases: [N]
- Estimated complexity: [Low/Medium/High/Critical]
- Key risk areas: [list]

## Phase 1: [Phase Name] — Foundation
**Goal:** [One sentence — what this phase achieves]
**Depends on:** Nothing (this is the foundation)

### Tasks:
1. [ ] [Detailed task with specific file/component target]
2. [ ] [Detailed task with acceptance criteria]
3. [ ] [Detailed task with expected output]
...

### Success Criteria:
- [Specific, measurable criterion 1]
- [Specific, measurable criterion 2]

### Risks:
- [Risk 1] → Mitigation: [strategy]

---

## Phase 2: [Phase Name] — [Description]
**Goal:** [One sentence]
**Depends on:** Phase 1 (specifically: [what from Phase 1])

### Tasks:
1. [ ] [Detailed task]
2. [ ] [Detailed task]
...

### Success Criteria:
- [criterion]

### Risks:
- [risk] → [mitigation]

---

## Phase N: [Final Phase Name] — Integration/Polish
...

---

## Cross-Phase Dependencies:
- Phase 2 task 3 requires Phase 1 task 2's output
- Phase 3 cannot start until Phase 2 tests pass
- [etc.]

## Documentation Impact:
- [Doc 1] needs updating after Phase [X]
- [Doc 2] overlaps with [workflow/pattern] — cross-reference needed
- [Doc 3] will need new section for [feature]
```

---

## STEP 2: PLAN SELF-ASSESSMENT

**BEFORE executing any phase,** critically evaluate the entire plan:

### Assessment Checklist

```
COMPLETENESS:
  □ Are all requirements from the original request covered?
  □ Are implicit requirements captured (error handling, edge cases, security)?
  □ Is there a clear task for every piece of work?
  □ Are acceptance criteria specific and testable?

ORDERING:
  □ Are dependencies correctly sequenced?
  □ Is the most foundational work in Phase 1?
  □ Could any phases be reordered for better compound value?

SIZING:
  □ Is any phase too large? (Should it be split?)
  □ Is any phase too small? (Should it be merged?)
  □ Can each phase be completed in a reasonable iteration window?

GAPS:
  □ Are there integration points between phases that need explicit tasks?
  □ Is error handling addressed in each phase (not deferred to "later")?
  □ Are there data migration or state management tasks needed?
  □ Is security considered in each phase (not as an afterthought)?

RISKS:
  □ Does every high-risk item have a mitigation strategy?
  □ Are there fallback approaches for the riskiest phases?
  □ Are external dependency risks identified?

DOCUMENTATION:
  □ Is EVERY document that will need updating identified?
  □ Are cross-references to overlapping workflows noted?
  □ Are there docs that describe patterns this work will change?

ENHANCEMENT OPPORTUNITIES:
  □ Could any task be done in a way that creates reusable patterns?
  □ Are there quick wins that dramatically improve quality?
  □ Is there an opportunity to reduce technical debt along the way?
```

### After Assessment — Revise the Plan

```
IF gaps found:
  → Add tasks to address each gap
  → Re-sequence if new dependencies created
  → Update risk mitigations

IF sizing issues:
  → Split oversized phases
  → Merge undersized phases

IF enhancement opportunities:
  → Add enhancement tasks (clearly marked as enhancements)
  → Ensure they don't compromise core delivery

THEN: Finalize plan in scratchpad and proceed to execution
```

---

## STEP 3: PHASE EXECUTION LOOP

For EACH phase in the plan, execute this mandatory 4-gate cycle:

### Gate A: EXECUTE

```
For each task in this phase:
  1. Read the task description and acceptance criteria
  2. Implement the task (code, config, infrastructure, etc.)
  3. Mark task as done in scratchpad
  4. After EACH task: quick incremental check (does it work?)

DO NOT skip tasks. DO NOT reorder without documenting why.
DO NOT start the next task if the current one is broken.
```

### Gate B: SELF-ASSESS (Critical — after ALL phase tasks complete)

This is NOT a rubber stamp. Be genuinely critical:

```
EXECUTION QUALITY:
  □ Did each task meet its acceptance criteria?
  □ Is the code clean and maintainable?
  □ Are there any shortcuts taken that should be addressed?
  □ Did I follow established patterns in the codebase?

GAP ANALYSIS:
  □ Did any new requirements emerge during implementation?
  □ Are there edge cases I discovered but didn't handle?
  □ Are there error conditions not covered?
  □ Is there missing validation or sanitization?

BEST PRACTICES RESEARCH (if needed):
  When the phase involved unfamiliar territory or complex patterns:
  □ Search: "[technology/pattern] best practices 2026"
  □ Search: "[what I implemented] common mistakes"
  □ Compare my implementation against best practices found
  □ Document any gaps between my code and best practices

IMPROVEMENTS IDENTIFIED:
  For each identified gap or improvement:
  □ Classify: CRITICAL (must fix now) / IMPORTANT (should fix) / NICE-TO-HAVE
  □ Implement all CRITICAL items immediately
  □ Implement IMPORTANT items if time allows
  □ Document NICE-TO-HAVE for future reference

HURDLE CHECK:
  □ Did I hit any walls during this phase?
  □ Are there potential hurdles for the NEXT phase based on what I learned?
  □ Should the next phase's plan be adjusted?
```

**After self-assessment: implement all identified fixes and improvements before proceeding.**

### Gate C: TEST

```
RUN ALL RELEVANT TESTS:
  □ Unit tests for code written in this phase
  □ Integration tests touching this phase's components
  □ Full test suite to catch regressions
  □ Lint check (zero errors)
  □ Build check (success)
  □ Type check if applicable (zero errors)

FOR EACH FAILURE:
  1. Read the error carefully
  2. Identify root cause (not just symptom)
  3. Fix the root cause
  4. Re-run ALL tests (not just the fixed one)
  5. Repeat until ALL tests pass

WHEN ALL TESTS PASS:
  □ Commit the working code
  □ Document test results in scratchpad
  □ Proceed to documentation gate
```

**Do NOT proceed to documentation until all tests pass. No exceptions.**

### Gate D: DOCUMENT

This is NOT optional. This is NOT "update the README." This is comprehensive:

```
IDENTIFY ALL AFFECTED DOCUMENTATION:
  □ README.md — does the feature/change affect user-facing docs?
  □ NELSON_PROTOCOL_GUIDE.md — does it change the protocol?
  □ CLAUDE.md — does it change project instructions?
  □ API docs — are endpoints/interfaces changed?
  □ Inline code comments — are complex sections documented?
  □ Type definitions — are they updated and accurate?
  □ Configuration files — are they documented?
  □ Test descriptions — do they explain what's being tested?

CROSS-REFERENCE CHECK:
  □ What OTHER documents reference the code/patterns I changed?
  □ Are there workflow diagrams that need updating?
  □ Are there data flow descriptions that changed?
  □ Do other features depend on patterns I modified?
  □ Are there onboarding docs that reference this area?

FOR EACH AFFECTED DOCUMENT:
  1. Read the current content
  2. Update to reflect the changes made in this phase
  3. Ensure consistency with other documentation
  4. Add cross-references to related docs where helpful
  5. Verify examples/code snippets are still accurate

DOCUMENTATION QUALITY:
  □ Is the documentation detailed enough for someone new?
  □ Are there code examples where helpful?
  □ Are edge cases and gotchas documented?
  □ Are configuration options documented with defaults?
  □ Is there a clear "what changed and why" note?
```

### Phase Gate Checkpoint

After all 4 gates pass:

```markdown
## Phase [N] Gate Checkpoint

### Gate A (Execute): ✅
- Tasks completed: [X/X]
- All acceptance criteria met: YES

### Gate B (Self-Assess): ✅
- Gaps identified: [N] → [N] fixed
- Best practices researched: [topics]
- Improvements implemented: [list]

### Gate C (Test): ✅
- Tests: [X passed, 0 failed]
- Lint: 0 errors
- Build: SUCCESS
- Commit: [hash]

### Gate D (Document): ✅
- Docs updated: [list]
- Cross-references verified: [list]

→ PROCEED TO PHASE [N+1]
```

---

## DOCUMENTATION AWARENESS MAP

Nelson must maintain awareness of ALL documentation that could be affected:

### Always Check These
```
Project-level:
  □ README.md
  □ CLAUDE.md / CLAUDE.local.md
  □ CONTRIBUTING.md
  □ CHANGELOG.md

Architecture:
  □ Architecture docs (if any)
  □ API documentation
  □ Database schema docs
  □ Data flow diagrams

Nelson-specific:
  □ NELSON_PROTOCOL_GUIDE.md
  □ .nelson/MEMORY.md (institutional knowledge)
  □ .nelson/patterns/successes.md (if new pattern)
  □ .nelson/patterns/failures.md (if anti-pattern discovered)
  □ nelson-handoff.local.md (for next iteration)

Code-level:
  □ Type definitions / interfaces
  □ Configuration schemas
  □ Inline comments on complex logic
  □ Test descriptions and assertions
```

### Cross-Reference Triggers
```
IF you changed an API endpoint:
  → Update API docs, README usage examples, test descriptions, type definitions

IF you changed a database schema:
  → Update schema docs, migration docs, data flow docs, model type definitions

IF you changed authentication/authorization:
  → Update security docs, API docs, deployment docs, environment variable docs

IF you changed a shared component/utility:
  → Find ALL consumers, update their docs if behavior changed

IF you changed configuration:
  → Update deployment docs, environment variable docs, README setup section
```

---

## INTEGRATION WITH NELSON LOOP

In a Nelson HA-HA iteration loop, the phase-gate engine operates like this:

```
Iteration 1 (Initializer):
  → STEP 1: Strategic decomposition into phases
  → STEP 2: Plan self-assessment
  → Write plan to scratchpad + handoff
  → May begin Phase 1 execution if time permits

Iteration 2+ (Executor):
  → Read plan from scratchpad/handoff
  → Execute current phase through 4 gates (A→B→C→D)
  → If phase complete: write gate checkpoint, advance to next phase
  → If phase incomplete: handoff with progress for next iteration

Multi-iteration phases:
  → Large phases may span multiple iterations
  → Each iteration works on tasks within the current phase
  → Phase gates only run when ALL tasks in the phase are done
  → Never skip ahead to the next phase without completing gates
```

---

## ENFORCEMENT

This protocol is **automatically activated** whenever HA-HA mode is engaged. The agent MUST:

1. Decompose EVERY request into phases (even "simple" ones — they get 1-2 phases)
2. Self-assess EVERY plan before execution
3. Run ALL 4 gates for EVERY phase
4. NEVER skip the documentation gate
5. NEVER advance to the next phase with failing tests
6. NEVER claim completion without updating ALL affected docs

**If the agent skips any gate, the verification challenge in the stop hook will reject the completion claim.**

---

## THE PHASE-GATE OATH

```
I will DECOMPOSE before I execute.
I will ASSESS my plan before I begin.
I will EXECUTE each phase completely.
I will SELF-ASSESS critically — not as a rubber stamp.
I will RESEARCH when my knowledge has gaps.
I will TEST until everything passes.
I will DOCUMENT every change, every doc, every cross-reference.
I will NEVER skip a gate. I will NEVER advance prematurely.

Each phase is a fortress. Each gate is a wall.
No phase falls until every gate stands.
```

---

*Nelson v5.1 Phase-Gate Execution Engine: Strategic. Critical. Thorough. Documented. HA-HA!*
