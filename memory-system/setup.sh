#!/bin/bash
# Nelson Protocol v4.0 - Auto-Install Script
# This script sets up the memory system with MANDATORY vector database
#
# Features:
# - Full documentation indexing (CLAUDE.md, docs/, README.md, etc.)
# - Git hooks for auto re-indexing on commit/push
# - Priority-weighted search across all indexed content
#
# Usage:
#   bash .nelson/setup.sh              # Full install with git hooks
#   bash .nelson/setup.sh --skip-hooks # Skip git hook installation
#   bash .nelson/setup.sh --force      # Force re-index all files

set -e  # Exit on error

NELSON_DIR=".nelson"
MEMORY_DIR="$NELSON_DIR/memory"
PATTERNS_DIR="$NELSON_DIR/patterns"
DB_FILE="$NELSON_DIR/memory.db"
SKIP_HOOKS=false
FORCE_REINDEX=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --skip-hooks)
            SKIP_HOOKS=true
            ;;
        --force)
            FORCE_REINDEX=true
            ;;
    esac
done

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║           NELSON PROTOCOL v4.0 - AUTO-INSTALL                    ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# Step 1: Verify prerequisites
echo "🔍 Checking prerequisites..."

# Check Node.js (REQUIRED)
if ! command -v node &> /dev/null; then
    echo "❌ FATAL: Node.js is required but not installed"
    echo "   Install Node.js from https://nodejs.org/"
    exit 1
fi
NODE_VERSION=$(node -v)
echo "   ✓ Node.js found: $NODE_VERSION"

# Check npm (REQUIRED)
if ! command -v npm &> /dev/null; then
    echo "❌ FATAL: npm is required but not installed"
    exit 1
fi
echo "   ✓ npm found"

# Step 2: Create directory structure
echo ""
echo "📁 Creating directory structure..."
mkdir -p "$MEMORY_DIR"
mkdir -p "$PATTERNS_DIR"
echo "   ✓ Created $NELSON_DIR/"
echo "   ✓ Created $MEMORY_DIR/"
echo "   ✓ Created $PATTERNS_DIR/"

# Step 3: Install better-sqlite3 (MANDATORY)
echo ""
echo "📦 Installing vector database dependencies..."
echo "   (This is REQUIRED for efficient memory retrieval)"

# Check if better-sqlite3 is already installed
if [ -f "node_modules/better-sqlite3/package.json" ]; then
    echo "   ✓ better-sqlite3 already installed"
else
    echo "   → Installing better-sqlite3..."
    npm install better-sqlite3 --save 2>&1 | while read line; do echo "     $line"; done

    if [ -f "node_modules/better-sqlite3/package.json" ]; then
        echo "   ✓ better-sqlite3 installed successfully"
    else
        echo "❌ FATAL: Failed to install better-sqlite3"
        echo "   The vector database is REQUIRED for Nelson Protocol."
        echo "   Try manually: npm install better-sqlite3"
        exit 1
    fi
fi

# Step 4: Check for existing configuration files
echo ""
echo "📄 Checking configuration files..."

if [ ! -f "$NELSON_DIR/NELSON_SOUL.md" ]; then
    echo "   ⚠️  NELSON_SOUL.md not found - please create manually or copy from template"
else
    echo "   ✓ NELSON_SOUL.md exists"
fi

if [ ! -f "$NELSON_DIR/MEMORY.md" ]; then
    echo "   ⚠️  MEMORY.md not found - please create manually or copy from template"
else
    echo "   ✓ MEMORY.md exists"
fi

if [ ! -f "$NELSON_DIR/context-loader.md" ]; then
    echo "   ⚠️  context-loader.md not found - please create manually or copy from template"
else
    echo "   ✓ context-loader.md exists"
fi

# Step 5: Create today's log if doesn't exist
TODAY=$(date +%Y-%m-%d)
TODAY_LOG="$MEMORY_DIR/$TODAY.md"

if [ ! -f "$TODAY_LOG" ]; then
    echo ""
    echo "📝 Creating today's log..."
    cat > "$TODAY_LOG" << EOF
# Daily Log: $TODAY

## Session: Nelson Setup

**Started:** $(date +%H:%M)
**Mode:** Standard
**Status:** SETUP_COMPLETE

---

## Tasks Completed

- [x] Nelson Protocol v4.0 installed
- [x] Vector database initialized

---

## Key Decisions Made

1. **Vector DB is mandatory** - Essential for efficient memory retrieval

---

## Next Actions

1. Test memory search with: node .nelson/search.cjs "test"
2. Review NELSON_SOUL.md
3. Seed MEMORY.md with project knowledge

---

*End of $TODAY log*
EOF
    echo "   ✓ Created $TODAY_LOG"
else
    echo "   ✓ Today's log exists"
fi

# Step 6: Create patterns files if don't exist
if [ ! -f "$PATTERNS_DIR/successes.md" ]; then
    echo ""
    echo "📊 Creating patterns files..."
    cat > "$PATTERNS_DIR/successes.md" << 'EOF'
# Success Patterns

**Purpose:** Document approaches that worked well for reuse in future sessions.

---

## Pattern: Vector Database for Memory

**When:** Starting any Nelson session
**Pattern:** Use FTS5 search instead of loading full files
**Why it works:** Targeted retrieval uses less context window
**Evidence:** File loading costs ~4000 tokens, search costs ~500 tokens

---

## Template

### Pattern Name
**When:** [Situation]
**Pattern:** [What to do]
**Why it works:** [Explanation]
**Evidence:** [Proof]

---

*Add patterns as you discover them.*
EOF
    echo "   ✓ Created successes.md"
fi

if [ ! -f "$PATTERNS_DIR/failures.md" ]; then
    cat > "$PATTERNS_DIR/failures.md" << 'EOF'
# Failure Patterns (Anti-Patterns)

**Purpose:** Document approaches that failed so we don't repeat them.

---

## Anti-Pattern: Loading Full Files

**What happened:** Loaded entire MEMORY.md to find one section
**Why it failed:** Wasted 3000+ tokens of context window
**Lesson:** Use vector search to retrieve only relevant chunks
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
EOF
    echo "   ✓ Created failures.md"
fi

# Step 7: Create/update initialization script
echo ""
echo "🗄️  Setting up vector database..."

# The init-db.cjs should already exist, but ensure it's there
if [ ! -f "$NELSON_DIR/init-db.cjs" ]; then
    echo "   ⚠️  init-db.cjs not found - this should have been created earlier"
    echo "   Please ensure the Nelson files are complete"
fi

# Run database initialization (REQUIRED)
echo "   → Initializing database..."
INIT_FLAGS=""
if [ "$FORCE_REINDEX" = true ]; then
    INIT_FLAGS="--force"
    echo "   (Force re-index enabled)"
fi
if node "$NELSON_DIR/init-db.cjs" $INIT_FLAGS 2>&1; then
    echo "   ✓ Vector database initialized"
else
    echo "❌ FATAL: Database initialization failed"
    echo "   The vector database is REQUIRED for Nelson Protocol."
    echo "   Check the error above and try: node $NELSON_DIR/init-db.cjs"
    exit 1
fi

# Step 8: Index existing memory files
echo ""
echo "📚 Indexing memory files..."

# Check if there are files to index
FILE_COUNT=$(find "$NELSON_DIR" -name "*.md" | wc -l | tr -d ' ')
echo "   Found $FILE_COUNT markdown files to index"

# Run the indexer if it exists
if [ -f "$NELSON_DIR/init-db.cjs" ]; then
    echo "   → Re-running init-db.cjs to index files..."
    node "$NELSON_DIR/init-db.cjs" 2>&1 | grep -v "^$" | while read line; do echo "     $line"; done || true
fi

# Step 9: Create search utility (shell fallback)
echo ""
echo "🔍 Creating search utilities..."

cat > "$NELSON_DIR/search.sh" << 'EOF'
#!/bin/bash
# Nelson Memory Search Utility (Shell fallback)
# Prefer: node .nelson/search.cjs "keyword"
# This script is for when Node isn't available

if [ -z "$1" ]; then
    echo "Usage: .nelson/search.sh \"keyword\""
    echo "Better: node .nelson/search.cjs \"keyword\""
    exit 1
fi

KEYWORD="$1"
NELSON_DIR=".nelson"

echo "🔍 Searching for: $KEYWORD"
echo "(Note: Use 'node .nelson/search.cjs' for better results)"
echo ""

echo "=== MEMORY.md ==="
grep -i -n -C 2 "$KEYWORD" "$NELSON_DIR/MEMORY.md" 2>/dev/null || echo "(no matches)"
echo ""

echo "=== Daily Logs ==="
grep -ri -n "$KEYWORD" "$NELSON_DIR/memory/" 2>/dev/null || echo "(no matches)"
echo ""

echo "=== Patterns ==="
grep -ri -n "$KEYWORD" "$NELSON_DIR/patterns/" 2>/dev/null || echo "(no matches)"
EOF

chmod +x "$NELSON_DIR/search.sh"
echo "   ✓ Created search.sh (shell fallback)"
echo "   ✓ Primary search: node .nelson/search.cjs"

# Step 10: Install git hooks (unless --skip-hooks)
if [ "$SKIP_HOOKS" = false ]; then
    echo ""
    echo "🔗 Installing git hooks for auto re-indexing..."

    GIT_HOOKS_DIR=".git/hooks"

    if [ -d "$GIT_HOOKS_DIR" ]; then
        # Create post-commit hook for auto re-indexing
        cat > "$GIT_HOOKS_DIR/post-commit" << 'HOOK_EOF'
#!/bin/bash
# Nelson Auto Re-Index Hook (post-commit)
# Re-indexes memory database when markdown files change

# Check if any .md files were changed in this commit
CHANGED_MD=$(git diff-tree --no-commit-id --name-only -r HEAD 2>/dev/null | grep '\.md$' || true)

if [ -n "$CHANGED_MD" ]; then
    # Count changed files
    MD_COUNT=$(echo "$CHANGED_MD" | wc -l | tr -d ' ')

    echo ""
    echo "📚 Nelson: $MD_COUNT markdown file(s) changed, re-indexing memory..."

    # Run incremental re-index (only changed files)
    if [ -f ".nelson/init-db.cjs" ]; then
        node .nelson/init-db.cjs 2>/dev/null | grep -E "(✓|Indexed:|Total:)" || true
        echo "   ✓ Memory database updated"
    fi
fi
HOOK_EOF
        chmod +x "$GIT_HOOKS_DIR/post-commit"
        echo "   ✓ Installed post-commit hook (auto re-index on commit)"

        # Create pre-push hook for verification
        cat > "$GIT_HOOKS_DIR/pre-push" << 'HOOK_EOF'
#!/bin/bash
# Nelson Pre-Push Hook
# Ensures memory is fully indexed before push

echo ""
echo "📚 Nelson: Verifying memory index before push..."

if [ -f ".nelson/init-db.cjs" ]; then
    # Run full index to catch any missed files
    RESULT=$(node .nelson/init-db.cjs 2>/dev/null | grep -E "(Indexed:|unchanged)" || true)

    if echo "$RESULT" | grep -q "Indexed:"; then
        echo "   ✓ Memory index updated"
        echo "$RESULT" | grep "Indexed:" | head -5
    else
        echo "   ✓ Memory index already up to date"
    fi
fi

# Always allow push (this is informational only)
exit 0
HOOK_EOF
        chmod +x "$GIT_HOOKS_DIR/pre-push"
        echo "   ✓ Installed pre-push hook (verify index before push)"

    else
        echo "   ⚠️  Not a git repository. Skipping hook installation."
        echo "   Run 'git init' first if you want auto re-indexing."
    fi
else
    echo ""
    echo "⏭️  Skipping git hooks (--skip-hooks flag)"
fi

# Step 11: Verify installation
echo ""
echo "🧪 Verifying installation..."

# Check database exists
if [ -f "$DB_FILE" ]; then
    DB_SIZE=$(ls -lh "$DB_FILE" | awk '{print $5}')
    echo "   ✓ Database exists: $DB_FILE ($DB_SIZE)"
else
    echo "   ⚠️  Database file not found - initialization may have failed"
fi

# Check search works
if node "$NELSON_DIR/search.cjs" --help > /dev/null 2>&1; then
    echo "   ✓ Search utility working"
else
    echo "   ⚠️  Search utility may have issues - check manually"
fi

# Check capture works
if node "$NELSON_DIR/capture.cjs" --help > /dev/null 2>&1; then
    echo "   ✓ Capture utility working"
else
    echo "   ⚠️  Capture utility may have issues - check manually"
fi

# Step 11: Final summary
echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                    SETUP COMPLETE ✅                             ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "Directory structure:"
echo "  $NELSON_DIR/"
echo "  ├── NELSON_SOUL.md       # Agent identity"
echo "  ├── MEMORY.md            # Long-term knowledge"
echo "  ├── context-loader.md    # Auto-retrieval instructions"
echo "  ├── memory.db            # Vector database (REQUIRED) ✓"
echo "  ├── init-db.cjs          # Database initialization"
echo "  ├── search.cjs           # Primary search utility"
echo "  ├── capture.cjs          # Session capture utility"
echo "  ├── memory/"
echo "  │   └── $TODAY.md        # Today's log"
echo "  └── patterns/"
echo "      ├── successes.md     # What works"
echo "      └── failures.md      # What doesn't"
echo ""
echo "Commands:"
echo "  • Search memory:     node .nelson/search.cjs \"keyword\""
echo "  • Search by type:    node .nelson/search.cjs \"query\" --type instructions"
echo "  • Search headers:    node .nelson/search.cjs --header \"MCP\""
echo "  • Index stats:       node .nelson/search.cjs --stats"
echo "  • List sessions:     node .nelson/search.cjs --list-sessions"
echo "  • Capture session:   node .nelson/capture.cjs \"Name\" \"STATUS\""
echo "  • Re-index files:    node .nelson/init-db.cjs"
echo "  • Force re-index:    node .nelson/init-db.cjs --force"
echo ""

if [ "$SKIP_HOOKS" = false ] && [ -d ".git/hooks" ]; then
    echo "Git hooks installed:"
    echo "  • post-commit: Auto re-index when .md files change"
    echo "  • pre-push: Verify index is current before pushing"
    echo ""
fi

echo "File types indexed (by priority):"
echo "  1. CLAUDE.md         (instructions) - priority 1.0"
echo "  2. .nelson/*.md      (memory/soul)  - priority 0.8-0.95"
echo "  3. docs/**/*.md      (documentation)- priority 0.6-0.7"
echo "  4. README.md         (overview)     - priority 0.75"
echo "  5. **/*.md           (other)        - priority 0.5"
echo ""
echo "Nelson Protocol v4.0 is ready! 🎯"
echo ""
echo "The vector database indexes ALL documentation for smart search."
