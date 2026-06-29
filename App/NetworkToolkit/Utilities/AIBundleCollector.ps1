function Global:Write-NTKCollectorSectionStatus {
param(
    [System.Collections.ArrayList]$Status,
    [string]$Name,
    [string]$State,
    [string]$Detail = ""
)
    [void]$Status.Add([pscustomobject]@{
        Section = $Name
        State   = $State
        Detail  = $Detail
        Time    = (Get-Date).ToString('s')
    })
}

function Global:Export-NTKSafeJson {
param($InputObject,[string]$Path)
    try {
        $folder = Split-Path -Parent $Path
        if($folder -and !(Test-Path -LiteralPath $folder)){ New-Item -ItemType Directory -Path $folder -Force | Out-Null }
        $InputObject | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $Path -Encoding UTF8
        return $true
    }
    catch {
        "ERROR: $($_.Exception.Message)" | Set-Content -LiteralPath $Path -Encoding UTF8
        return $false
    }
}

function Global:Export-NTKSafeCsv {
param($InputObject,[string]$Path)
    try {
        $folder = Split-Path -Parent $Path
        if($folder -and !(Test-Path -LiteralPath $folder)){ New-Item -ItemType Directory -Path $folder -Force | Out-Null }
        @($InputObject) | Export-Csv -LiteralPath $Path -NoTypeInformation -Encoding UTF8
        return $true
    }
    catch {
        "ERROR: $($_.Exception.Message)" | Set-Content -LiteralPath $Path -Encoding UTF8
        return $false
    }
}

function Global:ConvertTo-NTKCollectorCommandLine {
param([string[]]$Arguments = @())
    return (@($Arguments | Where-Object { $_ -ne $null -and $_ -ne "" } | ForEach-Object {
        $value = [string]$_
        if($value -match '[\s"]'){
            '"' + ($value -replace '"','\"') + '"'
        }
        else {
            $value
        }
    }) -join ' ')
}

function Global:Invoke-NTKSafeTextCommand {
param(
    [string]$FilePath,
    [string[]]$Arguments = @(),
    [string]$Path,
    [int]$TimeoutSeconds = 60,
    [string]$WorkingDirectory = ""
)
    $folder = Split-Path -Parent $Path
    if($folder -and !(Test-Path -LiteralPath $folder)){ New-Item -ItemType Directory -Path $folder -Force | Out-Null }

    try {
        $command = Get-Command $FilePath -ErrorAction Stop
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $command.Source
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.CreateNoWindow = $true
        if($WorkingDirectory){ $psi.WorkingDirectory = $WorkingDirectory }
        $psi.Arguments = ConvertTo-NTKCollectorCommandLine -Arguments $Arguments

        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $psi
        [void]$process.Start()
        $finished = $process.WaitForExit([Math]::Max(5,$TimeoutSeconds) * 1000)
        if(!$finished){
            try { $process.Kill() } catch {}
            "ERROR: Command timed out after $TimeoutSeconds seconds.`r`nCommand: $FilePath $($Arguments -join ' ')" | Set-Content -LiteralPath $Path -Encoding UTF8
            return $false
        }

        $output = $process.StandardOutput.ReadToEnd()
        $errorText = $process.StandardError.ReadToEnd()
        @(
            "Command: $FilePath $($Arguments -join ' ')"
            "ExitCode: $($process.ExitCode)"
            ""
            $output
            if($errorText){ "STDERR:`r`n$errorText" }
        ) | Set-Content -LiteralPath $Path -Encoding UTF8
        return ($process.ExitCode -eq 0)
    }
    catch {
        "ERROR: $($_.Exception.Message)`r`nCommand: $FilePath $($Arguments -join ' ')" | Set-Content -LiteralPath $Path -Encoding UTF8
        return $false
    }
}

function Global:Invoke-NTKCollectorSection {
param(
    [System.Collections.ArrayList]$Status,
    [string]$Name,
    [scriptblock]$Script
)
    try {
        $detail = & $Script
        Write-NTKCollectorSectionStatus $Status $Name 'Completed' ([string]$detail)
    }
    catch {
        Write-NTKCollectorSectionStatus $Status $Name 'Failed' $_.Exception.Message
    }
}

function Global:Get-NTKCollectorKeywordPattern {
    return '(?i)Sophos|SentinelOne|Huntress|Defender|CrowdStrike|Carbon\s*Black|Bitdefender|Webroot|Malwarebytes|Cisco\s*Secure|SonicWall|NetExtender|OpenVPN|WireGuard|Tailscale|Veeam|Datto|Acronis|Cove|N-able|Nable|N-Central|Auvik|Fortinet|FortiClient|Palo Alto|GlobalProtect|Zscaler|Tanium|Rapid7'
}

function Global:Get-NTKInstalledProgramInventory {
    $roots = @(
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    foreach($root in $roots){
        Get-ItemProperty -Path $root -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName } |
            Select-Object DisplayName,DisplayVersion,Publisher,InstallDate,InstallLocation,UninstallString
    }
}

function Global:Get-NTKDriverFocusCategory {
param($Driver)
    $text = "$($Driver.DeviceName) $($Driver.DeviceClass) $($Driver.DriverProviderName) $($Driver.Manufacturer) $($Driver.InfName)"
    $categories = New-Object System.Collections.Generic.List[string]
    if($text -match '(?i)net|ethernet|wi-?fi|wireless|bluetooth|ndis'){ [void]$categories.Add('Network') }
    if($text -match '(?i)storage|disk|raid|scsi|sata|nvme|volume|storport'){ [void]$categories.Add('Storage') }
    if($text -match '(?i)display|video|graphics|nvidia|amd|intel\(r\) uhd|radeon|geforce'){ [void]$categories.Add('Display') }
    if($text -match '(?i)hyper-v|vmbus|virtual machine|vmware|virtualbox'){ [void]$categories.Add('Virtualization') }
    if($text -match '(?i)vpn|tap|tun|wireguard|tailscale|netextender|sonicwall|cisco|anyconnect|globalprotect|fortinet'){ [void]$categories.Add('VPN') }
    if($text -match (Get-NTKCollectorKeywordPattern)){ [void]$categories.Add('Security/Backup') }
    if($categories.Count -eq 0){ return $null }
    return ($categories -join '; ')
}

function Global:Get-NTKStartupRunKeyEntries {
    $entries = @()
    foreach($key in @(
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run',
        'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
    )){
        if(!(Test-Path -LiteralPath $key)){ continue }
        $props = Get-ItemProperty -LiteralPath $key -ErrorAction SilentlyContinue
        foreach($property in @($props.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' })){
            $entries += [pscustomobject]@{
                Source = $key
                Name = $property.Name
                Command = [string]$property.Value
            }
        }
    }
    return $entries
}

function Global:Get-NTKStartupFolderEntries {
    $folders = @(
        [Environment]::GetFolderPath('Startup'),
        [Environment]::GetFolderPath('CommonStartup')
    ) | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -Unique

    foreach($folder in $folders){
        Get-ChildItem -LiteralPath $folder -File -ErrorAction SilentlyContinue |
            Select-Object @{n='Source';e={$folder}},Name,FullName,Length,CreationTime,LastWriteTime
    }
}

function Global:Get-NTKScheduledTaskInventory {
    try {
        Get-ScheduledTask -ErrorAction Stop | ForEach-Object {
            [pscustomobject]@{
                TaskName = $_.TaskName
                TaskPath = $_.TaskPath
                State = $_.State
                Author = $_.Author
                Triggers = (@($_.Triggers | ForEach-Object { $_.ToString() }) -join ' | ')
                Actions = (@($_.Actions | ForEach-Object { $_.ToString() }) -join ' | ')
            }
        }
    }
    catch {
        [pscustomobject]@{ TaskName='ERROR'; TaskPath=''; State=''; Author=''; Triggers=''; Actions=$_.Exception.Message }
    }
}

function Global:Get-NTKEventRows {
param(
    [string[]]$LogNames = @('System','Application'),
    [int[]]$Levels = @(1,2,3),
    [datetime]$StartTime = (Get-Date).AddDays(-30),
    [int]$MaxPerLog = 1000
)
    $rows = @()
    foreach($log in $LogNames){
        try {
            $rows += Get-WinEvent -FilterHashtable @{LogName=$log;StartTime=$StartTime;Level=$Levels} -MaxEvents $MaxPerLog -ErrorAction Stop |
                ForEach-Object {
                    [pscustomobject]@{
                        TimeCreated = $_.TimeCreated
                        LogName = $_.LogName
                        ProviderName = $_.ProviderName
                        Id = $_.Id
                        LevelDisplayName = $_.LevelDisplayName
                        Message = ($_.Message -replace '\s+',' ').Trim()
                    }
                }
        }
        catch {
            $rows += [pscustomobject]@{
                TimeCreated = Get-Date
                LogName = $log
                ProviderName = 'NetworkToolkitCollector'
                Id = 0
                LevelDisplayName = 'Error'
                Message = "Could not read $log log: $($_.Exception.Message)"
            }
        }
    }
    return $rows
}

function Global:New-NTKAIDiagnosticCollection {
param([string]$ComputerName=$env:COMPUTERNAME)
    $root = Join-Path $NTKPaths.Exports ("AI-Collection-{0}-{1}" -f $ComputerName,(Get-Date -Format 'yyyyMMdd-HHmmss'))
    New-Item -ItemType Directory -Path $root -Force | Out-Null
    $status = New-Object System.Collections.ArrayList
    $started = Get-Date

    Invoke-NTKCollectorSection $status 'Crash Dump Inventory' {
        $dumpPaths = @('C:\ProgramData\Microsoft\Windows\WER','C:\Windows\Minidump','C:\Windows\LiveKernelReports')
        $dumps = @()
        foreach($path in $dumpPaths){
            if(!(Test-Path -LiteralPath $path)){ continue }
            $dumps += Get-ChildItem -LiteralPath $path -Recurse -File -ErrorAction SilentlyContinue |
                Select-Object @{n='Folder';e={$path}},FullName,Length,CreationTime,LastWriteTime,Extension
        }
        $folderSummary = @($dumps | Group-Object Folder | ForEach-Object { [pscustomobject]@{Folder=$_.Name;Count=$_.Count;Bytes=($_.Group | Measure-Object Length -Sum).Sum} })
        $extensionSummary = @($dumps | Group-Object Extension | ForEach-Object { [pscustomobject]@{Extension=$_.Name;Count=$_.Count;Bytes=($_.Group | Measure-Object Length -Sum).Sum} })
        Export-NTKSafeCsv $dumps (Join-Path $root 'crash-dump-inventory.csv') | Out-Null
        Export-NTKSafeJson ([pscustomobject]@{Files=$dumps;SummaryByFolder=$folderSummary;SummaryByExtension=$extensionSummary;Note='Dump files are inventoried only. Large dumps are not copied by this collector.'}) (Join-Path $root 'crash-dump-inventory.json') | Out-Null
        "$($dumps.Count) file(s) inventoried"
    }

    Invoke-NTKCollectorSection $status 'Driver Inventory' {
        $drivers = @(Get-CimInstance Win32_PnPSignedDriver -ErrorAction Stop | Select-Object DeviceName,Manufacturer,DriverProviderName,DriverVersion,DriverDate,InfName,IsSigned,DeviceClass,DeviceID)
        $focus = @($drivers | ForEach-Object {
            $category = Get-NTKDriverFocusCategory $_
            if($category){
                [pscustomobject]@{
                    FocusCategory = $category
                    DeviceName = $_.DeviceName
                    DeviceClass = $_.DeviceClass
                    Manufacturer = $_.Manufacturer
                    DriverProviderName = $_.DriverProviderName
                    DriverVersion = $_.DriverVersion
                    DriverDate = $_.DriverDate
                    InfName = $_.InfName
                    IsSigned = $_.IsSigned
                    DeviceID = $_.DeviceID
                }
            }
        })
        Export-NTKSafeCsv $drivers (Join-Path $root 'driver-inventory.csv') | Out-Null
        Export-NTKSafeJson $drivers (Join-Path $root 'driver-inventory.json') | Out-Null
        Export-NTKSafeCsv $focus (Join-Path $root 'driver-focus.csv') | Out-Null
        Export-NTKSafeJson $focus (Join-Path $root 'driver-focus.json') | Out-Null
        "$($drivers.Count) driver(s); $($focus.Count) focus driver(s)"
    }

    Invoke-NTKCollectorSection $status 'Filter Drivers' {
        $filtersPath = Join-Path $root 'filter-drivers.txt'
        $instancesPath = Join-Path $root 'filter-instances.txt'
        Invoke-NTKSafeTextCommand 'fltmc.exe' @('filters') $filtersPath -TimeoutSeconds 30 | Out-Null
        Invoke-NTKSafeTextCommand 'fltmc.exe' @('instances') $instancesPath -TimeoutSeconds 30 | Out-Null
        $raw = ((Get-Content -LiteralPath $filtersPath -Raw -ErrorAction SilentlyContinue) + "`r`n" + (Get-Content -LiteralPath $instancesPath -Raw -ErrorAction SilentlyContinue))
        $productPattern = Get-NTKCollectorKeywordPattern
        $parsed = @($raw -split "`r?`n" | Where-Object { $_ -match '^\s*\S+' -and $_ -notmatch '^(Command|ExitCode|Filter Name|----|$)' } | ForEach-Object {
            [pscustomobject]@{
                RawLine = $_.Trim()
                ProductFlag = if($_ -match $productPattern){ $Matches[0] }else{ '' }
            }
        })
        Export-NTKSafeCsv $parsed (Join-Path $root 'filter-driver-summary.csv') | Out-Null
        "$($parsed.Count) parsed line(s); $(@($parsed | Where-Object ProductFlag).Count) product flag(s)"
    }

    Invoke-NTKCollectorSection $status 'Network Stack And Bindings' {
        $adapters = @(if(Get-Command Get-NetAdapter -ErrorAction SilentlyContinue){ Get-NetAdapter -ErrorAction SilentlyContinue | Select-Object Name,InterfaceDescription,Status,LinkSpeed,MacAddress,InterfaceGuid,ifIndex })
        $bindings = @(if(Get-Command Get-NetAdapterBinding -ErrorAction SilentlyContinue){ Get-NetAdapterBinding -AllBindings -ErrorAction SilentlyContinue | Select-Object Name,DisplayName,ComponentID,Enabled })
        $ip = @(if(Get-Command Get-NetIPConfiguration -ErrorAction SilentlyContinue){ Get-NetIPConfiguration -ErrorAction SilentlyContinue | Select-Object InterfaceAlias,InterfaceIndex,IPv4Address,IPv6Address,IPv4DefaultGateway,DNSServer })
        $routes = @(if(Get-Command Get-NetRoute -ErrorAction SilentlyContinue){ Get-NetRoute -ErrorAction SilentlyContinue | Select-Object DestinationPrefix,NextHop,RouteMetric,InterfaceMetric,InterfaceAlias,AddressFamily })
        $dns = @(if(Get-Command Get-DnsClientServerAddress -ErrorAction SilentlyContinue){ Get-DnsClientServerAddress -ErrorAction SilentlyContinue | Select-Object InterfaceAlias,AddressFamily,ServerAddresses })
        $nrpt = @(if(Get-Command Get-DnsClientNrptPolicy -ErrorAction SilentlyContinue){ Get-DnsClientNrptPolicy -ErrorAction SilentlyContinue })
        $vpnFilterSummary = @($adapters + $bindings | Where-Object { "$($_.InterfaceDescription) $($_.DisplayName) $($_.ComponentID) $($_.Name)" -match '(?i)vpn|filter|ndis|tap|tun|wireguard|tailscale|netextender|sonicwall|cisco|fortinet|globalprotect|zscaler|sophos|crowdstrike|sentinel' })
        Export-NTKSafeCsv $adapters (Join-Path $root 'network-adapters.csv') | Out-Null
        Export-NTKSafeCsv $bindings (Join-Path $root 'network-bindings.csv') | Out-Null
        Export-NTKSafeCsv $routes (Join-Path $root 'network-routes.csv') | Out-Null
        Export-NTKSafeJson ([pscustomobject]@{Adapters=$adapters;Bindings=$bindings;IPConfiguration=$ip;Routes=$routes;DnsServers=$dns;NrptPolicy=$nrpt;VpnFilterBindingSummary=$vpnFilterSummary}) (Join-Path $root 'network-stack.json') | Out-Null
        Invoke-NTKSafeTextCommand 'ipconfig.exe' @('/all') (Join-Path $root 'ipconfig-all.txt') -TimeoutSeconds 30 | Out-Null
        Invoke-NTKSafeTextCommand 'route.exe' @('print') (Join-Path $root 'route-print.txt') -TimeoutSeconds 30 | Out-Null
        Invoke-NTKSafeTextCommand 'netcfg.exe' @('-s','n') (Join-Path $root 'netcfg-bindings.txt') -TimeoutSeconds 30 | Out-Null
        "$($adapters.Count) adapter(s); $($bindings.Count) binding(s); $($vpnFilterSummary.Count) VPN/filter clue(s)"
    }

    Invoke-NTKCollectorSection $status 'Process Performance Snapshot' {
        $processes = @(Get-Process -ErrorAction SilentlyContinue | ForEach-Object {
            [pscustomobject]@{
                Name = $_.Name
                PID = $_.Id
                CPU = $_.CPU
                WorkingSet = $_.WorkingSet64
                PrivateMemory = $_.PrivateMemorySize64
                Handles = $_.HandleCount
                Path = $(try { $_.Path } catch { '' })
                StartTime = $(try { $_.StartTime } catch { $null })
            }
        })
        $snapshot = [pscustomobject]@{
            TopCPU = @($processes | Sort-Object CPU -Descending | Select-Object -First 25)
            TopWorkingSet = @($processes | Sort-Object WorkingSet -Descending | Select-Object -First 25)
            TopPrivateMemory = @($processes | Sort-Object PrivateMemory -Descending | Select-Object -First 25)
            TopHandles = @($processes | Sort-Object Handles -Descending | Select-Object -First 25)
        }
        Export-NTKSafeJson $snapshot (Join-Path $root 'process-performance.json') | Out-Null
        Export-NTKSafeCsv $snapshot.TopCPU (Join-Path $root 'process-top-cpu.csv') | Out-Null
        Export-NTKSafeCsv $snapshot.TopWorkingSet (Join-Path $root 'process-top-working-set.csv') | Out-Null
        Export-NTKSafeCsv $snapshot.TopPrivateMemory (Join-Path $root 'process-top-private-memory.csv') | Out-Null
        Export-NTKSafeCsv $snapshot.TopHandles (Join-Path $root 'process-top-handles.csv') | Out-Null
        "$($processes.Count) process(es) sampled"
    }

    Invoke-NTKCollectorSection $status 'Services And Startup' {
        $services = @(Get-CimInstance Win32_Service -ErrorAction Stop | Select-Object Name,DisplayName,State,StartMode,StartName,PathName)
        $serviceDetails = @($services | ForEach-Object {
            $delayed = $null
            try {
                $key = "HKLM:\SYSTEM\CurrentControlSet\Services\$($_.Name)"
                $delayed = (Get-ItemProperty -LiteralPath $key -Name DelayedAutoStart -ErrorAction SilentlyContinue).DelayedAutoStart
            } catch {}
            $_ | Add-Member -NotePropertyName DelayedAutoStart -NotePropertyValue ([bool]$delayed) -Force
            $_
        })
        $stoppedAuto = @($serviceDetails | Where-Object { $_.StartMode -eq 'Auto' -and $_.State -ne 'Running' })
        $runKeys = @(Get-NTKStartupRunKeyEntries)
        $startupFolders = @(Get-NTKStartupFolderEntries)
        $tasks = @(Get-NTKScheduledTaskInventory)
        Export-NTKSafeCsv $serviceDetails (Join-Path $root 'services.csv') | Out-Null
        Export-NTKSafeCsv $stoppedAuto (Join-Path $root 'services-stopped-automatic.csv') | Out-Null
        Export-NTKSafeJson ([pscustomobject]@{Services=$serviceDetails;StoppedAutomatic=$stoppedAuto;RunKeys=$runKeys;StartupFolders=$startupFolders;ScheduledTasks=$tasks}) (Join-Path $root 'services-startup.json') | Out-Null
        "$($serviceDetails.Count) service(s); $($stoppedAuto.Count) stopped automatic; $($runKeys.Count) run key item(s); $($tasks.Count) scheduled task(s)"
    }

    Invoke-NTKCollectorSection $status 'Event Timeline' {
        $events = @(Get-NTKEventRows -MaxPerLog 1000)
        $focusIds = @(41,1074,6005,6006,6008,19,20,21,31,43,44,1000,1001,7000,7001,7009,7011,7022,7023,7024,7031,7034,7,51,55,57,129,153,219,4001,4201,4202)
        $focusProviders = '(?i)WindowsUpdateClient|Service Control Manager|Windows Error Reporting|Application Error|Disk|Ntfs|stornvme|storahci|DriverFrameworks|Kernel-Power|Hyper-V|Tcpip|DNS Client Events|Netwtw|e1dexpress|NlaSvc'
        $focused = @($events | Where-Object { $focusIds -contains [int]$_.Id -or $_.ProviderName -match $focusProviders })
        $summary = @($events | Group-Object ProviderName,Id,LevelDisplayName | Sort-Object Count -Descending | ForEach-Object {
            [pscustomobject]@{ProviderIdLevel=$_.Name;Count=$_.Count;FirstSeen=($_.Group | Sort-Object TimeCreated | Select-Object -First 1).TimeCreated;LastSeen=($_.Group | Sort-Object TimeCreated -Descending | Select-Object -First 1).TimeCreated}
        })
        Export-NTKSafeJson $events (Join-Path $root 'event-timeline.json') | Out-Null
        Export-NTKSafeCsv $events (Join-Path $root 'event-timeline.csv') | Out-Null
        Export-NTKSafeJson $focused (Join-Path $root 'event-timeline-focused.json') | Out-Null
        Export-NTKSafeCsv $focused (Join-Path $root 'event-timeline-focused.csv') | Out-Null
        Export-NTKSafeCsv $summary (Join-Path $root 'event-summary.csv') | Out-Null
        "$($events.Count) event(s); $($focused.Count) focused event(s)"
    }

    Invoke-NTKCollectorSection $status 'Domain Controller Checks' {
        $cs = Get-CimInstance Win32_ComputerSystem -ErrorAction Stop
        if(!$cs.PartOfDomain){ return 'Skipped: computer is not domain joined' }
        $domain = [string]$cs.Domain
        Invoke-NTKSafeTextCommand 'nltest.exe' @('/dsgetdc:' + $domain) (Join-Path $root 'nltest-dsgetdc.txt') -TimeoutSeconds 45 | Out-Null
        Invoke-NTKSafeTextCommand 'nltest.exe' @('/sc_verify:' + $domain) (Join-Path $root 'nltest-sc-verify.txt') -TimeoutSeconds 45 | Out-Null
        if(Get-Command dcdiag.exe -ErrorAction SilentlyContinue){ Invoke-NTKSafeTextCommand 'dcdiag.exe' @('/q') (Join-Path $root 'dcdiag-q.txt') -TimeoutSeconds 120 | Out-Null }
        if(Get-Command repadmin.exe -ErrorAction SilentlyContinue){
            Invoke-NTKSafeTextCommand 'repadmin.exe' @('/replsummary') (Join-Path $root 'repadmin-replsummary.txt') -TimeoutSeconds 120 | Out-Null
            Invoke-NTKSafeTextCommand 'repadmin.exe' @('/showrepl','*') (Join-Path $root 'repadmin-showrepl.txt') -TimeoutSeconds 120 | Out-Null
        }
        if(Get-Command netdom.exe -ErrorAction SilentlyContinue){ Invoke-NTKSafeTextCommand 'netdom.exe' @('query','fsmo') (Join-Path $root 'netdom-fsmo.txt') -TimeoutSeconds 60 | Out-Null }
        'Domain joined; domain/DC commands attempted when tools were available'
    }

    Invoke-NTKCollectorSection $status 'DFSR And SYSVOL Checks' {
        $dfsr = Get-Service DFSR -ErrorAction SilentlyContinue
        $shares = @(if(Get-Command Get-SmbShare -ErrorAction SilentlyContinue){ Get-SmbShare -ErrorAction SilentlyContinue | Where-Object { $_.Name -in @('SYSVOL','NETLOGON') } | Select-Object Name,Path,Description })
        if(!$dfsr -and $shares.Count -eq 0){ return 'Skipped: DFSR service and SYSVOL/NETLOGON shares were not detected' }
        if(Get-Command dfsrdiag.exe -ErrorAction SilentlyContinue){
            Invoke-NTKSafeTextCommand 'dfsrdiag.exe' @('replicationstate') (Join-Path $root 'dfsr-replicationstate.txt') -TimeoutSeconds 90 | Out-Null
        }
        $events = @(Get-WinEvent -LogName 'DFS Replication' -MaxEvents 200 -ErrorAction SilentlyContinue | Select-Object TimeCreated,Id,LevelDisplayName,ProviderName,Message)
        Export-NTKSafeJson ([pscustomobject]@{Service=$dfsr;Shares=$shares;RecentEvents=$events}) (Join-Path $root 'dfsr-sysvol.json') | Out-Null
        "DFSR service detected: $([bool]$dfsr); SYSVOL/NETLOGON shares: $($shares.Count); DFSR events: $($events.Count)"
    }

    Invoke-NTKCollectorSection $status 'Group Policy Result' {
        Invoke-NTKSafeTextCommand 'gpresult.exe' @('/r') (Join-Path $root 'gpresult.txt') -TimeoutSeconds 90 | Out-Null
        $htmlPath = Join-Path $root 'gpresult.html'
        $tempHtml = Join-Path $env:TEMP ("ntk-gp-{0}.html" -f ([guid]::NewGuid().ToString('N').Substring(0,8)))
        Invoke-NTKSafeTextCommand 'gpresult.exe' @('/h',$tempHtml,'/f') (Join-Path $root 'gpresult-html-command.txt') -TimeoutSeconds 120 | Out-Null
        if(Test-Path -LiteralPath $tempHtml){
            Copy-Item -LiteralPath $tempHtml -Destination $htmlPath -Force -ErrorAction SilentlyContinue
            Remove-Item -LiteralPath $tempHtml -Force -ErrorAction SilentlyContinue
        }
        if(Test-Path -LiteralPath $htmlPath){ 'gpresult text and HTML exported' }else{ 'gpresult text exported; HTML was not created' }
    }

    Invoke-NTKCollectorSection $status 'Security Product Inventory' {
        $pattern = Get-NTKCollectorKeywordPattern
        $programs = @(Get-NTKInstalledProgramInventory | Where-Object { "$($_.DisplayName) $($_.Publisher)" -match $pattern })
        $services = @(Get-CimInstance Win32_Service -ErrorAction SilentlyContinue | Where-Object { "$($_.Name) $($_.DisplayName) $($_.PathName)" -match $pattern } | Select-Object Name,DisplayName,State,StartMode,StartName,PathName)
        $drivers = @(Get-CimInstance Win32_PnPSignedDriver -ErrorAction SilentlyContinue | Where-Object { "$($_.DeviceName) $($_.DriverProviderName) $($_.Manufacturer)" -match $pattern } | Select-Object DeviceName,Manufacturer,DriverProviderName,DriverVersion,DriverDate,InfName,IsSigned)
        $processes = @(Get-Process -ErrorAction SilentlyContinue | Where-Object { "$($_.Name) $(try{$_.Path}catch{''})" -match $pattern } | Select-Object Name,Id,Path)
        $bindings = @(if(Get-Command Get-NetAdapterBinding -ErrorAction SilentlyContinue){ Get-NetAdapterBinding -AllBindings -ErrorAction SilentlyContinue | Where-Object { "$($_.DisplayName) $($_.ComponentID) $($_.Name)" -match $pattern } | Select-Object Name,DisplayName,ComponentID,Enabled })
        $filterText = (Get-Content -LiteralPath (Join-Path $root 'filter-driver-summary.csv') -Raw -ErrorAction SilentlyContinue)
        $filterHits = @($filterText -split "`r?`n" | Where-Object { $_ -match $pattern } | ForEach-Object { [pscustomobject]@{Evidence=$_} })
        Export-NTKSafeJson ([pscustomobject]@{InstalledPrograms=$programs;Services=$services;Drivers=$drivers;FilterDrivers=$filterHits;NetworkBindings=$bindings;RunningProcesses=$processes}) (Join-Path $root 'security-product-inventory.json') | Out-Null
        Export-NTKSafeCsv $programs (Join-Path $root 'security-products-installed-programs.csv') | Out-Null
        "$($programs.Count) installed program(s); $($services.Count) service(s); $($drivers.Count) driver(s); $($processes.Count) process(es); $($bindings.Count) binding(s); $($filterHits.Count) filter hit(s)"
    }

    $toolkitVersion = try { Get-Content (Join-Path (Split-Path -Parent $NTKPaths.Root) 'manifests\toolkit-version.json') -Raw -ErrorAction Stop | ConvertFrom-Json } catch { $null }
    $domainOrWorkgroup = try { (Get-CimInstance Win32_ComputerSystem -ErrorAction Stop).Domain } catch { '' }
    $osVersion = try { $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop; "$($os.Caption) $($os.Version) Build $($os.BuildNumber)" } catch { '' }
    $manifestFiles = @(Get-ChildItem -LiteralPath $root -File -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne 'collection-manifest.json' } | ForEach-Object {
        $hash = try { (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256 -ErrorAction Stop).Hash } catch { "ERROR: $($_.Exception.Message)" }
        [pscustomobject]@{
            RelativePath = $_.FullName.Substring($root.Length).TrimStart('\')
            Size = $_.Length
            SHA256 = $hash
        }
    })

    $manifest = [pscustomobject]@{
        ToolkitVersion = $toolkitVersion
        CollectionStart = $started.ToString('s')
        CollectionEnd = (Get-Date).ToString('s')
        Hostname = $env:COMPUTERNAME
        DomainOrWorkgroup = $domainOrWorkgroup
        OSVersion = $osVersion
        PowerShellVersion = $PSVersionTable.PSVersion.ToString()
        Elevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        SectionsCompleted = @($status | Where-Object State -eq 'Completed' | Select-Object -ExpandProperty Section)
        SectionsFailed = @($status | Where-Object State -eq 'Failed' | Select-Object Section,Detail)
        SectionsSkipped = @($status | Where-Object State -eq 'Skipped' | Select-Object Section,Detail)
        Sections = $status
        Files = $manifestFiles
    }
    Export-NTKSafeJson $manifest (Join-Path $root 'collection-manifest.json') | Out-Null
    return $root
}
