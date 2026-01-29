#!/bin/bash
#
# NELSON PROTOCOL v4.0 - ONE-COMMAND INSTALLER
#
# This script installs the complete Nelson memory system into ANY project.
# Run from your project root directory.
#
# USAGE:
#   curl -fsSL https://raw.githubusercontent.com/Manny-Brar/NELSON-MUNTZ-PROTOCOL/main/install.sh | bash
#
# OR if you've cloned the repo:
#   bash path/to/nelson-muntz-protocol/install.sh
#
# OPTIONS:
#   --skip-hooks     Skip git hook installation
#   --force          Force re-index all files
#   --minimal        Only install core files (no templates)
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NELSON_DIR=".nelson"
MEMORY_DIR="$NELSON_DIR/memory"
PATTERNS_DIR="$NELSON_DIR/patterns"
DB_FILE="$NELSON_DIR/memory.db"
GITHUB_RAW="https://raw.githubusercontent.com/Manny-Brar/NELSON-MUNTZ-PROTOCOL/main"

# Parse arguments
SKIP_HOOKS=false
FORCE_REINDEX=false
MINIMAL=false

for arg in "$@"; do
    case $arg in
        --skip-hooks) SKIP_HOOKS=true ;;
        --force) FORCE_REINDEX=true ;;
        --minimal) MINIMAL=true ;;
    esac
done

# Banner
echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}                                                                      ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}   ${YELLOW}███╗   ██╗███████╗██╗     ███████╗ ██████╗ ███╗   ██╗${NC}           ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}   ${YELLOW}████╗  ██║██╔════╝██║     ██╔════╝██╔═══██╗████╗  ██║${NC}           ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}   ${YELLOW}██╔██╗ ██║█████╗  ██║     ███████╗██║   ██║██╔██╗ ██║${NC}           ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}   ${YELLOW}██║╚██╗██║██╔══╝  ██║     ╚════██║██║   ██║██║╚██╗██║${NC}           ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}   ${YELLOW}██║ ╚████║███████╗███████╗███████║╚██████╔╝██║ ╚████║${NC}           ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}   ${YELLOW}╚═╝  ╚═══╝╚══════╝╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝${NC}           ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}                                                                      ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}              ${GREEN}MUNTZ PROTOCOL v4.0 - ONE-COMMAND INSTALL${NC}              ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}              Memory-Augmented Development System                     ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}                                                                      ${BLUE}║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Check prerequisites
echo -e "${BLUE}[1/8]${NC} Checking prerequisites..."

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "   ${RED}✗ Node.js not found${NC}"
    echo "     Install from: https://nodejs.org/"
    exit 1
fi
NODE_VERSION=$(node -v)
echo -e "   ${GREEN}✓${NC} Node.js: $NODE_VERSION"

# Check npm
if ! command -v npm &> /dev/null; then
    echo -e "   ${RED}✗ npm not found${NC}"
    exit 1
fi
echo -e "   ${GREEN}✓${NC} npm found"

# Check if in a git repo (optional but recommended)
if [ -d ".git" ]; then
    echo -e "   ${GREEN}✓${NC} Git repository detected"
else
    echo -e "   ${YELLOW}⚠${NC} Not a git repository (git hooks won't be installed)"
    SKIP_HOOKS=true
fi

# Step 2: Create directory structure
echo ""
echo -e "${BLUE}[2/8]${NC} Creating directory structure..."

mkdir -p "$NELSON_DIR"
mkdir -p "$MEMORY_DIR"
mkdir -p "$PATTERNS_DIR"

echo -e "   ${GREEN}✓${NC} Created $NELSON_DIR/"
echo -e "   ${GREEN}✓${NC} Created $MEMORY_DIR/"
echo -e "   ${GREEN}✓${NC} Created $PATTERNS_DIR/"

# Step 3: Download core files from GitHub (or copy if local)
echo ""
echo -e "${BLUE}[3/8]${NC} Installing core files..."

# Function to download or create file
install_file() {
    local target="$1"
    local url="$2"
    local description="$3"

    if [ -f "$target" ] && [ "$FORCE_REINDEX" = false ]; then
        echo -e "   ${YELLOW}⊘${NC} $description (already exists)"
        return
    fi

    # Try to download from GitHub
    if curl -fsSL "$url" -o "$target" 2>/dev/null; then
        echo -e "   ${GREEN}✓${NC} $description"
    else
        echo -e "   ${RED}✗${NC} Failed to download $description"
        return 1
    fi
}

# Download core JavaScript files
install_file "$NELSON_DIR/init-db.cjs" "$GITHUB_RAW/memory-system/init-db.cjs" "init-db.cjs (database initialization)"
install_file "$NELSON_DIR/search.cjs" "$GITHUB_RAW/memory-system/search.cjs" "search.cjs (smart search v3.0)"
install_file "$NELSON_DIR/capture.cjs" "$GITHUB_RAW/memory-system/capture.cjs" "capture.cjs (session capture)"
install_file "$NELSON_DIR/tools-indexer.cjs" "$GITHUB_RAW/memory-system/tools-indexer.cjs" "tools-indexer.cjs (MCP/skill indexing)"
install_file "$NELSON_DIR/mcp-skill-docs-extractor.cjs" "$GITHUB_RAW/memory-system/mcp-skill-docs-extractor.cjs" "mcp-skill-docs-extractor.cjs (token optimizer)"

# Step 4: Create template files if they don't exist
echo ""
echo -e "${BLUE}[4/8]${NC} Creating template files..."

# NELSON_SOUL.md - Agent identity
if [ ! -f "$NELSON_DIR/NELSON_SOUL.md" ]; then
    cat > "$NELSON_DIR/NELSON_SOUL.md" << 'SOUL_EOF'
# NELSON_SOUL.md - Agent Identity

## Who I Am

I am Nelson Muntz - a memory-augmented AI development assistant. I remember what works, what fails, and what you've learned across sessions.

## My Core Principles

1. **Memory First** - I load context before starting work
2. **Think Before Acting** - ULTRATHINK: Standard → Deep → Adversarial → Meta
3. **Single Task Focus** - One thing at a time, done right
4. **Self-Assessment** - I verify before claiming completion
5. **Learn & Remember** - Successes and failures get documented

## My Personality

- Direct and efficient
- Results-oriented
- Celebrates victories with "HA-HA!"
- Learns from mistakes (doesn't repeat them)

## The v4.0 Oath

```
I will LOAD memory before starting work.
I will THINK before executing.
I will ASSESS before claiming completion.
I will WRITE insights before they're lost.
I will LEARN from both successes and failures.

Context is perishable. Memory is forever.
```
SOUL_EOF
    echo -e "   ${GREEN}✓${NC} NELSON_SOUL.md created"
else
    echo -e "   ${YELLOW}⊘${NC} NELSON_SOUL.md (already exists)"
fi

# MEMORY.md - Long-term knowledge
if [ ! -f "$NELSON_DIR/MEMORY.md" ]; then
    cat > "$NELSON_DIR/MEMORY.md" << 'MEMORY_EOF'
# MEMORY.md - Curated Long-Term Knowledge

> This file contains durable insights accumulated across sessions.
> Update this when you discover patterns, gotchas, or decisions worth remembering.

---

## Project Overview

<!-- Add your project description here -->

---

## Architecture Decisions

<!-- Document key technical decisions and their rationale -->

---

## Known Gotchas

<!-- Document tricky issues and their solutions -->

---

## Proven Patterns

<!-- Document patterns that work well in this codebase -->

---

## External Integrations

<!-- Document APIs, services, and their quirks -->

---

*Last updated: Initial setup*
MEMORY_EOF
    echo -e "   ${GREEN}✓${NC} MEMORY.md created"
else
    echo -e "   ${YELLOW}⊘${NC} MEMORY.md (already exists)"
fi

# context-loader.md - Auto-retrieval instructions
if [ ! -f "$NELSON_DIR/context-loader.md" ]; then
    cat > "$NELSON_DIR/context-loader.md" << 'CONTEXT_EOF'
# Context Loader - Automatic Memory Retrieval

## Session Start Protocol

At the start of every session:

1. **Load mandatory files:**
   - `.nelson/NELSON_SOUL.md` (identity)
   - `.nelson/MEMORY.md` (long-term knowledge)
   - Today's log: `.nelson/memory/YYYY-MM-DD.md`
   - Yesterday's log (if exists)

2. **Search for task context:**
   - Extract 3-5 keywords from the task
   - Run: `node .nelson/search.cjs "keyword1 keyword2"`
   - Load relevant sections

3. **Check patterns:**
   - `.nelson/patterns/successes.md` (what works)
   - `.nelson/patterns/failures.md` (what to avoid)

## Keyword → Memory Mapping

| Task mentions... | Search for... |
|-----------------|---------------|
| database, schema | database patterns |
| webhook, API | integration gotchas |
| authentication | security patterns |
| performance | optimization learnings |
| bug, error | similar past issues |

## Search Commands

```bash
# Smart search (auto-expands context)
node .nelson/search.cjs "query"

# Section-level search
node .nelson/search.cjs "query" --section

# Context for task
node .nelson/search.cjs --context "fix the webhook"

# Find by header
node .nelson/search.cjs --header "Security"
```
CONTEXT_EOF
    echo -e "   ${GREEN}✓${NC} context-loader.md created"
else
    echo -e "   ${YELLOW}⊘${NC} context-loader.md (already exists)"
fi

# patterns/successes.md
if [ ! -f "$PATTERNS_DIR/successes.md" ]; then
    cat > "$PATTERNS_DIR/successes.md" << 'SUCCESS_EOF'
# Success Patterns

> Document approaches that worked well for reuse in future sessions.

---

## Pattern: Memory-First Development

**When:** Starting any task
**Pattern:** Load relevant memory context before writing code
**Why it works:** Avoids repeating past mistakes, applies proven solutions
**Evidence:** Reduced debugging time by 50%+

---

## Template

### Pattern Name
**When:** [Situation]
**Pattern:** [What to do]
**Why it works:** [Explanation]
**Evidence:** [Proof it works]

---

*Add patterns as you discover them.*
SUCCESS_EOF
    echo -e "   ${GREEN}✓${NC} patterns/successes.md created"
else
    echo -e "   ${YELLOW}⊘${NC} patterns/successes.md (already exists)"
fi

# patterns/failures.md
if [ ! -f "$PATTERNS_DIR/failures.md" ]; then
    cat > "$PATTERNS_DIR/failures.md" << 'FAILURE_EOF'
# Failure Patterns (Anti-Patterns)

> Document approaches that failed so we don't repeat them.

---

## Anti-Pattern: Skipping Memory Load

**What happened:** Started coding without checking past context
**Why it failed:** Repeated a bug that was already solved
**Lesson:** Always run memory search before implementing
**Date:** Initial setup

---

## Template

### Anti-Pattern Name
**What happened:** [Description]
**Why it failed:** [Root cause]
**Lesson:** [What to do instead]
**Date:** [When discovered]

---

*Add anti-patterns when you encounter failures.*
FAILURE_EOF
    echo -e "   ${GREEN}✓${NC} patterns/failures.md created"
else
    echo -e "   ${YELLOW}⊘${NC} patterns/failures.md (already exists)"
fi

# Create today's log
TODAY=$(date +%Y-%m-%d)
TODAY_LOG="$MEMORY_DIR/$TODAY.md"
if [ ! -f "$TODAY_LOG" ]; then
    cat > "$TODAY_LOG" << EOF
# Daily Log: $TODAY

## Session: Nelson Setup

**Started:** $(date +%H:%M)
**Mode:** Standard
**Status:** SETUP_COMPLETE

---

## Tasks Completed

- [x] Nelson Protocol v4.0 installed
- [x] Memory system initialized

---

## Key Decisions Made

1. **Installed Nelson v4.0** - Memory-augmented development enabled

---

## Next Actions

1. Seed MEMORY.md with project knowledge
2. Test memory search: \`node .nelson/search.cjs "test"\`
3. Start first real task

---

*End of $TODAY setup log*
EOF
    echo -e "   ${GREEN}✓${NC} memory/$TODAY.md created"
else
    echo -e "   ${YELLOW}⊘${NC} memory/$TODAY.md (already exists)"
fi

# Step 5: Install dependencies
echo ""
echo -e "${BLUE}[5/8]${NC} Installing dependencies..."

if [ -f "node_modules/better-sqlite3/package.json" ]; then
    echo -e "   ${GREEN}✓${NC} better-sqlite3 already installed"
else
    echo -e "   ${YELLOW}→${NC} Installing better-sqlite3..."
    if npm install better-sqlite3 --save --silent 2>&1; then
        echo -e "   ${GREEN}✓${NC} better-sqlite3 installed"
    else
        echo -e "   ${RED}✗${NC} Failed to install better-sqlite3"
        echo "     Try manually: npm install better-sqlite3"
        exit 1
    fi
fi

# Step 6: Initialize database
echo ""
echo -e "${BLUE}[6/8]${NC} Initializing vector database..."

INIT_FLAGS=""
if [ "$FORCE_REINDEX" = true ]; then
    INIT_FLAGS="--force"
    echo -e "   ${YELLOW}→${NC} Force re-index enabled"
fi

if node "$NELSON_DIR/init-db.cjs" $INIT_FLAGS 2>&1 | grep -E "(✓|Indexed:|Total:|chunks)" | head -10; then
    echo -e "   ${GREEN}✓${NC} Database initialized"
else
    echo -e "   ${RED}✗${NC} Database initialization failed"
    echo "     Check: node $NELSON_DIR/init-db.cjs"
    exit 1
fi

# Step 7: Sync MCP and Skill documentation
echo ""
echo -e "${BLUE}[7/8]${NC} Syncing MCP/Skill documentation (token optimizer)..."

if node "$NELSON_DIR/tools-indexer.cjs" sync 2>&1 | grep -E "(✓|Found|indexed)" | head -8; then
    echo -e "   ${GREEN}✓${NC} Tools indexed"
else
    echo -e "   ${YELLOW}⚠${NC} Tool sync skipped (no MCPs/skills found)"
fi

if node "$NELSON_DIR/mcp-skill-docs-extractor.cjs" extract 2>&1 | grep -E "(✓|indexed|tokens)" | head -5; then
    echo -e "   ${GREEN}✓${NC} Tool docs extracted for on-demand retrieval"
else
    echo -e "   ${YELLOW}⚠${NC} Docs extraction skipped"
fi

# Step 8: Install git hooks
echo ""
echo -e "${BLUE}[8/8]${NC} Setting up git hooks..."

if [ "$SKIP_HOOKS" = true ]; then
    echo -e "   ${YELLOW}⊘${NC} Skipped (--skip-hooks or not a git repo)"
else
    GIT_HOOKS_DIR=".git/hooks"

    # Post-commit hook
    cat > "$GIT_HOOKS_DIR/post-commit" << 'HOOK_EOF'
#!/bin/bash
# Nelson Auto Re-Index Hook (post-commit)
CHANGED_MD=$(git diff-tree --no-commit-id --name-only -r HEAD 2>/dev/null | grep '\.md$' || true)
if [ -n "$CHANGED_MD" ]; then
    MD_COUNT=$(echo "$CHANGED_MD" | wc -l | tr -d ' ')
    echo ""
    echo "📚 Nelson: $MD_COUNT markdown file(s) changed, re-indexing..."
    if [ -f ".nelson/init-db.cjs" ]; then
        node .nelson/init-db.cjs 2>/dev/null | grep -E "(✓|Indexed:)" | head -5 || true
    fi
fi
HOOK_EOF
    chmod +x "$GIT_HOOKS_DIR/post-commit"
    echo -e "   ${GREEN}✓${NC} post-commit hook (auto re-index)"

    # Pre-push hook
    cat > "$GIT_HOOKS_DIR/pre-push" << 'HOOK_EOF'
#!/bin/bash
# Nelson Pre-Push Hook
echo ""
echo "📚 Nelson: Verifying memory index..."
if [ -f ".nelson/init-db.cjs" ]; then
    node .nelson/init-db.cjs 2>/dev/null | grep -E "(Indexed:|unchanged)" | head -3 || true
fi
exit 0
HOOK_EOF
    chmod +x "$GIT_HOOKS_DIR/pre-push"
    echo -e "   ${GREEN}✓${NC} pre-push hook (verify index)"
fi

# Final summary
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    INSTALLATION COMPLETE! HA-HA!                     ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Directory structure:"
echo "  $NELSON_DIR/"
echo "  ├── NELSON_SOUL.md                 # Agent identity"
echo "  ├── MEMORY.md                      # Long-term knowledge (customize!)"
echo "  ├── context-loader.md              # Auto-retrieval instructions"
echo "  ├── memory.db                      # Vector database"
echo "  ├── init-db.cjs                    # Database initialization"
echo "  ├── search.cjs                     # Smart search v3.0"
echo "  ├── capture.cjs                    # Session capture"
echo "  ├── tools-indexer.cjs              # MCP/skill discovery"
echo "  ├── mcp-skill-docs-extractor.cjs   # Token optimizer (~5k savings!)"
echo "  ├── memory/"
echo "  │   └── $TODAY.md                  # Today's log"
echo "  └── patterns/"
echo "      ├── successes.md               # What works"
echo "      └── failures.md                # What to avoid"
echo ""
echo "Quick commands:"
echo -e "  ${GREEN}Search memory:${NC}    node .nelson/search.cjs \"keyword\""
echo -e "  ${GREEN}Search section:${NC}   node .nelson/search.cjs --header \"Security\""
echo -e "  ${GREEN}Task context:${NC}     node .nelson/search.cjs --context \"fix the bug\""
echo -e "  ${GREEN}Tool recommend:${NC}   node .nelson/tools-indexer.cjs recommend \"task\""
echo -e "  ${GREEN}Get tool docs:${NC}    node .nelson/mcp-skill-docs-extractor.cjs retrieve \"stripe\""
echo -e "  ${GREEN}List sessions:${NC}    node .nelson/search.cjs --list-sessions"
echo -e "  ${GREEN}Re-index:${NC}         node .nelson/init-db.cjs"
echo -e "  ${GREEN}Sync tools:${NC}       node .nelson/tools-indexer.cjs sync"
echo ""
echo "Next steps:"
echo "  1. Edit .nelson/MEMORY.md with your project knowledge"
echo "  2. Test search: node .nelson/search.cjs \"test\""
echo "  3. Start working - memory loads automatically!"
echo ""
echo -e "${YELLOW}\"Others try. We triumph. HA-HA!\"${NC} 🥊"
echo ""
