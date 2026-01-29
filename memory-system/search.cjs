/**
 * Nelson Memory Search Module v2.0
 *
 * Enhanced with session-level retrieval for daily logs.
 * When a match is found in a daily log, returns the FULL session summary.
 * Falls back to chunk-level retrieval for MEMORY.md and patterns.
 *
 * Usage:
 *   node .nelson/search.cjs "your query"
 *   node .nelson/search.cjs "your query" --limit 10
 *   node .nelson/search.cjs "your query" --file MEMORY.md
 *   node .nelson/search.cjs --context "task description"
 *   node .nelson/search.cjs --session "keyword"  # Session-level search
 */

const fs = require('fs');
const path = require('path');

const NELSON_DIR = path.join(process.cwd(), '.nelson');
const DB_PATH = path.join(NELSON_DIR, 'memory.db');
const MEMORY_DIR = path.join(NELSON_DIR, 'memory');

/**
 * Check if a file is a daily log (memory/*.md)
 */
function isDailyLog(filePath) {
    return filePath.includes('memory/') && filePath.endsWith('.md');
}

/**
 * Extract the full session containing a specific line from a daily log
 * Sessions are delimited by "## Session:" headers
 */
function extractSessionFromDailyLog(filePath, lineNumber) {
    const fullPath = path.join(process.cwd(), filePath);

    if (!fs.existsSync(fullPath)) {
        return null;
    }

    const content = fs.readFileSync(fullPath, 'utf-8');
    const lines = content.split('\n');

    // Find all session boundaries
    const sessionStarts = [];
    for (let i = 0; i < lines.length; i++) {
        if (lines[i].startsWith('## Session:')) {
            sessionStarts.push(i);
        }
    }

    // If no sessions found, return the whole file
    if (sessionStarts.length === 0) {
        return {
            sessionName: 'Full Document',
            content: content,
            lineStart: 1,
            lineEnd: lines.length
        };
    }

    // Find which session contains the target line
    let sessionIndex = 0;
    for (let i = sessionStarts.length - 1; i >= 0; i--) {
        if (lineNumber >= sessionStarts[i]) {
            sessionIndex = i;
            break;
        }
    }

    // Extract session content
    const startLine = sessionStarts[sessionIndex];
    const endLine = sessionIndex < sessionStarts.length - 1
        ? sessionStarts[sessionIndex + 1] - 1
        : lines.length - 1;

    // Get session name from header
    const sessionHeader = lines[startLine];
    const sessionName = sessionHeader.replace('## Session:', '').trim();

    const sessionContent = lines.slice(startLine, endLine + 1).join('\n');

    return {
        sessionName,
        content: sessionContent,
        lineStart: startLine + 1,  // 1-indexed
        lineEnd: endLine + 1
    };
}

/**
 * Extract summary section from a session (Key Decisions, Insights, etc.)
 */
function extractSessionSummary(sessionContent) {
    // Priority sections to include in summary
    const summarySections = [
        '## Tasks Completed',
        '### Goal',
        '## Key Decisions Made',
        '## Insights Discovered',
        '### Key Insight',
        '### Implementation',
        '## Self-Assessment',
        '### Verdict'
    ];

    let summary = [];
    const lines = sessionContent.split('\n');
    let inSummarySection = false;
    let currentSection = '';

    for (const line of lines) {
        // Check if entering a summary section
        for (const section of summarySections) {
            if (line.startsWith(section)) {
                inSummarySection = true;
                currentSection = section;
                break;
            }
        }

        // Check if leaving section (new major section starts)
        if (inSummarySection && line.startsWith('## ') && !summarySections.some(s => line.startsWith(s))) {
            inSummarySection = false;
        }

        // Include session header
        if (line.startsWith('## Session:') || line.startsWith('**Started:') ||
            line.startsWith('**Mode:') || line.startsWith('**Status:')) {
            summary.push(line);
        }

        if (inSummarySection) {
            summary.push(line);
        }
    }

    return summary.join('\n');
}

/**
 * Search using FTS5 full-text search
 */
function searchFTS(db, query, options = {}) {
    const limit = options.limit || 5;
    const fileFilter = options.file || null;

    let sql = `
        SELECT
            c.id,
            c.file,
            c.line_start,
            c.line_end,
            c.content,
            bm25(chunks_fts) as score
        FROM chunks_fts
        JOIN chunks c ON chunks_fts.rowid = c.rowid
        WHERE chunks_fts MATCH ?
    `;

    const params = [query];

    if (fileFilter) {
        sql += ' AND c.file LIKE ?';
        params.push(`%${fileFilter}%`);
    }

    sql += ' ORDER BY score LIMIT ?';
    params.push(limit);

    try {
        return db.prepare(sql).all(...params);
    } catch (e) {
        // If FTS query fails, fall back to LIKE search
        console.log('⚠️  FTS query failed, using LIKE fallback');
        return searchLike(db, query, options);
    }
}

/**
 * Fallback search using LIKE (for simple queries)
 */
function searchLike(db, query, options = {}) {
    const limit = options.limit || 5;
    const fileFilter = options.file || null;

    let sql = `
        SELECT
            id,
            file,
            line_start,
            line_end,
            content,
            0 as score
        FROM chunks
        WHERE content LIKE ?
    `;

    const params = [`%${query}%`];

    if (fileFilter) {
        sql += ' AND file LIKE ?';
        params.push(`%${fileFilter}%`);
    }

    sql += ' ORDER BY created_at DESC LIMIT ?';
    params.push(limit);

    return db.prepare(sql).all(...params);
}

/**
 * Hybrid search combining FTS and keyword matching
 */
function hybridSearch(db, query, options = {}) {
    const limit = options.limit || 5;

    // Get FTS results (semantic-ish via BM25)
    const ftsResults = searchFTS(db, query, { ...options, limit: limit * 2 });

    // Get keyword results
    const keywordResults = searchLike(db, query, { ...options, limit: limit * 2 });

    // Merge and deduplicate
    const seen = new Set();
    const merged = [];

    // FTS results get priority (weight 0.7)
    for (const result of ftsResults) {
        if (!seen.has(result.id)) {
            seen.add(result.id);
            merged.push({
                ...result,
                combinedScore: result.score * 0.7,
                source: 'fts'
            });
        }
    }

    // Keyword results (weight 0.3)
    for (const result of keywordResults) {
        if (!seen.has(result.id)) {
            seen.add(result.id);
            merged.push({
                ...result,
                combinedScore: -0.3, // Negative because BM25 scores are negative (lower is better)
                source: 'keyword'
            });
        } else {
            // Boost score if found in both
            const existing = merged.find(r => r.id === result.id);
            if (existing) {
                existing.combinedScore *= 1.2; // 20% boost for appearing in both
            }
        }
    }

    // Sort by combined score (lower is better for BM25)
    merged.sort((a, b) => a.combinedScore - b.combinedScore);

    return merged.slice(0, limit);
}

/**
 * Session-level search - returns full sessions when matches found in daily logs
 * Falls back to chunk-level for MEMORY.md and patterns
 */
function sessionSearch(db, query, options = {}) {
    const limit = options.limit || 5;
    const summaryOnly = options.summaryOnly || false;

    // Get initial search results
    const rawResults = hybridSearch(db, query, { limit: limit * 2 });

    // Process results - expand daily log matches to full sessions
    const processedResults = [];
    const seenSessions = new Set();  // Dedupe sessions

    for (const result of rawResults) {
        if (isDailyLog(result.file)) {
            // Daily log - extract full session
            const session = extractSessionFromDailyLog(result.file, result.line_start);

            if (session) {
                const sessionKey = `${result.file}:${session.sessionName}`;

                // Skip if we've already seen this session
                if (seenSessions.has(sessionKey)) {
                    continue;
                }
                seenSessions.add(sessionKey);

                processedResults.push({
                    ...result,
                    type: 'session',
                    sessionName: session.sessionName,
                    content: summaryOnly
                        ? extractSessionSummary(session.content)
                        : session.content,
                    line_start: session.lineStart,
                    line_end: session.lineEnd,
                    matchContext: result.content.substring(0, 200) + '...'  // Original match for reference
                });
            }
        } else {
            // Not a daily log - use chunk-level (MEMORY.md, patterns, etc.)
            processedResults.push({
                ...result,
                type: 'chunk',
                sessionName: null
            });
        }
    }

    return processedResults.slice(0, limit);
}

/**
 * Format search results for display
 */
function formatResults(results, options = {}) {
    if (results.length === 0) {
        return 'No matches found.';
    }

    let output = '';
    const verbose = options.verbose || false;

    for (const result of results) {
        output += `\n${'═'.repeat(70)}\n`;

        if (result.type === 'session') {
            output += `📅 SESSION: ${result.sessionName}\n`;
            output += `   File: ${result.file}:${result.line_start}-${result.line_end}\n`;
            output += `   Score: ${result.combinedScore?.toFixed(3) || 'N/A'} (${result.source || 'unknown'})\n`;
            if (verbose && result.matchContext) {
                output += `   Match: "${result.matchContext.trim()}"\n`;
            }
        } else {
            output += `📄 CHUNK: ${result.file}:${result.line_start}-${result.line_end}\n`;
            output += `   Score: ${result.combinedScore?.toFixed(3) || 'N/A'} (${result.source || 'unknown'})\n`;
        }

        output += `${'─'.repeat(70)}\n`;
        output += result.content + '\n';
    }

    return output;
}

/**
 * Get context for a task (automatic retrieval)
 */
function getContextForTask(db, taskDescription, options = {}) {
    const limit = options.limit || 5;

    // Extract potential keywords from task
    const keywords = taskDescription
        .toLowerCase()
        .replace(/[^a-z0-9\s]/g, ' ')
        .split(/\s+/)
        .filter(w => w.length > 3)
        .filter(w => !['this', 'that', 'with', 'from', 'have', 'been', 'would', 'could', 'should'].includes(w));

    // Build FTS query from keywords
    const ftsQuery = keywords.slice(0, 5).join(' OR ');

    if (!ftsQuery) {
        return [];
    }

    // Use session search for better context
    return sessionSearch(db, ftsQuery, { limit, summaryOnly: true });
}

/**
 * List all sessions from daily logs (for browsing)
 */
function listSessions(options = {}) {
    const limit = options.limit || 20;
    const sessions = [];

    if (!fs.existsSync(MEMORY_DIR)) {
        return sessions;
    }

    // Get all daily log files
    const files = fs.readdirSync(MEMORY_DIR)
        .filter(f => f.endsWith('.md') && f !== 'template.md')
        .sort()
        .reverse();  // Most recent first

    for (const file of files) {
        const filePath = path.join(MEMORY_DIR, file);
        const content = fs.readFileSync(filePath, 'utf-8');
        const lines = content.split('\n');

        // Find all sessions in file
        for (let i = 0; i < lines.length; i++) {
            if (lines[i].startsWith('## Session:')) {
                const sessionName = lines[i].replace('## Session:', '').trim();

                // Get status if available
                let status = 'Unknown';
                for (let j = i + 1; j < Math.min(i + 10, lines.length); j++) {
                    if (lines[j].startsWith('**Status:**')) {
                        status = lines[j].replace('**Status:**', '').trim();
                        break;
                    }
                }

                sessions.push({
                    date: file.replace('.md', ''),
                    name: sessionName,
                    status,
                    file: `.nelson/memory/${file}`,
                    line: i + 1
                });

                if (sessions.length >= limit) {
                    return sessions;
                }
            }
        }
    }

    return sessions;
}

/**
 * Main CLI
 */
async function main() {
    const args = process.argv.slice(2);

    if (args.length === 0 || args.includes('--help')) {
        console.log('Nelson Memory Search v2.0');
        console.log('');
        console.log('Usage:');
        console.log('  node .nelson/search.cjs "query"             Hybrid search (chunk + session)');
        console.log('  node .nelson/search.cjs "query" --session   Force session-level retrieval');
        console.log('  node .nelson/search.cjs "query" --chunk     Force chunk-level retrieval');
        console.log('  node .nelson/search.cjs "query" --limit N   Limit results (default: 5)');
        console.log('  node .nelson/search.cjs "query" --file X    Filter by filename');
        console.log('  node .nelson/search.cjs --context "task"    Get context for a task');
        console.log('  node .nelson/search.cjs --list-sessions     List all sessions');
        console.log('  node .nelson/search.cjs --verbose           Show match context');
        console.log('');
        process.exit(0);
    }

    // Check for list-sessions command
    if (args.includes('--list-sessions')) {
        const sessions = listSessions();
        console.log('📚 Recent Sessions:\n');
        for (const session of sessions) {
            console.log(`  ${session.date} | ${session.name} | ${session.status}`);
            console.log(`    └─ ${session.file}:${session.line}`);
        }
        console.log(`\nTotal: ${sessions.length} sessions`);
        process.exit(0);
    }

    // Check database exists
    if (!fs.existsSync(DB_PATH)) {
        console.log('❌ Database not found. Run: node .nelson/init-db.cjs');
        process.exit(1);
    }

    // Load better-sqlite3
    let Database;
    try {
        Database = require('better-sqlite3');
    } catch (e) {
        console.log('❌ better-sqlite3 not installed. Run: npm install better-sqlite3');
        process.exit(1);
    }

    const db = new Database(DB_PATH, { readonly: true });

    // Parse arguments
    let query = '';
    let limit = 5;
    let fileFilter = null;
    let contextMode = false;
    let sessionMode = false;
    let chunkMode = false;
    let verbose = false;

    for (let i = 0; i < args.length; i++) {
        if (args[i] === '--limit' && args[i + 1]) {
            limit = parseInt(args[i + 1]);
            i++;
        } else if (args[i] === '--file' && args[i + 1]) {
            fileFilter = args[i + 1];
            i++;
        } else if (args[i] === '--context') {
            contextMode = true;
        } else if (args[i] === '--session') {
            sessionMode = true;
        } else if (args[i] === '--chunk') {
            chunkMode = true;
        } else if (args[i] === '--verbose') {
            verbose = true;
        } else if (!args[i].startsWith('--')) {
            query = args[i];
        }
    }

    if (!query) {
        console.log('❌ No query provided');
        process.exit(1);
    }

    console.log(`🔍 Searching for: "${query}"`);
    if (fileFilter) console.log(`   File filter: ${fileFilter}`);
    console.log(`   Limit: ${limit}`);
    console.log(`   Mode: ${contextMode ? 'context' : sessionMode ? 'session' : chunkMode ? 'chunk' : 'hybrid'}`);
    console.log('');

    // Perform search
    let results;
    if (contextMode) {
        results = getContextForTask(db, query, { limit, file: fileFilter });
    } else if (sessionMode) {
        results = sessionSearch(db, query, { limit, file: fileFilter });
    } else if (chunkMode) {
        results = hybridSearch(db, query, { limit, file: fileFilter });
    } else {
        // Default: session search (smarter)
        results = sessionSearch(db, query, { limit, file: fileFilter });
    }

    // Display results
    console.log(formatResults(results, { verbose }));
    console.log(`\nFound ${results.length} results.`);

    db.close();
}

// Export for use as module
module.exports = {
    searchFTS,
    searchLike,
    hybridSearch,
    sessionSearch,
    getContextForTask,
    formatResults,
    extractSessionFromDailyLog,
    extractSessionSummary,
    listSessions,
    isDailyLog
};

// Run if called directly
if (require.main === module) {
    main().catch(console.error);
}
