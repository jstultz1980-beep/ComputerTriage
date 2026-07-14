function Global:New-NTKTabWarmupController {
    param(
        [string]$Name = 'GUI Tab Warmup',
        [int]$IntervalMs = 100
    )

    return [pscustomobject]@{
        Name = $Name
        IntervalMs = $IntervalMs
        Queue = New-Object System.Collections.ArrayList
        Completed = New-Object System.Collections.ArrayList
        Skipped = New-Object System.Collections.ArrayList
        Failed = New-Object System.Collections.ArrayList
        StartedAtUtc = [datetimeoffset]::UtcNow.ToString('o')
        LastStepAtUtc = $null
    }
}

function Global:Set-NTKTabWarmupQueue {
    param(
        [Parameter(Mandatory=$true)]$Controller,
        [Parameter(Mandatory=$true)][object[]]$Items
    )

    if(!$Controller){
        return $null
    }

    $Controller.Queue.Clear()
    foreach($item in @($Items | Sort-Object @{Expression = { if($_.PSObject.Properties['Order']){ [int]$_.Order } else { 0 } } }, @{Expression = { [string]$_.Name }})){
        if(!$item){
            continue
        }
        [void]$Controller.Queue.Add($item)
    }

    return $Controller
}

function Global:Request-NTKTabWarmupPriority {
    param(
        [Parameter(Mandatory=$true)]$Controller,
        [Parameter(Mandatory=$true)][string]$Name
    )

    if(!$Controller -or [string]::IsNullOrWhiteSpace($Name)){
        return $false
    }

    $index = -1
    for($i = 0; $i -lt $Controller.Queue.Count; $i++){
        $item = $Controller.Queue[$i]
        if($item -and [string]::Equals([string]$item.Name, $Name, [System.StringComparison]::OrdinalIgnoreCase)){
            $index = $i
            break
        }
    }

    if($index -le 0){
        return ($index -eq 0)
    }

    $itemToPrioritize = $Controller.Queue[$index]
    $Controller.Queue.RemoveAt($index)
    $Controller.Queue.Insert(0, $itemToPrioritize)
    return $true
}

function Global:Get-NTKTabWarmupSnapshot {
    param([Parameter(Mandatory=$true)]$Controller)

    if(!$Controller){
        return @()
    }

    return @($Controller.Queue | ForEach-Object {
        [pscustomobject]@{
            Name = [string]$_.Name
            Order = if($_.PSObject.Properties['Order']){ [int]$_.Order }else{ 0 }
        }
    })
}

function Global:Invoke-NTKTabWarmupStep {
    param(
        [Parameter(Mandatory=$true)]$Controller
    )

    if(!$Controller){
        return $null
    }

    $lastSkipped = $null
    while($Controller.Queue.Count -gt 0){
        $item = $Controller.Queue[0]
        $Controller.Queue.RemoveAt(0)
        $Controller.LastStepAtUtc = [datetimeoffset]::UtcNow.ToString('o')

        $isBuilt = $false
        if($item.PSObject.Properties['IsBuilt'] -and $item.IsBuilt){
            try {
                $isBuilt = [bool](& $item.IsBuilt $item)
            }
            catch {
                $isBuilt = $false
            }
        }

        if($isBuilt){
            [void]$Controller.Skipped.Add($item)
            $lastSkipped = $item
            continue
        }

        $isDisposed = $false
        if($item.PSObject.Properties['IsDisposed'] -and $item.IsDisposed){
            try {
                $isDisposed = [bool](& $item.IsDisposed $item)
            }
            catch {
                $isDisposed = $false
            }
        }

        if($isDisposed){
            [void]$Controller.Skipped.Add($item)
            $lastSkipped = $item
            continue
        }

        $watch = [System.Diagnostics.Stopwatch]::StartNew()
        try {
            if(!$item.PSObject.Properties['BuildAction'] -or !$item.BuildAction){
                throw "Warm-up item $([string]$item.Name) is missing a build action."
            }

            & $item.BuildAction $item
            $watch.Stop()
            [void]$Controller.Completed.Add($item)
            return [pscustomobject]@{
                Item = $item
                Result = 'Built'
                DurationMs = $watch.ElapsedMilliseconds
                Error = $null
            }
        }
        catch {
            $watch.Stop()
            [void]$Controller.Failed.Add([pscustomobject]@{
                Item = $item
                Error = $_.Exception.Message
                CapturedAtUtc = [datetimeoffset]::UtcNow.ToString('o')
            })
            return [pscustomobject]@{
                Item = $item
                Result = 'Failed'
                DurationMs = $watch.ElapsedMilliseconds
                Error = $_.Exception.Message
            }
        }
    }

    return [pscustomobject]@{
        Item = $lastSkipped
        Result = $(if($lastSkipped){'Skipped'}else{'Empty'})
        DurationMs = 0
        Error = $null
    }
}
