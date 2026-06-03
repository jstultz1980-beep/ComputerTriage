function Global:Get-CSIWiFiServiceState {

    $service = Get-Service WlanSvc -ErrorAction SilentlyContinue

    if(!$service){

        return [pscustomobject]@{
            Present = $false
            Status  = "Missing"
            Detail  = "Wireless AutoConfig service is not installed."
        }

    }

    return [pscustomobject]@{
        Present = $true
        Status  = $service.Status
        Detail  = "StartType=$($service.StartType)"
    }

}

function Global:Convert-CSIWiFiKeyValue {

param([string[]]$Lines)

    $item = [ordered]@{}

    foreach($line in $Lines){

        if($line -match "^\s*([^:]+?)\s+:\s*(.*)$"){

            $key = ($matches[1] -replace "\s+","").Trim()
            $value = $matches[2].Trim()

            if($key){
                $item[$key] = $value
            }

        }

    }

    return [pscustomobject]$item

}

function Global:Get-CSIWiFiInterfaces {

    $service = Get-CSIWiFiServiceState

    if(!$service.Present -or $service.Status -ne "Running"){
        return @()
    }

    $output = netsh wlan show interfaces 2>&1

    if($LASTEXITCODE -ne 0 -or (($output -join " ") -match "There is no wireless interface")){
        return @()
    }

    $blocks = @()
    $current = @()

    foreach($line in $output){

        if($line -match "^\s*Name\s+:" -and $current.Count -gt 0){
            $blocks += ,$current
            $current = @()
        }

        $current += $line

    }

    if($current.Count -gt 0){
        $blocks += ,$current
    }

    return $blocks | ForEach-Object { Convert-CSIWiFiKeyValue $_ }

}

function Global:Get-CSIWiFiNetworks {

    $service = Get-CSIWiFiServiceState

    if(!$service.Present -or $service.Status -ne "Running"){
        return @()
    }

    $output = netsh wlan show networks mode=bssid 2>&1

    if($LASTEXITCODE -ne 0){
        return @()
    }

    $results = @()
    $ssid = ""
    $auth = ""
    $encryption = ""
    $bssid = ""
    $signal = ""
    $radio = ""
    $channel = ""

    foreach($line in $output){

        if($line -match "^\s*SSID\s+\d+\s+:\s*(.*)$"){
            $ssid = $matches[1].Trim()
            $auth = ""
            $encryption = ""
        }
        elseif($line -match "^\s*Authentication\s+:\s*(.*)$"){
            $auth = $matches[1].Trim()
        }
        elseif($line -match "^\s*Encryption\s+:\s*(.*)$"){
            $encryption = $matches[1].Trim()
        }
        elseif($line -match "^\s*BSSID\s+\d+\s+:\s*(.*)$"){
            $bssid = $matches[1].Trim()
            $signal = ""
            $radio = ""
            $channel = ""
        }
        elseif($line -match "^\s*Signal\s+:\s*(.*)$"){
            $signal = $matches[1].Trim()
        }
        elseif($line -match "^\s*Radio type\s+:\s*(.*)$"){
            $radio = $matches[1].Trim()
        }
        elseif($line -match "^\s*Channel\s+:\s*(.*)$"){
            $channel = $matches[1].Trim()

            $results += [pscustomobject]@{
                SSID       = $ssid
                BSSID      = $bssid
                Signal     = $signal
                Channel    = $channel
                Radio      = $radio
                Auth       = $auth
                Encryption = $encryption
            }

        }

    }

    return $results

}

function Global:Invoke-WiFiStatus {

param([switch]$PassThru)

    Clear-Host

    Write-Host ""
    Write-Host "WI-FI STATUS" -ForegroundColor Cyan
    Write-Host "============" -ForegroundColor DarkCyan
    Write-Host ""

    $service = Get-CSIWiFiServiceState
    $interfaces = @(Get-CSIWiFiInterfaces)
    $results = @()

    $results += [pscustomobject]@{
        Area   = "Service"
        Name   = "WlanSvc"
        Status = $service.Status
        Detail = $service.Detail
    }

    if($interfaces.Count -eq 0){

        $results += [pscustomobject]@{
            Area   = "Interface"
            Name   = "Wireless"
            Status = "Not Available"
            Detail = "No active Wi-Fi interface was reported by netsh."
        }

    }
    else{

        foreach($interface in $interfaces){

            $issues = @()

            if($interface.State -ne "connected"){
                $issues += "Not connected"
            }

            if($interface.Signal -and ([int]($interface.Signal -replace "%","")) -lt 50){
                $issues += "Weak signal"
            }

            if($interface.ReceiveRateMbps -and [double]$interface.ReceiveRateMbps -lt 50){
                $issues += "Low receive rate"
            }

            $results += [pscustomobject]@{
                Area   = "Interface"
                Name   = $interface.Name
                Status = if($issues){"Warning"}else{"OK"}
                Detail = "State=$($interface.State) SSID=$($interface.SSID) Signal=$($interface.Signal) Radio=$($interface.Radiotype) Channel=$($interface.Channel) Rx=$($interface.ReceiveRateMbps) Tx=$($interface.TransmitRateMbps) Issues=$($issues -join ',')"
            }

        }

    }

    if($PassThru){
        return $results
    }

    $results | Format-Table -Wrap -AutoSize

}

function Global:Invoke-WiFiNetworks {

param([switch]$PassThru)

    Clear-Host

    Write-Host ""
    Write-Host "WI-FI NETWORKS" -ForegroundColor Cyan
    Write-Host "==============" -ForegroundColor DarkCyan
    Write-Host ""

    $service = Get-CSIWiFiServiceState

    if(!$service.Present -or $service.Status -ne "Running"){

        $result = [pscustomobject]@{
            Check  = "Wireless AutoConfig"
            Status = "Warning"
            Detail = "WlanSvc $($service.Status): $($service.Detail)"
        }

        if($PassThru){
            return @($result)
        }

        $result | Format-Table -Wrap -AutoSize
        return

    }

    $networks = @(Get-CSIWiFiNetworks)

    if($networks.Count -eq 0){

        Write-Host "No Wi-Fi networks found." -ForegroundColor Yellow
        return

    }

    $networks = $networks |
                Sort-Object SSID,Channel,BSSID

    if($PassThru){
        return $networks
    }

    $networks | Format-Table -AutoSize

}

function Global:Invoke-WiFiProfiles {

param([switch]$PassThru)

    Clear-Host

    Write-Host ""
    Write-Host "WI-FI PROFILES" -ForegroundColor Cyan
    Write-Host "===============" -ForegroundColor DarkCyan
    Write-Host ""

    $service = Get-CSIWiFiServiceState

    if(!$service.Present){

        Write-Host $service.Detail -ForegroundColor Yellow
        return

    }

    if($service.Status -ne "Running"){

        Write-Host "Wireless AutoConfig service is $($service.Status)." -ForegroundColor Yellow
        Write-Host $service.Detail
        return

    }

    $profileOutput = netsh wlan show profiles 2>&1

    if($LASTEXITCODE -ne 0){

        Write-Host ($profileOutput -join " ") -ForegroundColor Yellow
        return

    }

    $profileNames = $profileOutput |
                    Where-Object {$_ -match "All User Profile\s+:\s*(.*)$"} |
                    ForEach-Object {$matches[1].Trim()}

    $results = @()

    foreach($profile in $profileNames){

        $detail = netsh wlan show profile name="$profile" 2>&1
        $parsed = Convert-CSIWiFiKeyValue $detail

        $results += [pscustomobject]@{
            Name           = $profile
            ConnectionMode = $parsed.Connectionmode
            Authentication = $parsed.Authentication
            Cipher         = $parsed.Cipher
            Cost           = $parsed.Cost
            AutoSwitch     = $parsed.Autoswitch
        }

    }

    if($PassThru){
        return $results
    }

    if($results){
        $results | Format-Table -AutoSize
    }
    else{
        Write-Host "No saved Wi-Fi profiles found." -ForegroundColor Yellow
    }

}

function Global:Invoke-WiFiIssueScan {

param([switch]$PassThru)

    Clear-Host

    Write-Host ""
    Write-Host "WI-FI ISSUE SCAN" -ForegroundColor Cyan
    Write-Host "================" -ForegroundColor DarkCyan
    Write-Host ""

    $results = @()
    $service = Get-CSIWiFiServiceState

    $results += [pscustomobject]@{
        Check  = "Wireless AutoConfig"
        Status = if($service.Status -eq "Running"){"OK"}else{"Warning"}
        Detail = $service.Detail
    }

    $interfaces = @(Get-CSIWiFiInterfaces)

    if($interfaces.Count -eq 0){

        $results += [pscustomobject]@{
            Check  = "Wi-Fi Interface"
            Status = "Warning"
            Detail = "No active Wi-Fi interface found."
        }

    }

    foreach($interface in $interfaces){

        if($interface.State -ne "connected"){

            $results += [pscustomobject]@{
                Check  = "Connection State"
                Status = "Warning"
                Detail = "$($interface.Name) is $($interface.State)."
            }

        }

        if($interface.Signal){

            $signal = [int]($interface.Signal -replace "%","")

            $results += [pscustomobject]@{
                Check  = "Signal Strength"
                Status = if($signal -lt 50){"Warning"}else{"OK"}
                Detail = "$($interface.SSID) signal is $signal%."
            }

        }

        if($interface.Authentication -match "Open"){

            $results += [pscustomobject]@{
                Check  = "Security"
                Status = "Warning"
                Detail = "$($interface.SSID) is using open authentication."
            }

        }

    }

    $networks = @(Get-CSIWiFiNetworks)

    if($networks.Count -gt 0){

        $crowded = $networks |
                   Group-Object Channel |
                   Sort-Object Count -Descending |
                   Select-Object -First 3

        foreach($channel in $crowded){

            $results += [pscustomobject]@{
                Check  = "Channel Congestion"
                Status = if($channel.Count -gt 5){"Warning"}else{"Info"}
                Detail = "Channel $($channel.Name) has $($channel.Count) visible BSSID entries."
            }

        }

        $weak = $networks |
                Where-Object {$_.Signal -and ([int]($_.Signal -replace "%","")) -lt 35}

        if($weak){

            $results += [pscustomobject]@{
                Check  = "Weak Nearby Networks"
                Status = "Info"
                Detail = "$(@($weak).Count) visible networks are below 35% signal."
            }

        }

    }

    if($PassThru){
        return $results
    }

    $results | Format-Table -Wrap -AutoSize

}

Register-CSICommand `
    -Name "Wi-Fi Status" `
    -Command "Invoke-WiFiStatus" `
    -Category "Wi-Fi" `
    -Description "Show current Wi-Fi service and connection status" `
    -Order 60

Register-CSICommand `
    -Name "Wi-Fi Networks" `
    -Command "Invoke-WiFiNetworks" `
    -Category "Wi-Fi" `
    -Description "Show visible Wi-Fi networks, channels, radios, and signal" `
    -Order 62

Register-CSICommand `
    -Name "Wi-Fi Profiles" `
    -Command "Invoke-WiFiProfiles" `
    -Category "Wi-Fi" `
    -Description "Show saved Wi-Fi profile security and connection settings" `
    -Order 63

Register-CSICommand `
    -Name "Wi-Fi Issue Scan" `
    -Command "Invoke-WiFiIssueScan" `
    -Category "Wi-Fi" `
    -Description "Expose live Wi-Fi service, signal, security, and channel issues" `
    -Order 61
