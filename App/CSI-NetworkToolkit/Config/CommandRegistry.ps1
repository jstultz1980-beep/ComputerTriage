# =====================================================================
# CommandRegistry.ps1
# Command registration system
# =====================================================================

$Global:CSIRegistry = @()

function Register-CSICommand {

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

    if($Global:CSILoadingPlugin){
        $Source = $Global:CSILoadingPlugin
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
    Sequence    = $Global:CSIRegistry.Count

}

$existing = $Global:CSIRegistry | Where-Object {$_.Id -eq $Id -or $_.Name -eq $Name} | Select-Object -First 1

if($existing){

    $Global:CSIRegistry = @($Global:CSIRegistry | Where-Object {$_.Id -ne $Id -and $_.Name -ne $Name})

}

$Global:CSIRegistry += $entry

}

function Get-CSICommands {

    return $Global:CSIRegistry | Sort-Object Order,Sequence

}

function Invoke-CSICommand {

param(
    [string]$Name,
    [string]$Id,
    [object[]]$Arguments = @()
)

if($Id){
    $cmd = $CSIRegistry | Where-Object {$_.Id -eq $Id} | Select-Object -First 1
}
else{
    $cmd = $CSIRegistry | Where-Object {$_.Name -eq $Name} | Select-Object -First 1
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
