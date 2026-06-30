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

$deploymentRoot = Split-Path -Parent $PSScriptRoot

$toolkitMutex = $null
$skipSingleton = $SmokeTest -or $ButtonSmokeTest
if(!$skipSingleton){
    $mutexName = "NetworkToolkit-$([System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value)"
    $createdNew = $false
    $toolkitMutex = New-Object System.Threading.Mutex($true,$mutexName,[ref]$createdNew)
    if(!$createdNew){
        try {
            Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
            [System.Windows.Forms.MessageBox]::Show(
                "Network Toolkit is already running. Use the existing window instead of launching another copy.",
                "Network Toolkit",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            ) | Out-Null
        }
        catch {
            Write-Warning "Network Toolkit is already running."
        }
        exit 0
    }

    # The GUI is invoked in this same PowerShell process. It reuses this mutex when
    # launched through the main launcher and creates its own only when run directly.
    $global:NetworkToolkitInstanceMutex = $toolkitMutex
}

$root = $PSScriptRoot
$consoleLauncher = Join-Path $root "NetworkToolkit\NetworkToolkit-Core.ps1"
$guiLauncher = Join-Path $root "ToolKit-GUI\ToolKit-GUI.ps1"

try {
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
}
finally {
    $global:NetworkToolkitInstanceMutex = $null
    if($toolkitMutex){
        try { $toolkitMutex.ReleaseMutex() } catch {}
        $toolkitMutex.Dispose()
    }
}
