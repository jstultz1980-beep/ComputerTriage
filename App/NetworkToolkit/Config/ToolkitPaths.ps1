# =====================================================================
# ToolkitPaths.ps1
# Central path resolver for Network Toolkit
# =====================================================================

$Script:ToolkitRoot = Split-Path -Parent $PSScriptRoot
$Script:DeploymentRoot = Split-Path -Parent (Split-Path -Parent $ToolkitRoot)
$Script:RuntimeRoot = Join-Path $DeploymentRoot "Runtime"

$Script:Paths = [pscustomobject]@{

    Root        = $ToolkitRoot
    DeploymentRoot = $DeploymentRoot
    Runtime     = $RuntimeRoot

    Config      = Join-Path $ToolkitRoot "Config"
    Core        = Join-Path $ToolkitRoot "Core"
    Discovery   = Join-Path $ToolkitRoot "Discovery"
    Utilities   = Join-Path $ToolkitRoot "Utilities"
    UI          = Join-Path $ToolkitRoot "UI"
    Plugins     = Join-Path $ToolkitRoot "Plugins"
    Docs        = Join-Path $ToolkitRoot "Docs"
    Custom      = Join-Path (Split-Path -Parent $ToolkitRoot) "Custom"
    Manifests   = Join-Path (Split-Path -Parent $ToolkitRoot) "manifests"

    Logs        = Join-Path $RuntimeRoot "Logs"
    Exports     = Join-Path $RuntimeRoot "Exports"
    Data        = Join-Path $RuntimeRoot "Data"
    TempOutputs = Join-Path $RuntimeRoot "Data\TempToolOutputs"
}

$Script:Files = [pscustomobject]@{

    Manifest    = Join-Path $Paths.Config "ToolkitManifest.psd1"
    Registry    = Join-Path $Paths.Config "CommandRegistry.ps1"
    ToolCatalog = Join-Path $Paths.Config "ToolCatalog.ps1"
    LogFile     = Join-Path $Paths.Logs "Toolkit.log"
    HelpFile    = Join-Path $Paths.Docs "NetworkToolkitHelp.html"
    CustomToolsDefaults = Join-Path $Paths.Manifests "custom-tools.json"
    CustomTools = Join-Path $RuntimeRoot "State\custom-tools.json"
    GuiSettings = Join-Path $RuntimeRoot "State\gui-settings.json"
}

if(!(Test-Path -LiteralPath (Split-Path -Parent $Files.CustomTools))){ New-Item -ItemType Directory -Path (Split-Path -Parent $Files.CustomTools) -Force | Out-Null }
if(!(Test-Path -LiteralPath $Files.CustomTools) -and (Test-Path -LiteralPath $Files.CustomToolsDefaults)){
    Copy-Item -LiteralPath $Files.CustomToolsDefaults -Destination $Files.CustomTools -Force
}

$Global:NTKPaths = $Paths
$Global:NTKFiles = $Files
