/**
 * Nelson Memory Search Module v3.0
 *
 * INTELLIGENT CONTEXT RETRIEVAL:
 * - Daily logs → Full session retrieval
 * - Documentation → Section-level retrieval (header to header)
 * - Any file → Context expansion (adjacent chunks)
 *
 * THE CHUNK PROBLEM SOLVED:
 * When a chunk matches but doesn't contain full context, we automatically:
 * 1. Expand to include the parent section (## Header → next ## Header)
 * 2. Include adjacent chunks for continuity
 * 3. Merge overlapping results to avoid duplicates
 *
 * Usage:
 *   node .nelson/search.cjs "your query"              # Smart retrieval (auto-expands)
 *   node .nelson/search.cjs "query" --expand          # Force context expansion
 *   node .nelson/search.cjs "query" --section         # Return full sections
 *   node .nelson/search.cjs "query" --chunk           # Raw chunks only (no expansion)
 *   node .nelson/search.cjs "query" --limit 10        # Limit results
 *   node .nelson/search.cjs "query" --file MEMORY.md  # Filter by file
 *   node .nelson/search.cjs --context "task"          # Auto-retrieve for task
 *   node .nelson/search.cjs --list-sessions           # List all sessions
 *   node .nelson/search.cjs --header "Webhook"        # Find section by header
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
 * Check if a file is structured documentation (CLAUDE.md, docs/, etc.)
 */
function isStructuredDoc(filePath) {
    return filePath.endsWith('CLAUDE.md') ||
           filePath.includes('docs/') ||
           filePath.endsWith('MEMORY.md') ||
           filePath.endsWith('NELSON_SOUL.md');
}

/**
 * Extract the full section containing a specific line from a markdown file
 * Sections are delimited by ## or ### headers
 */
function extractSectionFromFile(filePath, lineNumber) {
    const fullPath = path.join(process.cwd(), filePath);

    if (!fs.existsSync(fullPath)) {
        return null;
    }

    const content = fs.readFileSync(fullPath, 'utf-8');
    const lines = content.split('\n');

    // Find all section boundaries (## and ### headers)
    const sectionStarts = [];
    for (let i = 0; i < lines.length; i++) {
        if (lines[i].match(/^#{1,3}\s+/)) {  // Match #, ##, or ### headers
            sectionStarts.push({
                line: i,
                level: (lines[i].match(/^#+/) || [''])[0].length,
                header: lines[i]
            });
        }
    }

    // If no sections found, return context around the match
    if (sectionStarts.length === 0) {
        const contextStart = Math.max(0, lineNumber - 10);
        const contextEnd = Math.min(lines.length - 1, lineNumber + 20);
        return {
            sectionName: 'Context',
            header: null,
            content: lines.slice(contextStart, contextEnd + 1).join('\n'),
            lineStart: contextStart + 1,
            lineEnd: contextEnd + 1
        };
    }

    // Find which section contains the target line
    let sectionIndex = 0;
    for (let i = sectionStarts.length - 1; i >= 0; i--) {
        if (lineNumber >= sectionStarts[i].line) {
            sectionIndex = i;
            break;
        }
    }

    // Find section end (next header of same or higher level)
    const currentSection = sectionStarts[sectionIndex];
    let endLine = lines.length - 1;

    for (let i = sectionIndex + 1; i < sectionStarts.length; i++) {
        if (sectionStarts[i].level <= currentSection.level) {
            endLine = sectionStarts[i].line - 1;
            break;
        }
    }

    // Get section name from header
    const sectionName = currentSection.header.replace(/^#+\s*/, '').trim();

    const sectionContent = lines.slice(currentSection.line, endLine + 1).join('\n');

    return {
        sectionName,
        header: currentSection.header,
        content: sectionContent,
        lineStart: currentSection.line + 1,  // 1-indexed
        lineEnd: endLine + 1
    };
}

/**
 * Get adjacent chunks for context expansion
 */
function getAdjacentChunks(db, chunkId, file, lineStart, lineEnd, expandBy = 1) {
    // Get chunks from the same file that are adjacent
    const sql = `
        SELECT id, file, line_start, line_end, content
        FROM chunks
        WHERE file = ?
        AND (
            (line_end >= ? - 5 AND line_end < ?)  -- Chunk ends just before our chunk
            OR (line_start > ? AND line_start <= ? + 5)  -- Chunk starts just after our chunk
        )
        ORDER BY line_start
        LIMIT ?
    `;

    try {
        return db.prepare(sql).all(file, lineStart, lineStart, lineEnd, lineEnd, expandBy * 2);
    } catch (e) {
        return [];
    }
}

/**
 * Merge chunk content with adjacent chunks
 */
function mergeChunksContent(mainChunk, adjacentChunks, originalFile) {
    if (adjacentChunks.length === 0) {
        return mainChunk.content;
    }

    // Combine all chunks including main
    const allChunks = [...adjacentChunks, mainChunk].sort((a, b) => a.line_start - b.line_start);

    // Dedupe by line ranges (chunks might overlap)
    const merged = [];
    let currentEnd = -1;

    for (const chunk of allChunks) {
        if (chunk.line_start > currentEnd) {
            merged.push(chunk);
            currentEnd = chunk.line_end;
        } else if (chunk.line_end > currentEnd) {
            // Partial overlap - extend the last chunk
            const lastChunk = merged[merged.length - 1];
            // Read from file to get the extended content
            const fullPath = path.join(process.cwd(), originalFile);
            if (fs.existsSync(fullPath)) {
                const lines = fs.readFileSync(fullPath, 'utf-8').split('\n');
                lastChunk.content = lines.slice(lastChunk.line_start - 1, chunk.line_end).join('\n');
                lastChunk.line_end = chunk.line_end;
            }
            currentEnd = chunk.line_end;
        }
    }

    return merged.map(c => c.content).join('\n\n');
}

/**
 * Search for a section by header name
 */
function searchByHeader(db, headerQuery, options = {}) {
    const limit = options.limit || 5;

    // Search for chunks that contain headers matching the query
    const sql = `
        SELECT DISTINCT file, line_start, line_end, content
        FROM chunks
        WHERE content LIKE ?
        ORDER BY
            CASE
                WHEN file LIKE '%CLAUDE.md' THEN 1
                WHEN file LIKE '%.nelson/%' THEN 2
                WHEN file LIKE '%docs/%' THEN 3
                ELSE 4
            END,
            line_start
        LIMIT ?
    `;

    const results = db.prepare(sql).all(`%# %${headerQuery}%`, limit * 2);

    // Extract full sections for each match
    const sections = [];
    const seenSections = new Set();

    for (const result of results) {
        const section = extractSectionFromFile(result.file, result.line_start);
        if (section) {
            const sectionKey = `${result.file}:${section.sectionName}`;
            if (!seenSections.has(sectionKey)) {
                seenSections.add(sectionKey);
                sections.push({
                    file: result.file,
                    ...section,
                    type: 'section'
                });
            }
        }

        if (sections.length >= limit) break;
    }

    return sections;
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
 * Smart search - automatically expands context based on file type
 * - Daily logs → Full session
 * - Structured docs → Full section (header to header)
 * - Other files → Context expansion (adjacent chunks)
 */
function smartSearch(db, query, options = {}) {
    const limit = options.limit || 5;
    const summaryOnly = options.summaryOnly || false;
    const expandContext = options.expand !== false;  // Default: expand
    const sectionMode = options.section || false;

    // Get initial search results
    const rawResults = hybridSearch(db, query, { limit: limit * 2 });

    // Process results - expand based on file type
    const processedResults = [];
    const seenContexts = new Set();  // Dedupe expanded results

    for (const result of rawResults) {
        if (isDailyLog(result.file)) {
            // Daily log - extract full session
            const session = extractSessionFromDailyLog(result.file, result.line_start);

            if (session) {
                const contextKey = `${result.file}:session:${session.sessionName}`;

                if (seenContexts.has(contextKey)) continue;
                seenContexts.add(contextKey);

                processedResults.push({
                    ...result,
                    type: 'session',
                    sessionName: session.sessionName,
                    content: summaryOnly
                        ? extractSessionSummary(session.content)
                        : session.content,
                    line_start: session.lineStart,
                    line_end: session.lineEnd,
                    matchContext: result.content.substring(0, 200) + '...',
                    expansionType: 'session'
                });
            }
        } else if (isStructuredDoc(result.file) && (expandContext || sectionMode)) {
            // Structured doc - extract full section
            const section = extractSectionFromFile(result.file, result.line_start);

            if (section) {
                const contextKey = `${result.file}:section:${section.sectionName}`;

                if (seenContexts.has(contextKey)) continue;
                seenContexts.add(contextKey);

                processedResults.push({
                    ...result,
                    type: 'section',
                    sectionName: section.sectionName,
                    sectionHeader: section.header,
                    content: section.content,
                    line_start: section.lineStart,
                    line_end: section.lineEnd,
                    matchContext: result.content.substring(0, 200) + '...',
                    expansionType: 'section'
                });
            }
        } else if (expandContext && !sectionMode) {
            // Other files - expand with adjacent chunks
            const contextKey = `${result.file}:chunk:${result.line_start}-${result.line_end}`;

            if (seenContexts.has(contextKey)) continue;
            seenContexts.add(contextKey);

            const adjacentChunks = getAdjacentChunks(
                db, result.id, result.file, result.line_start, result.line_end, 1
            );

            const expandedContent = adjacentChunks.length > 0
                ? mergeChunksContent(result, adjacentChunks, result.file)
                : result.content;

            processedResults.push({
                ...result,
                type: 'expanded_chunk',
                content: expandedContent,
                matchContext: result.content.substring(0, 200) + '...',
                expansionType: 'adjacent',
                adjacentCount: adjacentChunks.length
            });
        } else {
            // Raw chunk mode - no expansion
            processedResults.push({
                ...result,
                type: 'chunk',
                expansionType: 'none'
            });
        }
    }

    return processedResults.slice(0, limit);
}

/**
 * Session-level search (legacy alias for smartSearch)
 */
function sessionSearch(db, query, options = {}) {
    return smartSearch(db, query, options);
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

        // Type-specific headers
        if (result.type === 'session') {
            output += `📅 SESSION: ${result.sessionName}\n`;
            output += `   File: ${result.file}:${result.line_start}-${result.line_end}\n`;
            output += `   Expansion: Full session retrieval\n`;
        } else if (result.type === 'section') {
            output += `📑 SECTION: ${result.sectionName}\n`;
            output += `   File: ${result.file}:${result.line_start}-${result.line_end}\n`;
            output += `   Header: ${result.sectionHeader || 'N/A'}\n`;
            output += `   Expansion: Full section (header→header)\n`;
        } else if (result.type === 'expanded_chunk') {
            output += `📄 CHUNK (expanded): ${result.file}:${result.line_start}-${result.line_end}\n`;
            output += `   Expansion: +${result.adjacentCount || 0} adjacent chunks\n`;
        } else {
            output += `📄 CHUNK: ${result.file}:${result.line_start}-${result.line_end}\n`;
            output += `   Expansion: None (raw chunk)\n`;
        }

        // Common fields
        if (result.combinedScore !== undefined) {
            output += `   Score: ${result.combinedScore.toFixed(3)} (${result.source || 'unknown'})\n`;
        }

        if (verbose && result.matchContext) {
            output += `   Match: "${result.matchContext.trim()}"\n`;
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
        console.log('Nelson Memory Search v3.0 - Intelligent Context Retrieval');
        console.log('');
        console.log('Usage:');
        console.log('  node .nelson/search.cjs "query"             Smart search (auto-expands context)');
        console.log('  node .nelson/search.cjs "query" --section   Return full sections (header→header)');
        console.log('  node .nelson/search.cjs "query" --expand    Force context expansion');
        console.log('  node .nelson/search.cjs "query" --chunk     Raw chunks only (no expansion)');
        console.log('  node .nelson/search.cjs "query" --limit N   Limit results (default: 5)');
        console.log('  node .nelson/search.cjs "query" --file X    Filter by filename');
        console.log('  node .nelson/search.cjs --header "Name"     Find section by header name');
        console.log('  node .nelson/search.cjs --context "task"    Auto-retrieve context for task');
        console.log('  node .nelson/search.cjs --list-sessions     List all sessions');
        console.log('  node .nelson/search.cjs --verbose           Show match snippets');
        console.log('');
        console.log('Context Expansion:');
        console.log('  • Daily logs → Returns full session (## Session: boundary)');
        console.log('  • CLAUDE.md, docs/ → Returns full section (## Header boundary)');
        console.log('  • Other files → Returns chunk + adjacent chunks');
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
    let sectionMode = false;
    let expandMode = false;
    let chunkMode = false;
    let headerMode = false;
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
        } else if (args[i] === '--section') {
            sectionMode = true;
        } else if (args[i] === '--expand') {
            expandMode = true;
        } else if (args[i] === '--chunk') {
            chunkMode = true;
        } else if (args[i] === '--header') {
            headerMode = true;
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

    // Determine mode for display
    let mode = 'smart';
    if (contextMode) mode = 'context';
    else if (headerMode) mode = 'header';
    else if (sectionMode) mode = 'section';
    else if (expandMode) mode = 'expand';
    else if (chunkMode) mode = 'chunk';

    console.log(`🔍 Searching for: "${query}"`);
    if (fileFilter) console.log(`   File filter: ${fileFilter}`);
    console.log(`   Limit: ${limit}`);
    console.log(`   Mode: ${mode}`);
    console.log('');

    // Perform search
    let results;
    if (contextMode) {
        results = getContextForTask(db, query, { limit, file: fileFilter });
    } else if (headerMode) {
        results = searchByHeader(db, query, { limit, file: fileFilter });
    } else if (chunkMode) {
        results = hybridSearch(db, query, { limit, file: fileFilter });
    } else {
        // Smart search - auto-expands based on file type
        results = smartSearch(db, query, {
            limit,
            file: fileFilter,
            section: sectionMode,
            expand: !chunkMode
        });
    }

    // Display results
    console.log(formatResults(results, { verbose }));
    console.log(`\nFound ${results.length} results.`);

    db.close();
}

// Export for use as module
module.exports = {
    // Core search functions
    searchFTS,
    searchLike,
    hybridSearch,
    smartSearch,
    sessionSearch,  // Legacy alias for smartSearch
    searchByHeader,

    // Context retrieval
    getContextForTask,
    extractSessionFromDailyLog,
    extractSessionSummary,
    extractSectionFromFile,
    getAdjacentChunks,
    mergeChunksContent,

    // Utilities
    formatResults,
    listSessions,
    isDailyLog,
    isStructuredDoc
};

// Run if called directly
if (require.main === module) {
    main().catch(console.error);
}
