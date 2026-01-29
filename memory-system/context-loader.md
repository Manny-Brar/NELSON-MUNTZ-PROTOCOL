# Nelson Memory Context Loader

## Purpose

This file defines HOW to automatically retrieve relevant context from Nelson's memory system. It is loaded at session start and defines the retrieval protocol.

---

## Automatic Retrieval Protocol

### MANDATORY: Execute Before Any Task

When you receive ANY task or question, BEFORE responding:

```
1. EXTRACT KEYWORDS from the task
   - Identify key terms (e.g., "webhook", "database", "api")
   - Identify file names mentioned
   - Identify error messages or patterns

2. SEARCH MEMORY for matches
   - Search MEMORY.md for relevant sections
   - Search today's daily log if exists
   - Search yesterday's daily log if exists
   - Look for matching patterns in patterns/

3. INJECT RELEVANT CONTEXT
   - Include matched content in your reasoning
   - Reference where you found it: "From MEMORY.md: ..."
   - Apply learned patterns to current task

4. PROCEED WITH TASK
   - Now execute with enhanced context
```

---

## File Loading Priority

### Always Load (Every Session)
```
1. .nelson/NELSON_SOUL.md        # Identity (WHO you are)
2. .nelson/MEMORY.md             # Long-term knowledge (WHAT you know)
3. .nelson/memory/YYYY-MM-DD.md  # Today's log (RECENT context)
4. .nelson/memory/YYYY-MM-DD.md  # Yesterday's log (RECENT context - 1 day)
```

### Load On Match (When Relevant)
```
5. .nelson/patterns/successes.md  # If task matches a success pattern
6. .nelson/patterns/failures.md   # If task matches a failure pattern
7. progress.json                  # For task status and feature tracking
8. SESSION_HANDOVER.md            # For detailed last-session context
```

---

## Keyword → Memory Section Mapping

When you see these keywords, search these sections:

| Keyword | Search In |
|---------|-----------|
| `webhook`, `api`, `endpoint` | MEMORY.md → API Patterns |
| `database`, `query`, `schema` | MEMORY.md → Database Patterns |
| `auth`, `oauth`, `token` | MEMORY.md → Authentication |
| `test`, `testing`, `verify` | patterns/successes.md |
| `bug`, `fix`, `error` | patterns/failures.md, recent daily logs |
| `deploy`, `production` | MEMORY.md → Deployment |
| `config`, `settings` | MEMORY.md → Configuration |

---

## Search Commands (For Reference)

If you need to search manually:

```bash
# Search MEMORY.md for keyword
grep -i "keyword" .nelson/MEMORY.md

# Search all daily logs
grep -ri "keyword" .nelson/memory/

# Search patterns
grep -ri "keyword" .nelson/patterns/

# Search with context
grep -i -C 3 "keyword" .nelson/MEMORY.md
```

---

## Pre-Compaction Flush

When context window approaches limit (you feel responses getting slower):

```
1. IDENTIFY key insights from current session
2. WRITE to today's daily log:
   - What was accomplished
   - What was discovered
   - What's still pending
3. UPDATE MEMORY.md if durable insight found
4. ANNOUNCE: "Pre-compaction flush complete"
```

---

## Session End Protocol

Before session ends, ALWAYS:

```
1. UPDATE daily log with session summary
2. CHECK if any insight should go to MEMORY.md
3. VERIFY progress tracking is current
4. UPDATE SESSION_HANDOVER.md for next session
```

---

## Memory Write Guidelines

### Goes to MEMORY.md (Durable)
- Architecture decisions (why we chose X over Y)
- Gotchas that will bite again (file X doesn't have table Y)
- Patterns that work (always do X when Y)
- Security rules (never forget auth check)
- Integration details (webhook URLs, API quirks)

### Goes to Daily Log (Temporal)
- What was done this session
- Commits made
- Blockers encountered
- Decisions made (with context)
- Things to follow up on

### Goes to Patterns (Reusable)
- **successes.md**: Approaches that worked well
- **failures.md**: Approaches that failed (and why)

---

## Example: Automatic Retrieval in Action

**User asks:** "Fix the webhook authentication"

**Your process:**
```
1. EXTRACT: "webhook", "authentication", "fix"

2. SEARCH:
   - MEMORY.md for "webhook auth" → Find: "webhooks use signature
     verification, not JWT"
   - Daily logs for "webhook" → Find: "Session 43: Fixed webhook
     signature validation at line 95"

3. INJECT:
   "From memory: Webhooks use signature verification, not JWT.
   Previous fix was at line 95. Let me verify this is still
   correct..."

4. PROCEED: Now you have context, work on the task
```

---

## The Golden Rule

**Never start a task cold.** Always check memory first. The 30 seconds spent searching memory saves 30 minutes of re-discovery.

---

*This loader ensures context retrieval happens automatically, without user prompting. It's the bridge between your ephemeral sessions and your persistent knowledge.*
