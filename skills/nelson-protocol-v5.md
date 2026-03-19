---
name: nelson-protocol-v5
description: Harness-engineered development protocol with tiered context loading, multi-agent orchestration, self-evolving evaluation, drift detection, and compound learning
version: 5.0.0
---

# Nelson Protocol v5.0 — Harness-Engineered Development

**"The agent isn't the hard part. The harness is."**

---

## What's New in v5.0

| Feature | v4.0 | v5.0 |
|---------|------|------|
| Architecture | Memory-augmented | **Harness-engineered (scaffolding + runtime)** |
| Context loading | Load all upfront | **Tiered L0/L1/L2 progressive disclosure** |
| Agent model | Single agent | **Planner-Worker-Judge multi-agent** |
| Evaluation | Self-assessment | **Self-evolving eval loop with assertions** |
| Memory | Files + vector DB | **Graph-relational + episodic + procedural** |
| Drift prevention | Fresh context | **Active drift detection + circuit breakers** |
| Learning | Pattern recognition | **Compound engineering (each unit → easier next)** |
| Command format | `/nelson` / `/ha-ha` | **`/nelson:ha-ha 'task' --max-iterations N`** |
| Validation | Two-stage | **Three-stage + adversarial red-team review** |
| Research | On failure | **GEPA-inspired reflective prompt evolution** |
| Parallelism | Sequential | **Worktree-isolated parallel execution** |

---

## The Harness Architecture

v5.0 treats Nelson as an **agent harness** — an operating system for development agents.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    NELSON v5.0 HARNESS ARCHITECTURE                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────────────┐    │
│  │ SCAFFOLDING  │  │   RUNTIME    │  │    FEEDBACK ENGINE      │    │
│  │ (before 1st  │  │   HARNESS    │  │  (after each iteration) │    │
│  │   prompt)    │  │              │  │                         │    │
│  ├─────────────┤  ├──────────────┤  ├─────────────────────────┤    │
│  │ • Boot seq   │  │ • Tool gate  │  │ • Eval assertions       │    │
│  │ • Context    │  │ • Context    │  │ • Drift detection       │    │
│  │   assembly   │  │   curation   │  │ • Pattern extraction    │    │
│  │ • Identity   │  │ • Drift      │  │ • Memory consolidation  │    │
│  │   injection  │  │   monitor    │  │ • Compound learning     │    │
│  │ • Skill      │  │ • Compaction │  │ • GEPA reflection       │    │
│  │   discovery  │  │   trigger    │  │ • Skill evolution       │    │
│  │ • Memory     │  │ • Safety     │  │                         │    │
│  │   hydration  │  │   gates      │  │                         │    │
│  └─────────────┘  └──────────────┘  └─────────────────────────┘    │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                   EXECUTION ENGINE                            │   │
│  │                                                               │   │
│  │   PLAN ──► RESEARCH ──► EXECUTE ──► VALIDATE ──►             │   │
│  │   RED-TEAM ──► COMPOUND ──► HANDOFF ──► (next iteration)     │   │
│  │                                                               │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                  MULTI-AGENT LAYER                            │   │
│  │                                                               │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐    │   │
│  │  │ PLANNER  │  │ WORKER   │  │ JUDGE    │  │ SCOUT    │    │   │
│  │  │ (Plan)   │  │ (Execute)│  │ (Eval)   │  │ (Research)│    │   │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘    │   │
│  │                                                               │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Phase 0: Boot Sequence (Scaffolding)

**The scaffolding assembles the agent before the first prompt.**

### Step 0.1: Tiered Context Loading (L0 → L1 → L2)

Context is loaded progressively to minimize token waste:

```
L0 — METADATA (~100 tokens each)
  Scan available resources: titles, descriptions, relevance scores
  Decision: which resources merit deeper loading?

L1 — OVERVIEW (~500 tokens each)
  Load summaries of selected resources
  Decision: which resources need full content?

L2 — FULL CONTENT (variable)
  Load complete content ONLY for resources needed NOW
  Everything else stays at L0/L1 until demanded
```

**Implementation:**
```
1. L0 scan: Read MEMORY.md index (first 200 lines)
2. L0 scan: Read NELSON_SOUL.md first section (identity)
3. L1 load: Task-relevant memory entries (search by keywords)
4. L1 load: Yesterday's daily log summary
5. L2 defer: Full skill files (load only when triggered)
6. L2 defer: Pattern library (load on wall encounter)
7. L2 defer: Full documentation (load on knowledge gap)
```

**Token Budget:**
```
L0 scan total: ~300 tokens (vs. 18,000+ loading everything)
L1 selective: ~2,000 tokens (only relevant entries)
L2 on-demand: loaded just-in-time during execution
SAVINGS: ~80-90% reduction in startup context overhead
```

### Step 0.2: Identity Injection

```bash
# Load identity core (L1 — overview only at boot)
# Full L2 identity loads only for ambiguous decisions
cat .nelson/NELSON_SOUL.md | head -50  # Core principles only
```

### Step 0.3: Skill Discovery

```
# Auto-detect available skills without loading them
# Each skill stays at L0 until the task triggers it
Skills available: [list names + one-line descriptions]
RAG skills: [detected if .claude/skills/rag/ exists]
Domain skills: [detected from plugin skills/]
```

### Step 0.4: State Hydration

```bash
# Load loop state (always — small file)
cat .claude/nelson-loop.local.md

# Load handoff (always — critical for continuity)
cat .claude/nelson-handoff.local.md

# Load scratchpad (L1 — summary section only)
head -30 .claude/nelson-scratchpad.local.md
```

---

## Phase 1: ULTRATHINK Planning (Enhanced)

**Every non-trivial task requires 5-level thinking BEFORE execution.**

### Level 1: Standard Analysis
```
What does this task require?
- Input → Output → Steps
```

### Level 2: Deep Analysis
```
Edge cases, dependencies, risks?
- What relies on this? What does this rely on?
```

### Level 3: Adversarial Analysis
```
What could go wrong? How would I break this?
- Failure modes, security, performance, integration
```

### Level 4: Meta Analysis
```
Is this the best approach? What would a 10x engineer do?
- Alternatives, simplification, future impact
```

### Level 5: Compound Analysis (NEW in v5.0)
```
How does this make the NEXT iteration easier?
- What reusable patterns emerge?
- What context should persist for future agents?
- What institutional knowledge does this create?
- How does this reduce total project complexity?
```

**Write all 5 levels to nelson-scratchpad.local.md. This is the reasoning trail.**

---

## Phase 2: Multi-Agent Orchestration

v5.0 introduces role-specialized agents for complex tasks.

### The Planner-Worker-Judge Pattern

```
┌──────────┐     ┌──────────┐     ┌──────────┐
│ PLANNER  │────►│ WORKER   │────►│  JUDGE   │
│          │     │          │     │          │
│ Reads    │     │ Implements│     │ Evaluates│
│ codebase,│     │ single   │     │ output   │
│ decides  │     │ feature  │     │ against  │
│ approach │     │ in clean │     │ spec +   │
│          │     │ context  │     │ quality  │
└──────────┘     └──────────┘     └──────────┘
      │                                 │
      │         ┌──────────┐           │
      └────────►│  SCOUT   │◄──────────┘
                │          │
                │ Parallel │
                │ research │
                │ on demand│
                └──────────┘
```

### When to Deploy Multi-Agent

```
SINGLE AGENT (default for most tasks):
  - Simple bug fixes
  - Well-understood patterns
  - Routine implementations

MULTI-AGENT (activate for):
  - Tasks spanning 3+ files in different domains
  - Competing implementation approaches to evaluate
  - Research-heavy tasks with knowledge gaps
  - Cross-layer changes (frontend + backend + DB)
```

### Parallel Research Scouts

For knowledge-intensive tasks, spawn parallel scouts:
```
Use Agent tool with subagent_type="Explore" to:
  Scout A: Research approach feasibility
  Scout B: Check existing codebase patterns
  Scout C: Search for best practices

Scouts run in parallel → synthesize findings → inform Worker
```

### Worktree Isolation (NEW in v5.0)

For parallel feature work, use git worktree isolation:
```
Use Agent tool with isolation="worktree" to:
  - Each feature gets its own isolated copy of the repo
  - No file conflicts between parallel workers
  - Changes merge back only on successful validation
  - Automatic cleanup if agent makes no changes
```

---

## Phase 3: Execute (Single-Feature Focus)

### The Iron Rule (Unchanged)
```
ONE TASK AT A TIME
Complete it → Commit it → Verify it → THEN move on
```

### Incremental Validation Checkpoints

After EVERY significant change (not just at the end):
```bash
# Quick check after each logical unit
npm run test 2>&1 | tail -5
npm run lint 2>&1 | tail -5

# If EITHER fails: Stop. Fix. Then continue.
# Do NOT accumulate broken state.
```

### Context Budget Monitoring

Track token usage during execution:
```
If context feels heavy (slow responses, 2+ hours elapsed):
  1. Write critical state to scratchpad
  2. Trigger pre-compaction flush
  3. Commit working code
  4. Prepare handoff with specific next steps
```

---

## Phase 4: Three-Stage Validation (Enhanced from v4.0)

### Stage 1: Spec Compliance
```
□ Does implementation match ALL requirements?
□ Are acceptance criteria met point-by-point?
□ Cross-reference handoff with actual code changes
```

### Stage 2: Quality Assurance
```
□ Tests pass with actual output shown
□ Lint clean
□ Build succeeds
□ Type checking passes
□ 3+ edge cases addressed
```

### Stage 3: Adversarial Red-Team Review (NEW in v5.0)
```
□ How would I break this?
  - Invalid inputs: what happens?
  - Concurrent access: race conditions?
  - Error cascade: what fails downstream?
  - Security: injection, XSS, auth bypass?

□ What did I assume that could be wrong?
  - Dependencies that might change
  - State that might not exist
  - Ordering that might differ

□ What would a hostile code reviewer flag?
  - Unnecessary complexity
  - Missing error handling
  - Implicit assumptions
  - Test coverage gaps
```

### Verification Document

Write to `.claude/nelson-verification.local.md`:
```markdown
## Verification - [Feature Name] - [Timestamp]

### Stage 1: Spec ✅/❌
- [Requirement]: [PASS/FAIL with evidence]

### Stage 2: Quality ✅/❌
- Tests: [X passed, Y failed] (output: ...)
- Build: [PASS/FAIL]
- Lint: [PASS/FAIL]

### Stage 3: Red-Team ✅/❌
- Attack vector tested: [what] → [result]
- Assumption challenged: [what] → [still valid/invalidated]
- Hostile review finding: [what] → [addressed/accepted risk]

### Decision: PASS / FAIL / BLOCKED
```

---

## Phase 5: Compound Learning Engine (NEW in v5.0)

**Each iteration MUST make the next iteration easier.**

### The Compound Loop

```
PLAN → WORK → REVIEW → COMPOUND
                          │
                          ├── What reusable pattern emerged?
                          ├── What context should persist?
                          ├── What mistake should never repeat?
                          ├── What shortcut was discovered?
                          └── How does this reduce future complexity?
```

### Compound Artifacts

After each successful feature, generate:

```markdown
## Compound Learning - [Feature] - [Timestamp]

### Pattern Extracted
**Name:** [descriptive name]
**Context:** When [situation arises]
**Solution:** [what to do]
**Evidence:** [file:line where this worked]

### Anti-Pattern Discovered
**Name:** [descriptive name]
**Trap:** [what seems right but isn't]
**Why:** [root cause]
**Better:** [correct approach]

### Context for Future Agents
**Key Decision:** [what was decided and why]
**Dependency:** [what this relies on]
**Gotcha:** [non-obvious thing that matters]
```

### Memory Consolidation

At iteration end, consolidate learnings:
```
1. Extract durable insights → MEMORY.md
2. Extract patterns → .nelson/patterns/
3. Extract anti-patterns → .nelson/patterns/failures.md
4. Update skill files if improved approach found
5. Prune stale entries from daily logs
```

---

## Phase 6: Self-Evolving Evaluation (NEW in v5.0)

Inspired by GEPA (Genetic-Pareto Reflective Evolution).

### Execution Trace Analysis

After each iteration, analyze the full execution trace:
```
1. Read the iteration's tool calls, results, and reasoning
2. Identify friction points (where things slowed down)
3. Identify delight points (where things went smoothly)
4. Extract Actionable Side Information (ASI):
   - Why did attempt N fail? (not just "it failed")
   - What diagnostic signal was available but missed?
   - What could the prompt/skill have said to prevent this?
```

### Skill Refinement Loop

```
FOR each skill file used this iteration:
  1. Did the skill's guidance help? (binary: yes/no)
  2. If no: what was missing?
  3. If yes: was there unnecessary content?
  4. Propose targeted update to skill file
  5. Test updated skill against past failures
  6. Accept if improved, reject if regressed
```

### Protocol Self-Assessment

Every 5 iterations, run meta-evaluation:
```
□ Is the protocol itself causing friction?
□ Are there phases that consistently add no value?
□ Are there gaps where failures keep recurring?
□ Should any phase be expanded/contracted?

Document findings in .nelson/protocol-evolution.md
```

---

## Phase 7: Drift Detection & Circuit Breakers (NEW in v5.0)

### Drift Indicators

Monitor for these degradation signals:
```
WARNING signs (proceed with caution):
  - Responses getting slower
  - Repeating same approach that already failed
  - Scope creeping beyond current feature
  - Skipping validation steps
  - Vague handoff documentation

CRITICAL signs (trigger circuit breaker):
  - Same error 3+ times without new approach
  - Context window > 80% capacity
  - Feature attempt count exceeds limit
  - 35+ minutes without meaningful progress
  - Test suite degrading (fewer passing than before)
```

### Circuit Breakers

When critical drift detected:
```
CIRCUIT BREAKER PROTOCOL:
  1. STOP current work immediately
  2. Commit any salvageable progress
  3. Write detailed state to scratchpad
  4. Prepare emergency handoff (compact format)
  5. Signal for fresh context iteration
  6. Do NOT continue in degraded state
```

### Fresh Context as Primary Defense

Nelson's core insight remains valid: **fresh context windows (up to 1M tokens with Opus 4.6) are the best defense against drift.**

v5.0 adds active monitoring to trigger fresh contexts BEFORE drift causes failures, not after.

---

## Phase 8: Handoff (Enhanced)

### The Four Critical Questions (< 30 seconds to parse)

```markdown
# Nelson Handoff - Iteration [N]

## 1. What was accomplished?
- [Feature]: [COMPLETE/PARTIAL/BLOCKED]
- Files changed: [specific paths with line numbers]
- Commits: [hash] [message]

## 2. What's the current state?
- Tests: [X/Y passing]
- Build: [PASS/FAIL]
- Blockers: [none / specific blocker]

## 3. What's the immediate next step?
- Task: [exact task description]
- Start at: [file:line]
- Approach: [specific strategy, not vague]

## 4. What critical context matters?
- Decision: [key decision made and why]
- Gotcha: [non-obvious thing to know]
- Pattern: [what worked that should be repeated]

## 5. Compound Learning (NEW in v5.0)
- Pattern extracted: [name → where documented]
- Anti-pattern found: [name → where documented]
- Iteration difficulty: [1-10] → [why]
```

### Emergency Handoff (when context is critical)

```markdown
# EMERGENCY HANDOFF - Iteration [N]
STATE: [working/broken/blocked]
NEXT: [exact single action]
CRITICAL: [one sentence of must-know context]
FILES: [changed files list]
```

---

## Activation & Command Format

### Standard Nelson
```bash
/nelson-muntz:nelson "task description" --max-iterations N
```

### HA-HA Mode (Peak Performance)
```bash
/nelson:ha-ha "task description" --max-iterations N
```

### Options
| Option | Description | Default |
|--------|-------------|---------|
| `--max-iterations N` | Stop after N iterations | 16 |
| `--completion-promise 'TEXT'` | Signal completion phrase | none |
| `--model MODEL` | Claude model | opus |
| `--delay N` | Seconds between iterations | 3 |
| `--ha-ha` | Enable all v5 enhancements | false |
| `--parallel` | Enable worktree-isolated parallel agents | false |

---

## Configuration

```json
{
  "version": "5.0.0",
  "mode": "ha-ha",
  "harness": {
    "context_loading": "tiered",
    "drift_detection": true,
    "circuit_breaker": true,
    "compound_learning": true
  },
  "thinking": {
    "depth": "maximum",
    "levels": 5,
    "compound_analysis": true
  },
  "validation": {
    "stages": 3,
    "red_team_review": true,
    "incremental_checks": true
  },
  "research": {
    "mandatory_preflight": true,
    "auto_on_failure": true,
    "gepa_reflection": true,
    "max_searches_per_wall": 10
  },
  "agents": {
    "planner_worker_judge": true,
    "parallel_scouts": true,
    "worktree_isolation": false
  },
  "evaluation": {
    "self_evolving": true,
    "skill_refinement": true,
    "meta_review_interval": 5
  },
  "persistence": {
    "max_attempts_per_feature": 5,
    "auto_research_on_failure": true,
    "checkpoint_frequency": "every_significant_change",
    "compound_artifacts": true
  }
}
```

---

## The v5.0 Oath

```
I will SCAFFOLD before executing.
I will LOAD context progressively, not greedily.
I will PLAN with 5 levels of analysis.
I will EXECUTE one feature at a time.
I will VALIDATE with three stages including adversarial review.
I will COMPOUND — each iteration makes the next easier.
I will DETECT drift before it causes failure.
I will EVOLVE my own skills based on execution traces.
I will LEARN from both success and failure.
I will HAND OFF with specificity, not narrative.

The harness is the hard part. The agent follows.
```

---

## Migration from v4.0

v5.0 is backwards-compatible with v4.0 state files. Enhancements activate progressively:

1. **Immediate**: Tiered context loading, 5-level ULTRATHINK, compound analysis
2. **When HA-HA active**: Three-stage validation, multi-agent orchestration, GEPA reflection
3. **When --parallel flag**: Worktree isolation, parallel scouts
4. **Always on**: Drift detection, circuit breakers, compound learning

---

*Nelson Protocol v5.0: Harness-Engineered Development for Autonomous Peak Performance*
*"2026 is the year we learned the agent isn't the hard part — the harness is."*
