#Requires -Version 5.1

$performanceModule = Join-Path $PSScriptRoot 'NetworkToolkit\Utilities\Performance.ps1'
if(!(Get-Command Start-NTKPerformanceRun -ErrorAction SilentlyContinue) -and (Test-Path -LiteralPath $performanceModule)){ . $performanceModule }

function New-NTKManagedFileManifest {
    param([Parameter(Mandatory=$true)][string]$Root,[string[]]$ExcludeRelativePaths=@())
    $performanceHandle=Start-NTKPerformanceRun -Name 'package-manifest-hash';$timer=[Diagnostics.Stopwatch]::StartNew();$fileCount=0
    try {
        $resolved=(Resolve-Path -LiteralPath $Root).Path.TrimEnd('\')
        $manifest=@((Get-ChildItem -LiteralPath $resolved -Recurse -File -Force -ErrorAction SilentlyContinue | ForEach-Object {
            $relative=$_.FullName.Substring($resolved.Length).TrimStart('\')
            if($ExcludeRelativePaths -contains $relative){return}
            if(!(Test-Path -LiteralPath $_.FullName -PathType Leaf)){return}
            [pscustomobject]@{Path=$relative;Length=$_.Length;SHA256=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash}
        }) | Sort-Object Path)
        $fileCount=$manifest.Count
        return $manifest
    }
    finally {
        $timer.Stop();[void](Add-NTKPerformanceTiming -Name 'package.manifest-hash' -DurationMs $timer.ElapsedMilliseconds -Tags @{Files=$fileCount;Operation='Create'});[void](Complete-NTKPerformanceRun -Handle $performanceHandle)
    }
}

function Test-NTKManagedFileManifest {
    param([Parameter(Mandatory=$true)][string]$Root,[Parameter(Mandatory=$true)][object[]]$Manifest)
    $performanceHandle=Start-NTKPerformanceRun -Name 'package-manifest-verify';$timer=[Diagnostics.Stopwatch]::StartNew()
    try {
        $failures=New-Object System.Collections.Generic.List[string]
        foreach($entry in @($Manifest)){
            $path=Join-Path $Root $entry.Path
            if(!(Test-Path -LiteralPath $path -PathType Leaf)){[void]$failures.Add("Missing: $($entry.Path)");continue}
            if((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $entry.SHA256){[void]$failures.Add("Hash mismatch: $($entry.Path)")}
        }
        return [pscustomobject]@{passed=($failures.Count -eq 0);failures=$failures.ToArray();verified=@($Manifest).Count}
    }
    finally {
        $timer.Stop();[void](Add-NTKPerformanceTiming -Name 'package.manifest-hash' -DurationMs $timer.ElapsedMilliseconds -Tags @{Files=@($Manifest).Count;Operation='Verify'});[void](Complete-NTKPerformanceRun -Handle $performanceHandle)
    }
}

function Test-NTKDeploymentIdentity {
    param([Parameter(Mandatory=$true)][string]$DeploymentRoot)
    try {
        $manifestPath=Join-Path $DeploymentRoot 'App\manifests\toolkit-version.json'
        $launcher=Join-Path $DeploymentRoot 'NetworkToolkit.vbs'
        if(!(Test-Path -LiteralPath $manifestPath) -or !(Test-Path -LiteralPath $launcher)){return $false}
        $manifest=Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
        return ($manifest.Product -eq 'Network Toolkit' -and $manifest.Version -and $null -ne $manifest.Build)
    } catch { return $false }
}

function Invoke-NTKStagedDirectorySwap {
    param(
        [Parameter(Mandatory=$true)][string]$StagedPath,
        [Parameter(Mandatory=$true)][string]$DestinationPath,
        [scriptblock]$PostSwapVerify={ $true },
        [scriptblock]$InterruptionPoint={ param($Point) }
    )
    $parent=Split-Path -Parent $DestinationPath
    if([string]::IsNullOrWhiteSpace($parent)){throw 'Destination must have a parent folder.'}
    $backup="$DestinationPath.ntk-backup"
    if(Test-Path -LiteralPath $backup){throw "Recoverable backup already exists: $backup"}
    $movedPrior=$false;$installed=$false
    try {
        & $InterruptionPoint 'before-swap'
        if(Test-Path -LiteralPath $DestinationPath){Move-Item -LiteralPath $DestinationPath -Destination $backup -ErrorAction Stop;$movedPrior=$true}
        & $InterruptionPoint 'after-backup'
        Move-Item -LiteralPath $StagedPath -Destination $DestinationPath -ErrorAction Stop;$installed=$true
        & $InterruptionPoint 'after-install'
        if(![bool](& $PostSwapVerify $DestinationPath)){throw 'Post-swap verification failed.'}
        if($movedPrior){Remove-Item -LiteralPath $backup -Recurse -Force -ErrorAction Stop}
        [pscustomobject]@{state='Succeeded';destination=$DestinationPath;backupRemoved=$movedPrior;rollbackSucceeded=$false}
    }
    catch {
        $message=$_.Exception.Message;$rollback=$false
        try {
            if($installed -and (Test-Path -LiteralPath $DestinationPath)){Remove-Item -LiteralPath $DestinationPath -Recurse -Force -ErrorAction Stop}
            if($movedPrior -and (Test-Path -LiteralPath $backup)){Move-Item -LiteralPath $backup -Destination $DestinationPath -ErrorAction Stop}
            $rollback=$true
        } catch { $message += "; rollback failed: $($_.Exception.Message)" }
        [pscustomobject]@{state=$(if($rollback){'Failed'}else{'Partial'});destination=$DestinationPath;error=$message;rollbackSucceeded=$rollback;backupPath=$backup}
    }
}
