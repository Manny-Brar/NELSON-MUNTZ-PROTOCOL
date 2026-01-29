/**
 * Nelson Memory Vector Database Initialization v2.0
 *
 * ENHANCED: Indexes ALL project documentation, not just .nelson/ files
 * - CLAUDE.md (project instructions - highest priority)
 * - README.md (project overview)
 * - docs/**/*.md (all documentation)
 * - .nelson/**/*.md (memory, patterns, soul)
 *
 * Features:
 * - Semantic chunking (respects markdown headers)
 * - File priority weighting for search ranking
 * - Auto-skip of binary files and excluded directories
 *
 * Run: node .nelson/init-db.cjs
 * Run with custom paths: node .nelson/init-db.cjs --include "src/**/*.md"
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const NELSON_DIR = path.join(process.cwd(), '.nelson');
const DB_PATH = path.join(NELSON_DIR, 'memory.db');

// Chunk configuration - optimized for LLM context retrieval
const CHUNK_SIZE = 600; // tokens (increased from 400 for better semantic units)
const CHUNK_OVERLAP = 100; // tokens overlap between chunks
const CHARS_PER_CHUNK = CHUNK_SIZE * 4; // ~2400 chars
const CHARS_OVERLAP = CHUNK_OVERLAP * 4; // ~400 chars

// Directories to always skip
const EXCLUDED_DIRS = [
    'node_modules',
    '.git',
    'dist',
    'build',
    '.next',
    '.vercel',
    'coverage',
    '.turbo',
    '__pycache__',
    'venv',
    '.venv'
];

// File patterns to index (in priority order)
const INDEX_PATTERNS = [
    // Priority 1: Project instructions (highest weight)
    { pattern: 'CLAUDE.md', priority: 1.0, description: 'Project instructions' },

    // Priority 2: Nelson memory system
    { pattern: '.nelson/NELSON_SOUL.md', priority: 0.95, description: 'Agent identity' },
    { pattern: '.nelson/MEMORY.md', priority: 0.9, description: 'Long-term memory' },
    { pattern: '.nelson/patterns/*.md', priority: 0.85, description: 'Patterns' },
    { pattern: '.nelson/memory/*.md', priority: 0.8, description: 'Daily logs' },

    // Priority 3: Core documentation
    { pattern: 'README.md', priority: 0.75, description: 'Project overview' },
    { pattern: 'docs/1-strategy/*.md', priority: 0.7, description: 'Strategy docs' },
    { pattern: 'docs/5-technical/*.md', priority: 0.65, description: 'Technical docs' },

    // Priority 4: Other documentation
    { pattern: 'docs/**/*.md', priority: 0.6, description: 'Documentation' },

    // Priority 5: Other markdown files
    { pattern: '**/*.md', priority: 0.5, description: 'Other markdown' }
];

/**
 * Initialize the database schema
 */
function initializeSchema(db) {
    console.log('📊 Creating database schema...');

    db.exec(`
        -- Memory chunks table with priority weighting
        CREATE TABLE IF NOT EXISTS chunks (
            id TEXT PRIMARY KEY,
            file TEXT NOT NULL,
            line_start INTEGER,
            line_end INTEGER,
            content TEXT NOT NULL,
            content_hash TEXT NOT NULL,
            chunk_index INTEGER,
            section_header TEXT,
            file_priority REAL DEFAULT 0.5,
            created_at TEXT DEFAULT (datetime('now')),
            updated_at TEXT DEFAULT (datetime('now'))
        );

        -- Metadata table for tracking indexed files
        CREATE TABLE IF NOT EXISTS indexed_files (
            file TEXT PRIMARY KEY,
            content_hash TEXT NOT NULL,
            chunk_count INTEGER,
            file_priority REAL DEFAULT 0.5,
            file_type TEXT,
            indexed_at TEXT DEFAULT (datetime('now'))
        );

        -- Full-text search index using FTS5
        CREATE VIRTUAL TABLE IF NOT EXISTS chunks_fts USING fts5(
            content,
            file,
            section_header,
            content='chunks',
            content_rowid='rowid'
        );

        -- Triggers to keep FTS in sync with chunks table
        CREATE TRIGGER IF NOT EXISTS chunks_ai AFTER INSERT ON chunks BEGIN
            INSERT INTO chunks_fts(rowid, content, file, section_header)
            VALUES (new.rowid, new.content, new.file, new.section_header);
        END;

        CREATE TRIGGER IF NOT EXISTS chunks_ad AFTER DELETE ON chunks BEGIN
            INSERT INTO chunks_fts(chunks_fts, rowid, content, file, section_header)
            VALUES('delete', old.rowid, old.content, old.file, old.section_header);
        END;

        CREATE TRIGGER IF NOT EXISTS chunks_au AFTER UPDATE ON chunks BEGIN
            INSERT INTO chunks_fts(chunks_fts, rowid, content, file, section_header)
            VALUES('delete', old.rowid, old.content, old.file, old.section_header);
            INSERT INTO chunks_fts(rowid, content, file, section_header)
            VALUES (new.rowid, new.content, new.file, new.section_header);
        END;

        -- Indexes for efficient querying
        CREATE INDEX IF NOT EXISTS idx_chunks_file ON chunks(file);
        CREATE INDEX IF NOT EXISTS idx_chunks_hash ON chunks(content_hash);
        CREATE INDEX IF NOT EXISTS idx_chunks_priority ON chunks(file_priority DESC);
        CREATE INDEX IF NOT EXISTS idx_chunks_created ON chunks(created_at);
    `);

    console.log('   ✓ Schema created');
}

/**
 * Calculate SHA-256 hash of content
 */
function hashContent(content) {
    return crypto.createHash('sha256').update(content).digest('hex').substring(0, 16);
}

/**
 * Check if a path should be excluded
 */
function shouldExclude(filePath) {
    const parts = filePath.split(path.sep);
    return parts.some(part => EXCLUDED_DIRS.includes(part));
}

/**
 * Get file priority based on matching pattern
 */
function getFilePriority(filePath) {
    const relativePath = filePath.replace(process.cwd() + path.sep, '');

    for (const { pattern, priority } of INDEX_PATTERNS) {
        // Simple glob matching
        const regex = new RegExp(
            '^' + pattern
                .replace(/\*\*/g, '.*')
                .replace(/\*/g, '[^/]*')
                .replace(/\//g, '[\\\\/]') + '$'
        );

        if (regex.test(relativePath)) {
            return priority;
        }
    }

    return 0.5; // Default priority
}

/**
 * Extract markdown sections with headers
 * Returns array of { header, content, lineStart, lineEnd }
 */
function extractMarkdownSections(content) {
    const lines = content.split('\n');
    const sections = [];
    let currentSection = {
        header: null,
        content: [],
        lineStart: 1,
        lineEnd: 1
    };

    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];

        // Check for header (# ## ### etc.)
        const headerMatch = line.match(/^(#{1,6})\s+(.+)$/);

        if (headerMatch) {
            // Save previous section if it has content
            if (currentSection.content.length > 0) {
                currentSection.lineEnd = i;
                sections.push({
                    header: currentSection.header,
                    content: currentSection.content.join('\n'),
                    lineStart: currentSection.lineStart,
                    lineEnd: currentSection.lineEnd
                });
            }

            // Start new section
            currentSection = {
                header: headerMatch[2].trim(),
                content: [line],
                lineStart: i + 1,
                lineEnd: i + 1
            };
        } else {
            currentSection.content.push(line);
        }
    }

    // Don't forget the last section
    if (currentSection.content.length > 0) {
        currentSection.lineEnd = lines.length;
        sections.push({
            header: currentSection.header,
            content: currentSection.content.join('\n'),
            lineStart: currentSection.lineStart,
            lineEnd: currentSection.lineEnd
        });
    }

    return sections;
}

/**
 * Split content into overlapping chunks, respecting section boundaries
 */
function chunkContent(content, filePath, priority) {
    const sections = extractMarkdownSections(content);
    const chunks = [];
    let chunkIndex = 0;

    for (const section of sections) {
        const sectionContent = section.content;

        // If section is small enough, keep it as one chunk
        if (sectionContent.length <= CHARS_PER_CHUNK) {
            if (sectionContent.trim().length > 0) {
                chunks.push({
                    id: `${filePath}:${section.lineStart}-${section.lineEnd}:${chunkIndex}`,
                    file: filePath,
                    line_start: section.lineStart,
                    line_end: section.lineEnd,
                    content: sectionContent,
                    content_hash: hashContent(sectionContent),
                    chunk_index: chunkIndex,
                    section_header: section.header,
                    file_priority: priority
                });
                chunkIndex++;
            }
            continue;
        }

        // Large section - split with overlap
        const lines = sectionContent.split('\n');
        let currentChunk = '';
        let currentLineStart = section.lineStart;

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const potentialChunk = currentChunk + (currentChunk ? '\n' : '') + line;

            if (potentialChunk.length > CHARS_PER_CHUNK && currentChunk.length > 0) {
                // Save current chunk
                chunks.push({
                    id: `${filePath}:${currentLineStart}-${section.lineStart + i - 1}:${chunkIndex}`,
                    file: filePath,
                    line_start: currentLineStart,
                    line_end: section.lineStart + i - 1,
                    content: currentChunk,
                    content_hash: hashContent(currentChunk),
                    chunk_index: chunkIndex,
                    section_header: section.header,
                    file_priority: priority
                });
                chunkIndex++;

                // Start new chunk with overlap
                const overlapLines = Math.ceil(CHARS_OVERLAP / 80);
                const startLine = Math.max(0, i - overlapLines);
                currentChunk = lines.slice(startLine, i + 1).join('\n');
                currentLineStart = section.lineStart + startLine;
            } else {
                currentChunk = potentialChunk;
            }
        }

        // Don't forget the last chunk
        if (currentChunk.trim().length > 0) {
            chunks.push({
                id: `${filePath}:${currentLineStart}-${section.lineEnd}:${chunkIndex}`,
                file: filePath,
                line_start: currentLineStart,
                line_end: section.lineEnd,
                content: currentChunk,
                content_hash: hashContent(currentChunk),
                chunk_index: chunkIndex,
                section_header: section.header,
                file_priority: priority
            });
            chunkIndex++;
        }
    }

    return chunks;
}

/**
 * Index a single file
 */
function indexFile(db, filePath, priority) {
    const absolutePath = path.isAbsolute(filePath) ? filePath : path.join(process.cwd(), filePath);

    if (!fs.existsSync(absolutePath)) {
        return { indexed: false, reason: 'not_found' };
    }

    // Skip non-markdown files
    if (!absolutePath.endsWith('.md')) {
        return { indexed: false, reason: 'not_markdown' };
    }

    // Skip excluded directories
    if (shouldExclude(absolutePath)) {
        return { indexed: false, reason: 'excluded' };
    }

    const content = fs.readFileSync(absolutePath, 'utf-8');
    const contentHash = hashContent(content);
    const relativePath = path.relative(process.cwd(), absolutePath);

    // Check if file is already indexed with same content
    const existing = db.prepare('SELECT content_hash FROM indexed_files WHERE file = ?').get(relativePath);

    if (existing && existing.content_hash === contentHash) {
        return { indexed: false, reason: 'unchanged', chunks: 0 };
    }

    // Delete old chunks for this file
    db.prepare('DELETE FROM chunks WHERE file = ?').run(relativePath);

    // Chunk and insert
    const chunks = chunkContent(content, relativePath, priority);

    if (chunks.length === 0) {
        return { indexed: false, reason: 'empty', chunks: 0 };
    }

    const insertChunk = db.prepare(`
        INSERT INTO chunks (id, file, line_start, line_end, content, content_hash, chunk_index, section_header, file_priority)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);

    const insertMany = db.transaction((chunks) => {
        for (const chunk of chunks) {
            insertChunk.run(
                chunk.id,
                chunk.file,
                chunk.line_start,
                chunk.line_end,
                chunk.content,
                chunk.content_hash,
                chunk.chunk_index,
                chunk.section_header,
                chunk.file_priority
            );
        }
    });

    insertMany(chunks);

    // Determine file type
    let fileType = 'other';
    if (relativePath.includes('.nelson/memory/')) fileType = 'daily_log';
    else if (relativePath.includes('.nelson/patterns/')) fileType = 'pattern';
    else if (relativePath === '.nelson/MEMORY.md') fileType = 'memory';
    else if (relativePath === '.nelson/NELSON_SOUL.md') fileType = 'soul';
    else if (relativePath === 'CLAUDE.md') fileType = 'instructions';
    else if (relativePath === 'README.md') fileType = 'readme';
    else if (relativePath.startsWith('docs/')) fileType = 'documentation';

    // Update indexed_files tracking
    db.prepare(`
        INSERT OR REPLACE INTO indexed_files (file, content_hash, chunk_count, file_priority, file_type, indexed_at)
        VALUES (?, ?, ?, ?, ?, datetime('now'))
    `).run(relativePath, contentHash, chunks.length, priority, fileType);

    return { indexed: true, chunks: chunks.length, fileType };
}

/**
 * Recursively find all markdown files
 */
function findMarkdownFiles(dir, files = []) {
    if (!fs.existsSync(dir)) {
        return files;
    }

    const items = fs.readdirSync(dir, { withFileTypes: true });

    for (const item of items) {
        const fullPath = path.join(dir, item.name);

        if (item.isDirectory()) {
            if (!EXCLUDED_DIRS.includes(item.name)) {
                findMarkdownFiles(fullPath, files);
            }
        } else if (item.isFile() && item.name.endsWith('.md')) {
            files.push(fullPath);
        }
    }

    return files;
}

/**
 * Index all files matching patterns
 */
function indexAllFiles(db) {
    console.log('');
    console.log('📚 Indexing files...');

    const stats = {
        indexed: 0,
        skipped: 0,
        unchanged: 0,
        totalChunks: 0,
        byType: {}
    };

    // Find all markdown files in project
    const allFiles = findMarkdownFiles(process.cwd());

    // Also check for specific high-priority files that might be missed
    const priorityFiles = ['CLAUDE.md', 'README.md'];
    for (const file of priorityFiles) {
        const fullPath = path.join(process.cwd(), file);
        if (fs.existsSync(fullPath) && !allFiles.includes(fullPath)) {
            allFiles.unshift(fullPath);
        }
    }

    console.log(`   Found ${allFiles.length} markdown files`);
    console.log('');

    for (const filePath of allFiles) {
        const priority = getFilePriority(filePath);
        const result = indexFile(db, filePath, priority);
        const relativePath = path.relative(process.cwd(), filePath);

        if (result.indexed) {
            stats.indexed++;
            stats.totalChunks += result.chunks;
            stats.byType[result.fileType] = (stats.byType[result.fileType] || 0) + 1;
            console.log(`   ✓ ${relativePath} (${result.chunks} chunks, priority: ${priority.toFixed(2)})`);
        } else if (result.reason === 'unchanged') {
            stats.unchanged++;
            // Silent for unchanged files
        } else {
            stats.skipped++;
        }
    }

    console.log('');
    console.log(`   Indexed: ${stats.indexed} files (${stats.totalChunks} chunks)`);
    console.log(`   Unchanged: ${stats.unchanged} files`);
    console.log(`   Skipped: ${stats.skipped} files`);

    if (Object.keys(stats.byType).length > 0) {
        console.log('');
        console.log('   By type:');
        for (const [type, count] of Object.entries(stats.byType)) {
            console.log(`     • ${type}: ${count} files`);
        }
    }

    return stats;
}

/**
 * Main initialization
 */
async function main() {
    console.log('╔══════════════════════════════════════════════════════════════════╗');
    console.log('║     NELSON MEMORY DATABASE v2.0 - FULL DOCUMENTATION INDEX        ║');
    console.log('╚══════════════════════════════════════════════════════════════════╝');
    console.log('');

    // Ensure .nelson directory exists
    if (!fs.existsSync(NELSON_DIR)) {
        fs.mkdirSync(NELSON_DIR, { recursive: true });
        console.log('📁 Created .nelson/ directory');
    }

    // Check for better-sqlite3
    let Database;
    try {
        Database = require('better-sqlite3');
        console.log('✓ better-sqlite3 found');
    } catch (e) {
        console.log('❌ better-sqlite3 not installed');
        console.log('');
        console.log('To enable the vector database:');
        console.log('  npm install better-sqlite3');
        console.log('');
        console.log('Then run this script again:');
        console.log('  node .nelson/init-db.cjs');
        console.log('');
        console.log('Note: Basic file-based memory will still work without this.');
        process.exit(0);
    }

    // Initialize database
    console.log(`📁 Database path: ${DB_PATH}`);

    // Delete old database to ensure clean schema
    if (fs.existsSync(DB_PATH)) {
        const args = process.argv.slice(2);
        if (args.includes('--force') || args.includes('-f')) {
            fs.unlinkSync(DB_PATH);
            console.log('   Removed old database (--force)');
        }
    }

    const db = new Database(DB_PATH);

    // Try to load sqlite-vec for vector search (optional)
    try {
        db.loadExtension('vec0');
        console.log('✓ sqlite-vec extension loaded (vector search enabled)');
    } catch (e) {
        console.log('ℹ️  sqlite-vec not available (using FTS5 full-text search)');
    }

    // Initialize schema
    initializeSchema(db);

    // Index all files
    const stats = indexAllFiles(db);

    // Report final status
    const chunkCount = db.prepare('SELECT COUNT(*) as count FROM chunks').get();
    const fileCount = db.prepare('SELECT COUNT(*) as count FROM indexed_files').get();

    // Get priority distribution
    const priorityDist = db.prepare(`
        SELECT
            CASE
                WHEN file_priority >= 0.9 THEN 'critical'
                WHEN file_priority >= 0.7 THEN 'high'
                WHEN file_priority >= 0.5 THEN 'medium'
                ELSE 'low'
            END as priority_level,
            COUNT(*) as count
        FROM indexed_files
        GROUP BY priority_level
        ORDER BY file_priority DESC
    `).all();

    console.log('');
    console.log('╔══════════════════════════════════════════════════════════════════╗');
    console.log('║                    INITIALIZATION COMPLETE                        ║');
    console.log('╚══════════════════════════════════════════════════════════════════╝');
    console.log('');
    console.log('📊 Database Statistics:');
    console.log(`   • Files indexed: ${fileCount.count}`);
    console.log(`   • Total chunks: ${chunkCount.count}`);
    console.log(`   • Database size: ${(fs.statSync(DB_PATH).size / 1024).toFixed(1)} KB`);

    if (priorityDist.length > 0) {
        console.log('');
        console.log('📈 Priority Distribution:');
        for (const { priority_level, count } of priorityDist) {
            console.log(`   • ${priority_level}: ${count} files`);
        }
    }

    console.log('');
    console.log('🔍 Search with:');
    console.log('   node .nelson/search.cjs "your query"');
    console.log('   node .nelson/search.cjs --context "task description"');
    console.log('');
    console.log('🔄 Re-index with:');
    console.log('   node .nelson/init-db.cjs          # Incremental (skip unchanged)');
    console.log('   node .nelson/init-db.cjs --force  # Full re-index');
    console.log('');

    db.close();
}

main().catch(console.error);
