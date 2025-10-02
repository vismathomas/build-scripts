# JavaScript/TypeScript Build Scripts Documentation

> **Professional build automation for Node.js projects with comprehensive quality gates**

## Overview

The JavaScript/TypeScript build scripts provide a complete, production-ready build pipeline for Node.js projects including:
- Code formatting with Prettier
- Linting with ESLint (flat config)
- TypeScript type checking
- Unit testing with coverage (Vitest, Jest, or c8)
- E2E testing with Playwright (optional)
- Code complexity analysis
- Smart project detection and configuration

## Features

✅ **Auto-Detection** - Automatically detects project structure and tools  
✅ **Zero Config** - Works out of the box with sensible defaults  
✅ **Framework Agnostic** - Supports React, Vue, Svelte, and vanilla JS/TS  
✅ **Test Framework Flexible** - Works with Vitest, Jest, or generic test runners  
✅ **Monorepo Ready** - Handles multi-package workspaces  
✅ **Coverage Enforcement** - Configurable coverage thresholds  
✅ **CI/CD Optimized** - JSON output for integration with pipelines  
✅ **Performance Aware** - Complexity analysis and optimization hints

## Files

```
js/
├── build.js                       # Main build orchestrator
├── package.json                   # Template dependencies
├── eslint.config.js               # ESLint flat configuration
├── tsconfig.json                  # TypeScript project references
├── tsconfig.app.json              # Application TypeScript config
├── tsconfig.node.json             # Node/tooling TypeScript config
└── vite.config.ts                 # Vite bundler configuration (example)
```

## Quick Start

### 1. Copy Build Script to Your Project

```bash
# Copy the build script
cp js/build.js your-project/scripts/build/

# Or place in project root
cp js/build.js your-project/
```

### 2. Install Required Dependencies (if not present)

The script uses npx to run tools, but for optimal performance, install them:

```bash
npm install --save-dev \
  prettier \
  eslint \
  typescript \
  vitest @vitest/coverage-v8 \
  @playwright/test \
  complexity-report
```

### 3. Run the Build

```bash
# From project root
node build.js

# Or from scripts directory
node scripts/build/build.js --root ../..
```

## Configuration

### Auto-Detection

The build script automatically detects:

1. **Project Type**: Package.json presence and structure
2. **Test Framework**: Vitest, Jest, or generic test script
3. **TypeScript**: Presence of tsconfig.json
4. **ESLint**: eslint.config.js or .eslintrc files
5. **Playwright**: Playwright projects in workspace
6. **Source Directories**: Common patterns (src, app, packages, etc.)

### Command Line Options

```bash
node build.js [options]
```

#### Coverage Configuration

- `--threshold <number>` - Set coverage threshold (default: 70)
  ```bash
  node build.js --threshold 85
  ```

- Environment variable override:
  ```bash
  export COVERAGE_THRESHOLD=80
  node build.js
  ```

#### Project Structure

- `--root <path>` - Specify project root directory
  ```bash
  node build.js --root /path/to/project
  ```

- `--src <dir>` - Specify source directory (default: "src")
  ```bash
  node build.js --src packages
  ```

#### Directory Inclusion/Exclusion

- `--include-dirs <dirs>` - Comma-separated list of directories to include
  ```bash
  node build.js --include-dirs "apps,packages,libs"
  ```

- `--exclude-dirs <dirs>` - Comma-separated list of directories to exclude
  ```bash
  node build.js --exclude-dirs "legacy,deprecated,vendor"
  ```

#### Test Execution

- `--run-playwright-tests` - Execute Playwright end-to-end tests
  ```bash
  node build.js --run-playwright-tests
  ```

- `--skip-tests` - Skip all test execution
  ```bash
  node build.js --skip-tests
  ```

### Configuration Files

#### package.json

The script respects these package.json configurations:

```json
{
  "scripts": {
    "test": "vitest run",
    "test:unit": "vitest run --coverage",
    "test:e2e": "playwright test"
  },
  "devDependencies": {
    "vitest": "^1.0.0",
    "@vitest/coverage-v8": "^1.0.0",
    "playwright": "^1.40.0"
  }
}
```

**Recommended package.json scripts**:
```json
{
  "scripts": {
    "build": "node scripts/build/build.js",
    "build:verbose": "node scripts/build/build.js --verbose",
    "build:ci": "node scripts/build/build.js --run-playwright-tests",
    "build:quick": "node scripts/build/build.js --skip-tests",
    "build:strict": "node scripts/build/build.js --threshold 90 --run-playwright-tests"
  }
}
```

#### ESLint Configuration

**Flat Config** (eslint.config.js) - Recommended:
```javascript
import js from "@eslint/js";
import globals from "globals";
import tseslint from "typescript-eslint";

export default tseslint.config([
  { ignores: ["dist", "node_modules", "coverage"] },
  {
    files: ["**/*.{ts,tsx,js,jsx}"],
    extends: [
      js.configs.recommended,
      ...tseslint.configs.recommended
    ],
    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.node
      }
    }
  }
]);
```

**Legacy Config** (.eslintrc.js) - Also supported:
```javascript
module.exports = {
  extends: ["eslint:recommended"],
  env: {
    browser: true,
    es2021: true,
    node: true
  }
};
```

#### TypeScript Configuration

**Project References** (recommended for monorepos):
```json
// tsconfig.json
{
  "files": [],
  "references": [
    { "path": "./tsconfig.app.json" },
    { "path": "./tsconfig.node.json" }
  ]
}
```

**Application Config**:
```json
// tsconfig.app.json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "lib": ["ES2020", "DOM"],
    "jsx": "react-jsx",
    "strict": true,
    "moduleResolution": "bundler"
  },
  "include": ["src"]
}
```

#### Playwright Configuration

```typescript
// playwright.config.ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  reporter: [
    ['line'],
    ['json', { outputFile: 'playwright-report.json' }]
  ],
  use: {
    baseURL: 'http://localhost:3000'
  }
});
```

## Build Pipeline Stages

### Stage 1: Environment Check

**Actions**:
- Verify Node.js version
- Check npm availability
- Display environment info

**Output**:
```
> Env info
Node.js version: v20.10.0
✓ Env info OK

> NPM info
npm version: 10.2.5
✓ NPM info OK
```

### Stage 2: Code Formatting

**Tool**: Prettier

**Actions**:
- Auto-detect source directories
- Format .js, .jsx, .ts, .tsx, .json, .css, .md files
- Apply formatting in-place with `--write`
- Skip if no eligible targets found

**Output**:
```
> Format
✓ Format OK
```

**Targets**: Automatically includes:
- Detected source directories (src, app, packages, etc.)
- Root-level config files
- Can be customized with `--include-dirs`

**Skip Conditions**:
- No eligible source targets found
- All ignored by .prettierignore

### Stage 3: Code Linting

**Tool**: ESLint

**Actions**:
- Auto-detect ESLint configuration
- Lint all source directories
- Auto-fix issues with `--fix`
- Enforce zero warnings with `--max-warnings 0`
- Generate JSON report for CI/CD

**Output**:
```
> Lint
Lint WARN (continuing)
Exit code: 1
diagnostic:
  [ESLint JSON written to artifacts/test-results/eslint.json]
```

**Failure Handling**:
- Linting failures are soft failures (build continues)
- Full diagnostic output generated
- JSON report saved to `artifacts/test-results/eslint.json`

**Skip Conditions**:
- No ESLint config found
- No eligible source targets

### Stage 4: Type Checking

**Tool**: TypeScript Compiler (tsc)

**Actions**:
- Check for tsconfig.json
- Run `tsc --noEmit` (no code generation)
- Validate all type definitions
- Report type errors

**Output**:
```
> TypeCheck
✓ TypeCheck OK
```

**Failure Handling**:
- Hard failure (stops build)
- Extended diagnostics on error
- Lists all type violations

**Skip Conditions**:
- No tsconfig.json found

### Stage 5: Unit Tests

**Tools**: Auto-detected
- Vitest (preferred)
- Jest
- Generic test runner with c8 coverage

**Actions**:
- Detect test framework from package.json
- Run tests with coverage collection
- Generate coverage reports (Cobertura XML, HTML, Text)
- Save to `coverage/` directory

**Output (Vitest)**:
```
> Unit Tests (vitest)
✓ Unit Tests (vitest) OK
```

**Output (Jest)**:
```
> Unit Tests (jest)
✓ Unit Tests (jest) OK
```

**Output (Generic + c8)**:
```
> Unit Tests (test:unit)
✓ Unit Tests (test:unit) OK
```

**Coverage Formats**:
- Cobertura XML: For CI/CD integration
- HTML: For human review
- Text: Console output

**Skip Conditions**:
- No test script configured in package.json
- `--skip-tests` flag provided

### Stage 6: Playwright E2E Tests

**Tool**: Playwright

**Actions**:
- Auto-detect Playwright projects in workspace
- Run tests for each detected project
- Generate JSON reports
- Copy reports to `artifacts/test-results/`

**Output**:
```
> Playwright (playwright.config.ts)
✓ Playwright (playwright.config.ts) OK
  Playwright report copied to artifacts/test-results/playwright-playwright.config.ts.json
```

**Failure Handling**:
- Soft failure (build continues)
- Individual project failures reported
- Reports saved even on failure

**Skip Conditions**:
- `--run-playwright-tests` not specified (default)
- No Playwright projects detected

**Manual Enable**:
```bash
node build.js --run-playwright-tests
```

### Stage 7: Coverage Validation

**Actions**:
- Locate coverage summary JSON
- Parse coverage metrics (lines, statements, branches, functions)
- Compare line coverage against threshold
- Display detailed metrics
- Fail if below threshold

**Output (Success)**:
```
Coverage metrics (total):
  lines      78.25% (312/399) OK
  statements 77.89% (310/398) OK
  branches   68.75% (55/80)   WARN
  functions  82.35% (28/34)   OK

COVERAGE OK: 78.25% >= 70%
```

**Output (Failure)**:
```
Coverage metrics (total):
  lines      65.12% (260/399) WARN
  statements 64.82% (258/398) WARN
  branches   58.75% (47/80)   WARN
  functions  70.59% (24/34)   OK

COVERAGE FAIL: 65.12% < 70%
  Summary: coverage/coverage-summary.json
```

**Analytics Output**:
```json
{
  "generatedAt": "2025-10-02T10:30:00.000Z",
  "threshold": 70,
  "summaryFile": "coverage/coverage-summary.json",
  "totals": [
    { "metric": "lines", "pct": 78.25, "covered": 312, "total": 399 },
    { "metric": "statements", "pct": 77.89, "covered": 310, "total": 398 },
    { "metric": "branches", "pct": 68.75, "covered": 55, "total": 80 },
    { "metric": "functions", "pct": 82.35, "covered": 28, "total": 34 }
  ],
  "consumer": "vitest"
}
```

### Stage 8: Complexity Analysis

**Tool**: complexity-report

**Actions**:
- Analyze code complexity metrics
- Prune node_modules from source directories
- Generate JSON complexity report
- Output to console (no file artifacts)

**Output**:
```
> Complexity
✓ Complexity OK
Complexity report JSON:
{
  "reports": [
    {
      "path": "src/components/Widget.tsx",
      "complexity": {
        "cyclomatic": 5,
        "halstead": {...}
      }
    }
  ]
}
```

**Metrics Analyzed**:
- Cyclomatic complexity
- Halstead metrics
- Lines of code
- Function/module complexity

**Skip Conditions**:
- No eligible complexity targets

### Stage 9: Build Summary

**Actions**:
- List all soft failures (warnings)
- Display artifact locations
- Show coverage and complexity summaries

**Output (All OK)**:
```
All steps OK
Artifacts:
  artifacts/test-results/           # additional reports (ESLint, Playwright, etc.)
  (Coverage analytics printed above; no coverage files emitted)
  (Complexity analytics printed above; no complexity files emitted)
```

**Output (With Issues)**:
```
Build completed with issues: Lint, Playwright (tests/e2e/app.spec.ts)
Artifacts:
  artifacts/test-results/           # additional reports
```

## Artifacts

```
artifacts/
└── test-results/
    ├── eslint.json                # ESLint results
    └── playwright-*.json          # Playwright test results

coverage/                          # Generated by test framework
├── coverage-summary.json          # Coverage metrics
├── coverage-final.json            # Detailed coverage data
├── cobertura-coverage.xml         # For CI/CD
└── index.html                     # HTML coverage report
```

### `.gitignore` Recommendations

```gitignore
# Build artifacts
artifacts/
coverage/
dist/
build/

# Test results
test-results/
playwright-report/
.playwright/

# Dependencies
node_modules/

# Logs
*.log
npm-debug.log*
```

## CI/CD Integration

### GitHub Actions

```yaml
name: JavaScript Build

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '20'
        cache: 'npm'
    
    - name: Install Dependencies
      run: npm ci
    
    - name: Run Build Pipeline
      run: node scripts/build/build.js --run-playwright-tests --threshold 80
    
    - name: Upload Coverage
      uses: codecov/codecov-action@v4
      with:
        files: ./coverage/cobertura-coverage.xml
        fail_ci_if_error: true
    
    - name: Upload Artifacts
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: build-artifacts
        path: |
          artifacts/
          coverage/
```

### Azure DevOps

```yaml
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

steps:
- task: NodeTool@0
  inputs:
    versionSpec: '20.x'

- script: npm ci
  displayName: 'Install Dependencies'

- script: node scripts/build/build.js --run-playwright-tests
  displayName: 'Run Build Pipeline'

- task: PublishCodeCoverageResults@2
  inputs:
    codeCoverageTool: 'Cobertura'
    summaryFileLocation: 'coverage/cobertura-coverage.xml'

- task: PublishTestResults@2
  condition: always()
  inputs:
    testResultsFiles: 'artifacts/test-results/*.json'
```

## Troubleshooting

### Common Issues

#### Issue: "No eligible source targets"

**Cause**: Build script cannot find source directories

**Solution**:
```bash
# Explicitly specify source directories
node build.js --include-dirs "src,lib,packages"

# Or check your directory structure
ls -la
```

#### Issue: "Coverage summary not found"

**Cause**: Test framework didn't generate coverage

**Solution**:
```bash
# Verify coverage is enabled in test script
cat package.json | grep coverage

# Run tests manually to debug
npm run test -- --coverage

# Check for coverage output
ls -la coverage/
```

#### Issue: "Playwright SKIP: no Playwright projects detected"

**Cause**: No playwright.config.js/ts found

**Solution**:
```bash
# Add Playwright configuration
npm init playwright@latest

# Or explicitly run Playwright
npx playwright test
```

#### Issue: "TypeCheck FAILED"

**Cause**: TypeScript errors in codebase

**Solution**:
```bash
# Run tsc directly to see all errors
npx tsc --noEmit

# Check tsconfig.json configuration
cat tsconfig.json
```

### Debugging

**Enable Extended Output**:
```bash
# The script doesn't have a --verbose flag, but you can:

# Run stages individually
npx prettier . --check
npx eslint . --max-warnings 0
npx tsc --noEmit
npm test

# Check environment
node --version
npm --version
which node
which npm
```

**Check Configuration Detection**:
```bash
# Verify files exist
ls -la tsconfig.json eslint.config.js package.json

# Check package.json scripts
cat package.json | jq '.scripts'

# Verify test framework
cat package.json | jq '.devDependencies | keys[]' | grep -E "vitest|jest|playwright"
```

## Best Practices

1. **Version Control**: Commit `package.json`, ignore `node_modules/`, `coverage/`, `artifacts/`
2. **Consistent Dependencies**: Use `npm ci` in CI/CD for reproducible builds
3. **Coverage Goals**: Start at 70%, increase gradually to 80-90%
4. **Incremental Adoption**: Add stages progressively (format → lint → test)
5. **Regular Updates**: Keep dependencies and build scripts current
6. **Documentation**: Document custom configuration in project README
7. **Performance**: Use `--skip-tests` for quick format/lint checks
8. **CI/CD**: Always run full pipeline with `--run-playwright-tests`

## Customization

### Adding Custom Stages

Modify `build.js` to add custom stages:

```javascript
// Add after complexity analysis
if (hasCustomCheck) {
  runStep('Custom Security Scan', npxBin(), ['-y', 'npm-audit', '--audit-level', 'high'], {
    allowFailure: true
  });
}
```

### Custom Coverage Thresholds per Environment

```javascript
// In build.js or wrapper script
const threshold = process.env.CI === 'true' ? 80 : 70;
process.env.COVERAGE_THRESHOLD = threshold.toString();
```

### Integration with Monorepo Tools

```bash
# Turborepo
node scripts/build/build.js --root packages/app

# Nx
node scripts/build/build.js --root apps/web

# Lerna
node scripts/build/build.js --include-dirs "packages/*"
```

## Support

- **Main Documentation**: [Root README](../README.md)
- **GitHub Issues**: [Report Issues](https://github.com/vismathomas/build-scripts/issues)
- **Copilot Guide**: [AI Integration](../.github/instructions/build-scripts.md)

---

**Version**: 1.0.0  
**Last Updated**: October 2, 2025  
**Maintained By**: Visma Software
