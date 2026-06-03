# =====================================================================
# ToolkitPaths.ps1
# Central path resolver for CSI Network Toolkit
# =====================================================================

$Script:ToolkitRoot = Split-Path -Parent $PSScriptRoot

$Script:Paths = [pscustomobject]@{

    Root        = $ToolkitRoot

    Config      = Join-Path $ToolkitRoot "Config"
    Core        = Join-Path $ToolkitRoot "Core"
    Discovery   = Join-Path $ToolkitRoot "Discovery"
    Utilities   = Join-Path $ToolkitRoot "Utilities"
    UI          = Join-Path $ToolkitRoot "UI"
    Plugins     = Join-Path $ToolkitRoot "Plugins"

    Logs        = Join-Path $ToolkitRoot "Logs"
    Exports     = Join-Path $ToolkitRoot "Exports"
    Data        = Join-Path $ToolkitRoot "Data"
}

$Script:Files = [pscustomobject]@{

    Manifest    = Join-Path $Paths.Config "ToolkitManifest.psd1"
    Registry    = Join-Path $Paths.Config "CommandRegistry.ps1"
    LogFile     = Join-Path $Paths.Logs "Toolkit.log"
}

$Global:CSIPaths = $Paths
$Global:CSIFiles = $Files