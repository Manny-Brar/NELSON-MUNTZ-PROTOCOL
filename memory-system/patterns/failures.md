# Failure Patterns (Anti-Patterns)

**Purpose:** Document approaches that failed so we don't repeat them.

---

## Development Anti-Patterns

### "While I'm Here..." Scope Creep
**What happened:** Started fixing unrelated issues during a task
**Why it failed:** Context exhausted, original task incomplete, messy commits
**Lesson:** Single-feature focus is sacred
**Frequency:** Common

### Claiming Done Without Testing
**What happened:** Said "this works" without running actual commands
**Why it failed:** Code had bugs that testing would have caught
**Lesson:** Run the test, show the output, THEN claim done
**Frequency:** Common

### Over-Engineering for Scale
**What happened:** Built complex solutions for "when we grow"
**Why it failed:** Wasted effort on hypothetical future needs
**Lesson:** Build for actual scale, optimize when needed
**Frequency:** Occasional

---

## Code Anti-Patterns

### Assuming Schema Without Verification
**What happened:** Wrote code assuming certain columns/tables exist
**Why it failed:** Schema was different than expected
**Lesson:** Always verify schema before writing queries
**Frequency:** Common

### Loading Full Files Instead of Searching
**What happened:** Loaded entire large files to find one section
**Why it failed:** Wasted 3000+ tokens of context window
**Lesson:** Use vector search to retrieve only relevant chunks
**Frequency:** Initial sessions

---

## Memory Anti-Patterns

### Not Writing to Memory Before Session End
**What happened:** Session ended, insights lost
**Why it failed:** Next session had to rediscover everything
**Lesson:** Always update daily log and handoff before ending
**Frequency:** Early sessions before harness pattern

### Trusting Memory Without Verification
**What happened:** Applied old fix that no longer worked
**Why it failed:** Code had changed since memory was written
**Lesson:** Verify memory against current code before applying
**Frequency:** Occasional

---

## Testing Anti-Patterns

### Testing Only Happy Path
**What happened:** Feature worked in demo, failed in production
**Why it failed:** Edge cases not tested (network errors, invalid input)
**Lesson:** Test error cases, edge cases, not just happy path
**Frequency:** Occasional

### Manual Testing Only
**What happened:** Regression introduced because no automated tests
**Why it failed:** Manual testing doesn't scale, things get missed
**Lesson:** Write tests for critical paths, at minimum
**Frequency:** Early development

---

## Communication Anti-Patterns

### Modifying Protected Files Without Permission
**What happened:** "Improved" working code that broke functionality
**Why it failed:** Code was frozen for a reason - changes not vetted
**Lesson:** Check protection status, ask before touching
**Frequency:** Early sessions

### Making Decisions Without Context
**What happened:** Made architectural change that conflicted with project goals
**Why it failed:** Didn't read context docs or understand constraints
**Lesson:** Read project context before significant decisions
**Frequency:** Occasional

---

*Add new anti-patterns when you encounter failures. Be specific about what went wrong and why. Future sessions will thank you.*
