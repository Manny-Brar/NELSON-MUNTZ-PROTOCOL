---
name: nelson-validate
description: "Two-stage validation protocol for Nelson Muntz iterations"
---

# Nelson Validate - Two-Stage Validation Protocol

## Purpose
Execute structured validation to ensure feature completeness and code quality before marking a feature as complete.

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

### Step 5: Create Verification File (v3.3.1)
Create `.claude/nelson-verification.local.md`:
```markdown
## Tests
[Actual test output - must show pass/fail counts]

## Build
[Build result - must contain success/pass/complete]

## Edge Cases
1. [Edge case 1 handled]
2. [Edge case 2 handled]
3. [Edge case 3 handled]

## Self-Review
[Weaknesses, technical debt, TODOs, criticism]

## Git Status
[Current git status]
```

**Note:** The stop hook validates content quality. Weak sections get REJECTED.

### Stage 2 Gate
- **All checks pass** → Feature COMPLETE
- **Any check fails** → STOP, fix issues first

---

## VALIDATION DECISION MATRIX

| Stage 1 (Spec) | Stage 2 (Quality) | Result |
|----------------|-------------------|--------|
| PASS | PASS | Feature COMPLETE - Git checkpoint |
| PASS | FAIL | Fix quality issues, re-validate |
| FAIL | - | Implement missing requirements |

---

## POST-VALIDATION ACTIONS

### If BOTH Stages Pass:
1. Update features.json: `"passes": true, "status": "complete"`
2. Git checkpoint: `git commit -m "feat(F[N]): [description] - Nelson iter [X]"`
3. Update config.json stats
4. Write handoff for next iteration

### If ANY Stage Fails:
1. Document what failed in nelson-scratchpad.local.md
2. Increment attempts counter
3. Check 3-fix rule (5 in HA-HA mode)
4. If under limit: Fix and re-validate
5. If at limit: Mark feature as "blocked"

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

[ ] Verification Challenge (v3.3.1)
    [ ] nelson-verification.local.md created
    [ ] Tests section has real output
    [ ] Build section confirms success
    [ ] 3+ edge cases listed
    [ ] Self-review includes weaknesses/debt

[ ] Post-Validation
    [ ] Git commit created
    [ ] Handoff updated
```

---

*Run this validation protocol before claiming any feature is complete.*
