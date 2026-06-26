function Global:Get-NTKWiFiServiceState {

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

function Global:Convert-NTKWiFiKeyValue {

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

function Global:Get-NTKWiFiInterfaces {

    $service = Get-NTKWiFiServiceState

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

    return $blocks | ForEach-Object { Convert-NTKWiFiKeyValue $_ }

}

function Global:Get-NTKWiFiNetworks {

    $service = Get-NTKWiFiServiceState

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

    $service = Get-NTKWiFiServiceState
    $interfaces = @(Get-NTKWiFiInterfaces)
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

    $service = Get-NTKWiFiServiceState

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

    $networks = @(Get-NTKWiFiNetworks)

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

    $service = Get-NTKWiFiServiceState

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
        $parsed = Convert-NTKWiFiKeyValue $detail

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

function Global:Get-NTKWiFiProfileStorePath {

param([string]$ComputerName = $env:COMPUTERNAME)

    $safeComputer = if($ComputerName){$ComputerName -replace '[^\w.-]','_'}else{'UnknownComputer'}

    if($script:NTKPaths -and $script:NTKPaths.Data){
        $root = Join-Path $script:NTKPaths.Data "WiFiProfiles"
    }
    elseif($global:NTKPaths -and $global:NTKPaths.Data){
        $root = Join-Path $global:NTKPaths.Data "WiFiProfiles"
    }
    else{
        $root = Join-Path $PSScriptRoot "WiFiProfiles"
    }

    return (Join-Path $root $safeComputer)

}

function Global:Export-NTKWiFiProfiles {

param(
    [string]$Destination,
    [switch]$PassThru
)

    $service = Get-NTKWiFiServiceState

    if(!$service.Present){
        throw $service.Detail
    }

    if($service.Status -ne "Running"){
        throw "Wireless AutoConfig service is $($service.Status). Start WlanSvc before exporting Wi-Fi profiles."
    }

    if(!$Destination){
        $Destination = Get-NTKWiFiProfileStorePath
    }

    New-Item -ItemType Directory -Force -Path $Destination | Out-Null

    $before = @(Get-ChildItem -LiteralPath $Destination -Filter "*.xml" -File -ErrorAction SilentlyContinue)
    $output = netsh wlan export profile key=clear folder="$Destination" 2>&1
    $exitCode = $LASTEXITCODE
    $after = @(Get-ChildItem -LiteralPath $Destination -Filter "*.xml" -File -ErrorAction SilentlyContinue)

    $result = [pscustomobject]@{
        Action      = "Export"
        Status      = if($exitCode -eq 0 -and $after.Count -gt 0){"Completed"}else{"Warning"}
        Destination = $Destination
        FilesBefore = $before.Count
        FilesAfter  = $after.Count
        ExitCode    = $exitCode
        Output      = ($output -join "`r`n")
        Sensitive   = "Exported XML may contain Wi-Fi keys in clear text."
    }

    if($PassThru){
        return $result
    }

    Write-Host ""
    Write-Host "WI-FI PROFILE EXPORT" -ForegroundColor Cyan
    Write-Host "====================" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "Destination: $Destination"
    Write-Host "Profiles exported: $($after.Count)"
    Write-Host "Warning: exported XML may contain Wi-Fi keys in clear text." -ForegroundColor Yellow
    Write-Host ""
    if($output){ $output | ForEach-Object { Write-Host $_ } }

}

function Global:Import-NTKWiFiProfiles {

param(
    [string]$Source,
    [switch]$PassThru
)

    $service = Get-NTKWiFiServiceState

    if(!$service.Present){
        throw $service.Detail
    }

    if($service.Status -ne "Running"){
        throw "Wireless AutoConfig service is $($service.Status). Start WlanSvc before importing Wi-Fi profiles."
    }

    if(!$Source){
        $Source = Get-NTKWiFiProfileStorePath
    }

    if(!(Test-Path -LiteralPath $Source)){
        throw "Wi-Fi profile source folder was not found: $Source"
    }

    $files = @(Get-ChildItem -LiteralPath $Source -Filter "*.xml" -File -ErrorAction SilentlyContinue)

    if($files.Count -eq 0){
        throw "No Wi-Fi profile XML files were found in: $Source"
    }

    $results = @()

    foreach($file in $files){

        $output = netsh wlan add profile filename="$($file.FullName)" user=all 2>&1
        $results += [pscustomobject]@{
            File     = $file.Name
            FullName = $file.FullName
            Status   = if($LASTEXITCODE -eq 0){"Imported"}else{"Failed"}
            ExitCode = $LASTEXITCODE
            Output   = ($output -join " ")
        }

    }

    if($PassThru){
        return $results
    }

    Write-Host ""
    Write-Host "WI-FI PROFILE IMPORT" -ForegroundColor Cyan
    Write-Host "====================" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "Source: $Source"
    Write-Host ""
    $results | Select-Object File,Status,ExitCode,Output | Format-Table -Wrap -AutoSize

}

function Global:Invoke-WiFiProfileBackupRestore {

param([switch]$PassThru)

    Clear-Host

    Write-Host ""
    Write-Host "WI-FI PROFILE BACKUP / RESTORE" -ForegroundColor Cyan
    Write-Host "==============================" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "This consolidates Wi-Fi profile export and import into one portable workflow."
    Write-Host "Default profile store: $(Get-NTKWiFiProfileStorePath)"
    Write-Host "Security note: exported XML may contain saved Wi-Fi keys in clear text." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Export saved Wi-Fi profiles from this computer"
    Write-Host "2. Import saved Wi-Fi profiles into this computer"
    Write-Host "3. Open Wi-Fi profile backup folder"
    Write-Host ""

    $choice = Read-NTKInput "Select Wi-Fi profile task"

    switch($choice){
        "1" {
            $default = Get-NTKWiFiProfileStorePath
            $destination = Read-NTKInput "Export folder, blank for default [$default]" -AllowEmpty
            if([string]::IsNullOrWhiteSpace($destination)){ $destination = $default }
            $result = Export-NTKWiFiProfiles -Destination $destination -PassThru
            Write-Host ""
            Write-Host "Exported $($result.FilesAfter) profile XML file(s) to: $($result.Destination)" -ForegroundColor Green
            Write-Host "Keep this folder protected. It may contain Wi-Fi passwords." -ForegroundColor Yellow
            if($PassThru){ return $result }
        }
        "2" {
            $default = Get-NTKWiFiProfileStorePath
            $source = Read-NTKInput "Import folder, blank for default [$default]" -AllowEmpty
            if([string]::IsNullOrWhiteSpace($source)){ $source = $default }
            $results = @(Import-NTKWiFiProfiles -Source $source -PassThru)
            Write-Host ""
            $results | Select-Object File,Status,ExitCode,Output | Format-Table -Wrap -AutoSize
            if($PassThru){ return $results }
        }
        "3" {
            $folder = Get-NTKWiFiProfileStorePath
            New-Item -ItemType Directory -Force -Path $folder | Out-Null
            Start-Process explorer.exe -ArgumentList "`"$folder`""
            Write-Host "Opened: $folder"
        }
        default {
            Write-Host "Invalid selection." -ForegroundColor Red
        }
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
    $service = Get-NTKWiFiServiceState

    $results += [pscustomobject]@{
        Check  = "Wireless AutoConfig"
        Status = if($service.Status -eq "Running"){"OK"}else{"Warning"}
        Detail = $service.Detail
    }

    $interfaces = @(Get-NTKWiFiInterfaces)

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

    $networks = @(Get-NTKWiFiNetworks)

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

function Global:Invoke-WiFiDiagnostics {

    while($true){

        Clear-Host

        Write-Host ""
        Write-Host "WI-FI DIAGNOSTICS" -ForegroundColor Cyan
        Write-Host "=================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "1. Wi-Fi Issue Scan"
        Write-Host "2. Wi-Fi Status"
        Write-Host "3. Visible Wi-Fi Networks"
        Write-Host "4. Saved Wi-Fi Profiles"
        Write-Host "5. Backup / Restore Wi-Fi Profiles"
        Write-Host ""

        $choice = Read-NTKInput "Select Wi-Fi task"

        switch($choice){
            "1" { Invoke-WiFiIssueScan }
            "2" { Invoke-WiFiStatus }
            "3" { Invoke-WiFiNetworks }
            "4" { Invoke-WiFiProfiles }
            "5" { Invoke-WiFiProfileBackupRestore }
            default { Write-Host "Invalid selection." -ForegroundColor Red }
        }

        Write-Host ""
        [void](Read-NTKInput "Press ENTER to continue" -AllowEmpty)

    }

}

Register-NTKCommand `
    -Name "Wi-Fi Diagnostics" `
    -Command "Invoke-WiFiDiagnostics" `
    -Category "Wi-Fi" `
    -Description "Signal, service, channel, visible network, and saved profile diagnostics" `
    -Order 60

Register-NTKCommand `
    -Name "Wi-Fi Profile Backup / Restore" `
    -Command "Invoke-WiFiProfileBackupRestore" `
    -Category "Wi-Fi" `
    -Description "Export or import saved Wi-Fi profiles from the toolkit data store" `
    -Order 61
