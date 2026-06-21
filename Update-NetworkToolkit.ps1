[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$SourceRoot,

    [Parameter(Mandatory=$true)]
    [string]$DestinationRoot,

    [Parameter(Mandatory=$true)]
    [string]$ResultPath
)

$ErrorActionPreference = "Stop"

function Resolve-NetworkToolkitFileSystemPath {
    param([Parameter(Mandatory=$true)][string]$Path)

    $item = Get-Item -LiteralPath $Path -Force -ErrorAction Stop
    if($item.PSProvider.Name -ne "FileSystem"){
        throw "Path is not a filesystem location: $Path"
    }
    $item.FullName.TrimEnd('\\')
}

function Get-NetworkToolkitVersionManifest {
    param([Parameter(Mandatory=$true)][string]$ToolkitRoot)

    $manifestPath = Join-Path $ToolkitRoot "manifests\toolkit-version.json"
    if(!(Test-Path -LiteralPath $manifestPath)){
        throw "Toolkit version manifest was not found: $manifestPath"
    }

    $manifest = Get-Content -LiteralPath $manifestPath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
    if(!$manifest.Version -or $null -eq $manifest.Build){
        throw "Toolkit version manifest is incomplete: $manifestPath"
    }
    try { [void][version]$manifest.Version } catch { throw "Toolkit version is invalid in $manifestPath" }
    try { $build = [int64]$manifest.Build } catch { throw "Toolkit build is invalid in $manifestPath" }

    [pscustomobject]@{
        Path = $manifestPath
        Version = [version]$manifest.Version
        VersionText = [string]$manifest.Version
        Build = $build
        SourceUpdatedAt = [string]$manifest.SourceUpdatedAt
    }
}

function Get-NetworkToolkitRobocopySummary {
    param([int]$ExitCode)
    switch($ExitCode){
        0 { "No toolkit files needed copying." }
        1 { "Toolkit files were copied successfully." }
        2 { "Destination contains preserved files; no toolkit files needed copying." }
        3 { "Toolkit files were copied successfully; destination also contains preserved files." }
        default { "Robocopy completed successfully with status $ExitCode." }
    }
}

function Test-NetworkToolkitCopy {
    param(
        [Parameter(Mandatory=$true)][string]$SourceRoot,
        [Parameter(Mandatory=$true)][string]$DestinationRoot
    )

    $verified = @()
    foreach($relativePath in @(
        "NetworkToolkit.ps1",
        "ToolKit-GUI\ToolKit-GUI.ps1",
        "CSI-NetworkToolkit\CSI-NetworkToolkit.ps1",
        "manifests\toolkit-version.json"
    )){
        $sourcePath = Join-Path $SourceRoot $relativePath
        $destinationPath = Join-Path $DestinationRoot $relativePath
        if(!(Test-Path -LiteralPath $destinationPath)){
            throw "Updated toolkit is missing required file: $relativePath"
        }
        if((Get-FileHash -LiteralPath $sourcePath -Algorithm SHA256).Hash -ne (Get-FileHash -LiteralPath $destinationPath -Algorithm SHA256).Hash){
            throw "Updated toolkit verification failed for: $relativePath"
        }
        $verified += $relativePath
    }
    $verified
}

$result = [ordered]@{
    SourceRoot = $SourceRoot
    DestinationRoot = $DestinationRoot
    StartedAt = (Get-Date).ToString("s")
    CompletedAt = ""
    Status = "Running"
    ExitCode = $null
    CopySummary = ""
    SourceVersion = ""
    SourceBuild = 0
    DestinationVersion = ""
    DestinationBuild = 0
    VerifiedFiles = @()
    Error = ""
}

try {
    $SourceRoot = Resolve-NetworkToolkitFileSystemPath -Path $SourceRoot
    if(Test-Path -LiteralPath $DestinationRoot){
        $DestinationRoot = Resolve-NetworkToolkitFileSystemPath -Path $DestinationRoot
    }
    else {
        New-Item -ItemType Directory -Path $DestinationRoot -Force | Out-Null
        $DestinationRoot = Resolve-NetworkToolkitFileSystemPath -Path $DestinationRoot
    }
    if($SourceRoot.Equals($DestinationRoot,[System.StringComparison]::OrdinalIgnoreCase)){
        throw "Source and destination must be different folders."
    }

    $sourceManifest = Get-NetworkToolkitVersionManifest -ToolkitRoot $SourceRoot
    $result.SourceRoot = $SourceRoot
    $result.DestinationRoot = $DestinationRoot
    $result.SourceVersion = $sourceManifest.VersionText
    $result.SourceBuild = $sourceManifest.Build

    $destinationManifestPath = Join-Path $DestinationRoot "manifests\toolkit-version.json"
    if(Test-Path -LiteralPath $destinationManifestPath){
        $destinationManifest = Get-NetworkToolkitVersionManifest -ToolkitRoot $DestinationRoot
        $result.DestinationVersion = $destinationManifest.VersionText
        $result.DestinationBuild = $destinationManifest.Build
        if($sourceManifest.Version -lt $destinationManifest.Version -or
           ($sourceManifest.Version -eq $destinationManifest.Version -and $sourceManifest.Build -lt $destinationManifest.Build)){
            throw "Source version $($sourceManifest.VersionText) build $($sourceManifest.Build) is older than destination version $($destinationManifest.VersionText) build $($destinationManifest.Build)."
        }
        if($sourceManifest.Version -eq $destinationManifest.Version -and $sourceManifest.Build -eq $destinationManifest.Build){
            $result.Status = "Current"
            $result.ExitCode = 0
            $result.CopySummary = "Destination already has Network Toolkit $($sourceManifest.VersionText) build $($sourceManifest.Build)."
            return
        }
    }

    $excludeDirectories = @(
        (Join-Path $SourceRoot ".git"),
        (Join-Path $SourceRoot "Release"),
        (Join-Path $SourceRoot "CSI-NetworkToolkit\Data"),
        (Join-Path $SourceRoot "CSI-NetworkToolkit\Exports"),
        (Join-Path $SourceRoot "CSI-NetworkToolkit\Logs"),
        (Join-Path $SourceRoot "CSI-NetworkToolkit\ExternalTools"),
        (Join-Path $SourceRoot "Custom")
    )
    $arguments = @($SourceRoot,$DestinationRoot,"/E","/COPY:DAT","/DCOPY:DAT","/R:1","/W:1","/NFL","/NDL","/NJH","/NJS","/NP","/XD") + $excludeDirectories + @("/XF",(Join-Path $SourceRoot "manifests\gui-settings.json"))
    & robocopy @arguments | Out-String | Set-Content -LiteralPath ($ResultPath + ".log") -Encoding UTF8
    $result.ExitCode = $LASTEXITCODE
    if($result.ExitCode -gt 7){
        throw "Robocopy failed with exit code $($result.ExitCode). Review $($ResultPath).log for details."
    }
    $result.CopySummary = Get-NetworkToolkitRobocopySummary -ExitCode $result.ExitCode
    $result.VerifiedFiles = @(Test-NetworkToolkitCopy -SourceRoot $SourceRoot -DestinationRoot $DestinationRoot)
    $result.Status = "Completed"
}
catch {
    $result.Status = "Failed"
    $result.Error = $_.Exception.Message
}
finally {
    $result.CompletedAt = (Get-Date).ToString("s")
    $result | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $ResultPath -Encoding UTF8
}

if($result.Status -eq "Failed") { exit 1 }
