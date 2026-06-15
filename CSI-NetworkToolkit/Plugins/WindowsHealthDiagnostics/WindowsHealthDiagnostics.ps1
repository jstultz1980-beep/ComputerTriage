function Global:Write-CSISection {

param([string]$Title)

    Write-Host ""
    Write-Host $Title -ForegroundColor Cyan
    Write-Host ("-" * $Title.Length) -ForegroundColor DarkCyan

}

function Global:Invoke-EventLogTriage {

param([int]$Hours = 24)

    Clear-Host
    Write-CSISection "EVENT LOG TRIAGE"

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
    Write-CSISection "SERVICE HEALTH"

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
    Write-CSISection "STARTUP IMPACT"

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
    Write-CSISection "DISK HEALTH"

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

function Global:Add-CSIHardwareFinding {

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

function Global:Get-CSIHardwareDeviceProblems {

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
    Write-CSISection "HARDWARE HEALTH DIAGNOSTICS"

    $findings = @()

    Write-Host "Device Manager Problem Devices"
    Write-Host "------------------------------"

    $deviceProblems = @(Get-CSIHardwareDeviceProblems)

    if($deviceProblems.Count -gt 0){

        $deviceProblems |
            Select-Object -First 50 |
            Format-Table -Wrap -AutoSize |
            Out-Host

        foreach($device in $deviceProblems){

            $name = if($device.FriendlyName){$device.FriendlyName}elseif($device.Name){$device.Name}else{$device.InstanceId}
            $code = if($device.Problem){$device.Problem}elseif($device.ConfigManagerErrorCode){"Code $($device.ConfigManagerErrorCode)"}else{$device.Status}

            Add-CSIHardwareFinding ([ref]$findings) `
                -Area "Device Manager" `
                -Status "Warning" `
                -Name $name `
                -Detail "Device status: $($device.Status). Problem: $code" `
                -Recommendation "Open Device Manager, review this device, reinstall/update the driver, check cabling/slot/firmware, or remove stale hardware if it is no longer present."

        }

    }
    else{

        Write-Host "No present Device Manager problem devices found." -ForegroundColor Green

        Add-CSIHardwareFinding ([ref]$findings) `
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

                    Add-CSIHardwareFinding ([ref]$findings) `
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

                    Add-CSIHardwareFinding ([ref]$findings) `
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

                Add-CSIHardwareFinding ([ref]$findings) `
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

                Add-CSIHardwareFinding ([ref]$findings) `
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

                Add-CSIHardwareFinding ([ref]$findings) `
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

            Add-CSIHardwareFinding ([ref]$findings) `
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
    Write-CSISection "WINDOWS UPDATE HEALTH"

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
    Write-CSISection "DEFENDER SECURITY CHECK"

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
    Write-CSISection "RESOURCE HOTSPOTS"

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
    Write-CSISection "DOMAIN LOGON HEALTH"

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
    Write-CSISection "GPO HEALTH"

    Write-Host "Resultant Set Summary"
    Write-Host "---------------------"
    cmd.exe /c "gpresult /r /scope computer" 2>&1

}

function Global:Invoke-DismSfcRepairPath {

param(
    [switch]$NoPrompt
)

    Clear-Host
    Write-CSISection "DISM AND SFC REPAIR PATH"

    if(!(Test-CSIAdministrator)){
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
        $confirm = Read-CSIInput "Type REPAIR to continue" -AllowEmpty

        if($confirm -ne "REPAIR"){
            Write-Host "Repair path cancelled." -ForegroundColor Yellow
            return
        }
    }

    if(!(Test-Path $CSIPaths.Exports)){
        New-Item -ItemType Directory -Path $CSIPaths.Exports -Force | Out-Null
    }

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $logPath = Join-Path $CSIPaths.Exports "dism-sfc-repair-$env:COMPUTERNAME-$timestamp.txt"

    function Invoke-CSIRepairStep {
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
    $results += [pscustomobject]@{ Step = "DISM CheckHealth"; ExitCode = Invoke-CSIRepairStep -Name "DISM CheckHealth" -FilePath "dism.exe" -Arguments @("/Online","/Cleanup-Image","/CheckHealth") }
    $results += [pscustomobject]@{ Step = "DISM ScanHealth"; ExitCode = Invoke-CSIRepairStep -Name "DISM ScanHealth" -FilePath "dism.exe" -Arguments @("/Online","/Cleanup-Image","/ScanHealth") }
    $results += [pscustomobject]@{ Step = "DISM RestoreHealth"; ExitCode = Invoke-CSIRepairStep -Name "DISM RestoreHealth" -FilePath "dism.exe" -Arguments @("/Online","/Cleanup-Image","/RestoreHealth") }
    $results += [pscustomobject]@{ Step = "SFC Scannow"; ExitCode = Invoke-CSIRepairStep -Name "SFC Scannow" -FilePath "sfc.exe" -Arguments @("/scannow") }

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

    Start-CSIToolProcess -FilePath "notepad.exe" -ArgumentList @("`"$logPath`"") | Out-Null

}

function Global:Get-CSIDumpSources {

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

function Global:Get-CSIDumpFiles {

    $files = @()

    foreach($source in Get-CSIDumpSources){

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

function Global:Get-CSIDumpAnalyzer {

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

function Global:Invoke-CSIDumpAnalyzer {

param(
    [string]$DumpPath,
    [string]$OutputPath
)

    if(!(Test-Path $DumpPath)){
        Write-Host "Dump file not found:" $DumpPath -ForegroundColor Red
        return
    }

    $analyzer = Get-CSIDumpAnalyzer

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

    Clear-Host
    Write-CSISection "MINIDUMP COLLECTOR AND ANALYZER"

    $dumpFiles = @(Get-CSIDumpFiles)

    Write-Host "Dump Sources"
    Write-Host "------------"
    $sources = @(Get-CSIDumpSources)

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
        for($i = 0; $i -lt [math]::Min($dumpFiles.Count,20); $i++){
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
        return
    }

    Write-Host ""
    $choice = Read-CSIInput "Select dump to collect/analyze"

    if(-not ($choice -as [int])){
        Write-Host "Invalid selection." -ForegroundColor Red
        return
    }

    $index = [int]$choice

    if($index -lt 1 -or $index -gt $dumpFiles.Count){
        Write-Host "Invalid selection." -ForegroundColor Red
        return
    }

    $selected = $dumpFiles[$index - 1]
    $outputSession = New-CSITempOutputSession -ToolName "Minidump-Collection"
    $session = $outputSession.Path

    $copyPath = Join-Path $session $selected.Name
    $analysisPath = Join-Path $session "analysis.txt"
    $summaryPath = Join-Path $session "summary.txt"

    Write-Host ""
    Write-Host "Collecting:" $selected.FullName

    try {
        Copy-Item -Path $selected.FullName -Destination $copyPath -Force -ErrorAction Stop
    }
    catch {
        Write-Host "Unable to copy dump file." -ForegroundColor Red
        Write-Host $_.Exception.Message
        return
    }

    $summary = @(
        "Network Toolkit Minidump Collection"
        "==================================="
        "Computer: $env:COMPUTERNAME"
        "Collected: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        "Source: $($selected.FullName)"
        "Copy: $copyPath"
        "SizeMB: $([math]::Round($selected.Length / 1MB,2))"
        "LastWriteTime: $($selected.LastWriteTime)"
        "Analyzer: $(if(Get-CSIDumpAnalyzer){Get-CSIDumpAnalyzer}else{'Not found'})"
        ""
        "Recent crash events are shown in the console output."
    )

    $summary | Set-Content -Path $summaryPath -Encoding UTF8

    Write-Host "Collected to temp output session:" $session -ForegroundColor Green
    Write-Host "Point BlueScreenView at this folder if you want to review the copied dump there." -ForegroundColor Green
    Write-Host ""

    Invoke-CSIDumpAnalyzer -DumpPath $copyPath -OutputPath $analysisPath

    Write-Host ""
    Write-Host "Collected Files"
    Write-Host "---------------"
    Get-ChildItem -Path $session -File | Select-Object Name,Length,LastWriteTime | Format-Table -AutoSize

    Write-Host ""
    $action = Read-CSIInput "Open folder, Delete collection, or Done" -AllowEmpty

    if($action -match "^(o|open)$"){
        Start-CSIToolProcess -FilePath "explorer.exe" -ArgumentList @("`"$session`"") | Out-Null
    }
    elseif($action -match "^(d|delete)$"){
        Remove-Item -Path $session -Recurse -Force
        Write-Host "Deleted collection:" $session -ForegroundColor Yellow
    }

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

        $choice = Read-CSIInput "Select health task"

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
            "13" { Invoke-CSIExternalTool -Id "ProcessExplorer" }
            "14" { Invoke-CSIExternalTool -Id "ProcessMonitor" }
            "15" { Invoke-CSIExternalTool -Id "Autoruns" }
            "16" { Invoke-CSIExternalTool -Id "RAMMap" }
            "17" { Invoke-CSIExternalTool -Id "BlueScreenView" }
            "18" { Invoke-CSIExternalTool -Id "CrystalDiskInfo" }
            "19" { Invoke-CSIExternalTool -Id "HWiNFO" }
            "20" { Invoke-CSIExternalTool -Id "Sigcheck" }
            default { Write-Host "Invalid selection." -ForegroundColor Red }
        }

        Write-Host ""
        [void](Read-Host "Press ENTER to continue")

    }

}

Register-CSICommand `
    -Name "Hardware Health Diagnostics" `
    -Command "Invoke-HardwareHealthDiagnostics" `
    -Category "Troubleshooting" `
    -Description "Check Device Manager, storage health, battery, memory inventory, and recent hardware/driver events" `
    -Order 6 `
    -RequiresAdmin

Register-CSICommand `
    -Name "DISM/SFC Repair Path" `
    -Command "Invoke-DismSfcRepairPath" `
    -Category "Troubleshooting" `
    -Description "Run DISM CheckHealth, ScanHealth, RestoreHealth, then SFC /scannow with exported log" `
    -Order 7 `
    -RequiresAdmin

Register-CSICommand `
    -Name "Windows Health Diagnostics" `
    -Command "Invoke-WindowsHealthDiagnostics" `
    -Category "Troubleshooting" `
    -Description "Windows health checks plus external process, dump, disk, and hardware tools" `
    -Order 5 `
    -RequiresAdmin
