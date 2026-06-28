function Global:Get-NTKTriageAppRoot {
    if($NTKPaths -and $NTKPaths.Root){
        return (Split-Path -Parent $NTKPaths.Root)
    }
    return (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
}

function Global:Get-NTKTriagePaths {
    $appRoot = Get-NTKTriageAppRoot
    $triageRoot = Join-Path $appRoot "Triage"
    return [pscustomobject]@{
        AppRoot = $appRoot
        Root = $triageRoot
        Tools = Join-Path $triageRoot "Tools"
        Profiles = Join-Path $triageRoot "Profiles"
        Runs = Join-Path $triageRoot "Runs"
        Templates = Join-Path $triageRoot "Templates"
        Manifests = Join-Path $appRoot "manifests"
        Manifest = Join-Path $appRoot "manifests\triage-tools.json"
        Cache = Join-Path $appRoot "cache\triage"
        Logs = Join-Path $appRoot "logs"
        UiLog = Join-Path $appRoot "logs\triage-ui.log"
    }
}

function Global:Initialize-NTKTriageStructure {
    $paths = Get-NTKTriagePaths
    foreach($path in @($paths.Root,$paths.Tools,$paths.Profiles,$paths.Runs,$paths.Templates,$paths.Manifests,$paths.Cache,$paths.Logs)){
        if(!(Test-Path -LiteralPath $path)){
            New-Item -ItemType Directory -Path $path -Force | Out-Null
        }
    }
    if(!(Test-Path -LiteralPath $paths.Manifest)){
        New-NTKDefaultTriageManifest | Save-NTKTriageManifest -Path $paths.Manifest
    }
    return $paths
}

function Global:Write-NTKTriageLog {
    param([string]$Message,[string]$RunLog)
    $paths = Get-NTKTriagePaths
    if(!(Test-Path -LiteralPath $paths.Logs)){ New-Item -ItemType Directory -Path $paths.Logs -Force | Out-Null }
    $line = "{0}`t{1}" -f (Get-Date).ToString("s"),$Message
    Add-Content -LiteralPath $paths.UiLog -Value $line -Encoding UTF8 -ErrorAction SilentlyContinue
    if($RunLog){
        Add-Content -LiteralPath $RunLog -Value $line -Encoding UTF8 -ErrorAction SilentlyContinue
    }
}

function Global:New-NTKDefaultTriageManifest {
    $tools = @(
        @{name="Microsoft TSS Toolset";id="tss";category="Triage";source="Microsoft";downloadUrl="https://learn.microsoft.com/en-us/troubleshoot/windows-client/windows-tss/introduction-to-troubleshootingscript-toolset-tss";localPath=".\Triage\Tools\TSS";executables=@(@{name="TSS";path=".\Triage\Tools\TSS\TSS.ps1";arguments="";outputFile="ToolOutput\tss.txt";captureStdout=$true;autoRun=$false;requiresConsent=$true});required=$false;portable=$true;notes="Optional long-running Microsoft collector."}
        @{name="Sysinternals Suite";id="sysinternals";category="Triage";source="Microsoft";downloadUrl="https://learn.microsoft.com/en-us/sysinternals/downloads/sysinternals-suite";localPath=".\Triage\Tools\Sysinternals";executables=@(
            @{name="Autoruns";path=".\Triage\Tools\Sysinternals\autorunsc.exe";arguments="-accepteula -a * -ct -h -s -m";outputFile="ToolOutput\autoruns.csv";captureStdout=$true;autoRun=$true},
            @{name="PsInfo";path=".\Triage\Tools\Sysinternals\psinfo.exe";arguments="-accepteula -s -d";outputFile="ToolOutput\psinfo.txt";captureStdout=$true;autoRun=$true},
            @{name="PsList";path=".\Triage\Tools\Sysinternals\pslist.exe";arguments="-accepteula";outputFile="ToolOutput\pslist.txt";captureStdout=$true;autoRun=$true},
            @{name="PsService";path=".\Triage\Tools\Sysinternals\psservice.exe";arguments="-accepteula";outputFile="ToolOutput\psservice.txt";captureStdout=$true;autoRun=$true},
            @{name="Handle";path=".\Triage\Tools\Sysinternals\handle.exe";arguments="-accepteula -a";outputFile="ToolOutput\handle.txt";captureStdout=$true;autoRun=$false},
            @{name="ListDLLs";path=".\Triage\Tools\Sysinternals\listdlls.exe";arguments="-accepteula";outputFile="ToolOutput\listdlls.txt";captureStdout=$true;autoRun=$true},
            @{name="TCPView Console";path=".\Triage\Tools\Sysinternals\tcpvcon.exe";arguments="-accepteula -a -c";outputFile="ToolOutput\tcpvcon.csv";captureStdout=$true;autoRun=$true},
            @{name="Sigcheck";path=".\Triage\Tools\Sysinternals\sigcheck.exe";arguments="-accepteula -nobanner -q -m c:\windows\system32";outputFile="ToolOutput\sigcheck_system32.txt";captureStdout=$true;autoRun=$false},
            @{name="ProcDump";path=".\Triage\Tools\Sysinternals\procdump.exe";arguments="-accepteula";outputFile="ToolOutput\procdump.txt";captureStdout=$true;autoRun=$false;requiresConsent=$true}
        );required=$false;portable=$true;notes="Endpoint tools may be blocked by security software."}
        @{name="FullEventLogView";id="fulleventlogview";category="Triage";source="NirSoft";downloadUrl="https://www.nirsoft.net/utils/full_event_log_view.html";localPath=".\Triage\Tools\FullEventLogView";executables=@(@{name="FullEventLogView";path=".\Triage\Tools\FullEventLogView\FullEventLogView.exe";arguments="/scomma ToolOutput\fulleventlogview.csv";outputFile="ToolOutput\fulleventlogview.csv";captureStdout=$false;autoRun=$true});required=$false;portable=$true}
        @{name="EventLogChannelsView";id="eventlogchannelsview";category="Triage";source="NirSoft";downloadUrl="https://www.nirsoft.net/utils/event_log_channels_view.html";localPath=".\Triage\Tools\EventLogChannelsView";executables=@(@{name="EventLogChannelsView";path=".\Triage\Tools\EventLogChannelsView\EventLogChannelsView.exe";arguments="/scomma ToolOutput\eventlogchannels.csv";outputFile="ToolOutput\eventlogchannels.csv";captureStdout=$false;autoRun=$true});required=$false;portable=$true}
        @{name="BlueScreenView";id="bluescreenview";category="Triage";source="NirSoft";downloadUrl="https://www.nirsoft.net/utils/blue_screen_view.html";localPath=".\Triage\Tools\BlueScreenView";executables=@(@{name="BlueScreenView";path=".\Triage\Tools\BlueScreenView\BlueScreenView.exe";arguments="/scomma ToolOutput\bluescreenview.csv";outputFile="ToolOutput\bluescreenview.csv";captureStdout=$false;autoRun=$true});required=$false;portable=$true}
        @{name="AppCrashView";id="appcrashview";category="Triage";source="NirSoft";downloadUrl="https://www.nirsoft.net/utils/app_crash_view.html";localPath=".\Triage\Tools\AppCrashView";executables=@(@{name="AppCrashView";path=".\Triage\Tools\AppCrashView\AppCrashView.exe";arguments="/scomma ToolOutput\appcrashview.csv";outputFile="ToolOutput\appcrashview.csv";captureStdout=$false;autoRun=$true});required=$false;portable=$true}
        @{name="DriverView";id="driverview";category="Triage";source="NirSoft";downloadUrl="https://www.nirsoft.net/utils/driverview.html";localPath=".\Triage\Tools\DriverView";executables=@(@{name="DriverView";path=".\Triage\Tools\DriverView\DriverView.exe";arguments="/scomma ToolOutput\driverview.csv";outputFile="ToolOutput\driverview.csv";captureStdout=$false;autoRun=$true});required=$false;portable=$true}
        @{name="ServiWin";id="serviwin";category="Triage";source="NirSoft";downloadUrl="https://www.nirsoft.net/utils/serviwin.html";localPath=".\Triage\Tools\ServiWin";executables=@(@{name="ServiWin";path=".\Triage\Tools\ServiWin\ServiWin.exe";arguments="/scomma ToolOutput\serviwin.csv";outputFile="ToolOutput\serviwin.csv";captureStdout=$false;autoRun=$true});required=$false;portable=$true}
        @{name="USBDeview";id="usbdeview";category="Triage";source="NirSoft";downloadUrl="https://www.nirsoft.net/utils/usb_devices_view.html";localPath=".\Triage\Tools\USBDeview";executables=@(@{name="USBDeview";path=".\Triage\Tools\USBDeview\USBDeview.exe";arguments="/scomma ToolOutput\usbdeview.csv";outputFile="ToolOutput\usbdeview.csv";captureStdout=$false;autoRun=$true});required=$false;portable=$true}
        @{name="NetworkInterfacesView";id="networkinterfacesview";category="Triage";source="NirSoft";downloadUrl="https://www.nirsoft.net/utils/network_interfaces.html";localPath=".\Triage\Tools\NetworkInterfacesView";executables=@(@{name="NetworkInterfacesView";path=".\Triage\Tools\NetworkInterfacesView\NetworkInterfacesView.exe";arguments="/scomma ToolOutput\networkinterfaces.csv";outputFile="ToolOutput\networkinterfaces.csv";captureStdout=$false;autoRun=$true});required=$false;portable=$true}
        @{name="CurrPorts";id="currports";category="Triage";source="NirSoft";downloadUrl="https://www.nirsoft.net/utils/cports.html";localPath=".\Triage\Tools\CurrPorts";executables=@(@{name="CurrPorts";path=".\Triage\Tools\CurrPorts\cports.exe";arguments="/scomma ToolOutput\currports.csv";outputFile="ToolOutput\currports.csv";captureStdout=$false;autoRun=$true});required=$false;portable=$true}
        @{name="ESET SysInspector";id="eset-sysinspector";category="Triage";source="ESET";downloadUrl="https://www.eset.com/int/support/sysinspector/";localPath=".\Triage\Tools\ESET SysInspector";executables=@(@{name="ESET SysInspector";path=".\Triage\Tools\ESET SysInspector\SysInspector.exe";arguments="/gen ToolOutput\eset-sysinspector.xml";outputFile="ToolOutput\eset-sysinspector.xml";captureStdout=$false;autoRun=$true});required=$false;portable=$true}
        @{name="FRST";id="frst";category="Triage";source="BleepingComputer";downloadUrl="https://www.bleepingcomputer.com/download/farbar-recovery-scan-tool/";localPath=".\Triage\Tools\FRST";executables=@(@{name="FRST";path=".\Triage\Tools\FRST\FRST64.exe";arguments="";outputFile="ToolOutput\FRST.txt";captureStdout=$false;autoRun=$false;requiresConsent=$true});required=$false;portable=$true;notes="Security-sensitive. Requires explicit consent."}
        @{name="HWiNFO Portable";id="hwinfo";category="Triage";source="HWiNFO";downloadUrl="https://www.hwinfo.com/download/";localPath=".\Triage\Tools\HWiNFO";executables=@(@{name="HWiNFO";path=".\Triage\Tools\HWiNFO\HWiNFO64.exe";arguments="";outputFile="ToolOutput\hwinfo.txt";captureStdout=$false;autoRun=$false});required=$false;portable=$true}
        @{name="CrystalDiskInfo Portable";id="crystaldiskinfo";category="Triage";source="PortableApps.com";downloadUrl="https://portableapps.com/apps/utilities/crystaldiskinfo_portable";localPath=".\Triage\Tools\CrystalDiskInfo";executables=@(@{name="CrystalDiskInfo";path=".\Triage\Tools\CrystalDiskInfo\DiskInfo64.exe";arguments="/CopyExit";outputFile="ToolOutput\crystaldiskinfo.txt";captureStdout=$false;autoRun=$false});required=$false;portable=$true}
        @{name="WinAudit";id="winaudit";category="Triage";source="Parmavex";downloadUrl="https://www.parmavex.co.uk/winaudit.html";localPath=".\Triage\Tools\WinAudit";executables=@(@{name="WinAudit";path=".\Triage\Tools\WinAudit\WinAudit.exe";arguments="/r=gsoPxuTUeERNtnzDaIbMpmidcSArCOHG /f=ToolOutput\winaudit.html";outputFile="ToolOutput\winaudit.html";captureStdout=$false;autoRun=$true});required=$false;portable=$true}
        @{name="MiTeC System Information X";id="mitec-msi";category="Triage";source="MiTeC";downloadUrl="https://www.mitec.cz/msi.html";localPath=".\Triage\Tools\MiTeC";executables=@(@{name="MiTeC System Information X";path=".\Triage\Tools\MiTeC\MSIX64.exe";arguments="";outputFile="ToolOutput\mitec.txt";captureStdout=$false;autoRun=$false});required=$false;portable=$true}
        @{name="WinMTR Portable";id="winmtr";category="Triage";source="PortableApps.com";downloadUrl="https://portableapps.com/apps/utilities/winmtr_portable";localPath=".\Triage\Tools\WinMTR";executables=@(@{name="WinMTR";path=".\Triage\Tools\WinMTR\WinMTR.exe";arguments="";outputFile="ToolOutput\winmtr.txt";captureStdout=$false;autoRun=$false});required=$false;portable=$true}
        @{name="Wireshark Portable";id="wireshark";category="Triage";source="PortableApps.com";downloadUrl="https://portableapps.com/apps/internet/wireshark_portable";localPath=".\Triage\Tools\Wireshark";executables=@(@{name="Wireshark";path=".\Triage\Tools\Wireshark\WiresharkPortable.exe";arguments="";outputFile="ToolOutput\wireshark.txt";captureStdout=$false;autoRun=$false;requiresConsent=$true});required=$false;portable=$true;notes="Packet captures are large and sensitive."}
        @{name="LatencyMon";id="latencymon";category="Triage";source="Resplendence";downloadUrl="https://www.resplendence.com/latencymon";localPath=".\Triage\Tools\LatencyMon";executables=@(@{name="LatencyMon";path=".\Triage\Tools\LatencyMon\LatMon.exe";arguments="";outputFile="ToolOutput\latencymon.txt";captureStdout=$false;autoRun=$false});required=$false;portable=$true}
    )
    return [pscustomobject]@{schemaVersion="1.0";updatedUtc=(Get-Date).ToUniversalTime().ToString("o");tools=$tools}
}

function Global:Save-NTKTriageManifest {
    param([Parameter(ValueFromPipeline=$true)]$Manifest,[string]$Path)
    process {
        if(!$Path){ $Path = (Get-NTKTriagePaths).Manifest }
        $folder = Split-Path -Parent $Path
        if(!(Test-Path -LiteralPath $folder)){ New-Item -ItemType Directory -Path $folder -Force | Out-Null }
        if(Test-Path -LiteralPath $Path){
            Copy-Item -LiteralPath $Path -Destination "$Path.bak" -Force -ErrorAction SilentlyContinue
        }
        $tmp = "$Path.tmp"
        $Manifest | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $tmp -Encoding UTF8
        Move-Item -LiteralPath $tmp -Destination $Path -Force
        return $Path
    }
}

function Global:Get-NTKTriageManifest {
    $paths = Initialize-NTKTriageStructure
    try {
        return (Get-Content -LiteralPath $paths.Manifest -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop)
    }
    catch {
        Write-NTKTriageLog "Triage manifest recovery used defaults: $($_.Exception.Message)"
        $manifest = New-NTKDefaultTriageManifest
        $manifest | Save-NTKTriageManifest -Path $paths.Manifest | Out-Null
        return $manifest
    }
}

function Global:Resolve-NTKTriageToolPath {
    param([string]$Path,[hashtable]$PathIndex,[switch]$SkipRecursiveSearch)
    if([string]::IsNullOrWhiteSpace($Path)){ return $null }
    $appRoot = Get-NTKTriageAppRoot
    $relative = $Path.Trim()
    $candidates = New-Object System.Collections.Generic.List[string]
    if([IO.Path]::IsPathRooted($relative)){ [void]$candidates.Add($relative) }
    else {
        [void]$candidates.Add((Join-Path $appRoot ($relative.TrimStart(".","\","/"))))
        [void]$candidates.Add((Join-Path (Join-Path $appRoot "NetworkToolkit\ExternalTools") ([IO.Path]::GetFileName($relative))))
        [void]$candidates.Add((Join-Path (Join-Path $appRoot "Custom") ([IO.Path]::GetFileName($relative))))
    }
    foreach($candidate in $candidates){
        if(Test-Path -LiteralPath $candidate){ return (Get-Item -LiteralPath $candidate).FullName }
    }
    $fileName = [IO.Path]::GetFileName($relative)
    if($fileName -and $PathIndex -and $PathIndex.ContainsKey($fileName.ToLowerInvariant())){
        return $PathIndex[$fileName.ToLowerInvariant()]
    }
    if(!$SkipRecursiveSearch -and $fileName){
        foreach($root in @((Join-Path $appRoot "Triage\Tools"),(Join-Path $appRoot "NetworkToolkit\ExternalTools"),(Join-Path $appRoot "Custom"))){
            $match = Get-ChildItem -LiteralPath $root -Filter $fileName -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if($match){ return $match.FullName }
        }
    }
    return $null
}

function Global:New-NTKTriageToolPathIndex {
    param([string[]]$ExpectedFileNames = @())
    $appRoot = Get-NTKTriageAppRoot
    $index = @{}
    $expected = @{}
    foreach($name in @($ExpectedFileNames)){
        if($name){ $expected[$name.ToLowerInvariant()] = $true }
    }
    $addIfExpected = {
        param($File)
        if(!$File){ return }
        $key = $File.Name.ToLowerInvariant()
        if($expected.Count -gt 0 -and !$expected.ContainsKey($key)){ return }
        if(!$index.ContainsKey($key)){
            $index[$key] = $File.FullName
        }
    }
    foreach($root in @((Join-Path $appRoot "Triage\Tools"),(Join-Path $appRoot "NetworkToolkit\ExternalTools"),(Join-Path $appRoot "Custom"))){
        if(!(Test-Path -LiteralPath $root)){ continue }
        foreach($file in @(Get-ChildItem -LiteralPath $root -File -ErrorAction SilentlyContinue)){
            & $addIfExpected $file
        }
        foreach($dir in @(Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue)){
            foreach($file in @(Get-ChildItem -LiteralPath $dir.FullName -File -ErrorAction SilentlyContinue)){
                & $addIfExpected $file
            }
            foreach($childDir in @(Get-ChildItem -LiteralPath $dir.FullName -Directory -ErrorAction SilentlyContinue)){
                foreach($file in @(Get-ChildItem -LiteralPath $childDir.FullName -File -ErrorAction SilentlyContinue)){
                    & $addIfExpected $file
                }
            }
        }
    }
    return $index
}

function Global:Get-NTKTriageToolStatus {
    param([switch]$Deep)
    $manifest = Get-NTKTriageManifest
    $expectedNames = @($manifest.tools | ForEach-Object { $_.executables } | ForEach-Object { [IO.Path]::GetFileName([string]$_.path) } | Where-Object { $_ } | Select-Object -Unique)
    $pathIndex = New-NTKTriageToolPathIndex -ExpectedFileNames $expectedNames
    foreach($tool in @($manifest.tools)){
        $present = $false
        $exeStatuses = @()
        foreach($exe in @($tool.executables)){
            $resolved = Resolve-NTKTriageToolPath -Path $exe.path -PathIndex $pathIndex -SkipRecursiveSearch:(!$Deep)
            if($resolved){ $present = $true }
            $exeStatuses += [pscustomobject]@{name=$exe.name;configuredPath=$exe.path;resolvedPath=$resolved;present=[bool]$resolved;autoRun=[bool]$exe.autoRun;requiresConsent=[bool]$exe.requiresConsent}
        }
        [pscustomobject]@{name=$tool.name;id=$tool.id;source=$tool.source;downloadUrl=$tool.downloadUrl;required=[bool]$tool.required;present=$present;status=$(if($present){"Present"}elseif($tool.required){"Missing Required"}else{"Missing Optional"});executables=$exeStatuses;notes=$tool.notes}
    }
}

function Global:New-NTKTriageRunFolder {
    param([string]$Profile="Quick")
    $paths = Initialize-NTKTriageStructure
    $stamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
    $computer = ($env:COMPUTERNAME -replace '[^\w.-]','_')
    $runId = "{0}_{1}" -f $computer,$stamp
    $run = Join-Path $paths.Runs $runId
    foreach($child in @("CollectedFiles","CommandOutput","ToolOutput","EventLogs","Dumps","Reports","Analysis","Metadata","Bundle")){
        New-Item -ItemType Directory -Path (Join-Path $run $child) -Force | Out-Null
    }
    return [pscustomobject]@{RunId=$runId;Path=$run;Profile=$Profile;RunLog=(Join-Path $run "run.log")}
}

function Global:Invoke-NTKTriageCommand {
    param([string]$Name,[string]$FilePath,[string]$Arguments,[string]$OutputPath,[int]$TimeoutSeconds=120,[string]$RunLog)
    $started = Get-Date
    $errPath = [IO.Path]::ChangeExtension($OutputPath,".stderr.txt")
    $result = [ordered]@{commandName=$Name;executable=$FilePath;arguments=$Arguments;outputPath=$OutputPath;errorPath=$errPath;exitCode=$null;startedUtc=$started.ToUniversalTime().ToString("o");endedUtc=$null;durationSeconds=0;timedOut=$false;succeeded=$false}
    try {
        if([string]::IsNullOrWhiteSpace($FilePath)){
            throw "No executable was supplied for $Name."
        }
        if($FilePath -match '[\\/:]' -and !(Test-Path -LiteralPath $FilePath)){
            throw "Executable was not found: $FilePath"
        }
        $outFolder = Split-Path -Parent $OutputPath
        if($outFolder -and !(Test-Path -LiteralPath $outFolder)){ New-Item -ItemType Directory -Path $outFolder -Force | Out-Null }
        Write-NTKTriageLog "Command started: $Name $FilePath $Arguments" $RunLog
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $FilePath
        $psi.Arguments = $Arguments
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.CreateNoWindow = $true
        $psi.WorkingDirectory = Split-Path -Parent $OutputPath
        $p = New-Object System.Diagnostics.Process
        $p.StartInfo = $psi
        [void]$p.Start()
        $stdoutTask = $p.StandardOutput.ReadToEndAsync()
        $stderrTask = $p.StandardError.ReadToEndAsync()
        if(!$p.WaitForExit($TimeoutSeconds * 1000)){
            $result.timedOut = $true
            try { $p.Kill() } catch {}
        }
        else {
            $p.WaitForExit()
        }
        try {
            $stdoutTask.Wait(5000) | Out-Null
            $stderrTask.Wait(5000) | Out-Null
        } catch {}
        $stdoutTask.Result | Set-Content -LiteralPath $OutputPath -Encoding UTF8
        $stderrTask.Result | Set-Content -LiteralPath $errPath -Encoding UTF8
        $result.exitCode = if($result.timedOut){-1}else{$p.ExitCode}
        $result.succeeded = (!$result.timedOut -and $p.ExitCode -eq 0)
    }
    catch {
        $_.Exception.Message | Set-Content -LiteralPath $errPath -Encoding UTF8
        $result.exitCode = -999
        $result.succeeded = $false
        Write-NTKTriageLog "Command failed: $Name $($_.Exception.Message)" $RunLog
    }
    $ended = Get-Date
    $result.endedUtc = $ended.ToUniversalTime().ToString("o")
    $result.durationSeconds = [Math]::Round(($ended - $started).TotalSeconds,2)
    Write-NTKTriageLog "Command completed: $Name exit=$($result.exitCode) seconds=$($result.durationSeconds)" $RunLog
    return [pscustomobject]$result
}

function Global:Export-NTKTriagePowerShellObject {
    param([string]$Name,[scriptblock]$ScriptBlock,[string]$TxtPath,[string]$JsonPath,[string]$RunLog)
    try {
        Write-NTKTriageLog "PowerShell collector started: $Name" $RunLog
        $data = & $ScriptBlock
        $data | Out-String -Width 260 | Set-Content -LiteralPath $TxtPath -Encoding UTF8
        $data | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $JsonPath -Encoding UTF8
        Write-NTKTriageLog "PowerShell collector completed: $Name" $RunLog
        return [pscustomobject]@{name=$Name;succeeded=$true;txt=$TxtPath;json=$JsonPath;error=$null}
    }
    catch {
        $_.Exception.Message | Set-Content -LiteralPath $TxtPath -Encoding UTF8
        Write-NTKTriageLog "PowerShell collector failed: $Name $($_.Exception.Message)" $RunLog
        return [pscustomobject]@{name=$Name;succeeded=$false;txt=$TxtPath;json=$JsonPath;error=$_.Exception.Message}
    }
}

function Global:Get-NTKTriageCommandPlan {
    param([string]$Profile)
    $normal = @(
        @{Name="hostname";Exe="cmd.exe";Args="/c hostname";Out="hostname.txt";Timeout=30},
        @{Name="whoami_all";Exe="whoami.exe";Args="/all";Out="whoami_all.txt";Timeout=30},
        @{Name="windows_version";Exe="cmd.exe";Args="/c ver";Out="windows_version.txt";Timeout=30},
        @{Name="systeminfo";Exe="systeminfo.exe";Args="";Out="systeminfo.txt";Timeout=120},
        @{Name="ipconfig_all";Exe="ipconfig.exe";Args="/all";Out="ipconfig_all.txt";Timeout=30},
        @{Name="route_print";Exe="route.exe";Args="print";Out="route_print.txt";Timeout=30},
        @{Name="arp_a";Exe="arp.exe";Args="-a";Out="arp_a.txt";Timeout=30},
        @{Name="netstat_ano";Exe="netstat.exe";Args="-ano";Out="netstat_ano.txt";Timeout=60},
        @{Name="tasklist_verbose";Exe="tasklist.exe";Args="/v";Out="tasklist_verbose.txt";Timeout=60},
        @{Name="tasklist_services";Exe="tasklist.exe";Args="/svc";Out="tasklist_services.txt";Timeout=60},
        @{Name="services_all";Exe="sc.exe";Args="query type= service state= all";Out="services_all.txt";Timeout=60},
        @{Name="drivers_all";Exe="sc.exe";Args="query type= driver state= all";Out="drivers_all.txt";Timeout=60},
        @{Name="driverquery_verbose";Exe="driverquery.exe";Args="/v";Out="driverquery_verbose.txt";Timeout=60},
        @{Name="driverquery_signed";Exe="driverquery.exe";Args="/si";Out="driverquery_signed.txt";Timeout=60},
        @{Name="hotfixes";Exe="wmic.exe";Args="qfe list full";Out="hotfixes.txt";Timeout=60},
        @{Name="scheduled_tasks";Exe="schtasks.exe";Args="/query /fo LIST /v";Out="scheduled_tasks.txt";Timeout=120},
        @{Name="firewall_profiles";Exe="netsh.exe";Args="advfirewall show allprofiles";Out="firewall_profiles.txt";Timeout=60},
        @{Name="eventlog_channels";Exe="wevtutil.exe";Args="el";Out="eventlog_channels.txt";Timeout=60}
    )
    $full = @(
        @{Name="netstat_abno";Exe="netstat.exe";Args="-abno";Out="netstat_abno.txt";Timeout=120},
        @{Name="winsock_catalog";Exe="netsh.exe";Args="winsock show catalog";Out="winsock_catalog.txt";Timeout=120},
        @{Name="netsh_ip_config";Exe="netsh.exe";Args="int ip show config";Out="netsh_ip_config.txt";Timeout=60},
        @{Name="powercfg_a";Exe="powercfg.exe";Args="/a";Out="powercfg_available_sleepstates.txt";Timeout=30},
        @{Name="powercfg_lastwake";Exe="powercfg.exe";Args="/lastwake";Out="powercfg_lastwake.txt";Timeout=30},
        @{Name="powercfg_waketimers";Exe="powercfg.exe";Args="/waketimers";Out="powercfg_waketimers.txt";Timeout=30},
        @{Name="powercfg_requests";Exe="powercfg.exe";Args="/requests";Out="powercfg_requests.txt";Timeout=30},
        @{Name="reagentc_info";Exe="reagentc.exe";Args="/info";Out="reagentc_info.txt";Timeout=30},
        @{Name="bcdedit_all";Exe="bcdedit.exe";Args="/enum all";Out="bcdedit_all.txt";Timeout=60},
        @{Name="bitlocker_status";Exe="manage-bde.exe";Args="-status";Out="bitlocker_status.txt";Timeout=60}
    )
    if($Profile -eq "Quick"){ return $normal }
    return @($normal + $full)
}

function Global:Copy-NTKTriageFileSafe {
    param([string]$Path,[string]$DestinationRoot,[long]$MaxBytes=104857600,[switch]$MetadataOnly,[string]$RunLog)
    $records = @()
    foreach($item in @(Get-ChildItem -Path $Path -File -Recurse -Force -ErrorAction SilentlyContinue)){
        try {
            $record = [ordered]@{source=$item.FullName;fileName=$item.Name;sizeBytes=$item.Length;created=$item.CreationTimeUtc.ToString("o");modified=$item.LastWriteTimeUtc.ToString("o");copied=$false;destination=$null;warning=$null}
            if($MetadataOnly -or $item.Length -gt $MaxBytes){
                $record.warning = "Metadata only; file exceeded size limit or metadata mode was selected."
            }
            else {
                $safeName = ($item.FullName -replace '^[A-Za-z]:\\','' -replace '[\\/:*?"<>|]','_')
                $dest = Join-Path $DestinationRoot $safeName
                $destFolder = Split-Path -Parent $dest
                if(!(Test-Path -LiteralPath $destFolder)){ New-Item -ItemType Directory -Path $destFolder -Force | Out-Null }
                Copy-Item -LiteralPath $item.FullName -Destination $dest -Force -ErrorAction Stop
                $record.copied = $true
                $record.destination = $dest
            }
            $records += [pscustomobject]$record
        }
        catch {
            $records += [pscustomobject]@{source=$item.FullName;fileName=$item.Name;sizeBytes=$item.Length;created=$item.CreationTimeUtc.ToString("o");modified=$item.LastWriteTimeUtc.ToString("o");copied=$false;destination=$null;warning=$_.Exception.Message}
            Write-NTKTriageLog "File copy skipped: $($item.FullName) $($_.Exception.Message)" $RunLog
        }
    }
    return $records
}

function Global:Export-NTKTriageEventSummary {
    param([string]$LogName,[int]$Days,[string]$OutputPath,[string]$RunLog)
    try {
        $start = (Get-Date).AddDays(-1 * $Days)
        $events = @(Get-WinEvent -FilterHashtable @{LogName=$LogName; StartTime=$start; Level=1,2,3} -ErrorAction Stop | Select-Object -First 1000 TimeCreated,ProviderName,Id,LevelDisplayName,Message)
        $events | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding UTF8
        Write-NTKTriageLog "Event summary exported: $LogName count=$($events.Count)" $RunLog
        return [pscustomobject]@{log=$LogName;path=$OutputPath;count=$events.Count;succeeded=$true;error=$null}
    }
    catch {
        "Event export failed for ${LogName}: $($_.Exception.Message)" | Set-Content -LiteralPath $OutputPath -Encoding UTF8
        Write-NTKTriageLog "Event summary failed: $LogName $($_.Exception.Message)" $RunLog
        return [pscustomobject]@{log=$LogName;path=$OutputPath;count=0;succeeded=$false;error=$_.Exception.Message}
    }
}

function Global:New-NTKTriageFileInventory {
    param([string]$RunPath,[string]$OutputPath,[long]$HashThresholdBytes=524288000)
    $rows = foreach($file in Get-ChildItem -LiteralPath $RunPath -File -Recurse -Force -ErrorAction SilentlyContinue){
        $relative = $file.FullName.Substring($RunPath.Length).TrimStart('\')
        $hash = ""
        $hashError = ""
        if($file.Length -le $HashThresholdBytes){
            try { $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256 -ErrorAction Stop).Hash } catch { $hashError = $_.Exception.Message }
        }
        [pscustomobject]@{relativePath=$relative;sizeBytes=$file.Length;createdUtc=$file.CreationTimeUtc.ToString("o");modifiedUtc=$file.LastWriteTimeUtc.ToString("o");sha256=$hash;category=($relative -split '\\')[0];hashError=$hashError}
    }
    $rows | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding UTF8
    return @($rows)
}

function Global:Invoke-NTKTriageAnalysis {
    param($Run,$CommandResults,$EventResults,$FileRecords,$ToolResults,$MissingTools,$Warnings,$StartedUtc)
    $analysisDir = Join-Path $Run.Path "Analysis"
    $findings = New-Object System.Collections.Generic.List[object]
    $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
    $cs = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue
    $volumes = @(Get-Volume -ErrorAction SilentlyContinue | Select-Object DriveLetter,FileSystemLabel,Size,SizeRemaining,HealthStatus)
    foreach($v in $volumes){
        if($v.Size -gt 0 -and (($v.SizeRemaining / $v.Size) -lt .10)){
            [void]$findings.Add([pscustomobject]@{severity="Medium";category="Disk";title="Low free disk space";evidence="$($v.DriveLetter): has less than 10 percent free";recommendation="Free disk space or expand the volume, then rerun triage."})
        }
    }
    foreach($ev in @($EventResults | Where-Object { $_.count -gt 0 })){
        [void]$findings.Add([pscustomobject]@{severity="Low";category="Events";title="Recent warning/error events";evidence="$($ev.log) exported $($ev.count) recent warning/error/critical event(s).";recommendation="Review $($ev.path) and correlate timestamps with user-reported symptoms."})
    }
    $dumpCount = @($FileRecords | Where-Object { $_.source -match '\.dmp$' }).Count
    if($dumpCount -gt 0){
        [void]$findings.Add([pscustomobject]@{severity="Medium";category="Crash";title="Dump files found";evidence="$dumpCount dump file record(s) found or collected.";recommendation="Open BlueScreenView or WinDbg against the Dumps folder, then correlate bugcheck time with System events."})
    }
    foreach($tool in @($MissingTools | Where-Object { $_.required })){
        [void]$findings.Add([pscustomobject]@{severity="Low";category="Setup";title="Required triage tool missing";evidence="$($tool.name) is marked required but was not found.";recommendation="Install the tool under Triage\Tools or update manifests\triage-tools.json."})
    }
    $findings | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $analysisDir "findings.json") -Encoding UTF8
    $summary = New-Object System.Collections.Generic.List[string]
    $summary.Add("# Network Toolkit Triage Summary")
    $summary.Add("")
    $summary.Add("Computer: $env:COMPUTERNAME")
    $summary.Add("Profile: $($Run.Profile)")
    $summary.Add("Started UTC: $StartedUtc")
    $summary.Add("Generated UTC: $((Get-Date).ToUniversalTime().ToString('o'))")
    $summary.Add("OS: $($os.Caption) $($os.Version) build $($os.BuildNumber)")
    $summary.Add("Last boot: $($os.LastBootUpTime)")
    $summary.Add("Domain/workgroup: $($cs.Domain)")
    $summary.Add("User: $env:USERDOMAIN\$env:USERNAME")
    $summary.Add("Elevated: $(([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))")
    $summary.Add("RAM GB: $([Math]::Round(($cs.TotalPhysicalMemory/1GB),2))")
    $summary.Add("")
    $summary.Add("## Collection Summary")
    $summary.Add("- Commands run: $(@($CommandResults).Count)")
    $summary.Add("- Tools run: $(@($ToolResults | Where-Object {$_.succeeded}).Count)")
    $summary.Add("- Missing tools: $(@($MissingTools).Count)")
    $summary.Add("- File records: $(@($FileRecords).Count)")
    $summary.Add("- Event summaries: $(@($EventResults).Count)")
    $summary.Add("- Warnings/errors: $(@($Warnings).Count)")
    $summary.Add("")
    $summary.Add("## Findings")
    if($findings.Count -eq 0){ $summary.Add("No high-confidence local findings were detected by the basic analyzer. Upload the bundle for deeper review.") }
    foreach($finding in $findings){
        $summary.Add("- [$($finding.severity)] $($finding.title): $($finding.evidence) Recommended next step: $($finding.recommendation)")
    }
    $summary.Add("")
    $summary.Add("## Network Adapters")
    try {
        foreach($nic in @(Get-NetIPConfiguration -ErrorAction Stop)){
            $summary.Add("- $($nic.InterfaceAlias): IPv4=$($nic.IPv4Address.IPAddress -join ', ') Gateway=$($nic.IPv4DefaultGateway.NextHop) DNS=$($nic.DNSServer.ServerAddresses -join ', ')")
        }
    } catch { $summary.Add("- Network adapter summary unavailable: $($_.Exception.Message)") }
    $summary.Add("")
    $summary.Add("Upload the ZIP bundle to ChatGPT for deeper analysis. Do not upload it to public locations unless approved.")
    $summary -join "`r`n" | Set-Content -LiteralPath (Join-Path $analysisDir "summary.md") -Encoding UTF8
    "Upload the ZIP bundle from the Bundle folder to ChatGPT. Ask it to review Analysis\summary.md, Analysis\findings.json, Metadata\collection_manifest.json, event summaries, command output, and collected dumps/logs. Request prioritized findings, confidence, evidence, and remediation steps. Ask for feedback as downloadable HTML or JSON if needed." | Set-Content -LiteralPath (Join-Path $analysisDir "chatgpt_upload_instructions.txt") -Encoding UTF8
    return @($findings)
}

function Global:Test-NTKTriageSetup {
    $paths = Initialize-NTKTriageStructure
    $checks = New-Object System.Collections.Generic.List[object]
    $add = { param($Name,$Passed,$Detail) [void]$checks.Add([pscustomobject]@{name=$Name;passed=[bool]$Passed;detail=$Detail}) }
    & $add "Folder structure" ((Test-Path $paths.Root) -and (Test-Path $paths.Runs) -and (Test-Path $paths.Tools)) $paths.Root
    try { $manifest = Get-NTKTriageManifest; & $add "Manifest parses" ($null -ne $manifest.tools) $paths.Manifest } catch { & $add "Manifest parses" $false $_.Exception.Message }
    foreach($cmd in @("systeminfo.exe","driverquery.exe","ipconfig.exe","netstat.exe","wevtutil.exe","schtasks.exe","powercfg.exe")){
        & $add "Command exists: $cmd" ([bool](Get-Command $cmd -ErrorAction SilentlyContinue)) $cmd
    }
    try {
        $test = Join-Path $paths.Runs "_validation_$(Get-Date -Format HHmmss)"
        New-Item -ItemType Directory -Path $test -Force | Out-Null
        Remove-Item -LiteralPath $test -Recurse -Force
        & $add "Run folder create/delete" $true $paths.Runs
    } catch { & $add "Run folder create/delete" $false $_.Exception.Message }
    try {
        $zipTest = Join-Path $paths.Cache "ziptest.zip"
        $txt = Join-Path $paths.Cache "ziptest.txt"
        "zip test" | Set-Content -LiteralPath $txt -Encoding UTF8
        Compress-Archive -LiteralPath $txt -DestinationPath $zipTest -Force
        Remove-Item -LiteralPath $txt,$zipTest -Force -ErrorAction SilentlyContinue
        & $add "ZIP creation" $true $paths.Cache
    } catch { & $add "ZIP creation" $false $_.Exception.Message }
    $status = @(Get-NTKTriageToolStatus)
    return [pscustomobject]@{checkedUtc=(Get-Date).ToUniversalTime().ToString("o");passed=(@($checks | Where-Object {!$_.passed}).Count -eq 0);checks=$checks;tools=$status}
}

function Global:Invoke-NTKTriageRun {
    param(
        [ValidateSet("Quick","Full","Crash")][string]$Profile="Quick",
        [string]$ResultPath,
        [switch]$IncludeMemoryDump,
        [switch]$RedactText,
        [switch]$SelectedToolsOnly,
        [string[]]$SelectedToolIds = @()
    )
    $started = (Get-Date).ToUniversalTime().ToString("o")
    $run = New-NTKTriageRunFolder -Profile $Profile
    $warnings = New-Object System.Collections.Generic.List[object]
    $commandResults = @()
    $toolResults = @()
    $missingTools = @()
    $fileRecords = @()
    $eventResults = @()
    try {
        Write-NTKTriageLog "Triage run started: $($run.RunId) profile=$Profile" $run.RunLog
        $preflight = Test-NTKTriageSetup
        $preflight | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $run.Path "Metadata\validation_preflight.json") -Encoding UTF8
        $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if(!$isAdmin){ [void]$warnings.Add([pscustomobject]@{severity="Warning";message="Run was not elevated. Some logs, dumps, registry keys, and tool outputs may be incomplete."}) }

        foreach($cmd in @(Get-NTKTriageCommandPlan -Profile $Profile)){
            $out = Join-Path (Join-Path $run.Path "CommandOutput") $cmd.Out
            $commandResults += Invoke-NTKTriageCommand -Name $cmd.Name -FilePath $cmd.Exe -Arguments $cmd.Args -OutputPath $out -TimeoutSeconds $cmd.Timeout -RunLog $run.RunLog
        }
        $psCollectors = @(
            @{Name="Get-ComputerInfo";Script={Get-ComputerInfo}},
            @{Name="Get-HotFix";Script={Get-HotFix}},
            @{Name="Get-Service";Script={Get-Service | Sort-Object Status,Name}},
            @{Name="Get-Process";Script={Get-Process | Sort-Object CPU -Descending | Select-Object -First 250}},
            @{Name="Get-NetIPConfiguration";Script={Get-NetIPConfiguration}},
            @{Name="Get-NetAdapter";Script={Get-NetAdapter}},
            @{Name="Get-NetTCPConnection";Script={Get-NetTCPConnection}},
            @{Name="Get-PhysicalDisk";Script={Get-PhysicalDisk}},
            @{Name="Win32_PnPSignedDriver";Script={Get-CimInstance Win32_PnPSignedDriver | Select-Object DeviceName,Manufacturer,DriverVersion,DriverDate,IsSigned,InfName}}
        )
        foreach($collector in $psCollectors){
            $base = ($collector.Name -replace '[^\w.-]','_')
            [void](Export-NTKTriagePowerShellObject -Name $collector.Name -ScriptBlock $collector.Script -TxtPath (Join-Path $run.Path "CommandOutput\$base.txt") -JsonPath (Join-Path $run.Path "CommandOutput\$base.json") -RunLog $run.RunLog)
        }
        $eventResults += Export-NTKTriageEventSummary -LogName "System" -Days 7 -OutputPath (Join-Path $run.Path "EventLogs\System_recent_errors.csv") -RunLog $run.RunLog
        $eventResults += Export-NTKTriageEventSummary -LogName "Application" -Days 7 -OutputPath (Join-Path $run.Path "EventLogs\Application_recent_errors.csv") -RunLog $run.RunLog
        foreach($ev in @(@{Log="Setup";Days=30;File="Setup_recent.csv"},@{Log="Microsoft-Windows-WindowsUpdateClient/Operational";Days=30;File="WindowsUpdateClient_recent.csv"},@{Log="Microsoft-Windows-TaskScheduler/Operational";Days=30;File="TaskScheduler_recent.csv"},@{Log="Microsoft-Windows-WER-Diag/Operational";Days=30;File="WER_Diag_recent.csv"},@{Log="Microsoft-Windows-Kernel-Boot/Operational";Days=30;File="KernelBoot_recent.csv"})){
            $eventResults += Export-NTKTriageEventSummary -LogName $ev.Log -Days $ev.Days -OutputPath (Join-Path $run.Path "EventLogs\$($ev.File)") -RunLog $run.RunLog
        }
        $fileRecords += Copy-NTKTriageFileSafe -Path "$env:SystemRoot\Minidump\*.dmp" -DestinationRoot (Join-Path $run.Path "Dumps") -MaxBytes 104857600 -RunLog $run.RunLog
        $fileRecords += Copy-NTKTriageFileSafe -Path "$env:SystemRoot\LiveKernelReports\*.dmp" -DestinationRoot (Join-Path $run.Path "Dumps") -MaxBytes 104857600 -RunLog $run.RunLog
        $fileRecords += Copy-NTKTriageFileSafe -Path "$env:SystemRoot\MEMORY.DMP" -DestinationRoot (Join-Path $run.Path "Dumps") -MaxBytes $(if($IncludeMemoryDump -or $Profile -eq "Full"){1073741824}else{0}) -MetadataOnly:(!$IncludeMemoryDump -and $Profile -ne "Full") -RunLog $run.RunLog
        foreach($pattern in @("$env:SystemRoot\Logs\CBS\*.log","$env:SystemRoot\Logs\DISM\*.log","$env:SystemRoot\Panther\*.log","$env:SystemRoot\INF\setupapi*.log","$env:LOCALAPPDATA\CrashDumps\*.dmp","$env:TEMP\*.log")){
            $fileRecords += Copy-NTKTriageFileSafe -Path $pattern -DestinationRoot (Join-Path $run.Path "CollectedFiles") -MaxBytes 52428800 -RunLog $run.RunLog
        }
        $fileRecords | Export-Csv -LiteralPath (Join-Path $run.Path "Dumps\dump_inventory.csv") -NoTypeInformation -Encoding UTF8

        $toolStatus = @(Get-NTKTriageToolStatus -Deep)
        if($SelectedToolsOnly){
            $selectedLookup = @{}
            foreach($id in @($SelectedToolIds)){ if($id){ $selectedLookup[[string]$id] = $true } }
            $toolStatus = @($toolStatus | Where-Object { $selectedLookup.ContainsKey([string]$_.id) })
            if($toolStatus.Count -eq 0){
                [void]$warnings.Add([pscustomobject]@{severity="Warning";message="Selected tool triage was requested, but no selected tools matched the triage manifest."})
            }
        }
        $toolStatus | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $run.Path "triage-tools-status.json") -Encoding UTF8
        foreach($tool in $toolStatus){
            if(!$tool.present){ $missingTools += $tool; continue }
            foreach($exe in @($tool.executables | Where-Object { $_.present -and $_.autoRun -and !$_.requiresConsent })){
                $manifestExe = @((Get-NTKTriageManifest).tools | Where-Object {$_.id -eq $tool.id} | Select-Object -ExpandProperty executables | Where-Object {$_.name -eq $exe.name} | Select-Object -First 1)
                if(!$manifestExe){ continue }
                $out = Join-Path $run.Path $manifestExe.outputFile
                $args = [string]$manifestExe.arguments
                if($args){
                    $toolOutputRoot = Join-Path $run.Path 'ToolOutput'
                    foreach($match in [regex]::Matches($args,'ToolOutput\\[^\s"]+')){
                        $full = Join-Path $run.Path $match.Value
                        $args = $args.Replace($match.Value,('"{0}"' -f $full))
                    }
                }
                $toolResults += Invoke-NTKTriageCommand -Name $exe.name -FilePath $exe.resolvedPath -Arguments $args -OutputPath $out -TimeoutSeconds 180 -RunLog $run.RunLog
            }
        }
        $commandResults | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $run.Path "Metadata\command_results.json") -Encoding UTF8
        $findings = Invoke-NTKTriageAnalysis -Run $run -CommandResults $commandResults -EventResults $eventResults -FileRecords $fileRecords -ToolResults $toolResults -MissingTools $missingTools -Warnings $warnings -StartedUtc $started
        $bundlePath = Join-Path $run.Path ("Bundle\{0}_DiagnosticsBundle.zip" -f $run.RunId)
        $manifest = [pscustomobject]@{runId=$run.RunId;toolkitVersion=(Get-Content -LiteralPath (Join-Path (Get-NTKTriagePaths).Manifests "toolkit-version.json") -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json -ErrorAction SilentlyContinue);computerName=$env:COMPUTERNAME;profile=$Profile;startedUtc=$started;endedUtc=(Get-Date).ToUniversalTime().ToString("o");selectedToolsOnly=[bool]$SelectedToolsOnly;selectedToolIds=@($SelectedToolIds);filesCollected=@($fileRecords).Count;commandsRun=@($commandResults).Count;toolsRun=@($toolResults).Count;missingTools=@($missingTools | Select-Object name,id,required,status);warnings=$warnings;bundleFileName=[IO.Path]::GetFileName($bundlePath);bundlePath=$bundlePath;bundleSha256=""}
        $manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $run.Path "Analysis\collection_manifest.json") -Encoding UTF8
        Copy-Item -LiteralPath (Join-Path $run.Path "Analysis\collection_manifest.json") -Destination (Join-Path $run.Path "Metadata\collection_manifest.json") -Force
        $inventory = New-NTKTriageFileInventory -RunPath $run.Path -OutputPath (Join-Path $run.Path "Metadata\file_inventory.csv")
        $items = @("CollectedFiles","CommandOutput","ToolOutput","EventLogs","Dumps","Reports","Analysis","Metadata","run.log","triage-tools-status.json") | ForEach-Object { Join-Path $run.Path $_ } | Where-Object { Test-Path -LiteralPath $_ }
        Compress-Archive -LiteralPath $items -DestinationPath $bundlePath -Force
        $bundleHash = (Get-FileHash -LiteralPath $bundlePath -Algorithm SHA256).Hash
        $manifest.bundleSha256 = $bundleHash
        $manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $run.Path "Analysis\collection_manifest.json") -Encoding UTF8
        Copy-Item -LiteralPath (Join-Path $run.Path "Analysis\collection_manifest.json") -Destination (Join-Path $run.Path "Metadata\collection_manifest.json") -Force
        Compress-Archive -LiteralPath $items -DestinationPath $bundlePath -Force
        $post = Test-NTKTriagePostRun -RunPath $run.Path -BundlePath $bundlePath
        $post | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $run.Path "Metadata\validation_postrun.json") -Encoding UTF8
        "Preflight validation: $($preflight.passed)`r`nCollection: PASS`r`nLocal analysis: PASS`r`nBundle creation: PASS`r`nPost-run validation: $($post.passed)" | Set-Content -LiteralPath (Join-Path $run.Path "Reports\validation_summary.txt") -Encoding UTF8
        $result = [pscustomobject]@{status="Completed";runId=$run.RunId;profile=$Profile;runPath=$run.Path;bundlePath=$bundlePath;summaryPath=(Join-Path $run.Path "Analysis\summary.md");filesCollected=@($fileRecords).Count;commandsRun=@($commandResults).Count;toolsRun=@($toolResults).Count;toolsMissing=@($missingTools).Count;warnings=@($warnings).Count;findings=@($findings).Count;postValidationPassed=$post.passed}
    }
    catch {
        Write-NTKTriageLog "Triage failed: $($_.Exception.Message)" $run.RunLog
        $result = [pscustomobject]@{status="Failed";runId=$run.RunId;profile=$Profile;runPath=$run.Path;bundlePath=$null;summaryPath=$null;error=$_.Exception.Message}
    }
    if($ResultPath){ $result | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $ResultPath -Encoding UTF8 }
    return $result
}

function Global:Test-NTKTriagePostRun {
    param([string]$RunPath,[string]$BundlePath)
    $checks = New-Object System.Collections.Generic.List[object]
    $add = { param($Name,$Passed,$Detail) [void]$checks.Add([pscustomobject]@{name=$Name;passed=[bool]$Passed;detail=$Detail}) }
    & $add "Run folder exists" (Test-Path -LiteralPath $RunPath) $RunPath
    & $add "run.log exists" (Test-Path -LiteralPath (Join-Path $RunPath "run.log")) ""
    & $add "summary.md exists" (Test-Path -LiteralPath (Join-Path $RunPath "Analysis\summary.md")) ""
    try { Get-Content -LiteralPath (Join-Path $RunPath "Analysis\findings.json") -Raw | ConvertFrom-Json | Out-Null; & $add "findings.json parses" $true "" } catch { & $add "findings.json parses" $false $_.Exception.Message }
    try { Get-Content -LiteralPath (Join-Path $RunPath "Analysis\collection_manifest.json") -Raw | ConvertFrom-Json | Out-Null; & $add "collection_manifest.json parses" $true "" } catch { & $add "collection_manifest.json parses" $false $_.Exception.Message }
    & $add "file_inventory.csv exists" (Test-Path -LiteralPath (Join-Path $RunPath "Metadata\file_inventory.csv")) ""
    & $add "bundle exists" (Test-Path -LiteralPath $BundlePath) $BundlePath
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
        $zip = [System.IO.Compression.ZipFile]::OpenRead($BundlePath)
        try {
            $names = @($zip.Entries | ForEach-Object FullName)
            & $add "ZIP includes Analysis summary" (@($names | Where-Object { $_ -match 'Analysis/summary.md|Analysis\\summary.md' }).Count -gt 0) ""
            & $add "ZIP includes file inventory" (@($names | Where-Object { $_ -match 'Metadata/file_inventory.csv|Metadata\\file_inventory.csv' }).Count -gt 0) ""
        } finally { $zip.Dispose() }
    } catch { & $add "ZIP readable" $false $_.Exception.Message }
    & $add "Command output exists" (@(Get-ChildItem -LiteralPath (Join-Path $RunPath "CommandOutput") -File -ErrorAction SilentlyContinue).Count -gt 0) ""
    & $add "Event summary exists" (@(Get-ChildItem -LiteralPath (Join-Path $RunPath "EventLogs") -File -ErrorAction SilentlyContinue).Count -gt 0) ""
    return [pscustomobject]@{checkedUtc=(Get-Date).ToUniversalTime().ToString("o");passed=(@($checks | Where-Object {!$_.passed}).Count -eq 0);checks=$checks}
}
