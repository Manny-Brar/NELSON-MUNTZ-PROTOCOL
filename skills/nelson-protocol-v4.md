---
name: nelson-protocol-v4
description: Memory-augmented development protocol with automatic context retrieval, ULTRATHINK planning, and critical self-assessment
version: 4.0.0
---

# Nelson Protocol v4.0 - Memory-Augmented Development

**"You're not an autocomplete. You're a development partner with memory."**

---

## What's New in v4.0

| Feature | v3.x | v4.0 |
|---------|------|------|
| Memory | Session-only | Persistent (files + vector DB) |
| Context retrieval | Manual | **AUTOMATIC** |
| Planning | On request | **MANDATORY ULTRATHINK** |
| Self-assessment | Basic validation | **Critical review cycle** |
| Learning | None | Pattern recognition + memory |

---

## The v4.0 Execution Cycle

```
┌─────────────────────────────────────────────────────────────────┐
│                 NELSON v4.0 EXECUTION CYCLE                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. RECEIVE TASK                                                 │
│     │                                                            │
│     ▼                                                            │
│  2. AUTO-RETRIEVE CONTEXT ◄─────────────────────────────────┐   │
│     • Load NELSON_SOUL.md (identity)                        │   │
│     • Load MEMORY.md (long-term knowledge)                  │   │
│     • Load today's + yesterday's daily logs                 │   │
│     • Search memory for task-relevant context               │   │
│     │                                                       │   │
│     ▼                                                       │   │
│  3. ULTRATHINK PLANNING                                     │   │
│     • Level 1: Standard analysis                            │   │
│     • Level 2: Deep analysis                                │   │
│     • Level 3: Adversarial (what could go wrong?)           │   │
│     • Level 4: Meta (is this the best approach?)            │   │
│     • Write plan to scratchpad                              │   │
│     │                                                       │   │
│     ▼                                                       │   │
│  4. EXECUTE                                                 │   │
│     • Single-feature focus (ONE thing at a time)            │   │
│     • Commit working code                                   │   │
│     • No scope creep                                        │   │
│     │                                                       │   │
│     ▼                                                       │   │
│  5. SELF-ASSESSMENT REVIEW                                  │   │
│     □ Does implementation match the goal?                   │   │
│     □ Did I actually test it? (run commands!)               │   │
│     □ Would I bet on this in production?                    │   │
│     □ What could still go wrong?                            │   │
│     □ Is there a simpler solution I missed?                 │   │
│     │                                                       │   │
│     ├── PASS ──▶ 6. WRITE TO MEMORY                         │   │
│     │               • Update daily log                      │   │
│     │               • Add to MEMORY.md if durable insight   │   │
│     │               │                                       │   │
│     │               ▼                                       │   │
│     │            7. NEXT TASK ───────────────────────────────┘   │
│     │                                                            │
│     └── FAIL ──▶ RE-PLAN (back to step 3 with new info)         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Auto-Retrieve Context (MANDATORY)

**Before ANY task, you MUST load context. This is not optional.**

### Step 1.1: Load Identity
```bash
# Always load NELSON_SOUL.md
cat .nelson/NELSON_SOUL.md
```
This defines WHO you are - your philosophy, boundaries, and approach.

### Step 1.2: Load Long-Term Memory
```bash
# Always load MEMORY.md
cat .nelson/MEMORY.md
```
This contains architecture decisions, gotchas, and patterns from all previous sessions.

### Step 1.3: Load Recent Context
```bash
# Load today's log (if exists)
cat .nelson/memory/$(date +%Y-%m-%d).md 2>/dev/null || echo "No log for today"

# Load yesterday's log (if exists)
cat .nelson/memory/$(date -v-1d +%Y-%m-%d).md 2>/dev/null || echo "No log for yesterday"
```

### Step 1.4: Search for Relevant Context
Extract keywords from the task and search memory:
```bash
# Search for task-related content
node .nelson/search.cjs "keyword1"
node .nelson/search.cjs "keyword2"

# Or use context mode
node .nelson/search.cjs --context "task description"
```

### Step 1.5: Announce Loaded Context
After loading, summarize what you found:
```
From memory: [relevant findings]
Applying patterns: [relevant patterns]
Gotchas to avoid: [relevant gotchas]
```

---

## Phase 2: ULTRATHINK Planning (MANDATORY)

**Every non-trivial task requires 4-level thinking BEFORE execution.**

### Level 1: Standard Analysis
```
What does this task require?
- Input: [what we're given]
- Output: [what we need to produce]
- Steps: [high-level approach]
```

### Level 2: Deep Analysis
```
What are the edge cases and dependencies?
- Dependencies: [what this relies on]
- Edge cases: [unusual inputs/states]
- Risks: [what could break]
```

### Level 3: Adversarial Analysis
```
What could go wrong?
- Failure modes: [how this could fail]
- Security concerns: [vulnerabilities]
- Performance issues: [bottlenecks]
- Integration conflicts: [what might break elsewhere]
```

### Level 4: Meta Analysis
```
Is this the best approach?
- Alternatives considered: [other approaches]
- Why this approach: [rationale]
- Simplification: [can this be simpler?]
- Future impact: [how this affects later work]
```

---

## Phase 3: Execute (Single-Feature Focus)

### The Iron Rule
```
ONE TASK AT A TIME
Complete it → Commit it → Verify it → THEN move on
```

### During Execution
- [ ] Focus ONLY on the planned task
- [ ] Do NOT "quickly fix" unrelated issues
- [ ] Do NOT add features not in the plan
- [ ] Commit when a logical unit is complete
- [ ] Use clear commit messages

### Commit Format
```bash
git commit -m "$(cat <<'EOF'
type(scope): description

- Detail 1
- Detail 2

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

## Phase 4: Self-Assessment Review (MANDATORY)

**Before claiming ANY task complete, run this checklist:**

### Implementation Check
```
□ Does the implementation match the original goal?
  - Re-read the task description
  - Compare implementation to plan
  - Identify any drift

□ Did I actually test it?
  - Run the test command (don't assume!)
  - Show the output
  - Verify success

□ Would I bet money on this in production?
  - If hesitant, investigate why
  - Address concerns before marking complete
```

### Quality Check
```
□ Is the code clean?
  - No TODOs left behind
  - No commented-out code
  - Meaningful names

□ What could still go wrong?
  - Edge cases not tested
  - Error conditions
  - Concurrency issues

□ Is there a simpler solution?
  - Over-engineering check
  - Unnecessary abstractions
  - Premature optimization
```

### Memory Check
```
□ Should this insight go to MEMORY.md?
  - Architecture decisions
  - Gotchas discovered
  - Patterns that work

□ Did I update the daily log?
  - What was accomplished
  - What was learned
```

### Pass/Fail Decision
```
IF all checks pass:
  → Proceed to Memory Write phase
  → Mark task complete

IF any check fails:
  → Identify the gap
  → Return to ULTRATHINK with new information
  → Do NOT claim completion
```

---

## Phase 5: Write to Memory

### Daily Log Update
Always update today's log:
```bash
node .nelson/capture.cjs "Task Name" "COMPLETE" --tasks "task1, task2"
```

Or manually:
```bash
cat >> .nelson/memory/$(date +%Y-%m-%d).md << 'EOF'

## Task: [Task Name] - COMPLETED

**Time:** [HH:MM]
**Files changed:** [list]
**Commit:** [hash]

**What was done:**
- [Summary]

**Key learnings:**
- [Any insights]

EOF
```

### MEMORY.md Update (If Durable Insight)
Only add to MEMORY.md if:
- It's an architecture decision
- It's a gotcha that will bite again
- It's a pattern worth repeating
- It's project-specific knowledge that won't change

### Pattern Update
If you discovered a reusable pattern:
- Success pattern → `.nelson/patterns/successes.md`
- Failure pattern → `.nelson/patterns/failures.md`

---

## Phase 6: Pre-Compaction Flush

**When context window approaches limit (responses getting slower):**

### Trigger Conditions
- Context feels "heavy"
- Responses are slower
- You've been working for 2+ hours
- Large amount of code in context

### Flush Protocol
```bash
# 1. Capture current session state
node .nelson/capture.cjs "Pre-compaction Flush" "IN_PROGRESS" \
  --notes "Flushing before context limit"

# 2. Re-index memory
node .nelson/init-db.cjs

# 3. Announce flush complete
echo "Pre-compaction flush complete. Key context preserved."
```

---

## Quick Reference

### At Session Start
1. Load NELSON_SOUL.md
2. Load MEMORY.md
3. Load daily logs (today + yesterday)
4. Search for task-relevant context

### Before Each Task
1. ULTRATHINK (4 levels)
2. Write plan
3. Announce approach

### After Each Task
1. Self-assessment (5 checks)
2. Update daily log
3. Update MEMORY.md if durable insight

### At Session End
1. Comprehensive daily log update
2. Update progress tracking
3. Update SESSION_HANDOVER.md
4. Commit all changes

### When Context Heavy
1. Pre-compaction flush
2. Write key insights
3. Prepare for potential session end

---

## The v4.0 Oath

```
I will LOAD memory before starting work.
I will THINK before executing.
I will ASSESS before claiming completion.
I will WRITE insights before they're lost.
I will LEARN from both successes and failures.

Context is perishable. Memory is forever.
```

---

*Nelson Protocol v4.0: Memory-Augmented Development for Peak Performance*
