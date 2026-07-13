$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
. (Join-Path $repoRoot 'App\DeploymentIntegrity.ps1')

function Assert-True {
    param([bool]$Condition,[string]$Message)
    if(!$Condition){ throw $Message }
}

function Invoke-PackageVerifierFixture {
    param([string]$PackageRoot)
    $process = Start-Process powershell.exe -ArgumentList @(
        '-NoProfile','-ExecutionPolicy','Bypass','-File',
        ('"{0}"' -f (Join-Path $repoRoot 'App\Test-ProductionPackage.ps1')),
        '-PackageRoot',('"{0}"' -f $PackageRoot)
    ) -WindowStyle Hidden -Wait -PassThru
    return $process.ExitCode
}

$root = Join-Path ([IO.Path]::GetTempPath()) ('ntk-production-contract-' + [guid]::NewGuid().ToString('N'))
try {
    $packageRoot = Join-Path $root 'Package'
    $paths = @(
        'App\manifests',
        'App\ToolKit-GUI',
        'App\NetworkToolkit\ExternalTools\Sysinternals'
    )
    foreach($relative in $paths){ New-Item -ItemType Directory -Path (Join-Path $packageRoot $relative) -Force | Out-Null }

    $files = [ordered]@{
        'NetworkToolkit.vbs' = 'fixture launcher'
        'App\NetworkToolkit.ps1' = 'Write-Host fixture'
        'App\ToolKit-GUI\ToolKit-GUI.ps1' = 'Write-Host fixture'
        'App\NetworkToolkit\NetworkToolkit-Core.ps1' = 'Write-Host fixture'
        'App\DEPLOYMENT-README.txt' = 'fixture package'
    }
    foreach($relative in $files.Keys){
        $path = Join-Path $packageRoot $relative
        $parent = Split-Path -Parent $path
        if(!(Test-Path -LiteralPath $parent)){ New-Item -ItemType Directory -Path $parent -Force | Out-Null }
        $files[$relative] | Set-Content -LiteralPath $path -Encoding UTF8
    }

    $launchers = @('NetworkToolkit.vbs','App\NetworkToolkit.ps1','App\ToolKit-GUI\ToolKit-GUI.ps1','App\NetworkToolkit\NetworkToolkit-Core.ps1') | ForEach-Object {
        [pscustomobject]@{ Path=$_; SHA256=(Get-FileHash -LiteralPath (Join-Path $packageRoot $_) -Algorithm SHA256).Hash }
    }
    $managedFiles = New-NTKManagedFileManifest -Root $packageRoot -ExcludeRelativePaths @('App\manifests\ProductionManifest.json')
    [ordered]@{schemaVersion='1.0';Launchers=$launchers;ManagedFiles=$managedFiles} |
        ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $packageRoot 'App\manifests\ProductionManifest.json') -Encoding UTF8

    Assert-True ((Invoke-PackageVerifierFixture -PackageRoot $packageRoot) -eq 0) 'Production verifier rejected a valid managed package fixture.'
    'tamper' | Add-Content -LiteralPath (Join-Path $packageRoot 'App\NetworkToolkit.ps1')
    Assert-True ((Invoke-PackageVerifierFixture -PackageRoot $packageRoot) -eq 1) 'Production verifier accepted a tampered managed package fixture.'
    Write-Host 'Production package positive/tamper contract fixtures passed.' -ForegroundColor Green
}
finally {
    if(Test-Path -LiteralPath $root){ Remove-Item -LiteralPath $root -Recurse -Force }
}
