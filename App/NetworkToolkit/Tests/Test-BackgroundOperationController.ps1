$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
. (Join-Path $root 'Utilities\BackgroundOperationController.ps1')

function Assert-True {
    param([bool]$Condition,[string]$Message)
    if(!$Condition){ throw $Message }
}

function New-FakeTimer {
    $timer = [pscustomobject]@{Stopped=$false;Disposed=$false}
    $timer | Add-Member ScriptMethod Stop { $this.Stopped = $true }
    $timer | Add-Member ScriptMethod Dispose { $this.Disposed = $true }
    return $timer
}

function New-FakeProcess {
    $process = [pscustomobject]@{HasExited=$false;Killed=$false;Disposed=$false}
    $process | Add-Member ScriptMethod Kill { $this.Killed = $true; $this.HasExited = $true }
    $process | Add-Member ScriptMethod Dispose { $this.Disposed = $true }
    return $process
}

$controller = New-NTKBackgroundOperationController
$resources = @()
1..3 | ForEach-Object {
    $process = New-FakeProcess
    $timer = New-FakeTimer
    $resources += [pscustomobject]@{Process=$process;Timer=$timer}
    Start-NTKBackgroundOperation -Controller $controller -Name 'repeat' -Process $process -Timer $timer | Out-Null
}
Stop-NTKBackgroundOperation -Controller $controller -Name 'repeat' | Out-Null
Assert-True ($controller.Operations.Count -eq 0) 'Repeated start/cancel left an active operation.'
Assert-True (@($resources | Where-Object { !$_.Process.Killed -or !$_.Process.Disposed -or !$_.Timer.Stopped -or !$_.Timer.Disposed }).Count -eq 0) 'Repeated start/cancel leaked a process or timer.'

$cases = @(
    @{Name='success';State='Succeeded';Kind='Success'},
    @{Name='partial';State='Partial';Kind='Partial'},
    @{Name='failure';State='Failed';Kind='Failure'}
)
foreach($case in $cases){
    $timer = New-FakeTimer
    $poll = { [pscustomobject]@{Completed=$true;State=$case.State;CompletionKind=$case.Kind;Message=$case.Name} }.GetNewClosure()
    Start-NTKBackgroundOperation -Controller $controller -Name $case.Name -Timer $timer -OnPoll $poll | Out-Null
    $result = Update-NTKBackgroundOperation -Controller $controller -Name $case.Name
    Assert-True ($result.State -eq $case.State -and $result.CompletionKind -eq $case.Kind) "$($case.Name) state was not preserved."
    Assert-True ($timer.Stopped -and $timer.Disposed) "$($case.Name) timer was not cleaned up."
}

$timeoutProcess = New-FakeProcess
$timeoutTimer = New-FakeTimer
$timeout = Start-NTKBackgroundOperation -Controller $controller -Name 'timeout' -Process $timeoutProcess -Timer $timeoutTimer -TimeoutSeconds 1
$timeoutResult = Update-NTKBackgroundOperation -Controller $controller -Name 'timeout' -NowUtc $timeout.StartedAtUtc.AddSeconds(2)
Assert-True ($timeoutResult.State -eq 'Failed' -and $timeoutResult.CompletionKind -eq 'Timeout') 'Timeout was not distinct from ordinary failure.'
Assert-True ($timeoutProcess.Killed -and $timeoutProcess.Disposed -and $timeoutTimer.Disposed) 'Timeout leaked resources.'

$throwingPoll = { throw 'fixture failure' }
Start-NTKBackgroundOperation -Controller $controller -Name 'exception' -OnPoll $throwingPoll | Out-Null
$exceptionResult = Update-NTKBackgroundOperation -Controller $controller -Name 'exception'
Assert-True ($exceptionResult.State -eq 'Failed' -and $exceptionResult.CompletionKind -eq 'Failure') 'Polling exception did not become a failure.'

$job = Start-Job -ScriptBlock { Start-Sleep -Seconds 30 }
$jobId = $job.Id
Start-NTKBackgroundOperation -Controller $controller -Name 'job' -Job $job | Out-Null
Stop-NTKBackgroundOperations -Controller $controller
Assert-True ($controller.Operations.Count -eq 0) 'Controller close left an active operation.'
Assert-True ($null -eq (Get-Job -Id $jobId -ErrorAction SilentlyContinue)) 'Controller close leaked a background job.'

Write-Host 'TASK-0096 background operation controller fixtures passed.'
