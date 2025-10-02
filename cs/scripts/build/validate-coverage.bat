@echo off
setlocal ENABLEDELAYEDEXPANSION

echo [4/4] Validating coverage...
set "COVERAGE_PERCENT="
set "COVERAGE_INT="
set "EXIT_CODE=0"
set "COVERAGE_PERCENT_RAW="

if not exist "artifacts\coverage\report\Summary.txt" (
  echo WARNING: Could not determine coverage percentage from report
  if %VERBOSE_MODE%==1 (
    echo [VERBOSE] Summary.txt not found at artifacts\coverage\report\Summary.txt
  )
  goto Finish
)

if %VERBOSE_MODE%==1 (
  echo [VERBOSE] Reading coverage summary from Summary.txt
)

for /f "tokens=3 delims=: " %%a in ('findstr /C:"Line coverage:" "artifacts\coverage\report\Summary.txt"') do if not defined COVERAGE_PERCENT_RAW call set "COVERAGE_PERCENT_RAW=%%a"

if defined COVERAGE_PERCENT_RAW (
  if "!COVERAGE_PERCENT_RAW:~-1!"=="%" (
    set "COVERAGE_PERCENT=!COVERAGE_PERCENT_RAW:~0,-1!"
  ) else (
    set "COVERAGE_PERCENT=!COVERAGE_PERCENT_RAW!"
  )
  set "COVERAGE_PERCENT=!COVERAGE_PERCENT: =!"
)

if defined COVERAGE_PERCENT (
  for /f "tokens=1 delims=." %%c in ("!COVERAGE_PERCENT!") do set "COVERAGE_INT=%%c"
)

if %VERBOSE_MODE%==1 (
  echo [VERBOSE] Coverage: !COVERAGE_PERCENT!%% (integer: !COVERAGE_INT!%%, minimum: %MIN_COVERAGE%%% )
)

if "!COVERAGE_INT!"=="" (
  echo WARNING: Coverage percentage could not be parsed.
) else if !COVERAGE_INT! LSS %MIN_COVERAGE% (
  echo ERROR: Test coverage !COVERAGE_PERCENT!%% is below minimum required %MIN_COVERAGE%%%
  echo        Report: artifacts\coverage\report\index.html
  set "EXIT_CODE=1"
) else (
  echo       ✓ Coverage validated: !COVERAGE_PERCENT!%% (minimum: %MIN_COVERAGE%%% )
)

:Finish
endlocal & exit /b %EXIT_CODE%
