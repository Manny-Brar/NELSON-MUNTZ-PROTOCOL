---
description: "Activate HA-HA Mode - Peak Performance Development Loop"
argument-hint: "PROMPT [--max-iterations N] [--completion-promise TEXT]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-nelson-loop.sh:*)"]
---

# Nelson Muntz - HA-HA Mode

Execute the Nelson Muntz loop with HA-HA Mode (Peak Performance):

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-nelson-loop.sh" --ha-ha $ARGUMENTS
```

**The ultimate peak performance configuration. All enhancements activated.**

## What is HA-HA Mode?

HA-HA Mode is Nelson Muntz with EVERY enhancement enabled:

| Standard Nelson | HA-HA Mode |
|-----------------|------------|
| Ultrathink | Multi-dimensional thinking (4 levels) |
| Research on 2nd failure | Pre-research MANDATORY |
| 3-fix rule | 5-attempt escalation with research |
| Single validation | Aggressive validation + self-review |
| Basic pattern tracking | Full pattern library |
| Standard handoff | Comprehensive iteration reports |

## Usage

```bash
# Start HA-HA Mode loop
/nelson-muntz:ha-ha "Build a complete authentication system with OAuth, JWT, and MFA"

# With options
/nelson-muntz:ha-ha "Complex task" --max-iterations 50

# With bracket-delimited task list
/nelson-muntz:ha-ha "( task1, task2, task3 )" --max-iterations 10

# Monitor
/nelson-muntz:nelson-status
tail -f .claude/nelson-muntz.log
```

## HA-HA Mode Protocol Stack

When HA-HA Mode is active, these protocols execute in sequence:

### Phase 0: Pre-Flight Research
- Search best practices before writing any code
- Review official documentation
- Analyze existing patterns in codebase
- Document research findings

### Phase 1: Multi-Dimensional Thinking
- Level 1: Standard ultrathink
- Level 2: Deep ultrathink
- Level 3: Adversarial ultrathink (what could go wrong?)
- Level 4: Meta ultrathink (is this the best approach?)

### Phase 2: Parallel Exploration
- Evaluate multiple approaches before committing
- Spawn exploration agents for complex decisions
- Document all considered alternatives

### Phase 3: Wall-Breaker Protocol
- Classify any obstacle by type
- Execute wall-specific research protocol
- 5-10 targeted web searches
- Document breakthrough and prevention

### Phase 4: Aggressive Validation
- Pre-implementation checks
- Incremental validation (after every change)
- Two-stage post-implementation
- Self-review against best practices

### Phase 5: Self-Reflection Checkpoints
- After research: "Do I have enough information?"
- After design: "Is this the simplest solution?"
- After implementation: "Does this code make me proud?"
- Before commit: "Would I bet on this in production?"

### Phase 6: Pattern Recognition
- Learn from previous iterations
- Build pattern library
- Document anti-patterns discovered

### Phase 7: No-Surrender Persistence
- 5-attempt escalation ladder
- Mandatory research between attempts
- Never retry without new information

## Wall-Breaker Auto-Research

HA-HA Mode automatically searches for solutions when hitting walls:

```
🔴 ERROR WALL → Search error message + solutions
🟠 KNOWLEDGE WALL → Search tutorials + documentation
🟡 DESIGN WALL → Search approach comparisons
🟢 DEPENDENCY WALL → Search alternatives
🔵 COMPLEXITY WALL → Decompose + research sub-problems
```

All research is documented in `scratchpad.md` for future iterations.

## Output Format

Each HA-HA Mode iteration produces a comprehensive report:

```markdown
# HA-HA Mode Iteration [N] Report

## Pre-Flight Research Completed
- [x] Best practices searched
- [x] Documentation reviewed

## Thinking Phases Executed
- [x] All 4 levels of ultrathink

## Walls Encountered & Broken
| Wall Type | Description | Solution |
|-----------|-------------|----------|

## Validation Results
- Tests: PASS
- Lint: PASS
- Self-Review: PASS

## Patterns Discovered
- [New patterns learned]

## HA-HA Status: TRIUMPHANT
```

## When to Use HA-HA Mode

**Use HA-HA Mode for:**
- Complex, multi-component features
- Unfamiliar technologies
- Critical system components
- High-stakes implementations
- When standard Nelson keeps failing

**Standard Nelson is fine for:**
- Simple bug fixes
- Well-understood patterns
- Routine implementations
- Tasks with clear solutions

## Configuration

HA-HA Mode uses enhanced settings:

```json
{
  "mode": "ha-ha",
  "model": "opus",
  "thinking_depth": "maximum",
  "research_mandatory": true,
  "max_attempts_per_feature": 5,
  "auto_research_on_failure": true,
  "parallel_exploration": true,
  "checkpoint_frequency": "every_significant_change"
}
```

## The HA-HA Oath

```
I will not write code without research.
I will not commit without validation.
I will not surrender without exhausting options.
I will not repeat failures without learning.

When I succeed, I say: "HA-HA!"
```

---

**HA-HA Mode: Peak Performance. No Compromises.**
