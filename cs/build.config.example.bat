@echo off
REM ============================================================================
REM Build Configuration Template for .NET Projects
REM ============================================================================
REM
REM Copy this file to your project root as "build.config.bat" and customize
REM the values below for your specific project.
REM
REM This file is sourced by the build scripts to override default settings.
REM ============================================================================

REM ----------------------------------------------------------------------------
REM Solution and Build Configuration
REM ----------------------------------------------------------------------------

REM Main solution file (relative to project root)
set "SOLUTION=YourProject.sln"

REM Build filter file (optional - speeds up CI builds by excluding unnecessary projects)
REM Create using: dotnet sln YourProject.sln list | Select projects | Save as .slnf
set "BUILD_FILTER=YourProject.Build.slnf"

REM ----------------------------------------------------------------------------
REM Code Coverage Settings
REM ----------------------------------------------------------------------------

REM Minimum required code coverage percentage (0-100)
REM Recommended: 70-80 for most projects, 80-90 for critical systems
set "MIN_COVERAGE=70"

REM ----------------------------------------------------------------------------
REM Test Configuration
REM ----------------------------------------------------------------------------

REM Test timeout threshold in milliseconds
REM Tests exceeding this duration will be flagged as slow
REM Recommended: 5000 (5 seconds) for unit tests, higher for integration tests
set "TEST_TIMEOUT_THRESHOLD=5000"

REM ----------------------------------------------------------------------------
REM Frontend Build Configuration (Optional)
REM ----------------------------------------------------------------------------

REM Path to frontend build script (if applicable)
REM This script will be called when --frontend flag is used
set "FRONTEND_SCRIPT=%~dp0frontend-build.bat"

REM ----------------------------------------------------------------------------
REM Advanced Settings (Optional)
REM ----------------------------------------------------------------------------

REM Build configuration (Release, Debug)
REM Default: Release
REM set "BUILD_CONFIGURATION=Release"

REM MSBuild verbosity (quiet, minimal, normal, detailed, diagnostic)
REM Default: quiet (unless --verbose is used)
REM set "BUILD_VERBOSITY=quiet"

REM Maximum parallel build processes
REM Default: Auto-detect based on CPU cores
REM set "BUILD_MAXCPUCOUNT=4"

REM Target framework (if multiple frameworks in solution)
REM set "TARGET_FRAMEWORK=net8.0"

REM ----------------------------------------------------------------------------
REM Environment-Specific Overrides
REM ----------------------------------------------------------------------------

REM Example: Adjust settings based on environment
if "%CI%"=="true" (
    REM CI/CD environment - stricter settings
    set "MIN_COVERAGE=75"
    set "BUILD_VERBOSITY=normal"
)

if "%ENVIRONMENT%"=="Development" (
    REM Development environment - relaxed settings for faster iteration
    set "MIN_COVERAGE=60"
    set "TEST_TIMEOUT_THRESHOLD=10000"
)

REM ----------------------------------------------------------------------------
REM Version Tracking
REM ----------------------------------------------------------------------------

REM Build Scripts Version: 1.0.0
REM Last Updated: 2025-10-02
REM Source: https://github.com/vismathomas/build-scripts
