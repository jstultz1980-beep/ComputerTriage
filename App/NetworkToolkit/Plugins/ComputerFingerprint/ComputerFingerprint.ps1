function Global:Get-NTKFingerprintPath {

    $path = Join-Path $NTKPaths.Data "ComputerProfiles"

    if(!(Test-Path $path)){
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }

    $legacyPath = Join-Path $NTKPaths.Data "Fingerprints"

    if((Test-Path $legacyPath) -and !(Get-ChildItem -Path $path -Filter "*.json" -File -ErrorAction SilentlyContinue | Select-Object -First 1)){
        Get-ChildItem -Path $legacyPath -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Extension -in ".json",".html" } |
            ForEach-Object {
                Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $path $_.Name) -Force -ErrorAction SilentlyContinue
            }
    }

    return $path

}

function Global:ConvertTo-NTKSafeFileName {

param([string]$Name)

    $invalid = [IO.Path]::GetInvalidFileNameChars()
    $safe = $Name

    foreach($char in $invalid){
        $safe = $safe.Replace($char,"_")
    }

    return $safe

}

function Global:Get-NTKPendingRebootState {

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

function Global:ConvertTo-NTKHtmlText {

param([object]$Value)

    if($null -eq $Value){
        return ""
    }

    return [System.Net.WebUtility]::HtmlEncode([string]$Value)

}

function Global:ConvertTo-NTKHtmlTable {

param(
    [string]$Title,
    [object[]]$Rows
)

    $items = @($Rows | Where-Object { $null -ne $_ })

    if($items.Count -eq 0){
        return "<details class='report-section'><summary>$(ConvertTo-NTKHtmlText $Title)</summary><p class='muted'>No data found.</p></details>"
    }

    $columns = @($items[0].PSObject.Properties.Name)
    $html = "<details class='report-section'><summary>$(ConvertTo-NTKHtmlText $Title)</summary><table><thead><tr>"

    foreach($column in $columns){
        $html += "<th>$(ConvertTo-NTKHtmlText $column)</th>"
    }

    $html += "</tr></thead><tbody>"

    foreach($item in $items){

        $html += "<tr>"

        foreach($column in $columns){
            $value = $item.$column

            if($value -is [array]){
                $value = $value -join ", "
            }

            $html += "<td>$(ConvertTo-NTKHtmlText $value)</td>"
        }

        $html += "</tr>"

    }

    $html += "</tbody></table></details>"
    return $html

}

function Global:ConvertTo-NTKSupplementalEvidenceHtml {

param([object]$Fingerprint)

    if(!$Fingerprint -or !$Fingerprint.PSObject.Properties["SysinternalsEvidence"] -or !$Fingerprint.SysinternalsEvidence){
        return @"
<details class="report-section">
<summary>Startup, CPU, and Session Evidence</summary>
<p class="muted">No supplemental Sysinternals evidence is attached to this profile yet. Run Quick Diagnosis to populate bounded Autoruns, Coreinfo, and session context.</p>
</details>
"@
    }

    $evidence = $Fingerprint.SysinternalsEvidence
    $html = @"
<details class="report-section">
<summary>Startup, CPU, and Session Evidence</summary>
<div class="grid">
<div class="key">Collected</div><div>$(ConvertTo-NTKHtmlText $evidence.CollectedAt)</div>
"@

    if($evidence.Autoruns){
        $autoruns = $evidence.Autoruns
        $html += @"
<div class="key">Autoruns Entries Checked</div><div>$(ConvertTo-NTKHtmlText $autoruns.EntriesChecked)</div>
<div class="key">Autoruns Missing Paths</div><div>$(ConvertTo-NTKHtmlText $autoruns.MissingFileCount)</div>
<div class="key">Autoruns Unsigned/Unverified</div><div>$(ConvertTo-NTKHtmlText $autoruns.UnsignedOrUnverifiedCount)</div>
"@
    }

    if($evidence.Coreinfo){
        $coreinfo = $evidence.Coreinfo
        $html += @"
<div class="key">Coreinfo Hypervisor Context</div><div>$(ConvertTo-NTKHtmlText $coreinfo.HypervisorMentioned)</div>
<div class="key">Coreinfo Notes</div><div>$(ConvertTo-NTKHtmlText ((@($coreinfo.VirtualizationLines) | Select-Object -First 8) -join "; "))</div>
"@
    }

    if($evidence.LoggedOnUsers){
        $loggedOn = $evidence.LoggedOnUsers
        $html += @"
<div class="key">Logged-on User Context</div><div>$(ConvertTo-NTKHtmlText ((@($loggedOn.Users) | Select-Object -First 12) -join "; "))</div>
"@
    }

    $html += "</div>"

    if($evidence.Autoruns -and $evidence.Autoruns.MissingFiles){
        $rows = @($evidence.Autoruns.MissingFiles | Select-Object Entry,Category,ImagePath)
        $html += ConvertTo-NTKHtmlTable "Autoruns Missing File Details" $rows
    }

    if($evidence.Autoruns -and $evidence.Autoruns.UnsignedOrUnverified){
        $rows = @($evidence.Autoruns.UnsignedOrUnverified | Select-Object Entry,Category,Publisher,Verified,ImagePath)
        $html += ConvertTo-NTKHtmlTable "Autoruns Signature Review Details" $rows
    }

    if($evidence.LogonSessions -and $evidence.LogonSessions.SessionSummary){
        $rows = @($evidence.LogonSessions.SessionSummary | ForEach-Object { [pscustomobject]@{ Detail = $_ } })
        $html += ConvertTo-NTKHtmlTable "Logon Session Summary" $rows
    }

    $html += "</details>"
    return $html

}

function Global:Get-NTKComputerProfileState {

param([string]$ComputerName)

    if(Get-Command Read-NTKComputerState -ErrorAction SilentlyContinue){
        try {
            return Read-NTKComputerState -ComputerName $ComputerName
        }
        catch {}
    }

    return $null

}

function Global:ConvertTo-NTKComputerStateSummaryHtml {

param(
    [object]$State,
    [string]$ComputerName
)

    if(!$State -or !$State.Sections){
        return @"
<section>
<h2>Toolkit Current State</h2>
<p class="muted">No additional toolkit state has been captured for $(ConvertTo-NTKHtmlText $ComputerName) yet. Run Quick Diagnosis or GUI tools to populate this section.</p>
</section>
"@
    }

    $sections = $State.Sections
    $sectionNames = if($sections -is [System.Collections.IDictionary]){
        @($sections.Keys)
    }
    else{
        @($sections.PSObject.Properties.Name)
    }

    $html = @"
<section>
<h2>Toolkit Current State</h2>
<div class="grid">
<div class="key">State File Updated</div><div>$(ConvertTo-NTKHtmlText $State.UpdatedAt)</div>
<div class="key">Stored Sections</div><div>$(ConvertTo-NTKHtmlText ($sectionNames -join ", "))</div>
</div>
</section>
"@

    $quickSection = if($sections -is [System.Collections.IDictionary] -and $sections.Contains("QuickDiagnosis")){
        $sections["QuickDiagnosis"]
    }
    else{
        $sections.QuickDiagnosis
    }

    if($quickSection -and $quickSection.Data){
        $quick = $quickSection.Data
        $summary = $quick.Summary
        $reportPath = if($quick.ReportPath){$quick.ReportPath}else{""}

        $html += @"
<section>
<h2>Latest Quick Diagnosis</h2>
<div class="grid">
<div class="key">Captured</div><div>$(ConvertTo-NTKHtmlText $quick.CapturedAt)</div>
<div class="key">Target</div><div>$(ConvertTo-NTKHtmlText $quick.Target)</div>
<div class="key">Report</div><div>$(ConvertTo-NTKHtmlText $reportPath)</div>
<div class="key">Critical / Warning / Info / OK</div><div>$(ConvertTo-NTKHtmlText "$($summary.Critical) / $($summary.Warning) / $($summary.Info) / $($summary.OK)")</div>
<div class="key">Repair Disposition</div><div>$(ConvertTo-NTKHtmlText $quick.RepairDisposition)</div>
</div>
</section>
"@

        $problemRows = @(
            @($quick.Problems) |
                ForEach-Object {
                    [pscustomobject]@{
                        Status = $_.Status
                        Area = $_.Area
                        Check = $_.Check
                        Evidence = $_.Detail
                        NextStep = $_.Tip
                    }
                }
        )

        $html += ConvertTo-NTKHtmlTable "Latest Quick Diagnosis Problems" $problemRows
    }

    $toolSection = if($sections -is [System.Collections.IDictionary] -and $sections.Contains("LatestToolOutputs")){
        $sections["LatestToolOutputs"]
    }
    else{
        $sections.LatestToolOutputs
    }

    if($toolSection -and $toolSection.Data){
        $toolItems = if($toolSection.Data -is [System.Collections.IDictionary]){
            $toolSection.Data.GetEnumerator() | ForEach-Object {
                [pscustomobject]@{ Name = $_.Key; Value = $_.Value }
            }
        }
        else{
            $toolSection.Data.PSObject.Properties
        }

        $toolRows = @(
            $toolItems |
                Sort-Object Name |
                ForEach-Object {
                    $tool = $_.Value
                    [pscustomobject]@{
                        Tool = $tool.ToolName
                        UpdatedAt = $tool.UpdatedAt
                        SessionPath = $tool.SessionPath
                        TranscriptPath = $tool.TranscriptPath
                    }
                }
        )

        $html += ConvertTo-NTKHtmlTable "Latest GUI Tool Outputs" $toolRows
    }

    return $html

}

function Global:ConvertTo-NTKDedupedListeningPortRows {

param([object[]]$ListeningPorts)

    return @(
        $ListeningPorts |
            Where-Object { $null -ne $_ } |
            Group-Object LocalPort,ProcessId,ProcessName |
            ForEach-Object {

                $first = $_.Group | Select-Object -First 1
                $addresses = @(
                    $_.Group |
                        ForEach-Object { $_.LocalAddress } |
                        Where-Object { $_ } |
                        Sort-Object -Unique
                )

                [pscustomobject]@{
                    LocalPort      = $first.LocalPort
                    ProcessName    = $first.ProcessName
                    ProcessId      = $first.ProcessId
                    LocalAddresses = ($addresses -join ", ")
                }

            } |
            Sort-Object LocalPort,ProcessName,ProcessId
    )

}

function Global:Get-NTKComputerFingerprintServicingHealth {

    $result = [pscustomobject]@{
        Status = "Info"
        FollowUpDismSfc = $false
        Detail = "DISM CheckHealth was not run."
        Recommendation = "Run Quick Diagnosis or DISM/SFC Repair Path if Windows servicing health is suspect."
    }

    if(!(Get-Command dism.exe -ErrorAction SilentlyContinue)){
        $result.Detail = "dism.exe was not found."
        $result.Recommendation = "Verify Windows servicing tools are available."
        return $result
    }

    try {
        $output = @(dism.exe /Online /Cleanup-Image /CheckHealth 2>&1 | ForEach-Object {$_.ToString()})
        $text = ($output -join " ").Trim()

        if($LASTEXITCODE -eq 0 -and $text -match "No component store corruption detected"){
            $result.Status = "OK"
            $result.Detail = "No component store corruption detected."
            $result.Recommendation = "No DISM/SFC follow-up needed based on CheckHealth."
        }
        else{
            $result.Status = "Warning"
            $result.FollowUpDismSfc = $true
            $result.Detail = if($text){$text.Substring(0,[math]::Min(260,$text.Length))}else{"DISM CheckHealth exited with code $LASTEXITCODE."}
            $result.Recommendation = "Run DISM/SFC Repair Path if repair is approved, reboot if repairs occur, then rerun Quick Diagnosis."
        }
    }
    catch {
        $result.Status = "Warning"
        $result.FollowUpDismSfc = $true
        $result.Detail = $_.Exception.Message
        $result.Recommendation = "Rerun elevated. If this still fails, inspect Windows servicing health."
    }

    return $result

}

function Global:ConvertTo-NTKComputerFingerprintHtml {

param([object]$Fingerprint)

    $pendingReboot = if($Fingerprint.PendingReboot -and $Fingerprint.PendingReboot.Pending){ "Yes" } else { "No" }
    $pendingClass = if($pendingReboot -eq "Yes"){ "warn" } else { "ok" }
    $servicing = $Fingerprint.ServicingHealth
    $servicingStatus = if($servicing -and $servicing.Status){ [string]$servicing.Status } else { "Info" }
    $servicingClass = if($servicingStatus -eq "OK"){ "ok" } elseif($servicingStatus -eq "Warning"){ "warn" } else { "muted" }
    $servicingFollowUp = if($servicing -and $servicing.FollowUpDismSfc){ "Yes" } else { "No" }
    $servicingDetail = if($servicing){ $servicing.Detail } else { "DISM CheckHealth was not collected." }
    $servicingRecommendation = if($servicing){ $servicing.Recommendation } else { "Run Quick Diagnosis if Windows servicing health is suspect." }

    $diskRows = @(
        $Fingerprint.Disks |
            ForEach-Object {
                $freePct = if($_.SizeGB -and $_.SizeGB -ne 0){ [math]::Round(($_.FreeGB / $_.SizeGB) * 100, 1) } else { 0 }

                [pscustomobject]@{
                    Drive = $_.DeviceID
                    Volume = $_.VolumeName
                    SizeGB = $_.SizeGB
                    FreeGB = $_.FreeGB
                    FreePercent = $freePct
                }
            }
    )

    $adminRows = @(
        $Fingerprint.LocalAdmins |
            ForEach-Object {
                [pscustomobject]@{
                    Name = $_.Name
                    Type = $_.ObjectClass
                    Source = $_.PrincipalSource
                }
            }
    )

    $listeningPortRows = ConvertTo-NTKDedupedListeningPortRows -ListeningPorts $Fingerprint.ListeningPorts

    $pendingDetails = ""

    if($Fingerprint.PendingReboot -and $Fingerprint.PendingReboot.Details){
        $pendingDetails = ($Fingerprint.PendingReboot.Details -join ", ")
    }

    $computerState = Get-NTKComputerProfileState -ComputerName $Fingerprint.ComputerName
    $computerStateHtml = ConvertTo-NTKComputerStateSummaryHtml -State $computerState -ComputerName $Fingerprint.ComputerName

    $css = @"
body{margin:0;background:#f3f6f8;color:#18212b;font-family:Segoe UI,Arial,sans-serif}
header{background:#0d3054;color:white;padding:26px 34px}
h1{margin:0;font-size:30px}
.sub{margin-top:6px;color:#cfe1f2}
main{padding:24px 34px}
.cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:14px;margin-bottom:22px}
.card{background:white;border:1px solid #d9e1ea;border-left:5px solid #1b6598;padding:14px}
.label{font-size:12px;text-transform:uppercase;color:#607080}
.value{font-size:20px;font-weight:700;margin-top:6px}
.ok{color:#137346}.warn{color:#a45b00}
section,.report-section{background:white;border:1px solid #d9e1ea;margin:16px 0;padding:18px}
h2{font-size:18px;margin:0 0 12px 0;color:#0d3054}
summary{cursor:pointer;font-size:18px;font-weight:700;color:#0d3054;margin:0 0 12px 0}
details[open] summary{margin-bottom:12px}
table{border-collapse:collapse;width:100%;font-size:13px}
th,td{border-bottom:1px solid #e5ebf0;padding:8px;text-align:left;vertical-align:top}
th{background:#eef4f8;color:#25394d}
.grid{display:grid;grid-template-columns:220px 1fr;gap:6px 14px}
.key{font-weight:700;color:#364b5f}
.muted{color:#6c7884}
"@

    $html = @"
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>Computer Profile - $(ConvertTo-NTKHtmlText $Fingerprint.ComputerName)</title>
<style>$css</style>
</head>
<body>
<header>
<h1>Computer Profile</h1>
<div class="sub">$(ConvertTo-NTKHtmlText $Fingerprint.ComputerName) &bull; Captured $(ConvertTo-NTKHtmlText $Fingerprint.CapturedAt)</div>
</header>
<main>
<div class="cards">
<div class="card"><div class="label">Computer</div><div class="value">$(ConvertTo-NTKHtmlText $Fingerprint.ComputerName)</div></div>
<div class="card"><div class="label">OS Build</div><div class="value">$(ConvertTo-NTKHtmlText $Fingerprint.OSBuild)</div></div>
<div class="card"><div class="label">Memory</div><div class="value">$(ConvertTo-NTKHtmlText $Fingerprint.MemoryGB) GB</div></div>
<div class="card"><div class="label">Uptime</div><div class="value">$(ConvertTo-NTKHtmlText $Fingerprint.UptimeDays) days</div></div>
<div class="card"><div class="label">Pending Reboot</div><div class="value $pendingClass">$pendingReboot</div></div>
<div class="card"><div class="label">DISM/SFC Follow-Up</div><div class="value $servicingClass">$servicingFollowUp</div></div>
</div>

<section>
<h2>Servicing Health</h2>
<div class="grid">
<div class="key">DISM CheckHealth</div><div class="$servicingClass">$(ConvertTo-NTKHtmlText $servicingStatus)</div>
<div class="key">Follow Up Needed</div><div class="$servicingClass">$(ConvertTo-NTKHtmlText $servicingFollowUp)</div>
<div class="key">Detail</div><div>$(ConvertTo-NTKHtmlText $servicingDetail)</div>
<div class="key">Recommendation</div><div>$(ConvertTo-NTKHtmlText $servicingRecommendation)</div>
</div>
</section>

<section>
<h2>System Summary</h2>
<div class="grid">
<div class="key">User</div><div>$(ConvertTo-NTKHtmlText $Fingerprint.UserName)</div>
<div class="key">Domain</div><div>$(ConvertTo-NTKHtmlText $Fingerprint.Domain)</div>
<div class="key">Manufacturer / Model</div><div>$(ConvertTo-NTKHtmlText "$($Fingerprint.Manufacturer) $($Fingerprint.Model)")</div>
<div class="key">Serial Number</div><div>$(ConvertTo-NTKHtmlText $Fingerprint.SerialNumber)</div>
<div class="key">BIOS Version</div><div>$(ConvertTo-NTKHtmlText $Fingerprint.BIOSVersion)</div>
<div class="key">OS</div><div>$(ConvertTo-NTKHtmlText "$($Fingerprint.OS) $($Fingerprint.OSVersion)")</div>
<div class="key">Last Boot</div><div>$(ConvertTo-NTKHtmlText $Fingerprint.LastBoot)</div>
<div class="key">CPU</div><div>$(ConvertTo-NTKHtmlText $Fingerprint.CPU)</div>
<div class="key">Cores / Logical Processors</div><div>$(ConvertTo-NTKHtmlText "$($Fingerprint.Cores) / $($Fingerprint.LogicalProcessors)")</div>
<div class="key">PowerShell</div><div>$(ConvertTo-NTKHtmlText $Fingerprint.PowerShell)</div>
<div class="key">Time Source</div><div>$(ConvertTo-NTKHtmlText $Fingerprint.TimeSource)</div>
<div class="key">Pending Reboot Details</div><div>$(ConvertTo-NTKHtmlText $pendingDetails)</div>
</div>
</section>

$computerStateHtml
"@

    $html += ConvertTo-NTKHtmlTable "Disks" $diskRows
    $html += ConvertTo-NTKHtmlTable "Network IP Configuration" $Fingerprint.NetworkAdapters
    $html += ConvertTo-NTKHtmlTable "Network Adapters / MAC Addresses" $Fingerprint.MACAddresses
    $html += ConvertTo-NTKHtmlTable "Firewall Profiles" $Fingerprint.FirewallProfiles
    $html += ConvertTo-NTKHtmlTable "Security Products" $Fingerprint.SecurityProducts
    $html += ConvertTo-NTKHtmlTable "Defender Status" @($Fingerprint.Defender)
    $html += ConvertTo-NTKHtmlTable "BitLocker" $Fingerprint.BitLocker
$html += ConvertTo-NTKHtmlTable "Local Administrators" $adminRows
$html += ConvertTo-NTKHtmlTable "Listening TCP Ports" $listeningPortRows
$html += ConvertTo-NTKSupplementalEvidenceHtml -Fingerprint $Fingerprint

    $html += @"
</main>
</body>
</html>
"@

    return $html

}

function Global:Export-NTKComputerFingerprintHtml {

param(
    [object]$Fingerprint,
    [string]$JsonPath
)

    if($JsonPath){
        $htmlPath = [IO.Path]::ChangeExtension($JsonPath, ".html")
    }
    else{
        $root = Get-NTKFingerprintPath
        $safeName = ConvertTo-NTKSafeFileName $Fingerprint.ComputerName
        $htmlPath = Join-Path $root "$safeName.html"
    }

    ConvertTo-NTKComputerFingerprintHtml -Fingerprint $Fingerprint |
        Set-Content -Path $htmlPath -Encoding UTF8

    return $htmlPath

}

function Global:Save-NTKComputerFingerprint {

param(
    [object]$Fingerprint,
    [string]$OutputRoot,
    [string]$Prefix = "",
    [switch]$Timestamped
)

    if(!$Fingerprint){
        return $null
    }

    if($OutputRoot){
        $root = $OutputRoot

        if(!(Test-Path $root)){
            New-Item -ItemType Directory -Path $root -Force | Out-Null
        }
    }
    else{
        $root = Get-NTKFingerprintPath
    }

    $safeName = ConvertTo-NTKSafeFileName $Fingerprint.ComputerName
    $fileBase = $safeName

    if($Prefix){
        $fileBase = "{0}-{1}" -f (ConvertTo-NTKSafeFileName $Prefix),$safeName
    }

    if($Timestamped){
        $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $fileBase = "{0}-{1}" -f $safeName,$stamp

        if($Prefix){
            $fileBase = "{0}-{1}-{2}" -f (ConvertTo-NTKSafeFileName $Prefix),$safeName,$stamp
        }
    }

    $jsonPath = Join-Path $root "$fileBase.json"

    $Fingerprint |
        ConvertTo-Json -Depth 8 |
        Set-Content -Path $jsonPath -Encoding UTF8

    if(Get-Command Set-NTKComputerStateSection -ErrorAction SilentlyContinue){
        try {
            [void](Set-NTKComputerStateSection `
                -SectionName "ComputerProfile" `
                -Data $Fingerprint `
                -ComputerName $Fingerprint.ComputerName `
                -Source "Save-NTKComputerFingerprint")
        }
        catch {}
    }

    $htmlPath = Export-NTKComputerFingerprintHtml -Fingerprint $Fingerprint -JsonPath $jsonPath

    return [pscustomobject]@{
        Json = $jsonPath
        Html = $htmlPath
    }

}

function Global:Open-NTKComputerFingerprintReport {

param([string]$Path)

    if(!(Test-Path $Path)){
        Write-Host "Computer profile file missing." -ForegroundColor Red
        return
    }

    try {
        $fingerprint = Get-Content -Raw -Path $Path | ConvertFrom-Json
        $htmlPath = Export-NTKComputerFingerprintHtml -Fingerprint $fingerprint -JsonPath $Path
        Write-Host "Opening:" $htmlPath -ForegroundColor Green
        Start-NTKToolProcess -FilePath $htmlPath | Out-Null
    }
    catch {
        Write-Host "Unable to open computer profile report." -ForegroundColor Red
        Write-Host $_.Exception.Message
    }

}

function Global:Get-NTKComputerFingerprint {

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

        $rawListeningPorts = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
                             Select-Object -First 250 |
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

        $listeningPorts = ConvertTo-NTKDedupedListeningPortRows -ListeningPorts $rawListeningPorts

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

    $pendingReboot = Get-NTKPendingRebootState
    $servicingHealth = Get-NTKComputerFingerprintServicingHealth

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
        ServicingHealth  = $servicingHealth
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

function Global:Show-NTKComputerFingerprintSummary {

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
    Write-Host "TAKE COMPUTER PROFILE" -ForegroundColor Cyan
    Write-Host "=====================" -ForegroundColor DarkCyan
    Write-Host ""

    $fingerprint = Get-NTKComputerFingerprint
    $saved = Save-NTKComputerFingerprint -Fingerprint $fingerprint

    Show-NTKComputerFingerprintSummary $fingerprint

    Write-Host ""
    Write-Host "Computer profile saved:" $saved.Json -ForegroundColor Green
    Write-Host "HTML report saved:" $saved.Html -ForegroundColor Green

    if($PassThru){
        return $fingerprint
    }

}

function Global:Get-NTKStoredFingerprints {

    $root = Get-NTKFingerprintPath

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
    Write-Host "COMPUTER PROFILE SELECTOR" -ForegroundColor Cyan
    Write-Host "=========================" -ForegroundColor DarkCyan
    Write-Host ""

    $fingerprints = @(Get-NTKStoredFingerprints)

    if($fingerprints.Count -eq 0){

        Write-Host "No computer profiles found." -ForegroundColor Yellow
        Write-Host "Run Quick Diagnosis to create a computer profile."
        return

    }

    for($i = 0; $i -lt $fingerprints.Count; $i++){

        $item = $fingerprints[$i]

        Write-Host ("{0}. {1}  {2}  {3}" -f ($i + 1),$item.ComputerName,$item.CapturedAt,$item.UserName)

    }

    Write-Host ""

    $choice = Read-NTKInput "Select computer profile"

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

    $action = Read-NTKInput "Open or Delete"

    if($action -match "^(o|open)$"){

        if(Test-Path $selected.Path){

            Open-NTKComputerFingerprintReport -Path $selected.Path

        }
        else{
            Write-Host "Computer profile file missing." -ForegroundColor Red
        }

    }
    elseif($action -match "^(d|delete)$"){

        if(Test-Path $selected.Path){

            Remove-Item -Path $selected.Path -Force
            Write-Host "Deleted:" $selected.ComputerName -ForegroundColor Yellow

        }
        else{
            Write-Host "Computer profile file missing." -ForegroundColor Red
        }

    }
    else{

        Write-Host "Action not recognized. Use Open or Delete." -ForegroundColor Red

    }

}
