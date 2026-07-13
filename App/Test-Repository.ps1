#Requires -Version 5.1

[CmdletBinding()]
param(
    [string]$ManifestPath = '',
    [string]$ResultPath = '',
    [int]$StageTimeoutSeconds = 180
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$ManifestPath = if($ManifestPath){$ManifestPath}else{Join-Path $PSScriptRoot 'manifests\repository-validation.json'}
$manifestPath = (Resolve-Path -LiteralPath $ManifestPath).Path
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$results = New-Object Collections.Generic.List[object]
$startedAt = [datetimeoffset]::UtcNow

function Add-ValidationResult {
    param([string]$Id,[string]$State,[long]$DurationMs,[string]$Detail,[string[]]$Coverage=@())
    [void]$results.Add([pscustomobject][ordered]@{id=$Id;state=$State;durationMs=$DurationMs;detail=$Detail;coverage=@($Coverage)})
}

function Get-TrackedFiles {
    param([string]$Pattern)
    $items = @(& git -C $repoRoot ls-files -- $Pattern)
    if($LASTEXITCODE -ne 0){ throw "git ls-files failed for pattern: $Pattern" }
    return @($items | Where-Object { $_ })
}

if([version]$PSVersionTable.PSVersion -lt [version]$manifest.minimumPowerShellVersion){
    throw "Repository validation requires Windows PowerShell $($manifest.minimumPowerShellVersion) or newer."
}

$requiredCoverage = @($manifest.requiredCoverage)
$declaredCoverage = @($manifest.stages | ForEach-Object { @($_.coverage) } | Select-Object -Unique)
$missingCoverage = @($requiredCoverage | Where-Object { $_ -notin $declaredCoverage })
if($missingCoverage.Count){ throw "Validation manifest is missing required coverage: $($missingCoverage -join ', ')" }
$negativeCoverage = @($manifest.stages | Where-Object { $_.negativePath } | ForEach-Object { @($_.coverage) } | Select-Object -Unique)
$missingNegativeCoverage = @(@($manifest.requiredNegativePathCoverage) | Where-Object { $_ -notin $negativeCoverage })
if($missingNegativeCoverage.Count){ throw "Validation manifest is missing required negative-path coverage: $($missingNegativeCoverage -join ', ')" }
$duplicateStageIds = @($manifest.stages | Group-Object id | Where-Object Count -gt 1)
if($duplicateStageIds.Count){ throw "Validation manifest contains duplicate stage IDs: $($duplicateStageIds.Name -join ', ')" }

$trackedScripts = @(Get-TrackedFiles -Pattern '*.ps1')
$trackedFixtureScripts = @($trackedScripts | Where-Object { $_ -like 'App/NetworkToolkit/Tests/Test-*.ps1' })
$declaredStagePaths = @($manifest.stages.path)
$undeclaredFixtureScripts = @($trackedFixtureScripts | Where-Object { $_ -notin $declaredStagePaths })
if($undeclaredFixtureScripts.Count){ throw "Tracked fixture scripts are missing from the repository validation manifest: $($undeclaredFixtureScripts -join ', ')" }
$exclusions = @($manifest.parser.exclusions)
$unknownExclusions = @($exclusions | Where-Object { $_ -notin $trackedScripts })
if($unknownExclusions.Count){ throw "Parser exclusions do not name tracked PowerShell files: $($unknownExclusions -join ', ')" }

$parseWatch = [Diagnostics.Stopwatch]::StartNew()
$parseFailures = New-Object Collections.Generic.List[string]
foreach($relative in @($trackedScripts | Where-Object { $_ -notin $exclusions })){
    $tokens = $null
    $errors = $null
    [void][Management.Automation.Language.Parser]::ParseFile((Join-Path $repoRoot $relative),[ref]$tokens,[ref]$errors)
    foreach($error in @($errors)){ [void]$parseFailures.Add("${relative}:$($error.Extent.StartLineNumber): $($error.Message)") }
}
$parseWatch.Stop()
if($parseFailures.Count){ Add-ValidationResult -Id 'powershell-5.1-parser' -State Failed -DurationMs $parseWatch.ElapsedMilliseconds -Detail ($parseFailures -join [Environment]::NewLine) }
else { Add-ValidationResult -Id 'powershell-5.1-parser' -State Passed -DurationMs $parseWatch.ElapsedMilliseconds -Detail "$($trackedScripts.Count - $exclusions.Count) tracked PowerShell files parsed; $($exclusions.Count) explicit exclusions." }

foreach($stage in @($manifest.stages)){
    $relativePath = [string]$stage.path
    if($relativePath -notin $trackedScripts){
        Add-ValidationResult -Id $stage.id -State Failed -DurationMs 0 -Detail "Stage path is not a tracked PowerShell file: $relativePath" -Coverage @($stage.coverage)
        continue
    }
    $fullPath = Join-Path $repoRoot $relativePath
    $watch = [Diagnostics.Stopwatch]::StartNew()
    $process = $null
    try {
        $stageArguments = @($stage.arguments | Where-Object { $null -ne $_ -and [string]$_ -ne '' })
        $arguments = @('-NoProfile','-ExecutionPolicy','Bypass','-File',$fullPath) + $stageArguments
        $quotedArguments = @($arguments | ForEach-Object { '"' + (([string]$_) -replace '"','\"') + '"' }) -join ' '
        $startInfo = New-Object Diagnostics.ProcessStartInfo
        $startInfo.FileName = 'powershell.exe'
        $startInfo.Arguments = $quotedArguments
        $startInfo.UseShellExecute = $false
        $startInfo.CreateNoWindow = $true
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true
        $process = New-Object Diagnostics.Process
        $process.StartInfo = $startInfo
        if(!$process.Start()){ throw "Failed to start validation stage: $($stage.id)" }
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()
        if(!$process.WaitForExit($StageTimeoutSeconds * 1000)){
            try { $process.Kill() } catch {}
            $watch.Stop()
            Add-ValidationResult -Id $stage.id -State Failed -DurationMs $watch.ElapsedMilliseconds -Detail "Timed out after $StageTimeoutSeconds seconds." -Coverage @($stage.coverage)
            continue
        }
        $process.WaitForExit()
        $process.Refresh()
        $exitCode = $process.ExitCode
        $watch.Stop()
        $output = @($stdoutTask.Result,$stderrTask.Result | Where-Object { $_ }) -join [Environment]::NewLine
        if($exitCode -eq 0){ Add-ValidationResult -Id $stage.id -State Passed -DurationMs $watch.ElapsedMilliseconds -Detail $output.Trim() -Coverage @($stage.coverage) }
        else { Add-ValidationResult -Id $stage.id -State Failed -DurationMs $watch.ElapsedMilliseconds -Detail "Exit code $exitCode. $($output.Trim())" -Coverage @($stage.coverage) }
    }
    catch {
        $watch.Stop()
        Add-ValidationResult -Id $stage.id -State Failed -DurationMs $watch.ElapsedMilliseconds -Detail $_.Exception.Message -Coverage @($stage.coverage)
    }
    finally { if($process){ $process.Dispose() } }
}

$failed = @($results | Where-Object state -eq 'Failed')
$summary = [pscustomobject][ordered]@{
    schemaVersion = '1.0'
    startedAtUtc = $startedAt.ToString('o')
    completedAtUtc = [datetimeoffset]::UtcNow.ToString('o')
    powershellVersion = $PSVersionTable.PSVersion.ToString()
    repositoryHead = (& git -C $repoRoot rev-parse HEAD).Trim()
    state = if($failed.Count){'Failed'}else{'Passed'}
    passed = @($results | Where-Object state -eq 'Passed').Count
    failed = $failed.Count
    results = @($results.ToArray())
}

if($ResultPath){
    $resultParent = Split-Path -Parent $ResultPath
    if($resultParent -and !(Test-Path -LiteralPath $resultParent)){ New-Item -ItemType Directory -Path $resultParent -Force | Out-Null }
    $summary | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $ResultPath -Encoding UTF8
}

foreach($result in $results){ Write-Host ("[{0}] {1} ({2} ms)" -f $result.state.ToUpperInvariant(),$result.id,$result.durationMs) -ForegroundColor $(if($result.state -eq 'Passed'){'Green'}else{'Red'}) }
Write-Host ("Repository validation: {0} passed, {1} failed." -f $summary.passed,$summary.failed)
if($failed.Count){ exit 1 }
