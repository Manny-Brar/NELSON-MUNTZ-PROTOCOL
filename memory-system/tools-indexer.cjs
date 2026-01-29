/**
 * Nelson Tool Indexer v1.0
 *
 * STRATEGIC MCP & SKILL INDEXING:
 * - Auto-detects MCPs from ~/.claude.json
 * - Auto-detects skills from .claude/skills/ and custom skill registries
 * - Extracts keywords from tool definitions, descriptions, parameters
 * - Syncs automatically when new MCPs/skills are added
 * - Recommends tools based on task description
 *
 * KEY DESIGN DECISIONS:
 * 1. Thoughtful keyword extraction (not just splitting names)
 * 2. Domain categorization (payment, voice, deployment, etc.)
 * 3. Task-to-tool matching via semantic keywords
 * 4. Incremental updates (only re-index changed tools)
 *
 * Usage:
 *   node .nelson/tools-indexer.cjs sync          # Full sync of all MCPs/skills
 *   node .nelson/tools-indexer.cjs recommend "task description"  # Get tool recommendations
 *   node .nelson/tools-indexer.cjs list          # List all indexed tools
 *   node .nelson/tools-indexer.cjs watch         # Watch for changes (runs once)
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

const NELSON_DIR = path.join(process.cwd(), '.nelson');
const DB_PATH = path.join(NELSON_DIR, 'memory.db');

// Paths to check for MCPs and skills
const CLAUDE_CONFIG_PATHS = [
    path.join(os.homedir(), '.claude.json'),                    // Global config
    path.join(process.cwd(), '.mcp.json'),                       // Project-level MCP config
    path.join(process.cwd(), '.claude', 'mcp.json'),             // Alternative project config
];

const SKILL_PATHS = [
    path.join(process.cwd(), '.claude', 'skills'),               // Project skills
    path.join(os.homedir(), '.claude', 'skills'),                // Global skills
];

// Domain categories for tool classification
const TOOL_DOMAINS = {
    payment: ['stripe', 'payment', 'checkout', 'invoice', 'subscription', 'refund', 'charge', 'price', 'coupon', 'billing'],
    voice: ['vapi', 'call', 'phone', 'assistant', 'voice', 'transcribe', 'speech', 'audio', 'twilio'],
    deployment: ['vercel', 'deploy', 'build', 'preview', 'domain', 'hosting', 'production', 'staging'],
    database: ['supabase', 'postgres', 'sql', 'query', 'table', 'schema', 'migration', 'rls'],
    automation: ['n8n', 'workflow', 'automation', 'trigger', 'webhook', 'integration'],
    testing: ['playwright', 'test', 'browser', 'screenshot', 'e2e', 'automation', 'selenium'],
    email: ['email', 'smtp', 'sendgrid', 'resend', 'notification', 'template'],
    ai: ['openai', 'anthropic', 'claude', 'gpt', 'llm', 'embedding', 'vector', 'rag'],
    git: ['git', 'commit', 'branch', 'merge', 'pr', 'pull', 'push', 'worktree'],
    file: ['file', 'read', 'write', 'edit', 'directory', 'path', 'glob', 'grep'],
    session: ['session', 'startup', 'completion', 'handoff', 'progress', 'memory'],
    quality: ['review', 'audit', 'test', 'verify', 'validate', 'lint', 'security'],
    design: ['frontend', 'ui', 'ux', 'component', 'design', 'style', 'layout', 'css'],
    planning: ['plan', 'brainstorm', 'spec', 'requirement', 'architecture', 'strategy'],
};

// Keyword extraction patterns
const KEYWORD_PATTERNS = {
    // Split camelCase: createCustomer -> create, customer
    camelCase: /([a-z])([A-Z])/g,
    // Split snake_case: create_customer -> create, customer
    snakeCase: /_/g,
    // Split kebab-case: create-customer -> create, customer
    kebabCase: /-/g,
    // Remove common prefixes
    prefixes: /^(mcp__|get_|set_|list_|create_|delete_|update_)/,
};

// Stop words to filter from keywords
const STOP_WORDS = new Set([
    'the', 'a', 'an', 'is', 'are', 'was', 'were', 'be', 'been', 'being',
    'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could',
    'should', 'may', 'might', 'must', 'shall', 'can', 'need', 'dare',
    'ought', 'used', 'to', 'of', 'in', 'for', 'on', 'with', 'at', 'by',
    'from', 'as', 'into', 'through', 'during', 'before', 'after', 'above',
    'below', 'between', 'under', 'again', 'further', 'then', 'once',
    'and', 'but', 'or', 'nor', 'so', 'yet', 'both', 'either', 'neither',
    'not', 'only', 'own', 'same', 'than', 'too', 'very', 'just',
    'this', 'that', 'these', 'those', 'such', 'when', 'where', 'why', 'how',
]);

/**
 * Initialize the tools table in the database
 */
function initializeToolsSchema(db) {
    console.log('📊 Creating tools schema...');

    db.exec(`
        -- Tools/MCPs/Skills table
        CREATE TABLE IF NOT EXISTS tools (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            type TEXT NOT NULL,              -- 'mcp' | 'skill' | 'builtin'
            source TEXT NOT NULL,            -- File path or 'builtin'
            domain TEXT,                     -- 'payment', 'voice', 'deployment', etc.
            description TEXT,
            keywords TEXT,                   -- JSON array of keywords
            parameters TEXT,                 -- JSON schema of parameters
            examples TEXT,                   -- Usage examples
            priority REAL DEFAULT 0.5,       -- Tool importance (0-1)
            last_used TEXT,                  -- Last time tool was recommended
            use_count INTEGER DEFAULT 0,     -- How many times recommended
            content_hash TEXT,               -- For change detection
            indexed_at TEXT DEFAULT (datetime('now')),
            updated_at TEXT DEFAULT (datetime('now'))
        );

        -- FTS for tool search
        CREATE VIRTUAL TABLE IF NOT EXISTS tools_fts USING fts5(
            name,
            description,
            keywords,
            domain,
            content='tools',
            content_rowid='rowid'
        );

        -- Triggers to keep FTS in sync
        CREATE TRIGGER IF NOT EXISTS tools_ai AFTER INSERT ON tools BEGIN
            INSERT INTO tools_fts(rowid, name, description, keywords, domain)
            VALUES (new.rowid, new.name, new.description, new.keywords, new.domain);
        END;

        CREATE TRIGGER IF NOT EXISTS tools_ad AFTER DELETE ON tools BEGIN
            INSERT INTO tools_fts(tools_fts, rowid, name, description, keywords, domain)
            VALUES('delete', old.rowid, old.name, old.description, old.keywords, old.domain);
        END;

        CREATE TRIGGER IF NOT EXISTS tools_au AFTER UPDATE ON tools BEGIN
            INSERT INTO tools_fts(tools_fts, rowid, name, description, keywords, domain)
            VALUES('delete', old.rowid, old.name, old.description, old.keywords, old.domain);
            INSERT INTO tools_fts(rowid, name, description, keywords, domain)
            VALUES (new.rowid, new.name, new.description, new.keywords, new.domain);
        END;

        -- Index for efficient querying
        CREATE INDEX IF NOT EXISTS idx_tools_type ON tools(type);
        CREATE INDEX IF NOT EXISTS idx_tools_domain ON tools(domain);
        CREATE INDEX IF NOT EXISTS idx_tools_priority ON tools(priority DESC);
    `);

    console.log('   ✓ Tools schema created');
}

/**
 * Extract thoughtful keywords from a tool name and description
 */
function extractKeywords(name, description = '', parameters = {}) {
    const keywords = new Set();

    // 1. Process tool name
    let processedName = name
        .replace(KEYWORD_PATTERNS.prefixes, '')  // Remove prefixes
        .replace(KEYWORD_PATTERNS.camelCase, '$1 $2')  // Split camelCase
        .replace(KEYWORD_PATTERNS.snakeCase, ' ')  // Split snake_case
        .replace(KEYWORD_PATTERNS.kebabCase, ' ')  // Split kebab-case
        .toLowerCase();

    processedName.split(/\s+/).forEach(word => {
        if (word.length > 2 && !STOP_WORDS.has(word)) {
            keywords.add(word);
        }
    });

    // 2. Process description
    if (description) {
        const descWords = description
            .toLowerCase()
            .replace(/[^a-z0-9\s]/g, ' ')
            .split(/\s+/);

        descWords.forEach(word => {
            if (word.length > 3 && !STOP_WORDS.has(word)) {
                keywords.add(word);
            }
        });

        // Extract noun phrases (2-word combinations that appear together)
        for (let i = 0; i < descWords.length - 1; i++) {
            const phrase = `${descWords[i]} ${descWords[i+1]}`;
            if (!STOP_WORDS.has(descWords[i]) && !STOP_WORDS.has(descWords[i+1])) {
                // Only add meaningful phrases
                const meaningfulPhrases = ['phone number', 'api key', 'webhook url', 'access token'];
                if (meaningfulPhrases.includes(phrase)) {
                    keywords.add(phrase.replace(' ', '_'));
                }
            }
        }
    }

    // 3. Process parameter names
    if (parameters && typeof parameters === 'object') {
        const props = parameters.properties || parameters;
        Object.keys(props).forEach(param => {
            const cleanParam = param
                .replace(KEYWORD_PATTERNS.camelCase, '$1 $2')
                .replace(KEYWORD_PATTERNS.snakeCase, ' ')
                .toLowerCase();

            cleanParam.split(/\s+/).forEach(word => {
                if (word.length > 2 && !STOP_WORDS.has(word)) {
                    keywords.add(word);
                }
            });
        });
    }

    return Array.from(keywords);
}

/**
 * Determine the domain category for a tool
 */
function determineDomain(name, description = '', keywords = []) {
    const text = `${name} ${description} ${keywords.join(' ')}`.toLowerCase();

    let bestMatch = { domain: 'general', score: 0 };

    for (const [domain, domainKeywords] of Object.entries(TOOL_DOMAINS)) {
        let score = 0;
        for (const keyword of domainKeywords) {
            if (text.includes(keyword)) {
                score++;
            }
        }

        if (score > bestMatch.score) {
            bestMatch = { domain, score };
        }
    }

    return bestMatch.domain;
}

/**
 * Calculate content hash for change detection
 */
function hashContent(content) {
    const crypto = require('crypto');
    return crypto.createHash('sha256').update(JSON.stringify(content)).digest('hex').substring(0, 16);
}

/**
 * Parse MCP configuration from ~/.claude.json
 */
function parseMCPConfig() {
    const mcps = [];

    for (const configPath of CLAUDE_CONFIG_PATHS) {
        if (!fs.existsSync(configPath)) continue;

        try {
            const config = JSON.parse(fs.readFileSync(configPath, 'utf-8'));

            // MCPs can be in different locations depending on config version
            const mcpConfig = config.mcpServers || config.mcp || {};

            for (const [name, serverConfig] of Object.entries(mcpConfig)) {
                // Extract tools from server config if available
                const tools = serverConfig.tools || [];

                // If no explicit tools, create a generic entry for the MCP server
                if (tools.length === 0) {
                    mcps.push({
                        id: `mcp:${name}`,
                        name: name,
                        type: 'mcp',
                        source: configPath,
                        description: serverConfig.description || `${name} MCP server`,
                        parameters: {},
                        rawConfig: serverConfig
                    });
                } else {
                    // Index each tool from the MCP
                    for (const tool of tools) {
                        mcps.push({
                            id: `mcp:${name}:${tool.name}`,
                            name: `${name}__${tool.name}`,
                            type: 'mcp',
                            source: configPath,
                            description: tool.description || '',
                            parameters: tool.inputSchema || tool.parameters || {},
                            rawConfig: tool
                        });
                    }
                }
            }
        } catch (e) {
            console.log(`   ⚠️  Failed to parse ${configPath}: ${e.message}`);
        }
    }

    return mcps;
}

/**
 * Parse skills from .claude/skills directories
 */
function parseSkills() {
    const skills = [];

    for (const skillPath of SKILL_PATHS) {
        if (!fs.existsSync(skillPath)) continue;

        const files = fs.readdirSync(skillPath);

        for (const file of files) {
            if (!file.endsWith('.md')) continue;

            const fullPath = path.join(skillPath, file);
            const content = fs.readFileSync(fullPath, 'utf-8');

            // Extract skill metadata from content
            const skillName = file.replace('.md', '');
            let description = '';
            let examples = [];

            // Look for description in first paragraph or YAML frontmatter
            const lines = content.split('\n');
            let inFrontmatter = false;
            let descriptionLines = [];

            for (const line of lines) {
                if (line === '---') {
                    inFrontmatter = !inFrontmatter;
                    continue;
                }

                if (inFrontmatter) {
                    // Parse YAML frontmatter
                    const match = line.match(/^description:\s*(.+)$/);
                    if (match) {
                        description = match[1];
                    }
                } else if (line.startsWith('# ')) {
                    // Skip title
                    continue;
                } else if (line.startsWith('## ')) {
                    // Stop at first section
                    break;
                } else if (line.trim() && !description) {
                    descriptionLines.push(line);
                    if (descriptionLines.length >= 3) {
                        description = descriptionLines.join(' ').substring(0, 500);
                        break;
                    }
                }
            }

            if (!description && descriptionLines.length > 0) {
                description = descriptionLines.join(' ').substring(0, 500);
            }

            // Look for examples section
            const exampleMatch = content.match(/## Examples?\n([\s\S]*?)(?=\n## |\n---|\Z)/i);
            if (exampleMatch) {
                examples = exampleMatch[1].trim().split('\n').filter(l => l.trim());
            }

            skills.push({
                id: `skill:${skillName}`,
                name: skillName,
                type: 'skill',
                source: fullPath,
                description,
                parameters: {},
                examples: examples.slice(0, 5),
                rawContent: content
            });
        }
    }

    return skills;
}

/**
 * Index a single tool into the database
 */
function indexTool(db, tool) {
    const keywords = extractKeywords(tool.name, tool.description, tool.parameters);
    const domain = determineDomain(tool.name, tool.description, keywords);
    const contentHash = hashContent(tool);

    // Check if tool exists and is unchanged
    const existing = db.prepare('SELECT content_hash FROM tools WHERE id = ?').get(tool.id);
    if (existing && existing.content_hash === contentHash) {
        return { indexed: false, reason: 'unchanged' };
    }

    // Calculate priority based on type and usage
    let priority = 0.5;
    if (tool.type === 'mcp') priority = 0.7;  // MCPs are direct API access
    if (domain !== 'general') priority += 0.1;  // Domain-specific tools are more useful

    // Upsert tool
    db.prepare(`
        INSERT OR REPLACE INTO tools
        (id, name, type, source, domain, description, keywords, parameters, examples, priority, content_hash, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now'))
    `).run(
        tool.id,
        tool.name,
        tool.type,
        tool.source,
        domain,
        tool.description || '',
        JSON.stringify(keywords),
        JSON.stringify(tool.parameters || {}),
        JSON.stringify(tool.examples || []),
        priority,
        contentHash
    );

    return { indexed: true, keywords, domain };
}

/**
 * Full sync - scan all MCP and skill sources, index everything
 */
function syncAll(db) {
    console.log('');
    console.log('🔄 Syncing all tools...');

    const stats = {
        mcps: 0,
        skills: 0,
        indexed: 0,
        unchanged: 0,
        domains: {}
    };

    // Parse MCPs
    console.log('');
    console.log('📡 Scanning MCP configurations...');
    const mcps = parseMCPConfig();
    stats.mcps = mcps.length;
    console.log(`   Found ${mcps.length} MCP tools`);

    for (const mcp of mcps) {
        const result = indexTool(db, mcp);
        if (result.indexed) {
            stats.indexed++;
            stats.domains[result.domain] = (stats.domains[result.domain] || 0) + 1;
            console.log(`   ✓ ${mcp.name} [${result.domain}] (${result.keywords.slice(0, 5).join(', ')})`);
        } else {
            stats.unchanged++;
        }
    }

    // Parse Skills
    console.log('');
    console.log('🎯 Scanning skill directories...');
    const skills = parseSkills();
    stats.skills = skills.length;
    console.log(`   Found ${skills.length} skills`);

    for (const skill of skills) {
        const result = indexTool(db, skill);
        if (result.indexed) {
            stats.indexed++;
            stats.domains[result.domain] = (stats.domains[result.domain] || 0) + 1;
            console.log(`   ✓ ${skill.name} [${result.domain}] (${result.keywords.slice(0, 5).join(', ')})`);
        } else {
            stats.unchanged++;
        }
    }

    return stats;
}

/**
 * Search for tools matching a task description
 */
function recommendTools(db, taskDescription, options = {}) {
    const limit = options.limit || 5;

    // Extract keywords from task
    const taskKeywords = taskDescription
        .toLowerCase()
        .replace(/[^a-z0-9\s]/g, ' ')
        .split(/\s+/)
        .filter(w => w.length > 2 && !STOP_WORDS.has(w));

    // Build FTS query
    const ftsQuery = taskKeywords.slice(0, 8).join(' OR ');

    if (!ftsQuery) {
        return [];
    }

    // Search using FTS
    let results = [];
    try {
        results = db.prepare(`
            SELECT
                t.id,
                t.name,
                t.type,
                t.domain,
                t.description,
                t.keywords,
                t.priority,
                t.use_count,
                bm25(tools_fts) as score
            FROM tools_fts
            JOIN tools t ON tools_fts.rowid = t.rowid
            WHERE tools_fts MATCH ?
            ORDER BY
                t.priority DESC,
                score,
                t.use_count DESC
            LIMIT ?
        `).all(ftsQuery, limit * 2);
    } catch (e) {
        // Fallback to LIKE search
        const likePattern = `%${taskKeywords[0]}%`;
        results = db.prepare(`
            SELECT
                id, name, type, domain, description, keywords, priority, use_count, 0 as score
            FROM tools
            WHERE keywords LIKE ? OR description LIKE ? OR name LIKE ?
            ORDER BY priority DESC
            LIMIT ?
        `).all(likePattern, likePattern, likePattern, limit * 2);
    }

    // Score results based on keyword overlap
    const scoredResults = results.map(r => {
        const toolKeywords = JSON.parse(r.keywords || '[]');
        let keywordOverlap = 0;

        for (const taskKw of taskKeywords) {
            for (const toolKw of toolKeywords) {
                if (toolKw.includes(taskKw) || taskKw.includes(toolKw)) {
                    keywordOverlap++;
                }
            }
        }

        return {
            ...r,
            keywordOverlap,
            finalScore: keywordOverlap * 0.3 + r.priority * 0.4 + (r.use_count || 0) * 0.1
        };
    });

    // Sort by final score and return
    scoredResults.sort((a, b) => b.finalScore - a.finalScore);

    return scoredResults.slice(0, limit).map(r => ({
        id: r.id,
        name: r.name,
        type: r.type,
        domain: r.domain,
        description: r.description,
        keywords: JSON.parse(r.keywords || '[]'),
        confidence: Math.min(1, r.finalScore / 3)  // Normalize to 0-1
    }));
}

/**
 * Record that a tool was used/recommended
 */
function recordToolUse(db, toolId) {
    db.prepare(`
        UPDATE tools
        SET use_count = use_count + 1, last_used = datetime('now')
        WHERE id = ?
    `).run(toolId);
}

/**
 * List all indexed tools
 */
function listTools(db, options = {}) {
    const type = options.type || null;
    const domain = options.domain || null;

    let sql = 'SELECT id, name, type, domain, description, keywords, priority FROM tools WHERE 1=1';
    const params = [];

    if (type) {
        sql += ' AND type = ?';
        params.push(type);
    }

    if (domain) {
        sql += ' AND domain = ?';
        params.push(domain);
    }

    sql += ' ORDER BY type, domain, name';

    return db.prepare(sql).all(...params);
}

/**
 * Format tool recommendations for display
 */
function formatRecommendations(recommendations) {
    if (recommendations.length === 0) {
        return 'No tool recommendations found for this task.';
    }

    let output = '\n🔧 RECOMMENDED TOOLS:\n';
    output += '═'.repeat(60) + '\n';

    for (const tool of recommendations) {
        const confidence = Math.round(tool.confidence * 100);
        const typeIcon = tool.type === 'mcp' ? '📡' : '🎯';

        output += `\n${typeIcon} ${tool.name}\n`;
        output += `   Type: ${tool.type.toUpperCase()} | Domain: ${tool.domain} | Confidence: ${confidence}%\n`;
        output += `   ${tool.description.substring(0, 100)}${tool.description.length > 100 ? '...' : ''}\n`;
        output += `   Keywords: ${tool.keywords.slice(0, 6).join(', ')}\n`;
    }

    return output;
}

/**
 * Main CLI
 */
async function main() {
    const args = process.argv.slice(2);
    const command = args[0] || 'help';

    if (command === 'help' || command === '--help') {
        console.log('Nelson Tool Indexer v1.0');
        console.log('');
        console.log('Commands:');
        console.log('  sync                     Full sync of all MCPs and skills');
        console.log('  recommend "task"         Get tool recommendations for a task');
        console.log('  list [--type X]          List all indexed tools');
        console.log('  watch                    Check for new tools (run once)');
        console.log('  help                     Show this help');
        console.log('');
        console.log('Examples:');
        console.log('  node .nelson/tools-indexer.cjs sync');
        console.log('  node .nelson/tools-indexer.cjs recommend "create a stripe checkout"');
        console.log('  node .nelson/tools-indexer.cjs list --type mcp');
        console.log('');
        process.exit(0);
    }

    // Check database exists
    if (!fs.existsSync(DB_PATH) && command !== 'sync') {
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

    const db = new Database(DB_PATH);

    // Ensure tools schema exists
    initializeToolsSchema(db);

    switch (command) {
        case 'sync': {
            console.log('╔══════════════════════════════════════════════════════════════════╗');
            console.log('║           NELSON TOOL INDEXER v1.0 - FULL SYNC                   ║');
            console.log('╚══════════════════════════════════════════════════════════════════╝');

            const stats = syncAll(db);

            console.log('');
            console.log('╔══════════════════════════════════════════════════════════════════╗');
            console.log('║                       SYNC COMPLETE                              ║');
            console.log('╚══════════════════════════════════════════════════════════════════╝');
            console.log('');
            console.log('📊 Statistics:');
            console.log(`   • MCP tools found: ${stats.mcps}`);
            console.log(`   • Skills found: ${stats.skills}`);
            console.log(`   • Newly indexed: ${stats.indexed}`);
            console.log(`   • Unchanged: ${stats.unchanged}`);

            if (Object.keys(stats.domains).length > 0) {
                console.log('');
                console.log('📂 By Domain:');
                for (const [domain, count] of Object.entries(stats.domains)) {
                    console.log(`   • ${domain}: ${count}`);
                }
            }

            console.log('');
            console.log('🔍 Get recommendations with:');
            console.log('   node .nelson/tools-indexer.cjs recommend "your task"');
            break;
        }

        case 'recommend': {
            const task = args.slice(1).join(' ');
            if (!task) {
                console.log('❌ No task provided');
                console.log('Usage: node .nelson/tools-indexer.cjs recommend "create a payment link"');
                process.exit(1);
            }

            console.log(`🔍 Finding tools for: "${task}"`);

            const recommendations = recommendTools(db, task, { limit: 5 });
            console.log(formatRecommendations(recommendations));

            // Record usage for learning
            for (const rec of recommendations) {
                recordToolUse(db, rec.id);
            }
            break;
        }

        case 'list': {
            const type = args.includes('--type') ? args[args.indexOf('--type') + 1] : null;
            const domain = args.includes('--domain') ? args[args.indexOf('--domain') + 1] : null;

            const tools = listTools(db, { type, domain });

            console.log(`📋 Indexed Tools (${tools.length} total):`);
            console.log('');

            let currentType = '';
            let currentDomain = '';

            for (const tool of tools) {
                if (tool.type !== currentType) {
                    currentType = tool.type;
                    console.log(`\n${currentType.toUpperCase()}:`);
                }

                if (tool.domain !== currentDomain) {
                    currentDomain = tool.domain;
                    console.log(`  [${currentDomain}]`);
                }

                const keywords = JSON.parse(tool.keywords || '[]').slice(0, 4).join(', ');
                console.log(`    • ${tool.name}`);
                console.log(`      ${tool.description.substring(0, 60)}...`);
                console.log(`      Keywords: ${keywords}`);
            }
            break;
        }

        case 'watch': {
            // One-time check for new tools (can be called from git hooks)
            console.log('👀 Checking for new MCPs and skills...');

            const existingCount = db.prepare('SELECT COUNT(*) as count FROM tools').get().count;
            const stats = syncAll(db);
            const newCount = db.prepare('SELECT COUNT(*) as count FROM tools').get().count;

            if (newCount > existingCount) {
                console.log(`\n✅ Added ${newCount - existingCount} new tools!`);
            } else {
                console.log('\n✓ All tools up to date');
            }
            break;
        }

        default:
            console.log(`❌ Unknown command: ${command}`);
            console.log('Run with --help for usage');
            process.exit(1);
    }

    db.close();
}

// Export for use as module
module.exports = {
    initializeToolsSchema,
    extractKeywords,
    determineDomain,
    parseMCPConfig,
    parseSkills,
    indexTool,
    syncAll,
    recommendTools,
    recordToolUse,
    listTools,
    formatRecommendations,
    TOOL_DOMAINS,
    STOP_WORDS
};

// Run if called directly
if (require.main === module) {
    main().catch(console.error);
}
