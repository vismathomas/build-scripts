@echo off
setlocal ENABLEDELAYEDEXPANSION

echo [3/4] Running tests with coverage...

if not defined VERBOSE_MODE set "VERBOSE_MODE=0"

set "TEMP_OUTPUT=%TEMP%\build_test_output_%RANDOM%.txt"
set "TEMP_DIAG=%TEMP%\build_test_diag_%RANDOM%.txt"
set "COVERAGE_RAW_DIR=artifacts\coverage\raw"
set "COVERAGE_OUTPUT=artifacts\coverage\coverage.cobertura.xml"
set "EXIT_CODE=0"

if exist "%COVERAGE_RAW_DIR%" rd /s /q "%COVERAGE_RAW_DIR%" >nul 2>&1

if %VERBOSE_MODE%==1 (
  echo [VERBOSE] Test execution started at %TIME%
  set "TEST_START_TIME=%TIME%"
  echo [VERBOSE] Running: dotnet test %BUILD_FILTER% -c Release --no-build --collect:"XPlat Code Coverage"
  echo [VERBOSE] Coverage output directory: %COVERAGE_RAW_DIR%
  echo.
  call dotnet test %BUILD_FILTER% -c Release --no-build --nologo --verbosity normal --collect:"XPlat Code Coverage" --results-directory "%COVERAGE_RAW_DIR%" > "%TEMP_OUTPUT%" 2>&1
  echo.
  echo [VERBOSE] Test execution completed at %TIME% (started at !TEST_START_TIME!)
  if exist "%TEMP_OUTPUT%" (
    for %%F in ("%TEMP_OUTPUT%") do echo [VERBOSE] Test output file size: %%~zF bytes (modified %%~tF)
  ) else (
    echo [VERBOSE] Warning: test output file missing!
  )
  echo.
) else (
  call dotnet test %BUILD_FILTER% -c Release --no-build --nologo --verbosity quiet --collect:"XPlat Code Coverage" --results-directory "%COVERAGE_RAW_DIR%" > "%TEMP_OUTPUT%" 2>&1
)

if errorlevel 1 (
  echo ERROR: dotnet test execution failed.
  if exist "%TEMP_OUTPUT%" type "%TEMP_OUTPUT%"
  set "EXIT_CODE=1"
  goto CleanupSection
)

if %VERBOSE_MODE%==1 (
  echo [VERBOSE] Checking test output for failures...
)

set "COVERAGE_SOURCE="
for /f "delims=" %%F in ('dir /b /s "%COVERAGE_RAW_DIR%\coverage.cobertura.xml" 2^>nul') do (
  if not defined COVERAGE_SOURCE (
    set "COVERAGE_SOURCE=%%F"
  )
)

if not defined COVERAGE_SOURCE (
  echo WARNING: Coverage data not found in %COVERAGE_RAW_DIR%.
  set "EXIT_CODE=1"
) else (
  if %VERBOSE_MODE%==1 (
    echo [VERBOSE] Coverage data located at: !COVERAGE_SOURCE!
    echo [VERBOSE] Copying coverage report to: %COVERAGE_OUTPUT%
  )
  if not exist "artifacts\coverage" mkdir "artifacts\coverage" >nul 2>&1
  copy /Y "!COVERAGE_SOURCE!" "%COVERAGE_OUTPUT%" >nul 2>&1
)

goto CleanupSection

:CleanupSection
timeout /t 1 /nobreak >nul 2>&1
del "%TEMP_OUTPUT%" >nul 2>&1
if exist "%TEMP_DIAG%" rd /s /q "%TEMP_DIAG%" >nul 2>&1

if %EXIT_CODE%==0 (
  echo       ✓ Tests completed successfully
)

if %EXIT_CODE%==0 if exist "%COVERAGE_RAW_DIR%" rd /s /q "%COVERAGE_RAW_DIR%" >nul 2>&1

endlocal & exit /b %EXIT_CODE%
