#Requires -Version 5.1

function Global:Invoke-NTKChangeTransaction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][scriptblock]$Capture,
        [Parameter(Mandatory=$true)][scriptblock]$Apply,
        [Parameter(Mandatory=$true)][scriptblock]$Verify,
        [Parameter(Mandatory=$true)][scriptblock]$Rollback,
        [scriptblock]$CancellationRequested = { $false }
    )
    $steps=New-Object System.Collections.Generic.List[object]; $preState=$null; $rollbackAttempted=$false; $rollbackSucceeded=$false
    try {
        $preState=& $Capture; [void]$steps.Add([pscustomobject]@{name='capture';succeeded=$true;detail='Pre-state captured.'})
        if(& $CancellationRequested){ throw [System.OperationCanceledException]::new('Change canceled before mutation.') }
        $applyResult=& $Apply $preState; [void]$steps.Add([pscustomobject]@{name='apply';succeeded=$true;detail=$applyResult})
        if(& $CancellationRequested){ throw [System.OperationCanceledException]::new('Change canceled after mutation.') }
        $verified=[bool](& $Verify $preState $applyResult); [void]$steps.Add([pscustomobject]@{name='verify';succeeded=$verified;detail='Post-state verification.'})
        if(!$verified){ throw 'Post-state verification failed.' }
        return New-NTKOperationResult -Operation $Name -State Succeeded -Message 'Transaction verified.' -Stages $steps.ToArray() -Data @{preState=$preState;rollbackAttempted=$false;rollbackSucceeded=$false}
    }
    catch {
        $failure=$_; if($null -ne $preState){
            $rollbackAttempted=$true
            try { & $Rollback $preState | Out-Null; $rollbackSucceeded=$true; [void]$steps.Add([pscustomobject]@{name='rollback';succeeded=$true;detail='Original state restored.'}) }
            catch { [void]$steps.Add([pscustomobject]@{name='rollback';succeeded=$false;detail=$_.Exception.Message}) }
        }
        $state=if($failure.Exception -is [System.OperationCanceledException]){'Canceled'}elseif($rollbackSucceeded){'Failed'}else{'Partial'}
        return New-NTKOperationResult -Operation $Name -State $state -Message $failure.Exception.Message -Errors @($failure.Exception.Message) -Stages $steps.ToArray() -Data @{preState=$preState;rollbackAttempted=$rollbackAttempted;rollbackSucceeded=$rollbackSucceeded}
    }
}
