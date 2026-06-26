function Global:Write-NTKSection {

param([string]$Title)

    Write-Host ""
    Write-Host $Title -ForegroundColor Cyan
    Write-Host ("-" * $Title.Length) -ForegroundColor DarkCyan

}

function Global:Invoke-EventLogTriage {

param([int]$Hours = 24)

    Clear-Host
    Write-NTKSection "EVENT LOG TRIAGE"

    $start = (Get-Date).AddHours(-1 * $Hours)
    $logs = "System","Application","Setup"
    $events = @()

    foreach($log in $logs){

        try {
            $events += Get-WinEvent -FilterHashtable @{LogName=$log; Level=1,2; StartTime=$start} -MaxEvents 40 -ErrorAction Stop |
                       Select-Object TimeCreated,LogName,ProviderName,Id,LevelDisplayName,Message
        }
        catch {
            Write-Host "Unable to read $log log: $($_.Exception.Message)" -ForegroundColor Yellow
        }

    }

    if(!$events){
        Write-Host "No critical or error events found in the last $Hours hours." -ForegroundColor Green
        return
    }

    $events |
        Sort-Object TimeCreated -Descending |
        Select-Object -First 60 TimeCreated,LogName,ProviderName,Id,LevelDisplayName,
            @{Name="Message";Expression={
                $message = [string]$_.Message -replace "\s+"," "
                $message.Substring(0,[math]::Min(140,$message.Length))
            }} |
        Format-Table -Wrap -AutoSize

}

function Global:Invoke-ServiceHealth {

    Clear-Host
    Write-NTKSection "SERVICE HEALTH"

    $services = Get-CimInstance Win32_Service |
                Where-Object {$_.StartMode -eq "Auto" -and $_.State -ne "Running"} |
                Select-Object Name,DisplayName,State,StartMode,StartName

    if(!$services){
        Write-Host "No stopped automatic services found." -ForegroundColor Green
        return
    }

    $services | Format-Table -Wrap -AutoSize

}

function Global:Invoke-StartupImpact {

    Clear-Host
    Write-NTKSection "STARTUP IMPACT"

    Write-Host "Startup Commands"
    Write-Host "----------------"

    try {
        Get-CimInstance Win32_StartupCommand |
            Select-Object Name,Location,Command |
            Format-Table -Wrap -AutoSize
    }
    catch {
        Write-Host "Unable to read startup commands." -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Recently Failed Scheduled Tasks"
    Write-Host "-------------------------------"

    if(Get-Command Get-ScheduledTask -ErrorAction SilentlyContinue){

        $tasks = Get-ScheduledTask |
                 Where-Object {$_.State -ne "Disabled"} |
                 ForEach-Object {
                     try {
                         $info = Get-ScheduledTaskInfo -TaskName $_.TaskName -TaskPath $_.TaskPath
                         if($info.LastTaskResult -ne 0){
                             [pscustomobject]@{
                                 Task = "$($_.TaskPath)$($_.TaskName)"
                                 State = $_.State
                                 LastRun = $info.LastRunTime
                                 Result = $info.LastTaskResult
                             }
                         }
                     }
                     catch {}
                 }

        if($tasks){
            $tasks | Sort-Object LastRun -Descending | Select-Object -First 40 | Format-Table -Wrap -AutoSize
        }
        else{
            Write-Host "No failed scheduled tasks found." -ForegroundColor Green
        }

    }
    else{
        Write-Host "Scheduled task cmdlets are not available." -ForegroundColor Yellow
    }

}

function Global:Invoke-DiskHealth {

    Clear-Host
    Write-NTKSection "DISK HEALTH"

    Write-Host "Volumes"
    Write-Host "-------"

    Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
        Select-Object DeviceID,VolumeName,
            @{Name="SizeGB";Expression={[math]::Round($_.Size / 1GB,1)}},
            @{Name="FreeGB";Expression={[math]::Round($_.FreeSpace / 1GB,1)}},
            @{Name="FreePct";Expression={if($_.Size){[math]::Round(($_.FreeSpace / $_.Size) * 100,1)}else{0}}} |
        Format-Table -AutoSize

    Write-Host ""
    Write-Host "Physical Disks"
    Write-Host "--------------"

    if(Get-Command Get-PhysicalDisk -ErrorAction SilentlyContinue){
        Get-PhysicalDisk |
            Select-Object FriendlyName,MediaType,HealthStatus,OperationalStatus,Size |
            Format-Table -AutoSize
    }
    else{
        Write-Host "Get-PhysicalDisk is not available." -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Recent Disk Errors"
    Write-Host "------------------"

    try {
        $events = Get-WinEvent -FilterHashtable @{LogName="System"; ProviderName="disk"; Level=1,2,3; StartTime=(Get-Date).AddDays(-7)} -MaxEvents 20 -ErrorAction Stop
        $events | Select-Object TimeCreated,Id,ProviderName,Message | Format-Table -Wrap -AutoSize
    }
    catch {
        Write-Host "No recent disk provider errors found." -ForegroundColor Green
    }

}

function Global:Add-NTKHardwareFinding {

param(
    [ref]$Findings,
    [string]$Area,
    [string]$Status,
    [string]$Name,
    [string]$Detail,
    [string]$Recommendation
)

    $finding = [pscustomobject]@{
        Area           = $Area
        Status         = $Status
        Name           = $Name
        Detail         = $Detail
        Recommendation = $Recommendation
    }

    $Findings.Value = @($Findings.Value) + $finding
    return

}

function Global:Get-NTKHardwareDeviceProblems {

    $problems = @()

    if(Get-Command Get-PnpDevice -ErrorAction SilentlyContinue){

        try {

            $problems = @(
                Get-PnpDevice -PresentOnly -ErrorAction Stop |
                    Where-Object { $_.Status -notin @("OK","Unknown") } |
                    Select-Object Status,Class,FriendlyName,InstanceId,Problem
            )

        }
        catch {}

    }

    if(!$problems -or $problems.Count -eq 0){

        try {

            $problems = @(
                Get-CimInstance Win32_PnPEntity -ErrorAction Stop |
                    Where-Object { $_.ConfigManagerErrorCode -and $_.ConfigManagerErrorCode -ne 0 } |
                    Select-Object `
                        @{Name="Status";Expression={"Problem"}},
                        PNPClass,
                        Name,
                        DeviceID,
                        ConfigManagerErrorCode
            )

        }
        catch {}

    }

    return $problems

}

function Global:Invoke-HardwareHealthDiagnostics {

param([switch]$PassThru)

    Clear-Host
    Write-NTKSection "HARDWARE HEALTH DIAGNOSTICS"

    $findings = @()

    Write-Host "Device Manager Problem Devices"
    Write-Host "------------------------------"

    $deviceProblems = @(Get-NTKHardwareDeviceProblems)

    if($deviceProblems.Count -gt 0){

        $deviceProblems |
            Select-Object -First 50 |
            Format-Table -Wrap -AutoSize |
            Out-Host

        foreach($device in $deviceProblems){

            $name = if($device.FriendlyName){$device.FriendlyName}elseif($device.Name){$device.Name}else{$device.InstanceId}
            $code = if($device.Problem){$device.Problem}elseif($device.ConfigManagerErrorCode){"Code $($device.ConfigManagerErrorCode)"}else{$device.Status}

            Add-NTKHardwareFinding ([ref]$findings) `
                -Area "Device Manager" `
                -Status "Warning" `
                -Name $name `
                -Detail "Device status: $($device.Status). Problem: $code" `
                -Recommendation "Open Device Manager, review this device, reinstall/update the driver, check cabling/slot/firmware, or remove stale hardware if it is no longer present."

        }

    }
    else{

        Write-Host "No present Device Manager problem devices found." -ForegroundColor Green

        Add-NTKHardwareFinding ([ref]$findings) `
            -Area "Device Manager" `
            -Status "OK" `
            -Name "Present devices" `
            -Detail "No present devices reported a problem state." `
            -Recommendation "No action needed unless the user reports missing hardware."

    }

    Write-Host ""
    Write-Host "Physical Disk Health"
    Write-Host "--------------------"

    $physicalDiskFound = $false

    if(Get-Command Get-PhysicalDisk -ErrorAction SilentlyContinue){

        try {

            $physicalDisks = @(Get-PhysicalDisk -ErrorAction Stop)
            $physicalDiskFound = $true

            if($physicalDisks){

                $physicalDisks |
                    Select-Object FriendlyName,MediaType,HealthStatus,OperationalStatus,BusType,
                        @{Name="SizeGB";Expression={[math]::Round($_.Size / 1GB,1)}} |
                    Format-Table -AutoSize |
                    Out-Host

                foreach($disk in $physicalDisks){

                    $status = if($disk.HealthStatus -eq "Healthy" -and ($disk.OperationalStatus -contains "OK")){ "OK" } else { "Warning" }

                    Add-NTKHardwareFinding ([ref]$findings) `
                        -Area "Storage" `
                        -Status $status `
                        -Name $disk.FriendlyName `
                        -Detail "Health: $($disk.HealthStatus). Operational: $($disk.OperationalStatus -join ', '). Bus: $($disk.BusType)." `
                        -Recommendation $(if($status -eq "OK"){"No action needed."}else{"Back up data immediately, check vendor diagnostics/SMART, inspect cabling, and plan disk replacement if health is not Healthy."})

                }

            }

        }
        catch {
            Write-Host "Unable to read Get-PhysicalDisk: $($_.Exception.Message)" -ForegroundColor Yellow
        }

    }

    try {

        $diskDrives = @(Get-CimInstance Win32_DiskDrive -ErrorAction Stop)

        if($diskDrives){

            if(!$physicalDiskFound){
                $diskDrives |
                    Select-Object Model,InterfaceType,Status,
                        @{Name="SizeGB";Expression={[math]::Round($_.Size / 1GB,1)}} |
                    Format-Table -AutoSize |
                    Out-Host
            }

            foreach($drive in $diskDrives){

                if($drive.Status -and $drive.Status -ne "OK"){

                    Add-NTKHardwareFinding ([ref]$findings) `
                        -Area "Storage" `
                        -Status "Warning" `
                        -Name $drive.Model `
                        -Detail "Win32_DiskDrive status: $($drive.Status). Interface: $($drive.InterfaceType)." `
                        -Recommendation "Run vendor disk diagnostics, check SMART/CrystalDiskInfo, verify cabling/controller health, and make sure backups are current."

                }

            }

        }

    }
    catch {
        Write-Host "Unable to read Win32_DiskDrive." -ForegroundColor Yellow
    }

    try {

        $smartStatuses = @(Get-CimInstance -Namespace root\wmi -ClassName MSStorageDriver_FailurePredictStatus -ErrorAction Stop)

        foreach($smart in $smartStatuses){

            if($smart.PredictFailure){

                Add-NTKHardwareFinding ([ref]$findings) `
                    -Area "Storage" `
                    -Status "Critical" `
                    -Name $smart.InstanceName `
                    -Detail "Windows storage driver predicts disk failure." `
                    -Recommendation "Back up data immediately and replace the disk. Confirm with vendor diagnostics if needed, but treat this as urgent."

            }

        }

        if($smartStatuses.Count -gt 0 -and -not ($smartStatuses | Where-Object {$_.PredictFailure})){
            Write-Host "No storage-driver predicted disk failures reported." -ForegroundColor Green
        }

    }
    catch {
        Write-Host "SMART failure prediction data was not available from root\\wmi." -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Battery Health"
    Write-Host "--------------"

    try {

        $batteries = @(Get-CimInstance Win32_Battery -ErrorAction Stop)

        if($batteries){

            $batteries |
                Select-Object Name,BatteryStatus,EstimatedChargeRemaining,EstimatedRunTime,Status |
                Format-Table -AutoSize |
                Out-Host

            foreach($battery in $batteries){

                $status = "OK"
                $recommendation = "Battery is present. Compare charge/runtime against user symptoms."

                if($battery.Status -and $battery.Status -ne "OK"){
                    $status = "Warning"
                    $recommendation = "Check battery health in OEM diagnostics, inspect charger/USB-C dock, and update BIOS/firmware."
                }

                Add-NTKHardwareFinding ([ref]$findings) `
                    -Area "Battery" `
                    -Status $status `
                    -Name $battery.Name `
                    -Detail "Status: $($battery.Status). Charge: $($battery.EstimatedChargeRemaining)%. Runtime: $($battery.EstimatedRunTime)." `
                    -Recommendation $recommendation

            }

        }
        else{
            Write-Host "No battery detected. This is expected for most desktops and servers." -ForegroundColor Gray
        }

    }
    catch {
        Write-Host "Unable to read battery information." -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Memory Inventory"
    Write-Host "----------------"

    try {

        $memory = @(Get-CimInstance Win32_PhysicalMemory -ErrorAction Stop)

        if($memory){

            $memory |
                Select-Object BankLabel,Manufacturer,PartNumber,SerialNumber,
                    @{Name="CapacityGB";Expression={[math]::Round($_.Capacity / 1GB,2)}},
                    Speed |
                Format-Table -AutoSize |
                Out-Host

            $emptySerials = @($memory | Where-Object { !$_.SerialNumber -or $_.SerialNumber -match "^(0+|Unknown|None)$" })

            if($emptySerials.Count -gt 0){

                Add-NTKHardwareFinding ([ref]$findings) `
                    -Area "Memory" `
                    -Status "Info" `
                    -Name "Memory module serials" `
                    -Detail "$($emptySerials.Count) memory module(s) have blank or generic serial data." `
                    -Recommendation "This can be normal on some systems/VMs. If memory issues are suspected, run Windows Memory Diagnostic or vendor diagnostics."

            }

        }

    }
    catch {
        Write-Host "Unable to read physical memory inventory." -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Recent Hardware And Driver Events"
    Write-Host "---------------------------------"

    $hardwareEvents = @()
    $providers = @(
        "Microsoft-Windows-WHEA-Logger",
        "Microsoft-Windows-Kernel-PnP",
        "Microsoft-Windows-DriverFrameworks-UserMode",
        "disk",
        "storahci",
        "stornvme",
        "iaStorA",
        "iaStorAC"
    )

    foreach($provider in $providers){

        try {
            $hardwareEvents += Get-WinEvent -FilterHashtable @{LogName="System"; ProviderName=$provider; Level=1,2,3; StartTime=(Get-Date).AddDays(-14)} -MaxEvents 20 -ErrorAction Stop
        }
        catch {}

    }

    if($hardwareEvents){

        $hardwareEvents |
            Sort-Object TimeCreated -Descending |
            Select-Object -First 40 TimeCreated,ProviderName,Id,LevelDisplayName,
                @{Name="Message";Expression={
                    $message = [string]$_.Message -replace "\s+"," "
                    $message.Substring(0,[math]::Min(170,$message.Length))
                }} |
            Format-Table -Wrap -AutoSize |
            Out-Host

        $eventGroups = $hardwareEvents | Group-Object ProviderName

        foreach($group in $eventGroups){

            $status = if($group.Name -eq "Microsoft-Windows-WHEA-Logger"){ "Critical" } else { "Warning" }

            Add-NTKHardwareFinding ([ref]$findings) `
                -Area "Hardware Events" `
                -Status $status `
                -Name $group.Name `
                -Detail "$($group.Count) warning/error/critical event(s) in the last 14 days." `
                -Recommendation "Review newest events in Event Viewer. For WHEA or storage events, update BIOS/firmware/drivers and run vendor diagnostics."

        }

    }
    else{
        Write-Host "No recent hardware/driver warning, error, or critical events found from common providers." -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "Summary"
    Write-Host "-------"

    $issueFindings = @($findings | Where-Object { $_.Status -in "Warning","Critical" })

    if($issueFindings.Count -eq 0){
        Write-Host "No obvious hardware problems were found by Windows-visible checks." -ForegroundColor Green
    }
    else{
        $issueFindings | Format-Table Area,Status,Name,Detail -Wrap -AutoSize | Out-Host
    }

    Write-Host ""
    Write-Host "Suggested next steps:" -ForegroundColor Yellow
    Write-Host "- If Device Manager reports a problem, inspect that device first."
    Write-Host "- For suspected disk issues, use CrystalDiskInfo or vendor storage diagnostics."
    Write-Host "- For WHEA events, update BIOS/firmware/chipset/storage drivers and run OEM diagnostics."
    Write-Host "- For memory symptoms, run Windows Memory Diagnostic or OEM preboot diagnostics."

    if($PassThru){
        return $findings
    }

}

function Global:Invoke-WindowsUpdateHealth {

    Clear-Host
    Write-NTKSection "WINDOWS UPDATE HEALTH"

    $services = "wuauserv","bits","cryptsvc","msiserver"

    Get-Service -Name $services -ErrorAction SilentlyContinue |
        Select-Object Name,Status,StartType |
        Format-Table -AutoSize

    Write-Host ""
    Write-Host "Pending Reboot"
    Write-Host "--------------"

    $pendingKeys = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
    )

    $found = $false

    foreach($path in $pendingKeys){
        if(Test-Path $path){
            Write-Host $path -ForegroundColor Yellow
            $found = $true
        }
    }

    try {
        $sessionManager = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -ErrorAction Stop
        if($sessionManager.PendingFileRenameOperations){
            Write-Host "PendingFileRenameOperations" -ForegroundColor Yellow
            $found = $true
        }
    }
    catch {}

    if(!$found){
        Write-Host "No common pending reboot markers found." -ForegroundColor Green
    }

}

function Global:Invoke-DefenderSecurityCheck {

    Clear-Host
    Write-NTKSection "DEFENDER SECURITY CHECK"

    if(Get-Command Get-MpComputerStatus -ErrorAction SilentlyContinue){
        Get-MpComputerStatus |
            Select-Object AMServiceEnabled,AntivirusEnabled,RealTimeProtectionEnabled,IoavProtectionEnabled,
                AntispywareSignatureLastUpdated,AntivirusSignatureLastUpdated,QuickScanAge,FullScanAge |
            Format-List
    }
    else{
        Write-Host "Defender cmdlets are not available." -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Firewall Profiles"
    Write-Host "-----------------"

    if(Get-Command Get-NetFirewallProfile -ErrorAction SilentlyContinue){
        Get-NetFirewallProfile | Select-Object Name,Enabled,DefaultInboundAction,DefaultOutboundAction | Format-Table -AutoSize
    }

}

function Global:Invoke-ResourceHotspots {

    Clear-Host
    Write-NTKSection "RESOURCE HOTSPOTS"

    Write-Host "Top CPU"
    Write-Host "-------"
    Get-Process |
        Sort-Object CPU -Descending |
        Select-Object -First 10 ProcessName,Id,
            @{Name="CPU";Expression={[math]::Round([double]$_.CPU,1)}},
            @{Name="MemoryMB";Expression={[math]::Round($_.WorkingSet / 1MB,1)}} |
        Format-Table -AutoSize

    Write-Host ""
    Write-Host "Top Memory"
    Write-Host "----------"
    Get-Process |
        Sort-Object WorkingSet -Descending |
        Select-Object -First 10 ProcessName,Id,@{Name="MemoryMB";Expression={[math]::Round($_.WorkingSet / 1MB,1)}} |
        Format-Table -AutoSize

}

function Global:Invoke-DomainLogonHealth {

    Clear-Host
    Write-NTKSection "DOMAIN LOGON HEALTH"

    try {
        $computer = Get-CimInstance Win32_ComputerSystem
        $computer | Select-Object Name,Domain,PartOfDomain,UserName | Format-List
    }
    catch {
        Write-Host "Unable to read computer domain information." -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Secure Channel"
    Write-Host "--------------"

    try {
        Test-ComputerSecureChannel -Verbose
    }
    catch {
        Write-Host $_.Exception.Message -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Domain Controller"
    Write-Host "-----------------"
    cmd.exe /c "nltest /dsgetdc:%USERDNSDOMAIN%" 2>&1

}

function Global:Invoke-GPOHealth {

    Clear-Host
    Write-NTKSection "GPO HEALTH"

    Write-Host "Resultant Set Summary"
    Write-Host "---------------------"
    cmd.exe /c "gpresult /r /scope computer" 2>&1

}

function Global:Invoke-DismSfcRepairPath {

param(
    [switch]$NoPrompt
)

    Clear-Host
    Write-NTKSection "DISM AND SFC REPAIR PATH"

    if(!(Test-NTKAdministrator)){
        Write-Host "This repair path requires administrator rights." -ForegroundColor Yellow
        Write-Host "Rerun the toolkit elevated."
        return
    }

    Write-Host "This runs the standard Windows component and system file repair path:"
    Write-Host "1. DISM CheckHealth"
    Write-Host "2. DISM ScanHealth"
    Write-Host "3. DISM RestoreHealth"
    Write-Host "4. SFC /scannow"
    Write-Host ""
    Write-Host "This can take a while and may require a reboot afterward." -ForegroundColor Yellow
    Write-Host ""

    if(!$NoPrompt){
        $confirm = Read-NTKInput "Type REPAIR to continue" -AllowEmpty

        if($confirm -ne "REPAIR"){
            Write-Host "Repair path cancelled." -ForegroundColor Yellow
            return
        }
    }

    if(!(Test-Path $NTKPaths.Exports)){
        New-Item -ItemType Directory -Path $NTKPaths.Exports -Force | Out-Null
    }

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $logPath = Join-Path $NTKPaths.Exports "dism-sfc-repair-$env:COMPUTERNAME-$timestamp.txt"

    function Invoke-NTKRepairStep {
        param(
            [string]$Name,
            [string]$FilePath,
            [string[]]$Arguments
        )

        Write-Host ""
        Write-Host $Name -ForegroundColor Cyan
        Write-Host ("-" * $Name.Length) -ForegroundColor DarkCyan

        Add-Content -Path $logPath -Encoding UTF8 -Value ""
        Add-Content -Path $logPath -Encoding UTF8 -Value $Name
        Add-Content -Path $logPath -Encoding UTF8 -Value ("-" * $Name.Length)
        Add-Content -Path $logPath -Encoding UTF8 -Value ("Command: {0} {1}" -f $FilePath,($Arguments -join " "))
        Add-Content -Path $logPath -Encoding UTF8 -Value ""

        & $FilePath @Arguments 2>&1 |
            Tee-Object -FilePath $logPath -Append

        $exitCode = $LASTEXITCODE
        Add-Content -Path $logPath -Encoding UTF8 -Value "ExitCode: $exitCode"

        Write-Host ""
        Write-Host "Exit code: $exitCode"

        return $exitCode
    }

    @(
        "Network Toolkit DISM/SFC Repair Path"
        "Computer: $env:COMPUTERNAME"
        "Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        "User: $env:USERDOMAIN\$env:USERNAME"
        ""
    ) | Set-Content -Path $logPath -Encoding UTF8

    $results = @()
    $results += [pscustomobject]@{ Step = "DISM CheckHealth"; ExitCode = Invoke-NTKRepairStep -Name "DISM CheckHealth" -FilePath "dism.exe" -Arguments @("/Online","/Cleanup-Image","/CheckHealth") }
    $results += [pscustomobject]@{ Step = "DISM ScanHealth"; ExitCode = Invoke-NTKRepairStep -Name "DISM ScanHealth" -FilePath "dism.exe" -Arguments @("/Online","/Cleanup-Image","/ScanHealth") }
    $results += [pscustomobject]@{ Step = "DISM RestoreHealth"; ExitCode = Invoke-NTKRepairStep -Name "DISM RestoreHealth" -FilePath "dism.exe" -Arguments @("/Online","/Cleanup-Image","/RestoreHealth") }
    $results += [pscustomobject]@{ Step = "SFC Scannow"; ExitCode = Invoke-NTKRepairStep -Name "SFC Scannow" -FilePath "sfc.exe" -Arguments @("/scannow") }

    Add-Content -Path $logPath -Encoding UTF8 -Value ""
    Add-Content -Path $logPath -Encoding UTF8 -Value "Summary"
    Add-Content -Path $logPath -Encoding UTF8 -Value "-------"
    $results | Format-Table -AutoSize | Out-String | Add-Content -Path $logPath -Encoding UTF8
    Add-Content -Path $logPath -Encoding UTF8 -Value "Finished: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

    Write-Host ""
    Write-Host "Repair path completed. Log saved to:" -ForegroundColor Green
    Write-Host $logPath -ForegroundColor Green
    Write-Host ""
    Write-Host "Recommended next step: reboot if DISM or SFC repaired anything, then rerun Quick Diagnosis."

    Start-NTKToolProcess -FilePath "notepad.exe" -ArgumentList @("`"$logPath`"") | Out-Null

}

function Global:Get-NTKDumpSources {

    $sources = @()

    $commonPaths = @(
        "$env:SystemRoot\Minidump"
        "$env:SystemRoot\MEMORY.DMP"
        "$env:LOCALAPPDATA\CrashDumps"
        "$env:ProgramData\Microsoft\Windows\WER\ReportArchive"
        "$env:ProgramData\Microsoft\Windows\WER\ReportQueue"
    )

    foreach($path in $commonPaths){
        if(Test-Path $path){
            $sources += $path
        }
    }

    $localDumpKeys = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps"
        "HKCU:\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps"
    )

    foreach($key in $localDumpKeys){

        try {
            $dumpFolder = (Get-ItemProperty -Path $key -ErrorAction Stop).DumpFolder

            if($dumpFolder -and (Test-Path $dumpFolder)){
                $sources += $dumpFolder
            }
        }
        catch {}

    }

    return $sources | Select-Object -Unique

}

function Global:Get-NTKDumpFiles {

    $files = @()

    foreach($source in Get-NTKDumpSources){

        try {

            if(Test-Path $source -PathType Leaf){
                $files += Get-Item -Path $source -ErrorAction Stop
            }
            else{
                $files += Get-ChildItem -Path $source -Recurse -File -Include "*.dmp","*.mdmp" -ErrorAction SilentlyContinue
            }

        }
        catch {}

    }

    return $files |
           Sort-Object LastWriteTime -Descending |
           Select-Object -Unique

}

function Global:Get-NTKMinidumpCollectionRoot {

    $root = Join-Path $NTKPaths.Data "MiniDumps"

    if(!(Test-Path $root)){
        New-Item -ItemType Directory -Path $root -Force | Out-Null
    }

    return $root

}

function Global:Get-NTKLatestMinidumpCollection {

    $root = Get-NTKMinidumpCollectionRoot
    $pointer = Join-Path $root "_LatestCollection.txt"

    if(Test-Path $pointer){
        try {
            $latest = (Get-Content -Path $pointer -Raw -ErrorAction Stop).Trim()
            if($latest -and (Test-Path $latest)){
                return $latest
            }
        }
        catch {}
    }

    $folders = @(Get-ChildItem -Path $root -Directory -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending)
    if($folders.Count -gt 0){
        return $folders[0].FullName
    }

    return $null

}

function Global:New-NTKMinidumpCollection {

param(
    [object[]]$DumpFiles,
    [object[]]$CrashEvents = @()
)

    $collectionRoot = Get-NTKMinidumpCollectionRoot
    $safeComputer = ($env:COMPUTERNAME -replace '[^A-Za-z0-9._-]+','_').Trim('_')
    if(!$safeComputer){ $safeComputer = "Computer" }

    $collectionName = "{0}-{1}" -f (Get-Date -Format "yyyyMMdd-HHmmss"),$safeComputer
    $collectionPath = Join-Path $collectionRoot $collectionName
    New-Item -ItemType Directory -Path $collectionPath -Force | Out-Null

    $copied = @()
    $failures = @()

    foreach($dump in @($DumpFiles)){
        if(!$dump -or !(Test-Path $dump.FullName)){
            continue
        }

        $destinationName = $dump.Name
        $destination = Join-Path $collectionPath $destinationName

        if(Test-Path $destination){
            $base = [IO.Path]::GetFileNameWithoutExtension($dump.Name)
            $ext = [IO.Path]::GetExtension($dump.Name)
            $destinationName = "{0}-{1}{2}" -f $base,($dump.LastWriteTime.ToString("yyyyMMddHHmmss")),$ext
            $destination = Join-Path $collectionPath $destinationName
        }

        try {
            Copy-Item -LiteralPath $dump.FullName -Destination $destination -Force -ErrorAction Stop
            $copied += [pscustomobject]@{
                Source = $dump.FullName
                Copy = $destination
                Name = $destinationName
                SizeMB = [math]::Round($dump.Length / 1MB,2)
                LastWriteTime = $dump.LastWriteTime
            }
        }
        catch {
            $failures += [pscustomobject]@{
                Source = $dump.FullName
                Error = $_.Exception.Message
            }
        }
    }

    $summaryPath = Join-Path $collectionPath "summary.txt"
    $manifestPath = Join-Path $collectionPath "manifest.csv"
    $eventsPath = Join-Path $collectionPath "crash-events.txt"
    $pointerPath = Join-Path $collectionRoot "_LatestCollection.txt"

    $summary = @(
        "Network Toolkit Minidump Collection"
        "==================================="
        "Computer: $env:COMPUTERNAME"
        "Collected: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        "Collection: $collectionPath"
        "DumpCount: $($copied.Count)"
        "FailedCount: $($failures.Count)"
        "Analyzer: $(if(Get-NTKDumpAnalyzer){Get-NTKDumpAnalyzer}else{'Not found'})"
        ""
        "Open this folder with BlueScreenView:"
        $collectionPath
        ""
        "Copied Dumps"
        "------------"
    )

    foreach($item in $copied){
        $summary += "{0} ({1} MB) <- {2}" -f $item.Name,$item.SizeMB,$item.Source
    }

    if($failures.Count -gt 0){
        $summary += ""
        $summary += "Copy Failures"
        $summary += "-------------"
        foreach($failure in $failures){
            $summary += "{0}: {1}" -f $failure.Source,$failure.Error
        }
    }

    $summary | Set-Content -Path $summaryPath -Encoding UTF8
    $copied | Export-Csv -Path $manifestPath -NoTypeInformation -Encoding UTF8

    if($CrashEvents -and $CrashEvents.Count -gt 0){
        $CrashEvents |
            Sort-Object TimeCreated -Descending |
            Select-Object -First 20 TimeCreated,ProviderName,Id,Message |
            Format-List |
            Out-String |
            Set-Content -Path $eventsPath -Encoding UTF8
    }

    Set-Content -Path $pointerPath -Value $collectionPath -Encoding UTF8

    return [pscustomobject]@{
        Path = $collectionPath
        SummaryPath = $summaryPath
        ManifestPath = $manifestPath
        EventsPath = if(Test-Path $eventsPath){$eventsPath}else{$null}
        Copied = $copied
        Failures = $failures
    }

}

function Global:Get-NTKDumpAnalyzer {

    $commands = "cdb.exe","dumpchk.exe","windbgx.exe"

    foreach($command in $commands){
        $found = Get-Command $command -ErrorAction SilentlyContinue | Select-Object -First 1
        if($found){
            return $found.Source
        }
    }

    $knownPaths = @(
        "${env:ProgramFiles(x86)}\Windows Kits\10\Debuggers\x64\cdb.exe"
        "${env:ProgramFiles(x86)}\Windows Kits\10\Debuggers\x86\cdb.exe"
        "$env:ProgramFiles\Windows Kits\10\Debuggers\x64\cdb.exe"
        "$env:ProgramFiles\Windows Kits\10\Debuggers\x64\dumpchk.exe"
    )

    foreach($path in $knownPaths){
        if(Test-Path $path){
            return $path
        }
    }

    return $null

}

function Global:Invoke-NTKDumpAnalyzer {

param(
    [string]$DumpPath,
    [string]$OutputPath
)

    if(!(Test-Path $DumpPath)){
        Write-Host "Dump file not found:" $DumpPath -ForegroundColor Red
        return
    }

    $analyzer = Get-NTKDumpAnalyzer

    if(!$analyzer){
        Write-Host "Windows debugging tools were not found. Showing metadata and event correlation only." -ForegroundColor Yellow
        return
    }

    Write-Host "Analyzer:" $analyzer
    Write-Host "Dump:" $DumpPath
    Write-Host ""

    try {

        if((Split-Path -Leaf $analyzer) -ieq "cdb.exe"){
            & $analyzer -z $DumpPath -y "srv*C:\Symbols*https://msdl.microsoft.com/download/symbols" -c "!analyze -v; q" 2>&1 |
                Tee-Object -FilePath $OutputPath
        }
        elseif((Split-Path -Leaf $analyzer) -ieq "dumpchk.exe"){
            & $analyzer $DumpPath 2>&1 |
                Tee-Object -FilePath $OutputPath
        }
        else{
            Write-Host "Windbg Preview was found, but command-line analysis is not available from this toolkit." -ForegroundColor Yellow
            Write-Host "Open this dump manually:" $DumpPath
        }

    }
    catch {
        Write-Host "Dump analyzer failed." -ForegroundColor Red
        Write-Host $_.Exception.Message
    }

}

function Global:Invoke-MinidumpCollectorAnalyzer {

param(
    [switch]$CollectAll
)

    Clear-Host
    Write-NTKSection "MINIDUMP COLLECTOR AND ANALYZER"

    $dumpFiles = @(Get-NTKDumpFiles)

    Write-Host "Dump Sources"
    Write-Host "------------"
    $sources = @(Get-NTKDumpSources)

    if($sources){
        $sources | ForEach-Object { Write-Host $_ }
    }
    else{
        Write-Host "No common dump source folders found." -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Recent Dumps"
    Write-Host "------------"

    if($dumpFiles.Count -eq 0){
        Write-Host "No .dmp or .mdmp files found in common dump locations." -ForegroundColor Yellow
    }
    else{
        $visibleDumpCount = [math]::Min($dumpFiles.Count,20)

        for($i = 0; $i -lt $visibleDumpCount; $i++){
            $dump = $dumpFiles[$i]
            Write-Host ("{0}. {1}  {2} MB  {3}" -f ($i + 1),$dump.FullName,[math]::Round($dump.Length / 1MB,2),$dump.LastWriteTime)
        }
    }

    Write-Host ""
    Write-Host "Recent Crash Events"
    Write-Host "-------------------"

    $crashEvents = @()

    try {
        $crashEvents += Get-WinEvent -FilterHashtable @{LogName="System"; Id=1001; StartTime=(Get-Date).AddDays(-14)} -MaxEvents 20 -ErrorAction Stop
    }
    catch {}

    try {
        $crashEvents += Get-WinEvent -FilterHashtable @{LogName="Application"; Id=1000,1001; StartTime=(Get-Date).AddDays(-14)} -MaxEvents 20 -ErrorAction Stop
    }
    catch {}

    if($crashEvents){
        $crashEvents |
            Sort-Object TimeCreated -Descending |
            Select-Object -First 20 TimeCreated,ProviderName,Id,
                @{Name="Message";Expression={
                    $message = [string]$_.Message -replace "\s+"," "
                    $message.Substring(0,[math]::Min(160,$message.Length))
                }} |
            Format-Table -Wrap -AutoSize
    }
    else{
        Write-Host "No recent bugcheck, application error, or WER events found." -ForegroundColor Green
    }

    if($dumpFiles.Count -eq 0){
        Write-Host ""
        Write-Host "No crash dump files are currently available to copy." -ForegroundColor Yellow
        Write-Host "Creating an evidence-only collection with the crash events shown above." -ForegroundColor Cyan

        $collection = New-NTKMinidumpCollection -DumpFiles @() -CrashEvents $crashEvents
        $noDumpNote = Join-Path $collection.Path "no-dumps-found.txt"
        @(
            "Network Toolkit Minidump Collector"
            ""
            "No .dmp or .mdmp files were found in the configured Windows dump locations."
            "The collection still includes crash-events.txt when Windows event evidence was available."
            ""
            "BlueScreenView cannot analyze this collection until Windows creates a minidump or memory dump."
            "For application crashes, use Crash Event Summary or Reliability Monitor to identify the repeating application, module, or provider."
            "For future BSOD troubleshooting, verify System Properties > Startup and Recovery > Write debugging information is configured to create a Small memory dump."
        ) | Set-Content -Path $noDumpNote -Encoding UTF8

        Write-Host "Evidence collection created:" $collection.Path -ForegroundColor Green
        Write-Host "Open crash-events.txt for the event evidence. No dump file was available for BlueScreenView." -ForegroundColor Yellow
        Start-NTKToolProcess -FilePath "explorer.exe" -ArgumentList @("`"$($collection.Path)`"") | Out-Null
        return $collection
    }

    $selectedDumps = @()

    if($CollectAll){
        $selectedDumps = @($dumpFiles | Select-Object -First 20)
    }
    else{
        Write-Host ""
        Write-Host "Collection options:"
        Write-Host "A. Collect all listed dumps"
        Write-Host "1-$visibleDumpCount. Collect one selected dump"
        Write-Host ""
        $choice = Read-NTKInput "Select dump number or A for all"

        if($choice -match "^(a|all)$"){
            $selectedDumps = @($dumpFiles | Select-Object -First 20)
        }
        else{
        if(-not ($choice -as [int])){
            Write-Host "Invalid selection." -ForegroundColor Red
            return
        }

        $index = [int]$choice

        if($index -lt 1 -or $index -gt $visibleDumpCount){
            Write-Host "Invalid selection." -ForegroundColor Red
            return
        }

        $selectedDumps = @($dumpFiles[$index - 1])
        }
    }

    Write-Host ""
    Write-Host "Collecting $($selectedDumps.Count) dump file(s) into toolkit storage..."

    $collection = New-NTKMinidumpCollection -DumpFiles $selectedDumps -CrashEvents $crashEvents
    $session = $collection.Path

    Write-Host ""
    Write-Host "Collected to toolkit minidump folder:" $session -ForegroundColor Green
    Write-Host "BlueScreenView will automatically use the latest collection when launched from the toolkit." -ForegroundColor Green
    Write-Host ""

    if($collection.Failures.Count -gt 0){
        Write-Host "Some dumps could not be copied:" -ForegroundColor Yellow
        $collection.Failures | Format-Table Source,Error -Wrap -AutoSize
    }

    if($collection.Copied.Count -gt 0){
        $firstCopy = $collection.Copied[0].Copy
        $analysisPath = Join-Path $session "analysis.txt"
        Invoke-NTKDumpAnalyzer -DumpPath $firstCopy -OutputPath $analysisPath
    }

    Write-Host ""
    Write-Host "Collected Files"
    Write-Host "---------------"
    Get-ChildItem -Path $session -File | Select-Object Name,Length,LastWriteTime | Format-Table -AutoSize

    Write-Host ""
    $action = Read-NTKInput "Open folder, Open BlueScreenView, Delete collection, or Done" -AllowEmpty

    if($action -match "^(o|open)$"){
        Start-NTKToolProcess -FilePath "explorer.exe" -ArgumentList @("`"$session`"") | Out-Null
    }
    elseif($action -match "^(b|blue|bluescreenview)$"){
        Invoke-NTKExternalTool -Id "BlueScreenView" -ExtraArguments @("/MiniDumpFolder",$session)
    }
    elseif($action -match "^(d|delete)$"){
        Remove-Item -Path $session -Recurse -Force
        Write-Host "Deleted collection:" $session -ForegroundColor Yellow
    }

}

function Global:Invoke-CrashEventSummary {

    Write-Host ""
    Write-Host "CRASH EVENT SUMMARY" -ForegroundColor Cyan
    Write-Host "===================" -ForegroundColor DarkCyan
    Write-Host ""

    $start = (Get-Date).AddDays(-14)
    $filter = @{
        LogName   = "System","Application"
        StartTime = $start
    }

    $eventIds = @(41,1001,1000,1002,6008)

    try {
        $events = Get-WinEvent -FilterHashtable $filter -ErrorAction Stop |
            Where-Object { $eventIds -contains $_.Id -or $_.ProviderName -match "Windows Error Reporting|BugCheck|Application Error|Application Hang" } |
            Sort-Object TimeCreated -Descending |
            Select-Object -First 40
    }
    catch {
        Write-Host "Unable to read crash events: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "Try running elevated or open Reliability Monitor from the Crash tab."
        return
    }

    $reportPath = Export-NTKCrashEventSummaryHtml -Events $events

    if(!$events){
        Write-Host "No recent bugcheck, unexpected shutdown, WER, application crash, or application hang events were found in the last 14 days." -ForegroundColor Green
        Write-Host "Crash event report:" $reportPath -ForegroundColor Green
        Start-NTKToolProcess -FilePath $reportPath | Out-Null
        return $reportPath
    }

    Write-Host "Recent crash-related events from the last 14 days:" -ForegroundColor Yellow
    Write-Host ""

    $events |
        Select-Object `
            @{Name="Time";Expression={$_.TimeCreated}},
            @{Name="Log";Expression={$_.LogName}},
            @{Name="Id";Expression={$_.Id}},
            @{Name="Provider";Expression={$_.ProviderName}},
            @{Name="Summary";Expression={($_.Message -replace "`r|`n"," " -replace "\s+"," ").Trim()}} |
        Format-Table -Wrap -AutoSize

    Write-Host ""
    Write-Host "Recommended next steps:" -ForegroundColor Cyan
    Write-Host "- Open Reliability Monitor for the plain-language timeline."
    Write-Host "- Run Minidump Collector, then open BlueScreenView against the collected dump folder."
    Write-Host "- If the same driver or application repeats, update, roll back, or remove that component."
    Write-Host ""
    Write-Host "Crash event report:" $reportPath -ForegroundColor Green

    if(Get-Command Set-NTKComputerStateSection -ErrorAction SilentlyContinue){
        try {
            $stateEvents = @($events | Select-Object -First 40 | ForEach-Object {
                [pscustomobject]@{
                    Time = if($_.TimeCreated){$_.TimeCreated.ToString("s")}else{""}
                    Log = $_.LogName
                    Id = $_.Id
                    Provider = $_.ProviderName
                    Summary = (([string]$_.Message -replace "`r|`n"," " -replace "\s+"," ").Trim())
                }
            })
            [void](Set-NTKComputerStateSection -SectionName "CrashEventSummary" -Data ([pscustomobject]@{
                CapturedAt = (Get-Date).ToString("s")
                ReportPath = $reportPath
                EventCount = @($events).Count
                Events = $stateEvents
            }) -Source "Invoke-CrashEventSummary")
        }
        catch {}
    }

    Start-NTKToolProcess -FilePath $reportPath | Out-Null
    return $reportPath

}

function Global:Export-NTKCrashEventSummaryHtml {

param([object[]]$Events = @())

    $outputRoot = if($NTKPaths -and $NTKPaths.Exports){$NTKPaths.Exports}else{Join-Path $env:TEMP "NetworkToolkit\Exports"}
    if(!(Test-Path $outputRoot)){
        New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null
    }

    $safeComputer = if($env:COMPUTERNAME){($env:COMPUTERNAME -replace '[^A-Za-z0-9._-]+','_')}else{"Computer"}
    $reportPath = Join-Path $outputRoot ("crash-event-summary-{0}-{1}.html" -f $safeComputer,(Get-Date -Format "yyyyMMdd-HHmmss"))
    $encode = { param($Value) [System.Net.WebUtility]::HtmlEncode([string]$Value) }

    $rows = if(@($Events).Count -gt 0){
        (@($Events | Select-Object -First 40 | ForEach-Object {
            $time = if($_.TimeCreated){$_.TimeCreated.ToString("g")}else{""}
            $summary = (([string]$_.Message -replace "`r|`n"," " -replace "\s+"," ").Trim())
            if($summary.Length -gt 1200){ $summary = $summary.Substring(0,1200) + "..." }
            "<tr class='event-meta'><td>$(& $encode $time)</td><td>$(& $encode $_.LogName)</td><td>$(& $encode $_.Id)</td><td>$(& $encode $_.ProviderName)</td></tr><tr class='event-detail'><td colspan='4'><span>Event Detail</span>$(& $encode $summary)</td></tr>"
        }) -join "`n")
    }
    else{
        "<tr><td colspan='4' class='empty'>No matching crash, WER, bugcheck, unexpected shutdown, application error, or application hang events were found in the last 14 days.</td></tr>"
    }

    $html = @"
<!doctype html>
<html lang="en"><head><meta charset="utf-8"><title>Network Toolkit Crash Event Summary</title>
<style>
body{margin:0;background:#eef2f6;color:#1f2933;font-family:"Segoe UI",Arial,sans-serif}.top{background:#0f2f4a;color:#fff;padding:28px 36px}.top h1{margin:0;font-size:28px}.top p{margin:7px 0 0;color:#c9d8e5}.wrap{max-width:1240px;margin:0 auto;padding:26px 28px 40px}.card{background:#fff;border:1px solid #d9e1e8;border-radius:12px;padding:18px;box-shadow:0 8px 22px rgba(15,47,74,.08)}.summary{font-size:16px;line-height:1.5}.note{margin-top:18px;background:#fff5d9;border-left:5px solid #b7791f;border-radius:9px;padding:14px 16px;line-height:1.5}table{width:100%;border-collapse:collapse;table-layout:fixed;margin-top:18px;background:#fff;border:1px solid #d9e1e8;border-radius:10px;overflow:hidden}th,td{text-align:left;vertical-align:top;padding:11px 12px;border-bottom:1px solid #e6edf3;font-size:13px;overflow-wrap:anywhere}th{background:#f6f8fb;color:#425466}.event-meta td{font-weight:600;color:#102a43}.event-detail td{background:#fbfcfe;color:#263645;line-height:1.45;padding:10px 16px 18px}.event-detail span{display:block;color:#66788a;text-transform:uppercase;letter-spacing:.04em;font-size:11px;font-weight:700;margin-bottom:5px}tr:last-child td{border-bottom:0}.empty{color:#66788a;font-style:italic}.footer{margin-top:22px;color:#66788a;font-size:12px}@media print{body{background:#fff}.card{box-shadow:none}}
</style></head><body><div class="top"><h1>Network Toolkit Crash Event Summary</h1><p>$(& $encode $env:COMPUTERNAME) | Generated $(Get-Date -Format "g") | Last 14 days</p></div><main class="wrap"><section class="card"><div class="summary"><strong>$(@($Events).Count)</strong> crash-related Windows event(s) were found. This report records event evidence; it does not prove a BSOD or that a dump file exists.</div><div class="note"><strong>How to use this:</strong> Find repeated providers, applications, modules, or event IDs around the user-reported time. Use Reliability Monitor for the timeline. Use BlueScreenView only when a .dmp file is present; the Minidump Collector will create an evidence collection even when Windows retained events but no dump.</div><table><thead><tr><th style="width:150px">Time</th><th style="width:120px">Log</th><th style="width:70px">ID</th><th>Provider</th></tr></thead><tbody>$rows</tbody></table></section><div class="footer">Generated by Network Toolkit.</div></main></body></html>
"@

    $html | Set-Content -Path $reportPath -Encoding UTF8
    return $reportPath

}

function Global:Invoke-WindowsHealthDiagnostics {

    while($true){

        Clear-Host

        Write-Host ""
        Write-Host "WINDOWS HEALTH DIAGNOSTICS" -ForegroundColor Cyan
        Write-Host "==========================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "1. Event Log Triage"
        Write-Host "2. Service Health"
        Write-Host "3. Startup Impact"
        Write-Host "4. Disk Health"
        Write-Host "5. Hardware Health Diagnostics"
        Write-Host "6. Windows Update Health"
        Write-Host "7. Defender Security Check"
        Write-Host "8. Resource Hotspots"
        Write-Host "9. Domain Logon Health"
        Write-Host "10. GPO Health"
        Write-Host "11. Minidump Collector And Analyzer"
        Write-Host "12. DISM/SFC Repair Path"
        Write-Host "13. Process Explorer"
        Write-Host "14. Process Monitor"
        Write-Host "15. Autoruns"
        Write-Host "16. RAMMap"
        Write-Host "17. BlueScreenView"
        Write-Host "18. CrystalDiskInfo"
        Write-Host "19. HWiNFO"
        Write-Host "20. Sigcheck"
        Write-Host ""

        $choice = Read-NTKInput "Select health task"

        switch($choice){
            "1" { Invoke-EventLogTriage }
            "2" { Invoke-ServiceHealth }
            "3" { Invoke-StartupImpact }
            "4" { Invoke-DiskHealth }
            "5" { Invoke-HardwareHealthDiagnostics }
            "6" { Invoke-WindowsUpdateHealth }
            "7" { Invoke-DefenderSecurityCheck }
            "8" { Invoke-ResourceHotspots }
            "9" { Invoke-DomainLogonHealth }
            "10" { Invoke-GPOHealth }
            "11" { Invoke-MinidumpCollectorAnalyzer }
            "12" { Invoke-DismSfcRepairPath }
            "13" { Invoke-NTKExternalTool -Id "ProcessExplorer" }
            "14" { Invoke-NTKExternalTool -Id "ProcessMonitor" }
            "15" { Invoke-NTKExternalTool -Id "Autoruns" }
            "16" { Invoke-NTKExternalTool -Id "RAMMap" }
            "17" { Invoke-NTKExternalTool -Id "BlueScreenView" }
            "18" { Invoke-NTKExternalTool -Id "CrystalDiskInfo" }
            "19" { Invoke-NTKExternalTool -Id "HWiNFO" }
            "20" { Invoke-NTKExternalTool -Id "Sigcheck" }
            default { Write-Host "Invalid selection." -ForegroundColor Red }
        }

        Write-Host ""
        [void](Read-NTKInput "Press ENTER to continue" -AllowEmpty)

    }

}

Register-NTKCommand `
    -Name "Hardware Health Diagnostics" `
    -Command "Invoke-HardwareHealthDiagnostics" `
    -Category "Troubleshooting" `
    -Description "Check Device Manager, storage health, battery, memory inventory, and recent hardware/driver events" `
    -Order 6 `
    -RequiresAdmin

Register-NTKCommand `
    -Name "DISM/SFC Repair Path" `
    -Command "Invoke-DismSfcRepairPath" `
    -Category "Troubleshooting" `
    -Description "Run DISM CheckHealth, ScanHealth, RestoreHealth, then SFC /scannow with exported log" `
    -Order 7 `
    -RequiresAdmin

Register-NTKCommand `
    -Name "Windows Health Diagnostics" `
    -Command "Invoke-WindowsHealthDiagnostics" `
    -Category "Troubleshooting" `
    -Description "Windows health checks plus external process, dump, disk, and hardware tools" `
    -Order 5 `
    -RequiresAdmin
