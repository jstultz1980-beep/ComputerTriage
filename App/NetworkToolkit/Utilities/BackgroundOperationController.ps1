function Global:New-NTKBackgroundOperationController {
    [CmdletBinding()]
    param()

    [pscustomobject]@{
        Operations = @{}
        History = New-Object System.Collections.ArrayList
    }
}

function Global:Get-NTKBackgroundOperation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Controller,
        [Parameter(Mandatory)][string]$Name
    )

    if($Controller.Operations.ContainsKey($Name)){
        return $Controller.Operations[$Name]
    }
    return $null
}

function Global:Close-NTKBackgroundOperationResource {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Operation,
        [switch]$Terminate
    )

    if($Operation.Timer){
        try { $Operation.Timer.Stop() | Out-Null } catch {}
        try { $Operation.Timer.Dispose() | Out-Null } catch {}
        $Operation.Timer = $null
    }

    if($Operation.Process){
        try {
            if($Terminate -and !$Operation.Process.HasExited){ $Operation.Process.Kill() | Out-Null }
        }
        catch {}
        try { $Operation.Process.Dispose() | Out-Null } catch {}
        $Operation.Process = $null
    }

    if($Operation.Job){
        try {
            if($Terminate -and $Operation.Job.State -notin @('Completed','Failed','Stopped')){
                Stop-Job -Job $Operation.Job -Force -ErrorAction SilentlyContinue | Out-Null
            }
        }
        catch {}
        try { Remove-Job -Job $Operation.Job -Force -ErrorAction SilentlyContinue | Out-Null } catch {}
        $Operation.Job = $null
    }
}

function Global:Complete-NTKBackgroundOperation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Controller,
        [Parameter(Mandatory)]$Operation,
        [ValidateSet('Succeeded','Partial','Failed','Canceled')][string]$State,
        [ValidateSet('Success','Partial','Failure','Timeout','Cancellation')][string]$CompletionKind,
        [string]$Message = '',
        $Data,
        [switch]$Terminate
    )

    if($Operation.IsTerminal){ return $Operation }

    $Operation.IsTerminal = $true
    $Operation.State = $State
    $Operation.CompletionKind = $CompletionKind
    $Operation.Message = $Message
    $Operation.Data = $Data
    $Operation.CompletedAtUtc = [datetime]::UtcNow

    Close-NTKBackgroundOperationResource -Operation $Operation -Terminate:$Terminate
    [void]$Controller.Operations.Remove($Operation.Name)

    if($Operation.OnCompleted){
        try { & $Operation.OnCompleted $Operation }
        catch { $Operation.CallbackError = $_.Exception.Message }
    }
    $Operation.OnPoll = $null
    $Operation.OnCompleted = $null
    [void]$Controller.History.Add([pscustomobject]@{
        Name = $Operation.Name
        State = $Operation.State
        CompletionKind = $Operation.CompletionKind
        Message = $Operation.Message
        StartedAtUtc = $Operation.StartedAtUtc
        CompletedAtUtc = $Operation.CompletedAtUtc
        CallbackError = $Operation.CallbackError
    })
    while($Controller.History.Count -gt 50){ $Controller.History.RemoveAt(0) }
    return $Operation
}

function Global:Stop-NTKBackgroundOperation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Controller,
        [Parameter(Mandatory)][string]$Name,
        [string]$Message = 'Canceled.'
    )

    $operation = Get-NTKBackgroundOperation -Controller $Controller -Name $Name
    if(!$operation){ return $null }
    Complete-NTKBackgroundOperation -Controller $Controller -Operation $operation -State Canceled -CompletionKind Cancellation -Message $Message -Terminate
}

function Global:Stop-NTKBackgroundOperations {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Controller)

    foreach($name in @($Controller.Operations.Keys)){
        Stop-NTKBackgroundOperation -Controller $Controller -Name $name -Message 'Closed during application shutdown.' | Out-Null
    }
}

function Global:Start-NTKBackgroundOperation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Controller,
        [Parameter(Mandatory)][string]$Name,
        $Process,
        $Job,
        $Timer,
        [ValidateRange(0,86400)][int]$TimeoutSeconds = 0,
        [scriptblock]$OnPoll,
        [scriptblock]$OnCompleted,
        $Metadata
    )

    if($Controller.Operations.ContainsKey($Name)){
        Stop-NTKBackgroundOperation -Controller $Controller -Name $Name -Message 'Replaced by a new operation.' | Out-Null
    }

    $operation = [pscustomobject]@{
        Name = $Name
        State = 'Running'
        CompletionKind = $null
        Message = ''
        Data = $null
        Metadata = $Metadata
        Process = $Process
        Job = $Job
        Timer = $Timer
        TimeoutSeconds = $TimeoutSeconds
        StartedAtUtc = [datetime]::UtcNow
        CompletedAtUtc = $null
        IsTerminal = $false
        OnPoll = $OnPoll
        OnCompleted = $OnCompleted
        CallbackError = $null
    }
    $Controller.Operations[$Name] = $operation
    return $operation
}

function Global:Update-NTKBackgroundOperation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Controller,
        [Parameter(Mandatory)][string]$Name,
        [datetime]$NowUtc = [datetime]::UtcNow
    )

    $operation = Get-NTKBackgroundOperation -Controller $Controller -Name $Name
    if(!$operation -or $operation.IsTerminal){ return $operation }

    if($operation.TimeoutSeconds -gt 0 -and ($NowUtc - $operation.StartedAtUtc).TotalSeconds -ge $operation.TimeoutSeconds){
        return Complete-NTKBackgroundOperation -Controller $Controller -Operation $operation -State Failed -CompletionKind Timeout -Message ("Timed out after {0} seconds." -f $operation.TimeoutSeconds) -Terminate
    }

    try {
        $result = if($operation.OnPoll){ & $operation.OnPoll $operation }else{ $null }
        if($result -and $result.Completed){
            $state = if($result.State){ [string]$result.State }else{ 'Succeeded' }
            $kind = if($result.CompletionKind){ [string]$result.CompletionKind }elseif($state -eq 'Partial'){'Partial'}elseif($state -eq 'Failed'){'Failure'}else{'Success'}
            return Complete-NTKBackgroundOperation -Controller $Controller -Operation $operation -State $state -CompletionKind $kind -Message ([string]$result.Message) -Data $result.Data
        }

        if(!$operation.OnPoll -and $operation.Process -and $operation.Process.HasExited){
            $exitCode = $operation.Process.ExitCode
            if($exitCode -eq 0){
                return Complete-NTKBackgroundOperation -Controller $Controller -Operation $operation -State Succeeded -CompletionKind Success -Message 'Process completed successfully.' -Data $exitCode
            }
            return Complete-NTKBackgroundOperation -Controller $Controller -Operation $operation -State Failed -CompletionKind Failure -Message ("Process exited with code {0}." -f $exitCode) -Data $exitCode
        }

        if(!$operation.OnPoll -and $operation.Job -and $operation.Job.State -in @('Completed','Failed','Stopped')){
            $jobState = [string]$operation.Job.State
            $jobOutput = if($jobState -eq 'Completed'){@(Receive-Job -Job $operation.Job -ErrorAction SilentlyContinue)}else{@()}
            if($jobState -eq 'Completed'){
                return Complete-NTKBackgroundOperation -Controller $Controller -Operation $operation -State Succeeded -CompletionKind Success -Message 'Job completed successfully.' -Data $jobOutput
            }
            if($jobState -eq 'Stopped'){
                return Complete-NTKBackgroundOperation -Controller $Controller -Operation $operation -State Canceled -CompletionKind Cancellation -Message 'Job was stopped.'
            }
            return Complete-NTKBackgroundOperation -Controller $Controller -Operation $operation -State Failed -CompletionKind Failure -Message 'Job failed.'
        }
    }
    catch {
        return Complete-NTKBackgroundOperation -Controller $Controller -Operation $operation -State Failed -CompletionKind Failure -Message $_.Exception.Message -Terminate
    }

    return $operation
}
