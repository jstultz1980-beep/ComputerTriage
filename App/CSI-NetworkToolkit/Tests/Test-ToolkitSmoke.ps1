param(
    [string]$ToolkitRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"

$launcher = Join-Path $ToolkitRoot "CSI-NetworkToolkit.ps1"

if(!(Test-Path $launcher)){
    throw "Toolkit launcher not found: $launcher"
}

. $launcher -NoConsole

$failures = New-Object System.Collections.Generic.List[string]

function Add-SmokeFailure {
    param([string]$Message)
    [void]$failures.Add($Message)
}

$catalog = @(Get-CSIToolCatalog)

if($catalog.Count -lt 1){
    Add-SmokeFailure "Tool catalog is empty."
}

$duplicateIds = @(
    $catalog |
        Group-Object Id |
        Where-Object { $_.Count -gt 1 } |
        ForEach-Object { $_.Name }
)

foreach($id in $duplicateIds){
    Add-SmokeFailure "Duplicate tool catalog id: $id"
}

foreach($tool in $catalog){
    if(!$tool.Id -or !$tool.Text -or !$tool.Tab){
        Add-SmokeFailure "Catalog entry is missing Id, Text, or Tab."
    }

    if(!$tool.Function -and !$tool.External -and !$tool.Action){
        Add-SmokeFailure "Catalog entry has no launch target: $($tool.Id)"
    }

    if($tool.Function -and !(Get-Command $tool.Function -ErrorAction SilentlyContinue)){
        Add-SmokeFailure "Catalog function is missing for $($tool.Id): $($tool.Function)"
    }

    if($tool.External -and (Get-Command Resolve-CSIExternalTool -ErrorAction SilentlyContinue)){
        $resolved = Resolve-CSIExternalTool -Id $tool.External

        if(!$resolved){
            Add-SmokeFailure "External tool id is not in the external catalog for $($tool.Id): $($tool.External)"
        }
    }
}

$requiredCommands = @(
    "Invoke-QuickDiagnosis",
    "Invoke-FullComputerTriage",
    "Get-CSIComputerFingerprint",
    "Save-CSIComputerFingerprint",
    "Start-CSIToolProcess"
)

foreach($command in $requiredCommands){
    if(!(Get-Command $command -ErrorAction SilentlyContinue)){
        Add-SmokeFailure "Required command missing: $command"
    }
}

if($failures.Count -gt 0){
    Write-Host "Toolkit smoke test failed:" -ForegroundColor Red
    $failures | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
    exit 1
}

Write-Host "Toolkit smoke test passed." -ForegroundColor Green
Write-Host "Catalog entries: $($catalog.Count)"
