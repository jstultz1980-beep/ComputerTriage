function Global:Get-NTKComputerStateRoot {

    $root = if($NTKPaths -and $NTKPaths.Data){
        Join-Path $NTKPaths.Data "ComputerState"
    }
    else{
        Join-Path $env:TEMP "NetworkToolkit\ComputerState"
    }

    if(!(Test-Path $root)){
        New-Item -ItemType Directory -Path $root -Force | Out-Null
    }

    return $root

}

function Global:Get-NTKComputerStatePath {

param([string]$ComputerName = $env:COMPUTERNAME)

    if(!$ComputerName){
        $ComputerName = "UnknownComputer"
    }

    $safeName = if(Get-Command ConvertTo-NTKSafeFileName -ErrorAction SilentlyContinue){
        ConvertTo-NTKSafeFileName $ComputerName
    }
    else{
        ($ComputerName -replace '[^A-Za-z0-9._-]+','_').Trim('_')
    }

    return (Join-Path (Get-NTKComputerStateRoot) "$safeName.json")

}

function Global:ConvertTo-NTKHashtable {

param([object]$InputObject)

    if($null -eq $InputObject){
        return $null
    }

    if($InputObject -is [System.Collections.IDictionary]){
        $hash = [ordered]@{}
        foreach($key in $InputObject.Keys){
            $hash[$key] = ConvertTo-NTKHashtable $InputObject[$key]
        }
        return $hash
    }

    if($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]){
        $items = @()
        foreach($item in $InputObject){
            $items += ConvertTo-NTKHashtable $item
        }
        return $items
    }

    if($InputObject.PSObject -and $InputObject.GetType().FullName -eq "System.Management.Automation.PSCustomObject"){
        $hash = [ordered]@{}
        foreach($property in $InputObject.PSObject.Properties){
            $hash[$property.Name] = ConvertTo-NTKHashtable $property.Value
        }
        return $hash
    }

    return $InputObject

}

function Global:Read-NTKComputerState {

param([string]$ComputerName = $env:COMPUTERNAME)

    $path = Get-NTKComputerStatePath -ComputerName $ComputerName

    if(Test-Path $path){
        try {
            return (ConvertTo-NTKHashtable (Get-Content -Raw -Path $path | ConvertFrom-Json))
        }
        catch {
            if(Get-Command Write-NTKWarning -ErrorAction SilentlyContinue){
                Write-NTKWarning -Component 'ComputerState' -Message ("Could not read {0}: {1}. A new state document will be used." -f $path,$_.Exception.Message)
            }
        }
    }

    return [ordered]@{
        SchemaVersion = 1
        ComputerName = if($ComputerName){$ComputerName}else{$env:COMPUTERNAME}
        CreatedAt = (Get-Date).ToString("s")
        UpdatedAt = (Get-Date).ToString("s")
        LastQuickDiagnosisAt = ""
        LastQuickDiagnosisReportPath = ""
        Sections = [ordered]@{}
    }

}

function Global:Write-NTKComputerState {

param(
    [Parameter(Mandatory=$true)]
    [System.Collections.IDictionary]$State,
    [string]$ComputerName = $env:COMPUTERNAME
)

    $State["UpdatedAt"] = (Get-Date).ToString("s")
    if(!$State.Contains("ComputerName") -or !$State["ComputerName"]){
        $State["ComputerName"] = if($ComputerName){$ComputerName}else{$env:COMPUTERNAME}
    }

    $path = Get-NTKComputerStatePath -ComputerName $State["ComputerName"]
    $State | ConvertTo-Json -Depth 20 | Set-Content -Path $path -Encoding UTF8
    return $path

}

function Global:Set-NTKComputerStateSection {

param(
    [Parameter(Mandatory=$true)]
    [string]$SectionName,
    [Parameter(Mandatory=$true)]
    [object]$Data,
    [string]$ComputerName = $env:COMPUTERNAME,
    [string]$Source = ""
)

    $state = ConvertTo-NTKHashtable (Read-NTKComputerState -ComputerName $ComputerName)

    if(!$state.Contains("Sections") -or $null -eq $state["Sections"]){
        $state["Sections"] = [ordered]@{}
    }
    elseif($state["Sections"] -isnot [System.Collections.IDictionary]){
        $state["Sections"] = ConvertTo-NTKHashtable $state["Sections"]
    }

    $safeSection = ($SectionName -replace '[^A-Za-z0-9._-]+','_').Trim('_')
    if(!$safeSection){
        $safeSection = "Unknown"
    }

    $state["Sections"][$safeSection] = [ordered]@{
        UpdatedAt = (Get-Date).ToString("s")
        Source = $Source
        Data = ConvertTo-NTKHashtable $Data
    }

    if($safeSection -eq "QuickDiagnosis"){
        $quickData = $state["Sections"][$safeSection]["Data"]
        $capturedAt = ""
        $reportPath = ""

        if($quickData -is [System.Collections.IDictionary]){
            if($quickData.Contains("CapturedAt")){ $capturedAt = [string]$quickData["CapturedAt"] }
            if($quickData.Contains("ReportPath")){ $reportPath = [string]$quickData["ReportPath"] }
        }
        else{
            try { if($quickData.CapturedAt){ $capturedAt = [string]$quickData.CapturedAt } } catch {}
            try { if($quickData.ReportPath){ $reportPath = [string]$quickData.ReportPath } } catch {}
        }

        if(!$capturedAt){
            $capturedAt = (Get-Date).ToString("s")
        }

        $state["LastQuickDiagnosisAt"] = $capturedAt
        $state["LastQuickDiagnosisReportPath"] = $reportPath
    }

    return (Write-NTKComputerState -State $state -ComputerName $ComputerName)

}

function Global:Set-NTKComputerStateToolOutput {

param(
    [Parameter(Mandatory=$true)]
    [string]$ToolName,
    [string]$SessionPath = "",
    [string]$TranscriptPath = "",
    [string]$MetadataPath = "",
    [string]$ComputerName = $env:COMPUTERNAME
)

    $state = ConvertTo-NTKHashtable (Read-NTKComputerState -ComputerName $ComputerName)

    if(!$state.Contains("Sections") -or $null -eq $state["Sections"]){
        $state["Sections"] = [ordered]@{}
    }
    elseif($state["Sections"] -isnot [System.Collections.IDictionary]){
        $state["Sections"] = ConvertTo-NTKHashtable $state["Sections"]
    }

    if(!$state["Sections"].Contains("LatestToolOutputs")){
        $state["Sections"]["LatestToolOutputs"] = [ordered]@{
            UpdatedAt = (Get-Date).ToString("s")
            Source = "Tool output capture"
            Data = [ordered]@{}
        }
    }

    $safeTool = ($ToolName -replace '[^A-Za-z0-9._-]+','_').Trim('_')
    if(!$safeTool){
        $safeTool = "UnknownTool"
    }

    $metadata = $null
    if($MetadataPath -and (Test-Path $MetadataPath)){
        try { $metadata = Get-Content -Raw -Path $MetadataPath | ConvertFrom-Json }
        catch {
            if(Get-Command Write-NTKWarning -ErrorAction SilentlyContinue){
                Write-NTKWarning -Component 'ComputerState' -Message ("Could not parse tool metadata {0}: {1}" -f $MetadataPath,$_.Exception.Message)
            }
        }
    }

    $preview = @()
    if($TranscriptPath -and (Test-Path $TranscriptPath)){
        try {
            $preview = @(Get-Content -Path $TranscriptPath -Tail 80 -ErrorAction Stop)
        }
        catch {
            if(Get-Command Write-NTKWarning -ErrorAction SilentlyContinue){
                Write-NTKWarning -Component 'ComputerState' -Message ("Could not read tool transcript {0}: {1}" -f $TranscriptPath,$_.Exception.Message)
            }
        }
    }

    $state["Sections"]["LatestToolOutputs"]["UpdatedAt"] = (Get-Date).ToString("s")
    $state["Sections"]["LatestToolOutputs"]["Data"][$safeTool] = [ordered]@{
        ToolName = $ToolName
        UpdatedAt = (Get-Date).ToString("s")
        SessionPath = $SessionPath
        TranscriptPath = $TranscriptPath
        MetadataPath = $MetadataPath
        Metadata = ConvertTo-NTKHashtable $metadata
        TranscriptPreview = $preview
    }

    return (Write-NTKComputerState -State $state -ComputerName $ComputerName)

}
