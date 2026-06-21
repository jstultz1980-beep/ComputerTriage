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

function Resolve-NetworkToolkitLayout {
    param([Parameter(Mandatory=$true)][string]$Path)

    $deploymentRoot = Resolve-NetworkToolkitFileSystemPath -Path $Path
    $appRoot = Join-Path $deploymentRoot "App"
    if(Test-Path -LiteralPath (Join-Path $appRoot "manifests\toolkit-version.json")){
        return [pscustomobject]@{ DeploymentRoot=$deploymentRoot; AppRoot=$appRoot; IsLegacy=$false }
    }
    if(Test-Path -LiteralPath (Join-Path $deploymentRoot "manifests\toolkit-version.json")){
        return [pscustomobject]@{ DeploymentRoot=$deploymentRoot; AppRoot=$deploymentRoot; IsLegacy=$true }
    }
    throw "Network Toolkit version manifest was not found in $deploymentRoot or $deploymentRoot\App."
}

function Move-NetworkToolkitLegacyLayout {
    param([Parameter(Mandatory=$true)]$Layout)
    if(!$Layout.IsLegacy){ return $Layout }

    $newAppRoot = Join-Path $Layout.DeploymentRoot "App"
    New-Item -ItemType Directory -Path $newAppRoot -Force | Out-Null
    foreach($name in @("CSI-NetworkToolkit","Custom","manifests","ToolKit-GUI")){
        $legacyPath = Join-Path $Layout.DeploymentRoot $name
        if(Test-Path -LiteralPath $legacyPath){
            Move-Item -LiteralPath $legacyPath -Destination $newAppRoot -ErrorAction Stop
        }
    }
    [pscustomobject]@{ DeploymentRoot=$Layout.DeploymentRoot; AppRoot=$newAppRoot; IsLegacy=$false }
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

function Remove-NetworkToolkitObsoleteProgramFiles {
    param(
        [Parameter(Mandatory=$true)][string]$SourceRoot,
        [Parameter(Mandatory=$true)][string]$DestinationRoot
    )

    # Only prune code locations owned by the updater. Runtime data, portable
    # apps, and technician settings are intentionally never part of this pass.
    $managedRoots = @(
        "ToolKit-GUI",
        "CSI-NetworkToolkit\Config",
        "CSI-NetworkToolkit\Core",
        "CSI-NetworkToolkit\Discovery",
        "CSI-NetworkToolkit\Plugins",
        "CSI-NetworkToolkit\UI",
        "CSI-NetworkToolkit\Utilities",
        "manifests"
    )
    $preservedPaths = @(
        "manifests\gui-settings.json",
        "manifests\custom-tools.json",
        "manifests\custom-tools.json.bak"
    )
    $managedRootFiles = @(
        ".gitignore",
        "NetworkToolkit.ps1",
        "NetworkToolkit-Elevated.bat",
        "Update-NetworkToolkit.ps1",
        "Update-ToolkitVersion.ps1",
        "Build-ProductionPackage.ps1",
        "Test-ProductionPackage.ps1"
    )
    $removed = 0
    $skipped = 0

    # The root is owned by the toolkit launcher. Restrict it to known program
    # files so stale production-package documents and accidental loose files
    # do not persist from one deployment to the next.
    foreach($destinationFile in @(Get-ChildItem -LiteralPath $DestinationRoot -File -Force -ErrorAction SilentlyContinue)){
        if($managedRootFiles -contains $destinationFile.Name){ continue }
        try {
            Remove-Item -LiteralPath $destinationFile.FullName -Force -ErrorAction Stop
            $removed++
        }
        catch {
            $skipped++
        }
    }

    foreach($relativeRoot in $managedRoots){
        $destinationManagedRoot = Join-Path $DestinationRoot $relativeRoot
        if(!(Test-Path -LiteralPath $destinationManagedRoot)){ continue }

        foreach($destinationFile in @(Get-ChildItem -LiteralPath $destinationManagedRoot -Recurse -File -Force -ErrorAction SilentlyContinue)){
            $relativePath = $destinationFile.FullName.Substring($DestinationRoot.Length).TrimStart('\\')
            if($preservedPaths -contains $relativePath -or $relativePath -match '(?i)(^|\\)(Data|Logs|ExternalTools|Exports)(\\|$)'){
                continue
            }

            if(Test-Path -LiteralPath (Join-Path $SourceRoot $relativePath)){ continue }
            try {
                Remove-Item -LiteralPath $destinationFile.FullName -Force -ErrorAction Stop
                $removed++
            }
            catch {
                $skipped++
            }
        }
    }

    foreach($legacyRelativePath in @(
        "LAST-UPDATED.txt",
        "manifests\toolkit-update-history.json"
    )){
        $legacyPath = Join-Path $DestinationRoot $legacyRelativePath
        if(Test-Path -LiteralPath $legacyPath){
            try {
                Remove-Item -LiteralPath $legacyPath -Force -ErrorAction Stop
                $removed++
            }
            catch {
                $skipped++
            }
        }
    }

    [pscustomobject]@{ Removed = $removed; Skipped = $skipped }
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
    PrunedFiles = 0
    PruneSkippedFiles = 0
    Error = ""
}

try {
    $sourceLayout = Resolve-NetworkToolkitLayout -Path $SourceRoot
    if(!(Test-Path -LiteralPath $DestinationRoot)){ New-Item -ItemType Directory -Path $DestinationRoot -Force | Out-Null }
    $destinationLayout = Resolve-NetworkToolkitLayout -Path $DestinationRoot
    if($sourceLayout.DeploymentRoot.Equals($destinationLayout.DeploymentRoot,[System.StringComparison]::OrdinalIgnoreCase)){
        throw "Source and destination must be different folders."
    }

    $destinationLayout = Move-NetworkToolkitLegacyLayout -Layout $destinationLayout
    $SourceRoot = $sourceLayout.AppRoot
    $DestinationRoot = $destinationLayout.AppRoot

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
            $pruneResult = Remove-NetworkToolkitObsoleteProgramFiles -SourceRoot $SourceRoot -DestinationRoot $DestinationRoot
            $result.PrunedFiles = $pruneResult.Removed
            $result.PruneSkippedFiles = $pruneResult.Skipped
            $result.Status = "Current"
            $result.ExitCode = 0
            $result.CopySummary = "Destination already has Network Toolkit $($sourceManifest.VersionText) build $($sourceManifest.Build); cleanup was still completed."
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
    $pruneResult = Remove-NetworkToolkitObsoleteProgramFiles -SourceRoot $SourceRoot -DestinationRoot $DestinationRoot
    $result.PrunedFiles = $pruneResult.Removed
    $result.PruneSkippedFiles = $pruneResult.Skipped
    $result.VerifiedFiles = @(Test-NetworkToolkitCopy -SourceRoot $SourceRoot -DestinationRoot $DestinationRoot)
    Copy-Item -LiteralPath (Join-Path $sourceLayout.DeploymentRoot "NetworkToolkit-Elevated.bat") -Destination (Join-Path $destinationLayout.DeploymentRoot "NetworkToolkit-Elevated.bat") -Force
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
