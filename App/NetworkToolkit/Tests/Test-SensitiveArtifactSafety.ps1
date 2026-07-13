$ErrorActionPreference='Stop'
$repoRoot=Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
. (Join-Path $repoRoot 'App\NetworkToolkit\Utilities\AtomicState.ps1')
. (Join-Path $repoRoot 'App\NetworkToolkit\Utilities\ReportingContract.ps1')
. (Join-Path $repoRoot 'App\NetworkToolkit\Utilities\ArtifactPolicy.ps1')
. (Join-Path $repoRoot 'App\NetworkToolkit\Utilities\ReportingRetention.ps1')
. (Join-Path $repoRoot 'App\NetworkToolkit\Utilities\ComputerState.ps1')
. (Join-Path $repoRoot 'App\NetworkToolkit\Utilities\ClientDataTransfer.ps1')
function Global:Register-NTKCommand {}
. (Join-Path $repoRoot 'App\NetworkToolkit\Plugins\SoftwareKeyFinder\SoftwareKeyFinder.ps1')
function Assert-True([bool]$Value,[string]$Message){if(!$Value){throw $Message}}

$testRoot=Join-Path $env:TEMP ('TASK-0094-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $testRoot|Out-Null
try{
    $Global:NTKPaths=[pscustomobject]@{Data=(Join-Path $testRoot 'Runtime\Data');Exports=(Join-Path $testRoot 'Runtime\Exports');Logs=(Join-Path $testRoot 'Runtime\Logs')}
    New-Item -ItemType Directory -Path $NTKPaths.Data,$NTKPaths.Exports,$NTKPaths.Logs -Force|Out-Null
    $keys=@([pscustomobject]@{Product='Fixture';Key='AAAAA-BBBBB-CCCCC-DDDDD-EEEEE';Source='Fixture';Note='Fixture'})
    $masked=Export-NTKSoftwareKeyReport -RecoveredKeys $keys -ActivationInventory @()
    $maskedText=Get-Content $masked -Raw
    Assert-True ($maskedText -notmatch 'AAAAA-BBBBB') 'Masked export leaked a full key.'
    Assert-True ($maskedText -match 'EEEEE') 'Masked export omitted the identifying suffix.'
    $blocked=$false;try{Export-NTKSoftwareKeyReport -RecoveredKeys $keys -ActivationInventory @() -Reveal|Out-Null}catch{$blocked=$true}
    Assert-True $blocked 'Reveal without explicit confirmation was not blocked.'
    $revealed=Export-NTKSoftwareKeyReport -RecoveredKeys $keys -ActivationInventory @() -Reveal -ConfirmSensitiveAction -Reason 'fixture'
    Assert-True ((Get-Content $revealed -Raw) -match 'AAAAA-BBBBB') 'Confirmed reveal did not export the value.'
    Assert-True (Test-Path (Join-Path $NTKPaths.Logs 'SensitiveActions\audit.jsonl')) 'Sensitive action audit was not written.'

    $retentionRoot=Join-Path $testRoot 'retention';New-Item -ItemType Directory $retentionRoot|Out-Null
    $pinned=Join-Path $retentionRoot 'pinned.log';$expired=Join-Path $retentionRoot 'expired.log';'x'|Set-Content $pinned;'x'|Set-Content $expired
    (Get-Item $pinned).LastWriteTime=(Get-Date).AddDays(-30);(Get-Item $expired).LastWriteTime=(Get-Date).AddDays(-30)
    @{SchemaVersion=1;Path=$pinned;Classification='ClientEvidence';CreatedAt=(Get-Date).AddDays(-30).ToString('o');RetentionDays=1;Pinned=$true}|ConvertTo-Json|Set-Content (Get-NTKArtifactMetadataPath $pinned)
    @{SchemaVersion=1;Path=$expired;Classification='ClientEvidence';CreatedAt=(Get-Date).AddDays(-30).ToString('o');RetentionDays=1;Pinned=$false}|ConvertTo-Json|Set-Content (Get-NTKArtifactMetadataPath $expired)
    Clear-NTKOutputQuota -Path $retentionRoot -Pattern '*.log' -KeepCount 0 -MaxAgeDays 1
    Assert-True (Test-Path $pinned) 'Pinned artifact was deleted.';Assert-True (!(Test-Path $expired)) 'Expired unpinned artifact was retained.'

    $statePath=Get-NTKComputerStatePath -ComputerName 'ATOMIC'
    $initial=[ordered]@{SchemaVersion=1;ComputerName='ATOMIC';CreatedAt=(Get-Date).ToString('s');UpdatedAt='';Sections=[ordered]@{}}
    Write-NTKComputerState -State $initial -ComputerName 'ATOMIC'|Out-Null
    $interrupted=$false;try{Write-NTKAtomicJson -Path $statePath -Value @{broken=$true} -BeforeCommit {param($p) throw 'fixture interruption'}|Out-Null}catch{$interrupted=$true}
    Assert-True $interrupted 'Interrupted write fixture did not interrupt.';Assert-True ((Read-NTKComputerState -ComputerName 'ATOMIC').ComputerName -eq 'ATOMIC') 'Interrupted write damaged final state.'

    $atomicScript=Join-Path $repoRoot 'App\NetworkToolkit\Utilities\AtomicState.ps1';$stateScript=Join-Path $repoRoot 'App\NetworkToolkit\Utilities\ComputerState.ps1';$dataRoot=$NTKPaths.Data
    $jobs=@()
    $jobs+=Start-Job -ScriptBlock {param($a,$c,$d). $a;. $c;$Global:NTKPaths=[pscustomobject]@{Data=$d};Set-NTKComputerStateSection -ComputerName ATOMIC -SectionName One -Data @{Value=1}} -ArgumentList $atomicScript,$stateScript,$dataRoot
    $jobs+=Start-Job -ScriptBlock {param($a,$c,$d). $a;. $c;$Global:NTKPaths=[pscustomobject]@{Data=$d};Set-NTKComputerStateSection -ComputerName ATOMIC -SectionName Two -Data @{Value=2}} -ArgumentList $atomicScript,$stateScript,$dataRoot
    $jobs|Wait-Job|Receive-Job|Out-Null;$jobs|Remove-Job
    $concurrent=Read-NTKComputerState -ComputerName ATOMIC
    Assert-True ($concurrent.Sections.Contains('One') -and $concurrent.Sections.Contains('Two')) 'Concurrent state update was lost.'

    $source=Join-Path $testRoot 'source';$destination=Join-Path $testRoot 'destination'
    foreach($root in @($source,$destination)){New-Item -ItemType Directory -Path (Join-Path $root 'App\NetworkToolkit') -Force|Out-Null;New-Item -ItemType File -Path (Join-Path $root 'NetworkToolkit.vbs')|Out-Null;New-Item -ItemType File -Path (Join-Path $root 'App\NetworkToolkit\NetworkToolkit-Core.ps1')|Out-Null}
    New-Item -ItemType Directory -Path (Join-Path $source 'Runtime\Exports') -Force|Out-Null
    'normal'|Set-Content (Join-Path $source 'Runtime\Exports\diagnostic-report.txt');'secret'|Set-Content (Join-Path $source 'Runtime\Exports\software-key-report.html')
    $transfer=Copy-NTKClientData -SourceRoot $source -DestinationRoot $destination
    Assert-True (Test-Path (Join-Path $destination 'Runtime\Exports\diagnostic-report.txt')) 'Selected evidence was not transferred.'
    Assert-True (!(Test-Path (Join-Path $destination 'Runtime\Exports\software-key-report.html'))) 'Sensitive evidence transferred by default.'
    $destination2=Join-Path $testRoot 'destination2';New-Item -ItemType Directory -Path (Join-Path $destination2 'App\NetworkToolkit') -Force|Out-Null;New-Item -ItemType File -Path (Join-Path $destination2 'NetworkToolkit.vbs')|Out-Null;New-Item -ItemType File -Path (Join-Path $destination2 'App\NetworkToolkit\NetworkToolkit-Core.ps1')|Out-Null
    Copy-NTKClientData -SourceRoot $source -DestinationRoot $destination2 -IncludeSensitivity Operational,ClientEvidence,Sensitive -EncryptSensitive -EncryptionPassword 'fixture-password'|Out-Null
    Assert-True (Test-Path (Join-Path $destination2 'Runtime\Exports\software-key-report.html.ntkenc')) 'Sensitive evidence was not encrypted.'

    $policy=Get-Content (Join-Path $repoRoot 'App\manifests\portable-state-policy.json') -Raw|ConvertFrom-Json
    Assert-True ($policy.runtimeRoot -eq '..\Runtime' -and @($policy.mutablePaths).Count -gt 0) 'Default/runtime separation policy is invalid.'
    $declared=@($policy.mutablePaths|ForEach-Object{$_ -replace '/','\'})
    $actual=@(Get-ChildItem (Join-Path $repoRoot 'App\Custom') -Directory -Recurse -ErrorAction SilentlyContinue|Where-Object Name -ceq Data|ForEach-Object{$_.FullName.Substring((Join-Path $repoRoot 'App').Length+1)})
    Assert-True (@($actual|Where-Object{$declared -notcontains $_}).Count -eq 0) 'A mutable portable Data path is not explicitly declared.'
    $layout=Join-Path $testRoot 'layout';$config=Join-Path $layout 'App\NetworkToolkit\Config';$manifests=Join-Path $layout 'App\manifests'
    New-Item -ItemType Directory -Path $config,$manifests -Force|Out-Null
    Copy-Item (Join-Path $repoRoot 'App\NetworkToolkit\Config\ToolkitPaths.ps1') $config
    '{"schemaVersion":3,"tools":[]}'|Set-Content (Join-Path $manifests 'custom-tools.json')
    $defaultHash=(Get-FileHash (Join-Path $manifests 'custom-tools.json')).Hash
    . (Join-Path $config 'ToolkitPaths.ps1')
    Assert-True ($NTKFiles.CustomTools -like '*Runtime\State\custom-tools.json' -and $NTKFiles.CustomToolsDefaults -like '*App\manifests\custom-tools.json') 'Runtime manifest was not separated from shipped defaults.'
    Assert-True ((Get-FileHash (Join-Path $manifests 'custom-tools.json')).Hash -eq $defaultHash) 'Runtime initialization mutated shipped defaults.'
    Write-Host 'TASK-0094 sensitive artifact and runtime-state fixtures passed.' -ForegroundColor Green
}finally{
    Remove-Item Function:\Register-NTKCommand -Force -ErrorAction SilentlyContinue
    if(Test-Path $testRoot){Remove-Item $testRoot -Recurse -Force}
}
