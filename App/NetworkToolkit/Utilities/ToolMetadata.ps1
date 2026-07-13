function Global:New-NTKToolDescriptor {
    param([string]$Id,[string]$Name,[string]$Tab,[string]$Section,[string]$Kind,[string]$EntryPoint,[bool]$RequiresAdmin,[string]$Description,[string]$Source,[string]$ExternalId='',[string]$LaunchPath='',[object]$NativeMetadata=$null)
    [pscustomobject]@{SchemaVersion='1.0';Id=$Id;Name=$Name;Tab=$Tab;Section=$Section;Kind=$Kind;EntryPoint=$EntryPoint;RequiresAdmin=$RequiresAdmin;Description=$Description;Source=$Source;ExternalId=$ExternalId;LaunchPath=$LaunchPath;NativeMetadata=$NativeMetadata}
}

function Global:Get-NTKCanonicalToolDescriptors {
    param([scriptblock]$CustomPlacementResolver=$null,[switch]$IncludeUnmappedExternal)
    $items=New-Object Collections.Generic.List[object];$ids=@{};$externalIds=@{};$placements=@{}
    foreach($tool in @(Get-NTKToolCatalog)){
        $kind=if($tool.External){'External'}elseif($tool.Action){'GuiAction'}else{'Command'}
        $entry=if($tool.External){[string]$tool.External}elseif($tool.Action){[string]$tool.Action}else{[string]$tool.Function}
        $descriptor=New-NTKToolDescriptor -Id $tool.Id -Name $tool.Text -Tab $tool.Tab -Section $tool.Section -Kind $kind -EntryPoint $entry -RequiresAdmin ([bool]$tool.RequiresAdmin) -Description $tool.Description -Source 'ToolCatalog' -ExternalId $tool.External -NativeMetadata $tool
        if(!$ids.ContainsKey($descriptor.Id)){$items.Add($descriptor);$ids[$descriptor.Id]=$true;$placements[("$($descriptor.Tab)|$($descriptor.Name)").ToLowerInvariant()]=$true;if($descriptor.ExternalId){$externalIds[$descriptor.ExternalId]=$true}}
    }
    if(Get-Command Get-GUICustomTools -ErrorAction SilentlyContinue){
        foreach($tool in @(Get-GUICustomTools -Detailed)){
            $placement=if($CustomPlacementResolver){& $CustomPlacementResolver $tool}else{[pscustomobject]@{Tab=if($tool.TabOverride){$tool.TabOverride}else{'Software'};Section='Toolkit Apps';Description='Toolkit-installed portable application.'}}
            $id='custom.'+(($tool.Name -replace '[^A-Za-z0-9]+','.').Trim('.').ToLowerInvariant())
            $placementKey=("$($placement.Tab)|$($tool.Name)").ToLowerInvariant()
            if(!$ids.ContainsKey($id) -and !$placements.ContainsKey($placementKey)){$items.Add((New-NTKToolDescriptor -Id $id -Name $tool.Name -Tab $placement.Tab -Section $placement.Section -Kind 'Custom' -EntryPoint $tool.LaunchPath -RequiresAdmin $false -Description $placement.Description -Source 'RuntimeCustomTools' -LaunchPath $tool.LaunchPath -NativeMetadata $tool));$ids[$id]=$true;$placements[$placementKey]=$true}
        }
    }
    if($IncludeUnmappedExternal -and (Get-Command Get-NTKExternalToolCatalog -ErrorAction SilentlyContinue)){
        foreach($tool in @(Get-NTKExternalToolCatalog|Where-Object{!$externalIds.ContainsKey($_.Id)})){
            $id='external.'+$tool.Id.ToLowerInvariant();if(!$ids.ContainsKey($id)){$items.Add((New-NTKToolDescriptor -Id $id -Name $tool.Name -Tab 'External Tools' -Section $tool.Group -Kind 'External' -EntryPoint $tool.Id -RequiresAdmin ([bool]$tool.RequiresAdmin) -Description $tool.Notes -Source 'ExternalToolCatalog' -ExternalId $tool.Id -NativeMetadata $tool));$ids[$id]=$true}
        }
    }
    return @($items.ToArray())
}

function Global:Test-NTKCanonicalToolDescriptors {
    $descriptors=@(Get-NTKCanonicalToolDescriptors -IncludeUnmappedExternal)
    $failures=New-Object Collections.Generic.List[string]
    foreach($duplicate in @($descriptors|Group-Object Id|Where-Object Count -gt 1)){[void]$failures.Add("Duplicate tool id: $($duplicate.Name)")}
    foreach($tool in @($descriptors)){if(!$tool.Id -or !$tool.Name -or !$tool.Kind -or !$tool.Source){[void]$failures.Add("Incomplete descriptor: $($tool.Id)")}}
    foreach($external in @($descriptors|Where-Object ExternalId)){
        if((Get-Command Get-NTKExternalToolProvenanceManifest -ErrorAction SilentlyContinue) -and !(@((Get-NTKExternalToolProvenanceManifest).tools|Where-Object id -eq $external.ExternalId).Count)){[void]$failures.Add("External provenance missing: $($external.ExternalId)")}
    }
    [pscustomobject]@{Passed=($failures.Count -eq 0);DescriptorCount=$descriptors.Count;Failures=@($failures.ToArray())}
}
