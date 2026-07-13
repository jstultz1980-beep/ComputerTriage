$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
. (Join-Path $repoRoot "Core\Analysis\DiagnosticBundleIdentity.ps1")
. (Join-Path $repoRoot "App\NetworkToolkit\Core\LocalAnalysisEngine.ps1")
. (Join-Path $repoRoot "App\NetworkToolkit\Core\LocalAnalysisRules.ps1")
. (Join-Path $repoRoot "Core\Argus\ArgusFoundation.ps1")
. (Join-Path $repoRoot "App\NetworkToolkit\Utilities\ClientDataTransfer.ps1")

function Assert-True { param([bool]$Condition,[string]$Message) if(!$Condition){ throw $Message } }

function New-TestBundle {
    param([string]$Root,[string]$RunId,[string]$ComputerName,[string]$StartedUtc)
    New-Item -ItemType Directory -Path (Join-Path $Root "Metadata") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $Root "CommandOutput") -Force | Out-Null
    [ordered]@{runId=$RunId;computerName=$ComputerName;startedUtc=$StartedUtc;endedUtc=$StartedUtc;profile="Fixture"} |
        ConvertTo-Json | Set-Content -LiteralPath (Join-Path $Root "Metadata\collection_manifest.json") -Encoding UTF8
    [ordered]@{CsName=$ComputerName;WindowsProductName="Fixture OS";OsBuildNumber="1000";CsManufacturer="Fixture Vendor";CsModel="Fixture Model";CsDomain="fixture.local"} |
        ConvertTo-Json | Set-Content -LiteralPath (Join-Path $Root "CommandOutput\Get-ComputerInfo.json") -Encoding UTF8
    "Windows IP Configuration`r`nIPv4 Address: 10.20.30.40" | Set-Content -LiteralPath (Join-Path $Root "CommandOutput\ipconfig.txt") -Encoding UTF8
}

$testRoot = Join-Path $env:TEMP ("TASK-0086-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $testRoot | Out-Null
$Global:NTKPaths = [pscustomobject]@{ Data = (Join-Path $testRoot 'Runtime\Data') }
try {
    $bundleA = Join-Path $testRoot "Computer-A"
    New-TestBundle -Root $bundleA -RunId "RUN-COMPUTER-A-001" -ComputerName "COMPUTER-A-FIXTURE" -StartedUtc "2026-07-10T10:00:00Z"
    $validatedA = Resolve-NTKDiagnosticBundle -BundleRoot $bundleA
    Assert-True ($validatedA.Identity.bundleId -like "NTK-*") "Bundle ID was not derived."

    $firstSourceCount = @(Get-NTKDiagnosticSourceFiles -BundleRoot $bundleA).Count
    $hep1 = Invoke-HEPHAESTUSLocalAnalysis -BundleRoot $bundleA
    $identityPath = Join-Path $bundleA "Metadata\run-identity.json"
    $identityHash1 = (Get-FileHash -LiteralPath $identityPath -Algorithm SHA256).Hash
    $profile1 = Get-Content -LiteralPath (Join-Path $bundleA "Analysis\normalized\machine-profile.json") -Raw | ConvertFrom-Json
    Assert-True ($profile1.machine.computerName -eq "COMPUTER-A-FIXTURE") "Offline profile did not use Computer-A evidence."
    Assert-True ($profile1.machine.computerName -ne $env:COMPUTERNAME) "Analysis host identity contaminated the offline profile."
    Assert-True ($profile1.sourceBundle.runId -eq "RUN-COMPUTER-A-001") "Deterministic artifact lost run ID."
    Assert-True ($profile1.sourceBundle.bundleId -eq $validatedA.Identity.bundleId) "Deterministic artifact lost bundle ID."

    $hep2 = Invoke-HEPHAESTUSLocalAnalysis -BundleRoot $bundleA
    $secondSourceCount = @(Get-NTKDiagnosticSourceFiles -BundleRoot $bundleA).Count
    $identityHash2 = (Get-FileHash -LiteralPath $identityPath -Algorithm SHA256).Hash
    Assert-True ($firstSourceCount -eq $secondSourceCount) "Generated outputs entered source evidence inventory."
    Assert-True ($identityHash1 -eq $identityHash2) "Immutable run identity changed on repeated analysis."
    Assert-True ($hep1.BundleId -eq $hep2.BundleId) "Repeated analysis changed bundle identity."
    Assert-True (@(Get-HEPEvidenceInventory -BundleRoot $bundleA | Where-Object { $_.RelativePath -match '^(Analysis|Metadata|ARGUS)[\\/]' }).Count -eq 0) "Generated directory appeared in HEP inventory."

    $argus = Invoke-ARGUSFoundationAnalysis -BundleRoot $bundleA
    $argusValidation = Get-Content -LiteralPath (Join-Path $bundleA "ARGUS\input-validation.json") -Raw | ConvertFrom-Json
    Assert-True ($argus.RunId -eq "RUN-COMPUTER-A-001") "ARGUS result lost run ID."
    Assert-True ($argus.BundleId -eq $validatedA.Identity.bundleId) "ARGUS result lost bundle ID."
    Assert-True ($argusValidation.sourceBundle.computerName -eq "COMPUTER-A-FIXTURE") "ARGUS used analysis-host identity."

    $invalidEmpty = Join-Path $testRoot "empty"
    New-Item -ItemType Directory -Path $invalidEmpty | Out-Null
    Assert-True (!(Test-NTKDiagnosticBundle -BundleRoot $invalidEmpty)) "Empty directory was accepted."
    $unrelated = Join-Path $testRoot "unrelated"
    New-Item -ItemType Directory -Path $unrelated | Out-Null
    "not a bundle" | Set-Content (Join-Path $unrelated "report.txt")
    Assert-True (!(Test-NTKDiagnosticBundle -BundleRoot $unrelated)) "Unrelated export was accepted."
    $partial = Join-Path $testRoot "partial"
    New-Item -ItemType Directory -Path (Join-Path $partial "Metadata") -Force | Out-Null
    '{"runId":"PARTIAL"}' | Set-Content (Join-Path $partial "Metadata\collection_manifest.json")
    Assert-True (!(Test-NTKDiagnosticBundle -BundleRoot $partial)) "Partial manifest was accepted."

    $bundleB = Join-Path $testRoot "Computer-B"
    New-TestBundle -Root $bundleB -RunId "RUN-COMPUTER-B-002" -ComputerName "COMPUTER-B-FIXTURE" -StartedUtc "2026-07-11T10:00:00Z"
    (Get-Item $invalidEmpty).LastWriteTime = Get-Date
    $selected = Get-NTKDefaultDiagnosticBundleRoot -SearchRoot $testRoot
    Assert-True ((Resolve-Path $selected).Path -eq (Resolve-Path $bundleB).Path) "Default selection did not choose the newest valid run."

    $mismatch = Join-Path $testRoot "mismatch"
    New-TestBundle -Root $mismatch -RunId "RUN-MISMATCH" -ComputerName "MANIFEST-COMPUTER" -StartedUtc "2026-07-12T10:00:00Z"
    $mismatchData = Get-Content (Join-Path $mismatch "CommandOutput\Get-ComputerInfo.json") -Raw | ConvertFrom-Json
    $mismatchData.CsName = "OTHER-COMPUTER"
    $mismatchData | ConvertTo-Json | Set-Content (Join-Path $mismatch "CommandOutput\Get-ComputerInfo.json")
    $mismatchResult = Invoke-HEPHAESTUSLocalAnalysis -BundleRoot $mismatch
    Assert-True ($mismatchResult.Status -ne "Completed") "Conflicting machine identities were not rejected."

    $sourceToolkit = Join-Path $testRoot "SourceToolkit"
    $destinationToolkit = Join-Path $testRoot "DestinationToolkit"
    foreach($toolkit in @($sourceToolkit,$destinationToolkit)){
        New-Item -ItemType Directory -Path (Join-Path $toolkit "App\NetworkToolkit") -Force | Out-Null
        New-Item -ItemType File -Path (Join-Path $toolkit "NetworkToolkit.vbs") -Force | Out-Null
        New-Item -ItemType File -Path (Join-Path $toolkit "App\NetworkToolkit\NetworkToolkit-Core.ps1") -Force | Out-Null
    }
    $transferSourceRun = Join-Path $sourceToolkit "App\Triage\Runs\RUN-TRANSFER"
    New-TestBundle -Root $transferSourceRun -RunId "RUN-TRANSFER-001" -ComputerName "TRANSFER-COMPUTER" -StartedUtc "2026-07-09T10:00:00Z"
    $transfer = Copy-NTKClientData -SourceRoot $sourceToolkit -DestinationRoot $destinationToolkit
    Assert-True ($transfer.Status -eq "Completed") "Client-data transfer did not complete cleanly."
    Assert-True (@($transfer.TransferredRunIdentities).Count -eq 1) "Transfer manifest did not record the run identity."
    Assert-True ($transfer.TransferredRunIdentities[0].RunId -eq "RUN-TRANSFER-001") "Transfer changed the run ID."
    $transferredBundle = Resolve-NTKDiagnosticBundle -BundleRoot (Join-Path $destinationToolkit "App\Triage\Runs\RUN-TRANSFER")
    Assert-True ($transferredBundle.Identity.bundleId -eq $transfer.TransferredRunIdentities[0].BundleId) "Transferred bundle ID did not verify."

    Write-Host "TASK-0086 diagnostic bundle identity fixtures passed."
}
finally {
    if(Test-Path -LiteralPath $testRoot){ Remove-Item -LiteralPath $testRoot -Recurse -Force }
}
