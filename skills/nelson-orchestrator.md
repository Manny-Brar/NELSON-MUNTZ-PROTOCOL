---
name: nelson-orchestrator
description: Multi-agent orchestration playbook — when and how to deploy Planner, Worker, Judge, and Scout subagents in coordinated workflows. Covers sequential chains, parallel research, and the full Planner-Worker-Judge pipeline.
version: 5.0.0
---

# Nelson v5.0 — Multi-Agent Orchestrator

**"One agent is good. Four specialized agents are better. An orchestrated team is unstoppable."**

This skill teaches the main Nelson agent how to coordinate the four specialized subagents: Planner, Worker, Judge, and Scout.

---

## When to Use Multi-Agent

```
SINGLE AGENT (default — 90% of tasks):
  ✅ Simple bug fixes
  ✅ Well-understood patterns
  ✅ Routine implementations
  ✅ Tasks in a single file or module

MULTI-AGENT (activate for — 10% of tasks):
  ✅ Features spanning 3+ files in different domains
  ✅ Unfamiliar technology requiring pre-research
  ✅ Complex architecture decisions with competing approaches
  ✅ High-stakes features requiring adversarial review
  ✅ When standard single-agent keeps failing (escalation)
```

**Rule of thumb:** If you'd spend 30+ minutes researching before coding, deploy Scout first. If the feature touches frontend + backend + database, deploy Planner first.

---

## The Four Agents

| Agent | Model | Speed | Cost | Role |
|-------|-------|-------|------|------|
| **nelson-scout** | Haiku | Fast | Low | Research, intelligence gathering |
| **nelson-planner** | Sonnet | Medium | Medium | Analysis, decomposition, planning |
| **nelson-worker** | Opus | Slower | Higher | Implementation, coding |
| **nelson-judge** | Opus | Medium | Higher | Validation, adversarial review |

---

## Orchestration Patterns

### Pattern 1: Full Pipeline (Complex Features)

Use when the task is complex, unfamiliar, or high-stakes.

```
Step 1: SCOUT — Gather intelligence
  ↓ (research report)
Step 2: PLANNER — Create implementation plan
  ↓ (structured plan)
Step 3: WORKER — Execute the plan
  ↓ (completion report)
Step 4: JUDGE — Validate the work
  ↓ (verdict: PASS / FAIL)
  ↓ If FAIL → back to WORKER with Judge feedback
```

**How to invoke:**

```
# Step 1: Deploy Scout for research
Use Agent tool:
  subagent_type: "nelson-scout"
  prompt: "Research [topic]. Wall type: KNOWLEDGE.
           I need to understand [specific question]."
→ Scout returns structured report with findings + sources

# Step 2: Deploy Planner with Scout's findings
Use Agent tool:
  subagent_type: "nelson-planner"
  prompt: "Create implementation plan for [feature].
           Research findings: [paste Scout report summary].
           Current codebase context: [key files]."
→ Planner returns structured plan with steps + risks

# Step 3: Deploy Worker with Planner's plan
Use Agent tool:
  subagent_type: "nelson-worker"
  prompt: "Implement this plan: [paste Planner output].
           Feature: [description].
           Skills to read: [from Planner's recommendations]."
→ Worker returns completion report with changes + tests

# Step 4: Deploy Judge to validate
Use Agent tool:
  subagent_type: "nelson-judge"
  prompt: "Validate this completed feature.
           Original plan: [paste Planner output].
           Worker report: [paste Worker output].
           Run three-stage validation."
→ Judge returns verdict with findings
```

### Pattern 2: Research-First (Unfamiliar Territory)

Use when you don't know the technology or best approach.

```
Step 1: SCOUT — Research the landscape
  ↓ (findings)
Step 2: Main agent implements (informed by research)
  ↓ (code changes)
Step 3: JUDGE — Validate (optional, for high-stakes)
```

**How to invoke:**

```
# Deploy Scout
Use Agent tool:
  subagent_type: "nelson-scout"
  prompt: "I need to [task] using [technology].
           Research: best practices, common pitfalls, example code.
           Wall type: KNOWLEDGE."

# Read Scout's report, then implement yourself
# Deploy Judge only if the feature is critical
```

### Pattern 3: Parallel Research (Design Decisions)

Use when facing competing approaches and need data before deciding.

```
                  ┌─ SCOUT A: Research Approach 1
Main agent ──────┤
                  └─ SCOUT B: Research Approach 2
                          ↓
                  Main agent synthesizes + decides
```

**How to invoke:**

```
# Deploy two Scouts in PARALLEL (same message, two Agent calls)
Use Agent tool:
  subagent_type: "nelson-scout"
  prompt: "Research [Approach A] for [task].
           Pros, cons, performance, complexity.
           Wall type: DESIGN."
  run_in_background: true
  name: "scout-approach-a"

Use Agent tool:
  subagent_type: "nelson-scout"
  prompt: "Research [Approach B] for [task].
           Pros, cons, performance, complexity.
           Wall type: DESIGN."
  run_in_background: true
  name: "scout-approach-b"

# Wait for both, then synthesize findings and decide
```

### Pattern 4: Plan-Then-Validate (Architecture Work)

Use for architecture decisions that need adversarial review before implementation.

```
Step 1: PLANNER — Create architecture plan
  ↓ (plan)
Step 2: JUDGE — Red-team the plan (before any code!)
  ↓ (verdict + concerns)
Step 3: PLANNER or Main — Revise plan based on Judge feedback
  ↓ (revised plan)
Step 4: WORKER — Implement revised plan
```

**How to invoke:**

```
# Deploy Planner
Use Agent tool:
  subagent_type: "nelson-planner"
  prompt: "Design architecture for [feature].
           Consider: [constraints].
           Produce: implementation plan with steps."

# Deploy Judge to red-team the PLAN (not code)
Use Agent tool:
  subagent_type: "nelson-judge"
  prompt: "Red-team this architecture plan.
           Plan: [paste Planner output].
           Focus on: feasibility, risks, missing requirements.
           This is a plan review, not code review."
```

### Pattern 5: Worktree-Isolated Parallel Workers

Use with `--parallel` flag for independent features that don't share files.

```
                  ┌─ WORKER A: Feature 1 (worktree A)
Main agent ──────┤
                  └─ WORKER B: Feature 2 (worktree B)
                          ↓
                  JUDGE validates each
                          ↓
                  Main agent merges
```

**How to invoke:**

```
# Deploy Worker A in isolated worktree
Use Agent tool:
  subagent_type: "nelson-worker"
  isolation: "worktree"
  prompt: "Implement [Feature 1]. Plan: [plan]."
  run_in_background: true
  name: "worker-feature-1"

# Deploy Worker B in isolated worktree
Use Agent tool:
  subagent_type: "nelson-worker"
  isolation: "worktree"
  prompt: "Implement [Feature 2]. Plan: [plan]."
  run_in_background: true
  name: "worker-feature-2"

# After both complete, Judge validates each
```

---

## Context Handoff Between Agents

Since subagents can't see each other's context, the orchestrator (you) must relay:

### What to Pass Forward

```
Scout → Planner:
  "Research findings: [3-5 key bullet points from Scout report]"
  "Recommended approach: [Scout's recommendation]"
  "Sources: [URLs if relevant]"

Planner → Worker:
  "Plan: [full structured plan output]"
  "Skills to read: [Planner's skill recommendations]"
  "Risks: [Planner's risk assessment]"

Worker → Judge:
  "Original plan: [Planner's plan]"
  "Worker report: [Worker's completion report]"
  "Changes made: [file list with descriptions]"

Judge → Worker (on FAIL):
  "Judge verdict: FAIL"
  "Blocking issues: [Judge's critical/high findings]"
  "Fix these specific items: [numbered list]"
```

### What NOT to Pass

- Don't paste entire file contents (let agents read files themselves)
- Don't paste full tool outputs (agents can run commands themselves)
- Don't relay vague summaries ("it went well") — be specific

---

## Error Handling

### Scout Returns Low-Confidence Results
```
If Scout confidence is LOW on all findings:
  → Try different search queries (more specific)
  → Try a second Scout with rephrased question
  → If still LOW: proceed with caution, flag uncertainty in plan
```

### Worker Reports BLOCKED
```
If Worker reports BLOCKED:
  → Read Worker's blocker description
  → Deploy Scout to research the specific blocker
  → If research helps: resume Worker with new info (SendMessage)
  → If still blocked: mark feature blocked, move to next
```

### Judge Returns FAIL
```
If Judge verdict is FAIL:
  → Read Judge's blocking issues
  → Resume Worker with specific fix instructions (SendMessage)
  → Worker fixes → Judge re-validates
  → Max 2 Judge rounds before marking feature blocked
```

---

## Cost Optimization

| Approach | Estimated Cost | When to Use |
|----------|---------------|-------------|
| Single agent (no delegation) | 1x | Simple tasks |
| Scout only | 1.2x | Research-heavy tasks |
| Scout + main agent | 1.3x | Unfamiliar tech |
| Full pipeline (Scout→Planner→Worker→Judge) | 2-3x | Complex/critical features |
| Parallel workers + Judge | 3-4x | Independent parallel features |

**Rule:** Only escalate to multi-agent when the task complexity justifies the cost. Don't use a full pipeline for a bug fix.

---

## Integration with Nelson Loop

In a Nelson iteration loop, multi-agent orchestration fits like this:

```
BOOT (tiered loading)
  ↓
PLAN (ULTRATHINK — decide: single agent or multi-agent?)
  ↓
If single agent:                    If multi-agent:
  WORK (main agent)                   SCOUT (if research needed)
  VERIFY (main agent)                 PLANNER (create plan)
  COMPOUND (main agent)               WORKER (execute plan)
  HANDOFF                             JUDGE (validate)
                                      COMPOUND (from Judge output)
                                      HANDOFF
```

The decision to use multi-agent happens during PLAN phase based on:
- Task complexity (3+ files? multiple domains?)
- Knowledge gaps (unfamiliar tech? need research?)
- Stakes (production-critical? security-sensitive?)
- Previous failures (did single-agent fail on this?)

---

*Nelson v5.0 Orchestrator: One agent is good. A coordinated team is HA-HA!*
