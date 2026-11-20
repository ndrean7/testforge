#!/usr/bin/env node
// gap-scan: rough map of untested exports in a JS/TS codebase.
// Usage: node scripts/gap-scan.mjs <src-dir> <test-dir>
// Lists every exported function/class/const and whether any test file
// mentions its name. This is a map, not a proof: a name can appear in
// a test file and still never be asserted on. Read the tests before
// trusting the map. Exits 1 when gaps are found, 0 when none are.
import { readdirSync, readFileSync, statSync } from "node:fs";
import { join, extname } from "node:path";

const [srcDir, testDir] = process.argv.slice(2);
if (!srcDir || !testDir) {
  console.error("usage: node scripts/gap-scan.mjs <src-dir> <test-dir>");
  process.exit(2);
}

const SRC_EXTS = new Set([".js", ".mjs", ".ts", ".mts"]);

function walk(dir, out = []) {
  for (const entry of readdirSync(dir)) {
    const p = join(dir, entry);
    const st = statSync(p);
    if (st.isDirectory()) {
      if (entry === "node_modules" || entry === ".git") continue;
      walk(p, out);
    } else if (SRC_EXTS.has(extname(p))) {
      out.push(p);
    }
  }
  return out;
}

function exportedNames(source) {
  const names = new Set();
  const patterns = [
    /export\s+(?:async\s+)?function\s+([A-Za-z_$][\w$]*)/g,
    /export\s+(?:const|let|var)\s+([A-Za-z_$][\w$]*)/g,
    /export\s+class\s+([A-Za-z_$][\w$]*)/g,
    /export\s+default\s+(?:async\s+)?function\s+([A-Za-z_$][\w$]*)/g,
    /exports\.([A-Za-z_$][\w$]*)\s*=/g,
    /module\.exports\s*=\s*\{([^}]*)\}/g,
    /export\s*\{([^}]*)\}/g,
  ];
  for (const re of patterns) {
    for (const m of source.matchAll(re)) {
      const body = m[1];
      for (const part of body.split(",")) {
        const name = part.trim().split(/\s+as\s+/).pop().trim();
        if (/^[A-Za-z_$][\w$]*$/.test(name) && name !== "default") names.add(name);
      }
    }
  }
  return [...names];
}

const srcFiles = walk(srcDir);
const testFiles = walk(testDir);
const testText = testFiles.map((f) => readFileSync(f, "utf8")).join("\n");

let covered = 0;
let uncovered = [];
for (const file of srcFiles) {
  const source = readFileSync(file, "utf8");
  for (const name of exportedNames(source)) {
    const mentioned = new RegExp(`\\b${name}\\b`).test(testText);
    if (mentioned) {
      covered++;
      console.log(`COVERED    ${name}  (${file})`);
    } else {
      uncovered.push(name);
      console.log(`UNCOVERED  ${name}  (${file})`);
    }
  }
}

console.log(`\n${covered} covered, ${uncovered.length} uncovered, ${testFiles.length} test files scanned.`);
if (uncovered.length > 0) {
  console.log("Uncovered exports (check each against the gap checklist):");
  for (const name of uncovered) console.log(`  - ${name}`);
  process.exit(1);
}
