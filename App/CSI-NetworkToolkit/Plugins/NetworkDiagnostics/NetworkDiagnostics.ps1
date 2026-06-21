function Global:Invoke-NetworkDiscovery {

    while($true){

        Clear-Host

        Write-Host ""
        Write-Host "NETWORK DISCOVERY" -ForegroundColor Cyan
        Write-Host "=================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "1. Auto Local Subnet Scan"
        Write-Host "2. Manual CIDR Ping Sweep"
        Write-Host "3. Network Topology Snapshot"
        Write-Host "4. Network Neighbors"
        Write-Host ""

        $choice = Read-CSIInput "Select discovery task"

        switch($choice){
            "1" { Invoke-NetworkScan }
            "2" { Invoke-NetworkPingUtility }
            "3" { Get-NetworkTopology }
            "4" { Get-NetworkNeighbors }
            default { Write-Host "Invalid selection." -ForegroundColor Red }
        }

        Write-Host ""
        [void](Read-Host "Press ENTER to continue")

    }

}

Register-CSICommand `
    -Name "Network Discovery" `
    -Command "Invoke-NetworkDiscovery" `
    -Category "Discovery" `
    -Description "Auto subnet scan, manual ping sweep, topology, and neighbor table" `
    -Order 12
