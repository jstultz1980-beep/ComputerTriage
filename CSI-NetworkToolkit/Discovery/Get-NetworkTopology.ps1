# =====================================================================
# Get-NetworkTopology.ps1
# Discover key network infrastructure
# =====================================================================

function Global:Get-NetworkTopology {

param([switch]$PassThru)

    Clear-Host

    Write-Host ""
    Write-Host "NETWORK TOPOLOGY SNAPSHOT" -ForegroundColor Cyan
    Write-Host "=========================" -ForegroundColor DarkCyan
    Write-Host ""

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
    $gateway = ""

    if($iface.IPv4DefaultGateway){
        $gateway = $iface.IPv4DefaultGateway.NextHop
    }

    try {
        $dns = (Get-DnsClientServerAddress -AddressFamily IPv4).ServerAddresses
    }
    catch {
        $dns = @()
    }

    try {
        $domain = (Get-CimInstance Win32_ComputerSystem).Domain
    }
    catch {
        $domain = ""
    }

    Write-Host "Local System"
    Write-Host "------------"

    $topology = [pscustomobject]@{
        Computer = $env:COMPUTERNAME
        IP       = $ip
        Prefix   = $prefix
        Gateway  = $gateway
        Domain   = $domain
    }

    $topology | Format-Table

    Write-Host ""
    Write-Host "DNS Servers"
    Write-Host "-----------"

    if($dns){

        foreach($d in $dns){
            Write-Host $d
        }

    }
    else{

        Write-Host "No IPv4 DNS servers found." -ForegroundColor Yellow

    }

    Write-Host ""

    if($PassThru){
        return $topology
    }

}

Register-CSICommand `
    -Name "Network Topology Snapshot" `
    -Command "Get-NetworkTopology" `
    -Category "Discovery" `
    -Description "Display key network infrastructure" `
    -Order 12
