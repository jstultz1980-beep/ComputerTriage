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

$result = [ordered]@{
    SourceRoot = $SourceRoot
    DestinationRoot = $DestinationRoot
    StartedAt = (Get-Date).ToString("s")
    CompletedAt = ""
    Status = "Running"
    Mode = "Update"
    ExitCode = $null
    Error = ""
}

try {
    $SourceRoot = (Resolve-Path -LiteralPath $SourceRoot).Path.TrimEnd('\')
    if(Test-Path $DestinationRoot){
        $DestinationRoot = (Resolve-Path -LiteralPath $DestinationRoot).Path.TrimEnd('\')
    }
    else{
        New-Item -ItemType Directory -Path $DestinationRoot -Force | Out-Null
        $DestinationRoot = (Resolve-Path -LiteralPath $DestinationRoot).Path.TrimEnd('\')
    }

    $result.SourceRoot = $SourceRoot
    $result.DestinationRoot = $DestinationRoot

    if($SourceRoot.Equals($DestinationRoot,[System.StringComparison]::OrdinalIgnoreCase)){
        throw "Source and destination must be different folders."
    }

    if(!(Test-NetworkToolkitRoot -Path $SourceRoot)){
        throw "The selected source is not a Network Toolkit folder. It must contain NetworkToolkit.ps1, CSI-NetworkToolkit, and ToolKit-GUI."
    }

    $excludeDirectories = @(
        (Join-Path $SourceRoot ".git"),
        (Join-Path $SourceRoot "Release"),
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
