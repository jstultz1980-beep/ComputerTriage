[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$SourceRoot,
    [Parameter(Mandatory=$true)][string]$DestinationRoot,
    [Parameter(Mandatory=$true)][string]$ResultPath,
    [switch]$ExcludeSysinternals
)

$ErrorActionPreference = 'Stop'

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
    if(!(Test-Path -LiteralPath $destination)){ New-Item -ItemType Directory -Path $destination -Force | Out-Null }

    # A deployment is a clean runtime image, not a clone of technician/client history.
    Get-ChildItem -LiteralPath $destination -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction Stop
    $appDestination = Join-Path $destination 'App'
    New-Item -ItemType Directory -Path $appDestination -Force | Out-Null
    $appSource = Join-Path $source 'App'
    $excludedDirectories = @(
        (Join-Path $appSource '.git'),
        (Join-Path $appSource 'Release'),
        (Join-Path $appSource 'NetworkToolkit\Data'),
        (Join-Path $appSource 'NetworkToolkit\Exports'),
        (Join-Path $appSource 'NetworkToolkit\Logs')
    )
    if($ExcludeSysinternals){
        $excludedDirectories += (Join-Path $appSource 'NetworkToolkit\ExternalTools\Sysinternals')
    }
    $arguments = @($appSource,$appDestination,'/E','/COPY:DAT','/DCOPY:DAT','/R:1','/W:1','/NFL','/NDL','/NJH','/NJS','/NP','/XD') + $excludedDirectories + @('/XF',(Join-Path $appSource 'manifests\gui-settings.json'))
    & robocopy @arguments | Out-String | Set-Content -LiteralPath $result.LogPath -Encoding UTF8
    $result.ExitCode = $LASTEXITCODE
    if($result.ExitCode -gt 7){ throw "Robocopy failed with exit code $($result.ExitCode). Review $($result.LogPath)." }

    # A fresh deployment includes the portable applications but none of their
    # prior user profiles, browser data, caches, or app-specific settings.
    $customRoot = Join-Path $appDestination 'Custom'
    if(Test-Path -LiteralPath $customRoot){
        Get-ChildItem -LiteralPath $customRoot -Directory -Recurse -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -ceq 'Data' } |
            ForEach-Object {
                Get-ChildItem -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue |
                    Remove-Item -Recurse -Force -ErrorAction Stop
            }
    }

    $launcher = Join-Path $source 'NetworkToolkit.vbs'
    if(!(Test-Path -LiteralPath $launcher)){ throw "Launcher not found: $launcher" }
    Copy-Item -LiteralPath $launcher -Destination (Join-Path $destination 'NetworkToolkit.vbs') -Force
    foreach($required in @('NetworkToolkit.ps1','ToolKit-GUI\ToolKit-GUI.ps1','NetworkToolkit\NetworkToolkit-Core.ps1','manifests\toolkit-version.json')){
        if(!(Test-Path -LiteralPath (Join-Path $appDestination $required))){ throw "Deployment is missing required file: App\$required" }
    }
    $result.FilesCopied = @(Get-ChildItem -LiteralPath $destination -File -Recurse -Force).Count
    $result.SourceRoot = $source; $result.DestinationRoot = $destination; $result.Status = 'Completed'
}
catch {
    $result.Status = 'Failed'; $result.Error = $_.Exception.Message
}
finally {
    $result.CompletedAt = (Get-Date).ToString('s')
    $result | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $ResultPath -Encoding UTF8
}

if($result.Status -eq 'Failed'){ exit 1 }
