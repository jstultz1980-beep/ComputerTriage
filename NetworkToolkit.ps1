# =====================================================================
# NetworkToolkit.ps1
# Network Toolkit - Single Launcher
# =====================================================================

#Requires -Version 5.1

[CmdletBinding()]
param(
    [switch]$CLI,
    [switch]$NoConsole,
    [string]$RunCommand,
    [switch]$SmokeTest,
    [switch]$ButtonSmokeTest,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
$consoleLauncher = Join-Path $root "CSI-NetworkToolkit\CSI-NetworkToolkit.ps1"
$guiLauncher = Join-Path $root "ToolKit-GUI\ToolKit-GUI.ps1"

if($CLI){
    if(!(Test-Path $consoleLauncher)){
        throw "Console launcher not found: $consoleLauncher"
    }

    $consoleArgs = @{}
    if($NoConsole){ $consoleArgs.NoConsole = $true }
    if($RunCommand){
        $consoleArgs.RunCommand = $RunCommand
    }

    & $consoleLauncher @consoleArgs
    exit $LASTEXITCODE
}

if(!(Test-Path $guiLauncher)){
    throw "GUI launcher not found: $guiLauncher"
}

$guiArgs = @{}
if($SmokeTest){ $guiArgs.SmokeTest = $true }
if($ButtonSmokeTest){ $guiArgs.ButtonSmokeTest = $true }

& $guiLauncher @guiArgs
exit $LASTEXITCODE
