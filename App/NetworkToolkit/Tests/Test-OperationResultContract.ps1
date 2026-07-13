$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
. (Join-Path $repoRoot 'App\NetworkToolkit\Utilities\OperationResult.ps1')
. (Join-Path $repoRoot 'Core\Analysis\DiagnosticBundleIdentity.ps1')
. (Join-Path $repoRoot 'App\NetworkToolkit\Core\LocalAnalysisEngine.ps1')
. (Join-Path $repoRoot 'App\NetworkToolkit\Core\LocalAnalysisRules.ps1')
. (Join-Path $repoRoot 'Core\Argus\ArgusFoundation.ps1')

function Assert-True { param([bool]$Condition,[string]$Message) if(!$Condition){throw $Message} }

$expected = @{Succeeded=0;SucceededWithWarnings=0;Partial=2;Failed=1;Blocked=3;Canceled=4}
foreach($state in $expected.Keys){
    $result = New-NTKOperationResult -Operation 'fixture' -State $state
    Assert-True ($result.schemaVersion -eq '1.0' -and $result.terminal) "State $state did not produce a canonical envelope."
    Assert-True ($result.exitCode -eq $expected[$state]) "State $state mapped to the wrong exit code."
}

$launcher = Join-Path $repoRoot 'App\NetworkToolkit.ps1'
$process = Start-Process powershell.exe -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',$launcher,'-CLI','-RunCommand','__missing_operation_fixture__') -Wait -PassThru -WindowStyle Hidden
Assert-True ($process.ExitCode -eq 1) "Thrown/missing CLI command returned exit code $($process.ExitCode), expected 1."

$root = Join-Path $env:TEMP ('TASK-0088-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path (Join-Path $root 'Metadata') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $root 'CommandOutput') -Force | Out-Null
try {
    [ordered]@{runId='RUN-RESULT-001';computerName='RESULT-FIXTURE';startedUtc='2026-01-01T00:00:00Z';endedUtc='2026-01-01T00:01:00Z'} | ConvertTo-Json | Set-Content (Join-Path $root 'Metadata\collection_manifest.json') -Encoding UTF8
    [ordered]@{CsName='RESULT-FIXTURE';WindowsProductName='Fixture';OsBuildNumber='1'} | ConvertTo-Json | Set-Content (Join-Path $root 'CommandOutput\Get-ComputerInfo.json') -Encoding UTF8
    $hep = Invoke-HEPHAESTUSLocalAnalysis -BundleRoot $root
    Assert-True ($hep.state -eq 'Succeeded' -and $hep.exitCode -eq 0) 'HEPHAESTUS did not return a canonical success result.'
    [ordered]@{schemaVersion='999.0'} | ConvertTo-Json | Set-Content (Join-Path $root 'Metadata\schema-version.json') -Encoding UTF8
    $argus = Invoke-ARGUSFoundationAnalysis -BundleRoot $root
    Assert-True ($argus.state -eq 'Failed' -and $argus.exitCode -eq 1) 'Failed ARGUS contract returned false success.'
    $recommendations = Get-Content (Join-Path $root 'ARGUS\recommendations.json') -Raw | ConvertFrom-Json
    Assert-True ($recommendations.status -eq 'suppressed' -and @($recommendations.recommendations).Count -eq 0) 'ARGUS recommendations were not suppressed after contract failure.'
}
finally { if(Test-Path $root){Remove-Item -LiteralPath $root -Recurse -Force} }

Write-Host 'TASK-0088 canonical operation-result fixtures passed.'
