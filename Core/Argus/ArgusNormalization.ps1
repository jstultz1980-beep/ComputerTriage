# =====================================================================
# ArgusNormalization.ps1
# ARGUS Normalization - Structured loaders and normalized evidence model
# =====================================================================

function Global:Get-ARGUSCapabilityStatus {
    param(
        [hashtable]$Capabilities,
        [string]$CapabilityKey
    )

    if(!$Capabilities -or !$CapabilityKey){
        return "unknown"
    }

    if($Capabilities.ContainsKey($CapabilityKey)){
        return [string]$Capabilities[$CapabilityKey]
    }

    return "unknown"
}

function Global:Get-ARGUSFindingDomain {
    param([object]$Finding)

    $title = ([string]$Finding.title).Trim().ToLowerInvariant()
    $tags = @($Finding.tags | ForEach-Object { ([string]$_).Trim().ToLowerInvariant() })
    $category = ([string]$Finding.category).Trim().ToLowerInvariant()

    $domainMap = @(
        @{ Domain = "storage"; Tokens = @("storage") },
        @{ Domain = "network"; Tokens = @("network","dhcp","apipa","dns","gateway") },
        @{ Domain = "updates"; Tokens = @("updates","update","windows update","wu") },
        @{ Domain = "securityProducts"; Tokens = @("security-products","securityproducts","defender","antivirus","endpoint protection") },
        @{ Domain = "services"; Tokens = @("services","service") },
        @{ Domain = "domainHealth"; Tokens = @("domainhealth","domain health","trust","logon","dc") },
        @{ Domain = "gpo"; Tokens = @("gpo","gpresult","group policy") },
        @{ Domain = "processes"; Tokens = @("processes","process") },
        @{ Domain = "drivers"; Tokens = @("drivers","driver") }
    )

    foreach($entry in $domainMap){
        foreach($token in $entry.Tokens){
            $normalizedToken = $token.ToLowerInvariant()
            if($title -eq $normalizedToken -or $category -eq $normalizedToken){
                return $entry.Domain
            }

            foreach($tag in $tags){
                if($tag -eq $normalizedToken){
                    return $entry.Domain
                }
            }
        }
    }

    if($category -eq "evidence" -or $title -match "Expected evidence category missing"){
        return "deterministicFindings"
    }

    return "general"
}

function Global:New-ARGUSCitationRecord {
    param(
        [Parameter(Mandatory=$true)][string]$SourceType,
        [Parameter(Mandatory=$true)][string]$Artifact,
        [string]$JsonPointer,
        [string]$Field,
        [object]$ObservedValue,
        [Parameter(Mandatory=$true)][int]$TrustRank
    )

    return [ordered]@{
        sourceType = $SourceType
        artifact = $Artifact
        jsonPointer = $JsonPointer
        field = $Field
        observedValue = if($null -ne $ObservedValue){ [string]$ObservedValue } else { $null }
        trustRank = $TrustRank
        runId = if($script:ARGUSBundleValidation){$script:ARGUSBundleValidation.Identity.runId}else{$null}
        bundleId = if($script:ARGUSBundleValidation){$script:ARGUSBundleValidation.Identity.bundleId}else{$null}
    }
}

function Global:Add-ARGUSCitationRecord {
    param(
        [Parameter(Mandatory=$true)][object]$Collection,
        [Parameter(Mandatory=$true)][object]$Seen,
        [Parameter(Mandatory=$true)][object]$Citation
    )

    $key = "{0}|{1}|{2}|{3}|{4}|{5}" -f $Citation.sourceType,$Citation.artifact,$Citation.jsonPointer,$Citation.field,$Citation.observedValue,$Citation.trustRank
    if($Seen.Add($key)){
        [void]$Collection.Add($Citation)
    }

    return $Citation
}

function Global:New-ARGUSFactRecord {
    param(
        [Parameter(Mandatory=$true)][string]$Id,
        [Parameter(Mandatory=$true)][string]$Domain,
        [Parameter(Mandatory=$true)][string]$Label,
        [Parameter(Mandatory=$true)][string]$Statement,
        [Parameter(Mandatory=$true)][string]$Severity,
        [Parameter(Mandatory=$true)][string]$Confidence,
        [Parameter(Mandatory=$true)][string]$SourceKind,
        [object[]]$Citations = @(),
        [object[]]$Limitations = @()
    )

    return [ordered]@{
        id = $Id
        domain = $Domain
        label = $Label
        statement = $Statement
        severity = $Severity
        confidence = $Confidence
        sourceKind = $SourceKind
        citations = @($Citations)
        limitations = @($Limitations)
    }
}

function Global:New-ARGUSGapRecord {
    param(
        [Parameter(Mandatory=$true)][string]$Domain,
        [Parameter(Mandatory=$true)][string]$Artifact,
        [Parameter(Mandatory=$true)][string]$Reason,
        [object[]]$BlockedConclusions = @(),
        [string]$RecommendedCollection = ""
    )

    return [ordered]@{
        domain = $Domain
        artifact = $Artifact
        reason = $Reason
        blockedConclusions = @($BlockedConclusions)
        recommendedCollection = $RecommendedCollection
    }
}

function Global:Get-ARGUSNextFactId {
    param([ref]$Counter)
    $Counter.Value++
    return ("ARGUS-FACT-{0:0001}" -f $Counter.Value)
}

function Global:Get-ARGUSDomainBlueprints {
    return @(
        [ordered]@{
            domain = "contractMetadata"
            capabilityKey = $null
            capabilityStatus = "supported"
            primaryArtifacts = @("Metadata/schema-version.json","Metadata/bundle-capabilities.json")
            normalizedArtifacts = @("Metadata/schema-version.json","Metadata/bundle-capabilities.json")
            rawEvidencePatterns = @("Bundle manifest files","Schema metadata")
            allowedConclusionLevel = "validation"
            missingEvidenceImpact = "Cannot validate schema compatibility or supported analysis mode."
            blockedConclusions = @("schema compatibility","capability routing")
            recommendedCollection = "Preserve the schema-version.json and bundle-capabilities.json contract files."
        }
        [ordered]@{
            domain = "evidenceQuality"
            capabilityKey = $null
            capabilityStatus = "supported"
            primaryArtifacts = @("Analysis/evidence-score.json")
            normalizedArtifacts = @("Analysis/evidence-score.json")
            rawEvidencePatterns = @("Evidence-score summary","Parser warnings")
            allowedConclusionLevel = "confidence-conditioning"
            missingEvidenceImpact = "Confidence and caveat scaling cannot be calibrated."
            blockedConclusions = @("confidence scaling","missing-evidence caveats")
            recommendedCollection = "Collect evidence-score data and parser warnings with the analysis bundle."
        }
        [ordered]@{
            domain = "deterministicFindings"
            capabilityKey = $null
            capabilityStatus = "supported"
            primaryArtifacts = @("Analysis/findings.json")
            normalizedArtifacts = @("Analysis/findings.json")
            rawEvidencePatterns = @("Deterministic rule output","Finding summaries")
            allowedConclusionLevel = "finding"
            missingEvidenceImpact = "Deterministic problem statements are unavailable."
            blockedConclusions = @("priority findings","deterministic problem framing")
            recommendedCollection = "Preserve findings.json from HEPHAESTUS local analysis."
        }
        [ordered]@{
            domain = "timeline"
            capabilityKey = $null
            capabilityStatus = "supported"
            primaryArtifacts = @("Analysis/timeline.json")
            normalizedArtifacts = @("Analysis/timeline.json")
            rawEvidencePatterns = @("Timeline events","Event sequencing")
            allowedConclusionLevel = "context"
            missingEvidenceImpact = "Temporal sequencing and event correlation are weaker."
            blockedConclusions = @("event sequence confidence","causal timing claims")
            recommendedCollection = "Preserve timeline.json and date-stamped event summaries."
        }
        [ordered]@{
            domain = "machineProfile"
            capabilityKey = $null
            capabilityStatus = "supported"
            primaryArtifacts = @("Analysis/normalized/machine-profile.json")
            normalizedArtifacts = @("Analysis/normalized/machine-profile.json")
            rawEvidencePatterns = @("System info","Computer identity","OS profile")
            allowedConclusionLevel = "context"
            missingEvidenceImpact = "Computer identity and environment context are reduced."
            blockedConclusions = @("machine identity claims","OS context claims")
            recommendedCollection = "Preserve the normalized machine-profile artifact."
        }
        [ordered]@{
            domain = "storage"
            capabilityKey = "storage"
            capabilityStatus = $null
            primaryArtifacts = @("Analysis/findings.json","Analysis/timeline.json")
            normalizedArtifacts = @("Analysis/findings.json","Analysis/timeline.json")
            rawEvidencePatterns = @("Disk inventory","Volume health","SMART status")
            allowedConclusionLevel = $null
            missingEvidenceImpact = "Storage-health and low-space conclusions may be incomplete."
            blockedConclusions = @("storage-health diagnosis","low-space root cause")
            recommendedCollection = "Collect storage evidence such as disk inventory, volume capacity, and health data."
        }
        [ordered]@{
            domain = "network"
            capabilityKey = "network"
            capabilityStatus = $null
            primaryArtifacts = @("Analysis/findings.json","Analysis/timeline.json")
            normalizedArtifacts = @("Analysis/findings.json","Analysis/timeline.json")
            rawEvidencePatterns = @("Adapter inventory","IP configuration","Route table","DNS results")
            allowedConclusionLevel = $null
            missingEvidenceImpact = "Network-path, DHCP, DNS, and gateway conclusions may be incomplete."
            blockedConclusions = @("network diagnosis","addressing/root-cause claims")
            recommendedCollection = "Collect adapter, IP configuration, route, DNS, and connectivity evidence."
        }
        [ordered]@{
            domain = "updates"
            capabilityKey = "updates"
            capabilityStatus = $null
            primaryArtifacts = @("Analysis/findings.json","Analysis/timeline.json")
            normalizedArtifacts = @("Analysis/findings.json","Analysis/timeline.json")
            rawEvidencePatterns = @("Windows Update state","Pending updates","Service health")
            allowedConclusionLevel = $null
            missingEvidenceImpact = "Windows Update repair and pending-update conclusions may be incomplete."
            blockedConclusions = @("update repair guidance","pending-update root-cause claims")
            recommendedCollection = "Collect Windows Update service and pending-update evidence."
        }
        [ordered]@{
            domain = "securityProducts"
            capabilityKey = "securityProducts"
            capabilityStatus = $null
            primaryArtifacts = @("Analysis/findings.json","Analysis/timeline.json")
            normalizedArtifacts = @("Analysis/findings.json","Analysis/timeline.json")
            rawEvidencePatterns = @("Defender state","AV status","Endpoint protection state")
            allowedConclusionLevel = $null
            missingEvidenceImpact = "Endpoint-protection conclusions may be incomplete."
            blockedConclusions = @("security posture claims","endpoint protection recommendations")
            recommendedCollection = "Collect endpoint-protection status and definition/update evidence."
        }
        [ordered]@{
            domain = "services"
            capabilityKey = "services"
            capabilityStatus = $null
            primaryArtifacts = @("Analysis/findings.json","Analysis/timeline.json")
            normalizedArtifacts = @("Analysis/findings.json","Analysis/timeline.json")
            rawEvidencePatterns = @("Service inventory","Automatic service state","Dependency state")
            allowedConclusionLevel = $null
            missingEvidenceImpact = "Stopped-service and dependency conclusions may be incomplete."
            blockedConclusions = @("service restart guidance","service dependency claims")
            recommendedCollection = "Collect service state and automatic service dependency evidence."
        }
        [ordered]@{
            domain = "domainHealth"
            capabilityKey = "domainHealth"
            capabilityStatus = $null
            primaryArtifacts = @("Analysis/findings.json","Analysis/timeline.json")
            normalizedArtifacts = @("Analysis/findings.json","Analysis/timeline.json")
            rawEvidencePatterns = @("Secure channel","Domain trust","Logon controller")
            allowedConclusionLevel = $null
            missingEvidenceImpact = "Domain trust, logon, and DC-path conclusions may be incomplete."
            blockedConclusions = @("domain trust diagnosis","logon/DC-path claims")
            recommendedCollection = "Collect secure-channel, trust, logon, and domain controller evidence."
        }
        [ordered]@{
            domain = "gpo"
            capabilityKey = "gpo"
            capabilityStatus = $null
            primaryArtifacts = @("Analysis/findings.json","Analysis/timeline.json")
            normalizedArtifacts = @("Analysis/findings.json","Analysis/timeline.json")
            rawEvidencePatterns = @("GPResult","Policy processing","Applied policy data")
            allowedConclusionLevel = $null
            missingEvidenceImpact = "Group Policy processing conclusions may be incomplete."
            blockedConclusions = @("policy-processing diagnosis","GPO compliance claims")
            recommendedCollection = "Collect GPResult or other Group Policy processing evidence."
        }
        [ordered]@{
            domain = "processes"
            capabilityKey = "processes"
            capabilityStatus = $null
            primaryArtifacts = @("Analysis/findings.json","Analysis/timeline.json")
            normalizedArtifacts = @("Analysis/findings.json","Analysis/timeline.json")
            rawEvidencePatterns = @("Process inventory","Startup inventory","Running processes")
            allowedConclusionLevel = $null
            missingEvidenceImpact = "Process-analysis conclusions are not yet available."
            blockedConclusions = @("process analysis","startup correlation")
            recommendedCollection = "Collect process inventory when process normalization is implemented."
        }
        [ordered]@{
            domain = "drivers"
            capabilityKey = "drivers"
            capabilityStatus = $null
            primaryArtifacts = @("Analysis/findings.json","Analysis/timeline.json")
            normalizedArtifacts = @("Analysis/findings.json","Analysis/timeline.json")
            rawEvidencePatterns = @("Driver inventory","Driver versions","Signed driver data")
            allowedConclusionLevel = $null
            missingEvidenceImpact = "Driver-analysis conclusions are not yet available."
            blockedConclusions = @("driver analysis","driver stability claims")
            recommendedCollection = "Collect driver inventory when driver normalization is implemented."
        }
        [ordered]@{
            domain = "rawEvidence"
            capabilityKey = $null
            capabilityStatus = "verification-only"
            primaryArtifacts = @("Original bundle files")
            normalizedArtifacts = @("Analysis/findings.json","Analysis/timeline.json","Analysis/normalized/machine-profile.json")
            rawEvidencePatterns = @("Original collector output","Command transcripts","Raw logs")
            allowedConclusionLevel = "verificationOnly"
            missingEvidenceImpact = "Raw evidence is not primary when deterministic or normalized evidence exists."
            blockedConclusions = @("raw-log first reasoning","guessing from unnormalized evidence")
            recommendedCollection = "Use raw evidence only to verify or enrich cited claims."
        }
    )
}

function Global:New-ARGUSNormalizedAnalysis {
    param(
        [Parameter(Mandatory=$true)][string]$BundleRoot,
        [Parameter(Mandatory=$true)][object]$Validation,
        [Parameter(Mandatory=$true)][hashtable]$Artifacts
    )

    $capabilityData = @{}
    $capabilities = $Artifacts["bundleCapabilities"].Data
    if($capabilities -and $capabilities.capabilities){
        foreach($property in $capabilities.capabilities.PSObject.Properties){
            $capabilityData[$property.Name] = [string]$property.Value
        }
    }

    $evidenceScore = $Artifacts["evidenceScore"].Data
    $findingsData = $Artifacts["findings"].Data
    $timelineData = $Artifacts["timeline"].Data
    $machineProfileData = $Artifacts["machineProfile"].Data
    $schemaData = $Artifacts["schemaVersion"].Data

    $citations = New-Object System.Collections.Generic.List[object]
    $citationKeys = New-Object System.Collections.Generic.HashSet[string]
    $facts = New-Object System.Collections.Generic.List[object]
    $gaps = New-Object System.Collections.Generic.List[object]

    foreach($requiredArtifact in @($Validation.requiredArtifacts | Where-Object { $_.status -ne "parsed" })) {
        $artifactName = [string]$requiredArtifact.path
        $artifactDomain = switch -Regex ($artifactName){
            "schema-version" { "contractMetadata" }
            "bundle-capabilities" { "contractMetadata" }
            "evidence-score" { "evidenceQuality" }
            "findings" { "deterministicFindings" }
            "timeline" { "timeline" }
            "machine-profile" { "machineProfile" }
            default { "contractMetadata" }
        }

        [void]$gaps.Add((New-ARGUSGapRecord -Domain $artifactDomain -Artifact $artifactName -Reason ("Required artifact {0} is {1}: {2}" -f $artifactName,$requiredArtifact.status,$requiredArtifact.message) -BlockedConclusions @("normal ARGUS analysis","strong evidence claims") -RecommendedCollection "Restore the missing or parseable HEPHAESTUS artifact before relying on ARGUS output."))
    }

    $factCounter = 0

    function Add-NormalizedCitation {
        param([object]$Citation)
        [void](Add-ARGUSCitationRecord -Collection $citations -Seen $citationKeys -Citation $Citation)
        return $Citation
    }

    $schemaVersion = if($schemaData){ [string]$schemaData.schemaVersion } else { $null }
    $schemaCitation = Add-NormalizedCitation (New-ARGUSCitationRecord -SourceType "metadata" -Artifact "Metadata/schema-version.json" -JsonPointer "/schemaVersion" -Field "schemaVersion" -ObservedValue $schemaVersion -TrustRank 1)
    [void]$facts.Add((New-ARGUSFactRecord -Id (Get-ARGUSNextFactId -Counter ([ref]$factCounter)) -Domain "contractMetadata" -Label "schemaVersion" -Statement ("HEPHAESTUS schema version is {0}." -f $schemaVersion) -Severity "informational" -Confidence "confirmed" -SourceKind "metadata" -Citations @($schemaCitation) -Limitations @("Schema version confirms contract compatibility, not health.")))

    $supported = @()
    $partial = @()
    $planned = @()
    if($capabilities -and $capabilities.capabilities){
        foreach($property in $capabilities.capabilities.PSObject.Properties){
            $status = ([string]$property.Value).ToLowerInvariant()
            switch($status){
                "supported" { $supported += $property.Name }
                "partial" { $partial += $property.Name }
                "planned" { $planned += $property.Name }
                "missing" { $planned += $property.Name }
                "skipped" { $planned += $property.Name }
                "not_implemented" { $planned += $property.Name }
            }

            if(@("partial","planned","missing","skipped","not_implemented") -contains $status){
                $citation = Add-NormalizedCitation (New-ARGUSCitationRecord -SourceType "metadata" -Artifact "Metadata/bundle-capabilities.json" -JsonPointer ("/capabilities/{0}" -f $property.Name) -Field $property.Name -ObservedValue $property.Value -TrustRank 2)
                [void]$facts.Add((New-ARGUSFactRecord -Id (Get-ARGUSNextFactId -Counter ([ref]$factCounter)) -Domain ([string]$property.Name) -Label ("capability-{0}" -f $property.Name) -Statement ("Bundle capability {0} is {1}." -f $property.Name,$property.Value) -Severity "informational" -Confidence "unsupported" -SourceKind "metadata" -Citations @($citation) -Limitations @("Capability is not fully supported for first-release ARGUS analysis.")))
            }
        }
    }

    if($supported.Count -gt 0 -or $partial.Count -gt 0 -or $planned.Count -gt 0){
        $capabilityCitation = Add-NormalizedCitation (New-ARGUSCitationRecord -SourceType "metadata" -Artifact "Metadata/bundle-capabilities.json" -JsonPointer "/capabilities" -Field "capabilities" -ObservedValue ("supported={0}; partial={1}; planned={2}" -f ($supported -join ","),($partial -join ","),($planned -join ",")) -TrustRank 2)
        [void]$facts.Add((New-ARGUSFactRecord -Id (Get-ARGUSNextFactId -Counter ([ref]$factCounter)) -Domain "contractMetadata" -Label "bundleCapabilities" -Statement ("Bundle capabilities parsed with {0} supported, {1} partial, and {2} planned domains." -f $supported.Count,$partial.Count,$planned.Count) -Severity "informational" -Confidence "confirmed" -SourceKind "metadata" -Citations @($capabilityCitation) -Limitations @("Capability status informs confidence and domain availability; it is not a health conclusion.")))
    }

    if($evidenceScore){
        $qualityBand = Get-ARGUSEvidenceQualityBand -EvidenceScore $evidenceScore
        $qualityCitation = Add-NormalizedCitation (New-ARGUSCitationRecord -SourceType "evidenceQuality" -Artifact "Analysis/evidence-score.json" -JsonPointer "/overallScore" -Field "overallScore" -ObservedValue $evidenceScore.overallScore -TrustRank 3)
        [void]$facts.Add((New-ARGUSFactRecord -Id (Get-ARGUSNextFactId -Counter ([ref]$factCounter)) -Domain "evidenceQuality" -Label "evidenceScores" -Statement ("Evidence quality scores are overall {0}, completeness {1}, quality {2} ({3})." -f $evidenceScore.overallScore,$evidenceScore.completenessScore,$evidenceScore.qualityScore,$qualityBand) -Severity "informational" -Confidence "confirmed" -SourceKind "evidenceQuality" -Citations @($qualityCitation) -Limitations @("Evidence quality calibrates confidence; it does not replace deterministic findings.")))
    }
    else{
        $qualityBand = "unknown"
    }

    if($machineProfileData -and $machineProfileData.machine){
        $machine = $machineProfileData.machine
        $machineFields = @(
            @{ Label = "computerName"; Field = "computerName"; Value = $machine.computerName },
            @{ Label = "domain"; Field = "domain"; Value = $machine.domain },
            @{ Label = "osCaption"; Field = "osCaption"; Value = $machine.osCaption },
            @{ Label = "osVersion"; Field = "osVersion"; Value = $machine.osVersion },
            @{ Label = "manufacturerModel"; Field = "model"; Value = ("{0} {1}" -f $machine.manufacturer,$machine.model).Trim() }
        )

        foreach($field in $machineFields){
            $citation = Add-NormalizedCitation (New-ARGUSCitationRecord -SourceType "normalizedEvidence" -Artifact "Analysis/normalized/machine-profile.json" -JsonPointer ("/machine/{0}" -f $field.Field) -Field $field.Field -ObservedValue $field.Value -TrustRank 6)
            [void]$facts.Add((New-ARGUSFactRecord -Id (Get-ARGUSNextFactId -Counter ([ref]$factCounter)) -Domain "machineProfile" -Label $field.Label -Statement ("Machine profile {0} is {1}." -f $field.Label,$field.Value) -Severity "informational" -Confidence "high" -SourceKind "normalizedEvidence" -Citations @($citation) -Limitations @("Environment context only; not a health conclusion.")))
        }
    }

    if($findingsData -and $findingsData.findings){
        $findings = @($findingsData.findings)
        for($i = 0; $i -lt $findings.Count; $i++){
            $finding = $findings[$i]
            $domain = Get-ARGUSFindingDomain -Finding $finding
            $citation = Add-NormalizedCitation (New-ARGUSCitationRecord -SourceType "deterministicFinding" -Artifact "Analysis/findings.json" -JsonPointer ("/findings/{0}" -f $i) -Field "finding" -ObservedValue $finding.title -TrustRank 4)
            $statement = if($finding.summary){ [string]$finding.summary } else { [string]$finding.title }
            $upstreamConfidence = ([string]$finding.confidence).ToLowerInvariant()
            $boundedConfidence = if($qualityBand -eq 'low'){'low'}elseif($qualityBand -eq 'partial' -and $upstreamConfidence -in @('confirmed','high')){'medium'}else{$upstreamConfidence}
            [void]$facts.Add((New-ARGUSFactRecord -Id (Get-ARGUSNextFactId -Counter ([ref]$factCounter)) -Domain $domain -Label ([string]$finding.id) -Statement $statement -Severity ([string]$finding.severity) -Confidence $boundedConfidence -SourceKind "deterministicFinding" -Citations @($citation) -Limitations @("Deterministic HEPHAESTUS finding; ARGUS confidence is capped by verified evidence quality.")))

            $recommended = if($finding.recommendations -and @($finding.recommendations).Count -gt 0){
                [string](@($finding.recommendations) -join " ")
            }
            else{
                "Collect additional evidence for the same category before drawing stronger conclusions."
            }

            [void]$gaps.Add((New-ARGUSGapRecord -Domain $domain -Artifact "Analysis/findings.json" -Reason $statement -BlockedConclusions @("root-cause certainty","strong remediation claims") -RecommendedCollection $recommended))
        }
    }

    if($timelineData -and $timelineData.events){
        $events = @($timelineData.events)
        for($i = 0; $i -lt [Math]::Min($events.Count, 10); $i++){
            $event = $events[$i]
            $timelineConfidence = if($event.timestampType -eq "sourceEventTime"){"medium"}else{"unsupported"}
            $citation = Add-NormalizedCitation (New-ARGUSCitationRecord -SourceType "timelineEvent" -Artifact "Analysis/timeline.json" -JsonPointer ("/events/{0}" -f $i) -Field "event" -ObservedValue $event.title -TrustRank 5)
            [void]$facts.Add((New-ARGUSFactRecord -Id (Get-ARGUSNextFactId -Counter ([ref]$factCounter)) -Domain "timeline" -Label ("event-{0}" -f ($i + 1)) -Statement ("Timeline event {0} from {1} records {2}." -f ($i + 1),$event.source,$event.title) -Severity "informational" -Confidence $timelineConfidence -SourceKind "timelineEvent" -Citations @($citation) -Limitations @("Timestamp semantics: $($event.timestampType). Temporal context only; no causality without supporting findings.")))
        }
    }

    $domainRecords = New-Object System.Collections.Generic.List[object]
    foreach($blueprint in (Get-ARGUSDomainBlueprints)){
        $status = if($blueprint.capabilityKey){
            Get-ARGUSCapabilityStatus -Capabilities $capabilityData -CapabilityKey $blueprint.capabilityKey
        }
        else{
            $blueprint.capabilityStatus
        }

        $supportLevel = switch(([string]$status).ToLowerInvariant()){
            "supported" { "supported" }
            "partial" { "partial" }
            "verification-only" { "verification-only" }
            default { [string]$status }
        }

        $allowedConclusionLevel = switch($blueprint.domain){
            "contractMetadata" { "validation" }
            "evidenceQuality" { "confidence-conditioning" }
            "deterministicFindings" { "finding" }
            "timeline" { "context" }
            "machineProfile" { "context" }
            "rawEvidence" { "verificationOnly" }
            default {
                switch(([string]$status).ToLowerInvariant()){
                    "supported" { "finding" }
                    "partial" { "limitedFinding" }
                    default { "unsupported" }
                }
            }
        }

        [void]$domainRecords.Add([ordered]@{
            domain = $blueprint.domain
            capabilityStatus = $status
            supportLevel = $supportLevel
            primaryArtifacts = @($blueprint.primaryArtifacts)
            normalizedArtifacts = @($blueprint.normalizedArtifacts)
            rawEvidencePatterns = @($blueprint.rawEvidencePatterns)
            allowedConclusionLevel = $allowedConclusionLevel
            missingEvidenceImpact = $blueprint.missingEvidenceImpact
        })

        if($blueprint.domain -in @("storage","network","updates","securityProducts","services","domainHealth","gpo","processes","drivers")){
            $domainStatus = [string]$status
            if($domainStatus -eq "partial" -or $domainStatus -match '^(planned|missing|skipped|not_implemented)$'){
                $gapArtifact = if($domainStatus -eq "partial"){ "Analysis/evidence-score.json" } else { "Metadata/bundle-capabilities.json" }
                $gapReason = if($domainStatus -eq "partial"){
                    "Capability is partial; ARGUS can only make limited conclusions for this domain."
                }
                else{
                    "Capability is $domainStatus; ARGUS cannot make first-release conclusions for this domain."
                }

                $gapCollection = if($blueprint.recommendedCollection){ [string]$blueprint.recommendedCollection } else { "Collect the missing domain evidence." }
                [void]$gaps.Add((New-ARGUSGapRecord -Domain $blueprint.domain -Artifact $gapArtifact -Reason $gapReason -BlockedConclusions @($blueprint.blockedConclusions) -RecommendedCollection $gapCollection))
            }
        }
    }

    if($qualityBand -eq "partial" -or $qualityBand -eq "low"){
        [void]$gaps.Add((New-ARGUSGapRecord -Domain "evidenceQuality" -Artifact "Analysis/evidence-score.json" -Reason ("Evidence quality is {0}; ARGUS must avoid strong root-cause language." -f $qualityBand) -BlockedConclusions @("strong root-cause language","high-confidence remediation claims") -RecommendedCollection "Collect additional supporting evidence and parser warnings before drawing stronger conclusions."))
    }

    $normalized = New-ARGUSBaseArtifact -BundleRoot $BundleRoot -ArtifactType "normalized-analysis"
    $normalized["inputValidationStatus"] = $Validation.status
    $normalized["inputValidationMode"] = $Validation.mode
    $normalized["evidenceQuality"] = [ordered]@{
        label = "normalizedEvidence"
        overallScore = if($evidenceScore){$evidenceScore.overallScore}else{$null}
        completenessScore = if($evidenceScore){$evidenceScore.completenessScore}else{$null}
        qualityScore = if($evidenceScore){$evidenceScore.qualityScore}else{$null}
        qualityBand = $qualityBand
        warnings = if($evidenceScore){@($evidenceScore.warnings)}else{@()}
        caveat = switch($qualityBand){
            "high" { "Evidence quality is high enough for normal prioritization." }
            "partial" { "Evidence is partial. ARGUS should include missing-evidence caveats and avoid strong root-cause language." }
            "low" { "Evidence is low. ARGUS should request more evidence and avoid strong root-cause language." }
            default { "Evidence quality is unknown because evidence-score data was unavailable." }
        }
    }
    $normalized["domains"] = @($domainRecords.ToArray())
    $normalized["facts"] = @($facts.ToArray())
    $normalized["gaps"] = @($gaps.ToArray())
    $normalized["citations"] = @($citations.ToArray())

    return $normalized
}



