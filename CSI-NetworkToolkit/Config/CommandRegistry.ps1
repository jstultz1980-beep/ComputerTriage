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

$entry = [pscustomobject]@{

    Name        = $Name
    Command     = $Command
    Category    = $Category
    Description = $Description
    Source      = $Source
    Order       = $Order
    RequiresAdmin = [bool]$RequiresAdmin
    Sequence    = $Global:CSIRegistry.Count

}

$existing = $Global:CSIRegistry | Where-Object {$_.Name -eq $Name} | Select-Object -First 1

if($existing){

    $Global:CSIRegistry = @($Global:CSIRegistry | Where-Object {$_.Name -ne $Name})

}

$Global:CSIRegistry += $entry

}

function Get-CSICommands {

    return $Global:CSIRegistry | Sort-Object Order,Sequence

}

function Invoke-CSICommand {

param(
    [string]$Name,
    [object[]]$Arguments = @()
)

$cmd = $CSIRegistry | Where-Object {$_.Name -eq $Name} | Select-Object -First 1

if(!$cmd){

    Write-Host "Command not found." -ForegroundColor Red
    return

}

$commandName = $cmd.Command

if(Get-Command $commandName -ErrorAction SilentlyContinue){

    & $commandName @Arguments

}
else{

    Write-Host "Command function missing:" $commandName -ForegroundColor Red

}

}
