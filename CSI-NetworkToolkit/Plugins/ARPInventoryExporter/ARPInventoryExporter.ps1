function Global:Invoke-ARPInventoryExporter {

param(
    [string]$OutputPath,
    [ValidateSet("CSV","JSON")]
    [string]$Format = "CSV",
    [switch]$PassThru
)

    Clear-Host

    Write-Host ""
    Write-Host "ARP INVENTORY EXPORTER" -ForegroundColor Cyan
    Write-Host "======================" -ForegroundColor DarkCyan
    Write-Host ""

    if(!(Get-Command Get-NetNeighbor -ErrorAction SilentlyContinue)){

        Write-Host "Get-NetNeighbor is not available on this system." -ForegroundColor Yellow
        return

    }

    if(!$OutputPath){

        $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $extension = if($Format -eq "JSON"){"json"}else{"csv"}
        $OutputPath = Join-Path $CSIPaths.Exports "arp-inventory-$stamp.$extension"

    }

    $neighbors = Get-NetNeighbor -AddressFamily IPv4 |
                 Where-Object {
                     $_.LinkLayerAddress -and
                     $_.State -ne "Unreachable" -and
                     $_.IPAddress -notmatch "^(224|225|226|227|228|229|230|231|232|233|234|235|236|237|238|239)\." -and
                     $_.IPAddress -notmatch "\.255$" -and
                     $_.LinkLayerAddress -ne "FF-FF-FF-FF-FF-FF" -and
                     $_.LinkLayerAddress -notlike "01-00-5E-*"
                 } |
                 Select-Object IPAddress,LinkLayerAddress,InterfaceAlias,State

    if(!$neighbors){

        Write-Host "No IPv4 ARP/neighbor entries found." -ForegroundColor Yellow
        return

    }

    if($Format -eq "JSON"){
        $neighbors | ConvertTo-Json | Set-Content -Path $OutputPath -Encoding UTF8
    }
    else{
        $neighbors | Export-Csv -Path $OutputPath -NoTypeInformation
    }

    if(!$PassThru){
        $neighbors | Format-Table -AutoSize
    }

    Write-Host ""
    Write-Host "Exported:" $OutputPath -ForegroundColor Green

    if($PassThru){
        return $neighbors
    }

}

Register-CSICommand `
    -Name "ARP Inventory Exporter" `
    -Command "Invoke-ARPInventoryExporter" `
    -Category "Plugins" `
    -Description "Export IPv4 neighbor inventory to CSV or JSON" `
    -Order 90 `
    -RequiresAdmin
