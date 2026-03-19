---
name: nelson-validate
description: "Three-stage validation protocol for Nelson Muntz v5.0 iterations — spec compliance, quality assurance, and adversarial red-team review with compound learning extraction"
version: 5.0.0
---

# Nelson Validate — Three-Stage Validation Protocol (v5.0)

## Purpose
Execute structured three-stage validation to ensure feature completeness, code quality, and adversarial resilience before marking a feature as complete. Extract compound learning after validation.

---

## STAGE 1: SPEC COMPLIANCE CHECK

Before checking code quality, verify the implementation matches requirements.

### Step 1: Read Feature Requirements
```bash
# Check current task from handoff
cat .claude/nelson-handoff.local.md
```

### Step 2: Check Each Requirement

For each requirement in the feature's `steps` array:

| Requirement | Implemented | Evidence |
|-------------|-------------|----------|
| [Req 1] | YES/NO | [file:line or test name] |
| [Req 2] | YES/NO | [file:line or test name] |
| ... | ... | ... |

### Step 3: Document Spec Check
Document results in nelson-scratchpad.local.md:
```markdown
## Spec Check - [Feature]
- [Req 1]: PASS/FAIL
- [Req 2]: PASS/FAIL
- Notes: [What's missing or incomplete]
```

### Stage 1 Gate
- **ALL requirements implemented** → Proceed to Stage 2
- **ANY requirement missing** → STOP, implement missing requirements first

---

## STAGE 2: QUALITY CHECK

Only run after Stage 1 passes.

### Step 1: Run Test Suite
```bash
npm run test
# OR project-specific test command
```

**Record:**
- Pass/fail status
- Number of tests
- Number of failures
- Any new test failures (regressions)

### Step 2: Run Linter
```bash
npm run lint
# OR: npx eslint . --ext .ts,.tsx
```

**Record:**
- Error count (must be 0)
- Warning count (document but allow)

### Step 3: Run Type Check
```bash
npx tsc --noEmit
```

**Record:**
- Error count (must be 0)

### Step 4: Run Build
```bash
npm run build
```

**Record:**
- Success/failure
- Any build warnings

### Step 5: Create Verification File (v5.0)
Create `.claude/nelson-verification.local.md`:
```markdown
## Tests
[Actual test output — must show pass/fail counts]

## Build
[Build result — must contain success/pass/complete]

## Edge Cases
1. [Edge case 1 handled]
2. [Edge case 2 handled]
3. [Edge case 3 handled]

## Self-Review
- Weakest part: [honest assessment]
- Potential criticism: [what would be flagged]
- Tech debt: [any introduced, or 'None']
- TODOs remaining: [count, or 'None']

## Red-Team Review (v5.0)
1. [Attack vector tested]: [result and how handled]
2. [Assumption challenged]: [still valid or invalidated]
3. [Hostile reviewer finding]: [addressed or accepted risk]

## Compound Learning (v5.0)
- Pattern extracted: [name, or 'None']
- Anti-pattern found: [name, or 'None']
- Insight for next iteration: [what makes next work easier]

## Git Status
[Current git status — uncommitted should be 0]
```

**Note:** The v5.0 stop hook validates content quality. Weak sections get REJECTED. Red-Team and Compound Learning sections are checked when present.

### Stage 2 Gate
- **All checks pass** → Proceed to Stage 3
- **Any check fails** → STOP, fix issues first

---

## STAGE 3: ADVERSARIAL RED-TEAM REVIEW (v5.0)

Only run after Stage 2 passes. Think like an attacker, a hostile code reviewer, and a pessimistic QA engineer.

### Step 1: Input Adversarial Testing
```
For each user-facing input in this feature:
  □ What happens with empty/null/undefined input?
  □ What happens with extremely long input?
  □ What happens with special characters / injection attempts?
  □ What happens with unexpected types?
```

### Step 2: Error Cascade Analysis
```
For each external dependency (API, database, file system):
  □ What happens if it's unavailable?
  □ What happens if it responds slowly (timeout)?
  □ What happens if it returns unexpected data?
  □ Does error handling prevent cascading failure?
```

### Step 3: Security Spot-Check
```
□ Are secrets hardcoded anywhere? (check for passwords, API keys, tokens)
□ Is user input sanitized before database queries?
□ Are authentication/authorization checks in place?
□ Is sensitive data logged or exposed in errors?
```

### Step 4: Assumption Challenge
```
□ What ordering assumptions did I make? (Could things happen out of order?)
□ What state assumptions did I make? (Could state be different than expected?)
□ What concurrency assumptions did I make? (Could parallel requests conflict?)
```

### Step 5: Document Red-Team Findings

For each finding, classify severity:
- **CRITICAL** — Must fix before merge (security, data loss)
- **HIGH** — Should fix (logic errors, missing error handling)
- **MEDIUM** — Consider fixing (edge cases, code quality)
- **LOW** — Nice to have (style, optimization)

### Stage 3 Gate
- **No CRITICAL findings** → Feature validated
- **Any CRITICAL finding** → STOP, fix before proceeding
- **HIGH/MEDIUM/LOW findings** → Document, decide per-item whether to fix now or accept

---

## VALIDATION DECISION MATRIX

| Stage 1 (Spec) | Stage 2 (Quality) | Stage 3 (Red-Team) | Result |
|----------------|-------------------|-------------------|--------|
| PASS | PASS | PASS (no CRITICAL) | Feature COMPLETE — git checkpoint + compound learning |
| PASS | PASS | FAIL (CRITICAL) | Fix critical findings, re-validate Stage 3 |
| PASS | FAIL | — | Fix quality issues, re-validate from Stage 2 |
| FAIL | — | — | Implement missing requirements, re-validate from Stage 1 |

---

## POST-VALIDATION ACTIONS

### If ALL THREE Stages Pass:
1. Update features.json: `"passes": true, "status": "complete"`
2. Update features.json v5 fields: `validation_stages`, `red_team_findings`, `drift_score_at_completion`
3. Git checkpoint: `git commit -m "feat(F[N]): [description] - Nelson v5.0 iter [X]"`
4. **Compound learning extraction** (MANDATORY in v5.0):
   - Extract at least ONE pattern or anti-pattern
   - Document in handoff compound learning section
   - Add to `patterns/successes.md` or `patterns/failures.md` if reusable
   - Update `MEMORY.md` if insight is durable (lasts 10+ sessions)
5. Write handoff for next iteration (include compound transfer)

### If ANY Stage Fails:
1. Document what failed in nelson-scratchpad.local.md
2. Increment attempts counter
3. Check 3-fix rule (5 in HA-HA mode)
4. If under limit: Fix and re-validate (from the failing stage, not from scratch)
5. If at limit: Mark feature as "blocked" with detailed blocker documentation

---

## COMMON VALIDATION FAILURES

### Spec Failures:
- Missing edge case handling
- Incomplete error states
- Missing required fields
- Partial implementation

### Quality Failures:
- Test assertions incorrect
- Type mismatches
- Unused imports (lint)
- Build configuration issues

---

## VALIDATION CHECKLIST

```
[ ] Stage 1: Spec Compliance
    [ ] All requirements listed
    [ ] Each requirement verified with evidence
    [ ] Stage 1 passes

[ ] Stage 2: Quality Check
    [ ] Tests pass (0 failures)
    [ ] Lint passes (0 errors)
    [ ] Type check passes (0 errors)
    [ ] Build succeeds
    [ ] Stage 2 passes

[ ] Stage 3: Red-Team Review (v5.0)
    [ ] Input adversarial testing done
    [ ] Error cascade analysis done
    [ ] Security spot-check done
    [ ] Assumptions challenged
    [ ] No CRITICAL findings
    [ ] Stage 3 passes

[ ] Verification File (v5.0)
    [ ] nelson-verification.local.md created
    [ ] Tests section has real output
    [ ] Build section confirms success
    [ ] 3+ edge cases listed
    [ ] Self-review includes weaknesses/debt
    [ ] Red-Team section has 2+ findings
    [ ] Compound Learning section filled

[ ] Post-Validation
    [ ] Git commit created
    [ ] Compound learning extracted (pattern or anti-pattern)
    [ ] Handoff updated with compound transfer
```

---

*Run this three-stage validation protocol before claiming any feature is complete. HA-HA!*
