function Global:Invoke-WakeOnLANTool {

param(
    [string]$MacAddress,
    [string]$Broadcast = "255.255.255.255",
    [int]$Port = 9
)

    Clear-Host

    Write-Host ""
    Write-Host "WAKE-ON-LAN TOOL" -ForegroundColor Cyan
    Write-Host "================" -ForegroundColor DarkCyan
    Write-Host ""

    if(!$MacAddress){
        $MacAddress = Read-CSIInput "MAC address"
    }

    $cleanMac = $MacAddress -replace "[-:\.]",""

    if($cleanMac -notmatch "^[0-9A-Fa-f]{12}$"){

        Write-Host "Invalid MAC address." -ForegroundColor Red
        return

    }

    $macBytes = New-Object byte[] 6

    for($i = 0; $i -lt 6; $i++){
        $macBytes[$i] = [Convert]::ToByte($cleanMac.Substring($i * 2,2),16)
    }

    $packet = New-Object byte[] 102

    for($i = 0; $i -lt 6; $i++){
        $packet[$i] = 0xFF
    }

    for($i = 1; $i -le 16; $i++){
        [Array]::Copy($macBytes,0,$packet,$i * 6,6)
    }

    $client = New-Object Net.Sockets.UdpClient
    $client.EnableBroadcast = $true

    try {

        [void]$client.Send($packet,$packet.Length,$Broadcast,$Port)

        Write-Host "Magic packet sent to $MacAddress via $Broadcast`:$Port" -ForegroundColor Green

    }
    finally {
        $client.Close()
    }

}

Register-CSICommand `
    -Name "Wake-on-LAN Tool" `
    -Command "Invoke-WakeOnLANTool" `
    -Category "Plugins" `
    -Description "Send a Wake-on-LAN magic packet" `
    -Order 72
