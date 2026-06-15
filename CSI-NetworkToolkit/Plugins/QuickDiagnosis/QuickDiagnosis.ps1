function Global:Convert-CSIHtml {

param([object]$Value)

    return [System.Net.WebUtility]::HtmlEncode([string]$Value)

}

function Global:Export-CSIQuickDiagnosisHtml {

param(
    [pscustomobject]$Report,
    [string]$OutputRoot
)

    if(!$OutputRoot){
        $OutputRoot = $CSIPaths.Exports
    }

    if(!(Test-Path $OutputRoot)){
        New-Item -ItemType Directory -Path $OutputRoot -Force | Out-Null
    }

    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $htmlPath = Join-Path $OutputRoot "quick-diagnosis-$($Report.ComputerName)-$stamp.html"
    $problems = @($Report.Problems)
    $checks = @($Report.Health)
    $fingerprint = $Report.Fingerprint
    $overallClass = if($Report.Summary.Critical -gt 0){"critical"}elseif($Report.Summary.Warning -gt 0){"warning"}else{"ok"}
    $overallText = if($Report.Summary.Critical -gt 0){"Immediate attention needed"}elseif($Report.Summary.Warning -gt 0){"Issues found"}else{"No major issues found"}

    $problemRows = if($problems.Count -gt 0){
        ($problems | ForEach-Object {
            "<tr><td><span class='badge $($_.Status.ToLower())'>$(Convert-CSIHtml $_.Status)</span></td><td>$(Convert-CSIHtml $_.Area)</td><td>$(Convert-CSIHtml $_.Check)</td><td>$(Convert-CSIHtml $_.Detail)</td><td>$(Convert-CSIHtml $_.Tip)</td></tr>"
        }) -join "`n"
    }
    else{
        "<tr><td colspan='5' class='empty'>No critical or warning findings.</td></tr>"
    }

    $checkRows = ($checks | ForEach-Object {
        $status = [string]$_.Status
        "<tr><td><span class='badge $($status.ToLower())'>$(Convert-CSIHtml $status)</span></td><td>$(Convert-CSIHtml $_.Area)</td><td>$(Convert-CSIHtml $_.Check)</td><td>$(Convert-CSIHtml $_.Detail)</td><td>$(Convert-CSIHtml $_.Tip)</td></tr>"
    }) -join "`n"

    $diskRows = if($fingerprint -and $fingerprint.Disks){
        (@($fingerprint.Disks) | ForEach-Object {
            "<tr><td>$(Convert-CSIHtml $_.DeviceID)</td><td>$(Convert-CSIHtml $_.VolumeName)</td><td>$(Convert-CSIHtml $_.SizeGB)</td><td>$(Convert-CSIHtml $_.FreeGB)</td></tr>"
        }) -join "`n"
    }
    else{
        "<tr><td colspan='4' class='empty'>Disk details were not collected.</td></tr>"
    }

    $adapterRows = if($fingerprint -and $fingerprint.NetworkAdapters){
        (@($fingerprint.NetworkAdapters) | ForEach-Object {
            "<tr><td>$(Convert-CSIHtml $_.Interface)</td><td>$(Convert-CSIHtml $_.IPv4)</td><td>$(Convert-CSIHtml $_.Gateway)</td><td>$(Convert-CSIHtml $_.DNS)</td></tr>"
        }) -join "`n"
    }
    else{
        "<tr><td colspan='4' class='empty'>Network adapter details were not collected.</td></tr>"
    }

    $html = @"
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Network Toolkit Quick Diagnosis - $(Convert-CSIHtml $Report.ComputerName)</title>
<style>
body { margin: 0; font-family: "Segoe UI", Arial, sans-serif; color: #1f2933; background: #eef2f6; }
.topbar { background: #0f2f4a; color: #fff; padding: 28px 36px; }
.topbar h1 { margin: 0; font-size: 28px; font-weight: 650; }
.topbar p { margin: 8px 0 0; color: #c9d8e5; }
.wrap { max-width: 1180px; margin: 0 auto; padding: 26px 28px 40px; }
.summary { display: grid; grid-template-columns: 1.4fr repeat(4, 1fr); gap: 14px; margin-top: -42px; }
.card { background: #fff; border: 1px solid #d9e1e8; border-radius: 8px; padding: 18px; box-shadow: 0 8px 20px rgba(15,47,74,.08); }
.status-card { border-left: 7px solid #2e7d32; }
.status-card.warning { border-left-color: #b7791f; }
.status-card.critical { border-left-color: #b42318; }
.status-title { font-size: 13px; color: #66788a; text-transform: uppercase; letter-spacing: .04em; }
.status-value { font-size: 28px; font-weight: 700; margin-top: 4px; }
.metric { text-align: center; }
.metric strong { display: block; font-size: 30px; margin-top: 4px; }
.metric span { color: #66788a; font-size: 13px; text-transform: uppercase; }
.section { margin-top: 22px; }
.section h2 { font-size: 20px; margin: 0 0 10px; color: #102a43; }
.grid { display: grid; grid-template-columns: repeat(2, minmax(0,1fr)); gap: 16px; }
table { width: 100%; border-collapse: collapse; background: #fff; border: 1px solid #d9e1e8; border-radius: 8px; overflow: hidden; }
th, td { text-align: left; padding: 10px 12px; border-bottom: 1px solid #e6edf3; vertical-align: top; font-size: 13px; }
th { background: #f6f8fb; color: #425466; font-weight: 650; }
tr:last-child td { border-bottom: none; }
.badge { display: inline-block; min-width: 68px; text-align: center; border-radius: 999px; padding: 3px 9px; font-size: 12px; font-weight: 700; }
.badge.ok { color: #1b5e20; background: #dff3e3; }
.badge.info { color: #174ea6; background: #e1ecff; }
.badge.warning { color: #7a4a00; background: #fff1cc; }
.badge.critical { color: #8a1f11; background: #ffe1dc; }
.empty { color: #66788a; font-style: italic; }
.kv { display: grid; grid-template-columns: 155px 1fr; row-gap: 8px; column-gap: 12px; font-size: 14px; }
.kv div:nth-child(odd) { color: #66788a; }
.footer { color: #66788a; font-size: 12px; margin-top: 24px; }
@media print {
  body { background: #fff; }
  .summary { margin-top: 0; }
  .card { box-shadow: none; }
}
</style>
</head>
<body>
<div class="topbar">
  <h1>Network Toolkit Quick Diagnosis</h1>
  <p>$(Convert-CSIHtml $Report.ComputerName) | $(Convert-CSIHtml $Report.CollectedAt) | Target: $(Convert-CSIHtml $Report.Target)</p>
</div>
<div class="wrap">
  <div class="summary">
    <div class="card status-card $overallClass">
      <div class="status-title">Overall Status</div>
      <div class="status-value">$overallText</div>
      <p>Diagnostic-only scan. DISM CheckHealth may run; repair actions are skipped. Use the DISM/SFC Repair Path tool only after reviewing this report.</p>
    </div>
    <div class="card metric"><span>Critical</span><strong>$(Convert-CSIHtml $Report.Summary.Critical)</strong></div>
    <div class="card metric"><span>Warning</span><strong>$(Convert-CSIHtml $Report.Summary.Warning)</strong></div>
    <div class="card metric"><span>Info</span><strong>$(Convert-CSIHtml $Report.Summary.Info)</strong></div>
    <div class="card metric"><span>OK</span><strong>$(Convert-CSIHtml $Report.Summary.OK)</strong></div>
  </div>

  <div class="section">
    <h2>Problems Found</h2>
    <table>
      <thead><tr><th>Status</th><th>Area</th><th>Check</th><th>Detail</th><th>Recommended Next Step</th></tr></thead>
      <tbody>
$problemRows
      </tbody>
    </table>
  </div>

  <div class="section grid">
    <div class="card">
      <h2>System Snapshot</h2>
      <div class="kv">
        <div>User</div><div>$(Convert-CSIHtml $Report.UserName)</div>
        <div>Domain</div><div>$(Convert-CSIHtml $(if($fingerprint){$fingerprint.Domain}else{""}))</div>
        <div>Model</div><div>$(Convert-CSIHtml $(if($fingerprint){"$($fingerprint.Manufacturer) $($fingerprint.Model)"}else{""}))</div>
        <div>OS</div><div>$(Convert-CSIHtml $(if($fingerprint){"$($fingerprint.OS) $($fingerprint.OSVersion) Build $($fingerprint.OSBuild)"}else{""}))</div>
        <div>Uptime Days</div><div>$(Convert-CSIHtml $(if($fingerprint){$fingerprint.UptimeDays}else{""}))</div>
        <div>Memory GB</div><div>$(Convert-CSIHtml $(if($fingerprint){$fingerprint.MemoryGB}else{""}))</div>
        <div>Pending Reboot</div><div>$(Convert-CSIHtml $(if($fingerprint){$fingerprint.PendingReboot.Pending}else{""}))</div>
      </div>
    </div>
    <div class="card">
      <h2>Repair Disposition</h2>
      <p>$(Convert-CSIHtml $Report.RepairDisposition)</p>
    </div>
  </div>

  <div class="section grid">
    <div>
      <h2>Disks</h2>
      <table><thead><tr><th>Drive</th><th>Volume</th><th>Size GB</th><th>Free GB</th></tr></thead><tbody>$diskRows</tbody></table>
    </div>
    <div>
      <h2>Network Adapters</h2>
      <table><thead><tr><th>Interface</th><th>IPv4</th><th>Gateway</th><th>DNS</th></tr></thead><tbody>$adapterRows</tbody></table>
    </div>
  </div>

  <div class="section">
    <h2>All Checks</h2>
    <table>
      <thead><tr><th>Status</th><th>Area</th><th>Check</th><th>Detail</th><th>Recommended Next Step</th></tr></thead>
      <tbody>
$checkRows
      </tbody>
    </table>
  </div>

  <div class="footer">Generated by Network Toolkit Quick Diagnosis.</div>
</div>
</body>
</html>
"@

    $html | Set-Content -Path $htmlPath -Encoding UTF8
    return $htmlPath

}

function Global:Add-CSIQuickFinding {

param(
    [ref]$Findings,
    [string]$Area,
    [string]$Check,
    [string]$Status,
    [string]$Detail,
    [string]$Tip = ""
)

    $Findings.Value += [pscustomobject]@{
        Area   = $Area
        Check  = $Check
        Status = $Status
        Detail = $Detail
        Tip    = $Tip
    }

}

function Global:Get-CSIQuickRemediationTip {

param([pscustomobject]$Finding)

    $area = [string]$Finding.Area
    $check = [string]$Finding.Check
    $detail = [string]$Finding.Detail
    $status = [string]$Finding.Status

    if($status -in @("OK","Info")){
        return ""
    }

    if($area -eq "System Image" -and $check -eq "DISM CheckHealth"){
        return "Use Windows Health Diagnostics > DISM/SFC Repair Path if CheckHealth reports corruption or servicing health is suspect, then reboot if repairs occur and rerun Quick Diagnosis."
    }

    if($area -eq "System" -and $check -eq "Pending Reboot"){
        return "Reboot the computer during an approved window, then rerun Quick Diagnosis to confirm the pending reboot cleared."
    }

    if($area -eq "Disk"){
        if($check -eq "Physical Disk Health"){
            return "Open CrystalDiskInfo or HWiNFO from Windows Health Diagnostics and verify SMART/physical disk status."
        }
        return "Free disk space or inspect usage with File Utilities > WizTree. Prioritize drives below 10 percent free."
    }

    if($area -eq "Hardware"){
        if($check -eq "Device Manager"){
            return "Open Hardware Health Diagnostics and Device Manager. Review problem devices, update or reinstall drivers, and check cabling/firmware for affected hardware."
        }
        if($check -eq "SMART Failure Prediction"){
            return "Back up data immediately. Open CrystalDiskInfo or vendor diagnostics and plan disk replacement if failure prediction is confirmed."
        }
        return "Open Hardware Health Diagnostics. Review hardware/driver events, then run OEM diagnostics if symptoms match."
    }

    if($area -eq "Event Logs"){
        return "Open Windows Health Diagnostics > Event Log Triage and review recent critical/error events by provider and timestamp."
    }

    if($area -eq "Services"){
        if($check -eq "Stopped Automatic Services"){
            return "Review the listed services. Confirm whether each is expected to be stopped before restarting or changing startup behavior."
        }
        return "Open Services or Windows Health Diagnostics > Service Health and verify whether the service should be running."
    }

    if($area -eq "Security"){
        return "Open Windows Security or Windows Health Diagnostics > Defender Security Check and verify AV, signatures, and real-time protection."
    }

    if($area -eq "Crashes"){
        return "Open Windows Health Diagnostics > Minidump Collector And Analyzer or BlueScreenView to inspect recent crashes and dump files."
    }

    if($area -eq "Resources"){
        return "Open Windows Health Diagnostics > Resource Hotspots, Process Explorer, or RAMMap to identify active memory/CPU pressure."
    }

    if($area -eq "Network" -or $area -eq "Internet"){
        return "Open Connectivity Diagnostics. Check adapter route health, Test-NetConnection, gateway reachability, DNS, and packet loss."
    }

    if($area -eq "DNS"){
        return "Open DNS Diagnostics and compare configured resolvers against a known-good resolver."
    }

    if($area -eq "Domain"){
        return "Open Windows Health Diagnostics > Domain Logon Health and verify DC discovery, secure channel, DNS, and time sync."
    }

    if($area -eq "Time"){
        return "Open Infrastructure Services > Time Sync Health. Verify Windows Time service, source, and domain time hierarchy."
    }

    if($area -eq "Firewall"){
        return "Open Infrastructure Services > Local Exposure Inspector and confirm firewall profile policy matches the network role."
    }

    if($area -eq "Print"){
        return "Open Print Queue Tools and check spooler state, stuck jobs, and stale printer artifacts."
    }

    if($detail -match "Access is denied"){
        return "Rerun the toolkit elevated, then rerun Quick Diagnosis."
    }

    return "Use the matching diagnostics submenu for this area and rerun Quick Diagnosis after changes."

}

function Global:Add-CSIQuickTipsToFindings {

param([object[]]$Findings)

    foreach($finding in @($Findings)){

        $tip = ""

        if($finding.PSObject.Properties["Tip"] -and $finding.Tip){
            $tip = [string]$finding.Tip
        }
        else{
            $tip = Get-CSIQuickRemediationTip -Finding $finding
        }

        [pscustomobject]@{
            Area   = $finding.Area
            Check  = $finding.Check
            Status = $finding.Status
            Detail = $finding.Detail
            Tip    = $tip
        }

    }

}

function Global:Invoke-CSIQuickDismCheckHealth {

    $findings = @()

    if(!(Get-Command dism.exe -ErrorAction SilentlyContinue)){
        Add-CSIQuickFinding ([ref]$findings) "System Image" "DISM CheckHealth" "Info" "dism.exe was not found." "Verify Windows servicing tools are available on this machine."
        return $findings
    }

    try {

        $output = @(dism.exe /Online /Cleanup-Image /CheckHealth 2>&1 | ForEach-Object {$_.ToString()})
        $text = ($output -join " ").Trim()

        if($LASTEXITCODE -eq 0 -and $text -match "No component store corruption detected"){
            Add-CSIQuickFinding ([ref]$findings) "System Image" "DISM CheckHealth" "OK" "No component store corruption detected."
        }
        elseif($text -match "repairable|corruption|component store"){
            Add-CSIQuickFinding ([ref]$findings) "System Image" "DISM CheckHealth" "Warning" ($text.Substring(0,[math]::Min(240,$text.Length))) "Run Windows Health Diagnostics > DISM/SFC Repair Path if repair is approved, then reboot if repairs occur and rerun Quick Diagnosis."
        }
        else{
            Add-CSIQuickFinding ([ref]$findings) "System Image" "DISM CheckHealth" "Warning" "DISM exited with code $LASTEXITCODE. $($text.Substring(0,[math]::Min(200,$text.Length)))" "Rerun Quick Diagnosis elevated. If it still fails, inspect Windows servicing health."
        }

    }
    catch {
        Add-CSIQuickFinding ([ref]$findings) "System Image" "DISM CheckHealth" "Warning" $_.Exception.Message "Rerun Quick Diagnosis elevated. If it still fails, inspect Windows servicing health."
    }

    return $findings

}

function Global:Get-CSIQuickStatusChecks {

param([pscustomobject]$BaseReport)

    $findings = @()

    $findings += Invoke-CSIQuickDismCheckHealth

    try {

        $start = (Get-Date).AddHours(-24)
        $events = @()

        foreach($log in @("System","Application","Setup")){
            try {
                $events += Get-WinEvent -FilterHashtable @{LogName=$log; Level=1,2; StartTime=$start} -MaxEvents 40 -ErrorAction Stop
            }
            catch {}
        }

        $critical = @($events | Where-Object {$_.LevelDisplayName -eq "Critical"}).Count
        $errors = @($events | Where-Object {$_.LevelDisplayName -eq "Error"}).Count

        if($critical -gt 0){
            Add-CSIQuickFinding ([ref]$findings) "Event Logs" "Last 24 Hours" "Critical" "$critical critical and $errors error events found." "Open Windows Health Diagnostics > Event Log Triage and review the newest critical events first."
        }
        elseif($errors -gt 10){
            Add-CSIQuickFinding ([ref]$findings) "Event Logs" "Last 24 Hours" "Warning" "$errors error events found." "Open Windows Health Diagnostics > Event Log Triage and group errors by provider."
        }
        else{
            Add-CSIQuickFinding ([ref]$findings) "Event Logs" "Last 24 Hours" "OK" "$errors error events and no critical events found."
        }

    }
    catch {
        Add-CSIQuickFinding ([ref]$findings) "Event Logs" "Last 24 Hours" "Info" "Unable to read recent event logs." "Rerun elevated or open Event Viewer manually."
    }

    try {

        $stoppedAuto = @(Get-CimInstance Win32_Service |
                         Where-Object {$_.StartMode -eq "Auto" -and $_.State -ne "Running" -and $_.Name -notin @("edgeupdate","edgeupdatem","MapsBroker","RemoteRegistry","sppsvc")})

        if($stoppedAuto.Count -gt 0){
            Add-CSIQuickFinding ([ref]$findings) "Services" "Stopped Automatic Services" "Warning" (($stoppedAuto | Select-Object -First 8 -ExpandProperty Name) -join ",") "Open Windows Health Diagnostics > Service Health and verify whether each listed service should be running."
        }
        else{
            Add-CSIQuickFinding ([ref]$findings) "Services" "Stopped Automatic Services" "OK" "No unexpected stopped automatic services found."
        }

    }
    catch {
        Add-CSIQuickFinding ([ref]$findings) "Services" "Stopped Automatic Services" "Info" "Unable to evaluate service state." "Rerun elevated or inspect services.msc manually."
    }

    try {

        if(Get-Command Get-MpComputerStatus -ErrorAction SilentlyContinue){

            $defender = Get-MpComputerStatus
            $issues = @()

            if(!$defender.AntivirusEnabled){$issues += "Antivirus disabled"}
            if(!$defender.RealTimeProtectionEnabled){$issues += "Real-time protection disabled"}

            if($defender.AntivirusSignatureLastUpdated){
                $ageDays = [math]::Round(((Get-Date) - $defender.AntivirusSignatureLastUpdated).TotalDays,1)
                if($ageDays -gt 7){$issues += "Signatures $ageDays days old"}
            }

            if($issues){
                Add-CSIQuickFinding ([ref]$findings) "Security" "Defender" "Warning" ($issues -join "; ") "Open Windows Security or Defender Security Check and verify AV/signature status."
            }
            else{
                Add-CSIQuickFinding ([ref]$findings) "Security" "Defender" "OK" "Defender and real-time protection appear enabled."
            }

        }
        else{
            Add-CSIQuickFinding ([ref]$findings) "Security" "Defender" "Info" "Defender cmdlets are not available." "Confirm the active antivirus/security platform manually."
        }

    }
    catch {
        Add-CSIQuickFinding ([ref]$findings) "Security" "Defender" "Info" "Unable to evaluate Defender status." "Confirm the active antivirus/security platform manually."
    }

    try {

        if(Get-Command Get-PhysicalDisk -ErrorAction SilentlyContinue){

            $badDisks = @(Get-PhysicalDisk | Where-Object {$_.HealthStatus -ne "Healthy" -or $_.OperationalStatus -notcontains "OK"})

            if($badDisks.Count -gt 0){
                Add-CSIQuickFinding ([ref]$findings) "Disk" "Physical Disk Health" "Warning" (($badDisks | ForEach-Object {"$($_.FriendlyName) $($_.HealthStatus) $($_.OperationalStatus)"}) -join "; ") "Open CrystalDiskInfo or HWiNFO and inspect SMART/drive health immediately."
            }
            else{
                Add-CSIQuickFinding ([ref]$findings) "Disk" "Physical Disk Health" "OK" "Physical disks report healthy."
            }

        }
        else{
            Add-CSIQuickFinding ([ref]$findings) "Disk" "Physical Disk Health" "Info" "Get-PhysicalDisk is not available." "Use CrystalDiskInfo or vendor tools to verify disk health."
        }

    }
    catch {
        Add-CSIQuickFinding ([ref]$findings) "Disk" "Physical Disk Health" "Info" "Unable to evaluate physical disk health." "Use CrystalDiskInfo or vendor tools to verify disk health."
    }

    try {

        $deviceProblems = @()

        if(Get-Command Get-CSIHardwareDeviceProblems -ErrorAction SilentlyContinue){
            $deviceProblems = @(Get-CSIHardwareDeviceProblems)
        }
        elseif(Get-Command Get-PnpDevice -ErrorAction SilentlyContinue){
            $deviceProblems = @(Get-PnpDevice -PresentOnly -ErrorAction SilentlyContinue | Where-Object { $_.Status -notin @("OK","Unknown") })
        }

        if($deviceProblems.Count -gt 0){

            $detail = @(
                $deviceProblems |
                    Select-Object -First 8 |
                    ForEach-Object {
                        if($_.FriendlyName){"$($_.FriendlyName) [$($_.Status)]"}
                        elseif($_.Name){"$($_.Name) [$($_.Status)]"}
                        else{"$($_.InstanceId) [$($_.Status)]"}
                    }
            ) -join "; "

            Add-CSIQuickFinding ([ref]$findings) "Hardware" "Device Manager" "Warning" "$($deviceProblems.Count) problem device(s): $detail" "Open Hardware Health Diagnostics and Device Manager. Fix driver, firmware, cabling, or missing-device problems."
        }
        else{
            Add-CSIQuickFinding ([ref]$findings) "Hardware" "Device Manager" "OK" "No present Device Manager problem devices found."
        }

    }
    catch {
        Add-CSIQuickFinding ([ref]$findings) "Hardware" "Device Manager" "Info" "Unable to evaluate Device Manager problem devices." "Open Device Manager manually or rerun elevated."
    }

    try {

        $smartFailures = @(Get-CimInstance -Namespace root\wmi -ClassName MSStorageDriver_FailurePredictStatus -ErrorAction Stop | Where-Object { $_.PredictFailure })

        if($smartFailures.Count -gt 0){
            Add-CSIQuickFinding ([ref]$findings) "Hardware" "SMART Failure Prediction" "Critical" "$($smartFailures.Count) disk device(s) report predicted failure." "Back up data immediately and inspect disk health with CrystalDiskInfo or vendor diagnostics."
        }
        else{
            Add-CSIQuickFinding ([ref]$findings) "Hardware" "SMART Failure Prediction" "OK" "No storage-driver predicted disk failures reported."
        }

    }
    catch {
        Add-CSIQuickFinding ([ref]$findings) "Hardware" "SMART Failure Prediction" "Info" "SMART failure prediction was not available from Windows." "Use CrystalDiskInfo, HWiNFO, or vendor diagnostics if disk symptoms exist."
    }

    try {

        $hardwareEvents = @()

        foreach($provider in @("Microsoft-Windows-WHEA-Logger","Microsoft-Windows-Kernel-PnP","Microsoft-Windows-DriverFrameworks-UserMode","disk","storahci","stornvme")){
            try {
                $hardwareEvents += Get-WinEvent -FilterHashtable @{LogName="System"; ProviderName=$provider; Level=1,2,3; StartTime=(Get-Date).AddDays(-14)} -MaxEvents 10 -ErrorAction Stop
            }
            catch {}
        }

        $wheaEvents = @($hardwareEvents | Where-Object { $_.ProviderName -eq "Microsoft-Windows-WHEA-Logger" })

        if($wheaEvents.Count -gt 0){
            Add-CSIQuickFinding ([ref]$findings) "Hardware" "WHEA Events" "Critical" "$($wheaEvents.Count) WHEA warning/error event(s) found in the last 14 days." "Open Hardware Health Diagnostics. Update BIOS/firmware/chipset/storage drivers and run OEM diagnostics."
        }
        elseif($hardwareEvents.Count -gt 0){
            Add-CSIQuickFinding ([ref]$findings) "Hardware" "Hardware Driver Events" "Warning" "$($hardwareEvents.Count) hardware/driver warning or error event(s) found in the last 14 days." "Open Hardware Health Diagnostics and review the newest provider events."
        }
        else{
            Add-CSIQuickFinding ([ref]$findings) "Hardware" "Hardware Events" "OK" "No recent common hardware/driver warning, error, or critical events found."
        }

    }
    catch {
        Add-CSIQuickFinding ([ref]$findings) "Hardware" "Hardware Events" "Info" "Unable to evaluate recent hardware events." "Open Event Viewer System log and check WHEA, Kernel-PnP, disk, and storage providers."
    }

    try {

        $crashEvents = @()
        $crashEvents += Get-WinEvent -FilterHashtable @{LogName="System"; Id=1001; StartTime=(Get-Date).AddDays(-14)} -MaxEvents 10 -ErrorAction SilentlyContinue
        $crashEvents += Get-WinEvent -FilterHashtable @{LogName="Application"; Id=1000,1001; StartTime=(Get-Date).AddDays(-14)} -MaxEvents 10 -ErrorAction SilentlyContinue

        if($crashEvents.Count -gt 0){
            Add-CSIQuickFinding ([ref]$findings) "Crashes" "Recent WER/Bugcheck Events" "Warning" "$($crashEvents.Count) crash or WER events found in the last 14 days." "Open Minidump Collector And Analyzer or BlueScreenView to inspect crash history."
        }
        else{
            Add-CSIQuickFinding ([ref]$findings) "Crashes" "Recent WER/Bugcheck Events" "OK" "No recent WER or bugcheck events found."
        }

    }
    catch {
        Add-CSIQuickFinding ([ref]$findings) "Crashes" "Recent WER/Bugcheck Events" "Info" "Unable to evaluate crash events." "Rerun elevated or inspect Reliability Monitor/Event Viewer."
    }

    try {

        if(Get-Command Get-CSIDumpFiles -ErrorAction SilentlyContinue){
            $dumps = @(Get-CSIDumpFiles | Select-Object -First 5)

            if($dumps.Count -gt 0){
                Add-CSIQuickFinding ([ref]$findings) "Crashes" "Dump Files" "Warning" "$($dumps.Count) recent dump files found. Latest: $($dumps[0].FullName)" "Run Minidump Collector And Analyzer and review the newest dump."
            }
            else{
                Add-CSIQuickFinding ([ref]$findings) "Crashes" "Dump Files" "OK" "No dump files found in common locations."
            }
        }

    }
    catch {}

    try {

        $os = Get-CimInstance Win32_OperatingSystem
        $freeMemoryPct = if($os.TotalVisibleMemorySize -gt 0){[math]::Round(($os.FreePhysicalMemory / $os.TotalVisibleMemorySize) * 100,1)}else{100}

        if($freeMemoryPct -lt 10){
            Add-CSIQuickFinding ([ref]$findings) "Resources" "Available Memory" "Warning" "$freeMemoryPct% physical memory free." "Open Resource Hotspots, Process Explorer, or RAMMap to identify memory pressure."
        }
        else{
            Add-CSIQuickFinding ([ref]$findings) "Resources" "Available Memory" "OK" "$freeMemoryPct% physical memory free."
        }

    }
    catch {
        Add-CSIQuickFinding ([ref]$findings) "Resources" "Available Memory" "Info" "Unable to evaluate memory pressure." "Open Task Manager or Resource Hotspots manually."
    }

    try {

        $printers = @()

        if(Get-Command Get-Printer -ErrorAction SilentlyContinue){
            $printers = @(Get-Printer -ErrorAction SilentlyContinue)
        }

        if($printers.Count -gt 0){

            $spooler = Get-Service Spooler -ErrorAction SilentlyContinue

            if(!$spooler -or $spooler.Status -ne "Running"){
                Add-CSIQuickFinding ([ref]$findings) "Print" "Spooler" "Warning" "Printers exist but spooler is $($spooler.Status)." "Open Print Queue Tools and check spooler state and stuck jobs."
            }
            else{
                Add-CSIQuickFinding ([ref]$findings) "Print" "Spooler" "OK" "Spooler running with $($printers.Count) printer(s)."
            }

        }

    }
    catch {}

    return $findings

}

function Global:Add-CSIQuickStatusChecksToReport {

param([pscustomobject]$Report)

    $quickChecks = @(Get-CSIQuickStatusChecks -BaseReport $Report)
    $combinedHealth = Add-CSIQuickTipsToFindings (@($Report.Health) + $quickChecks)
    $problems = @($combinedHealth | Where-Object {$_.Status -in @("Critical","Warning")})
    $summary = Get-CSITriageSummary -Health $combinedHealth

    $Report.Health = $combinedHealth
    $Report.Problems = $problems
    $Report.Summary = $summary
    $Report.RepairDisposition = "Diagnostic-only scan. DISM CheckHealth was allowed; DISM ScanHealth, RestoreHealth, and SFC were not run. If servicing corruption or system file damage is suspected, run Windows Health Diagnostics > DISM/SFC Repair Path as a separate remediation task."

    return $Report

}

function Global:Invoke-QuickDiagnosis {

param(
    [string]$Target = "www.microsoft.com"
)

    Clear-Host

    Write-Host ""
    Write-Host "QUICK DIAGNOSIS" -ForegroundColor Cyan
    Write-Host "===============" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "Running one-click live diagnosis."
    Write-Host "Fast diagnostic checks will run. Repair actions will not run."
    Write-Host "DISM CheckHealth is included. DISM ScanHealth, RestoreHealth, and SFC are skipped."
    Write-Host "A report will be exported when the scan completes."
    Write-Host ""

    $report = Invoke-FullComputerTriage `
        -Target $Target `
        -SkipRepair `
        -PassThru

    if($report){

        try {
            if($report.Fingerprint -and (Get-Command Save-CSIComputerFingerprint -ErrorAction SilentlyContinue)){
                $fingerprintData = Save-CSIComputerFingerprint -Fingerprint $report.Fingerprint
                $fingerprintExports = Save-CSIComputerFingerprint -Fingerprint $report.Fingerprint -OutputRoot $CSIPaths.Exports -Prefix "computer-profile" -Timestamped
                $fingerprintExports | Add-Member -MemberType NoteProperty -Name DataJson -Value $fingerprintData.Json -Force
                $fingerprintExports | Add-Member -MemberType NoteProperty -Name DataHtml -Value $fingerprintData.Html -Force
                $report | Add-Member -MemberType NoteProperty -Name FingerprintExports -Value $fingerprintExports -Force

                Write-Host ""
                Write-Host "Computer profile output JSON:" $fingerprintExports.Json -ForegroundColor Green
                Write-Host "Computer profile output HTML:" $fingerprintExports.Html -ForegroundColor Green
                Write-Host "Computer profile saved for selector:" $fingerprintData.Json -ForegroundColor Green
            }

            $report = Add-CSIQuickStatusChecksToReport -Report $report
            $htmlPath = Export-CSIQuickDiagnosisHtml -Report $report -OutputRoot $CSIPaths.Exports

            Write-Host ""
            Write-Host "Quick Diagnosis summary:" $htmlPath -ForegroundColor Green
        }
        catch {
            Write-Host ""
            Write-Host "Unable to create the Quick Diagnosis HTML summary." -ForegroundColor Red
            Write-Host $_.Exception.Message
        }

    }

}

Register-CSICommand `
    -Name "Quick Diagnosis" `
    -Command "Invoke-QuickDiagnosis" `
    -Category "Troubleshooting" `
    -Description "One-click live diagnosis report with computer profile, DISM CheckHealth, and remediation guidance" `
    -Order 0 `
    -RequiresAdmin
