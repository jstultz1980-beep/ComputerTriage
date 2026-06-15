function Global:Get-CSIExternalToolRoot {

    if($CSIPaths -and $CSIPaths.Root){
        return (Join-Path $CSIPaths.Root "ExternalTools")
    }

    return $null

}

function Global:Get-CSIExternalToolCatalog {

    if($script:CSIExternalToolCatalogCache){
        return $script:CSIExternalToolCatalogCache
    }

    $script:CSIExternalToolCatalogCache = @(
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
            Paths = @("_Downloads\systeminformer-3.2.25011-release-bin\amd64\SystemInformer.exe","_Downloads\systeminformer-3.2.25011-release-bin\i386\SystemInformer.exe")
            Arguments = @()
            RequiresAdmin = $true
            Console = $false
            Notes = "Advanced process, service, handle, module, and system activity inspection."
        }
        [pscustomobject]@{
            Id = "WindowsErrorLookup"
            Name = "Windows Error Lookup"
            Group = "Windows Health"
            Paths = @("_Downloads\WindowsErrorLookupToolPortable\WindowsErrorLookupToolPortable.exe")
            Arguments = @()
            RequiresAdmin = $false
            Console = $false
            Notes = "Look up Windows error codes, HRESULTs, and Win32 error messages."
        }
        [pscustomobject]@{
            Id = "MicrosoftSafetyScanner"
            Name = "Microsoft Safety Scanner"
            Group = "Security"
            Paths = @("_Downloads\MicrosoftSafetyScanner-MSERT-x64.exe")
            Arguments = @()
            RequiresAdmin = $true
            Console = $false
            Notes = "On-demand Microsoft malware scanner for suspected infection checks."
        }
        [pscustomobject]@{
            Id = "AdwCleaner"
            Name = "Malwarebytes AdwCleaner"
            Group = "Security"
            Paths = @("_Downloads\adwcleaner.exe")
            Arguments = @()
            RequiresAdmin = $true
            Console = $false
            Notes = "Finds and removes adware, browser hijackers, unwanted programs, and toolbars."
        }
        [pscustomobject]@{
            Id = "ClamWin"
            Name = "ClamWin Portable"
            Group = "Security"
            Paths = @("_Downloads\ClamWinPortable\ClamWinPortable.exe")
            Arguments = @()
            RequiresAdmin = $true
            Console = $false
            Notes = "Portable antivirus scanner for manual file and folder scans."
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
            Paths = @("_Downloads\WinMTRPortable\WinMTRPortable.exe","_Downloads\WinMTRPortable\App\WinMTR64\WinMTR.exe","_Downloads\WinMTRPortable\App\WinMTR\WinMTR.exe")
            Arguments = @()
            RequiresAdmin = $false
            Console = $false
            Notes = "Continuous traceroute and packet loss view for path quality troubleshooting."
        }
        [pscustomobject]@{
            Id = "WinSCP"
            Name = "WinSCP Portable"
            Group = "Network Utilities"
            Paths = @("_Downloads\WinSCP-6.5.6-Portable\WinSCP.exe")
            Arguments = @()
            RequiresAdmin = $false
            Console = $false
            Notes = "SFTP, SCP, FTP, and WebDAV file transfer client."
        }
        [pscustomobject]@{
            Id = "KiTTY"
            Name = "KiTTY Portable"
            Group = "Network Utilities"
            Paths = @("_Downloads\KiTTYPortable\KiTTYPortable.exe")
            Arguments = @()
            RequiresAdmin = $false
            Console = $false
            Notes = "Portable SSH and Telnet terminal client based on PuTTY."
        }
        [pscustomobject]@{
            Id = "WhoDat"
            Name = "WhoDat Portable"
            Group = "Network Utilities"
            Paths = @("_Downloads\WhoDatPortable\WhoDatPortable.exe")
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
            Paths = @("_Downloads\Everything-1.4.1.1032.x64\Everything.exe","_Downloads\Everything-1.4.1.1032.x64\everything.exe")
            Arguments = @()
            RequiresAdmin = $false
            Console = $false
            Notes = "Instant local filename search across indexed NTFS volumes."
        }
        [pscustomobject]@{
            Id = "WinDirStat"
            Name = "WinDirStat Portable"
            Group = "File Utilities"
            Paths = @("_Downloads\WinDirStatPortable\WinDirStatPortable.exe")
            Arguments = @()
            RequiresAdmin = $true
            Console = $false
            Notes = "Visual disk usage map for finding large folders and files."
        }
        [pscustomobject]@{
            Id = "WinMerge"
            Name = "WinMerge Portable"
            Group = "File Utilities"
            Paths = @("_Downloads\WinMergePortable\WinMergePortable.exe")
            Arguments = @()
            RequiresAdmin = $false
            Console = $false
            Notes = "Compare and merge files or folders."
        }
        [pscustomobject]@{
            Id = "Kudu"
            Name = "Kudu Portable"
            Group = "File Utilities"
            Paths = @("_Downloads\KuduPortable\KuduPortable.exe")
            Arguments = @()
            RequiresAdmin = $false
            Console = $false
            Notes = "Portable file manager for browsing and working with local files."
        }
        [pscustomobject]@{
            Id = "NotepadPlusPlus"
            Name = "Notepad++ Portable"
            Group = "Software Utilities"
            Paths = @("_Downloads\Notepad++Portable\Notepad++Portable.exe")
            Arguments = @()
            RequiresAdmin = $false
            Console = $false
            Notes = "Portable text editor for logs, scripts, configs, and quick notes."
        }
        [pscustomobject]@{
            Id = "Drawio"
            Name = "Draw.io Portable"
            Group = "Software Utilities"
            Paths = @("_Downloads\DrawioPortable\DrawioPortable.exe")
            Arguments = @()
            RequiresAdmin = $false
            Console = $false
            Notes = "Create network diagrams, flowcharts, and troubleshooting visuals."
        }
        [pscustomobject]@{
            Id = "KompoZer"
            Name = "KompoZer Portable"
            Group = "Software Utilities"
            Paths = @("_Downloads\KompoZerPortable\KompoZerPortable.exe")
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

    return $script:CSIExternalToolCatalogCache

}

function Global:Resolve-CSIExternalTool {

param([string]$Id)

    $root = Get-CSIExternalToolRoot

    if(!$root -or !(Test-Path $root)){
        return $null
    }

    $tool = Get-CSIExternalToolCatalog | Where-Object {$_.Id -eq $Id} | Select-Object -First 1

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

function Global:Get-CSIExternalToolStatus {

    foreach($tool in Get-CSIExternalToolCatalog){
        Resolve-CSIExternalTool -Id $tool.Id
    }

}

function Global:Get-CSIExternalToolArguments {

param(
    [pscustomobject]$Tool,
    [string[]]$ExtraArguments = @()
)

    $arguments = @($Tool.Arguments | Where-Object {$null -ne $_ -and $_ -ne ""})
    $arguments += @($ExtraArguments | Where-Object {$null -ne $_ -and $_ -ne ""})

    if($ExtraArguments.Count -eq 0){

        switch($Tool.Id){

            "PsPing" {
                $target = Read-CSIInput "Target host or host:port for PsPing"
                $arguments += $target
            }

            "Handle" {
                $target = Read-CSIInput "File, folder, or handle search text"
                $arguments += $target
            }

            "Sigcheck" {
                $target = Read-CSIInput "File or folder to check"
                $arguments += "-a"
                $arguments += "-h"
                $arguments += $target
            }

            "PsExec" {
                $target = Read-CSIInput "Remote computer name, like \\SERVER"
                $command = Read-CSIInput "Command to run remotely, like cmd or ipconfig"
                $arguments += $target
                $arguments += $command
            }

        }

    }

    return @($arguments | Where-Object {$null -ne $_ -and $_ -ne ""})

}

function Global:Start-CSIExternalProcess {

param(
    [pscustomobject]$Tool,
    [string[]]$Arguments = @()
)

    $workingDirectory = Split-Path -Parent $Tool.Path

    if(!$workingDirectory){
        $workingDirectory = Get-Location
    }

    Start-CSIToolProcess `
        -FilePath $Tool.Path `
        -ArgumentList $Arguments `
        -WorkingDirectory $workingDirectory `
        -WindowStyle Normal `
        -Elevated:($Tool.RequiresAdmin -and !(Test-CSIAdministrator)) | Out-Null

}

function Global:Invoke-CSIExternalTool {

param(
    [string]$Id,
    [string[]]$ExtraArguments = @()
)

    $tool = Resolve-CSIExternalTool -Id $Id

    if(!$tool -or !$tool.Found){
        Write-Host "External tool not found:" $Id -ForegroundColor Yellow
        Write-Host "Expected under:" (Get-CSIExternalToolRoot)
        return
    }

    Write-Host "Launching:" $tool.Name -ForegroundColor Green
    Write-Host $tool.Path

    $arguments = Get-CSIExternalToolArguments -Tool $tool -ExtraArguments $ExtraArguments

    if($tool.Console){

        $escapedArguments = @($arguments | ForEach-Object {
            if($_ -match "\s"){"`"$_`""}else{$_}
        })

        $commandLine = "`"$($tool.Path)`" $($escapedArguments -join ' ')"

        $consoleTool = [pscustomobject]@{
            Path = "cmd.exe"
            RequiresAdmin = $tool.RequiresAdmin
        }

        Start-CSIExternalProcess `
            -Tool $consoleTool `
            -Arguments @("/k",$commandLine)

    }
    else{

        Start-CSIExternalProcess -Tool $tool -Arguments $arguments

    }

}

function Global:Invoke-ExternalToolManager {

    while($true){

        Clear-Host

        Write-Host ""
        Write-Host "EXTERNAL TOOL MANAGER" -ForegroundColor Cyan
        Write-Host "=====================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "Root:" (Get-CSIExternalToolRoot)
        Write-Host ""

        $tools = @(Get-CSIExternalToolStatus)

        for($i = 0; $i -lt $tools.Count; $i++){
            $tool = $tools[$i]
            $state = if($tool.Found){"Ready"}else{"Missing"}
            Write-Host ("{0}. {1} [{2}] - {3}" -f ($i + 1),$tool.Name,$state,$tool.Group)
        }

        Write-Host ""
        Write-Host "Select a ready tool to launch it, or B to return."
        Write-Host ""

        $choice = Read-CSIInput "Select external tool"

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
            Invoke-CSIExternalTool -Id $selected.Id
        }

        Write-Host ""
        [void](Read-Host "Press ENTER to continue")

    }

}
