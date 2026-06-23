[CmdletBinding()]
param(
    [string]$PackageRoot = ""
)

$ErrorActionPreference = "Stop"
$PackageRoot = if($PackageRoot){$PackageRoot}else{(Split-Path -Parent $PSScriptRoot)}
$PackageRoot = (Resolve-Path -LiteralPath $PackageRoot).Path

if(!(Test-Path -LiteralPath (Join-Path $PackageRoot "App\manifests\ProductionManifest.json")) -and (Test-Path -LiteralPath (Join-Path $PackageRoot ".git"))){
    throw "This is the source workspace, not a built portable package. Run Build-ProductionPackage.ps1 first, then run this verifier against the generated package folder."
}

$failures = New-Object System.Collections.ArrayList

function Test-PackagePath {
    param([string]$RelativePath)

    $path = Join-Path $PackageRoot $RelativePath
    if(!(Test-Path -LiteralPath $path)){
        [void]$failures.Add("Missing required path: $RelativePath")
    }
}

foreach($requiredPath in @(
    "NetworkToolkit.vbs",
    "App\NetworkToolkit.ps1",
    "App\ToolKit-GUI\ToolKit-GUI.ps1",
    "App\CSI-NetworkToolkit\CSI-NetworkToolkit.ps1",
    "App\CSI-NetworkToolkit\ExternalTools\Sysinternals",
    "App\manifests\ProductionManifest.json",
    "App\DEPLOYMENT-README.txt"
)){
    Test-PackagePath -RelativePath $requiredPath
}

$manifestPath = Join-Path $PackageRoot "App\manifests\ProductionManifest.json"
if(Test-Path -LiteralPath $manifestPath){
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json

    foreach($launcher in @($manifest.Launchers)){
        $path = Join-Path $PackageRoot $launcher.Path
        if(!(Test-Path -LiteralPath $path)){
            [void]$failures.Add("Launcher missing: $($launcher.Path)")
            continue
        }

        $actualHash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
        if($actualHash -ne $launcher.SHA256){
            [void]$failures.Add("Launcher hash mismatch: $($launcher.Path)")
        }
    }
}
else{
    [void]$failures.Add("ProductionManifest.json is missing.")
}

foreach($relativePath in @(
    ".git",
    "App\CSI-NetworkToolkit\Exports",
    "App\CSI-NetworkToolkit\Data\ComputerState",
    "App\CSI-NetworkToolkit\Data\MiniDumps",
    "App\manifests\gui-settings.json"
)){
    $path = Join-Path $PackageRoot $relativePath
    if($relativePath -eq ".git"){
        if(Test-Path -LiteralPath $path){
            [void]$failures.Add("Git metadata should not be included in the portable package.")
        }
        continue
    }

    if(Test-Path -LiteralPath $path){
        $fileCount = @(Get-ChildItem -LiteralPath $path -Recurse -File -Force -ErrorAction SilentlyContinue).Count
        if($fileCount -gt 0){
            [void]$failures.Add("Client/runtime data is present in $relativePath ($fileCount file(s)).")
        }
    }
}

$customRoot = Join-Path $PackageRoot 'App\Custom'
if(Test-Path -LiteralPath $customRoot){
    foreach($dataFolder in @(Get-ChildItem -LiteralPath $customRoot -Directory -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -ceq 'Data' })){
        $fileCount = @(Get-ChildItem -LiteralPath $dataFolder.FullName -Recurse -File -Force -ErrorAction SilentlyContinue).Count
        if($fileCount -gt 0){
            [void]$failures.Add("Portable app data is present in $($dataFolder.FullName) ($fileCount file(s)).")
        }
    }
}

$files = @(Get-ChildItem -LiteralPath $PackageRoot -Recurse -File -Force -ErrorAction SilentlyContinue)
$sizeGB = [math]::Round((($files | Measure-Object -Property Length -Sum).Sum / 1GB),2)

if($failures.Count -gt 0){
    Write-Host "Production package validation failed:" -ForegroundColor Red
    $failures | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
    exit 1
}

Write-Host "Production package validation passed." -ForegroundColor Green
Write-Host "Package: $PackageRoot"
Write-Host "Size: $sizeGB GB"
Write-Host "Files: $($files.Count)"
