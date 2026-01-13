# Nelson Muntz - Auto-Research Protocol

## Purpose

When Nelson encounters obstacles, errors, or knowledge gaps, this protocol automatically triggers research to find solutions rather than blindly retrying failed approaches.

**Principle:** "Research before retry. Intelligence over persistence."

---

## TRIGGER CONDITIONS

Auto-research activates when ANY of these occur:

```
┌─────────────────────────────────────────────────────────────────┐
│  TRIGGER                           │  RESEARCH TYPE             │
├────────────────────────────────────┼────────────────────────────┤
│  Test failure                      │  Error Resolution          │
│  Build error                       │  Error Resolution          │
│  Lint error (non-trivial)          │  Best Practices            │
│  Type error                        │  Error Resolution          │
│  Runtime exception                 │  Error Resolution          │
│  "I don't know how to..."          │  Knowledge Acquisition     │
│  Multiple approaches possible      │  Decision Research         │
│  Same error twice                  │  Deep Dive Research        │
│  Third attempt on same feature     │  Comprehensive Research    │
│  Dependency issue                  │  Alternative Search        │
│  Performance problem               │  Optimization Research     │
└────────────────────────────────────┴────────────────────────────┘
```

---

## RESEARCH TYPES

### 1. Error Resolution Research

**Triggered by:** Test failure, build error, runtime exception, type error

**Search Sequence:**
```
1. WebSearch: "[exact error message]"
2. WebSearch: "[error message] [language/framework] solution"
3. WebSearch: "[error message] github issue"
4. WebSearch: "[error message] stack overflow"
5. WebSearch: "[error code] fix [year]"
```

**Parse Results For:**
- Root cause explanation
- Step-by-step fix
- Common mistakes that cause this
- Prevention strategies

**Document in scratchpad.md:**
```markdown
## Error Research: [Error Type]

**Error:** [Exact message]
**Search Query:** [What I searched]
**Root Cause:** [Why this happens]
**Solution:** [How to fix]
**Prevention:** [How to avoid in future]
```

---

### 2. Knowledge Acquisition Research

**Triggered by:** "I don't know how to...", unfamiliar technology, new pattern needed

**Search Sequence:**
```
1. WebSearch: "how to [task] [technology] tutorial"
2. WebSearch: "[task] [technology] best practices 2025"
3. WebSearch: "[task] [technology] example code"
4. WebFetch: [official documentation URL if known]
5. WebSearch: "[task] [technology] guide"
```

**Parse Results For:**
- Step-by-step instructions
- Code examples
- Common pitfalls
- Recommended libraries/tools

**Document in scratchpad.md:**
```markdown
## Knowledge Acquired: [Topic]

**Goal:** [What I needed to learn]
**Key Steps:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Code Pattern:**
```[language]
[example code]
```

**Gotchas:**
- [Pitfall 1]
- [Pitfall 2]

**Source:** [URL or search query]
```

---

### 3. Decision Research

**Triggered by:** Multiple valid approaches, architectural choice, library selection

**Search Sequence:**
```
1. WebSearch: "[option A] vs [option B] [context]"
2. WebSearch: "[option A] pros cons"
3. WebSearch: "[option B] pros cons"
4. WebSearch: "when to use [option A] vs [option B]"
5. WebSearch: "[option A] [option B] comparison 2025"
```

**Parse Results For:**
- Tradeoffs of each approach
- Use case recommendations
- Performance differences
- Community preference/support

**Document in scratchpad.md:**
```markdown
## Decision Research: [Choice]

**Options Evaluated:**

| Criteria        | Option A | Option B | Option C |
|-----------------|----------|----------|----------|
| Performance     | [rating] | [rating] | [rating] |
| Complexity      | [rating] | [rating] | [rating] |
| Maintainability | [rating] | [rating] | [rating] |
| Community       | [rating] | [rating] | [rating] |
| Fit for Project | [rating] | [rating] | [rating] |

**Decision:** [Selected option]
**Reasoning:** [Why this is best for our context]
```

---

### 4. Deep Dive Research

**Triggered by:** Same error twice, persistent issue, complex bug

**Search Sequence:**
```
1. WebSearch: "[problem] deep dive"
2. WebSearch: "[problem] root cause analysis"
3. WebSearch: "[problem] debugging [technology]"
4. WebSearch: "[problem] internals [technology]"
5. WebSearch: "[technology] [problem] comprehensive guide"
6. WebFetch: [GitHub issues for related library]
7. WebSearch: "[problem] [technology] blog post"
```

**Parse Results For:**
- Underlying cause (not just symptoms)
- Debugging strategies
- Internal workings that explain behavior
- Similar cases and their resolutions

**Document in scratchpad.md:**
```markdown
## Deep Dive: [Problem]

**Surface Symptom:** [What appears to be wrong]
**Underlying Cause:** [Actual root cause]

**Investigation Path:**
1. [What I checked first]
2. [What I discovered]
3. [What led to root cause]

**The Real Fix:** [Solution that addresses root cause]

**Why Other Fixes Fail:** [Why surface-level fixes don't work]
```

---

### 5. Comprehensive Research

**Triggered by:** Third attempt on same feature, blocked feature

**Search Sequence:**
```
# Start broad, get specific
1. WebSearch: "[feature type] implementation guide [technology]"
2. WebSearch: "[feature type] architecture patterns"
3. WebSearch: "[feature type] [technology] tutorial 2025"
4. WebSearch: "[feature type] common mistakes"
5. WebSearch: "[feature type] [technology] github example"

# Get specific to our blockers
6. WebSearch: "[specific blocker 1] solution"
7. WebSearch: "[specific blocker 2] workaround"

# Look for alternatives
8. WebSearch: "[feature type] alternative approach"
9. WebSearch: "[feature type] simpler implementation"
10. WebSearch: "[feature type] [technology] library"
```

**Parse Results For:**
- Complete implementation strategies
- Working example repositories
- Alternative approaches we haven't tried
- Libraries that solve this problem
- Simplification opportunities

**Document in scratchpad.md:**
```markdown
## Comprehensive Research: [Feature]

**Attempts So Far:**
1. [Approach 1] - Failed because [reason]
2. [Approach 2] - Failed because [reason]

**New Approaches Found:**
1. [New approach 1] - [Description and source]
2. [New approach 2] - [Description and source]
3. [New approach 3] - [Description and source]

**Recommended Path Forward:** [Best new approach]

**If All Else Fails:** [Fallback strategy or accept blocked]
```

---

### 6. Alternative Search

**Triggered by:** Dependency issue, library limitation, external blocker

**Search Sequence:**
```
1. WebSearch: "[dependency] alternatives"
2. WebSearch: "[dependency] replacement [technology]"
3. WebSearch: "[what dependency does] without [dependency]"
4. WebSearch: "[dependency] workaround"
5. WebSearch: "best [type of tool] [technology] 2025"
```

**Parse Results For:**
- Drop-in replacements
- Alternative libraries
- Native implementations
- Workarounds

**Document in scratchpad.md:**
```markdown
## Alternative Search: [Dependency]

**Original Dependency:** [Name and what it does]
**Problem:** [Why we can't use it]

**Alternatives Found:**
1. [Alternative 1]
   - Pros: [List]
   - Cons: [List]
   - Migration effort: [Low/Medium/High]

2. [Alternative 2]
   - Pros: [List]
   - Cons: [List]
   - Migration effort: [Low/Medium/High]

**Workarounds Found:**
- [Workaround 1]
- [Workaround 2]

**Recommendation:** [Best path forward]
```

---

### 7. Optimization Research

**Triggered by:** Performance problem, slow tests, resource issues

**Search Sequence:**
```
1. WebSearch: "[technology] performance optimization"
2. WebSearch: "[specific operation] slow [technology]"
3. WebSearch: "[technology] profiling guide"
4. WebSearch: "[technology] performance best practices 2025"
5. WebSearch: "[operation] optimization techniques"
```

**Parse Results For:**
- Profiling techniques
- Common performance pitfalls
- Optimization strategies
- Benchmarking approaches

**Document in scratchpad.md:**
```markdown
## Optimization Research: [Performance Issue]

**Problem:** [What's slow and how slow]
**Profiling Results:** [What profiling revealed]

**Optimization Strategies Found:**
1. [Strategy 1] - Expected improvement: [X%]
2. [Strategy 2] - Expected improvement: [X%]
3. [Strategy 3] - Expected improvement: [X%]

**Implementation Plan:**
1. [First optimization to try]
2. [Measure improvement]
3. [If needed, try next optimization]
```

---

## RESEARCH EXECUTION RULES

### Rule 1: Research Before Retry
```
NEVER retry a failed approach without new information.
If approach fails → Research → Try informed solution.
```

### Rule 2: Document Everything
```
ALL research findings go in scratchpad.md.
Future iterations can read your research.
Don't make next iteration re-discover what you learned.
```

### Rule 3: Synthesize, Don't Copy
```
Don't blindly copy Stack Overflow answers.
Understand WHY the solution works.
Adapt to our specific context.
```

### Rule 4: Verify Sources
```
Prefer official documentation over random blogs.
Check dates - solutions from 2020 may be outdated.
Look for multiple sources confirming same solution.
```

### Rule 5: Time-Box Research
```
Max 5 searches per research type.
If 5 searches don't help → Try different angle.
If 15 total searches don't help → Mark as blocked with research notes.
```

---

## INTEGRATION WITH ITERATION LOOP

### Standard Mode
- Auto-research triggers on second failure of same issue
- Max 3 research rounds per feature
- Research notes in scratchpad.md

### HA-HA Mode
- Auto-research triggers on FIRST failure
- Pre-research MANDATORY before implementation
- Max 5 research rounds per feature
- Comprehensive documentation required

---

## RESEARCH QUALITY CHECKLIST

Before concluding research, verify:

- [ ] Found at least 2 sources confirming solution
- [ ] Understand WHY solution works (not just WHAT to do)
- [ ] Solution is compatible with our tech stack
- [ ] Solution is recent (2024-2025 preferred)
- [ ] Documented findings in scratchpad.md
- [ ] Identified how to prevent this issue in future

---

## EXAMPLE RESEARCH SESSION

**Situation:** Tests failing with "ReferenceError: fetch is not defined"

**Research Execution:**
```
Step 1: Classify - This is an ERROR WALL
Step 2: Search sequence:
  - "ReferenceError fetch is not defined" → Node.js doesn't have fetch natively
  - "ReferenceError fetch is not defined jest" → Need to polyfill in tests
  - "jest fetch polyfill 2025" → Use whatwg-fetch or node-fetch
  - "jest setup fetch mock" → Configure in jest.setup.js

Step 3: Document findings:
  Root cause: Node.js <18 doesn't have native fetch
  Solution: Add fetch polyfill to jest.setup.js
  Prevention: Always check Node.js version compatibility

Step 4: Implement informed solution
Step 5: Verify fix works
Step 6: Add to pattern library for future reference
```

---

## PROTOCOL SUMMARY

```
┌─────────────────────────────────────────────────────────────────┐
│                    AUTO-RESEARCH FLOW                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   Encounter Obstacle                                            │
│          ↓                                                      │
│   Classify Trigger Type                                         │
│          ↓                                                      │
│   Execute Research Sequence (5-10 searches)                     │
│          ↓                                                      │
│   Parse and Synthesize Results                                  │
│          ↓                                                      │
│   Document in scratchpad.md                                     │
│          ↓                                                      │
│   Apply Informed Solution                                       │
│          ↓                                                      │
│   Verify Success                                                │
│          ↓                                                      │
│   Add to Pattern Library (if novel)                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Remember:** The smartest approach isn't trying harder - it's learning faster.
