#Requires -Version 5.1

function New-NTKManagedFileManifest {
    param([Parameter(Mandatory=$true)][string]$Root,[string[]]$ExcludeRelativePaths=@())
    $resolved=(Resolve-Path -LiteralPath $Root).Path.TrimEnd('\')
    @((Get-ChildItem -LiteralPath $resolved -Recurse -File -Force -ErrorAction SilentlyContinue | ForEach-Object {
        $relative=$_.FullName.Substring($resolved.Length).TrimStart('\')
        if($ExcludeRelativePaths -contains $relative){return}
        if(!(Test-Path -LiteralPath $_.FullName -PathType Leaf)){return}
        [pscustomobject]@{Path=$relative;Length=$_.Length;SHA256=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash}
    }) | Sort-Object Path)
}

function Test-NTKManagedFileManifest {
    param([Parameter(Mandatory=$true)][string]$Root,[Parameter(Mandatory=$true)][object[]]$Manifest)
    $failures=New-Object System.Collections.Generic.List[string]
    foreach($entry in @($Manifest)){
        $path=Join-Path $Root $entry.Path
        if(!(Test-Path -LiteralPath $path -PathType Leaf)){[void]$failures.Add("Missing: $($entry.Path)");continue}
        if((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $entry.SHA256){[void]$failures.Add("Hash mismatch: $($entry.Path)")}
    }
    [pscustomobject]@{passed=($failures.Count -eq 0);failures=$failures.ToArray();verified=@($Manifest).Count}
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
