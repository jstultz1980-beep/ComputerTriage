function Global:Test-CSITcpPort {

param(
    [string]$Target,
    [int]$Port,
    [int]$Timeout = 1000
)

    $tcp = New-Object Net.Sockets.TcpClient
    $open = $false
    $status = "Timeout"

    try {

        $connect = $tcp.BeginConnect($Target,$Port,$null,$null)

        if($connect.AsyncWaitHandle.WaitOne($Timeout,$false)){

            $tcp.EndConnect($connect)
            $open = $true
            $status = "Open"

        }

    }
    catch {
        $status = "Closed"
    }
    finally {
        $tcp.Close()
    }

    return [pscustomobject]@{
        Target = $Target
        Port   = $Port
        Open   = $open
        Status = $status
    }

}

function Global:Test-CSIPing {

param(
    [string]$Target,
    [int]$Timeout = 1000
)

    $ping = New-Object System.Net.NetworkInformation.Ping

    try {

        $reply = $ping.Send($Target,$Timeout)

        return [pscustomobject]@{
            Target = $Target
            Status = $reply.Status
            TimeMS = if($reply.Status -eq "Success"){$reply.RoundtripTime}else{$null}
        }

    }
    catch {

        return [pscustomobject]@{
            Target = $Target
            Status = "Failed"
            TimeMS = $null
        }

    }
    finally {
        $ping.Dispose()
    }

}

function Global:Get-CSIDefaultGateways {

    if(!(Get-Command Get-NetIPConfiguration -ErrorAction SilentlyContinue)){
        return @()
    }

    return Get-NetIPConfiguration |
           Where-Object {$_.IPv4DefaultGateway} |
           ForEach-Object {$_.IPv4DefaultGateway.NextHop} |
           Select-Object -Unique

}

function Global:Invoke-ConnectivityTriage {

param(
    [string]$Target = "www.microsoft.com",
    [switch]$PassThru
)

    Clear-Host

    Write-Host ""
    Write-Host "CONNECTIVITY TRIAGE" -ForegroundColor Cyan
    Write-Host "===================" -ForegroundColor DarkCyan
    Write-Host ""

    $results = @()
    $gateways = @(Get-CSIDefaultGateways)

    foreach($gateway in $gateways){

        $ping = Test-CSIPing -Target $gateway

        $results += [pscustomobject]@{
            Check  = "Gateway Ping"
            Target = $gateway
            Status = $ping.Status
            Detail = if($ping.TimeMS -ne $null){"$($ping.TimeMS) ms"}else{""}
        }

    }

    foreach($internetTarget in @("1.1.1.1","8.8.8.8")){

        $ping = Test-CSIPing -Target $internetTarget

        $results += [pscustomobject]@{
            Check  = "Internet IP Ping"
            Target = $internetTarget
            Status = $ping.Status
            Detail = if($ping.TimeMS -ne $null){"$($ping.TimeMS) ms"}else{""}
        }

    }

    try {

        $dnsTime = Measure-Command {
            $addresses = [System.Net.Dns]::GetHostAddresses($Target)
        }

        $results += [pscustomobject]@{
            Check  = "DNS Resolution"
            Target = $Target
            Status = "Success"
            Detail = "$([math]::Round($dnsTime.TotalMilliseconds,0)) ms"
        }

    }
    catch {

        $results += [pscustomobject]@{
            Check  = "DNS Resolution"
            Target = $Target
            Status = "Failed"
            Detail = $_.Exception.Message
        }

    }

    $https = Test-CSITcpPort -Target $Target -Port 443 -Timeout 1500

    $results += [pscustomobject]@{
        Check  = "HTTPS Reachability"
        Target = "$Target`:443"
        Status = $https.Status
        Detail = ""
    }

    $domain = ""

    try {
        $domain = (Get-CimInstance Win32_ComputerSystem).Domain
    }
    catch {}

    if($domain -and $domain -ne "WORKGROUP"){

        if(Get-Command nltest -ErrorAction SilentlyContinue){

            $dc = nltest /dsgetdc:$domain 2>&1
            $dcStatus = if($LASTEXITCODE -eq 0){"Success"}else{"Failed"}

            $results += [pscustomobject]@{
                Check  = "Domain Controller Discovery"
                Target = $domain
                Status = $dcStatus
                Detail = ($dc | Select-Object -First 1)
            }

        }

        if(Get-Command Test-ComputerSecureChannel -ErrorAction SilentlyContinue){

            try {
                $secure = Test-ComputerSecureChannel -ErrorAction Stop
            }
            catch {
                $secure = $false
            }

            $results += [pscustomobject]@{
                Check  = "Secure Channel"
                Target = $domain
                Status = if($secure){"Success"}else{"Failed"}
                Detail = ""
            }

        }

    }

    if(Get-Command netsh -ErrorAction SilentlyContinue){

        $winHttpProxy = (netsh winhttp show proxy) -join " "

        $results += [pscustomobject]@{
            Check  = "WinHTTP Proxy"
            Target = "Local"
            Status = "Info"
            Detail = $winHttpProxy.Trim()
        }

    }

    if($PassThru){
        return $results
    }

    $results | Format-Table -Wrap -AutoSize

}

function Global:Invoke-DNSPathTest {

param(
    [string]$Name,
    [switch]$PassThru
)

    Clear-Host

    Write-Host ""
    Write-Host "DNS PATH TEST" -ForegroundColor Cyan
    Write-Host "=============" -ForegroundColor DarkCyan
    Write-Host ""

    if(!$Name){
        $Name = Read-CSIInput "Host or IP to test"
    }

    $results = @()
    $hostsFile = Join-Path $env:SystemRoot "System32\drivers\etc\hosts"

    if(Test-Path $hostsFile){

        $hostsHits = Get-Content $hostsFile |
                     Where-Object {$_ -match "\s$([regex]::Escape($Name))(\s|$)" -and $_ -notmatch "^\s*#"}

        $results += [pscustomobject]@{
            Check  = "Hosts File"
            Target = $Name
            Status = if($hostsHits){"Match"}else{"Clear"}
            Detail = ($hostsHits -join "; ")
        }

    }

    if(Get-Command Get-DnsClientCache -ErrorAction SilentlyContinue){

        $cache = Get-DnsClientCache -ErrorAction SilentlyContinue |
                 Where-Object {$_.Entry -eq $Name -or $_.Name -eq $Name}

        $results += [pscustomobject]@{
            Check  = "DNS Client Cache"
            Target = $Name
            Status = if($cache){"Present"}else{"Not Present"}
            Detail = if($cache){($cache | Select-Object -First 1 | Out-String).Trim()}else{""}
        }

    }

    $servers = @()

    try {
        $servers = (Get-DnsClientServerAddress -AddressFamily IPv4).ServerAddresses | Select-Object -Unique
    }
    catch {}

    if(!$servers){
        $servers = @("System")
    }

    foreach($server in $servers){

        try {

            $answer = $null
            $elapsed = Measure-Command {

                if(Get-Command Resolve-DnsName -ErrorAction SilentlyContinue){

                    if($server -eq "System"){
                        $answer = Resolve-DnsName -Name $Name -ErrorAction Stop
                    }
                    else{
                        $answer = Resolve-DnsName -Name $Name -Server $server -ErrorAction Stop
                    }

                }
                else{
                    $answer = [System.Net.Dns]::GetHostAddresses($Name)
                }

            }

            $detail = ($answer |
                       Where-Object {$_.IPAddress -or $_.IPAddressToString} |
                       ForEach-Object {if($_.IPAddress){$_.IPAddress}else{$_.IPAddressToString}} |
                       Select-Object -Unique) -join ", "

            $results += [pscustomobject]@{
                Check  = "DNS Server"
                Target = $server
                Status = "Success"
                Detail = "$([math]::Round($elapsed.TotalMilliseconds,0)) ms $detail"
            }

        }
        catch {

            $results += [pscustomobject]@{
                Check  = "DNS Server"
                Target = $server
                Status = "Failed"
                Detail = $_.Exception.Message
            }

        }

    }

    if($Name -match "^\d{1,3}(\.\d{1,3}){3}$"){

        try {

            $reverse = [System.Net.Dns]::GetHostEntry($Name)

            $results += [pscustomobject]@{
                Check  = "Reverse Lookup"
                Target = $Name
                Status = "Success"
                Detail = $reverse.HostName
            }

        }
        catch {

            $results += [pscustomobject]@{
                Check  = "Reverse Lookup"
                Target = $Name
                Status = "Failed"
                Detail = $_.Exception.Message
            }

        }

    }

    if($PassThru){
        return $results
    }

    $results | Format-Table -Wrap -AutoSize

}

function Global:Invoke-AdapterRouteHealth {

param([switch]$PassThru)

    Clear-Host

    Write-Host ""
    Write-Host "ADAPTER / ROUTE HEALTH" -ForegroundColor Cyan
    Write-Host "======================" -ForegroundColor DarkCyan
    Write-Host ""

    $results = @()

    if(Get-Command Get-NetIPConfiguration -ErrorAction SilentlyContinue){

        $configs = Get-NetIPConfiguration | Where-Object {$_.NetAdapter.Status -eq "Up" -or $_.IPv4Address}

        foreach($config in $configs){

            $ip = if($config.IPv4Address){$config.IPv4Address.IPAddress}else{""}
            $gateway = if($config.IPv4DefaultGateway){$config.IPv4DefaultGateway.NextHop}else{""}
            $dns = if($config.DNSServer){$config.DNSServer.ServerAddresses -join ","}else{""}
            $issues = @()

            if($ip -match "^169\.254\."){
                $issues += "APIPA"
            }

            if($ip -and !$gateway){
                $issues += "No gateway"
            }

            if(!$dns){
                $issues += "No DNS"
            }

            if($config.NetAdapter.LinkSpeed){
                $speed = $config.NetAdapter.LinkSpeed
            }
            else{
                $speed = ""
            }

            $results += [pscustomobject]@{
                Area   = "Adapter"
                Name   = $config.InterfaceAlias
                Status = if($issues){"Warning"}else{"OK"}
                Detail = "IP=$ip Gateway=$gateway DNS=$dns Speed=$speed Issues=$($issues -join ',')"
            }

        }

    }

    if(Get-Command Get-NetRoute -ErrorAction SilentlyContinue){

        $defaults = Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue |
                    Sort-Object RouteMetric,InterfaceMetric

        foreach($route in $defaults){

            $results += [pscustomobject]@{
                Area   = "Default Route"
                Name   = $route.InterfaceAlias
                Status = "Info"
                Detail = "NextHop=$($route.NextHop) RouteMetric=$($route.RouteMetric) InterfaceMetric=$($route.InterfaceMetric)"
            }

        }

        if(@($defaults).Count -gt 1){

            $results += [pscustomobject]@{
                Area   = "Route Conflict"
                Name   = "Default Routes"
                Status = "Warning"
                Detail = "Multiple default routes are active"
            }

        }

    }

    if(Get-Command Get-NetAdapter -ErrorAction SilentlyContinue){

        $vpnAdapters = Get-NetAdapter -ErrorAction SilentlyContinue |
                       Where-Object {$_.InterfaceDescription -match "VPN|TAP|TUN|WireGuard|Cisco|AnyConnect|OpenVPN|Fortinet|SonicWall"}

        foreach($adapter in $vpnAdapters){

            $results += [pscustomobject]@{
                Area   = "VPN"
                Name   = $adapter.Name
                Status = $adapter.Status
                Detail = $adapter.InterfaceDescription
            }

        }

    }

    try {

        $dhcpConfigs = Get-CimInstance Win32_NetworkAdapterConfiguration -Filter "IPEnabled=True"

        foreach($dhcp in $dhcpConfigs){

            $results += [pscustomobject]@{
                Area   = "DHCP"
                Name   = $dhcp.Description
                Status = if($dhcp.DHCPEnabled){"Enabled"}else{"Static"}
                Detail = "Server=$($dhcp.DHCPServer) LeaseExpires=$($dhcp.DHCPLeaseExpires)"
            }

        }

    }
    catch {}

    if(Get-Command netsh -ErrorAction SilentlyContinue){

        $wifi = netsh wlan show interfaces 2>$null

        if($wifi -and ($wifi -join "") -notmatch "There is no wireless interface"){

            $summary = ($wifi |
                        Where-Object {$_ -match "^\s*(SSID|Signal|Radio type|Channel|Receive rate|Transmit rate|Authentication)\s+:"} |
                        ForEach-Object {$_.Trim()}) -join "; "

            $results += [pscustomobject]@{
                Area   = "Wi-Fi"
                Name   = "Wireless"
                Status = "Info"
                Detail = $summary
            }

        }

    }

    if($PassThru){
        return $results
    }

    $results | Format-Table -Wrap -AutoSize

}

function Global:Invoke-PortReachabilityMatrix {

param(
    [string]$Target,
    [ValidateSet("Basic","Web","Windows","Directory","Database","RDP","SMB","All")]
    [string]$Profile = "Basic",
    [int]$Timeout = 1000,
    [switch]$PassThru
)

    Clear-Host

    Write-Host ""
    Write-Host "PORT REACHABILITY MATRIX" -ForegroundColor Cyan
    Write-Host "========================" -ForegroundColor DarkCyan
    Write-Host ""

    if(!$Target){
        $Target = Read-CSIInput "Target host"
    }

    $profiles = @{
        Basic     = @(53,80,443)
        Web       = @(80,443,8080,8443)
        Windows   = @(135,139,445,3389,5985,5986)
        Directory = @(53,88,135,389,445,464,636,3268,3269)
        Database  = @(1433,1521,3306,5432,6379,27017)
        RDP       = @(3389)
        SMB       = @(445,139)
        All       = @(22,25,53,80,88,110,135,139,143,389,443,445,464,587,636,993,995,1433,1521,3306,3389,5432,5985,5986,6379,8080,8443,27017)
    }

    $results = @()

    foreach($port in $profiles[$Profile]){
        $results += Test-CSITcpPort -Target $Target -Port $port -Timeout $Timeout
    }

    if($PassThru){
        return $results
    }

    $results | Format-Table -AutoSize

}

function Global:Invoke-PacketLossMonitor {

param(
    [string[]]$Targets,
    [int]$Count = 20,
    [int]$DelayMS = 500,
    [int]$Timeout = 1000,
    [switch]$PassThru
)

    Clear-Host

    Write-Host ""
    Write-Host "PACKET LOSS MONITOR" -ForegroundColor Cyan
    Write-Host "===================" -ForegroundColor DarkCyan
    Write-Host ""

    if(!$Targets -or $Targets.Count -eq 0){
        $Targets = (Read-CSIInput "Targets separated by comma").Split(",") | ForEach-Object {$_.Trim()} | Where-Object {$_}
    }

    $stats = @{}

    foreach($target in $Targets){
        $stats[$target] = [pscustomobject]@{
            Target = $target
            Sent   = 0
            Lost   = 0
            Times  = New-Object System.Collections.ArrayList
        }
    }

    for($i = 1; $i -le $Count; $i++){

        if(Test-CSIKeyEscape){
            Exit-CSITool
        }

        foreach($target in $Targets){

            if(Test-CSIKeyEscape){
                Exit-CSITool
            }

            $ping = Test-CSIPing -Target $target -Timeout $Timeout
            $stats[$target].Sent++

            if($ping.Status -eq "Success"){
                [void]$stats[$target].Times.Add([int]$ping.TimeMS)
                Write-Host "$target reply $($ping.TimeMS) ms" -ForegroundColor Green
            }
            else{
                $stats[$target].Lost++
                Write-Host "$target $($ping.Status)" -ForegroundColor Yellow
            }

        }

        if($i -lt $Count){
            Start-Sleep -Milliseconds $DelayMS
        }

    }

    $results = foreach($target in $Targets){

        $item = $stats[$target]
        $times = @($item.Times)
        $avg = if($times.Count -gt 0){[math]::Round(($times | Measure-Object -Average).Average,1)}else{$null}
        $max = if($times.Count -gt 0){($times | Measure-Object -Maximum).Maximum}else{$null}
        $min = if($times.Count -gt 0){($times | Measure-Object -Minimum).Minimum}else{$null}
        $jitter = if($times.Count -gt 1){[math]::Round((($times | Measure-Object -Maximum).Maximum - ($times | Measure-Object -Minimum).Minimum),1)}else{0}

        [pscustomobject]@{
            Target  = $target
            Sent    = $item.Sent
            Lost    = $item.Lost
            LossPct = [math]::Round(($item.Lost / $item.Sent) * 100,1)
            MinMS   = $min
            AvgMS   = $avg
            MaxMS   = $max
            Jitter  = $jitter
        }

    }

    Write-Host ""

    if($PassThru){
        return $results
    }

    $results | Format-Table -AutoSize

}

function Global:Invoke-LocalExposureInspector {

param([switch]$PassThru)

    Clear-Host

    Write-Host ""
    Write-Host "LOCAL EXPOSURE INSPECTOR" -ForegroundColor Cyan
    Write-Host "========================" -ForegroundColor DarkCyan
    Write-Host ""

    $results = @()

    if(Get-Command Get-NetFirewallProfile -ErrorAction SilentlyContinue){

        foreach($profile in Get-NetFirewallProfile){

            $results += [pscustomobject]@{
                Area   = "Firewall Profile"
                Name   = $profile.Name
                Status = if($profile.Enabled){"Enabled"}else{"Disabled"}
                Detail = "DefaultInbound=$($profile.DefaultInboundAction) DefaultOutbound=$($profile.DefaultOutboundAction)"
            }

        }

    }

    if(Get-Command Get-NetTCPConnection -ErrorAction SilentlyContinue){

        $listeners = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
                     Select-Object -First 60

        foreach($listener in $listeners){

            $processName = ""

            try {
                $processName = (Get-Process -Id $listener.OwningProcess -ErrorAction Stop).ProcessName
            }
            catch {}

            $results += [pscustomobject]@{
                Area   = "Listening TCP"
                Name   = "$($listener.LocalAddress):$($listener.LocalPort)"
                Status = "Listening"
                Detail = "PID=$($listener.OwningProcess) Process=$processName"
            }

        }

    }

    if(Get-Command Get-NetFirewallRule -ErrorAction SilentlyContinue){

        $allowRules = Get-NetFirewallRule -Enabled True -Direction Inbound -Action Allow -ErrorAction SilentlyContinue |
                      Select-Object -First 50

        foreach($rule in $allowRules){

            $results += [pscustomobject]@{
                Area   = "Inbound Allow Rule"
                Name   = $rule.DisplayName
                Status = $rule.Profile
                Detail = $rule.Group
            }

        }

    }

    if(Get-Service TermService -ErrorAction SilentlyContinue){

        $rdpPort = Test-CSITcpPort -Target "127.0.0.1" -Port 3389 -Timeout 500

        $results += [pscustomobject]@{
            Area   = "RDP Readiness"
            Name   = "Local RDP"
            Status = $rdpPort.Status
            Detail = "TermService=$((Get-Service TermService).Status)"
        }

    }

    if($PassThru){
        return $results
    }

    $results | Format-Table -Wrap -AutoSize

}

function Global:Invoke-TLSCertificateCheck {

param(
    [string]$Target,
    [int]$Port = 443,
    [switch]$PassThru
)

    Clear-Host

    Write-Host ""
    Write-Host "TLS / CERTIFICATE CHECK" -ForegroundColor Cyan
    Write-Host "=======================" -ForegroundColor DarkCyan
    Write-Host ""

    if(!$Target){
        $Target = Read-CSIInput "TLS host"
    }

    $result = $null
    $tcp = New-Object Net.Sockets.TcpClient

    try {

        $tcp.Connect($Target,$Port)
        $ssl = New-Object Net.Security.SslStream($tcp.GetStream(),$false,({$true}))
        $ssl.AuthenticateAsClient($Target)
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($ssl.RemoteCertificate)
        $days = ([datetime]$cert.NotAfter - (Get-Date)).Days

        $result = [pscustomobject]@{
            Target    = "$Target`:$Port"
            Subject   = $cert.Subject
            Issuer    = $cert.Issuer
            NotBefore = $cert.NotBefore
            NotAfter  = $cert.NotAfter
            DaysLeft  = $days
            Thumbprint = $cert.Thumbprint
            Status    = if($days -lt 0){"Expired"}elseif($days -lt 30){"Expiring Soon"}else{"OK"}
        }

    }
    catch {

        $result = [pscustomobject]@{
            Target    = "$Target`:$Port"
            Subject   = ""
            Issuer    = ""
            NotBefore = ""
            NotAfter  = ""
            DaysLeft  = ""
            Thumbprint = ""
            Status    = $_.Exception.Message
        }

    }
    finally {
        $tcp.Close()
    }

    if($PassThru){
        return $result
    }

    $result | Format-List

}

function Global:Invoke-TimeSyncHealth {

param([switch]$PassThru)

    Clear-Host

    Write-Host ""
    Write-Host "TIME SYNC HEALTH" -ForegroundColor Cyan
    Write-Host "================" -ForegroundColor DarkCyan
    Write-Host ""

    $results = @()

    $service = Get-Service W32Time -ErrorAction SilentlyContinue

    if($service){

        $results += [pscustomobject]@{
            Check  = "Windows Time Service"
            Status = $service.Status
            Detail = $service.StartType
        }

    }

    if(Get-Command w32tm -ErrorAction SilentlyContinue){

        $source = w32tm /query /source 2>&1
        $status = w32tm /query /status 2>&1

        $results += [pscustomobject]@{
            Check  = "Time Source"
            Status = "Info"
            Detail = ($source -join " ").Trim()
        }

        $results += [pscustomobject]@{
            Check  = "Time Status"
            Status = if($LASTEXITCODE -eq 0){"OK"}else{"Warning"}
            Detail = (($status | Select-Object -First 3) -join " ").Trim()
        }

    }

    if($PassThru){
        return $results
    }

    $results | Format-Table -Wrap -AutoSize

}

function Global:Invoke-UsualSuspectsTriage {

param(
    [string]$Target = "www.microsoft.com",
    [switch]$PassThru
)

    Clear-Host

    Write-Host ""
    Write-Host "USUAL SUSPECTS TRIAGE" -ForegroundColor Cyan
    Write-Host "=====================" -ForegroundColor DarkCyan
    Write-Host ""

    $results = @()

    $results += [pscustomobject]@{
        Area   = "Session"
        Check  = "Administrator"
        Status = if(Test-CSIAdministrator){"OK"}else{"Info"}
        Detail = if(Test-CSIAdministrator){"Running elevated"}else{"Not elevated"}
    }

    if(Get-Command Get-NetIPConfiguration -ErrorAction SilentlyContinue){

        $configs = @(Get-NetIPConfiguration | Where-Object {$_.IPv4Address})

        foreach($config in $configs){

            $ip = $config.IPv4Address.IPAddress
            $gateway = if($config.IPv4DefaultGateway){$config.IPv4DefaultGateway.NextHop}else{""}
            $dns = if($config.DNSServer){$config.DNSServer.ServerAddresses -join ","}else{""}
            $issues = @()

            if($ip -match "^169\.254\."){
                $issues += "APIPA"
            }

            if(!$gateway){
                $issues += "No gateway"
            }

            if(!$dns){
                $issues += "No DNS"
            }

            $results += [pscustomobject]@{
                Area   = "Network"
                Check  = $config.InterfaceAlias
                Status = if($issues){"Warning"}else{"OK"}
                Detail = "IP=$ip Gateway=$gateway DNS=$dns Issues=$($issues -join ',')"
            }

        }

    }

    foreach($gateway in @(Get-CSIDefaultGateways)){

        $ping = Test-CSIPing -Target $gateway -Timeout 1000

        $results += [pscustomobject]@{
            Area   = "Network"
            Check  = "Gateway $gateway"
            Status = if($ping.Status -eq "Success"){"OK"}else{"Warning"}
            Detail = if($ping.TimeMS -ne $null){"$($ping.TimeMS) ms"}else{$ping.Status}
        }

    }

    foreach($internetTarget in @("1.1.1.1","8.8.8.8")){

        $ping = Test-CSIPing -Target $internetTarget -Timeout 1000

        $results += [pscustomobject]@{
            Area   = "Internet"
            Check  = "Ping $internetTarget"
            Status = if($ping.Status -eq "Success"){"OK"}else{"Warning"}
            Detail = if($ping.TimeMS -ne $null){"$($ping.TimeMS) ms"}else{$ping.Status}
        }

    }

    try {

        $dnsTime = Measure-Command {
            [void][System.Net.Dns]::GetHostAddresses($Target)
        }

        $results += [pscustomobject]@{
            Area   = "DNS"
            Check  = $Target
            Status = "OK"
            Detail = "$([math]::Round($dnsTime.TotalMilliseconds,0)) ms"
        }

    }
    catch {

        $results += [pscustomobject]@{
            Area   = "DNS"
            Check  = $Target
            Status = "Warning"
            Detail = $_.Exception.Message
        }

    }

    $https = Test-CSITcpPort -Target $Target -Port 443 -Timeout 1500

    $results += [pscustomobject]@{
        Area   = "Internet"
        Check  = "HTTPS $Target"
        Status = if($https.Open){"OK"}else{"Warning"}
        Detail = $https.Status
    }

    $services = "Dnscache","Dhcp","NlaSvc","LanmanWorkstation","W32Time","WinRM","Netlogon"

    foreach($serviceName in $services){

        $service = Get-Service $serviceName -ErrorAction SilentlyContinue

        if($service){

            $results += [pscustomobject]@{
                Area   = "Services"
                Check  = $serviceName
                Status = if($service.Status -eq "Running"){"OK"}else{"Warning"}
                Detail = $service.Status
            }

        }

    }

    try {

        $domain = (Get-CimInstance Win32_ComputerSystem).Domain

        if($domain -and $domain -ne "WORKGROUP"){

            if(Get-Command nltest -ErrorAction SilentlyContinue){

                $dc = nltest /dsgetdc:$domain 2>&1

                $results += [pscustomobject]@{
                    Area   = "Domain"
                    Check  = "DC Discovery"
                    Status = if($LASTEXITCODE -eq 0){"OK"}else{"Warning"}
                    Detail = (($dc | Select-Object -First 1) -join " ").Trim()
                }

            }

            if(Get-Command Test-ComputerSecureChannel -ErrorAction SilentlyContinue){

                try {
                    $secure = Test-ComputerSecureChannel -ErrorAction Stop
                }
                catch {
                    $secure = $false
                }

                $results += [pscustomobject]@{
                    Area   = "Domain"
                    Check  = "Secure Channel"
                    Status = if($secure){"OK"}else{"Warning"}
                    Detail = if($secure){"Healthy"}else{"Failed"}
                }

            }

        }

    }
    catch {}

    if(Get-Command Get-NetFirewallProfile -ErrorAction SilentlyContinue){

        foreach($profile in Get-NetFirewallProfile){

            $results += [pscustomobject]@{
                Area   = "Firewall"
                Check  = $profile.Name
                Status = if($profile.Enabled){"OK"}else{"Warning"}
                Detail = "Inbound=$($profile.DefaultInboundAction) Outbound=$($profile.DefaultOutboundAction)"
            }

        }

    }

    if(Get-Command w32tm -ErrorAction SilentlyContinue){

        $source = w32tm /query /source 2>&1

        $results += [pscustomobject]@{
            Area   = "Time"
            Check  = "Source"
            Status = if($LASTEXITCODE -eq 0){"OK"}else{"Warning"}
            Detail = ($source -join " ").Trim()
        }

    }

    try {

        $pending = Get-CSIPendingRebootState

        $results += [pscustomobject]@{
            Area   = "System"
            Check  = "Pending Reboot"
            Status = if($pending.Pending){"Warning"}else{"OK"}
            Detail = if($pending.Pending){$pending.Details -join ","}else{"None"}
        }

    }
    catch {}

    Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction SilentlyContinue |
        ForEach-Object {

            $freePct = if($_.Size -gt 0){[math]::Round(($_.FreeSpace / $_.Size) * 100,1)}else{0}

            $results += [pscustomobject]@{
                Area   = "Disk"
                Check  = $_.DeviceID
                Status = if($freePct -lt 10){"Warning"}else{"OK"}
                Detail = "$freePct% free"
            }

        }

    if(Get-Command netsh -ErrorAction SilentlyContinue){

        $proxy = (netsh winhttp show proxy) -join " "

        $results += [pscustomobject]@{
            Area   = "Proxy"
            Check  = "WinHTTP"
            Status = "Info"
            Detail = $proxy.Trim()
        }

    }

    $wifi = Get-Service WlanSvc -ErrorAction SilentlyContinue

    if($wifi){

        $results += [pscustomobject]@{
            Area   = "Wi-Fi"
            Check  = "WlanSvc"
            Status = if($wifi.Status -eq "Running"){"OK"}else{"Info"}
            Detail = $wifi.Status
        }

    }

    if($PassThru){
        return $results
    }

    $results | Format-Table -Wrap -AutoSize

}

function Global:Invoke-LiveRouteTrace {

param(
    [string]$Target,
    [int]$MaxHops = 30,
    [switch]$PassThru
)

    Clear-Host

    Write-Host ""
    Write-Host "LIVE ROUTE TRACE" -ForegroundColor Cyan
    Write-Host "================" -ForegroundColor DarkCyan
    Write-Host ""

    if(!$Target){
        $Target = Read-CSIInput "Target host or IP"
    }

    $results = @()
    $addresses = @()

    try {
        $addresses = [System.Net.Dns]::GetHostAddresses($Target) |
                     Where-Object {$_.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork}
    }
    catch {}

    $targetIP = if($addresses){$addresses[0].IPAddressToString}else{$Target}

    $results += [pscustomobject]@{
        Step   = "Resolve"
        Target = $Target
        Status = if($addresses){"OK"}else{"Info"}
        Detail = if($addresses){($addresses.IPAddressToString -join ", ")}else{"Using target as provided"}
    }

    if(Get-Command Find-NetRoute -ErrorAction SilentlyContinue){

        try {

            $route = Find-NetRoute -RemoteIPAddress $targetIP -ErrorAction Stop |
                     Select-Object -First 1

            $results += [pscustomobject]@{
                Step   = "Selected Route"
                Target = $targetIP
                Status = "OK"
                Detail = "Interface=$($route.InterfaceAlias) NextHop=$($route.NextHop) Route=$($route.DestinationPrefix)"
            }

        }
        catch {

            $results += [pscustomobject]@{
                Step   = "Selected Route"
                Target = $targetIP
                Status = "Warning"
                Detail = $_.Exception.Message
            }

        }

    }

    foreach($gateway in @(Get-CSIDefaultGateways)){

        $ping = Test-CSIPing -Target $gateway -Timeout 1000

        $results += [pscustomobject]@{
            Step   = "Gateway Ping"
            Target = $gateway
            Status = if($ping.Status -eq "Success"){"OK"}else{"Warning"}
            Detail = if($ping.TimeMS -ne $null){"$($ping.TimeMS) ms"}else{$ping.Status}
        }

    }

    $targetPing = Test-CSIPing -Target $targetIP -Timeout 1500

    $results += [pscustomobject]@{
        Step   = "Target Ping"
        Target = $targetIP
        Status = if($targetPing.Status -eq "Success"){"OK"}else{"Warning"}
        Detail = if($targetPing.TimeMS -ne $null){"$($targetPing.TimeMS) ms"}else{$targetPing.Status}
    }

    $trace = tracert -d -h $MaxHops $targetIP 2>&1

    foreach($line in $trace){

        if($line -match "^\s*(\d+)\s+(.+)$"){

            $hop = [int]$matches[1]
            $body = $matches[2].Trim()
            $address = ([regex]::Matches($body,"\d{1,3}(\.\d{1,3}){3}") | Select-Object -First 1).Value
            $timeouts = ([regex]::Matches($body,"\*")).Count

            $results += [pscustomobject]@{
                Step   = "Hop $hop"
                Target = if($address){$address}else{"No Reply"}
                Status = if($timeouts -ge 3){"Timeout"}elseif($timeouts -gt 0){"Partial"}else{"OK"}
                Detail = $body
            }

        }

    }

    if($PassThru){
        return $results
    }

    $results | Format-Table -Wrap -AutoSize

}

Register-CSICommand `
    -Name "Usual Suspects Triage" `
    -Command "Invoke-UsualSuspectsTriage" `
    -Category "Troubleshooting" `
    -Description "Run a broad live workstation/server issue triage" `
    -Order 4

Register-CSICommand `
    -Name "Connectivity Triage" `
    -Command "Invoke-ConnectivityTriage" `
    -Category "Troubleshooting" `
    -Description "Live gateway, DNS, internet, domain, HTTPS, and proxy checks" `
    -Order 10

Register-CSICommand `
    -Name "DNS Path Test" `
    -Command "Invoke-DNSPathTest" `
    -Category "Troubleshooting" `
    -Description "Check hosts file, DNS cache, DNS servers, and reverse lookup" `
    -Order 31

Register-CSICommand `
    -Name "Adapter Route Health" `
    -Command "Invoke-AdapterRouteHealth" `
    -Category "Troubleshooting" `
    -Description "Expose adapter, DHCP, route, VPN, and Wi-Fi issues" `
    -Order 11 `
    -RequiresAdmin

Register-CSICommand `
    -Name "Port Reachability Matrix" `
    -Command "Invoke-PortReachabilityMatrix" `
    -Category "Troubleshooting" `
    -Description "Test troubleshooting port profiles against a target" `
    -Order 41

Register-CSICommand `
    -Name "Packet Loss Monitor" `
    -Command "Invoke-PacketLossMonitor" `
    -Category "Troubleshooting" `
    -Description "Live packet loss, latency, and jitter monitor" `
    -Order 23

Register-CSICommand `
    -Name "Live Route Trace" `
    -Command "Invoke-LiveRouteTrace" `
    -Category "Troubleshooting" `
    -Description "Show selected route, gateway health, ping, and hop trace to a target" `
    -Order 24

Register-CSICommand `
    -Name "Local Exposure Inspector" `
    -Command "Invoke-LocalExposureInspector" `
    -Category "Troubleshooting" `
    -Description "Show firewall state, listening ports, allow rules, and RDP readiness" `
    -Order 50 `
    -RequiresAdmin

Register-CSICommand `
    -Name "TLS Certificate Check" `
    -Command "Invoke-TLSCertificateCheck" `
    -Category "Troubleshooting" `
    -Description "Check TLS negotiation and certificate health" `
    -Order 43

Register-CSICommand `
    -Name "Time Sync Health" `
    -Command "Invoke-TimeSyncHealth" `
    -Category "Troubleshooting" `
    -Description "Check Windows Time service and current time source" `
    -Order 52 `
    -RequiresAdmin
