# Enterprise Build Scripts Collection

> **Professional, production-ready build scripts for .NET, JavaScript/TypeScript, and Python projects**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](CHANGELOG.md)

## Overview

This repository provides a comprehensive, battle-tested collection of build scripts designed for enterprise-level software projects. These scripts are **production-ready**, **framework-agnostic**, and can be dropped into any project with minimal configuration.

### Key Features

✅ **Enterprise-Ready** - Battle-tested in production environments  
✅ **Zero-Configuration Start** - Works out of the box with sensible defaults  
✅ **Highly Configurable** - Customize every aspect via configuration files  
✅ **CI/CD Optimized** - Designed for GitHub Actions, Azure DevOps, GitLab CI  
✅ **Comprehensive Quality Gates** - Formatting, linting, testing, coverage, security  
✅ **Verbose & Quiet Modes** - Detailed diagnostics or clean output as needed  
✅ **Agent-Friendly** - Optimized for AI coding assistants (GitHub Copilot, Claude, etc.)  
✅ **Multi-Platform** - Windows (PowerShell/Batch) and Unix (Bash) support

## Quick Start

### Prerequisites

Choose the technology stack you're working with:

#### For .NET (C#/F#)
- **.NET SDK 6.0+** ([Download](https://dotnet.microsoft.com/download))
- **dotnet-reportgenerator-globaltool** (auto-installed by scripts)

#### For JavaScript/TypeScript
- **Node.js 18+** ([Download](https://nodejs.org/))
- **npm 9+** (included with Node.js)

#### For Python
- **Python 3.10+** ([Download](https://www.python.org/downloads/))
- **uv** (recommended) or **pip** for dependency management

### Installation

#### Option 1: Direct Copy (Recommended for Existing Projects)

```bash
# Copy only the scripts you need
cp -r cs/ your-project/scripts/build/
# OR
cp -r js/ your-project/scripts/build/
# OR
cp -r python/ your-project/scripts/build/
```

#### Option 2: Git Submodule (For Shared Updates)

```bash
cd your-project
git submodule add https://github.com/vismathomas/build-scripts scripts/build-templates
```

#### Option 3: Download as ZIP

Download the [latest release](https://github.com/vismathomas/build-scripts/releases) and extract to your project.

## Usage

### .NET Projects

#### Basic Usage

```batch
cd your-project
.\scripts\build\build-full.bat
```

#### Advanced Options

```batch
# Run with verbose output
.\build-full.bat --verbose

# Skip specific stages
.\build-full.bat --skip-tests --skip-coverage-report

# Frontend + Backend
.\build-full.bat --frontend

# Frontend only
.\build-full.bat --frontend-only
```

#### Configuration

Create a `build.config.bat` in your project root (optional):

```batch
@echo off
REM Project-specific build configuration

REM Solution and filter files
set "SOLUTION=YourProject.sln"
set "BUILD_FILTER=YourProject.Build.slnf"

REM Coverage threshold (percentage)
set "MIN_COVERAGE=75"

REM Test timeout threshold (milliseconds)
set "TEST_TIMEOUT_THRESHOLD=10000"

REM Frontend build script (if applicable)
set "FRONTEND_SCRIPT=%~dp0frontend-build.bat"
```

See [C# Build Scripts Documentation](cs/README.md) for detailed configuration options.

### JavaScript/TypeScript Projects

#### Using npm Scripts (Recommended)

Add these scripts to your `package.json`:

```json
{
  "scripts": {
    "build:full": "node build.js",
    "build:with-e2e": "node build.js --run-playwright-tests",
    "build:ci": "node build.js --run-playwright-tests --threshold 80"
  }
}
```

Then run:
```bash
npm run build:full              # Full build pipeline
npm run build:with-e2e          # Include E2E tests
npm run build:ci                # CI build with stricter coverage
```

#### Direct Command Line Usage

```bash
cd your-project
node scripts/build/build.js
```

#### Advanced Options

```bash
# Set coverage threshold
node build.js --threshold 80

# Specify source directory
node build.js --src src

# Run Playwright tests
node build.js --run-playwright-tests

# Specify project root
node build.js --root /path/to/project

# Include/exclude specific directories
node build.js --include-dirs "apps,packages" --exclude-dirs "legacy,deprecated"
```

#### Configuration

The build script auto-detects configuration from:
- `package.json` - Dependencies and scripts
- `tsconfig.json` - TypeScript configuration
- `eslint.config.js` - ESLint settings
- `playwright.config.js` - Playwright test configuration

Environment variables:
```bash
export COVERAGE_THRESHOLD=80
node build.js
```

See [JavaScript Build Scripts Documentation](js/README.md) for detailed configuration.

### Python Projects

#### Using uvx Directly from GitHub (Easiest)

No installation needed! Run the build script directly:

```bash
# Install uv first (one-time)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Run build script directly from GitHub
uvx --from git+https://github.com/vismathomas/build-scripts python python/build.py

# With options
uvx --from git+https://github.com/vismathomas/build-scripts python python/build.py --verbose
uvx --from git+https://github.com/vismathomas/build-scripts python python/build.py --fix
```

#### Using uv with Downloaded Script

```bash
# Download the script
curl -o build.py https://raw.githubusercontent.com/vismathomas/build-scripts/main/python/build.py

# Run with uv (automatic environment management)
uv run build.py

# With verbose output
uv run build.py --verbose

# Auto-fix issues
uv run build.py --fix
```

#### Traditional Python

```bash
cd your-project
uv run scripts/build/build.py
```

#### Dependencies

Add these build tools to your `pyproject.toml`:

```toml
[dependency-groups]
dev = [
    "uv>=0.1.0",        # Fast package manager
    "ruff>=0.13.1",     # Linter and formatter
    "mypy>=1.18.2",     # Type checker
    "pytest>=8.4.2",    # Test framework
    "pytest-cov>=7.0.0", # Coverage plugin
]
```

Then install:
```bash
uv sync  # With uv (recommended)
# OR
pip install -e ".[dev]"  # With pip
```

#### Advanced Options

```bash
# Verbose output
uv run build.py --verbose

# Auto-fix formatting and linting
uv run build.py --fix

# Clean artifacts
uv run build.py --clean
```

#### Configuration

Create a `pyproject.toml` configuration (recommended):

```toml
[tool.build]
min_coverage = 75
test_timeout = 10

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
addopts = [
    "--cov=your_package",
    "--cov-report=term-missing",
    "--cov-report=html",
    "--cov-fail-under=75",
]

[tool.ruff]
line-length = 88
target-version = "py310"

[tool.mypy]
python_version = "3.10"
warn_return_any = true
```

See [Python Build Scripts Documentation](python/README.md) for detailed configuration.

## Build Pipeline Stages

All build scripts follow a consistent multi-stage pipeline:

### Stage 1: Initialization
- Verify required tools and dependencies
- Create artifact directories
- Load configuration

### Stage 2: Code Quality
- **Format** - Auto-format code to standards
- **Lint** - Check for code quality issues
- **Type Check** - Verify type safety (TypeScript, Python type hints)

### Stage 3: Validation
- **Security Check** - Scan for security vulnerabilities

### Stage 4: Testing
- **Unit Tests** - Fast, isolated tests with mocking
- **Integration Tests** - Full system integration tests
- **E2E Tests** - End-to-end browser tests (Playwright)
- **Coverage Analysis** - Ensure minimum code coverage

### Stage 5: Reporting
- **Coverage Reports** - HTML, XML, and text summaries
- **Test Reports** - JSON output for CI/CD integration
- **Complexity Analysis** - Code complexity metrics
- **Performance Analysis** - Slow test detection

### Stage 6: Finalization
- **Artifact Collection** - Gather all reports and outputs
- **Summary Display** - Print build results
- **Exit Code Management** - Proper failure signaling for CI/CD

## Directory Structure

```
build-scripts/
├── README.md                          # This file
├── LICENSE                            # MIT License
├── CONTRIBUTING.md                    # Contribution guidelines
├── CHANGELOG.md                       # Version history
├── .github/
│   ├── instructions/
│   │   └── build-scripts.md           # Instructions for AI assistants
│   └── workflows/
│       ├── ci-dotnet.yml              # CI workflow examples
│       ├── ci-javascript.yml
│       └── ci-python.yml
├── cs/                                # .NET/C# build scripts
│   ├── README.md                      # Detailed C# documentation
│   ├── build-full.bat                 # Main orchestration script
│   ├── build.config.example.bat       # Configuration template
│   └── scripts/
│       └── build/
│           ├── init.bat               # Initialization
│           ├── format.bat             # Code formatting
│           ├── build-sln.bat          # Solution compilation
│           ├── run-tests.bat          # Test execution
│           ├── generate-coverage-report.bat
│           ├── validate-coverage.bat  # Coverage threshold check
│           ├── finalize.bat           # Cleanup and summary
│           └── analyze-slow-tests.ps1 # Performance analysis
├── js/                                # JavaScript/TypeScript scripts
│   ├── README.md                      # Detailed JS/TS documentation
│   ├── build.js                       # Main build orchestrator
│   ├── package.json                   # Dependencies (template)
│   ├── eslint.config.js               # ESLint configuration
│   ├── tsconfig.json                  # TypeScript configuration
│   ├── tsconfig.app.json              # App-specific TS config
│   ├── tsconfig.node.json             # Node-specific TS config
│   └── vite.config.ts                 # Vite bundler configuration
└── python/                            # Python build scripts
    ├── README.md                      # Detailed Python documentation
    ├── build.py                       # Main build orchestrator
    └── pyproject.toml                 # Python project configuration

artifacts/                             # Generated during build (gitignored)
├── coverage/                          # Code coverage reports
│   ├── coverage.cobertura.xml
│   └── report/
│       └── index.html
├── test-results/                      # Test execution results
│   ├── eslint.json
│   └── playwright-*.json
└── logs/                              # Build logs
```

## Configuration Guide

### Common Configuration Patterns

#### Coverage Thresholds
- **Strict (Enterprise)**: 80-90% - Critical systems, financial, healthcare
- **Standard (Production)**: 70-80% - Most production applications
- **Relaxed (Startups)**: 60-70% - Early stage, rapid iteration
- **Minimal (POC)**: 40-60% - Proof of concepts, prototypes

#### Test Timeouts
- **Unit Tests**: 100-500ms per test
- **Integration Tests**: 1-5 seconds per test
- **E2E Tests**: 30-60 seconds per test

### Environment-Specific Configurations

#### Development
```bash
# Fast feedback, skip slow tests
build.bat --skip-coverage-report --skip-integration-tests
```

#### CI/CD
```bash
# Full validation, verbose output
build.bat --verbose --run-all-tests --strict-coverage
```

#### Pre-commit
```bash
# Quick validation before commit
build.bat --skip-tests --format-only
```

## Integration with CI/CD

### GitHub Actions

See [`.github/workflows/`](.github/workflows/) for complete examples.

```yaml
name: Build and Test

on: [push, pull_request]

jobs:
  build:
    runs-on: windows-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: '8.0.x'
    
    - name: Run Build
      run: .\scripts\build\build-full.bat --verbose
    
    - name: Upload Coverage
      uses: codecov/codecov-action@v4
      with:
        files: ./artifacts/coverage/coverage.cobertura.xml
```

### Azure DevOps

```yaml
trigger:
  - main

pool:
  vmImage: 'windows-latest'

steps:
- task: UseDotNet@2
  inputs:
    version: '8.0.x'

- script: |
    scripts\build\build-full.bat --verbose
  displayName: 'Run Build Pipeline'

- task: PublishCodeCoverageResults@2
  inputs:
    summaryFileLocation: 'artifacts/coverage/coverage.cobertura.xml'
```

### GitLab CI

```yaml
stages:
  - build
  - test

build:
  stage: build
  script:
    - ./scripts/build/build-full.bat --verbose
  artifacts:
    paths:
      - artifacts/
    reports:
      coverage_report:
        coverage_format: cobertura
        path: artifacts/coverage/coverage.cobertura.xml
```

## AI Assistant Integration

These scripts are optimized for use with AI coding assistants like GitHub Copilot, Claude, GPT-4, etc.

### For AI Assistants

When working with these build scripts, consider:

1. **Configuration First**: Always check for existing configuration files before running
2. **Dry Run Mode**: Test changes with `--verbose` flag first
3. **Incremental Adoption**: Start with single stages (format → lint → test)
4. **Error Diagnostics**: Parse error output to suggest fixes
5. **Smart Defaults**: Scripts auto-detect project structure and tools

See [`.github/instructions/build-scripts.md`](.github/instructions/build-scripts.md) for detailed AI integration guidance.

## Troubleshooting

### Common Issues

#### "dotnet not found" or "node not found"
**Solution**: Ensure SDK is installed and in PATH
```bash
# Windows
where dotnet
where node

# Unix
which dotnet
which node
```

#### Coverage below threshold
**Solution**: Either improve test coverage or adjust threshold
```batch
REM Option 1: Adjust in build.config.bat
set "MIN_COVERAGE=65"

REM Option 2: Skip validation temporarily
build-full.bat --skip-coverage-validate
```

#### Tests timeout
**Solution**: Increase timeout threshold or optimize slow tests
```batch
set "TEST_TIMEOUT_THRESHOLD=10000"
```

#### Out of memory during build
**Solution**: Increase Node.js memory or use incremental builds
```bash
# Increase Node.js memory
export NODE_OPTIONS="--max-old-space-size=8192"

# .NET incremental build
dotnet build --no-incremental false
```

### Debug Mode

All scripts support verbose mode for detailed diagnostics:

```batch
# .NET
build-full.bat --verbose

# JavaScript
node build.js --verbose

# Python
uv run build.py --verbose
```

## Best Practices

### Pre-commit Checks
```bash
# Fast validation before commit
./build.sh --skip-tests --format-check
```

### CI/CD Pipeline
```bash
# Full validation with all gates
./build.sh --verbose --strict --coverage-threshold 80
```

### Local Development
```bash
# Quick iteration with auto-fix
./build.sh --fix --skip-slow-tests
```

### Release Preparation
```bash
# Comprehensive validation
./build.sh --all-checks --generate-docs --security-scan
```

## Customization

### Extending the Build Pipeline

#### Adding a Custom Stage (.NET)

1. Create new script in `scripts/build/custom-stage.bat`
2. Add call in `build-full.bat`:

```batch
if %RUN_CUSTOM_STAGE%==1 (
    call "%CS_BUILD_DIR%\custom-stage.bat"
    if errorlevel 1 goto :error
)
```

#### Adding a Custom Check (JavaScript)

1. Add function to `build.js`:

```javascript
function runCustomCheck() {
  return runStep('Custom Check', npxBin(), ['custom-tool', '--check'], {
    allowFailure: true,
    diagArgs: ['--verbose']
  });
}
```

2. Call in pipeline:

```javascript
if (hasCustomCheck) {
  runCustomCheck();
}
```

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test thoroughly on multiple projects
5. Submit a Pull Request

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Support

- 📚 **Documentation**: See language-specific READMEs in each directory
- 🐛 **Issues**: [GitHub Issues](https://github.com/vismathomas/build-scripts/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/vismathomas/build-scripts/discussions)

## Acknowledgments

Built with ❤️ for the enterprise software development community.

Special thanks to:
- Microsoft .NET Team
- Node.js Community
- Python Software Foundation
- All contributors and users

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and release notes.

---

**Version**: 1.0.0  
**Last Updated**: October 2, 2025  
**Maintained By**: Visma Software