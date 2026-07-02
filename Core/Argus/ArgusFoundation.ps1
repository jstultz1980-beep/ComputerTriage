# =====================================================================
# ArgusFoundation.ps1
# ARGUS Foundation - Minimal Contract Validation and Summary Slice
# =====================================================================
# PowerShell : 5.1+
# Purpose    : Consume HEPHAESTUS Local Analysis Engine artifacts, validate
#              the ARGUS input contract, and produce clearly labeled ARGUS
#              foundation outputs without modifying HEPHAESTUS evidence.
# =====================================================================

function Global:New-ARGUSTimestamp {
    return (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

function Global:Get-ARGUSDefaultBundleRoot {
    if($Global:NTKPaths -and $Global:NTKPaths.Exports -and (Test-Path $Global:NTKPaths.Exports)){
        $latest = Get-ChildItem -Path $Global:NTKPaths.Exports -Directory -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1

        if($latest){
            return $latest.FullName
        }
    }

    throw "No HEPHAESTUS bundle root was supplied and no export folder was available."
}

function Global:Get-ARGUSRelativePath {
    param(
        [Parameter(Mandatory=$true)][string]$Root,
        [Parameter(Mandatory=$true)][string]$Path
    )

    $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd('\','/')
    $pathFull = [System.IO.Path]::GetFullPath($Path)
    if($pathFull.StartsWith($rootFull, [System.StringComparison]::OrdinalIgnoreCase)){
        return $pathFull.Substring($rootFull.Length).TrimStart('\','/')
    }
    return $Path
}

function Global:Read-ARGUSJsonArtifact {
    param(
        [Parameter(Mandatory=$true)][string]$BundleRoot,
        [Parameter(Mandatory=$true)][string]$RelativePath,
        [Parameter(Mandatory=$true)][string]$Role,
        [Parameter(Mandatory=$true)][int]$TrustRank,
        [switch]$Required
    )

    $path = Join-Path $BundleRoot $RelativePath
    $record = [ordered]@{
        path = $RelativePath
        role = $Role
        required = [bool]$Required
        trustRank = $TrustRank
        status = "missing"
        message = $null
    }

    if(!(Test-Path $path)){
        $record.message = "Artifact was not found."
        return [pscustomobject]@{ Record = $record; Data = $null }
    }

    try {
        $raw = Get-Content -Path $path -Raw -ErrorAction Stop
        $data = $raw | ConvertFrom-Json -ErrorAction Stop
        $record.status = "parsed"
        $record.message = "Artifact parsed successfully."
        return [pscustomobject]@{ Record = $record; Data = $data }
    }
    catch {
        $record.status = "parse_failed"
        $record.message = $_.Exception.Message
        return [pscustomobject]@{ Record = $record; Data = $null }
    }
}

function Global:Write-ARGUSJsonFile {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][object]$InputObject
    )

    $parent = Split-Path -Parent $Path
    if($parent -and !(Test-Path $parent)){
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $json = $InputObject | ConvertTo-Json -Depth 16
    Set-Content -Path $Path -Value $json -Encoding UTF8
}

function Global:Get-ARGUSSeverityRank {
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

function Global:Get-ARGUSEvidenceQualityBand {
    param([object]$EvidenceScore)

    if($null -eq $EvidenceScore){
        return "unknown"
    }

    $overall = [int]($EvidenceScore.overallScore)
    $completeness = [int]($EvidenceScore.completenessScore)
    $quality = [int]($EvidenceScore.qualityScore)

    if($quality -lt 50 -or $overall -lt 40){ return "low" }
    if($completeness -lt 70 -or $overall -lt 70){ return "partial" }
    return "high"
}

function Global:New-ARGUSBaseArtifact {
    param(
        [Parameter(Mandatory=$true)][string]$BundleRoot,
        [string]$ArtifactType = "argus-artifact"
    )

    return [ordered]@{
        schemaVersion = "1.0"
        generatedAtUtc = New-ARGUSTimestamp
        generator = "ARGUS Foundation"
        artifactType = $ArtifactType
        sourceBundle = [ordered]@{
            bundleRoot = $BundleRoot
            computerName = $env:COMPUTERNAME
        }
    }
}

function Global:New-ARGUSInputValidation {
    param(
        [Parameter(Mandatory=$true)][string]$BundleRoot,
        [Parameter(Mandatory=$true)][hashtable]$Artifacts,
        [object[]]$NormalizedArtifacts
    )

    $artifactRecords = @()
    foreach($key in @("schemaVersion","bundleCapabilities","evidenceScore","findings","timeline","machineProfile")){
        $artifactRecords += $Artifacts[$key].Record
    }

    $requiredFailures = @($artifactRecords | Where-Object { $_.required -and $_.status -ne "parsed" })
    $unsupportedCapabilities = @()
    $capabilityWarnings = @()

    $capabilities = $Artifacts["bundleCapabilities"].Data
    if($capabilities -and $capabilities.capabilities){
        foreach($property in $capabilities.capabilities.PSObject.Properties){
            $state = [string]$property.Value
            if($state -match '^(planned|partial|missing|skipped|not_implemented)$'){
                $capabilityWarnings += [ordered]@{
                    capability = $property.Name
                    status = $state
                    message = "ARGUS must not treat this category as fully analyzed."
                }
                if($state -match '^(planned|missing|skipped|not_implemented)$'){
                    $unsupportedCapabilities += $property.Name
                }
            }
        }
    }

    $schema = $Artifacts["schemaVersion"].Data
    $schemaVersion = if($schema){ [string]$schema.schemaVersion } else { $null }
    $contractSupported = $schemaVersion -eq "1.0"
    $errors = @()

    if(!$contractSupported){
        $errors += [ordered]@{
            code = "ARGUS-CONTRACT-SCHEMA"
            message = "ARGUS Foundation supports HEPHAESTUS schemaVersion 1.0. Actual value: $schemaVersion"
        }
    }

    foreach($failure in $requiredFailures){
        $errors += [ordered]@{
            code = "ARGUS-CONTRACT-REQUIRED-ARTIFACT"
            message = "Required artifact $($failure.path) is $($failure.status): $($failure.message)"
        }
    }

    $status = if($errors.Count -gt 0){"failed"}elseif($capabilityWarnings.Count -gt 0){"limited"}else{"passed"}
    $mode = if($status -eq "passed"){"normal"}else{"limited"}

    $validation = New-ARGUSBaseArtifact -BundleRoot $BundleRoot -ArtifactType "input-validation"
    $validation["status"] = $status
    $validation["mode"] = $mode
    $validation["contract"] = [ordered]@{
        name = "ARGUS Input Contract"
        adr = "ADR-0003-ARGUS-Input-Contract-And-Trust-Model"
        supportedSchemaVersion = "1.0"
        actualSchemaVersion = $schemaVersion
    }
    $validation["requiredArtifacts"] = @($artifactRecords | Where-Object { $_.required })
    $validation["optionalArtifacts"] = @($artifactRecords | Where-Object { !$_.required })
    $validation["normalizedArtifacts"] = @($NormalizedArtifacts)
    $validation["capabilityWarnings"] = @($capabilityWarnings)
    $validation["unsupportedAreas"] = @($unsupportedCapabilities)
    $validation["errors"] = @($errors)
    return $validation
}

function Global:New-ARGUSAnalysisSummary {
    param(
        [Parameter(Mandatory=$true)][string]$BundleRoot,
        [Parameter(Mandatory=$true)][object]$Validation,
        [Parameter(Mandatory=$true)][hashtable]$Artifacts
    )

    $findingsData = $Artifacts["findings"].Data
    $evidenceScore = $Artifacts["evidenceScore"].Data
    $timeline = $Artifacts["timeline"].Data
    $machineProfile = $Artifacts["machineProfile"].Data

    $findings = @()
    if($findingsData -and $findingsData.findings){
        $findings = @($findingsData.findings)
    }

    $prioritized = @($findings | Sort-Object @{ Expression = { Get-ARGUSSeverityRank $_.severity } }, @{ Expression = { $_.title } } | ForEach-Object {
        [ordered]@{
            label = "deterministicFinding"
            id = $_.id
            ruleId = $_.ruleId
            title = $_.title
            severity = $_.severity
            confidence = $_.confidence
            category = $_.category
            summary = $_.summary
            evidence = @($_.evidence)
            recommendations = @($_.recommendations)
            argusTreatment = "Accepted as deterministic HEPHAESTUS evidence. ARGUS Foundation does not override deterministic findings."
        }
    })

    $qualityBand = Get-ARGUSEvidenceQualityBand -EvidenceScore $evidenceScore
    $qualityCaveat = switch($qualityBand){
        "high" { "Evidence quality is high enough for normal prioritization." }
        "partial" { "Evidence is partial. Recommendations should include missing-evidence caveats and avoid strong root-cause language." }
        "low" { "Evidence quality is low. ARGUS should avoid strong root-cause language and request more evidence." }
        default { "Evidence quality is unknown because evidence-score data was unavailable." }
    }

    $machine = $null
    if($machineProfile -and $machineProfile.machine){
        $machine = [ordered]@{
            label = "normalizedEvidence"
            computerName = $machineProfile.machine.computerName
            userName = $machineProfile.machine.userName
            domain = $machineProfile.machine.domain
            osCaption = $machineProfile.machine.osCaption
            osVersion = $machineProfile.machine.osVersion
            manufacturer = $machineProfile.machine.manufacturer
            model = $machineProfile.machine.model
            source = "Analysis/normalized/machine-profile.json"
        }
    }

    $timelineHighlights = @()
    if($timeline -and $timeline.events){
        $timelineHighlights = @($timeline.events | Select-Object -First 10 | ForEach-Object {
            [ordered]@{
                label = "normalizedEvidence"
                timestampUtc = $_.timestampUtc
                source = $_.source
                category = $_.category
                title = $_.title
                details = $_.details
            }
        })
    }

    $summary = New-ARGUSBaseArtifact -BundleRoot $BundleRoot -ArtifactType "analysis-summary"
    $summary["inputValidationStatus"] = $Validation.status
    $summary["inputValidationMode"] = $Validation.mode
    $summary["evidenceQuality"] = [ordered]@{
        label = "normalizedEvidence"
        overallScore = if($evidenceScore){$evidenceScore.overallScore}else{$null}
        completenessScore = if($evidenceScore){$evidenceScore.completenessScore}else{$null}
        qualityScore = if($evidenceScore){$evidenceScore.qualityScore}else{$null}
        qualityBand = $qualityBand
        caveat = $qualityCaveat
        warnings = if($evidenceScore){@($evidenceScore.warnings)}else{@()}
    }
    $summary["machineProfile"] = $machine
    $summary["prioritizedDeterministicFindings"] = @($prioritized)
    $summary["timelineHighlights"] = @($timelineHighlights)
    $summary["unsupported"] = @($Validation.unsupportedAreas | ForEach-Object {
        [ordered]@{
            label = "unsupported"
            area = $_
            reason = "Bundle capabilities do not mark this area as fully supported."
        }
    })
    $summary["argusInference"] = @(
        [ordered]@{
            label = "argusInference"
            statement = "ARGUS Foundation performed contract validation and deterministic finding prioritization only. It did not infer a root cause beyond HEPHAESTUS findings."
            confidence = "not_applicable"
            supportingEvidence = @("Analysis/findings.json","Analysis/evidence-score.json","Metadata/bundle-capabilities.json")
        }
    )
    $summary["caveats"] = @(
        $qualityCaveat
        "Raw evidence was not used as the primary interface because ADR-0003 prioritizes HEPHAESTUS deterministic and normalized artifacts."
    )

    return $summary
}

function Global:ConvertTo-ARGUSMarkdownValue {
    param([object]$Value)

    if($null -eq $Value){ return "Unknown" }
    $text = [string]$Value
    if([string]::IsNullOrWhiteSpace($text)){ return "Unknown" }
    return $text.Replace("`r"," ").Replace("`n"," ").Trim()
}

function Global:Write-ARGUSMarkdownReport {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][object]$Validation,
        [Parameter(Mandatory=$true)][object]$Summary
    )

    $lines = New-Object System.Collections.Generic.List[string]
    [void]$lines.Add("# ARGUS Foundation Report")
    [void]$lines.Add("")
    [void]$lines.Add("Generated: $(ConvertTo-ARGUSMarkdownValue $Summary.generatedAtUtc)")
    [void]$lines.Add("Bundle: $(ConvertTo-ARGUSMarkdownValue $Summary.sourceBundle.bundleRoot)")
    [void]$lines.Add("")
    [void]$lines.Add("## Input Validation")
    [void]$lines.Add("")
    [void]$lines.Add("- Status: $(ConvertTo-ARGUSMarkdownValue $Validation.status)")
    [void]$lines.Add("- Mode: $(ConvertTo-ARGUSMarkdownValue $Validation.mode)")
    [void]$lines.Add("- Contract: $(ConvertTo-ARGUSMarkdownValue $Validation.contract.adr)")
    [void]$lines.Add("")
    [void]$lines.Add("## Evidence Quality")
    [void]$lines.Add("")
    [void]$lines.Add("- Overall score: $(ConvertTo-ARGUSMarkdownValue $Summary.evidenceQuality.overallScore)")
    [void]$lines.Add("- Completeness score: $(ConvertTo-ARGUSMarkdownValue $Summary.evidenceQuality.completenessScore)")
    [void]$lines.Add("- Quality score: $(ConvertTo-ARGUSMarkdownValue $Summary.evidenceQuality.qualityScore)")
    [void]$lines.Add("- Quality band: $(ConvertTo-ARGUSMarkdownValue $Summary.evidenceQuality.qualityBand)")
    [void]$lines.Add("- Caveat: $(ConvertTo-ARGUSMarkdownValue $Summary.evidenceQuality.caveat)")
    [void]$lines.Add("")
    [void]$lines.Add("## Machine Profile")
    [void]$lines.Add("")
    if($Summary.machineProfile){
        [void]$lines.Add("- Computer: $(ConvertTo-ARGUSMarkdownValue $Summary.machineProfile.computerName)")
        [void]$lines.Add("- Domain: $(ConvertTo-ARGUSMarkdownValue $Summary.machineProfile.domain)")
        [void]$lines.Add("- OS: $(ConvertTo-ARGUSMarkdownValue $Summary.machineProfile.osCaption) $(ConvertTo-ARGUSMarkdownValue $Summary.machineProfile.osVersion)")
        [void]$lines.Add("- Model: $(ConvertTo-ARGUSMarkdownValue $Summary.machineProfile.manufacturer) $(ConvertTo-ARGUSMarkdownValue $Summary.machineProfile.model)")
    }
    else{
        [void]$lines.Add("- Machine profile was not available.")
    }
    [void]$lines.Add("")
    [void]$lines.Add("## Prioritized Deterministic Findings")
    [void]$lines.Add("")
    $findings = @($Summary.prioritizedDeterministicFindings)
    if($findings.Count -eq 0){
        [void]$lines.Add("No deterministic HEPHAESTUS findings were available.")
    }
    else{
        foreach($finding in $findings){
            [void]$lines.Add("### [$($finding.severity)] $(ConvertTo-ARGUSMarkdownValue $finding.title)")
            [void]$lines.Add("")
            [void]$lines.Add("- Label: deterministicFinding")
            [void]$lines.Add("- Confidence: $(ConvertTo-ARGUSMarkdownValue $finding.confidence)")
            [void]$lines.Add("- Category: $(ConvertTo-ARGUSMarkdownValue $finding.category)")
            [void]$lines.Add("- Summary: $(ConvertTo-ARGUSMarkdownValue $finding.summary)")
            if($finding.recommendations){
                [void]$lines.Add("- Recommendations:")
                foreach($recommendation in @($finding.recommendations)){
                    [void]$lines.Add("  - $(ConvertTo-ARGUSMarkdownValue $recommendation)")
                }
            }
            [void]$lines.Add("")
        }
    }
    [void]$lines.Add("## Unsupported Or Limited Areas")
    [void]$lines.Add("")
    $unsupported = @($Summary.unsupported)
    if($unsupported.Count -eq 0){
        [void]$lines.Add("No unsupported capability areas were reported by ARGUS Foundation.")
    }
    else{
        foreach($item in $unsupported){
            [void]$lines.Add("- $($item.area): $($item.reason)")
        }
    }
    [void]$lines.Add("")
    [void]$lines.Add("## ARGUS Inference")
    [void]$lines.Add("")
    foreach($inference in @($Summary.argusInference)){
        [void]$lines.Add("- Label: argusInference")
        [void]$lines.Add("- Statement: $(ConvertTo-ARGUSMarkdownValue $inference.statement)")
    }

    $parent = Split-Path -Parent $Path
    if($parent -and !(Test-Path $parent)){
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    Set-Content -Path $Path -Value ($lines -join [Environment]::NewLine) -Encoding UTF8
}

function Global:Invoke-ARGUSFoundationAnalysis {
    [CmdletBinding()]
    param([string]$BundleRoot)

    if(!$BundleRoot){
        $BundleRoot = Get-ARGUSDefaultBundleRoot
    }

    if(!(Test-Path $BundleRoot)){
        throw "Bundle root not found: $BundleRoot"
    }

    $argusRoot = Join-Path $BundleRoot "ARGUS"
    if(!(Test-Path $argusRoot)){
        New-Item -ItemType Directory -Path $argusRoot -Force | Out-Null
    }

    $artifactSpecs = @(
        @{ Key = "schemaVersion"; RelativePath = "Metadata/schema-version.json"; Role = "schemaMetadata"; TrustRank = 1; Required = $true },
        @{ Key = "bundleCapabilities"; RelativePath = "Metadata/bundle-capabilities.json"; Role = "capabilityMetadata"; TrustRank = 2; Required = $true },
        @{ Key = "evidenceScore"; RelativePath = "Analysis/evidence-score.json"; Role = "evidenceQuality"; TrustRank = 3; Required = $true },
        @{ Key = "findings"; RelativePath = "Analysis/findings.json"; Role = "deterministicFindings"; TrustRank = 4; Required = $true },
        @{ Key = "timeline"; RelativePath = "Analysis/timeline.json"; Role = "timeline"; TrustRank = 5; Required = $true },
        @{ Key = "machineProfile"; RelativePath = "Analysis/normalized/machine-profile.json"; Role = "normalizedEvidence"; TrustRank = 6; Required = $true }
    )

    $artifacts = @{}
    foreach($spec in $artifactSpecs){
        $artifacts[$spec.Key] = Read-ARGUSJsonArtifact `
            -BundleRoot $BundleRoot `
            -RelativePath $spec.RelativePath `
            -Role $spec.Role `
            -TrustRank $spec.TrustRank `
            -Required:([bool]$spec.Required)
    }

    $normalizedArtifacts = @()
    $normalizedRoot = Join-Path $BundleRoot "Analysis/normalized"
    if(Test-Path $normalizedRoot){
        $normalizedArtifacts = @(Get-ChildItem -Path $normalizedRoot -Filter "*.json" -File -ErrorAction SilentlyContinue | ForEach-Object {
            [ordered]@{
                path = Get-ARGUSRelativePath -Root $BundleRoot -Path $_.FullName
                role = "normalizedEvidence"
                required = ($_.Name -eq "machine-profile.json")
                status = "present"
            }
        })
    }

    $validation = New-ARGUSInputValidation -BundleRoot $BundleRoot -Artifacts $artifacts -NormalizedArtifacts $normalizedArtifacts
    $summary = New-ARGUSAnalysisSummary -BundleRoot $BundleRoot -Validation $validation -Artifacts $artifacts

    $validationPath = Join-Path $argusRoot "input-validation.json"
    $summaryPath = Join-Path $argusRoot "analysis-summary.json"
    $reportPath = Join-Path $argusRoot "report.md"

    Write-ARGUSJsonFile -Path $validationPath -InputObject $validation
    Write-ARGUSJsonFile -Path $summaryPath -InputObject $summary
    Write-ARGUSMarkdownReport -Path $reportPath -Validation $validation -Summary $summary

    Write-Host "ARGUS Foundation completed." -ForegroundColor Green
    Write-Host "Bundle root: $BundleRoot"
    Write-Host "ARGUS root: $argusRoot"
    Write-Host "Input validation: $($validation.status)"

    return [pscustomobject]@{
        Status = "Completed"
        BundleRoot = $BundleRoot
        ArgusRoot = $argusRoot
        InputValidationStatus = $validation.status
        InputValidationMode = $validation.mode
        Findings = @($summary.prioritizedDeterministicFindings).Count
        Report = $reportPath
    }
}
