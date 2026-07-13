# =====================================================================
# ArgusRecommendations.ps1
# ARGUS Diagnostic Grouping and Technician Recommendations
# =====================================================================

function Global:Get-ARGUSRecommendationSeverityRank {
    param([string]$Severity)

    switch(([string]$Severity).ToLowerInvariant()){
        "critical" { return 1 }
        "high" { return 2 }
        "medium" { return 3 }
        "low" { return 4 }
        "informational" { return 5 }
        default { return 6 }
    }
}

function Global:Get-ARGUSRecommendationConfidenceRank {
    param([string]$Confidence)

    switch(([string]$Confidence).ToLowerInvariant()){
        "confirmed" { return 1 }
        "high" { return 2 }
        "medium" { return 3 }
        "low" { return 4 }
        "unsupported" { return 5 }
        default { return 6 }
    }
}

function Global:Get-ARGUSRecommendationPriority {
    param(
        [string]$Severity,
        [string]$Confidence,
        [bool]$HasBlockingGaps
    )

    if($HasBlockingGaps -and ([string]$Confidence).ToLowerInvariant() -eq "unsupported"){
        return "evidence-needed"
    }

    switch(([string]$Severity).ToLowerInvariant()){
        "critical" { return "urgent" }
        "high" { return "high" }
        "medium" { return "normal" }
        "low" { return "low" }
        default {
            if($HasBlockingGaps){ return "evidence-needed" }
            return "low"
        }
    }
}

function Global:Get-ARGUSRecommendationPriorityRank {
    param([string]$Priority)
    switch(([string]$Priority).ToLowerInvariant()){
        'urgent' {1}; 'high' {2}; 'normal' {3}; 'low' {4}; 'evidence-needed' {5}; default {6}
    }
}

function Global:Get-ARGUSRecommendationActionArea {
    param([string]$Domain)

    switch($Domain){
        "network" { return "Network connectivity" }
        "updates" { return "Windows Update repair" }
        "securityProducts" { return "Endpoint protection" }
        "services" { return "Service health" }
        "domainHealth" { return "Domain trust and logon" }
        "gpo" { return "Group Policy" }
        "storage" { return "Storage health" }
        "evidenceQuality" { return "Evidence collection" }
        "deterministicFindings" { return "Finding review" }
        "timeline" { return "Timeline review" }
        "machineProfile" { return "Machine context" }
        default { return "Technician review" }
    }
}

function Global:Get-ARGUSRecommendationAction {
    param(
        [string]$Domain,
        [object[]]$Facts,
        [object[]]$Gaps
    )

    $gap = @($Gaps | Select-Object -First 1)
    if($Facts.Count -eq 0 -and $gap.Count -gt 0){
        return [string]$gap[0].recommendedCollection
    }

    switch($Domain){
        "network" { return "Review adapter addressing, DHCP, DNS, default gateway, and connectivity evidence before changing network configuration." }
        "updates" { return "Review Windows Update service state and pending update evidence, then perform the documented repair path only if service evidence supports it." }
        "securityProducts" { return "Review endpoint protection status, definitions, and policy ownership before making security-product changes." }
        "services" { return "Review stopped automatic services and dependencies, then restart or repair only the affected service path." }
        "domainHealth" { return "Review secure-channel, logon controller, and domain trust evidence before attempting domain repair." }
        "gpo" { return "Collect or review GPResult and policy processing evidence before drawing Group Policy conclusions." }
        "storage" { return "Review volume capacity, disk health, and storage inventory before cleanup or hardware action." }
        "evidenceQuality" { return "Collect the missing or weak evidence called out by ARGUS before relying on stronger conclusions." }
        default { return "Review the cited deterministic findings and normalized facts, then collect missing evidence before remediation." }
    }
}

function Global:Get-ARGUSRecommendationWhy {
    param(
        [string]$Domain,
        [object[]]$Facts,
        [object[]]$Gaps
    )

    $problemFacts = @($Facts | Where-Object { $_.sourceKind -eq "deterministicFinding" -and $_.severity -ne "informational" })
    if($problemFacts.Count -gt 0){
        return ("ARGUS grouped {0} deterministic finding(s) in {1}; recommendations remain tied to cited HEPHAESTUS evidence." -f $problemFacts.Count,(Get-ARGUSRecommendationActionArea -Domain $Domain))
    }

    if($Gaps.Count -gt 0){
        return ("ARGUS cannot determine stronger {0} conclusions because required or supported evidence is limited or missing." -f (Get-ARGUSRecommendationActionArea -Domain $Domain))
    }

    return ("ARGUS found contextual {0} facts but no deterministic problem finding for this area." -f (Get-ARGUSRecommendationActionArea -Domain $Domain))
}

function Global:Select-ARGUSCitations {
    param([object[]]$Facts)

    $seen = New-Object System.Collections.Generic.HashSet[string]
    $citations = New-Object System.Collections.Generic.List[object]

    foreach($fact in @($Facts)){
        foreach($citation in @($fact.citations)){
            $key = "{0}|{1}|{2}|{3}|{4}" -f $citation.sourceType,$citation.artifact,$citation.jsonPointer,$citation.field,$citation.observedValue
            if($seen.Add($key)){
                [void]$citations.Add($citation)
            }
        }
    }

    return @($citations.ToArray())
}

function Global:Get-ARGUSDomainGaps {
    param(
        [object[]]$Gaps,
        [string]$Domain
    )

    return @($Gaps | Where-Object {
        $_.domain -eq $Domain -or
        ($Domain -ne "evidenceQuality" -and $_.domain -eq "evidenceQuality")
    })
}

function Global:New-ARGUSDiagnosticGroups {
    param([Parameter(Mandatory=$true)][object]$NormalizedAnalysis)

    $groups = New-Object System.Collections.Generic.List[object]
    $facts = @($NormalizedAnalysis.facts)
    $gaps = @($NormalizedAnalysis.gaps)
    $domains = @(@($facts | ForEach-Object { $_.domain }) + @($gaps | ForEach-Object { $_.domain }) | Where-Object { ![string]::IsNullOrWhiteSpace([string]$_) } | Sort-Object -Unique)
    $counter = 0

    foreach($domainName in $domains){
        $domain = [string]$domainName
        if([string]::IsNullOrWhiteSpace($domain)){ continue }

        $domainFacts = @($facts | Where-Object { $_.domain -eq $domain })
        $problemFacts = @($domainFacts | Where-Object { $_.sourceKind -eq "deterministicFinding" -and $_.severity -ne "informational" })
        $domainGaps = Get-ARGUSDomainGaps -Gaps $gaps -Domain $domain

        if($problemFacts.Count -eq 0 -and $domainGaps.Count -eq 0 -and $domain -notin @("evidenceQuality","contractMetadata")){
            continue
        }

        $counter++
        $orderedFacts = @($domainFacts | Sort-Object @{ Expression = { Get-ARGUSRecommendationSeverityRank $_.severity } }, @{ Expression = { Get-ARGUSRecommendationConfidenceRank $_.confidence } }, id)
        $primaryFact = $null
        if($orderedFacts.Count -gt 0){ $primaryFact = $orderedFacts[0] }

        $severity = "informational"
        $confidence = "unsupported"
        if($primaryFact){
            $severity = [string]$primaryFact.severity
            $confidence = [string]$primaryFact.confidence
        }

        $hasBlockingGaps = $domainGaps.Count -gt 0
        $priority = Get-ARGUSRecommendationPriority -Severity $severity -Confidence $confidence -HasBlockingGaps $hasBlockingGaps
        $citations = @(Select-ARGUSCitations -Facts $orderedFacts)
        foreach($gap in $domainGaps){
            $citations += [ordered]@{
                sourceType = "evidenceQuality"
                artifact = $gap.artifact
                jsonPointer = $null
                field = "gap"
                observedValue = $gap.reason
                trustRank = 3
            }
        }
        $actionArea = Get-ARGUSRecommendationActionArea -Domain $domain

        $rootCauseCandidates = @()
        if($problemFacts.Count -gt 0){
            $rootCauseCandidates = @($problemFacts | ForEach-Object {
                [ordered]@{
                    statement = $_.statement
                    confidence = $_.confidence
                    evidenceBoundary = "deterministicFinding"
                    limitations = @($_.limitations)
                }
            })
        }
        elseif($domainGaps.Count -gt 0){
            $rootCauseCandidates = @(
                [ordered]@{
                    statement = "ARGUS cannot determine a root-cause candidate for this group from available evidence."
                    confidence = "unsupported"
                    evidenceBoundary = "unsupported"
                    limitations = @($domainGaps | ForEach-Object { $_.reason })
                }
            )
        }

        [void]$groups.Add([ordered]@{
            id = ("ARGUS-GROUP-{0:0001}" -f $counter)
            title = $actionArea
            domain = $domain
            actionArea = $actionArea
            priority = $priority
            confidence = $confidence
            summary = Get-ARGUSRecommendationWhy -Domain $domain -Facts $orderedFacts -Gaps $domainGaps
            facts = @($orderedFacts | ForEach-Object { $_.id })
            rootCauseCandidates = @($rootCauseCandidates)
            citations = @($citations)
            blockedByMissingEvidence = @($domainGaps | ForEach-Object {
                [ordered]@{
                    artifact = $_.artifact
                    reason = $_.reason
                    blockedConclusions = @($_.blockedConclusions)
                    recommendedCollection = $_.recommendedCollection
                }
            })
            limitations = @($orderedFacts | ForEach-Object { $_.limitations } | ForEach-Object { $_ })
        })
    }

    if($groups.Count -eq 0){
        [void]$groups.Add([ordered]@{
            id = "ARGUS-GROUP-0001"
            title = "No grouped diagnostic issues"
            domain = "general"
            actionArea = "Technician review"
            priority = "low"
            confidence = "medium"
            summary = "ARGUS did not find deterministic problem findings in the normalized analysis."
            facts = @()
            rootCauseCandidates = @()
            citations = @()
            blockedByMissingEvidence = @()
            limitations = @("Absence of findings is not proof of absence; it reflects the available HEPHAESTUS evidence.")
        })
    }

    return @($groups.ToArray())
}

function Global:New-ARGUSRecommendations {
    param(
        [Parameter(Mandatory=$true)][object]$NormalizedAnalysis,
        [Parameter(Mandatory=$true)][object[]]$DiagnosticGroups
    )

    $recommendations = New-Object System.Collections.Generic.List[object]
    $counter = 0

    foreach($group in @($DiagnosticGroups | Sort-Object @{ Expression = { Get-ARGUSRecommendationPriorityRank $_.priority } }, id)){
        $counter++
        $blocked = @($group.blockedByMissingEvidence)
        $safeToAutomate = $false
        $confidence = [string]$group.confidence
        if($confidence -eq "confirmed" -and $blocked.Count -eq 0){
            $safeToAutomate = $false
        }

        [void]$recommendations.Add([ordered]@{
            id = ("ARGUS-REC-{0:0001}" -f $counter)
            diagnosticGroupId = $group.id
            title = ("Review {0}" -f $group.actionArea)
            priority = $group.priority
            confidence = $confidence
            action = Get-ARGUSRecommendationAction -Domain $group.domain -Facts @($NormalizedAnalysis.facts | Where-Object { $group.facts -contains $_.id }) -Gaps @($NormalizedAnalysis.gaps | Where-Object { $_.domain -eq $group.domain -or $_.domain -eq "evidenceQuality" })
            why = $group.summary
            citations = @($group.citations)
            blockedByMissingEvidence = @($blocked)
            safeToAutomate = $safeToAutomate
            unsupportedConclusions = @($blocked | ForEach-Object { $_.blockedConclusions } | ForEach-Object { $_ })
        })
    }

    return @($recommendations.ToArray())
}

function Global:Invoke-ARGUSGroupingAndRecommendations {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$BundleRoot,
        [Parameter(Mandatory=$true)][string]$NormalizedAnalysisPath
    )

    if(!(Test-Path $NormalizedAnalysisPath)){
        throw "ARGUS normalized analysis was not found: $NormalizedAnalysisPath"
    }

    $normalized = Get-Content -Path $NormalizedAnalysisPath -Raw | ConvertFrom-Json
    $groups = New-ARGUSDiagnosticGroups -NormalizedAnalysis $normalized
    $recommendations = New-ARGUSRecommendations -NormalizedAnalysis $normalized -DiagnosticGroups $groups

    $groupsArtifact = New-ARGUSBaseArtifact -BundleRoot $BundleRoot -ArtifactType "diagnostic-groups"
    $groupsArtifact["inputValidationStatus"] = $normalized.inputValidationStatus
    $groupsArtifact["inputValidationMode"] = $normalized.inputValidationMode
    $groupsArtifact["groups"] = @($groups)

    $recommendationsArtifact = New-ARGUSBaseArtifact -BundleRoot $BundleRoot -ArtifactType "recommendations"
    $recommendationsArtifact["inputValidationStatus"] = $normalized.inputValidationStatus
    $recommendationsArtifact["inputValidationMode"] = $normalized.inputValidationMode
    $recommendationsArtifact["recommendations"] = @($recommendations)

    return [pscustomobject]@{
        DiagnosticGroups = $groupsArtifact
        Recommendations = $recommendationsArtifact
    }
}
