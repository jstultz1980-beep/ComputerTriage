[CmdletBinding()]
param(
    [string]$DestinationRoot = "",
    [string]$PackageName = "NetworkToolkit-Portable",
    [switch]$Zip,
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$sourceRoot = $PSScriptRoot
$DestinationRoot = if($DestinationRoot){$DestinationRoot}else{Join-Path $sourceRoot "Release"}
if([string]::IsNullOrWhiteSpace($PackageName) -or $PackageName -match '[\\/:*?"<>|]'){
    throw "PackageName must be a valid folder name."
}
$packageRoot = Join-Path $DestinationRoot $PackageName

if(!(Test-Path (Join-Path $sourceRoot "NetworkToolkit-Elevated.bat"))){
    throw "NetworkToolkit-Elevated.bat was not found. Run this builder from the toolkit root."
}

if(Test-Path $packageRoot){
    if(!$Force){
        throw "Package folder already exists: $packageRoot. Use -Force to replace it."
    }

    Remove-Item -LiteralPath $packageRoot -Recurse -Force
}

New-Item -ItemType Directory -Path $packageRoot -Force | Out-Null

$excludeDirectories = @(
    (Join-Path $sourceRoot ".git"),
    (Join-Path $sourceRoot "Release"),
    (Join-Path $sourceRoot "CSI-NetworkToolkit\Data"),
    (Join-Path $sourceRoot "CSI-NetworkToolkit\Exports"),
    (Join-Path $sourceRoot "CSI-NetworkToolkit\Logs"),
    (Join-Path $sourceRoot "Custom\FirefoxPortable\Data")
)

Write-Host "Building clean portable package..." -ForegroundColor Cyan
$robocopyArguments = @(
    "`"$sourceRoot`"",
    "`"$packageRoot`"",
    "/E",
    "/COPY:DAT",
    "/DCOPY:DAT",
    "/R:1",
    "/W:1",
    "/NFL",
    "/NDL",
    "/NJH",
    "/NJS",
    "/NP",
    "/XD"
) + @($excludeDirectories | ForEach-Object { "`"$_`"" })

& robocopy @robocopyArguments | Out-Host
if($LASTEXITCODE -gt 7){
    throw "Robocopy failed with exit code $LASTEXITCODE."
}

# Recreate clean runtime folders expected by the toolkit; no client records are copied.
$runtimeFolders = @(
    "CSI-NetworkToolkit\Data",
    "CSI-NetworkToolkit\Data\Fingerprints",
    "CSI-NetworkToolkit\Data\ComputerProfiles",
    "CSI-NetworkToolkit\Data\ComputerState",
    "CSI-NetworkToolkit\Data\MiniDumps",
    "CSI-NetworkToolkit\Data\Temp",
    "CSI-NetworkToolkit\Data\TempToolOutputs",
    "CSI-NetworkToolkit\Exports",
    "CSI-NetworkToolkit\Logs\ToolUsage",
    "Custom\FirefoxPortable\Data"
)

foreach($relativePath in $runtimeFolders){
    New-Item -ItemType Directory -Path (Join-Path $packageRoot $relativePath) -Force | Out-Null
}

# Portable tool logs may sit inside plugin folders rather than the central Logs folder.
Get-ChildItem -LiteralPath $packageRoot -Directory -Recurse -Filter "Logs" -ErrorAction SilentlyContinue |
    ForEach-Object {
        Get-ChildItem -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue |
            Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }

Remove-Item -LiteralPath (Join-Path $packageRoot "manifests\gui-settings.json") -Force -ErrorAction SilentlyContinue

$packageFiles = @(Get-ChildItem -LiteralPath $packageRoot -Recurse -File -Force -ErrorAction SilentlyContinue)
$totalBytes = [int64](($packageFiles | Measure-Object -Property Length -Sum).Sum)
$launchers = @(
    "NetworkToolkit-Elevated.bat",
    "NetworkToolkit.ps1",
    "ToolKit-GUI\ToolKit-GUI.ps1",
    "CSI-NetworkToolkit\CSI-NetworkToolkit.ps1"
) | ForEach-Object {
    $path = Join-Path $packageRoot $_
    if(Test-Path $path){
        [pscustomobject]@{
            Path = $_
            SHA256 = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
        }
    }
}

$manifest = [ordered]@{
    PackageName = "Network Toolkit Portable"
    BuiltAt = (Get-Date).ToString("s")
    SourceRoot = $sourceRoot
    PackageRoot = $packageRoot
    FileCount = $packageFiles.Count
    TotalBytes = $totalBytes
    TotalGB = [math]::Round($totalBytes / 1GB,2)
    ClientDataExcluded = @(
        ".git",
        "Release",
        "CSI-NetworkToolkit\\Data",
        "CSI-NetworkToolkit\\Exports",
        "CSI-NetworkToolkit\\Logs",
        "Custom\\FirefoxPortable\\Data",
        "Plugin Logs",
        "manifests\\gui-settings.json"
    )
    Launchers = $launchers
}

$manifestPath = Join-Path $packageRoot "ProductionManifest.json"
$manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $manifestPath -Encoding UTF8

$readmePath = Join-Path $packageRoot "DEPLOYMENT-README.txt"
@(
    "Network Toolkit Portable - Production Test Package"
    ""
    "Launch: right-click NetworkToolkit-Elevated.bat and choose Run as administrator."
    ""
    "This package is intentionally clean: collected reports, profiles, computer state, minidumps, temporary output, logs, GUI settings, and the previous Firefox Portable profile were excluded."
    ""
    "Before handing the drive to a technician, copy the NetworkToolkit-Portable folder to the thumb drive and run NetworkToolkit-Elevated.bat from that folder."
    ""
    "ProductionManifest.json records build size, file count, and SHA256 hashes for the primary launch files."
    ""
    "After a customer engagement, use Settings > Remove Client Data to clear collected diagnostic data."
) | Set-Content -LiteralPath $readmePath -Encoding UTF8

if($Zip){
    $zipPath = Join-Path $DestinationRoot ("{0}.zip" -f $PackageName)
    Remove-Item -LiteralPath $zipPath -Force -ErrorAction SilentlyContinue
    Write-Host "Creating zip archive..." -ForegroundColor Cyan
    Compress-Archive -LiteralPath $packageRoot -DestinationPath $zipPath -CompressionLevel Optimal -Force
    Write-Host "Zip package: $zipPath" -ForegroundColor Green
}

Write-Host "Portable package ready: $packageRoot" -ForegroundColor Green
Write-Host ("Package size: {0} GB across {1} files" -f $manifest.TotalGB,$manifest.FileCount) -ForegroundColor Green
