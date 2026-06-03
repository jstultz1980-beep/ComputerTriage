function Global:Invoke-ToolkitStatus {

    Clear-Host

    Write-Host ""
    Write-Host "TOOLKIT STATUS / COMMAND INVENTORY" -ForegroundColor Cyan
    Write-Host "==================================" -ForegroundColor DarkCyan
    Write-Host ""

    Write-Host "Root:" $CSIPaths.Root
    Write-Host "Logs:" $CSIPaths.Logs
    Write-Host "Plugins:" $CSIPaths.Plugins
    Write-Host ""

    Write-Host "Registered Commands"
    Write-Host "-------------------"

    Get-CSICommands |
        Select-Object Name,Category,Source,RequiresAdmin,Description |
        Format-Table -AutoSize

}

Register-CSICommand `
    -Name "Toolkit Status / Command Inventory" `
    -Command "Invoke-ToolkitStatus" `
    -Category "Plugins" `
    -Description "Show toolkit paths, plugin sources, and registered commands" `
    -Order 1
