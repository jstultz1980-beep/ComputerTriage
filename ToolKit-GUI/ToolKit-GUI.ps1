# =====================================================================
# ToolKit-GUI.ps1
# Network Toolkit - Technician GUI
# =====================================================================

#Requires -Version 5.1

[CmdletBinding()]
param(
    [switch]$SmokeTest,
    [switch]$ButtonSmokeTest
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$GuiRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$SharedToolkitRoot = Join-Path (Split-Path -Parent $GuiRoot) "CSI-NetworkToolkit"
$ToolkitLauncher = Join-Path $SharedToolkitRoot "CSI-NetworkToolkit.ps1"
$GuiIconPath = Join-Path $GuiRoot "NetworkToolkit.ico"

if(!(Test-Path $ToolkitLauncher)){
    [System.Windows.Forms.MessageBox]::Show(
        "Could not find the shared toolkit launcher:`r`n$ToolkitLauncher",
        "Network Toolkit",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
    exit 1
}

try {
    . "$ToolkitLauncher" -NoConsole
}
catch {
    [System.Windows.Forms.MessageBox]::Show(
        "Could not load the toolkit.`r`n`r`n$($_.Exception.Message)",
        "Network Toolkit",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
    exit 1
}

$script:Commands = @(Get-CSICommands | Where-Object {$_.Name -notin @("File Utilities","Software Utilities")})
$script:Fingerprints = @()
$script:ChocoPackages = @()
$script:ChocoInstalledPackages = @()
$script:Reports = @()
$script:CustomTools = @()
$script:QuickDiagnosisRan = $false
$script:DismSfcRecommended = $false
$script:ToolTip = $null
$script:DashboardLabels = @{}
$script:ExternalToolCache = @{}
$script:TabButtons = @{}
$script:StaticTabStrip = $null
$script:LatestQuickDiagnosisReport = $null
$script:ChocoDownloadUpgradeAttempted = $false
$script:PublicIPJob = $null
$script:PublicIPTimer = $null
$script:PublicIPStartedAt = $null
$script:PublicIPQuiet = $false

function Test-GUIAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Add-GUILog {
    param([string]$Message)

    $line = "[{0}] {1}" -f (Get-Date -Format "HH:mm:ss"),$Message

    if($script:LogBox){
        $script:LogBox.AppendText($line + [Environment]::NewLine)
    }

    if($script:StatusLabel){
        $script:StatusLabel.Text = $Message
    }
}

function Write-GUIToolUsageLog {
    param(
        [string]$Tool,
        [string]$Action,
        [string]$Detail = "",
        [string]$Level = "INFO"
    )

    try {
        $root = Join-Path $CSIPaths.Logs "ToolUsage"
        if(!(Test-Path $root)){
            New-Item -ItemType Directory -Path $root -Force | Out-Null
        }

        $safeTool = if(Get-Command ConvertTo-CSISafeFileName -ErrorAction SilentlyContinue){ ConvertTo-CSISafeFileName $Tool }else{ $Tool -replace '[^A-Za-z0-9._-]+','_' }
        $logPath = Join-Path $root "$safeTool.log"
        $line = "{0}`t{1}`t{2}`t{3}`t{4}" -f (Get-Date -Format "s"),$Level,$Tool,$Action,($Detail -replace "\r?\n"," ")
        Add-Content -Path $logPath -Value $line -Encoding UTF8
    }
    catch {
    }
}

function Invoke-GUISafely {
    param(
        [string]$Tool,
        [scriptblock]$Action
    )

    try {
        Write-GUIToolUsageLog -Tool $Tool -Action "Start"
        & $Action
        Write-GUIToolUsageLog -Tool $Tool -Action "Completed"
    }
    catch {
        Write-GUIToolUsageLog -Tool $Tool -Action "Failed" -Detail $_.Exception.Message -Level "ERROR"
        Add-GUILog "$Tool failed: $($_.Exception.Message)"
        [System.Windows.Forms.MessageBox]::Show(
            "$Tool failed.`r`n`r`n$($_.Exception.Message)",
            "Network Toolkit",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
    }
}

function Get-GUIPrivateIPSummary {
    try {
        $addresses = @(
            Get-NetIPConfiguration -ErrorAction Stop |
                Where-Object { $_.IPv4Address -and $_.NetAdapter.Status -eq "Up" } |
                ForEach-Object {
                    "$($_.InterfaceAlias): $($_.IPv4Address.IPAddress -join ', ')"
                }
        )

        if($addresses.Count -gt 0){
            return ($addresses -join "  |  ")
        }
    }
    catch {}

    try {
        $addresses = @(
            Get-CimInstance Win32_NetworkAdapterConfiguration -Filter "IPEnabled=True" -ErrorAction Stop |
                ForEach-Object {
                    $ipv4 = @($_.IPAddress | Where-Object { $_ -match "^\d{1,3}(\.\d{1,3}){3}$" })
                    if($ipv4.Count -gt 0){
                        "$($_.Description): $($ipv4 -join ', ')"
                    }
                }
        )

        if($addresses.Count -gt 0){
            return ($addresses -join "  |  ")
        }
    }
    catch {}

    return "Not detected"
}

function Get-GUIPublicIPSummary {
    try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

    $endpoints = @(
        "https://api.ipify.org",
        "https://checkip.amazonaws.com",
        "https://icanhazip.com",
        "https://ipv4.icanhazip.com",
        "http://ipinfo.io/ip"
    )

    foreach($endpoint in $endpoints){
        try {
            $request = [System.Net.WebRequest]::Create($endpoint)
            $request.Timeout = 5000
            $request.UserAgent = "NetworkToolkit"

            if([System.Net.WebRequest]::DefaultWebProxy){
                $request.Proxy = [System.Net.WebRequest]::DefaultWebProxy
                $request.Proxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
            }

            $response = $request.GetResponse()
            try {
                $reader = New-Object System.IO.StreamReader($response.GetResponseStream())
                $value = $reader.ReadToEnd().Trim()
            }
            finally {
                if($reader){ $reader.Dispose() }
                if($response){ $response.Dispose() }
            }

            if($value -match '^\d{1,3}(\.\d{1,3}){3}$'){
                return $value
            }
        }
        catch {}
    }

    try {
        $response = Invoke-RestMethod -Uri "https://ifconfig.me/ip" -TimeoutSec 5 -ErrorAction Stop

        if($response){
            return ([string]$response).Trim()
        }
    }
    catch {}

    try {
        $lookup = nslookup myip.opendns.com resolver1.opendns.com 2>$null
        $matches = @($lookup | Select-String -Pattern 'Address:\s+(\d{1,3}(\.\d{1,3}){3})')
        if($matches.Count -gt 1){
            return $matches[-1].Matches[0].Groups[1].Value
        }
    }
    catch {}

    return "Unavailable"
}

function Update-GUIPublicIPSummaryAsync {
    param([switch]$Quiet)

    if(!$script:DashboardLabels.ContainsKey("PublicIP")){
        return
    }

    if($script:PublicIPTimer){
        try {
            $script:PublicIPTimer.Stop()
            $script:PublicIPTimer.Dispose()
        }
        catch {}
        $script:PublicIPTimer = $null
    }

    if($script:PublicIPJob){
        try {
            Stop-Job -Job $script:PublicIPJob -Force -ErrorAction SilentlyContinue
            Remove-Job -Job $script:PublicIPJob -Force -ErrorAction SilentlyContinue
        }
        catch {}
        $script:PublicIPJob = $null
    }
    $script:PublicIPStartedAt = Get-Date
    $script:PublicIPQuiet = [bool]$Quiet

    $label = $script:DashboardLabels["PublicIP"]
    $label.SuspendLayout()
    $label.Text = "Checking..."
    $label.ResumeLayout()

    try {
        $script:PublicIPJob = Start-Job -ScriptBlock {
            try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

            $endpoints = @(
                "https://api.ipify.org",
                "https://checkip.amazonaws.com",
                "https://icanhazip.com",
                "https://ipv4.icanhazip.com",
                "http://ipinfo.io/ip"
            )

            foreach($endpoint in $endpoints){
                try {
                    $request = [System.Net.WebRequest]::Create($endpoint)
                    $request.Timeout = 5000
                    $request.UserAgent = "NetworkToolkit"

                    if([System.Net.WebRequest]::DefaultWebProxy){
                        $request.Proxy = [System.Net.WebRequest]::DefaultWebProxy
                        $request.Proxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
                    }

                    $response = $request.GetResponse()
                    try {
                        $reader = New-Object System.IO.StreamReader($response.GetResponseStream())
                        $value = $reader.ReadToEnd().Trim()
                    }
                    finally {
                        if($reader){ $reader.Dispose() }
                        if($response){ $response.Dispose() }
                    }

                    if($value -match '^\d{1,3}(\.\d{1,3}){3}$'){
                        return $value
                    }
                }
                catch {}
            }

            try {
                $lookup = nslookup myip.opendns.com resolver1.opendns.com 2>$null
                $matches = @($lookup | Select-String -Pattern 'Address:\s+(\d{1,3}(\.\d{1,3}){3})')
                if($matches.Count -gt 1){
                    return $matches[-1].Matches[0].Groups[1].Value
                }
            }
            catch {}

            return "Unavailable"
        }
    }
    catch {
        $label.Text = "Unavailable"
        if(!$script:PublicIPQuiet){
            Add-GUILog "Public IP lookup failed: $($_.Exception.Message)"
        }
        return
    }

    $script:PublicIPTimer = New-Object System.Windows.Forms.Timer
    $script:PublicIPTimer.Interval = 500
    $script:PublicIPTimer.Add_Tick({
        try {
            if(!$script:PublicIPJob){
                return
            }

            $elapsed = New-TimeSpan -Start $script:PublicIPStartedAt -End (Get-Date)
            $timedOut = $elapsed.TotalSeconds -gt 25
            if($script:PublicIPJob.State -notin @("Completed","Failed","Stopped") -and !$timedOut){
                return
            }

            $value = "Unavailable"
            if($script:PublicIPJob.State -eq "Completed"){
                $result = @(Receive-Job -Job $script:PublicIPJob -ErrorAction SilentlyContinue)
                if($result.Count -gt 0 -and $result[-1]){
                    $value = [string]$result[-1]
                }
            }
            elseif($script:PublicIPJob.State -eq "Failed" -and !$script:PublicIPQuiet){
                $reason = $script:PublicIPJob.ChildJobs[0].JobStateInfo.Reason
                if($reason){
                    Add-GUILog "Public IP lookup failed: $($reason.Message)"
                }
            }
            elseif($timedOut -and !$script:PublicIPQuiet){
                Add-GUILog "Public IP lookup timed out."
            }

            try {
                Stop-Job -Job $script:PublicIPJob -Force -ErrorAction SilentlyContinue
                Remove-Job -Job $script:PublicIPJob -Force -ErrorAction SilentlyContinue
            }
            catch {}
            $script:PublicIPJob = $null

            if($script:PublicIPTimer){
                $script:PublicIPTimer.Stop()
                $script:PublicIPTimer.Dispose()
                $script:PublicIPTimer = $null
            }

            if($script:DashboardLabels.ContainsKey("PublicIP")){
                $ipLabel = $script:DashboardLabels["PublicIP"]
                $ipLabel.SuspendLayout()
                $ipLabel.Text = $value
                $ipLabel.ResumeLayout()
            }

            if(!$script:PublicIPQuiet){
                Add-GUILog "Public IP: $value"
            }
        }
        catch {
            try {
                if($script:PublicIPTimer){
                    $script:PublicIPTimer.Stop()
                    $script:PublicIPTimer.Dispose()
                    $script:PublicIPTimer = $null
                }
                if($script:PublicIPJob){
                    Stop-Job -Job $script:PublicIPJob -Force -ErrorAction SilentlyContinue
                    Remove-Job -Job $script:PublicIPJob -Force -ErrorAction SilentlyContinue
                    $script:PublicIPJob = $null
                }
            }
            catch {}

            if(!$script:PublicIPQuiet){
                Add-GUILog "Public IP refresh failed: $($_.Exception.Message)"
            }
        }
    })
    $script:PublicIPTimer.Start()
}

function Get-GUILatestQuickDiagnosisReport {
    try {
        $reports = @(Get-ChildItem -Path $CSIPaths.Exports -Filter "quick-diagnosis*.html" -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending)
        if($reports.Count -gt 0){
            return $reports[0].FullName
        }
    }
    catch {}

    return $null
}

function Open-GUILatestQuickDiagnosisReport {
    $report = Get-GUILatestQuickDiagnosisReport

    if(!$report){
        [System.Windows.Forms.MessageBox]::Show(
            "No Quick Diagnosis HTML report was found yet.",
            "Quick Diagnosis Report",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null
        return
    }

    Start-CSIToolProcess -FilePath $report | Out-Null
    Add-GUILog "Opened Quick Diagnosis report: $report"
}

function Update-GUIComputerHealthLight {
    if(!$script:HealthStatusLight -or !$script:HealthStatusLabel){
        return
    }

    $profile = Get-GUILatestComputerProfile
    $level = "Unknown"
    $detail = "Run Quick Diagnosis"
    $color = [System.Drawing.Color]::FromArgb(150,160,165)

    if($profile){
        $issues = @()
        if($profile.ServicingHealth -and [bool]$profile.ServicingHealth.FollowUpDismSfc){ $issues += "DISM/SFC follow-up" }
        if($profile.PendingReboot -and [bool]$profile.PendingReboot.Pending){ $issues += "pending reboot" }
        if($profile.Disks){
            foreach($disk in @($profile.Disks)){
                if($disk.SizeGB -and $disk.FreeGB){
                    $freePct = [math]::Round((([double]$disk.FreeGB / [double]$disk.SizeGB) * 100),1)
                    if($freePct -lt 10){ $issues += "low disk space" }
                }
            }
        }

        if($issues.Count -eq 0){
            $level = "Healthy"
            $detail = "No major profile issues"
            $color = [System.Drawing.Color]::FromArgb(53,150,80)
        }
        elseif($issues.Count -le 2){
            $level = "Review"
            $detail = ($issues -join ", ")
            $color = [System.Drawing.Color]::FromArgb(225,170,45)
        }
        else{
            $level = "Needs Attention"
            $detail = ($issues -join ", ")
            $color = [System.Drawing.Color]::FromArgb(205,70,55)
        }
    }

    $script:HealthStatusLight.BackColor = $color
    $script:HealthStatusLabel.Text = "$level - $detail"
}

function Invoke-GUIQuickPing {
    $target = if($script:QuickPingBox){$script:QuickPingBox.Text.Trim()}else{""}
    if(!$target){
        Add-GUILog "Enter a host or IP to ping."
        return
    }

    try {
        $ok = Test-Connection -ComputerName $target -Count 4 -Quiet -ErrorAction SilentlyContinue
        $message = if($ok){"Ping succeeded: $target"}else{"Ping failed: $target"}
        Add-GUILog $message
        [System.Windows.Forms.MessageBox]::Show(
            $message,
            "Ping Result",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            $(if($ok){[System.Windows.Forms.MessageBoxIcon]::Information}else{[System.Windows.Forms.MessageBoxIcon]::Warning})
        ) | Out-Null
    }
    catch {
        Add-GUILog "Ping failed: $($_.Exception.Message)"
    }
}

function Get-GUILatestComputerProfile {
    try {
        $profiles = @(Get-CSIStoredFingerprints)

        if($profiles.Count -eq 0){
            return $null
        }

        $latest = $profiles |
            Sort-Object {
                try { [datetime]$_.CapturedAt } catch { [datetime]::MinValue }
            } -Descending |
            Select-Object -First 1

        if($latest -and (Test-Path $latest.Path)){
            return Get-Content -Raw -Path $latest.Path | ConvertFrom-Json
        }
    }
    catch {
    }

    return $null
}

function Refresh-GUIDismSfcState {
    $profile = Get-GUILatestComputerProfile
    $needsRepair = $false

    if($profile -and $profile.ServicingHealth){
        $needsRepair = [bool]$profile.ServicingHealth.FollowUpDismSfc
    }

    $script:QuickDiagnosisRan = [bool]$profile
    $script:DismSfcRecommended = $needsRepair

    if($script:DismRepairButton){
        if($needsRepair){
            $script:DismRepairButton.BackColor = [System.Drawing.Color]::FromArgb(195,82,54)
            $script:DismRepairButton.ForeColor = [System.Drawing.Color]::White
        }
        else{
            $script:DismRepairButton.BackColor = [System.Drawing.Color]::FromArgb(205,214,211)
            $script:DismRepairButton.ForeColor = [System.Drawing.Color]::FromArgb(70,82,86)
        }
    }

    if($script:DismRepairNoteLabel){
        if($needsRepair){
            $script:DismRepairNoteLabel.Text = "Quick Diagnosis indicates DISM/SFC follow-up may be needed."
        }
        elseif($profile){
            $script:DismRepairNoteLabel.Text = "Latest computer profile does not indicate DISM/SFC follow-up."
        }
        else{
            $script:DismRepairNoteLabel.Text = "Run Quick Diagnosis first. Override is available if symptoms justify it."
        }
    }
}

function Get-GUIDashboardInfo {
    $computer = $env:COMPUTERNAME
    $domain = ""

    try {
        $system = Get-CimInstance Win32_ComputerSystem -ErrorAction Stop
        $domain = $system.Domain
    }
    catch {
        $domain = $env:USERDOMAIN
    }

    return [pscustomobject]@{
        ComputerName = $computer
        Domain       = $domain
        PrivateIP    = Get-GUIPrivateIPSummary
        PublicIP     = "Checking..."
    }
}

function Get-SelectedCommand {
    if(!$script:CommandList -or $script:CommandList.SelectedIndex -lt 0){
        return $null
    }

    $index = $script:CommandList.SelectedIndex

    if($index -ge $script:Commands.Count){
        return $null
    }

    return $script:Commands[$index]
}

function Update-SelectedCommandDetails {
    $command = Get-SelectedCommand

    if(!$script:DescriptionBox){
        return
    }

    if(!$command){
        $script:DescriptionBox.Text = ""
        return
    }

    $admin = if($command.RequiresAdmin){"Yes"}else{"No"}

    $script:DescriptionBox.Text = @"
Name: $($command.Name)
Category: $($command.Category)
Source: $($command.Source)
Requires Admin: $admin

$($command.Description)
"@
}

function Start-SelectedCommand {
    $command = Get-SelectedCommand

    if(!$command){
        Add-GUILog "Select a tool first."
        return
    }

    $arguments = @(
        "-NoProfile"
        "-ExecutionPolicy"
        "Bypass"
        "-File"
        "`"$ToolkitLauncher`""
        "-RunCommand"
        "`"$($command.Name)`""
    )

    try {
        Start-CSIToolProcess `
            -FilePath "powershell.exe" `
            -ArgumentList $arguments `
            -WorkingDirectory $SharedToolkitRoot `
            -WindowStyle Hidden | Out-Null

        Add-GUILog "Launched: $($command.Name)"
    }
    catch {
        Add-GUILog "Failed to launch $($command.Name): $($_.Exception.Message)"
    }
}

function Start-GUICommandByName {
    param(
        [string]$Name,
        [System.Diagnostics.ProcessWindowStyle]$WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Normal
    )

    $command = Get-CSICommands | Where-Object {$_.Name -eq $Name} | Select-Object -First 1

    if(!$command){
        Add-GUILog "Command not found: $Name"
        return
    }

    $arguments = @(
        "-NoProfile"
        "-ExecutionPolicy"
        "Bypass"
        "-File"
        "`"$ToolkitLauncher`""
        "-RunCommand"
        "`"$Name`""
    )

    try {
        Start-CSIToolProcess `
            -FilePath "powershell.exe" `
            -ArgumentList $arguments `
            -WorkingDirectory $SharedToolkitRoot `
            -WindowStyle $WindowStyle | Out-Null

        Add-GUILog "Launched: $Name"
    }
    catch {
        Add-GUILog "Failed to launch ${Name}: $($_.Exception.Message)"
    }
}

function Start-GUIToolkitFunctionConsole {
    param(
        [string]$FunctionName,
        [string]$DisplayName = "",
        [switch]$RequiresAdmin
    )

    $toolLabel = if($DisplayName){$DisplayName}else{$FunctionName}
    $session = New-CSITempOutputSession -ToolName $toolLabel
    $runnerPath = Join-Path $session.Path "run-tool.ps1"

    $commandText = @"
try {
    `$ErrorActionPreference = "Continue"
    . "$ToolkitLauncher" -NoConsole
    `$metadata = [pscustomobject]@{
        Tool = "$($toolLabel.Replace('"','\"'))"
        Function = "$($FunctionName.Replace('"','\"'))"
        StartedAt = (Get-Date).ToString("s")
        ComputerName = `$env:COMPUTERNAME
        UserName = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    }
    `$metadata | ConvertTo-Json -Depth 4 | Set-Content -Path "$($session.Metadata)" -Encoding UTF8
    Start-Transcript -Path "$($session.Transcript)" -Force | Out-Null
    Write-Host ""
    Write-Host "Running: $($toolLabel.Replace('"','\"'))" -ForegroundColor Cyan
    Write-Host "Output session: $($session.Path)" -ForegroundColor DarkCyan
    Write-Host ""
    $FunctionName
}
catch [System.OperationCanceledException] {
    Write-Host ""
    Write-Host `$_.Exception.Message -ForegroundColor Yellow
}
catch {
    Write-Host ""
    Write-Host "Command failed." -ForegroundColor Red
    Write-Host `$_
}
finally {
    try { Stop-Transcript | Out-Null } catch {}
    Write-Host ""
    Write-Host "Output saved to:" -ForegroundColor Green
    Write-Host "$($session.Path)"
    Write-Host ""
    [void](Read-Host "Press ENTER to close")
}
"@

    try {
        $commandText | Set-Content -Path $runnerPath -Encoding UTF8

        Start-CSIToolProcess `
            -FilePath "powershell.exe" `
            -ArgumentList @("-NoProfile","-ExecutionPolicy","Bypass","-File","`"$runnerPath`"") `
            -WorkingDirectory $SharedToolkitRoot `
            -WindowStyle Normal `
            -Elevated:($RequiresAdmin -and !(Test-GUIAdministrator)) | Out-Null

        Add-GUILog "Launched: $toolLabel"
        Add-GUILog "Temp output session: $($session.Path)"
    }
    catch {
        Add-GUILog "Failed to launch ${toolLabel}: $($_.Exception.Message)"
    }
}

function Start-GUIExternalToolById {
    param([string]$Id)

    Start-GUIExternalFileTool -Id $Id
}

function Invoke-GUINamedAction {
    param([string]$Action)

    switch($Action){
        "Start-GUIDismSfcRepairPath" { Start-GUIDismSfcRepairPath; break }
        "Start-GUIPrintQueueMaintenance" { Start-GUIPrintQueueMaintenance; break }
        "Open-GUIOutputsFolder" { Open-GUIFolder $CSIPaths.Exports; break }
        "Open-GUITempOutputsFolder" { Open-GUIFolder (Get-CSITempOutputRoot); break }
        "Open-GUIDataFolder" { Open-GUIFolder $CSIPaths.Data; break }
        "Open-GUILogsFolder" { Open-GUIFolder $CSIPaths.Logs; break }
        "Open-GUIToolkitFolder" { Open-GUIFolder $CSIPaths.Root; break }
        default { Add-GUILog "Unknown GUI action: $Action"; break }
    }
}

function Start-GUIPrintQueueMaintenance {
    $toolPath = Join-Path $CSIPaths.Plugins "PrintQueues\Print Queue Cleanup\PrinterSpoolerTool.ps1"

    if(!(Test-Path $toolPath)){
        Add-GUILog "Print Queue Maintenance tool not found: $toolPath"
        [System.Windows.Forms.MessageBox]::Show(
            "The Print Queue Maintenance tool was not found.`r`n`r`n$toolPath",
            "Tool Not Found",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return
    }

    $dataRoot = Join-Path $CSIPaths.Data "PrintQueueTools"
    if(!(Test-Path $dataRoot)){
        New-Item -ItemType Directory -Path $dataRoot -Force | Out-Null
    }

    try {
        Start-CSIToolProcess `
            -FilePath "powershell.exe" `
            -ArgumentList @("-NoProfile","-WindowStyle","Hidden","-ExecutionPolicy","Bypass","-STA","-File","`"$toolPath`"","-ToolDataRoot","`"$dataRoot`"") `
            -WorkingDirectory (Split-Path -Parent $toolPath) `
            -WindowStyle Normal | Out-Null

        Add-GUILog "Launched Print Queue Maintenance."
    }
    catch {
        Add-GUILog "Failed to launch Print Queue Maintenance: $($_.Exception.Message)"
    }
}

function Get-GUISysinternalsRoot {
    return (Join-Path (Get-CSIExternalToolRoot) "Sysinternals")
}

function ConvertTo-GUISysinternalsBaseName {
    param([string]$Name)

    return ($Name -replace "(?i)64$","")
}

function Get-GUISysinternalsCategory {
    param([string]$BaseName)

    $name = $BaseName.ToLowerInvariant()

    if($name -in @("procexp","procmon","autoruns","autorunsc","listdlls","handle","loadord","loadordc","pslist","pskill","pssuspend","procdump")){
        return "Process And Startup"
    }

    if($name -in @("tcpview","tcpvcon","psping","whois","psfile","psloggedon")){
        return "Network"
    }

    if($name -in @("psexec","psgetsid","psinfo","psloglist","pspasswd","psservice","psshutdown")){
        return "PsTools"
    }

    if($name -in @("du","disk2vhd","diskext","diskmon","diskview","ntfsinfo","contig","sdelete","streams","sync","volumeid","pendmoves","movefile","junction","findlinks")){
        return "Disk And File"
    }

    if($name -in @("accesschk","accessenum","shareenum","sigcheck","sysmon","regdelnull","regjump","autologon","logonsessions")){
        return "Security And Registry"
    }

    if($name -in @("adexplorer","adinsight","adrestore")){
        return "Active Directory"
    }

    if($name -in @("rammap","vmmap","coreinfo","coreinfoex","clockres","cacheset","dbgview","livekd","winobj","bginfo","rdcman","desktops","zoomit")){
        return "System Inspection"
    }

    if($name -in @("notmyfault","notmyfaultc","testlimit","cpustres")){
        return "Stress And Caution"
    }

    return "Other"
}

function Test-GUISysinternalsConsoleTool {
    param([string]$BaseName)

    $consoleTools = @(
        "accesschk","adrestore","autorunsc","clockres","contig","coreinfo","coreinfoex",
        "du","efsdump","findlinks","handle","hex2dec","junction","ldmdump","listdlls",
        "livekd","logonsessions","movefile","ntfsinfo","pendmoves","pipelist","procdump",
        "psexec","psfile","psgetsid","psinfo","pskill","pslist","psloggedon","psloglist",
        "pspasswd","psping","psservice","psshutdown","pssuspend","regdelnull","ru",
        "sdelete","sigcheck","streams","strings","sync","sysmon","tcpvcon","testlimit",
        "volumeid","whois"
    )

    return $consoleTools -contains $BaseName.ToLowerInvariant()
}

function Test-GUISysinternalsRiskyTool {
    param([string]$BaseName)

    return @("notmyfault","notmyfaultc","testlimit","cpustres","sdelete","psshutdown") -contains $BaseName.ToLowerInvariant()
}

function Get-GUISysinternalsDescription {
    param(
        [string]$BaseName,
        [string]$FileName,
        [string]$Category,
        [bool]$Console,
        [bool]$Risky
    )

    $key = $BaseName.ToLowerInvariant()
    $descriptions = @{
        "accesschk" = "Checks file, folder, registry, service, and object permissions for access issues."
        "accessenum" = "Shows where permissions differ under a folder or registry path."
        "adexplorer" = "Browses Active Directory and can save snapshots for offline comparison."
        "adinsight" = "Traces LDAP calls from applications during Active Directory troubleshooting."
        "adrestore" = "Finds and can restore deleted Active Directory objects."
        "autoruns" = "Shows nearly every auto-start location for malware, bloat, and startup troubleshooting."
        "autorunsc" = "Command-line autoruns inventory for startup entries and persistence checks."
        "bginfo" = "Displays system identity details on the desktop for quick workstation labeling."
        "cacheset" = "Views and adjusts Windows file system cache working set values."
        "clockres" = "Shows system clock resolution, useful for timing and performance troubleshooting."
        "contig" = "Defragments individual files without running a full volume defrag."
        "coreinfo" = "Reports CPU topology, virtualization support, and processor feature flags."
        "coreinfoex" = "Extended CPU feature and topology reporting."
        "cpustres" = "Creates CPU load for testing cooling, stability, and monitoring behavior."
        "dbgview" = "Captures debug output from applications, drivers, and the kernel."
        "desktops" = "Creates multiple Windows desktop sessions for separating workspaces."
        "disk2vhd" = "Creates VHD/VHDX images from physical disks for capture or migration."
        "diskext" = "Maps volume extents to physical disk offsets."
        "diskmon" = "Shows live physical disk activity."
        "diskview" = "Visualizes disk cluster usage for file placement review."
        "du" = "Command-line disk usage by folder for finding space consumption quickly."
        "efsdump" = "Lists Encrypting File System information for encrypted files."
        "findlinks" = "Finds hard links that reference the same file data."
        "handle" = "Finds which process has a file, folder, registry key, or object open."
        "hex2dec" = "Converts hexadecimal and decimal values."
        "junction" = "Lists or manages NTFS junctions and reparse points."
        "ldmdump" = "Dumps Logical Disk Manager database information."
        "listdlls" = "Lists DLLs loaded by processes to troubleshoot modules and versions."
        "livekd" = "Runs kernel debugger analysis against a live system or dump source."
        "loadord" = "Shows driver and service load order."
        "loadordc" = "Command-line driver and service load order view."
        "logonsessions" = "Lists active logon sessions and associated processes."
        "movefile" = "Schedules file move/delete operations for the next reboot."
        "notmyfault" = "Crash and hang test utility for validating dump collection and recovery behavior."
        "notmyfaultc" = "Command-line crash and hang test utility."
        "ntfsinfo" = "Shows NTFS volume metadata such as MFT and cluster details."
        "pendmoves" = "Shows pending file rename/delete operations scheduled for reboot."
        "pipelist" = "Lists named pipes on the local computer."
        "procdump" = "Captures process dumps based on CPU, memory, hang, exception, or manual triggers."
        "procexp" = "Advanced Task Manager for process trees, handles, DLLs, signatures, and performance."
        "procmon" = "Live file, registry, process, thread, and network event trace."
        "psexec" = "Runs processes locally or remotely for admin troubleshooting."
        "psfile" = "Shows files opened remotely through file shares."
        "psgetsid" = "Translates account names and SIDs."
        "psinfo" = "Shows local or remote system inventory and uptime details."
        "pskill" = "Terminates local or remote processes."
        "pslist" = "Lists local or remote process and thread details."
        "psloggedon" = "Shows locally and remotely logged-on users."
        "psloglist" = "Dumps local or remote event logs."
        "pspasswd" = "Changes local or remote account passwords."
        "psping" = "Tests ICMP/TCP latency, packet loss, and bandwidth."
        "psservice" = "Views and controls local or remote Windows services."
        "psshutdown" = "Shuts down, reboots, logs off, or locks local or remote computers."
        "pssuspend" = "Suspends or resumes local or remote processes."
        "rammap" = "Breaks down physical memory usage and standby cache behavior."
        "rdcman" = "Manages groups of Remote Desktop connections."
        "regdelnull" = "Finds and deletes registry keys with embedded null characters."
        "regjump" = "Opens Registry Editor directly to a selected registry path."
        "sdelete" = "Securely deletes files or wipes free space."
        "shareenum" = "Enumerates network shares and share permissions."
        "sigcheck" = "Checks file signatures, versions, hashes, unsigned files, and VirusTotal lookups."
        "streams" = "Lists or removes NTFS alternate data streams."
        "strings" = "Extracts printable strings from binaries or other files."
        "sync" = "Flushes cached file system data to disk."
        "sysmon" = "Installs or controls Sysmon event collection."
        "tcpvcon" = "Command-line TCP/UDP endpoint viewer."
        "tcpview" = "Live TCP/UDP endpoint viewer with owning processes."
        "testlimit" = "Stress-tests memory, handles, processes, threads, and other limits."
        "vmmap" = "Shows detailed process virtual and physical memory usage."
        "volumeid" = "Changes FAT or NTFS volume serial numbers."
        "whois" = "Looks up domain registration and ownership records."
        "winobj" = "Browses the Windows Object Manager namespace."
        "zoomit" = "Screen zoom, annotation, and timer utility for demos and support."
    }

    if($descriptions.ContainsKey($key)){
        $description = $descriptions[$key]
    }
    else{
        switch($Category){
            "Process And Startup" { $description = "Process, startup, module, or dump troubleshooting utility."; break }
            "Network" { $description = "Network visibility or connectivity troubleshooting utility."; break }
            "PsTools" { $description = "PsTools remote administration and troubleshooting utility."; break }
            "Disk And File" { $description = "Disk, file system, or storage troubleshooting utility."; break }
            "Security And Registry" { $description = "Security, signature, permission, or registry troubleshooting utility."; break }
            "Active Directory" { $description = "Active Directory inspection or recovery utility."; break }
            "System Inspection" { $description = "System inspection, memory, driver, or debugging utility."; break }
            "Stress And Caution" { $description = "Stress or crash testing utility. Use only when you intend to test failure behavior."; break }
            default { $description = "Launches $FileName from the local Sysinternals folder."; break }
        }
    }

    if($Risky){
        $description += " Caution: this can change state, stress the computer, delete data, or reboot/shut down systems."
    }

    return $description
}

function Get-GUISysinternalsTools {
    $root = Get-GUISysinternalsRoot

    if(!(Test-Path $root)){
        return @()
    }

    $files = @(Get-ChildItem -Path $root -Filter "*.exe" -File -ErrorAction SilentlyContinue)
    $groups = $files | Group-Object { ConvertTo-GUISysinternalsBaseName $_.BaseName }
    $tools = @()

    foreach($group in $groups){
        $preferred = $group.Group |
            Sort-Object @{Expression={ if($_.BaseName -match "64$"){0}else{1} }},Name |
            Select-Object -First 1

        $base = ConvertTo-GUISysinternalsBaseName $preferred.BaseName

        $tools += [pscustomobject]@{
            Name = $base
            DisplayName = $base
            Path = $preferred.FullName
            FileName = $preferred.Name
            Category = Get-GUISysinternalsCategory -BaseName $base
            Console = Test-GUISysinternalsConsoleTool -BaseName $base
            Risky = Test-GUISysinternalsRiskyTool -BaseName $base
        }
    }

    return $tools | Sort-Object Category,DisplayName
}

function Start-GUISysinternalsTool {
    param(
        [string]$Path,
        [string]$DisplayName,
        [bool]$Console,
        [bool]$Risky
    )

    if(!(Test-Path $Path)){
        Add-GUILog "Sysinternals tool not found: $DisplayName"
        return
    }

    if($Risky){
        $confirm = [System.Windows.Forms.MessageBox]::Show(
            "$DisplayName can change system state, stress the computer, delete data, or shut down/reboot systems. Launch it?",
            "Sysinternals Caution",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )

        if($confirm -ne [System.Windows.Forms.DialogResult]::Yes){
            Add-GUILog "Cancelled Sysinternals tool: $DisplayName"
            return
        }
    }

    try {
        if($Console){
            $commandLine = "`"$Path`" -accepteula"
            Start-CSIToolProcess -FilePath "cmd.exe" -ArgumentList @("/k",$commandLine) -WorkingDirectory (Split-Path -Parent $Path) -WindowStyle Normal | Out-Null
        }
        else{
            Start-CSIToolProcess -FilePath $Path -ArgumentList @("-accepteula") -WorkingDirectory (Split-Path -Parent $Path) -WindowStyle Normal | Out-Null
        }

        Add-GUILog "Launched Sysinternals: $DisplayName"
    }
    catch {
        Add-GUILog "Failed to launch Sysinternals ${DisplayName}: $($_.Exception.Message)"
    }
}

function Start-GUIQuickDiagnosis {
    $target = "www.microsoft.com"

    if($script:QuickTargetBox -and $script:QuickTargetBox.Text.Trim()){
        $target = $script:QuickTargetBox.Text.Trim()
    }

    $commandText = ". `"$ToolkitLauncher`" -NoConsole; Invoke-QuickDiagnosis -Target `"$target`""

    try {
        $process = Start-CSIToolProcess `
            -FilePath "powershell.exe" `
            -ArgumentList @("-NoProfile","-ExecutionPolicy","Bypass","-Command",$commandText) `
            -WorkingDirectory $SharedToolkitRoot `
            -WindowStyle Hidden `
            -PassThru

        Add-GUILog "Quick Diagnosis started for target: $target"
        Write-GUIToolUsageLog -Tool "Quick Diagnosis" -Action "Started" -Detail "Target=$target"

        $timer = New-Object System.Windows.Forms.Timer
        $timer.Interval = 3000
        $timer.Add_Tick({
            if($process.HasExited){
                $timer.Stop()
                $timer.Dispose()
                Refresh-Fingerprints -Quiet
                Refresh-GUIDismSfcState
                Update-GUIComputerHealthLight
                $script:LatestQuickDiagnosisReport = Get-GUILatestQuickDiagnosisReport
                Add-GUILog "Quick Diagnosis completed. Computer profile state refreshed."
            }
        })
        $timer.Start()

        [System.Windows.Forms.MessageBox]::Show(
            "Quick Diagnosis is running. Use Open Latest Report when it completes.",
            "Quick Diagnosis",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null
    }
    catch {
        Add-GUILog "Failed to start Quick Diagnosis: $($_.Exception.Message)"
    }
}

function Start-GUIDismSfcRepairPath {
    if(!$script:DismSfcRecommended){
        $override = [System.Windows.Forms.MessageBox]::Show(
            "Quick Diagnosis has not indicated that DISM/SFC repair is needed.`r`n`r`nRun the repair path anyway?",
            "Override DISM/SFC Gate",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )

        if($override -ne [System.Windows.Forms.DialogResult]::Yes){
            Add-GUILog "DISM/SFC repair path override cancelled."
            return
        }
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Run DISM CheckHealth, ScanHealth, RestoreHealth, and SFC /scannow now? This can take a while.",
        "DISM/SFC Repair Path",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )

    if($confirm -ne [System.Windows.Forms.DialogResult]::Yes){
        Add-GUILog "DISM/SFC repair path cancelled."
        return
    }

    Start-GUICommandByName -Name "DISM/SFC Repair Path"
}

function Start-ToolkitConsole {
    try {
        Start-CSIToolProcess `
            -FilePath "powershell.exe" `
            -ArgumentList @("-NoProfile","-ExecutionPolicy","Bypass","-File","`"$ToolkitLauncher`"") `
            -WorkingDirectory $SharedToolkitRoot `
            -WindowStyle Normal | Out-Null

        Add-GUILog "Opened full console toolkit."
    }
    catch {
        Add-GUILog "Failed to open console toolkit: $($_.Exception.Message)"
    }
}

function Open-GUIFolder {
    param([string]$Path)

    if(!(Test-Path $Path)){
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }

    Start-CSIToolProcess -FilePath "explorer.exe" -ArgumentList @("`"$Path`"") | Out-Null
    Add-GUILog "Opened folder: $Path"
}

function Open-GUIHelpFile {
    if($CSIFiles.HelpFile -and (Test-Path $CSIFiles.HelpFile)){
        Start-CSIToolProcess -FilePath $CSIFiles.HelpFile | Out-Null
    }
    else{
        Add-GUILog "Help file not found."
    }
}

function Resolve-GUIToolkitPath {
    param([string]$Path)

    if(!$Path){
        return ""
    }

    if([IO.Path]::IsPathRooted($Path)){
        return $Path
    }

    return Join-Path (Split-Path -Parent $SharedToolkitRoot) ($Path.TrimStart(".","\","/"))
}

function Get-GUICustomTools {
    $tools = @()

    if($CSIFiles.CustomTools -and (Test-Path $CSIFiles.CustomTools)){
        try {
            $manifest = Get-Content -Raw -Path $CSIFiles.CustomTools | ConvertFrom-Json

            foreach($tool in @($manifest.tools)){
                $launchPath = Resolve-GUIToolkitPath $tool.launchPath
                $tools += [pscustomobject]@{
                    Name = $tool.name
                    Source = $tool.source
                    Version = $tool.version
                    LaunchPath = $launchPath
                    Arguments = $tool.arguments
                    Folder = if($tool.installPath){Resolve-GUIToolkitPath $tool.installPath}else{Split-Path -Parent $launchPath}
                    Status = if(Test-Path $launchPath){"Ready"}else{"Missing"}
                }
            }
        }
        catch {
            Add-GUILog "Custom tools manifest could not be read: $($_.Exception.Message)"
        }
    }

    return @($tools | Sort-Object Name)
}

function Refresh-GUICustomTools {
    if(!$script:CustomGrid){
        return
    }

    $script:CustomTools = @(Get-GUICustomTools)
    $script:CustomGrid.Rows.Clear()

    foreach($tool in $script:CustomTools){
        $rowIndex = $script:CustomGrid.Rows.Add($tool.Name,$tool.Source,$tool.Version,$tool.Status,$tool.LaunchPath)
        $script:CustomGrid.Rows[$rowIndex].Tag = $tool
    }

    Add-GUILog ("Custom tools loaded: {0}" -f $script:CustomTools.Count)
}

function ConvertTo-GUIRelativeToolkitPath {
    param([string]$Path)

    $toolkitBase = Split-Path -Parent $SharedToolkitRoot
    try {
        $baseUri = [Uri]((Resolve-Path $toolkitBase).Path.TrimEnd("\") + "\")
        $pathUri = [Uri]((Resolve-Path $Path).Path)
        return ".\" + ([Uri]::UnescapeDataString($baseUri.MakeRelativeUri($pathUri).ToString()) -replace "/","\")
    }
    catch {
        return $Path
    }
}

function Update-GUICustomToolsManifestEntry {
    param(
        [string]$Name,
        [string]$Version = "",
        [string]$LaunchPath,
        [string]$InstallPath,
        [string]$Source = "Chocolatey",
        [string]$Arguments = ""
    )

    if(!$CSIFiles.CustomTools){
        return
    }

    if(!(Test-Path $CSIPaths.Manifests)){
        New-Item -ItemType Directory -Path $CSIPaths.Manifests -Force | Out-Null
    }

    $manifest = [pscustomobject]@{ tools = @() }

    if(Test-Path $CSIFiles.CustomTools){
        try {
            $manifest = Get-Content -Raw -Path $CSIFiles.CustomTools | ConvertFrom-Json
        }
        catch {
            $manifest = [pscustomobject]@{ tools = @() }
        }
    }

    $existing = @($manifest.tools | Where-Object { $_.name -ne $Name })
    $entry = [pscustomobject]@{
        name = $Name
        source = $Source
        version = $Version
        launchPath = ConvertTo-GUIRelativeToolkitPath $LaunchPath
        installPath = ConvertTo-GUIRelativeToolkitPath $InstallPath
        arguments = $Arguments
    }

    $manifest = [pscustomobject]@{ tools = @($existing + $entry | Sort-Object name) }
    $manifest | ConvertTo-Json -Depth 6 | Set-Content -Path $CSIFiles.CustomTools -Encoding UTF8
}

function Remove-GUICustomToolsManifestEntry {
    param([string]$Name)

    if(!$Name -or !$CSIFiles.CustomTools -or !(Test-Path $CSIFiles.CustomTools)){
        return
    }

    try {
        $manifest = Get-Content -Raw -Path $CSIFiles.CustomTools | ConvertFrom-Json
        $manifest = [pscustomobject]@{
            tools = @($manifest.tools | Where-Object { $_.name -ne $Name } | Sort-Object name)
        }
        $manifest | ConvertTo-Json -Depth 6 | Set-Content -Path $CSIFiles.CustomTools -Encoding UTF8
    }
    catch {
        Add-GUILog "Could not update custom tools manifest: $($_.Exception.Message)"
    }
}

function Get-SelectedGUICustomTool {
    if(!$script:CustomGrid -or $script:CustomGrid.SelectedRows.Count -eq 0){
        return $null
    }

    return $script:CustomGrid.SelectedRows[0].Tag
}

function Start-SelectedGUICustomTool {
    $tool = Get-SelectedGUICustomTool

    if(!$tool){
        Add-GUILog "Select a custom tool first."
        return
    }

    if(!(Test-Path $tool.LaunchPath)){
        Add-GUILog "Custom tool missing: $($tool.LaunchPath)"
        return
    }

    $args = @()
    if($tool.Arguments){
        $args = @($tool.Arguments)
    }

    $extension = [System.IO.Path]::GetExtension($tool.LaunchPath).ToLowerInvariant()
    switch($extension){
        ".ps1" {
            $launchArgs = @("-NoProfile","-ExecutionPolicy","Bypass","-File","`"$($tool.LaunchPath)`"") + $args
            Start-CSIToolProcess -FilePath "powershell.exe" -ArgumentList $launchArgs -WorkingDirectory (Split-Path -Parent $tool.LaunchPath) -WindowStyle Normal | Out-Null
            break
        }
        ".bat" {
            Start-CSIToolProcess -FilePath "cmd.exe" -ArgumentList (@("/k","`"$($tool.LaunchPath)`"") + $args) -WorkingDirectory (Split-Path -Parent $tool.LaunchPath) -WindowStyle Normal | Out-Null
            break
        }
        ".cmd" {
            Start-CSIToolProcess -FilePath "cmd.exe" -ArgumentList (@("/k","`"$($tool.LaunchPath)`"") + $args) -WorkingDirectory (Split-Path -Parent $tool.LaunchPath) -WindowStyle Normal | Out-Null
            break
        }
        default {
            Start-CSIToolProcess -FilePath $tool.LaunchPath -ArgumentList $args -WorkingDirectory (Split-Path -Parent $tool.LaunchPath) -WindowStyle Normal | Out-Null
            break
        }
    }
    Add-GUILog "Launched custom tool: $($tool.Name)"
    Write-GUIToolUsageLog -Tool $tool.Name -Action "Launch" -Detail $tool.LaunchPath
}

function Start-GUIFirefoxPortable {
    $firefoxPath = Join-Path $CSIPaths.Custom "FirefoxPortable\FirefoxPortable.exe"

    if(!(Test-Path $firefoxPath)){
        Add-GUILog "Firefox Portable is not installed in the toolkit: $firefoxPath"
        [System.Windows.Forms.MessageBox]::Show(
            "Firefox Portable was not found in the toolkit.`r`n`r`nExpected path:`r`n$firefoxPath",
            "Firefox Portable Missing",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return
    }

    Start-CSIToolProcess `
        -FilePath $firefoxPath `
        -WorkingDirectory (Split-Path -Parent $firefoxPath) `
        -WindowStyle Normal | Out-Null

    Add-GUILog "Launched Firefox Portable."
    Write-GUIToolUsageLog -Tool "Firefox Portable" -Action "Launch" -Detail $firefoxPath
}

function Open-SelectedGUICustomToolFolder {
    $tool = Get-SelectedGUICustomTool

    if(!$tool){
        Add-GUILog "Select a custom tool first."
        return
    }

    Open-GUIFolder $tool.Folder
}

function Remove-SelectedGUICustomTool {
    $tool = Get-SelectedGUICustomTool

    if(!$tool){
        Add-GUILog "Select a custom tool first."
        return
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Remove '$($tool.Name)' from the toolbox?`r`n`r`nThis removes its manifest entry and can delete its Custom folder.",
        "Remove Custom Tool",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )

    if($confirm -ne [System.Windows.Forms.DialogResult]::Yes){
        return
    }

    try {
        Remove-GUICustomToolsManifestEntry -Name $tool.Name

        $folder = $tool.Folder
        if($folder -and (Test-Path $folder) -and $folder.StartsWith($CSIPaths.Custom,[System.StringComparison]::OrdinalIgnoreCase)){
            $deleteFolder = [System.Windows.Forms.MessageBox]::Show(
                "Delete the toolbox folder too?`r`n`r`n$folder",
                "Delete Custom Tool Files",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Question
            )

            if($deleteFolder -eq [System.Windows.Forms.DialogResult]::Yes){
                Remove-Item -LiteralPath $folder -Recurse -Force -ErrorAction SilentlyContinue
            }
        }

        Refresh-GUICustomTools
        Add-GUILog "Removed custom tool: $($tool.Name)"
    }
    catch {
        Add-GUILog "Failed to remove custom tool: $($_.Exception.Message)"
    }
}

function Get-SelectedFingerprint {
    if(!$script:FingerprintGrid -or $script:FingerprintGrid.SelectedRows.Count -eq 0){
        return $null
    }

    $row = $script:FingerprintGrid.SelectedRows[0]

    if($row.Tag){
        return $row.Tag
    }

    $index = $row.Index

    if($index -ge 0 -and $index -lt $script:Fingerprints.Count){
        return $script:Fingerprints[$index]
    }

    return $null
}

function Refresh-Fingerprints {
    param([switch]$Quiet)

    if(!$script:FingerprintGrid){
        return
    }

    $script:Fingerprints = @(Get-CSIStoredFingerprints)

    $script:FingerprintGrid.Rows.Clear()
    $script:FingerprintGrid.Columns.Clear()

    [void]$script:FingerprintGrid.Columns.Add("ComputerName","Computer")
    [void]$script:FingerprintGrid.Columns.Add("CapturedAt","Captured")
    [void]$script:FingerprintGrid.Columns.Add("UserName","User")
    [void]$script:FingerprintGrid.Columns.Add("Domain","Domain")

    foreach($fingerprint in $script:Fingerprints){
        $rowIndex = $script:FingerprintGrid.Rows.Add(
            $fingerprint.ComputerName,
            $fingerprint.CapturedAt,
            $fingerprint.UserName,
            $fingerprint.Domain
        )

        $script:FingerprintGrid.Rows[$rowIndex].Tag = $fingerprint
    }

    foreach($column in $script:FingerprintGrid.Columns){
        $column.AutoSizeMode = "Fill"
    }

    if($script:FingerprintGrid.Rows.Count -gt 0){
        $script:FingerprintGrid.Rows[0].Selected = $true
    }

    if(!$Quiet){
        Add-GUILog ("Computer profiles loaded: {0}" -f $script:Fingerprints.Count)
    }
}

function Open-SelectedFingerprintReport {
    $fingerprint = Get-SelectedFingerprint

    if(!$fingerprint){
        Add-GUILog "Select a computer profile first."
        return
    }

    Open-CSIComputerFingerprintReport -Path $fingerprint.Path
    Add-GUILog "Opened computer profile report: $($fingerprint.ComputerName)"
}

function Delete-SelectedFingerprint {
    $fingerprint = Get-SelectedFingerprint

    if(!$fingerprint){
        Add-GUILog "Select a computer profile first."
        return
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Delete computer profile for $($fingerprint.ComputerName)?",
        "Delete Computer Profile",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )

    if($confirm -ne [System.Windows.Forms.DialogResult]::Yes){
        Add-GUILog "Delete cancelled."
        return
    }

    $htmlPath = [IO.Path]::ChangeExtension($fingerprint.Path, ".html")

    Remove-Item -Path $fingerprint.Path -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $htmlPath -Force -ErrorAction SilentlyContinue

    Add-GUILog "Deleted computer profile: $($fingerprint.ComputerName)"
    Refresh-Fingerprints
}

function Take-FingerprintFromGUI {
    Start-GUIQuickDiagnosis
}

function Get-GUIChocoPath {
    $choco = Get-CSIChocolateyCommand

    if($script:ChocoStatusLabel){
        if($choco){
            $script:ChocoStatusLabel.Text = "Chocolatey ready: $choco"
            $script:ChocoStatusLabel.ForeColor = [System.Drawing.Color]::FromArgb(20,115,55)
        }
        else{
            $script:ChocoStatusLabel.Text = "Chocolatey is not installed or not on PATH."
            $script:ChocoStatusLabel.ForeColor = [System.Drawing.Color]::FromArgb(165,90,0)
        }
    }

    return $choco
}

function Refresh-GUIChocoStatus {
    [void](Get-GUIChocoPath)
    Add-GUILog "Refreshed Chocolatey status."
}

function Start-GUIChocolateyInstall {
    $existing = Get-GUIChocoPath

    if($existing){
        [System.Windows.Forms.MessageBox]::Show(
            "Chocolatey is already installed.`r`n`r`n$existing",
            "Chocolatey Ready",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null
        return
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Install Chocolatey now? This requires administrator rights and downloads the official installer from community.chocolatey.org.",
        "Install Chocolatey",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    if($confirm -ne [System.Windows.Forms.DialogResult]::Yes){
        Add-GUILog "Chocolatey install cancelled."
        return
    }

    $installCommand = @"
try {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Host ''
    Write-Host 'Chocolatey install command finished.'
}
catch {
    Write-Host ''
    Write-Host 'Chocolatey install failed.' -ForegroundColor Red
    Write-Host `$_.Exception.Message
}
finally {
    Write-Host ''
    Read-Host 'Press ENTER to close'
}
"@

    try {
        Start-CSIToolProcess `
            -FilePath "powershell.exe" `
            -ArgumentList @("-NoProfile","-ExecutionPolicy","Bypass","-Command",$installCommand) `
            -WindowStyle Normal `
            -Elevated:(!(Test-GUIAdministrator)) | Out-Null
        Add-GUILog "Started Chocolatey installer."
    }
    catch {
        Add-GUILog "Failed to start Chocolatey installer: $($_.Exception.Message)"
    }
}

function Search-GUIChocoPackages {
    $query = if($script:ChocoSearchBox){$script:ChocoSearchBox.Text.Trim()}else{""}

    if(!$query){
        Add-GUILog "Enter a Chocolatey package search term."
        return
    }

    $choco = Get-GUIChocoPath

    if(!$choco){
        Add-GUILog "Chocolatey is not installed."
        return
    }

    try {
        Add-GUILog "Searching Chocolatey for: $query"

        $raw = & $choco search $query --limit-output --page-size=30 2>&1
        $packages = @()

        foreach($line in $raw){
            if($line -notmatch "\|"){
                continue
            }

            $parts = $line.ToString().Split("|")
            $packages += [pscustomobject]@{
                Name = $parts[0]
                Version = if($parts.Count -gt 1){$parts[1]}else{""}
            }
        }

        $script:ChocoPackages = @($packages)
        $script:ChocoGrid.Rows.Clear()

        foreach($package in $script:ChocoPackages){
            $rowIndex = $script:ChocoGrid.Rows.Add($package.Name,$package.Version)
            $script:ChocoGrid.Rows[$rowIndex].Tag = $package
        }

        Add-GUILog ("Chocolatey packages found: {0}" -f $script:ChocoPackages.Count)
    }
    catch {
        Add-GUILog "Chocolatey search failed: $($_.Exception.Message)"
    }
}

function Refresh-GUIChocoInstalledPackages {
    $choco = Get-GUIChocoPath

    if(!$choco){
        Add-GUILog "Chocolatey is not installed."
        return
    }

    try {
        Add-GUILog "Scanning installed Chocolatey packages..."
        $raw = & $choco list --local-only --limit-output 2>&1
        $installed = @()

        foreach($line in $raw){
            if($line -notmatch "\|"){
                continue
            }

            $parts = $line.ToString().Split("|")
            $installed += [pscustomobject]@{
                Name = $parts[0]
                Version = if($parts.Count -gt 1){$parts[1]}else{""}
                Available = ""
            }
        }

        $outdatedRaw = & $choco outdated --limit-output 2>&1

        foreach($line in $outdatedRaw){
            if($line -notmatch "\|"){
                continue
            }

            $parts = $line.ToString().Split("|")
            $packageName = $parts[0]
            $available = if($parts.Count -gt 2){$parts[2]}else{""}
            $match = $installed | Where-Object { $_.Name -eq $packageName } | Select-Object -First 1

            if($match){
                $match.Available = $available
            }
        }

        $script:ChocoInstalledPackages = @($installed | Sort-Object Name)

        if($script:ChocoInstalledGrid){
            $script:ChocoInstalledGrid.Rows.Clear()

            foreach($package in $script:ChocoInstalledPackages){
                $state = if($package.Available){"Update available"}else{"Current"}
                $rowIndex = $script:ChocoInstalledGrid.Rows.Add($package.Name,$package.Version,$package.Available,$state)
                $script:ChocoInstalledGrid.Rows[$rowIndex].Tag = $package
            }
        }

        Add-GUILog ("Installed Chocolatey packages: {0}" -f $script:ChocoInstalledPackages.Count)
    }
    catch {
        Add-GUILog "Chocolatey installed-package scan failed: $($_.Exception.Message)"
    }
}

function Get-SelectedGUIChocoInstalledPackage {
    if(!$script:ChocoInstalledGrid -or $script:ChocoInstalledGrid.SelectedRows.Count -eq 0){
        return $null
    }

    return $script:ChocoInstalledGrid.SelectedRows[0].Tag
}

function Test-GUIChocoPackageInstalled {
    param([string]$PackageName)

    $choco = Get-GUIChocoPath
    if(!$choco -or !$PackageName){
        return $false
    }

    try {
        $raw = & $choco list --local-only --exact $PackageName --limit-output 2>$null
        $escaped = [regex]::Escape($PackageName)
        return [bool](@($raw | Where-Object { $_ -match "^$escaped\|" }).Count)
    }
    catch {
        return $false
    }
}

function Start-GUIChocoAction {
    param(
        [string]$PackageName,
        [ValidateSet("install","upgrade","uninstall")]
        [string]$Action
    )

    $choco = Get-GUIChocoPath

    if(!$choco){
        Add-GUILog "Chocolatey is not installed."
        return
    }

    $session = New-CSITempOutputSession -ToolName "Chocolatey-$Action-$PackageName"
    $scriptPath = Join-Path $session.Path "Run-ChocolateyAction.ps1"
    $escapedChoco = $choco.Replace("'","''")
    $escapedAction = $Action.Replace("'","''")
    $escapedPackage = $PackageName.Replace("'","''")
    $escapedTranscript = $session.Transcript.Replace("'","''")
    $escapedSessionPath = $session.Path.Replace("'","''")

    $scriptText = @"
try {
    `$ErrorActionPreference = 'Stop'
    Start-Transcript -Path '$escapedTranscript' -Force | Out-Null
    Write-Host "Chocolatey $escapedAction`: $escapedPackage" -ForegroundColor Cyan
    & '$escapedChoco' '$escapedAction' '$escapedPackage' --yes --no-progress
    `$code = `$LASTEXITCODE
    Write-Host ''
    Write-Host "Chocolatey $escapedAction finished with exit code `$code."
}
catch {
    Write-Host ''
    Write-Host "Chocolatey $escapedAction failed." -ForegroundColor Red
    Write-Host `$_.Exception.Message
}
finally {
    try { Stop-Transcript | Out-Null } catch {}
    Write-Host ''
    Write-Host "Output saved to: $escapedSessionPath" -ForegroundColor Green
    Read-Host 'Press ENTER to close'
}
"@

    Set-Content -Path $scriptPath -Value $scriptText -Encoding UTF8

    try {
        Start-CSIToolProcess `
            -FilePath "powershell.exe" `
            -ArgumentList @("-NoProfile","-ExecutionPolicy","Bypass","-File",$scriptPath) `
            -WindowStyle Normal `
            -Elevated:(!(Test-GUIAdministrator)) | Out-Null

        Add-GUILog "Started Chocolatey $Action for $PackageName."
        Write-GUIToolUsageLog -Tool "Chocolatey" -Action $Action -Detail $PackageName
    }
    catch {
        Add-GUILog "Failed to start Chocolatey $Action for ${PackageName}: $($_.Exception.Message)"
        Write-GUIToolUsageLog -Tool "Chocolatey" -Action "$Action-start-failed" -Detail $_.Exception.Message -Level "ERROR"
        [System.Windows.Forms.MessageBox]::Show(
            "Could not start Chocolatey $Action for '$PackageName'.`r`n`r`n$($_.Exception.Message)",
            "Chocolatey Action Failed",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
}

function Get-SelectedGUIChocoPackage {
    if(!$script:ChocoGrid -or $script:ChocoGrid.SelectedRows.Count -eq 0){
        return $null
    }

    return $script:ChocoGrid.SelectedRows[0].Tag
}

function Test-GUIChocoPackagePortable {
    param([pscustomobject]$Package)

    if(!$Package){
        return $false
    }

    if($Package.Name -match '(?i)(portable|\\.portable|portableapps)'){
        return $true
    }

    $choco = Get-GUIChocoPath
    if(!$choco){
        return $false
    }

    try {
        $info = (& $choco info $Package.Name 2>&1) -join " "
        return ($info -match '(?i)\bportable\b|portableapps|standalone|no install required')
    }
    catch {
        return $false
    }
}

function Get-GUIChocoPackageInfoText {
    param([string]$PackageName)

    $choco = Get-GUIChocoPath
    if(!$choco -or !$PackageName){
        return ""
    }

    try {
        return ((& $choco info $PackageName 2>&1) -join "`n")
    }
    catch {
        return ""
    }
}

function Get-GUIChocoPortableInstallArguments {
    param([pscustomobject]$Package)

    $args = @("install",$Package.Name,"--yes","--no-progress")
    $info = Get-GUIChocoPackageInfoText -PackageName $Package.Name

    if($info -match '(?i)--params\s+["'']?/Portable' -or $info -match '(?i)\s/Portable\s'){
        $args += @("--params","/Portable")
    }

    return $args
}

function Test-GUIChocoDownloadCommand {
    param([string]$ChocoPath)

    if(!$ChocoPath){
        return $false
    }

    try {
        $output = & $ChocoPath download --help 2>&1
        $text = ($output | Out-String)
        return ($LASTEXITCODE -eq 0 -and $text -notmatch "Could not find a command registered")
    }
    catch {
        return $false
    }
}

function Update-GUIChocolateyForDownloadCommand {
    param(
        [string]$ChocoPath,
        [pscustomobject]$Session
    )

    if($script:ChocoDownloadUpgradeAttempted){
        return
    }

    $script:ChocoDownloadUpgradeAttempted = $true

    if(!(Test-GUIAdministrator)){
        Add-GUILog "Chocolatey download command is unavailable. Skipping Chocolatey self-upgrade because the GUI is not elevated."
        return
    }

    Add-GUILog "Chocolatey download command is unavailable. Attempting Chocolatey self-upgrade first."
    $upgradeOutput = & $ChocoPath upgrade chocolatey --yes --no-progress 2>&1
    $upgradeExitCode = $LASTEXITCODE

    if($Session -and $Session.Transcript){
        Add-Content -Path $Session.Transcript -Encoding UTF8 -Value ""
        Add-Content -Path $Session.Transcript -Encoding UTF8 -Value "Chocolatey self-upgrade for download command"
        Add-Content -Path $Session.Transcript -Encoding UTF8 -Value ($upgradeOutput | Out-String)
    }

    if($upgradeExitCode -eq 0){
        Add-GUILog "Chocolatey self-upgrade completed. Rechecking download command."
    }
    else{
        Add-GUILog "Chocolatey self-upgrade returned exit code $upgradeExitCode. Falling back to direct package extraction."
    }
}

function Save-GUIChocoPackageViaChocoDownload {
    param(
        [pscustomobject]$Package,
        [pscustomobject]$Session
    )

    $choco = Get-GUIChocoPath
    if(!$choco){
        throw "Chocolatey is not installed."
    }

    if(!(Test-GUIChocoDownloadCommand -ChocoPath $choco)){
        Update-GUIChocolateyForDownloadCommand -ChocoPath $choco -Session $Session
    }

    if(!(Test-GUIChocoDownloadCommand -ChocoPath $choco)){
        throw "Chocolatey download command is not available."
    }

    $downloadRoot = Join-Path $Session.Path "choco-download-command"
    New-Item -ItemType Directory -Path $downloadRoot -Force | Out-Null

    $args = @("download",$Package.Name,"--output-directory",$downloadRoot,"--yes","--no-progress")
    if($Package.Version){
        $args += @("--version",$Package.Version)
    }

    Add-GUILog "Downloading package with Chocolatey download command: $($Package.Name)"
    $output = & $choco @args 2>&1
    $exitCode = $LASTEXITCODE

    if($Session -and $Session.Transcript){
        Add-Content -Path $Session.Transcript -Encoding UTF8 -Value ""
        Add-Content -Path $Session.Transcript -Encoding UTF8 -Value "Chocolatey download command: $($args -join ' ')"
        Add-Content -Path $Session.Transcript -Encoding UTF8 -Value ($output | Out-String)
    }

    if($exitCode -ne 0){
        $tail = (($output | Select-Object -Last 8) -join "`r`n").Trim()
        throw "Chocolatey download command failed with exit code $exitCode.`r`n$tail"
    }

    $nupkg = Get-ChildItem -Path $downloadRoot -Filter "*.nupkg" -Recurse -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if(!$nupkg){
        throw "Chocolatey download command completed but no .nupkg was found."
    }

    $extractRoot = Join-Path $Session.Path "package-expanded"
    New-Item -ItemType Directory -Path $extractRoot -Force | Out-Null
    Expand-Archive -Path $nupkg.FullName -DestinationPath $extractRoot -Force

    return [pscustomobject]@{
        PackagePath = $nupkg.FullName
        ExtractRoot = $extractRoot
    }
}

function Save-GUIChocoPackageToTemp {
    param(
        [pscustomobject]$Package,
        [pscustomobject]$Session
    )

    if(!$Package -or !$Package.Name){
        throw "No Chocolatey package was selected."
    }

    if(!$Session -or !$Session.Path){
        throw "No temp output session is available for package download."
    }

    try {
        return Save-GUIChocoPackageViaChocoDownload -Package $Package -Session $Session
    }
    catch {
        Add-GUILog "Chocolatey download command path unavailable: $($_.Exception.Message)"
        if($Session -and $Session.Transcript){
            Add-Content -Path $Session.Transcript -Encoding UTF8 -Value ""
            Add-Content -Path $Session.Transcript -Encoding UTF8 -Value "Chocolatey download command fallback: $($_.Exception.Message)"
        }
    }

    $packageRoot = Join-Path $Session.Path "package-download"
    $extractRoot = Join-Path $Session.Path "package-expanded"
    New-Item -ItemType Directory -Path $packageRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $extractRoot -Force | Out-Null

    $safePackageName = ($Package.Name -replace '[^A-Za-z0-9._-]+','_').Trim('_')
    if(!$safePackageName){
        $safePackageName = "package"
    }

    $nupkgPath = Join-Path $packageRoot "$safePackageName.nupkg"
    $encodedName = [System.Uri]::EscapeDataString($Package.Name)
    $packageUris = New-Object System.Collections.ArrayList

    if($Package.Version){
        [void]$packageUris.Add("https://community.chocolatey.org/api/v2/package/$encodedName/$($Package.Version)")
    }
    [void]$packageUris.Add("https://community.chocolatey.org/api/v2/package/$encodedName")

    $downloadErrors = New-Object System.Collections.ArrayList

    foreach($uri in $packageUris){
        try {
            Add-GUILog "Downloading Chocolatey package payload: $($Package.Name)"
            Invoke-WebRequest -Uri $uri -OutFile $nupkgPath -UseBasicParsing -TimeoutSec 45 -ErrorAction Stop

            if((Test-Path $nupkgPath) -and ((Get-Item $nupkgPath).Length -gt 0)){
                Add-Content -Path $Session.Transcript -Encoding UTF8 -Value "Downloaded package: $uri"
                break
            }
        }
        catch {
            [void]$downloadErrors.Add("$uri - $($_.Exception.Message)")
        }
    }

    if(!(Test-Path $nupkgPath) -or ((Get-Item $nupkgPath).Length -eq 0)){
        throw "Could not download the Chocolatey package without installing it.`r`n$($downloadErrors -join "`r`n")"
    }

    try {
        Expand-Archive -Path $nupkgPath -DestinationPath $extractRoot -Force
    }
    catch {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($nupkgPath,$extractRoot)
    }

    return [pscustomobject]@{
        PackagePath = $nupkgPath
        ExtractRoot = $extractRoot
    }
}

function Get-GUIChocoPackageExtractCandidateRoots {
    param([string]$ExtractRoot)

    if(!$ExtractRoot -or !(Test-Path $ExtractRoot)){
        return @()
    }

    $roots = New-Object System.Collections.ArrayList

    foreach($relative in @("tools","content","lib","")){
        $path = if($relative){ Join-Path $ExtractRoot $relative } else { $ExtractRoot }
        if(Test-Path $path){
            [void]$roots.Add($path)
        }
    }

    Get-ChildItem -Path $ExtractRoot -Directory -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match '(?i)^(tools?|app|bin|portable|content)$' } |
        ForEach-Object { [void]$roots.Add($_.FullName) }

    return @($roots | Sort-Object -Unique)
}

function Expand-GUIChocoPackagePayloadArchives {
    param(
        [string]$ExtractRoot,
        [pscustomobject]$Session
    )

    if(!$ExtractRoot -or !(Test-Path $ExtractRoot)){
        return @()
    }

    $expandedRoots = New-Object System.Collections.ArrayList
    $archiveRoot = Join-Path $ExtractRoot "_toolkit-expanded-payloads"
    $archives = @(
        Get-ChildItem -Path $ExtractRoot -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Extension -match '(?i)^\.(zip|7z)$' }
    )

    foreach($archive in $archives){
        try {
            $targetName = ($archive.BaseName -replace '[^A-Za-z0-9._-]+','_').Trim('_')
            if(!$targetName){
                $targetName = "payload"
            }

            $target = Join-Path $archiveRoot $targetName
            New-Item -ItemType Directory -Path $target -Force | Out-Null

            if($archive.Extension -ieq ".zip"){
                Expand-Archive -Path $archive.FullName -DestinationPath $target -Force
                [void]$expandedRoots.Add($target)
                if($Session -and $Session.Transcript){
                    Add-Content -Path $Session.Transcript -Encoding UTF8 -Value "Expanded package payload archive: $($archive.FullName)"
                }
            }
            elseif($archive.Extension -ieq ".7z"){
                $sevenZip = Get-Command 7z.exe -ErrorAction SilentlyContinue
                if($sevenZip){
                    & $sevenZip.Source x "-o$target" -y $archive.FullName | Out-Null
                    [void]$expandedRoots.Add($target)
                    if($Session -and $Session.Transcript){
                        Add-Content -Path $Session.Transcript -Encoding UTF8 -Value "Expanded package payload archive: $($archive.FullName)"
                    }
                }
            }
        }
        catch {
            if($Session -and $Session.Transcript){
                Add-Content -Path $Session.Transcript -Encoding UTF8 -Value "Could not expand payload archive $($archive.FullName): $($_.Exception.Message)"
            }
        }
    }

    return @($expandedRoots | Sort-Object -Unique)
}

function Get-GUIChocoLibCandidateRoots {
    param([string]$PackageName)

    $roots = New-Object System.Collections.ArrayList
    $libRoot = Join-Path $env:ProgramData "chocolatey\lib"

    foreach($name in @($PackageName, ($PackageName -replace '(?i)\.portable$','')) | Where-Object { $_ } | Select-Object -Unique){
        $direct = Join-Path $libRoot $name
        if(Test-Path $direct){
            [void]$roots.Add($direct)
        }
    }

    if(Test-Path $libRoot){
        $base = ($PackageName -replace '(?i)\.portable$','')
        Get-ChildItem -Path $libRoot -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -eq $PackageName -or $_.Name -eq $base -or $_.Name -like "$base*" } |
            ForEach-Object { [void]$roots.Add($_.FullName) }
    }

    return @($roots | Sort-Object -Unique)
}

function Get-GUIBestToolboxExecutable {
    param(
        [string]$Root,
        [string]$PackageName = ""
    )

    if(!(Test-Path $Root)){
        return $null
    }

    $executables = @(
        Get-ChildItem -Path $Root -Recurse -Filter *.exe -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -notmatch '(?i)(unins|uninstall|setup|install|update|crashreport|helper|elevate|shimgen)' }
    )

    if($executables.Count -eq 0){
        return $null
    }

    $baseNeedle = (($PackageName -replace '(?i)\.portable$','') -replace '[^A-Za-z0-9]+','').ToLowerInvariant()
    $preferred = $executables |
        Sort-Object @{Expression={
                        $base = ($_.BaseName -replace '[^A-Za-z0-9]+','').ToLowerInvariant()
                        if($baseNeedle -and $base -eq $baseNeedle){0}
                        elseif($baseNeedle -and $base -like "$baseNeedle*"){1}
                        elseif($_.BaseName -match '(?i)(portable|64|x64)'){2}
                        else{3}
                    }},
                    @{Expression={ if($_.DirectoryName -match '(?i)\\tools?$'){0}else{1} }},
                    @{Expression={ $_.FullName.Length }} |
        Select-Object -First 1

    return $preferred
}

function Add-SelectedChocoPackageToToolbox {
    $package = Get-SelectedGUIChocoPackage

    if(!$package){
        Add-GUILog "Select a Chocolatey package first."
        return
    }

    $choco = Get-GUIChocoPath
    if(!$choco){
        Add-GUILog "Chocolatey is not installed."
        return
    }

    $overrideNonPortable = $false
    if(!(Test-GUIChocoPackagePortable -Package $package)){
        $portableChoice = [System.Windows.Forms.MessageBox]::Show(
            "$($package.Name) does not look like a portable package.`r`n`r`nYes: search Chocolatey for portable variants.`r`nNo: try to add this package anyway.`r`nCancel: stop.",
            "Portable Package Check",
            [System.Windows.Forms.MessageBoxButtons]::YesNoCancel,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )

        if($portableChoice -eq [System.Windows.Forms.DialogResult]::Yes){
            $script:ChocoSearchBox.Text = "$($package.Name) portable"
            Search-GUIChocoPackages
            return
        }

        if($portableChoice -eq [System.Windows.Forms.DialogResult]::Cancel){
            Add-GUILog "Add to toolbox cancelled during portable package check."
            return
        }

        $overrideNonPortable = $true
        Add-GUILog "Portable check override approved for: $($package.Name)"
    }

    if(!$CSIPaths.Custom -or !(Test-Path $CSIPaths.Custom)){
        New-Item -ItemType Directory -Path $CSIPaths.Custom -Force | Out-Null
    }

    $safeName = ($package.Name -replace '[^A-Za-z0-9._-]+','_').Trim('_')
    if(!$safeName){
        $safeName = $package.Name
    }

    $dest = Join-Path $CSIPaths.Custom $safeName
    $destExisted = Test-Path $dest

    if($destExisted){
        $overwrite = [System.Windows.Forms.MessageBox]::Show(
            "$($package.Name) already exists in the Custom toolbox folder.`r`n`r`nReplace/update it?",
            "Update Toolbox Tool",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )

        if($overwrite -ne [System.Windows.Forms.DialogResult]::Yes){
            return
        }
    }

    $overrideNotice = ""
    if($overrideNonPortable){
        $overrideNotice = "`r`n`r`nWarning: this package did not advertise itself as portable. The toolkit will try it, then roll back copied files and temporary Chocolatey installs if the attempt fails."
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Add '$($package.Name)' to the portable toolbox?`r`n`r`nThe package will be installed/downloaded, copied into .\Custom\$safeName, registered, and the Custom tab will refresh.$overrideNotice",
        "Add To Toolbox",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    if($confirm -ne [System.Windows.Forms.DialogResult]::Yes){
        return
    }

    $oldCursor = $script:Form.Cursor
    $script:Form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    $backupDest = $null
    $session = $null
    $installedBefore = $false
    $cleanupPackageName = $package.Name
    $chocoInstallSucceeded = $false
    $manifestUpdated = $false
    $usedMachineInstallFallback = $false

    try {
        if($destExisted){
            $backupDest = Join-Path $CSIPaths.Custom ("{0}.rollback-{1}" -f $safeName,(Get-Date -Format "yyyyMMddHHmmss"))
            Move-Item -LiteralPath $dest -Destination $backupDest -Force
            Add-GUILog "Existing toolbox copy backed up for rollback: $safeName"
        }

        $session = New-CSITempOutputSession -ToolName "Choco-AddToToolbox-$($package.Name)"

        Add-GUILog "Adding Chocolatey package to toolbox without machine install: $($package.Name)"
        $downloadedPackage = Save-GUIChocoPackageToTemp -Package $package -Session $session
        $candidateRoots = @(Get-GUIChocoPackageExtractCandidateRoots -ExtractRoot $downloadedPackage.ExtractRoot)
        $candidateRoots += @(Expand-GUIChocoPackagePayloadArchives -ExtractRoot $downloadedPackage.ExtractRoot -Session $session)
        $candidateRoots = @($candidateRoots | Sort-Object -Unique)
        $bestExe = $null

        foreach($root in $candidateRoots){
            $bestExe = Get-GUIBestToolboxExecutable -Root $root -PackageName $package.Name
            if($bestExe){
                break
            }
        }

        if(!$bestExe){
            $fallbackChoice = [System.Windows.Forms.MessageBox]::Show(
                "The Chocolatey package downloaded successfully, but no runnable EXE was found inside the package payload.`r`n`r`nSome packages only contain install scripts that download the app during install.`r`n`r`nTemporarily install this package on the computer, copy the app into the toolbox, and uninstall it afterward?",
                "Machine Install Fallback",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )

            if($fallbackChoice -ne [System.Windows.Forms.DialogResult]::Yes){
                throw "No runnable executable was found in the downloaded package. Machine install fallback was not approved."
            }

            if(!(Test-GUIAdministrator)){
                throw "Machine install fallback needs the GUI running elevated so Chocolatey can install package files temporarily."
            }

            $usedMachineInstallFallback = $true
            $installedBefore = Test-GUIChocoPackageInstalled -PackageName $package.Name

            Add-GUILog "Using temporary machine install fallback for: $($package.Name)"
            $installArgs = Get-GUIChocoPortableInstallArguments -Package $package
            $installOutput = & $choco @installArgs 2>&1
            $installExitCode = $LASTEXITCODE
            Add-Content -Path $session.Transcript -Encoding UTF8 -Value ""
            Add-Content -Path $session.Transcript -Encoding UTF8 -Value "Machine install fallback: $($package.Name)"
            Add-Content -Path $session.Transcript -Encoding UTF8 -Value ($installOutput | Out-String)

            if($installExitCode -ne 0){
                $tail = (($installOutput | Select-Object -Last 8) -join "`r`n").Trim()
                throw "Chocolatey fallback install failed with exit code $installExitCode.`r`n$tail"
            }
            $chocoInstallSucceeded = $true

            $candidateRoots = @(Get-GUIChocoLibCandidateRoots -PackageName $package.Name)
            foreach($root in $candidateRoots){
                $bestExe = Get-GUIBestToolboxExecutable -Root $root -PackageName $package.Name
                if($bestExe){
                    break
                }
            }

            if(!$bestExe -and $package.Name -match '(?i)\.portable$'){
                $baseName = $package.Name -replace '(?i)\.portable$',''
                $baseInfo = Get-GUIChocoPackageInfoText -PackageName $baseName

                if($baseInfo -match '(?i)\s/Portable\s|--params\s+["'']?/Portable'){
                    Add-GUILog "No executable found for $($package.Name). Trying $baseName with portable parameters."
                    $basePackage = [pscustomobject]@{ Name = $baseName; Version = $package.Version }
                    $baseInstalledBefore = Test-GUIChocoPackageInstalled -PackageName $baseName
                    $baseArgs = Get-GUIChocoPortableInstallArguments -Package $basePackage
                    $baseOutput = & $choco @baseArgs 2>&1
                    $baseExitCode = $LASTEXITCODE
                    Add-Content -Path $session.Transcript -Encoding UTF8 -Value ""
                    Add-Content -Path $session.Transcript -Encoding UTF8 -Value "Fallback install: $baseName"
                    Add-Content -Path $session.Transcript -Encoding UTF8 -Value ($baseOutput | Out-String)

                    if($baseExitCode -eq 0){
                        $cleanupPackageName = $baseName
                        $installedBefore = $baseInstalledBefore
                        $chocoInstallSucceeded = $true
                        $candidateRoots = @(Get-GUIChocoLibCandidateRoots -PackageName $baseName)
                        foreach($root in $candidateRoots){
                            $bestExe = Get-GUIBestToolboxExecutable -Root $root -PackageName $baseName
                            if($bestExe){
                                break
                            }
                        }
                    }
                }
            }
        }

        if(!$bestExe){
            throw "No runnable executable was found after Chocolatey processed the package."
        }

        $sourceFolder = $bestExe.DirectoryName
        New-Item -ItemType Directory -Path $dest -Force | Out-Null
        Copy-Item -Path (Join-Path $sourceFolder "*") -Destination $dest -Recurse -Force

        $launchExe = Get-GUIBestToolboxExecutable -Root $dest -PackageName $package.Name
        if(!$launchExe){
            throw "The package copied into Custom, but no launchable executable was found."
        }

        Update-GUICustomToolsManifestEntry `
            -Name $package.Name `
            -Version $package.Version `
            -LaunchPath $launchExe.FullName `
            -InstallPath $dest `
            -Source "Chocolatey Toolbox"
        $manifestUpdated = $true

        Refresh-GUICustomTools
        if($usedMachineInstallFallback -and !$installedBefore -and $cleanupPackageName){
            Add-GUILog "Cleaning temporary Chocolatey package install from computer: $cleanupPackageName"
            $cleanupOutput = & $choco uninstall $cleanupPackageName --yes --no-progress 2>&1
            Add-Content -Path $session.Transcript -Encoding UTF8 -Value ""
            Add-Content -Path $session.Transcript -Encoding UTF8 -Value "Cleanup uninstall: $cleanupPackageName"
            Add-Content -Path $session.Transcript -Encoding UTF8 -Value ($cleanupOutput | Out-String)
            Refresh-GUIChocoInstalledPackages
        }

        if($backupDest -and (Test-Path $backupDest)){
            Remove-Item -LiteralPath $backupDest -Recurse -Force -ErrorAction SilentlyContinue
        }

        Add-GUILog "Added to toolbox: $($package.Name)"

        [System.Windows.Forms.MessageBox]::Show(
            "$($package.Name) was added to the Custom toolbox and is ready to launch.",
            "Added To Toolbox",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null
    }
    catch {
        Add-GUILog "Rolling back toolbox add attempt for: $($package.Name)"

        if($manifestUpdated){
            Remove-GUICustomToolsManifestEntry -Name $package.Name
        }

        if(Test-Path $dest){
            Remove-Item -LiteralPath $dest -Recurse -Force -ErrorAction SilentlyContinue
        }

        if($backupDest -and (Test-Path $backupDest)){
            Move-Item -LiteralPath $backupDest -Destination $dest -Force
            Add-GUILog "Restored previous toolbox copy: $safeName"
        }

        if($chocoInstallSucceeded -and !$installedBefore -and $cleanupPackageName){
            try {
                Add-GUILog "Cleaning failed temporary Chocolatey install: $cleanupPackageName"
                $rollbackOutput = & $choco uninstall $cleanupPackageName --yes --no-progress 2>&1
                if($session -and $session.Transcript){
                    Add-Content -Path $session.Transcript -Encoding UTF8 -Value ""
                    Add-Content -Path $session.Transcript -Encoding UTF8 -Value "Rollback uninstall: $cleanupPackageName"
                    Add-Content -Path $session.Transcript -Encoding UTF8 -Value ($rollbackOutput | Out-String)
                }
                Refresh-GUIChocoInstalledPackages
            }
            catch {
                Add-GUILog "Rollback uninstall failed: $($_.Exception.Message)"
            }
        }

        Refresh-GUICustomTools
        Add-GUILog "Add to toolbox failed: $($_.Exception.Message)"
        [System.Windows.Forms.MessageBox]::Show(
            "Could not add $($package.Name) to the toolbox.`r`n`r`nRollback cleanup was attempted so the Custom toolbox stays clean.`r`n`r`n$($_.Exception.Message)",
            "Add To Toolbox Failed",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
    finally {
        $script:Form.Cursor = $oldCursor
    }
}

function Install-SelectedGUIChocoPackage {
    $package = Get-SelectedGUIChocoPackage

    if(!$package){
        Add-GUILog "Select a Chocolatey package first."
        return
    }

    $choco = Get-GUIChocoPath

    if(!$choco){
        Add-GUILog "Chocolatey is not installed."
        return
    }

    if(($script:ChocoInstalledPackages | Where-Object { $_.Name -eq $package.Name } | Select-Object -First 1) -or (& $choco list --local-only --exact $package.Name --limit-output 2>$null)){
        [System.Windows.Forms.MessageBox]::Show(
            "$($package.Name) is already installed by Chocolatey.`r`n`r`nUse the Installed Packages section to upgrade or uninstall it.",
            "Package Already Installed",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null
        Add-GUILog "Chocolatey package already installed: $($package.Name)"
        Refresh-GUIChocoInstalledPackages
        return
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Install Chocolatey package '$($package.Name)'?",
        "Install Package",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    if($confirm -ne [System.Windows.Forms.DialogResult]::Yes){
        Add-GUILog "Package install cancelled."
        return
    }

    try {
        Start-GUIChocoAction -PackageName $package.Name -Action install
    }
    catch {
        Add-GUILog "Failed to start package install: $($_.Exception.Message)"
    }
}

function Upgrade-SelectedGUIChocoPackage {
    $package = Get-SelectedGUIChocoInstalledPackage

    if(!$package){
        Add-GUILog "Select an installed Chocolatey package first."
        return
    }

    Start-GUIChocoAction -PackageName $package.Name -Action upgrade
}

function Upgrade-AllGUIChocoPackages {
    $choco = Get-GUIChocoPath

    if(!$choco){
        Add-GUILog "Chocolatey is not installed."
        return
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Upgrade all Chocolatey packages installed on this computer?",
        "Upgrade All Chocolatey Packages",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )

    if($confirm -ne [System.Windows.Forms.DialogResult]::Yes){
        Add-GUILog "Chocolatey upgrade all cancelled."
        return
    }

    $session = New-CSITempOutputSession -ToolName "Chocolatey-Upgrade-All"
    $command = @"
try {
    Start-Transcript -Path "$($session.Transcript)" -Force | Out-Null
    & "$choco" upgrade all --yes --no-progress
    `$code = `$LASTEXITCODE
    Write-Host ''
    Write-Host "Chocolatey upgrade all finished with exit code `$code."
}
catch {
    Write-Host ''
    Write-Host "Chocolatey upgrade all failed." -ForegroundColor Red
    Write-Host `$_.Exception.Message
}
finally {
    try { Stop-Transcript | Out-Null } catch {}
    Write-Host ''
    Write-Host "Output saved to: $($session.Path)" -ForegroundColor Green
    Read-Host 'Press ENTER to close'
}
"@

    Start-CSIToolProcess `
        -FilePath "powershell.exe" `
        -ArgumentList @("-NoProfile","-ExecutionPolicy","Bypass","-Command",$command) `
        -WindowStyle Normal `
        -Elevated:(!(Test-GUIAdministrator)) | Out-Null

    Add-GUILog "Started Chocolatey upgrade all."
    Write-GUIToolUsageLog -Tool "Chocolatey" -Action "upgrade-all" -Detail "all"
}

function Uninstall-SelectedGUIChocoPackage {
    $package = Get-SelectedGUIChocoInstalledPackage

    if(!$package){
        Add-GUILog "Select an installed Chocolatey package first."
        return
    }

    if($package.Name -eq "chocolatey"){
        $selfConfirm = [System.Windows.Forms.MessageBox]::Show(
            "You selected the Chocolatey package itself.`r`n`r`nUninstalling Chocolatey will remove the package manager this tab depends on. Continue anyway?",
            "Uninstall Chocolatey?",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )

        if($selfConfirm -ne [System.Windows.Forms.DialogResult]::Yes){
            Add-GUILog "Chocolatey self-uninstall cancelled."
            return
        }
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Uninstall Chocolatey package '$($package.Name)' from this computer?`r`n`r`nThis does not remove tools copied into the portable toolkit Custom folder.",
        "Uninstall From Computer",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )

    if($confirm -eq [System.Windows.Forms.DialogResult]::Yes){
        Start-GUIChocoAction -PackageName $package.Name -Action uninstall
    }
}

function ConvertTo-GUICommandToken {
    param([string]$Value)

    if($Value -match "^/"){
        return $Value
    }

    if($Value -match "\s"){
        return "`"$Value`""
    }

    return $Value
}

function Get-GUIRobocopyPlan {
    if(!$script:RobocopySourceBox -or !$script:RobocopyDestinationBox){
        return $null
    }

    $source = $script:RobocopySourceBox.Text.Trim()
    $destination = $script:RobocopyDestinationBox.Text.Trim()

    if(!$source -or !$destination){
        throw "Source and destination are required."
    }

    $patternInput = $script:RobocopyPatternBox.Text.Trim()
    $filePatterns = @("*.*")

    if($patternInput){
        $filePatterns = @($patternInput -split "," | ForEach-Object {$_.Trim()} | Where-Object {$_})
    }

    $switches = @()
    $reasons = @()

    switch($script:RobocopyCopyTypeBox.SelectedItem){
        "Mirror destination to source" {
            $switches += "/MIR"
            $reasons += "Mirrors the destination to match the source, including deletes."
        }
        "Unreliable network copy" {
            $switches += "/E"
            $switches += "/Z"
            $reasons += "Copies all folders and uses restartable mode for interrupted network copies."
        }
        "Permission-preserving migration" {
            $switches += "/E"
            $reasons += "Copies all folders and prepares for security-preserving migration."
        }
        default {
            $switches += "/E"
            $reasons += "Copies all subfolders, including empty folders."
        }
    }

    switch($script:RobocopyMetadataBox.SelectedItem){
        "Preserve NTFS permissions" {
            $switches += "/COPY:DATS"
            $switches += "/DCOPY:DAT"
            $switches += "/SECFIX"
            $reasons += "Preserves NTFS security and fixes skipped-file security."
        }
        "Full owner and audit migration" {
            $switches += "/COPYALL"
            $switches += "/DCOPY:DAT"
            $switches += "/SECFIX"
            $reasons += "Copies all available metadata including owner and audit information."
        }
        default {
            $switches += "/COPY:DAT"
            $switches += "/DCOPY:DAT"
            $reasons += "Copies data, attributes, and timestamps."
        }
    }

    switch($script:RobocopyRetryBox.SelectedItem){
        "Balanced" {
            $switches += "/R:3"
            $switches += "/W:5"
            $reasons += "Retries failed files three times with a five-second wait."
        }
        "Patient migration" {
            $switches += "/R:10"
            $switches += "/W:10"
            if($switches -notcontains "/Z"){
                $switches += "/Z"
            }
            $reasons += "Retries longer and uses restartable mode."
        }
        default {
            $switches += "/R:1"
            $switches += "/W:1"
            $reasons += "Fails quickly so troubleshooting is not held up by locked files."
        }
    }

    switch($script:RobocopyThreadsBox.SelectedItem){
        "Gentle" { $switches += "/MT:4" }
        "Fast" { $switches += "/MT:32" }
        default { $switches += "/MT:16" }
    }

    if($script:RobocopyNasCheck.Checked){
        $switches += "/FFT"
        $reasons += "Allows two-second timestamp tolerance for NAS and non-Windows shares."
    }

    if($script:RobocopyNoProgressCheck.Checked){
        $switches += "/NP"
    }

    $excludeFiles = @($script:RobocopyExcludeFilesBox.Text -split "," | ForEach-Object {$_.Trim()} | Where-Object {$_})
    if($excludeFiles.Count -gt 0){
        $switches += "/XF"
        $switches += $excludeFiles
    }

    $excludeFolders = @($script:RobocopyExcludeFoldersBox.Text -split "," | ForEach-Object {$_.Trim()} | Where-Object {$_})
    if($excludeFolders.Count -gt 0){
        $switches += "/XD"
        $switches += $excludeFolders
    }

    if($script:RobocopyLogCheck.Checked){
        if(!(Test-Path $CSIPaths.Exports)){
            New-Item -ItemType Directory -Path $CSIPaths.Exports -Force | Out-Null
        }

        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $logPath = Join-Path $CSIPaths.Exports "robocopy-$timestamp.log"
        $switches += "/TEE"
        $switches += "/LOG:`"$logPath`""
        $reasons += "Writes a robocopy log to the toolkit Outputs folder."
    }

    $command = Format-CSIRobocopyCommand `
        -Source $source `
        -Destination $destination `
        -FilePatterns $filePatterns `
        -Switches $switches

    return [pscustomobject]@{
        Command = $command
        Reasons = $reasons
    }
}

function Update-GUIRobocopyCommand {
    try {
        $plan = Get-GUIRobocopyPlan
        $text = $plan.Command

        if($plan.Reasons.Count -gt 0){
            $text += [Environment]::NewLine
            $text += [Environment]::NewLine
            $text += "Why these switches:"
            foreach($reason in $plan.Reasons){
                $text += [Environment]::NewLine + "- " + $reason
            }
        }

        $script:RobocopyCommandBox.Text = $text
        Add-GUILog "Built robocopy command."
        return $plan
    }
    catch {
        $script:RobocopyCommandBox.Text = ""
        Add-GUILog "Robocopy builder: $($_.Exception.Message)"
        return $null
    }
}

function Copy-GUIRobocopyCommand {
    $plan = Update-GUIRobocopyCommand

    if(!$plan){
        return
    }

    Set-Clipboard -Value $plan.Command
    Add-GUILog "Copied robocopy command to clipboard."
}

function Start-GUIRobocopyCommand {
    param([switch]$Preview)

    $plan = Update-GUIRobocopyCommand

    if(!$plan){
        return
    }

    $command = $plan.Command

    if($Preview -and $command -notmatch "\s/L(\s|$)"){
        $command += " /L"
    }

    if(!$Preview){
        $confirm = [System.Windows.Forms.MessageBox]::Show(
            "Run this robocopy command now?",
            "Run Robocopy",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )

        if($confirm -ne [System.Windows.Forms.DialogResult]::Yes){
            Add-GUILog "Robocopy run cancelled."
            return
        }
    }

    Start-CSIToolProcess -FilePath "cmd.exe" -ArgumentList @("/k",$command) -WindowStyle Normal | Out-Null

    if($Preview){
        Add-GUILog "Started robocopy preview."
    }
    else{
        Add-GUILog "Started robocopy copy."
    }
}

function Start-GUIExternalFileTool {
    param([string]$Id)

    try {
        $tool = Resolve-CSIExternalTool -Id $Id

        if(!$tool -or !$tool.Found){
            Add-GUILog "External tool not found: $Id"
            return
        }

        $arguments = @($tool.Arguments | Where-Object {$null -ne $_ -and $_ -ne ""})

        if($Id -eq "Handle"){
            $searchText = $script:HandleSearchBox.Text.Trim()

            if($searchText){
                $arguments += $searchText
            }
        }

        if($tool.Console){
            $escapedArguments = @($arguments | ForEach-Object { ConvertTo-GUICommandToken $_ })
            $commandLine = "`"$($tool.Path)`""

            if($escapedArguments.Count -gt 0){
                $commandLine += " " + ($escapedArguments -join " ")
            }

            $consoleTool = [pscustomobject]@{
                Path = "cmd.exe"
                RequiresAdmin = $tool.RequiresAdmin
            }

            Start-CSIExternalProcess -Tool $consoleTool -Arguments @("/k",$commandLine)
        }
        else{
            Start-CSIExternalProcess -Tool $tool -Arguments $arguments
        }

        Add-GUILog "Launched: $($tool.Name)"
    }
    catch {
        Add-GUILog "Failed to launch ${Id}: $($_.Exception.Message)"
    }
}

function Build-FingerprintPage {
    param([System.Windows.Forms.TabPage]$Page)

    $layout = New-Object System.Windows.Forms.TableLayoutPanel
    $layout.Dock = "Fill"
    $layout.RowCount = 2
    $layout.ColumnCount = 1
    $layout.Padding = New-Object System.Windows.Forms.Padding(10)
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,48))) | Out-Null
    $Page.Controls.Add($layout)

    $script:FingerprintGrid = New-Object System.Windows.Forms.DataGridView
    $FingerprintGrid.Dock = "Fill"
    $FingerprintGrid.ReadOnly = $true
    $FingerprintGrid.AllowUserToAddRows = $false
    $FingerprintGrid.AllowUserToDeleteRows = $false
    $FingerprintGrid.RowHeadersVisible = $false
    $FingerprintGrid.MultiSelect = $false
    $FingerprintGrid.SelectionMode = "FullRowSelect"
    $FingerprintGrid.AutoSizeColumnsMode = "Fill"
    $FingerprintGrid.BackgroundColor = [System.Drawing.Color]::White
    $FingerprintGrid.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10)
    $layout.Controls.Add($FingerprintGrid,0,0)

    $buttons = New-Object System.Windows.Forms.FlowLayoutPanel
    $buttons.Dock = "Fill"
    $buttons.FlowDirection = "LeftToRight"
    $layout.Controls.Add($buttons,0,1)

    foreach($buttonDef in @(
        @{ Text = "Open HTML Report"; Action = { Open-SelectedFingerprintReport } },
        @{ Text = "Create Profile"; Action = { Take-FingerprintFromGUI } },
        @{ Text = "Delete"; Action = { Delete-SelectedFingerprint } },
        @{ Text = "Refresh"; Action = { Refresh-Fingerprints } }
    )){
        $button = New-Object System.Windows.Forms.Button
        $button.Text = $buttonDef.Text
        $button.Tag = $buttonDef.Action
        $button.Width = 160
        $button.Height = 32
        $button.Margin = New-Object System.Windows.Forms.Padding(6)
        $button.Add_Click({
            param($sender,$eventArgs)
            & $sender.Tag
        })
        [void]$buttons.Controls.Add($button)
    }

    $FingerprintGrid.Add_CellDoubleClick({ Open-SelectedFingerprintReport })
}

function Build-QuickTriagePage {
    param([System.Windows.Forms.TabPage]$Page)

    $layout = New-Object System.Windows.Forms.TableLayoutPanel
    $layout.Dock = "Fill"
    $layout.ColumnCount = 1
    $layout.RowCount = 2
    $layout.Padding = New-Object System.Windows.Forms.Padding(16)
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,82))) | Out-Null
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $Page.Controls.Add($layout)

    $runGroup = New-Object System.Windows.Forms.GroupBox
    $runGroup.Text = "Quick Diagnosis"
    $runGroup.Dock = "Fill"
    $runGroup.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $layout.Controls.Add($runGroup,0,0)

    $runPanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $runPanel.Dock = "Fill"
    $runPanel.Padding = New-Object System.Windows.Forms.Padding(10)
    $runGroup.Controls.Add($runPanel)

    $targetLabel = New-GUILabel "Internet test target"
    $targetLabel.Dock = "None"
    $targetLabel.Width = 130
    $targetLabel.Height = 30
    $targetLabel.Margin = New-Object System.Windows.Forms.Padding(3,7,6,3)
    [void]$runPanel.Controls.Add($targetLabel)

    $script:QuickTargetBox = New-GUITextBox "www.microsoft.com"
    $QuickTargetBox.Dock = "None"
    $QuickTargetBox.Width = 260
    $QuickTargetBox.Height = 26
    $QuickTargetBox.Margin = New-Object System.Windows.Forms.Padding(3,8,10,3)
    [void]$runPanel.Controls.Add($QuickTargetBox)

    $script:QuickRunButton = New-GUIButton "Run Quick Diagnosis" { Start-GUIQuickDiagnosis }
    $QuickRunButton.Width = 190
    [void]$runPanel.Controls.Add($QuickRunButton)

    $reportButton = New-GUIButton "Open Latest Report" { Open-GUILatestQuickDiagnosisReport }
    $reportButton.Width = 160
    [void]$runPanel.Controls.Add($reportButton)

    $lowerLayout = New-Object System.Windows.Forms.TableLayoutPanel
    $lowerLayout.Dock = "Fill"
    $lowerLayout.ColumnCount = 2
    $lowerLayout.RowCount = 1
    $lowerLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,58))) | Out-Null
    $lowerLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,42))) | Out-Null
    $lowerLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $layout.Controls.Add($lowerLayout,0,1)

    $statusGroup = New-Object System.Windows.Forms.GroupBox
    $statusGroup.Text = "Live Status"
    $statusGroup.Dock = "Fill"
    $statusGroup.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $lowerLayout.Controls.Add($statusGroup,0,0)

    $statusLayout = New-Object System.Windows.Forms.TableLayoutPanel
    $statusLayout.Dock = "Fill"
    $statusLayout.ColumnCount = 1
    $statusLayout.RowCount = 3
    $statusLayout.Padding = New-Object System.Windows.Forms.Padding(12)
    $statusLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $statusLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,54))) | Out-Null
    $statusLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,54))) | Out-Null
    $statusLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $statusGroup.Controls.Add($statusLayout)

    $healthPanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $healthPanel.Dock = "Fill"
    $healthPanel.FlowDirection = "LeftToRight"
    $statusLayout.Controls.Add($healthPanel,0,0)

    $script:HealthStatusLight = New-Object System.Windows.Forms.Panel
    $HealthStatusLight.Width = 24
    $HealthStatusLight.Height = 24
    $HealthStatusLight.Margin = New-Object System.Windows.Forms.Padding(4,8,8,4)
    [void]$healthPanel.Controls.Add($HealthStatusLight)

    $script:HealthStatusLabel = New-Object System.Windows.Forms.Label
    $HealthStatusLabel.Width = 430
    $HealthStatusLabel.Height = 36
    $HealthStatusLabel.TextAlign = "MiddleLeft"
    $HealthStatusLabel.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9)
    [void]$healthPanel.Controls.Add($HealthStatusLabel)

    $pingPanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $pingPanel.Dock = "Fill"
    $pingPanel.FlowDirection = "LeftToRight"
    $statusLayout.Controls.Add($pingPanel,0,1)

    $pingLabel = New-GUILabel "Ping"
    $pingLabel.Dock = "None"
    $pingLabel.Width = 42
    $pingLabel.Height = 30
    $pingLabel.Margin = New-Object System.Windows.Forms.Padding(3,8,6,3)
    [void]$pingPanel.Controls.Add($pingLabel)

    $script:QuickPingBox = New-GUITextBox "10.10.10.1"
    $QuickPingBox.Dock = "None"
    $QuickPingBox.Width = 230
    $QuickPingBox.Height = 26
    $QuickPingBox.Margin = New-Object System.Windows.Forms.Padding(3,8,10,3)
    [void]$pingPanel.Controls.Add($QuickPingBox)

    $pingButton = New-GUIButton "Ping" { Invoke-GUIQuickPing }
    $pingButton.Width = 90
    [void]$pingPanel.Controls.Add($pingButton)

    $hintLabel = New-Object System.Windows.Forms.Label
    $hintLabel.Dock = "Fill"
    $hintLabel.Text = "Use Quick Diagnosis for the full report. Use Ping here for a quick reachability check before diving into Network tools."
    $hintLabel.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9)
    $hintLabel.ForeColor = [System.Drawing.Color]::FromArgb(72,84,96)
    $statusLayout.Controls.Add($hintLabel,0,2)
    Update-GUIComputerHealthLight

    $repairGroup = New-Object System.Windows.Forms.GroupBox
    $repairGroup.Text = "Repair After Review"
    $repairGroup.Dock = "Fill"
    $repairGroup.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $lowerLayout.Controls.Add($repairGroup,1,0)

    $repairPanel = New-Object System.Windows.Forms.TableLayoutPanel
    $repairPanel.Dock = "Fill"
    $repairPanel.Padding = New-Object System.Windows.Forms.Padding(10)
    $repairPanel.ColumnCount = 1
    $repairPanel.RowCount = 3
    $repairPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,70))) | Out-Null
    $repairPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,48))) | Out-Null
    $repairPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $repairGroup.Controls.Add($repairPanel)

    $script:DismRepairNoteLabel = New-Object System.Windows.Forms.Label
    $repairNote = $script:DismRepairNoteLabel
    $repairNote.Text = "Run Quick Diagnosis first. Override is available if symptoms justify it."
    $repairNote.Dock = "Fill"
    $repairNote.TextAlign = "MiddleLeft"
    $repairNote.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9)
    [void]$repairPanel.Controls.Add($repairNote,0,0)

    $script:DismRepairButton = New-GUIButton "Run DISM/SFC Repair Path" { Start-GUIDismSfcRepairPath }
    $DismRepairButton.Dock = "Fill"
    [void]$repairPanel.Controls.Add($DismRepairButton,0,1)
    Refresh-GUIDismSfcState
}

function Add-GUIHeaderComputerSummary {
    param([System.Windows.Forms.Panel]$Header)

    $dashboard = Get-GUIDashboardInfo

    $summary = New-Object System.Windows.Forms.TableLayoutPanel
    $summary.Location = New-Object System.Drawing.Point(360,10)
    $summary.Size = New-Object System.Drawing.Size(650,66)
    $summary.Anchor = "Top,Left,Right"
    $summary.ColumnCount = 4
    $summary.RowCount = 3
    $summary.BackColor = [System.Drawing.Color]::FromArgb(22,82,91)
    $summary.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,78))) | Out-Null
    $summary.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,45))) | Out-Null
    $summary.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,76))) | Out-Null
    $summary.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,55))) | Out-Null
    $Header.Controls.Add($summary)

    foreach($cell in @(
        @{R=0;C=0;Text="Computer";Bold=$true;Key=""},
        @{R=0;C=1;Text=$dashboard.ComputerName;Key="ComputerName"},
        @{R=0;C=2;Text="Domain";Bold=$true;Key=""},
        @{R=0;C=3;Text=$dashboard.Domain;Key="Domain"},
        @{R=1;C=0;Text="Private IP";Bold=$true;Key=""},
        @{R=1;C=1;Text=$dashboard.PrivateIP;Key="PrivateIP";Span=3},
        @{R=2;C=0;Text="Public IP";Bold=$true;Key=""},
        @{R=2;C=1;Text=$dashboard.PublicIP;Key="PublicIP";Span=3}
    )){
        $label = New-Object System.Windows.Forms.Label
        $label.Text = $cell.Text
        $label.Dock = "Fill"
        $label.TextAlign = "MiddleLeft"
        $label.AutoEllipsis = $true
        $label.ForeColor = if($cell.Bold){[System.Drawing.Color]::FromArgb(198,230,226)}else{[System.Drawing.Color]::White}
        $label.Font = if($cell.Bold){New-Object System.Drawing.Font("Segoe UI Semilight",8.5,[System.Drawing.FontStyle]::Bold)}else{New-Object System.Drawing.Font("Segoe UI Semilight",8.5)}
        $summary.Controls.Add($label,$cell.C,$cell.R)

        if($cell.Span){
            $summary.SetColumnSpan($label,$cell.Span)
        }

        if($cell.Key){
            $script:DashboardLabels[$cell.Key] = $label
        }
    }

    $publicRefresh = New-Object System.Windows.Forms.Button
    $publicRefresh.Text = "R"
    $publicRefresh.Size = New-Object System.Drawing.Size(26,24)
    $publicRefresh.Location = New-Object System.Drawing.Point(1018,54)
    $publicRefresh.Anchor = "Top,Right"
    $publicRefresh.FlatStyle = "Flat"
    $publicRefresh.BackColor = [System.Drawing.Color]::FromArgb(48,128,137)
    $publicRefresh.ForeColor = [System.Drawing.Color]::White
    $publicRefresh.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9,[System.Drawing.FontStyle]::Bold)
    $publicRefresh.Add_Click({
        param($sender,$eventArgs)
        try {
            $sender.Enabled = $false
            Update-GUIPublicIPSummaryAsync -Quiet
        }
        finally {
            $timer = New-Object System.Windows.Forms.Timer
            $timer.Interval = 1200
            $timer.Add_Tick({
                $timer.Stop()
                $timer.Dispose()
                $sender.Enabled = $true
            })
            $timer.Start()
        }
    })
    $Header.Controls.Add($publicRefresh)

    if($script:ToolTip){
        $script:ToolTip.SetToolTip($publicRefresh,"Retry public IP lookup.")
    }

    Update-GUIPublicIPSummaryAsync -Quiet
}

function Update-GUIStaticTabStripSelection {
    if(!$script:MainTabs -or !$script:TabButtons){
        return
    }

    foreach($entry in $script:TabButtons.GetEnumerator()){
        $button = $entry.Value
        $selected = ($script:MainTabs.SelectedTab -and $script:MainTabs.SelectedTab.Text -eq $entry.Key)
        $button.BackColor = if($selected){[System.Drawing.Color]::FromArgb(238,111,76)}else{[System.Drawing.Color]::FromArgb(219,229,226)}
        $button.ForeColor = if($selected){[System.Drawing.Color]::White}else{[System.Drawing.Color]::FromArgb(31,54,61)}
        $button.FlatAppearance.BorderColor = if($selected){[System.Drawing.Color]::FromArgb(210,84,56)}else{[System.Drawing.Color]::FromArgb(188,202,199)}
    }
}

function Add-GUIStaticTabStrip {
    param(
        [System.Windows.Forms.FlowLayoutPanel]$Strip,
        [System.Windows.Forms.TabControl]$Tabs
    )

    $script:TabButtons = @{}
    $Strip.Controls.Clear()

    foreach($page in $Tabs.TabPages){
        $button = New-Object System.Windows.Forms.Button
        $button.Text = $page.Text
        $button.Tag = $page
        $button.Width = 132
        $button.Height = 28
        $button.Margin = New-Object System.Windows.Forms.Padding(3,3,3,3)
        $button.FlatStyle = "Flat"
        $button.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9)
        $button.Add_Click({
            param($sender,$eventArgs)
            $script:MainTabs.SelectedTab = $sender.Tag
            Update-GUIStaticTabStripSelection
        })
        [void]$Strip.Controls.Add($button)
        $script:TabButtons[$page.Text] = $button
    }

    Update-GUIStaticTabStripSelection
}

function Add-GUIComboItems {
    param(
        [System.Windows.Forms.ComboBox]$ComboBox,
        [string[]]$Items,
        [int]$SelectedIndex = 0
    )

    foreach($item in $Items){
        [void]$ComboBox.Items.Add($item)
    }

    if($ComboBox.Items.Count -gt $SelectedIndex){
        $ComboBox.SelectedIndex = $SelectedIndex
    }
}

function New-GUILabel {
    param([string]$Text)

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Text
    $label.Dock = "Fill"
    $label.TextAlign = "MiddleLeft"
    $label.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9)
    return $label
}

function New-GUITextBox {
    param([string]$Text = "")

    $box = New-Object System.Windows.Forms.TextBox
    $box.Dock = "Fill"
    $box.Text = $Text
    $box.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9)
    return $box
}

function New-GUIButton {
    param(
        [string]$Text,
        [scriptblock]$Action
    )

    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Tag = $Action
    $button.Width = 150
    $button.Height = 32
    $button.Margin = New-Object System.Windows.Forms.Padding(5)
    $button.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9)
    $button.TextAlign = "MiddleCenter"
    $button.Add_Click({
        param($sender,$eventArgs)
        Invoke-GUISafely -Tool $sender.Text -Action $sender.Tag
    })
    return $button
}

function New-GUIToolButton {
    param(
        [string]$Text,
        [string]$FunctionName
    )

    return New-GUIButton -Text $Text -Action ([scriptblock]::Create("Start-GUIToolkitFunctionConsole -FunctionName '$FunctionName'"))
}

function New-GUIExternalToolButton {
    param(
        [string]$Text,
        [string]$ToolId
    )

    return New-GUIButton -Text $Text -Action ([scriptblock]::Create("Start-GUIExternalToolById -Id '$ToolId'"))
}

function New-GUIToolItem {
    param(
        [string]$Text,
        [string]$Description,
        [string]$Section = "",
        [string]$FunctionName = "",
        [string]$External = "",
        [scriptblock]$Action = $null,
        [string]$ActionName = "",
        [bool]$RequiresAdmin = $false
    )

    return [pscustomobject]@{
        Text        = $Text
        Description = $Description
        Section     = $Section
        Function    = $FunctionName
        External    = $External
        ActionName  = $ActionName
        Action      = $Action
        RequiresAdmin = $RequiresAdmin
    }
}

function Get-GUIToolAction {
    param([pscustomobject]$Tool)

    if($Tool.Action){
        return $Tool.Action
    }

    if($Tool.External){
        return [scriptblock]::Create("Start-GUIExternalToolById -Id '$($Tool.External)'")
    }

    if($Tool.ActionName){
        return [scriptblock]::Create("Invoke-GUINamedAction -Action '$($Tool.ActionName)'")
    }

    $functionName = $Tool.Function.Replace("'","''")
    $displayName = $Tool.Text.Replace("'","''")
    $requiresAdmin = if($Tool.RequiresAdmin){"`$true"}else{"`$false"}
    return [scriptblock]::Create("Start-GUIToolkitFunctionConsole -FunctionName '$functionName' -DisplayName '$displayName' -RequiresAdmin:$requiresAdmin")
}

function Get-GUICatalogTools {
    param([string]$Tab)

    if(!(Get-Command Get-CSIToolCatalog -ErrorAction SilentlyContinue)){
        return @()
    }

    return @(Get-CSIToolCatalog | Where-Object { $_.Tab -eq $Tab } | ForEach-Object {
        New-GUIToolItem `
            -Text $_.Text `
            -Description $_.Description `
            -Section $_.Section `
            -FunctionName $_.Function `
            -External $_.External `
            -ActionName $_.Action `
            -RequiresAdmin ([bool]$_.RequiresAdmin)
    })
}

function Build-GUICatalogToolsPage {
    param(
        [System.Windows.Forms.TabPage]$Page,
        [string]$Tab,
        [string]$Title
    )

    $tools = @(Get-GUICatalogTools -Tab $Tab)
    $tools += @(Get-GUIMappedSysinternalsItems -Tab $Tab)
    Add-GUICompactToolGrid -Page $Page -Title $Title -Tools $tools -Columns 4
}

function Get-GUIMappedSysinternalsItems {
    param([string]$Tab)

    $categoryMap = @{
        "Processes" = @("Process And Startup")
        "Hardware" = @("System Inspection")
        "Network" = @("Network")
        "Directory" = @("Active Directory")
        "Remote" = @("PsTools")
        "Files" = @("Disk And File")
        "Security" = @("Security And Registry")
    }

    if(!$categoryMap.ContainsKey($Tab)){
        return @()
    }

    $alreadyCataloged = @("procexp","procmon","autoruns","rammap","tcpview","psping","psexec","handle","sigcheck")
    $categories = $categoryMap[$Tab]
    $items = @()

    foreach($tool in @(Get-GUISysinternalsTools | Where-Object { $categories -contains $_.Category -and $alreadyCataloged -notcontains $_.Name.ToLowerInvariant() })){
        $path = $tool.Path.Replace("'","''")
        $name = $tool.DisplayName.Replace("'","''")
        $console = if($tool.Console){"`$true"}else{"`$false"}
        $risky = if($tool.Risky){"`$true"}else{"`$false"}
        $description = Get-GUISysinternalsDescription -BaseName $tool.Name -FileName $tool.FileName -Category $tool.Category -Console $tool.Console -Risky $tool.Risky

        $items += New-GUIToolItem `
            -Text $tool.DisplayName `
            -Description $description `
            -Section "Sysinternals" `
            -Action ([scriptblock]::Create("Start-GUISysinternalsTool -Path '$path' -DisplayName '$name' -Console $console -Risky $risky"))
    }

    return $items
}

function New-GUICompactToolControl {
    param([pscustomobject]$Tool)

    $panel = New-Object System.Windows.Forms.Panel
    $panel.Dock = "Fill"
    $panel.Margin = New-Object System.Windows.Forms.Padding(4)
    $panel.Height = 30

    $button = New-Object System.Windows.Forms.Button
    $button.Text = ">"
    $button.Tag = (Get-GUIToolAction -Tool $Tool)
    $button.Location = New-Object System.Drawing.Point(0,2)
    $button.Size = New-Object System.Drawing.Size(26,26)
    $button.Font = New-Object System.Drawing.Font("Segoe UI Semilight",8,[System.Drawing.FontStyle]::Bold)
    $button.FlatStyle = "Flat"
    $button.BackColor = [System.Drawing.Color]::FromArgb(32,105,150)
    $button.ForeColor = [System.Drawing.Color]::White
    $button.Add_Click({
        param($sender,$eventArgs)
        Invoke-GUISafely -Tool $sender.Parent.Controls[1].Text -Action $sender.Tag
    })
    $panel.Controls.Add($button)

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Tool.Text
    $label.Tag = $button.Tag
    $label.Location = New-Object System.Drawing.Point(34,4)
    $label.Size = New-Object System.Drawing.Size(220,22)
    $label.Anchor = "Top,Left,Right"
    $label.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9)
    $label.TextAlign = "MiddleLeft"
    $label.AutoEllipsis = $true
    $label.Add_Click({
        param($sender,$eventArgs)
        Invoke-GUISafely -Tool $sender.Text -Action $sender.Tag
    })
    $panel.Controls.Add($label)

    if($script:ToolTip){
        $tip = if($Tool.Description){$Tool.Description}else{$Tool.Text}
        $script:ToolTip.SetToolTip($button,$tip)
        $script:ToolTip.SetToolTip($label,$tip)
        $script:ToolTip.SetToolTip($panel,$tip)
    }

    return $panel
}

function Add-GUICompactToolGrid {
    param(
        [System.Windows.Forms.Control]$Page,
        [string]$Title,
        [object[]]$Tools,
        [int]$Columns = 3
    )

    $group = New-Object System.Windows.Forms.GroupBox
    $group.Text = $Title
    $group.Dock = "Fill"
    $group.Padding = New-Object System.Windows.Forms.Padding(10)
    $group.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $group.BackColor = [System.Drawing.Color]::FromArgb(248,250,252)
    $Page.Controls.Add($group)

    $scroll = New-Object System.Windows.Forms.Panel
    $scroll.Dock = "Fill"
    $scroll.AutoScroll = $true
    $scroll.BackColor = [System.Drawing.Color]::FromArgb(248,250,252)
    $group.Controls.Add($scroll)

    $layout = New-Object System.Windows.Forms.TableLayoutPanel
    $layout.Dock = "Top"
    $layout.AutoSize = $true
    $layout.AutoSizeMode = "GrowAndShrink"
    $layout.ColumnCount = $Columns
    $layout.RowCount = 0
    $layout.Padding = New-Object System.Windows.Forms.Padding(4)
    $layout.Width = 1180
    $scroll.Controls.Add($layout)
    $scroll.Add_Resize({
        if($layout){
            $layout.Width = [Math]::Max(720,($scroll.ClientSize.Width - 18))
        }
    })

    for($i = 0; $i -lt $Columns; $i++){
        $layout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,(100 / $Columns)))) | Out-Null
    }

    $row = -1
    $col = 0
    $currentSection = $null

    foreach($tool in $Tools){
        if($tool.Section -and $tool.Section -ne $currentSection){
            $currentSection = $tool.Section
            $row++
            $col = 0
            $layout.RowCount = $layout.RowCount + 1
            $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,28))) | Out-Null

            $sectionLabel = New-Object System.Windows.Forms.Label
            $sectionLabel.Text = $currentSection
            $sectionLabel.Dock = "Fill"
            $sectionLabel.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9.5,[System.Drawing.FontStyle]::Bold)
            $sectionLabel.ForeColor = [System.Drawing.Color]::FromArgb(18,82,120)
            $sectionLabel.TextAlign = "MiddleLeft"
            $layout.Controls.Add($sectionLabel,0,$row)
            $layout.SetColumnSpan($sectionLabel,$Columns)
        }

        if($col -eq 0){
            $row++
            $layout.RowCount = $layout.RowCount + 1
            $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,36))) | Out-Null
        }

        $layout.Controls.Add((New-GUICompactToolControl -Tool $tool),$col,$row)
        $col = ($col + 1) % $Columns
    }

    if($layout.RowCount -eq 0){
        $layout.RowCount = 1
        $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    }
}

function Add-GUIToolButtonGroup {
    param(
        [System.Windows.Forms.Control]$Parent,
        [string]$Title,
        [object[]]$Buttons
    )

    $group = New-Object System.Windows.Forms.GroupBox
    $group.Text = $Title
    $group.Dock = "Fill"
    $group.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)

    $buttonRows = [math]::Ceiling([math]::Max(1,$Buttons.Count) / 4)
    $groupHeight = [math]::Max(132,44 + ($buttonRows * 54))
    $row = $Parent.RowCount
    $Parent.RowCount = $Parent.RowCount + 1
    $Parent.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,$groupHeight))) | Out-Null
    $Parent.Controls.Add($group,0,$row)

    $panel = New-Object System.Windows.Forms.FlowLayoutPanel
    $panel.Dock = "Fill"
    $panel.FlowDirection = "LeftToRight"
    $panel.WrapContents = $true
    $panel.Padding = New-Object System.Windows.Forms.Padding(10)
    $group.Controls.Add($panel)

    foreach($buttonInfo in $Buttons){
        if($buttonInfo.External){
            $button = New-GUIExternalToolButton -Text $buttonInfo.Text -ToolId $buttonInfo.External
        }
        elseif($buttonInfo.Action){
            $button = New-GUIButton -Text $buttonInfo.Text -Action $buttonInfo.Action
        }
        else{
            $button = New-GUIToolButton -Text $buttonInfo.Text -FunctionName $buttonInfo.Function
        }

        [void]$panel.Controls.Add($button)
    }
}

function New-GUIToolTab {
    param([System.Windows.Forms.TabPage]$Page)

    $scroll = New-Object System.Windows.Forms.Panel
    $scroll.Dock = "Fill"
    $scroll.AutoScroll = $true
    $Page.Controls.Add($scroll)

    $stack = New-Object System.Windows.Forms.TableLayoutPanel
    $stack.Dock = "Top"
    $stack.AutoSize = $true
    $stack.ColumnCount = 1
    $stack.RowCount = 0
    $stack.Padding = New-Object System.Windows.Forms.Padding(10)
    $stack.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $scroll.Controls.Add($stack)

    return $stack
}

function Build-WindowsToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Windows" -Title "Windows Tools"
}

function Build-ProcessesToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Processes" -Title "Process Tools"
}

function Build-RepairToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Repair" -Title "Repair Tools"
}

function Build-DirectoryToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Directory" -Title "Directory Tools"
}

function Build-HardwareToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Hardware" -Title "Hardware Tools"
}

function Build-DiskToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Disk" -Title "Disk Tools"
}

function Build-CrashToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Crash" -Title "Crash Tools"
}

function Build-SecurityToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Security" -Title "Security Tools"
}

function Build-NetworkToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Network" -Title "Network Tools"
}

function Build-RemoteToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Remote" -Title "Remote Tools"
}

function Build-CaptureToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Capture" -Title "Packet Capture Tools"
}

function Build-DiscoveryToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Discovery" -Title "Discovery Tools"
}

function Build-InfrastructureToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Infrastructure" -Title "Infrastructure Tools"
}

function Build-WiFiToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Wi-Fi" -Title "Wi-Fi Tools"
}

function Build-PrintToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Print" -Title "Print Tools"
}

function Build-ReportsPage {
    param([System.Windows.Forms.TabPage]$Page)

    $layout = New-Object System.Windows.Forms.TableLayoutPanel
    $layout.Dock = "Fill"
    $layout.RowCount = 3
    $layout.ColumnCount = 1
    $layout.Padding = New-Object System.Windows.Forms.Padding(10)
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,56))) | Out-Null
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,52))) | Out-Null
    $Page.Controls.Add($layout)

    $filterPanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $filterPanel.Dock = "Fill"
    $filterPanel.Padding = New-Object System.Windows.Forms.Padding(8)
    $layout.Controls.Add($filterPanel,0,0)

    $filterLabel = New-GUILabel "Report type"
    $filterLabel.Dock = "None"
    $filterLabel.Width = 80
    $filterLabel.Height = 28
    [void]$filterPanel.Controls.Add($filterLabel)

    $script:ReportTypeBox = New-Object System.Windows.Forms.ComboBox
    $ReportTypeBox.DropDownStyle = "DropDownList"
    $ReportTypeBox.Width = 190
    Add-GUIComboItems -ComboBox $ReportTypeBox -Items @("All","Quick Diagnosis","Computer Profiles","Temp Tool Outputs","Logs","Minidumps","Other")
    $ReportTypeBox.Add_SelectedIndexChanged({ Refresh-GUIReports })
    [void]$filterPanel.Controls.Add($ReportTypeBox)

    $script:ReportSearchBox = New-GUITextBox
    $ReportSearchBox.Dock = "None"
    $ReportSearchBox.Width = 260
    $ReportSearchBox.Margin = New-Object System.Windows.Forms.Padding(14,4,6,4)
    [void]$filterPanel.Controls.Add($ReportSearchBox)

    [void]$filterPanel.Controls.Add((New-GUIButton "Search" { Refresh-GUIReports }))
    [void]$filterPanel.Controls.Add((New-GUIButton "Refresh Reports" { Refresh-GUIReports }))

    $script:ReportsGrid = New-Object System.Windows.Forms.DataGridView
    $ReportsGrid.Dock = "Fill"
    $ReportsGrid.ReadOnly = $true
    $ReportsGrid.AllowUserToAddRows = $false
    $ReportsGrid.AllowUserToDeleteRows = $false
    $ReportsGrid.RowHeadersVisible = $false
    $ReportsGrid.MultiSelect = $false
    $ReportsGrid.SelectionMode = "FullRowSelect"
    $ReportsGrid.AutoSizeColumnsMode = "Fill"
    $ReportsGrid.BackgroundColor = [System.Drawing.Color]::White
    [void]$ReportsGrid.Columns.Add("Type","Type")
    [void]$ReportsGrid.Columns.Add("Name","Name")
    [void]$ReportsGrid.Columns.Add("Modified","Modified")
    [void]$ReportsGrid.Columns.Add("Path","Path")
    $layout.Controls.Add($ReportsGrid,0,1)

    $buttons = New-Object System.Windows.Forms.FlowLayoutPanel
    $buttons.Dock = "Fill"
    $buttons.Padding = New-Object System.Windows.Forms.Padding(8)
    $layout.Controls.Add($buttons,0,2)

    [void]$buttons.Controls.Add((New-GUIButton "Open Selected" { Open-SelectedGUIReport }))
    [void]$buttons.Controls.Add((New-GUIButton "Open Location" { Open-SelectedGUIReportLocation }))
    [void]$buttons.Controls.Add((New-GUIButton "Delete Selected" { Delete-SelectedGUIReport }))
    [void]$buttons.Controls.Add((New-GUIButton "Open Help" { Open-GUIHelpFile }))

    $ReportsGrid.Add_CellDoubleClick({ Open-SelectedGUIReport })
    Refresh-GUIReports
}

function Get-GUIReportItems {
    $items = @()
    $roots = @(
        @{ Type="Quick Diagnosis"; Path=$CSIPaths.Exports; Pattern="quick-diagnosis*.html" },
        @{ Type="Computer Profiles"; Path=(Get-CSIFingerprintPath); Pattern="*.html" },
        @{ Type="Computer Profiles"; Path=(Get-CSIFingerprintPath); Pattern="*.json" },
        @{ Type="Temp Tool Outputs"; Path=(Get-CSITempOutputRoot); Pattern="*" },
        @{ Type="Logs"; Path=$CSIPaths.Logs; Pattern="*.log" },
        @{ Type="Logs"; Path=(Join-Path $CSIPaths.Logs "ToolUsage"); Pattern="*.log" },
        @{ Type="Minidumps"; Path=(Join-Path $CSIPaths.Data "MiniDumps"); Pattern="*" },
        @{ Type="Other"; Path=$CSIPaths.Exports; Pattern="*.txt" },
        @{ Type="Other"; Path=$CSIPaths.Exports; Pattern="*.json" },
        @{ Type="Other"; Path=$CSIPaths.Exports; Pattern="*.csv" },
        @{ Type="Other"; Path=$CSIPaths.Exports; Pattern="*.log" }
    )

    foreach($root in $roots){
        if(!(Test-Path $root.Path)){
            continue
        }

        $items += Get-ChildItem -Path $root.Path -Filter $root.Pattern -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -ne ".gitkeep" } |
            ForEach-Object {
                [pscustomobject]@{
                    Type = $root.Type
                    Name = $_.Name
                    Modified = $_.LastWriteTime
                    Path = $_.FullName
                    IsDirectory = $_.PSIsContainer
                }
            }
    }

    return @($items | Sort-Object Modified -Descending -Unique)
}

function Refresh-GUIReports {
    if(!$script:ReportsGrid){
        return
    }

    $type = if($script:ReportTypeBox){[string]$script:ReportTypeBox.SelectedItem}else{"All"}
    $search = if($script:ReportSearchBox){$script:ReportSearchBox.Text.Trim()}else{""}
    $reports = @(Get-GUIReportItems)

    if($type -and $type -ne "All"){
        $reports = @($reports | Where-Object { $_.Type -eq $type })
    }

    if($search){
        $reports = @($reports | Where-Object { $_.Name -like "*$search*" -or $_.Path -like "*$search*" })
    }

    $script:Reports = $reports
    $script:ReportsGrid.Rows.Clear()

    foreach($report in $reports){
        $rowIndex = $script:ReportsGrid.Rows.Add($report.Type,$report.Name,$report.Modified.ToString("yyyy-MM-dd HH:mm:ss"),$report.Path)
        $script:ReportsGrid.Rows[$rowIndex].Tag = $report
    }

    Add-GUILog ("Reports loaded: {0}" -f $reports.Count)
}

function Get-SelectedGUIReport {
    if(!$script:ReportsGrid -or $script:ReportsGrid.SelectedRows.Count -eq 0){
        return $null
    }

    return $script:ReportsGrid.SelectedRows[0].Tag
}

function Open-SelectedGUIReport {
    $report = Get-SelectedGUIReport

    if(!$report){
        Add-GUILog "Select a report first."
        return
    }

    if($report.IsDirectory){
        Open-GUIFolder $report.Path
    }
    else{
        Open-CSIOutputFile -Path $report.Path
    }
}

function Open-SelectedGUIReportLocation {
    $report = Get-SelectedGUIReport

    if(!$report){
        Add-GUILog "Select a report first."
        return
    }

    $location = if($report.IsDirectory){$report.Path}else{Split-Path -Parent $report.Path}
    Open-GUIFolder $location
}

function Delete-SelectedGUIReport {
    $report = Get-SelectedGUIReport

    if(!$report){
        Add-GUILog "Select a report first."
        return
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Delete this item?`r`n`r`n$($report.Path)",
        "Delete Report",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )

    if($confirm -eq [System.Windows.Forms.DialogResult]::Yes){
        Remove-Item -LiteralPath $report.Path -Recurse:$report.IsDirectory -Force -ErrorAction SilentlyContinue
        Refresh-GUIReports
    }
}

function Build-SysinternalsPage {
    param(
        [System.Windows.Forms.TabPage]$Page,
        [string[]]$Categories,
        [string]$Title = "Sysinternals",
        [int]$Columns = 3
    )

    $catalogSysinternalsBases = @(
        "procexp",
        "procmon",
        "autoruns",
        "rammap",
        "tcpview",
        "psping",
        "psexec",
        "handle",
        "sigcheck"
    )

    $mappedCategories = @("Process And Startup","System Inspection","Network","PsTools","Active Directory","Disk And File","Security And Registry")
    $tools = @(Get-GUISysinternalsTools | Where-Object { $catalogSysinternalsBases -notcontains $_.Name.ToLowerInvariant() -and $mappedCategories -notcontains $_.Category })

    if($tools.Count -eq 0){
        $note = New-Object System.Windows.Forms.Label
        $note.Dock = "Fill"
        $note.TextAlign = "MiddleCenter"
        $note.Font = New-Object System.Drawing.Font("Segoe UI Semilight",11)
        $note.ForeColor = [System.Drawing.Color]::FromArgb(72,84,96)
        $note.Text = "All detected Sysinternals tools are already grouped on the tabs where they fit best."
        $Page.Controls.Add($note)
        return
    }

    if($Categories -and $Categories.Count -gt 0){
        $tools = @($tools | Where-Object { $Categories -contains $_.Category })
    }

    $items = @()

    foreach($tool in $tools){
        $path = $tool.Path.Replace("'","''")
        $name = $tool.DisplayName.Replace("'","''")
        $console = if($tool.Console){"`$true"}else{"`$false"}
        $risky = if($tool.Risky){"`$true"}else{"`$false"}
        $description = Get-GUISysinternalsDescription `
            -BaseName $tool.Name `
            -FileName $tool.FileName `
            -Category $tool.Category `
            -Console $tool.Console `
            -Risky $tool.Risky

        $items += New-GUIToolItem `
            -Text $tool.DisplayName `
            -Description $description `
            -Section $tool.Category `
            -Action ([scriptblock]::Create("Start-GUISysinternalsTool -Path '$path' -DisplayName '$name' -Console $console -Risky $risky"))
    }

    Add-GUICompactToolGrid -Page $Page -Title $Title -Tools $items -Columns $Columns
}

function Build-RobocopyPage {
    param([System.Windows.Forms.TabPage]$Page)

    $layout = New-Object System.Windows.Forms.TableLayoutPanel
    $layout.Dock = "Fill"
    $layout.RowCount = 1
    $layout.ColumnCount = 1
    $layout.Padding = New-Object System.Windows.Forms.Padding(10)
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $Page.Controls.Add($layout)

    $robocopyGroup = New-Object System.Windows.Forms.GroupBox
    $robocopyGroup.Text = "Robocopy Builder"
    $robocopyGroup.Dock = "Fill"
    $robocopyGroup.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $layout.Controls.Add($robocopyGroup,0,0)

    $builder = New-Object System.Windows.Forms.TableLayoutPanel
    $builder.Dock = "Fill"
    $builder.ColumnCount = 4
    $builder.RowCount = 8
    $builder.Padding = New-Object System.Windows.Forms.Padding(10)
    $builder.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,120))) | Out-Null
    $builder.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $builder.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,120))) | Out-Null
    $builder.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $builder.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,34))) | Out-Null
    $builder.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,34))) | Out-Null
    $builder.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,34))) | Out-Null
    $builder.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,34))) | Out-Null
    $builder.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,34))) | Out-Null
    $builder.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,34))) | Out-Null
    $builder.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,46))) | Out-Null
    $builder.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $robocopyGroup.Controls.Add($builder)

    $script:RobocopySourceBox = New-GUITextBox
    $script:RobocopyDestinationBox = New-GUITextBox
    $script:RobocopyPatternBox = New-GUITextBox "*.*"
    $script:RobocopyExcludeFilesBox = New-GUITextBox
    $script:RobocopyExcludeFoldersBox = New-GUITextBox

    $builder.Controls.Add((New-GUILabel "Source"),0,0)
    $builder.Controls.Add($RobocopySourceBox,1,0)
    $builder.Controls.Add((New-GUILabel "Destination"),2,0)
    $builder.Controls.Add($RobocopyDestinationBox,3,0)

    $builder.Controls.Add((New-GUILabel "File patterns"),0,1)
    $builder.Controls.Add($RobocopyPatternBox,1,1)
    $builder.Controls.Add((New-GUILabel "Exclude files"),2,1)
    $builder.Controls.Add($RobocopyExcludeFilesBox,3,1)

    $script:RobocopyCopyTypeBox = New-Object System.Windows.Forms.ComboBox
    $RobocopyCopyTypeBox.Dock = "Fill"
    $RobocopyCopyTypeBox.DropDownStyle = "DropDownList"
    Add-GUIComboItems -ComboBox $RobocopyCopyTypeBox -Items @("Normal folder copy","Mirror destination to source","Unreliable network copy","Permission-preserving migration")

    $script:RobocopyMetadataBox = New-Object System.Windows.Forms.ComboBox
    $RobocopyMetadataBox.Dock = "Fill"
    $RobocopyMetadataBox.DropDownStyle = "DropDownList"
    Add-GUIComboItems -ComboBox $RobocopyMetadataBox -Items @("Normal data, attributes, timestamps","Preserve NTFS permissions","Full owner and audit migration")

    $builder.Controls.Add((New-GUILabel "Copy type"),0,2)
    $builder.Controls.Add($RobocopyCopyTypeBox,1,2)
    $builder.Controls.Add((New-GUILabel "Metadata"),2,2)
    $builder.Controls.Add($RobocopyMetadataBox,3,2)

    $script:RobocopyRetryBox = New-Object System.Windows.Forms.ComboBox
    $RobocopyRetryBox.Dock = "Fill"
    $RobocopyRetryBox.DropDownStyle = "DropDownList"
    Add-GUIComboItems -ComboBox $RobocopyRetryBox -Items @("Fast troubleshooting","Balanced","Patient migration")

    $script:RobocopyThreadsBox = New-Object System.Windows.Forms.ComboBox
    $RobocopyThreadsBox.Dock = "Fill"
    $RobocopyThreadsBox.DropDownStyle = "DropDownList"
    Add-GUIComboItems -ComboBox $RobocopyThreadsBox -Items @("Gentle","Normal","Fast") -SelectedIndex 1

    $builder.Controls.Add((New-GUILabel "Retry"),0,3)
    $builder.Controls.Add($RobocopyRetryBox,1,3)
    $builder.Controls.Add((New-GUILabel "Threads"),2,3)
    $builder.Controls.Add($RobocopyThreadsBox,3,3)

    $builder.Controls.Add((New-GUILabel "Exclude folders"),0,4)
    $builder.Controls.Add($RobocopyExcludeFoldersBox,1,4)

    $options = New-Object System.Windows.Forms.FlowLayoutPanel
    $options.Dock = "Fill"
    $options.FlowDirection = "LeftToRight"
    $builder.SetColumnSpan($options,2)
    $builder.Controls.Add($options,2,4)

    $script:RobocopyNasCheck = New-Object System.Windows.Forms.CheckBox
    $RobocopyNasCheck.Text = "NAS/Linux timestamps"
    $RobocopyNasCheck.AutoSize = $true
    $RobocopyNasCheck.Margin = New-Object System.Windows.Forms.Padding(4,7,12,4)
    [void]$options.Controls.Add($RobocopyNasCheck)

    $script:RobocopyNoProgressCheck = New-Object System.Windows.Forms.CheckBox
    $RobocopyNoProgressCheck.Text = "Cleaner output"
    $RobocopyNoProgressCheck.AutoSize = $true
    $RobocopyNoProgressCheck.Checked = $true
    $RobocopyNoProgressCheck.Margin = New-Object System.Windows.Forms.Padding(4,7,12,4)
    [void]$options.Controls.Add($RobocopyNoProgressCheck)

    $script:RobocopyLogCheck = New-Object System.Windows.Forms.CheckBox
    $RobocopyLogCheck.Text = "Log to Outputs"
    $RobocopyLogCheck.AutoSize = $true
    $RobocopyLogCheck.Checked = $true
    $RobocopyLogCheck.Margin = New-Object System.Windows.Forms.Padding(4,7,12,4)
    [void]$options.Controls.Add($RobocopyLogCheck)

    $actions = New-Object System.Windows.Forms.FlowLayoutPanel
    $actions.Dock = "Fill"
    $actions.FlowDirection = "LeftToRight"
    $builder.SetColumnSpan($actions,4)
    $builder.Controls.Add($actions,0,6)

    foreach($button in @(
        (New-GUIButton "Build Command" { Update-GUIRobocopyCommand | Out-Null }),
        (New-GUIButton "Copy Command" { Copy-GUIRobocopyCommand }),
        (New-GUIButton "Preview Only" { Start-GUIRobocopyCommand -Preview }),
        (New-GUIButton "Run Copy" { Start-GUIRobocopyCommand })
    )){
        [void]$actions.Controls.Add($button)
    }

    $script:RobocopyCommandBox = New-Object System.Windows.Forms.TextBox
    $RobocopyCommandBox.Dock = "Fill"
    $RobocopyCommandBox.Multiline = $true
    $RobocopyCommandBox.ReadOnly = $true
    $RobocopyCommandBox.ScrollBars = "Vertical"
    $RobocopyCommandBox.Font = New-Object System.Drawing.Font("Consolas",9)
    $builder.SetColumnSpan($RobocopyCommandBox,4)
    $builder.Controls.Add($RobocopyCommandBox,0,7)
}

function Build-FileToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Files" -Title "File Tools"
}

function Build-ChocolateyPage {
    param([System.Windows.Forms.TabPage]$Page)

    $layout = New-Object System.Windows.Forms.TableLayoutPanel
    $layout.Dock = "Fill"
    $layout.RowCount = 2
    $layout.ColumnCount = 2
    $layout.Padding = New-Object System.Windows.Forms.Padding(10)
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,124))) | Out-Null
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $layout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $layout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $Page.Controls.Add($layout)

    $chocoTop = New-Object System.Windows.Forms.GroupBox
    $chocoTop.Text = "Chocolatey"
    $chocoTop.Dock = "Fill"
    $chocoTop.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $layout.Controls.Add($chocoTop,0,0)

    $topPanel = New-Object System.Windows.Forms.TableLayoutPanel
    $topPanel.Dock = "Fill"
    $topPanel.Padding = New-Object System.Windows.Forms.Padding(10)
    $topPanel.ColumnCount = 3
    $topPanel.RowCount = 2
    $topPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,34))) | Out-Null
    $topPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,33))) | Out-Null
    $topPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,33))) | Out-Null
    $topPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $topPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,42))) | Out-Null
    $chocoTop.Controls.Add($topPanel)

    $script:ChocoStatusLabel = New-Object System.Windows.Forms.Label
    $ChocoStatusLabel.Dock = "Fill"
    $ChocoStatusLabel.TextAlign = "MiddleLeft"
    $ChocoStatusLabel.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9)
    [void]$topPanel.Controls.Add($ChocoStatusLabel,0,0)
    $topPanel.SetColumnSpan($ChocoStatusLabel,3)

    [void]$topPanel.Controls.Add((New-GUIButton "Refresh Status" { Refresh-GUIChocoStatus }),0,1)
    [void]$topPanel.Controls.Add((New-GUIButton "Install Chocolatey" { Start-GUIChocolateyInstall }),1,1)
    [void]$topPanel.Controls.Add((New-GUIButton "Scan Installed" { Refresh-GUIChocoInstalledPackages }),2,1)

    $guidanceGroup = New-Object System.Windows.Forms.GroupBox
    $guidanceGroup.Text = "Add Choco Packages To This Toolkit"
    $guidanceGroup.Dock = "Fill"
    $guidanceGroup.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $layout.Controls.Add($guidanceGroup,1,0)

    $guidance = New-Object System.Windows.Forms.Label
    $guidance.Dock = "Fill"
    $guidance.Padding = New-Object System.Windows.Forms.Padding(10,6,10,6)
    $guidance.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9)
    $guidance.TextAlign = "MiddleLeft"
    $guidance.Text = "Use Add to Toolbox for portable utilities. The toolkit tries Chocolatey's download command first, then package extraction, and only asks for a temporary computer install as a last resort. Tools copied into .\Custom are managed on the Custom tab."
    $guidanceGroup.Controls.Add($guidance)

    $searchGroup = New-Object System.Windows.Forms.GroupBox
    $searchGroup.Text = "Install Chocolatey Packages"
    $searchGroup.Dock = "Fill"
    $searchGroup.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $layout.Controls.Add($searchGroup,0,1)

    $searchLayout = New-Object System.Windows.Forms.TableLayoutPanel
    $searchLayout.Dock = "Fill"
    $searchLayout.RowCount = 3
    $searchLayout.ColumnCount = 1
    $searchLayout.Padding = New-Object System.Windows.Forms.Padding(10)
    $searchLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,44))) | Out-Null
    $searchLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $searchLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,46))) | Out-Null
    $searchGroup.Controls.Add($searchLayout)

    $searchPanel = New-Object System.Windows.Forms.TableLayoutPanel
    $searchPanel.Dock = "Fill"
    $searchPanel.ColumnCount = 3
    $searchPanel.RowCount = 1
    $searchPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,82))) | Out-Null
    $searchPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $searchPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,150))) | Out-Null
    $searchLayout.Controls.Add($searchPanel,0,0)

    $searchLabel = New-GUILabel "Search term"
    $searchLabel.Dock = "None"
    $searchLabel.Width = 82
    $searchLabel.Height = 30
    $searchLabel.Margin = New-Object System.Windows.Forms.Padding(3,7,6,3)
    [void]$searchPanel.Controls.Add($searchLabel,0,0)

    $script:ChocoSearchBox = New-GUITextBox
    $ChocoSearchBox.Dock = "Fill"
    $ChocoSearchBox.Height = 26
    $ChocoSearchBox.Margin = New-Object System.Windows.Forms.Padding(3,8,10,3)
    [void]$searchPanel.Controls.Add($ChocoSearchBox,1,0)

    [void]$searchPanel.Controls.Add((New-GUIButton "Search Packages" { Search-GUIChocoPackages }),2,0)

    $script:ChocoGrid = New-Object System.Windows.Forms.DataGridView
    $ChocoGrid.Dock = "Fill"
    $ChocoGrid.ReadOnly = $true
    $ChocoGrid.AllowUserToAddRows = $false
    $ChocoGrid.AllowUserToDeleteRows = $false
    $ChocoGrid.RowHeadersVisible = $false
    $ChocoGrid.MultiSelect = $false
    $ChocoGrid.SelectionMode = "FullRowSelect"
    $ChocoGrid.AutoSizeColumnsMode = "Fill"
    $ChocoGrid.BackgroundColor = [System.Drawing.Color]::White
    [void]$ChocoGrid.Columns.Add("Name","Package")
    [void]$ChocoGrid.Columns.Add("Version","Version")
    $searchLayout.Controls.Add($ChocoGrid,0,1)

    $installPanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $installPanel.Dock = "Fill"
    $searchLayout.Controls.Add($installPanel,0,2)

    [void]$installPanel.Controls.Add((New-GUIButton "Install Selected" { Install-SelectedGUIChocoPackage }))
    $addToolboxButton = New-GUIButton "Add to Toolbox" { Add-SelectedChocoPackageToToolbox }
    $addToolboxButton.Width = 150
    [void]$installPanel.Controls.Add($addToolboxButton)

    $installedGroup = New-Object System.Windows.Forms.GroupBox
    $installedGroup.Text = "Computer Installed Chocolatey Packages"
    $installedGroup.Dock = "Fill"
    $installedGroup.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $layout.Controls.Add($installedGroup,1,1)

    $installedLayout = New-Object System.Windows.Forms.TableLayoutPanel
    $installedLayout.Dock = "Fill"
    $installedLayout.RowCount = 2
    $installedLayout.ColumnCount = 1
    $installedLayout.Padding = New-Object System.Windows.Forms.Padding(10)
    $installedLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $installedLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,84))) | Out-Null
    $installedGroup.Controls.Add($installedLayout)

    $script:ChocoInstalledGrid = New-Object System.Windows.Forms.DataGridView
    $ChocoInstalledGrid.Dock = "Fill"
    $ChocoInstalledGrid.ReadOnly = $true
    $ChocoInstalledGrid.AllowUserToAddRows = $false
    $ChocoInstalledGrid.AllowUserToDeleteRows = $false
    $ChocoInstalledGrid.RowHeadersVisible = $false
    $ChocoInstalledGrid.MultiSelect = $false
    $ChocoInstalledGrid.SelectionMode = "FullRowSelect"
    $ChocoInstalledGrid.AutoSizeColumnsMode = "Fill"
    $ChocoInstalledGrid.BackgroundColor = [System.Drawing.Color]::White
    [void]$ChocoInstalledGrid.Columns.Add("Name","Package")
    [void]$ChocoInstalledGrid.Columns.Add("Version","Installed")
    [void]$ChocoInstalledGrid.Columns.Add("Available","Available")
    [void]$ChocoInstalledGrid.Columns.Add("State","State")
    $installedLayout.Controls.Add($ChocoInstalledGrid,0,0)

    $installedButtons = New-Object System.Windows.Forms.TableLayoutPanel
    $installedButtons.Dock = "Fill"
    $installedButtons.ColumnCount = 2
    $installedButtons.RowCount = 2
    $installedButtons.Padding = New-Object System.Windows.Forms.Padding(4)
    $installedButtons.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $installedButtons.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $installedButtons.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $installedButtons.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $installedLayout.Controls.Add($installedButtons,0,1)

    $refreshComputerButton = New-GUIButton "Refresh Computer List" { Refresh-GUIChocoInstalledPackages }
    $refreshComputerButton.Dock = "Fill"
    $refreshComputerButton.Width = 0
    [void]$installedButtons.Controls.Add($refreshComputerButton,0,0)

    $upgradeAllButton = New-GUIButton "Upgrade All" { Upgrade-AllGUIChocoPackages }
    $upgradeAllButton.Dock = "Fill"
    $upgradeAllButton.Width = 0
    [void]$installedButtons.Controls.Add($upgradeAllButton,1,0)

    $upgradeSelectedButton = New-GUIButton "Upgrade Selected" { Upgrade-SelectedGUIChocoPackage }
    $upgradeSelectedButton.Dock = "Fill"
    $upgradeSelectedButton.Width = 0
    [void]$installedButtons.Controls.Add($upgradeSelectedButton,0,1)

    $uninstallComputerButton = New-GUIButton "Uninstall From Computer" { Uninstall-SelectedGUIChocoPackage }
    $uninstallComputerButton.Dock = "Fill"
    $uninstallComputerButton.Width = 0
    [void]$installedButtons.Controls.Add($uninstallComputerButton,1,1)

    Refresh-GUIChocoStatus
}

function Build-SoftwareToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Software" -Title "Software Tools"
}

function Build-CustomToolsPage {
    param([System.Windows.Forms.TabPage]$Page)

    $layout = New-Object System.Windows.Forms.TableLayoutPanel
    $layout.Dock = "Fill"
    $layout.RowCount = 2
    $layout.ColumnCount = 1
    $layout.Padding = New-Object System.Windows.Forms.Padding(10)
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,52))) | Out-Null
    $Page.Controls.Add($layout)

    $script:CustomGrid = New-Object System.Windows.Forms.DataGridView
    $CustomGrid.Dock = "Fill"
    $CustomGrid.ReadOnly = $true
    $CustomGrid.AllowUserToAddRows = $false
    $CustomGrid.AllowUserToDeleteRows = $false
    $CustomGrid.RowHeadersVisible = $false
    $CustomGrid.MultiSelect = $false
    $CustomGrid.SelectionMode = "FullRowSelect"
    $CustomGrid.AutoSizeColumnsMode = "Fill"
    $CustomGrid.BackgroundColor = [System.Drawing.Color]::White
    [void]$CustomGrid.Columns.Add("Name","Name")
    [void]$CustomGrid.Columns.Add("Source","Source")
    [void]$CustomGrid.Columns.Add("Version","Version")
    [void]$CustomGrid.Columns.Add("Status","Status")
    [void]$CustomGrid.Columns.Add("Path","Launch Path")
    $layout.Controls.Add($CustomGrid,0,0)

    $buttons = New-Object System.Windows.Forms.FlowLayoutPanel
    $buttons.Dock = "Fill"
    $buttons.Padding = New-Object System.Windows.Forms.Padding(8)
    $layout.Controls.Add($buttons,0,1)
    [void]$buttons.Controls.Add((New-GUIButton "Launch Toolkit Tool" { Start-SelectedGUICustomTool }))
    $removeToolkitButton = New-GUIButton "Remove From Toolkit" { Remove-SelectedGUICustomTool }
    $removeToolkitButton.Width = 180
    [void]$buttons.Controls.Add($removeToolkitButton)
    [void]$buttons.Controls.Add((New-GUIButton "Open Location" { Open-SelectedGUICustomToolFolder }))
    [void]$buttons.Controls.Add((New-GUIButton "Refresh Toolkit Tools" { Refresh-GUICustomTools }))

    $CustomGrid.Add_CellDoubleClick({ Start-SelectedGUICustomTool })
    Refresh-GUICustomTools
}

function Build-LiveLogPage {
    param([System.Windows.Forms.TabPage]$Page)

    $layout = New-Object System.Windows.Forms.TableLayoutPanel
    $layout.Dock = "Fill"
    $layout.RowCount = 2
    $layout.ColumnCount = 1
    $layout.Padding = New-Object System.Windows.Forms.Padding(10)
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,52))) | Out-Null
    $Page.Controls.Add($layout)

    $script:LogBox = New-Object System.Windows.Forms.TextBox
    $LogBox.Dock = "Fill"
    $LogBox.Multiline = $true
    $LogBox.ReadOnly = $true
    $LogBox.ScrollBars = "Vertical"
    $LogBox.Font = New-Object System.Drawing.Font("Consolas",9)
    $LogBox.BackColor = [System.Drawing.Color]::FromArgb(17,28,38)
    $LogBox.ForeColor = [System.Drawing.Color]::FromArgb(226,236,240)
    $layout.Controls.Add($LogBox,0,0)

    $buttons = New-Object System.Windows.Forms.FlowLayoutPanel
    $buttons.Dock = "Fill"
    $buttons.Padding = New-Object System.Windows.Forms.Padding(8)
    $layout.Controls.Add($buttons,0,1)

    [void]$buttons.Controls.Add((New-GUIButton "Clear Log" { if($script:LogBox){ $script:LogBox.Clear(); Add-GUILog "Live log cleared." } }))
    [void]$buttons.Controls.Add((New-GUIButton "Copy Log" { if($script:LogBox){ [System.Windows.Forms.Clipboard]::SetText($script:LogBox.Text); Add-GUILog "Live log copied to clipboard." } }))
}

function Set-GUIFallbackButtonToolTips {
    if(!$script:ToolTip -or !$script:Form){
        return
    }

    $tooltips = @{
        "Run Quick Diagnosis" = "Run the primary health check and create a technician-ready HTML report."
        "Run DISM/SFC Repair Path" = "Start the Windows image and system file repair workflow after reviewing diagnosis results."
        "Open HTML Report" = "Open the selected computer profile report in the default browser."
        "Create Profile" = "Run Quick Diagnosis and save a fresh computer profile with the report."
        "Delete" = "Delete the selected saved computer profile record and related report files."
        "Refresh" = "Reload the list with the latest available computer profiles."
        "Build Command" = "Generate a robocopy command from the selected source, destination, and options."
        "Copy Command" = "Copy the generated robocopy command to the clipboard."
        "Preview Only" = "Run robocopy in list-only mode so you can review what would copy."
        "Run Copy" = "Start the generated robocopy job with the selected options."
        "Open WizTree" = "Launch WizTree for fast disk space analysis."
        "Everything" = "Launch Everything for instant local filename search."
        "WinDirStat" = "Launch WinDirStat to visualize disk usage and large folders."
        "WinMerge" = "Launch WinMerge to compare and merge files or folders."
        "Kudu" = "Launch Kudu as a portable file manager."
        "Refresh Status" = "Check whether Chocolatey is installed and ready to use."
        "Install Chocolatey" = "Install Chocolatey so packages can be added from this toolkit."
        "Search Packages" = "Search Chocolatey for package names matching the entered term."
        "Install Selected" = "Install the selected Chocolatey package."
        "Notepad++" = "Open Notepad++ for logs, scripts, configs, and quick text edits."
        "Draw.io" = "Open Draw.io for network diagrams, flowcharts, and troubleshooting visuals."
        "KompoZer" = "Open KompoZer for quick HTML or report edits."
        "Open Console" = "Open the original command-line toolkit."
    }

    $pending = New-Object System.Collections.ArrayList
    [void]$pending.Add($script:Form)

    while($pending.Count -gt 0){
        $current = $pending[0]
        $pending.RemoveAt(0)

        if($current -is [System.Windows.Forms.Button]){
            $existing = $script:ToolTip.GetToolTip($current)

            if([string]::IsNullOrWhiteSpace($existing)){
                $text = [string]$current.Text

                if($tooltips.ContainsKey($text)){
                    $script:ToolTip.SetToolTip($current,$tooltips[$text])
                }
                elseif(![string]::IsNullOrWhiteSpace($text) -and $text -ne ">"){
                    $script:ToolTip.SetToolTip($current,"Run $text.")
                }
            }
        }

        foreach($child in $current.Controls){
            [void]$pending.Add($child)
        }
    }
}

function Build-Form {
    $script:Form = New-Object System.Windows.Forms.Form
    $Form.Text = "Network Toolkit"
    $Form.StartPosition = "CenterScreen"
    $Form.MinimumSize = New-Object System.Drawing.Size(1280,720)
    $Form.Size = New-Object System.Drawing.Size(1480,820)
    $Form.ShowIcon = $true
    $Form.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9.5)
    $Form.BackColor = [System.Drawing.Color]::FromArgb(235,241,238)

    if(Test-Path $GuiIconPath){
        $Form.Icon = New-Object System.Drawing.Icon($GuiIconPath)
    }

    $root = New-Object System.Windows.Forms.TableLayoutPanel
    $root.Dock = "Fill"
    $root.RowCount = 4
    $root.ColumnCount = 1
    $root.Padding = New-Object System.Windows.Forms.Padding(10)
    $root.BackColor = [System.Drawing.Color]::FromArgb(242,246,249)
    $root.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,86))) | Out-Null
    $root.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,108))) | Out-Null
    $root.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $root.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,26))) | Out-Null
    $Form.Controls.Add($root)

    if(!$script:ToolTip){
        $script:ToolTip = New-Object System.Windows.Forms.ToolTip
        $script:ToolTip.AutoPopDelay = 12000
        $script:ToolTip.InitialDelay = 400
        $script:ToolTip.ReshowDelay = 150
        $script:ToolTip.ShowAlways = $true
    }

    $header = New-Object System.Windows.Forms.Panel
    $header.Dock = "Fill"
    $header.BackColor = [System.Drawing.Color]::FromArgb(22,82,91)
    $root.Controls.Add($header,0,0)

    $logo = New-Object System.Windows.Forms.PictureBox
    $logo.Location = New-Object System.Drawing.Point(12,13)
    $logo.Size = New-Object System.Drawing.Size(52,52)
    $logo.SizeMode = "Zoom"
    $logoPath = Join-Path $GuiRoot "NetworkToolkit.png"
    if(Test-Path $logoPath){
        $logo.Image = [System.Drawing.Image]::FromFile($logoPath)
    }
    $header.Controls.Add($logo)

    $title = New-Object System.Windows.Forms.Label
    $title.Text = "Network Toolkit"
    $title.Location = New-Object System.Drawing.Point(76,14)
    $title.Size = New-Object System.Drawing.Size(270,30)
    $title.Font = New-Object System.Drawing.Font("Segoe UI Semilight",18,[System.Drawing.FontStyle]::Bold)
    $title.ForeColor = [System.Drawing.Color]::White
    $header.Controls.Add($title)

    $subtitle = New-Object System.Windows.Forms.Label
    $subtitle.Text = "Portable technician console"
    $subtitle.Location = New-Object System.Drawing.Point(80,46)
    $subtitle.Size = New-Object System.Drawing.Size(235,20)
    $subtitle.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9.5)
    $subtitle.ForeColor = [System.Drawing.Color]::FromArgb(210,230,245)
    $header.Controls.Add($subtitle)

    $admin = New-Object System.Windows.Forms.Label
    $admin.Text = if(Test-GUIAdministrator){"Running elevated"}else{"Not elevated"}
    $admin.Anchor = "Top,Right"
    $admin.Location = New-Object System.Drawing.Point(1165,32)
    $admin.Size = New-Object System.Drawing.Size(160,22)
    $admin.TextAlign = "MiddleRight"
    $admin.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $admin.ForeColor = if(Test-GUIAdministrator){[System.Drawing.Color]::FromArgb(150,235,175)}else{[System.Drawing.Color]::FromArgb(255,215,120)}
    $header.Controls.Add($admin)

    Add-GUIHeaderComputerSummary -Header $header

    $tabStrip = New-Object System.Windows.Forms.FlowLayoutPanel
    $tabStrip.Dock = "Fill"
    $tabStrip.WrapContents = $true
    $tabStrip.AutoScroll = $false
    $tabStrip.Padding = New-Object System.Windows.Forms.Padding(0,4,0,0)
    $tabStrip.BackColor = [System.Drawing.Color]::FromArgb(232,239,237)
    $script:StaticTabStrip = $tabStrip
    $root.Controls.Add($tabStrip,0,1)

    $tabs = New-Object System.Windows.Forms.TabControl
    $tabs.Dock = "Fill"
    $tabs.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10)
    $tabs.Multiline = $false
    $tabs.SizeMode = "Fixed"
    $tabs.ItemSize = New-Object System.Drawing.Size(1,1)
    $tabs.Appearance = [System.Windows.Forms.TabAppearance]::FlatButtons
    $script:MainTabs = $tabs
    $root.Controls.Add($tabs,0,2)

    $quickPage = New-Object System.Windows.Forms.TabPage
    $quickPage.Text = "Quick Diagnosis"
    $tabs.TabPages.Add($quickPage) | Out-Null

    $hardwarePage = New-Object System.Windows.Forms.TabPage
    $hardwarePage.Text = "Hardware"
    $tabs.TabPages.Add($hardwarePage) | Out-Null

    $processesPage = New-Object System.Windows.Forms.TabPage
    $processesPage.Text = "Processes"
    $tabs.TabPages.Add($processesPage) | Out-Null

    $networkPage = New-Object System.Windows.Forms.TabPage
    $networkPage.Text = "Network"
    $tabs.TabPages.Add($networkPage) | Out-Null

    $remotePage = New-Object System.Windows.Forms.TabPage
    $remotePage.Text = "Remote"
    $tabs.TabPages.Add($remotePage) | Out-Null

    $infrastructurePage = New-Object System.Windows.Forms.TabPage
    $infrastructurePage.Text = "Services"
    $tabs.TabPages.Add($infrastructurePage) | Out-Null

    $windowsPage = New-Object System.Windows.Forms.TabPage
    $windowsPage.Text = "Windows"
    $tabs.TabPages.Add($windowsPage) | Out-Null

    $repairPage = New-Object System.Windows.Forms.TabPage
    $repairPage.Text = "Repair"
    $tabs.TabPages.Add($repairPage) | Out-Null

    $directoryPage = New-Object System.Windows.Forms.TabPage
    $directoryPage.Text = "Directory"
    $tabs.TabPages.Add($directoryPage) | Out-Null

    $securityPage = New-Object System.Windows.Forms.TabPage
    $securityPage.Text = "Security"
    $tabs.TabPages.Add($securityPage) | Out-Null

    $wifiPage = New-Object System.Windows.Forms.TabPage
    $wifiPage.Text = "Wi-Fi"
    $tabs.TabPages.Add($wifiPage) | Out-Null

    $printPage = New-Object System.Windows.Forms.TabPage
    $printPage.Text = "Print"
    $tabs.TabPages.Add($printPage) | Out-Null

    $filesPage = New-Object System.Windows.Forms.TabPage
    $filesPage.Text = "Files"
    $tabs.TabPages.Add($filesPage) | Out-Null

    $discoveryPage = New-Object System.Windows.Forms.TabPage
    $discoveryPage.Text = "Discovery"
    $tabs.TabPages.Add($discoveryPage) | Out-Null

    $robocopyPage = New-Object System.Windows.Forms.TabPage
    $robocopyPage.Text = "Robocopy"
    $tabs.TabPages.Add($robocopyPage) | Out-Null

    $softwarePage = New-Object System.Windows.Forms.TabPage
    $softwarePage.Text = "Software"
    $tabs.TabPages.Add($softwarePage) | Out-Null

    $customPage = New-Object System.Windows.Forms.TabPage
    $customPage.Text = "Custom"
    $tabs.TabPages.Add($customPage) | Out-Null

    $chocolateyPage = New-Object System.Windows.Forms.TabPage
    $chocolateyPage.Text = "Choco"
    $tabs.TabPages.Add($chocolateyPage) | Out-Null

    $sysinternalsPage = New-Object System.Windows.Forms.TabPage
    $sysinternalsPage.Text = "Sysinternals"
    $tabs.TabPages.Add($sysinternalsPage) | Out-Null

    $fingerprintPage = New-Object System.Windows.Forms.TabPage
    $fingerprintPage.Text = "Computer Info"
    $tabs.TabPages.Add($fingerprintPage) | Out-Null

    $reportsPage = New-Object System.Windows.Forms.TabPage
    $reportsPage.Text = "Reports"
    $tabs.TabPages.Add($reportsPage) | Out-Null

    $liveLogPage = New-Object System.Windows.Forms.TabPage
    $liveLogPage.Text = "Live Log"
    $tabs.TabPages.Add($liveLogPage) | Out-Null

    foreach($page in $tabs.TabPages){
        $page.UseVisualStyleBackColor = $false
        $page.BackColor = [System.Drawing.Color]::FromArgb(242,246,249)
    }

    Add-GUIStaticTabStrip -Strip $tabStrip -Tabs $tabs
    $tabs.Add_SelectedIndexChanged({ Update-GUIStaticTabStripSelection })

    $script:RunButton = New-GUIButton "Run Quick Diagnosis" { Start-GUIQuickDiagnosis }

    $consoleButton = New-Object System.Windows.Forms.Button
    $consoleButton.Text = "Open Console"
    $consoleButton.Width = 130
    $consoleButton.Height = 32
    $consoleButton.Add_Click({ Start-ToolkitConsole })

    $status = New-Object System.Windows.Forms.StatusStrip
    $script:StatusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
    $StatusLabel.Text = "Ready"
    $status.Items.Add($StatusLabel) | Out-Null
    $root.Controls.Add($status,0,3)

    if(!$script:ToolTip){
        $script:ToolTip = New-Object System.Windows.Forms.ToolTip
        $script:ToolTip.AutoPopDelay = 12000
        $script:ToolTip.InitialDelay = 400
        $script:ToolTip.ReshowDelay = 150
        $script:ToolTip.ShowAlways = $true
    }

    Build-QuickTriagePage -Page $quickPage
    Build-WindowsToolsPage -Page $windowsPage
    Build-HardwareToolsPage -Page $hardwarePage
    Build-ProcessesToolsPage -Page $processesPage
    Build-SecurityToolsPage -Page $securityPage
    Build-NetworkToolsPage -Page $networkPage
    Build-RemoteToolsPage -Page $remotePage
    Build-DiscoveryToolsPage -Page $discoveryPage
    Build-InfrastructureToolsPage -Page $infrastructurePage
    Build-RepairToolsPage -Page $repairPage
    Build-DirectoryToolsPage -Page $directoryPage
    Build-WiFiToolsPage -Page $wifiPage
    Build-PrintToolsPage -Page $printPage
    Build-FileToolsPage -Page $filesPage
    Build-RobocopyPage -Page $robocopyPage
    Build-SoftwareToolsPage -Page $softwarePage
    Build-CustomToolsPage -Page $customPage
    Build-ChocolateyPage -Page $chocolateyPage
    Build-SysinternalsPage -Page $sysinternalsPage -Title "Sysinternals Tools" -Categories @("Process And Startup","System Inspection","Network","PsTools","Disk And File","Security And Registry","Active Directory","Stress And Caution","Other") -Columns 3
    Build-FingerprintPage -Page $fingerprintPage
    Build-ReportsPage -Page $reportsPage
    Build-LiveLogPage -Page $liveLogPage
    Set-GUIFallbackButtonToolTips
}

Build-Form
Refresh-Fingerprints -Quiet
Add-GUILog "Loaded GUI launcher from $GuiRoot"
Add-GUILog "Using shared toolkit from $SharedToolkitRoot"
Add-GUILog ("Registered commands: {0}" -f $script:Commands.Count)

if($SmokeTest){
    Write-Host "Network Toolkit GUI loaded successfully."
    Write-Host "Commands:" $script:Commands.Count
    return
}

if($ButtonSmokeTest){
    if($script:Commands.Count -lt 1){
        Write-Host "No commands loaded."
        exit 1
    }

    if(!$script:QuickRunButton){
        Write-Host "Quick Diagnosis button missing."
        exit 1
    }

    if(!$script:RobocopySourceBox -or !$script:RobocopyDestinationBox){
        Write-Host "Robocopy tab missing."
        exit 1
    }

    if(!$script:ChocoGrid -or !$script:ChocoSearchBox){
        Write-Host "Chocolatey tab missing."
        exit 1
    }

    foreach($tabName in @("Quick Diagnosis","Hardware","Processes","Network","Remote","Services","Windows","Repair","Directory","Security","Wi-Fi","Print","Files","Discovery","Robocopy","Software","Custom","Choco","Sysinternals","Computer Info","Reports","Live Log")){
        $tab = $script:MainTabs.TabPages | Where-Object {$_.Text -eq $tabName} | Select-Object -First 1

        if(!$tab){
            Write-Host "Tab missing: $tabName"
            exit 1
        }

        $pending = New-Object System.Collections.ArrayList
        [void]$pending.Add($tab)
        $buttons = @()

        while($pending.Count -gt 0){
            $current = $pending[0]
            $pending.RemoveAt(0)

            if($current -is [System.Windows.Forms.Button]){
                $buttons += $current
            }

            foreach($child in $current.Controls){
                [void]$pending.Add($child)
            }
        }

        if($buttons.Count -lt 1){
            Write-Host "No buttons found on tab: $tabName"
            exit 1
        }
    }

    $script:RobocopySourceBox.Text = "C:\Source Folder"
    $script:RobocopyDestinationBox.Text = "D:\Destination Folder"
    $plan = Update-GUIRobocopyCommand

    if(!$plan -or $plan.Command -notmatch "robocopy.exe"){
        Write-Host "Robocopy builder smoke test failed."
        exit 1
    }

    Write-Host "Button smoke test completed."
    Write-Host "Quick tab: OK"
    Write-Host "Robocopy:" $plan.Command
    Write-Host "Software tab: OK"
    return
}

[void]$Form.ShowDialog()
