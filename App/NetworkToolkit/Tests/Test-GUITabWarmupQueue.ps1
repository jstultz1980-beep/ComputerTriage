$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
. (Join-Path $repoRoot 'App\NetworkToolkit\Utilities\GuiTabWarmup.ps1')

function Assert-True {
    param([bool]$Condition,[string]$Message)
    if(!$Condition){ throw $Message }
}

function New-MockWarmupItem {
    param(
        [Parameter(Mandatory=$true)][string]$Name,
        [int]$Order = 0,
        [switch]$AlreadyBuilt,
        [switch]$ShouldFail,
        [ref]$BuiltState,
        [ref]$BuildCounts
    )

    $item = $null
    $item = [pscustomobject]@{
        Name = $Name
        Order = $Order
        Page = $Name
        BuildAction = {
            param($WarmupItem)
            if(-not $BuildCounts.Value.ContainsKey($WarmupItem.Name)){ $BuildCounts.Value[$WarmupItem.Name] = 0 }
            $BuildCounts.Value[$WarmupItem.Name]++
            if($ShouldFail){ throw "Warm-up failed for $($WarmupItem.Name)" }
            $BuiltState.Value[$WarmupItem.Name] = $true
        }.GetNewClosure()
        IsBuilt = {
            param($WarmupItem)
            return $BuiltState.Value.ContainsKey($WarmupItem.Name) -and $BuiltState.Value[$WarmupItem.Name]
        }.GetNewClosure()
        IsDisposed = { return $false }.GetNewClosure()
    }

    if($AlreadyBuilt){
        $BuiltState.Value[$Name] = $true
    }

    return $item
}

$builtState = @{}
$buildCounts = @{}
$controller = New-NTKTabWarmupController -Name 'warmup-fixture' -IntervalMs 25
$items = @(
    (New-MockWarmupItem -Name 'Alpha' -Order 1 -BuiltState ([ref]$builtState) -BuildCounts ([ref]$buildCounts)),
    (New-MockWarmupItem -Name 'Beta' -Order 2 -BuiltState ([ref]$builtState) -BuildCounts ([ref]$buildCounts)),
    (New-MockWarmupItem -Name 'Gamma' -Order 3 -BuiltState ([ref]$builtState) -BuildCounts ([ref]$buildCounts))
)
[void](Set-NTKTabWarmupQueue -Controller $controller -Items $items)

$snapshot = @(Get-NTKTabWarmupSnapshot -Controller $controller)
Assert-True ($snapshot[0].Name -eq 'Alpha' -and $snapshot[1].Name -eq 'Beta' -and $snapshot[2].Name -eq 'Gamma') 'Warm-up queue ordering was not preserved.'

[void](Request-NTKTabWarmupPriority -Controller $controller -Name 'Gamma')
$snapshot = @(Get-NTKTabWarmupSnapshot -Controller $controller)
Assert-True ($snapshot[0].Name -eq 'Gamma') 'Priority request did not move the requested tab to the front.'

$result = Invoke-NTKTabWarmupStep -Controller $controller
Assert-True ($result.Result -eq 'Built' -and $result.Item.Name -eq 'Gamma') 'Warm-up step did not build the prioritized tab first.'
Assert-True ($buildCounts['Gamma'] -eq 1) 'Prioritized tab was not initialized exactly once.'

[void](Request-NTKTabWarmupPriority -Controller $controller -Name 'Beta')
$result = Invoke-NTKTabWarmupStep -Controller $controller
Assert-True ($result.Result -eq 'Built' -and $result.Item.Name -eq 'Beta') 'User-priority tab was not serviced ahead of the remaining queue.'
Assert-True ($buildCounts['Beta'] -eq 1) 'User-priority tab initialized more than once.'

$skipBuiltState = @{}
$skipCounts = @{}
$skipController = New-NTKTabWarmupController -Name 'skip-fixture'
$skipItems = @(
    (New-MockWarmupItem -Name 'AlreadyBuilt' -Order 1 -AlreadyBuilt -BuiltState ([ref]$skipBuiltState) -BuildCounts ([ref]$skipCounts)),
    (New-MockWarmupItem -Name 'NeedsWork' -Order 2 -BuiltState ([ref]$skipBuiltState) -BuildCounts ([ref]$skipCounts))
)
[void](Set-NTKTabWarmupQueue -Controller $skipController -Items $skipItems)
$result = Invoke-NTKTabWarmupStep -Controller $skipController
Assert-True ($result.Result -eq 'Built' -and $result.Item.Name -eq 'NeedsWork') 'Warm-up did not skip an already initialized tab and continue to the next tab.'
Assert-True ($skipCounts.ContainsKey('AlreadyBuilt') -eq $false -or $skipCounts['AlreadyBuilt'] -eq 0) 'Already initialized tab ran its build action again.'
Assert-True ($skipCounts['NeedsWork'] -eq 1) 'Pending tab did not initialize exactly once.'

$failureState = @{}
$failureCounts = @{}
$failureController = New-NTKTabWarmupController -Name 'failure-fixture'
$failureItems = @(
    (New-MockWarmupItem -Name 'Broken' -Order 1 -ShouldFail -BuiltState ([ref]$failureState) -BuildCounts ([ref]$failureCounts)),
    (New-MockWarmupItem -Name 'Recovered' -Order 2 -BuiltState ([ref]$failureState) -BuildCounts ([ref]$failureCounts))
)
[void](Set-NTKTabWarmupQueue -Controller $failureController -Items $failureItems)
$result = Invoke-NTKTabWarmupStep -Controller $failureController
Assert-True ($result.Result -eq 'Failed' -and $result.Item.Name -eq 'Broken') 'Warm-up failure was not isolated to the failing tab.'
$result = Invoke-NTKTabWarmupStep -Controller $failureController
Assert-True ($result.Result -eq 'Built' -and $result.Item.Name -eq 'Recovered') 'Warm-up queue did not continue after a tab failure.'
Assert-True ($failureCounts['Broken'] -eq 1) 'Failing tab was retried during the same controller run.'
Assert-True ($failureCounts['Recovered'] -eq 1) 'Subsequent tab did not initialize after a failure.'
Assert-True (@($failureController.Failed).Count -eq 1) 'Warm-up failure was not recorded once.'

Write-Host 'GUI tab warm-up controller fixtures passed.' -ForegroundColor Green
