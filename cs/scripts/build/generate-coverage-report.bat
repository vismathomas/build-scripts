@echo off
setlocal ENABLEDELAYEDEXPANSION

if not defined VERBOSE_MODE set "VERBOSE_MODE=0"

if %VERBOSE_MODE%==1 (
  echo [VERBOSE] Installing/verifying reportgenerator tool
)
dotnet tool install --global dotnet-reportgenerator-globaltool >nul 2>nul

if %VERBOSE_MODE%==1 (
  echo [VERBOSE] Generating coverage report at %TIME%
  set "COVERAGE_START_TIME=%TIME%"
  reportgenerator -reports:"artifacts\coverage\coverage.cobertura.xml" -targetdir:"artifacts\coverage\report" -reporttypes:Html;TextSummary
) else (
  reportgenerator -reports:"artifacts\coverage\coverage.cobertura.xml" -targetdir:"artifacts\coverage\report" -reporttypes:Html;TextSummary >nul 2>&1
)
if errorlevel 1 (
  echo ERROR: Coverage report generation failed.
  endlocal & exit /b 1
)

if %VERBOSE_MODE%==1 (
  echo [VERBOSE] Coverage report generated at %TIME% (started at !COVERAGE_START_TIME!)
  echo [VERBOSE] Report location: artifacts\coverage\report\index.html
)

endlocal & exit /b 0
