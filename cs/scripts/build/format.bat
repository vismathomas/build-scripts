@echo off

echo [1/4] Formatting code...
if %VERBOSE_MODE%==1 (
  echo [VERBOSE] Running: dotnet format %SOLUTION%
  set "FORMAT_START_TIME=%TIME%"
)

if %VERBOSE_MODE%==1 (
  dotnet format %SOLUTION% --verbosity minimal
) else (
  dotnet format %SOLUTION% --verbosity quiet >nul 2>nul
)
if errorlevel 1 (
  echo ERROR: Formatting failed.
  dotnet format %SOLUTION% --verbosity minimal
  exit /b 1
)

if %VERBOSE_MODE%==1 (
  echo [VERBOSE] Formatting completed at %TIME% (started at !FORMAT_START_TIME!)
)
echo       ✓ Code formatting completed

exit /b 0
