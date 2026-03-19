# Nelson Protocol v5.1 — Complete Usage Guide

> **"The agent isn't the hard part. The harness is."**

The Nelson Protocol is a **harness-engineered** development system with a **Phase-Gate Execution Engine** that wraps AI agents with strategic multi-phase decomposition, mandatory 4-gate cycles (Execute → Self-Assess → Test → Document), tiered context loading, drift detection, compound learning, multi-agent orchestration, and self-evolving evaluation — enabling peak performance across unlimited iterations.

---

## Table of Contents

1. [Core Concepts](#core-concepts)
2. [Phase-Gate Execution Engine](#phase-gate-execution-engine)
3. [Session Lifecycle](#session-lifecycle)
4. [Memory System](#memory-system)
5. [Token Optimization](#token-optimization)
6. [Drift Detection](#drift-detection)
7. [Compound Learning](#compound-learning)
8. [Multi-Agent Orchestration](#multi-agent-orchestration)
9. [Tool Discovery](#tool-discovery)
10. [Eval Assertions](#eval-assertions)
11. [Best Practices](#best-practices)
12. [Command Reference](#command-reference)
13. [Migration from v4](#migration-from-v4)
14. [Integration with CLAUDE.md](#integration-with-claudemd)
15. [Troubleshooting](#troubleshooting)

---

## Core Concepts

### The Problem Nelson Solves

AI agents work in discrete sessions with no memory of previous work. This leads to:
- **Repeated mistakes** - Same errors across sessions
- **Lost context** - Insights discovered but forgotten
- **Wasted tokens** - Re-explaining the same things
- **Inconsistent work** - No continuity between sessions

### The Nelson Solution

1. **Persistent Memory** - SQLite database with FTS5 full-text search
2. **Session Continuity** - Structured handoff between sessions
3. **Pattern Learning** - Document successes and failures
4. **Token Optimization** - On-demand retrieval instead of loading everything
5. **Auto-Indexing** - Git hooks keep memory current

### The Five Pillars (v5.0)

```
┌─────────────────────────────────────────────────────────────┐
│                    NELSON PROTOCOL v5.0                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. HARNESS           2. MEMORY          3. WORKFLOW         │
│  ────────────         ───────────        ──────────          │
│  • Scaffolding        • MEMORY.md        • Tiered boot       │
│  • Runtime engine     • Daily logs       • 5-level THINK     │
│  • Drift detection    • Patterns DB      • 3-stage validate  │
│  • Circuit breaker    • Vector search    • Single-feature    │
│  • Tool detection     • Obsidian graph   • Compound learn    │
│                                                              │
│  4. OPTIMIZATION      5. EVALUATION                          │
│  ─────────────────    ──────────────                         │
│  • L0/L1/L2 tiered   • Binary assertions                    │
│  • On-demand docs     • Execution traces                     │
│  • Compressed CLAUDE  • GEPA reflection                      │
│  • ~87% token save    • Skill evolution                      │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Phase-Gate Execution Engine (v5.1)

The Phase-Gate Engine is the **master orchestrator** for HA-HA mode. Every request is automatically processed through it.

### How It Works

```
1. DECOMPOSE: Break request into strategic multi-phase plan (5-level ULTRATHINK)
2. SELF-ASSESS: Critically evaluate plan for gaps, risks, enhancements → revise
3. FOR EACH PHASE:
   Gate A — EXECUTE: Complete all tasks in the phase
   Gate B — SELF-ASSESS: Research best practices, identify gaps/improvements, fix them
   Gate C — TEST: All tests must pass, apply fixes, retest until green
   Gate D — DOCUMENT: Update ALL affected docs, cross-reference overlapping workflows
   → Phase gate checkpoint: all 4 gates must pass before advancing
4. REPEAT until all phases complete
```

### Strategic Decomposition

Every request — even simple ones — gets decomposed into phases:
- **Simple requests:** 1-2 phases (still go through gate cycle)
- **Medium requests:** 3-4 phases
- **Complex requests:** 5+ phases with dependency mapping

Each phase gets:
- Detailed task list with acceptance criteria
- Success criteria (measurable)
- Risk assessment with mitigations
- Documentation impact analysis

### The 4 Gates

| Gate | Purpose | Passes When |
|------|---------|-------------|
| A. Execute | Complete the work | All tasks done, acceptance criteria met |
| B. Self-Assess | Quality check + improve | Gaps identified and fixed, best practices researched |
| C. Test | Verify correctness | All tests pass, lint clean, build succeeds |
| D. Document | Update all docs | ALL affected docs updated, cross-references verified |

**Gate B is critical.** It's not a rubber stamp — the agent must genuinely research best practices for the work done, identify gaps, and implement improvements before proceeding to testing.

**Gate D requires documentation awareness.** The agent must identify EVERY document affected by the phase's changes, including docs that reference overlapping workflows, patterns, or data flows.

See `skills/nelson-phase-gate.md` for the complete protocol with templates and checklists.

---

## Session Lifecycle

### Phase 1: Boot Sequence — Tiered Context Loading (MANDATORY)

Every session MUST begin with progressive context loading:

```bash
# L0 — METADATA (always load, ~300 tokens)
Read: .claude/nelson-loop.local.md       # Loop state
Read: .claude/nelson-handoff.local.md    # Previous iteration context
Read: head -30 .nelson/NELSON_SOUL.md    # Identity core (first section)
Read: head -40 .nelson/MEMORY.md         # Memory index (first 40 lines)

# L1 — OVERVIEW (selective, ~2000 tokens)
Read: head -30 .claude/nelson-scratchpad.local.md  # Recent reasoning
Search: node .nelson/search.cjs "task keywords"     # Task-relevant context
Read: head -20 .nelson/memory/YYYY-MM-DD.md         # Today's log summary

# L2 — FULL CONTENT (on-demand, loaded at trigger points)
# Load skill files ONLY when their trigger fires:
#   Hit an error → Read skills/nelson-wall-breaker.md
#   Feature done → Read skills/nelson-validate.md
#   Writing handoff → Read skills/nelson-handoff.md
#   Working on UI → Read skills/frontend-ui-ux.md
```

**v5 vs v4:** Token savings of ~87% at startup. v4 loaded ~18,000 tokens upfront; v5 loads ~2,300 tokens via tiered L0/L1/L2.

**If Obsidian MCP available:** Replace L1 keyword search with graph-aware search via `mcp__obsidian__search`.

### Phase 2: During Work (5-Level ULTRATHINK + v5 Harness)

For each task, follow the v5.0 execution cycle:

```
┌─────────────────────────────────────────────────────────────┐
│                NELSON v5.0 EXECUTION CYCLE                   │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. RECEIVE TASK                                             │
│     ↓                                                        │
│  2. RETRIEVE CONTEXT (tiered L0/L1/L2 loading)               │
│     ↓                                                        │
│  3. 5-LEVEL ULTRATHINK PLANNING                              │
│     • Level 1: Standard (what needs to be done)              │
│     • Level 2: Deep (edge cases, dependencies)               │
│     • Level 3: Adversarial (what could go wrong)             │
│     • Level 4: Meta (is this the best approach)              │
│     • Level 5: Compound (how does this make NEXT easier)     │
│     ↓                                                        │
│  4. EXECUTE (single-feature focus)                           │
│     ↓                                                        │
│  5. THREE-STAGE VALIDATION                                   │
│     □ Stage 1: Spec compliance (requirements met?)           │
│     □ Stage 2: Quality (tests/lint/build/types pass?)        │
│     □ Stage 3: Red-team review (how would I break this?)     │
│     ↓                                                        │
│  6. COMPOUND LEARNING                                        │
│     □ Extract pattern or anti-pattern                        │
│     □ Document in handoff compound section                   │
│     ↓                                                        │
│  7. DRIFT CHECK (score 0-10)                                 │
│     □ Score < 7 → Continue                                   │
│     □ Score >= 7 → CIRCUIT BREAKER (fresh context)           │
│     ↓                                                        │
│  8. UPDATE MEMORY (write learnings to correct tier)          │
│     ↓                                                        │
│  9. HANDOFF (with compound learning transfer)                │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Phase 3: Session End (MANDATORY)

Before ending a session:

```bash
# 1. Commit all code changes
git add . && git commit -m "description"

# 2. Update daily log
Edit: .nelson/memory/YYYY-MM-DD.md
# Add: Tasks completed, decisions made, insights discovered

# 3. Update patterns if applicable
Edit: .nelson/patterns/successes.md  # New patterns that worked
Edit: .nelson/patterns/failures.md   # Anti-patterns discovered

# 4. Update MEMORY.md for durable insights
Edit: .nelson/MEMORY.md  # Only for insights that will matter in 10+ sessions

# 5. Push changes
git push origin main
```

**Use the `session-completion` skill to automate this.**

---

## Memory System

### File Structure

```
.nelson/
├── NELSON_SOUL.md           # Agent identity (read every session)
├── MEMORY.md                # Curated long-term knowledge
├── context-loader.md        # Auto-retrieval instructions
├── memory.db                # SQLite vector database
│
├── memory/
│   ├── template.md          # Daily log template
│   ├── 2026-01-29.md        # Today's log
│   └── [YYYY-MM-DD].md      # Historical logs
│
├── patterns/
│   ├── successes.md         # What works
│   └── failures.md          # What to avoid
│
├── init-db.cjs              # Database initialization
├── search.cjs               # Smart search v3.0
├── capture.cjs              # Session capture
├── tools-indexer.cjs        # MCP/skill discovery
└── mcp-skill-docs-extractor.cjs  # Token optimizer
```

### What Goes Where

| Content Type | Location | When to Update |
|--------------|----------|----------------|
| Project architecture | MEMORY.md | When major decisions made |
| API quirks/gotchas | MEMORY.md | When discovered |
| Today's work | memory/YYYY-MM-DD.md | Every session |
| Patterns that work | patterns/successes.md | When pattern proven 3+ times |
| Anti-patterns | patterns/failures.md | When mistake made |
| Agent personality | NELSON_SOUL.md | Rarely (identity is stable) |

### Search Commands

```bash
# Basic search
node .nelson/search.cjs "webhook tenant_id"

# Search by section header
node .nelson/search.cjs --header "Security Rules"

# Get context for a task (auto-extracts keywords)
node .nelson/search.cjs --context "fix the stripe webhook"

# Search in specific file
node .nelson/search.cjs "query" --file MEMORY.md

# List all sessions
node .nelson/search.cjs --list-sessions

# Full section retrieval (header to header)
node .nelson/search.cjs "query" --section
```

### Indexing

```bash
# Re-index all files (incremental - skips unchanged)
node .nelson/init-db.cjs

# Force full re-index
node .nelson/init-db.cjs --force

# Index priority:
# 1. CLAUDE.md         (1.0)
# 2. NELSON_SOUL.md    (0.95)
# 3. MEMORY.md         (0.9)
# 4. patterns/*.md     (0.85)
# 5. memory/*.md       (0.8)
# 6. README.md         (0.75)
# 7. docs/**/*.md      (0.6-0.7)
```

---

## Token Optimization

### The Problem

A typical CLAUDE.md file can be 20,000+ tokens. With MCPs adding another 14,000 tokens, you lose 17%+ of your context window before doing any work.

### The Solution

Store detailed documentation in the database and retrieve on-demand:

```
BEFORE (Traditional):
┌─────────────────────────────────────────┐
│ Context Window: 1M tokens              │
├─────────────────────────────────────────┤
│ CLAUDE.md:        20,000 tokens (10%)   │
│ MCP Tools:        14,000 tokens (7%)    │
│ System:           20,000 tokens (10%)   │
│ Autocompact:      33,000 tokens (16%)   │
│ ─────────────────────────────────────── │
│ FREE SPACE:       113,000 tokens (57%)  │
└─────────────────────────────────────────┘

AFTER (Token-Optimized):
┌─────────────────────────────────────────┐
│ Context Window: 1M tokens              │
├─────────────────────────────────────────┤
│ CLAUDE.optimized: 1,700 tokens (1%)     │
│ MCP Tools:        14,000 tokens (7%)    │
│ System:           20,000 tokens (10%)   │
│ Autocompact:      33,000 tokens (16%)   │
│ ─────────────────────────────────────── │
│ FREE SPACE:       131,300 tokens (66%)  │
│                                          │
│ SAVINGS: +18,300 tokens (+16% more!)    │
└─────────────────────────────────────────┘
```

### How It Works

1. **Compress CLAUDE.md** - Keep essentials, move details to DB
2. **On-demand retrieval** - Fetch relevant docs when needed
3. **Tool indexing** - Store MCP/skill docs with smart keywords

### Commands

```bash
# Extract tool docs to database
node .nelson/mcp-skill-docs-extractor.cjs extract

# Retrieve docs for a specific task
node .nelson/mcp-skill-docs-extractor.cjs retrieve "stripe payment"

# Analyze context usage
node .nelson/context-optimizer.cjs analyze

# Generate compressed CLAUDE.md
node .nelson/context-optimizer.cjs compress-claude
```

---

## Tool Discovery

### The Problem

With 80+ MCP tools and dozens of skills, how do you know which one to use?

### The Solution

The tools-indexer extracts keywords from tool definitions and recommends relevant tools based on your task.

### How It Works

```
Task: "Create a Stripe payment link for a customer"
         ↓
    Keyword Extraction
         ↓
    Keywords: stripe, payment, link, customer
         ↓
    Database Search (tools_fts)
         ↓
    Results:
    1. mcp__stripe__create_payment_link (95% match)
    2. mcp__stripe__create_customer (80% match)
    3. skill:twilio-number-provisioning (20% match)
```

### Commands

```bash
# Sync all MCPs and skills
node .nelson/tools-indexer.cjs sync

# Get recommendations for a task
node .nelson/tools-indexer.cjs recommend "configure vapi assistant"

# List all indexed tools
node .nelson/tools-indexer.cjs list

# List by type
node .nelson/tools-indexer.cjs list --type mcp
node .nelson/tools-indexer.cjs list --type skill

# Watch for new tools (run after adding MCP/skill)
node .nelson/tools-indexer.cjs watch
```

### Auto-Detection

When you add a new MCP or skill:
1. Run `node .nelson/tools-indexer.cjs watch`
2. It detects new tools automatically
3. Extracts keywords from names, descriptions, parameters
4. Indexes for future recommendations

---

## Drift Detection

### What is Agent Drift?

Agent drift is the progressive degradation of decision quality, instruction following, and output coherence over extended sessions. Research shows every agent experiences success rate decrease after 35 minutes, and doubling task duration quadruples failure rate.

### Drift Scoring (0-10)

The stop hook calculates drift from:
- Edit count this iteration (+1 at 20+, +2 at 30+)
- Unique files touched (+1 at 5+, +2 at 8+)
- Iteration count (+1 at 5+, +2 at 10+)
- Session duration (+1 at 35min+, +2 at 60min+)

| Score | Status | Action |
|-------|--------|--------|
| 0-2 | HEALTHY | Continue normally |
| 3-4 | WATCH | Monitor, consider compaction |
| 5-6 | WARNING | Prepare for fresh context |
| 7+ | CIRCUIT BREAKER | Auto-triggers recovery prompt |

### Circuit Breaker Protocol

When drift >= 7, the stop hook automatically:
1. Injects a recovery prompt with behavioral anchors
2. Resets the edit tracker for fresh metrics
3. Instructs the agent to re-read handoff from scratch
4. Prevents inheriting degraded assumptions

**Nelson's core insight: fresh context windows (up to 1M tokens with Opus 4.6) are the primary defense against drift. v5 adds active monitoring to trigger fresh contexts BEFORE drift causes failures.**

See: `skills/nelson-drift-detection.md` for full protocol.

---

## Compound Learning

### The Compound Principle

Traditional development accumulates technical debt — each feature makes the next harder. Compound engineering inverts this by extracting learnings that accelerate future work.

```
WITHOUT compound: F1 (45 min) → F2 (50 min) → F3 (60 min) ← debt accumulates
WITH compound:    F1 (45 min) → F2 (35 min) → F3 (20 min) ← knowledge accelerates
```

### After Each Feature Completion

1. **Extract** pattern or anti-pattern from the work
2. **Document** in handoff compound learning section
3. **Classify** as durable (MEMORY.md) or temporal (daily log)
4. **Consolidate** with existing entries (don't duplicate)

### Compound Artifacts

```markdown
## Pattern: [Name]
Context: When [situation]
Solution: [What worked]
Evidence: [file:line]

## Anti-Pattern: [Name]
Trap: [What seems right but isn't]
Better: [What to do instead]
```

### Memory Consolidation (every 5 iterations)

```bash
# Check memory health
node .nelson/consolidate.cjs --stats

# Find duplicate entries
node .nelson/consolidate.cjs --find-dupes

# Trim MEMORY.md to 200 lines
node .nelson/consolidate.cjs --trim
```

See: `skills/nelson-compound-learning.md` for full protocol.

---

## Multi-Agent Orchestration

### The Planner-Worker-Judge-Scout Pattern

v5.0 introduces 4 specialized subagents for complex tasks:

| Agent | Model | Role | Tools |
|-------|-------|------|-------|
| **nelson-planner** | Sonnet | Analyze, plan, decompose | Read-only |
| **nelson-worker** | Opus | Implement single feature | Full access |
| **nelson-judge** | Opus | Three-stage validation | Read + Bash |
| **nelson-scout** | Haiku | Web research, intelligence | Read + Web |

### When to Use Multi-Agent

- **Single agent (default):** Simple bugs, well-understood patterns, routine work
- **Multi-agent:** Cross-layer changes, competing approaches, research-heavy tasks, complex features

### Workflow

```
User task → Planner analyzes → Worker implements → Judge validates
                                    ↑                      │
                                    └── Scout researches ←──┘ (if walls hit)
```

### Worktree Isolation

With `--parallel` flag, each worker gets an isolated git worktree:
- No file conflicts between parallel agents
- Changes merge only on successful validation
- Automatic cleanup if no changes made

See: `agents/nelson-planner.md`, `nelson-worker.md`, `nelson-judge.md`, `nelson-scout.md`

---

## Eval Assertions

### Binary Assertion Framework

v5.0 includes `scripts/eval-assertions.sh` — a test suite for protocol compliance:

```bash
# Run all assertions
./scripts/eval-assertions.sh --verbose

# Run specific category
./scripts/eval-assertions.sh --category quality

# JSON output for automation
./scripts/eval-assertions.sh --json

# CI mode (exit 1 on failure)
./scripts/eval-assertions.sh --ci
```

### Assertion Categories

| Category | Checks | Count |
|----------|--------|-------|
| Protocol | Loop state, v5 version, handoff, planning, scope | 5 |
| Quality | Verification file, 3 stages, edge cases, self-review, git | 7 |
| Compound | Compound in verification/handoff, patterns, reasoning trail | 4 |
| Drift | Edit tracker, velocity, file spread, circuit breaker threshold | 4 |
| Handoff | Exists, substance, file paths, next action, conciseness | 5 |

Each assertion returns PASS, FAIL, or SKIP with detail strings.

### Self-Evolving Evaluation (GEPA-Inspired)

Every 5 iterations, analyze execution traces:
1. **Sample** tool calls, decisions, and outcomes
2. **Reflect** on what guidance helped vs. hindered
3. **Propose** targeted skill revisions
4. **Validate** revision doesn't contradict other skills
5. **Apply** or defer with comment for human review

See: `skills/nelson-self-evolving-eval.md` for full protocol.

---

## Best Practices

### 1. Always Start with Memory

```
❌ WRONG:
User: "Fix the webhook"
Agent: *starts coding immediately*

✅ CORRECT:
User: "Fix the webhook"
Agent:
1. Search: node .nelson/search.cjs "webhook"
2. Load relevant context from MEMORY.md
3. Check patterns/failures.md for past webhook issues
4. THEN start working
```

### 2. Single Feature Focus

```
❌ WRONG:
"Let me fix the webhook, and while I'm here I'll also
refactor the error handling and add some tests..."

✅ CORRECT:
"I'll fix the webhook first, commit it, then move to
the next task if there's time."
```

### 3. Self-Assess Before Claiming Done

```
Before saying "Done!":
□ Did I actually run the tests?
□ Did I see them pass with my own eyes?
□ Would I bet $100 this works in production?
□ What could still go wrong?
```

### 4. Write Memory Before It's Lost

```
❌ WRONG:
*Discovers important gotcha*
*Keeps working*
*Session ends*
*Gotcha forgotten forever*

✅ CORRECT:
*Discovers important gotcha*
*Immediately writes to MEMORY.md or daily log*
*Continues working*
*Knowledge preserved for future sessions*
```

### 5. Use On-Demand Retrieval

```
❌ WRONG:
"Let me load the entire CLAUDE.md to understand the MCP operations..."

✅ CORRECT:
"Let me retrieve the relevant MCP docs for this task..."
node .nelson/mcp-skill-docs-extractor.cjs retrieve "stripe"
```

---

## Command Reference

### Memory Commands

| Command | Description |
|---------|-------------|
| `node .nelson/search.cjs "query"` | Search memory database |
| `node .nelson/search.cjs --header "Name"` | Find section by header |
| `node .nelson/search.cjs --context "task"` | Auto-retrieve for task |
| `node .nelson/search.cjs --list-sessions` | List all sessions |
| `node .nelson/search.cjs --section` | Return full sections |
| `node .nelson/init-db.cjs` | Re-index (incremental) |
| `node .nelson/init-db.cjs --force` | Force full re-index |

### Tool Commands

| Command | Description |
|---------|-------------|
| `node .nelson/tools-indexer.cjs sync` | Sync all MCPs/skills |
| `node .nelson/tools-indexer.cjs recommend "task"` | Get tool recommendations |
| `node .nelson/tools-indexer.cjs list` | List indexed tools |
| `node .nelson/tools-indexer.cjs watch` | Detect new tools |
| `node .nelson/mcp-skill-docs-extractor.cjs extract` | Extract tool docs to DB |
| `node .nelson/mcp-skill-docs-extractor.cjs retrieve "query"` | Retrieve tool docs |

### Optimization Commands

| Command | Description |
|---------|-------------|
| `node .nelson/context-optimizer.cjs analyze` | Analyze context usage |
| `node .nelson/context-optimizer.cjs compress-claude` | Generate compressed CLAUDE.md |
| `node .nelson/context-optimizer.cjs mcp-profile` | Show MCP profile options |

### v5.0 Commands

| Command | Description |
|---------|-------------|
| `./scripts/eval-assertions.sh` | Run binary assertions for protocol compliance |
| `./scripts/eval-assertions.sh --json` | JSON output for automation |
| `node .nelson/obsidian-bridge.cjs status` | Check Obsidian MCP availability |
| `node .nelson/obsidian-bridge.cjs sync-patterns` | Sync patterns to Obsidian vault |
| `node .nelson/obsidian-bridge.cjs hubs` | Find most-connected knowledge nodes |
| `node .nelson/consolidate.cjs` | Run memory consolidation |
| `node .nelson/consolidate.cjs --stats` | Memory health dashboard |
| `node .nelson/consolidate.cjs --find-dupes` | Detect duplicate entries |
| `node .nelson/consolidate.cjs --trim` | Trim MEMORY.md to 200 lines |

### Loop Commands

| Command | Description |
|---------|-------------|
| `/nelson-muntz:ha-ha "task"` | v5 HA-HA mode (primary format) |
| `/nelson-muntz:nelson "task"` | Standard dev loop |
| `/nelson-muntz:ha-ha "task"` | Peak performance mode |
| `/nelson-muntz:nelson-status` | Check status + drift score |
| `/nelson-muntz:nelson-stop` | Stop loop + cleanup |

### Session Skills

| Skill | When to Use |
|-------|-------------|
| `nelson-protocol-v5` | Full v5 harness protocol |
| `nelson-compound-learning` | After feature completion |
| `nelson-drift-detection` | When feeling slow/stuck |
| `nelson-self-evolving-eval` | Every 5 iterations |
| `nelson-integrations-v5` | Setting up Obsidian/GWS |

---

## Integration with CLAUDE.md

### Recommended Structure

Your CLAUDE.md should include this section to enable Nelson:

```markdown
## 🧠 NELSON MEMORY SYSTEM (MANDATORY)

**Before ANY task:**
1. Read `.nelson/MEMORY.md` (long-term knowledge)
2. Check today's log `.nelson/memory/YYYY-MM-DD.md`
3. Search: `node .nelson/search.cjs "keywords"`
4. Only THEN begin work

**For tool discovery:**
```bash
node .nelson/tools-indexer.cjs recommend "task description"
node .nelson/mcp-skill-docs-extractor.cjs retrieve "service name"
```

**Update memory:**
- Session end → daily log
- Major discovery → MEMORY.md
- Pattern proven → patterns/successes.md
- Mistake made → patterns/failures.md
```

### Token-Optimized CLAUDE.md

Use the compressed version that keeps essentials and retrieves details on-demand:

```bash
# Generate optimized version
node .nelson/context-optimizer.cjs compress-claude

# Review it
cat CLAUDE.optimized.md

# If satisfied, replace
mv CLAUDE.md CLAUDE.original.md
mv CLAUDE.optimized.md CLAUDE.md
```

---

## Troubleshooting

### "Database not found"

```bash
# Initialize the database
node .nelson/init-db.cjs
```

### "better-sqlite3 not installed"

```bash
npm install better-sqlite3
```

### Search returns no results

```bash
# Re-index with force flag
node .nelson/init-db.cjs --force
```

### Tools not being detected

```bash
# Check MCP config location
cat ~/.claude.json

# Force sync
node .nelson/tools-indexer.cjs sync
```

### Memory not loading

Ensure your session starts with:
1. Reading NELSON_SOUL.md
2. Reading MEMORY.md
3. Reading today's daily log
4. Searching for task-relevant context

Use the `session-startup` skill to automate this.

---

## Migration from v4

### Zero-Effort Migration

v5.0 is fully backwards-compatible with v4.0:

- All v4 state files work unchanged
- All v5 fields are optional with defaults
- v5 features activate progressively

### What Activates When

| Feature | When Active |
|---------|-------------|
| Tiered L0/L1/L2 loading | Immediately (new boot sequence) |
| 5-level ULTRATHINK | Immediately (compound analysis added) |
| Edit tracker / drift scoring | Immediately (stop hook v5) |
| Three-stage validation | HA-HA mode |
| Compound learning extraction | HA-HA mode |
| GEPA self-evolving evaluation | HA-HA mode (every 5 iterations) |
| Worktree-isolated parallel agents | `--parallel` flag |
| Obsidian graph memory | When Obsidian MCP detected (port 22360) |
| GWS workspace orchestration | When `gws` CLI installed |
| Eval assertions | Manual (`./scripts/eval-assertions.sh`) |

### No Config Changes Needed

Update the plugin and v5 kicks in. The setup script auto-detects tools and initializes v5 state files automatically.

---

## The Nelson Oath (v5.0)

```
I will SCAFFOLD before executing.
I will LOAD context progressively, not greedily.
I will THINK five levels deep before every action.
I will VALIDATE three ways before claiming completion.
I will COMPOUND — each iteration makes the next easier.
I will DETECT drift before it causes failure.
I will WRITE insights before they're lost.

The harness is the hard part. The agent follows.
```

---

*Nelson Protocol v5.1 — "The agent isn't the hard part. The harness is. HA-HA!"* 🥊
