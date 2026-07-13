$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
. (Join-Path $repoRoot 'App\NetworkToolkit\Utilities\AtomicState.ps1')
. (Join-Path $repoRoot 'App\NetworkToolkit\Utilities\Performance.ps1')

function Assert-True {
    param([bool]$Condition,[string]$Message)
    if(!$Condition){ throw $Message }
}

function Invoke-GuiPerformanceProbe {
    param([string]$ResultPath)
    $timer = [Diagnostics.Stopwatch]::StartNew()
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $repoRoot 'App\NetworkToolkit.ps1') -SmokeTest -PerformanceResultPath $ResultPath | Out-Host
    $timer.Stop()
    Assert-True ($LASTEXITCODE -eq 0) 'GUI performance probe failed.'
    $result = Get-Content -LiteralPath $ResultPath -Raw | ConvertFrom-Json
    foreach($required in @('gui.startup.shell','gui.tab.first-render','gui.tab.switch')){
        Assert-True (@($result.timings | Where-Object name -eq $required).Count -gt 0) "GUI timing '$required' was not emitted."
    }
    Assert-True (@($result.timings | Where-Object { $_.budgetState -eq 'Exceeded' }).Count -eq 0) 'An internal GUI performance budget was exceeded.'
    return [pscustomobject]@{ElapsedMs=$timer.ElapsedMilliseconds;Result=$result}
}

$root = Join-Path ([IO.Path]::GetTempPath()) ('ntk-performance-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $root -Force | Out-Null
$Global:NTKPaths = [pscustomobject]@{Logs=(Join-Path $root 'Logs')}
try {
    $script:calls = 0
    $handle = Start-NTKPerformanceRun -Name 'cache-fixture'
    $first = Get-NTKRunObservation -Key 'fixture.value' -Provider 'fixture-provider' -Collector { $script:calls++; 'value' }
    $second = Get-NTKRunObservation -Key 'fixture.value' -Provider 'fixture-provider' -Collector { $script:calls++; 'changed' }
    Assert-True ($first.Value -eq 'value' -and !$first.FromCache) 'First observation was not collected.'
    Assert-True ($second.Value -eq 'value' -and $second.FromCache) 'Repeated observation was not served from the run cache.'
    Assert-True ($script:calls -eq 1) 'Observation collector ran more than once within a run.'

    Clear-NTKRunObservation -Key 'fixture.value'
    $third = Get-NTKRunObservation -Key 'fixture.value' -Provider 'fixture-provider' -Collector { $script:calls++; 'refreshed' }
    Assert-True ($third.Value -eq 'refreshed' -and $script:calls -eq 2) 'Explicit observation invalidation did not requery.'

    $script:failures = 0
    $failed = Get-NTKRunObservation -Key 'fixture.failure' -Provider 'broken-provider' -Collector { $script:failures++; throw 'provider fixture' }
    $suppressed = Get-NTKRunObservation -Key 'fixture.failure.second' -Provider 'broken-provider' -Collector { $script:failures++; 'unexpected' }
    Assert-True ($failed.State -eq 'Failed' -and $suppressed.State -eq 'ProviderUnavailable') 'Run-scoped provider failure was not cached.'
    Assert-True ($script:failures -eq 1) 'Failed provider was retried inside the same run.'

    Assert-True ((Add-NTKPerformanceTiming -Name 'fixture.within' -DurationMs 5 -BudgetMs 10).budgetState -eq 'WithinBudget') 'Within-budget timing was classified incorrectly.'
    Assert-True ((Add-NTKPerformanceTiming -Name 'fixture.exceeded' -DurationMs 11 -BudgetMs 10).budgetState -eq 'Exceeded') 'Exceeded timing was classified incorrectly.'
    $quickBudget = Get-NTKPerformanceBudgetMs -Name 'workflow.quick-diagnosis'
    Assert-True ($quickBudget -gt 0 -and !(Test-NTKPerformanceBudgetExpired -Name 'workflow.quick-diagnosis' -ElapsedMs ($quickBudget - 1))) 'Quick Diagnosis budget expired early.'
    Assert-True (Test-NTKPerformanceBudgetExpired -Name 'workflow.quick-diagnosis' -ElapsedMs $quickBudget) 'Quick Diagnosis budget did not expire at its boundary.'
    $cacheResult = Join-Path $root 'cache-result.json'
    [void](Complete-NTKPerformanceRun -Handle $handle -ResultPath $cacheResult)
    Assert-True ($null -eq $Global:NTKPerformanceRunContext) 'Performance run context leaked after completion.'

    $retryHandle = Start-NTKPerformanceRun -Name 'retry-fixture'
    $retry = Get-NTKRunObservation -Key 'fixture.failure.second' -Provider 'broken-provider' -Collector { $script:failures++; 'recovered' }
    Assert-True ($retry.State -eq 'Available' -and $script:failures -eq 2) 'Provider failure leaked across run scope.'
    [void](Complete-NTKPerformanceRun -Handle $retryHandle -ResultPath (Join-Path $root 'retry-result.json'))

    $cold = Invoke-GuiPerformanceProbe -ResultPath (Join-Path $root 'gui-cold.json')
    $warm = Invoke-GuiPerformanceProbe -ResultPath (Join-Path $root 'gui-warm.json')
    Assert-True ($cold.ElapsedMs -le (Get-NTKPerformanceBudgetMs -Name 'gui.process.cold')) "Cold GUI process exceeded budget: $($cold.ElapsedMs) ms."
    Assert-True ($warm.ElapsedMs -le (Get-NTKPerformanceBudgetMs -Name 'gui.process.warm')) "Warm GUI process exceeded budget: $($warm.ElapsedMs) ms."

    Write-Host ("Performance/cache fixtures passed. Cold={0} ms; Warm={1} ms." -f $cold.ElapsedMs,$warm.ElapsedMs) -ForegroundColor Green
}
finally {
    $Global:NTKPerformanceRunContext = $null
    Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue
}
