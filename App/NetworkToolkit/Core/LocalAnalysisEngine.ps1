# =====================================================================

$diagnosticIdentityModule = Join-Path (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))) "Core\Analysis\DiagnosticBundleIdentity.ps1"
if(!(Test-Path -LiteralPath $diagnosticIdentityModule)){ throw "Diagnostic bundle identity module not found: $diagnosticIdentityModule" }
. $diagnosticIdentityModule
$script:HEPAppRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
# LocalAnalysisEngine.ps1
# HEPHAESTUS Local Analysis Engine v1 - Minimal Vertical Slice
# =====================================================================
# PowerShell : 5.1+
# Purpose    : Create deterministic local analysis artifacts for a bundle
#              or output folder without requiring ARGUS or internet access.
# =====================================================================

function Global:New-HEPAnalysisTimestamp {
    return (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

function Global:New-HEPSourceBundleInfo {
    param([Parameter(Mandatory=$true)][string]$BundleRoot)
    $validated = if($script:HEPBundleValidation -and $script:HEPBundleValidation.BundleRoot -eq $BundleRoot){$script:HEPBundleValidation}else{Resolve-NTKDiagnosticBundle -BundleRoot $BundleRoot}
    return [ordered]@{
        runId = $validated.Identity.runId
        bundleId = $validated.Identity.bundleId
        computerName = $validated.Identity.computerName
        collectionStartedUtc = $validated.Identity.collectionStartedUtc
        collectionCompletedUtc = $validated.Identity.collectionCompletedUtc
        bundleRoot = $validated.Identity.bundleRoot
        sourceManifest = $validated.Identity.sourceManifest
    }
}

function Global:New-HEPBaseArtifact {
    param([Parameter(Mandatory=$true)][string]$BundleRoot)

    return [ordered]@{
        schemaVersion = "1.0"
        generatedAtUtc = New-HEPAnalysisTimestamp
        generator = "HEPHAESTUS Local Analysis Engine"
        sourceBundle = New-HEPSourceBundleInfo -BundleRoot $BundleRoot
    }
}

function Global:Write-HEPJsonFile {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][object]$InputObject
    )

    $parent = Split-Path -Parent $Path
    if($parent -and !(Test-Path $parent)){
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $json = $InputObject | ConvertTo-Json -Depth 12
    Set-Content -Path $Path -Value $json -Encoding UTF8
}

function Global:Get-HEPDefaultBundleRoot {
    $searchRoots = @()
    if($Global:NTKPaths -and $Global:NTKPaths.Exports){ $searchRoots += $Global:NTKPaths.Exports }
    $searchRoots += Join-Path $script:HEPAppRoot "Triage\Runs"
    $candidates = @()
    foreach($root in @($searchRoots | Select-Object -Unique)){
        if(!(Test-Path -LiteralPath $root)){ continue }
        try {
            $bundle = Get-NTKDefaultDiagnosticBundleRoot -SearchRoot $root
            $validated = Resolve-NTKDiagnosticBundle -BundleRoot $bundle
            $started = [datetime]::Parse($validated.Identity.collectionStartedUtc)
            $candidates += [pscustomobject]@{Root=$bundle;Started=$started;RunId=$validated.Identity.runId}
        }
        catch {}
    }
    $selected = $candidates | Sort-Object Started,RunId -Descending | Select-Object -First 1
    if(!$selected){ throw "No valid diagnostic bundle is available for deterministic analysis." }
    return $selected.Root
}

function Global:Get-HEPEvidenceInventory {
    param([Parameter(Mandatory=$true)][string]$BundleRoot)

    if(!(Test-Path $BundleRoot)){
        return @()
    }

    return @(Get-NTKDiagnosticSourceFiles -BundleRoot $BundleRoot | ForEach-Object {
        [pscustomobject]@{
            Name = $_.Name
            FullName = $_.FullName
            RelativePath = ($_.FullName.Substring($BundleRoot.Length).TrimStart('\','/'))
            Extension = $_.Extension
            Length = $_.Length
            LastWriteTimeUtc = $_.LastWriteTimeUtc.ToString("yyyy-MM-ddTHH:mm:ssZ")
        }
    })
}

function Global:Test-HEPEvidenceMatch {
    param(
        [object[]]$Inventory,
        [string[]]$Patterns
    )

    foreach($pattern in $Patterns){
        $match = $Inventory | Where-Object { $_.RelativePath -match $pattern -or $_.Name -match $pattern } | Select-Object -First 1
        if($match){ return $match }
    }

    return $null
}

function Global:Test-HEPArtifactContent {
    param([Parameter(Mandatory=$true)][object]$Item)

    $result = [ordered]@{
        artifact = $Item.RelativePath
        format = $Item.Extension.TrimStart('.').ToLowerInvariant()
        discoveryStatus = "present"
        parserStatus = "not_applicable"
        semanticStatus = "unknown"
        recordCount = 0
        error = $null
    }
    if($Item.Length -le 0){ $result.parserStatus="failed"; $result.semanticStatus="invalid"; $result.error="Artifact is empty."; return [pscustomobject]$result }

    try {
        $raw = Get-Content -LiteralPath $Item.FullName -Raw -ErrorAction Stop
        if($raw -match '^\s*ERROR\s*:'){ throw "Artifact contains collector error text." }
        switch($result.format){
            "json" {
                $data = $raw | ConvertFrom-Json -ErrorAction Stop
                if($null -eq $data){ throw "JSON contains no value." }
                $result.parserStatus = "parsed"
                $result.recordCount = @($data).Count
                $result.semanticStatus = if($result.recordCount -gt 0){"valid"}else{"empty"}
            }
            "csv" {
                $data = @(Import-Csv -LiteralPath $Item.FullName -ErrorAction Stop)
                if($data.Count -eq 0){ throw "CSV contains no data records." }
                $result.parserStatus = "parsed"; $result.recordCount = $data.Count; $result.semanticStatus = "valid"
            }
            "xml" {
                [xml]$data = $raw
                if(!$data.DocumentElement){ throw "XML contains no document element." }
                $result.parserStatus = "parsed"; $result.recordCount = 1; $result.semanticStatus = "valid"
            }
            default {
                if([string]::IsNullOrWhiteSpace($raw)){ throw "Artifact contains no meaningful text." }
                $result.parserStatus = "parsed"; $result.recordCount = @($raw -split "`r?`n" | Where-Object { $_.Trim() }).Count; $result.semanticStatus = "valid"
            }
        }
    }
    catch { $result.parserStatus="failed"; $result.semanticStatus="invalid"; $result.error=$_.Exception.Message }
    return [pscustomobject]$result
}

function Global:New-HEPFinding {
    param(
        [Parameter(Mandatory=$true)][string]$Id,
        [Parameter(Mandatory=$true)][string]$RuleId,
        [Parameter(Mandatory=$true)][string]$Title,
        [Parameter(Mandatory=$true)][string]$Summary,
        [ValidateSet("critical","high","medium","low","informational")][string]$Severity = "informational",
        [ValidateSet("confirmed","high","medium","low")][string]$Confidence = "medium",
        [string]$Category = "evidence",
        [object[]]$Evidence = @(),
        [string[]]$Recommendations = @(),
        [string[]]$Tags = @()
    )

    return [ordered]@{
        id = $Id
        ruleId = $RuleId
        title = $Title
        summary = $Summary
        severity = $Severity
        confidence = $Confidence
        category = $Category
        status = "active"
        evidence = @($Evidence)
        recommendations = @($Recommendations)
        tags = @($Tags)
        firstSeenUtc = $null
        lastSeenUtc = $null
    }
}

function Global:New-HEPMachineProfile {
    param(
        [Parameter(Mandatory=$true)][string]$BundleRoot,
        [object[]]$Inventory
    )

    $artifact = New-HEPBaseArtifact -BundleRoot $BundleRoot
    $validated = if($script:HEPBundleValidation){$script:HEPBundleValidation}else{Resolve-NTKDiagnosticBundle -BundleRoot $BundleRoot}
    $systemEvidence = Test-HEPEvidenceMatch -Inventory $Inventory -Patterns @("Get-ComputerInfo\.json$", "computer.?info.*\.json$", "machine.?profile.*\.json$")

    $machine = [ordered]@{
        computerName = $validated.Identity.computerName
        userName = $null
        domain = $null
        osCaption = $null
        osVersion = $null
        manufacturer = $null
        model = $null
        source = if($systemEvidence){$systemEvidence.RelativePath}else{$validated.Identity.sourceManifest}
    }

    if($systemEvidence){
        try {
            $data = Get-Content -LiteralPath $systemEvidence.FullName -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
            if($data.CsName){ $machine.computerName = [string]$data.CsName }
            $machine.domain = [string]$data.CsDomain
            $machine.osCaption = [string]$data.WindowsProductName
            $machine.osVersion = [string]$data.OsBuildNumber
            $machine.manufacturer = [string]$data.CsManufacturer
            $machine.model = [string]$data.CsModel
        }
        catch { $machine.warning = "Bundle machine profile could not be parsed: $($_.Exception.Message)" }
    }
    if($machine.computerName -ne $validated.Identity.computerName){
        throw "Bundle computer identity mismatch between collection manifest and machine evidence."
    }

    $artifact["machine"] = $machine
    return $artifact
}

function Global:New-HEPEvidenceScore {
    param(
        [Parameter(Mandatory=$true)][string]$BundleRoot,
        [object[]]$Inventory,
        [object[]]$Warnings
    )

    $categories = @(
        @{ Name = "machine-profile"; Patterns = @("systeminfo", "computer.?info", "machine.?profile", "os.?info") },
        @{ Name = "storage"; Patterns = @("disk", "storage", "volume") },
        @{ Name = "network"; Patterns = @("ipconfig", "network", "adapter", "dns") },
        @{ Name = "updates"; Patterns = @("update", "hotfix", "patch") },
        @{ Name = "security-products"; Patterns = @("security", "defender", "antivirus", "edr") },
        @{ Name = "services"; Patterns = @("service") }
    )

    $categoryResults = @()
    $warningsOut = New-Object System.Collections.Generic.List[object]
    foreach($warning in @($Warnings)){ [void]$warningsOut.Add($warning) }
    $present = 0
    $parsed = 0
    $failed = 0

    foreach($category in $categories){
        $matches = @($Inventory | Where-Object {
            $item = $_
            @($category.Patterns | Where-Object { $item.RelativePath -match $_ -or $item.Name -match $_ }).Count -gt 0
        })
        $outcomes = @($matches | ForEach-Object { Test-HEPArtifactContent -Item $_ })
        $parsedOutcomes = @($outcomes | Where-Object { $_.parserStatus -eq "parsed" -and $_.semanticStatus -eq "valid" })
        $failedOutcomes = @($outcomes | Where-Object { $_.parserStatus -eq "failed" -or $_.semanticStatus -eq "invalid" })
        if($matches.Count -gt 0){ $present++ }
        if($parsedOutcomes.Count -gt 0){ $parsed++ }
        $failed += $failedOutcomes.Count
        foreach($failure in $failedOutcomes){
            [void]$warningsOut.Add([ordered]@{artifact=$failure.artifact;parser=$failure.format;status="failed";message=$failure.error;category=$category.Name})
        }
        $score = if($matches.Count -eq 0){0}elseif($parsedOutcomes.Count -eq 0){0}else{[int][Math]::Round(($parsedOutcomes.Count / [double]$matches.Count) * 100)}
        $categoryResults += [ordered]@{
            category = $category.Name
            expectedArtifacts = 1
            discoveredArtifacts = $matches.Count
            presentArtifacts = $matches.Count
            parsedArtifacts = $parsedOutcomes.Count
            failedParsers = $failedOutcomes.Count
            score = $score
            status = if($matches.Count -eq 0){"missing"}elseif($parsedOutcomes.Count -eq 0){"invalid"}elseif($failedOutcomes.Count -gt 0){"partial"}else{"parsed"}
            artifacts = @($outcomes)
        }
    }

    $completeness = [int][Math]::Round(($parsed / [double]$categories.Count) * 100)
    $qualityPenalty = $warningsOut.Count * 5
    $quality = [Math]::Max(0, 100 - $qualityPenalty - ($failed * 10))
    $overall = [int][Math]::Round(($completeness + $quality) / 2)

    $artifact = New-HEPBaseArtifact -BundleRoot $BundleRoot
    $artifact["overallScore"] = $overall
    $artifact["completenessScore"] = $completeness
    $artifact["qualityScore"] = $quality
    $artifact["categories"] = @($categoryResults)
    $artifact["discoveredCategoryCount"] = $present
    $artifact["parsedCategoryCount"] = $parsed
    $artifact["failedParserCount"] = $failed
    $artifact["warnings"] = @($warningsOut.ToArray())
    return $artifact
}

function Global:New-HEPTimeline {
    param(
        [Parameter(Mandatory=$true)][string]$BundleRoot,
        [object[]]$Inventory
    )

    $artifact = New-HEPBaseArtifact -BundleRoot $BundleRoot
    $events = @()
    $warnings = @()
    $eventArtifacts = @($Inventory | Where-Object { $_.Extension -eq ".json" -and $_.RelativePath -match '(?i)(event|timeline)' })
    foreach($item in $eventArtifacts){
        $outcome = Test-HEPArtifactContent -Item $item
        if($outcome.parserStatus -ne "parsed"){ $warnings += [ordered]@{artifact=$item.RelativePath;message=$outcome.error}; continue }
        try {
            $records = @(Get-Content -LiteralPath $item.FullName -Raw | ConvertFrom-Json)
            if($records.Count -eq 1 -and $records[0] -is [System.Array]){
                $records = @($records[0] | ForEach-Object { $_ })
            }
            $recordIndex = 0
            foreach($record in $records){
                $rawTimestamp = @($record.timestampUtc,$record.TimeCreated,$record.timeCreated,$record.EventTimeUtc,$record.eventTimeUtc) | Where-Object { $_ } | Select-Object -First 1
                $eventTime = [datetime]::MinValue
                if(!$rawTimestamp -or ![datetime]::TryParse([string]$rawTimestamp,[ref]$eventTime)){
                    $warnings += [ordered]@{artifact=$item.RelativePath;record=$recordIndex;message="Record has no parseable source event timestamp."}
                    $recordIndex++; continue
                }
                $title = @($record.title,$record.ProviderName,$record.Source,$record.Id) | Where-Object { $_ } | Select-Object -First 1
                $details = @($record.details,$record.Message,$record.Summary) | Where-Object { $_ } | Select-Object -First 1
                $events += [ordered]@{
                    timestampUtc = $eventTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
                    timestampType = "sourceEventTime"
                    source = $item.RelativePath
                    sourceRecord = $recordIndex
                    category = "event"
                    title = if($title){[string]$title}else{"Event record"}
                    details = if($details){[string]$details}else{"Structured event record from $($item.RelativePath)."}
                    relatedFindingIds = @()
                }
                $recordIndex++
            }
        }
        catch { $warnings += [ordered]@{artifact=$item.RelativePath;message=$_.Exception.Message} }
    }

    $artifact["timelineSemantics"] = "sourceEventTimeOnly"
    $artifact["events"] = @($events | Sort-Object timestampUtc -Descending)
    $artifact["warnings"] = @($warnings)
    return $artifact
}

function Global:New-HEPSchemaVersionArtifact {
    param([Parameter(Mandatory=$true)][string]$BundleRoot)

    return [ordered]@{
        schemaVersion = "1.0"
        generatedAtUtc = New-HEPAnalysisTimestamp
        generator = "HEPHAESTUS Local Analysis Engine"
        sourceBundle = New-HEPSourceBundleInfo -BundleRoot $BundleRoot
        schemaFamily = "HEPHAESTUS.LocalAnalysis"
        compatibleConsumers = @("HEPHAESTUS Local HTML Report", "Future ARGUS consumers")
        artifacts = @(
            "Analysis/findings.json",
            "Analysis/timeline.json",
            "Analysis/evidence-score.json",
            "Analysis/normalized/machine-profile.json",
            "Analysis/report.html",
            "Metadata/bundle-capabilities.json"
        )
    }
}

function Global:ConvertTo-HEPHtmlText {
    param([object]$Value)

    if($null -eq $Value){ return "" }
    return [System.Net.WebUtility]::HtmlEncode([string]$Value)
}

function Global:Write-HEPHtmlReport {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][object]$Findings,
        [Parameter(Mandatory=$true)][object]$EvidenceScore,
        [Parameter(Mandatory=$true)][object]$MachineProfile
    )

    $findingRows = ""
    foreach($finding in @($Findings.findings)){
        $findingRows += "<tr><td>$(ConvertTo-HEPHtmlText $finding.severity)</td><td>$(ConvertTo-HEPHtmlText $finding.confidence)</td><td>$(ConvertTo-HEPHtmlText $finding.title)</td><td>$(ConvertTo-HEPHtmlText $finding.summary)</td></tr>"
    }

    if(!$findingRows){
        $findingRows = "<tr><td colspan='4'>No deterministic findings were produced.</td></tr>"
    }

    $computerName = ConvertTo-HEPHtmlText $MachineProfile.machine.computerName
    $osCaption = ConvertTo-HEPHtmlText $MachineProfile.machine.osCaption
    $osVersion = ConvertTo-HEPHtmlText $MachineProfile.machine.osVersion

    $html = @"
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>HEPHAESTUS Local Analysis Report</title>
<style>
body { font-family: Segoe UI, Arial, sans-serif; margin: 24px; color: #222; }
h1, h2 { margin-bottom: 6px; }
table { border-collapse: collapse; width: 100%; margin-top: 12px; }
th, td { border: 1px solid #ccc; padding: 6px 8px; text-align: left; vertical-align: top; }
th { background: #f2f2f2; }
.small { color: #555; font-size: 12px; }
</style>
</head>
<body>
<h1>HEPHAESTUS Local Analysis Report</h1>
<p class="small">Generated $($Findings.generatedAtUtc)</p>
<p class="small">Run ID: $(ConvertTo-HEPHtmlText $Findings.sourceBundle.runId)<br>Bundle ID: $(ConvertTo-HEPHtmlText $Findings.sourceBundle.bundleId)</p>
<h2>Machine Profile</h2>
<p><strong>Computer:</strong> $computerName</p>
<p><strong>OS:</strong> $osCaption $osVersion</p>
<h2>Evidence Score</h2>
<p><strong>Overall:</strong> $($EvidenceScore.overallScore) / 100</p>
<p><strong>Completeness:</strong> $($EvidenceScore.completenessScore) / 100</p>
<p><strong>Quality:</strong> $($EvidenceScore.qualityScore) / 100</p>
<h2>Deterministic Findings</h2>
<table>
<thead><tr><th>Severity</th><th>Confidence</th><th>Title</th><th>Summary</th></tr></thead>
<tbody>$findingRows</tbody>
</table>
<h2>Missing Evidence and Parser Warnings</h2>
<p>Review <code>Analysis/evidence-score.json</code> for category-level completeness and warnings.</p>
</body>
</html>
"@

    $parent = Split-Path -Parent $Path
    if($parent -and !(Test-Path $parent)){
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    Set-Content -Path $Path -Value $html -Encoding UTF8
}

function Global:Invoke-HEPHAESTUSLocalAnalysis {
    [CmdletBinding()]
    param([string]$BundleRoot)

    if(!(Get-Command New-NTKOperationResult -ErrorAction SilentlyContinue)){
        . (Join-Path (Split-Path -Parent $PSScriptRoot) 'Utilities\OperationResult.ps1')
    }

    if(!$BundleRoot){
        $BundleRoot = Get-HEPDefaultBundleRoot
    }

    $script:HEPBundleValidation = Resolve-NTKDiagnosticBundle -BundleRoot $BundleRoot
    $BundleRoot = $script:HEPBundleValidation.BundleRoot
    [void](Write-NTKDiagnosticRunIdentity -BundleValidation $script:HEPBundleValidation)

    $analysisRoot = Join-Path $BundleRoot "Analysis"
    $normalizedRoot = Join-Path $analysisRoot "normalized"
    $metadataRoot = Join-Path $BundleRoot "Metadata"

    foreach($dir in @($analysisRoot, $normalizedRoot, $metadataRoot)){
        if(!(Test-Path $dir)){
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }

    try {
        $warnings = @()
        $inventory = Get-HEPEvidenceInventory -BundleRoot $BundleRoot
        $machineProfile = New-HEPMachineProfile -BundleRoot $BundleRoot -Inventory $inventory
        $evidenceScore = New-HEPEvidenceScore -BundleRoot $BundleRoot -Inventory $inventory -Warnings $warnings
        $timeline = New-HEPTimeline -BundleRoot $BundleRoot -Inventory $inventory
        $findings = New-HEPFindings -BundleRoot $BundleRoot -Inventory $inventory -EvidenceScore $evidenceScore
        $capabilities = New-HEPBundleCapabilities -BundleRoot $BundleRoot
        $schemaVersion = New-HEPSchemaVersionArtifact -BundleRoot $BundleRoot

        Write-HEPJsonFile -Path (Join-Path $normalizedRoot "machine-profile.json") -InputObject $machineProfile
        Write-HEPJsonFile -Path (Join-Path $analysisRoot "evidence-score.json") -InputObject $evidenceScore
        Write-HEPJsonFile -Path (Join-Path $analysisRoot "timeline.json") -InputObject $timeline
        Write-HEPJsonFile -Path (Join-Path $analysisRoot "findings.json") -InputObject $findings
        Write-HEPJsonFile -Path (Join-Path $metadataRoot "bundle-capabilities.json") -InputObject $capabilities
        Write-HEPJsonFile -Path (Join-Path $metadataRoot "schema-version.json") -InputObject $schemaVersion
        Write-HEPHtmlReport -Path (Join-Path $analysisRoot "report.html") -Findings $findings -EvidenceScore $evidenceScore -MachineProfile $machineProfile

        Write-Host "HEPHAESTUS Local Analysis completed." -ForegroundColor Green
        Write-Host "Bundle root: $BundleRoot"
        Write-Host "Analysis root: $analysisRoot"

        return New-NTKOperationResult -Operation 'HEPHAESTUS Local Analysis' -State Succeeded -Message 'Local analysis completed.' -Data @{
            Status='Completed'; BundleRoot=$BundleRoot; AnalysisRoot=$analysisRoot; Findings=@($findings.findings).Count
            EvidenceScore=$evidenceScore.overallScore; RunId=$script:HEPBundleValidation.Identity.runId; BundleId=$script:HEPBundleValidation.Identity.bundleId
        }
    }
    catch {
        $warning = [ordered]@{
            artifact = $BundleRoot
            parser = "local-analysis-engine"
            status = "failed"
            message = $_.Exception.Message
        }

        $failure = New-HEPBaseArtifact -BundleRoot $BundleRoot
        $failure["overallScore"] = 0
        $failure["completenessScore"] = 0
        $failure["qualityScore"] = 0
        $failure["categories"] = @()
        $failure["warnings"] = @($warning)
        Write-HEPJsonFile -Path (Join-Path $analysisRoot "evidence-score.json") -InputObject $failure

        Write-Warning "HEPHAESTUS Local Analysis failed but collection should continue: $($_.Exception.Message)"
        return New-NTKOperationResult -Operation 'HEPHAESTUS Local Analysis' -State Partial -Message 'Local analysis failed; collection may continue.' -Errors @($_.Exception.Message) -Data @{
            Status='FailedNonFatal'; BundleRoot=$BundleRoot; AnalysisRoot=$analysisRoot; Error=$_.Exception.Message
        }
    }
}

if(Get-Command Register-NTKCommand -ErrorAction SilentlyContinue){
    Register-NTKCommand `
        -Name "Run Local Analysis" `
        -Command "Invoke-HEPHAESTUSLocalAnalysis" `
        -Category "Analyze" `
        -Description "Run deterministic HEPHAESTUS Local Analysis Engine v1 against the latest export or a supplied bundle root." `
        -Source "HEPHAESTUS" `
        -Id "hephaestus-local-analysis" `
        -Order 40
}
