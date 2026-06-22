function Global:Write-CSICollectorSectionStatus {
param([System.Collections.ArrayList]$Status,[string]$Name,[string]$State,[string]$Detail="")
    [void]$Status.Add([pscustomobject]@{ Section=$Name; State=$State; Detail=$Detail; Time=(Get-Date).ToString('s') })
}

function Global:Export-CSISafeJson { param($InputObject,[string]$Path) try { $InputObject | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $Path -Encoding UTF8; $true } catch { "ERROR: $($_.Exception.Message)" | Set-Content -LiteralPath $Path -Encoding UTF8; $false } }
function Global:Export-CSISafeCsv { param($InputObject,[string]$Path) try { @($InputObject) | Export-Csv -LiteralPath $Path -NoTypeInformation -Encoding UTF8; $true } catch { "ERROR: $($_.Exception.Message)" | Set-Content -LiteralPath $Path -Encoding UTF8; $false } }
function Global:Invoke-CSISafeTextCommand {
param([string]$FilePath,[string[]]$Arguments,[string]$Path)
    try { & $FilePath @Arguments 2>&1 | Out-String | Set-Content -LiteralPath $Path -Encoding UTF8; $true }
    catch { "ERROR: $($_.Exception.Message)" | Set-Content -LiteralPath $Path -Encoding UTF8; $false }
}

function Global:New-CSIAIDiagnosticCollection {
param([string]$ComputerName=$env:COMPUTERNAME)
    $root = Join-Path $CSIPaths.Exports ("AI-Collection-{0}-{1}" -f $ComputerName,(Get-Date -Format 'yyyyMMdd-HHmmss'))
    New-Item -ItemType Directory -Path $root -Force | Out-Null
    $status = New-Object System.Collections.ArrayList
    $started = Get-Date
    try {
        # A. Crash dump inventory: metadata only, never copies dump content.
        $dumpPaths=@('C:\ProgramData\Microsoft\Windows\WER','C:\Windows\Minidump','C:\Windows\LiveKernelReports')
        $dumps=@(); foreach($path in $dumpPaths){ if(Test-Path $path){ $dumps += Get-ChildItem $path -Recurse -File -ErrorAction SilentlyContinue | Select-Object FullName,Length,CreationTime,LastWriteTime,Extension } }
        Export-CSISafeCsv $dumps (Join-Path $root 'crash-dump-inventory.csv') | Out-Null
        $dumpSummary = @($dumps | Group-Object Extension | ForEach-Object { [pscustomobject]@{ Extension=$_.Name; Count=$_.Count } })
        Export-CSISafeJson ([pscustomobject]@{ Files=$dumps; Summary=$dumpSummary }) (Join-Path $root 'crash-dump-inventory.json') | Out-Null
        Write-CSICollectorSectionStatus $status 'Crash Dump Inventory' 'Completed' "$($dumps.Count) file(s) inventoried"

        # B. Driver inventory, including categories useful during root-cause review.
        $drivers=@(Get-CimInstance Win32_PnPSignedDriver -ErrorAction Stop | Select-Object DeviceName,Manufacturer,DriverProviderName,DriverVersion,DriverDate,InfName,IsSigned,DeviceClass,DeviceID)
        Export-CSISafeCsv $drivers (Join-Path $root 'driver-inventory.csv') | Out-Null; Export-CSISafeJson $drivers (Join-Path $root 'driver-inventory.json') | Out-Null
        $driverFocus=@($drivers|Where-Object { "$($_.DeviceName) $($_.DeviceClass) $($_.DriverProviderName)" -match '(?i)network|ethernet|wifi|wireless|storage|raid|nvme|display|hyper-v|vpn|filter|security' })
        Export-CSISafeJson $driverFocus (Join-Path $root 'driver-focus.json') | Out-Null; Write-CSICollectorSectionStatus $status 'Driver Inventory' 'Completed' "$($drivers.Count) drivers; $($driverFocus.Count) focus drivers"
    } catch { Write-CSICollectorSectionStatus $status 'Driver Inventory' 'Failed' $_.Exception.Message }
    try { Invoke-CSISafeTextCommand 'fltmc.exe' @('filters') (Join-Path $root 'filter-drivers.txt') | Out-Null; Invoke-CSISafeTextCommand 'fltmc.exe' @('instances') (Join-Path $root 'filter-instances.txt') | Out-Null; Write-CSICollectorSectionStatus $status 'Filter Drivers' 'Completed' } catch { Write-CSICollectorSectionStatus $status 'Filter Drivers' 'Failed' $_.Exception.Message }
    try {
        $net=@{Adapters=@(Get-NetAdapter -ErrorAction Stop);Bindings=@(Get-NetAdapterBinding -AllBindings -ErrorAction SilentlyContinue);IP=@(Get-NetIPConfiguration -ErrorAction SilentlyContinue);Routes=@(Get-NetRoute -ErrorAction SilentlyContinue);Dns=@(Get-DnsClientServerAddress -ErrorAction SilentlyContinue);Nrpt=@(Get-DnsClientNrptPolicy -ErrorAction SilentlyContinue)}
        Export-CSISafeJson $net (Join-Path $root 'network-stack.json') | Out-Null; Invoke-CSISafeTextCommand 'ipconfig.exe' @('/all') (Join-Path $root 'ipconfig-all.txt') | Out-Null; Invoke-CSISafeTextCommand 'route.exe' @('print') (Join-Path $root 'route-print.txt') | Out-Null; Invoke-CSISafeTextCommand 'netcfg.exe' @('-s','n') (Join-Path $root 'netcfg-bindings.txt') | Out-Null; Write-CSICollectorSectionStatus $status 'Network Stack And Bindings' 'Completed'
    } catch { Write-CSICollectorSectionStatus $status 'Network Stack And Bindings' 'Failed' $_.Exception.Message }
    try {
        $processes=@(Get-Process -ErrorAction SilentlyContinue|ForEach-Object { [pscustomobject]@{Name=$_.Name;PID=$_.Id;CPU=$_.CPU;WorkingSet=$_.WorkingSet64;PrivateMemory=$_.PrivateMemorySize64;Handles=$_.HandleCount;Path=$(try{$_.Path}catch{''});StartTime=$(try{$_.StartTime}catch{''})} })
        Export-CSISafeJson ([pscustomobject]@{TopCPU=@($processes|Sort-Object CPU -Descending|Select-Object -First 25);TopWorkingSet=@($processes|Sort-Object WorkingSet -Descending|Select-Object -First 25);TopPrivateMemory=@($processes|Sort-Object PrivateMemory -Descending|Select-Object -First 25);TopHandles=@($processes|Sort-Object Handles -Descending|Select-Object -First 25)}) (Join-Path $root 'process-performance.json') | Out-Null; Write-CSICollectorSectionStatus $status 'Process Performance Snapshot' 'Completed'
    } catch { Write-CSICollectorSectionStatus $status 'Process Performance Snapshot' 'Failed' $_.Exception.Message }
    try {
        $services=@(Get-CimInstance Win32_Service -ErrorAction Stop|Select-Object Name,DisplayName,State,StartMode,StartName,PathName); Export-CSISafeCsv $services (Join-Path $root 'services.csv')|Out-Null; Export-CSISafeJson $services (Join-Path $root 'services.json')|Out-Null
        $startup=@(); foreach($key in @('HKLM:\Software\Microsoft\Windows\CurrentVersion\Run','HKCU:\Software\Microsoft\Windows\CurrentVersion\Run')){if(Test-Path $key){$startup+=Get-ItemProperty $key|Select-Object *}}; Export-CSISafeJson ([pscustomobject]@{Services=$services;StoppedAutomatic=@($services|Where-Object{$_.StartMode -eq 'Auto' -and $_.State -ne 'Running'});RunKeys=$startup;ScheduledTasks=@(Get-ScheduledTask -ErrorAction SilentlyContinue|Where-Object{$_.State -ne 'Disabled'}|Select-Object TaskName,TaskPath,State)}) (Join-Path $root 'services-startup.json')|Out-Null; Write-CSICollectorSectionStatus $status 'Services And Startup' 'Completed'
    } catch { Write-CSICollectorSectionStatus $status 'Services And Startup' 'Failed' $_.Exception.Message }
    try {
        $events=@(); foreach($log in 'System','Application'){try{$events+=Get-WinEvent -FilterHashtable @{LogName=$log;StartTime=(Get-Date).AddDays(-30);Level=1,2,3} -MaxEvents 500 -ErrorAction Stop|ForEach-Object{[pscustomobject]@{TimeCreated=$_.TimeCreated;LogName=$_.LogName;ProviderName=$_.ProviderName;Id=$_.Id;LevelDisplayName=$_.LevelDisplayName;Message=$_.Message}}}catch{}}
        Export-CSISafeJson $events (Join-Path $root 'event-timeline.json')|Out-Null; Export-CSISafeCsv ($events|Group-Object ProviderName,Id,LevelDisplayName|ForEach-Object{[pscustomobject]@{Group=$_.Name;Count=$_.Count}}) (Join-Path $root 'event-summary.csv')|Out-Null; Write-CSICollectorSectionStatus $status 'Event Timeline' 'Completed' "$($events.Count) events"
    } catch { Write-CSICollectorSectionStatus $status 'Event Timeline' 'Failed' $_.Exception.Message }
    try { $cs=Get-CimInstance Win32_ComputerSystem; if($cs.PartOfDomain -and (Get-Command dcdiag.exe -ErrorAction SilentlyContinue)){Invoke-CSISafeTextCommand 'dcdiag.exe' @('/q') (Join-Path $root 'dcdiag.txt')|Out-Null; Invoke-CSISafeTextCommand 'repadmin.exe' @('/replsummary') (Join-Path $root 'repadmin-replsummary.txt')|Out-Null; Invoke-CSISafeTextCommand 'nltest.exe' @('/dsgetdc:'+$cs.Domain) (Join-Path $root 'nltest-dc.txt')|Out-Null; Write-CSICollectorSectionStatus $status 'Domain Controller Checks' 'Completed'}else{Write-CSICollectorSectionStatus $status 'Domain Controller Checks' 'Skipped' 'Not applicable or tools unavailable'}} catch {Write-CSICollectorSectionStatus $status 'Domain Controller Checks' 'Failed' $_.Exception.Message}
    try { $dfsr=Get-Service DFSR -ErrorAction SilentlyContinue; if($dfsr){ Invoke-CSISafeTextCommand 'dfsrdiag.exe' @('replicationstate') (Join-Path $root 'dfsr-replicationstate.txt')|Out-Null; Export-CSISafeJson ([pscustomobject]@{Service=$dfsr;Shares=@(Get-SmbShare -ErrorAction SilentlyContinue|Where-Object{$_.Name -in 'SYSVOL','NETLOGON'});Events=@(Get-WinEvent -LogName 'DFS Replication' -MaxEvents 200 -ErrorAction SilentlyContinue|Select-Object TimeCreated,Id,LevelDisplayName,Message)}) (Join-Path $root 'dfsr-sysvol.json')|Out-Null; Write-CSICollectorSectionStatus $status 'DFSR And SYSVOL Checks' 'Completed'}else{Write-CSICollectorSectionStatus $status 'DFSR And SYSVOL Checks' 'Skipped' 'DFSR service unavailable'}} catch {Write-CSICollectorSectionStatus $status 'DFSR And SYSVOL Checks' 'Failed' $_.Exception.Message}
    try { $keywords='Sophos|SentinelOne|Huntress|Defender|CrowdStrike|Carbon Black|Bitdefender|Webroot|Malwarebytes|Cisco Secure|SonicWall|NetExtender|OpenVPN|WireGuard|Tailscale|Veeam|Datto|Acronis|Cove|N-able'; $security=@(Get-Process -ErrorAction SilentlyContinue|Where-Object{$_.Name -match $keywords}|Select-Object Name,Id,Path); Export-CSISafeJson $security (Join-Path $root 'security-product-inventory.json')|Out-Null; Write-CSICollectorSectionStatus $status 'Security Product Inventory' 'Completed' "$($security.Count) matching process(es)"} catch {Write-CSICollectorSectionStatus $status 'Security Product Inventory' 'Failed' $_.Exception.Message}
    Invoke-CSISafeTextCommand 'gpresult.exe' @('/r') (Join-Path $root 'gpresult.txt')|Out-Null; Invoke-CSISafeTextCommand 'gpresult.exe' @('/h',(Join-Path $root 'gpresult.html')) (Join-Path $root 'gpresult-html-command.txt')|Out-Null; Write-CSICollectorSectionStatus $status 'Group Policy Result' 'Completed'
    $manifest=[pscustomobject]@{ToolkitVersion=(Get-Content (Join-Path (Split-Path -Parent $CSIPaths.Root) 'manifests\toolkit-version.json') -Raw -ErrorAction SilentlyContinue|ConvertFrom-Json);CollectionStart=$started.ToString('s');CollectionEnd=(Get-Date).ToString('s');Hostname=$env:COMPUTERNAME;Domain=(Get-CimInstance Win32_ComputerSystem).Domain;OS=(Get-CimInstance Win32_OperatingSystem).Caption;PowerShell=$PSVersionTable.PSVersion.ToString();Elevated=([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator);Sections=$status;Files=@(Get-ChildItem $root -File|ForEach-Object{[pscustomobject]@{Name=$_.Name;Size=$_.Length;SHA256=(Get-FileHash $_.FullName -Algorithm SHA256).Hash}})}; Export-CSISafeJson $manifest (Join-Path $root 'collection-manifest.json')|Out-Null
    return $root
}
