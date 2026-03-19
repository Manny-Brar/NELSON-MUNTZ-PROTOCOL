# Contributing to Nelson Muntz Protocol v5.0

> *"Who hath summoned me?"* — You, apparently. Let's see what you got.

---

## So You Wanna Help?

Fine. But we do things MY way around here. Follow the rules or get beat up (metaphorically).

---

## Architecture Overview (Know This First)

Nelson v5.0 is a **harness-engineered** system. Before contributing, understand the structure:

```
NELSON-MUNTZ-PROTOCOL/
├── .claude-plugin/         # Plugin manifest (plugin.json, marketplace.json)
├── agents/                 # v5: Subagent definitions (Planner, Worker, Judge, Scout)
├── commands/               # Slash commands (/nelson, /ha-ha, /nelson-status, etc.)
├── hooks/                  # Lifecycle hooks (stop-hook, post-edit-hook)
├── memory-system/          # Memory files + Node.js scripts (search, consolidate, etc.)
├── prompts/                # System prompts (executor, initializer, ultrathink, etc.)
├── schemas/                # JSON schemas (features.schema.json)
├── scripts/                # Bash scripts (setup-loop, validate-feature, eval-assertions)
├── skills/                 # Skill files (protocol, validation, compound learning, etc.)
├── README.md               # User-facing docs (Nelson voice)
├── NELSON_PROTOCOL_GUIDE.md # Technical reference (comprehensive)
├── CONTRIBUTING.md          # You are here
└── install.sh              # One-command installer
```

### Key v5 Concepts

| Concept | What It Means |
|---------|--------------|
| **Harness engineering** | The infrastructure wrapping the agent matters more than the model |
| **Tiered L0/L1/L2 loading** | Load context progressively (metadata → overview → full) to save tokens |
| **5-level ULTRATHINK** | Standard → Deep → Adversarial → Meta → Compound analysis |
| **Three-stage validation** | Spec compliance + quality assurance + adversarial red-team review |
| **Compound learning** | Each iteration extracts patterns that make the next iteration easier |
| **Drift detection** | Monitor agent degradation, circuit break at score >= 7 |
| **Multi-agent** | Planner-Worker-Judge-Scout subagent orchestration |

---

## How To Contribute

### 1. Found a Bug? 🔴

Open an issue. Include:
- What you were trying to do
- What happened instead
- Error messages (the whole thing, not just "it didn't work")
- Your setup (OS, Claude Code version, Nelson version)
- Which component: hook / command / skill / script / agent

**Don't:** Open an issue that just says "it's broken." That's lazy. I don't respect lazy.

### 2. Got an Idea? 💡

Open an issue first. Describe:
- What you want to add
- Why it's useful
- How it fits the Nelson philosophy (harness engineering, compound learning, single focus)

**Don't:** Just submit a PR without talking first. I might not want your "improvement."

### 3. Want to Submit Code? 🥊

1. Fork the repo
2. Create a branch (`git checkout -b feature/your-thing`)
3. Make your changes
4. Run the eval assertions: `bash scripts/eval-assertions.sh --verbose`
5. Validate bash scripts: `bash -n scripts/your-script.sh`
6. Validate JSON: `cat schemas/file.json | python3 -m json.tool`
7. Submit a PR with a clear description

---

## Code Standards

### Keep It Simple

- No over-engineering
- If it works, don't make it "elegant"
- Comments only where actually needed

### Follow the Patterns

- Look at existing code and match the style
- Skills use YAML frontmatter (`name`, `description`, `version`)
- Agents use YAML frontmatter (`name`, `description`, `tools`, `model`)
- Commands use YAML frontmatter (`description`, `argument-hint`, `allowed-tools`)
- Scripts include version header comments

### File-Specific Guidelines

| File Type | Key Rules |
|-----------|-----------|
| **Skills** (`skills/*.md`) | YAML frontmatter, < 500 words ideal, clear trigger description |
| **Agents** (`agents/*.md`) | YAML frontmatter with tools/model, structured output format in prompt |
| **Commands** (`commands/*.md`) | YAML frontmatter, `!` shell blocks for execution |
| **Hooks** (`hooks/*.sh`) | `set -euo pipefail`, handle missing files gracefully, don't delete state on errors |
| **Scripts** (`scripts/*.sh`) | `bash -n` must pass, version header, `--help` flag |
| **Schemas** (`schemas/*.json`) | Valid JSON (`python3 -m json.tool`), new fields must be optional with defaults |
| **Prompts** (`prompts/*.md`) | Reference v5 concepts, maintain backwards compatibility |

### Test Your Stuff

- `bash -n script.sh` — syntax check bash scripts
- `node -c file.cjs` — syntax check Node.js scripts
- `python3 -m json.tool < file.json` — validate JSON
- `bash scripts/eval-assertions.sh` — run protocol compliance checks
- Make sure nothing breaks existing v4 functionality

---

## What I'll Accept

✅ Bug fixes (always welcome)
✅ Documentation improvements (typos, clarity)
✅ New skills following the frontmatter pattern
✅ New agent definitions following Planner/Worker/Judge/Scout pattern
✅ Performance improvements (with proof / metrics)
✅ Better error messages in hooks and scripts
✅ New eval assertions for better protocol coverage
✅ Integration patterns (new MCP bridges, tool adapters)

## What I Won't Accept

❌ Breaking changes without discussion
❌ "Refactoring" that doesn't improve anything
❌ Adding dependencies we don't need
❌ Changing the core philosophy (harness engineering, compound learning, fresh context)
❌ Sloppy code with no testing
❌ Skills > 1000 lines (split into multiple skills)
❌ Removing backwards compatibility with v4

---

## The Review Process

1. I'll look at your PR
2. I'll run `eval-assertions.sh` on it
3. I might ask questions
4. I might request changes
5. If it's good, it gets merged
6. If it's not, I'll tell you why

**Don't take it personally.** I'm tough on everyone. That's why this thing works.

---

## Want to Add a New Skill?

Follow this template:

```markdown
---
name: your-skill-name
description: One-line description — specific about WHEN this skill triggers
version: 5.0.0
---

# Your Skill Title

[Instructions for the agent — imperative verbs, clear structure]
[Include output format templates]
[Keep under 500 words if possible]
```

Place it in `skills/` and submit a PR.

---

## Want to Add a New Agent?

Follow the existing pattern in `agents/`:

```markdown
---
name: your-agent-name
description: "When to use this agent and what it does"
tools: Read, Grep, Glob  # Only what's needed
model: sonnet  # or inherit, opus, haiku
---

[System prompt — focused role, structured output format, clear rules]
```

---

## Questions?

Open an issue. Don't DM me on random platforms.

---

*"The agent isn't the hard part. The harness is. HA-HA!"* 🥊

Now go make something useful.
