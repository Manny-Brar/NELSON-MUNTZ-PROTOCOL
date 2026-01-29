/**
 * Nelson Memory Vector Database Initialization
 *
 * This script initializes the sqlite database for Nelson's memory system.
 * It creates tables for chunks and full-text search.
 *
 * Run: node .nelson/init-db.cjs
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const NELSON_DIR = path.join(process.cwd(), '.nelson');
const DB_PATH = path.join(NELSON_DIR, 'memory.db');
const MEMORY_DIR = path.join(NELSON_DIR, 'memory');
const PATTERNS_DIR = path.join(NELSON_DIR, 'patterns');

// Chunk configuration
const CHUNK_SIZE = 400; // tokens (approx 4 chars per token)
const CHUNK_OVERLAP = 80; // tokens overlap between chunks
const CHARS_PER_CHUNK = CHUNK_SIZE * 4; // ~1600 chars
const CHARS_OVERLAP = CHUNK_OVERLAP * 4; // ~320 chars

/**
 * Initialize the database schema
 */
function initializeSchema(db) {
    console.log('📊 Creating database schema...');

    db.exec(`
        -- Memory chunks table
        CREATE TABLE IF NOT EXISTS chunks (
            id TEXT PRIMARY KEY,
            file TEXT NOT NULL,
            line_start INTEGER,
            line_end INTEGER,
            content TEXT NOT NULL,
            content_hash TEXT NOT NULL,
            chunk_index INTEGER,
            created_at TEXT DEFAULT (datetime('now')),
            updated_at TEXT DEFAULT (datetime('now'))
        );

        -- Metadata table for tracking indexed files
        CREATE TABLE IF NOT EXISTS indexed_files (
            file TEXT PRIMARY KEY,
            content_hash TEXT NOT NULL,
            chunk_count INTEGER,
            indexed_at TEXT DEFAULT (datetime('now'))
        );

        -- Full-text search index using FTS5
        CREATE VIRTUAL TABLE IF NOT EXISTS chunks_fts USING fts5(
            content,
            file,
            content='chunks',
            content_rowid='rowid'
        );

        -- Triggers to keep FTS in sync with chunks table
        CREATE TRIGGER IF NOT EXISTS chunks_ai AFTER INSERT ON chunks BEGIN
            INSERT INTO chunks_fts(rowid, content, file)
            VALUES (new.rowid, new.content, new.file);
        END;

        CREATE TRIGGER IF NOT EXISTS chunks_ad AFTER DELETE ON chunks BEGIN
            INSERT INTO chunks_fts(chunks_fts, rowid, content, file)
            VALUES('delete', old.rowid, old.content, old.file);
        END;

        CREATE TRIGGER IF NOT EXISTS chunks_au AFTER UPDATE ON chunks BEGIN
            INSERT INTO chunks_fts(chunks_fts, rowid, content, file)
            VALUES('delete', old.rowid, old.content, old.file);
            INSERT INTO chunks_fts(rowid, content, file)
            VALUES (new.rowid, new.content, new.file);
        END;

        -- Indexes for efficient querying
        CREATE INDEX IF NOT EXISTS idx_chunks_file ON chunks(file);
        CREATE INDEX IF NOT EXISTS idx_chunks_hash ON chunks(content_hash);
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
 * Split content into overlapping chunks
 */
function chunkContent(content, filePath) {
    const lines = content.split('\n');
    const chunks = [];
    let currentChunk = '';
    let currentLineStart = 1;
    let chunkIndex = 0;

    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        const potentialChunk = currentChunk + (currentChunk ? '\n' : '') + line;

        if (potentialChunk.length > CHARS_PER_CHUNK && currentChunk.length > 0) {
            // Save current chunk
            chunks.push({
                id: `${filePath}:${currentLineStart}-${i}:${chunkIndex}`,
                file: filePath,
                line_start: currentLineStart,
                line_end: i,
                content: currentChunk,
                content_hash: hashContent(currentChunk),
                chunk_index: chunkIndex
            });

            chunkIndex++;

            // Start new chunk with overlap
            const overlapLines = Math.ceil(CHARS_OVERLAP / 80); // Assume ~80 chars per line
            const startLine = Math.max(0, i - overlapLines);
            currentChunk = lines.slice(startLine, i + 1).join('\n');
            currentLineStart = startLine + 1;
        } else {
            currentChunk = potentialChunk;
        }
    }

    // Don't forget the last chunk
    if (currentChunk.trim().length > 0) {
        chunks.push({
            id: `${filePath}:${currentLineStart}-${lines.length}:${chunkIndex}`,
            file: filePath,
            line_start: currentLineStart,
            line_end: lines.length,
            content: currentChunk,
            content_hash: hashContent(currentChunk),
            chunk_index: chunkIndex
        });
    }

    return chunks;
}

/**
 * Index a single file
 */
function indexFile(db, filePath) {
    const absolutePath = path.isAbsolute(filePath) ? filePath : path.join(process.cwd(), filePath);

    if (!fs.existsSync(absolutePath)) {
        console.log(`   ⚠️  File not found: ${filePath}`);
        return 0;
    }

    const content = fs.readFileSync(absolutePath, 'utf-8');
    const contentHash = hashContent(content);
    const relativePath = path.relative(process.cwd(), absolutePath);

    // Check if file is already indexed with same content
    const existing = db.prepare('SELECT content_hash FROM indexed_files WHERE file = ?').get(relativePath);

    if (existing && existing.content_hash === contentHash) {
        console.log(`   ⏭️  Skipping (unchanged): ${relativePath}`);
        return 0;
    }

    // Delete old chunks for this file
    db.prepare('DELETE FROM chunks WHERE file = ?').run(relativePath);

    // Chunk and insert
    const chunks = chunkContent(content, relativePath);

    const insertChunk = db.prepare(`
        INSERT INTO chunks (id, file, line_start, line_end, content, content_hash, chunk_index)
        VALUES (?, ?, ?, ?, ?, ?, ?)
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
                chunk.chunk_index
            );
        }
    });

    insertMany(chunks);

    // Update indexed_files tracking
    db.prepare(`
        INSERT OR REPLACE INTO indexed_files (file, content_hash, chunk_count, indexed_at)
        VALUES (?, ?, ?, datetime('now'))
    `).run(relativePath, contentHash, chunks.length);

    console.log(`   ✓ Indexed: ${relativePath} (${chunks.length} chunks)`);
    return chunks.length;
}

/**
 * Index all memory files
 */
function indexAllMemory(db) {
    console.log('');
    console.log('📚 Indexing memory files...');

    let totalChunks = 0;

    // Index MEMORY.md
    const memoryMd = path.join(NELSON_DIR, 'MEMORY.md');
    if (fs.existsSync(memoryMd)) {
        totalChunks += indexFile(db, memoryMd);
    }

    // Index NELSON_SOUL.md
    const soulMd = path.join(NELSON_DIR, 'NELSON_SOUL.md');
    if (fs.existsSync(soulMd)) {
        totalChunks += indexFile(db, soulMd);
    }

    // Index daily logs
    if (fs.existsSync(MEMORY_DIR)) {
        const dailyLogs = fs.readdirSync(MEMORY_DIR).filter(f => f.endsWith('.md'));
        for (const log of dailyLogs) {
            totalChunks += indexFile(db, path.join(MEMORY_DIR, log));
        }
    }

    // Index patterns
    if (fs.existsSync(PATTERNS_DIR)) {
        const patterns = fs.readdirSync(PATTERNS_DIR).filter(f => f.endsWith('.md'));
        for (const pattern of patterns) {
            totalChunks += indexFile(db, path.join(PATTERNS_DIR, pattern));
        }
    }

    console.log(`   ✓ Total: ${totalChunks} chunks indexed`);
    return totalChunks;
}

/**
 * Main initialization
 */
async function main() {
    console.log('╔══════════════════════════════════════════════════════════════════╗');
    console.log('║        NELSON MEMORY DATABASE INITIALIZATION                      ║');
    console.log('╚══════════════════════════════════════════════════════════════════╝');
    console.log('');

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
    const db = new Database(DB_PATH);

    // Try to load sqlite-vec for vector search (optional)
    try {
        db.loadExtension('vec0');
        console.log('✓ sqlite-vec extension loaded (vector search enabled)');
    } catch (e) {
        console.log('ℹ️  sqlite-vec not available (using keyword search only)');
        console.log('   This is fine - FTS5 full-text search will be used');
    }

    // Initialize schema
    initializeSchema(db);

    // Index all memory files
    indexAllMemory(db);

    // Report final status
    const chunkCount = db.prepare('SELECT COUNT(*) as count FROM chunks').get();
    const fileCount = db.prepare('SELECT COUNT(*) as count FROM indexed_files').get();

    console.log('');
    console.log('╔══════════════════════════════════════════════════════════════════╗');
    console.log('║                    INITIALIZATION COMPLETE                        ║');
    console.log('╚══════════════════════════════════════════════════════════════════╝');
    console.log('');
    console.log(`📊 Database Statistics:`);
    console.log(`   • Files indexed: ${fileCount.count}`);
    console.log(`   • Total chunks: ${chunkCount.count}`);
    console.log(`   • Database size: ${(fs.statSync(DB_PATH).size / 1024).toFixed(1)} KB`);
    console.log('');
    console.log('🔍 Search with:');
    console.log('   node .nelson/search.cjs "your query"');
    console.log('   .nelson/search.sh "your query"');
    console.log('');

    db.close();
}

main().catch(console.error);
