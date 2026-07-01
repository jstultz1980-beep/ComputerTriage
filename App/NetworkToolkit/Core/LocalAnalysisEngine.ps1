# =====================================================================
# LocalAnalysisEngine.ps1
# HEPHAESTUS Local Analysis Engine v1 - Minimal Vertical Slice
# =====================================================================
# PowerShell : 5.1+
# Purpose    : Create deterministic local analysis artifacts for a bundle
#              or output folder without requiring ARGUS or internet access.
# =====================================================================

function New-HEPAnalysisTimestamp {
    return (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

function New-HEPSourceBundleInfo {
    param(
        [Parameter(Mandatory=$true)]
        [string]$BundleRoot
    )

    $computerName = $null
    try { $computerName = $env:COMPUTERNAME } catch {}

    return [ordered]@{
        computerName = $computerName
        collectionStartedUtc = $null
        collectionCompletedUtc = $null
        bundleRoot = $BundleRoot
    }
}

function New-HEPBaseArtifact {
    param(
        [Parameter(Mandatory=$true)]
        [string]$BundleRoot
    )

    return [ordered]@{
        schemaVersion = "1.0"
        generatedAtUtc = New-HEPAnalysisTimestamp
        generator = "HEPHAESTUS Local Analysis Engine"
        sourceBundle = New-HEPSourceBundleInfo -BundleRoot $BundleRoot
    }
}

function Write-HEPJsonFile {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,

        [Parameter(Mandatory=$true)]
        [object]$InputObject
    )

    $parent = Split-Path -Parent $Path
    if($parent -and !(Test-Path $parent)){
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $json = $InputObject | ConvertTo-Json -Depth 12
    Set-Content -Path $Path -Value $json -Encoding UTF8
}

function Get-HEPDefaultBundleRoot {
    if($Global:NTKPaths -and $Global:NTKPaths.Exports){
        if(!(Test-Path $Global:NTKPaths.Exports)){
            New-Item -ItemType Directory -Path $Global:NTKPaths.Exports -Force | Out-Null
        }

        $latest = Get-ChildItem -Path $Global:NTKPaths.Exports -Directory -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1

        if($latest){
            return $latest.FullName
        }

        $created = Join-Path $Global:NTKPaths.Exports ("HEPHAESTUS-Analysis-" + (Get-Date -Format "yyyyMMdd-HHmmss"))
        New-Item -ItemType Directory -Path $created -Force | Out-Null
        return $created
    }

    $fallback = Join-Path $env:TEMP ("HEPHAESTUS-Analysis-" + (Get-Date -Format "yyyyMMdd-HHmmss"))
    New-Item -ItemType Directory -Path $fallback -Force | Out-Null
    return $fallback
}

function Get-HEPEvidenceInventory {
    param(
        [Parameter(Mandatory=$true)]
        [string]$BundleRoot
    )

    if(!(Test-Path $BundleRoot)){
        return @()
    }

    return @(Get-ChildItem -Path $BundleRoot -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
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

function Test-HEPEvidenceMatch {
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

function New-HEPFinding {
    param(
        [Parameter(Mandatory=$true)] [string]$Id,
        [Parameter(Mandatory=$true)] [string]$RuleId,
        [Parameter(Mandatory=$true)] [string]$Title,
        [Parameter(Mandatory=$true)] [string]$Summary,
        [ValidateSet("critical","high","medium","low","informational")]
        [string]$Severity = "informational",
        [ValidateSet("confirmed","high","medium","low")]
        [string]$Confidence = "medium",
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

function New-HEPMachineProfile {
    param(
        [Parameter(Mandatory=$true)] [string]$BundleRoot,
        [object[]]$Inventory
    )

    $artifact = New-HEPBaseArtifact -BundleRoot $BundleRoot
    $systemEvidence = Test-HEPEvidenceMatch -Inventory $Inventory -Patterns @("systeminfo", "computer.?info", "machine.?profile", "os.?info")

    $artifact.machine = [ordered]@{
        computerName = $env:COMPUTERNAME
        userName = $env:USERNAME
        domain = $env:USERDOMAIN
        osCaption = $null
        osVersion = $null
        manufacturer = $null
        model = $null
        source = if($systemEvidence){$systemEvidence.RelativePath}else{"runtime-environment"}
    }

    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        $cs = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop
        $artifact.machine.osCaption = $os.Caption
        $artifact.machine.osVersion = $os.Version
        $artifact.machine.manufacturer = $cs.Manufacturer
        $artifact.machine.model = $cs.Model
    }
    catch {
        $artifact.machine.warning = "Runtime CIM machine profile collection failed: $($_.Exception.Message)"
    }

    return $artifact
}

function New-HEPEvidenceScore {
    param(
        [Parameter(Mandatory=$true)] [string]$BundleRoot,
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
    $present = 0

    foreach($category in $categories){
        $match = Test-HEPEvidenceMatch -Inventory $Inventory -Patterns $category.Patterns
        $isPresent = [bool]$match
        if($isPresent){ $present++ }
        $categoryResults += [ordered]@{
            category = $category.Name
            expectedArtifacts = 1
            presentArtifacts = if($isPresent){1}else{0}
            parsedArtifacts = if($isPresent){1}else{0}
            failedParsers = 0
            score = if($isPresent){100}else{0}
            status = if($isPresent){"present"}else{"missing"}
        }
    }

    $completeness = [int][Math]::Round(($present / [double]$categories.Count) * 100)
    $qualityPenalty = @($Warnings).Count * 5
    $quality = [Math]::Max(0, 100 - $qualityPenalty)
    $overall = [int][Math]::Round(($completeness + $quality) / 2)

    $artifact = New-HEPBaseArtifact -BundleRoot $BundleRoot
    $artifact.overallScore = $overall
    $artifact.completenessScore = $completeness
    $artifact.qualityScore = $quality
    $artifact.categories = @($categoryResults)
    $artifact.warnings = @($Warnings)
    return $artifact
}

function New-HEPTimeline {
    param(
        [Parameter(Mandatory=$true)] [string]$BundleRoot,
        [object[]]$Inventory
    )

    $artifact = New-HEPBaseArtifact -BundleRoot $BundleRoot
    $events = @()

    foreach($item in @($Inventory | Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 25)){
        $events += [ordered]@{
            timestampUtc = $item.LastWriteTimeUtc
            source = $item.RelativePath
            category = "evidence"
            title = "Evidence artifact present"
            details = "Artifact $($item.RelativePath) was present in the analyzed bundle."
            relatedFindingIds = @()
        }
    }

    $artifact.events = @($events)
    return $artifact
}

function New-HEPFindings {
    param(
        [Parameter(Mandatory=$true)] [string]$BundleRoot,
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

    try {
        $systemDrive = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction Stop
        if($systemDrive -and $systemDrive.Size -gt 0){
            $freePercent = [Math]::Round(($systemDrive.FreeSpace / [double]$systemDrive.Size) * 100, 2)
            if($freePercent -lt 10){
                $id = "HEP-FINDING-{0:0000}" -f $counter
                $findings += New-HEPFinding `
                    -Id $id `
                    -RuleId "HEP-RULE-STORAGE-001" `
                    -Title "System drive free space is low" `
                    -Summary "Drive C: has $freePercent percent free space available." `
                    -Severity "high" `
                    -Confidence "confirmed" `
                    -Category "storage" `
                    -Evidence @([ordered]@{ artifact = "runtime-cim"; field = "C.FreePercent"; value = $freePercent }) `
                    -Recommendations @("Free disk space or expand the system volume before continuing other remediation.") `
                    -Tags @("storage", "low-free-space")
                $counter++
            }
        }
    }
    catch {
        $id = "HEP-FINDING-{0:0000}" -f $counter
        $findings += New-HEPFinding `
            -Id $id `
            -RuleId "HEP-RULE-PARSER-001" `
            -Title "Storage runtime check could not run" `
            -Summary $_.Exception.Message `
            -Severity "informational" `
            -Confidence "confirmed" `
            -Category "evidence" `
            -Recommendations @("Review storage evidence manually if storage symptoms are present.") `
            -Tags @("parser-warning", "storage")
    }

    $artifact.findings = @($findings)
    return $artifact
}

function New-HEPBundleCapabilities {
    param(
        [Parameter(Mandatory=$true)] [string]$BundleRoot
    )

    $artifact = [ordered]@{
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
            domainHealth = "planned"
            gpo = "planned"
            localHtmlReport = "supported"
        }
        tools = @()
    }

    return $artifact
}

function New-HEPSchemaVersionArtifact {
    param(
        [Parameter(Mandatory=$true)] [string]$BundleRoot
    )

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

function Write-HEPHtmlReport {
    param(
        [Parameter(Mandatory=$true)] [string]$Path,
        [Parameter(Mandatory=$true)] [object]$Findings,
        [Parameter(Mandatory=$true)] [object]$EvidenceScore,
        [Parameter(Mandatory=$true)] [object]$MachineProfile
    )

    $findingRows = ""
    foreach($finding in @($Findings.findings)){
        $findingRows += "<tr><td>$([System.Web.HttpUtility]::HtmlEncode($finding.severity))</td><td>$([System.Web.HttpUtility]::HtmlEncode($finding.confidence))</td><td>$([System.Web.HttpUtility]::HtmlEncode($finding.title))</td><td>$([System.Web.HttpUtility]::HtmlEncode($finding.summary))</td></tr>"
    }

    if(!$findingRows){
        $findingRows = "<tr><td colspan='4'>No deterministic findings were produced.</td></tr>"
    }

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
<h2>Machine Profile</h2>
<p><strong>Computer:</strong> $([System.Web.HttpUtility]::HtmlEncode($MachineProfile.machine.computerName))</p>
<p><strong>OS:</strong> $([System.Web.HttpUtility]::HtmlEncode($MachineProfile.machine.osCaption)) $([System.Web.HttpUtility]::HtmlEncode($MachineProfile.machine.osVersion))</p>
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

function Invoke-HEPHAESTUSLocalAnalysis {
    [CmdletBinding()]
    param(
        [string]$BundleRoot
    )

    if(!$BundleRoot){
        $BundleRoot = Get-HEPDefaultBundleRoot
    }

    if(!(Test-Path $BundleRoot)){
        New-Item -ItemType Directory -Path $BundleRoot -Force | Out-Null
    }

    $analysisRoot = Join-Path $BundleRoot "Analysis"
    $normalizedRoot = Join-Path $analysisRoot "normalized"
    $metadataRoot = Join-Path $BundleRoot "Metadata"

    foreach($dir in @($analysisRoot, $normalizedRoot, $metadataRoot)){
        if(!(Test-Path $dir)){
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }

    $warnings = @()

    try {
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

        $result = [pscustomobject]@{
            Status = "Completed"
            BundleRoot = $BundleRoot
            AnalysisRoot = $analysisRoot
            Findings = @($findings.findings).Count
            EvidenceScore = $evidenceScore.overallScore
        }

        Write-Host "HEPHAESTUS Local Analysis completed." -ForegroundColor Green
        Write-Host "Bundle root: $BundleRoot"
        Write-Host "Analysis root: $analysisRoot"
        return $result
    }
    catch {
        $warning = [ordered]@{
            artifact = $BundleRoot
            parser = "local-analysis-engine"
            status = "failed"
            message = $_.Exception.Message
        }

        $base = New-HEPBaseArtifact -BundleRoot $BundleRoot
        $base.overallScore = 0
        $base.completenessScore = 0
        $base.qualityScore = 0
        $base.categories = @()
        $base.warnings = @($warning)

        Write-HEPJsonFile -Path (Join-Path $analysisRoot "evidence-score.json") -InputObject $base
        Write-Warning "HEPHAESTUS Local Analysis failed but collection should continue: $($_.Exception.Message)"
        return [pscustomobject]@{
            Status = "FailedNonFatal"
            BundleRoot = $BundleRoot
            AnalysisRoot = $analysisRoot
            Error = $_.Exception.Message
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
