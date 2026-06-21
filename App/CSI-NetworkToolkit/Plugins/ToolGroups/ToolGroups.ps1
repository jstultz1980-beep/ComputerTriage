function Global:Invoke-ConnectivityDiagnostics {

    while($true){

        Clear-Host

        Write-Host ""
        Write-Host "CONNECTIVITY DIAGNOSTICS" -ForegroundColor Cyan
        Write-Host "========================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "1. Connectivity Triage"
        Write-Host "2. Adapter Route Health"
        Write-Host "3. Packet Loss Monitor"
        Write-Host "4. Live Route Trace"
        Write-Host "5. Test-NetConnection"
        Write-Host "6. TCPView"
        Write-Host "7. PsPing"
        Write-Host "8. Wireshark Portable"
        Write-Host "9. Install Npcap"
        Write-Host ""

        $choice = Read-CSIInput "Select connectivity task"

        switch($choice){
            "1" { Invoke-ConnectivityTriage }
            "2" { Invoke-AdapterRouteHealth }
            "3" { Invoke-PacketLossMonitor }
            "4" { Invoke-LiveRouteTrace }
            "5" { Invoke-TestNetConnectionTool }
            "6" { Invoke-CSIExternalTool -Id "TCPView" }
            "7" { Invoke-CSIExternalTool -Id "PsPing" }
            "8" { Invoke-CSIExternalTool -Id "Wireshark" }
            "9" { Invoke-CSIExternalTool -Id "NpcapInstaller" }
            default { Write-Host "Invalid selection." -ForegroundColor Red }
        }

        Write-Host ""
        [void](Read-Host "Press ENTER to continue")

    }

}

function Global:Invoke-InfrastructureServices {

    while($true){

        Clear-Host

        Write-Host ""
        Write-Host "INFRASTRUCTURE SERVICES" -ForegroundColor Cyan
        Write-Host "=======================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "1. Local Exposure Inspector"
        Write-Host "2. DHCP Scope Inspector"
        Write-Host "3. Time Sync Health"
        Write-Host "4. Reset Domain Time Source"
        Write-Host "5. DHCP Server Locator"
        Write-Host ""

        $choice = Read-CSIInput "Select infrastructure task"

        switch($choice){
            "1" { Invoke-LocalExposureInspector }
            "2" { Invoke-DHCPScopeInspector }
            "3" { Invoke-TimeSyncHealth }
            "4" { Invoke-ResetDomainTimeSource }
            "5" { Invoke-DHCPServerLocator }
            default { Write-Host "Invalid selection." -ForegroundColor Red }
        }

        Write-Host ""
        [void](Read-Host "Press ENTER to continue")

    }

}

function Global:Invoke-NetworkUtilities {

    while($true){

        Clear-Host

        Write-Host ""
        Write-Host "NETWORK UTILITIES" -ForegroundColor Cyan
        Write-Host "=================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "1. Subnet Calculator"
        Write-Host "2. Wake-on-LAN Tool"
        Write-Host "3. PuTTY"
        Write-Host "4. PsExec"
        Write-Host ""

        $choice = Read-CSIInput "Select network utility"

        switch($choice){
            "1" { Invoke-SubnetCalculator }
            "2" { Invoke-WakeOnLANTool }
            "3" { Invoke-CSIExternalTool -Id "PuTTY" }
            "4" { Invoke-CSIExternalTool -Id "PsExec" }
            default { Write-Host "Invalid selection." -ForegroundColor Red }
        }

        Write-Host ""
        [void](Read-Host "Press ENTER to continue")

    }

}

function Global:Invoke-SoftwareUtilities {

    while($true){

        Clear-Host

        Write-Host ""
        Write-Host "SOFTWARE UTILITIES" -ForegroundColor Cyan
        Write-Host "==================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "1. Install Chocolatey"
        Write-Host "2. Install Choco Package"
        Write-Host "3. External Tool Manager"
        Write-Host ""

        $choice = Read-CSIInput "Select software utility"

        switch($choice){
            "1" { Invoke-InstallChocolatey }
            "2" { Invoke-InstallChocoPackage }
            "3" { Invoke-ExternalToolManager }
            default { Write-Host "Invalid selection." -ForegroundColor Red }
        }

        Write-Host ""
        [void](Read-Host "Press ENTER to continue")

    }

}

Register-CSICommand `
    -Name "Connectivity Diagnostics" `
    -Command "Invoke-ConnectivityDiagnostics" `
    -Category "Troubleshooting" `
    -Description "Connectivity triage, Test-NetConnection, route tracing, packet tools, and live network viewers" `
    -Order 10 `
    -RequiresAdmin

Register-CSICommand `
    -Name "Infrastructure Services" `
    -Command "Invoke-InfrastructureServices" `
    -Category "Troubleshooting" `
    -Description "Local exposure, DHCP, rogue DHCP, and time sync diagnostics" `
    -Order 50 `
    -RequiresAdmin

Register-CSICommand `
    -Name "Network Utilities" `
    -Command "Invoke-NetworkUtilities" `
    -Category "Utilities" `
    -Description "Subnet, Wake-on-LAN, SSH, and remote admin tools" `
    -Order 70

Register-CSICommand `
    -Name "Software Utilities" `
    -Command "Invoke-SoftwareUtilities" `
    -Category "Utilities" `
    -Description "Chocolatey helpers and external tool manager" `
    -Order 80 `
    -RequiresAdmin
