# .NET/C# Build Scripts Documentation

> **Professional build automation for .NET projects with comprehensive quality gates**

## Overview

The C# build scripts provide a complete, production-ready build pipeline for .NET projects including:
- Code formatting with `dotnet format`
- Solution compilation with configurable build filters
- Unit and integration testing with code coverage
- Coverage reporting and threshold validation
- OpenAPI specification validation
- Slow test detection and performance analysis

## Files

```
cs/
├── build-full.bat                 # Main orchestrator
├── build.config.example.bat       # Configuration template
└── scripts/
    └── build/
        ├── init.bat               # Environment initialization
        ├── format.bat             # Code formatting
        ├── build-sln.bat          # Solution build
        ├── run-tests.bat          # Test execution with coverage
        ├── generate-coverage-report.bat  # Coverage HTML generation
        ├── validate-coverage.bat  # Threshold validation
        ├── finalize.bat           # Cleanup and summary
        └── analyze-slow-tests.ps1 # Performance diagnostics
```

## Quick Start

### 1. Copy Scripts to Your Project

```batch
xcopy /E /I cs\* your-project\scripts\build\
```

### 2. Create Configuration (Optional)

Create `build.config.bat` in your project root:

```batch
@echo off
REM Project-specific build configuration

REM Your solution file
set "SOLUTION=YourProject.sln"

REM Build filter (optional - speeds up build)
set "BUILD_FILTER=YourProject.Build.slnf"

REM Minimum code coverage percentage
set "MIN_COVERAGE=75"

REM Test timeout threshold in milliseconds
set "TEST_TIMEOUT_THRESHOLD=5000"
```

### 3. Run the Build

```batch
cd your-project
scripts\build\build-full.bat
```

## Configuration

### Required Configuration Variables

These are defined in `scripts/build/init.bat` with defaults:

| Variable | Default | Description |
|----------|---------|-------------|
| `SOLUTION` | `MyApp.sln` | Main solution file to build |
| `BUILD_FILTER` | `MyApp.Build.slnf` | Solution filter (optional) |
| `MIN_COVERAGE` | `1` | Minimum code coverage percentage |
| `TEST_TIMEOUT_THRESHOLD` | `5000` | Test timeout warning threshold (ms) |
| `VERBOSE_MODE` | `0` | Enable verbose output (0 or 1) |

### Override Configuration

**Option 1**: Create `build.config.bat` in project root (recommended)

**Option 2**: Set environment variables before running

```batch
set "SOLUTION=MyApp.sln"
set "MIN_COVERAGE=80"
scripts\build\build-full.bat
```

**Option 3**: Modify `scripts/build/init.bat` directly (not recommended)

## Command Line Options

### Main Build Script (`build-full.bat`)

```batch
build-full.bat [options]
```

#### General Options

- `--help` - Show help message and exit
- `--verbose` - Enable detailed logging throughout pipeline
- `--frontend` - Run frontend build after backend stages
- `--frontend-only` - Skip backend, run only frontend
- `--backend-only` - Run backend only (default)

#### Backend Stage Control

- `--skip-format` - Skip code formatting
- `--skip-build` - Skip solution compilation
- `--skip-tests` - Skip all testing and coverage stages
- `--skip-coverage-report` - Skip HTML report generation
- `--skip-coverage-validate` - Skip coverage threshold check

#### Examples

```batch
REM Full build with verbose output
build-full.bat --verbose

REM Quick validation (no tests)
build-full.bat --skip-tests

REM Format and build only
build-full.bat --skip-tests

REM Build both backend and frontend
build-full.bat --frontend

REM CI/CD full validation
build-full.bat --verbose --frontend
```

## Build Pipeline Stages

### Stage 1: Initialization (`init.bat`)

**Purpose**: Verify environment and create artifact directories

**Actions**:
- Check for `dotnet` CLI in PATH
- Load configuration variables
- Create `artifacts/` and `artifacts/coverage/` directories
- Display configuration if verbose mode enabled

**Output**:
```
Checking build environment...
  ✓ dotnet CLI found
  ✓ Artifacts directory ready
```

### Stage 2: Code Formatting (`format.bat`)

**Purpose**: Auto-format all code to consistent style

**Tools**: `dotnet format`

**Actions**:
- Run `dotnet format` on solution
- Auto-fix whitespace, indentation, style issues
- Fail build if formatting changes are needed (CI mode)

**Output**:
```
[1/4] Formatting code...
      ✓ Code formatting completed
```

**Configuration**:
- Format rules defined in `.editorconfig`
- Respects project-level formatting settings

### Stage 3: Solution Build (`build-sln.bat`)

**Purpose**: Compile entire solution in Release configuration

**Tools**: `dotnet build`

**Actions**:
- Build solution or build filter
- Use Release configuration
- Skip restore (assumes restore done separately)
- Detect and warn about workspace warnings

**Output**:
```
[2/4] Building solution...
      ✓ Build completed successfully
```

**Verbose Output**:
- Full MSBuild diagnostics
- Warning details
- Build timing information

### Stage 4: Test Execution (`run-tests.bat`)

**Purpose**: Run all tests with code coverage collection

**Tools**: `dotnet test`, XPlat Code Coverage

**Actions**:
- Execute all tests in Release configuration
- Collect code coverage data
- Generate Cobertura XML coverage report
- Copy coverage to `artifacts/coverage/coverage.cobertura.xml`

**Output**:
```
[3/4] Running tests with coverage...
      ✓ Tests completed successfully
```

**Coverage Collection**:
- Uses `--collect:"XPlat Code Coverage"`
- Raw coverage in `artifacts/coverage/raw/`
- Final report in `artifacts/coverage/coverage.cobertura.xml`

**Troubleshooting**:
- If tests fail, full output is displayed
- Check temp files in `%TEMP%\build_test_output_*.txt`
- Increase timeout if needed

### Stage 5: Coverage Report Generation (`generate-coverage-report.bat`)

**Purpose**: Create human-readable HTML coverage report

**Tools**: `reportgenerator`

**Actions**:
- Install/verify `dotnet-reportgenerator-globaltool`
- Generate HTML report from Cobertura XML
- Create text summary for threshold validation
- Output to `artifacts/coverage/report/`

**Output**:
```
Generating coverage report...
  ✓ Report generated: artifacts\coverage\report\index.html
```

**Report Contents**:
- `index.html` - Main coverage dashboard
- `Summary.txt` - Text summary with percentages
- Per-file and per-class coverage details

### Stage 6: Coverage Validation (`validate-coverage.bat`)

**Purpose**: Enforce minimum code coverage threshold

**Actions**:
- Parse `Summary.txt` for line coverage percentage
- Compare against `MIN_COVERAGE` threshold
- Fail build if below threshold

**Output (Success)**:
```
[4/4] Validating coverage...
      ✓ Coverage validated: 78.5% (minimum: 75%)
```

**Output (Failure)**:
```
[4/4] Validating coverage...
ERROR: Test coverage 68.2% is below minimum required 75%
       Report: artifacts\coverage\report\index.html
```

### Stage 7: Finalization (`finalize.bat`)

**Purpose**: Display build summary and next steps

**Actions**:
- Show build success message
- Display artifact locations
- Suggest additional QA commands
- Log build duration (verbose mode)

**Output**:
```
========================================
  BUILD SUCCEEDED
========================================
Coverage report: artifacts\coverage\report\index.html

Additional tools available:
  - Full QA suite: pwsh -File scripts\qa-all.ps1
```

## Performance Analysis

### Slow Test Detection (`analyze-slow-tests.ps1`)

**Purpose**: Identify tests that exceed performance thresholds

**Usage**:
```powershell
pwsh -File scripts\build\analyze-slow-tests.ps1 `
    -TestOutputFile "artifacts\test-output.txt" `
    -ThresholdMs 5000
```

**Parameters**:
- `-TestOutputFile` - Path to test output file
- `-ThresholdMs` - Threshold in milliseconds (default: 5000)

**Output**:
```
========================================
  WARNING: SLOW TESTS DETECTED
========================================

The following tests took longer than 5 seconds:

  12.3s - MyProject.Tests.IntegrationTests.SlowTest1
  8.7s - MyProject.Tests.IntegrationTests.SlowTest2

These tests should be optimized or may indicate a problem.
```

**Integration**: Called automatically by `run-tests.bat` if slow tests detected.

## Artifacts

All build artifacts are generated in the `artifacts/` directory:

```
artifacts/
├── coverage/
│   ├── raw/                           # Raw coverage data (deleted after processing)
│   ├── coverage.cobertura.xml         # Coverage XML (for CI/CD)
│   └── report/
│       ├── index.html                 # Coverage dashboard
│       ├── Summary.txt                # Text summary
│       └── [class-specific reports]   # Detailed per-class coverage
└── logs/
    └── build-*.log                    # Build logs (if logging enabled)
```

### Artifact Retention

**Keep**:
- `coverage/coverage.cobertura.xml` - For CI/CD reporting
- `coverage/report/` - For human review

**Delete**:
- `coverage/raw/` - Automatically cleaned up after processing

### `.gitignore` Recommendations

Add to your `.gitignore`:
```gitignore
# Build artifacts
artifacts/
*.log

# Test results
TestResults/
*.trx

# Coverage
coverage/
*.coverage
```

## CI/CD Integration

### GitHub Actions

```yaml
name: .NET Build

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
    
    - name: Run Build Pipeline
      run: .\scripts\build\build-full.bat --verbose
    
    - name: Upload Coverage
      uses: codecov/codecov-action@v4
      with:
        files: ./artifacts/coverage/coverage.cobertura.xml
        fail_ci_if_error: true
    
    - name: Upload Artifacts
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: build-artifacts
        path: artifacts/
```

### Azure DevOps

```yaml
trigger:
  - main
  - develop

pool:
  vmImage: 'windows-latest'

steps:
- task: UseDotNet@2
  displayName: 'Use .NET 8.0'
  inputs:
    version: '8.0.x'

- script: |
    call scripts\build\build-full.bat --verbose
  displayName: 'Run Build Pipeline'

- task: PublishCodeCoverageResults@2
  displayName: 'Publish Coverage'
  inputs:
    codeCoverageTool: 'Cobertura'
    summaryFileLocation: '$(Build.SourcesDirectory)/artifacts/coverage/coverage.cobertura.xml'
    reportDirectory: '$(Build.SourcesDirectory)/artifacts/coverage/report'

- task: PublishBuildArtifacts@1
  displayName: 'Publish Artifacts'
  condition: always()
  inputs:
    PathtoPublish: 'artifacts'
    ArtifactName: 'build-artifacts'
```

### GitLab CI

```yaml
build:
  stage: build
  image: mcr.microsoft.com/dotnet/sdk:8.0
  script:
    - ./scripts/build/build-full.bat --verbose
  artifacts:
    paths:
      - artifacts/
    reports:
      coverage_report:
        coverage_format: cobertura
        path: artifacts/coverage/coverage.cobertura.xml
  coverage: '/Line coverage: (\d+\.\d+)%/'
```

## Troubleshooting

### Common Issues

#### Issue: "dotnet CLI not found"

**Cause**: .NET SDK not installed or not in PATH

**Solution**:
```batch
REM Check if dotnet is available
where dotnet

REM If not found, install from:
REM https://dotnet.microsoft.com/download

REM Or add to PATH
set PATH=%PATH%;C:\Program Files\dotnet
```

#### Issue: "Coverage percentage could not be parsed"

**Cause**: Report generation failed or Summary.txt missing

**Solution**:
```batch
REM Check if report was generated
dir artifacts\coverage\report\Summary.txt

REM Re-run coverage report generation
scripts\build\generate-coverage-report.bat

REM Check for reportgenerator issues
dotnet tool list --global
```

#### Issue: "Tests failed but no diagnostic output"

**Cause**: Test output not captured properly

**Solution**:
```batch
REM Run with verbose mode
build-full.bat --verbose

REM Or run tests directly
dotnet test YourProject.sln -c Release --verbosity normal
```

#### Issue: "Build warnings were encountered"

**Cause**: Workspace or project has warnings

**Solution**:
```batch
REM See full warning details
build-full.bat --verbose

REM Or build directly with detailed output
dotnet build YourProject.sln -c Release --verbosity normal
```

### Debugging Tips

1. **Enable Verbose Mode**:
   ```batch
   build-full.bat --verbose
   ```

2. **Run Stages Individually**:
   ```batch
   scripts\build\init.bat --verbose
   scripts\build\format.bat
   scripts\build\build-sln.bat
   scripts\build\run-tests.bat
   ```

3. **Check Environment Variables**:
   ```batch
   set | findstr /I "SOLUTION BUILD MIN_COVERAGE VERBOSE"
   ```

4. **Examine Temp Files**:
   ```batch
   dir %TEMP%\build_*.txt
   type %TEMP%\build_test_output_*.txt
   ```

## Customization

### Adding Custom Build Stages

1. Create new script in `scripts/build/`:
   ```batch
   REM scripts/build/custom-stage.bat
   @echo off
   
   echo Running custom stage...
   
   REM Your custom logic here
   
   if errorlevel 1 (
       echo ERROR: Custom stage failed
       exit /b 1
   )
   
   echo       ✓ Custom stage completed
   exit /b 0
   ```

2. Add to `build-full.bat`:
   ```batch
   if %RUN_BACKEND%==1 (
       REM ... existing stages ...
       
       if %RUN_CUSTOM_STAGE%==1 (
           call "%CS_BUILD_DIR%\custom-stage.bat"
           if errorlevel 1 goto :error
       )
   )
   ```

### Customizing Coverage Thresholds

**Per-Environment Thresholds**:
```batch
REM Development: Relaxed
if "%ENVIRONMENT%"=="DEV" set "MIN_COVERAGE=60"

REM Production: Strict
if "%ENVIRONMENT%"=="PROD" set "MIN_COVERAGE=85"
```

### Integrating Additional Tools

**Example: SonarQube Integration**
```batch
REM Before build
dotnet sonarscanner begin /k:"project-key"

REM Run build
call scripts\build\build-full.bat

REM After build
dotnet sonarscanner end
```

## Best Practices

1. **Version Control**: Commit `build.config.bat`, ignore `artifacts/`
2. **Consistent Naming**: Use consistent solution/project naming
3. **Regular Updates**: Keep scripts updated from this repository
4. **Test Locally**: Always test script changes locally before CI/CD
5. **Document Changes**: Update README when customizing scripts
6. **Monitor Performance**: Use slow test analysis to optimize
7. **Coverage Goals**: Set realistic coverage thresholds
8. **Clean Builds**: Regularly clean and rebuild to verify

## Support

- **Main Documentation**: [Root README](../README.md)
- **GitHub Issues**: [Report Issues](https://github.com/vismathomas/build-scripts/issues)
- **Copilot Guide**: [AI Integration](../.github/instructions/build-scripts.md)

---

**Version**: 1.0.0  
**Last Updated**: October 2, 2025  
**Maintained By**: Visma Software
