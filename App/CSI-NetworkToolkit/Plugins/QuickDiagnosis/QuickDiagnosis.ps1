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
    [object[]]$problems = @($Report.Problems)
    [object[]]$checks = @($Report.Health)
    $fingerprint = $Report.Fingerprint
    $overallClass = if($Report.Summary.Critical -gt 0){"critical"}elseif($Report.Summary.Warning -gt 0){"warning"}else{"ok"}
    $overallText = if($Report.Summary.Critical -gt 0){"Immediate attention needed"}elseif($Report.Summary.Warning -gt 0){"Issues found"}else{"No major issues found"}
    [object[]]$deepDives = if($Report.PSObject.Properties.Name -contains "DeepDives"){ @($Report.DeepDives) }else{ @() }
    $usedDeepDives = @{}

    $problemRows = if($problems.Count -gt 0){
        @(for($problemIndex = 0; $problemIndex -lt $problems.Count; $problemIndex++){
            $problem = $problems[$problemIndex]
            $deepDive = $null

            if($problemIndex -lt $deepDives.Count){
                $deepDive = $deepDives[$problemIndex]
                $usedDeepDives[$problemIndex] = $true
            }

            if(!$deepDive){
                for($deepIndex = 0; $deepIndex -lt $deepDives.Count; $deepIndex++){
                    if($usedDeepDives.ContainsKey($deepIndex)){
                        continue
                    }

                    $candidate = $deepDives[$deepIndex]
                    $candidateArea = [string]$candidate.Area
                    $problemArea = [string]$problem.Area
                    $sameArea = $candidateArea -eq $problemArea
                    $windowsSystemMatch = $candidateArea -eq "Windows" -and $problemArea -in @("System","System Image","Event Logs")

                    if(($sameArea -or $windowsSystemMatch) -and [string]$candidate.Severity -eq [string]$problem.Status){
                        $deepDive = $candidate
                        $usedDeepDives[$deepIndex] = $true
                        break
                    }
                }
            }

            $deepDiveHtml = ""
            $recommendedAction = [string]$problem.Tip
            if($deepDive){
                $candidateDriverHtml = if($deepDive.CandidateDriver){
                    "<div class='wide'><span>Candidate Driver</span><p>$(Convert-CSIHtml $deepDive.CandidateDriver)</p></div>"
                }
                else{
                    ""
                }

                $deepDiveHtml = "<div class='finding-detail'><div class='finding-subhead'>Deeper Investigation</div><div class='finding-body investigation-grid'><div><span>Confidence</span><p>$(Convert-CSIHtml $deepDive.Confidence)</p></div><div><span>Evidence</span><p>$(Convert-CSIHtml $deepDive.Evidence)</p></div><div><span>Impact</span><p>$(Convert-CSIHtml $deepDive.WhyItMatters)</p></div><div><span>Best Next Action</span><p>$(Convert-CSIHtml $deepDive.RecommendedAction)</p></div>$candidateDriverHtml</div></div>"
                if($deepDive.RecommendedAction){
                    $recommendedAction = [string]$deepDive.RecommendedAction
                }
            }

            $supportingEvidence = @($problem.Detail,$problem.Explanation) | Where-Object { $_ } | Select-Object -Unique
            "<div class='finding-card'><div class='finding-head'><span class='badge $($problem.Status.ToLower())'>$(Convert-CSIHtml $problem.Status)</span><strong>$(Convert-CSIHtml $problem.Area) - $(Convert-CSIHtml $problem.Check)</strong></div><div class='finding-body problem-grid'><div><span>Supporting Evidence</span><p>$(Convert-CSIHtml ($supportingEvidence -join "`n`n"))</p></div><div><span>Recommended Next Step</span><p>$(Convert-CSIHtml $recommendedAction)</p></div></div>$deepDiveHtml</div>"
        }) -join "`n"
    }
    else{
        "<div class='empty finding-empty'>No critical or warning findings.</div>"
    }

    $checkRows = ($checks | ForEach-Object {
        $status = [string]$_.Status
        $statusClass = $status.ToLower()
        $task = "$($_.Area) - $($_.Check)"

        if($status -eq "OK"){
            "<tr><td><span class='badge ok'>OK</span></td><td>$(Convert-CSIHtml $task)</td><td class='oktext'>Error free</td><td></td></tr>"
        }
        elseif($status -eq "Info"){
            "<tr><td><span class='badge info'>Info</span></td><td>$(Convert-CSIHtml $task)</td><td>$(Convert-CSIHtml $_.Detail)</td><td>$(Convert-CSIHtml $_.Tip)</td></tr>"
        }
        else{
            $evidence = "$($_.Detail) $($_.Explanation)".Trim()
            "<tr><td><span class='badge $statusClass'>$(Convert-CSIHtml $status)</span></td><td>$(Convert-CSIHtml $task)</td><td>$(Convert-CSIHtml $evidence)</td><td>$(Convert-CSIHtml $_.Tip)</td></tr>"
        }
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

    $remediationItems = @(
        $problems |
            ForEach-Object {
                [pscustomobject]@{
                    Key = "{0}|{1}" -f $_.Check,$_.Tip
                    Status = [string]$_.Status
                    Title = "{0} - {1}" -f $_.Area,$_.Check
                    Evidence = [string]$_.Detail
                    Action = [string]$_.Tip
                    Steps = @(Get-CSIQuickRemediationSteps -Finding $_)
                }
            } |
            Group-Object Key |
            ForEach-Object { $_.Group | Select-Object -First 1 } |
            Sort-Object @{ Expression = { switch($_.Status){ "Critical" { 0 }; "Warning" { 1 }; default { 2 } } } }, Title
    )

    $remediationChecklist = if($remediationItems.Count -gt 0){
        (@($remediationItems | ForEach-Object {
            $stepHtml = if(@($_.Steps).Count -gt 0){
                "<ol class='remediation-steps'>" + ((@($_.Steps) | ForEach-Object { "<li>$(Convert-CSIHtml $_)</li>" }) -join "") + "</ol>"
            }
            else{ "" }
            "<li class='remediation-item $($_.Status.ToLower())'><label><input type='checkbox'><span class='badge $($_.Status.ToLower())'>$(Convert-CSIHtml $_.Status)</span><strong>$(Convert-CSIHtml $_.Title)</strong></label><div class='remediation-evidence'><span>Why this was flagged</span>$(Convert-CSIHtml $_.Evidence)</div><p><strong>Recommended action:</strong> $(Convert-CSIHtml $_.Action)</p>$stepHtml</li>"
        }) -join "`n")
    }
    else{
        "<li class='remediation-item ok'><label><input type='checkbox'><span class='badge ok'>OK</span><strong>No remediation is indicated by this scan.</strong></label><p>Continue with the reported user symptom or routine maintenance workflow if one remains.</p></li>"
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
.finding-list { display: grid; gap: 12px; }
.finding-card { background: #fff; border: 1px solid #d9e1e8; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 14px rgba(15,47,74,.05); }
.finding-head { display: flex; align-items: center; gap: 10px; padding: 12px 14px; background: #f6f8fb; border-bottom: 1px solid #e6edf3; color: #102a43; }
.finding-head strong { font-size: 15px; }
.finding-body { display: grid; gap: 14px; padding: 14px; }
.finding-body.problem-grid { grid-template-columns: minmax(0,1.15fr) minmax(0,1fr); }
.finding-body.investigation-grid { grid-template-columns: repeat(2, minmax(0,1fr)); padding-top: 10px; }
.finding-body .wide { grid-column: 1 / -1; }
.finding-body span { display: block; margin-bottom: 5px; color: #66788a; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: .04em; }
.finding-body p { margin: 0; line-height: 1.45; overflow-wrap: anywhere; }
.finding-body p { white-space: pre-line; }
.finding-detail { border-top: 1px solid #e6edf3; background: #fbfcfe; }
.finding-subhead { padding: 12px 14px 0; color: #102a43; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: .04em; }
.finding-empty { background: #fff; border: 1px solid #d9e1e8; border-radius: 8px; padding: 16px; }
.remediation-list { list-style: none; margin: 0; padding: 0; display: grid; gap: 10px; }
.remediation-item { background: #fff; border: 1px solid #d9e1e8; border-left: 5px solid #7b8794; border-radius: 8px; padding: 13px 15px; }
.remediation-item.warning { border-left-color: #b7791f; }
.remediation-item.critical { border-left-color: #b42318; }
.remediation-item.ok { border-left-color: #2e7d32; }
.remediation-item label { display: flex; align-items: center; gap: 10px; cursor: pointer; }
.remediation-item input { width: 16px; height: 16px; accent-color: #1f6fb2; }
.remediation-item strong { color: #102a43; font-size: 15px; }
.remediation-item p { margin: 8px 0 0 27px; line-height: 1.45; overflow-wrap: anywhere; }
.remediation-evidence { margin: 9px 0 0 27px; color: #4b5d6c; line-height: 1.45; overflow-wrap: anywhere; }
.remediation-evidence span { display: block; margin-bottom: 3px; color: #66788a; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: .04em; }
.remediation-steps { margin: 10px 0 0 45px; padding-left: 18px; line-height: 1.5; }
.remediation-steps li { margin: 4px 0; padding-left: 2px; }
table { width: 100%; border-collapse: collapse; table-layout: fixed; background: #fff; border: 1px solid #d9e1e8; border-radius: 8px; overflow: hidden; }
th, td { text-align: left; padding: 10px 12px; border-bottom: 1px solid #e6edf3; vertical-align: top; font-size: 13px; }
td { overflow-wrap: anywhere; word-break: normal; }
th { background: #f6f8fb; color: #425466; font-weight: 650; }
tr:last-child td { border-bottom: none; }
.muted { color: #66788a; font-size: 12px; }
.badge { display: inline-block; min-width: 68px; text-align: center; border-radius: 999px; padding: 3px 9px; font-size: 12px; font-weight: 700; }
.badge.ok { color: #1b5e20; background: #dff3e3; }
.badge.info { color: #174ea6; background: #e1ecff; }
.badge.warning { color: #7a4a00; background: #fff1cc; }
.badge.critical { color: #8a1f11; background: #ffe1dc; }
.empty { color: #66788a; font-style: italic; }
.oktext { color: #137346; font-weight: 650; }
.kv { display: grid; grid-template-columns: 155px 1fr; row-gap: 8px; column-gap: 12px; font-size: 14px; }
.kv div:nth-child(odd) { color: #66788a; }
.footer { color: #66788a; font-size: 12px; margin-top: 24px; }
@media print {
  body { background: #fff; }
  .summary { margin-top: 0; }
  .card { box-shadow: none; }
  .finding-card { box-shadow: none; }
}
@media (max-width: 900px) {
  .finding-body.problem-grid, .finding-body.investigation-grid { grid-template-columns: 1fr; }
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
    <h2>Problems Found</h2>
    <div class="finding-list">
$problemRows
    </div>
  </div>

  <div class="section">
    <h2>All Checks</h2>
    <table>
      <thead><tr><th style="width:90px">Status</th><th style="width:26%">Task</th><th>Result / Supporting Evidence</th><th style="width:30%">Recommended Next Step</th></tr></thead>
      <tbody>
$checkRows
      </tbody>
    </table>
  </div>

  <div class="section">
    <h2>Remediation Checklist</h2>
    <p class="muted">Work from the highest-severity items first. Check each item only after its recommended action has been completed or explicitly ruled out.</p>
    <ul class="remediation-list">
$remediationChecklist
    </ul>
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

function Global:Get-CSIQuickRemediationSteps {

param([pscustomobject]$Finding)

    $area = [string]$Finding.Area
    $check = [string]$Finding.Check
    $detail = [string]$Finding.Detail

    if($area -eq "System" -and $check -eq "Pending Reboot"){
        return @(
            "Confirm there is no active installation, maintenance window restriction, or unsaved user work.",
            "Restart the computer through the approved support process; do not only sign out or shut down with Fast Startup enabled.",
            "After sign-in, rerun Quick Diagnosis and confirm that the Pending Reboot check is clear before starting unrelated repair work."
        )
    }

    if($area -eq "System Image" -or $check -match "DISM|SFC"){
        return @(
            "Run the toolkit elevated and review the DISM CheckHealth result in this report.",
            "If it reports repairable corruption, use Repair > DISM/SFC Repair Path during an approved window; allow DISM and SFC to finish without interruption.",
            "Restart if either repair changes files, then rerun Quick Diagnosis to verify servicing health and the original symptom."
        )
    }

    if($area -eq "Crashes" -and $detail -match '(?i)not retained any \.dmp|no \.dmp files'){
        return @(
            "Open the Crash Event Summary report and Reliability Monitor. Start with events nearest the time the user saw the failure.",
            "Identify repeated application names, faulting modules, providers, or event IDs. Correlate them with recent software, driver, update, security, or hardware changes.",
            "If the problem is a blue screen, confirm Windows Startup and Recovery is configured to write a Small memory dump and that the system drive has free space.",
            "Reproduce or wait for the next failure, run Minidump Collector again, then inspect the collected .dmp with BlueScreenView or WinDbg."
        )
    }

    if($area -eq "Crashes"){
        return @(
            "Run Minidump Collector and keep the collected folder with the incident ticket or technician notes.",
            "Open the newest dump in BlueScreenView or WinDbg and record the bugcheck, probable module, and crash timestamp; do not assume the highlighted driver is automatically the root cause.",
            "Compare the crash time with driver, Windows Update, storage, security, and application events in the Crash Event Summary.",
            "Update, roll back, or remove the implicated component only when the evidence and user symptom agree; rerun Quick Diagnosis after the change."
        )
    }

    if($area -eq "Drivers" -or $check -match "Device Manager|Display Adapter|Hardware Driver Events"){
        return @(
            "Open Device Manager and Event Log Triage. Match the device, provider, service, or event timestamp to the user symptom before changing a driver.",
            "Use the computer manufacturer's support page first for the exact model. Prefer its chipset, storage, network, graphics, and firmware packages over generic driver sites.",
            "Create a restore point or document the current version when a rollback may be needed, then install one relevant driver change at a time.",
            "Restart if requested and rerun Quick Diagnosis. Confirm the event does not recur and the device shows no error status."
        )
    }

    if($area -eq "Services"){
        return @(
            "Open Service Health or Services and verify the service's startup type, dependencies, logon account, and recent System log events.",
            "Determine whether the stopped state is expected for this computer. Some automatic services are trigger-started and should not be forced to run continuously.",
            "If it should run, correct the underlying dependency, configuration, or application issue before starting it; capture the exact error if it fails to start.",
            "Verify the user-facing function, then rerun Quick Diagnosis to make sure the service state and related warnings are resolved."
        )
    }

    if($area -eq "Startup"){
        if($check -eq "Autoruns Missing Files"){
            return @(
                "In Autoruns, use the exact Entry Location, Entry, Autoruns target, and Launch fields shown in the supporting evidence to locate the record. Do not search only by the broad Logon category.",
                "Compare the full launch command with the installed application or approved login script. If the command points to a truly absent executable, record the current entry before changing it.",
                "Disable the one entry first, sign out/sign in or reproduce the affected application behavior, and restore it immediately if it was required.",
                "Delete the entry only after the disabled test succeeds. Rerun Quick Diagnosis and confirm that the exact location/entry no longer appears."
            )
        }
        if($check -eq "Autoruns Command Syntax Review"){
            return @(
                "Open Autoruns and locate the exact Entry Location and Entry shown in the evidence.",
                "Read the entire Launch command. If Autoruns labels a built-in cmd.exe command such as cd, start, set, or call as missing, verify the command before treating it as a broken file path.",
                "Keep the entry when the command is expected for the computer's alternate shell, login automation, or management software. Disable it only when its owner or purpose cannot be confirmed."
            )
        }
        return @(
            "Open Autoruns and locate the exact entry, registry/task location, and launch command named in the supporting evidence.",
            "Confirm whether the command belongs to an installed application, approved login script, or known management component before treating it as stale.",
            "Disable the entry first, test sign-in and the affected application, then delete it only when the owner and impact are understood.",
            "Rerun Quick Diagnosis or Autoruns to confirm the same exact entry no longer appears."
        )
    }

    if($area -in @("Network","Domain","Wi-Fi")){
        return @(
            "Capture the current IP address, gateway, DNS servers, adapter state, and target name before making changes.",
            "Use the matching Network tool to test name resolution, gateway reachability, TCP connectivity, and route behavior; compare results with a known-good computer on the same network.",
            "Correct the lowest-level failure first: physical/Wi-Fi connection, VLAN, IP configuration, DNS, route, firewall, then the target service.",
            "Repeat the original test and document the working result in the incident notes."
        )
    }

    return @(
        "Review the supporting evidence above and confirm that it matches the reported symptom and time of occurrence.",
        "Use the recommended toolkit area to collect a more specific log, event, or configuration view before making a change.",
        "Apply the smallest approved corrective action, test the original symptom, and rerun Quick Diagnosis to verify that the finding clears or is understood."
    )

}

function Global:Get-CSIQuickSysinternalsPath {

param(
    [string[]]$Names
)

    $roots = @()
    if($CSIPaths -and $CSIPaths.Root){
        $roots += Join-Path $CSIPaths.Root "ExternalTools\Sysinternals"
    }

    foreach($root in $roots | Where-Object { $_ -and (Test-Path $_) }){
        foreach($name in $Names){
            $candidate = Join-Path $root $name
            if(Test-Path $candidate){
                return (Resolve-Path $candidate).Path
            }
        }
    }

    foreach($name in $Names){
        $command = Get-Command $name -ErrorAction SilentlyContinue | Select-Object -First 1
        if($command){
            return $command.Source
        }
    }

    return $null

}

function Global:Invoke-CSIQuickExternalCapture {

param(
    [string]$FilePath,
    [string[]]$Arguments = @(),
    [int]$TimeoutSeconds = 12
)

    $result = [pscustomobject]@{
        Path = $FilePath
        Arguments = $Arguments
        TimedOut = $false
        ExitCode = $null
        Output = @()
        Error = ""
    }

    if(!$FilePath -or !(Test-Path $FilePath)){
        $result.Error = "Tool not found."
        return $result
    }

    try {
        if(Get-Command Set-CSISysinternalsEulaAccepted -ErrorAction SilentlyContinue){
            Set-CSISysinternalsEulaAccepted -Path $FilePath
        }

        if(Get-Command Add-CSISysinternalsEulaArgument -ErrorAction SilentlyContinue){
            $Arguments = @(Add-CSISysinternalsEulaArgument -Path $FilePath -Arguments $Arguments)
            $result.Arguments = $Arguments
        }
    }
    catch {}

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $FilePath
    $cleanArguments = @($Arguments | Where-Object { $null -ne $_ -and $_ -ne "" } | ForEach-Object { [string]$_ })
    if($cleanArguments.Count -gt 0){
        if(Get-Command Join-CSICommandLine -ErrorAction SilentlyContinue){
            $psi.Arguments = Join-CSICommandLine -Parts $cleanArguments
        }
        else{
            $psi.Arguments = (($cleanArguments | ForEach-Object {
                if($_ -match '[\s"]'){ '"' + ($_.Replace('"','\"')) + '"' }else{ $_ }
            }) -join " ")
        }
    }
    $psi.WorkingDirectory = Split-Path -Parent $FilePath
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi

    try {
        [void]$process.Start()
        if(!$process.WaitForExit([Math]::Max(1,$TimeoutSeconds) * 1000)){
            $result.TimedOut = $true
            try { $process.Kill() } catch {}
        }

        $stdout = $process.StandardOutput.ReadToEnd()
        $stderr = $process.StandardError.ReadToEnd()
        if(!$result.TimedOut){
            $result.ExitCode = $process.ExitCode
        }

        $result.Output = @($stdout -split "`r?`n" | Where-Object { $_ -and $_.Trim() })
        $result.Error = ($stderr -split "`r?`n" | Where-Object { $_ -and $_.Trim() }) -join " "
    }
    catch {
        $result.Error = $_.Exception.Message
    }
    finally {
        try { $process.Dispose() } catch {}
    }

    return $result

}

function Global:Get-CSIQuickSysinternalsEvidence {

    $evidence = [ordered]@{
        CollectedAt = (Get-Date).ToString("s")
        Autoruns = $null
        Coreinfo = $null
        LoggedOnUsers = $null
        LogonSessions = $null
    }

    $autorunsc = Get-CSIQuickSysinternalsPath -Names @("autorunsc64.exe","autorunsc.exe")
    if($autorunsc){
        $capture = Invoke-CSIQuickExternalCapture -FilePath $autorunsc -Arguments @("-accepteula","-nobanner","-m","-c") -TimeoutSeconds 10
        $rows = @()
        if($capture.Output.Count -gt 1){
            try {
                $rows = @($capture.Output | ConvertFrom-Csv -ErrorAction Stop)
            }
            catch {}
        }

        $unsignedAll = @($rows | Where-Object {
            $verified = [string]($_.Verified)
            $publisher = [string]($_.Publisher)
            $imagePath = [string]($_.'Image Path')
            $imagePath -and
            $verified -notmatch '(?i)verified' -and
            $publisher -notmatch '(?i)^Microsoft'
        })
        $unsigned = @($unsignedAll | Select-Object -First 20)

        $missingAll = @($rows | Where-Object {
            $imagePath = [string]($_.'Image Path')
            $imagePath -match '(?i)file not found|not found|missing'
        })
        $commandSyntaxRows = @($missingAll | Where-Object {
            $imagePath = [string]($_.'Image Path')
            $launchString = [string]($_.'Launch String')
            $imagePath -match '(?i)^file not found:\s*(cd|dir|echo|set|start|call|if|for)\b' -and
            $launchString -match '(?i)\bcmd(?:\.exe)?\b'
        })
        $missingDefinite = @($missingAll | Where-Object { $commandSyntaxRows -notcontains $_ })
        $missing = @($missingDefinite | Select-Object -First 20)
        $commandSyntax = @($commandSyntaxRows | Select-Object -First 20)

        $evidence.Autoruns = [pscustomobject]@{
            ToolPath = $autorunsc
            TimedOut = $capture.TimedOut
            ExitCode = $capture.ExitCode
            EntriesChecked = $rows.Count
            UnsignedOrUnverifiedCount = $unsignedAll.Count
            MissingFileCount = $missingDefinite.Count
            CommandSyntaxReviewCount = $commandSyntaxRows.Count
            UnsignedOrUnverified = @($unsigned | ForEach-Object {
                [pscustomobject]@{
                    Entry = $_.Entry
                    Category = $_.Category
                    Publisher = $_.Publisher
                    ImagePath = $_.'Image Path'
                    Verified = $_.Verified
                }
            })
            MissingFiles = @($missing | ForEach-Object {
                [pscustomobject]@{
                    Entry = $_.Entry
                    EntryLocation = $_.'Entry Location'
                    Category = $_.Category
                    ImagePath = $_.'Image Path'
                    LaunchString = $_.'Launch String'
                }
            })
            CommandSyntaxReviews = @($commandSyntax | ForEach-Object {
                [pscustomobject]@{
                    Entry = $_.Entry
                    EntryLocation = $_.'Entry Location'
                    Category = $_.Category
                    ImagePath = $_.'Image Path'
                    LaunchString = $_.'Launch String'
                }
            })
            Error = $capture.Error
        }
    }

    $coreinfo = Get-CSIQuickSysinternalsPath -Names @("coreinfo64.exe","coreinfo.exe")
    if($coreinfo){
        $capture = Invoke-CSIQuickExternalCapture -FilePath $coreinfo -Arguments @("-accepteula","-nobanner") -TimeoutSeconds 8
        $text = ($capture.Output -join " ")
        $evidence.Coreinfo = [pscustomobject]@{
            ToolPath = $coreinfo
            TimedOut = $capture.TimedOut
            ExitCode = $capture.ExitCode
            VirtualizationLines = @($capture.Output | Where-Object { $_ -match '(?i)hypervisor|vmx|svm|ept|npt|virtualization' } | Select-Object -First 12)
            HypervisorMentioned = ($text -match '(?i)hypervisor')
            Error = $capture.Error
        }
    }

    $psloggedon = Get-CSIQuickSysinternalsPath -Names @("PsLoggedon64.exe","PsLoggedon.exe","psloggedon64.exe","psloggedon.exe")
    if($psloggedon){
        $capture = Invoke-CSIQuickExternalCapture -FilePath $psloggedon -Arguments @("-accepteula","-nobanner","-l") -TimeoutSeconds 8
        $userLines = @($capture.Output | Where-Object { $_ -match '\\' -and $_ -notmatch '(?i)^users logged on' } | Select-Object -First 20)
        $evidence.LoggedOnUsers = [pscustomobject]@{
            ToolPath = $psloggedon
            TimedOut = $capture.TimedOut
            ExitCode = $capture.ExitCode
            Users = $userLines
            Error = $capture.Error
        }
    }

    $logonsessions = Get-CSIQuickSysinternalsPath -Names @("logonsessions64.exe","logonsessions.exe")
    if($logonsessions){
        $capture = Invoke-CSIQuickExternalCapture -FilePath $logonsessions -Arguments @("-accepteula","-nobanner") -TimeoutSeconds 8
        $sessionLines = @($capture.Output | Where-Object { $_ -match '(?i)logon session|user name|auth package|logon type' } | Select-Object -First 40)
        $evidence.LogonSessions = [pscustomobject]@{
            ToolPath = $logonsessions
            TimedOut = $capture.TimedOut
            ExitCode = $capture.ExitCode
            SessionSummary = $sessionLines
            Error = $capture.Error
        }
    }

    return [pscustomobject]$evidence

}

function Global:Add-CSIQuickSysinternalsFindings {

param(
    [ref]$Findings,
    [pscustomobject]$BaseReport
)

    $evidence = Get-CSIQuickSysinternalsEvidence

    function Format-CSIQuickAutorunsRow {
    param([object]$Row)

        if(!$Row){
            return ""
        }

        $category = [string]$Row.Category
        $entry = [string]$Row.Entry
        $location = [string]$Row.EntryLocation
        $path = [string]$Row.ImagePath
        $launch = [string]$Row.LaunchString
        $publisher = [string]$Row.Publisher

        $parts = @()
        if($category){ $parts += "Category=$category" }
        if($location){ $parts += "Location=$location" }
        if($entry -and $entry -notmatch '^\d+$'){ $parts += $entry }
        elseif($entry){ $parts += "Entry=$entry" }
        if($publisher){ $parts += "Publisher=$publisher" }
        if($path){ $parts += "Autoruns target=$path" }
        if($launch){ $parts += "Launch=$launch" }

        return ($parts -join ": ")
    }

    if($BaseReport){
        $BaseReport | Add-Member -MemberType NoteProperty -Name SysinternalsEvidence -Value $evidence -Force
        if($BaseReport.Fingerprint){
            $BaseReport.Fingerprint | Add-Member -MemberType NoteProperty -Name SysinternalsEvidence -Value $evidence -Force
        }
    }

    if($evidence.Autoruns){
        $autoruns = $evidence.Autoruns
        if($autoruns.TimedOut){
            Add-CSIQuickFinding $Findings "Startup" "Autoruns" "Info" "Autorunsc did not finish within the quick diagnosis timeout. Partial startup evidence may still be available in the Computer Profile." "Use the Autoruns button for deeper startup and persistence review if symptoms point to startup, malware, or logon slowness."
        }
        elseif($autoruns.MissingFileCount -gt 0){
            $detail = (($autoruns.MissingFiles | Select-Object -First 5 | ForEach-Object { Format-CSIQuickAutorunsRow $_ }) -join "; ")
            Add-CSIQuickFinding $Findings "Startup" "Autoruns Missing Files" "Warning" "$($autoruns.MissingFileCount) definite startup/persistence file path(s) are missing. Exact affected entries: $detail" "In Autoruns, locate each exact entry/location listed above. Confirm its application was intentionally removed or the path is truly absent, then disable the entry first and test before deleting it."
        }
        elseif($autoruns.CommandSyntaxReviewCount -gt 0){
            $detail = (($autoruns.CommandSyntaxReviews | Select-Object -First 5 | ForEach-Object { Format-CSIQuickAutorunsRow $_ }) -join "; ")
            Add-CSIQuickFinding $Findings "Startup" "Autoruns Command Syntax Review" "Info" "Autoruns could not resolve $($autoruns.CommandSyntaxReviewCount) command-style startup target(s), but it did not find a definite missing executable. Exact entry: $detail" "Review the exact location and launch command in Autoruns. The reported target may be a built-in cmd.exe command rather than a missing file. Keep it unless the alternate-shell or startup command is unexpected for this computer."
        }
        elseif($autoruns.UnsignedOrUnverifiedCount -gt 0){
            $detail = (($autoruns.UnsignedOrUnverified | Select-Object -First 5 | ForEach-Object { Format-CSIQuickAutorunsRow $_ }) -join "; ")
            Add-CSIQuickFinding $Findings "Startup" "Autoruns Verification" "Warning" "$($autoruns.UnsignedOrUnverifiedCount) non-Microsoft startup/persistence entries are unsigned or unverified. $detail" "Open Autoruns and Sigcheck. Verify the publisher and path before disabling anything; replace suspicious software from a trusted vendor source."
        }
        else{
            Add-CSIQuickFinding $Findings "Startup" "Autoruns" "OK" "Autorunsc checked $($autoruns.EntriesChecked) startup/persistence entries without missing paths or unverified non-Microsoft entries in the quick scan."
        }
    }
    else{
        Add-CSIQuickFinding $Findings "Startup" "Autoruns" "Info" "Autorunsc was not found in Sysinternals." "Install or restore Sysinternals Autoruns if startup/persistence evidence should be included in Quick Diagnosis."
    }

    if($evidence.Coreinfo){
        $coreinfo = $evidence.Coreinfo
        if($coreinfo.TimedOut){
            Add-CSIQuickFinding $Findings "Hardware" "Coreinfo" "Info" "Coreinfo did not finish within the quick diagnosis timeout." "Use Coreinfo manually if CPU virtualization or hypervisor feature details are needed."
        }
        elseif($coreinfo.HypervisorMentioned){
            Add-CSIQuickFinding $Findings "Virtualization" "Coreinfo" "Info" "Coreinfo output indicates hypervisor/virtualization context. $((@($coreinfo.VirtualizationLines) | Select-Object -First 4) -join '; ')" "For VM hardware, validate disk, CPU, memory, and drivers at the hypervisor layer when guest-only evidence is inconclusive."
        }
        else{
            Add-CSIQuickFinding $Findings "Hardware" "Coreinfo" "OK" "Coreinfo ran successfully. No hypervisor-specific warning was detected in the quick scan."
        }
    }

    if($evidence.LoggedOnUsers){
        $users = @($evidence.LoggedOnUsers.Users)
        if($users.Count -gt 0){
            Add-CSIQuickFinding $Findings "User Sessions" "Logged On Users" "Info" "PsLoggedOn found local logged-on user context: $($users -join '; ')" "Use this to confirm whether the active user context matches the reported issue. For profile or lock issues, check the listed user sessions before rebooting."
        }
        elseif($evidence.LoggedOnUsers.TimedOut){
            Add-CSIQuickFinding $Findings "User Sessions" "Logged On Users" "Info" "PsLoggedOn did not finish within the quick diagnosis timeout." "Use PsLoggedOn manually if remote/local session context matters."
        }
        else{
            Add-CSIQuickFinding $Findings "User Sessions" "Logged On Users" "OK" "PsLoggedOn did not return extra local logged-on users."
        }
    }

    return $evidence

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

    if($area -eq "Drivers"){
        if($check -eq "Unsigned Drivers"){
            return "Open Sigcheck or Device Manager and verify the listed drivers. Replace unknown, unsigned, or suspicious drivers with vendor-signed packages."
        }
        if($check -eq "Recent Driver Events"){
            return "Open Event Log Triage and Device Manager. If symptoms started recently, focus on repeated device, provider, or driver names."
        }
        if($check -eq "Recently Dated Drivers"){
            return "Compare the listed drivers with recent updates or vendor installs. Roll back or update only if symptoms match."
        }
        return "Use Device Manager, vendor tools, or Sigcheck to review the listed driver evidence before changing drivers."
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

    if($area -eq "Startup"){
        if($check -eq "Autoruns Missing Files"){
            return "In Autoruns, locate the exact registry/task location, entry name, reported target, and launch command shown in Supporting Evidence. Disable the entry first; delete it only if the command truly points to an intentionally removed application."
        }
        if($check -eq "Autoruns Command Syntax Review"){
            return "Review the exact Autoruns location and full launch command. A cmd.exe built-in such as cd /d can look like a missing file to Autoruns even though no executable is absent."
        }
        if($check -eq "Autoruns Verification"){
            return "Open Autoruns and Sigcheck. Confirm publisher, path, and business need before disabling startup entries."
        }
        return "Open Autoruns for deeper startup, scheduled task, service, driver, and logon persistence review."
    }

    if($area -eq "User Sessions"){
        return "Use the listed session context to confirm whether the affected user is currently logged on. Check profile/session state before rebooting or killing processes."
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

function Global:Get-CSIQuickPlainExplanation {

param([pscustomobject]$Finding)

    $area = [string]$Finding.Area
    $check = [string]$Finding.Check
    $status = [string]$Finding.Status
    $detail = if($null -ne $Finding.Detail){ [string]$Finding.Detail } else { "" }

    if($status -eq "OK"){
        switch("$area|$check"){
            "Hardware|Device Manager" { return "Windows does not currently report any present devices with driver or hardware errors." }
            "Hardware|SMART Failure Prediction" { return "Windows storage drivers are not predicting a disk failure. This is a quick signal, not a full vendor diagnostic." }
            "Hardware|Hardware Events" { return "Windows did not log recent common hardware or driver warnings in the checked event providers." }
            "Hardware|Display Adapter" { return "Windows sees the display adapter and driver without an obvious problem status." }
            "Power|Battery Status" { return "Battery information is present and Windows is not reporting an obvious battery fault." }
            "Security|TPM" { return "TPM is present and usable. This supports BitLocker, Windows Hello, and device security features." }
            "Security|Secure Boot" { return "Secure Boot is enabled, which helps protect the boot chain from tampering." }
            "Security|BitLocker" { return "Fixed data volumes appear protected where BitLocker information is available." }
            "Licensing|Windows Activation" { return "Windows reports that it is activated." }
            "Drivers|Unsigned Drivers" { return "Important non-Microsoft drivers in the checked classes appear signed or at least do not show an obvious unsigned state." }
            "Drivers|Recent Driver Events" { return "Windows did not log recent driver or device warnings/errors in the checked driver event providers." }
            "Drivers|Recently Dated Drivers" { return "No important third-party drivers have very recent driver dates. This makes a fresh driver package a less likely suspect." }
            "Drivers|Driver Age" { return "No old third-party drivers were found in the checked hardware classes." }
            "Startup|Autoruns" { return "Startup and persistence entries checked by Autorunsc did not show missing paths or unverified non-Microsoft entries in the quick scan." }
            "User Sessions|Logged On Users" { return "The quick session check did not find extra logged-on user context that needs attention." }
            default { return "This check did not find a problem." }
        }
    }

    if($status -eq "Info"){
        if($area -eq "Power" -and $check -eq "Battery Status"){
            return "No battery data usually means this is a desktop, server, or virtual machine. It is not a problem by itself."
        }
        if($area -eq "Hardware" -and $check -eq "SMART Failure Prediction"){
            return "Windows could not read SMART failure-prediction data. This is common on virtual disks, RAID/controllers, USB bridges, and some storage drivers."
        }
        if($area -eq "Hardware" -and $check -eq "Storage Visibility"){
            return "The system is virtualized or abstracts storage. Guest tools may not see the real physical disk health, so host or storage-platform checks matter more."
        }
        if($area -eq "Hardware" -and $check -eq "Driver Age"){
            return "Driver age is only a clue. Older non-Microsoft hardware drivers are worth reviewing when symptoms match; Microsoft in-box drivers are ignored for this check."
        }
        if($area -eq "Security" -and $check -eq "TPM"){
            return "TPM is not clearly available to Windows. On VMs this may simply mean virtual TPM is not enabled."
        }
        if($area -eq "Security" -and $check -eq "Secure Boot"){
            return "Secure Boot could not be confirmed. This can be normal on VMs, legacy boot systems, or when the check lacks required permissions."
        }
        if($area -eq "Startup"){
            if($check -eq "Autoruns Command Syntax Review"){
                return "Autoruns could not resolve part of a startup command as a file. The evidence shows the exact registry location, entry, and full launch command so the technician can verify whether it is legitimate cmd.exe syntax or an unexpected startup modification."
            }
            return "Startup evidence was partially collected or the helper tool was unavailable. This is not automatically a problem, but it limits the quick startup review."
        }
        if($area -eq "User Sessions"){
            return "Logged-on user context can help explain profile, lock, app, and reboot complaints. This is supporting information, not usually an issue by itself."
        }
    }

    if($area -eq "Services"){
        if($check -eq "Stopped Automatic Services"){
            return "One or more services configured to start automatically are currently stopped. Some services stop when idle, but unexpected stopped services can break networking, logon, printing, updates, or management features."
        }

        return "The $check service is not in the expected running state. This can be normal for some services, but core services should be checked when symptoms match."
    }

    if($area -eq "System" -and $check -eq "Pending Reboot"){
        return "Windows has queued changes that require a restart. Updates, driver installs, file replacements, or servicing work may not finish until the machine reboots."
    }

    if($area -eq "System Image" -and $check -eq "DISM CheckHealth"){
        $detailLower = $detail.ToLowerInvariant()
        if($detailLower.Contains("elevated permissions") -or $detailLower.Contains("access is denied") -or $detailLower.Contains("error: 740") -or $detailLower.Contains("error 740")){
            return "The toolkit could not complete the servicing health check because it was not running with enough rights. This does not prove Windows is damaged; it means the check needs elevation."
        }

        return "DISM CheckHealth is the fast Windows component-store health check. If it reports corruption or cannot complete cleanly, Windows repair steps may be needed."
    }

    if($area -eq "Event Logs" -and $check -eq "Last 24 Hours"){
        return "Windows logged multiple recent errors or critical events. This does not always mean the computer is broken, but repeated recent errors are useful clues and should be grouped by provider and time."
    }

    if($area -eq "Crashes"){
        return "Windows recorded application crashes, Windows Error Reporting events, or bugcheck evidence. The next useful step is to identify whether the same app, driver, or module keeps appearing."
    }

    if($area -eq "Time"){
        if($detail -match '(?i)access is denied|0x80070005'){
            return "The toolkit could not query or verify time sync because Windows denied access. Time problems can break domain logons, Kerberos, certificates, and secure connections."
        }

        return "Windows time sync is not reporting a clean state. Incorrect time can cause domain, authentication, certificate, and update problems."
    }

    if($area -eq "Network"){
        if($check -match '(?i)gateway'){
            return "The computer may not be able to reach its default gateway. If true, local network access will fail before internet or DNS troubleshooting matters."
        }
        if($check -match '(?i)dns'){
            return "Name resolution may be unhealthy. DNS issues can make the network look down even when raw IP connectivity works."
        }
        if($check -match '(?i)https|internet|target'){
            return "The computer had trouble reaching the test target. This points toward routing, firewall, proxy, DNS, or upstream connectivity."
        }
        return "A network health check returned a warning. Use the detail column to decide whether this is adapter, gateway, DNS, or target reachability."
    }

    if($area -eq "Domain"){
        return "Domain health is not clean. This can affect logons, mapped drives, Group Policy, Kerberos, and access to domain resources."
    }

    if($area -eq "Firewall"){
        return "Firewall profile or exposure settings may not match the network role. This can block expected access or expose services on the wrong network."
    }

    if($area -eq "Virtualization"){
        return "The toolkit believes this machine is virtualized. Some hardware tools and SMART checks may show limited data because the hypervisor abstracts the real hardware."
    }

    if($area -eq "Hardware" -and $check -eq "Display Adapter"){
        return "A graphics adapter or display driver looks unhealthy, very old, or incomplete. On servers and VMs this may be normal; on workstations it can explain display glitches, poor performance, or app rendering problems."
    }

    if($area -eq "Hardware" -and $check -eq "Storage Visibility"){
        return "Windows could not expose full physical disk health details. This commonly happens on virtual machines, RAID controllers, USB bridges, and some vendor storage stacks."
    }

    if($area -eq "Hardware" -and $check -eq "Driver Age"){
        return "One or more important device drivers look old enough to be worth reviewing. Old drivers are not automatically bad, but they are common suspects for instability and hardware symptoms."
    }

    if($area -eq "Drivers"){
        if($check -eq "Unsigned Drivers"){
            return "A non-Microsoft driver is unsigned or Windows could not verify its signature. That can be normal for old/internal drivers, but it is also a trust and stability signal worth reviewing."
        }
        if($check -eq "Recent Driver Events"){
            return "Windows logged recent driver or device warnings/errors. Repeated events around the same device often point to a bad driver, failing hardware, or a device that cannot start cleanly."
        }
        if($check -eq "Recently Dated Drivers"){
            return "A driver has a recent driver date. This does not prove it was just installed, but it is a useful clue when issues started after updates or vendor software changes."
        }
        if($check -eq "Driver Age"){
            return "Older third-party drivers are not automatically wrong, but they are worth reviewing when the device is unstable or symptoms match that hardware class."
        }
        return "Driver evidence was collected because drivers commonly cause hardware, network, crash, and performance issues."
    }

    if($area -eq "Firmware" -and $check -eq "BIOS Age"){
        return "The BIOS/firmware appears old. Firmware updates can resolve hardware compatibility, stability, storage, and security issues, but should be planned carefully."
    }

    if($area -eq "Power" -and $check -eq "Battery Status"){
        return "Windows is reporting a battery condition that may affect runtime, charging, or device reliability."
    }

    if($area -eq "Security" -and $check -eq "TPM"){
        return "TPM is missing, disabled, or not usable. On some VMs this is expected unless virtual TPM is enabled."
    }

    if($area -eq "Security" -and $check -eq "Secure Boot"){
        return "Secure Boot is off, unavailable, or could not be checked. On some VMs this depends on VM generation and firmware settings."
    }

    if($area -eq "Security" -and $check -eq "BitLocker"){
        return "At least one fixed volume does not appear protected. That may be expected on lab systems, but it matters for laptops and systems with sensitive data."
    }

    if($area -eq "Licensing" -and $check -eq "Windows Activation"){
        return "Windows is not reporting a clean activated state. This can cause user-facing activation warnings and may indicate licensing or KMS/domain reachability issues."
    }

    if($area -eq "Disk" -and $check -eq "Physical Disk Health"){
        return "Windows reported a non-healthy physical disk state. On physical machines, treat this seriously; on VMs, verify whether the warning is from the guest or the host storage layer."
    }

    if($area -eq "Hardware" -and $check -eq "SMART Failure Prediction"){
        return "Windows received a predicted disk failure signal. Virtual machines often cannot provide this data, but if this appears on physical hardware, back up immediately."
    }

    return "This check returned a warning. Use the detail value with the recommended next step to decide whether it matches the reported issue."

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
            Area        = $finding.Area
            Check       = $finding.Check
            Status      = $finding.Status
            Detail      = $finding.Detail
            Explanation = Get-CSIQuickPlainExplanation -Finding $finding
            Tip         = $tip
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

function Global:Test-CSIQuickVirtualMachine {

param([object]$Fingerprint)

    $text = ""
    if($Fingerprint){
        $text = "$($Fingerprint.Manufacturer) $($Fingerprint.Model)"
    }

    return ($text -match '(?i)virtual|vmware|hyper-v|kvm|qemu|xen|virtualbox|parallels|bochs|bhyve')

}

function Global:Get-CSIQuickDriverDate {

param([object]$Driver)

    if(!$Driver -or !$Driver.DriverDate){
        return $null
    }

    try {
        if($Driver.DriverDate -is [datetime]){
            return $Driver.DriverDate
        }

        return [Management.ManagementDateTimeConverter]::ToDateTime($Driver.DriverDate)
    }
    catch {
        try { return [datetime]$Driver.DriverDate } catch { return $null }
    }

}

function Global:Get-CSIQuickDriverInventory {

    $importantClasses = @("Display","Net","SCSIAdapter","HDC","System","MEDIA","Bluetooth","USB","Printer")
    $drivers = @()

    try {
        $drivers = @(
            Get-CimInstance Win32_PnPSignedDriver -ErrorAction Stop |
                Where-Object { $importantClasses -contains $_.DeviceClass } |
                ForEach-Object {
                    $driverDate = Get-CSIQuickDriverDate -Driver $_
                    [pscustomobject]@{
                        DeviceName     = $_.DeviceName
                        DeviceClass    = $_.DeviceClass
                        Provider       = $_.DriverProviderName
                        Version        = $_.DriverVersion
                        DriverDate     = if($driverDate){$driverDate.ToString("yyyy-MM-dd")}else{""}
                        DriverDateRaw  = $driverDate
                        Signed         = if($_.IsSigned -ne $null){[bool]$_.IsSigned}else{ if($_.Signer){"Yes"}else{"Unknown"} }
                        Signer         = $_.Signer
                        InfName        = $_.InfName
                        DeviceID       = $_.DeviceID
                    }
                }
        )
    }
    catch {}

    return @($drivers | Sort-Object DeviceClass,DeviceName)

}

function Global:Get-CSIQuickDriverForDevice {

param(
    [object]$DeviceProblem,
    [object[]]$DriverInventory
)

    if(!$DeviceProblem -or !$DriverInventory){
        return $null
    }

    $ids = @(
        $DeviceProblem.InstanceId
        $DeviceProblem.PNPDeviceID
        $DeviceProblem.DeviceID
    ) | Where-Object { $_ }

    foreach($id in $ids){
        $match = @($DriverInventory | Where-Object { $_.DeviceID -and $_.DeviceID.Equals($id,[System.StringComparison]::OrdinalIgnoreCase) } | Select-Object -First 1)
        if($match.Count -gt 0){
            return $match[0]
        }
    }

    return $null

}

function Global:Add-CSIQuickExtendedComputerChecks {

param(
    [ref]$Findings,
    [pscustomobject]$BaseReport
)

    $fingerprint = if($BaseReport){$BaseReport.Fingerprint}else{$null}
    $isVM = Test-CSIQuickVirtualMachine -Fingerprint $fingerprint
    $driverInventory = Get-CSIQuickDriverInventory

    if($BaseReport){
        $BaseReport | Add-Member -MemberType NoteProperty -Name DriverInventory -Value $driverInventory -Force
    }

    if($isVM){
        Add-CSIQuickFinding $Findings "Virtualization" "Machine Type" "Info" "This appears to be a virtual machine: $($fingerprint.Manufacturer) $($fingerprint.Model)." "Do not rely on guest-only SMART or temperature tools for final hardware health. Check the hypervisor host/storage layer when disk or hardware symptoms are suspected."
    }

    try {
        $video = @(Get-CimInstance Win32_VideoController -ErrorAction Stop)
        if($video.Count -eq 0){
            Add-CSIQuickFinding $Findings "Hardware" "Display Adapter" "Info" "No display adapters were returned by Windows inventory." "If this is a VM or server, this may be normal. If this is a workstation, open Device Manager and GPU-Z/HWiNFO."
        }
        else{
            $badVideo = @($video | Where-Object { $_.ConfigManagerErrorCode -and $_.ConfigManagerErrorCode -ne 0 })
            $displaySummary = (($video | Select-Object -First 3 | ForEach-Object { "$($_.Name) driver $($_.DriverVersion)" }) -join "; ")
            $displayDrivers = @($driverInventory | Where-Object { $_.DeviceClass -eq "Display" })
            $genericPhysicalVideo = @($video | Where-Object { $_.Name -match '(?i)Microsoft Basic Display' })
            if($badVideo.Count -gt 0){
                Add-CSIQuickFinding $Findings "Hardware" "Display Adapter" "Warning" "$($badVideo.Count) display adapter(s) have a Device Manager error. $displaySummary" "Open Device Manager and GPU-Z or HWiNFO. Reinstall or update the display driver if this is a physical workstation."
            }
            elseif(!$isVM -and $genericPhysicalVideo.Count -gt 0){
                $driverText = if($displayDrivers.Count -gt 0){ (($displayDrivers | Select-Object -First 3 | ForEach-Object { "$($_.DeviceName) provider $($_.Provider) version $($_.Version)" }) -join "; ") }else{$displaySummary}
                Add-CSIQuickFinding $Findings "Hardware" "Display Adapter" "Warning" "Physical workstation appears to be using a generic Microsoft display driver. $driverText" "Install the OEM display driver for this exact computer model, or the GPU vendor driver if the OEM package is unavailable."
            }
            else{
                Add-CSIQuickFinding $Findings "Hardware" "Display Adapter" "OK" $displaySummary
            }
        }
    }
    catch {
        Add-CSIQuickFinding $Findings "Hardware" "Display Adapter" "Info" "Unable to inspect display adapters: $($_.Exception.Message)" "Open Device Manager manually if graphics symptoms exist."
    }

    try {
        $bios = Get-CimInstance Win32_BIOS -ErrorAction Stop
        $releaseDate = Get-CSIQuickDriverDate -Driver ([pscustomobject]@{ DriverDate = $bios.ReleaseDate })
        if($releaseDate){
            $ageYears = [math]::Round(((Get-Date) - $releaseDate).TotalDays / 365,1)
            if($ageYears -ge 5){
                Add-CSIQuickFinding $Findings "Firmware" "BIOS Age" "Warning" "BIOS $($bios.SMBIOSBIOSVersion) was released $ageYears years ago." "Check the vendor support page or OEM update utility. Update firmware only during an approved maintenance window."
            }
            else{
                Add-CSIQuickFinding $Findings "Firmware" "BIOS Age" "OK" "BIOS $($bios.SMBIOSBIOSVersion) release date appears about $ageYears years old."
            }
        }
        else{
            Add-CSIQuickFinding $Findings "Firmware" "BIOS Age" "Info" "BIOS release date was not available." "Check vendor firmware manually if hardware symptoms exist."
        }
    }
    catch {
        Add-CSIQuickFinding $Findings "Firmware" "BIOS Age" "Info" "Unable to inspect BIOS information." "Check vendor firmware manually if hardware symptoms exist."
    }

    try {
        $batteries = @(Get-CimInstance Win32_Battery -ErrorAction Stop)
        if($batteries.Count -eq 0){
            Add-CSIQuickFinding $Findings "Power" "Battery Status" "Info" "No battery was detected. This is normal for desktops, servers, and many virtual machines."
        }
        else{
            $bad = @($batteries | Where-Object { $_.BatteryStatus -in @(4,5,6,7,8,9,10,11) })
            $summary = (($batteries | ForEach-Object { "$($_.Name): status $($_.BatteryStatus), estimated charge $($_.EstimatedChargeRemaining)%" }) -join "; ")
            if($bad.Count -gt 0){
                Add-CSIQuickFinding $Findings "Power" "Battery Status" "Warning" $summary "Run powercfg /batteryreport or the OEM diagnostics tool and review battery health."
            }
            else{
                Add-CSIQuickFinding $Findings "Power" "Battery Status" "OK" $summary
            }
        }
    }
    catch {
        Add-CSIQuickFinding $Findings "Power" "Battery Status" "Info" "Unable to inspect battery status." "If this is a laptop with power symptoms, run powercfg /batteryreport."
    }

    try {
        if(Get-Command Get-Tpm -ErrorAction SilentlyContinue){
            $tpm = Get-Tpm
            if($tpm.TpmPresent -and $tpm.TpmReady){
                Add-CSIQuickFinding $Findings "Security" "TPM" "OK" "TPM is present and ready."
            }
            else{
                $status = if($isVM){"Info"}else{"Warning"}
                Add-CSIQuickFinding $Findings "Security" "TPM" $status "TPM present: $($tpm.TpmPresent); TPM ready: $($tpm.TpmReady)." "Enable TPM/vTPM if BitLocker, Windows Hello, or device security requires it."
            }
        }
        else{
            Add-CSIQuickFinding $Findings "Security" "TPM" "Info" "TPM cmdlet is not available." "Check tpm.msc if TPM status matters."
        }
    }
    catch {
        Add-CSIQuickFinding $Findings "Security" "TPM" "Info" "Unable to inspect TPM status." "Check tpm.msc if TPM status matters."
    }

    try {
        if(Get-Command Confirm-SecureBootUEFI -ErrorAction SilentlyContinue){
            $secureBoot = Confirm-SecureBootUEFI -ErrorAction Stop
            if($secureBoot){
                Add-CSIQuickFinding $Findings "Security" "Secure Boot" "OK" "Secure Boot is enabled."
            }
            else{
                $status = if($isVM){"Info"}else{"Warning"}
                Add-CSIQuickFinding $Findings "Security" "Secure Boot" $status "Secure Boot is disabled." "Enable Secure Boot if required by the workstation security baseline."
            }
        }
        else{
            Add-CSIQuickFinding $Findings "Security" "Secure Boot" "Info" "Secure Boot check is not available in this environment." "This is common on legacy BIOS systems and some VMs."
        }
    }
    catch {
        Add-CSIQuickFinding $Findings "Security" "Secure Boot" "Info" "Secure Boot could not be checked: $($_.Exception.Message)" "This is common on legacy BIOS systems and some VMs."
    }

    try {
        if(Get-Command Get-BitLockerVolume -ErrorAction SilentlyContinue){
            $volumes = @(Get-BitLockerVolume -ErrorAction Stop | Where-Object { $_.VolumeType -eq "OperatingSystem" -or $_.MountPoint -match '^[A-Z]:' })
            $unprotected = @($volumes | Where-Object { $_.ProtectionStatus -ne "On" })
            if($volumes.Count -eq 0){
                Add-CSIQuickFinding $Findings "Security" "BitLocker" "Info" "No BitLocker-capable fixed volumes were returned." "Check manage-bde -status if encryption status matters."
            }
            elseif($unprotected.Count -gt 0){
                Add-CSIQuickFinding $Findings "Security" "BitLocker" "Warning" "$($unprotected.Count) fixed volume(s) are not protected by BitLocker." "Enable or resume BitLocker if this system should be encrypted."
            }
            else{
                Add-CSIQuickFinding $Findings "Security" "BitLocker" "OK" "Fixed volumes returned by BitLocker are protected."
            }
        }
    }
    catch {
        Add-CSIQuickFinding $Findings "Security" "BitLocker" "Info" "Unable to inspect BitLocker status." "Check manage-bde -status if encryption status matters."
    }

    try {
        $license = @(Get-CimInstance SoftwareLicensingProduct -ErrorAction Stop | Where-Object { $_.PartialProductKey -and $_.Name -match "Windows" } | Select-Object -First 1)
        if($license.Count -gt 0 -and $license[0].LicenseStatus -eq 1){
            Add-CSIQuickFinding $Findings "Licensing" "Windows Activation" "OK" "Windows reports an activated license state."
        }
        elseif($license.Count -gt 0){
            Add-CSIQuickFinding $Findings "Licensing" "Windows Activation" "Warning" "Windows license status code: $($license[0].LicenseStatus)." "Check Activation settings, KMS reachability, or the license channel."
        }
        else{
            Add-CSIQuickFinding $Findings "Licensing" "Windows Activation" "Info" "No Windows licensing product with a partial key was returned." "Check Activation settings manually if the user sees activation warnings."
        }
    }
    catch {
        Add-CSIQuickFinding $Findings "Licensing" "Windows Activation" "Info" "Unable to inspect Windows activation status." "Check Activation settings manually if the user sees activation warnings."
    }

    try {
        if(Get-Command Get-PhysicalDisk -ErrorAction SilentlyContinue){
            $physicalDisks = @(Get-PhysicalDisk -ErrorAction Stop)
            if($physicalDisks.Count -eq 0){
                Add-CSIQuickFinding $Findings "Hardware" "Storage Visibility" "Info" "Windows did not return physical disks through Get-PhysicalDisk." "On a VM this is expected. For physical hardware, use CrystalDiskInfo, HWiNFO, or vendor storage tools."
            }
            elseif($isVM){
                Add-CSIQuickFinding $Findings "Hardware" "Storage Visibility" "Info" "Physical disk data is visible, but this appears to be a VM. Guest disk health may not reflect host storage health." "Check the hypervisor or storage platform if disk symptoms exist."
            }
        }
    }
    catch {
        $status = if($isVM){"Info"}else{"Warning"}
        Add-CSIQuickFinding $Findings "Hardware" "Storage Visibility" $status "Physical disk inventory could not be read: $($_.Exception.Message)" "On VMs this is often normal. On physical systems, use CrystalDiskInfo/HWiNFO or vendor tools."
    }

    try {
        $drivers = @($driverInventory | Where-Object { $_.Provider -notmatch '(?i)^Microsoft' })
        $oldDrivers = @()
        foreach($driver in $drivers){
            $driverDate = $driver.DriverDateRaw
            if($driverDate -and ((Get-Date) - $driverDate).TotalDays -gt 1825){
                $oldDrivers += $driver
            }
        }

        if($oldDrivers.Count -gt 0){
            $detail = (($oldDrivers | Select-Object -First 5 | ForEach-Object { "$($_.DeviceName) $($_.Version) $($_.DriverDate)" }) -join "; ")
            Add-CSIQuickFinding $Findings "Drivers" "Driver Age" "Info" "$($oldDrivers.Count) non-Microsoft important driver(s) are older than five years. $detail" "Only update drivers when symptoms, vendor guidance, or security requirements justify it."
        }
        else{
            Add-CSIQuickFinding $Findings "Drivers" "Driver Age" "OK" "No non-Microsoft display, network, storage, chipset, audio, USB, Bluetooth, or printer drivers older than five years were found."
        }
    }
    catch {
        Add-CSIQuickFinding $Findings "Drivers" "Driver Age" "Info" "Unable to inspect driver age." "Use Device Manager or vendor update tools if driver age is suspect."
    }

    try {
        $unsigned = @($driverInventory | Where-Object {
            $_.Provider -notmatch '(?i)^Microsoft' -and
            ($_.Signed -eq $false -or $_.Signed -eq "Unknown" -or !$_.Signer)
        })

        if($unsigned.Count -gt 0){
            $detail = (($unsigned | Select-Object -First 6 | ForEach-Object { "$($_.DeviceName) [$($_.Provider)]" }) -join "; ")
            Add-CSIQuickFinding $Findings "Drivers" "Unsigned Drivers" "Warning" "$($unsigned.Count) non-Microsoft driver(s) are unsigned or signature status is unknown. $detail" "Review these in Device Manager or with Sigcheck. Replace suspicious or unsupported drivers with vendor-signed versions."
        }
        else{
            Add-CSIQuickFinding $Findings "Drivers" "Unsigned Drivers" "OK" "No unsigned non-Microsoft drivers were found in the important driver classes."
        }
    }
    catch {
        Add-CSIQuickFinding $Findings "Drivers" "Unsigned Drivers" "Info" "Unable to inspect driver signature status." "Use Sigcheck or Device Manager if driver trust is suspect."
    }

    try {
        $recentDrivers = @($driverInventory | Where-Object {
            $_.Provider -notmatch '(?i)^Microsoft' -and
            $_.DriverDateRaw -and
            ((Get-Date) - $_.DriverDateRaw).TotalDays -le 45
        })

        if($recentDrivers.Count -gt 0){
            $detail = (($recentDrivers | Select-Object -First 6 | ForEach-Object { "$($_.DeviceName) $($_.Version) $($_.DriverDate)" }) -join "; ")
            Add-CSIQuickFinding $Findings "Drivers" "Recently Dated Drivers" "Info" "$($recentDrivers.Count) non-Microsoft important driver(s) have driver dates within the last 45 days. $detail" "If symptoms started recently, compare these against recent updates or vendor installs."
        }
        else{
            Add-CSIQuickFinding $Findings "Drivers" "Recently Dated Drivers" "OK" "No non-Microsoft important drivers with driver dates in the last 45 days were found."
        }
    }
    catch {
        Add-CSIQuickFinding $Findings "Drivers" "Recently Dated Drivers" "Info" "Unable to inspect recently dated drivers." "If symptoms began after an update, check Device Manager driver dates manually."
    }

    try {
        $driverEvents = @()
        foreach($provider in @("Microsoft-Windows-Kernel-PnP","Microsoft-Windows-DriverFrameworks-UserMode","Service Control Manager")){
            try {
                $driverEvents += Get-WinEvent -FilterHashtable @{LogName="System"; ProviderName=$provider; Level=1,2,3; StartTime=(Get-Date).AddDays(-14)} -MaxEvents 25 -ErrorAction Stop |
                    Where-Object { $_.Message -match '(?i)driver|device|pnp|failed|start|install' }
            }
            catch {}
        }

        if($driverEvents.Count -gt 0){
            $detail = (($driverEvents | Sort-Object TimeCreated -Descending | Select-Object -First 5 | ForEach-Object { "$($_.TimeCreated.ToString('yyyy-MM-dd HH:mm')) $($_.ProviderName) ID $($_.Id)" }) -join "; ")
            Add-CSIQuickFinding $Findings "Drivers" "Recent Driver Events" "Warning" "$($driverEvents.Count) driver/device warning or error event(s) found in the last 14 days. $detail" "Open Event Log Triage and Device Manager. Look for repeated provider, device, or driver names."
        }
        else{
            Add-CSIQuickFinding $Findings "Drivers" "Recent Driver Events" "OK" "No recent driver/device warning or error events were found in common driver event providers."
        }
    }
    catch {
        Add-CSIQuickFinding $Findings "Drivers" "Recent Driver Events" "Info" "Unable to inspect recent driver events." "Open Event Viewer System log and check Kernel-PnP and DriverFrameworks providers."
    }

}

function Global:Get-CSIQuickStatusChecks {

param([pscustomobject]$BaseReport)

    $findings = @()

    $findings += Invoke-CSIQuickDismCheckHealth
    Add-CSIQuickExtendedComputerChecks ([ref]$findings) -BaseReport $BaseReport
    Add-CSIQuickSysinternalsFindings ([ref]$findings) -BaseReport $BaseReport | Out-Null

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
            $driverInventory = @()
            if($BaseReport -and $BaseReport.PSObject.Properties["DriverInventory"]){
                $driverInventory = @($BaseReport.DriverInventory)
            }

            $detail = @(
                $deviceProblems |
                    Select-Object -First 8 |
                    ForEach-Object {
                        $driver = Get-CSIQuickDriverForDevice -DeviceProblem $_ -DriverInventory $driverInventory
                        $driverText = if($driver){" driver $($driver.Provider) $($driver.Version) $($driver.DriverDate)"}else{""}

                        if($_.FriendlyName){"$($_.FriendlyName) [$($_.Status)]$driverText"}
                        elseif($_.Name){"$($_.Name) [$($_.Status)]$driverText"}
                        else{"$($_.InstanceId) [$($_.Status)]$driverText"}
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

        $dumps = @()
        if(Get-Command Get-CSIDumpFiles -ErrorAction SilentlyContinue){
            $dumps = @(Get-CSIDumpFiles | Select-Object -First 5)
        }

        $crashEvents = @()
        $crashEvents += Get-WinEvent -FilterHashtable @{LogName="System"; Id=1001; StartTime=(Get-Date).AddDays(-14)} -MaxEvents 10 -ErrorAction SilentlyContinue
        $crashEvents += Get-WinEvent -FilterHashtable @{LogName="Application"; Id=1000,1001; StartTime=(Get-Date).AddDays(-14)} -MaxEvents 10 -ErrorAction SilentlyContinue

        if($crashEvents.Count -gt 0){
            if($dumps.Count -gt 0){
                Add-CSIQuickFinding ([ref]$findings) "Crashes" "Recent WER/Bugcheck Events" "Warning" "$($crashEvents.Count) crash or WER events found in the last 14 days. $($dumps.Count) dump file(s) are also available for analysis." "Run Minidump Collector And Analyzer, then review the collected dump with BlueScreenView or WinDbg Preview. Correlate the dump time with the listed crash events."
            }
            else{
                Add-CSIQuickFinding ([ref]$findings) "Crashes" "Recent WER/Application Crash Events" "Warning" "$($crashEvents.Count) crash or WER events found in the last 14 days, but Windows has not retained any .dmp files in the common dump locations." "Open Crash Event Summary or Reliability Monitor to identify the repeating application/provider. Minidump Collector will export the event evidence, but BlueScreenView cannot analyze a crash until Windows produces a dump file."
            }
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
            if($dumps.Count -gt 0){
                Add-CSIQuickFinding ([ref]$findings) "Crashes" "Dump Files" "Warning" "$($dumps.Count) recent dump files found. Latest: $($dumps[0].FullName)" "Run Minidump Collector And Analyzer and review the newest dump."
            }
            else{
                Add-CSIQuickFinding ([ref]$findings) "Crashes" "Dump Files" "Info" "No .dmp files were found in common dump locations. This is expected for application-only crashes or when Windows dump creation/retention is disabled."
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

function Global:New-CSIQuickDeepDive {

param(
    [string]$Area,
    [string]$Issue,
    [string]$Severity,
    [string]$Confidence,
    [string]$Evidence,
    [string]$WhyItMatters,
    [string]$RecommendedAction,
    [string]$CandidateDriver = ""
)

    [pscustomobject]@{
        Area              = $Area
        Issue             = $Issue
        Severity          = $Severity
        Confidence        = $Confidence
        Evidence          = $Evidence
        WhyItMatters      = $WhyItMatters
        RecommendedAction = $RecommendedAction
        CandidateDriver   = $CandidateDriver
    }

}

function Global:Get-CSIQuickWindowsUpdateDriverCandidates {

param([int]$TimeoutSeconds = 18)

    try {
        $service = Get-Service wuauserv -ErrorAction SilentlyContinue
        if($service -and $service.StartType -eq "Disabled"){
            return @([pscustomobject]@{
                LookupStatus       = "Unavailable"
                Title              = "Windows Update service is disabled"
                DriverManufacturer = ""
                DriverModel        = ""
                DriverClass        = ""
                DriverVersion      = ""
                DriverDate         = ""
            })
        }

        $job = Start-Job -ScriptBlock {
            function Get-ComValue {
                param([object]$InputObject,[string]$PropertyName)
                try { return $InputObject.$PropertyName } catch { return "" }
            }

            $items = @()
            try {
                $session = New-Object -ComObject Microsoft.Update.Session
                $searcher = $session.CreateUpdateSearcher()
                $result = $searcher.Search("IsInstalled=0 and Type='Driver'")

                for($i = 0; $i -lt $result.Updates.Count; $i++){
                    $update = $result.Updates.Item($i)
                    $items += [pscustomobject]@{
                        LookupStatus       = "OK"
                        Title              = [string](Get-ComValue $update "Title")
                        Description        = [string](Get-ComValue $update "Description")
                        DriverManufacturer = [string](Get-ComValue $update "DriverManufacturer")
                        DriverModel        = [string](Get-ComValue $update "DriverModel")
                        DriverClass        = [string](Get-ComValue $update "DriverClass")
                        DriverVersion      = [string](Get-ComValue $update "DriverVerVersion")
                        DriverDate         = [string](Get-ComValue $update "DriverVerDate")
                    }
                }
            }
            catch {
                $items += [pscustomobject]@{
                    LookupStatus       = "Failed"
                    Title              = $_.Exception.Message
                    Description        = ""
                    DriverManufacturer = ""
                    DriverModel        = ""
                    DriverClass        = ""
                    DriverVersion      = ""
                    DriverDate         = ""
                }
            }

            return $items
        } -ErrorAction Stop

        $completedJob = Wait-Job -Job $job -Timeout $TimeoutSeconds
        if($completedJob){
            return @(Receive-Job -Job $job -ErrorAction SilentlyContinue)
        }

        Stop-Job -Job $job -Force -ErrorAction SilentlyContinue | Out-Null
        return @([pscustomobject]@{
            LookupStatus       = "TimedOut"
            Title              = "Windows Update driver candidate lookup timed out after $TimeoutSeconds seconds"
            DriverManufacturer = ""
            DriverModel        = ""
            DriverClass        = ""
            DriverVersion      = ""
            DriverDate         = ""
        })
    }
    catch {
        return @([pscustomobject]@{
            LookupStatus       = "Failed"
            Title              = $_.Exception.Message
            DriverManufacturer = ""
            DriverModel        = ""
            DriverClass        = ""
            DriverVersion      = ""
            DriverDate         = ""
        })
    }
    finally {
        if($job){
            Remove-Job -Job $job -Force -ErrorAction SilentlyContinue | Out-Null
        }
    }

}

function Global:Find-CSIQuickDriverCandidate {

param(
    [object]$Driver,
    [object[]]$Candidates
)

    if(!$Driver -or !$Candidates){
        return $null
    }

    $usable = @($Candidates | Where-Object { $_.LookupStatus -eq "OK" -and $_.Title })
    if($usable.Count -eq 0){
        return $null
    }

    $needles = @(
        $Driver.DeviceName
        $Driver.Provider
        $Driver.DeviceClass
    ) | Where-Object { $_ -and ([string]$_).Length -ge 4 } | ForEach-Object { ([string]$_).ToLowerInvariant() }

    $best = $null
    $bestScore = 0

    foreach($candidate in $usable){
        $haystack = "$($candidate.Title) $($candidate.DriverManufacturer) $($candidate.DriverModel) $($candidate.DriverClass)".ToLowerInvariant()
        $score = 0

        foreach($needle in $needles){
            if($haystack.Contains($needle)){
                $score += 3
            }
            else{
                $parts = @($needle -split '\s+' | Where-Object { $_.Length -ge 4 })
                foreach($part in $parts){
                    if($haystack.Contains($part)){
                        $score += 1
                    }
                }
            }
        }

        if($score -gt $bestScore){
            $best = $candidate
            $bestScore = $score
        }
    }

    if($bestScore -gt 0){
        return $best
    }

    return $null

}

function Global:Format-CSIQuickDriverCandidate {

param(
    [object]$Candidate,
    [object[]]$AllCandidates
)

    if($Candidate){
        $version = if($Candidate.DriverVersion){" version $($Candidate.DriverVersion)"}else{""}
        $date = if($Candidate.DriverDate){" dated $($Candidate.DriverDate)"}else{""}
        return "Windows Update candidate: $($Candidate.Title)$version$date."
    }

    $status = @($AllCandidates | Where-Object { $_.LookupStatus -and $_.LookupStatus -ne "OK" } | Select-Object -First 1)
    if($status.Count -gt 0){
        return "No exact driver candidate was confirmed. Windows Update lookup status: $($status[0].LookupStatus) - $($status[0].Title)."
    }

    return "No exact Windows Update driver candidate was available during this scan. Use the computer OEM support page first, then the device vendor if the OEM does not publish a newer driver."

}

function Global:Get-CSIQuickDeepDives {

param([pscustomobject]$Report)

    $deepDives = @()
    if(!$Report){
        return $deepDives
    }

    $findings = @($Report.Problems)
    if($findings.Count -eq 0){
        return $deepDives
    }

    $driverInventory = @()
    if($Report.PSObject.Properties["DriverInventory"]){
        $driverInventory = @($Report.DriverInventory)
    }

    $needsDriverCandidateLookup = @($findings | Where-Object {
        ($_.Area -in @("Hardware","Drivers") -and $_.Check -in @("Device Manager","Display Adapter","Unsigned Drivers","Recent Driver Events")) -or
        ($_.Area -eq "Hardware" -and $_.Check -like "*Driver*")
    }).Count -gt 0

    $driverCandidates = @()
    if($needsDriverCandidateLookup){
        $driverCandidates = @(Get-CSIQuickWindowsUpdateDriverCandidates)
    }

    foreach($finding in $findings){
        $area = [string]$finding.Area
        $check = [string]$finding.Check
        $severity = [string]$finding.Status
        $detail = [string]$finding.Detail

        if($area -eq "Hardware" -and $check -eq "Display Adapter"){
            $displayDrivers = @($driverInventory | Where-Object { $_.DeviceClass -eq "Display" })
            $driver = @($displayDrivers | Select-Object -First 1)
            $candidate = if($driver.Count -gt 0){ Find-CSIQuickDriverCandidate -Driver $driver[0] -Candidates $driverCandidates }else{$null}
            $candidateText = Format-CSIQuickDriverCandidate -Candidate $candidate -AllCandidates $driverCandidates
            $evidence = if($driver.Count -gt 0){"Current display driver: $($driver[0].DeviceName), provider $($driver[0].Provider), version $($driver[0].Version), date $($driver[0].DriverDate). Finding: $detail"}else{$detail}

            $deepDives += New-CSIQuickDeepDive `
                -Area "Hardware" `
                -Issue "Display adapter driver needs review" `
                -Severity $severity `
                -Confidence "High when Device Manager reports an adapter error; Medium when only version/date evidence is available." `
                -Evidence $evidence `
                -WhyItMatters "A bad, missing, or generic display driver can cause poor resolution, hardware acceleration failures, app crashes, remote display problems, and GPU instability." `
                -RecommendedAction "If this is a physical workstation, install the OEM display package for this exact model first. If the OEM package is unavailable or stale, use the GPU vendor package for the detected adapter. On VMs, use the hypervisor guest tools/video driver." `
                -CandidateDriver $candidateText
        }
        elseif($area -eq "Hardware" -and $check -eq "Device Manager"){
            $problemDrivers = @($driverInventory | Where-Object { $detail -like "*$($_.DeviceName)*" } | Select-Object -First 5)
            $driverText = if($problemDrivers.Count -gt 0){
                ($problemDrivers | ForEach-Object { "$($_.DeviceName): $($_.Provider) $($_.Version) $($_.DriverDate)" }) -join "; "
            }
            else{
                "No matching signed-driver inventory row was found for the problem device text."
            }

            $candidateText = "No exact candidate selected. Check Windows Update optional driver updates and the computer OEM support page for the specific problem device."
            if($problemDrivers.Count -gt 0){
                $candidate = Find-CSIQuickDriverCandidate -Driver $problemDrivers[0] -Candidates $driverCandidates
                $candidateText = Format-CSIQuickDriverCandidate -Candidate $candidate -AllCandidates $driverCandidates
            }

            $deepDives += New-CSIQuickDeepDive `
                -Area "Hardware" `
                -Issue "Device Manager problem device" `
                -Severity $severity `
                -Confidence "High. Windows is reporting a present device that is not healthy." `
                -Evidence "$detail Driver evidence: $driverText" `
                -WhyItMatters "A problem device usually means the driver is missing, the wrong driver is installed, the device was removed, firmware is failing, or Windows cannot start the device." `
                -RecommendedAction "Open Device Manager, view the device status code, then reinstall the OEM driver package. If this is dock, USB, printer, storage, or display related, also reseat/reconnect the device and update firmware where applicable." `
                -CandidateDriver $candidateText
        }
        elseif($area -eq "Drivers" -and $check -eq "Unsigned Drivers"){
            $unsigned = @($driverInventory | Where-Object {
                $_.Provider -notmatch '(?i)^Microsoft' -and
                ($_.Signed -eq $false -or $_.Signed -eq "Unknown" -or !$_.Signer)
            } | Select-Object -First 6)
            $driverText = if($unsigned.Count -gt 0){
                ($unsigned | ForEach-Object { "$($_.DeviceName): $($_.Provider) $($_.Version) $($_.InfName)" }) -join "; "
            }
            else{
                $detail
            }

            $deepDives += New-CSIQuickDeepDive `
                -Area "Drivers" `
                -Issue "Unsigned or unknown-signature driver" `
                -Severity $severity `
                -Confidence "Medium. Signature metadata can be incomplete, but unsigned third-party kernel drivers deserve review." `
                -Evidence $driverText `
                -WhyItMatters "Unsigned or unknown-signature drivers are more likely to be old, unsupported, tampered with, or incompatible with modern Windows security features." `
                -RecommendedAction "Do not blindly remove the driver. Identify the owning device or application, then replace it with a current vendor-signed package. Use Sigcheck for verification if the file path is known." `
                -CandidateDriver "Windows Update may not offer replacements for application filter drivers. Prefer the device or application vendor's signed package."
        }
        elseif($area -eq "Drivers" -and $check -eq "Recent Driver Events"){
            $deepDives += New-CSIQuickDeepDive `
                -Area "Drivers" `
                -Issue "Recent driver or device errors in Event Viewer" `
                -Severity $severity `
                -Confidence "Medium. Event providers identify timing and subsystem, but the underlying cause needs correlation with symptoms." `
                -Evidence $detail `
                -WhyItMatters "Repeated Kernel-PnP, DriverFrameworks, or Service Control Manager driver errors can explain intermittent hardware failures, boot delays, crashes, or devices disappearing." `
                -RecommendedAction "Open Event Log Triage and sort by time/provider. Match the newest repeated event to Device Manager, recently installed drivers, Windows Updates, docks, printers, USB devices, storage controllers, or VPN/security software." `
                -CandidateDriver (Format-CSIQuickDriverCandidate -Candidate $null -AllCandidates $driverCandidates)
        }
        elseif($area -eq "Hardware" -and $check -match "WHEA|Hardware Driver Events"){
            $deepDives += New-CSIQuickDeepDive `
                -Area "Hardware" `
                -Issue "Hardware or low-level driver events" `
                -Severity $severity `
                -Confidence "High for WHEA events; Medium for general hardware driver events." `
                -Evidence $detail `
                -WhyItMatters "These events can point to CPU, memory, PCIe, storage, firmware, chipset, or device-driver instability." `
                -RecommendedAction "Check BIOS/UEFI, chipset, storage, network, and GPU drivers from the OEM. Run vendor diagnostics and inspect cabling/docks if the issue follows a peripheral." `
                -CandidateDriver "Use OEM update utilities first because chipset, firmware, and storage stacks are model-specific."
        }
        elseif($area -eq "Disk" -and $severity -in @("Critical","Warning")){
            $deepDives += New-CSIQuickDeepDive `
                -Area "Disk" `
                -Issue "Storage health needs investigation" `
                -Severity $severity `
                -Confidence "High when Windows reports unhealthy physical disk or SMART predicted failure; Medium when disk visibility is limited by VM/storage abstraction." `
                -Evidence $detail `
                -WhyItMatters "Disk or controller problems can cause slowness, freezes, corruption, failed updates, profile issues, and application crashes." `
                -RecommendedAction "Back up important data first if failure is suspected. Then inspect the disk with CrystalDiskInfo, HWiNFO, or the storage vendor utility. On VMs, check the host or storage platform rather than only the guest." `
                -CandidateDriver "If storage controller events exist, use the OEM chipset/storage driver package for the exact model."
        }
        elseif($area -eq "System Image" -and $check -eq "DISM CheckHealth"){
            $deepDives += New-CSIQuickDeepDive `
                -Area "Windows" `
                -Issue "Windows component store health issue" `
                -Severity $severity `
                -Confidence "High when DISM reports corruption; Medium if DISM could not complete." `
                -Evidence $detail `
                -WhyItMatters "Component store corruption can break Windows Updates, optional features, driver installs, and system file repair." `
                -RecommendedAction "Run the DISM/SFC Repair Path only after reviewing this report. If DISM requires elevation, restart the toolkit elevated and rerun Quick Diagnosis before repair." `
                -CandidateDriver "Not driver-related."
        }
        elseif($area -eq "Services"){
            $serviceNames = if($detail){($detail -replace ',', ', ')}else{"Service name was not captured."}
            $serviceIssue = if($check -eq "Stopped Automatic Services"){"Stopped automatic services need review"}else{"Service $check is not in expected state"}
            $deepDives += New-CSIQuickDeepDive `
                -Area "Services" `
                -Issue $serviceIssue `
                -Severity $severity `
                -Confidence "Medium. Some automatic services are intentionally trigger-started, but core services that remain stopped can break normal workstation functions." `
                -Evidence "$check reported: $serviceNames" `
                -WhyItMatters "Stopped automatic services can explain missing network identity, update failures, printing issues, security gaps, slow logons, or app features not working." `
                -RecommendedAction "Open Services or the Service Health tool and inspect the listed service startup type, current state, dependencies, and newest System log errors. Start the service only after confirming it should run on this computer." `
                -CandidateDriver "Not driver-related unless the failed service belongs to a device, VPN, print, security, or storage driver package."
        }
        elseif($area -eq "Startup" -and $check -eq "Autoruns Missing Files"){
            $deepDives += New-CSIQuickDeepDive `
                -Area "Startup" `
                -Issue "Startup entry points to a missing file" `
                -Severity $severity `
                -Confidence "Medium. Autorunsc found a persistence/startup entry whose image path is missing or stale." `
                -Evidence $detail `
                -WhyItMatters "Missing startup paths can slow logon, create repeated errors, leave software half-uninstalled, or indicate a broken persistence entry after cleanup." `
                -RecommendedAction "Open Autoruns, find the listed entry, confirm the owning application was removed or broken, then disable or delete the stale entry. Do not remove entries until the publisher/path is understood." `
                -CandidateDriver "Not usually driver-related unless the Autoruns category is Drivers or Services."
        }
        elseif($area -eq "Startup" -and $check -eq "Autoruns Verification"){
            $deepDives += New-CSIQuickDeepDive `
                -Area "Startup" `
                -Issue "Startup entry signature or publisher needs review" `
                -Severity $severity `
                -Confidence "Medium. Autorunsc signature verification is a fast signal, not a final malware verdict." `
                -Evidence $detail `
                -WhyItMatters "Unsigned or unverified startup entries can be normal internal tools, but they are also common places for unwanted software, stale agents, and persistence mechanisms." `
                -RecommendedAction "Open Autoruns and Sigcheck for the listed entries. Verify publisher, path, install source, and business need. Disable only after confirming the entry is unwanted or suspicious." `
                -CandidateDriver "If the entry is a driver/service, replace it with a current vendor-signed package instead of deleting it blindly."
        }
        elseif($area -eq "Time"){
            $deepDives += New-CSIQuickDeepDive `
                -Area "Time" `
                -Issue "Windows time sync is not clean" `
                -Severity $severity `
                -Confidence "Medium. Time commands can fail from permissions, service state, domain policy, or an actual sync problem." `
                -Evidence $detail `
                -WhyItMatters "Bad time can break domain logons, Kerberos, certificates, VPNs, MFA, file timestamps, and management agent communication." `
                -RecommendedAction "Verify the Windows Time service is running. On domain-joined systems, use the toolkit time repair to point the workstation back to the domain hierarchy, then run w32tm /query /status and w32tm /resync." `
                -CandidateDriver "Not driver-related."
        }
        elseif($area -eq "System" -and $check -eq "Pending Reboot"){
            $deepDives += New-CSIQuickDeepDive `
                -Area "Windows" `
                -Issue "Pending reboot is blocking a clean baseline" `
                -Severity $severity `
                -Confidence "High. Windows has recorded pending reboot evidence." `
                -Evidence $detail `
                -WhyItMatters "Pending reboots can leave driver installs, Windows Updates, feature changes, security updates, and file replacements half-applied." `
                -RecommendedAction "Schedule or perform a reboot, then rerun Quick Diagnosis. Do not start deeper repair work until the reboot state clears unless the computer cannot reboot safely." `
                -CandidateDriver "Driver updates may not fully apply until after reboot."
        }
        elseif($area -eq "Event Logs"){
            $deepDives += New-CSIQuickDeepDive `
                -Area "Windows" `
                -Issue "Recent critical or error events" `
                -Severity $severity `
                -Confidence "Medium. Event count alone does not prove root cause, but repeated recent errors point the next investigation." `
                -Evidence $detail `
                -WhyItMatters "A high error count can explain user-visible failures such as app crashes, service failures, update problems, device errors, or domain communication issues." `
                -RecommendedAction "Open Event Log Triage, group by provider, then investigate the newest repeated provider first. Ignore one-off noise until repeated or time-correlated with the user's symptom." `
                -CandidateDriver "If repeated providers mention PnP, DriverFrameworks, disk, display, storage, VPN, or security software, check that driver package next."
        }
        elseif($area -eq "Network" -or $area -eq "Domain"){
            $deepDives += New-CSIQuickDeepDive `
                -Area $area `
                -Issue "$area connectivity issue" `
                -Severity $severity `
                -Confidence "Medium to High depending on whether DNS, gateway, domain, or TCP checks failed." `
                -Evidence $detail `
                -WhyItMatters "Network and domain failures can break logon, mapped drives, printers, management tools, updates, DNS resolution, and cloud access." `
                -RecommendedAction "Use the Quick Target Checks, DNS tools, Test-NetConnection, route trace, and domain logon health tools. Verify IP, gateway, DNS servers, VLAN/Wi-Fi, and firewall policy before changing applications." `
                -CandidateDriver "If only this computer is affected, check the network adapter driver and power management settings."
        }
        elseif($area -eq "Security" -or $area -eq "Licensing"){
            $deepDives += New-CSIQuickDeepDive `
                -Area $area `
                -Issue "$area setting needs review" `
                -Severity $severity `
                -Confidence "Medium. Security and licensing cmdlets can be affected by policy, product edition, and third-party security tools." `
                -Evidence $detail `
                -WhyItMatters "Security or activation problems can cause compliance gaps, blocked updates, user prompts, reduced protection, or management alerts." `
                -RecommendedAction "Open the matching toolkit security check and Windows settings page. Confirm whether the detected state is expected for this workstation, server, VM, or lab system." `
                -CandidateDriver "Not driver-related."
        }
        elseif($area -eq "Crashes"){
            $noDumps = $detail -match '(?i)not retained any \.dmp|no \.dmp files|no dump files'
            $recommendedAction = if($noDumps){
                "Open Crash Event Summary or Reliability Monitor and identify the repeating application, provider, or module. The Minidump Collector will save this event evidence, but BlueScreenView needs a future .dmp file before it can identify a bugcheck driver."
            }
            else{
                "Run Minidump Collector and open the collected dump folder with BlueScreenView or WinDbg Preview. Correlate bugcheck time with driver events and Windows Update history."
            }
            $candidateDriver = if($noDumps){
                "No dump is available yet. Use the event provider/module and Reliability Monitor history to narrow the suspected application or driver."
            }
            else{
                "If a dump names a driver, replace that driver from the OEM/vendor source and rerun Quick Diagnosis."
            }
            $deepDives += New-CSIQuickDeepDive `
                -Area "Crashes" `
                -Issue "Crash evidence found" `
                -Severity $severity `
                -Confidence "Medium until dump files are reviewed." `
                -Evidence $detail `
                -WhyItMatters "Crash and WER events may identify failing drivers, unstable applications, bad memory, disk problems, or security software conflicts." `
                -RecommendedAction $recommendedAction `
                -CandidateDriver $candidateDriver
        }
    }

    return @($deepDives | Select-Object -First 20)

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
    $Report | Add-Member -MemberType NoteProperty -Name DeepDives -Value @(Get-CSIQuickDeepDives -Report $Report) -Force
    $Report.RepairDisposition = "Diagnostic-only scan. DISM CheckHealth was allowed; DISM ScanHealth, RestoreHealth, and SFC were not run. If servicing corruption or system file damage is suspected, run Windows Health Diagnostics > DISM/SFC Repair Path as a separate remediation task."

    return $Report

}

function Global:Export-CSIQuickIssueEvidence {
param([pscustomobject]$Report)

    $start = (Get-Date).AddDays(-14)
    $eventRows = New-Object System.Collections.ArrayList
    $addEvents = {
        param([string]$LogName,[string[]]$Providers,[int[]]$Ids,[string]$Category)
        foreach($provider in $Providers){
            try {
                $filter = @{ LogName=$LogName; ProviderName=$provider; StartTime=$start }
                if($Ids){ $filter.Id = $Ids }
                Get-WinEvent -FilterHashtable $filter -MaxEvents 30 -ErrorAction Stop | ForEach-Object {
                    [void]$eventRows.Add([pscustomobject]@{
                        Category=$Category; Time=$_.TimeCreated.ToString('s'); Log=$_.LogName; Provider=$_.ProviderName; Id=$_.Id; Level=$_.LevelDisplayName
                        Message=([string]$_.Message).Trim()
                    })
                }
            }
            catch {}
        }
    }

    & $addEvents 'System' @('Service Control Manager') @(7000,7001,7009,7031,7034) 'Service failures'
    & $addEvents 'Application' @('Application Error','Windows Error Reporting') @(1000,1001) 'Application crashes and WER'
    & $addEvents 'System' @('Microsoft-Windows-Kernel-PnP','Microsoft-Windows-DriverFrameworks-UserMode') @() 'Driver and device events'
    & $addEvents 'Setup' @('Microsoft-Windows-WindowsUpdateClient') @() 'Windows Update events'

    $stoppedAuto = @()
    try {
        $stoppedAuto = @(Get-CimInstance Win32_Service -ErrorAction Stop |
            Where-Object { $_.StartMode -eq 'Auto' -and $_.State -ne 'Running' } |
            Select-Object Name,DisplayName,State,StartMode,StartName,PathName)
    }
    catch {}

    $deviceProblems = @()
    try {
        if(Get-Command Get-PnpDevice -ErrorAction SilentlyContinue){
            $deviceProblems = @(Get-PnpDevice -PresentOnly -ErrorAction SilentlyContinue |
                Where-Object { $_.Status -notin @('OK','Unknown') } |
                Select-Object FriendlyName,Class,Status,Problem,InstanceId)
        }
    }
    catch {}

    $recentUpdates = @()
    try { $recentUpdates = @(Get-HotFix -ErrorAction Stop | Sort-Object InstalledOn -Descending | Select-Object -First 12 HotFixID,Description,InstalledOn,InstalledBy) } catch {}

    $computerName = if($Report.Fingerprint -and $Report.Fingerprint.ComputerName){$Report.Fingerprint.ComputerName}else{$env:COMPUTERNAME}
    $evidence = [pscustomobject]@{
        ComputerName=$computerName; CollectedAt=(Get-Date).ToString('s'); WindowStart=$start.ToString('s')
        PendingReboot=if($Report.Fingerprint){$Report.Fingerprint.PendingReboot}else{$null}
        TargetedEvents=@($eventRows | Sort-Object Time -Descending | Select-Object -First 100)
        StoppedAutomaticServices=$stoppedAuto
        DeviceManagerProblems=$deviceProblems
        DriverInventory=if($Report.DriverInventory){@($Report.DriverInventory | Select-Object DeviceName,DeviceClass,Provider,Version,DriverDate,InfName)}else{@()}
        RecentInstalledUpdates=$recentUpdates
    }
    $path = Join-Path $CSIPaths.Exports ("issue-evidence-{0}-{1}.json" -f $computerName,(Get-Date -Format 'yyyyMMdd-HHmmss'))
    $evidence | ConvertTo-Json -Depth 7 | Set-Content -LiteralPath $path -Encoding UTF8
    $Report | Add-Member -MemberType NoteProperty -Name IssueEvidencePath -Value $path -Force
    $Report | Add-Member -MemberType NoteProperty -Name IssueEvidence -Value $evidence -Force
    $path
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
            $issueEvidencePath = Export-CSIQuickIssueEvidence -Report $report

            if($report.Fingerprint -and $report.FingerprintExports){
                foreach($jsonPath in @($report.FingerprintExports.DataJson,$report.FingerprintExports.Json)){
                    if($jsonPath){
                        try {
                            $report.Fingerprint |
                                ConvertTo-Json -Depth 10 |
                                Set-Content -Path $jsonPath -Encoding UTF8
                        }
                        catch {}
                    }
                }
            }

            $htmlPath = Export-CSIQuickDiagnosisHtml -Report $report -OutputRoot $CSIPaths.Exports

            if(Get-Command Set-CSIComputerStateSection -ErrorAction SilentlyContinue){
                try {
                    $stateData = [pscustomobject]@{
                        Target = $Target
                        ReportPath = $htmlPath
                        CapturedAt = (Get-Date).ToString("s")
                        Summary = $report.Summary
                        Problems = $report.Problems
                        Health = $report.Health
                        DeepDives = $report.DeepDives
                        IssueEvidencePath = $issueEvidencePath
                        IssueEvidence = $report.IssueEvidence
                        RepairDisposition = $report.RepairDisposition
                        FingerprintExports = $report.FingerprintExports
                    }

                    $computerName = if($report.Fingerprint -and $report.Fingerprint.ComputerName){$report.Fingerprint.ComputerName}else{$env:COMPUTERNAME}
                    [void](Set-CSIComputerStateSection `
                        -SectionName "QuickDiagnosis" `
                        -Data $stateData `
                        -ComputerName $computerName `
                        -Source "Invoke-QuickDiagnosis")

                    if($report.Fingerprint -and $report.FingerprintExports -and (Get-Command Export-CSIComputerFingerprintHtml -ErrorAction SilentlyContinue)){
                        if($report.FingerprintExports.DataJson -and (Test-Path $report.FingerprintExports.DataJson)){
                            $dataHtml = Export-CSIComputerFingerprintHtml -Fingerprint $report.Fingerprint -JsonPath $report.FingerprintExports.DataJson
                            $report.FingerprintExports.DataHtml = $dataHtml
                        }

                        if($report.FingerprintExports.Json -and (Test-Path $report.FingerprintExports.Json)){
                            $exportHtml = Export-CSIComputerFingerprintHtml -Fingerprint $report.Fingerprint -JsonPath $report.FingerprintExports.Json
                            $report.FingerprintExports.Html = $exportHtml
                        }
                    }
                }
                catch {}
            }

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
