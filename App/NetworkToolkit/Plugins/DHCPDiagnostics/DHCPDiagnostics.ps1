function Global:Convert-NTKMacAddressToBytes {

param([string]$MacAddress)

    if(!$MacAddress){
        return $null
    }

    $parts = $MacAddress -split "[:-]"

    if($parts.Count -lt 6){
        return $null
    }

    return [byte[]]($parts[0..5] | ForEach-Object { [Convert]::ToByte($_, 16) })

}

function Global:Convert-NTKBytesToIPv4 {

param([byte[]]$Bytes)

    if(!$Bytes -or $Bytes.Count -lt 4){
        return $null
    }

    return ([System.Net.IPAddress]::new($Bytes[0..3])).ToString()

}

function Global:New-NTKDHCPInformPacket {

param(
    [string]$IPv4Address,
    [string]$MacAddress,
    [string]$HostName
)

    $macBytes = Convert-NTKMacAddressToBytes $MacAddress

    if(!$macBytes){
        throw "Unable to parse adapter MAC address: $MacAddress"
    }

    $packet = New-Object byte[] 548
    $packet[0] = 1
    $packet[1] = 1
    $packet[2] = 6

    $transactionId = [uint32](Get-Random -Minimum 1 -Maximum ([int]::MaxValue))
    $transactionBytes = [BitConverter]::GetBytes($transactionId)

    if([BitConverter]::IsLittleEndian){
        [Array]::Reverse($transactionBytes)
    }

    [Array]::Copy($transactionBytes, 0, $packet, 4, 4)

    $packet[10] = 0x80

    $ipBytes = [System.Net.IPAddress]::Parse($IPv4Address).GetAddressBytes()
    [Array]::Copy($ipBytes, 0, $packet, 12, 4)
    [Array]::Copy($macBytes, 0, $packet, 28, 6)

    $packet[236] = 99
    $packet[237] = 130
    $packet[238] = 83
    $packet[239] = 99

    $options = [System.Collections.Generic.List[byte]]::new()
    $options.AddRange([byte[]]@(53, 1, 8))

    if($HostName){
        $cleanName = $HostName

        if($cleanName.Length -gt 63){
            $cleanName = $cleanName.Substring(0, 63)
        }

        $hostBytes = [Text.Encoding]::ASCII.GetBytes($cleanName)
        $options.Add(12)
        $options.Add([byte]$hostBytes.Length)
        $options.AddRange([byte[]]$hostBytes)
    }

    $options.AddRange([byte[]]@(55, 8, 1, 3, 6, 15, 51, 54, 58, 59))
    $options.Add(255)

    [Array]::Copy($options.ToArray(), 0, $packet, 240, $options.Count)

    return $packet

}

function Global:Get-NTKDHCPPacketOptions {

param([byte[]]$Packet)

    $options = @{}

    if(!$Packet -or $Packet.Count -lt 241){
        return $options
    }

    if($Packet[236] -ne 99 -or $Packet[237] -ne 130 -or $Packet[238] -ne 83 -or $Packet[239] -ne 99){
        return $options
    }

    $index = 240

    while($index -lt $Packet.Count){

        $code = [int]$Packet[$index]
        $index++

        if($code -eq 0){
            continue
        }

        if($code -eq 255){
            break
        }

        if($index -ge $Packet.Count){
            break
        }

        $length = [int]$Packet[$index]
        $index++

        if(($index + $length) -gt $Packet.Count){
            break
        }

        if($length -eq 0){
            $options[$code] = [byte[]]@()
        }
        else{
            $options[$code] = [byte[]]$Packet[$index..($index + $length - 1)]
        }

        $index += $length

    }

    return $options

}

function Global:Get-NTKNetworkNeighborHint {

param([string]$IPAddress)

    try {
        $neighbor = Get-NetNeighbor -IPAddress $IPAddress -ErrorAction SilentlyContinue |
            Where-Object { $_.LinkLayerAddress -and $_.LinkLayerAddress -ne "00-00-00-00-00-00" } |
            Select-Object -First 1

        if($neighbor){
            return $neighbor.LinkLayerAddress
        }
    }
    catch {
        return $null
    }

    return $null

}

function Global:Invoke-NTKDHCPInformProbe {

param(
    [pscustomobject]$Adapter,
    [int]$TimeoutSeconds = 4
)

    $results = @()

    if(!$Adapter.IPv4Address -or !$Adapter.MacAddress){
        return $results
    }

    $client = $null

    try {

        $packet = New-NTKDHCPInformPacket `
            -IPv4Address $Adapter.IPv4Address `
            -MacAddress $Adapter.MacAddress `
            -HostName $env:COMPUTERNAME

        $client = [System.Net.Sockets.UdpClient]::new()
        $client.EnableBroadcast = $true
        $client.Client.ReceiveTimeout = 500
        $client.Client.SetSocketOption(
            [System.Net.Sockets.SocketOptionLevel]::Socket,
            [System.Net.Sockets.SocketOptionName]::ReuseAddress,
            $true
        )

        $localAddress = [System.Net.IPAddress]::Parse($Adapter.IPv4Address)

        try {
            $client.Client.Bind([System.Net.IPEndPoint]::new($localAddress, 68))
        }
        catch {
            $client.Client.Bind([System.Net.IPEndPoint]::new($localAddress, 0))
        }

        $target = [System.Net.IPEndPoint]::new([System.Net.IPAddress]::Broadcast, 67)
        [void]$client.Send($packet, $packet.Length, $target)

        $stopAt = (Get-Date).AddSeconds($TimeoutSeconds)

        while((Get-Date) -lt $stopAt){

            try {

                if($client.Available -le 0){
                    Start-Sleep -Milliseconds 100
                    continue
                }

                $remote = [System.Net.IPEndPoint]::new([System.Net.IPAddress]::Any, 0)
                $response = $client.Receive([ref]$remote)
                $options = Get-NTKDHCPPacketOptions -Packet $response
                $serverId = $null

                if($options.ContainsKey(54)){
                    $serverId = Convert-NTKBytesToIPv4 $options[54]
                }

                if(!$serverId){
                    $serverId = $remote.Address.ToString()
                }

                $router = $null
                $dnsServers = @()
                $domain = $null

                if($options.ContainsKey(3)){
                    $router = Convert-NTKBytesToIPv4 $options[3]
                }

                if($options.ContainsKey(6)){
                    for($i = 0; $i -lt $options[6].Count; $i += 4){
                        if(($i + 3) -lt $options[6].Count){
                            $dnsServers += Convert-NTKBytesToIPv4 ([byte[]]$options[6][$i..($i + 3)])
                        }
                    }
                }

                if($options.ContainsKey(15)){
                    $domain = ([Text.Encoding]::ASCII.GetString($options[15])).Trim([char]0).Trim()
                }

                $results += [pscustomobject]@{
                    Adapter       = $Adapter.Description
                    Interface     = $Adapter.InterfaceAlias
                    LocalAddress  = $Adapter.IPv4Address
                    Server        = $serverId
                    SourceAddress = $remote.Address.ToString()
                    Router        = $router
                    DnsServers    = ($dnsServers -join ", ")
                    Domain        = $domain
                    Method        = "DHCPINFORM"
                }

            }
            catch [System.Net.Sockets.SocketException] {
                Start-Sleep -Milliseconds 100
            }

        }

    }
    catch {

        $results += [pscustomobject]@{
            Adapter       = $Adapter.Description
            Interface     = $Adapter.InterfaceAlias
            LocalAddress  = $Adapter.IPv4Address
            Server        = $null
            SourceAddress = $null
            Router        = $null
            DnsServers    = $null
            Domain        = $null
            Method        = "Probe failed: $($_.Exception.Message)"
        }

    }
    finally {

        if($client){
            $client.Close()
            $client.Dispose()
        }

    }

    return $results

}

function Global:Get-NTKDHCPClientAdapters {

    $configs = Get-CimInstance Win32_NetworkAdapterConfiguration -Filter "IPEnabled=True"

    foreach($config in $configs){

        $ipv4 = @($config.IPAddress | Where-Object { $_ -match "^\d{1,3}(\.\d{1,3}){3}$" }) | Select-Object -First 1

        if(!$ipv4){
            continue
        }

        $netAdapter = $null

        try {
            $netAdapter = Get-NetAdapter -InterfaceIndex $config.InterfaceIndex -ErrorAction SilentlyContinue
        }
        catch {
            $netAdapter = $null
        }

        [pscustomobject]@{
            Description    = $config.Description
            InterfaceAlias = if($netAdapter){ $netAdapter.Name } else { "Interface $($config.InterfaceIndex)" }
            InterfaceIndex = $config.InterfaceIndex
            IPv4Address    = $ipv4
            MacAddress     = $config.MACAddress
            DHCPEnabled    = [bool]$config.DHCPEnabled
            DHCPServer     = $config.DHCPServer
            DefaultGateway = (@($config.DefaultIPGateway | Where-Object { $_ -match "^\d{1,3}(\.\d{1,3}){3}$" }) -join ", ")
            DNSServers     = (@($config.DNSServerSearchOrder | Where-Object { $_ -match "^\d{1,3}(\.\d{1,3}){3}$" }) -join ", ")
        }

    }

}

function Global:Get-NTKIpconfigDHCPServers {

    $servers = @()

    try {
        $lines = ipconfig.exe /all 2>$null
        $currentAdapter = $null

        foreach($line in $lines){

            if($line -match "^[^\s].*adapter\s+(.+):\s*$"){
                $currentAdapter = $matches[1].Trim()
                continue
            }

            if($line -match "DHCP Server[ .]*:\s*(\d{1,3}(\.\d{1,3}){3})"){
                $servers += [pscustomobject]@{
                    Adapter = $currentAdapter
                    Server  = $matches[1]
                    Method  = "ipconfig /all"
                }
            }

        }
    }
    catch {
        return @()
    }

    return @($servers | Sort-Object Adapter,Server -Unique)

}

function Global:Resolve-NTKTSharkPath {

    if(Get-Command Resolve-NTKExternalTool -ErrorAction SilentlyContinue){
        $tool = Resolve-NTKExternalTool -Id "TShark"

        if($tool -and $tool.Found){
            return $tool.Path
        }
    }

    $root = $null

    if($NTKPaths -and $NTKPaths.Root){
        $root = Join-Path $NTKPaths.Root "ExternalTools"
    }

    if(!$root -or !(Test-Path $root)){
        return $null
    }

    $paths = @(
        "WiresharkPortable64\App\Wireshark\tshark.exe"
        "WiresharkPortable\App\Wireshark\tshark.exe"
    )

    foreach($relativePath in $paths){
        $path = Join-Path $root $relativePath

        if(Test-Path $path){
            return (Resolve-Path $path).Path
        }
    }

    return $null

}

function Global:Get-NTKTSharkInterfaces {

param([string]$TSharkPath)

    $interfaces = @()

    if(!$TSharkPath -or !(Test-Path $TSharkPath)){
        return $interfaces
    }

    try {
        $lines = & $TSharkPath -D 2>&1

        foreach($line in $lines){

            if($line -match "^\s*(\d+)\.\s+(.+)$"){
                $number = [int]$matches[1]
                $name = $matches[2].Trim()

                $interfaces += [pscustomobject]@{
                    Number = $number
                    Name   = $name
                }
            }

        }
    }
    catch {
        return @()
    }

    return $interfaces

}

function Global:Convert-NTKTSharkDHCPLine {

param([string]$Line)

    if(!$Line){
        return $null
    }

    $fields = $Line -split "\|", 9

    while($fields.Count -lt 9){
        $fields += ""
    }

    $server = $fields[3]

    if(!$server){
        $server = $fields[1]
    }

    if(!$server -or $server -eq "0.0.0.0"){
        return $null
    }

    return [pscustomobject]@{
        Adapter       = "TShark capture"
        Interface     = $fields[8]
        LocalAddress  = ""
        Server        = $server
        SourceAddress = $fields[1]
        SourceMac     = $fields[2]
        Router        = $fields[5]
        DnsServers    = $fields[6]
        Domain        = ""
        Method        = "TShark"
        Time          = $fields[0]
        MessageType   = $fields[7]
    }

}

function Global:Invoke-NTKTSharkDHCPCapture {

param(
    [int]$DurationSeconds = 20,
    [int]$InterfaceNumber = 0,
    [switch]$RenewLease
)

    $results = @()
    $tshark = Resolve-NTKTSharkPath

    if(!$tshark){
        Write-Host "TShark was not found under ExternalTools\\WiresharkPortable64." -ForegroundColor Yellow
        Write-Host "Install or extract Wireshark Portable with tshark.exe to use CLI DHCP capture." -ForegroundColor Yellow
        return $results
    }

    $interfaces = @(Get-NTKTSharkInterfaces -TSharkPath $tshark)

    if(!$interfaces){
        Write-Host "TShark is installed, but no capture interfaces were returned." -ForegroundColor Yellow
        Write-Host "Npcap may be missing or needs to be installed with admin rights." -ForegroundColor Yellow
        return $results
    }

    Write-Host ""
    Write-Host "TShark capture interfaces" -ForegroundColor Yellow

    foreach($interface in $interfaces){
        Write-Host ("{0}. {1}" -f $interface.Number,$interface.Name)
    }

    if($InterfaceNumber -gt 0){
        $selected = $interfaces | Where-Object { $_.Number -eq $InterfaceNumber } | Select-Object -First 1
    }
    else{
        Write-Host ""
        $selection = Read-NTKInput "Capture interface number (blank for first listed interface)" -AllowEmpty

        if($selection -and ($selection -as [int])){
            $selected = $interfaces | Where-Object { $_.Number -eq [int]$selection } | Select-Object -First 1
        }
        else{
            $selected = $interfaces |
                Where-Object { $_.Name -notmatch "Loopback|ciscodump|etwdump|randpkt|sshdump|udpdump|wifidump" } |
                Select-Object -First 1

            if(!$selected){
                $selected = $interfaces | Select-Object -First 1
            }
        }
    }

    if(!$selected){
        Write-Host "Invalid TShark interface selection." -ForegroundColor Red
        return $results
    }

    Write-Host ""
    Write-Host ("Capturing DHCP traffic for {0} seconds on interface {1}..." -f $DurationSeconds,$selected.Number) -ForegroundColor Gray
    Write-Host "Tip: DHCP traffic only appears when a client requests or renews a lease." -ForegroundColor Gray

    $arguments = @(
        "-i", ([string]$selected.Number)
        "-a", "duration:$DurationSeconds"
        "-f", "udp port 67 or udp port 68"
        "-Y", "dhcp.option.dhcp_server_id || udp.srcport == 67"
        "-T", "fields"
        "-E", "separator=|"
        "-e", "frame.time"
        "-e", "ip.src"
        "-e", "eth.src"
        "-e", "dhcp.option.dhcp_server_id"
        "-e", "dhcp.ip.your"
        "-e", "dhcp.option.router"
        "-e", "dhcp.option.domain_name_server"
        "-e", "dhcp.option.dhcp"
    )

    $outputFile = Join-Path $env:TEMP ("NTK-TShark-DHCP-{0}.out" -f ([guid]::NewGuid().ToString("N")))
    $errorFile = Join-Path $env:TEMP ("NTK-TShark-DHCP-{0}.err" -f ([guid]::NewGuid().ToString("N")))

    try {

        $argumentLine = ($arguments | ForEach-Object {
            if($_ -match '[\s"]'){
                '"' + ($_ -replace '"','\"') + '"'
            }
            else{
                $_
            }
        }) -join " "

        $startedAt = Get-Date

        $process = Start-Process `
            -FilePath $tshark `
            -ArgumentList $argumentLine `
            -RedirectStandardOutput $outputFile `
            -RedirectStandardError $errorFile `
            -WindowStyle Hidden `
            -PassThru

        if($RenewLease){

            Start-Sleep -Seconds 2

            Write-Host "Requesting DHCP lease renewal to generate DHCP traffic..." -ForegroundColor Gray

            try {
                $renew = Start-Process `
                    -FilePath "ipconfig.exe" `
                    -ArgumentList "/renew" `
                    -WindowStyle Hidden `
                    -PassThru

                [void]$renew.WaitForExit(15000)
            }
            catch {
                Write-Host "Unable to run ipconfig /renew automatically." -ForegroundColor Yellow
                Write-Host $_.Exception.Message
            }

        }

        $finished = $process.WaitForExit(($DurationSeconds + 15) * 1000)

        if(!$finished){

            try {
                $process.Kill()
            }
            catch {
            }

            try {
                Get-CimInstance Win32_Process -Filter "ParentProcessId=$($process.Id)" -ErrorAction SilentlyContinue |
                    ForEach-Object {
                        Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
                    }
            }
            catch {
            }

            Write-Host "TShark did not stop cleanly; capture was ended by the toolkit." -ForegroundColor Yellow

        }

        $lines = @()

        if(Test-Path $outputFile){
            $lines = Get-Content $outputFile -ErrorAction SilentlyContinue
        }

        foreach($line in $lines){

            if(!$line -or $line -match "^(Capturing|Packets|tshark:|Running as user)"){
                continue
            }

            $result = Convert-NTKTSharkDHCPLine ("$line|$($selected.Name)")

            if($result){
                $results += $result
            }

        }

        if((Test-Path $errorFile) -and !$results){
            $errorLines = @(Get-Content $errorFile -ErrorAction SilentlyContinue | Where-Object { $_ -and $_ -notmatch "^(Capturing|Packets captured)" })

            if($errorLines){
                Write-Host "TShark notes:" -ForegroundColor Yellow
                $errorLines | Select-Object -First 6 | ForEach-Object { Write-Host $_ -ForegroundColor Gray }
            }
        }
    }
    catch {
        Write-Host "TShark capture failed." -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
    finally {
        Remove-Item $outputFile,$errorFile -Force -ErrorAction SilentlyContinue
    }

    return @($results | Sort-Object Server,SourceMac,Interface -Unique)

}

function Global:Invoke-RogueDHCPServerScan {

param(
    [string[]]$KnownServer,
    [int]$TimeoutSeconds = 4,
    [int]$CaptureSeconds = 20,
    [int]$CaptureInterface = 0,
    [switch]$UseTShark,
    [switch]$RenewLease,
    [switch]$NoPrompt,
    [switch]$PassThru
)

    Clear-Host

    Write-Host ""
    Write-Host "DHCP SERVER LOCATOR" -ForegroundColor Cyan
    Write-Host "===================" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "This checks current DHCP lease evidence, sends a best-effort DHCPINFORM probe, and can capture DHCP replies with TShark." -ForegroundColor Gray
    Write-Host "Unexpected DHCP responders should be investigated on the switch, firewall, or wireless network." -ForegroundColor Gray
    Write-Host ""

    if(!$KnownServer -and !$NoPrompt){
        $knownInput = Read-NTKInput "Known/approved DHCP server IPs (comma separated, blank to trust current lease server)" -AllowEmpty

        if($knownInput){
            $KnownServer = @($knownInput -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ })
        }
    }

    $adapters = @(Get-NTKDHCPClientAdapters)
    $findings = @()

    if(!$UseTShark -and !$NoPrompt){
        $tsharkChoice = Read-NTKInput "Run Wireshark CLI/TShark DHCP capture? Y/N (blank = Yes)" -AllowEmpty

        if(!$tsharkChoice -or $tsharkChoice -match "^(y|yes)$"){
            $UseTShark = $true
        }
    }

    if($UseTShark -and !$RenewLease -and !$NoPrompt){
        $renewChoice = Read-NTKInput "Run ipconfig /renew during capture to force DHCP traffic? Y/N (blank = No)" -AllowEmpty

        if($renewChoice -match "^(y|yes)$"){
            $RenewLease = $true
        }
    }

    if(!$adapters -and !$UseTShark){

        $findings += [pscustomobject]@{
            Status       = "Info"
            Adapter      = "Local computer"
            Server       = ""
            Evidence     = "No active IPv4 adapters were found through Windows client configuration."
            Recommendation = "Use the TShark capture path, or check adapter status, cable/Wi-Fi connection, VLAN, VM network mode, and static IP configuration."
        }

        if(!$PassThru){
            $findings | Format-List Status,Adapter,Server,Evidence,Recommendation | Out-Host
        }

        return $findings

    }

    if($adapters){

        Write-Host "Current adapter and DHCP evidence" -ForegroundColor Yellow
        $adapters |
            Select-Object InterfaceAlias,IPv4Address,DHCPEnabled,DHCPServer,DefaultGateway,DNSServers |
            Format-Table -AutoSize |
            Out-Host

    }
    else{

        $findings += [pscustomobject]@{
            Status       = "Info"
            Adapter      = "Local computer"
            Server       = ""
            Evidence     = "No active IPv4 adapters were found through Windows client configuration."
            Recommendation = "Use the TShark capture path below, or check whether the adapter is static, disconnected, or hidden by the VM network driver."
        }

    }

    Write-Host ""
    Write-Host "Active DHCP probe" -ForegroundColor Yellow

    $probeResults = @()

    foreach($adapter in $adapters){

        Write-Host "Probing from $($adapter.InterfaceAlias) ($($adapter.IPv4Address))..." -ForegroundColor Gray
        $probeResults += Invoke-NTKDHCPInformProbe -Adapter $adapter -TimeoutSeconds $TimeoutSeconds

    }

    $tsharkResults = @()

    if($UseTShark){
        $tsharkResults = @(Invoke-NTKTSharkDHCPCapture -DurationSeconds ([Math]::Max($CaptureSeconds, $TimeoutSeconds)) -InterfaceNumber $CaptureInterface -RenewLease:$RenewLease)
    }

    $ipconfigServers = @(Get-NTKIpconfigDHCPServers)

    $approvedServers = @($KnownServer | Where-Object { $_ })

    if(!$approvedServers){
        $approvedServers = @($adapters | ForEach-Object { $_.DHCPServer } | Where-Object { $_ } | Select-Object -Unique)
    }

    foreach($adapter in $adapters){

        $macHint = $null

        if($adapter.DHCPServer){
            $macHint = Get-NTKNetworkNeighborHint -IPAddress $adapter.DHCPServer
        }

        if(!$adapter.DHCPServer -and !$adapter.DHCPEnabled){
            $status = "Info"
        }
        else{
            $status = if($adapter.DHCPServer -and ($approvedServers -contains $adapter.DHCPServer)){ "OK" } else { "Warning" }
        }

        $recommendation = if($status -eq "OK"){
            "Current lease server is approved. Compare active probe responders below for conflicts."
        }
        elseif($status -eq "Info"){
            "Adapter is not currently using DHCP. Use TShark capture on the connected interface to watch for DHCP offers from other clients."
        }
        else{
            "Confirm this DHCP server is authorized. Trace the MAC address from ARP or the switch CAM table and disable unauthorized DHCP service."
        }

        $findings += [pscustomobject]@{
            Status       = $status
            Adapter      = $adapter.InterfaceAlias
            Server       = $adapter.DHCPServer
            Evidence     = "IPv4 $($adapter.IPv4Address). DHCP enabled: $($adapter.DHCPEnabled). Lease server: $($adapter.DHCPServer). MAC hint: $macHint"
            Recommendation = $recommendation
        }

    }

    foreach($server in $ipconfigServers){

        $status = if($approvedServers -contains $server.Server){ "OK" } else { "Warning" }

        $findings += [pscustomobject]@{
            Status       = $status
            Adapter      = $server.Adapter
            Server       = $server.Server
            Evidence     = "DHCP server found in ipconfig /all."
            Recommendation = if($status -eq "OK"){ "Server matches approved DHCP list." } else { "Confirm this DHCP server is authorized and trace it from ARP/switch CAM table." }
        }

    }

    $uniqueProbeServers = @(
        @($probeResults + $tsharkResults) |
            Where-Object { $_.Server } |
            Sort-Object Server,Interface -Unique
    )

    foreach($response in $uniqueProbeServers){

        $status = if($approvedServers -contains $response.Server){ "OK" } else { "Warning" }
        $macText = if($response.SourceMac){ " MAC: $($response.SourceMac)." } else { "" }
        $detail = "Responder $($response.Server) answered from $($response.SourceAddress) on $($response.Interface).$macText Router: $($response.Router). DNS: $($response.DnsServers). Domain: $($response.Domain). Method: $($response.Method)"
        $recommendation = if($status -eq "OK"){
            "Responder matches the approved DHCP server list."
        }
        else{
            "Potential rogue DHCP server. Check the connected switch port/VLAN, wireless AP client list, and enable DHCP snooping where available."
        }

        $findings += [pscustomobject]@{
            Status       = $status
            Adapter      = $response.Interface
            Server       = $response.Server
            Evidence     = $detail
            Recommendation = $recommendation
        }

    }

    if(!$uniqueProbeServers){

        $findings += [pscustomobject]@{
            Status       = "Info"
            Adapter      = "Active probe"
            Server       = ""
            Evidence     = "No DHCP replies were observed during the probe/capture window."
            Recommendation = "This does not prove the network is clean. Try again on the affected VLAN, connect by wire when possible, and renew a DHCP client during the capture window."
        }

    }

    Write-Host ""
    Write-Host "Findings" -ForegroundColor Yellow
    $findings | Format-List Status,Adapter,Server,Evidence,Recommendation | Out-Host

    Write-Host ""
    Write-Host "Fast next steps:" -ForegroundColor Yellow
    Write-Host "- If an unknown DHCP server appears, find its MAC in ARP or the switch CAM table."
    Write-Host "- Check for Internet Connection Sharing, rogue routers, lab gear, VMs, or wireless extenders."
    Write-Host "- On managed switches, enable DHCP snooping and allow only trusted uplink/server ports."

    if($PassThru){
        return $findings
    }

}

function Global:Invoke-DHCPServerLocator {

param(
    [string[]]$KnownServer,
    [int]$TimeoutSeconds = 4,
    [int]$CaptureSeconds = 20,
    [int]$CaptureInterface = 0,
    [switch]$UseTShark,
    [switch]$RenewLease,
    [switch]$NoPrompt,
    [switch]$PassThru
)

    Invoke-RogueDHCPServerScan `
        -KnownServer $KnownServer `
        -TimeoutSeconds $TimeoutSeconds `
        -CaptureSeconds $CaptureSeconds `
        -CaptureInterface $CaptureInterface `
        -UseTShark:$UseTShark `
        -RenewLease:$RenewLease `
        -NoPrompt:$NoPrompt `
        -PassThru:$PassThru

}
