function Global:Get-NTKPluginDescriptor {
    param([Parameter(Mandatory=$true)][string]$PluginPath,[version]$ToolkitVersion=[version]'1.0.0')
    $manifestPath=Join-Path $PluginPath 'PluginManifest.psd1'
    if(!(Test-Path -LiteralPath $manifestPath)){throw "Plugin manifest missing: $manifestPath"}
    $manifest=Import-PowerShellDataFile -LiteralPath $manifestPath -ErrorAction Stop
    foreach($field in @('Name','Version','Script','Enabled')){if(!$manifest.ContainsKey($field)){throw "Plugin manifest missing required field '$field': $manifestPath"}}
    $scriptPath=Join-Path $PluginPath ([string]$manifest.Script)
    $compatible=$true;$reason='Compatible'
    if($manifest.MinToolkitVersion -and $ToolkitVersion -lt [version]$manifest.MinToolkitVersion){$compatible=$false;$reason="Requires toolkit $($manifest.MinToolkitVersion) or later."}
    [pscustomobject]@{SchemaVersion='1.0';Id=(Split-Path -Leaf $PluginPath);Name=[string]$manifest.Name;Version=[string]$manifest.Version;Enabled=[bool]$manifest.Enabled;ScriptPath=$scriptPath;ManifestPath=$manifestPath;Compatible=$compatible;CompatibilityReason=$reason;Required=$false;Lifecycle=if([bool]$manifest.Enabled){'Enabled'}else{'Disabled'};NativeManifest=$manifest}
}

function Global:Get-NTKPluginInventory {
    param([Parameter(Mandatory=$true)][string]$PluginRoot)
    foreach($folder in @(Get-ChildItem -LiteralPath $PluginRoot -Directory -ErrorAction SilentlyContinue|Sort-Object Name)){
        try{Get-NTKPluginDescriptor -PluginPath $folder.FullName}catch{[pscustomobject]@{SchemaVersion='1.0';Id=$folder.Name;Name=$folder.Name;Enabled=$false;Compatible=$false;Lifecycle='Invalid';CompatibilityReason=$_.Exception.Message;ScriptPath='';ManifestPath=(Join-Path $folder.FullName 'PluginManifest.psd1');Required=$false}}
    }
}
