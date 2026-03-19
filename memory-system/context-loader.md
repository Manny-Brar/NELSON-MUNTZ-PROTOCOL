# Nelson v5.0 — Tiered Context Loader

## Purpose

This file defines the **tiered L0/L1/L2 context loading protocol** for Nelson v5.0. Context is loaded progressively — not all at once — to minimize token waste and maximize signal density.

**Core principle:** Find the smallest set of high-signal tokens that maximize desired outcomes.

---

## The Three Tiers

```
┌─────────────────────────────────────────────────────────────┐
│  L0 — METADATA SCAN (~100 tokens each)                       │
│  Always loaded. Titles, descriptions, relevance scores.      │
│  Purpose: Decide what deserves deeper loading.               │
├─────────────────────────────────────────────────────────────┤
│  L1 — OVERVIEW (~500 tokens each)                            │
│  Selectively loaded. Summaries of relevant resources.        │
│  Purpose: Inform planning without full content overhead.     │
├─────────────────────────────────────────────────────────────┤
│  L2 — FULL CONTENT (variable)                                │
│  On-demand only. Complete file contents.                     │
│  Purpose: Deep reading when actively needed.                 │
└─────────────────────────────────────────────────────────────┘

Token budget comparison:
  v4 (load everything): ~18,000+ tokens at startup
  v5 (tiered loading):  ~2,300 tokens at startup (87% reduction)
```

---

## L0: Metadata Scan (ALWAYS — every session start)

Load these every time. They're small and critical:

```bash
# 1. Loop state (tiny — YAML frontmatter)
cat .claude/nelson-loop.local.md

# 2. Handoff (critical — previous iteration context)
cat .claude/nelson-handoff.local.md

# 3. NELSON_SOUL.md — first section only (identity core)
head -30 .nelson/NELSON_SOUL.md 2>/dev/null || true

# 4. MEMORY.md — index section only (first 40 lines)
head -40 .nelson/MEMORY.md 2>/dev/null || true
```

**Decision point:** From L0, identify which topics are relevant to the current task.

---

## L1: Overview (SELECTIVE — based on task relevance)

Load overviews ONLY for resources related to the current task:

```bash
# 5. Scratchpad — recent reasoning (first 30 lines)
head -30 .claude/nelson-scratchpad.local.md 2>/dev/null || true

# 6. Search memory for task-relevant keywords
node .nelson/search.cjs "keyword1" --limit 3
node .nelson/search.cjs "keyword2" --limit 3

# 7. Today's log — summary section only
head -20 .nelson/memory/$(date +%Y-%m-%d).md 2>/dev/null || true

# 8. Yesterday's log — summary section only
head -20 .nelson/memory/$(date -v-1d +%Y-%m-%d).md 2>/dev/null || true
```

**Decision point:** From L1, identify which resources need full content for this task.

---

## L2: Full Content (ON-DEMAND — triggered by specific need)

Load full content ONLY when a specific trigger fires:

| Trigger | Load |
|---------|------|
| Hit an error or obstacle | Full `skills/nelson-wall-breaker.md` |
| Feature ready for validation | Full `skills/nelson-validate.md` |
| Writing handoff document | Full `skills/nelson-handoff.md` |
| Implementing UI components | Full `skills/frontend-ui-ux.md` |
| Working with database | Full `skills/database-supabase.md` |
| Extracting compound learning | Full `skills/nelson-compound-learning.md` |
| Feeling drift/slow | Full `skills/nelson-drift-detection.md` |
| Every 5 iterations (meta-eval) | Full `skills/nelson-self-evolving-eval.md` |
| RAG/search task | Relevant file from `.claude/skills/rag/` |
| Full MEMORY.md needed | `cat .nelson/MEMORY.md` |
| Full pattern library needed | `cat .nelson/patterns/successes.md` |

**Rule:** Never load a full skill file "just in case." Load it when the trigger fires.

---

## Obsidian Bridge (v5.0 — when available)

If Obsidian MCP is detected (port 22360), use graph-relational queries for richer context:

### Replace L1 keyword search with graph search:

```
# Instead of flat keyword search:
node .nelson/search.cjs "authentication"

# Use Obsidian graph-aware search (if available):
mcp__obsidian__search "authentication"
→ Returns: notes + backlinks + connected concepts

# Traverse knowledge graph for related context:
mcp__obsidian__graph_query "hubs" min_links=3
→ Returns: highest-signal knowledge nodes

# Follow backlinks for one-hop context:
mcp__obsidian__get_backlinks "patterns/auth-pattern"
→ Returns: all notes linking to this pattern
```

### When to use Obsidian vs. flat search:

| Scenario | Use Obsidian | Use Flat Search |
|----------|--------------|-----------------|
| Obsidian MCP available | Primary | Fallback |
| Obsidian MCP unavailable | N/A | Primary |
| Need relational context | Yes | No |
| Need keyword match | Either | Yes |
| Cross-project knowledge | Yes (one vault) | No (per-project) |

---

## GEPA-Inspired Memory Consolidation (v5.0)

### After Each Iteration

Consolidate learnings into the right tier:

```
1. EXTRACT from execution trace:
   - What worked? → Pattern candidate
   - What failed? → Anti-pattern candidate
   - What diagnostic signal was available? → ASI candidate

2. CLASSIFY the insight:
   - Durable (lasts 10+ sessions)? → MEMORY.md
   - Reusable pattern? → patterns/successes.md (+ Obsidian note)
   - Failure to avoid? → patterns/failures.md (+ Obsidian note)
   - Temporal (this session only)? → Daily log

3. CONSOLIDATE:
   - Check: does a similar entry already exist in MEMORY.md?
   - If yes: update/merge (don't duplicate)
   - If no: add with clear context
   - Keep MEMORY.md under 200 lines (for auto-loading)
```

### Every 5 Iterations — Memory Pruning

```
1. Read MEMORY.md entries older than 5 sessions
2. For each: Is this still true?
   - Outdated → remove or update
   - Still valid → keep
   - Uncertain → verify against current code
3. Merge overlapping entries
4. Trim to 200 lines max
5. Run: node .nelson/consolidate.cjs (if available)
```

---

## GWS Integration (v5.0 — when available)

If GWS CLI is detected, use Google Workspace for crash-safe persistence:

```bash
# Save state to Drive every iteration (survives terminal crash)
gws drive upload .claude/nelson-handoff.local.md \
  --folder "Nelson-State" --name "handoff-iter-${ITERATION}.md"

# On restart after crash: restore from Drive
gws drive download "Nelson-State/handoff-iter-latest.md" \
  --output .claude/nelson-handoff.local.md
```

---

## Adaptive Loading Flow

```
SESSION START
    │
    ▼
L0: Load metadata (always — state, handoff, identity, memory index)
    │
    ▼
EXTRACT KEYWORDS from task
    │
    ├─ Obsidian available? ──► Graph search for related concepts
    │
    └─ Flat search only ──► node .nelson/search.cjs "keywords"
    │
    ▼
L1: Load overviews of relevant results
    │
    ▼
BEGIN WORK
    │
    ├─ Hit trigger? ──► L2: Load specific skill file
    ├─ Hit wall? ──► L2: Load wall-breaker skill
    ├─ Feature done? ──► L2: Load validation skill
    └─ Context heavy? ──► Pre-compaction flush
    │
    ▼
END OF ITERATION
    │
    ▼
CONSOLIDATE: Extract insights → Classify → Write to correct tier
```

---

## Pre-Compaction Flush (Preserved from v4)

When context window approaches limit:

```
1. IDENTIFY key insights from current work
2. WRITE to scratchpad (what matters for continuation)
3. UPDATE daily log with session progress
4. UPDATE MEMORY.md if durable insight found
5. COMMIT working code
6. Prepare handoff with specific next steps
7. ANNOUNCE: "Pre-compaction flush complete"
```

---

## The Golden Rules

1. **Load progressively, not greedily** — L0 always, L1 selectively, L2 on-demand
2. **Never start a task cold** — Always check memory first (30 seconds saves 30 minutes)
3. **Consolidate, don't accumulate** — Merge, prune, keep MEMORY.md under 200 lines
4. **Adapt to available tools** — Obsidian graph when available, flat search otherwise
5. **Each iteration's learning compounds** — Patterns extracted today save time tomorrow

---

*Nelson v5.0 Tiered Context Loader: Progressive loading. Maximum signal. Minimum tokens.*
