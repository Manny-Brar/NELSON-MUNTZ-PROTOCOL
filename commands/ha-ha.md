---
description: "Activate HA-HA Mode - Phase-Gate Harness-Engineered Peak Performance (v5.1)"
argument-hint: "PROMPT [--max-iterations N] [--completion-promise TEXT] [--parallel]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-nelson-loop.sh:*)"]
---

# Nelson Muntz - HA-HA Mode (v5.1)

Execute the Nelson Muntz loop with HA-HA Mode (Peak Performance):

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-nelson-loop.sh" --ha-ha ${ARGUMENTS}
```

**Phase-Gate harness-engineered peak performance. Every request becomes a strategic multi-phase operation.**

## What is HA-HA Mode?

HA-HA Mode is Nelson Muntz with EVERY enhancement enabled — now with v5.1 Phase-Gate Execution Engine:

| Standard Nelson | HA-HA Mode (v5.1) |
|-----------------|-------------------|
| Work on features sequentially | **Phase-Gate Engine: strategic multi-phase decomposition with 4 gates** |
| Ultrathink (standard) | Multi-dimensional thinking (5 levels, incl. Compound Analysis) |
| Research on 2nd failure | Pre-research MANDATORY |
| 3-fix rule | 5-attempt escalation with research |
| Two-stage validation | Three-stage validation (spec + quality + red-team review) |
| Basic pattern tracking | Compound learning engine (each iteration easier) |
| Standard handoff | Comprehensive handoff + compound learning transfer |
| No drift detection | Active drift scoring + circuit breaker |
| Single agent | Planner-Worker-Judge-Scout multi-agent (optional) |
| Load all context | Tiered L0/L1/L2 progressive context loading |
| Ad-hoc documentation | **Mandatory doc gate with cross-reference awareness** |

## Usage

```bash
# Primary invocation format (v5.0)
/nelson-muntz:ha-ha "Build a complete authentication system with OAuth, JWT, and MFA" --max-iterations 30

# Also supported (plugin-qualified format)
/nelson-muntz:ha-ha "Complex task" --max-iterations 50

# With bracket-delimited task list
/nelson-muntz:ha-ha "( task1, task2, task3 )" --max-iterations 10

# With worktree-isolated parallel agents (v5.0)
/nelson-muntz:ha-ha "Complex task" --max-iterations 30 --parallel

# Monitor
/nelson-muntz:nelson-status
```

## HA-HA Mode Protocol Stack (v5.1)

When HA-HA Mode is active, the **Phase-Gate Execution Engine** drives ALL execution:

### Phase 0: Boot + Strategic Decomposition
- Tiered context loading: L0 → L1 → L2 on-demand
- **Read `skills/nelson-phase-gate.md`** — the master execution protocol
- **Decompose** entire request into strategic multi-phase plan using 5-level ULTRATHINK
- **Self-assess** the plan: gaps, risks, ordering, enhancement opportunities
- **Revise** plan based on assessment before executing anything

### Phase 1: Pre-Flight Research
- Search best practices before writing any code
- Review official documentation
- Analyze existing patterns in codebase
- Document research findings

### Phase 2: Multi-Dimensional Thinking (5 Levels)
- Level 1: Standard ultrathink
- Level 2: Deep ultrathink
- Level 3: Adversarial ultrathink (what could go wrong?)
- Level 4: Meta ultrathink (is this the best approach?)
- Level 5: **Compound analysis** (how does this make the NEXT iteration easier?)

### Phase 3: Parallel Exploration
- Evaluate multiple approaches before committing
- Spawn exploration agents for complex decisions
- Worktree isolation for parallel feature work (with --parallel flag)
- Document all considered alternatives

### Phase 4: Wall-Breaker Protocol
- Classify any obstacle by type (5 wall types)
- Execute wall-specific research protocol
- 5-10 targeted web searches
- Document breakthrough and prevention

### Phase 5: Three-Stage Validation
- **Stage 1: Spec compliance** — requirements met?
- **Stage 2: Quality assurance** — tests, lint, build, types pass?
- **Stage 3: Adversarial red-team review** — how would I break this?

### Phase 6: Self-Reflection Checkpoints
- After research: "Do I have enough information?"
- After design: "Is this the simplest solution?"
- After implementation: "Does this code make me proud?"
- Before commit: "Would I bet on this in production?"

### Phase 7: Compound Learning
- Extract pattern or anti-pattern from this iteration
- Update institutional knowledge if durable insight
- Refine skill files based on execution trace (GEPA-inspired)
- Track metrics for trend analysis

### Phase 8: Drift Detection
- Calculate drift score (0-10) from edit count, file spread, time, iterations
- Circuit breaker triggers at score >= 7
- Behavioral anchors re-center focus each phase
- Fresh context on drift (Nelson's core defense)

### Phase 9: No-Surrender Persistence
- 5-attempt escalation ladder
- Mandatory research between attempts
- Never retry without new information

### Per-Phase Gate Cycle (v5.1 — applies to EVERY phase above)

Each phase must pass through these 4 gates before the next phase begins:

```
Gate A: EXECUTE — Complete all tasks in the phase
Gate B: SELF-ASSESS — Critically evaluate, research best practices, fix gaps
Gate C: TEST — All tests pass, all fixes applied
Gate D: DOCUMENT — Update ALL affected docs, cross-reference overlapping workflows
```

No phase advances without all 4 gates passing. See `skills/nelson-phase-gate.md` for full protocol.

## Wall-Breaker Auto-Research

```
🔴 ERROR WALL      → Search error message + solutions
🟠 KNOWLEDGE WALL  → Search tutorials + documentation
🟡 DESIGN WALL     → Search approach comparisons
🟢 DEPENDENCY WALL → Search alternatives
🔵 COMPLEXITY WALL → Decompose + research sub-problems
```

## Output Format (v5.0)

Each HA-HA Mode iteration produces:

```markdown
# HA-HA Mode Iteration [N] Report

## Pre-Flight Research Completed
- [x] Best practices searched
- [x] Documentation reviewed

## Thinking Phases Executed
- [x] All 5 levels of ultrathink (including compound analysis)

## Walls Encountered & Broken
| Wall Type | Description | Solution |
|-----------|-------------|----------|

## Validation Results
- Stage 1 (Spec): PASS
- Stage 2 (Quality): PASS
- Stage 3 (Red-Team): PASS

## Compound Learning
- Pattern extracted: [name]
- Anti-pattern found: [name or None]
- Insight for next iteration: [what makes next easier]

## Drift Score: [0-10]

## HA-HA Status: TRIUMPHANT
```

## When to Use HA-HA Mode

**Use HA-HA Mode for:**
- Complex, multi-component features
- Unfamiliar technologies
- Critical system components
- High-stakes implementations
- When standard Nelson keeps failing
- Overnight autonomous loops

**Standard Nelson is fine for:**
- Simple bug fixes
- Well-understood patterns
- Routine implementations
- Tasks with clear solutions

## Configuration (v5.0)

```json
{
  "version": "5.0.0",
  "mode": "ha-ha",
  "model": "opus",
  "harness": {
    "context_loading": "tiered",
    "drift_detection": true,
    "circuit_breaker": true,
    "compound_learning": true
  },
  "thinking_depth": "maximum",
  "thinking_levels": 5,
  "validation_stages": 3,
  "research_mandatory": true,
  "max_attempts_per_feature": 5,
  "auto_research_on_failure": true,
  "parallel_exploration": true,
  "checkpoint_frequency": "every_significant_change"
}
```

## The HA-HA Oath (v5.0)

```
I will not write code without research.
I will not commit without three-stage validation.
I will not surrender without exhausting options.
I will not repeat failures without learning.
I will compound — each iteration makes the next easier.
I will detect drift before it causes failure.

When I succeed, I say: "HA-HA!"
```

---

**HA-HA Mode v5.0: Harness-Engineered Peak Performance. No Compromises.**
