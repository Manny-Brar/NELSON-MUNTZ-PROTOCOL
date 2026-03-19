---
name: nelson-self-evolving-eval
description: GEPA-inspired self-evolving evaluation system — analyzes execution traces, diagnoses failures with Actionable Side Information, and evolves prompts/skills through reflective optimization
version: 5.0.0
---

# Nelson v5.0 — Self-Evolving Evaluation Engine

**"Grade what the agent produced, not the path it took."**

Inspired by GEPA (Genetic-Pareto Reflective Prompt Evolution) — accepted at ICLR 2026 (Oral).

---

## Core Concept

Traditional evaluation: Did the feature pass? (binary)
Self-evolving evaluation: WHY did it pass/fail, and how do we prevent the failure class forever?

```
Standard eval:  Input → Agent → Output → PASS/FAIL
                                           ↓
                                         (done)

GEPA eval:      Input → Agent → Output → PASS/FAIL
                          │                  ↓
                          │            Trace Analysis
                          │                  ↓
                          │         Actionable Side Info (ASI)
                          │                  ↓
                          │         Targeted Prompt Revision
                          │                  ↓
                          └──────── Evolved Agent (better next time)
```

---

## Phase 1: Execution Trace Capture

After each iteration, capture the execution trace:

```markdown
## Execution Trace - Iteration [N]

### Tool Calls Made
| # | Tool | Input (summary) | Output (summary) | Duration |
|---|------|-----------------|-------------------|----------|
| 1 | Glob | "**/*.ts" | 42 files | fast |
| 2 | Read | src/auth.ts | 200 lines | fast |
| 3 | Edit | src/auth.ts:45 | modified | fast |
| 4 | Bash | npm test | 3 failing | slow |
| 5 | ... | ... | ... | ... |

### Decision Points
| # | Decision | Reasoning | Outcome |
|---|----------|-----------|---------|
| 1 | Approach A over B | [why] | [good/bad] |
| 2 | Used library X | [why] | [good/bad] |

### Friction Points (where things slowed down)
- [Tool call N]: [what went wrong]
- [Decision N]: [what caused hesitation]

### Delight Points (where things went smoothly)
- [Tool call N]: [what worked well]
- [Decision N]: [what was clearly right]
```

---

## Phase 2: Actionable Side Information (ASI) Extraction

ASI is the diagnostic feedback that tells you NOT just "it failed" but WHY and HOW TO FIX IT.

### For Failed Iterations

```
1. Read the full error output
   - Not just the error message
   - The complete stack trace
   - The test output context

2. Identify the failure class:
   □ SYNTAX — code doesn't parse
   □ TYPE — type mismatch
   □ LOGIC — code runs but wrong behavior
   □ INTEGRATION — components don't connect
   □ ENVIRONMENT — works locally, fails in CI
   □ SPEC — code works but doesn't match spec
   □ REGRESSION — broke something that worked before

3. Extract ASI:
   "The failure occurred because [root cause].
    The diagnostic signal was [what indicated the problem].
    This could have been prevented by [specific prompt/skill change].
    The relevant skill that should have caught this: [skill name].
    The missing guidance was: [specific instruction to add]."

4. Rate the ASI:
   □ Actionable: Can I change a prompt/skill based on this? (yes/no)
   □ General: Will this help in other contexts? (yes/no)
   □ Novel: Is this a new failure class? (yes/no)
```

### For Successful Iterations

```
1. Identify what went RIGHT
   - Was it due to a skill's guidance?
   - Was it due to research?
   - Was it due to a pattern from memory?

2. Extract positive ASI:
   "The success was enabled by [specific factor].
    The skill/pattern that helped: [name].
    The critical guidance was: [specific instruction].
    This should be reinforced because: [reason]."

3. Rate the positive ASI:
   □ Replicable: Will this help again? (yes/no)
   □ Documented: Is this pattern captured? (yes/no)
   □ Skill-linked: Does a skill need reinforcement? (yes/no)
```

---

## Phase 3: Reflective Skill Evolution

### Skill Revision Cycle

```
FOR each skill used this iteration:

  1. SAMPLE: What guidance from the skill influenced decisions?

  2. REFLECT: Did that guidance help or hinder?
     - Helpful → reinforce (add emphasis, add example)
     - Unhelpful → revise (correct, clarify, remove)
     - Missing → extend (add the missing guidance)
     - Excessive → trim (remove noise that diluted signal)

  3. PROPOSE: Draft specific revision
     Before: "[original text from skill]"
     After:  "[proposed new text]"
     Reason: "[why this change helps, based on ASI]"

  4. VALIDATE: Check revision quality
     □ Does it contradict other skills?
     □ Does it add tokens without proportional value?
     □ Is it general enough (not overfitting to one case)?
     □ Does it maintain the skill's core purpose?

  5. APPLY or DEFER:
     - If all validation passes → update skill file
     - If uncertain → add as comment: <!-- PROPOSED: ... -->
     - If rejected → document why in protocol-evolution.md
```

### Pareto Front Maintenance

Don't just keep the "best" version — maintain alternatives:

```
For each skill revision:
  - Keep the previous version as a comment block
  - Track which version worked for which context
  - When a new failure occurs with the revised version:
    → Check if the previous version would have prevented it
    → If yes: the revision was an overcorrection
    → If no: the revision is validated

This prevents local optima in skill evolution.
```

---

## Phase 4: Protocol Meta-Evaluation

### Every 5 Iterations: Protocol Self-Assessment

```markdown
## Protocol Meta-Eval - Iterations [N-4] to [N]

### Phase Effectiveness
| Phase | Avg Time | Value Added | Skip Rate | Verdict |
|-------|----------|-------------|-----------|---------|
| Boot  | [time]   | [high/med/low] | [%]   | [keep/trim/expand] |
| Plan  | [time]   | [high/med/low] | [%]   | [keep/trim/expand] |
| Research | [time] | [high/med/low] | [%]  | [keep/trim/expand] |
| Execute | [time] | [high/med/low] | [%]  | [keep/trim/expand] |
| Validate | [time] | [high/med/low] | [%] | [keep/trim/expand] |
| Red-team | [time] | [high/med/low] | [%] | [keep/trim/expand] |
| Compound | [time] | [high/med/low] | [%] | [keep/trim/expand] |
| Handoff | [time] | [high/med/low] | [%]  | [keep/trim/expand] |

### Failure Patterns
| Failure Class | Count | Resolved By | Prevention Added? |
|---------------|-------|-------------|-------------------|
| [class]       | [N]   | [what]      | [yes/no]          |

### Drift Events
| Iteration | Score | Cause | Recovery |
|-----------|-------|-------|----------|
| [N]       | [score] | [cause] | [action] |

### Protocol Adjustments
- [Proposed change]: [rationale]
- [Proposed change]: [rationale]

### Compound Learning Rate
- Patterns extracted per iteration: [avg]
- Time savings from patterns: [estimate]
- Knowledge reuse rate: [% of iterations that benefited from prior patterns]
```

### Every 10 Iterations: Deep Protocol Review

```
1. Read ALL compound artifacts from last 10 iterations
2. Identify recurring themes
3. Check: Is the protocol itself causing friction?
   - Phases too long → shorten
   - Phases too short → expand
   - Missing phase → add
   - Redundant phase → merge
4. Check: Are skills evolving in the right direction?
   - Getting longer without more value → over-engineering
   - Getting shorter and more precise → good evolution
5. Write findings to .nelson/protocol-evolution.md
```

---

## Phase 5: Eval Assertions (Binary Testing)

### Skill Activation Assertions

For each skill, define binary assertions:

```yaml
skill: nelson-validate
assertions:
  - name: "runs_tests_before_claiming_pass"
    check: "execution trace contains 'npm test' or 'npm run test'"
    expected: true
  - name: "shows_test_output"
    check: "validation doc contains actual test output (not just 'PASS')"
    expected: true
  - name: "three_stages_executed"
    check: "validation doc has Stage 1, Stage 2, Stage 3 sections"
    expected: true
```

### Protocol Compliance Assertions

```yaml
protocol: nelson-v5
assertions:
  - name: "handoff_has_specifics"
    check: "handoff contains file paths (matches pattern 'src/' or similar)"
    expected: true
  - name: "compound_artifact_created"
    check: "pattern or anti-pattern documented this iteration"
    expected: true
  - name: "drift_score_calculated"
    check: "metrics include drift score"
    expected: true
  - name: "single_feature_focus"
    check: "only one feature marked in_progress at a time"
    expected: true
```

### Running Assertions

```
After each iteration:
  1. Collect execution trace
  2. Run assertions against trace
  3. For each FAIL:
     - Generate ASI explaining why
     - Propose skill/protocol revision
  4. Track assertion pass rate over time
  5. If pass rate drops → investigate systemic issue
```

---

## Integration Points

### With Compound Learning
```
Every ASI extracted → potential compound artifact
Every skill revision → compound knowledge transfer
Every protocol adjustment → institutional learning
```

### With Drift Detection
```
Declining assertion pass rates → drift indicator
Repeated ASI for same failure class → protocol gap
Skill revisions causing regressions → overcorrection drift
```

### With Obsidian (if available)
```
Store eval results as linked notes:
  eval/[date]-[feature].md → linked to patterns used
  ASI becomes searchable knowledge
  Skill revision history tracked with graph connections
```

---

## The Evolution Oath

```
I will analyze traces, not just outcomes.
I will extract WHY, not just WHAT.
I will evolve skills based on evidence.
I will maintain alternatives, not just latest.
I will measure my own protocol's effectiveness.
I will compound learning, never compound debt.

The agent that improves itself is the agent that endures.
```

---

*Nelson v5.0 Self-Evolving Eval: Analyze. Diagnose. Evolve. Compound.*
