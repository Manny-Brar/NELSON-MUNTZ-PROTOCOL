/**
 * Nelson v5.0 — GEPA-Inspired Memory Consolidation
 *
 * Analyzes execution history, prunes stale entries, merges duplicates,
 * and maintains MEMORY.md under 200 lines for efficient auto-loading.
 *
 * Inspired by GEPA (Genetic-Pareto Reflective Prompt Evolution):
 *   - Extract Actionable Side Information from past iterations
 *   - Identify patterns vs anti-patterns from success/failure history
 *   - Consolidate overlapping entries
 *   - Prune entries that are now derivable from code
 *
 * Usage:
 *   node .nelson/consolidate.cjs                 # Full consolidation
 *   node .nelson/consolidate.cjs --stats         # Show memory statistics
 *   node .nelson/consolidate.cjs --prune-stale   # Remove entries older than 30 days
 *   node .nelson/consolidate.cjs --find-dupes    # Find duplicate/overlapping entries
 *   node .nelson/consolidate.cjs --trim          # Trim MEMORY.md to 200 lines
 */

const fs = require('fs');
const path = require('path');

const NELSON_DIR = path.join(process.cwd(), '.nelson');
const MEMORY_FILE = path.join(NELSON_DIR, 'MEMORY.md');
const PATTERNS_DIR = path.join(NELSON_DIR, 'patterns');
const DAILY_DIR = path.join(NELSON_DIR, 'memory');

/**
 * Parse MEMORY.md into sections
 */
function parseMemoryFile() {
  if (!fs.existsSync(MEMORY_FILE)) {
    return { lines: 0, sections: [], raw: '' };
  }

  const raw = fs.readFileSync(MEMORY_FILE, 'utf8');
  const lines = raw.split('\n');
  const sections = [];
  let currentSection = null;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    if (line.startsWith('## ')) {
      if (currentSection) sections.push(currentSection);
      currentSection = {
        title: line.replace(/^## /, '').trim(),
        startLine: i,
        endLine: i,
        content: [line],
        itemCount: 0,
      };
    } else if (line.startsWith('### ') && currentSection) {
      currentSection.itemCount++;
      currentSection.content.push(line);
      currentSection.endLine = i;
    } else if (currentSection) {
      currentSection.content.push(line);
      currentSection.endLine = i;
      // Count list items
      if (line.match(/^[-*] \*\*/) || line.match(/^\d+\./)) {
        currentSection.itemCount++;
      }
    }
  }

  if (currentSection) sections.push(currentSection);

  return {
    lines: lines.length,
    sections,
    raw,
  };
}

/**
 * Parse daily logs to find recent entries
 */
function parseDailyLogs(daysBack = 30) {
  if (!fs.existsSync(DAILY_DIR)) return [];

  const logs = [];
  const files = fs.readdirSync(DAILY_DIR)
    .filter(f => f.endsWith('.md'))
    .sort()
    .reverse();

  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() - daysBack);

  for (const file of files) {
    const dateMatch = file.match(/(\d{4}-\d{2}-\d{2})/);
    if (!dateMatch) continue;

    const fileDate = new Date(dateMatch[1]);
    if (fileDate < cutoff) break;

    const content = fs.readFileSync(path.join(DAILY_DIR, file), 'utf8');
    logs.push({
      date: dateMatch[1],
      file,
      content,
      lineCount: content.split('\n').length,
    });
  }

  return logs;
}

/**
 * Parse pattern files
 */
function parsePatterns() {
  if (!fs.existsSync(PATTERNS_DIR)) return { successes: [], failures: [] };

  const result = { successes: [], failures: [] };

  for (const type of ['successes', 'failures']) {
    const filePath = path.join(PATTERNS_DIR, `${type}.md`);
    if (!fs.existsSync(filePath)) continue;

    const content = fs.readFileSync(filePath, 'utf8');
    const sections = content.split(/(?=^### )/m).filter(s => s.trim());

    for (const section of sections) {
      const nameMatch = section.match(/^### (.+)/);
      if (nameMatch) {
        result[type === 'successes' ? 'successes' : 'failures'].push({
          name: nameMatch[1].trim(),
          content: section.trim(),
          lineCount: section.split('\n').length,
        });
      }
    }
  }

  return result;
}

/**
 * Find potential duplicate entries in MEMORY.md
 * Uses simple word overlap to detect similar sections
 */
function findDuplicates(sections) {
  const dupes = [];

  function getKeywords(text) {
    return text.toLowerCase()
      .replace(/[^a-z0-9\s]/g, '')
      .split(/\s+/)
      .filter(w => w.length > 3);
  }

  for (let i = 0; i < sections.length; i++) {
    for (let j = i + 1; j < sections.length; j++) {
      const wordsA = new Set(getKeywords(sections[i].content.join(' ')));
      const wordsB = new Set(getKeywords(sections[j].content.join(' ')));

      const intersection = [...wordsA].filter(w => wordsB.has(w));
      const overlap = intersection.length / Math.min(wordsA.size, wordsB.size);

      if (overlap > 0.6) {
        dupes.push({
          sectionA: sections[i].title,
          sectionB: sections[j].title,
          overlap: Math.round(overlap * 100) + '%',
          sharedWords: intersection.slice(0, 10),
        });
      }
    }
  }

  return dupes;
}

/**
 * Generate memory statistics
 */
function getStats() {
  const memory = parseMemoryFile();
  const dailyLogs = parseDailyLogs();
  const patterns = parsePatterns();

  const stats = {
    memory_md: {
      lines: memory.lines,
      sections: memory.sections.length,
      over_200_lines: memory.lines > 200,
      items_per_section: memory.sections.map(s => ({
        title: s.title,
        items: s.itemCount,
        lines: s.content.length,
      })),
    },
    daily_logs: {
      count: dailyLogs.length,
      total_lines: dailyLogs.reduce((sum, l) => sum + l.lineCount, 0),
      date_range: dailyLogs.length > 0
        ? `${dailyLogs[dailyLogs.length - 1].date} to ${dailyLogs[0].date}`
        : 'none',
    },
    patterns: {
      successes: patterns.successes.length,
      failures: patterns.failures.length,
      total: patterns.successes.length + patterns.failures.length,
    },
    health: {
      memory_within_limit: memory.lines <= 200,
      has_patterns: patterns.successes.length + patterns.failures.length > 0,
      has_recent_logs: dailyLogs.length > 0,
      duplicates_found: findDuplicates(memory.sections).length,
    },
  };

  return stats;
}

/**
 * Trim MEMORY.md to 200 lines by removing least-critical content
 */
function trimMemory() {
  const memory = parseMemoryFile();
  if (memory.lines <= 200) {
    console.log(`[trim] MEMORY.md is ${memory.lines} lines (within 200 limit)`);
    return;
  }

  console.log(`[trim] MEMORY.md is ${memory.lines} lines, trimming to 200...`);

  // Strategy: keep header + first N sections that fit in 200 lines
  const lines = memory.raw.split('\n');
  const trimmed = lines.slice(0, 200);

  // Ensure we don't cut in the middle of a section
  let lastSectionEnd = 200;
  for (let i = 199; i >= 0; i--) {
    if (trimmed[i].startsWith('## ') || trimmed[i] === '---') {
      lastSectionEnd = i;
      break;
    }
  }

  const result = lines.slice(0, lastSectionEnd).join('\n');
  const trimmedNote = `\n\n---\n\n*[Trimmed to 200 lines by consolidate.cjs on ${new Date().toISOString().split('T')[0]}. Run full consolidation to reorganize.]*\n`;

  fs.writeFileSync(MEMORY_FILE, result + trimmedNote);
  console.log(`[trim] Trimmed from ${memory.lines} to ${lastSectionEnd} lines`);
}

// CLI entry point
function main() {
  const args = process.argv.slice(2);
  const command = args[0] || '--stats';

  if (!fs.existsSync(NELSON_DIR)) {
    console.log('[consolidate] No .nelson/ directory found. Run setup first.');
    process.exit(0);
  }

  switch (command) {
    case '--stats': {
      const stats = getStats();
      console.log(JSON.stringify(stats, null, 2));
      break;
    }

    case '--find-dupes': {
      const memory = parseMemoryFile();
      const dupes = findDuplicates(memory.sections);
      if (dupes.length === 0) {
        console.log('[dupes] No duplicate sections found');
      } else {
        console.log(`[dupes] Found ${dupes.length} potential duplicates:`);
        for (const dupe of dupes) {
          console.log(`  "${dupe.sectionA}" ↔ "${dupe.sectionB}" (${dupe.overlap} overlap)`);
          console.log(`    Shared words: ${dupe.sharedWords.join(', ')}`);
        }
      }
      break;
    }

    case '--prune-stale': {
      const daysBack = parseInt(args[1]) || 30;
      const dailyLogs = parseDailyLogs(Infinity);
      const cutoff = new Date();
      cutoff.setDate(cutoff.getDate() - daysBack);

      let pruned = 0;
      for (const log of dailyLogs) {
        const logDate = new Date(log.date);
        if (logDate < cutoff) {
          const filePath = path.join(DAILY_DIR, log.file);
          // Don't delete — archive by renaming
          const archivePath = filePath.replace('.md', '.archived.md');
          if (!fs.existsSync(archivePath)) {
            fs.renameSync(filePath, archivePath);
            pruned++;
          }
        }
      }
      console.log(`[prune] Archived ${pruned} daily logs older than ${daysBack} days`);
      break;
    }

    case '--trim': {
      trimMemory();
      break;
    }

    default: {
      // Full consolidation: stats + dupes + trim
      console.log('=== Nelson v5.0 Memory Consolidation ===\n');

      const stats = getStats();
      console.log(`MEMORY.md: ${stats.memory_md.lines} lines, ${stats.memory_md.sections} sections`);
      console.log(`Daily logs: ${stats.daily_logs.count} (${stats.daily_logs.date_range})`);
      console.log(`Patterns: ${stats.patterns.successes} success, ${stats.patterns.failures} failure`);
      console.log(`Duplicates: ${stats.health.duplicates_found}`);
      console.log('');

      if (stats.health.duplicates_found > 0) {
        console.log('⚠️  Duplicate sections detected — review with --find-dupes');
      }

      if (!stats.health.memory_within_limit) {
        console.log('⚠️  MEMORY.md exceeds 200 lines — trim with --trim');
      }

      if (stats.health.memory_within_limit && stats.health.duplicates_found === 0) {
        console.log('✅ Memory system healthy');
      }
    }
  }
}

main();
