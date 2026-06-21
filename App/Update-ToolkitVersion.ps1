[CmdletBinding()]
param(
    [string]$Version = "",
    [string]$ReleaseNotes = ""
)

$ErrorActionPreference = "Stop"
$manifestPath = Join-Path $PSScriptRoot "manifests\toolkit-version.json"
if(!(Test-Path -LiteralPath $manifestPath)){
    throw "Toolkit version manifest was not found: $manifestPath"
}

$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
if($Version){
    try { [void][version]$Version }
    catch { throw "Version must use numeric semantic format such as 1.0.1." }
    $manifest.Version = $Version
}

$manifest.Build = [int64](Get-Date -Format "yyyyMMddHHmmss")
$manifest.SourceUpdatedAt = (Get-Date).ToString("o")
if($ReleaseNotes){ $manifest.ReleaseNotes = $ReleaseNotes }
if($manifest.PSObject.Properties.Name -contains "Commit"){
    $manifest.PSObject.Properties.Remove("Commit")
}

$manifest | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
Write-Host ("Updated {0} version {1}, build {2}." -f $manifest.Product,$manifest.Version,$manifest.Build) -ForegroundColor Green
