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
        [Parameter(Mandatory=$true)][string]$DestinationRoot,
        [Parameter(Mandatory=$true)][string]$SourceRoot,
        [int]$ExitCode
    )

    $manifestRoot = Join-Path $DestinationRoot "manifests"
    $historyPath = Join-Path $manifestRoot "toolkit-update-history.json"
    New-Item -ItemType Directory -Path $manifestRoot -Force | Out-Null

    $history = @()
    if(Test-Path -LiteralPath $historyPath){
        try {
            $history = @(Get-Content -LiteralPath $historyPath -Raw -ErrorAction Stop | ConvertFrom-Json)
        }
        catch {
            $history = @()
        }
    }

    $history += [pscustomobject]@{
        UpdatedAt = (Get-Date).ToString("s")
        Source = $SourceRoot
        ExitCode = $ExitCode
    }
    $history = @($history | Select-Object -Last 25)
    $history | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $historyPath -Encoding UTF8
    return $historyPath
}

$result = [ordered]@{
    SourceRoot = $SourceRoot
    DestinationRoot = $DestinationRoot
    StartedAt = (Get-Date).ToString("s")
    CompletedAt = ""
    Status = "Running"
    Mode = "Update"
    ExitCode = $null
    UpdateRecordPath = ""
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
    $excludeDirectories = @(
        (Join-Path $SourceRoot ".git"),
        $sourceReleaseDirectory,
        (Join-Path $SourceRoot "CSI-NetworkToolkit\Data"),
        (Join-Path $SourceRoot "CSI-NetworkToolkit\Exports"),
        (Join-Path $SourceRoot "CSI-NetworkToolkit\Logs"),
        (Join-Path $SourceRoot "Custom\FirefoxPortable\Data")
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
    ) + $excludeDirectories

    & robocopy @arguments | Out-String | Set-Content -LiteralPath ($ResultPath + ".log") -Encoding UTF8
    $result.ExitCode = $LASTEXITCODE
    if($LASTEXITCODE -gt 7){
        throw "Robocopy failed with exit code $LASTEXITCODE. Review $($ResultPath).log for details."
    }

    $result.UpdateRecordPath = Write-NetworkToolkitUpdateRecord -DestinationRoot $DestinationRoot -SourceRoot $SourceRoot -ExitCode $result.ExitCode
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
