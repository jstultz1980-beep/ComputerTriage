$repoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
$ErrorActionPreference = 'Stop'
. (Join-Path $repoRoot 'App\NetworkToolkit\Utilities\AtomicState.ps1')
. (Join-Path $repoRoot 'App\NetworkToolkit\Utilities\ReportingContract.ps1')

function Assert-True {
    param([bool]$Condition,[string]$Message)
    if(!$Condition){ throw $Message }
}

function Assert-Equal {
    param([object]$Actual,[object]$Expected,[string]$Message)
    if([string]$Actual -cne [string]$Expected){ throw "$Message Expected '$Expected', got '$Actual'." }
}

$root = Join-Path ([IO.Path]::GetTempPath()) ('ntk-run-index-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $root -Force | Out-Null
try {
    Assert-Equal (ConvertTo-NTKReportHtml '<tag a="1">A&B</tag>') '&lt;tag a=&quot;1&quot;&gt;A&amp;B&lt;/tag&gt;' 'HTML escaping snapshot changed.'
    Assert-Equal (ConvertTo-NTKReportMarkdown "A|B`r`nC") 'A\|B C' 'Markdown escaping snapshot changed.'
    Assert-Equal (ConvertTo-NTKReportMarkdown $null) 'Not available' 'Markdown missing-value behavior changed.'

    $oldRun = [pscustomobject]@{schemaVersion='1.0';runId='run-old';bundleId='bundle-old';computerName='PC1';collectionStartedUtc='2026-01-01T00:00:00Z';collectionCompletedUtc=$null;bundleRoot='C:\bundle-old';sourceManifest='Metadata\collection_manifest.json'}
    $newRun = [pscustomobject]@{schemaVersion='1.0';runId='run-new';bundleId='bundle-new';computerName='PC1';collectionStartedUtc='2026-02-01T00:00:00Z';collectionCompletedUtc=$null;bundleRoot='C:\bundle-new';sourceManifest='Metadata\collection_manifest.json'}
    [void](Register-NTKRunIdentity -RunIdentity $newRun -IndexRoot $root)
    Start-Sleep -Milliseconds 20
    [void](Register-NTKRunIdentity -RunIdentity $oldRun -IndexRoot $root)
    $latest = Get-NTKLatestRun -IndexRoot $root
    Assert-Equal $latest.runId 'run-new' 'Latest selection used filesystem creation order instead of collection identity time.'

    $reportPath = Join-Path $root 'report.html'
    '<html>snapshot</html>' | Set-Content -LiteralPath $reportPath -Encoding UTF8
    $metadata = New-NTKReportMetadata -ReportType 'fixture' -Title 'Fixture Report' -Format html -RunIdentity $newRun -SourceArtifacts @('fixture.json') -Limitations @('Fixture only.') -GeneratedAtUtc ([datetimeoffset]'2026-02-01T01:00:00Z')
    Assert-Equal $metadata.runIdentity.runId 'run-new' 'Report metadata lost its immutable run identity.'
    Assert-Equal $metadata.format 'html' 'Report metadata format snapshot changed.'
    $artifact = Register-NTKRunArtifact -RunIdentity $newRun -Path $reportPath -ArtifactType 'fixture-report' -ReportMetadata $metadata -IndexRoot $root
    Assert-Equal (Resolve-NTKRunArtifact -ArtifactRecord $artifact).State 'Available' 'New artifact was not available.'
    '<html>changed</html>' | Set-Content -LiteralPath $reportPath -Encoding UTF8
    Assert-Equal (Resolve-NTKRunArtifact -ArtifactRecord $artifact).State 'Stale' 'Changed artifact was not explicitly stale.'
    Remove-Item -LiteralPath $reportPath -Force
    Assert-Equal (Resolve-NTKRunArtifact -ArtifactRecord $artifact).State 'Missing' 'Deleted artifact was not explicitly missing.'

    $conflict = [pscustomobject]@{runId='run-new';bundleId='different';computerName='PC1';collectionStartedUtc='2026-02-01T00:00:00Z'}
    $conflictRaised = $false
    try { [void](Register-NTKRunIdentity -RunIdentity $conflict -IndexRoot $root) } catch { $conflictRaised = $true }
    Assert-True $conflictRaised 'Conflicting immutable identity was accepted.'

    $invalidRaised = $false
    try { [void](New-NTKReportMetadata -ReportType fixture -Title Invalid -Format html -RunIdentity ([pscustomobject]@{runId='missing-fields'})) } catch { $invalidRaised = $true }
    Assert-True $invalidRaised 'Report metadata accepted an incomplete run identity.'

    Write-Host 'Reporting and run-index contract tests passed.' -ForegroundColor Green
}
finally {
    Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue
}
