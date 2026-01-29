# Success Patterns

**Purpose:** Document approaches that worked well for reuse in future sessions.

---

## Development Patterns

### Single-Feature Focus
**When:** Any task
**Pattern:** ONE task at a time, complete → commit → verify → next
**Why it works:** Prevents context exhaustion, ensures clean commits
**Evidence:** Sessions without this pattern had more bugs, incomplete work

### Pre-Compaction Memory Flush
**When:** Context window approaching limit
**Pattern:** Write key insights to memory BEFORE compaction
**Why it works:** Prevents knowledge loss during automatic summarization
**Evidence:** Moltbot architecture, validated by Anthropic research

### ULTRATHINK Before Complex Tasks
**When:** Multi-step or unfamiliar work
**Pattern:** 4-level analysis (standard → deep → adversarial → meta)
**Why it works:** Catches edge cases, finds simpler solutions, prevents rework
**Evidence:** HA-HA mode produces higher quality output

---

## Code Patterns

### Verify Before Implementing
**When:** Any code change based on assumptions
**Pattern:** Check current state first, don't assume code structure
**Why it works:** Assumptions are often wrong; verification catches this early
**Evidence:** Multiple sessions avoided rework by checking first

### Commit Small, Commit Often
**When:** Making any code changes
**Pattern:** Commit after each logical unit of work
**Why it works:** Easier to rollback, cleaner history, less lost work
**Evidence:** Large uncommitted changes lead to lost work on failures

---

## Debugging Patterns

### Check the Actual Data/Schema
**When:** Database query fails or returns unexpected results
**Pattern:** Query the schema or data directly, don't trust documentation
**Why it works:** Documentation is often outdated; data doesn't lie
**Evidence:** Multiple bugs caught by verifying actual schema

### Verify Assumptions
**When:** Something "should" work but doesn't
**Pattern:** List assumptions, verify each one systematically
**Why it works:** Usually one assumption is wrong; systematic check finds it
**Evidence:** Faster debugging when done systematically

---

## Testing Patterns

### Run the Command, Don't Assume
**When:** Claiming something works
**Pattern:** Actually run test/build/curl, show output
**Why it works:** Words lie, output doesn't
**Evidence:** Multiple "it works" claims disproven by actual tests

---

## Documentation Patterns

### Update Memory Before Session End
**When:** Every session
**Pattern:** Write daily log + update MEMORY.md if durable insight
**Why it works:** Knowledge persists across sessions
**Evidence:** Sessions with good handoff are more productive

### Commit Message Format
**When:** Every commit
**Pattern:** `type(scope): description` + Co-Authored-By footer
**Why it works:** Clear history, credit where due
**Evidence:** Git log is readable and traceable

---

*Add new patterns when you discover approaches that work. Keep entries concise and evidence-based.*
