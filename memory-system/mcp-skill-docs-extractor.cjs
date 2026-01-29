/**
 * MCP & Skill Documentation Extractor v1.0
 *
 * PURPOSE: Extract detailed MCP/skill documentation from CLAUDE.md
 * and store in the database for on-demand retrieval.
 *
 * This enables MASSIVE token savings by:
 * 1. Storing detailed docs in DB (~5000+ tokens)
 * 2. Keeping only minimal instruction in CLAUDE.md (~300 tokens)
 * 3. Retrieving relevant tool docs based on task keywords
 *
 * Run: node .nelson/mcp-skill-docs-extractor.cjs extract
 * Run: node .nelson/mcp-skill-docs-extractor.cjs retrieve "stripe payment"
 */

const fs = require('fs');
const path = require('path');

const NELSON_DIR = path.join(process.cwd(), '.nelson');
const DB_PATH = path.join(NELSON_DIR, 'memory.db');

/**
 * Initialize enhanced tools schema with documentation storage
 */
function initializeDocsSchema(db) {
    db.exec(`
        -- Tool documentation table (stores full docs, examples, usage patterns)
        CREATE TABLE IF NOT EXISTS tool_docs (
            id TEXT PRIMARY KEY,
            tool_name TEXT NOT NULL,
            tool_type TEXT NOT NULL,           -- 'mcp' | 'skill' | 'mcp_operation'
            service TEXT,                       -- 'stripe', 'vapi', 'vercel', etc.
            category TEXT,                      -- 'payment', 'session', 'audit', etc.
            short_description TEXT,             -- 1-line description
            full_documentation TEXT,            -- Complete usage docs
            operations TEXT,                    -- JSON array of operations (for MCPs)
            examples TEXT,                      -- JSON array of code examples
            parameters TEXT,                    -- JSON schema of parameters
            keywords TEXT,                      -- JSON array of keywords
            priority REAL DEFAULT 0.5,
            token_count INTEGER,                -- Approx tokens in full_documentation
            indexed_at TEXT DEFAULT (datetime('now'))
        );

        -- FTS for fast documentation search
        CREATE VIRTUAL TABLE IF NOT EXISTS tool_docs_fts USING fts5(
            tool_name,
            short_description,
            full_documentation,
            keywords,
            category,
            content='tool_docs',
            content_rowid='rowid'
        );

        -- Triggers for FTS sync
        CREATE TRIGGER IF NOT EXISTS tool_docs_ai AFTER INSERT ON tool_docs BEGIN
            INSERT INTO tool_docs_fts(rowid, tool_name, short_description, full_documentation, keywords, category)
            VALUES (new.rowid, new.tool_name, new.short_description, new.full_documentation, new.keywords, new.category);
        END;

        CREATE TRIGGER IF NOT EXISTS tool_docs_ad AFTER DELETE ON tool_docs BEGIN
            INSERT INTO tool_docs_fts(tool_docs_fts, rowid, tool_name, short_description, full_documentation, keywords, category)
            VALUES('delete', old.rowid, old.tool_name, old.short_description, old.full_documentation, old.keywords, old.category);
        END;

        -- Index for efficient lookups
        CREATE INDEX IF NOT EXISTS idx_tool_docs_service ON tool_docs(service);
        CREATE INDEX IF NOT EXISTS idx_tool_docs_category ON tool_docs(category);
        CREATE INDEX IF NOT EXISTS idx_tool_docs_type ON tool_docs(tool_type);
    `);
}

/**
 * Pre-defined tool documentation (extracted from CLAUDE.md)
 * This is the source of truth for tool docs
 */
const TOOL_DOCUMENTATION = {
    // MCP Servers
    mcps: [
        {
            id: 'mcp:stripe',
            tool_name: 'Stripe MCP',
            tool_type: 'mcp',
            service: 'stripe',
            category: 'payment',
            short_description: 'Payment & Subscription Management - create customers, invoices, subscriptions, refunds',
            operations: [
                'create_customer(name, email)',
                'list_customers(limit?, email?)',
                'create_product(name, description?)',
                'list_products(limit?)',
                'create_price(product, unit_amount, currency)',
                'list_prices(product?, limit?)',
                'create_payment_link(price, quantity, redirect_url?)',
                'create_invoice(customer, days_until_due?)',
                'list_invoices(customer?, limit?)',
                'create_invoice_item(customer, price, invoice)',
                'finalize_invoice(invoice)',
                'retrieve_balance()',
                'create_refund(payment_intent, amount?, reason?)',
                'list_payment_intents(customer?, limit?)',
                'list_subscriptions(customer?, price?, status?, limit?)',
                'cancel_subscription(subscription)',
                'update_subscription(subscription, items, proration_behavior?)',
                'list_coupons(limit?)',
                'create_coupon(name, percent_off OR amount_off, duration?, duration_in_months?)',
                'update_dispute(dispute, evidence?, submit?)',
                'list_disputes(charge?, payment_intent?, limit?)',
                'search_stripe_documentation(question, language?)'
            ],
            examples: [
                {
                    wrong: 'const stripe = new Stripe(process.env.STRIPE_SECRET_KEY); const customer = await stripe.customers.create({...})',
                    correct: 'await mcp__stripe__create_customer({ name: "John Doe", email: "john@example.com" })'
                }
            ],
            keywords: ['payment', 'stripe', 'customer', 'invoice', 'subscription', 'refund', 'checkout', 'price', 'coupon', 'billing', 'charge', 'dispute'],
            priority: 0.9
        },
        {
            id: 'mcp:vapi',
            tool_name: 'Vapi MCP',
            tool_type: 'mcp',
            service: 'vapi',
            category: 'voice',
            short_description: 'Voice AI Management - create assistants, manage calls, phone numbers, tools',
            operations: [
                'list_assistants()',
                'create_assistant(name, firstMessage?, firstMessageMode?, instructions?, llm?, toolIds?, transcriber?, voice?)',
                'get_assistant(assistantId)',
                'update_assistant(assistantId, name?, instructions?, llm?, voice?, ...)',
                'list_calls()',
                'create_call(assistantId?, customer?, phoneNumberId?, scheduledAt?, assistantOverrides?)',
                'get_call(callId)',
                'list_phone_numbers()',
                'get_phone_number(phoneNumberId)',
                'list_tools()',
                'get_tool(toolId)',
                'create_tool(type, name?, description?, sms?, transferCall?, function?, apiRequest?)',
                'update_tool(toolId, name?, description?, ...)'
            ],
            examples: [
                {
                    wrong: 'const response = await fetch("https://api.vapi.ai/assistant", { method: "POST", ... })',
                    correct: 'await mcp__vapi__create_assistant({ name: "AI Receptionist", instructions: "You are a helpful receptionist...", voice: { provider: "11labs", voiceId: "sarah" } })'
                }
            ],
            keywords: ['voice', 'vapi', 'assistant', 'call', 'phone', 'transcribe', 'speech', 'audio', 'ai', 'receptionist'],
            priority: 0.9
        },
        {
            id: 'mcp:vercel',
            tool_name: 'Vercel MCP',
            tool_type: 'mcp',
            service: 'vercel',
            category: 'deployment',
            short_description: 'Deployment & Infrastructure - deploy projects, manage domains, view logs',
            operations: [
                'search_vercel_documentation(topic, tokens?)',
                'deploy_to_vercel()',
                'list_projects(teamId)',
                'get_project(projectId, teamId)',
                'list_deployments(projectId, teamId, since?, until?)',
                'get_deployment(idOrUrl, teamId)',
                'get_deployment_build_logs(idOrUrl, teamId, limit?)',
                'get_access_to_vercel_url(url)',
                'web_fetch_vercel_url(url)',
                'list_teams()',
                'check_domain_availability_and_price(names[])'
            ],
            keywords: ['deploy', 'vercel', 'build', 'production', 'staging', 'domain', 'hosting', 'logs', 'project'],
            priority: 0.8
        },
        {
            id: 'mcp:playwright',
            tool_name: 'Playwright MCP',
            tool_type: 'mcp',
            service: 'playwright',
            category: 'testing',
            short_description: 'Browser Automation & E2E Testing - navigate, click, type, screenshot',
            operations: [
                'browser_navigate(url)',
                'browser_click(selector)',
                'browser_type(selector, text)',
                'browser_select_option(selector, value)',
                'browser_take_screenshot()',
                'browser_snapshot()',
                'browser_hover(selector)',
                'browser_drag(from, to)',
                'browser_navigate_back()',
                'browser_close()'
            ],
            full_documentation: 'Usage: Say "use playwright mcp to..." - opens visible Chrome window. Auth: Login manually, Claude watches - cookies persist for session. Skill: Use playwright-e2e-testing skill for Project Aurora test scenarios.',
            keywords: ['test', 'browser', 'e2e', 'screenshot', 'automation', 'click', 'navigate', 'playwright'],
            priority: 0.7
        },
        {
            id: 'mcp:supabase',
            tool_name: 'Supabase MCP',
            tool_type: 'mcp',
            service: 'supabase',
            category: 'database',
            short_description: 'Database operations via @supabase/mcp-server-supabase',
            keywords: ['database', 'supabase', 'postgres', 'sql', 'query', 'table', 'schema', 'rls'],
            priority: 0.8
        },
        {
            id: 'mcp:n8n',
            tool_name: 'n8n MCP',
            tool_type: 'mcp',
            service: 'n8n',
            category: 'automation',
            short_description: 'Workflow automation via mcp-n8n',
            keywords: ['workflow', 'n8n', 'automation', 'trigger', 'webhook', 'integration'],
            priority: 0.7
        }
    ],

    // Skills by category
    skills: {
        session: [
            { id: 'skill:session-startup', tool_name: 'session-startup', short_description: 'START of every session - establishes context, loads memory, reads progress, selects task', keywords: ['session', 'startup', 'context', 'progress', 'harness'], priority: 0.95 },
            { id: 'skill:session-completion', tool_name: 'session-completion', short_description: 'END of every session - documents progress, updates memory, prepares handoff', keywords: ['session', 'completion', 'handoff', 'memory', 'end'], priority: 0.95 },
            { id: 'skill:single-feature-focus', tool_name: 'single-feature-focus', short_description: 'DURING work - maintains disciplined one-task-at-a-time execution', keywords: ['focus', 'single', 'task', 'discipline', 'feature'], priority: 0.9 },
            { id: 'skill:nelson-protocol-v4', tool_name: 'nelson-protocol-v4', short_description: 'FULL CYCLE - memory-augmented development with ULTRATHINK planning and self-assessment', keywords: ['nelson', 'protocol', 'ultrathink', 'memory', 'planning'], priority: 0.9 }
        ],
        development: [
            { id: 'skill:using-superpowers', tool_name: 'using-superpowers', short_description: 'How to find and use skills (use at conversation start)', keywords: ['skills', 'superpowers', 'start', 'help'], priority: 0.8 },
            { id: 'skill:using-git-worktrees', tool_name: 'using-git-worktrees', short_description: 'Create isolated git worktrees for features', keywords: ['git', 'worktree', 'branch', 'isolation', 'feature'], priority: 0.7 },
            { id: 'skill:test-driven-development', tool_name: 'test-driven-development', short_description: 'TDD workflow before implementation', keywords: ['test', 'tdd', 'testing', 'development', 'red-green-refactor'], priority: 0.8 },
            { id: 'skill:systematic-debugging', tool_name: 'systematic-debugging', short_description: 'Debug bugs before proposing fixes', keywords: ['debug', 'bug', 'fix', 'systematic', 'error'], priority: 0.85 },
            { id: 'skill:dispatching-parallel-agents', tool_name: 'dispatching-parallel-agents', short_description: 'Run 2+ independent tasks in parallel', keywords: ['parallel', 'agents', 'concurrent', 'tasks'], priority: 0.7 },
            { id: 'skill:executing-plans', tool_name: 'executing-plans', short_description: 'Execute implementation plans with review checkpoints', keywords: ['execute', 'plan', 'implement', 'review'], priority: 0.75 },
            { id: 'skill:finishing-a-development-branch', tool_name: 'finishing-a-development-branch', short_description: 'Guide branch completion (merge/PR/cleanup)', keywords: ['branch', 'merge', 'pr', 'finish', 'cleanup'], priority: 0.7 },
            { id: 'skill:subagent-driven-development', tool_name: 'subagent-driven-development', short_description: 'Execute plans with independent tasks', keywords: ['subagent', 'parallel', 'independent', 'tasks'], priority: 0.7 }
        ],
        planning: [
            { id: 'skill:brainstorming', tool_name: 'brainstorming', short_description: 'Explore user intent before implementation (REQUIRED for creative work)', keywords: ['brainstorm', 'creative', 'intent', 'explore', 'design'], priority: 0.85 },
            { id: 'skill:writing-plans', tool_name: 'writing-plans', short_description: 'Create implementation plans for multi-step tasks', keywords: ['plan', 'write', 'implementation', 'strategy'], priority: 0.8 },
            { id: 'skill:frontend-design', tool_name: 'frontend-design', short_description: 'Create production-grade UI components', keywords: ['frontend', 'design', 'ui', 'component', 'css'], priority: 0.75 }
        ],
        quality: [
            { id: 'skill:playwright-e2e-testing', tool_name: 'playwright-e2e-testing', short_description: 'Visual E2E testing with browser automation (uses Playwright MCP)', keywords: ['e2e', 'test', 'playwright', 'browser', 'visual'], priority: 0.8 },
            { id: 'skill:requesting-code-review', tool_name: 'requesting-code-review', short_description: 'Request code review before merging', keywords: ['review', 'code', 'request', 'merge'], priority: 0.75 },
            { id: 'skill:receiving-code-review', tool_name: 'receiving-code-review', short_description: 'Process code review feedback with rigor', keywords: ['review', 'feedback', 'code', 'receive'], priority: 0.75 },
            { id: 'skill:verification-before-completion', tool_name: 'verification-before-completion', short_description: 'Verify work before claiming completion', keywords: ['verify', 'complete', 'check', 'done'], priority: 0.85 },
            { id: 'skill:writing-skills', tool_name: 'writing-skills', short_description: 'Create/edit/verify new skills', keywords: ['skill', 'write', 'create', 'template'], priority: 0.7 }
        ],
        audit: [
            { id: 'skill:audit', tool_name: 'audit', short_description: 'System-wide audit', keywords: ['audit', 'system', 'review', 'check'], priority: 0.6 },
            { id: 'skill:api-audit', tool_name: 'api-audit', short_description: 'API & Edge Functions audit', keywords: ['api', 'audit', 'edge', 'function'], priority: 0.6 },
            { id: 'skill:business-portal-audit', tool_name: 'business-portal-audit', short_description: 'Business portal audit', keywords: ['business', 'portal', 'audit', 'dashboard'], priority: 0.6 },
            { id: 'skill:database-audit', tool_name: 'database-audit', short_description: 'Database schema audit', keywords: ['database', 'schema', 'audit', 'sql'], priority: 0.6 },
            { id: 'skill:n8n-workflow-audit', tool_name: 'n8n-workflow-audit', short_description: 'n8n workflow audit', keywords: ['n8n', 'workflow', 'audit', 'automation'], priority: 0.6 },
            { id: 'skill:sales-demo-audit', tool_name: 'sales-demo-audit', short_description: 'Sales & demo system audit', keywords: ['sales', 'demo', 'audit'], priority: 0.6 },
            { id: 'skill:security-scan', tool_name: 'security-scan', short_description: 'Security audit', keywords: ['security', 'scan', 'audit', 'vulnerability'], priority: 0.7 },
            { id: 'skill:tech-app-audit', tool_name: 'tech-app-audit', short_description: 'Technician app audit', keywords: ['tech', 'app', 'audit', 'mobile'], priority: 0.6 },
            { id: 'skill:ui-expert-audit', tool_name: 'ui-expert-audit', short_description: 'UI expert audit', keywords: ['ui', 'audit', 'design', 'expert'], priority: 0.6 },
            { id: 'skill:ux-expert-audit', tool_name: 'ux-expert-audit', short_description: 'UX expert audit', keywords: ['ux', 'audit', 'user', 'experience'], priority: 0.6 },
            { id: 'skill:test-integrations', tool_name: 'test-integrations', short_description: 'Integration testing', keywords: ['test', 'integration', 'e2e'], priority: 0.7 }
        ],
        nelson: [
            { id: 'skill:nelson-muntz:nelson', tool_name: '/nelson-muntz:nelson', short_description: 'Start standard development loop', keywords: ['nelson', 'loop', 'development', 'start'], priority: 0.85 },
            { id: 'skill:nelson-muntz:ha-ha', tool_name: '/nelson-muntz:ha-ha', short_description: 'HA-HA MODE - Peak performance loop for complex tasks', keywords: ['ha-ha', 'nelson', 'peak', 'performance', 'complex'], priority: 0.9 },
            { id: 'skill:nelson-muntz:nelson-status', tool_name: '/nelson-muntz:nelson-status', short_description: 'Check loop status', keywords: ['nelson', 'status', 'check'], priority: 0.6 },
            { id: 'skill:nelson-muntz:nelson-stop', tool_name: '/nelson-muntz:nelson-stop', short_description: 'Stop running loop', keywords: ['nelson', 'stop', 'end'], priority: 0.6 },
            { id: 'skill:nelson-muntz:help', tool_name: '/nelson-muntz:help', short_description: 'Show Nelson help documentation', keywords: ['nelson', 'help', 'documentation'], priority: 0.5 }
        ],
        phone_routing: [
            { id: 'skill:twilio-number-provisioning', tool_name: 'twilio-number-provisioning', short_description: 'Auto-provision local US numbers based on customer location', keywords: ['twilio', 'phone', 'provision', 'number', 'local'], priority: 0.8 },
            { id: 'skill:vapi-assistant-setup', tool_name: 'vapi-assistant-setup', short_description: 'Configure Vapi assistants using MCP', keywords: ['vapi', 'assistant', 'setup', 'configure'], priority: 0.8 },
            { id: 'skill:call-routing-configuration', tool_name: 'call-routing-configuration', short_description: 'Business hours, overflow, emergency protocols', keywords: ['routing', 'call', 'hours', 'emergency', 'overflow'], priority: 0.75 },
            { id: 'skill:phone-forwarding-verification', tool_name: 'phone-forwarding-verification', short_description: 'Verify call forwarding setup', keywords: ['forwarding', 'phone', 'verify', 'test'], priority: 0.7 }
        ]
    },

    // Decision frameworks
    decision_guide: {
        use_mcp_when: [
            'Direct API operation exists (Stripe customer, Vapi assistant, etc.)',
            'Single operation with clear input/output',
            'MCP handles auth, rate limiting, errors'
        ],
        use_skill_when: [
            'Multi-step workflow (provision number → configure → send email)',
            'Operation will be reused 3+ times',
            'Combines multiple MCPs or complex logic',
            'Requires specific domain knowledge (phone provisioning, Vapi setup)'
        ],
        use_custom_code_when: [
            'Truly one-off operation',
            'No MCP exists and not reusable',
            'Simple utility function'
        ]
    },

    // Nelson quick reference
    nelson_guide: {
        trigger_phrases: ['use ha-ha mode', 'activate ha-ha mode', 'start ha-ha mode', 'nelson ha-ha', 'peak performance mode'],
        iteration_limits: { default: 16, max: 36, unlimited: 0 },
        task_guide: [
            { type: 'Quick fix', command: '/nelson-muntz:nelson', iterations: '3-5' },
            { type: 'Standard feature', command: '/nelson-muntz:nelson', iterations: '5-10' },
            { type: 'Complex feature', command: '/nelson-muntz:ha-ha', iterations: '10-20' },
            { type: 'Multi-task audit', command: '/nelson-muntz:ha-ha + task list', iterations: '2-3' },
            { type: 'Critical system', command: '/nelson-muntz:ha-ha', iterations: '20-36' }
        ]
    }
};

/**
 * Index all tool documentation into the database
 */
function indexAllDocs(db) {
    console.log('');
    console.log('📚 Indexing tool documentation...');

    const stats = { mcps: 0, skills: 0, total_tokens: 0 };

    const insertDoc = db.prepare(`
        INSERT OR REPLACE INTO tool_docs
        (id, tool_name, tool_type, service, category, short_description, full_documentation, operations, examples, keywords, priority, token_count, indexed_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now'))
    `);

    // Index MCPs
    console.log('');
    console.log('📡 Indexing MCP documentation...');
    for (const mcp of TOOL_DOCUMENTATION.mcps) {
        const fullDoc = mcp.full_documentation || generateMCPDoc(mcp);
        const tokenCount = Math.ceil(fullDoc.length / 4);

        insertDoc.run(
            mcp.id,
            mcp.tool_name,
            'mcp',
            mcp.service,
            mcp.category,
            mcp.short_description,
            fullDoc,
            JSON.stringify(mcp.operations || []),
            JSON.stringify(mcp.examples || []),
            JSON.stringify(mcp.keywords || []),
            mcp.priority,
            tokenCount
        );

        stats.mcps++;
        stats.total_tokens += tokenCount;
        console.log(`   ✓ ${mcp.tool_name} (~${tokenCount} tokens)`);
    }

    // Index Skills
    console.log('');
    console.log('🎯 Indexing skill documentation...');
    for (const [category, skills] of Object.entries(TOOL_DOCUMENTATION.skills)) {
        for (const skill of skills) {
            const fullDoc = skill.full_documentation || skill.short_description;
            const tokenCount = Math.ceil(fullDoc.length / 4);

            insertDoc.run(
                skill.id,
                skill.tool_name,
                'skill',
                null,
                category,
                skill.short_description,
                fullDoc,
                JSON.stringify([]),
                JSON.stringify(skill.examples || []),
                JSON.stringify(skill.keywords || []),
                skill.priority,
                tokenCount
            );

            stats.skills++;
            stats.total_tokens += tokenCount;
        }
        console.log(`   ✓ ${category}: ${skills.length} skills`);
    }

    return stats;
}

/**
 * Generate full documentation for an MCP from its operations
 */
function generateMCPDoc(mcp) {
    let doc = `${mcp.tool_name}\n`;
    doc += `${mcp.short_description}\n\n`;

    if (mcp.operations && mcp.operations.length > 0) {
        doc += 'Operations:\n';
        for (const op of mcp.operations) {
            doc += `- ${op}\n`;
        }
    }

    if (mcp.examples && mcp.examples.length > 0) {
        doc += '\nExamples:\n';
        for (const ex of mcp.examples) {
            doc += `WRONG: ${ex.wrong}\n`;
            doc += `CORRECT: ${ex.correct}\n\n`;
        }
    }

    return doc;
}

/**
 * Retrieve documentation for a task (search-based)
 */
function retrieveDocs(db, taskDescription, options = {}) {
    const limit = options.limit || 3;

    // Extract keywords from task
    const keywords = taskDescription
        .toLowerCase()
        .replace(/[^a-z0-9\s]/g, ' ')
        .split(/\s+/)
        .filter(w => w.length > 2);

    const ftsQuery = keywords.slice(0, 6).join(' OR ');

    if (!ftsQuery) {
        return [];
    }

    try {
        return db.prepare(`
            SELECT
                d.id,
                d.tool_name,
                d.tool_type,
                d.service,
                d.category,
                d.short_description,
                d.full_documentation,
                d.operations,
                d.examples,
                d.keywords,
                d.priority,
                bm25(tool_docs_fts) as score
            FROM tool_docs_fts
            JOIN tool_docs d ON tool_docs_fts.rowid = d.rowid
            WHERE tool_docs_fts MATCH ?
            ORDER BY d.priority DESC, score
            LIMIT ?
        `).all(ftsQuery, limit);
    } catch (e) {
        // Fallback to LIKE
        const likePattern = `%${keywords[0]}%`;
        return db.prepare(`
            SELECT * FROM tool_docs
            WHERE keywords LIKE ? OR short_description LIKE ? OR tool_name LIKE ?
            ORDER BY priority DESC
            LIMIT ?
        `).all(likePattern, likePattern, likePattern, limit);
    }
}

/**
 * Format retrieved docs for injection into context
 */
function formatDocsForContext(docs) {
    if (docs.length === 0) {
        return '';
    }

    let output = '## Relevant Tools for This Task\n\n';

    for (const doc of docs) {
        const typeIcon = doc.tool_type === 'mcp' ? '📡' : '🎯';
        output += `### ${typeIcon} ${doc.tool_name}\n`;
        output += `${doc.short_description}\n\n`;

        if (doc.tool_type === 'mcp') {
            const operations = JSON.parse(doc.operations || '[]');
            if (operations.length > 0) {
                output += 'Key operations:\n';
                for (const op of operations.slice(0, 5)) {
                    output += `- \`${op}\`\n`;
                }
                if (operations.length > 5) {
                    output += `- ... and ${operations.length - 5} more\n`;
                }
                output += '\n';
            }
        }

        const examples = JSON.parse(doc.examples || '[]');
        if (examples.length > 0) {
            output += 'Example:\n```\n';
            output += `${examples[0].correct || examples[0]}\n`;
            output += '```\n\n';
        }
    }

    return output;
}

/**
 * Generate minimal CLAUDE.md replacement section
 */
function generateMinimalSection() {
    return `## 🔧 MCP & SKILL PROTOCOL (TOKEN-OPTIMIZED)

### The Golden Rule: Don't Reinvent the Wheel

**BEFORE writing custom code, check MCP/Skills in this order:**

1. ✅ **MCPs** - Direct API integrations (Stripe, Vapi, Vercel, n8n, Supabase, Playwright)
2. ✅ **Skills** - Reusable workflows (\`/help skills\` to list)
3. ❌ **Custom code** - Only for truly one-off tasks

### Tool Discovery (On-Demand)

**Get relevant tools for your task:**
\`\`\`bash
node .nelson/mcp-skill-docs-extractor.cjs retrieve "your task description"
\`\`\`

**Example:**
\`\`\`bash
# Finding payment tools
node .nelson/mcp-skill-docs-extractor.cjs retrieve "create stripe checkout"

# Finding voice AI tools
node .nelson/mcp-skill-docs-extractor.cjs retrieve "configure vapi assistant"
\`\`\`

### Quick Reference

| Domain | MCP/Skill |
|--------|-----------|
| Payments | Stripe MCP |
| Voice AI | Vapi MCP |
| Deploy | Vercel MCP |
| Database | Supabase MCP |
| Automation | n8n MCP |
| Testing | Playwright MCP |
| Sessions | session-startup, session-completion |
| Debug | systematic-debugging |
| Quality | verification-before-completion |

### Nelson Commands
- \`/nelson-muntz:nelson "task"\` - Standard loop
- \`/nelson-muntz:ha-ha "task"\` - Peak performance mode

**Full documentation stored in database. Retrieve as needed.**

---`;
}

/**
 * Main CLI
 */
async function main() {
    const args = process.argv.slice(2);
    const command = args[0] || 'help';

    if (command === 'help' || command === '--help') {
        console.log('MCP & Skill Documentation Extractor v1.0');
        console.log('');
        console.log('Commands:');
        console.log('  extract               Index all documentation to database');
        console.log('  retrieve "task"       Get relevant docs for a task');
        console.log('  minimal               Print minimal CLAUDE.md section');
        console.log('  stats                 Show documentation statistics');
        console.log('');
        console.log('Token Savings:');
        console.log('  Current CLAUDE.md: ~5,600 tokens for MCP/skill section');
        console.log('  With this system:  ~300 tokens + on-demand retrieval');
        console.log('  Savings:           ~5,300 tokens per session');
        console.log('');
        process.exit(0);
    }

    // Load better-sqlite3
    let Database;
    try {
        Database = require('better-sqlite3');
    } catch (e) {
        console.log('❌ better-sqlite3 not installed. Run: npm install better-sqlite3');
        process.exit(1);
    }

    // Ensure DB exists
    if (!fs.existsSync(DB_PATH) && command !== 'extract') {
        console.log('❌ Database not found. Run: node .nelson/init-db.cjs');
        process.exit(1);
    }

    const db = new Database(DB_PATH);
    initializeDocsSchema(db);

    switch (command) {
        case 'extract': {
            console.log('╔══════════════════════════════════════════════════════════════════╗');
            console.log('║      MCP & SKILL DOCUMENTATION EXTRACTOR - TOKEN OPTIMIZER       ║');
            console.log('╚══════════════════════════════════════════════════════════════════╝');

            const stats = indexAllDocs(db);

            console.log('');
            console.log('╔══════════════════════════════════════════════════════════════════╗');
            console.log('║                    EXTRACTION COMPLETE                           ║');
            console.log('╚══════════════════════════════════════════════════════════════════╝');
            console.log('');
            console.log('📊 Statistics:');
            console.log(`   • MCPs indexed: ${stats.mcps}`);
            console.log(`   • Skills indexed: ${stats.skills}`);
            console.log(`   • Total docs: ${stats.mcps + stats.skills}`);
            console.log(`   • Estimated tokens stored: ~${stats.total_tokens}`);
            console.log('');
            console.log('💡 Token Savings:');
            console.log('   • Original CLAUDE.md section: ~5,600 tokens');
            console.log('   • Minimal replacement: ~300 tokens');
            console.log('   • SAVINGS PER SESSION: ~5,300 tokens');
            console.log('');
            console.log('📝 Next Steps:');
            console.log('   1. Replace MCP section in CLAUDE.md with minimal version:');
            console.log('      node .nelson/mcp-skill-docs-extractor.cjs minimal');
            console.log('');
            console.log('   2. Retrieve docs on-demand:');
            console.log('      node .nelson/mcp-skill-docs-extractor.cjs retrieve "task"');
            break;
        }

        case 'retrieve': {
            const task = args.slice(1).join(' ');
            if (!task) {
                console.log('❌ No task provided');
                console.log('Usage: node .nelson/mcp-skill-docs-extractor.cjs retrieve "create payment link"');
                process.exit(1);
            }

            console.log(`🔍 Finding relevant tools for: "${task}"`);
            console.log('');

            const docs = retrieveDocs(db, task, { limit: 3 });
            console.log(formatDocsForContext(docs));
            break;
        }

        case 'minimal': {
            console.log('');
            console.log('Copy this to replace the MCP section in CLAUDE.md:');
            console.log('');
            console.log('─'.repeat(70));
            console.log(generateMinimalSection());
            console.log('─'.repeat(70));
            break;
        }

        case 'stats': {
            const mcpCount = db.prepare('SELECT COUNT(*) as count FROM tool_docs WHERE tool_type = ?').get('mcp').count;
            const skillCount = db.prepare('SELECT COUNT(*) as count FROM tool_docs WHERE tool_type = ?').get('skill').count;
            const totalTokens = db.prepare('SELECT SUM(token_count) as total FROM tool_docs').get().total || 0;

            console.log('📊 Documentation Statistics:');
            console.log(`   • MCPs: ${mcpCount}`);
            console.log(`   • Skills: ${skillCount}`);
            console.log(`   • Total tokens stored: ~${totalTokens}`);
            console.log('');
            console.log('💡 Token Savings: ~5,300 tokens per session');
            break;
        }

        default:
            console.log(`❌ Unknown command: ${command}`);
            console.log('Run with --help for usage');
            process.exit(1);
    }

    db.close();
}

// Export for module use
module.exports = {
    initializeDocsSchema,
    indexAllDocs,
    retrieveDocs,
    formatDocsForContext,
    generateMinimalSection,
    TOOL_DOCUMENTATION
};

// Run if called directly
if (require.main === module) {
    main().catch(console.error);
}
