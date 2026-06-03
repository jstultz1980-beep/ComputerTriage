function Global:Get-CSIFingerprintPath {

    $path = Join-Path $CSIPaths.Data "Fingerprints"

    if(!(Test-Path $path)){
        New-Item -ItemType Directory -Path $path | Out-Null
    }

    return $path

}

function Global:ConvertTo-CSISafeFileName {

param([string]$Name)

    $invalid = [IO.Path]::GetInvalidFileNameChars()
    $safe = $Name

    foreach($char in $invalid){
        $safe = $safe.Replace($char,"_")
    }

    return $safe

}

function Global:Get-CSIPendingRebootState {

    $checks = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired",
        "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager"
    )

    $pending = $false
    $details = @()

    foreach($check in $checks){

        if(Test-Path $check){

            if($check -like "*Session Manager"){

                $value = Get-ItemProperty -Path $check -Name PendingFileRenameOperations -ErrorAction SilentlyContinue

                if($value.PendingFileRenameOperations){
                    $pending = $true
                    $details += "PendingFileRenameOperations"
                }

            }
            else{

                $pending = $true
                $details += $check

            }

        }

    }

    return [pscustomobject]@{
        Pending = $pending
        Details = $details
    }

}

function Global:Get-CSIComputerFingerprint {

    $os = Get-CimInstance Win32_OperatingSystem
    $system = Get-CimInstance Win32_ComputerSystem
    $bios = Get-CimInstance Win32_BIOS
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
             Select-Object DeviceID,VolumeName,
                           @{Name="SizeGB";Expression={[math]::Round($_.Size / 1GB,2)}},
                           @{Name="FreeGB";Expression={[math]::Round($_.FreeSpace / 1GB,2)}}

    $adapters = @()

    if(Get-Command Get-NetIPConfiguration -ErrorAction SilentlyContinue){

        $adapters = Get-NetIPConfiguration |
                    Where-Object {$_.IPv4Address -or $_.IPv6Address} |
                    ForEach-Object {

                        [pscustomobject]@{
                            Interface = $_.InterfaceAlias
                            IPv4      = if($_.IPv4Address){$_.IPv4Address.IPAddress -join ","}else{""}
                            IPv6      = if($_.IPv6Address){$_.IPv6Address.IPAddress -join ","}else{""}
                            Gateway   = if($_.IPv4DefaultGateway){$_.IPv4DefaultGateway.NextHop}else{""}
                            DNS       = if($_.DNSServer){$_.DNSServer.ServerAddresses -join ","}else{""}
                        }

                    }

    }

    $macs = @()

    if(Get-Command Get-NetAdapter -ErrorAction SilentlyContinue){

        $macs = Get-NetAdapter |
                Select-Object Name,Status,MacAddress,LinkSpeed,InterfaceDescription

    }

    $firewallProfiles = @()

    if(Get-Command Get-NetFirewallProfile -ErrorAction SilentlyContinue){

        $firewallProfiles = Get-NetFirewallProfile |
                            Select-Object Name,Enabled,DefaultInboundAction,DefaultOutboundAction

    }

    $listeningPorts = @()

    if(Get-Command Get-NetTCPConnection -ErrorAction SilentlyContinue){

        $listeningPorts = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
                          Select-Object -First 100 |
                          ForEach-Object {

                              $processName = ""

                              try {
                                  $processName = (Get-Process -Id $_.OwningProcess -ErrorAction Stop).ProcessName
                              }
                              catch {}

                              [pscustomobject]@{
                                  LocalAddress = $_.LocalAddress
                                  LocalPort    = $_.LocalPort
                                  ProcessId    = $_.OwningProcess
                                  ProcessName  = $processName
                              }

                          }

    }

    $securityProducts = @()

    try {

        $securityProducts = Get-CimInstance -Namespace root\SecurityCenter2 -ClassName AntiVirusProduct -ErrorAction Stop |
                            Select-Object displayName,pathToSignedProductExe,productState

    }
    catch {}

    $defender = $null

    if(Get-Command Get-MpComputerStatus -ErrorAction SilentlyContinue){

        try {

            $defender = Get-MpComputerStatus |
                        Select-Object AMServiceEnabled,AntivirusEnabled,RealTimeProtectionEnabled,
                                      AntispywareEnabled,NISEnabled,AntivirusSignatureLastUpdated

        }
        catch {}

    }

    $bitLocker = @()

    if(Get-Command Get-BitLockerVolume -ErrorAction SilentlyContinue){

        try {

            $bitLocker = Get-BitLockerVolume |
                         Select-Object MountPoint,VolumeStatus,ProtectionStatus,EncryptionPercentage

        }
        catch {}

    }

    $localAdmins = @()

    if(Get-Command Get-LocalGroupMember -ErrorAction SilentlyContinue){

        try {

            $localAdmins = Get-LocalGroupMember -Group "Administrators" |
                           Select-Object Name,ObjectClass,PrincipalSource

        }
        catch {}

    }

    $timeSource = ""

    if(Get-Command w32tm -ErrorAction SilentlyContinue){
        $timeSource = (w32tm /query /source 2>&1) -join " "
    }

    $pendingReboot = Get-CSIPendingRebootState

    if($os.LastBootUpTime -is [datetime]){
        $lastBoot = $os.LastBootUpTime
    }
    else{
        $lastBoot = [Management.ManagementDateTimeConverter]::ToDateTime($os.LastBootUpTime)
    }

    $uptime = New-TimeSpan -Start $lastBoot -End (Get-Date)

    return [pscustomobject]@{
        CapturedAt       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        ComputerName     = $env:COMPUTERNAME
        UserName         = "$env:USERDOMAIN\$env:USERNAME"
        Domain           = $system.Domain
        Manufacturer     = $system.Manufacturer
        Model            = $system.Model
        SerialNumber     = $bios.SerialNumber
        BIOSVersion      = ($bios.SMBIOSBIOSVersion -join ",")
        OS               = $os.Caption
        OSVersion        = $os.Version
        OSBuild          = $os.BuildNumber
        LastBoot         = $lastBoot
        UptimeDays       = [math]::Round($uptime.TotalDays,2)
        CPU              = $cpu.Name
        Cores            = $cpu.NumberOfCores
        LogicalProcessors = $cpu.NumberOfLogicalProcessors
        MemoryGB         = [math]::Round($system.TotalPhysicalMemory / 1GB,2)
        PowerShell       = $PSVersionTable.PSVersion.ToString()
        PendingReboot    = $pendingReboot
        Disks            = $disks
        NetworkAdapters  = $adapters
        MACAddresses     = $macs
        FirewallProfiles = $firewallProfiles
        ListeningPorts   = $listeningPorts
        SecurityProducts = $securityProducts
        Defender         = $defender
        BitLocker        = $bitLocker
        LocalAdmins      = $localAdmins
        TimeSource       = $timeSource.Trim()
    }

}

function Global:Show-CSIComputerFingerprintSummary {

param([object]$Fingerprint)

    Write-Host ""
    Write-Host "Computer:" $Fingerprint.ComputerName
    Write-Host "Captured:" $Fingerprint.CapturedAt
    Write-Host "User:" $Fingerprint.UserName
    Write-Host "Domain:" $Fingerprint.Domain
    Write-Host "Model:" $Fingerprint.Manufacturer $Fingerprint.Model
    Write-Host "Serial:" $Fingerprint.SerialNumber
    Write-Host "OS:" $Fingerprint.OS $Fingerprint.OSVersion "Build" $Fingerprint.OSBuild
    Write-Host "Uptime Days:" $Fingerprint.UptimeDays
    Write-Host "CPU:" $Fingerprint.CPU
    Write-Host "Memory GB:" $Fingerprint.MemoryGB
    Write-Host "Pending Reboot:" $Fingerprint.PendingReboot.Pending
    Write-Host ""

    Write-Host "Network Adapters"
    Write-Host "----------------"
    $Fingerprint.NetworkAdapters | Format-Table -AutoSize

    Write-Host ""
    Write-Host "Disks"
    Write-Host "-----"
    $Fingerprint.Disks | Format-Table -AutoSize

    Write-Host ""
    Write-Host "Firewall Profiles"
    Write-Host "-----------------"
    $Fingerprint.FirewallProfiles | Format-Table -AutoSize

}

function Global:Invoke-TakeComputerFingerprint {

param([switch]$PassThru)

    Clear-Host

    Write-Host ""
    Write-Host "TAKE COMPUTER FINGERPRINT" -ForegroundColor Cyan
    Write-Host "=========================" -ForegroundColor DarkCyan
    Write-Host ""

    $fingerprint = Get-CSIComputerFingerprint
    $root = Get-CSIFingerprintPath
    $safeName = ConvertTo-CSISafeFileName $fingerprint.ComputerName
    $file = Join-Path $root "$safeName.json"

    $fingerprint |
        ConvertTo-Json -Depth 8 |
        Set-Content -Path $file -Encoding UTF8

    Show-CSIComputerFingerprintSummary $fingerprint

    Write-Host ""
    Write-Host "Fingerprint saved:" $file -ForegroundColor Green

    if($PassThru){
        return $fingerprint
    }

}

function Global:Get-CSIStoredFingerprints {

    $root = Get-CSIFingerprintPath

    return Get-ChildItem -Path $root -Filter "*.json" -File -ErrorAction SilentlyContinue |
           ForEach-Object {

               try {

                   $data = Get-Content -Raw -Path $_.FullName | ConvertFrom-Json

                   [pscustomobject]@{
                       ComputerName = $data.ComputerName
                       CapturedAt   = $data.CapturedAt
                       UserName     = $data.UserName
                       Domain       = $data.Domain
                       Path         = $_.FullName
                   }

               }
               catch {

                   [pscustomobject]@{
                       ComputerName = $_.BaseName
                       CapturedAt   = "Unreadable"
                       UserName     = ""
                       Domain       = ""
                       Path         = $_.FullName
                   }

               }

           } |
           Sort-Object ComputerName

}

function Global:Invoke-ComputerFingerprintSelector {

    Clear-Host

    Write-Host ""
    Write-Host "COMPUTER FINGERPRINT SELECTOR" -ForegroundColor Cyan
    Write-Host "=============================" -ForegroundColor DarkCyan
    Write-Host ""

    $fingerprints = @(Get-CSIStoredFingerprints)

    if($fingerprints.Count -eq 0){

        Write-Host "No computer fingerprints found." -ForegroundColor Yellow
        Write-Host "Use option 2 to take a computer fingerprint."
        return

    }

    for($i = 0; $i -lt $fingerprints.Count; $i++){

        $item = $fingerprints[$i]

        Write-Host ("{0}. {1}  {2}  {3}" -f ($i + 1),$item.ComputerName,$item.CapturedAt,$item.UserName)

    }

    Write-Host ""

    $choice = Read-CSIInput "Select computer fingerprint"

    if(-not ($choice -as [int])){
        Write-Host "Invalid selection." -ForegroundColor Red
        return
    }

    $index = [int]$choice

    if($index -lt 1 -or $index -gt $fingerprints.Count){
        Write-Host "Invalid selection." -ForegroundColor Red
        return
    }

    $selected = $fingerprints[$index - 1]

    Write-Host ""
    Write-Host "Selected:" $selected.ComputerName
    Write-Host ""

    $action = Read-CSIInput "Open or Delete"

    if($action -match "^(o|open)$"){

        if(Test-Path $selected.Path){

            Write-Host "Opening:" $selected.Path -ForegroundColor Green
            Start-Process notepad.exe -ArgumentList "`"$($selected.Path)`"" | Out-Null

        }
        else{
            Write-Host "Fingerprint file missing." -ForegroundColor Red
        }

    }
    elseif($action -match "^(d|delete)$"){

        if(Test-Path $selected.Path){

            Remove-Item -Path $selected.Path -Force
            Write-Host "Deleted:" $selected.ComputerName -ForegroundColor Yellow

        }
        else{
            Write-Host "Fingerprint file missing." -ForegroundColor Red
        }

    }
    else{

        Write-Host "Action not recognized. Use Open or Delete." -ForegroundColor Red

    }

}

Register-CSICommand `
    -Name "Take Computer Fingerprint" `
    -Command "Invoke-TakeComputerFingerprint" `
    -Category "Fingerprint" `
    -Description "Capture this computer's live system and network fingerprint" `
    -Order 2 `
    -RequiresAdmin

Register-CSICommand `
    -Name "Computer Fingerprint Selector" `
    -Command "Invoke-ComputerFingerprintSelector" `
    -Category "Fingerprint" `
    -Description "Open or delete saved computer fingerprints" `
    -Order 3
