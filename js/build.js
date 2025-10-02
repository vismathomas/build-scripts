/**
 * Node build script: format -> lint -> typecheck -> unit tests + coverage -> Playwright -> complexity.
 * Free tools only. Minimal success logs. Failures dump diagnostics to console.
 *
 * Usage: node build.js [--threshold 70] [--src src] [--run-playwright-tests]
 * Env: COVERAGE_THRESHOLD
 */
import { spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, readdirSync, copyFileSync, rmSync } from "node:fs";
import { join, relative, dirname, isAbsolute } from "node:path";
import { fileURLToPath } from "node:url";

const argv = process.argv.slice(2);
const hasFlag = (flag) => argv.includes(flag);
const getArg = (flag, fallback = null) => {
  const idx = argv.indexOf(flag);
  return idx >= 0 ? argv[idx + 1] : fallback;
};

const SCRIPT_DIR = dirname(fileURLToPath(import.meta.url));
const rawRootArg = getArg("--root");
const ROOT = rawRootArg ? (isAbsolute(rawRootArg) ? rawRootArg : join(process.cwd(), rawRootArg)) : SCRIPT_DIR;

const ART_DIR = join(ROOT, "artifacts");
const REPORT_DIR = join(ART_DIR, "test-results");
mkdirSync(ART_DIR, { recursive: true });
mkdirSync(REPORT_DIR, { recursive: true });

const COVERAGE_THRESHOLD = Number(process.env.COVERAGE_THRESHOLD ?? getArg("--threshold", "70")) || 70;
const SRC_DIR = getArg("--src", "src");

const COLORS = {
  blue: (s) => "\u001b[38;5;39m" + s + "\u001b[0m",
  green: (s) => "\u001b[32m" + s + "\u001b[0m",
  red: (s) => "\u001b[31m" + s + "\u001b[0m",
  yellow: (s) => "\u001b[33m" + s + "\u001b[0m",
};

const MAX_OUTPUT_CHARS = 8000;
const softFailures = [];

const parseListArg = (flag) => {
  const raw = getArg(flag);
  if (!raw) {
    return [];
  }
  return raw
    .split(",")
    .map((segment) => segment.trim())
    .filter(Boolean);
};

const ALWAYS_IGNORE_DIRS = new Set([
  ".cache",
  ".git",
  ".idea",
  ".next",
  ".nuxt",
  ".output",
  ".pnpm",
  ".turbo",
  ".venv",
  ".vscode",
  "artifacts",
  "build",
  "coverage",
  "coverage-report",
  "coverage-reports",
  "dist",
  "logs",
  "node_modules",
  "out",
  "reports",
  "tmp",
  "temp",
]);

const COMPLEXITY_IGNORE_PATTERNS = ["**/node_modules/**", "**/dist/**", "**/build/**", "**/artifacts/**", "**/coverage/**", "**/*.min.js"];
const COMPLEXITY_PRUNE_DIRS = new Set(["dist", "node_modules", "artifacts", "coverage", "build"]);
const MAX_COMPLEXITY_PRUNE_DEPTH = 4;

const DEFAULT_SOURCE_DIRS = [
  "src",
  "app",
  "apps",
  "packages",
  "services",
  "client",
  "clients",
  "frontend",
  "backend",
  "server",
  "shared",
  "lib",
  "libs",
  "modules",
  "components",
  "scripts",
  "test",
  "tests",
  "e2e",
];

const DEFAULT_ROOT_FILE_GLOBS = ["*.{js,jsx,ts,tsx,mjs,cjs,cts,mts,json,css,scss,md,html}", "*.{yml,yaml}", "*.{cjs,mjs,cts,mts}"];

const extraIncludeDirs = parseListArg("--include-dirs");
const extraExcludeDirs = new Set(parseListArg("--exclude-dirs"));

const containsGlobPattern = (value) => /[\*?\[\]]/.test(value);

const normalizeCandidate = (candidate) => candidate.replace(/^[./]+/, "").replace(/\\/g, "/");

const resolveTargets = (candidates) => {
  const resolved = new Set();
  for (const candidate of candidates) {
    const normalized = normalizeCandidate(candidate);
    if (!normalized) {
      continue;
    }

    const topSegment = normalized.split("/")[0];
    if (ALWAYS_IGNORE_DIRS.has(topSegment)) {
      continue;
    }
    if (extraExcludeDirs.has(normalized) || extraExcludeDirs.has(topSegment)) {
      continue;
    }

    if (containsGlobPattern(normalized)) {
      resolved.add(normalized);
      continue;
    }

    const absolute = join(ROOT, normalized);
    if (existsSync(absolute)) {
      resolved.add(normalized);
    }
  }
  return Array.from(resolved);
};

const SOURCE_TARGETS = resolveTargets([...extraIncludeDirs, ...DEFAULT_SOURCE_DIRS]);
const FALLBACK_TARGETS = resolveTargets(DEFAULT_SOURCE_DIRS);
const PRETTIER_TARGETS = SOURCE_TARGETS.length ? SOURCE_TARGETS : FALLBACK_TARGETS;
const ESLINT_TARGETS = SOURCE_TARGETS.length ? SOURCE_TARGETS : FALLBACK_TARGETS;
const COMPLEXITY_TARGETS = ESLINT_TARGETS.length ? ESLINT_TARGETS : FALLBACK_TARGETS;
const shouldRunPlaywright = hasFlag("--run-playwright-tests");

const prettierTargetsWithRootGlobs = (() => {
  if (PRETTIER_TARGETS.length) {
    return Array.from(new Set([...PRETTIER_TARGETS, ...DEFAULT_ROOT_FILE_GLOBS]));
  }
  return DEFAULT_ROOT_FILE_GLOBS;
})();

const hasPrettierTargets = prettierTargetsWithRootGlobs.length > 0;
const hasEslintTargets = ESLINT_TARGETS.length > 0;

function printSection(label, value) {
  const text = (value ?? "").trim();
  if (!text) {
    return;
  }
  console.log("  " + label + ":");
  if (text.length > MAX_OUTPUT_CHARS) {
    console.log(text.slice(0, MAX_OUTPUT_CHARS));
    console.log("  ... output truncated (" + (text.length - MAX_OUTPUT_CHARS) + " more characters)");
  } else {
    console.log(text);
  }
}

function runStep(name, command, args, options = {}) {
  const { diagArgs = [], diagNote, cwd = ROOT, env = {}, allowFailure = false, diagCommand } = options;
  process.stdout.write(COLORS.blue("> " + name + "\n"));

  const result = spawnSync(command, args, {
    cwd,
    shell: process.platform === "win32",
    encoding: "utf8",
    env: { ...process.env, ...env },
  });

  if (result.status !== 0) {
    const failureColor = allowFailure ? COLORS.yellow : COLORS.red;
    const failureLabel = allowFailure ? name + " WARN (continuing)" : name + " FAILED";
    process.stdout.write(failureColor(failureLabel + "\n"));
    console.log("  Exit code: " + (result.status ?? "unknown"));
    console.log("  Command: " + [command, ...args].join(" "));
    if (cwd !== ROOT) {
      console.log("  Work dir: " + cwd);
    }
    printSection("stdout", result.stdout);
    printSection("stderr", result.stderr);

    const hasDiag = typeof diagArgs === "function" || (Array.isArray(diagArgs) && diagArgs.length > 0);
    if (hasDiag) {
      const baseArgs = args.slice();
      const finalDiagArgs = typeof diagArgs === "function" ? diagArgs(baseArgs) : [...baseArgs, ...diagArgs];
      const diagResult = spawnSync(diagCommand ?? command, finalDiagArgs, {
        cwd,
        shell: process.platform === "win32",
        encoding: "utf8",
        env: { ...process.env, ...env },
      });
      printSection("diagnostic", (diagResult.stdout ?? "") + (diagResult.stderr ?? ""));
    }

    if (diagNote) {
      console.log("  Info: " + diagNote);
    }

    if (allowFailure) {
      softFailures.push({ name, exitCode: result.status ?? 1 });
      return result;
    }

    process.exit(1);
  }

  process.stdout.write(COLORS.green(name + " OK\n"));
  return result;
}

const PLAYWRIGHT_CONFIG_REGEX = /^playwright\.config\.[cm]?js$|^playwright\.config\.[cm]?ts$/i;
const IGNORED_SCAN_DIRS = new Set(["node_modules", ".git", "dist", "artifacts", "coverage", "coverage-report", "coverage-reports", "logs", "obj", "bin", "reports"]);
const MAX_SCAN_DEPTH = 4;

function hasPlaywrightDependency(pkgJson) {
  if (!pkgJson) {
    return false;
  }
  const deps = { ...pkgJson.dependencies, ...pkgJson.devDependencies };
  if (deps?.["@playwright/test"]) {
    return true;
  }
  const scripts = Object.keys(pkgJson.scripts ?? {});
  return scripts.some((name) => name.toLowerCase().includes("playwright") || name.startsWith("test:e2e"));
}

function enumDirectories(base, depth = 0, acc = []) {
  if (depth > MAX_SCAN_DEPTH) {
    return acc;
  }
  let entries;
  try {
    entries = readdirSync(base, { withFileTypes: true });
  } catch {
    return acc;
  }

  acc.push({ dir: base, entries });

  for (const entry of entries) {
    if (!entry.isDirectory()) {
      continue;
    }
    if (IGNORED_SCAN_DIRS.has(entry.name)) {
      continue;
    }
    enumDirectories(join(base, entry.name), depth + 1, acc);
  }

  return acc;
}

function findPlaywrightProjects() {
  const projects = [];
  const directories = enumDirectories(ROOT);
  for (const { dir, entries } of directories) {
    const packageEntry = entries.find((entry) => entry.isFile() && entry.name === "package.json");
    if (!packageEntry) {
      continue;
    }

    const packagePath = join(dir, packageEntry.name);
    const packageJson = readJSON(packagePath);
    if (!hasPlaywrightDependency(packageJson)) {
      continue;
    }

    const configEntry = entries.find((entry) => entry.isFile() && PLAYWRIGHT_CONFIG_REGEX.test(entry.name));
    if (!configEntry) {
      continue;
    }

    projects.push({ cwd: dir, configPath: join(dir, configEntry.name) });
  }

  return projects;
}

function hasAny(paths) {
  return paths.some((path) => existsSync(join(ROOT, path)));
}

function readJSON(pathname) {
  try {
    return JSON.parse(readFileSync(pathname, "utf8"));
  } catch {
    return null;
  }
}

const pkg = existsSync(join(ROOT, "package.json")) ? readJSON(join(ROOT, "package.json")) : null;
const defaultTestScript = pkg?.scripts?.test ?? "";
const unitScriptName = pkg?.scripts?.["test:unit"] ? "test:unit" : defaultTestScript ? "test" : null;
const unitScriptCommand = unitScriptName ? (pkg?.scripts?.[unitScriptName] ?? "") : "";

const hasTsConfig = existsSync(join(ROOT, "tsconfig.json"));
const hasEslintConfig = hasAny(["eslint.config.js", "eslint.config.mjs", "eslint.config.cjs", ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json", ".eslintrc"]);
const usesVitest = /\bvitest\b/.test(unitScriptCommand) || pkg?.devDependencies?.vitest || pkg?.dependencies?.vitest;
const usesJest = /\bjest\b/.test(unitScriptCommand) || pkg?.devDependencies?.jest || pkg?.dependencies?.jest;

function npxBin() {
  return process.platform === "win32" ? "npx.cmd" : "npx";
}

runStep("Env info", process.platform === "win32" ? "node.exe" : "node", ["-v"]);
runStep("NPM info", process.platform === "win32" ? "npm.cmd" : "npm", ["-v"]);

if (hasPrettierTargets) {
  runStep("Format", npxBin(), ["-y", "prettier", ...prettierTargetsWithRootGlobs, "--write", "--log-level", "warn", "--no-error-on-unmatched-pattern"], {
    diagArgs: ["--log-level", "debug"],
  });
} else {
  console.log(COLORS.yellow("Format SKIP: no eligible source targets"));
}

if (hasEslintConfig && hasEslintTargets) {
  runStep("Lint", npxBin(), ["-y", "eslint", ...ESLINT_TARGETS, "--max-warnings", "0", "-f", "stylish", "--fix", "--cache"], {
    allowFailure: true,
    diagArgs: (baseArgs) => {
      const filtered = baseArgs.filter((arg) => arg !== "--fix");
      return [...filtered, "--format", "json", "--output-file", join(REPORT_DIR, "eslint.json"), "--fix-dry-run"];
    },
    diagNote: "ESLint JSON written to " + join(REPORT_DIR, "eslint.json"),
  });
} else if (hasEslintConfig) {
  console.log(COLORS.yellow("Lint SKIP: no eligible source targets for ESLint"));
} else {
  console.log(COLORS.yellow("Lint SKIP: no ESLint config found"));
}

if (hasTsConfig) {
  runStep("TypeCheck", npxBin(), ["-y", "tsc", "-p", "tsconfig.json", "--noEmit"], {
    diagArgs: ["--listFiles", "--extendedDiagnostics"],
  });
} else {
  console.log(COLORS.yellow("TypeCheck SKIP: no tsconfig.json"));
}

let coverageConsumer = "none";
if (usesVitest) {
  runStep("Unit Tests (vitest)", npxBin(), ["-y", "vitest", "run", "--coverage", "--reporter=dot"], {
    diagArgs: ["--reporter=verbose"],
  });
  coverageConsumer = "vitest";
} else if (usesJest) {
  runStep("Unit Tests (jest)", npxBin(), ["-y", "jest", "--coverage", "--runInBand"], {
    diagArgs: ["--verbose"],
  });
  coverageConsumer = "jest";
} else if (unitScriptName) {
  runStep("Unit Tests (" + unitScriptName + ")", npxBin(), ["-y", "c8", "--reporter=text", "--reporter=cobertura", "npm", "run", unitScriptName, "--silent"], {
    diagArgs: ["--reporter=html", "--exclude=**/*.test.*"],
  });
  coverageConsumer = "c8";
} else {
  console.log(COLORS.yellow("Unit Tests SKIP: no supported test runner configured"));
}

const playwrightProjects = shouldRunPlaywright ? findPlaywrightProjects() : [];
if (!shouldRunPlaywright) {
  console.log(COLORS.yellow("Playwright SKIP: add --run-playwright-tests to enable Playwright execution"));
} else if (playwrightProjects.length) {
  for (const project of playwrightProjects) {
    const relConfig = relative(ROOT, project.configPath);
    const safeId = relConfig.replace(/[\/:\s]+/g, "-");
    const artifactName = "playwright-" + safeId + ".json";
    const reportPath = join(REPORT_DIR, artifactName);
    const env = { PLAYWRIGHT_JSON_OUTPUT_NAME: artifactName };
    const result = runStep("Playwright (" + relConfig + ")", npxBin(), ["-y", "playwright", "test", "--config", project.configPath, "--reporter=line", "--reporter=json"], {
      allowFailure: true,
      cwd: project.cwd,
      env,
    });

    const defaultReport = join(project.cwd, "playwright-report", artifactName);
    if (existsSync(defaultReport)) {
      try {
        copyFileSync(defaultReport, reportPath);
        console.log("  Playwright report copied to " + reportPath);
      } catch (error) {
        console.log(COLORS.yellow("  Failed to copy Playwright report: " + (error instanceof Error ? error.message : String(error))));
      }
    } else if (result.status === 0) {
      console.log(COLORS.yellow("  Playwright report not found at " + defaultReport));
    }
  }
} else {
  console.log(COLORS.yellow("Playwright SKIP: no Playwright projects detected"));
}

function findCoverageSummary() {
  const candidates = [join(ROOT, "coverage", "coverage-summary.json"), join(ROOT, "coverage", "v8", "coverage-summary.json"), join(ART_DIR, "coverage", "coverage-summary.json")];
  for (const candidate of candidates) {
    if (existsSync(candidate)) {
      return candidate;
    }
  }
  return null;
}

function buildComplexityArgs(format) {
  const args = ["-y", "complexity-report", "-f", format];
  for (const target of COMPLEXITY_TARGETS) {
    args.push(target);
  }
  for (const pattern of COMPLEXITY_IGNORE_PATTERNS) {
    args.push("--ignore", pattern);
  }
  return args;
}

function pruneComplexityArtifacts(basePath, depth = 0) {
  if (depth > MAX_COMPLEXITY_PRUNE_DEPTH || !existsSync(basePath)) {
    return;
  }

  let entries;
  try {
    entries = readdirSync(basePath, { withFileTypes: true });
  } catch {
    return;
  }

  for (const entry of entries) {
    if (!entry.isDirectory()) {
      continue;
    }

    const entryPath = join(basePath, entry.name);
    if (COMPLEXITY_PRUNE_DIRS.has(entry.name)) {
      try {
        rmSync(entryPath, { recursive: true, force: true });
      } catch {
        // ignore cleanup failures
      }
      continue;
    }

    pruneComplexityArtifacts(entryPath, depth + 1);
  }
}

function pruneComplexitySources() {
  for (const target of COMPLEXITY_TARGETS) {
    pruneComplexityArtifacts(join(ROOT, target));
  }
}

if (coverageConsumer !== "none") {
  const summaryPath = findCoverageSummary();
  if (summaryPath) {
    const data = readJSON(summaryPath) ?? {};
    const metrics = ["lines", "statements", "branches", "functions"].map((metric) => {
      const section = data.total?.[metric] ?? {};
      return {
        metric,
        pct: Number(section.pct ?? 0),
        covered: Number(section.covered ?? 0),
        total: Number(section.total ?? 0),
      };
    });

    const linePct = metrics.find((item) => item.metric === "lines")?.pct ?? 0;

    console.log("Coverage metrics (total):");
    for (const { metric, pct, covered, total } of metrics) {
      const status = pct >= COVERAGE_THRESHOLD ? COLORS.green("OK") : COLORS.yellow("WARN");
      console.log("  " + metric.padEnd(10) + " " + pct.toFixed(2).padStart(6) + "% (" + covered + "/" + total + ") " + status);
    }

    const analytics = {
      generatedAt: new Date().toISOString(),
      threshold: COVERAGE_THRESHOLD,
      summaryFile: summaryPath,
      totals: metrics,
      consumer: coverageConsumer,
    };
    console.log("Coverage analytics JSON:");
    console.log(JSON.stringify(analytics, null, 2));

    if (linePct < COVERAGE_THRESHOLD) {
      console.log(COLORS.red("COVERAGE FAIL: " + linePct.toFixed(2) + "% < " + COVERAGE_THRESHOLD + "%"));
      console.log("  Summary: " + summaryPath);
      process.exit(1);
    } else {
      console.log(COLORS.green("COVERAGE OK: " + linePct.toFixed(2) + "% >= " + COVERAGE_THRESHOLD + "%"));
    }
  } else {
    console.log(COLORS.yellow("Coverage summary not found. Threshold check skip."));
  }
}

if (COMPLEXITY_TARGETS.length) {
  pruneComplexitySources();
  const complexityArgs = buildComplexityArgs("json");
  const result = runStep("Complexity", npxBin(), complexityArgs, {
    allowFailure: true,
  });

  if (result.status === 0) {
    const output = (result.stdout ?? "").trim();
    if (output) {
      console.log("Complexity report JSON:");
      console.log(output);
    } else {
      console.log("Complexity report returned no data");
    }
  }
} else {
  console.log(COLORS.yellow("Complexity SKIP: no eligible complexity targets"));
}

if (softFailures.length) {
  const names = softFailures.map((item) => item.name).join(", ");
  console.log(COLORS.yellow("Build completed with issues: " + names));
} else {
  console.log(COLORS.green("All steps OK"));
}
console.log("Artifacts:");
console.log("  " + REPORT_DIR + "                   # additional reports (ESLint, Playwright, etc.)");
console.log("  (Coverage analytics printed above; no coverage files emitted)");
console.log("  (Complexity analytics printed above; no complexity files emitted)");
