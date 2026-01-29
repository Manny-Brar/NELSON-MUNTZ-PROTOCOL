# Nelson Protocol v4.0 - Complete Usage Guide

> **"Context is perishable. Memory is forever."**

The Nelson Protocol is a memory-augmented development system that enables AI agents to maintain context across unlimited sessions, learn from past work, and operate with maximum efficiency.

---

## Table of Contents

1. [Core Concepts](#core-concepts)
2. [Session Lifecycle](#session-lifecycle)
3. [Memory System](#memory-system)
4. [Token Optimization](#token-optimization)
5. [Tool Discovery](#tool-discovery)
6. [Best Practices](#best-practices)
7. [Command Reference](#command-reference)
8. [Integration with CLAUDE.md](#integration-with-claudemd)
9. [Troubleshooting](#troubleshooting)

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

### The Three Pillars

```
┌─────────────────────────────────────────────────────────────┐
│                    NELSON PROTOCOL v4.0                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   1. MEMORY          2. WORKFLOW         3. OPTIMIZATION     │
│   ───────────        ──────────          ─────────────────   │
│   • MEMORY.md        • session-startup   • Token-optimized   │
│   • Daily logs       • single-focus      • On-demand docs    │
│   • Patterns DB      • session-end       • MCP/Skill index   │
│   • Vector search    • ULTRATHINK        • Compressed CLAUDE │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Session Lifecycle

### Phase 1: Session Startup (MANDATORY)

Every session MUST begin with context retrieval:

```bash
# 1. Load mandatory files
Read: .nelson/NELSON_SOUL.md      # Agent identity
Read: .nelson/MEMORY.md           # Long-term knowledge
Read: .nelson/memory/YYYY-MM-DD.md # Today's log
Read: .nelson/memory/[yesterday].md # Yesterday's log

# 2. Search for task-relevant context
node .nelson/search.cjs "task keywords"

# 3. Get tool recommendations
node .nelson/tools-indexer.cjs recommend "task description"

# 4. Check patterns
Read: .nelson/patterns/successes.md
Read: .nelson/patterns/failures.md
```

**Use the `session-startup` skill to automate this.**

### Phase 2: During Work (ULTRATHINK)

For each task, follow the ULTRATHINK cycle:

```
┌─────────────────────────────────────────────────────────────┐
│                   ULTRATHINK CYCLE                           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. RECEIVE TASK                                             │
│     ↓                                                        │
│  2. RETRIEVE CONTEXT (from memory DB)                        │
│     ↓                                                        │
│  3. ULTRATHINK PLANNING                                      │
│     • Level 1: Standard analysis (what needs to be done)     │
│     • Level 2: Deep analysis (how to implement)              │
│     • Level 3: Adversarial (what could go wrong)             │
│     • Level 4: Meta (is this the best approach)              │
│     ↓                                                        │
│  4. EXECUTE (single-feature focus)                           │
│     ↓                                                        │
│  5. SELF-ASSESS                                              │
│     □ Does implementation match the goal?                    │
│     □ Did I actually test it?                                │
│     □ Would I bet money on this in production?               │
│     ↓                                                        │
│  6. UPDATE MEMORY (write learnings)                          │
│     ↓                                                        │
│  7. NEXT TASK (or end session)                               │
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
│ Context Window: 200k tokens              │
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
│ Context Window: 200k tokens              │
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

### Session Commands (Skills)

| Skill | When to Use |
|-------|-------------|
| `session-startup` | START of every session |
| `single-feature-focus` | DURING work |
| `session-completion` | END of every session |
| `nelson-protocol-v4` | Full ULTRATHINK cycle |
| `/nelson-muntz:nelson "task"` | Standard dev loop |
| `/nelson-muntz:ha-ha "task"` | Peak performance mode |

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

## The Nelson Oath

```
I will LOAD memory before starting work.
I will THINK before executing.
I will ASSESS before claiming completion.
I will WRITE insights before they're lost.
I will LEARN from both successes and failures.

Context is perishable. Memory is forever.
```

---

*Nelson Protocol v4.0 - "Others try. We triumph. HA-HA!"* 🥊
