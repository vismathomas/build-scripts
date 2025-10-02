@echo off

if %VERBOSE_MODE%==1 (
  echo.
  echo [VERBOSE] Build process completed at %TIME% (started at %BUILD_PIPELINE_START_TIME%)
)

echo.
echo ========================================
echo   BUILD SUCCEEDED
echo ========================================
echo Coverage report: artifacts\coverage\report\index.html
echo.
echo Additional tools available:
echo   - Full QA suite: pwsh -File scripts\qa-all.ps1
if %VERBOSE_MODE%==1 (
  echo   - Run with --verbose flag for detailed logging
)
echo.

exit /b 0
