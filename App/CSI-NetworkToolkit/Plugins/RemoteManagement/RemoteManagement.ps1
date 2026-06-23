function Global:Get-CSIRemoteManagementEnableBlock {

    return {
        $results = New-Object System.Collections.ArrayList

        function Add-Result {
            param(
                [string]$Step,
                [string]$Status,
                [string]$Detail
            )

            [void]$results.Add([pscustomobject]@{
                ComputerName = $env:COMPUTERNAME
                Step = $Step
                Status = $Status
                Detail = $Detail
            })
        }

        try {
            Enable-PSRemoting -Force -SkipNetworkProfileCheck -ErrorAction Stop | Out-Null
            Add-Result "WinRM / PowerShell Remoting" "OK" "Enable-PSRemoting completed."
        }
        catch {
            Add-Result "WinRM / PowerShell Remoting" "Error" $_.Exception.Message
        }

        foreach($service in @("WinRM","RemoteRegistry")){
            try {
                Set-Service -Name $service -StartupType Automatic -ErrorAction Stop
                Start-Service -Name $service -ErrorAction SilentlyContinue
                Add-Result "Service $service" "OK" "Startup type set to Automatic and start attempted."
            }
            catch {
                Add-Result "Service $service" "Warning" $_.Exception.Message
            }
        }

        foreach($group in @(
            "Windows Remote Management",
            "Remote Service Management",
            "Remote Event Log Management",
            "Remote Scheduled Tasks Management",
            "Windows Management Instrumentation (WMI)",
            "File and Printer Sharing"
        )){
            try {
                $rules = @(Get-NetFirewallRule -DisplayGroup $group -ErrorAction Stop)
                if($rules.Count -gt 0){
                    $rules | Enable-NetFirewallRule -ErrorAction Stop
                    Add-Result "Firewall: $group" "OK" "Enabled $($rules.Count) rule(s)."
                }
                else{
                    Add-Result "Firewall: $group" "Warning" "No firewall rules found for this display group."
                }
            }
            catch {
                Add-Result "Firewall: $group" "Warning" $_.Exception.Message
            }
        }

        try {
            $winrm = @(winrm enumerate winrm/config/listener 2>&1 | ForEach-Object { $_.ToString() })
            Add-Result "WinRM listener verification" "OK" ($winrm -join " ")
        }
        catch {
            Add-Result "WinRM listener verification" "Warning" $_.Exception.Message
        }

        return @($results)
    }
}

function Global:Write-CSIRemoteManagementResults {

param([object[]]$Results)

    foreach($result in @($Results)){
        $color = switch([string]$result.Status){
            "OK" { "Green" }
            "Warning" { "Yellow" }
            default { "Red" }
        }

        $prefix = if($result.ComputerName){ "[$($result.ComputerName)] " }else{ "" }
        Write-Host ("{0}{1,-34} {2}" -f $prefix,$result.Step,$result.Status) -ForegroundColor $color
        if($result.Detail){ Write-Host "  $($result.Detail)" -ForegroundColor DarkGray }
    }
}

function Global:Get-CSIPsExecPath {

    $candidates = @()

    if($CSIPaths -and $CSIPaths.Root){
        $candidates += Join-Path $CSIPaths.Root "ExternalTools\Sysinternals\PsExec64.exe"
        $candidates += Join-Path $CSIPaths.Root "ExternalTools\Sysinternals\PsExec.exe"
        $candidates += Join-Path $CSIPaths.Root "ExternalTools\Sysinternals\psexec64.exe"
        $candidates += Join-Path $CSIPaths.Root "ExternalTools\Sysinternals\psexec.exe"
    }

    foreach($candidate in $candidates){
        if(Test-Path $candidate){
            return $candidate
        }
    }

    $found = Get-Command psexec.exe,psexec64.exe -ErrorAction SilentlyContinue | Select-Object -First 1
    if($found){
        return $found.Source
    }

    return $null
}

function Global:Invoke-CSIEnableRemoteManagementWithPsExec {

param(
    [Parameter(Mandatory=$true)]
    [string]$ComputerName
)

    $psexec = Get-CSIPsExecPath
    if(!$psexec){
        return @([pscustomobject]@{
            ComputerName = $ComputerName
            Step = "PsExec fallback"
            Status = "Error"
            Detail = "PsExec was not found in ExternalTools\Sysinternals or PATH."
        })
    }

    $enableBlockText = (Get-CSIRemoteManagementEnableBlock).ToString()
    $command = @"
`$results = & {
$enableBlockText
}
`$results | ConvertTo-Json -Depth 6
"@

    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command))
    $arguments = @(
        "\\$ComputerName",
        "-accepteula",
        "-h",
        "-s",
        "powershell.exe",
        "-NoProfile",
        "-ExecutionPolicy",
        "Bypass",
        "-EncodedCommand",
        $encoded
    )

    try {
        $output = @(& $psexec @arguments 2>&1 | ForEach-Object { $_.ToString() })
        $jsonText = ($output | Where-Object { $_ -match '^\s*[\[\{]' } | Select-Object -Last 1)

        if($jsonText){
            try {
                return @(($jsonText | ConvertFrom-Json))
            }
            catch {}
        }

        return @([pscustomobject]@{
            ComputerName = $ComputerName
            Step = "PsExec fallback"
            Status = "Warning"
            Detail = ($output -join " ")
        })
    }
    catch {
        return @([pscustomobject]@{
            ComputerName = $ComputerName
            Step = "PsExec fallback"
            Status = "Error"
            Detail = $_.Exception.Message
        })
    }
}

function Global:Invoke-CSIEnableRemoteManagementTarget {

param(
    [Parameter(Mandatory=$true)]
    [string]$ComputerName,
    [ValidateSet("Local","WinRM","PsExec","Auto")]
    [string]$Method = "Auto"
)

    if($Method -eq "Local" -or $ComputerName -eq "." -or $ComputerName -eq $env:COMPUTERNAME){
        return @(& (Get-CSIRemoteManagementEnableBlock))
    }

    if($Method -in @("Auto","WinRM")){
        try {
            Test-WSMan -ComputerName $ComputerName -ErrorAction Stop | Out-Null
            return @(Invoke-Command -ComputerName $ComputerName -ScriptBlock (Get-CSIRemoteManagementEnableBlock) -ErrorAction Stop)
        }
        catch {
            if($Method -eq "WinRM"){
                return @([pscustomobject]@{
                    ComputerName = $ComputerName
                    Step = "WinRM remote execution"
                    Status = "Error"
                    Detail = $_.Exception.Message
                })
            }

            Write-Host "[$ComputerName] WinRM is not reachable. Trying PsExec fallback..." -ForegroundColor Yellow
        }
    }

    return @(Invoke-CSIEnableRemoteManagementWithPsExec -ComputerName $ComputerName)
}

function Global:Get-CSIRemoteManagementReadinessBlock {

    return {
        $results = New-Object System.Collections.ArrayList

        function Add-Result {
            param(
                [string]$Step,
                [string]$Status,
                [string]$Detail
            )

            [void]$results.Add([pscustomobject]@{
                ComputerName = $env:COMPUTERNAME
                Step = $Step
                Status = $Status
                Detail = $Detail
            })
        }

        foreach($service in @("WinRM","RemoteRegistry","RpcSs","LanmanServer","EventLog","Schedule")){
            try {
                $svc = Get-Service -Name $service -ErrorAction Stop
                $status = if($svc.Status -eq "Running"){"OK"}elseif($service -eq "RemoteRegistry"){"Warning"}else{"Error"}
                Add-Result "Service $service" $status "Status=$($svc.Status); StartType=$($svc.StartType)"
            }
            catch {
                Add-Result "Service $service" "Warning" $_.Exception.Message
            }
        }

        foreach($group in @(
            "Windows Remote Management",
            "Remote Service Management",
            "Remote Event Log Management",
            "Remote Scheduled Tasks Management",
            "Windows Management Instrumentation (WMI)",
            "File and Printer Sharing"
        )){
            try {
                $rules = @(Get-NetFirewallRule -DisplayGroup $group -ErrorAction Stop)
                $enabled = @($rules | Where-Object { $_.Enabled -eq "True" })
                $status = if($enabled.Count -gt 0){"OK"}else{"Warning"}
                Add-Result "Firewall: $group" $status "Enabled $($enabled.Count) of $($rules.Count) rule(s)."
            }
            catch {
                Add-Result "Firewall: $group" "Warning" $_.Exception.Message
            }
        }

        try {
            $listeners = @(winrm enumerate winrm/config/listener 2>&1 | ForEach-Object { $_.ToString() })
            $listenerText = ($listeners -join " ")
            $status = if($listenerText -match "Transport\s*=\s*HTTP|Transport\s*=\s*HTTPS"){"OK"}else{"Warning"}
            Add-Result "WinRM listener" $status $listenerText
        }
        catch {
            Add-Result "WinRM listener" "Warning" $_.Exception.Message
        }

        try {
            $networkProfiles = @(Get-NetConnectionProfile -ErrorAction Stop)
            $publicProfiles = @($networkProfiles | Where-Object { $_.NetworkCategory -eq "Public" })
            $status = if($publicProfiles.Count -gt 0){"Warning"}else{"OK"}
            Add-Result "Network profile" $status (($networkProfiles | ForEach-Object { "$($_.InterfaceAlias)=$($_.NetworkCategory)" }) -join "; ")
        }
        catch {
            Add-Result "Network profile" "Info" $_.Exception.Message
        }

        return @($results)
    }
}

function Global:Invoke-CSIRemoteManagementReadinessTarget {

param([string]$ComputerName)

    if(!$ComputerName -or $ComputerName -eq "." -or $ComputerName -eq $env:COMPUTERNAME){
        return @(& (Get-CSIRemoteManagementReadinessBlock))
    }

    $results = New-Object System.Collections.ArrayList

    function Add-RemoteReadinessResult {
        param([string]$Step,[string]$Status,[string]$Detail)
        [void]$results.Add([pscustomobject]@{
            ComputerName = $ComputerName
            Step = $Step
            Status = $Status
            Detail = $Detail
        })
    }

    try {
        $pingOk = Test-Connection -ComputerName $ComputerName -Count 1 -Quiet -ErrorAction Stop
        $pingStatus = if($pingOk){"OK"}else{"Warning"}
        $pingDetail = if($pingOk){"Ping responded."}else{"Ping did not respond. Firewall may block ICMP."}
        Add-RemoteReadinessResult "ICMP reachability" $pingStatus $pingDetail
    }
    catch {
        Add-RemoteReadinessResult "ICMP reachability" "Warning" $_.Exception.Message
    }

    try {
        $resolved = [System.Net.Dns]::GetHostEntry($ComputerName)
        Add-RemoteReadinessResult "DNS resolution" "OK" (($resolved.AddressList | ForEach-Object { $_.IPAddressToString }) -join ", ")
    }
    catch {
        Add-RemoteReadinessResult "DNS resolution" "Error" $_.Exception.Message
    }

    $winrmOk = $false
    try {
        Test-WSMan -ComputerName $ComputerName -ErrorAction Stop | Out-Null
        $winrmOk = $true
        Add-RemoteReadinessResult "WinRM connectivity" "OK" "Test-WSMan succeeded."
    }
    catch {
        Add-RemoteReadinessResult "WinRM connectivity" "Warning" $_.Exception.Message
    }

    try {
        $cim = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $ComputerName -ErrorAction Stop
        Add-RemoteReadinessResult "CIM/WMI connectivity" "OK" "$($cim.Caption) $($cim.Version)"
    }
    catch {
        Add-RemoteReadinessResult "CIM/WMI connectivity" "Warning" $_.Exception.Message
    }

    try {
        $adminShare = "\\$ComputerName\admin$"
        $shareOk = Test-Path $adminShare
        $shareStatus = if($shareOk){"OK"}else{"Warning"}
        $shareDetail = if($shareOk){"$adminShare is reachable."}else{"$adminShare is not reachable with current credentials/firewall."}
        Add-RemoteReadinessResult "Admin share" $shareStatus $shareDetail
    }
    catch {
        Add-RemoteReadinessResult "Admin share" "Warning" $_.Exception.Message
    }

    try {
        $services = @(Get-Service -ComputerName $ComputerName -Name WinRM,RemoteRegistry,RpcSs,LanmanServer,EventLog,Schedule -ErrorAction Stop)
        foreach($svc in $services){
            $status = if($svc.Status -eq "Running"){"OK"}elseif($svc.Name -eq "RemoteRegistry"){"Warning"}else{"Error"}
            Add-RemoteReadinessResult "Service $($svc.Name)" $status "Status=$($svc.Status)"
        }
    }
    catch {
        Add-RemoteReadinessResult "Remote service query" "Warning" $_.Exception.Message
    }

    if($winrmOk){
        try {
            $remoteDetails = @(Invoke-Command -ComputerName $ComputerName -ScriptBlock (Get-CSIRemoteManagementReadinessBlock) -ErrorAction Stop)
            foreach($detail in $remoteDetails){
                [void]$results.Add($detail)
            }
        }
        catch {
            Add-RemoteReadinessResult "Remote firewall/profile detail" "Warning" $_.Exception.Message
        }
    }
    else{
        Add-RemoteReadinessResult "Remote firewall/profile detail" "Info" "Skipped because WinRM is not reachable. Use Enable Remote Management or PsExec-based repair if appropriate."
    }

    return @($results)
}

function Global:Invoke-EnableRemoteManagement {

    Write-Host "ENABLE REMOTE MANAGEMENT" -ForegroundColor Cyan
    Write-Host "========================"
    Write-Host ""
    Write-Host "This can run locally or against remote computers."
    Write-Host "Remote mode uses WinRM when available, then falls back to bundled PsExec if needed."
    Write-Host ""

    if(Get-Command Test-CSIAdministrator -ErrorAction SilentlyContinue){
        if(!(Test-CSIAdministrator)){
            Write-Host "This tool must be run elevated." -ForegroundColor Yellow
            return
        }
    }

    $targetInput = Read-CSIInput "Target computer(s), comma separated. Blank = local computer" -AllowEmpty
    $targets = @()

    if([string]::IsNullOrWhiteSpace($targetInput)){
        $targets = @($env:COMPUTERNAME)
    }
    else{
        $targets = @($targetInput -split '[,;]' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    }

    if($targets.Count -eq 0){
        Write-Host "No target computers were entered." -ForegroundColor Yellow
        return
    }

    $methodInput = Read-CSIInput "Remote method [A=Auto, W=WinRM only, P=PsExec only] (default A)" -AllowEmpty
    $method = switch -Regex ($methodInput){
        '^(?i)w' { "WinRM"; break }
        '^(?i)p' { "PsExec"; break }
        default { "Auto" }
    }

    if($targets.Count -gt 1 -or $targets[0] -ne $env:COMPUTERNAME){
        Write-Host ""
        Write-Host "Targets:" -ForegroundColor Cyan
        $targets | ForEach-Object { Write-Host "  $_" }
        Write-Host "Method: $method"
        Write-Host ""
        $confirm = Read-CSIInput "Continue? Type YES" -AllowEmpty
        if($confirm -ne "YES"){
            Write-Host "Cancelled." -ForegroundColor Yellow
            return
        }
    }

    $allResults = @()

    foreach($target in $targets){
        Write-Host ""
        Write-Host "Processing $target..." -ForegroundColor Cyan

        $targetMethod = if($target -eq $env:COMPUTERNAME -or $target -eq "."){"Local"}else{$method}
        $results = @(Invoke-CSIEnableRemoteManagementTarget -ComputerName $target -Method $targetMethod)
        $allResults += $results
        Write-CSIRemoteManagementResults -Results $results

        try {
            $state = [pscustomobject]@{
                CapturedAt = (Get-Date).ToString("s")
                RequestedTarget = $target
                Method = $targetMethod
                Results = $results
            }

            if(Get-Command Set-CSIComputerStateSection -ErrorAction SilentlyContinue){
                [void](Set-CSIComputerStateSection -SectionName "RemoteManagement" -Data $state -ComputerName $target -Source "Invoke-EnableRemoteManagement")
            }
        }
        catch {}
    }

    Write-Host ""
    Write-Host "Remote management enablement finished. Review any Warning or Error lines before handing off the system." -ForegroundColor Cyan
}

function Global:Invoke-RemoteManagementReadiness {

    Write-Host "REMOTE MANAGEMENT READINESS" -ForegroundColor Cyan
    Write-Host "==========================="
    Write-Host ""
    Write-Host "Read-only check for WinRM, WMI/CIM, RPC/admin share, services, and firewall readiness."
    Write-Host ""

    $targetInput = Read-CSIInput "Target computer(s), comma separated. Blank = local computer" -AllowEmpty
    $targets = if([string]::IsNullOrWhiteSpace($targetInput)){
        @($env:COMPUTERNAME)
    }
    else{
        @($targetInput -split '[,;]' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    }

    if($targets.Count -eq 0){
        Write-Host "No target computers were entered." -ForegroundColor Yellow
        return
    }

    foreach($target in $targets){
        Write-Host ""
        Write-Host "Checking $target..." -ForegroundColor Cyan
        $results = @(Invoke-CSIRemoteManagementReadinessTarget -ComputerName $target)
        Write-CSIRemoteManagementResults -Results $results

        try {
            $state = [pscustomobject]@{
                CapturedAt = (Get-Date).ToString("s")
                RequestedTarget = $target
                Results = $results
            }

            if(Get-Command Set-CSIComputerStateSection -ErrorAction SilentlyContinue){
                [void](Set-CSIComputerStateSection -SectionName "RemoteManagementReadiness" -Data $state -ComputerName $target -Source "Invoke-RemoteManagementReadiness")
            }
        }
        catch {}
    }

    Write-Host ""
    Write-Host "Remote management readiness check finished." -ForegroundColor Cyan
}

Register-CSICommand `
    -Name "Enable Remote Management" `
    -Command "Invoke-EnableRemoteManagement" `
    -Category "Remote" `
    -Description "Enables WinRM, WMI/firewall remote administration rules, Remote Registry, and verifies WinRM listener state locally or on selected remote computers." `
    -Order 515 `
    -RequiresAdmin

Register-CSICommand `
    -Name "Remote Management Readiness" `
    -Command "Invoke-RemoteManagementReadiness" `
    -Category "Remote" `
    -Description "Read-only check for local or remote WinRM, WMI/CIM, RPC/admin share, services, and firewall readiness." `
    -Order 312
