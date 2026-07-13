$ErrorActionPreference='Stop'
$appRoot=Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
. (Join-Path $appRoot 'DeploymentIntegrity.ps1')
function Assert-True{param([bool]$Condition,[string]$Message)if(!$Condition){throw $Message}}
$root=Join-Path $env:TEMP ('TASK-0092-'+[guid]::NewGuid().ToString('N'))
try{
    $image=Join-Path $root 'image';New-Item -ItemType Directory -Path $image -Force|Out-Null
    'alpha'|Set-Content (Join-Path $image 'a.txt');'beta'|Set-Content (Join-Path $image 'b.txt')
    $manifest=New-NTKManagedFileManifest -Root $image
    Assert-True ((Test-NTKManagedFileManifest -Root $image -Manifest $manifest).passed) 'Valid managed image failed.'
    Remove-Item (Join-Path $image 'a.txt')
    Assert-True (!(Test-NTKManagedFileManifest -Root $image -Manifest $manifest).passed) 'Missing payload was accepted.'
    'alpha'|Set-Content (Join-Path $image 'a.txt');'corrupt'|Set-Content (Join-Path $image 'b.txt')
    Assert-True (!(Test-NTKManagedFileManifest -Root $image -Manifest $manifest).passed) 'Corrupt payload was accepted.'

    $wrong=Join-Path $root 'wrong';New-Item -ItemType Directory -Path $wrong -Force|Out-Null
    Assert-True (!(Test-NTKDeploymentIdentity -DeploymentRoot $wrong)) 'Wrong destination identity was accepted.'

    $destination=Join-Path $root 'destination';New-Item -ItemType Directory -Path $destination -Force|Out-Null;'prior'|Set-Content (Join-Path $destination 'state.txt')
    $stage=Join-Path $root 'stage';New-Item -ItemType Directory -Path $stage -Force|Out-Null;'new'|Set-Content (Join-Path $stage 'state.txt')
    $interrupted=Invoke-NTKStagedDirectorySwap -StagedPath $stage -DestinationPath $destination -InterruptionPoint {param($point)if($point -eq 'after-backup'){throw 'interrupted fixture'}}
    Assert-True ($interrupted.rollbackSucceeded -and (Get-Content (Join-Path $destination 'state.txt')) -eq 'prior') 'Interrupted update did not restore prior image.'

    $stage2=Join-Path $root 'stage2';New-Item -ItemType Directory -Path $stage2 -Force|Out-Null;'new'|Set-Content (Join-Path $stage2 'state.txt')
    $verifyFail=Invoke-NTKStagedDirectorySwap -StagedPath $stage2 -DestinationPath $destination -PostSwapVerify {$false}
    Assert-True ($verifyFail.rollbackSucceeded -and (Get-Content (Join-Path $destination 'state.txt')) -eq 'prior') 'Failed post-swap reconciliation did not roll back.'

    $stageOk=Join-Path $root 'stage-ok';New-Item -ItemType Directory -Path $stageOk -Force|Out-Null;'replacement'|Set-Content (Join-Path $stageOk 'state.txt')
    $swapped=Invoke-NTKStagedDirectorySwap -StagedPath $stageOk -DestinationPath $destination -PostSwapVerify {param($installed)(Get-Content (Join-Path $installed 'state.txt')) -eq 'replacement'}
    Assert-True ($swapped.state -eq 'Succeeded' -and (Get-Content (Join-Path $destination 'state.txt')) -eq 'replacement' -and !(Test-Path ($destination+'.ntk-backup'))) 'Verified swap did not commit cleanly.'

    $locked=Join-Path $destination 'obsolete.lock';$stream=[IO.File]::Open($locked,[IO.FileMode]::Create,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)
    try{
        $stage3=Join-Path $root 'stage3';New-Item -ItemType Directory -Path $stage3 -Force|Out-Null;'new'|Set-Content (Join-Path $stage3 'state.txt')
        $lockedResult=Invoke-NTKStagedDirectorySwap -StagedPath $stage3 -DestinationPath $destination -InterruptionPoint {param($point)if($point -eq 'before-swap'){throw 'locked obsolete fixture'}}
        Assert-True ($lockedResult.state -ne 'Succeeded' -and (Test-Path $locked)) 'Locked obsolete-file failure was not detected.'
    }finally{$stream.Dispose()}
    Write-Host 'TASK-0092 deployment integrity fixtures passed.'
}finally{if(Test-Path $root){Remove-Item -LiteralPath $root -Recurse -Force}}
