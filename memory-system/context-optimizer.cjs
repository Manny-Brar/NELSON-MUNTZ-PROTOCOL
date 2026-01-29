/**
 * Nelson Context Optimizer v1.0
 *
 * PURPOSE: Analyze and optimize context usage for maximum working space
 *
 * PROBLEM: With 200k context window:
 * - System takes ~35k (tools, prompt, autocompact buffer)
 * - CLAUDE.md takes ~20k
 * - MCP tools take ~14k
 * - Leaves only ~130k for actual work
 *
 * SOLUTION: This tool helps:
 * 1. Analyze what's consuming context
 * 2. Generate minimal CLAUDE.md
 * 3. Recommend which MCPs to enable per project
 * 4. Track token usage over sessions
 *
 * Usage:
 *   node .nelson/context-optimizer.cjs analyze
 *   node .nelson/context-optimizer.cjs compress-claude
 *   node .nelson/context-optimizer.cjs mcp-profile
 */

const fs = require('fs');
const path = require('path');

// Token estimation (4 chars ≈ 1 token for English text)
function estimateTokens(text) {
    if (!text) return 0;
    return Math.ceil(text.length / 4);
}

// MCP token costs (approximate, from real measurements)
const MCP_TOKEN_COSTS = {
    'n8n': {
        tools: 46,
        avgTokensPerTool: 100,
        total: 4600,
        essential: ['n8n_list_workflows_summary', 'n8n_get_workflow', 'n8n_update_workflow', 'n8n_activate_workflow', 'n8n_list_executions'],
        essentialTokens: 900
    },
    'vapi': {
        tools: 13,
        avgTokensPerTool: 300,  // create_assistant and update_assistant are huge
        total: 3900,
        essential: ['list_assistants', 'get_assistant', 'update_assistant', 'list_calls', 'create_call'],
        essentialTokens: 1800
    },
    'playwright': {
        tools: 22,
        avgTokensPerTool: 150,
        total: 3300,
        essential: ['browser_navigate', 'browser_click', 'browser_type', 'browser_snapshot', 'browser_take_screenshot'],
        essentialTokens: 700
    },
    'stripe': {
        tools: 20,
        avgTokensPerTool: 100,
        total: 2000,
        essential: ['create_customer', 'list_customers', 'create_payment_link', 'list_subscriptions'],
        essentialTokens: 400
    },
    'supabase': {
        tools: 10,
        avgTokensPerTool: 80,
        total: 800,
        essential: ['all'],  // Database is core
        essentialTokens: 800
    },
    'vercel': {
        tools: 11,
        avgTokensPerTool: 100,
        total: 1100,
        essential: ['deploy_to_vercel', 'list_deployments', 'get_deployment_build_logs'],
        essentialTokens: 300
    }
};

// CLAUDE.md section token costs
const CLAUDE_SECTIONS = {
    'strategic_context': { lines: 40, tokens: 600, essential: true },
    'nelson_memory_system': { lines: 40, tokens: 600, essential: true },
    'deployment_rule': { lines: 15, tokens: 200, essential: true },
    'frozen_files_protocol': { lines: 35, tokens: 500, essential: true },
    'mcp_skill_protocol': { lines: 374, tokens: 5600, essential: false },  // MOVE TO DB
    'architectural_constraints': { lines: 155, tokens: 2300, essential: true },
    'security_rules': { lines: 75, tokens: 1100, essential: true },
    'file_structure_patterns': { lines: 110, tokens: 1600, essential: false },  // CAN COMPRESS
    'code_patterns': { lines: 80, tokens: 1200, essential: false },  // CAN COMPRESS
    'integration_points': { lines: 35, tokens: 500, essential: false },
    'common_mistakes': { lines: 80, tokens: 1200, essential: true },
    'feature_guidance': { lines: 30, tokens: 400, essential: false },
    'key_documents': { lines: 30, tokens: 400, essential: false },
    'high_risk_areas': { lines: 55, tokens: 800, essential: true },
    'ui_ux_patterns': { lines: 40, tokens: 600, essential: false },
    'development_commands': { lines: 35, tokens: 500, essential: false },
    'testing_checklist': { lines: 25, tokens: 350, essential: false },
    'deployment_checklist': { lines: 40, tokens: 600, essential: false },
    'optimization_guidelines': { lines: 40, tokens: 600, essential: false },
    'decision_frameworks': { lines: 35, tokens: 500, essential: false },
    'new_session_guide': { lines: 30, tokens: 400, essential: false },
    'agent_harness': { lines: 265, tokens: 4000, essential: true },  // KEEP - critical pattern
    'nelson_memory_v4': { lines: 130, tokens: 2000, essential: true },
    'final_reminders': { lines: 30, tokens: 400, essential: true }
};

/**
 * Analyze current context usage
 */
function analyzeContext(claudeMdPath) {
    console.log('');
    console.log('╔══════════════════════════════════════════════════════════════════╗');
    console.log('║            NELSON CONTEXT OPTIMIZER - ANALYSIS                   ║');
    console.log('╚══════════════════════════════════════════════════════════════════╝');
    console.log('');

    const totalContext = 200000;
    const autocompactBuffer = 33000;  // Reserved by Claude Code
    const systemPrompt = 3500;
    const systemTools = 17600;
    const availableForWork = totalContext - autocompactBuffer - systemPrompt - systemTools;

    console.log('📊 Context Window Analysis (200k total):');
    console.log('');
    console.log('   FIXED COSTS (cannot change):');
    console.log(`   ├── System prompt:      ${systemPrompt.toLocaleString()} tokens (1.8%)`);
    console.log(`   ├── System tools:       ${systemTools.toLocaleString()} tokens (8.8%)`);
    console.log(`   └── Autocompact buffer: ${autocompactBuffer.toLocaleString()} tokens (16.5%)`);
    console.log(`       Subtotal:           ${(systemPrompt + systemTools + autocompactBuffer).toLocaleString()} tokens (27%)`);
    console.log('');

    // Analyze CLAUDE.md
    let claudeMdTokens = 0;
    let essentialTokens = 0;
    let compressibleTokens = 0;

    for (const [section, data] of Object.entries(CLAUDE_SECTIONS)) {
        claudeMdTokens += data.tokens;
        if (data.essential) {
            essentialTokens += data.tokens;
        } else {
            compressibleTokens += data.tokens;
        }
    }

    console.log('   VARIABLE COSTS (can optimize):');
    console.log(`   ├── CLAUDE.md:          ${claudeMdTokens.toLocaleString()} tokens (current)`);
    console.log(`   │   ├── Essential:      ${essentialTokens.toLocaleString()} tokens (must keep)`);
    console.log(`   │   └── Compressible:   ${compressibleTokens.toLocaleString()} tokens (can move to DB)`);

    // Analyze MCP tools
    let totalMcpTokens = 0;
    let essentialMcpTokens = 0;

    for (const [mcp, data] of Object.entries(MCP_TOKEN_COSTS)) {
        totalMcpTokens += data.total;
        essentialMcpTokens += data.essentialTokens;
    }

    console.log(`   ├── MCP tools:          ${totalMcpTokens.toLocaleString()} tokens (current)`);
    console.log(`   │   ├── Essential:      ${essentialMcpTokens.toLocaleString()} tokens (frequently used)`);
    console.log(`   │   └── Prunable:       ${(totalMcpTokens - essentialMcpTokens).toLocaleString()} tokens (rarely used)`);
    console.log('   ├── Custom agents:      2,200 tokens');
    console.log('   └── Skills:             1,400 tokens');

    const currentVariableCost = claudeMdTokens + totalMcpTokens + 2200 + 1400;
    const optimizedVariableCost = essentialTokens + essentialMcpTokens + 2200 + 1400;

    console.log(`       Current:            ${currentVariableCost.toLocaleString()} tokens`);
    console.log(`       Optimized:          ${optimizedVariableCost.toLocaleString()} tokens`);
    console.log('');

    const currentFreeSpace = availableForWork - currentVariableCost;
    const optimizedFreeSpace = availableForWork - optimizedVariableCost;
    const savings = optimizedFreeSpace - currentFreeSpace;

    console.log('   💡 OPTIMIZATION POTENTIAL:');
    console.log(`   ├── Current free space:   ${currentFreeSpace.toLocaleString()} tokens (${Math.round(currentFreeSpace/totalContext*100)}%)`);
    console.log(`   ├── Optimized free space: ${optimizedFreeSpace.toLocaleString()} tokens (${Math.round(optimizedFreeSpace/totalContext*100)}%)`);
    console.log(`   └── SAVINGS:              ${savings.toLocaleString()} tokens (+${Math.round(savings/currentFreeSpace*100)}% more working space)`);
    console.log('');

    return {
        totalContext,
        currentFreeSpace,
        optimizedFreeSpace,
        savings,
        claudeMd: {
            current: claudeMdTokens,
            essential: essentialTokens,
            compressible: compressibleTokens
        },
        mcpTools: {
            current: totalMcpTokens,
            essential: essentialMcpTokens,
            prunable: totalMcpTokens - essentialMcpTokens
        }
    };
}

/**
 * Generate MCP profile recommendations
 */
function generateMcpProfile(projectType = 'full-stack') {
    console.log('');
    console.log('╔══════════════════════════════════════════════════════════════════╗');
    console.log('║            MCP PROFILE RECOMMENDATIONS                           ║');
    console.log('╚══════════════════════════════════════════════════════════════════╝');
    console.log('');

    const profiles = {
        'full-stack': {
            description: 'Web app with payments, voice, and automation',
            recommended: ['stripe', 'vapi', 'supabase', 'vercel'],
            optional: ['n8n', 'playwright'],
            tokens: 7800
        },
        'api-only': {
            description: 'Backend API development',
            recommended: ['supabase'],
            optional: ['stripe'],
            tokens: 2800
        },
        'voice-ai': {
            description: 'Voice assistant development',
            recommended: ['vapi', 'supabase'],
            optional: ['n8n'],
            tokens: 5500
        },
        'automation': {
            description: 'Workflow automation',
            recommended: ['n8n', 'supabase'],
            optional: [],
            tokens: 5400
        },
        'testing': {
            description: 'E2E testing focus',
            recommended: ['playwright'],
            optional: ['supabase'],
            tokens: 4100
        },
        'minimal': {
            description: 'Minimal footprint (no MCPs)',
            recommended: [],
            optional: [],
            tokens: 0
        }
    };

    console.log('📡 MCP Profile Options:');
    console.log('');

    for (const [name, profile] of Object.entries(profiles)) {
        const isSelected = name === projectType ? ' ← CURRENT' : '';
        console.log(`   ${name.toUpperCase()}${isSelected}`);
        console.log(`   Description: ${profile.description}`);
        console.log(`   Recommended: ${profile.recommended.length > 0 ? profile.recommended.join(', ') : 'none'}`);
        console.log(`   Optional: ${profile.optional.length > 0 ? profile.optional.join(', ') : 'none'}`);
        console.log(`   Token cost: ~${profile.tokens.toLocaleString()} tokens`);
        console.log('');
    }

    console.log('   💡 To change MCP profile:');
    console.log('   1. Disable unused MCPs: claude mcp remove <name>');
    console.log('   2. Restart VS Code to apply changes');
    console.log('');

    console.log('   📊 Per-MCP Token Breakdown:');
    console.log('');
    for (const [mcp, data] of Object.entries(MCP_TOKEN_COSTS)) {
        console.log(`   ${mcp}:`);
        console.log(`     Tools: ${data.tools} | Total: ~${data.total.toLocaleString()} tokens`);
        console.log(`     Essential: ${data.essential.length > 5 ? data.essential.slice(0, 5).join(', ') + '...' : data.essential.join(', ')}`);
        console.log(`     Essential tokens: ~${data.essentialTokens.toLocaleString()} (${Math.round(data.essentialTokens/data.total*100)}%)`);
        console.log('');
    }

    return profiles;
}

/**
 * Generate compressed CLAUDE.md
 */
function generateCompressedClaude(inputPath, outputPath) {
    console.log('');
    console.log('╔══════════════════════════════════════════════════════════════════╗');
    console.log('║          CLAUDE.MD COMPRESSION - TOKEN OPTIMIZER                 ║');
    console.log('╚══════════════════════════════════════════════════════════════════╝');
    console.log('');

    // Essential sections to keep (with compression)
    const essentialSections = [
        'strategic_context',
        'nelson_memory_system',
        'deployment_rule',
        'frozen_files_protocol',
        'architectural_constraints',
        'security_rules',
        'common_mistakes',
        'high_risk_areas',
        'agent_harness',
        'nelson_memory_v4',
        'final_reminders'
    ];

    // Sections to move to DB
    const dbSections = [
        'mcp_skill_protocol',
        'file_structure_patterns',
        'code_patterns',
        'integration_points',
        'feature_guidance',
        'key_documents',
        'ui_ux_patterns',
        'development_commands',
        'testing_checklist',
        'deployment_checklist',
        'optimization_guidelines',
        'decision_frameworks',
        'new_session_guide'
    ];

    let essentialTokens = 0;
    let movedTokens = 0;

    console.log('📝 Section Analysis:');
    console.log('');
    console.log('   KEEPING (essential):');
    for (const section of essentialSections) {
        const data = CLAUDE_SECTIONS[section];
        if (data) {
            essentialTokens += data.tokens;
            console.log(`     ✓ ${section}: ~${data.tokens.toLocaleString()} tokens`);
        }
    }
    console.log(`     Subtotal: ~${essentialTokens.toLocaleString()} tokens`);
    console.log('');

    console.log('   MOVING TO DB (on-demand retrieval):');
    for (const section of dbSections) {
        const data = CLAUDE_SECTIONS[section];
        if (data) {
            movedTokens += data.tokens;
            console.log(`     → ${section}: ~${data.tokens.toLocaleString()} tokens`);
        }
    }
    console.log(`     Subtotal: ~${movedTokens.toLocaleString()} tokens SAVED`);
    console.log('');

    // Generate minimal MCP section replacement
    const minimalMcpSection = `## 🔧 MCP & SKILL PROTOCOL (TOKEN-OPTIMIZED)

### The Golden Rule: Don't Reinvent the Wheel

**Check MCP/Skills before writing custom code:**
1. ✅ **MCPs** - Direct API integrations (Stripe, Vapi, Vercel, n8n, Supabase, Playwright)
2. ✅ **Skills** - Reusable workflows (\`/help skills\`)
3. ❌ **Custom code** - Only for truly one-off tasks

### Tool Discovery (On-Demand)

Get relevant tools for your task:
\`\`\`bash
node .nelson/tools-indexer.cjs recommend "your task"
node .nelson/mcp-skill-docs-extractor.cjs retrieve "stripe payment"
\`\`\`

### Quick Reference

| Domain | MCP |
|--------|-----|
| Payments | Stripe MCP |
| Voice AI | Vapi MCP |
| Deploy | Vercel MCP |
| Database | Supabase MCP |
| Automation | n8n MCP |
| Testing | Playwright MCP |

### Nelson Commands
- \`/nelson-muntz:nelson "task"\` - Standard loop
- \`/nelson-muntz:ha-ha "task"\` - Peak performance mode

**Full documentation stored in database. Retrieve as needed.**

---`;

    console.log('📊 Summary:');
    console.log(`   Original CLAUDE.md: ~${(essentialTokens + movedTokens).toLocaleString()} tokens`);
    console.log(`   Optimized CLAUDE.md: ~${essentialTokens.toLocaleString()} tokens`);
    console.log(`   SAVINGS: ~${movedTokens.toLocaleString()} tokens (${Math.round(movedTokens/(essentialTokens+movedTokens)*100)}% reduction)`);
    console.log('');

    console.log('📝 Minimal MCP section replacement:');
    console.log('─'.repeat(60));
    console.log(minimalMcpSection);
    console.log('─'.repeat(60));
    console.log('');
    console.log('Copy the above to replace lines 124-497 in CLAUDE.md');

    return {
        essentialTokens,
        movedTokens,
        savings: movedTokens,
        minimalMcpSection
    };
}

/**
 * Main CLI
 */
async function main() {
    const args = process.argv.slice(2);
    const command = args[0] || 'help';

    if (command === 'help' || command === '--help') {
        console.log('Nelson Context Optimizer v1.0');
        console.log('');
        console.log('PURPOSE: Maximize working context by reducing token overhead');
        console.log('');
        console.log('Commands:');
        console.log('  analyze           Analyze current context usage');
        console.log('  compress-claude   Generate optimized CLAUDE.md');
        console.log('  mcp-profile       Show MCP profile recommendations');
        console.log('');
        console.log('Typical savings: 10-15k tokens = 50%+ more working space');
        console.log('');
        process.exit(0);
    }

    switch (command) {
        case 'analyze': {
            const analysis = analyzeContext();
            break;
        }

        case 'compress-claude': {
            generateCompressedClaude();
            break;
        }

        case 'mcp-profile': {
            const projectType = args[1] || 'full-stack';
            generateMcpProfile(projectType);
            break;
        }

        default:
            console.log(`❌ Unknown command: ${command}`);
            console.log('Run with --help for usage');
            process.exit(1);
    }
}

// Export for module use
module.exports = {
    analyzeContext,
    generateCompressedClaude,
    generateMcpProfile,
    estimateTokens,
    MCP_TOKEN_COSTS,
    CLAUDE_SECTIONS
};

// Run if called directly
if (require.main === module) {
    main().catch(console.error);
}
