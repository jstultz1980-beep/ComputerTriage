# =====================================================================
# CSI-NetworkToolkit.ps1
# CSI Network Toolkit - Main Launcher
# =====================================================================
# Version : 1.0
# PowerShell : 5.1+
# =====================================================================

#Requires -Version 5.1

[CmdletBinding()]
param(
    [switch]$NoConsole,
    [string]$RunCommand
)

$ErrorActionPreference = "Stop"

# --------------------------------------------------
# Resolve Toolkit Root
# --------------------------------------------------

$ToolkitRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# --------------------------------------------------
# Load Path Resolver
# --------------------------------------------------

$pathFile = Join-Path $ToolkitRoot "Config\ToolkitPaths.ps1"

if(!(Test-Path $pathFile)){
    Write-Host "ToolkitPaths.ps1 not found." -ForegroundColor Red
    exit 1
}

. "$pathFile"

# --------------------------------------------------
# Load Command Registry
# --------------------------------------------------

if(!(Test-Path $CSIFiles.Registry)){
    Write-Host "CommandRegistry.ps1 not found." -ForegroundColor Red
    exit 1
}

. "$($CSIFiles.Registry)"

# --------------------------------------------------
# Ensure Required Directories
# --------------------------------------------------

$requiredDirs = @(
    $CSIPaths.Logs
    $CSIPaths.Exports
    $CSIPaths.Data
)

foreach($dir in $requiredDirs){

    if(!(Test-Path $dir)){
        New-Item -ItemType Directory -Path $dir | Out-Null
    }

}

# --------------------------------------------------
# Logging Initialization
# --------------------------------------------------

if(!(Test-Path $CSIFiles.LogFile)){
    New-Item -ItemType File -Path $CSIFiles.LogFile | Out-Null
}

$time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

try{
    Add-Content $CSIFiles.LogFile "$time  Toolkit started"
}
catch{
    Start-Sleep -Milliseconds 100
    Add-Content $CSIFiles.LogFile "$time  Toolkit started" -ErrorAction SilentlyContinue
}

# --------------------------------------------------
# Module Loader
# --------------------------------------------------

function Import-CSIModules {

param([string]$Directory)

if(!(Test-Path $Directory)){
    Write-Host "Module directory missing: $Directory" -ForegroundColor Yellow
    return
}

$files = Get-ChildItem -Path $Directory -Filter "*.ps1" -File |
         Sort-Object Name

foreach($file in $files){

    try{

        if($DebugPreference -ne "SilentlyContinue"){
            Write-Host "Importing:" $file.FullName -ForegroundColor DarkGray
        }

        . "$($file.FullName)"   # dot source

    }
    catch{

        Write-Host "Failed loading module:" $file.Name -ForegroundColor Red
        Write-Host $_

    }

}

}

# --------------------------------------------------
# Plugin Loader
# --------------------------------------------------

function Import-CSIPlugins {

if(!(Test-Path $CSIPaths.Plugins)){
    return
}

$plugins = Get-ChildItem -Path $CSIPaths.Plugins -Directory -ErrorAction SilentlyContinue |
           Sort-Object Name

foreach($plugin in $plugins){

    $manifestFile = Join-Path $plugin.FullName "PluginManifest.psd1"
    $pluginName = $plugin.Name
    $enabled = $true
    $scriptName = $plugin.Name + ".ps1"

    if(Test-Path $manifestFile){

        try{

            $manifest = Import-PowerShellDataFile $manifestFile

            if($manifest.Name){
                $pluginName = $manifest.Name
            }

            if($manifest.ContainsKey("Enabled")){
                $enabled = [bool]$manifest.Enabled
            }

            if($manifest.Script){
                $scriptName = $manifest.Script
            }

        }
        catch{

            Write-Host "Plugin manifest failed: $($plugin.Name)" -ForegroundColor Red
            Write-Host $_
            continue

        }

    }

    if(!$enabled){

        Write-Host "Plugin disabled: $pluginName" -ForegroundColor DarkGray
        continue

    }

    $script = Join-Path $plugin.FullName $scriptName

    if(Test-Path $script){

        try{

            $Global:CSILoadingPlugin = $pluginName

            . "$script"

            Remove-Variable -Name CSILoadingPlugin -Scope Global -ErrorAction SilentlyContinue

            if($DebugPreference -ne "SilentlyContinue"){
                Write-Host "Loaded plugin: $pluginName" -ForegroundColor Cyan
            }

        }
        catch{

            Remove-Variable -Name CSILoadingPlugin -Scope Global -ErrorAction SilentlyContinue

            Write-Host "Plugin failed: $pluginName" -ForegroundColor Red
            Write-Host $_

        }

    }
    else{

        Write-Host "Plugin script missing: $script" -ForegroundColor Yellow

    }

}

}

# --------------------------------------------------
# Load Toolkit Modules
# --------------------------------------------------

Import-CSIModules $CSIPaths.Utilities
Import-CSIModules $CSIPaths.Core
Import-CSIModules $CSIPaths.Discovery

Import-CSIPlugins

Import-CSIModules $CSIPaths.UI

# --------------------------------------------------
# Verify Console Exists
# --------------------------------------------------

if(!(Get-Command Start-NetworkConsole -ErrorAction SilentlyContinue)){

    Write-Host ""
    Write-Host "Console entry point missing." -ForegroundColor Red
    Write-Host "Expected function: Start-NetworkConsole"
    Write-Host ""

    Write-Host "UI path checked:" $CSIPaths.UI -ForegroundColor Yellow

    exit 1
}

# --------------------------------------------------
# Launch Console
# --------------------------------------------------

if($NoConsole){
    return
}

if($RunCommand){

    Clear-Host

    $command = Get-CSICommands | Where-Object {$_.Name -eq $RunCommand} | Select-Object -First 1

    if($command -and $command.RequiresAdmin -and !(Test-CSIAdministrator)){

        Write-Host ""
        Write-Host "This tool requires administrator rights." -ForegroundColor Yellow
        Write-Host "Launching elevated PowerShell for:" $RunCommand
        Write-Host ""

        [void](Start-CSIElevatedTool $RunCommand)
        return

    }

    try {

        Invoke-CSICommand $RunCommand

    }
    catch [System.OperationCanceledException] {

        Write-Host ""
        Write-Host $_.Exception.Message -ForegroundColor Yellow

    }
    catch {

        Write-Host ""
        Write-Host "Command failed." -ForegroundColor Red
        Write-Host $_

    }

    Write-Host ""
    [void](Read-Host "Press ENTER to close")
    return

}

Start-NetworkConsole

# --------------------------------------------------
# Shutdown Logging
# --------------------------------------------------

$time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

try{
    Add-Content $CSIFiles.LogFile "$time  Toolkit exited"
}
catch{
    Start-Sleep -Milliseconds 100
    Add-Content $CSIFiles.LogFile "$time  Toolkit exited" -ErrorAction SilentlyContinue
}
