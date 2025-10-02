param(
    [string]$TestOutputFile,
    [int]$ThresholdMs = 5000
)

$ErrorActionPreference = 'Continue'

if (-not (Test-Path $TestOutputFile)) {
    Write-Host "[VERBOSE] Test output file not found: $TestOutputFile" -ForegroundColor Yellow
    exit 0
}

try {
    # Read file with timeout protection
    $content = [System.IO.File]::ReadAllText($TestOutputFile)
    
    # Simple line-by-line parsing instead of complex regex
    $slowTests = @()
    $lines = $content -split "`n"
    
    foreach ($line in $lines) {
        # Match pattern like: "  Passed TestName [123ms]" or "  Failed TestName [1.23s]"
        if ($line -match '^\s*(Passed|Failed)\s+(.+?)\s+\[(\d+(?:\.\d+)?)\s*(ms|s)\]') {
            $testName = $matches[2].Trim()
            $time = [double]$matches[3]
            $unit = $matches[4]
            
            # Convert to milliseconds
            $timeMs = if ($unit -eq 's') { $time * 1000 } else { $time }
            
            # Check if test is slow
            if ($timeMs -gt $ThresholdMs) {
                $slowTests += [PSCustomObject]@{
                    Test = $testName
                    TimeMs = [math]::Round($timeMs, 2)
                    TimeFormatted = if($timeMs -ge 1000) {
                        [math]::Round($timeMs/1000, 2).ToString() + 's'
                    } else {
                        $timeMs.ToString() + 'ms'
                    }
                }
            }
        }
    }
    
    # Report slow tests
    if ($slowTests.Count -gt 0) {
        Write-Host ''
        Write-Host '========================================' -ForegroundColor Red
        Write-Host '  WARNING: SLOW TESTS DETECTED' -ForegroundColor Red
        Write-Host '========================================' -ForegroundColor Red
        Write-Host ''
        Write-Host "The following tests took longer than $($ThresholdMs/1000) seconds:" -ForegroundColor Yellow
        Write-Host ''
        
        foreach ($t in $slowTests | Sort-Object -Property TimeMs -Descending) {
            Write-Host "  $($t.TimeFormatted) - $($t.Test)" -ForegroundColor Yellow
        }
        
        Write-Host ''
        Write-Host 'These tests should be optimized or may indicate a problem.' -ForegroundColor Yellow
        Write-Host ''
    } else {
        Write-Host "[VERBOSE] No slow tests detected (all tests completed in <$($ThresholdMs/1000)s)" -ForegroundColor Green
    }
} catch {
    Write-Host "[VERBOSE] Error analyzing test output: $_" -ForegroundColor Yellow
    exit 0
}