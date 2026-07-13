$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
. (Join-Path $repoRoot "Core\Analysis\DiagnosticBundleIdentity.ps1")
. (Join-Path $repoRoot "App\NetworkToolkit\Core\LocalAnalysisEngine.ps1")
. (Join-Path $repoRoot "App\NetworkToolkit\Core\LocalAnalysisRules.ps1")
. (Join-Path $repoRoot "App\NetworkToolkit\Utilities\AIBundleCollector.ps1")
. (Join-Path $repoRoot "Core\Argus\ArgusFoundation.ps1")

function Assert-True { param([bool]$Condition,[string]$Message) if(!$Condition){ throw $Message } }

$sectionStatus = New-Object System.Collections.ArrayList
Invoke-NTKCollectorSection -Status $sectionStatus -Name 'inner-failure-fixture' -Script { $false }
Assert-True ($sectionStatus[0].State -eq 'Failed') 'Collector section reported Completed after an inner writer failure.'

$root = Join-Path $env:TEMP ("TASK-0087-" + [guid]::NewGuid().ToString("N"))
$Global:NTKPaths = [pscustomobject]@{ Data = (Join-Path $root 'Runtime\Data') }
New-Item -ItemType Directory -Path (Join-Path $root "Metadata") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $root "CommandOutput") -Force | Out-Null
try {
    [ordered]@{runId="RUN-PARSER-001";computerName="PARSER-FIXTURE";startedUtc="2026-01-01T00:00:00Z";endedUtc="2026-01-01T00:10:00Z"} |
        ConvertTo-Json | Set-Content (Join-Path $root "Metadata\collection_manifest.json") -Encoding UTF8
    [ordered]@{CsName="PARSER-FIXTURE";WindowsProductName="Fixture OS";OsBuildNumber="1";CsManufacturer="Fixture";CsModel="Fixture";CsDomain="fixture.local"} |
        ConvertTo-Json | Set-Content (Join-Path $root "CommandOutput\Get-ComputerInfo.json") -Encoding UTF8
    @([ordered]@{FriendlyName="Disk 0";HealthStatus="Healthy"}) | ConvertTo-Json | Set-Content (Join-Path $root "CommandOutput\Get-PhysicalDisk.json") -Encoding UTF8
    '{"broken":' | Set-Content (Join-Path $root "CommandOutput\Get-NetAdapter.json") -Encoding UTF8
    '[]' | Set-Content (Join-Path $root "CommandOutput\Get-HotFix.json") -Encoding UTF8
    'ERROR: access denied' | Set-Content (Join-Path $root "CommandOutput\security-products.json") -Encoding UTF8
    '{"Name":"Svc"' | Set-Content (Join-Path $root "CommandOutput\Get-Service.json") -Encoding UTF8
    "Name,Status`r`nAdapter,Up" | Set-Content (Join-Path $root "CommandOutput\network-valid.csv") -Encoding UTF8

    $eventPath = Join-Path $root "CommandOutput\event-timeline.json"
    @(
        [ordered]@{TimeCreated="2025-12-15T08:30:00Z";ProviderName="FixtureProvider";Id=42;Message="Known event"},
        [ordered]@{ProviderName="NoTimestamp";Id=43;Message="Must be excluded"}
    ) | ConvertTo-Json | Set-Content $eventPath -Encoding UTF8
    (Get-Item $eventPath).LastWriteTimeUtc = [datetime]"2026-07-12T12:00:00Z"

    $result = Invoke-HEPHAESTUSLocalAnalysis -BundleRoot $root
    Assert-True ($result.Status -eq "Completed") "Fixture analysis did not complete."
    $score = Get-Content (Join-Path $root "Analysis\evidence-score.json") -Raw | ConvertFrom-Json
    Assert-True ($score.failedParserCount -eq 3) "Failed parser count did not include malformed, truncated, and error-text artifacts without misclassifying semantic emptiness."
    foreach($category in @("network","security-products","services")){
        $record = $score.categories | Where-Object { $_.category -eq $category }
        Assert-True ($record.failedParsers -gt 0) "Category '$category' received no parser failure."
        Assert-True ($record.score -lt 100) "Category '$category' received full parsed credit."
    }
    $updates = $score.categories | Where-Object { $_.category -eq "updates" }
    Assert-True ($updates.failedParsers -eq 0 -and $updates.artifacts[0].semanticStatus -eq "empty") "Empty valid JSON was not separated from parser failure."
    Assert-True ($updates.score -eq 0) "Semantically empty JSON received parsed evidence credit."
    $machine = $score.categories | Where-Object { $_.category -eq "machine-profile" }
    Assert-True ($machine.parsedArtifacts -gt 0 -and $machine.status -eq "parsed") "Valid JSON did not receive parsed credit."

    $timeline = Get-Content (Join-Path $root "Analysis\timeline.json") -Raw | ConvertFrom-Json
    Assert-True ($timeline.timelineSemantics -eq "sourceEventTimeOnly") "Timeline semantics were not declared."
    Assert-True (@($timeline.events).Count -eq 1) "Timestamp-free event was not excluded. Timeline: $($timeline | ConvertTo-Json -Compress -Depth 6)"
    Assert-True ($timeline.events[0].timestampUtc -eq "2025-12-15T08:30:00Z") "Timeline used copy time instead of source event time."
    Assert-True ($timeline.events[0].timestampType -eq "sourceEventTime") "Event timestamp type is missing."
    Assert-True ($timeline.events[0].timestampUtc -ne "2026-07-12T12:00:00Z") "File LastWriteTime contaminated the event timeline."
    Assert-True (@($timeline.warnings).Count -eq 1) "Missing event timestamp warning was not recorded."

    $argus = Invoke-ARGUSFoundationAnalysis -BundleRoot $root
    $summary = Get-Content (Join-Path $root "ARGUS\analysis-summary.json") -Raw | ConvertFrom-Json
    Assert-True ($summary.evidenceQuality.qualityBand -eq "low") "ARGUS did not downgrade confidence for parser failures."
    $normalized = Get-Content (Join-Path $root "ARGUS\normalized-analysis.json") -Raw | ConvertFrom-Json
    $timelineFact = $normalized.facts | Where-Object { $_.sourceKind -eq "timelineEvent" } | Select-Object -First 1
    Assert-True ($timelineFact.confidence -eq "medium") "Valid source-time event received incorrect confidence."

    $jsonTarget = Join-Path $root "CommandOutput\export-failure.json"
    $global:blockedJsonTarget = $jsonTarget
    function Global:Set-Content {
        [CmdletBinding()] param([Parameter(ValueFromPipeline=$true)]$Value,[string]$LiteralPath,[string]$Encoding)
        begin { $values = @() }
        process { $values += $Value }
        end {
            if($LiteralPath -eq $global:blockedJsonTarget){ throw "json write fixture" }
            Microsoft.PowerShell.Management\Set-Content -LiteralPath $LiteralPath -Value $values -Encoding $Encoding
        }
    }
    try { $jsonOk = Export-NTKSafeJson ([ordered]@{value=1}) $jsonTarget }
    finally { Remove-Item Function:\Global:Set-Content -Force }
    Assert-True (!$jsonOk -and !(Test-Path $jsonTarget)) "Failed JSON export left a false structured artifact."
    $jsonError = Get-Content ($jsonTarget + ".error.json") -Raw | ConvertFrom-Json
    Assert-True ($jsonError.status -eq "failed" -and $jsonError.intendedFormat -eq "json") "JSON failure envelope is invalid."
    $csvTarget = Join-Path $root "CommandOutput\export-failure.csv"
    $global:blockedCsvTarget = $csvTarget
    function Global:Export-Csv {
        [CmdletBinding()] param([Parameter(ValueFromPipeline=$true)]$InputObject,[string]$LiteralPath,[switch]$NoTypeInformation,[string]$Encoding)
        process { if($LiteralPath -eq $global:blockedCsvTarget){ throw "csv write fixture" } }
    }
    try { $csvOk = Export-NTKSafeCsv ([ordered]@{value=1}) $csvTarget }
    finally { Remove-Item Function:\Global:Export-Csv -Force }
    Assert-True (!$csvOk -and !(Test-Path $csvTarget)) "Failed CSV export left a false structured artifact."
    $csvError = Get-Content ($csvTarget + ".error.json") -Raw | ConvertFrom-Json
    Assert-True ($csvError.status -eq "failed" -and $csvError.intendedFormat -eq "csv") "CSV failure envelope is invalid."

    Write-Host "TASK-0087 parser-backed evidence quality fixtures passed."
}
finally {
    if(Test-Path $root){ Remove-Item -LiteralPath $root -Recurse -Force }
}
