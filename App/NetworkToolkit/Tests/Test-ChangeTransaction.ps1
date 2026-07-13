$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
. (Join-Path $root 'Utilities\OperationResult.ps1')
. (Join-Path $root 'Utilities\ChangeTransaction.ps1')
function Assert-True{param([bool]$Condition,[string]$Message)if(!$Condition){throw $Message}}

$state=@{service='Stopped';firewallA=$false;firewallB=$false;lockedFile='present'}
$success=Invoke-NTKChangeTransaction -Name 'success' -Capture {$state.Clone()} -Apply {param($pre)$state.service='Running';$state.firewallA=$true} -Verify {param($pre,$apply) $state.service -eq 'Running' -and $state.firewallA} -Rollback {param($pre)foreach($k in $pre.Keys){$state[$k]=$pre[$k]}}
Assert-True ($success.state -eq 'Succeeded' -and !$success.rollbackAttempted) 'Verified transaction did not succeed.'

$state=@{service='Stopped';firewallA=$false;firewallB=$false}
$partial=Invoke-NTKChangeTransaction -Name 'partial firewall' -Capture {$state.Clone()} -Apply {param($pre)$state.service='Running';$state.firewallA=$true} -Verify {param($pre,$apply) $state.firewallA -and $state.firewallB} -Rollback {param($pre)foreach($k in $pre.Keys){$state[$k]=$pre[$k]}}
Assert-True ($partial.state -eq 'Failed' -and $partial.rollbackSucceeded -and !$state.firewallA -and $state.service -eq 'Stopped') 'Partial firewall change was not detected and rolled back.'

$state=@{service='Stopped'}
$serviceFail=Invoke-NTKChangeTransaction -Name 'service failure' -Capture {$state.Clone()} -Apply {param($pre)throw 'service start fixture'} -Verify {$false} -Rollback {param($pre)$state.service=$pre.service}
Assert-True ($serviceFail.state -eq 'Failed' -and $serviceFail.rollbackSucceeded) 'Service-start failure did not restore original state.'

$state=@{lockedFile='present'}
$locked=Invoke-NTKChangeTransaction -Name 'locked spool file' -Capture {$state.Clone()} -Apply {param($pre)throw 'file locked fixture'} -Verify {$false} -Rollback {param($pre)$state.lockedFile=$pre.lockedFile}
Assert-True ($locked.rollbackSucceeded -and $state.lockedFile -eq 'present') 'Locked spool-file failure did not preserve original state.'

$cancel=Invoke-NTKChangeTransaction -Name 'cancel' -Capture {@{value=1}} -Apply {throw 'must not run'} -Verify {$false} -Rollback {} -CancellationRequested {$true}
Assert-True ($cancel.state -eq 'Canceled') 'Cancellation did not return Canceled.'
Write-Host 'TASK-0091 change transaction fixtures passed.'
