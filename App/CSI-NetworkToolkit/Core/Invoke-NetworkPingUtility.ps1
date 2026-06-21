function Global:Invoke-NetworkPingUtility {

param(
    [string]$CIDR,
    [int]$Timeout = 750,
    [int]$Throttle = 128,
    [switch]$PassThru
)

    Clear-Host

    Write-Host ""
    Write-Host "PING SWEEP" -ForegroundColor Cyan
    Write-Host "===========" -ForegroundColor DarkCyan
    Write-Host ""

    if(!$CIDR){
        $CIDR = Read-CSIInput "Enter CIDR network (example 192.168.1.0/24)"
    }

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

    foreach($ip in $alive){

        Write-Host "$ip alive" -ForegroundColor Green

    }

    Write-Host ""
    Write-Host "Alive Hosts:" $alive.Count

    if($PassThru){
        return $alive
    }

}
