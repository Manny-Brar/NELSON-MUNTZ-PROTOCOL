---
name: nelson-drift-detection
description: Active drift detection and circuit breaker system — monitors agent behavioral degradation in long-running sessions and triggers recovery before failures cascade
version: 5.0.0
---

# Nelson v5.0 — Drift Detection & Circuit Breakers

**"Agentic AI systems don't fail suddenly — they drift over time."**

Research shows: every agent experiences success rate decrease after 35 minutes.
Doubling task duration quadruples failure rate.
Nelson's fresh context model is the primary defense — this system ensures it triggers BEFORE drift causes damage.

---

## What is Agent Drift?

Agent drift is the progressive degradation of:
- **Decision quality** — worse choices over time
- **Instruction following** — skipping protocol steps
- **Output coherence** — vaguer, less specific responses
- **Tool selection accuracy** — wrong tools, redundant calls
- **Self-assessment calibration** — overconfidence in broken code

---

## Drift Indicators

### Level 1: WATCH (yellow)

Subtle signs — monitor but continue:

```
□ Responses slightly slower than early in session
□ Validation steps abbreviated (fewer details)
□ Handoff less specific than previous iterations
□ Commit messages getting vaguer
□ Starting to "quickly fix" unrelated things
□ Research getting shallower (fewer queries, less analysis)
```

### Level 2: WARNING (orange)

Clear degradation — intervene proactively:

```
□ Repeating an approach that already failed
□ Scope creeping beyond current feature
□ Skipping one or more protocol phases
□ Handoff missing critical context
□ Tests not actually being run (claiming PASS without output)
□ Forgetting decisions made earlier in the session
□ Token usage feeling heavy (slow responses)
```

### Level 3: CRITICAL (red)

Active failure — trigger circuit breaker:

```
□ Same error 3+ times without new approach
□ Context window > 80% capacity
□ Feature attempt count exceeds max (3 or 5)
□ 35+ minutes without meaningful progress
□ Test suite regressing (fewer passing than at start)
□ Making changes to wrong files
□ Claiming completion without evidence
□ Generating code that doesn't compile/lint
```

---

## Drift Scoring

Calculate drift score at each phase transition:

```
DRIFT SCORE (0-10):

  Base: 0 (fresh context, no drift)

  +1 per repeated failed approach
  +1 per skipped protocol phase
  +1 per vague handoff line (< 10 words per section)
  +1 if validation abbreviated
  +1 per 20 minutes of continuous work
  +2 if same error appears 3+ times
  +2 if scope creep detected
  +3 if test regression detected

  THRESHOLDS:
    0-2: GREEN — healthy, continue
    3-4: YELLOW — watch closely, consider compaction
    5-6: ORANGE — prepare for fresh context
    7+:  RED — CIRCUIT BREAKER: stop immediately
```

---

## Circuit Breaker Protocol

When drift score reaches RED (7+):

### Step 1: STOP (Immediate)
```
Do NOT continue current work.
Do NOT try "one more thing."
The degraded context is producing degraded output.
```

### Step 2: SALVAGE
```bash
# Commit any working code
git add -A && git commit -m "checkpoint: pre-circuit-breaker state"

# Or if code is broken, stash
git stash push -m "circuit-breaker-stash-$(date +%s)"
```

### Step 3: DOCUMENT
Write emergency state to scratchpad:
```markdown
## CIRCUIT BREAKER TRIGGERED - [Timestamp]

### Drift Score: [N]/10
### Indicators:
- [List specific drift indicators observed]

### Current State:
- Feature: [name] — [status]
- Tests: [X/Y passing]
- Last working commit: [hash]

### What Was Being Attempted:
- [Specific action in progress]
- [Why it was failing]

### Root Cause of Drift:
- [Best assessment: context pollution / repetitive failure / scope creep / time]
```

### Step 4: HANDOFF
Write compact emergency handoff:
```markdown
# EMERGENCY HANDOFF - Circuit Breaker

STATE: [working/broken/blocked]
LAST GOOD COMMIT: [hash]
NEXT ACTION: [one specific thing]
CRITICAL CONTEXT: [one sentence]
AVOID: [what caused the drift]
```

### Step 5: FRESH CONTEXT
Signal for fresh context iteration. The stop hook should detect and restart with clean 1M context window.

---

## Proactive Drift Prevention

### Time-Based Checks

```
Every 15 minutes:
  Quick self-check: "Am I still following the protocol?"
  If any doubt → write current state to scratchpad

Every 30 minutes:
  Calculate drift score
  If YELLOW → trigger compaction consideration
  If ORANGE → prepare emergency handoff

After 45 minutes:
  Strongly consider circuit breaker regardless of score
  Long sessions correlate with drift even when not detected
```

### Context Budget Management

```
Context usage estimation:
  - Each tool call result: ~500-2000 tokens
  - Each file read: ~200-5000 tokens
  - Each web search: ~1000-3000 tokens
  - Accumulated conversation: grows continuously

  When estimated > 60% capacity:
    → Trigger pre-compaction flush
    → Write key state to persistent files
    → Clear tool result cache mentally

  When estimated > 80% capacity:
    → CIRCUIT BREAKER (don't wait for problems)
```

### Behavioral Anchors

At the start of each phase, re-anchor:

```
PLAN phase anchor:
  "I am starting fresh analysis. Previous iterations' reasoning
   may be corrupted by drift. I will read the handoff and form
   my own assessment."

WORK phase anchor:
  "I am implementing ONE feature. I will not touch other features.
   I will not quickly fix unrelated things."

VERIFY phase anchor:
  "I will actually run the tests and show the output.
   I will not claim PASS without evidence."

HANDOFF phase anchor:
  "I will write specific file paths and line numbers.
   I will not write vague narrative."
```

---

## Drift Recovery Strategies

### After Circuit Breaker

The next iteration should:

```
1. Read emergency handoff FIRST
2. Check git log for last good state
3. Run test suite to establish baseline
4. Assess: continue from last good state OR revert?
5. If reverting: document why and what was lost
6. Start fresh analysis — do NOT inherit assumptions
```

### After Compaction

When context is compacted (not full circuit breaker):

```
1. Re-read scratchpad for preserved context
2. Re-read handoff for current state
3. Verify: does preserved context match reality?
4. If mismatch: trust current code state over memory
5. Resume from verified state
```

---

## Integration with Other Systems

### With Obsidian (if available)
```
Write drift events to vault:
  daily/[date].md → "Drift event at [time]: [indicators]"
  decisions/drift-recovery-[date].md → "Recovery strategy: [approach]"

Query vault for drift patterns:
  "When did drift happen before? What helped?"
```

### With GWS (if available)
```
On WARNING: Update Sheets dashboard with drift score
On CRITICAL: Send Chat/Gmail alert
On circuit breaker: Upload emergency state to Drive
```

### With Compound Learning
```
Every drift event is a learning opportunity:
  - What triggered the drift?
  - What could have prevented it?
  - Should protocol be adjusted?
  Document as anti-pattern if recurring
```

---

## The Drift Oath

```
I will monitor my own performance honestly.
I will not fight degraded context.
I will trigger fresh context before drift causes failure.
I will document state before it's lost.
I will start fresh rather than continue broken.

Fresh context is cheap. Bad code is expensive.
```

---

*Nelson v5.0 Drift Detection: Monitor. Detect. Recover. Before failure cascades.*
