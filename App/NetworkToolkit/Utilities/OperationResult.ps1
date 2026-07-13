#Requires -Version 5.1

$script:NTKOperationStates = @('Succeeded','SucceededWithWarnings','Partial','Failed','Blocked','Canceled')

function Global:New-NTKOperationResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$Operation,
        [Parameter(Mandatory=$true)][ValidateSet('Succeeded','SucceededWithWarnings','Partial','Failed','Blocked','Canceled')][string]$State,
        [string]$Message = '',
        [object[]]$Warnings = @(),
        [object[]]$Errors = @(),
        [hashtable]$Data = @{},
        [object[]]$Stages = @()
    )
    $result = [ordered]@{
        schemaVersion = '1.0'
        operation = $Operation
        state = $State
        succeeded = ($State -in @('Succeeded','SucceededWithWarnings'))
        terminal = $true
        exitCode = Get-NTKOperationExitCode -State $State
        message = $Message
        warnings = @($Warnings)
        errors = @($Errors)
        stages = @($Stages)
        completedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
    }
    foreach($key in @($Data.Keys)){ $result[$key] = $Data[$key] }
    [pscustomobject]$result
}

function Global:Get-NTKOperationExitCode {
    param([Parameter(Mandatory=$true)][string]$State)
    switch($State){
        'Succeeded' { 0 }
        'SucceededWithWarnings' { 0 }
        'Partial' { 2 }
        'Failed' { 1 }
        'Blocked' { 3 }
        'Canceled' { 4 }
        default { 1 }
    }
}

function Global:ConvertTo-NTKOperationResult {
    param([object]$InputObject,[string]$Operation='Toolkit command')
    if($InputObject -and $InputObject.PSObject.Properties['state'] -and $InputObject.PSObject.Properties['exitCode']){ return $InputObject }
    if($InputObject -and $InputObject.PSObject.Properties['Status']){
        $legacy = [string]$InputObject.Status
        $state = switch -Regex ($legacy){
            '^(Completed|Succeeded|Current)$' {'Succeeded';break}
            'Warning' {'SucceededWithWarnings';break}
            'Partial|FailedNonFatal' {'Partial';break}
            'Cancel' {'Canceled';break}
            'Block' {'Blocked';break}
            default {'Failed'}
        }
        return New-NTKOperationResult -Operation $Operation -State $state -Message $legacy -Data @{legacyResult=$InputObject}
    }
    New-NTKOperationResult -Operation $Operation -State Succeeded -Message 'Command completed.' -Data @{value=$InputObject}
}
