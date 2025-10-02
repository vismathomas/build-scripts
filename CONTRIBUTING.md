# Contributing to Enterprise Build Scripts

Thank you for your interest in contributing! This document provides guidelines and best practices for contributing to this project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Guidelines](#development-guidelines)
- [Testing](#testing)
- [Documentation](#documentation)
- [Pull Request Process](#pull-request-process)
- [Style Guidelines](#style-guidelines)

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors, regardless of experience level, gender, gender identity and expression, sexual orientation, disability, personal appearance, body size, race, ethnicity, age, religion, or nationality.

### Expected Behavior

- Use welcoming and inclusive language
- Be respectful of differing viewpoints and experiences
- Gracefully accept constructive criticism
- Focus on what is best for the community
- Show empathy towards other community members

### Unacceptable Behavior

- Trolling, insulting/derogatory comments, and personal or political attacks
- Public or private harassment
- Publishing others' private information without explicit permission
- Other conduct which could reasonably be considered inappropriate

## Getting Started

### Prerequisites

Depending on which scripts you're working on, you'll need:

- **For .NET Scripts**: .NET SDK 6.0+, Windows or Linux
- **For JavaScript Scripts**: Node.js 18+, npm 9+
- **For Python Scripts**: Python 3.10+, uv or pip

### Development Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/build-scripts.git
   cd build-scripts
   ```
3. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## How to Contribute

### Reporting Bugs

When reporting bugs, please include:

1. **Clear Title**: Descriptive summary of the issue
2. **Environment**: OS, tool versions, project type
3. **Steps to Reproduce**: Detailed steps to recreate the issue
4. **Expected Behavior**: What should happen
5. **Actual Behavior**: What actually happens
6. **Logs**: Relevant error messages or verbose output
7. **Configuration**: Any relevant configuration files

**Example**:
```markdown
## Bug: Coverage validation fails on Windows

**Environment**:
- OS: Windows 11
- .NET SDK: 8.0.100
- Build Scripts: 1.0.0

**Steps to Reproduce**:
1. Run `build-full.bat --verbose`
2. Tests pass with 75% coverage
3. Coverage validation fails

**Expected**: Coverage should pass (threshold is 70%)
**Actual**: Error message "Coverage percentage could not be parsed"

**Logs**:
```
[4/4] Validating coverage...
WARNING: Coverage percentage could not be parsed.
```

**Configuration**: Using default configuration, MIN_COVERAGE=70
```

### Suggesting Enhancements

Enhancement suggestions are welcome! Please include:

1. **Use Case**: Why is this enhancement needed?
2. **Proposed Solution**: How should it work?
3. **Alternatives**: Any alternative approaches considered?
4. **Impact**: How does this affect existing functionality?

### Submitting Changes

1. **Small Changes**: Typos, documentation fixes - direct PR
2. **Medium Changes**: New features, refactoring - create an issue first
3. **Large Changes**: Architecture changes - discuss in an issue before coding

## Development Guidelines

### Directory Structure

Maintain the existing structure:
```
build-scripts/
├── cs/                 # .NET scripts
├── js/                 # JavaScript scripts
├── python/             # Python scripts
├── .github/            # GitHub-specific files
└── docs/               # Additional documentation
```

### Code Organization

- **Platform-Specific**: Keep platform code separate (cs/, js/, python/)
- **Shared Logic**: If shared logic is needed, document it well
- **Configuration**: Use configuration files, not hardcoded values
- **Error Handling**: Always handle errors gracefully
- **Logging**: Provide both verbose and quiet modes

### Backward Compatibility

- **Breaking Changes**: Avoid if possible; document if necessary
- **Deprecation**: Mark features as deprecated before removal
- **Migration Guides**: Provide guides for breaking changes
- **Version Bumps**: Follow semantic versioning

## Testing

### Testing Requirements

All contributions must include appropriate tests:

#### .NET Scripts
```batch
REM Test on clean project
mkdir test-project
cd test-project
dotnet new sln -n TestProject
dotnet new classlib -n TestProject
dotnet sln add TestProject
copy ..\build-full.bat .
build-full.bat --verbose
```

#### JavaScript Scripts
```bash
# Test on clean project
mkdir test-project && cd test-project
npm init -y
npm install --save-dev prettier eslint typescript vitest
cp ../build.js .
node build.js --verbose
```

#### Python Scripts
```bash
# Test on clean project
mkdir test-project && cd test-project
uv init
cp ../build.py .
python build.py --verbose
```

### Test Coverage

- Test on multiple OS platforms when possible
- Test with different project structures
- Test edge cases (missing files, wrong permissions, etc.)
- Test verbose and quiet modes
- Test skip flags and options

### Validation Checklist

Before submitting, verify:

- [ ] Scripts execute without errors on clean project
- [ ] Verbose mode provides useful diagnostics
- [ ] Error messages are clear and actionable
- [ ] Configuration is respected
- [ ] Artifacts are generated correctly
- [ ] Exit codes are appropriate
- [ ] Documentation is updated
- [ ] CHANGELOG.md is updated

## Documentation

### Documentation Standards

All contributions must include documentation updates:

#### README Updates
- Update main README.md if adding new features
- Update platform-specific READMEs (cs/README.md, etc.)
- Add examples for new functionality
- Update troubleshooting section if needed

#### Code Comments
- **Why, not What**: Explain reasoning, not obvious operations
- **Assumptions**: Document any assumptions made
- **Gotchas**: Warn about potential issues
- **TODOs**: Mark incomplete work clearly

#### Examples
```batch
REM GOOD: Explain why
REM Use findstr instead of find for better Unicode support
findstr /C:"Coverage" report.txt

REM BAD: State the obvious
REM Find coverage in report
findstr /C:"Coverage" report.txt
```

### Documentation Checklist

- [ ] README.md updated
- [ ] Platform-specific README updated
- [ ] CHANGELOG.md updated with entry
- [ ] Code comments added where needed
- [ ] Examples provided for new features
- [ ] Configuration documented

## Pull Request Process

### Before Submitting

1. **Test Thoroughly**: Run on multiple projects
2. **Update Documentation**: All relevant docs updated
3. **Clean Commit History**: Squash meaningless commits
4. **Descriptive Commit Messages**: Follow convention below

### Commit Message Convention

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, missing semicolons, etc.
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples**:
```
feat(cs): add security scanning stage

Adds a new security scanning stage using SecurityCodeScan NuGet package.
Integrates with existing build pipeline and respects --skip-security flag.

Closes #123
```

```
fix(js): handle missing coverage summary gracefully

Previously crashed when coverage/coverage-summary.json was missing.
Now displays warning and continues with soft failure.

Fixes #456
```

### PR Title and Description

**Title**: Clear, concise summary matching commit convention

**Description Template**:
```markdown
## Description
Brief description of changes

## Motivation
Why is this change needed?

## Changes
- List of specific changes
- Each change on its own line

## Testing
How was this tested?

## Screenshots (if applicable)
Include screenshots for UI changes

## Checklist
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Tested on Windows/Linux/macOS
- [ ] Backward compatible (or migration guide provided)
```

### Review Process

1. **Automated Checks**: Must pass CI/CD
2. **Code Review**: At least one maintainer approval
3. **Testing**: Verify on different projects
4. **Documentation**: Confirm docs are complete
5. **Merge**: Squash and merge with clear commit message

## Style Guidelines

### Batch Scripts (.bat)

```batch
@echo off
REM Use ENABLEDELAYEDEXPANSION when needed
setlocal ENABLEDELAYEDEXPANSION

REM Clear variable names
set "DESCRIPTIVE_NAME=value"

REM Check for errors after important commands
dotnet build
if errorlevel 1 (
    echo ERROR: Build failed
    exit /b 1
)

REM Use functions for reusable logic
goto :main

:function_name
    REM Function implementation
    exit /b 0

:main
call :function_name
exit /b 0
```

### JavaScript/TypeScript

```javascript
// Use modern JavaScript features
const { spawnSync } = require('node:child_process');

// Clear function names
function runStep(name, command, args, options = {}) {
  // Implementation
}

// Handle errors explicitly
if (result.status !== 0) {
  console.error(`Failed: ${name}`);
  process.exit(1);
}

// Use template literals
console.log(`Coverage: ${percentage}%`);
```

### Python

```python
#!/usr/bin/env python3
"""Module docstring describing purpose."""

import sys
from pathlib import Path
from typing import Optional

class BuildRunner:
    """Class docstring."""
    
    def run_command(
        self,
        cmd: list[str],
        description: str,
        check: bool = True
    ) -> tuple[bool, str, str]:
        """
        Function docstring.
        
        Args:
            cmd: Command to execute
            description: Human-readable description
            check: Whether to check return code
        
        Returns:
            Tuple of (success, stdout, stderr)
        """
        # Implementation
```

## Questions?

- **GitHub Discussions**: For general questions
- **GitHub Issues**: For specific problems or feature requests
- **Email**: For sensitive matters

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Celebrated in the community!

Thank you for contributing! 🎉

---

**Version**: 1.0.0  
**Last Updated**: October 2, 2025  
**Maintained By**: Visma Software
