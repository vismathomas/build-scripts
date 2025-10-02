@echo off
REM ============================================================================
REM Full Build Pipeline Orchestrator for .NET Projects
REM ============================================================================
REM This script orchestrates a complete build pipeline including:
REM   - Code formatting
REM   - Solution compilation
REM   - Test execution with coverage
REM   - Coverage reporting and validation
REM
REM For usage information, run: build-full.bat --help
REM ============================================================================

setlocal ENABLEDELAYEDEXPANSION

set "ALL_ARGS=%*"

REM ----------------------------------------------------------------------------
REM Default Stage Flags
REM ----------------------------------------------------------------------------

set "RUN_BACKEND=1"
set "RUN_FRONTEND=0"
set "RUN_FORMAT=1"
set "RUN_BUILD=1"
set "RUN_TESTS=1"
set "RUN_COV_REPORT=1"
set "RUN_COV_VALIDATE=1"
set "DISPLAY_HELP=0"

REM ----------------------------------------------------------------------------
REM Parse Command Line Arguments
REM ----------------------------------------------------------------------------

:parse_args
if "%~1"=="" goto args_done
set "ARG=%~1"

if /i "%ARG%"=="--help" set "DISPLAY_HELP=1"
if /i "%ARG%"=="--frontend" set "RUN_FRONTEND=1"
if /i "%ARG%"=="--frontend-only" (
	set "RUN_FRONTEND=1"
	set "RUN_BACKEND=0"
)
if /i "%ARG%"=="--backend-only" (
	set "RUN_BACKEND=1"
	set "RUN_FRONTEND=0"
)
if /i "%ARG%"=="--skip-format" set "RUN_FORMAT=0"
if /i "%ARG%"=="--skip-build" set "RUN_BUILD=0"
if /i "%ARG%"=="--skip-tests" (
	set "RUN_TESTS=0"
	set "RUN_COV_REPORT=0"
	set "RUN_COV_VALIDATE=0"
)
if /i "%ARG%"=="--skip-coverage-report" set "RUN_COV_REPORT=0"
if /i "%ARG%"=="--skip-coverage-validate" set "RUN_COV_VALIDATE=0"

shift
goto parse_args

:args_done

REM ----------------------------------------------------------------------------
REM Display Help
REM ----------------------------------------------------------------------------

if %DISPLAY_HELP%==1 (
	call :print_usage
	endlocal & exit /b 0
)

REM ----------------------------------------------------------------------------
REM Stage Dependency Logic
REM ----------------------------------------------------------------------------

if %RUN_BACKEND%==0 (
	set "RUN_FORMAT=0"
	set "RUN_BUILD=0"
	set "RUN_TESTS=0"
	set "RUN_COV_REPORT=0"
	set "RUN_COV_VALIDATE=0"
)

if %RUN_TESTS%==0 (
	set "RUN_COV_REPORT=0"
	set "RUN_COV_VALIDATE=0"
)

if %RUN_BACKEND%==0 if %RUN_FRONTEND%==0 (
	echo No build stages selected. Use --help to see available options.
	endlocal & exit /b 0
)

REM ----------------------------------------------------------------------------
REM Determine Script Paths
REM ----------------------------------------------------------------------------

REM This script is in the same directory as the build scripts
set "ROOT_DIR=%~dp0"
set "BUILD_SCRIPTS_DIR=%ROOT_DIR%scripts\build"

REM Verify build scripts directory exists
if not exist "%BUILD_SCRIPTS_DIR%" (
	echo ERROR: Build scripts directory not found: %BUILD_SCRIPTS_DIR%
	echo.
	echo Expected directory structure:
	echo   your-project\
	echo   ├── build-full.bat            (this script)
	echo   └── scripts\
	echo       └── build\
	echo           ├── init.bat
	echo           ├── format.bat
	echo           └── ... (other scripts)
	echo.
	echo Please ensure the build scripts are properly copied to your project.
	goto :error_missing
)

REM ----------------------------------------------------------------------------
REM Execute Backend Build Pipeline
REM ----------------------------------------------------------------------------

if %RUN_BACKEND%==1 (
	call "%BUILD_SCRIPTS_DIR%\init.bat" %ALL_ARGS%
	if errorlevel 1 goto :error

	if %RUN_FORMAT%==1 (
		call "%BUILD_SCRIPTS_DIR%\format.bat"
		if errorlevel 1 goto :error
	)

	if %RUN_BUILD%==1 (
		call "%BUILD_SCRIPTS_DIR%\build-sln.bat"
		if errorlevel 1 goto :error
	)

	if %RUN_TESTS%==1 (
		call "%BUILD_SCRIPTS_DIR%\run-tests.bat"
		if errorlevel 1 goto :error
	) else (
		if %RUN_COV_REPORT%==1 set "RUN_COV_REPORT=0"
		if %RUN_COV_VALIDATE%==1 set "RUN_COV_VALIDATE=0"
	)

	if %RUN_COV_REPORT%==1 (
		call "%BUILD_SCRIPTS_DIR%\generate-coverage-report.bat"
		if errorlevel 1 goto :error
	)

	if %RUN_COV_VALIDATE%==1 (
		call "%BUILD_SCRIPTS_DIR%\validate-coverage.bat"
		if errorlevel 1 goto :error
	)

	call "%BUILD_SCRIPTS_DIR%\finalize.bat"
	if errorlevel 1 goto :error
)

REM ----------------------------------------------------------------------------
REM Execute Frontend Build (if applicable)
REM ----------------------------------------------------------------------------

if %RUN_FRONTEND%==1 (
	if defined FRONTEND_SCRIPT (
		if exist "%FRONTEND_SCRIPT%" (
			call "%FRONTEND_SCRIPT%" %ALL_ARGS%
			if errorlevel 1 goto :error
			if %RUN_BACKEND%==0 (
				echo.
				echo Frontend build completed successfully.
			)
		) else (
			echo WARNING: FRONTEND_SCRIPT defined but not found: %FRONTEND_SCRIPT%
		)
	) else (
		echo WARNING: Frontend build requested but FRONTEND_SCRIPT not configured
		echo   Configure in build.config.bat: set "FRONTEND_SCRIPT=path\to\frontend-build.bat"
	)
)

REM ----------------------------------------------------------------------------
REM Success Exit
REM ----------------------------------------------------------------------------

:success
endlocal & exit /b 0

REM ----------------------------------------------------------------------------
REM Error Handling
REM ----------------------------------------------------------------------------

:error_missing
set "EXIT_CODE=1"
endlocal & exit /b %EXIT_CODE%

:error
set "EXIT_CODE=%ERRORLEVEL%"
endlocal & exit /b %EXIT_CODE%

REM ----------------------------------------------------------------------------
REM Help Message
REM ----------------------------------------------------------------------------

:print_usage
echo Usage: build-full.bat [options]
echo.
echo Full build pipeline for .NET projects with configurable stages.
echo.
echo General:
echo   --help               Show this help message and exit
echo   --verbose            Forwarded to backend scripts for detailed logging
echo   --frontend           Run the frontend build after backend stages
echo   --frontend-only      Skip backend stages and run only the frontend build
echo   --backend-only       Run backend stages only (default)
echo.
echo Backend stage control:
echo   --skip-format               Skip dotnet format
echo   --skip-build                Skip dotnet build
echo   --skip-openapi              Skip OpenAPI validation
echo   --skip-tests                Skip dotnet test and dependent coverage stages
echo   --skip-coverage-report      Skip coverage report generation
echo   --skip-coverage-validate    Skip coverage threshold validation
echo.
echo Configuration:
echo   Create build.config.bat in project root to configure:
echo     - SOLUTION: Solution file name
echo     - BUILD_FILTER: Build filter file (optional)
echo     - MIN_COVERAGE: Minimum coverage percentage
echo     - TEST_TIMEOUT_THRESHOLD: Test timeout in milliseconds
echo     - FRONTEND_SCRIPT: Frontend build script path
echo.
echo Examples:
echo   build-full.bat                    # Full build with defaults
echo   build-full.bat --verbose          # Full build with detailed output
echo   build-full.bat --skip-tests       # Build without running tests
echo   build-full.bat --frontend         # Build both backend and frontend
echo   build-full.bat --frontend-only    # Build frontend only
echo.
echo For more information, see: https://github.com/vismathomas/build-scripts
goto :eof
