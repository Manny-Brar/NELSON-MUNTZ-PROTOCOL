/**
 * Nelson Automatic Conversation Capture
 *
 * Automatically captures session summaries and appends them to daily logs.
 * Can be invoked manually or via hook at session completion.
 *
 * Usage:
 *   node .nelson/capture.cjs "Session Name" "Status" --tasks "Task 1, Task 2"
 *   node .nelson/capture.cjs "Session Name" "COMPLETE" --mode HA-HA --commit abc123
 *   node .nelson/capture.cjs --append "Additional notes to add"
 *
 * Hook Integration:
 *   Add to .claude/settings.local.json hooks.Stop or session-completion skill
 */

const fs = require('fs');
const path = require('path');

const NELSON_DIR = path.join(process.cwd(), '.nelson');
const MEMORY_DIR = path.join(NELSON_DIR, 'memory');

/**
 * Get today's date in YYYY-MM-DD format
 */
function getTodayDate() {
    const now = new Date();
    return now.toISOString().split('T')[0];
}

/**
 * Get current time in HH:MM format
 */
function getCurrentTime() {
    const now = new Date();
    return now.toTimeString().split(' ')[0].slice(0, 5);
}

/**
 * Get or create today's daily log
 */
function getOrCreateDailyLog() {
    const date = getTodayDate();
    const logPath = path.join(MEMORY_DIR, `${date}.md`);

    // Ensure memory directory exists
    if (!fs.existsSync(MEMORY_DIR)) {
        fs.mkdirSync(MEMORY_DIR, { recursive: true });
    }

    // If log doesn't exist, create from template
    if (!fs.existsSync(logPath)) {
        const templatePath = path.join(MEMORY_DIR, 'template.md');
        let content = `# Daily Log: ${date}\n\n`;

        if (fs.existsSync(templatePath)) {
            // Use template but replace date
            content = fs.readFileSync(templatePath, 'utf-8')
                .replace('[DATE]', date);
        }

        fs.writeFileSync(logPath, content);
        console.log(`📝 Created daily log: ${logPath}`);
    }

    return logPath;
}

/**
 * Append a new session to today's daily log
 */
function appendSession(options = {}) {
    const {
        name = 'Untitled Session',
        status = 'IN_PROGRESS',
        mode = 'Standard',
        tasks = [],
        decisions = [],
        insights = [],
        files = [],
        commits = [],
        blockers = [],
        notes = '',
        iteration = null
    } = options;

    const logPath = getOrCreateDailyLog();
    const time = getCurrentTime();

    let sessionContent = `

---

## Session: ${name}

**Started:** ~${time}
**Mode:** ${mode}
${iteration ? `**Iteration:** ${iteration}\n` : ''}**Status:** ${status}

`;

    // Tasks completed
    if (tasks.length > 0) {
        sessionContent += `### Tasks Completed\n`;
        for (const task of tasks) {
            sessionContent += `- [x] ${task}\n`;
        }
        sessionContent += '\n';
    }

    // Key decisions
    if (decisions.length > 0) {
        sessionContent += `### Key Decisions Made\n`;
        for (let i = 0; i < decisions.length; i++) {
            sessionContent += `${i + 1}. ${decisions[i]}\n`;
        }
        sessionContent += '\n';
    }

    // Insights
    if (insights.length > 0) {
        sessionContent += `### Insights Discovered\n`;
        for (const insight of insights) {
            sessionContent += `- ${insight}\n`;
        }
        sessionContent += '\n';
    }

    // Files modified
    if (files.length > 0) {
        sessionContent += `### Files Modified\n`;
        sessionContent += '```\n';
        for (const file of files) {
            sessionContent += `${file}\n`;
        }
        sessionContent += '```\n\n';
    }

    // Commits
    if (commits.length > 0) {
        sessionContent += `### Commits\n`;
        sessionContent += '| Hash | Message |\n';
        sessionContent += '|------|---------|\n';
        for (const commit of commits) {
            if (typeof commit === 'string') {
                sessionContent += `| ${commit} | - |\n`;
            } else {
                sessionContent += `| ${commit.hash} | ${commit.message} |\n`;
            }
        }
        sessionContent += '\n';
    }

    // Blockers
    if (blockers.length > 0) {
        sessionContent += `### Blockers\n`;
        for (const blocker of blockers) {
            sessionContent += `- [ ] ${blocker}\n`;
        }
        sessionContent += '\n';
    }

    // Notes
    if (notes) {
        sessionContent += `### Notes\n${notes}\n\n`;
    }

    sessionContent += `---\n`;

    // Append to daily log
    fs.appendFileSync(logPath, sessionContent);
    console.log(`✅ Session captured: "${name}"`);
    console.log(`   File: ${logPath}`);

    return logPath;
}

/**
 * Append arbitrary content to today's daily log
 */
function appendToLog(content) {
    const logPath = getOrCreateDailyLog();
    fs.appendFileSync(logPath, `\n${content}\n`);
    console.log(`✅ Appended to daily log: ${logPath}`);
    return logPath;
}

/**
 * Quick capture - minimal session info
 */
function quickCapture(name, status = 'COMPLETE', tasksStr = '') {
    const tasks = tasksStr
        ? tasksStr.split(',').map(t => t.trim()).filter(t => t)
        : [];

    return appendSession({
        name,
        status,
        tasks
    });
}

/**
 * Generate session summary from git diff (for automatic capture)
 */
function captureFromGit() {
    const { execSync } = require('child_process');

    try {
        // Get recent commits (last hour or last 5)
        const commits = execSync('git log --oneline -5 --since="1 hour ago" 2>/dev/null || git log --oneline -3', {
            encoding: 'utf-8',
            cwd: process.cwd()
        }).trim().split('\n').filter(c => c);

        // Get modified files
        const files = execSync('git diff --name-only HEAD~3 2>/dev/null || echo ""', {
            encoding: 'utf-8',
            cwd: process.cwd()
        }).trim().split('\n').filter(f => f);

        // Generate session name from last commit
        let sessionName = 'Development Session';
        if (commits.length > 0) {
            const lastCommit = commits[0];
            sessionName = lastCommit.substring(8).trim(); // Remove hash prefix
        }

        return appendSession({
            name: sessionName,
            status: 'COMPLETE',
            mode: 'Auto-captured',
            files: files.slice(0, 10), // Limit files
            commits: commits.map(c => {
                const [hash, ...msgParts] = c.split(' ');
                return { hash, message: msgParts.join(' ') };
            })
        });
    } catch (e) {
        console.log('⚠️ Could not capture from git:', e.message);
        return null;
    }
}

/**
 * Main CLI
 */
async function main() {
    const args = process.argv.slice(2);

    if (args.length === 0 || args.includes('--help')) {
        console.log('Nelson Conversation Capture');
        console.log('');
        console.log('Usage:');
        console.log('  node .nelson/capture.cjs "Session Name" [STATUS]');
        console.log('  node .nelson/capture.cjs "Name" "COMPLETE" --tasks "Task 1, Task 2"');
        console.log('  node .nelson/capture.cjs "Name" --mode "HA-HA" --commit abc123');
        console.log('  node .nelson/capture.cjs --append "Text to append"');
        console.log('  node .nelson/capture.cjs --git           Auto-capture from git history');
        console.log('');
        console.log('Options:');
        console.log('  --tasks "t1, t2"    Comma-separated tasks completed');
        console.log('  --mode "HA-HA"      Session mode (Standard, HA-HA)');
        console.log('  --commit "hash"     Add commit hash');
        console.log('  --notes "text"      Additional notes');
        console.log('  --iteration N       Iteration number');
        console.log('');
        process.exit(0);
    }

    // Handle --git auto-capture
    if (args.includes('--git')) {
        captureFromGit();
        process.exit(0);
    }

    // Handle --append
    const appendIdx = args.indexOf('--append');
    if (appendIdx !== -1 && args[appendIdx + 1]) {
        appendToLog(args[appendIdx + 1]);
        process.exit(0);
    }

    // Parse session capture
    let name = args[0] || 'Untitled Session';
    let status = 'IN_PROGRESS';
    let tasks = [];
    let mode = 'Standard';
    let commits = [];
    let notes = '';
    let iteration = null;

    // Second positional arg is status
    if (args[1] && !args[1].startsWith('--')) {
        status = args[1];
    }

    // Parse flags
    for (let i = 0; i < args.length; i++) {
        if (args[i] === '--tasks' && args[i + 1]) {
            tasks = args[i + 1].split(',').map(t => t.trim()).filter(t => t);
            i++;
        } else if (args[i] === '--mode' && args[i + 1]) {
            mode = args[i + 1];
            i++;
        } else if (args[i] === '--commit' && args[i + 1]) {
            commits.push(args[i + 1]);
            i++;
        } else if (args[i] === '--notes' && args[i + 1]) {
            notes = args[i + 1];
            i++;
        } else if (args[i] === '--iteration' && args[i + 1]) {
            iteration = args[i + 1];
            i++;
        }
    }

    appendSession({
        name,
        status,
        mode,
        tasks,
        commits,
        notes,
        iteration
    });
}

// Export for use as module
module.exports = {
    appendSession,
    appendToLog,
    quickCapture,
    captureFromGit,
    getOrCreateDailyLog,
    getTodayDate
};

// Run if called directly
if (require.main === module) {
    main().catch(console.error);
}
