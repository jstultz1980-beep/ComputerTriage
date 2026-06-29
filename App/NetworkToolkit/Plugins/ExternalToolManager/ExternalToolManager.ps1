function Global:Get-NTKExternalToolRoot {

    if($NTKPaths -and $NTKPaths.Root){
        return (Join-Path $NTKPaths.Root "ExternalTools")
    }

    return $null

}

function Global:Test-NTKSysinternalsPath {

param([string]$Path)

    return ($Path -and $Path -match '(?i)[\\/]Sysinternals[\\/]')

}

function Global:Get-NTKSysinternalsBaseName {

param([string]$Path)

    if(!$Path){
        return ""
    }

    $base = [IO.Path]::GetFileNameWithoutExtension($Path)
    $base = $base -replace '(?i)64a$',''
    $base = $base -replace '(?i)64$',''
    return $base

}

function Global:Get-NTKSysinternalsEulaRegistryNames {

param([string]$Path)

    $base = Get-NTKSysinternalsBaseName -Path $Path
    if(!$base){
        return @()
    }

    $key = $base.ToLowerInvariant()
    $map = @{
        "accesschk" = @("AccessChk")
        "accessenum" = @("AccessEnum")
        "adexplorer" = @("ADExplorer")
        "adinsight" = @("ADInsight")
        "adrestore" = @("AdRestore")
        "autoruns" = @("Autoruns")
        "autorunsc" = @("Autoruns")
        "dbgview" = @("DbgView")
        "disk2vhd" = @("Disk2vhd")
        "diskmon" = @("DiskMon")
        "diskview" = @("DiskView")
        "handle" = @("Handle")
        "listdlls" = @("ListDLLs")
        "logonsessions" = @("LogonSessions")
        "pendmoves" = @("PendMoves")
        "procdump" = @("ProcDump")
        "procexp" = @("Process Explorer")
        "procmon" = @("Process Monitor")
        "psexec" = @("PsExec")
        "psfile" = @("PsFile")
        "psgetsid" = @("PsGetSid")
        "psinfo" = @("PsInfo")
        "pskill" = @("PsKill")
        "pslist" = @("PsList")
        "psloggedon" = @("PsLoggedon")
        "psloglist" = @("PsLogList")
        "pspasswd" = @("PsPasswd")
        "psping" = @("PsPing")
        "psservice" = @("PsService")
        "psshutdown" = @("PsShutdown")
        "pssuspend" = @("PsSuspend")
        "rammap" = @("RAMMap")
        "regdelnull" = @("RegDelNull")
        "shareenum" = @("ShareEnum")
        "sigcheck" = @("Sigcheck")
        "streams" = @("Streams")
        "strings" = @("Strings")
        "sysmon" = @("Sysmon")
        "tcpview" = @("TCPView")
        "tcpvcon" = @("TCPView")
        "vmmap" = @("VMMap")
        "whois" = @("Whois")
        "winobj" = @("WinObj")
        "zoomit" = @("ZoomIt")
    }

    $names = @($base)
    if($map.ContainsKey($key)){
        $names += @($map[$key])
    }

    try {
        if(Test-Path $Path){
            $versionInfo = (Get-Item -LiteralPath $Path -ErrorAction Stop).VersionInfo
            if($versionInfo.ProductName){
                $names += [string]$versionInfo.ProductName
            }
            if($versionInfo.FileDescription){
                $names += [string]$versionInfo.FileDescription
            }
        }
    }
    catch {}

    return @($names | Where-Object { $_ } | Select-Object -Unique)

}

function Global:Set-NTKSysinternalsEulaAccepted {

param([string]$Path)

    if(!(Test-NTKSysinternalsPath -Path $Path)){
        return
    }

    foreach($name in Get-NTKSysinternalsEulaRegistryNames -Path $Path){
        try {
            $keyPath = Join-Path "HKCU:\Software\Sysinternals" $name
            if(!(Test-Path $keyPath)){
                New-Item -Path $keyPath -Force | Out-Null
            }
            New-ItemProperty -Path $keyPath -Name "EulaAccepted" -Value 1 -PropertyType DWord -Force | Out-Null
        }
        catch {}
    }

}

function Global:Add-NTKSysinternalsEulaArgument {

param(
    [string]$Path,
    [string[]]$Arguments = @()
)

    $arguments = @($Arguments | Where-Object { $null -ne $_ -and $_ -ne "" })
    if(!(Test-NTKSysinternalsPath -Path $Path)){
        return $arguments
    }

    if(@($arguments | Where-Object { $_ -match '(?i)^[-/]accept(eula)?$|^[-/]accepteula$' }).Count -gt 0){
        return $arguments
    }

    $base = (Get-NTKSysinternalsBaseName -Path $Path).ToLowerInvariant()
    $switch = if($base -eq "procmon"){ "/AcceptEula" } else { "-accepteula" }
    return @($switch) + $arguments

}

function Global:Get-NTKExternalToolCatalog {

    if($script:NTKExternalToolCatalogCache){
        return $script:NTKExternalToolCatalogCache
    }

    $script:NTKExternalToolCatalogCache = @(
        [pscustomobject]@{
            Id = "ProcessExplorer"
            Name = "Process Explorer"
            Group = "Windows Health"
            Paths = @("Sysinternals\procexp64.exe","Sysinternals\procexp.exe")
            Arguments = @()
            RequiresAdmin = $false
            Console = $false
            Notes = "Deep process inspection."
        }
        [pscustomobject]@{
            Id = "ProcessMonitor"
            Name = "Process Monitor"
            Group = "Windows Health"
            Paths = @("Sysinternals\Procmon64.exe","Sysinternals\Procmon.exe")
            Arguments = @("/AcceptEula")
            RequiresAdmin = $true
            Console = $false
            Notes = "Live file, registry, process, and network trace."
        }
        [pscustomobject]@{
            Id = "Autoruns"
            Name = "Autoruns"
            Group = "Windows Health"
            Paths = @("Sysinternals\Autoruns64.exe","Sysinternals\Autoruns.exe")
            Arguments = @()
            RequiresAdmin = $true
            Console = $false
            Notes = "Startup, services, drivers, scheduled tasks, and persistence view."
        }
        [pscustomobject]@{
            Id = "RAMMap"
            Name = "RAMMap"
            Group = "Windows Health"
            Paths = @("Sysinternals\RAMMap64.exe","Sysinternals\RAMMap.exe")
            Arguments = @()
            RequiresAdmin = $true
            Console = $false
            Notes = "Memory pressure and standby list inspection."
        }
        [pscustomobject]@{
            Id = "BlueScreenView"
            Name = "BlueScreenView"
            Group = "Windows Health"
            Paths = @("BlueScreenView\BlueScreenView.exe")
            Arguments = @()
            RequiresAdmin = $false
            Console = $false
            Notes = "Quick BSOD/minidump viewer."
        }
        [pscustomobject]@{
            Id = "CrystalDiskInfo"
            Name = "CrystalDiskInfo"
            Group = "Windows Health"
            Paths = @("CrystalDiskInfo\DiskInfo64.exe","CrystalDiskInfo\DiskInfoA64.exe","CrystalDiskInfo\DiskInfo32.exe")
            Arguments = @()
            RequiresAdmin = $true
            Console = $false
            Notes = "SMART and disk health GUI. VM disks may not expose SMART data."
        }
        [pscustomobject]@{
            Id = "HWiNFO"
            Name = "HWiNFO"
            Group = "Windows Health"
            Paths = @("HWiNFO\HWiNFO64.exe","HWiNFO\HWiNFO32.exe")
            Arguments = @()
            RequiresAdmin = $false
            Console = $false
            Notes = "Hardware inventory and sensor inspection."
        }
        [pscustomobject]@{
            Id = "SystemInformer"
            Name = "System Informer"
            Group = "Windows Health"
            Paths = @("SystemInformer\amd64\SystemInformer.exe","SystemInformer\i386\SystemInformer.exe")
            Arguments = @()
            RequiresAdmin = $true
            Console = $false
            Notes = "Advanced process, service, handle, module, and system activity inspection."
        }
        [pscustomobject]@{
            Id = "WindowsErrorLookup"
            Name = "Windows Error Lookup"
            Group = "Windows Health"
            Paths = @("WindowsErrorLookup\WindowsErrorLookupToolPortable.exe")
            Arguments = @()
            RequiresAdmin = $false
            Console = $false
            Notes = "Look up Windows error codes, HRESULTs, and Win32 error messages."
        }
        [pscustomobject]@{
            Id = "MicrosoftSafetyScanner"
            Name = "Microsoft Safety Scanner"
            Group = "Security"
            Paths = @("MicrosoftSafetyScanner\MSERT.exe")
            Arguments = @()
            RequiresAdmin = $true
            Console = $false
            Notes = "On-demand Microsoft malware scanner for suspected infection checks."
        }
        [pscustomobject]@{
            Id = "AdwCleaner"
            Name = "Malwarebytes AdwCleaner"
            Group = "Security"
            Paths = @("AdwCleaner\adwcleaner.exe")
            Arguments = @()
            RequiresAdmin = $true
            Console = $false
            Notes = "Finds and removes adware, browser hijackers, unwanted programs, and toolbars."
        }
        [pscustomobject]@{
            Id = "ClamWin"
            Name = "ClamWin Portable"
            Group = "Security"
            Paths = @("ClamWin\ClamWinPortable.exe")
            Arguments = @()
            RequiresAdmin = $true
            Console = $false
            Notes = "Portable antivirus scanner for manual file and folder scans."
        }
        [pscustomobject]@{
            Id = "JRT"
            Name = "Junkware Removal Tool"
            Group = "Security"
            Paths = @("JRT\JRT.exe")
            Arguments = @()
            RequiresAdmin = $true
            Console = $false
            Notes = "Legacy Malwarebytes junkware/adware cleanup utility. Use only after review."
        }
        [pscustomobject]@{
            Id = "TCPView"
            Name = "TCPView"
            Group = "Connectivity"
            Paths = @("Sysinternals\tcpview64.exe","Sysinternals\tcpview.exe")
            Arguments = @()
            RequiresAdmin = $true
            Console = $false
            Notes = "Live TCP/UDP connection viewer."
        }
        [pscustomobject]@{
            Id = "PsPing"
            Name = "PsPing"
            Group = "Connectivity"
            Paths = @("Sysinternals\psping64.exe","Sysinternals\psping.exe")
            Arguments = @("-accepteula")
            RequiresAdmin = $false
            Console = $true
            Notes = "Latency and TCP ping testing."
        }
        [pscustomobject]@{
            Id = "Wireshark"
            Name = "Wireshark Portable"
            Group = "Connectivity"
            Paths = @("WiresharkPortable\WiresharkPortable.exe","WiresharkPortable64\WiresharkPortable64.exe","WiresharkPortable64\WiresharkPortable.exe","WiresharkPortable64\App\Wireshark\Wireshark.exe")
            Arguments = @()
            RequiresAdmin = $true
            Console = $false
            Notes = "Packet capture and protocol analysis. Requires Npcap for live capture."
        }
        [pscustomobject]@{
            Id = "WinMTR"
            Name = "WinMTR Portable"
            Group = "Connectivity"
            Paths = @("..\..\Custom\winmtr-redux\WinMTR64.exe")
            Arguments = @()
            RequiresAdmin = $false
            Console = $false
            Notes = "Continuous traceroute and packet loss view for path quality troubleshooting."
        }
        [pscustomobject]@{
            Id = "WinSCP"
            Name = "WinSCP Portable"
            Group = "Network Utilities"
            Paths = @("..\..\Custom\winscp.portable\WinSCP.exe")
            Arguments = @()
            RequiresAdmin = $false
            Console = $false
            Notes = "SFTP, SCP, FTP, and WebDAV file transfer client."
        }
        [pscustomobject]@{
            Id = "mRemoteNG"
            Name = "mRemoteNG Portable"
            Group = "Remote Access"
            Paths = @("..\..\Custom\mRemoteNGPortable\mRemoteNG.exe","mRemoteNG\mRemoteNG.exe")
            Arguments = @()
            RequiresAdmin = $false
            Console = $false
            Notes = "Tabbed RDP, VNC, SSH, Telnet, and multi-protocol remote connection manager."
        }
        [pscustomobject]@{
            Id = "TigerVNC"
            Name = "TigerVNC Viewer"
            Group = "Remote Access"
            Paths = @("TigerVNC\vncviewer.exe")
            Arguments = @()
            RequiresAdmin = $false
            Console = $false
            Notes = "VNC viewer for direct remote screen connections to systems running a VNC server."
        }
        [pscustomobject]@{
            Id = "KiTTY"
            Name = "KiTTY Portable"
            Group = "Network Utilities"
            Paths = @("..\..\Custom\kitty\kitty.exe")
            Arguments = @()
            RequiresAdmin = $false
            Console = $false
            Notes = "Portable SSH and Telnet terminal client based on PuTTY."
        }
        [pscustomobject]@{
            Id = "WhoDat"
            Name = "WhoDat Portable"
            Group = "Network Utilities"
            Paths = @("WhoDat\WhoDatPortable.exe")
            Arguments = @()
            RequiresAdmin = $false
            Console = $false
            Notes = "WHOIS lookup client for domain and public IP ownership checks."
        }
        [pscustomobject]@{
            Id = "TShark"
            Name = "TShark"
            Group = "Connectivity"
            Paths = @("WiresharkPortable64\App\Wireshark\tshark.exe","WiresharkPortable\App\Wireshark\tshark.exe")
            Arguments = @()
            RequiresAdmin = $true
            Console = $true
            Notes = "Wireshark command-line packet capture. Used by Rogue DHCP Server Scan."
        }
        [pscustomobject]@{
            Id = "Dumpcap"
            Name = "Dumpcap"
            Group = "Connectivity"
            Paths = @("WiresharkPortable64\App\Wireshark\dumpcap.exe","WiresharkPortable\App\Wireshark\dumpcap.exe")
            Arguments = @()
            RequiresAdmin = $true
            Console = $true
            Notes = "Wireshark capture engine. Requires Npcap for live capture."
        }
        [pscustomobject]@{
            Id = "NpcapInstaller"
            Name = "Npcap Installer"
            Group = "Connectivity"
            Paths = @("Npcap\npcap-1.88.exe")
            Arguments = @()
            RequiresAdmin = $true
            Console = $false
            Notes = "Installs packet capture driver for Wireshark and Nmap."
        }
        [pscustomobject]@{
            Id = "WizTree"
            Name = "WizTree"
            Group = "File Utilities"
            Paths = @("WizTree\WizTree64.exe","WizTree\WizTree.exe")
            Arguments = @()
            RequiresAdmin = $true
            Console = $false
            Notes = "Fast disk usage analysis."
        }
        [pscustomobject]@{
            Id = "Everything"
            Name = "Everything Portable"
            Group = "File Utilities"
            Paths = @("Everything\Everything.exe","Everything\everything.exe")
            Arguments = @()
            RequiresAdmin = $false
            Console = $false
            Notes = "Instant local filename search across indexed NTFS volumes."
        }
        [pscustomobject]@{
            Id = "WinDirStat"
            Name = "WinDirStat Portable"
            Group = "File Utilities"
            Paths = @("WinDirStat\WinDirStatPortable.exe")
            Arguments = @()
            RequiresAdmin = $true
            Console = $false
            Notes = "Visual disk usage map for finding large folders and files."
        }
        [pscustomobject]@{
            Id = "WinMerge"
            Name = "WinMerge Portable"
            Group = "File Utilities"
            Paths = @("WinMerge\WinMergePortable.exe")
            Arguments = @()
            RequiresAdmin = $false
            Console = $false
            Notes = "Compare and merge files or folders."
        }
        [pscustomobject]@{
            Id = "Kudu"
            Name = "Kudu Portable"
            Group = "File Utilities"
            Paths = @("Kudu\KuduPortable.exe")
            Arguments = @()
            RequiresAdmin = $false
            Console = $false
            Notes = "Portable file manager for browsing and working with local files."
        }
        [pscustomobject]@{
            Id = "RegistrarRegistryManager"
            Name = "Registrar Registry Manager"
            Group = "Repair"
            Paths = @("RegistrarRegistryManager\RegistrarHomeV9.exe")
            Arguments = @()
            RequiresAdmin = $true
            Console = $false
            Notes = "Advanced registry editor. Use carefully and only with a known remediation plan."
        }
        [pscustomobject]@{
            Id = "NotepadPlusPlus"
            Name = "Notepad++ Portable"
            Group = "Software Utilities"
            Paths = @("NotepadPlusPlus\Notepad++Portable.exe")
            Arguments = @()
            RequiresAdmin = $false
            Console = $false
            Notes = "Portable text editor for logs, scripts, configs, and quick notes."
        }
        [pscustomobject]@{
            Id = "Drawio"
            Name = "Draw.io Portable"
            Group = "Software Utilities"
            Paths = @("Drawio\DrawioPortable.exe")
            Arguments = @()
            RequiresAdmin = $false
            Console = $false
            Notes = "Create network diagrams, flowcharts, and troubleshooting visuals."
        }
        [pscustomobject]@{
            Id = "KompoZer"
            Name = "KompoZer Portable"
            Group = "Software Utilities"
            Paths = @("KompoZer\KompoZerPortable.exe")
            Arguments = @()
            RequiresAdmin = $false
            Console = $false
            Notes = "Portable HTML editor for quick report or web page edits."
        }
        [pscustomobject]@{
            Id = "PuTTY"
            Name = "PuTTY"
            Group = "Network Utilities"
            Paths = @("PuTTY\putty.exe")
            Arguments = @()
            RequiresAdmin = $false
            Console = $false
            Notes = "SSH/Telnet client."
        }
        [pscustomobject]@{
            Id = "PsExec"
            Name = "PsExec"
            Group = "Network Utilities"
            Paths = @("Sysinternals\PsExec64.exe","Sysinternals\PsExec.exe")
            Arguments = @("-accepteula")
            RequiresAdmin = $true
            Console = $true
            Notes = "Remote process execution. Use carefully."
        }
        [pscustomobject]@{
            Id = "Handle"
            Name = "Handle"
            Group = "File Utilities"
            Paths = @("Sysinternals\handle64.exe","Sysinternals\handle.exe")
            Arguments = @("-accepteula")
            RequiresAdmin = $true
            Console = $true
            Notes = "Find processes locking files or folders."
        }
        [pscustomobject]@{
            Id = "Sigcheck"
            Name = "Sigcheck"
            Group = "Windows Health"
            Paths = @("Sysinternals\sigcheck64.exe","Sysinternals\sigcheck.exe")
            Arguments = @("-accepteula")
            RequiresAdmin = $false
            Console = $true
            Notes = "Signature and file version checks."
        }
    )

    return $script:NTKExternalToolCatalogCache

}

function Global:Resolve-NTKExternalTool {

param([string]$Id)

    $root = Get-NTKExternalToolRoot

    if(!$root -or !(Test-Path $root)){
        return $null
    }

    $tool = Get-NTKExternalToolCatalog | Where-Object {$_.Id -eq $Id} | Select-Object -First 1

    if(!$tool){
        return $null
    }

    foreach($relativePath in $tool.Paths){

        $path = Join-Path $root $relativePath

        if(Test-Path $path){

            $arguments = @($tool.Arguments | Where-Object {$null -ne $_ -and $_ -ne ""})

            return [pscustomobject]@{
                Id = $tool.Id
                Name = $tool.Name
                Group = $tool.Group
                Path = (Resolve-Path $path).Path
                Arguments = $arguments
                RequiresAdmin = [bool]$tool.RequiresAdmin
                Console = [bool]$tool.Console
                Notes = $tool.Notes
                Found = $true
            }

        }

    }

    $arguments = @($tool.Arguments | Where-Object {$null -ne $_ -and $_ -ne ""})

    return [pscustomobject]@{
        Id = $tool.Id
        Name = $tool.Name
        Group = $tool.Group
        Path = ""
        Arguments = $arguments
        RequiresAdmin = [bool]$tool.RequiresAdmin
        Console = [bool]$tool.Console
        Notes = $tool.Notes
        Found = $false
    }

}

function Global:Get-NTKExternalToolStatus {

    foreach($tool in Get-NTKExternalToolCatalog){
        Resolve-NTKExternalTool -Id $tool.Id
    }

}

function Global:Get-NTKExternalToolArguments {

param(
    [pscustomobject]$Tool,
    [string[]]$ExtraArguments = @()
)

    $arguments = @($Tool.Arguments | Where-Object {$null -ne $_ -and $_ -ne ""})
    $arguments += @($ExtraArguments | Where-Object {$null -ne $_ -and $_ -ne ""})

    if($ExtraArguments.Count -eq 0){

        switch($Tool.Id){

            "PsPing" {
                $target = Read-NTKInput "Target host or host:port for PsPing"
                $arguments += $target
            }

            "Handle" {
                $target = Read-NTKInput "File, folder, or handle search text"
                $arguments += $target
            }

            "Sigcheck" {
                $target = Read-NTKInput "File or folder to check"
                $arguments += "-a"
                $arguments += "-h"
                $arguments += $target
            }

            "PsExec" {
                $target = Read-NTKInput "Remote computer name, like \\SERVER"
                $command = Read-NTKInput "Command to run remotely, like cmd or ipconfig"
                $arguments += $target
                $arguments += $command
            }

        }

    }

    if(Get-Command Set-NTKSysinternalsEulaAccepted -ErrorAction SilentlyContinue){
        Set-NTKSysinternalsEulaAccepted -Path $Tool.Path
    }

    # GUI Sysinternals tools use the registry acceptance set above. Some, such as
    # Autoruns, interpret -accepteula as an invalid input-file argument.
    if($Tool.Console -and (Get-Command Add-NTKSysinternalsEulaArgument -ErrorAction SilentlyContinue)){
        $arguments = @(Add-NTKSysinternalsEulaArgument -Path $Tool.Path -Arguments $arguments)
    }

    return @($arguments | Where-Object {$null -ne $_ -and $_ -ne ""})

}

function Global:Start-NTKExternalProcess {

param(
    [pscustomobject]$Tool,
    [string[]]$Arguments = @()
)

    $workingDirectory = Split-Path -Parent $Tool.Path

    if(!$workingDirectory){
        $workingDirectory = Get-Location
    }

    if(Get-Command Set-NTKSysinternalsEulaAccepted -ErrorAction SilentlyContinue){
        Set-NTKSysinternalsEulaAccepted -Path $Tool.Path
    }

    Start-NTKToolProcess `
        -FilePath $Tool.Path `
        -ArgumentList $Arguments `
        -WorkingDirectory $workingDirectory `
        -WindowStyle Normal `
        -Elevated:($Tool.RequiresAdmin -and !(Test-NTKAdministrator)) | Out-Null

}

function Global:Invoke-NTKExternalTool {

param(
    [string]$Id,
    [string[]]$ExtraArguments = @()
)

    $tool = Resolve-NTKExternalTool -Id $Id

    if(!$tool -or !$tool.Found){
        Write-Host "External tool not found:" $Id -ForegroundColor Yellow
        Write-Host "Expected under:" (Get-NTKExternalToolRoot)
        return
    }

    Write-Host "Launching:" $tool.Name -ForegroundColor Green
    Write-Host $tool.Path

    $arguments = Get-NTKExternalToolArguments -Tool $tool -ExtraArguments $ExtraArguments

    if($tool.Console){

        $escapedArguments = @($arguments | ForEach-Object {
            if($_ -match "\s"){"`"$_`""}else{$_}
        })

        $commandLine = "`"$($tool.Path)`" $($escapedArguments -join ' ')"

        $consoleTool = [pscustomobject]@{
            Path = "cmd.exe"
            RequiresAdmin = $tool.RequiresAdmin
        }

        Start-NTKExternalProcess `
            -Tool $consoleTool `
            -Arguments @("/k",$commandLine)

    }
    else{

        Start-NTKExternalProcess -Tool $tool -Arguments $arguments

    }

}

function Global:Invoke-ExternalToolManager {

    while($true){

        Clear-Host

        Write-Host ""
        Write-Host "EXTERNAL TOOL MANAGER" -ForegroundColor Cyan
        Write-Host "=====================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "Root:" (Get-NTKExternalToolRoot)
        Write-Host ""

        $tools = @(Get-NTKExternalToolStatus)

        for($i = 0; $i -lt $tools.Count; $i++){
            $tool = $tools[$i]
            $state = if($tool.Found){"Ready"}else{"Missing"}
            Write-Host ("{0}. {1} [{2}] - {3}" -f ($i + 1),$tool.Name,$state,$tool.Group)
        }

        Write-Host ""
        Write-Host "Select a ready tool to launch it, or B to return."
        Write-Host ""

        $choice = Read-NTKInput "Select external tool"

        if(-not ($choice -as [int])){
            Write-Host "Invalid selection." -ForegroundColor Red
            continue
        }

        $index = [int]$choice

        if($index -lt 1 -or $index -gt $tools.Count){
            Write-Host "Invalid selection." -ForegroundColor Red
            continue
        }

        $selected = $tools[$index - 1]

        if(!$selected.Found){
            Write-Host "Tool is missing:" $selected.Name -ForegroundColor Yellow
        }
        else{
            Invoke-NTKExternalTool -Id $selected.Id
        }

        Write-Host ""
        [void](Read-NTKInput "Press ENTER to continue" -AllowEmpty)

    }

}
