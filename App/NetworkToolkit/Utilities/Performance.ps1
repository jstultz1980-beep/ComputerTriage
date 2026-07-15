# =====================================================================
# Performance.ps1
# Structured timing, budgets, provider health, telemetry, and QA bundle helpers
# =====================================================================

if(-not (Get-Variable -Scope Global -Name NTKPerformanceRunContext -ErrorAction SilentlyContinue)){
    $Global:NTKPerformanceRunContext = $null
}
if(-not (Get-Variable -Scope Global -Name NTKPerformanceDefaultLogRoot -ErrorAction SilentlyContinue)){
    $Global:NTKPerformanceDefaultLogRoot = Join-Path (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))) 'Runtime\Logs'
}

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

function Global:Get-NTKPerformanceToolkitVersionInfo {
    $path = Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) 'manifests\toolkit-version.json'
    if(!(Test-Path -LiteralPath $path -PathType Leaf)){
        return $null
    }

    try {
        $manifest = Get-Content -LiteralPath $path -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        return [pscustomobject]@{
            Product = [string]$manifest.Product
            Version = [string]$manifest.Version
            Build = [long]$manifest.Build
            SourceUpdatedAt = [string]$manifest.SourceUpdatedAt
            ReleaseNotes = [string]$manifest.ReleaseNotes
        }
    }
    catch {
        return $null
    }
}

function Global:Get-NTKPerformanceSourceCommit {
    $root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
    try {
        $commit = (& git -C $root rev-parse HEAD 2>$null).Trim()
        if($commit){ return $commit }
    }
    catch {}
    return $null
}

function Global:Get-NTKPerformanceEnvironmentFingerprint {
    $toolkitVersion = Get-NTKPerformanceToolkitVersionInfo
    $seedParts = @(
        $env:COMPUTERNAME
        [Environment]::Is64BitProcess
        $PSVersionTable.PSVersion.ToString()
        [string]$PSVersionTable.PSEdition
        [System.Environment]::OSVersion.VersionString
        [System.Diagnostics.Process]::GetCurrentProcess().SessionId
        [System.Threading.Thread]::CurrentThread.ManagedThreadId
    )
    $seed = ($seedParts -join '|')
    $hashBytes = [System.Security.Cryptography.SHA256]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes($seed))
    $fingerprintId = ([System.BitConverter]::ToString($hashBytes) -replace '-','').ToLowerInvariant()
    return [pscustomobject]@{
        fingerprintId = $fingerprintId
        computerName = $env:COMPUTERNAME
        osVersion = [System.Environment]::OSVersion.VersionString
        powershellVersion = $PSVersionTable.PSVersion.ToString()
        powershellEdition = [string]$PSVersionTable.PSEdition
        processArchitecture = if([Environment]::Is64BitProcess){'x64'}else{'x86'}
        sessionId = [System.Diagnostics.Process]::GetCurrentProcess().SessionId
        threadId = [System.Threading.Thread]::CurrentThread.ManagedThreadId
        toolkitVersion = if($toolkitVersion){ $toolkitVersion.Version }else{ $null }
    }
}

function Global:Get-NTKPerformanceResourceSnapshot {
    param(
        [string]$Name = 'current',
        [object]$Process = $null
    )

    if(!$Process){
        $Process = [System.Diagnostics.Process]::GetCurrentProcess()
    }

    try { $Process.Refresh() } catch {}

    $workingSetMb = $null
    $privateMemoryMb = $null
    $handleCount = $null
    $threadCount = $null
    $cpuTimeMs = $null

    try { if($null -ne $Process.WorkingSet64){ $workingSetMb = [Math]::Round(([double]$Process.WorkingSet64 / 1MB),2) } } catch {}
    try { if($null -ne $Process.PrivateMemorySize64){ $privateMemoryMb = [Math]::Round(([double]$Process.PrivateMemorySize64 / 1MB),2) } } catch {}
    try { if($null -ne $Process.HandleCount){ $handleCount = [long]$Process.HandleCount } } catch {}
    try { if($Process.Threads){ $threadCount = [long]$Process.Threads.Count } } catch {}
    try {
        if($null -ne $Process.TotalProcessorTime){
            $cpuTimeMs = [Math]::Round($Process.TotalProcessorTime.TotalMilliseconds,2)
        }
    }
    catch {}

    return [pscustomobject]@{
        schemaVersion = '1.0'
        capturedAtUtc = [datetimeoffset]::UtcNow.ToString('o')
        capturedAtOffset = [datetimeoffset]::Now.Offset.ToString()
        name = $Name
        processId = if($Process -and $Process.Id){ [int]$Process.Id }else{ $null }
        processName = if($Process -and $Process.ProcessName){ [string]$Process.ProcessName }else{ $null }
        workingSetMb = $workingSetMb
        privateMemoryMb = $privateMemoryMb
        handleCount = $handleCount
        threadCount = $threadCount
        cpuTimeMs = $cpuTimeMs
    }
}

function Global:Get-NTKPerformanceTelemetryPath {
    $logRoot = if($Global:NTKPaths -and $Global:NTKPaths.Logs){$Global:NTKPaths.Logs}else{$Global:NTKPerformanceDefaultLogRoot}
    return Join-Path $logRoot 'Performance\performance.jsonl'
}

function Global:Add-NTKPerformanceResourceSnapshot {
    param(
        [Parameter(Mandatory=$true)][string]$Name,
        [hashtable]$Tags = @{},
        [object]$Process = $null,
        [object]$Context = $Global:NTKPerformanceRunContext
    )

    if(!$Context){ return $null }
    if(!$Process){
        $Process = [System.Diagnostics.Process]::GetCurrentProcess()
    }

    $snapshot = Get-NTKPerformanceResourceSnapshot -Name $Name -Process $Process
    $record = [pscustomobject][ordered]@{
        schemaVersion = $snapshot.schemaVersion
        runId = [string]$Context.RunId
        name = $snapshot.name
        capturedAtUtc = $snapshot.capturedAtUtc
        capturedAtOffset = $snapshot.capturedAtOffset
        processId = $snapshot.processId
        processName = $snapshot.processName
        workingSetMb = $snapshot.workingSetMb
        privateMemoryMb = $snapshot.privateMemoryMb
        handleCount = $snapshot.handleCount
        threadCount = $snapshot.threadCount
        cpuTimeMs = $snapshot.cpuTimeMs
        toolkitVersion = if($Context.ToolkitVersionInfo){ [string]$Context.ToolkitVersionInfo.Version }else{ $null }
        sourceCommit = if($Context.SourceCommit){ [string]$Context.SourceCommit }else{ $null }
        environmentFingerprint = if($Context.EnvironmentFingerprint){ $Context.EnvironmentFingerprint }else{ $null }
        tags = [pscustomobject]$Tags
    }
    if(-not $Context.ResourceSnapshots){
        $Context.ResourceSnapshots = New-Object System.Collections.ArrayList
    }
    [void]$Context.ResourceSnapshots.Add($record)
    return $record
}

function Global:Resolve-NTKPerformanceEventParts {
    param([Parameter(Mandatory=$true)][string]$Name)

    $parts = @($Name -split '\.' | Where-Object { ![string]::IsNullOrWhiteSpace($_) })
    $category = if($parts.Count -gt 0){ [string]$parts[0] }else{ 'performance' }
    $operation = if($parts.Count -gt 1){ [string]$parts[1] }else{ [string]$Name }
    $stage = if($parts.Count -gt 2){ ($parts[2..($parts.Count - 1)] -join '.') }else{ $null }
    return [pscustomobject]@{
        Category = $category
        Operation = $operation
        Stage = $stage
    }
}

function Global:Read-NTKPerformanceTelemetry {
    param([string]$Path = (Get-NTKPerformanceTelemetryPath))

    $result = [pscustomobject]@{
        Path = $Path
        Records = @()
        CorruptLineCount = 0
        CorruptTail = $false
        LastModifiedUtc = $null
    }

    if(!(Test-Path -LiteralPath $Path -PathType Leaf)){
        return $result
    }

    try {
        $result.LastModifiedUtc = (Get-Item -LiteralPath $Path).LastWriteTimeUtc
    }
    catch {}

    $lines = @(Get-Content -LiteralPath $Path -ErrorAction Stop)
    $records = New-Object System.Collections.ArrayList
    $lastIndex = $lines.Count - 1
    for($i = 0; $i -lt $lines.Count; $i++){
        $line = [string]$lines[$i]
        if([string]::IsNullOrWhiteSpace($line)){
            continue
        }

        try {
            $parsed = $line | ConvertFrom-Json -ErrorAction Stop
            [void]$records.Add($parsed)
        }
        catch {
            $result.CorruptLineCount++
            if($i -eq $lastIndex){
                $result.CorruptTail = $true
            }
        }
    }

    $result.Records = @($records)
    return $result
}

function Global:Get-NTKPerformanceRunHistory {
    param([string]$Path = (Get-NTKPerformanceTelemetryPath), [int]$KeepRecent = 12)

    $telemetry = Read-NTKPerformanceTelemetry -Path $Path
    $runs = New-Object System.Collections.ArrayList
    foreach($record in @($telemetry.Records)){
        $timings = @()
        if($record.timings){
            $timings = @($record.timings)
        }
        $resourceSnapshots = @()
        if($record.resourceSnapshots){
            $resourceSnapshots = @($record.resourceSnapshots)
        }

        $durations = @($timings | Where-Object { $null -ne $_.durationMs } | Select-Object -ExpandProperty durationMs)
        $lastTiming = if($timings.Count -gt 0){ $timings | Select-Object -Last 1 }else{ $null }
        $currentRun = [pscustomobject]@{
            schemaVersion = [string]$record.schemaVersion
            runId = [string]$record.runId
            name = [string]$record.name
            startedAtUtc = [string]$record.startedAtUtc
            completedAtUtc = [string]$record.completedAtUtc
            durationMs = [long]$record.durationMs
            timingCount = $timings.Count
            averageTimingMs = if($durations.Count -gt 0){ [Math]::Round((($durations | Measure-Object -Average).Average),2) }else{ 0 }
            bestTimingMs = if($durations.Count -gt 0){ [long](($durations | Measure-Object -Minimum).Minimum) }else{ 0 }
            worstTimingMs = if($durations.Count -gt 0){ [long](($durations | Measure-Object -Maximum).Maximum) }else{ 0 }
            lastTimingName = if($lastTiming){ [string]$lastTiming.name }else{ '' }
            lastTimingMs = if($lastTiming -and $null -ne $lastTiming.durationMs){ [long]$lastTiming.durationMs }else{ 0 }
            toolkitVersion = if($record.toolkitVersion){ $record.toolkitVersion }else{ $null }
            sourceCommit = if($record.sourceCommit){ $record.sourceCommit }else{ $null }
            environmentFingerprint = if($record.environmentFingerprint){ $record.environmentFingerprint }else{ $null }
            timings = @($timings)
            resourceSnapshots = @($resourceSnapshots)
        }
        [void]$runs.Add($currentRun)
    }

    $sorted = @($runs | Sort-Object @{Expression={[datetimeoffset]$_.startedAtUtc};Descending=$true}, @{Expression={$_.runId};Descending=$true})
    if($KeepRecent -gt 0 -and $sorted.Count -gt $KeepRecent){
        $sorted = @($sorted | Select-Object -First $KeepRecent)
    }

    return [pscustomobject]@{
        Telemetry = $telemetry
        Runs = $sorted
    }
}

function Global:Get-NTKPerformanceMetricSummary {
    param([object[]]$Runs)

    $timings = @()
    foreach($run in @($Runs)){
        foreach($timing in @($run.timings)){
            $timings += [pscustomobject]@{
                runId = [string]$run.runId
                runStartedAtUtc = [string]$run.startedAtUtc
                name = [string]$timing.name
                durationMs = if($null -ne $timing.durationMs){ [long]$timing.durationMs }else{ 0 }
                budgetMs = if($null -ne $timing.budgetMs){ [long]$timing.budgetMs }else{ $null }
                budgetState = if($timing.budgetState){ [string]$timing.budgetState }else{ 'Unknown' }
                outcome = if($timing.outcome){ [string]$timing.outcome }else{ 'Success' }
                stageName = if($timing.stageName){ [string]$timing.stageName }else{ '' }
                eventCategory = if($timing.eventCategory){ [string]$timing.eventCategory }else{ '' }
                operationName = if($timing.operationName){ [string]$timing.operationName }else{ '' }
                capturedAtUtc = if($timing.capturedAtUtc){ [string]$timing.capturedAtUtc }else{ '' }
            }
        }
    }

    $summary = New-Object System.Collections.ArrayList
    foreach($group in @($timings | Group-Object name | Sort-Object Name)){
        $ordered = @($group.Group | Sort-Object runStartedAtUtc)
        $values = @($ordered | Select-Object -ExpandProperty durationMs)
        $last = if($ordered.Count -gt 0){ $ordered[-1] }else{ $null }
        $previous = if($ordered.Count -gt 1){ $ordered[-2] }else{ $null }
        $average = if($values.Count -gt 0){ [Math]::Round((($values | Measure-Object -Average).Average),2) }else{ 0 }
        $regression = if($last -and $previous){ [Math]::Round(([double]$last.durationMs - [double]$previous.durationMs),2) }else{ 0 }
        $best = if($values.Count -gt 0){ [long](($values | Measure-Object -Minimum).Minimum) }else{ 0 }
        $worst = if($values.Count -gt 0){ [long](($values | Measure-Object -Maximum).Maximum) }else{ 0 }
        [void]$summary.Add([pscustomobject]@{
            name = [string]$group.Name
            sampleCount = $values.Count
            averageMs = $average
            bestMs = $best
            worstMs = $worst
            lastMs = if($last){ [long]$last.durationMs }else{ 0 }
            regressionMs = $regression
            lastOutcome = if($last){ [string]$last.outcome }else{ '' }
            budgetState = if($last){ [string]$last.budgetState }else{ '' }
            budgetMs = if($last -and $null -ne $last.budgetMs){ [long]$last.budgetMs }else{ $null }
            lastRunId = if($last){ [string]$last.runId }else{ '' }
        })
    }

    return @($summary)
}

function Global:Get-NTKPerformanceResourceSummary {
    param([object[]]$Runs)

    $snapshots = @()
    foreach($run in @($Runs)){
        foreach($snapshot in @($run.resourceSnapshots)){
            $snapshots += [pscustomobject]@{
                runId = [string]$run.runId
                runStartedAtUtc = [string]$run.startedAtUtc
                name = [string]$snapshot.name
                workingSetMb = if($null -ne $snapshot.workingSetMb){ [double]$snapshot.workingSetMb }else{ $null }
                privateMemoryMb = if($null -ne $snapshot.privateMemoryMb){ [double]$snapshot.privateMemoryMb }else{ $null }
                handleCount = if($null -ne $snapshot.handleCount){ [double]$snapshot.handleCount }else{ $null }
                threadCount = if($null -ne $snapshot.threadCount){ [double]$snapshot.threadCount }else{ $null }
                cpuTimeMs = if($null -ne $snapshot.cpuTimeMs){ [double]$snapshot.cpuTimeMs }else{ $null }
                capturedAtUtc = if($snapshot.capturedAtUtc){ [string]$snapshot.capturedAtUtc }else{ '' }
            }
        }
    }

    $summary = New-Object System.Collections.ArrayList
    foreach($group in @($snapshots | Group-Object name | Sort-Object Name)){
        $ordered = @($group.Group | Sort-Object runStartedAtUtc)
        $last = if($ordered.Count -gt 0){ $ordered[-1] }else{ $null }
        $previous = if($ordered.Count -gt 1){ $ordered[-2] }else{ $null }
        $workingSetValues = @($ordered | Where-Object { $null -ne $_.workingSetMb } | Select-Object -ExpandProperty workingSetMb)
        $privateMemoryValues = @($ordered | Where-Object { $null -ne $_.privateMemoryMb } | Select-Object -ExpandProperty privateMemoryMb)
        $handleValues = @($ordered | Where-Object { $null -ne $_.handleCount } | Select-Object -ExpandProperty handleCount)
        $threadValues = @($ordered | Where-Object { $null -ne $_.threadCount } | Select-Object -ExpandProperty threadCount)
        $cpuValues = @($ordered | Where-Object { $null -ne $_.cpuTimeMs } | Select-Object -ExpandProperty cpuTimeMs)

        [void]$summary.Add([pscustomobject]@{
            name = [string]$group.Name
            sampleCount = $ordered.Count
            workingSetAverageMb = if($workingSetValues.Count -gt 0){ [Math]::Round((($workingSetValues | Measure-Object -Average).Average),2) }else{ $null }
            workingSetBestMb = if($workingSetValues.Count -gt 0){ [Math]::Round((($workingSetValues | Measure-Object -Minimum).Minimum),2) }else{ $null }
            workingSetWorstMb = if($workingSetValues.Count -gt 0){ [Math]::Round((($workingSetValues | Measure-Object -Maximum).Maximum),2) }else{ $null }
            privateMemoryAverageMb = if($privateMemoryValues.Count -gt 0){ [Math]::Round((($privateMemoryValues | Measure-Object -Average).Average),2) }else{ $null }
            privateMemoryBestMb = if($privateMemoryValues.Count -gt 0){ [Math]::Round((($privateMemoryValues | Measure-Object -Minimum).Minimum),2) }else{ $null }
            privateMemoryWorstMb = if($privateMemoryValues.Count -gt 0){ [Math]::Round((($privateMemoryValues | Measure-Object -Maximum).Maximum),2) }else{ $null }
            handleAverage = if($handleValues.Count -gt 0){ [Math]::Round((($handleValues | Measure-Object -Average).Average),2) }else{ $null }
            handleBest = if($handleValues.Count -gt 0){ [Math]::Round((($handleValues | Measure-Object -Minimum).Minimum),2) }else{ $null }
            handleWorst = if($handleValues.Count -gt 0){ [Math]::Round((($handleValues | Measure-Object -Maximum).Maximum),2) }else{ $null }
            threadAverage = if($threadValues.Count -gt 0){ [Math]::Round((($threadValues | Measure-Object -Average).Average),2) }else{ $null }
            threadBest = if($threadValues.Count -gt 0){ [Math]::Round((($threadValues | Measure-Object -Minimum).Minimum),2) }else{ $null }
            threadWorst = if($threadValues.Count -gt 0){ [Math]::Round((($threadValues | Measure-Object -Maximum).Maximum),2) }else{ $null }
            cpuAverageMs = if($cpuValues.Count -gt 0){ [Math]::Round((($cpuValues | Measure-Object -Average).Average),2) }else{ $null }
            cpuBestMs = if($cpuValues.Count -gt 0){ [Math]::Round((($cpuValues | Measure-Object -Minimum).Minimum),2) }else{ $null }
            cpuWorstMs = if($cpuValues.Count -gt 0){ [Math]::Round((($cpuValues | Measure-Object -Maximum).Maximum),2) }else{ $null }
            lastWorkingSetMb = if($last){ $last.workingSetMb }else{ $null }
            lastPrivateMemoryMb = if($last){ $last.privateMemoryMb }else{ $null }
            lastHandleCount = if($last){ $last.handleCount }else{ $null }
            lastThreadCount = if($last){ $last.threadCount }else{ $null }
            lastCpuTimeMs = if($last){ $last.cpuTimeMs }else{ $null }
            regressionWorkingSetMb = if($last -and $previous -and $null -ne $last.workingSetMb -and $null -ne $previous.workingSetMb){ [Math]::Round(([double]$last.workingSetMb - [double]$previous.workingSetMb),2) }else{ $null }
            regressionPrivateMemoryMb = if($last -and $previous -and $null -ne $last.privateMemoryMb -and $null -ne $previous.privateMemoryMb){ [Math]::Round(([double]$last.privateMemoryMb - [double]$previous.privateMemoryMb),2) }else{ $null }
            regressionHandleCount = if($last -and $previous -and $null -ne $last.handleCount -and $null -ne $previous.handleCount){ [Math]::Round(([double]$last.handleCount - [double]$previous.handleCount),2) }else{ $null }
            regressionThreadCount = if($last -and $previous -and $null -ne $last.threadCount -and $null -ne $previous.threadCount){ [Math]::Round(([double]$last.threadCount - [double]$previous.threadCount),2) }else{ $null }
            regressionCpuTimeMs = if($last -and $previous -and $null -ne $last.cpuTimeMs -and $null -ne $previous.cpuTimeMs){ [Math]::Round(([double]$last.cpuTimeMs - [double]$previous.cpuTimeMs),2) }else{ $null }
            lastRunId = if($last){ [string]$last.runId }else{ '' }
        })
    }

    return @($summary)
}

function Global:Get-NTKPerformanceDashboardModel {
    param([int]$KeepRecent = 12)

    $history = Get-NTKPerformanceRunHistory -KeepRecent $KeepRecent
    $runs = @($history.Runs)
    $metrics = @(Get-NTKPerformanceMetricSummary -Runs $runs)
    $resourceSummaries = @(Get-NTKPerformanceResourceSummary -Runs $runs)
    $current = if($Global:NTKPerformanceRunContext){
        [pscustomobject]@{
            runId = [string]$Global:NTKPerformanceRunContext.RunId
            name = [string]$Global:NTKPerformanceRunContext.Name
            startedAtUtc = [string]$Global:NTKPerformanceRunContext.StartedAtUtc.ToString('o')
            elapsedMs = [long]$Global:NTKPerformanceRunContext.Stopwatch.ElapsedMilliseconds
            timingCount = @($Global:NTKPerformanceRunContext.Timings).Count
            resourceSnapshotCount = @($Global:NTKPerformanceRunContext.ResourceSnapshots).Count
            observationCount = $Global:NTKPerformanceRunContext.Observations.Count
            toolkitVersion = if($Global:NTKPerformanceRunContext.ToolkitVersionInfo){ $Global:NTKPerformanceRunContext.ToolkitVersionInfo.Version }else{ $null }
            sourceCommit = $Global:NTKPerformanceRunContext.SourceCommit
            environmentFingerprint = $Global:NTKPerformanceRunContext.EnvironmentFingerprint
            resourceSnapshots = @($Global:NTKPerformanceRunContext.ResourceSnapshots)
        }
    }else{
        $null
    }

    $dataQuality = [pscustomobject]@{
        totalRuns = $runs.Count
        totalTimings = @($runs | ForEach-Object { @($_.timings).Count } | Measure-Object -Sum).Sum
        totalResourceSnapshots = @($runs | ForEach-Object { @($_.resourceSnapshots).Count } | Measure-Object -Sum).Sum
        corruptTail = [bool]$history.Telemetry.CorruptTail
        corruptLineCount = [int]$history.Telemetry.CorruptLineCount
        sampleSizeWarning = if($runs.Count -lt 5){ 'Fewer than 5 recent runs are available.' }else{ $null }
    }

    $qualityState = if($runs.Count -eq 0){ 'InsufficientData' }elseif($runs.Count -lt 5 -or $history.Telemetry.CorruptTail -or $dataQuality.totalResourceSnapshots -eq 0){ 'Warning' }else{ 'Pass' }

    return [pscustomobject]@{
        schemaVersion = '1.0'
        telemetryPath = $history.Telemetry.Path
        telemetryLastModifiedUtc = $history.Telemetry.LastModifiedUtc
        currentRun = $current
        recentRuns = $runs
        metricSummaries = $metrics
        resourceSummaries = $resourceSummaries
        dataQuality = $dataQuality
        overallState = $qualityState
    }
}

function Global:Invoke-NTKPerformanceTelemetryRetention {
    param(
        [string]$Path = (Get-NTKPerformanceTelemetryPath),
        [ValidateRange(1,1000)][int]$KeepRecentRuns = 100,
        [ValidateRange(1,3650)][int]$MaxAgeDays = 30
    )

    if(!(Test-Path -LiteralPath $Path -PathType Leaf)){
        return [pscustomobject]@{ Path = $Path; Kept = 0; Removed = 0; Changed = $false }
    }

    $history = Get-NTKPerformanceRunHistory -Path $Path -KeepRecent 5000
    $cutoff = [datetimeoffset]::UtcNow.AddDays(-1 * [Math]::Max(1,$MaxAgeDays))
    $allowedIds = @(
        $history.Runs |
            Where-Object { [datetimeoffset]$_.startedAtUtc -ge $cutoff } |
            Select-Object -First $KeepRecentRuns |
            Select-Object -ExpandProperty runId
    )

    $keptRecords = @(
        $history.Telemetry.Records |
            Where-Object { $allowedIds -contains [string]$_.runId }
    )

    $parent = Split-Path -Parent $Path
    if($parent -and !(Test-Path -LiteralPath $parent)){ New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    $content = @($keptRecords | ForEach-Object { $_ | ConvertTo-Json -Depth 20 -Compress }) -join [Environment]::NewLine
    if($content){ $content += [Environment]::NewLine }

    if(Get-Command Invoke-NTKFileLock -ErrorAction SilentlyContinue){
        Invoke-NTKFileLock -Path $Path -Action {
            Set-Content -LiteralPath $Path -Value $content -Encoding UTF8
        } | Out-Null
    }
    else{
        Set-Content -LiteralPath $Path -Value $content -Encoding UTF8
    }

    return [pscustomobject]@{
        Path = $Path
        Kept = $keptRecords.Count
        Removed = @($history.Telemetry.Records).Count - $keptRecords.Count
        Changed = $true
    }
}

function Global:Export-NTKPerformanceQABundle {
    param(
        [string]$OutputRoot = $(if($Global:NTKPaths -and $Global:NTKPaths.Exports){$Global:NTKPaths.Exports}else{Join-Path ([Environment]::GetFolderPath('Desktop')) 'NetworkToolkit\Exports'}),
        [switch]$IncludeTelemetry
    )

    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $bundleRoot = Join-Path $OutputRoot ("PerformanceQA\{0}" -f $timestamp)
    New-Item -ItemType Directory -Path $bundleRoot -Force | Out-Null

    $model = Get-NTKPerformanceDashboardModel -KeepRecent 25
    $summary = [pscustomobject]@{
        schemaVersion = '1.0'
        generatedAtUtc = [datetimeoffset]::UtcNow.ToString('o')
        overallState = $model.overallState
        telemetryPath = $model.telemetryPath
        telemetryLastModifiedUtc = if($model.telemetryLastModifiedUtc){ [string]$model.telemetryLastModifiedUtc }else{ $null }
        currentRun = $model.currentRun
        dataQuality = $model.dataQuality
        recentRuns = @($model.recentRuns | Select-Object runId,name,startedAtUtc,completedAtUtc,durationMs,timingCount,resourceSnapshotCount,averageTimingMs,bestTimingMs,worstTimingMs,lastTimingName,lastTimingMs,toolkitVersion,sourceCommit)
        metricSummaries = @($model.metricSummaries)
        resourceSummaries = @($model.resourceSummaries)
    }

    $summaryPath = Join-Path $bundleRoot 'qa-performance-summary.json'
    $summary | ConvertTo-Json -Depth 18 | Set-Content -LiteralPath $summaryPath -Encoding UTF8

    $reportPath = Join-Path $bundleRoot 'qa-performance-summary.txt'
    $lines = New-Object System.Collections.ArrayList
    [void]$lines.Add('Network Toolkit Performance QA Summary')
    [void]$lines.Add(("Generated UTC: {0}" -f $summary.generatedAtUtc))
    [void]$lines.Add(("Overall state: {0}" -f $summary.overallState))
    [void]$lines.Add(("Recent runs: {0}" -f $summary.recentRuns.Count))
    [void]$lines.Add(("Metric groups: {0}" -f $summary.metricSummaries.Count))
    [void]$lines.Add(("Resource groups: {0}" -f $summary.resourceSummaries.Count))
    if($summary.dataQuality.sampleSizeWarning){ [void]$lines.Add(("Warning: {0}" -f $summary.dataQuality.sampleSizeWarning)) }
    if($summary.dataQuality.corruptTail){ [void]$lines.Add(("Warning: telemetry log has a corrupt tail record. Corrupt lines: {0}" -f $summary.dataQuality.corruptLineCount)) }
    if($summary.currentRun -and $summary.currentRun.resourceSnapshotCount -ne $null){ [void]$lines.Add(("Current resource snapshots: {0}" -f $summary.currentRun.resourceSnapshotCount)) }
    if($summary.currentRun){ [void]$lines.Add(("Current run: {0} ({1} ms)" -f $summary.currentRun.name,$summary.currentRun.elapsedMs)) }
    if($summary.metricSummaries.Count -gt 0){
        [void]$lines.Add('')
        [void]$lines.Add('Startup metrics:')
        foreach($metric in @($summary.metricSummaries | Where-Object { $_.name -like 'gui.startup.*' } | Select-Object -First 8)){
            [void]$lines.Add((" - {0}: count={1}; avg={2} ms; best={3} ms; worst={4} ms; regression={5} ms; state={6}" -f $metric.name,$metric.sampleCount,$metric.averageMs,$metric.bestMs,$metric.worstMs,$metric.regressionMs,$metric.budgetState))
        }
        [void]$lines.Add('')
        [void]$lines.Add('Navigation metrics:')
        foreach($metric in @($summary.metricSummaries | Where-Object { $_.name -like 'gui.tab.*' -or $_.name -like 'navigation.*' } | Select-Object -First 8)){
            [void]$lines.Add((" - {0}: count={1}; avg={2} ms; best={3} ms; worst={4} ms; regression={5} ms; state={6}" -f $metric.name,$metric.sampleCount,$metric.averageMs,$metric.bestMs,$metric.worstMs,$metric.regressionMs,$metric.budgetState))
        }
        [void]$lines.Add('')
        [void]$lines.Add('Operation metrics:')
        foreach($metric in @($summary.metricSummaries | Where-Object { $_.name -like 'operation.*' -or $_.name -like 'provider.*' -or $_.name -like 'external-tool.*' } | Select-Object -First 8)){
            [void]$lines.Add((" - {0}: count={1}; avg={2} ms; best={3} ms; worst={4} ms; regression={5} ms; state={6}" -f $metric.name,$metric.sampleCount,$metric.averageMs,$metric.bestMs,$metric.worstMs,$metric.regressionMs,$metric.budgetState))
        }
        [void]$lines.Add('')
        [void]$lines.Add('Resource trends:')
        foreach($resource in @($summary.resourceSummaries | Select-Object -First 8)){
            [void]$lines.Add((" - {0}: count={1}; ws={2}/{3}/{4} MB; private={5}/{6}/{7} MB; handles={8}/{9}/{10}; threads={11}/{12}/{13}; cpu={14}/{15}/{16} ms; regression(ws/private/handles/threads/cpu)={17}/{18}/{19}/{20}/{21}" -f $resource.name,$resource.sampleCount,$resource.workingSetAverageMb,$resource.workingSetBestMb,$resource.workingSetWorstMb,$resource.privateMemoryAverageMb,$resource.privateMemoryBestMb,$resource.privateMemoryWorstMb,$resource.handleAverage,$resource.handleBest,$resource.handleWorst,$resource.threadAverage,$resource.threadBest,$resource.threadWorst,$resource.cpuAverageMs,$resource.cpuBestMs,$resource.cpuWorstMs,$resource.regressionWorkingSetMb,$resource.regressionPrivateMemoryMb,$resource.regressionHandleCount,$resource.regressionThreadCount,$resource.regressionCpuTimeMs))
        }
        [void]$lines.Add('')
        [void]$lines.Add('Regression-oriented metrics:')
        foreach($metric in @($summary.metricSummaries | Select-Object -First 12)){
            [void]$lines.Add((" - {0}: count={1}; avg={2} ms; best={3} ms; worst={4} ms; regression={5} ms; state={6}" -f $metric.name,$metric.sampleCount,$metric.averageMs,$metric.bestMs,$metric.worstMs,$metric.regressionMs,$metric.budgetState))
        }
    }
    $lines | Set-Content -LiteralPath $reportPath -Encoding UTF8

    $telemetryCopy = $null
    if($IncludeTelemetry){
        $telemetryCopy = Join-Path $bundleRoot 'performance.jsonl'
        $sourceTelemetry = Get-NTKPerformanceTelemetryPath
        if(Test-Path -LiteralPath $sourceTelemetry){
            Copy-Item -LiteralPath $sourceTelemetry -Destination $telemetryCopy -Force
        }
    }

    $bundlePath = Join-Path $OutputRoot ("PerformanceQA\{0}.zip" -f $timestamp)
    if(Test-Path -LiteralPath $bundlePath){
        Remove-Item -LiteralPath $bundlePath -Force
    }
    Compress-Archive -Path (Join-Path $bundleRoot '*') -DestinationPath $bundlePath -Force

    return [pscustomobject]@{
        BundleRoot = $bundleRoot
        BundlePath = $bundlePath
        SummaryPath = $summaryPath
        ReportPath = $reportPath
        TelemetryCopyPath = $telemetryCopy
        GeneratedAtUtc = $summary.generatedAtUtc
    }
}

function Global:Reset-NTKPerformanceTelemetry {
    param([string]$Path = (Get-NTKPerformanceTelemetryPath))

    if(!(Test-Path -LiteralPath $Path -PathType Leaf)){
        return [pscustomobject]@{ Path = $Path; Reset = $false; BackupPath = $null }
    }

    $backupPath = "$Path.reset-$(Get-Date -Format 'yyyyMMddHHmmssfff')"
    Copy-Item -LiteralPath $Path -Destination $backupPath -Force
    Set-Content -LiteralPath $Path -Value '' -Encoding UTF8
    return [pscustomobject]@{
        Path = $Path
        Reset = $true
        BackupPath = $backupPath
    }
}

function Global:Start-NTKPerformanceRun {
    param([Parameter(Mandatory=$true)][string]$Name,[string]$RunId,[switch]$ReuseActive)
    if($ReuseActive -and $Global:NTKPerformanceRunContext){
        return [pscustomobject]@{ Context=$Global:NTKPerformanceRunContext; OwnsContext=$false; Name=$Name }
    }
    $parentContext = $Global:NTKPerformanceRunContext
    $toolkitVersionInfo = Get-NTKPerformanceToolkitVersionInfo
    $sourceCommit = Get-NTKPerformanceSourceCommit
    $environmentFingerprint = Get-NTKPerformanceEnvironmentFingerprint
    $context = [pscustomobject]@{
        SchemaVersion = '1.0'
        RunId = if($RunId){$RunId}else{'NTK-PERF-' + [guid]::NewGuid().ToString('N')}
        Name = $Name
        StartedAtUtc = [datetimeoffset]::UtcNow
        Stopwatch = [Diagnostics.Stopwatch]::StartNew()
        Budgets = Get-NTKPerformanceBudgets
        Timings = New-Object Collections.ArrayList
        ResourceSnapshots = New-Object Collections.ArrayList
        Observations = @{}
        ProviderHealth = @{}
        ParentContext = $parentContext
        ToolkitVersionInfo = $toolkitVersionInfo
        SourceCommit = $sourceCommit
        EnvironmentFingerprint = $environmentFingerprint
    }
    $Global:NTKPerformanceRunContext = $context
    [void](Add-NTKPerformanceResourceSnapshot -Name 'run.start' -Tags @{Point='Start-NTKPerformanceRun'} -Context $context)
    return [pscustomobject]@{ Context=$context; OwnsContext=$true; Name=$Name }
}

function Global:Add-NTKPerformanceTiming {
    param(
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][long]$DurationMs,
        [Nullable[long]]$StartElapsedMs,
        [Nullable[long]]$EndElapsedMs,
        [string]$EventCategory,
        [string]$OperationName,
        [string]$StageName,
        [ValidateSet('Success','Failure','Cancelled','Timeout','Skipped')][string]$Outcome = 'Success',
        [string]$ColdWarmState,
        [Nullable[int]]$ThreadId,
        [string]$ToolkitVersion,
        [string]$SourceCommit,
        [object]$EnvironmentFingerprint,
        [hashtable]$Tags = @{},
        [Nullable[long]]$BudgetMs,
        [object]$Context = $Global:NTKPerformanceRunContext
    )
    if(!$Context){ return $null }
    $budget = if($null -ne $BudgetMs){[long]$BudgetMs}else{Get-NTKPerformanceBudgetMs -Name $Name -Context $Context}
    $parts = Resolve-NTKPerformanceEventParts -Name $Name
    if(!$EventCategory){ $EventCategory = $parts.Category }
    if(!$OperationName){ $OperationName = $parts.Operation }
    if(!$StageName){ $StageName = $parts.Stage }
    if(!$ToolkitVersion -and $Context.ToolkitVersionInfo){ $ToolkitVersion = [string]$Context.ToolkitVersionInfo.Version }
    if(!$SourceCommit -and $Context.SourceCommit){ $SourceCommit = [string]$Context.SourceCommit }
    if($null -eq $ThreadId){ $ThreadId = [int][System.Threading.Thread]::CurrentThread.ManagedThreadId }
    $environment = if($EnvironmentFingerprint){ $EnvironmentFingerprint }elseif($Context.EnvironmentFingerprint){ $Context.EnvironmentFingerprint }else{ $null }
    $start = if($null -ne $StartElapsedMs){ [long]$StartElapsedMs }else{ $null }
    $end = if($null -ne $EndElapsedMs){ [long]$EndElapsedMs }else{ if($null -ne $start){ [long]($start + $DurationMs) }else{ $null } }
    $record = [pscustomobject][ordered]@{
        schemaVersion = '1.0'
        runId = [string]$Context.RunId
        name = $Name
        eventCategory = $EventCategory
        operationName = $OperationName
        stageName = $StageName
        outcome = $Outcome
        coldWarmState = $ColdWarmState
        startElapsedMs = $start
        endElapsedMs = $end
        durationMs = $DurationMs
        budgetMs = $budget
        budgetState = if($null -eq $budget){'Unbudgeted'}elseif($DurationMs -le $budget){'WithinBudget'}else{'Exceeded'}
        capturedAtUtc = [datetimeoffset]::UtcNow.ToString('o')
        capturedAtOffset = [datetimeoffset]::Now.Offset.ToString()
        threadId = $ThreadId
        toolkitVersion = if($ToolkitVersion){$ToolkitVersion}else{$null}
        sourceCommit = if($SourceCommit){$SourceCommit}else{$null}
        environmentFingerprint = if($environment){$environment}else{$null}
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
    [void](Add-NTKPerformanceResourceSnapshot -Name 'run.complete' -Tags @{Point='Complete-NTKPerformanceRun'} -Context $context)
    if($context.Stopwatch.IsRunning){ $context.Stopwatch.Stop() }
    $summary = [pscustomobject][ordered]@{
        schemaVersion = '1.0'
        runId = $context.RunId
        name = $context.Name
        startedAtUtc = $context.StartedAtUtc.ToString('o')
        completedAtUtc = [datetimeoffset]::UtcNow.ToString('o')
        durationMs = $context.Stopwatch.ElapsedMilliseconds
        timings = @($context.Timings.ToArray())
        resourceSnapshots = @($context.ResourceSnapshots.ToArray())
        providerHealth = @($context.ProviderHealth.GetEnumerator() | ForEach-Object { [pscustomobject]@{provider=$_.Key;state=$_.Value.State;error=$_.Value.Error;capturedAtUtc=$_.Value.CapturedAtUtc} })
        observationCount = $context.Observations.Count
        toolkitVersion = $context.ToolkitVersionInfo
        sourceCommit = $context.SourceCommit
        environmentFingerprint = $context.EnvironmentFingerprint
    }
    try {
        if($ResultPath){
            $parent = Split-Path -Parent $ResultPath
            if($parent -and !(Test-Path -LiteralPath $parent)){ New-Item -ItemType Directory -Path $parent -Force | Out-Null }
            if(Get-Command Write-NTKAtomicJson -ErrorAction SilentlyContinue){ [void](Write-NTKAtomicJson -Path $ResultPath -Value $summary -Depth 12) }
            else { $summary | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $ResultPath -Encoding UTF8 }
        }
        else {
            $logPath = Get-NTKPerformanceTelemetryPath
            $parent = Split-Path -Parent $logPath
            if(!(Test-Path -LiteralPath $parent)){ New-Item -ItemType Directory -Path $parent -Force | Out-Null }
            $line = ($summary | ConvertTo-Json -Depth 12 -Compress) + [Environment]::NewLine
            if(Get-Command Invoke-NTKFileLock -ErrorAction SilentlyContinue){ [void](Invoke-NTKFileLock -Path $logPath -Action { [IO.File]::AppendAllText($logPath,$line,(New-Object Text.UTF8Encoding($false))) }) }
            else { [IO.File]::AppendAllText($logPath,$line,(New-Object Text.UTF8Encoding($false))) }
            try { [void](Invoke-NTKPerformanceTelemetryRetention -Path $logPath) } catch {}
        }
        return $summary
    }
    finally { $Global:NTKPerformanceRunContext = $context.ParentContext }
}
