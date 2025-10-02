# Python Build Scripts Documentation

> **Professional build automation for Python projects with comprehensive quality gates**

## Overview

The Python build scripts provide a complete, production-ready build pipeline for Python projects including:
- Dependency management with `uv` (or pip)
- Code formatting with Ruff
- Linting with Ruff
- Type checking with mypy
- Unit and integration testing with pytest
- Code coverage analysis with coverage thresholds
- Security vulnerability scanning
- Performance reporting

## Features

✅ **Modern Tooling** - Uses fast, modern Python tools (uv, ruff, mypy)  
✅ **Comprehensive Checks** - Format, lint, type check, test, security scan  
✅ **Coverage Enforcement** - Configurable coverage thresholds with pytest-cov  
✅ **Fast Execution** - Leverages uv for rapid dependency management  
✅ **CI/CD Ready** - Generates reports for integration with pipelines  
✅ **Verbose Mode** - Detailed diagnostics for troubleshooting  
✅ **Auto-fix Mode** - Automatically fix formatting and linting issues  
✅ **Clean Build** - Built-in artifact cleanup

## Files

```
python/
├── build.py                       # Main build orchestrator
└── pyproject.toml                 # Python project configuration template
```

## Quick Start

### Option 1: Run Directly from GitHub (Easiest)

No installation needed! Use `uvx` to run the build script directly:

```bash
# Run build script directly from GitHub
uvx --from git+https://github.com/vismathomas/build-scripts python python/build.py

# With options
uvx --from git+https://github.com/vismathomas/build-scripts python python/build.py --verbose
uvx --from git+https://github.com/vismathomas/build-scripts python python/build.py --fix
```

**Or download just the script:**

```bash
# Download to your project
curl -o build.py https://raw.githubusercontent.com/vismathomas/build-scripts/main/python/build.py

# Run with uv
uv run build.py

# Or run directly (if uv not available)
python build.py --verbose
```

### Option 2: Copy Build Script to Your Project

```bash
# Copy from cloned repo
cp python/build.py your-project/scripts/build/

# Or place in project root
cp python/build.py your-project/
```

### 2. Install Required Tools

The build script requires the following tools:
- **uv** - Fast Python package manager
- **ruff** - Python linter and formatter
- **mypy** - Static type checker
- **pytest** - Testing framework with coverage support

#### Using uv (Recommended - Fast)

```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Or with pip
pip install uv

# Add build tools to your pyproject.toml
[dependency-groups]
dev = [
    "uv>=0.1.0",
    "ruff>=0.13.1",
    "mypy>=1.18.2",
    "pytest>=8.4.2",
    "pytest-cov>=7.0.0",
]

# Sync dependencies (reads pyproject.toml)
uv sync
```

#### Using pip (Traditional)

```bash
# Install development dependencies
pip install ruff mypy pytest pytest-cov pytest-asyncio pytest-timeout
```

### 3. Configure pyproject.toml

Ensure your `pyproject.toml` has the required sections (see Configuration below).

### 4. Run the Build

```bash
# Full build
uv run build.py

# With verbose output
uv run build.py --verbose

# Auto-fix issues
uv run build.py --fix

# Clean artifacts
uv run build.py --clean
```

## Usage with uv

### Using uv run (Recommended)

`uv` automatically manages the virtual environment and dependencies:

```bash
# Full build (uv handles the environment)
uv run build.py

# With verbose output
uv run build.py --verbose

# Auto-fix issues
uv run build.py --fix

# Clean artifacts
uv run build.py --clean
```

**Benefits:**
- ✅ No need to activate virtual environment
- ✅ Automatically syncs dependencies before running
- ✅ Ensures consistent environment across runs
- ✅ Fast dependency resolution

### Using uvx for One-Off Execution

`uvx` runs Python scripts in isolated environments without installing:

```bash
# Run build script without installing dependencies globally
uvx --from . python build.py

# With options
uvx --from . python build.py --verbose
uvx --from . python build.py --fix
```

**Use cases:**
- CI/CD pipelines where you don't want persistent installations
- Testing the build script in isolation
- Running on systems where you can't install packages globally

### Traditional Virtual Environment

If you prefer manual environment management:

```bash
# Create and activate virtual environment
uv venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install dependencies
uv sync

# Run build
uv run build.py --verbose
```

### Comparison: uv vs pip vs uvx

| Method | Command | Setup Time | Use Case |
|--------|---------|------------|----------|
| **uvx from GitHub** | `uvx --from git+https://...` | Very fast | No local install needed |
| **uv run** | `uv run build.py` | Fast (auto-sync) | Daily development, automatic env management |
| **uvx local** | `uvx --from . python build.py` | Very fast (isolated) | CI/CD, one-off runs, testing |
| **uv + venv** | `source .venv/bin/activate && uv run build.py` | Fast (one-time setup) | Traditional workflow, IDE integration |
| **pip + venv** | `source .venv/bin/activate && python build.py` | Slow (dependency resolution) | Systems without uv |

**Recommendation**: Use `uvx` from GitHub for first-time testing, `uv run` for development, and `uvx` for CI/CD pipelines.

### Creating a Convenient Alias

For easier access, create a shell alias or script wrapper:

**Bash/Zsh (~/.bashrc or ~/.zshrc):**
```bash
alias pybuild='uvx --from git+https://github.com/vismathomas/build-scripts python python/build.py'

# Then use:
pybuild --verbose
pybuild --fix
```

**PowerShell ($PROFILE):**
```powershell
function pybuild {
    uvx --from git+https://github.com/vismathomas/build-scripts python python/build.py @args
}

# Then use:
pybuild --verbose
pybuild --fix
```

**Or create a local wrapper script (build.sh):**
```bash
#!/bin/bash
uvx --from git+https://github.com/vismathomas/build-scripts python python/build.py "$@"
```
```bash
chmod +x build.sh
./build.sh --verbose
```

## Configuration

### pyproject.toml

The build script reads configuration from `pyproject.toml`:

```toml
[project]
name = "your-package"
version = "1.0.0"
requires-python = ">=3.10"
dependencies = [
    "requests>=2.31.0",
    # ... your dependencies
]

[project.optional-dependencies]
dev = [
    "ruff>=0.1.0",
    "mypy>=1.7.0",
    "pytest>=7.4.0",
    "pytest-cov>=4.1.0",
    "pytest-asyncio>=0.21.0",
    "pytest-timeout>=2.1.0",
]

[tool.ruff]
line-length = 88
target-version = "py310"
exclude = [
    ".git",
    ".mypy_cache",
    ".pytest_cache",
    ".ruff_cache",
    ".venv",
    "__pycache__",
    "build",
    "dist",
]

[tool.ruff.lint]
select = [
    "E",   # pycodestyle errors
    "W",   # pycodestyle warnings
    "F",   # pyflakes
    "I",   # isort
    "B",   # flake8-bugbear
    "C4",  # flake8-comprehensions
    "UP",  # pyupgrade
    "N",   # pep8-naming
    "S",   # flake8-bandit (security)
    "T20", # flake8-print
    "RUF", # ruff-specific rules
]
ignore = [
    "S101",  # Use of assert (OK in tests)
    "T201",  # Print statements (OK in scripts)
]

[tool.ruff.lint.per-file-ignores]
"tests/*" = ["S101", "T201"]  # Allow assert and print in tests

[tool.mypy]
python_version = "3.10"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = false
no_implicit_optional = true
warn_redundant_casts = true
show_error_codes = true

[[tool.mypy.overrides]]
module = ["third_party_lib.*"]
ignore_missing_imports = true

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = [
    "-v",
    "--tb=short",
    "--cov=your_package",
    "--cov-report=term-missing",
    "--cov-report=html",
    "--cov-report=xml",
    "--cov-fail-under=70",
    "--timeout=5",
]
asyncio_mode = "auto"

[tool.coverage.run]
source = ["."]
omit = [
    "tests/*",
    ".venv/*",
    "build/*",
    "dist/*",
    "*.egg-info/*",
    "**/__pycache__/*",
]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "if self.debug:",
    "raise AssertionError",
    "raise NotImplementedError",
    "if __name__ == .__main__.:",
    "@(abc\\.)?abstractmethod",
]
```

## Command Line Options

```bash
uv run build.py [options]
```

### Options

- `--verbose` / `-v` - Enable verbose output with detailed diagnostics
- `--fix` - Automatically fix formatting and linting issues
- `--clean` - Clean build artifacts and exit (no build)

### Examples

```bash
# Full build with verbose output
uv run build.py --verbose

# Quick check (no auto-fix)
uv run build.py

# Auto-fix issues
uv run build.py --fix

# Clean up artifacts
uv run build.py --clean

# CI/CD build (verbose + auto-fix)
uv run build.py --verbose --fix
```

## Build Pipeline Stages

### Stage 1: Check Dependencies

**Purpose**: Verify all required tools are available

**Tools Checked**:
- `uv` - Dependency manager
- `ruff` - Formatter and linter
- `mypy` - Type checker
- `pytest` - Test runner

**Output**:
```
========================================
🔧 Checking Dependencies
========================================
✅ uv: uv 0.1.0
✅ ruff: ruff 0.1.7
✅ mypy: mypy 1.7.1
✅ pytest: pytest 7.4.3
```

**Failure**: Build stops if required tools are missing

### Stage 2: Sync Dependencies

**Purpose**: Install/update all project dependencies

**Tool**: `uv sync`

**Actions**:
- Read dependencies from pyproject.toml
- Install/update packages
- Create/update virtual environment

**Output**:
```
========================================
🔧 Syncing Dependencies
========================================
✅ Dependency Sync - PASSED
```

**Equivalent pip command**:
```bash
pip install -e ".[dev]"
```

### Stage 3: Code Formatting

**Purpose**: Ensure consistent code style

**Tool**: Ruff (format + check)

**Actions**:
- Run `ruff format` (with `--check` if `--fix` not specified)
- Run `ruff check --fix` for import sorting and other auto-fixes
- Apply PEP 8 style guide
- Sort imports

**Output (Success)**:
```
========================================
🔧 Code Formatting
========================================
✅ ruff format - PASSED
✅ ruff check - PASSED
```

**Output (Failure - needs fix)**:
```
========================================
🔧 Code Formatting
========================================
❌ ruff format - FAILED
Error: 5 files would be reformatted

Run with --fix to automatically fix issues
```

**Verbose Output**:
- List of files that would be changed
- Specific rule violations
- Line numbers and context

### Stage 4: Code Linting

**Purpose**: Check for code quality issues

**Tool**: Ruff

**Actions**:
- Run `ruff check --fix`
- Check for style violations
- Check for common bugs
- Check for security issues
- Enforce naming conventions

**Output**:
```
========================================
🔧 Code Linting
========================================
✅ ruff - PASSED
```

**Rule Categories**:
- **E, W**: pycodestyle (PEP 8)
- **F**: Pyflakes (unused imports, undefined names)
- **I**: isort (import sorting)
- **B**: Bugbear (likely bugs)
- **S**: Bandit (security)
- **N**: PEP 8 naming
- **UP**: Pyupgrade (modern Python syntax)

### Stage 5: Type Checking

**Purpose**: Verify type annotations and catch type errors

**Tool**: mypy

**Actions**:
- Check main module (e.g., `mypy your_package/`)
- Verify type annotations
- Check for type mismatches
- Validate return types

**Output (Success)**:
```
========================================
🔧 Type Checking
========================================
✅ mypy your_package/ - PASSED
```

**Output (Failure)**:
```
========================================
🔧 Type Checking
========================================
❌ mypy your_package/ - FAILED
Error: your_package/module.py:42: error: Argument 1 has incompatible type
```

**Configuration**: Controlled by `[tool.mypy]` in pyproject.toml

### Stage 6: Security Check

**Purpose**: Scan for security vulnerabilities

**Tool**: Ruff with security rules (S prefix)

**Actions**:
- Run `ruff check` with security rules only
- Check for hardcoded passwords
- Check for unsafe use of eval/exec
- Check for SQL injection risks
- Check for insecure random usage

**Output**:
```
========================================
🔧 Security Checks
========================================
✅ Security Check - PASSED
```

**Common Security Rules**:
- S101: Use of assert (can be optimized away)
- S104: Binding to all interfaces
- S105-S107: Hardcoded passwords
- S301-S324: Various injection risks
- S501-S506: Weak cryptography

### Stage 7: Unit Tests

**Purpose**: Run unit tests with code coverage

**Tool**: pytest with pytest-cov

**Actions**:
- Run all tests in `tests/` directory
- Collect code coverage
- Generate coverage reports (HTML, XML, Terminal)
- Enforce coverage threshold (default: 70%)
- Set test timeout (default: 5 seconds per test)

**Output (Success)**:
```
========================================
🔧 Unit Tests
========================================
✅ Unit Tests with Coverage - PASSED
📊 Code Coverage: 78%
```

**Output (Failure)**:
```
========================================
🔧 Unit Tests
========================================
❌ Unit Tests with Coverage - FAILED
Error: 3 tests failed
⚠️  Coverage below 70% threshold!
```

**Coverage Reports Generated**:
- **Terminal**: Immediate feedback with missing lines
- **HTML**: `htmlcov/index.html` - Interactive report
- **XML**: `coverage.xml` - For CI/CD integration

**Test Timeout**:
- Default: 5 seconds per test
- Configurable via `[tool.pytest.ini_options]`
- Prevents hanging tests

### Stage 8: Integration Tests

**Purpose**: Run integration tests (if present)

**Actions**:
- Run core integration tests
- Test system integration points
- Skip Docker tests for speed (configurable)

**Output**:
```
========================================
🔧 Integration Tests
========================================
✅ Core Integration Tests - PASSED
```

**Note**: This stage allows failures without stopping the build (soft fail)

### Stage 9: Generate Reports

**Purpose**: Create build artifacts and reports

**Actions**:
- Verify coverage report generation
- Create reports directory
- Display report locations

**Output**:
```
========================================
🔧 Generating Reports
========================================
✅ Coverage HTML report: htmlcov/index.html
✅ Coverage XML report: coverage.xml
```

**Reports Directory**:
```
reports/
├── coverage/
│   ├── htmlcov/          # Interactive HTML coverage
│   └── coverage.xml      # XML for CI/CD
└── test-results/
    └── junit.xml         # Test results (if configured)
```

### Stage 10: Build Summary

**Purpose**: Display overall build status and timing

**Output (All Passed)**:
```
========================================
📊 Build Summary
========================================
✅ Successful steps: 9/9
⏱️  Build duration: 45.23 seconds

🎉 BUILD SUCCESSFUL - All quality checks passed!
📦 Ready for deployment
```

**Output (Some Failures)**:
```
========================================
📊 Build Summary
========================================
✅ Successful steps: 7/9
⏱️  Build duration: 38.15 seconds
❌ Failed steps: Type Check, Unit Tests

❌ BUILD FAILED - 2 critical issues
🛠️  Please fix the failed steps before proceeding
```

## Artifacts

```
your-project/
├── htmlcov/                       # HTML coverage report
│   └── index.html                 # Main coverage page
├── coverage.xml                   # Coverage XML (Cobertura)
├── .coverage                      # Coverage data file
├── reports/                       # Additional reports (if created)
│   └── test-results/
└── __pycache__/                   # Python cache (auto-generated)
```

### `.gitignore` Recommendations

```gitignore
# Build artifacts
__pycache__/
*.py[cod]
*$py.class
*.so
.Python

# Testing
.pytest_cache/
.coverage
htmlcov/
coverage.xml
*.cover

# Type checking
.mypy_cache/
.dmypy.json
dmypy.json

# Linting
.ruff_cache/

# Virtual environments
.venv/
venv/
ENV/

# Reports
reports/

# Distribution
build/
dist/
*.egg-info/
```

## CI/CD Integration

### GitHub Actions

**Option 1: Run directly from GitHub repo (easiest, no file copying):**

```yaml
name: Python Build

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ['3.10', '3.11', '3.12']
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Install uv
      uses: astral-sh/setup-uv@v4
    
    - name: Run Build from GitHub Repository
      run: |
        uvx --from git+https://github.com/vismathomas/build-scripts \
          python python/build.py --verbose
    
    - name: Upload Coverage
      uses: codecov/codecov-action@v4
      if: always()
      with:
        files: ./coverage.xml
        fail_ci_if_error: true
    
    - name: Upload HTML Coverage
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: coverage-report-${{ matrix.python-version }}
        path: htmlcov/
```

**Option 2: With local build.py script in your repo:**

```yaml
name: Python Build

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ['3.10', '3.11', '3.12']
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Install uv
      uses: astral-sh/setup-uv@v4
      with:
        enable-cache: true
    
    - name: Set up Python
      run: uv python install ${{ matrix.python-version }}
    
    - name: Run Build Pipeline with uv
      run: uv run scripts/build/build.py --verbose
    
    - name: Upload Coverage
      uses: codecov/codecov-action@v4
      with:
        files: ./coverage.xml
        fail_ci_if_error: true
    
    - name: Upload HTML Coverage
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: coverage-report-${{ matrix.python-version }}
        path: htmlcov/
```

**Alternative with uvx (no environment setup):**

```yaml
    - uses: actions/checkout@v4
    
    - name: Install uv
      uses: astral-sh/setup-uv@v4
    
    - name: Run Build with uvx
      run: uvx --from . python build.py --verbose
```

### Azure DevOps

```yaml
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

strategy:
  matrix:
    Python310:
      python.version: '3.10'
    Python311:
      python.version: '3.11'

steps:
- task: UsePythonVersion@0
  inputs:
    versionSpec: '$(python.version)'

- script: |
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
    uv run scripts/build/build.py --verbose
  displayName: 'Run Build Pipeline with uv'

- task: PublishCodeCoverageResults@2
  inputs:
    codeCoverageTool: 'Cobertura'
    summaryFileLocation: 'coverage.xml'
    reportDirectory: 'htmlcov'
```

### GitLab CI

```yaml
image: python:3.11

stages:
  - build
  - test

build:
  stage: build
  before_script:
    - curl -LsSf https://astral.sh/uv/install.sh | sh
    - export PATH="$HOME/.cargo/bin:$PATH"
  script:
    - uv run build.py --verbose
  artifacts:
    paths:
      - htmlcov/
      - coverage.xml
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml
  coverage: '/TOTAL.*\s+(\d+)%/'
```

## Troubleshooting

### Common Issues

#### Issue: "uv not found"

**Cause**: uv not installed or not in PATH

**Solution**:
```bash
# Install uv (recommended)
curl -LsSf https://astral.sh/uv/install.sh | sh

# On Windows (PowerShell)
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"

# Or with pip
pip install uv

# Verify installation
uv --version

# Alternative: Use pip-based build without uv
pip install -e ".[dev]"
python build.py  # Note: without uv run when using pip
```

#### Issue: "uv run fails with dependency errors"

**Cause**: Dependencies not synced or pyproject.toml issues

**Solution**:
```bash
# Force dependency sync
uv sync --force

# Clear cache and retry
rm -rf .venv
uv venv
uv sync

# Check pyproject.toml syntax
uv tree  # Shows dependency tree
```

#### Issue: "uvx command not found"

**Cause**: Using older version of uv without uvx

**Solution**:
```bash
# Update uv to latest version
curl -LsSf https://astral.sh/uv/install.sh | sh

# Or use uv run instead
uv run build.py
```

#### Issue: "Coverage below threshold"

**Cause**: Test coverage is below configured minimum

**Solution**:
```bash
# Option 1: Write more tests
# Add tests to increase coverage

# Option 2: Adjust threshold in pyproject.toml
# [tool.pytest.ini_options]
# addopts = ["--cov-fail-under=60"]  # Lower threshold

# Option 3: See which files need coverage
uv run build.py --verbose
open htmlcov/index.html  # View detailed report
```

#### Issue: "Type checking errors"

**Cause**: Type annotation issues

**Solution**:
```bash
# Run mypy directly for detailed output
uv run mypy your_package/ --show-error-codes

# Ignore specific errors
# Add to pyproject.toml:
# [[tool.mypy.overrides]]
# module = "problematic_module"
# ignore_errors = true
```

#### Issue: "Tests timeout"

**Cause**: Tests taking too long

**Solution**:
```toml
# Increase timeout in pyproject.toml
[tool.pytest.ini_options]
addopts = [
    "--timeout=30",  # Increase from 5 to 30 seconds
]
```

### Debugging

**Enable Verbose Mode**:
```bash
uv run build.py --verbose
```

**Run Stages Individually**:
```bash
# Format
uv run ruff format .

# Lint
uv run ruff check .

# Type check
uv run mypy your_package/

# Tests
uv run pytest tests/ -v

# Coverage
uv run pytest tests/ --cov=your_package --cov-report=html
```

**Check Configuration**:
```bash
# Verify pyproject.toml syntax
python -c "import tomllib; print(tomllib.load(open('pyproject.toml', 'rb')))"

# Check installed tools
uv run ruff --version
uv run mypy --version
uv run pytest --version
```

## Best Practices

1. **Version Control**: Commit `pyproject.toml`, ignore `__pycache__/`, `.venv/`, `htmlcov/`
2. **Virtual Environments**: Always use virtual environments (uv handles this automatically)
3. **Type Annotations**: Add type hints for better mypy coverage
4. **Coverage Goals**: Start at 70%, increase to 80-90% for production code
5. **Regular Updates**: Keep dependencies updated with `uv sync --upgrade`
6. **Documentation**: Add docstrings for better code maintainability
7. **Pre-commit**: Use `--fix` flag for automatic issue resolution
8. **CI/CD**: Always run full pipeline in CI/CD with `--verbose`

## Customization

### Adding Custom Build Stages

Modify `build.py` to add custom stages:

```python
def run_custom_check(self) -> bool:
    """Run custom validation."""
    self.print_step("Custom Check")
    
    success, output, error = self.run_command(
        ["uv", "run", "custom-tool", "--check"],
        "Custom validation"
    )
    
    self.print_result(success, "Custom Check", output, error)
    return success
```

Add to pipeline:
```python
# In run_full_build method
steps = [
    # ... existing steps ...
    ("Custom Check", self.run_custom_check),
]
```

### Environment-Specific Configuration

```python
import os

# Adjust coverage threshold based on environment
if os.environ.get('CI') == 'true':
    # Strict in CI
    MIN_COVERAGE = 80
else:
    # Relaxed locally
    MIN_COVERAGE = 70
```

## Support

- **Main Documentation**: [Root README](../README.md)
- **GitHub Issues**: [Report Issues](https://github.com/vismathomas/build-scripts/issues)
- **Copilot Guide**: [AI Integration](../.github/instructions/build-scripts.md)

---

**Version**: 1.0.0  
**Last Updated**: October 2, 2025  
**Maintained By**: Visma Software
