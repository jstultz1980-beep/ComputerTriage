[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$SourceRoot,

    [Parameter(Mandatory=$true)]
    [string]$DestinationRoot,

    [Parameter(Mandatory=$true)]
    [string]$ResultPath
)

$ErrorActionPreference = "Stop"

function Test-NetworkToolkitRoot {
    param([string]$Path)

    return (Test-Path (Join-Path $Path "NetworkToolkit.ps1")) -and
           (Test-Path (Join-Path $Path "CSI-NetworkToolkit")) -and
           (Test-Path (Join-Path $Path "ToolKit-GUI"))
}

function Resolve-NetworkToolkitFileSystemPath {
    param([Parameter(Mandatory=$true)][string]$Path)

    $item = Get-Item -LiteralPath $Path -Force -ErrorAction Stop
    if($item.PSProvider.Name -ne "FileSystem"){
        throw "Path is not a filesystem location: $Path"
    }

    return $item.FullName.TrimEnd('\\')
}

function Write-NetworkToolkitUpdateRecord {
    param(
        [Parameter(Mandatory=$true)][string]$ToolkitRoot,
        [Parameter(Mandatory=$true)][string]$SourceRoot,
        [Parameter(Mandatory=$true)][string]$DestinationRoot,
        [int]$ExitCode,
        [string]$CopySummary,
        [string[]]$VerifiedFiles = @()
    )

    $manifestRoot = Join-Path $ToolkitRoot "manifests"
    $historyPath = Join-Path $manifestRoot "toolkit-update-history.json"
    New-Item -ItemType Directory -Path $manifestRoot -Force | Out-Null

    $history = @()
    if(Test-Path -LiteralPath $historyPath){
        try {
            $history = @((Get-Content -LiteralPath $historyPath -Raw -ErrorAction Stop | ConvertFrom-Json) | ForEach-Object { $_ })
            $history = @($history | ForEach-Object {
                if($_.PSObject.Properties.Name -contains "value" -and $_.PSObject.Properties.Name -contains "Count"){
                    @($_.value)
                }
                else{
                    $_
                }
            })
        }
        catch {
            $history = @()
        }
    }

    $history += [pscustomobject]@{
        UpdatedAt = (Get-Date).ToString("s")
        Source = $SourceRoot
        Destination = $DestinationRoot
        ExitCode = $ExitCode
        CopySummary = $CopySummary
        VerifiedFiles = $VerifiedFiles
    }
    $history = @($history | Select-Object -Last 25)
    $history | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $historyPath -Encoding UTF8
    return $historyPath
}

function Get-NetworkToolkitRobocopySummary {
    param([int]$ExitCode)

    switch($ExitCode){
        0 { return "No program files needed to be copied; destination was already current." }
        1 { return "Program files were copied successfully." }
        2 { return "Destination contains additional preserved files; no program files needed copying." }
        3 { return "Program files were copied successfully; destination also contains preserved client data or other extra files." }
        default { return "Robocopy completed successfully with status $ExitCode." }
    }
}

function Test-NetworkToolkitCopy {
    param(
        [Parameter(Mandatory=$true)][string]$SourceRoot,
        [Parameter(Mandatory=$true)][string]$DestinationRoot
    )

    $verified = @()
    $skipped = @()
    foreach($relativePath in @(
        "NetworkToolkit.ps1",
        "ToolKit-GUI\ToolKit-GUI.ps1",
        "CSI-NetworkToolkit\CSI-NetworkToolkit.ps1"
    )){
        $sourcePath = Join-Path $SourceRoot $relativePath
        $destinationPath = Join-Path $DestinationRoot $relativePath
        if(!(Test-Path -LiteralPath $destinationPath)){
            throw "Updated toolkit is missing required file: $relativePath"
        }
        try {
            if((Get-FileHash -LiteralPath $sourcePath -Algorithm SHA256).Hash -ne (Get-FileHash -LiteralPath $destinationPath -Algorithm SHA256).Hash){
                throw "Updated toolkit verification failed for: $relativePath"
            }
            $verified += $relativePath
        }
        catch {
            if($_.Exception.Message -match '(?i)being used by another process|cannot be read'){
                $skipped += $relativePath
                continue
            }
            throw
        }
    }

    return [pscustomobject]@{
        Verified = $verified
        Skipped = $skipped
    }
}

function Touch-NetworkToolkitProgramFiles {
    param(
        [Parameter(Mandatory=$true)][string]$SourceRoot,
        [Parameter(Mandatory=$true)][string]$DestinationRoot
    )

    $excludedRelativeRoots = @(
        ".git",
        "Release",
        "CSI-NetworkToolkit\Data",
        "CSI-NetworkToolkit\Exports",
        "CSI-NetworkToolkit\Logs",
        "Custom\FirefoxPortable\Data"
    )
    $managedPrefixes = @(
        "ToolKit-GUI\",
        "CSI-NetworkToolkit\Config\",
        "CSI-NetworkToolkit\Core\",
        "CSI-NetworkToolkit\Discovery\",
        "CSI-NetworkToolkit\Plugins\",
        "CSI-NetworkToolkit\UI\",
        "CSI-NetworkToolkit\Utilities\",
        "manifests\"
    )
    $timestamp = Get-Date
    $touched = 0
    $skipped = 0
    $priorityRelativePaths = @(
        "NetworkToolkit.ps1",
        "ToolKit-GUI\ToolKit-GUI.ps1",
        "CSI-NetworkToolkit\CSI-NetworkToolkit.ps1"
    )
    $sourceFiles = @(Get-ChildItem -LiteralPath $SourceRoot -Recurse -File -Force -ErrorAction Stop)
    $priorityFiles = @($priorityRelativePaths | ForEach-Object {
        $path = Join-Path $SourceRoot $_
        if(Test-Path -LiteralPath $path){ Get-Item -LiteralPath $path }
    })
    $remainingFiles = @($sourceFiles | Where-Object {
        $relative = $_.FullName.Substring($SourceRoot.Length).TrimStart('\\')
        $priorityRelativePaths -notcontains $relative
    })

    foreach($sourceFile in @($priorityFiles + $remainingFiles)){
        $relativePath = $sourceFile.FullName.Substring($SourceRoot.Length).TrimStart('\\')
        if(@($excludedRelativeRoots | Where-Object { $relativePath -eq $_ -or $relativePath.StartsWith($_ + '\',[System.StringComparison]::OrdinalIgnoreCase) }).Count -gt 0){
            continue
        }
        $isRootFile = $relativePath -notmatch '\\'
        $isManagedFile = $isRootFile -or @($managedPrefixes | Where-Object { $relativePath.StartsWith($_,[System.StringComparison]::OrdinalIgnoreCase) }).Count -gt 0
        if(!$isManagedFile -or $relativePath -in @("manifests\gui-settings.json","manifests\toolkit-update-history.json")){
            continue
        }

        $destinationFile = Join-Path $DestinationRoot $relativePath
        if(Test-Path -LiteralPath $destinationFile){
            try {
                [System.IO.File]::SetLastWriteTime($destinationFile,$timestamp)
                $touched++
            }
            catch {
                $skipped++
            }
        }
    }

    return [pscustomobject]@{
        Touched = $touched
        Skipped = $skipped
    }
}

function Write-NetworkToolkitUpdateMarker {
    param(
        [Parameter(Mandatory=$true)][string]$ToolkitRoot,
        [Parameter(Mandatory=$true)][string]$SourceRoot,
        [Parameter(Mandatory=$true)][string]$DestinationRoot,
        [int]$ExitCode,
        [string]$CopySummary
    )

    $markerPath = Join-Path $ToolkitRoot "LAST-UPDATED.txt"
    @(
        "Network Toolkit update marker"
        "Updated: $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))"
        "Source: $SourceRoot"
        "Destination: $DestinationRoot"
        "Robocopy exit code: $ExitCode"
        "Result: $CopySummary"
    ) | Set-Content -LiteralPath $markerPath -Encoding UTF8
    return $markerPath
}

$result = [ordered]@{
    SourceRoot = $SourceRoot
    DestinationRoot = $DestinationRoot
    StartedAt = (Get-Date).ToString("s")
    CompletedAt = ""
    Status = "Running"
    Mode = "Update"
    ExitCode = $null
    CopySummary = ""
    VerifiedFiles = @()
    VerificationSkippedFiles = @()
    TimestampTouchedFiles = 0
    TimestampSkippedFiles = 0
    UpdateRecordPath = ""
    UpdateMarkerPath = ""
    Error = ""
}

try {
    $SourceRoot = Resolve-NetworkToolkitFileSystemPath -Path $SourceRoot
    if(Test-Path $DestinationRoot){
        $DestinationRoot = Resolve-NetworkToolkitFileSystemPath -Path $DestinationRoot
    }
    else{
        New-Item -ItemType Directory -Path $DestinationRoot -Force | Out-Null
        $DestinationRoot = Resolve-NetworkToolkitFileSystemPath -Path $DestinationRoot
    }

    $result.SourceRoot = $SourceRoot
    $result.DestinationRoot = $DestinationRoot

    if($SourceRoot.Equals($DestinationRoot,[System.StringComparison]::OrdinalIgnoreCase)){
        throw "Source and destination must be different folders."
    }

    if(!(Test-NetworkToolkitRoot -Path $SourceRoot)){
        throw "The selected source is not a Network Toolkit folder. It must contain NetworkToolkit.ps1, CSI-NetworkToolkit, and ToolKit-GUI."
    }

    # A source checkout can contain production packages under Release. Never
    # recurse into those packages while updating another toolkit location.
    $sourceReleaseDirectory = Join-Path $SourceRoot "Release"
    $sourceUpdateHistory = Join-Path $SourceRoot "manifests\toolkit-update-history.json"
    $excludeDirectories = @(
        (Join-Path $SourceRoot ".git"),
        $sourceReleaseDirectory,
        (Join-Path $SourceRoot "CSI-NetworkToolkit\Data"),
        (Join-Path $SourceRoot "CSI-NetworkToolkit\Exports"),
        (Join-Path $SourceRoot "CSI-NetworkToolkit\Logs"),
        (Join-Path $SourceRoot "CSI-NetworkToolkit\ExternalTools"),
        (Join-Path $SourceRoot "Custom")
    )

    $arguments = @(
        $SourceRoot,
        $DestinationRoot,
        "/E",
        "/COPY:DAT",
        "/DCOPY:DAT",
        "/R:1",
        "/W:1",
        "/NFL",
        "/NDL",
        "/NJH",
        "/NJS",
        "/NP",
        "/XD"
    ) + $excludeDirectories + @(
        "/XF",
        $sourceUpdateHistory
    )

    & robocopy @arguments | Out-String | Set-Content -LiteralPath ($ResultPath + ".log") -Encoding UTF8
    $result.ExitCode = $LASTEXITCODE
    if($LASTEXITCODE -gt 7){
        throw "Robocopy failed with exit code $LASTEXITCODE. Review $($ResultPath).log for details."
    }

    $result.CopySummary = Get-NetworkToolkitRobocopySummary -ExitCode $result.ExitCode
    $verification = Test-NetworkToolkitCopy -SourceRoot $SourceRoot -DestinationRoot $DestinationRoot
    $result.VerifiedFiles = @($verification.Verified)
    $result.VerificationSkippedFiles = @($verification.Skipped)
    $timestampRefresh = Touch-NetworkToolkitProgramFiles -SourceRoot $SourceRoot -DestinationRoot $DestinationRoot
    $result.TimestampTouchedFiles = $timestampRefresh.Touched
    $result.TimestampSkippedFiles = $timestampRefresh.Skipped
    $result.UpdateRecordPath = Write-NetworkToolkitUpdateRecord -ToolkitRoot $DestinationRoot -SourceRoot $SourceRoot -DestinationRoot $DestinationRoot -ExitCode $result.ExitCode -CopySummary $result.CopySummary -VerifiedFiles $result.VerifiedFiles
    $result.UpdateMarkerPath = Write-NetworkToolkitUpdateMarker -ToolkitRoot $DestinationRoot -SourceRoot $SourceRoot -DestinationRoot $DestinationRoot -ExitCode $result.ExitCode -CopySummary $result.CopySummary
    $result.Status = "Completed"
}
catch {
    $result.Status = "Failed"
    $result.Error = $_.Exception.Message
}
finally {
    $result.CompletedAt = (Get-Date).ToString("s")
    $result | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $ResultPath -Encoding UTF8
}

if($result.Status -ne "Completed"){
    exit 1
}
