function Get-NetworkToolkitDeploymentExclusions {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$SourceRoot,
        [ValidateSet("Fresh","Update")][string]$Mode = "Update",
        [switch]$ExcludeSysinternals
    )

    $relativeDirectories = @(
        ".git",
        "Release",
        "NetworkToolkit\Data",
        "NetworkToolkit\Exports",
        "NetworkToolkit\Logs",
        "NetworkToolkit\Tests",
        "Triage\Runs",
        "Triage\Profiles",
        "logs"
        "Runtime"
    )

    $relativeFiles = @(
        "Build-ProductionPackage.ps1",
        "Test-ProductionPackage.ps1",
        "Update-ToolkitVersion.ps1",
        "manifests\gui-settings.json"
    )

    if($Mode -eq "Update"){
        $relativeFiles += @(
            "manifests\custom-tools.json",
            "manifests\custom-tools.json.bak"
        )
        $relativeDirectories += @(
            "Custom"
        )
    }

    if($ExcludeSysinternals){
        $relativeDirectories += "NetworkToolkit\ExternalTools\Sysinternals"
    }

    $relativeDirectories = @($relativeDirectories | Sort-Object -Unique)
    $relativeFiles = @($relativeFiles | Sort-Object -Unique)

    [pscustomobject]@{
        Mode = $Mode
        RelativeDirectories = $relativeDirectories
        RelativeFiles = $relativeFiles
        Directories = @($relativeDirectories | ForEach-Object { Join-Path $SourceRoot $_ })
        Files = @($relativeFiles | ForEach-Object { Join-Path $SourceRoot $_ })
    }
}

function Test-NetworkToolkitRelativePathExcluded {
    param(
        [Parameter(Mandatory=$true)][string]$RelativePath,
        [Parameter(Mandatory=$true)]$Exclusions
    )

    $normalized = $RelativePath.TrimStart('\')
    foreach($directory in @($Exclusions.RelativeDirectories)){
        $prefix = $directory.Trim('\')
        if($normalized.Equals($prefix,[System.StringComparison]::OrdinalIgnoreCase) -or
           $normalized.StartsWith($prefix + '\',[System.StringComparison]::OrdinalIgnoreCase)){
            return $true
        }
    }

    foreach($file in @($Exclusions.RelativeFiles)){
        if($normalized.Equals($file,[System.StringComparison]::OrdinalIgnoreCase)){
            return $true
        }
    }

    return $false
}
