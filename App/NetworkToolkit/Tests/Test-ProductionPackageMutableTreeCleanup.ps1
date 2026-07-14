$ErrorActionPreference='Stop'
$repoRoot=Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
. (Join-Path $repoRoot 'App\PackageCleanup.ps1')

function Assert-True{
    param([bool]$Condition,[string]$Message)
    if(!$Condition){ throw $Message }
}

function New-DeepMutableTreeFixture {
    param([Parameter(Mandatory=$true)][string]$Root)

    $path = $Root
    foreach($segment in @(
        'App','Custom','LibreOfficePortable','Data','settings','user','extensions','bundled','registry',
        'com.sun.star.comp.configuration.backend.Lua','lu123.tmp','another','deep','path','segment','final'
    )){
        $path = Join-Path $path $segment
    }

    while($path.Length -lt 280){
        $path = Join-Path $path ('more-' + [guid]::NewGuid().ToString('N'))
    }

    $filePath = Join-Path $path 'OptionsDialog.xcu'
    $extendedDirectory = ConvertTo-NTKExtendedPath -Path $path
    [System.IO.Directory]::CreateDirectory($extendedDirectory) | Out-Null
    [System.IO.File]::WriteAllText((ConvertTo-NTKExtendedPath -Path $filePath), 'fixture')
    return [pscustomobject]@{
        Root = $path
        File = $filePath
    }
}

$root=Join-Path $env:TEMP ('TASK-0111-'+[guid]::NewGuid().ToString('N'))
try{
    $packageRoot = Join-Path $root 'Package'
    $mutableRoot = Join-Path $packageRoot 'App\Custom\LibreOfficePortable\Data'
    $deepFixture = New-DeepMutableTreeFixture -Root $packageRoot
    Assert-True ([System.IO.File]::Exists((ConvertTo-NTKExtendedPath -Path $deepFixture.File))) 'Long-path fixture file was not created.'

    Invoke-NTKMutableTreeCleanup -Path $mutableRoot

    $remaining = @(Get-ChildItem -LiteralPath $mutableRoot -Recurse -File -Force -ErrorAction SilentlyContinue)
    Assert-True ($remaining.Count -eq 0) 'Long-path cleanup fixture left file residue behind.'

    $lockedPackageRoot = Join-Path $root 'LockedPackage'
    $lockedRoot = Join-Path $lockedPackageRoot 'App\Custom\LibreOfficePortable\Data'
    $lockedFixture = New-DeepMutableTreeFixture -Root $lockedPackageRoot
    $stream = [System.IO.File]::Open((ConvertTo-NTKExtendedPath -Path $lockedFixture.File),[System.IO.FileMode]::Open,[System.IO.FileAccess]::ReadWrite,[System.IO.FileShare]::None)
    try{
        $failed = $false
        try{
            Invoke-NTKMutableTreeCleanup -Path $lockedRoot
        }
        catch{
            $failed = $true
        }
        Assert-True $failed 'Locked long-path cleanup was not rejected.'
    }
    finally{
        $stream.Dispose()
    }

    Invoke-NTKMutableTreeCleanup -Path $lockedRoot
    Assert-True ((Get-ChildItem -LiteralPath $lockedRoot -Recurse -File -Force -ErrorAction SilentlyContinue).Count -eq 0) 'Locked fixture was not cleared after unlock.'

    Write-Host 'TASK-0111 mutable-tree cleanup fixtures passed.' -ForegroundColor Green
}
finally{
    if(Test-Path -LiteralPath $root){ Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue }
}
