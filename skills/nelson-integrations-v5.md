---
name: nelson-integrations-v5
description: External tool integrations for Nelson v5 — Obsidian knowledge graph memory, GWS workspace orchestration, and MCP-powered toolchains
version: 5.0.0
---

# Nelson v5.0 — External Integrations

**"The vault is the memory. The workspace is the workflow."**

---

## Integration Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    NELSON v5.0 INTEGRATION LAYER                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌───────────────┐   ┌───────────────┐   ┌───────────────┐         │
│  │   OBSIDIAN    │   │   GWS CLI     │   │  MCP BRIDGE   │         │
│  │   VAULT       │   │   WORKSPACE   │   │               │         │
│  ├───────────────┤   ├───────────────┤   ├───────────────┤         │
│  │ Graph memory  │   │ Drive storage │   │ Tool discovery│         │
│  │ Linked notes  │   │ Gmail alerts  │   │ Unified API   │         │
│  │ Semantic      │   │ Sheets metrics│   │ Auto-connect  │         │
│  │   search      │   │ Calendar sync │   │               │         │
│  │ Visual debug  │   │ Chat notify   │   │               │         │
│  └───────┬───────┘   └───────┬───────┘   └───────┬───────┘         │
│          │                   │                    │                  │
│          └───────────────────┼────────────────────┘                  │
│                              │                                       │
│                     ┌────────▼────────┐                              │
│                     │  NELSON HARNESS │                              │
│                     │  (context eng.) │                              │
│                     └─────────────────┘                              │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 1. Obsidian Vault as Graph Memory

### Why Obsidian > Flat Files

| Capability | Nelson v4 (flat files) | Nelson v5 + Obsidian |
|------------|----------------------|----------------------|
| Search | SQLite FTS keyword | Semantic + graph traversal |
| Relationships | None (isolated files) | Wikilinks, backlinks, graph |
| Visualization | None | Graph view, canvas |
| Cross-project | Per-project only | One vault, all projects |
| Discovery | Manual keyword search | "What's connected to X?" |
| Persistence | .nelson/ directory | Obsidian vault (synced) |
| Human review | Read raw markdown | Rich preview + graph |

### Setup

```bash
# 1. Install Obsidian MCP plugin
# In Obsidian: Settings → Community Plugins → obsidian-claude-code-mcp

# 2. Configure MCP connection in Claude Code
# Add to .mcp.json:
{
  "mcpServers": {
    "obsidian": {
      "type": "ws",
      "url": "ws://localhost:22360"
    }
  }
}

# 3. Create Nelson vault structure
mkdir -p ~/ObsidianVault/Nelson/{memory,patterns,daily,decisions,skills}
```

### Vault Structure

```
Nelson/
├── memory/
│   ├── MEMORY.md              # Master index (auto-loaded)
│   ├── architecture.md        # Architecture decisions
│   ├── gotchas.md             # Non-obvious pitfalls
│   └── conventions.md         # Coding conventions
├── patterns/
│   ├── successes.md           # Proven patterns (linked)
│   ├── failures.md            # Anti-patterns (linked)
│   └── [pattern-name].md      # Individual patterns
├── daily/
│   ├── 2026-03-18.md          # Daily logs
│   └── ...
├── decisions/
│   ├── [decision-name].md     # ADR-style decision records
│   └── ...
├── skills/
│   ├── evolved/               # Skills refined by GEPA loop
│   └── evaluation/            # Eval results per skill
└── projects/
    ├── [project-a]/           # Project-specific context
    └── [project-b]/           # Cross-project pattern reuse
```

### Graph Memory Operations

```
# Search memory with graph context
mcp__obsidian__search "authentication pattern"
→ Returns: notes + backlinks + connected concepts

# Traverse knowledge graph
mcp__obsidian__graph_query "shortest_path" from="auth" to="security"
→ Returns: conceptual path between topics

# Find most-connected knowledge
mcp__obsidian__graph_query "hubs" min_links=5
→ Returns: highest-signal knowledge nodes

# Find orphaned knowledge (potential gaps)
mcp__obsidian__graph_query "orphans"
→ Returns: isolated notes needing integration

# Write with automatic linking
mcp__obsidian__write_note "patterns/cursor-pagination.md"
  content: "## Cursor Pagination\n[[database]] [[performance]]\n..."
→ Auto-creates bidirectional links
```

### Memory Protocol with Obsidian

Replace Phase 0 (Boot Sequence) memory loading:

```
BOOT (with Obsidian):
  1. L0: Read MEMORY.md index from vault (graph-aware)
  2. L0: Query graph hubs → identify high-signal knowledge
  3. L1: Semantic search vault for task-relevant notes
  4. L1: Follow backlinks from relevant notes (1 hop)
  5. L2: Load full content only for directly applicable notes

  TOKEN SAVINGS: Graph traversal finds relevant context
  in ~500 tokens vs. 5000+ tokens of keyword search
```

### Compound Learning → Obsidian

After each iteration, write compound learning to vault:

```
1. Create note: patterns/[pattern-name].md
2. Add wikilinks: [[related-concept]] [[project-name]]
3. Add tags: #pattern #success OR #anti-pattern #failure
4. Add metadata frontmatter: date, project, confidence
5. Graph auto-updates → future agents discover via traversal
```

---

## 2. GWS CLI as Workspace Orchestration

### Why GWS

| Capability | Without GWS | With GWS |
|------------|-------------|----------|
| Artifact persistence | Local files only | Google Drive (synced, backed up) |
| Notifications | Terminal only | Gmail, Chat, Calendar |
| Metrics tracking | Manual | Google Sheets (live dashboard) |
| Scheduling | /loop only | Calendar integration |
| Collaboration | Git only | Drive sharing, Chat threads |
| Crash recovery | Lost if terminal dies | Artifacts in Drive persist |

### Setup

```bash
# 1. Install gws CLI
npm install -g @anthropic-ai/gws  # or follow official install

# 2. Authenticate
gws auth login

# 3. Start MCP server for Claude Code
gws mcp -s drive,gmail,calendar,sheets,chat

# 4. Add to .mcp.json:
{
  "mcpServers": {
    "gws": {
      "type": "stdio",
      "command": "gws",
      "args": ["mcp", "-s", "drive,gmail,calendar,sheets,chat"]
    }
  }
}
```

### Overnight Loop Workflow with GWS

```
ITERATION START:
  1. Log iteration start to Sheets dashboard
  2. Check Calendar for freeze windows

DURING WORK:
  3. On feature complete → append to Sheets
  4. On blocker → send Chat notification
  5. Save verification docs to Drive

ITERATION END:
  6. Update Sheets with metrics
  7. Upload handoff to Drive (crash-safe)

LOOP COMPLETE:
  8. Send Gmail summary report
  9. Create Calendar event for morning review
```

### Metrics Dashboard (Google Sheets)

Create a live metrics dashboard:

```
# Headers for Nelson Metrics Sheet:
| Timestamp | Iteration | Feature | Status | Duration | Attempts | Walls Hit | Research Queries | Compound Pattern | Drift Score |

# Auto-populate after each iteration:
gws sheets append "Nelson-Metrics" \
  --values "$(date -u +%H:%M),${ITERATION},${FEATURE},${STATUS},${DURATION},${ATTEMPTS},${WALLS},${SEARCHES},${PATTERN},${DRIFT}"
```

### Notification Patterns

```bash
# Blocker notification (immediate)
gws chat send --space "nelson-alerts" \
  "🔴 BLOCKED: Feature ${FEATURE} - ${REASON}\nIteration: ${N}\nNeeds human input."

# Progress update (every 5 iterations)
gws gmail send --to "you@email.com" \
  --subject "Nelson Loop Progress - Iteration ${N}" \
  --body "Features: ${DONE}/${TOTAL} complete\nNext: ${NEXT_FEATURE}"

# Completion notification
gws gmail send --to "you@email.com" \
  --subject "🎉 Nelson Loop COMPLETE" \
  --body "All features done in ${N} iterations.\nReview: [Drive link]"
```

### Crash Recovery with Drive

```
# Save state to Drive every iteration (survives terminal crash)
gws drive upload .claude/nelson-handoff.local.md \
  --folder "Nelson-State" --name "handoff-iter-${N}.md"

gws drive upload .claude/nelson-scratchpad.local.md \
  --folder "Nelson-State" --name "scratchpad-iter-${N}.md"

# On restart after crash: restore from Drive
gws drive download "Nelson-State/handoff-iter-latest.md" \
  --output .claude/nelson-handoff.local.md
```

---

## 3. MCP Bridge — Unified Tool Layer

### Tool Discovery Protocol

Nelson v5 auto-discovers available tools at boot:

```
BOOT:
  1. Check for Obsidian MCP → graph memory available?
  2. Check for GWS MCP → workspace tools available?
  3. Check for Vapi MCP → voice interface available?
  4. Check for Excalidraw MCP → diagram tools available?
  5. Build tool capability map
  6. Adapt workflow based on available tools
```

### Adaptive Workflow

```
IF obsidian available:
  → Use graph memory for context loading
  → Write compound learnings to vault
  → Leverage graph traversal for research
ELSE:
  → Fall back to .nelson/ flat files
  → Use SQLite FTS for search

IF gws available:
  → Upload artifacts to Drive
  → Send notifications via Gmail/Chat
  → Track metrics in Sheets
ELSE:
  → Local files only
  → Terminal output only
  → Manual metrics tracking

IF both available:
  → Full harness mode
  → Graph memory + workspace orchestration
  → Maximum observability and crash recovery
```

---

## 4. Advanced Integration Patterns

### Pattern: Obsidian as Evaluation Store

Store eval results in Obsidian for graph-queryable analysis:

```markdown
# eval/2026-03-18-auth-feature.md
---
feature: authentication
iteration: 5
result: PASS
duration: 12m
attempts: 2
patterns_used: ["jwt-validation", "middleware-chain"]
tags: [eval, pass, auth, backend]
---

## Evaluation Results
- Stage 1 (Spec): ✅ PASS
- Stage 2 (Quality): ✅ PASS
- Stage 3 (Red-Team): ✅ PASS

## Linked Patterns
- [[patterns/jwt-validation]] — applied successfully
- [[patterns/middleware-chain]] — first use, validated

## Compound Learning
- [[gotchas/jwt-refresh-timing]] — discovered during red-team
```

### Pattern: GWS as Overnight Monitor

For overnight loops, use GWS to create an autonomous monitoring system:

```
Every 30 minutes:
  1. Read current loop state
  2. Calculate drift score
  3. Append to Sheets dashboard
  4. If drift > threshold → Chat alert
  5. If blocked > 15 min → Gmail with context

On completion:
  1. Generate summary report
  2. Upload to Drive
  3. Send Gmail with results
  4. Create Calendar event: "Review Nelson Results"
```

### Pattern: Cross-Tool Knowledge Pipeline

```
Discovery → Obsidian (graph memory)
     ↓
Execution → Local (nelson state files)
     ↓
Metrics → GWS Sheets (live dashboard)
     ↓
Artifacts → GWS Drive (crash-safe)
     ↓
Learning → Obsidian (compound patterns)
     ↓
Alerts → GWS Gmail/Chat (human loop)
```

---

## Quick Start

### Minimal Setup (Obsidian only)
```bash
# Install obsidian-claude-code-mcp plugin
# Create vault structure
# Add MCP config to .mcp.json
# Nelson auto-detects and uses graph memory
```

### Full Setup (Obsidian + GWS)
```bash
# 1. Obsidian MCP
# 2. gws CLI + auth
# 3. gws MCP server
# 4. Create Sheets dashboard
# 5. Create Drive folders
# 6. Nelson auto-detects all tools
```

### No External Tools (fallback)
```bash
# Nelson v5 works without any external tools
# Falls back to v4 behavior: .nelson/ flat files + SQLite
# All v5 protocol enhancements still apply
```

---

*Nelson v5.0 Integrations: The vault is the memory. The workspace is the workflow.*
