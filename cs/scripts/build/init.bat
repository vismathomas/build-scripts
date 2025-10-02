@echo off
REM ============================================================================
REM Build Initialization Script
REM ============================================================================
REM Sets up environment variables and validates prerequisites for the build.
REM Supports project-specific configuration via build.config.bat
REM ============================================================================

REM ----------------------------------------------------------------------------
REM Default Configuration (Override via build.config.bat)
REM ----------------------------------------------------------------------------

REM Auto-detect solution file if not specified
set "SOLUTION="
set "BUILD_FILTER="

REM Default coverage threshold (1% = effectively disabled, set higher in config)
set "MIN_COVERAGE=1"

REM Verbose mode (0=quiet, 1=verbose)
set "VERBOSE_MODE=0"

REM Test timeout threshold in milliseconds
set "TEST_TIMEOUT_THRESHOLD=5000"

REM Build pipeline start time
set "BUILD_PIPELINE_START_TIME=%TIME%"

REM ----------------------------------------------------------------------------
REM Load Project-Specific Configuration
REM ----------------------------------------------------------------------------

REM Check for build.config.bat in project root (2 levels up from scripts/build/)
set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%..\.."
set "BUILD_CONFIG=%PROJECT_ROOT%\build.config.bat"

if exist "%BUILD_CONFIG%" (
    if %VERBOSE_MODE%==1 echo [VERBOSE] Loading configuration from %BUILD_CONFIG%
    call "%BUILD_CONFIG%"
    if errorlevel 1 (
        echo ERROR: Failed to load build.config.bat
        exit /b 1
    )
) else (
    if %VERBOSE_MODE%==1 echo [VERBOSE] No build.config.bat found, using defaults
)

REM ----------------------------------------------------------------------------
REM Parse Command Line Arguments
REM ----------------------------------------------------------------------------

:parse_args
if "%~1"=="" goto args_done
if /i "%~1"=="--verbose" set "VERBOSE_MODE=1"
shift
goto parse_args
:args_done

REM ----------------------------------------------------------------------------
REM Auto-detect Solution File (if not configured)
REM ----------------------------------------------------------------------------

if not defined SOLUTION (
    if %VERBOSE_MODE%==1 echo [VERBOSE] Auto-detecting solution file...
    
    REM Find .sln file in project root
    for %%F in ("%PROJECT_ROOT%\*.sln") do (
        if not defined SOLUTION (
            set "SOLUTION=%%~nxF"
            if %VERBOSE_MODE%==1 echo [VERBOSE] Found solution: %%~nxF
        )
    )
    
    if not defined SOLUTION (
        echo ERROR: No solution file found and SOLUTION not configured in build.config.bat
        echo.
        echo Please either:
        echo   1. Create build.config.bat with: set "SOLUTION=YourProject.sln"
        echo   2. Place a .sln file in the project root
        exit /b 1
    )
)

)

REM ----------------------------------------------------------------------------
REM Display Configuration (Verbose Mode)
REM ----------------------------------------------------------------------------

if %VERBOSE_MODE%==1 (
  echo ========================================
  echo   BUILD CONFIGURATION
  echo ========================================
  echo Solution: %SOLUTION%
  if defined BUILD_FILTER echo Build Filter: %BUILD_FILTER%
  echo Min Coverage: %MIN_COVERAGE%%%
  echo Test Timeout Threshold: %TEST_TIMEOUT_THRESHOLD%ms
  echo Verbose Mode: Enabled
  echo Project Root: %PROJECT_ROOT%
  echo ========================================
  echo.
)

REM ----------------------------------------------------------------------------
REM Validate Prerequisites
REM ----------------------------------------------------------------------------

REM Check for dotnet CLI
where dotnet >nul 2>nul
if errorlevel 1 (
  echo ERROR: dotnet CLI not found on PATH.
  echo.
  echo Please install .NET SDK from: https://dotnet.microsoft.com/download
  exit /b 1
)

if %VERBOSE_MODE%==1 (
  echo [VERBOSE] Prerequisites check:
  dotnet --version
  echo.
)

REM ----------------------------------------------------------------------------
REM Create Artifact Directories
REM ----------------------------------------------------------------------------

if not exist "%PROJECT_ROOT%\artifacts" mkdir "%PROJECT_ROOT%\artifacts" >nul 2>nul
if not exist "%PROJECT_ROOT%\artifacts\coverage" mkdir "%PROJECT_ROOT%\artifacts\coverage" >nul 2>nul

if %VERBOSE_MODE%==1 (
  echo [VERBOSE] Artifacts directory: %PROJECT_ROOT%\artifacts
  echo [VERBOSE] Coverage directory: %PROJECT_ROOT%\artifacts\coverage
  echo [VERBOSE] Starting build process at %TIME%
  echo.
)

exit /b 0
