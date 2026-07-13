[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$SourceRoot,
    [Parameter(Mandatory=$true)][string]$DestinationRoot,
    [Parameter(Mandatory=$true)][string]$ResultPath,
    [switch]$ExcludeSysinternals
)

$ErrorActionPreference = 'Stop'

$exclusionHelper = Join-Path $PSScriptRoot 'DeploymentExclusions.ps1'
if(!(Test-Path -LiteralPath $exclusionHelper)){
    throw "Deployment exclusion helper was not found: $exclusionHelper"
}
. $exclusionHelper
. (Join-Path $PSScriptRoot 'DeploymentIntegrity.ps1')

function Resolve-DeploymentRoot {
    param([string]$Path)
    $item = Get-Item -LiteralPath $Path -Force -ErrorAction Stop
    if(!$item.PSIsContainer){ throw "Not a folder: $Path" }
    $root = $item.FullName.TrimEnd('\')
    if(!(Test-Path -LiteralPath (Join-Path $root 'App\manifests\toolkit-version.json'))){
        throw "Network Toolkit App\manifests\toolkit-version.json was not found in $root."
    }
    return $root
}

$result = [ordered]@{
    SourceRoot = $SourceRoot; DestinationRoot = $DestinationRoot
    StartedAt = (Get-Date).ToString('s'); CompletedAt = ''; Status = 'Running'
    ExitCode = $null; FilesCopied = 0; Error = ''; LogPath = "$ResultPath.log"
    ExcludeSysinternals = [bool]$ExcludeSysinternals
}

try {
    $source = Resolve-DeploymentRoot $SourceRoot
    $destinationFullPath = [System.IO.Path]::GetFullPath($DestinationRoot)
    $destination = $destinationFullPath.TrimEnd('\')
    $destinationDriveRoot = [System.IO.Path]::GetPathRoot($destinationFullPath).TrimEnd('\')
    if($destination.Equals($destinationDriveRoot,[System.StringComparison]::OrdinalIgnoreCase)){
        throw 'Choose a dedicated destination folder, such as E:\NetworkToolkit, not the root of a drive.'
    }
    if($source.Equals($destination,[System.StringComparison]::OrdinalIgnoreCase)){
        throw 'Source and destination must be different folders.'
    }
    $finalDestination=$destination
    $staging="$finalDestination.ntk-stage"
    if(Test-Path -LiteralPath $staging){throw "Incomplete staging folder already exists: $staging"}
    New-Item -ItemType Directory -Path $staging -Force | Out-Null
    $appDestination = Join-Path $staging 'App'
    New-Item -ItemType Directory -Path $appDestination -Force | Out-Null
    $appSource = Join-Path $source 'App'
    $exclusions = Get-NetworkToolkitDeploymentExclusions -SourceRoot $appSource -Mode Fresh -ExcludeSysinternals:$ExcludeSysinternals
    $arguments = @($appSource,$appDestination,'/E','/COPY:DAT','/DCOPY:DAT','/R:1','/W:1','/NFL','/NDL','/NJH','/NJS','/NP','/XD') + $exclusions.Directories + @('/XF') + $exclusions.Files
    & robocopy @arguments | Out-String | Set-Content -LiteralPath $result.LogPath -Encoding UTF8
    $result.ExitCode = $LASTEXITCODE
    if($result.ExitCode -gt 7){ throw "Robocopy failed with exit code $($result.ExitCode). Review $($result.LogPath)." }

    # A fresh deployment clears only explicitly declared portable state paths.
    $statePolicyPath=Join-Path $appDestination 'manifests\portable-state-policy.json'
    if(!(Test-Path -LiteralPath $statePolicyPath)){throw 'Portable state policy is missing.'}
    $statePolicy=Get-Content -LiteralPath $statePolicyPath -Raw|ConvertFrom-Json
    foreach($relativeMutablePath in @($statePolicy.mutablePaths)){
        $mutablePath=Join-Path $appDestination $relativeMutablePath
        if(Test-Path -LiteralPath $mutablePath){Get-ChildItem -LiteralPath $mutablePath -Force -ErrorAction SilentlyContinue|Remove-Item -Recurse -Force -ErrorAction Stop}
    }
    foreach($relativeRuntimePath in @('Data','Exports','Logs','State')){New-Item -ItemType Directory -Path (Join-Path $staging ("Runtime\"+$relativeRuntimePath)) -Force|Out-Null}

    $launcher = Join-Path $source 'NetworkToolkit.vbs'
    if(!(Test-Path -LiteralPath $launcher)){ throw "Launcher not found: $launcher" }
    Copy-Item -LiteralPath $launcher -Destination (Join-Path $staging 'NetworkToolkit.vbs') -Force
    foreach($required in @('NetworkToolkit.ps1','DeploymentExclusions.ps1','ToolKit-GUI\ToolKit-GUI.ps1','NetworkToolkit\NetworkToolkit-Core.ps1','manifests\toolkit-version.json')){
        if(!(Test-Path -LiteralPath (Join-Path $appDestination $required))){ throw "Deployment is missing required file: App\$required" }
    }
    $sourceManifest=New-NTKManagedFileManifest -Root $staging
    $preflight=Test-NTKManagedFileManifest -Root $staging -Manifest $sourceManifest
    if(!$preflight.passed){throw "Staged deployment verification failed: $($preflight.failures -join '; ')"}
    $swap=Invoke-NTKStagedDirectorySwap -StagedPath $staging -DestinationPath $finalDestination -PostSwapVerify {param($installed)(Test-NTKManagedFileManifest -Root $installed -Manifest $sourceManifest).passed}
    if($swap.state -ne 'Succeeded'){throw "Deployment swap failed: $($swap.error)"}
    $result.FilesCopied = @(Get-ChildItem -LiteralPath $finalDestination -File -Recurse -Force).Count
    $result.SourceRoot = $source; $result.DestinationRoot = $finalDestination; $result.Status = 'Completed'
}
catch {
    $result.Status = 'Failed'; $result.Error = $_.Exception.Message
}
finally {
    $result.CompletedAt = (Get-Date).ToString('s')
    $result | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $ResultPath -Encoding UTF8
}

if($result.Status -eq 'Failed'){ exit 1 }
