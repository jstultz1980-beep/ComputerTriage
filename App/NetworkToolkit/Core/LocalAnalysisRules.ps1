# =====================================================================
# LocalAnalysisRules.ps1
# HEPHAESTUS deterministic rule catalog expansion
# =====================================================================

function Global:Get-HEPRawEvidenceItems {
    param([object[]]$Inventory)

    return @($Inventory | Where-Object {
        $_.RelativePath -notmatch '^(Analysis|ARGUS|Metadata)[\\/]' -and
        $_.Extension -in @(".txt",".log",".json",".csv",".xml",".html",".htm")
    })
}

function Global:Get-HEPEvidenceText {
    param(
        [object[]]$Inventory,
        [string[]]$Patterns,
        [int]$MaxBytes = 1048576
    )

    $rawItems = @(Get-HEPRawEvidenceItems -Inventory $Inventory)
    foreach($pattern in $Patterns){
        $match = $rawItems | Where-Object { $_.RelativePath -match $pattern -or $_.Name -match $pattern } | Select-Object -First 1
        if(!$match -or $match.Length -gt $MaxBytes){ continue }

        try {
            return [pscustomobject]@{
                Artifact = $match.RelativePath
                Text = Get-Content -LiteralPath $match.FullName -Raw -ErrorAction Stop
            }
        }
        catch {
            return [pscustomobject]@{
                Artifact = $match.RelativePath
                Text = ""
                Warning = $_.Exception.Message
            }
        }
    }

    return $null
}

function Global:New-HEPFindings {
    param(
        [Parameter(Mandatory=$true)][string]$BundleRoot,
        [object[]]$Inventory,
        [object]$EvidenceScore
    )

    $artifact = New-HEPBaseArtifact -BundleRoot $BundleRoot
    $findings = @()
    $counter = 1

    foreach($category in @($EvidenceScore.categories)){
        if($category.status -eq "missing"){
            $id = "HEP-FINDING-{0:0000}" -f $counter
            $findings += New-HEPFinding `
                -Id $id `
                -RuleId "HEP-RULE-EVIDENCE-001" `
                -Title "Expected evidence category missing: $($category.category)" `
                -Summary "The local analysis engine did not find evidence for $($category.category). Findings that depend on this category may be incomplete." `
                -Severity "informational" `
                -Confidence "confirmed" `
                -Category "evidence" `
                -Evidence @([ordered]@{ artifact = $BundleRoot; field = "category"; value = $category.category }) `
                -Recommendations @("Confirm whether the collector is expected to gather $($category.category) evidence on this computer.") `
                -Tags @("missing-evidence", $category.category)
            $counter++
        }
    }

    $networkEvidence = Get-HEPEvidenceText -Inventory $Inventory -Patterns @("ipconfig", "network", "adapter")
    if($networkEvidence -and $networkEvidence.Text -match '\b169\.254\.\d{1,3}\.\d{1,3}\b'){
        $id = "HEP-FINDING-{0:0000}" -f $counter
        $findings += New-HEPFinding `
            -Id $id `
            -RuleId "HEP-RULE-NETWORK-001" `
            -Title "APIPA address observed in network evidence" `
            -Summary "Network evidence contains an automatic private 169.254.x.x address, which usually indicates DHCP assignment failed on at least one adapter." `
            -Severity "medium" `
            -Confidence "high" `
            -Category "network" `
            -Evidence @([ordered]@{ artifact = $networkEvidence.Artifact; field = "IPv4Address"; value = $matches[0] }) `
            -Recommendations @("Check DHCP reachability, VLAN or switch port assignment, adapter link state, and recent IP configuration changes.") `
            -Tags @("network", "dhcp", "apipa")
        $counter++
    }

    $updateEvidence = Get-HEPEvidenceText -Inventory $Inventory -Patterns @("windows.?update", "update", "hotfix", "patch")
    if($updateEvidence -and $updateEvidence.Text -match '(?im)\b(wuauserv|bits|usosvc)\b.*\b(disabled|missing)\b'){
        $id = "HEP-FINDING-{0:0000}" -f $counter
        $findings += New-HEPFinding `
            -Id $id `
            -RuleId "HEP-RULE-UPDATES-001" `
            -Title "Windows Update service repair is indicated" `
            -Summary "Windows Update evidence reports a required update service as disabled or missing." `
            -Severity "medium" `
            -Confidence "high" `
            -Category "updates" `
            -Evidence @([ordered]@{ artifact = $updateEvidence.Artifact; field = "ServiceState"; value = $matches[0] }) `
            -Recommendations @("Run the Windows Update repair workflow, then rescan update health and pending reboot state.") `
            -Tags @("updates", "service-health", "repair")
        $counter++
    }

    $securityEvidence = Get-HEPEvidenceText -Inventory $Inventory -Patterns @("defender", "security", "antivirus", "edr")
    if($securityEvidence -and ($securityEvidence.Text -match '(?im)\b(RealTimeProtectionEnabled|Real.?Time.*Protection)\b\s*[:=]\s*(false|0|disabled)\b' -or $securityEvidence.Text -match '(?im)\b(defender|antivirus)\b.*\b(disabled|not running)\b')){
        $id = "HEP-FINDING-{0:0000}" -f $counter
        $findings += New-HEPFinding `
            -Id $id `
            -RuleId "HEP-RULE-SECURITY-001" `
            -Title "Endpoint protection appears disabled" `
            -Summary "Security evidence indicates Defender or real-time endpoint protection is disabled or not running." `
            -Severity "high" `
            -Confidence "high" `
            -Category "security-products" `
            -Evidence @([ordered]@{ artifact = $securityEvidence.Artifact; field = "ProtectionState"; value = $matches[0] }) `
            -Recommendations @("Confirm the intended security product, restore real-time protection, and verify signatures or EDR health before closing the case.") `
            -Tags @("security", "defender", "endpoint-protection")
        $counter++
    }

    $serviceEvidence = Get-HEPEvidenceText -Inventory $Inventory -Patterns @("service", "services")
    if($serviceEvidence -and ($serviceEvidence.Text -match '(?im)^\s*([A-Za-z0-9_.-]+)\s+Stopped\s+Automatic\b' -or $serviceEvidence.Text -match '(?ims)\bName\s*[:=]\s*([A-Za-z0-9_.-]+).*?\bStatus\s*[:=]\s*Stopped.*?\b(StartType|StartupType)\s*[:=]\s*Automatic')){
        $serviceName = if($matches.Count -gt 1){$matches[1]}else{"unknown"}
        $id = "HEP-FINDING-{0:0000}" -f $counter
        $findings += New-HEPFinding `
            -Id $id `
            -RuleId "HEP-RULE-SERVICES-001" `
            -Title "Automatic service is stopped" `
            -Summary "Service evidence shows automatic service '$serviceName' is stopped." `
            -Severity "medium" `
            -Confidence "medium" `
            -Category "services" `
            -Evidence @([ordered]@{ artifact = $serviceEvidence.Artifact; field = "Service"; value = $matches[0] }) `
            -Recommendations @("Verify whether '$serviceName' is expected to run, then inspect service dependencies and recent service-control events.") `
            -Tags @("services", "stopped-automatic")
        $counter++
    }

    $domainEvidence = Get-HEPEvidenceText -Inventory $Inventory -Patterns @("domain", "gpo", "gpresult", "dcdiag", "nltest", "secure.?channel")
    if($domainEvidence -and ($domainEvidence.Text -match '(?im)(secure channel|trust relationship).*(failed|broken)' -or $domainEvidence.Text -match '(?im)no logon servers available')){
        $id = "HEP-FINDING-{0:0000}" -f $counter
        $findings += New-HEPFinding `
            -Id $id `
            -RuleId "HEP-RULE-DOMAIN-001" `
            -Title "Domain trust or logon path failure detected" `
            -Summary "Domain evidence indicates a broken secure channel, trust failure, or unavailable logon servers." `
            -Severity "high" `
            -Confidence "high" `
            -Category "domain-health" `
            -Evidence @([ordered]@{ artifact = $domainEvidence.Artifact; field = "DomainHealth"; value = $matches[0] }) `
            -Recommendations @("Verify DNS and domain controller reachability, secure channel state, time sync, and computer account health before rejoining the domain.") `
            -Tags @("domain", "secure-channel", "logon")
        $counter++
    }

    $artifact["findings"] = @($findings)
    return $artifact
}

function Global:New-HEPBundleCapabilities {
    param([Parameter(Mandatory=$true)][string]$BundleRoot)

    return [ordered]@{
        schemaVersion = "1.0"
        generatedAtUtc = New-HEPAnalysisTimestamp
        analysisEngineVersion = "1.0.0"
        generator = "HEPHAESTUS Local Analysis Engine"
        sourceBundle = New-HEPSourceBundleInfo -BundleRoot $BundleRoot
        capabilities = [ordered]@{
            machineProfile = "supported"
            services = "partial"
            processes = "planned"
            drivers = "planned"
            network = "partial"
            storage = "partial"
            updates = "partial"
            securityProducts = "partial"
            domainHealth = "partial"
            gpo = "partial"
            localHtmlReport = "supported"
        }
        tools = @()
    }
}
