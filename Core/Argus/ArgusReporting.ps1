# =====================================================================
# ArgusReporting.ps1
# ARGUS first-release technician and escalation reports
# =====================================================================

$reportingContractModule = Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) 'App\NetworkToolkit\Utilities\ReportingContract.ps1'
if(!(Get-Command New-NTKReportMetadata -ErrorAction SilentlyContinue)){
    if(!(Test-Path -LiteralPath $reportingContractModule)){ throw "Reporting contract module not found: $reportingContractModule" }
    . $reportingContractModule
}

function Global:ConvertTo-ARGUSReportText {
    param([object]$Value)
    return ConvertTo-NTKReportMarkdown -Value $Value
}

function Global:Format-ARGUSReportCitation {
    param([object]$Citation)
    if($null -eq $Citation){ return "Citation unavailable" }
    $location = ConvertTo-ARGUSReportText $Citation.artifact
    if($Citation.jsonPointer){ $location += [string]$Citation.jsonPointer }
    return ("{0} [{1}; trust rank {2}]" -f $location,(ConvertTo-ARGUSReportText $Citation.sourceType),(ConvertTo-ARGUSReportText $Citation.trustRank))
}

function Global:Add-ARGUSReportCitations {
    param([System.Collections.Generic.List[string]]$Lines,[object[]]$Citations)
    if(@($Citations).Count -eq 0){ [void]$Lines.Add("- Citation unavailable; treat this entry as unsupported."); return }
    foreach($citation in @($Citations)){ [void]$Lines.Add("- $(Format-ARGUSReportCitation $citation)") }
}

function Global:Add-ARGUSReportHeader {
    param([System.Collections.Generic.List[string]]$Lines,[string]$Title,[object]$Validation,[object]$Summary)
    [void]$Lines.Add("# $Title")
    [void]$Lines.Add("")
    [void]$Lines.Add("Generated: $(ConvertTo-ARGUSReportText $Summary.generatedAtUtc)")
    [void]$Lines.Add("Bundle: $(ConvertTo-ARGUSReportText $Summary.sourceBundle.bundleRoot)")
    [void]$Lines.Add("Run ID: $(ConvertTo-ARGUSReportText $Summary.sourceBundle.runId)")
    [void]$Lines.Add("Bundle ID: $(ConvertTo-ARGUSReportText $Summary.sourceBundle.bundleId)")
    [void]$Lines.Add("")
    [void]$Lines.Add("- Input status: $(ConvertTo-ARGUSReportText $Validation.status)")
    [void]$Lines.Add("- Analysis mode: $(ConvertTo-ARGUSReportText $Validation.mode)")
    [void]$Lines.Add("- Evidence quality: $(ConvertTo-ARGUSReportText $Summary.evidenceQuality.qualityBand)")
}

function Global:Write-ARGUSTechnicianReport {
    param([string]$Path,[object]$Validation,[object]$Summary,[object]$NormalizedAnalysis,[object]$DiagnosticGroups,[object]$Recommendations)
    $lines = New-Object System.Collections.Generic.List[string]
    Add-ARGUSReportHeader -Lines $lines -Title "ARGUS Technician Report" -Validation $Validation -Summary $Summary

    [void]$lines.Add("")
    [void]$lines.Add("## Computer Context")
    [void]$lines.Add("")
    [void]$lines.Add("- Computer: $(ConvertTo-ARGUSReportText $Summary.machineProfile.computerName)")
    [void]$lines.Add("- Domain: $(ConvertTo-ARGUSReportText $Summary.machineProfile.domain)")
    [void]$lines.Add("- Operating system: $(ConvertTo-ARGUSReportText $Summary.machineProfile.osCaption) $(ConvertTo-ARGUSReportText $Summary.machineProfile.osVersion)")
    [void]$lines.Add("- Hardware: $(ConvertTo-ARGUSReportText $Summary.machineProfile.manufacturer) $(ConvertTo-ARGUSReportText $Summary.machineProfile.model)")

    [void]$lines.Add("")
    [void]$lines.Add("## Recommended Actions")
    foreach($recommendation in @($Recommendations.recommendations)){
        [void]$lines.Add("")
        [void]$lines.Add("### $(ConvertTo-ARGUSReportText $recommendation.title)")
        [void]$lines.Add("")
        [void]$lines.Add("- Priority / confidence: $(ConvertTo-ARGUSReportText $recommendation.priority) / $(ConvertTo-ARGUSReportText $recommendation.confidence)")
        [void]$lines.Add("- Action: $(ConvertTo-ARGUSReportText $recommendation.action)")
        [void]$lines.Add("- Why: $(ConvertTo-ARGUSReportText $recommendation.why)")
        [void]$lines.Add("- Safe to automate: $([bool]$recommendation.safeToAutomate)")
        [void]$lines.Add("- Evidence:")
        Add-ARGUSReportCitations -Lines $lines -Citations @($recommendation.citations)
        foreach($blocked in @($recommendation.blockedByMissingEvidence)){
            [void]$lines.Add("- Evidence limitation: $(ConvertTo-ARGUSReportText $blocked.reason)")
            [void]$lines.Add("- Collection guidance: $(ConvertTo-ARGUSReportText $blocked.recommendedCollection)")
        }
    }

    [void]$lines.Add("")
    [void]$lines.Add("## Diagnostic Themes")
    foreach($group in @($DiagnosticGroups.groups)){
        [void]$lines.Add("")
        [void]$lines.Add("### $(ConvertTo-ARGUSReportText $group.title)")
        [void]$lines.Add("")
        [void]$lines.Add("- Domain / confidence: $(ConvertTo-ARGUSReportText $group.domain) / $(ConvertTo-ARGUSReportText $group.confidence)")
        [void]$lines.Add("- Summary: $(ConvertTo-ARGUSReportText $group.summary)")
        foreach($candidate in @($group.rootCauseCandidates)){ [void]$lines.Add("- Root-cause candidate ($($candidate.confidence)): $(ConvertTo-ARGUSReportText $candidate.statement)") }
    }

    [void]$lines.Add("")
    [void]$lines.Add("## Evidence Limitations")
    [void]$lines.Add("")
    [void]$lines.Add("- $(ConvertTo-ARGUSReportText $Summary.evidenceQuality.caveat)")
    foreach($gap in @($NormalizedAnalysis.gaps)){ [void]$lines.Add("- [$($gap.domain)] $(ConvertTo-ARGUSReportText $gap.reason) Collection: $(ConvertTo-ARGUSReportText $gap.recommendedCollection)") }
    [void]$lines.Add("- ARGUS recommendations are technician guidance only and do not perform remediation.")
    Set-Content -LiteralPath $Path -Value $lines.ToArray() -Encoding UTF8
}

function Global:Write-ARGUSEscalationReport {
    param([string]$Path,[object]$Validation,[object]$Summary,[object]$NormalizedAnalysis,[object]$DiagnosticGroups,[object]$Recommendations)
    $lines = New-Object System.Collections.Generic.List[string]
    Add-ARGUSReportHeader -Lines $lines -Title "ARGUS Escalation Handoff" -Validation $Validation -Summary $Summary
    [void]$lines.Add("")
    [void]$lines.Add("This handoff summarizes cited local evidence. Review the structured artifacts before drawing conclusions.")
    [void]$lines.Add("")
    [void]$lines.Add("## Structured Artifacts To Review")
    foreach($artifact in @("ARGUS/input-validation.json","ARGUS/analysis-summary.json","ARGUS/normalized-analysis.json","ARGUS/diagnostic-groups.json","ARGUS/recommendations.json","Analysis/findings.json","Analysis/evidence-score.json")){
        [void]$lines.Add(('- `{0}`' -f $artifact))
    }

    [void]$lines.Add("")
    [void]$lines.Add("## Diagnostic Groups And Evidence")
    foreach($group in @($DiagnosticGroups.groups)){
        [void]$lines.Add("")
        [void]$lines.Add("### $($group.id): $(ConvertTo-ARGUSReportText $group.title)")
        [void]$lines.Add("")
        [void]$lines.Add("- Domain / priority / confidence: $(ConvertTo-ARGUSReportText $group.domain) / $(ConvertTo-ARGUSReportText $group.priority) / $(ConvertTo-ARGUSReportText $group.confidence)")
        [void]$lines.Add("- Summary: $(ConvertTo-ARGUSReportText $group.summary)")
        [void]$lines.Add("- Fact IDs: $(@($group.facts) -join ', ')")
        [void]$lines.Add("- Citations:")
        Add-ARGUSReportCitations -Lines $lines -Citations @($group.citations)
        foreach($blocked in @($group.blockedByMissingEvidence)){
            [void]$lines.Add("- Missing evidence: $(ConvertTo-ARGUSReportText $blocked.reason)")
            [void]$lines.Add("- Blocked conclusions: $(ConvertTo-ARGUSReportText (@($blocked.blockedConclusions) -join ', '))")
        }
    }

    [void]$lines.Add("")
    [void]$lines.Add("## Recommendation Handoff")
    foreach($recommendation in @($Recommendations.recommendations)){ [void]$lines.Add("- [$($recommendation.priority)/$($recommendation.confidence)] $(ConvertTo-ARGUSReportText $recommendation.title): $(ConvertTo-ARGUSReportText $recommendation.action)") }
    [void]$lines.Add("")
    [void]$lines.Add("## Known Limits And Unsupported Conclusions")
    foreach($gap in @($NormalizedAnalysis.gaps)){ [void]$lines.Add("- [$($gap.domain)] $(ConvertTo-ARGUSReportText $gap.reason) Blocked: $(ConvertTo-ARGUSReportText (@($gap.blockedConclusions) -join ', ')).") }
    [void]$lines.Add("- Do not infer causality from timeline proximity alone.")
    [void]$lines.Add("- Missing findings are not proof that a subsystem is healthy.")
    [void]$lines.Add("- This single-computer report does not support fleet-wide or whole-network conclusions.")
    Set-Content -LiteralPath $Path -Value $lines.ToArray() -Encoding UTF8
}

function Global:Write-ARGUSFinalReports {
    param([string]$ArgusRoot,[object]$Validation,[object]$Summary,[object]$NormalizedAnalysis,[object]$DiagnosticGroups,[object]$Recommendations)
    $technicianPath = Join-Path $ArgusRoot "technician-report.md"
    $escalationPath = Join-Path $ArgusRoot "escalation-report.md"
    Write-ARGUSTechnicianReport -Path $technicianPath -Validation $Validation -Summary $Summary -NormalizedAnalysis $NormalizedAnalysis -DiagnosticGroups $DiagnosticGroups -Recommendations $Recommendations
    Write-ARGUSEscalationReport -Path $escalationPath -Validation $Validation -Summary $Summary -NormalizedAnalysis $NormalizedAnalysis -DiagnosticGroups $DiagnosticGroups -Recommendations $Recommendations
    $identity = $Summary.sourceBundle
    $sourceArtifacts = @('ARGUS/input-validation.json','ARGUS/analysis-summary.json','ARGUS/normalized-analysis.json','ARGUS/diagnostic-groups.json','ARGUS/recommendations.json')
    $limitations = @('Technician guidance only; no remediation is performed.','Missing evidence limits supported conclusions.')
    $technicianMetadata = New-NTKReportMetadata -ReportType 'argus-technician' -Title 'ARGUS Technician Report' -Format markdown -RunIdentity $identity -SourceArtifacts $sourceArtifacts -Limitations $limitations
    $escalationMetadata = New-NTKReportMetadata -ReportType 'argus-escalation' -Title 'ARGUS Escalation Handoff' -Format markdown -RunIdentity $identity -SourceArtifacts $sourceArtifacts -Limitations $limitations
    [void](Register-NTKRunArtifact -RunIdentity $identity -Path $technicianPath -ArtifactType 'argus-technician-report' -ReportMetadata $technicianMetadata)
    [void](Register-NTKRunArtifact -RunIdentity $identity -Path $escalationPath -ArtifactType 'argus-escalation-report' -ReportMetadata $escalationMetadata)
    return [pscustomobject]@{ TechnicianReport = $technicianPath; EscalationReport = $escalationPath }
}
