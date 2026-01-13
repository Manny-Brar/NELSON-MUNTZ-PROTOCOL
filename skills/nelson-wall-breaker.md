---
name: nelson-wall-breaker
description: "Auto-research protocol when hitting obstacles in Nelson Muntz iterations"
---

# Nelson Wall-Breaker - Obstacle Research Protocol

## Purpose
Systematically identify, classify, and break through obstacles using targeted web research instead of blind retry attempts.

---

## THE WALL-BREAKER PHILOSOPHY

**Never retry without new information.**

When you hit a wall:
1. STOP attempting the same approach
2. CLASSIFY the wall type
3. RESEARCH targeted solutions
4. DOCUMENT findings
5. APPLY new knowledge
6. TRY AGAIN with informed approach

---

## WALL CLASSIFICATION

### 🔴 ERROR WALL
**Symptoms:** Exception, error message, stack trace, crash
**Examples:**
- `TypeError: Cannot read property 'x' of undefined`
- Build failure with specific error
- Test assertion failure

**Research Strategy:**
```
Search: "[exact error message]"
Search: "[error code] [framework] solution"
Search: "[library name] [error type] fix"
```

---

### 🟠 KNOWLEDGE WALL
**Symptoms:** Don't know how to do something, unfamiliar API/pattern
**Examples:**
- "How do I implement JWT refresh tokens?"
- "What's the pattern for Supabase RLS policies?"
- "How does this library handle X?"

**Research Strategy:**
```
Search: "[technology] [specific task] tutorial 2025"
Search: "[library] [feature] example"
Search: "[framework] best practices [topic]"
```

---

### 🟡 DESIGN WALL
**Symptoms:** Multiple valid approaches, unsure which is best
**Examples:**
- "Should I use REST or GraphQL?"
- "State management: Context vs Redux vs Zustand?"
- "Database schema: normalized vs denormalized?"

**Research Strategy:**
```
Search: "[option A] vs [option B] [use case] 2025"
Search: "[technology] architecture patterns"
Search: "[domain] best practices comparison"
```

---

### 🟢 DEPENDENCY WALL
**Symptoms:** Library conflict, version mismatch, missing package
**Examples:**
- Package not found
- Version incompatibility
- Deprecated API

**Research Strategy:**
```
Search: "[package name] alternative"
Search: "[package] version [X] compatibility"
Search: "[error] npm/yarn [package name]"
```

---

### 🔵 COMPLEXITY WALL
**Symptoms:** Task is too big, unclear where to start, overwhelming
**Examples:**
- Feature feels impossible
- Too many moving parts
- Analysis paralysis

**Research Strategy:**
```
Search: "[complex task] step by step guide"
Search: "[big feature] implementation breakdown"
Search: "[topic] simplified tutorial beginner"
```

Then: Decompose into smaller sub-problems

---

## WALL-BREAKER PROTOCOL

### Step 1: Recognize the Wall
Stop when you notice:
- Same error appearing repeatedly
- Trying random things hoping they work
- Feeling stuck or frustrated
- Time spent > expected with no progress

### Step 2: Classify the Wall
Ask: "What TYPE of wall is this?"
- Error message? → 🔴 ERROR WALL
- Don't know how? → 🟠 KNOWLEDGE WALL
- Multiple options? → 🟡 DESIGN WALL
- Package issues? → 🟢 DEPENDENCY WALL
- Too complex? → 🔵 COMPLEXITY WALL

### Step 3: Formulate Search Queries
Based on wall type, create 3-5 targeted searches:

```markdown
## Wall-Breaker Research Log

**Wall Type:** [🔴/🟠/🟡/🟢/🔵]
**Problem:** [1-sentence description]

**Search Queries:**
1. [query 1]
2. [query 2]
3. [query 3]
```

### Step 4: Execute Research
Use WebSearch tool with each query:
```
WebSearch: "[your query]"
```

### Step 5: Document Findings
Add to scratchpad.md:

```markdown
## Wall-Breaker: [Problem Title]
**Type:** [wall type]
**Time:** [timestamp]

### Problem
[What was happening]

### Research Findings
1. **[Source 1]**: [key insight]
2. **[Source 2]**: [key insight]
3. **[Source 3]**: [key insight]

### Solution
[What to try based on research]

### Result
[Did it work? Y/N - What happened]
```

### Step 6: Apply and Retry
- Implement the researched solution
- If it works → Document the pattern
- If it fails → Research again with new info

---

## RESEARCH QUERY TEMPLATES

### For Errors:
```
"[exact error message] site:stackoverflow.com"
"[error code] [framework] solution"
"[library] [error] github issues"
"[error] fix 2025"
```

### For How-To:
```
"[task] tutorial [framework] 2025"
"[library] [feature] example code"
"[framework] [pattern] implementation"
"how to [specific task] in [technology]"
```

### For Decisions:
```
"[option A] vs [option B] when to use"
"[technology] architecture decision [domain]"
"[pattern] pros cons [use case]"
"best [type] for [specific scenario] 2025"
```

### For Dependencies:
```
"[package] alternative npm"
"[package] [version] breaking changes"
"[package A] [package B] compatibility"
"[framework] recommended [package type]"
```

---

## ESCALATION LADDER

If research doesn't break the wall:

**Attempt 1:** Basic search (error message, how-to)
**Attempt 2:** Refined search (add framework, version, context)
**Attempt 3:** Alternative search (different keywords, related concepts)
**Attempt 4:** Official docs + GitHub issues
**Attempt 5 (HA-HA only):** Decompose problem, research sub-problems

After max attempts → Mark feature as BLOCKED with research notes

---

## WALL-BREAKER CHECKLIST

```
[ ] Recognized I'm hitting a wall (not just slow)
[ ] Classified the wall type
[ ] Created targeted search queries
[ ] Executed searches (3-5 minimum)
[ ] Documented findings in scratchpad.md
[ ] Applied researched solution
[ ] Updated approach based on findings
[ ] Recorded whether solution worked
```

---

## SCRATCHPAD INTEGRATION

Wall-Breaker findings should ALWAYS go in scratchpad.md:

```markdown
# .claude/ralph-v3/scratchpad.md

## Wall-Breaker Log

### [Timestamp] - 🔴 ERROR: JWT Validation Failure

**Problem:** `JsonWebTokenError: jwt malformed`

**Research:**
- jwt.io debugger shows token is valid
- Stack Overflow: Often caused by Bearer prefix
- GitHub issue: Need to strip "Bearer " before verify

**Solution:** Added `token.replace('Bearer ', '')` before verify

**Result:** FIXED - Tests passing now

---

### [Timestamp] - 🟡 DESIGN: Auth State Management

**Problem:** Where to store auth state in React?

**Research:**
- Context API: Simple, built-in, good for small apps
- Zustand: Lightweight, devtools, persists easily
- Supabase has built-in auth helpers

**Decision:** Using Supabase auth helpers + Context for user object

**Rationale:** Supabase handles tokens, Context for simple sharing

---
```

---

## PATTERN LIBRARY

As you break walls, build a pattern library:

```markdown
## Patterns Discovered

### JWT Token Handling
- Always strip "Bearer " prefix before verification
- Store in httpOnly cookie for security
- Refresh tokens should be longer-lived

### Supabase RLS
- Always wrap auth.uid() in (select auth.uid())
- Index tenant_id columns for performance
- Use security definer functions for cross-table checks

### React State
- For auth: Use Supabase helpers + Context
- For server state: TanStack Query
- For UI state: useState or Zustand
```

---

*When stuck, don't retry blindly. Research, document, then retry with knowledge.*
