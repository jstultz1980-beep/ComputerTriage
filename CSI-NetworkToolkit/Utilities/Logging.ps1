function Global:Write-ToolkitLog {

param([string]$Message)

$logFile = Join-Path $PSScriptRoot "..\Logs\Toolkit.log"

$time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Add-Content $logFile "$time  $Message"

}
