# =====================================================================
# CommandRegistry.ps1
# Command registration system
# =====================================================================

$Global:NTKRegistry = @()

function Register-NTKCommand {

param(
    [string]$Name,
    [string]$Command,
    [string]$Category = "General",
    [string]$Description = "",
    [string]$Source = "",
    [string]$Id = "",
    [int]$Order = 100,
    [switch]$RequiresAdmin
)

if(!$Source){

    if($Global:NTKLoadingPlugin){
        $Source = $Global:NTKLoadingPlugin
    }
    else{
        $Source = "Toolkit"
    }

}

if(!$Id){
    $Id = ($Name -replace '[^A-Za-z0-9]+','-').Trim('-').ToLowerInvariant()
}

$entry = [pscustomobject]@{

    Id          = $Id
    Name        = $Name
    Command     = $Command
    Category    = $Category
    Description = $Description
    Source      = $Source
    Order       = $Order
    RequiresAdmin = [bool]$RequiresAdmin
    Sequence    = $Global:NTKRegistry.Count

}

$existing = $Global:NTKRegistry | Where-Object {$_.Id -eq $Id -or $_.Name -eq $Name} | Select-Object -First 1

if($existing){

    $Global:NTKRegistry = @($Global:NTKRegistry | Where-Object {$_.Id -ne $Id -and $_.Name -ne $Name})

}

$Global:NTKRegistry += $entry

}

function Get-NTKCommands {

    return $Global:NTKRegistry | Sort-Object Order,Sequence

}

function Invoke-NTKCommand {

param(
    [string]$Name,
    [string]$Id,
    [object[]]$Arguments = @()
)

if($Id){
    $cmd = $NTKRegistry | Where-Object {$_.Id -eq $Id} | Select-Object -First 1
}
else{
    $cmd = $NTKRegistry | Where-Object {$_.Name -eq $Name} | Select-Object -First 1
}

if(!$cmd){
    $requested = if($Id){"id '$Id'"}else{"name '$Name'"}
    throw "Command not found for $requested."

}

$commandName = $cmd.Command

if(Get-Command $commandName -ErrorAction SilentlyContinue){

    & $commandName @Arguments

}
else{
    throw "Command function is missing: $commandName"

}

}
