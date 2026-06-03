function Global:Invoke-NetworkScan {

param(
    [string]$CIDR,
    [int]$Timeout = 750,
    [int]$Throttle = 128,
    [switch]$PassThru
)

    Clear-Host

    Write-Host ""
    Write-Host "LOCAL NETWORK SCAN" -ForegroundColor Cyan
    Write-Host "==================" -ForegroundColor DarkCyan
    Write-Host ""

    if(!$CIDR){

        if(!(Get-Command Get-NetIPConfiguration -ErrorAction SilentlyContinue)){

            Write-Host "Get-NetIPConfiguration is not available on this system." -ForegroundColor Yellow
            return

        }

        $iface = Get-NetIPConfiguration |
                 Where-Object {$_.IPv4Address} |
                 Select-Object -First 1

        if(!$iface){

            Write-Host "No IPv4 network interface found." -ForegroundColor Yellow
            return

        }

        $ip = $iface.IPv4Address.IPAddress
        $prefix = $iface.IPv4Address.PrefixLength

        $CIDR = "$ip/$prefix"

    }

    Write-Host "Scanning network:" $CIDR
    Write-Host ""

    try {

        $ips = Convert-CIDRToIPs $CIDR

    }
    catch {

        Write-Host $_.Exception.Message -ForegroundColor Red
        return

    }

    Write-Host "Scanning hosts:" $ips.Count
    Write-Host "Timeout:" $Timeout "ms"
    Write-Host ""

    $alive = Invoke-CSIPingSweep `
        -IPAddresses $ips `
        -Timeout $Timeout `
        -Throttle $Throttle

    foreach($ipAddress in $alive){

        Write-Host "$ipAddress alive" -ForegroundColor Green

    }

    Write-Host ""
    Write-Host "Alive Hosts:" $alive.Count

    if($PassThru){
        return $alive
    }

}

Register-CSICommand `
    -Name "Network Scan" `
    -Command "Invoke-NetworkScan" `
    -Category "Scanning" `
    -Description "Auto-detect and scan the local IPv4 network" `
    -Order 21
