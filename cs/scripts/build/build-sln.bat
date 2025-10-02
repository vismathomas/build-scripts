@echo off

echo [2/4] Building solution...
if %VERBOSE_MODE%==1 (
  echo [VERBOSE] Running: dotnet build %BUILD_FILTER% -c Release --verbosity normal
  set "BUILD_START_TIME=%TIME%"
)

if %VERBOSE_MODE%==1 (
  dotnet build %BUILD_FILTER% -c Release --verbosity normal --nologo
) else (
  set "TEMP_BUILD_OUTPUT=%TEMP%\build_output_%RANDOM%.txt"
  dotnet build %BUILD_FILTER% -c Release --verbosity quiet --nologo 2>&1 > "!TEMP_BUILD_OUTPUT!"
  findstr /C:"Warnings were encountered" "!TEMP_BUILD_OUTPUT!" >nul
  if not errorlevel 1 (
    echo WARNING: Workspace warnings detected. Run with --verbose flag for diagnostic details.
  )
  del "!TEMP_BUILD_OUTPUT!" >nul 2>&1
)
if errorlevel 1 (
  echo ERROR: Build failed. Showing details:
  dotnet build %BUILD_FILTER% -c Release --verbosity minimal --nologo
  exit /b 1
)

if %VERBOSE_MODE%==1 (
  echo [VERBOSE] Build completed at %TIME% (started at !BUILD_START_TIME!)
)
echo       ✓ Build completed successfully

exit /b 0
