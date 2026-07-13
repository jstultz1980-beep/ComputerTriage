# =====================================================================
# Performance.ps1
# Structured timing, budgets, provider health, and run-scoped cache
# =====================================================================

$Global:NTKPerformanceRunContext = $null
$Global:NTKPerformanceDefaultLogRoot = Join-Path (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))) 'Runtime\Logs'

function Global:Get-NTKPerformanceBudgetManifestPath {
    return Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) 'manifests\performance-budgets.json'
}

function Global:Get-NTKPerformanceBudgets {
    $path = Get-NTKPerformanceBudgetManifestPath
    if(!(Test-Path -LiteralPath $path -PathType Leaf)){ return [pscustomobject]@{} }
    return (Get-Content -LiteralPath $path -Raw | ConvertFrom-Json).budgetsMs
}

function Global:Get-NTKPerformanceBudgetMs {
    param([Parameter(Mandatory=$true)][string]$Name,[object]$Context = $Global:NTKPerformanceRunContext)
    $budgets = if($Context -and $Context.Budgets){$Context.Budgets}else{Get-NTKPerformanceBudgets}
    $property = $budgets.PSObject.Properties[$Name]
    if($property){ return [long]$property.Value }
    return $null
}

function Global:Start-NTKPerformanceRun {
    param([Parameter(Mandatory=$true)][string]$Name,[string]$RunId,[switch]$ReuseActive)
    if($ReuseActive -and $Global:NTKPerformanceRunContext){
        return [pscustomobject]@{ Context=$Global:NTKPerformanceRunContext; OwnsContext=$false; Name=$Name }
    }
    $parentContext = $Global:NTKPerformanceRunContext
    $context = [pscustomobject]@{
        SchemaVersion = '1.0'
        RunId = if($RunId){$RunId}else{'NTK-PERF-' + [guid]::NewGuid().ToString('N')}
        Name = $Name
        StartedAtUtc = [datetimeoffset]::UtcNow
        Stopwatch = [Diagnostics.Stopwatch]::StartNew()
        Budgets = Get-NTKPerformanceBudgets
        Timings = New-Object Collections.ArrayList
        Observations = @{}
        ProviderHealth = @{}
        ParentContext = $parentContext
    }
    $Global:NTKPerformanceRunContext = $context
    return [pscustomobject]@{ Context=$context; OwnsContext=$true; Name=$Name }
}

function Global:Add-NTKPerformanceTiming {
    param(
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][long]$DurationMs,
        [hashtable]$Tags = @{},
        [Nullable[long]]$BudgetMs,
        [object]$Context = $Global:NTKPerformanceRunContext
    )
    if(!$Context){ return $null }
    $budget = if($null -ne $BudgetMs){[long]$BudgetMs}else{Get-NTKPerformanceBudgetMs -Name $Name -Context $Context}
    $record = [pscustomobject][ordered]@{
        name = $Name
        durationMs = $DurationMs
        budgetMs = $budget
        budgetState = if($null -eq $budget){'Unbudgeted'}elseif($DurationMs -le $budget){'WithinBudget'}else{'Exceeded'}
        capturedAtUtc = [datetimeoffset]::UtcNow.ToString('o')
        tags = [pscustomobject]$Tags
    }
    [void]$Context.Timings.Add($record)
    return $record
}

function Global:Get-NTKPerformanceRemainingMs {
    param([Parameter(Mandatory=$true)][string]$BudgetName,[object]$Context=$Global:NTKPerformanceRunContext)
    if(!$Context){ return $null }
    $budget = Get-NTKPerformanceBudgetMs -Name $BudgetName -Context $Context
    if($null -eq $budget){ return $null }
    return [Math]::Max(0,[long]$budget - [long]$Context.Stopwatch.ElapsedMilliseconds)
}

function Global:Test-NTKPerformanceBudgetExpired {
    param([Parameter(Mandatory=$true)][string]$Name,[Parameter(Mandatory=$true)][long]$ElapsedMs,[object]$Context=$Global:NTKPerformanceRunContext)
    $budget = Get-NTKPerformanceBudgetMs -Name $Name -Context $Context
    if($null -eq $budget){ return $false }
    return ($ElapsedMs -ge $budget)
}

function Global:Get-NTKRunObservation {
    param(
        [Parameter(Mandatory=$true)][string]$Key,
        [Parameter(Mandatory=$true)][string]$Provider,
        [Parameter(Mandatory=$true)][scriptblock]$Collector,
        [switch]$RetryFailedProvider,
        [object]$Context = $Global:NTKPerformanceRunContext
    )
    if(!$Context){
        $watch = [Diagnostics.Stopwatch]::StartNew()
        try { return [pscustomobject]@{Key=$Key;Provider=$Provider;State='Available';Value=(& $Collector);Error=$null;FromCache=$false;CollectedAtUtc=[datetimeoffset]::UtcNow.ToString('o');DurationMs=$watch.ElapsedMilliseconds} }
        catch { return [pscustomobject]@{Key=$Key;Provider=$Provider;State='Failed';Value=$null;Error=$_.Exception.Message;FromCache=$false;CollectedAtUtc=[datetimeoffset]::UtcNow.ToString('o');DurationMs=$watch.ElapsedMilliseconds} }
        finally { $watch.Stop() }
    }
    if($Context.Observations.ContainsKey($Key)){
        $cached = $Context.Observations[$Key]
        return [pscustomobject]@{Key=$cached.Key;Provider=$cached.Provider;State=$cached.State;Value=$cached.Value;Error=$cached.Error;FromCache=$true;CollectedAtUtc=$cached.CollectedAtUtc;DurationMs=$cached.DurationMs}
    }
    if(!$RetryFailedProvider -and $Context.ProviderHealth.ContainsKey($Provider) -and $Context.ProviderHealth[$Provider].State -eq 'Failed'){
        $health = $Context.ProviderHealth[$Provider]
        return [pscustomobject]@{Key=$Key;Provider=$Provider;State='ProviderUnavailable';Value=$null;Error=$health.Error;FromCache=$true;CollectedAtUtc=$health.CapturedAtUtc;DurationMs=0}
    }
    $watch = [Diagnostics.Stopwatch]::StartNew()
    try {
        $value = & $Collector
        $watch.Stop()
        $record = [pscustomobject]@{Key=$Key;Provider=$Provider;State='Available';Value=$value;Error=$null;FromCache=$false;CollectedAtUtc=[datetimeoffset]::UtcNow.ToString('o');DurationMs=$watch.ElapsedMilliseconds}
        $Context.ProviderHealth[$Provider] = [pscustomobject]@{State='Available';Error=$null;CapturedAtUtc=$record.CollectedAtUtc}
    }
    catch {
        $watch.Stop()
        $record = [pscustomobject]@{Key=$Key;Provider=$Provider;State='Failed';Value=$null;Error=$_.Exception.Message;FromCache=$false;CollectedAtUtc=[datetimeoffset]::UtcNow.ToString('o');DurationMs=$watch.ElapsedMilliseconds}
        $Context.ProviderHealth[$Provider] = [pscustomobject]@{State='Failed';Error=$record.Error;CapturedAtUtc=$record.CollectedAtUtc}
    }
    $Context.Observations[$Key] = $record
    [void](Add-NTKPerformanceTiming -Name ("provider.{0}" -f $Provider) -DurationMs $record.DurationMs -Tags @{Observation=$Key;State=$record.State} -Context $Context)
    return $record
}

function Global:Get-NTKRunObservationValue {
    param([Parameter(Mandatory=$true)][string]$Key,[Parameter(Mandatory=$true)][string]$Provider,[Parameter(Mandatory=$true)][scriptblock]$Collector,[switch]$Required,[switch]$RetryFailedProvider)
    $observation = Get-NTKRunObservation -Key $Key -Provider $Provider -Collector $Collector -RetryFailedProvider:$RetryFailedProvider
    if($observation.State -ne 'Available'){
        if($Required){ throw "Observation '$Key' failed through provider '$Provider': $($observation.Error)" }
        return $null
    }
    return $observation.Value
}

function Global:Clear-NTKRunObservation {
    param([string]$Key,[string]$Provider,[object]$Context=$Global:NTKPerformanceRunContext)
    if(!$Context){ return }
    if($Key){ [void]$Context.Observations.Remove($Key) }
    if($Provider){
        [void]$Context.ProviderHealth.Remove($Provider)
        foreach($cachedKey in @($Context.Observations.Keys | Where-Object { $Context.Observations[$_].Provider -eq $Provider })){ [void]$Context.Observations.Remove($cachedKey) }
    }
}

function Global:Complete-NTKPerformanceRun {
    param([Parameter(Mandatory=$true)][object]$Handle,[string]$ResultPath)
    if(!$Handle.OwnsContext){ return $Handle.Context }
    $context = $Handle.Context
    if($context.Stopwatch.IsRunning){ $context.Stopwatch.Stop() }
    $summary = [pscustomobject][ordered]@{
        schemaVersion = '1.0'
        runId = $context.RunId
        name = $context.Name
        startedAtUtc = $context.StartedAtUtc.ToString('o')
        completedAtUtc = [datetimeoffset]::UtcNow.ToString('o')
        durationMs = $context.Stopwatch.ElapsedMilliseconds
        timings = @($context.Timings.ToArray())
        providerHealth = @($context.ProviderHealth.GetEnumerator() | ForEach-Object { [pscustomobject]@{provider=$_.Key;state=$_.Value.State;error=$_.Value.Error;capturedAtUtc=$_.Value.CapturedAtUtc} })
        observationCount = $context.Observations.Count
    }
    try {
        if($ResultPath){
            $parent = Split-Path -Parent $ResultPath
            if($parent -and !(Test-Path -LiteralPath $parent)){ New-Item -ItemType Directory -Path $parent -Force | Out-Null }
            if(Get-Command Write-NTKAtomicJson -ErrorAction SilentlyContinue){ [void](Write-NTKAtomicJson -Path $ResultPath -Value $summary -Depth 12) }
            else { $summary | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $ResultPath -Encoding UTF8 }
        }
        else {
            $logRoot = if($Global:NTKPaths -and $Global:NTKPaths.Logs){$Global:NTKPaths.Logs}else{$Global:NTKPerformanceDefaultLogRoot}
            $logPath = Join-Path $logRoot 'Performance\performance.jsonl'
            $parent = Split-Path -Parent $logPath
            if(!(Test-Path -LiteralPath $parent)){ New-Item -ItemType Directory -Path $parent -Force | Out-Null }
            $line = ($summary | ConvertTo-Json -Depth 12 -Compress) + [Environment]::NewLine
            if(Get-Command Invoke-NTKFileLock -ErrorAction SilentlyContinue){ [void](Invoke-NTKFileLock -Path $logPath -Action { [IO.File]::AppendAllText($logPath,$line,(New-Object Text.UTF8Encoding($false))) }) }
            else { [IO.File]::AppendAllText($logPath,$line,(New-Object Text.UTF8Encoding($false))) }
        }
        return $summary
    }
    finally { $Global:NTKPerformanceRunContext = $context.ParentContext }
}
