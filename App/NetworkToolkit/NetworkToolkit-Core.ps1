# =====================================================================
# NetworkToolkit-Core.ps1
# Network Toolkit - Main Launcher
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

if(!(Test-Path $NTKFiles.Registry)){
    Write-Host "CommandRegistry.ps1 not found." -ForegroundColor Red
    exit 1
}

. "$($NTKFiles.Registry)"

if($NTKFiles.ToolCatalog -and (Test-Path $NTKFiles.ToolCatalog)){
    . "$($NTKFiles.ToolCatalog)"
}

$Global:NTKImportFailures = New-Object System.Collections.Generic.List[object]

function Global:Add-NTKImportFailure {
    param(
        [string]$Stage,
        [string]$Name,
        [string]$Path,
        [System.Exception]$Exception
    )

    $record = [pscustomobject]@{
        CapturedAt = (Get-Date).ToString('s')
        Stage = $Stage
        Name = $Name
        Path = $Path
        Error = if($Exception){$Exception.Message}else{'Unknown load failure'}
    }
    [void]$Global:NTKImportFailures.Add($record)
    Write-Host "[$Stage] $Name failed to load: $($record.Error)" -ForegroundColor Red
}

function Global:Get-NTKImportFailures {
    return @($Global:NTKImportFailures.ToArray())
}

# --------------------------------------------------
# Ensure Required Directories
# --------------------------------------------------

$requiredDirs = @(
    $NTKPaths.Logs
    $NTKPaths.Exports
    $NTKPaths.Data
    $NTKPaths.TempOutputs
    $NTKPaths.Custom
    $NTKPaths.Manifests
)

foreach($dir in $requiredDirs){

    if(!(Test-Path $dir)){
        New-Item -ItemType Directory -Path $dir | Out-Null
    }

}

# --------------------------------------------------
# Logging Initialization
# --------------------------------------------------

if(!(Test-Path $NTKFiles.LogFile)){
    New-Item -ItemType File -Path $NTKFiles.LogFile | Out-Null
}

$time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

try{
    Add-Content $NTKFiles.LogFile "$time  Toolkit started"
}
catch{
    Start-Sleep -Milliseconds 100
    Add-Content $NTKFiles.LogFile "$time  Toolkit started" -ErrorAction SilentlyContinue
}

# --------------------------------------------------
# Module Loader
# --------------------------------------------------

function Import-NTKModules {

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
        Add-NTKImportFailure -Stage 'Module' -Name $file.Name -Path $file.FullName -Exception $_.Exception

    }

}

}

# --------------------------------------------------
# Plugin Loader
# --------------------------------------------------

function Import-NTKPlugins {

if(!(Test-Path $NTKPaths.Plugins)){
    return
}

$plugins = Get-ChildItem -Path $NTKPaths.Plugins -Directory -ErrorAction SilentlyContinue |
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
            Add-NTKImportFailure -Stage 'Plugin manifest' -Name $plugin.Name -Path $manifestFile -Exception $_.Exception
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

            $Global:NTKLoadingPlugin = $pluginName

            . "$script"

            Remove-Variable -Name NTKLoadingPlugin -Scope Global -ErrorAction SilentlyContinue

            if($DebugPreference -ne "SilentlyContinue"){
                Write-Host "Loaded plugin: $pluginName" -ForegroundColor Cyan
            }

        }
        catch{

            Remove-Variable -Name NTKLoadingPlugin -Scope Global -ErrorAction SilentlyContinue
            Add-NTKImportFailure -Stage 'Plugin' -Name $pluginName -Path $script -Exception $_.Exception

        }

    }
    else{
        Add-NTKImportFailure -Stage 'Plugin' -Name $pluginName -Path $script -Exception ([System.IO.FileNotFoundException]::new("Plugin script missing: $script"))

    }

}

}

# --------------------------------------------------
# Load Toolkit Modules
# --------------------------------------------------

Import-NTKModules $NTKPaths.Utilities

if(Get-Command Clear-NTKOldTempOutputs -ErrorAction SilentlyContinue){
    Clear-NTKOldTempOutputs -KeepCount 12 -MaxAgeDays 7
}

if(Get-Command Clear-NTKReportAndLogQuota -ErrorAction SilentlyContinue){
    Clear-NTKReportAndLogQuota -ReportKeepCount 6 -LogKeepCount 10 -TempKeepCount 12 -MaxAgeDays 21
}

Import-NTKModules $NTKPaths.Core
Import-NTKModules $NTKPaths.Discovery

Import-NTKPlugins

Import-NTKModules $NTKPaths.UI

# --------------------------------------------------
# Verify Console Exists
# --------------------------------------------------

if(!(Get-Command Start-NetworkConsole -ErrorAction SilentlyContinue)){

    Write-Host ""
    Write-Host "Console entry point missing." -ForegroundColor Red
    Write-Host "Expected function: Start-NetworkConsole"
    Write-Host ""

    Write-Host "UI path checked:" $NTKPaths.UI -ForegroundColor Yellow

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

    $command = Get-NTKCommands | Where-Object {$_.Name -eq $RunCommand} | Select-Object -First 1

    if($command -and $command.RequiresAdmin -and !(Test-NTKAdministrator)){

        Write-Host ""
        Write-Host "This tool requires administrator rights." -ForegroundColor Yellow
        Write-Host "Launching elevated PowerShell for:" $RunCommand
        Write-Host ""

        [void](Start-NTKElevatedTool $RunCommand)
        return

    }

    try {

        Invoke-NTKCommand $RunCommand

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

try {
    Start-NetworkConsole
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

# --------------------------------------------------
# Shutdown Logging
# --------------------------------------------------

$time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

try{
    Add-Content $NTKFiles.LogFile "$time  Toolkit exited"
}
catch{
    Start-Sleep -Milliseconds 100
    Add-Content $NTKFiles.LogFile "$time  Toolkit exited" -ErrorAction SilentlyContinue
}
