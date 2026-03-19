/**
 * Nelson v5.0 — Obsidian Bridge
 *
 * Bridges Nelson's memory system with an Obsidian vault for graph-relational queries.
 * Falls back gracefully to flat-file search when Obsidian is unavailable.
 *
 * Features:
 *   - Auto-detect Obsidian MCP on port 22360
 *   - Read/write notes to vault with wikilinks
 *   - Search vault with backlink context
 *   - Extract graph hubs (most-connected knowledge)
 *   - Sync patterns from .nelson/ to Obsidian vault
 *
 * Usage:
 *   node .nelson/obsidian-bridge.cjs status          # Check Obsidian availability
 *   node .nelson/obsidian-bridge.cjs sync-patterns   # Sync patterns to vault
 *   node .nelson/obsidian-bridge.cjs search "query"  # Search vault
 *   node .nelson/obsidian-bridge.cjs write-pattern "name" "content"
 *   node .nelson/obsidian-bridge.cjs hubs            # Find most-connected notes
 */

const fs = require('fs');
const path = require('path');
const net = require('net');

// Configuration
const OBSIDIAN_PORT = 22360;
const OBSIDIAN_HOST = 'localhost';
const NELSON_DIR = path.join(process.cwd(), '.nelson');
const VAULT_NELSON_DIR = path.join(
  process.env.HOME || process.env.USERPROFILE || '~',
  'ObsidianVault', 'Nelson'
);

/**
 * Check if Obsidian MCP server is available
 */
async function checkObsidianAvailable() {
  return new Promise((resolve) => {
    const socket = new net.Socket();
    socket.setTimeout(2000);

    socket.on('connect', () => {
      socket.destroy();
      resolve(true);
    });

    socket.on('timeout', () => {
      socket.destroy();
      resolve(false);
    });

    socket.on('error', () => {
      socket.destroy();
      resolve(false);
    });

    socket.connect(OBSIDIAN_PORT, OBSIDIAN_HOST);
  });
}

/**
 * Ensure vault directory structure exists
 */
function ensureVaultStructure() {
  const dirs = [
    VAULT_NELSON_DIR,
    path.join(VAULT_NELSON_DIR, 'memory'),
    path.join(VAULT_NELSON_DIR, 'patterns'),
    path.join(VAULT_NELSON_DIR, 'daily'),
    path.join(VAULT_NELSON_DIR, 'decisions'),
    path.join(VAULT_NELSON_DIR, 'eval'),
  ];

  for (const dir of dirs) {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  }
}

/**
 * Write a pattern to both .nelson/ and Obsidian vault (with wikilinks)
 */
function writePattern(name, content, type = 'success') {
  const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-');
  const timestamp = new Date().toISOString().split('T')[0];
  const tags = type === 'success' ? '#pattern #success' : '#anti-pattern #failure';

  // Write to .nelson/ flat files
  const nelsonPath = path.join(NELSON_DIR, 'patterns', type === 'success' ? 'successes.md' : 'failures.md');
  if (fs.existsSync(nelsonPath)) {
    const existing = fs.readFileSync(nelsonPath, 'utf8');
    if (!existing.includes(name)) {
      fs.appendFileSync(nelsonPath, `\n\n### ${name}\n${content}\n`);
      console.log(`[nelson] Pattern "${name}" appended to ${nelsonPath}`);
    }
  }

  // Write to Obsidian vault (if directory exists)
  if (fs.existsSync(VAULT_NELSON_DIR)) {
    const vaultPath = path.join(VAULT_NELSON_DIR, 'patterns', `${slug}.md`);
    const vaultContent = `---
name: ${name}
type: ${type}
date: ${timestamp}
tags: [${type === 'success' ? 'pattern, success' : 'anti-pattern, failure'}]
---

# ${name}

${tags}

${content}

## Related
- [[memory/MEMORY]]
`;

    fs.writeFileSync(vaultPath, vaultContent);
    console.log(`[obsidian] Pattern "${name}" written to ${vaultPath}`);
  }
}

/**
 * Sync all patterns from .nelson/patterns/ to Obsidian vault
 */
function syncPatternsToVault() {
  const patternsDir = path.join(NELSON_DIR, 'patterns');
  if (!fs.existsSync(patternsDir)) {
    console.log('[sync] No patterns directory found');
    return;
  }

  ensureVaultStructure();

  const files = fs.readdirSync(patternsDir).filter(f => f.endsWith('.md'));
  let synced = 0;

  for (const file of files) {
    const content = fs.readFileSync(path.join(patternsDir, file), 'utf8');

    // Extract individual patterns (sections starting with ###)
    const sections = content.split(/(?=^### )/m).filter(s => s.trim());

    for (const section of sections) {
      const nameMatch = section.match(/^### (.+)/);
      if (!nameMatch) continue;

      const name = nameMatch[1].trim();
      const type = file.includes('success') ? 'success' : 'failure';
      const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-');

      if (slug.length < 3) continue;

      const vaultPath = path.join(VAULT_NELSON_DIR, 'patterns', `${slug}.md`);
      if (!fs.existsSync(vaultPath)) {
        writePattern(name, section.replace(/^### .+\n/, '').trim(), type);
        synced++;
      }
    }
  }

  console.log(`[sync] Synced ${synced} new patterns to Obsidian vault`);
}

/**
 * Search .nelson/ flat files (fallback when Obsidian unavailable)
 */
function searchFlat(query) {
  const results = [];
  const searchDirs = [
    path.join(NELSON_DIR, 'memory'),
    path.join(NELSON_DIR, 'patterns'),
    NELSON_DIR,
  ];

  const queryLower = query.toLowerCase();

  for (const dir of searchDirs) {
    if (!fs.existsSync(dir)) continue;

    const files = fs.readdirSync(dir).filter(f => f.endsWith('.md'));
    for (const file of files) {
      const filePath = path.join(dir, file);
      try {
        const content = fs.readFileSync(filePath, 'utf8');
        const lines = content.split('\n');

        for (let i = 0; i < lines.length; i++) {
          if (lines[i].toLowerCase().includes(queryLower)) {
            // Get context (3 lines before and after)
            const start = Math.max(0, i - 3);
            const end = Math.min(lines.length, i + 4);
            const context = lines.slice(start, end).join('\n');

            results.push({
              file: path.relative(process.cwd(), filePath),
              line: i + 1,
              context: context.trim(),
            });
          }
        }
      } catch (e) {
        // Skip unreadable files
      }
    }
  }

  return results;
}

/**
 * Find hub notes (most-connected) in Obsidian vault
 */
function findHubs(minLinks = 3) {
  if (!fs.existsSync(VAULT_NELSON_DIR)) {
    console.log('[hubs] Obsidian vault not found at', VAULT_NELSON_DIR);
    return [];
  }

  const linkCounts = {};
  const allFiles = [];

  // Recursively find all .md files
  function walkDir(dir) {
    const entries = fs.readdirSync(dir, { withFileTypes: true });
    for (const entry of entries) {
      const full = path.join(dir, entry.name);
      if (entry.isDirectory()) {
        walkDir(full);
      } else if (entry.name.endsWith('.md')) {
        allFiles.push(full);
      }
    }
  }

  walkDir(VAULT_NELSON_DIR);

  // Count wikilinks in each file
  for (const file of allFiles) {
    const content = fs.readFileSync(file, 'utf8');
    const wikilinks = content.match(/\[\[([^\]]+)\]\]/g) || [];
    const relPath = path.relative(VAULT_NELSON_DIR, file);

    linkCounts[relPath] = linkCounts[relPath] || { outgoing: 0, incoming: 0 };
    linkCounts[relPath].outgoing = wikilinks.length;

    // Count incoming links
    for (const link of wikilinks) {
      const target = link.replace(/\[\[|\]\]/g, '').split('|')[0];
      const targetKey = target.endsWith('.md') ? target : `${target}.md`;
      linkCounts[targetKey] = linkCounts[targetKey] || { outgoing: 0, incoming: 0 };
      linkCounts[targetKey].incoming++;
    }
  }

  // Find hubs (total links >= minLinks)
  const hubs = Object.entries(linkCounts)
    .map(([file, counts]) => ({
      file,
      total: counts.outgoing + counts.incoming,
      outgoing: counts.outgoing,
      incoming: counts.incoming,
    }))
    .filter(h => h.total >= minLinks)
    .sort((a, b) => b.total - a.total);

  return hubs;
}

// CLI entry point
async function main() {
  const args = process.argv.slice(2);
  const command = args[0];

  switch (command) {
    case 'status': {
      const available = await checkObsidianAvailable();
      const vaultExists = fs.existsSync(VAULT_NELSON_DIR);
      console.log(JSON.stringify({
        obsidian_mcp: available ? 'connected' : 'unavailable',
        obsidian_port: OBSIDIAN_PORT,
        vault_path: VAULT_NELSON_DIR,
        vault_exists: vaultExists,
        fallback: 'flat-file search via .nelson/',
      }, null, 2));
      break;
    }

    case 'sync-patterns': {
      syncPatternsToVault();
      break;
    }

    case 'search': {
      const query = args.slice(1).join(' ');
      if (!query) {
        console.error('Usage: obsidian-bridge.cjs search "query"');
        process.exit(1);
      }
      const results = searchFlat(query);
      console.log(JSON.stringify(results.slice(0, 10), null, 2));
      break;
    }

    case 'write-pattern': {
      const name = args[1];
      const content = args.slice(2).join(' ');
      if (!name || !content) {
        console.error('Usage: obsidian-bridge.cjs write-pattern "name" "content"');
        process.exit(1);
      }
      writePattern(name, content);
      break;
    }

    case 'hubs': {
      const minLinks = parseInt(args[1]) || 3;
      const hubs = findHubs(minLinks);
      if (hubs.length === 0) {
        console.log('No hub notes found (min links:', minLinks, ')');
      } else {
        console.log('Knowledge hubs (most-connected notes):');
        for (const hub of hubs.slice(0, 10)) {
          console.log(`  ${hub.file}: ${hub.total} links (${hub.incoming} in, ${hub.outgoing} out)`);
        }
      }
      break;
    }

    default:
      console.log('Nelson v5.0 Obsidian Bridge');
      console.log('');
      console.log('Commands:');
      console.log('  status           Check Obsidian MCP availability');
      console.log('  sync-patterns    Sync .nelson/patterns/ to Obsidian vault');
      console.log('  search "query"   Search memory (flat-file fallback)');
      console.log('  write-pattern    Write pattern to both .nelson/ and vault');
      console.log('  hubs [min]       Find most-connected knowledge nodes');
  }
}

main().catch(console.error);
