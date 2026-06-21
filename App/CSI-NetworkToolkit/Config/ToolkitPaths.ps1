# =====================================================================
# ToolkitPaths.ps1
# Central path resolver for Network Toolkit
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
    Docs        = Join-Path $ToolkitRoot "Docs"
    Custom      = Join-Path (Split-Path -Parent $ToolkitRoot) "Custom"
    Manifests   = Join-Path (Split-Path -Parent $ToolkitRoot) "manifests"

    Logs        = Join-Path $ToolkitRoot "Logs"
    Exports     = Join-Path $ToolkitRoot "Exports"
    Data        = Join-Path $ToolkitRoot "Data"
    TempOutputs = Join-Path $ToolkitRoot "Data\TempToolOutputs"
}

$Script:Files = [pscustomobject]@{

    Manifest    = Join-Path $Paths.Config "ToolkitManifest.psd1"
    Registry    = Join-Path $Paths.Config "CommandRegistry.ps1"
    ToolCatalog = Join-Path $Paths.Config "ToolCatalog.ps1"
    LogFile     = Join-Path $Paths.Logs "Toolkit.log"
    HelpFile    = Join-Path $Paths.Docs "NetworkToolkitHelp.html"
    CustomTools = Join-Path $Paths.Manifests "custom-tools.json"
    GuiSettings = Join-Path $Paths.Manifests "gui-settings.json"
}

$Global:CSIPaths = $Paths
$Global:CSIFiles = $Files
