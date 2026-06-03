function Global:Get-NetworkNeighbors {

param([switch]$PassThru)

    Clear-Host

    Write-Host ""
    Write-Host "NETWORK NEIGHBOR TABLE" -ForegroundColor Cyan
    Write-Host "======================" -ForegroundColor DarkCyan
    Write-Host ""

    if(!(Get-Command Get-NetNeighbor -ErrorAction SilentlyContinue)){

        Write-Host "Get-NetNeighbor is not available on this system." -ForegroundColor Yellow
        return

    }

    try {

        $neighbors = Get-NetNeighbor -AddressFamily IPv4 |
                     Where-Object {$_.State -eq "Reachable"}

    }
    catch {

        Write-Host "Unable to read the neighbor table." -ForegroundColor Red
        Write-Host $_.Exception.Message
        return

    }

    if(!$neighbors){

        Write-Host "No reachable IPv4 neighbors found." -ForegroundColor Yellow
        return

    }

    $neighbors |
        Select-Object IPAddress,LinkLayerAddress,InterfaceAlias |
        Format-Table -AutoSize

    if($PassThru){
        return $neighbors
    }

}

Register-CSICommand `
    -Name "Network Neighbors" `
    -Command "Get-NetworkNeighbors" `
    -Category "Discovery" `
    -Description "Show reachable IPv4 neighbor table entries" `
    -Order 13
