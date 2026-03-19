# Nelson v5.1 — Quick Reference Card

> For the full story, see [NELSON_PROTOCOL_GUIDE.md](NELSON_PROTOCOL_GUIDE.md). This card covers what changed from v4 to v5.1.

---

## Command Format

```bash
/nelson:ha-ha "task" --max-iterations 30          # Primary v5 HA-HA format
/nelson-muntz:nelson "task" --max-iterations 20    # Standard mode
/nelson-muntz:ha-ha "task" --parallel              # With worktree isolation
```

---

## Phase-Gate Execution Engine (v5.1 — HA-HA Mode)

Every HA-HA request is automatically processed:

```
DECOMPOSE → SELF-ASSESS PLAN → FOR EACH PHASE: [EXECUTE → ASSESS → TEST → DOCUMENT]
```

No phase advances without all 4 gates passing.

---

## 6-Phase Iteration Protocol

```
BOOT → PLAN → WORK → VERIFY → COMPOUND → HANDOFF
```

| Phase | v4 | v5.1 |
|-------|----|----|
| BOOT | Load all files | Tiered L0/L1/L2 (~87% less tokens) + phase decomposition |
| PLAN | 4-level ULTRATHINK | 5-level (+ Compound Analysis) + plan self-assessment |
| WORK | Single feature | Execute → Self-Assess → Research → Fix gaps |
| VERIFY | 2-stage | 3-stage (+ adversarial red-team) |
| COMPOUND | None | Extract pattern/anti-pattern (NEW) |
| DOCUMENT | Ad-hoc | **Mandatory doc gate with cross-reference awareness** (NEW) |
| HANDOFF | Basic | 5-section with compound transfer |

---

## Tiered Context Loading

```
L0 (always, ~300 tok):  handoff, loop state, identity core, memory index
L1 (selective, ~2k tok): task-relevant search, recent scratchpad
L2 (on-demand):          full skill files, full MEMORY.md, patterns
```

---

## 5-Level ULTRATHINK

```
Level 1: Standard    — What needs to happen?
Level 2: Deep        — Edge cases, dependencies?
Level 3: Adversarial — What could go wrong?
Level 4: Meta        — Is this the best approach?
Level 5: Compound    — How does this make NEXT iteration easier?
```

---

## Three-Stage Validation

| Stage | What | Fails When |
|-------|------|-----------|
| 1. Spec | Requirements met? | Any requirement unimplemented |
| 2. Quality | Tests/lint/build/types pass? | Any check fails |
| 3. Red-Team | How would I break this? | CRITICAL security findings |

---

## Drift Detection

| Score | Status | Action |
|-------|--------|--------|
| 0-2 | HEALTHY | Continue |
| 3-4 | WATCH | Monitor |
| 5-6 | WARNING | Prepare fresh context |
| 7+ | CIRCUIT BREAKER | Auto-recovery prompt |

Factors: edit count, file spread, iteration count, session duration.

---

## Multi-Agent (Subagents)

| Agent | Model | Role |
|-------|-------|------|
| `nelson-planner` | Sonnet | Read-only analysis + plan |
| `nelson-worker` | Opus | Implement single feature |
| `nelson-judge` | Opus | Three-stage adversarial validation |
| `nelson-scout` | Haiku | Fast web research |

See `skills/nelson-orchestrator.md` for coordination patterns.

---

## New v5.1 Skills

| Skill | When to Read |
|-------|-------------|
| `nelson-phase-gate` | **START of every HA-HA request** (master execution protocol) |
| `nelson-protocol-v5` | Architecture overview |
| `nelson-compound-learning` | After feature completion |
| `nelson-drift-detection` | When feeling slow/stuck |
| `nelson-self-evolving-eval` | Every 5 iterations |
| `nelson-integrations-v5` | Setting up Obsidian/GWS |
| `nelson-orchestrator` | Before deploying subagents |

---

## New v5 Scripts

```bash
# Eval assertions (protocol compliance)
bash scripts/eval-assertions.sh --verbose
bash scripts/eval-assertions.sh --json --category quality

# Three-stage feature validation
bash scripts/validate-feature.sh --verbose

# Memory consolidation
node .nelson/consolidate.cjs --stats
node .nelson/consolidate.cjs --find-dupes
node .nelson/consolidate.cjs --trim

# Obsidian bridge
node .nelson/obsidian-bridge.cjs status
node .nelson/obsidian-bridge.cjs sync-patterns
node .nelson/obsidian-bridge.cjs hubs
```

---

## New v5 State Files

```
.claude/nelson-edit-tracker.local.json   # Edit metrics for drift scoring
```

## New features.json Fields (all optional)

```
compound_value, skills_required, red_team_findings,
drift_score_at_completion, pattern_extracted, anti_pattern_found,
asi_notes, iteration_completed, validation_stages
```

---

## Migration from v4

Zero effort. All v5 fields are optional with defaults. Update the plugin and v5 features activate progressively.

---

## The v5.1 Oath

```
DECOMPOSE → ASSESS plan → EXECUTE through gates →
THINK 5 levels → VALIDATE 3 ways → COMPOUND →
TEST → DOCUMENT all docs → DETECT drift

No phase advances without passing every gate.
```

---

*Nelson v5.1 — "HA-HA!" 🥊*
