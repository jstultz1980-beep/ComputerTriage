function Global:Write-ToolkitLog {

param([string]$Message)

$logFile = Join-Path $PSScriptRoot "..\Logs\Toolkit.log"

$time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Add-Content $logFile "$time  $Message"

}

function Global:Write-CSIWarning {

param(
    [string]$Component,
    [string]$Message
)

    $text = "[WARN][$Component] $Message"
    try {
        Write-ToolkitLog $text
    }
    catch {
        [System.Diagnostics.Debug]::WriteLine($text)
    }
}
