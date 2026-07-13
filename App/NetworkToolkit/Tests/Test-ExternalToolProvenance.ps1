$ErrorActionPreference = 'Stop'

$manager = Join-Path (Split-Path -Parent $PSScriptRoot) 'Plugins\ExternalToolManager\ExternalToolManager.ps1'
. $manager

$testRoot = Join-Path $env:TEMP ('TASK-0093-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $testRoot -Force | Out-Null

function Assert-Equal($Expected, $Actual, [string]$Message) {
    if($Expected -ne $Actual){ throw "$Message Expected '$Expected', got '$Actual'." }
}

try {
    $toolPath = Join-Path $testRoot 'fixture.exe'
    [IO.File]::WriteAllText($toolPath, 'trusted fixture')
    $hash = (Get-FileHash -LiteralPath $toolPath -Algorithm SHA256).Hash
    $script:NTKExternalToolProvenanceManifestPath = Join-Path $testRoot 'provenance.json'

    function Write-FixtureManifest([string]$Id, [string]$Sha256, [bool]$SignatureRequired = $false, [bool]$EulaRequired = $false, [string]$Lifecycle = 'approved', [string]$ExpiresUtc = '') {
        $record = [ordered]@{ id=$Id; sha256=$Sha256; source='fixture'; publisher='Fixture Publisher'; license='Fixture License'; eulaRequired=$EulaRequired; signatureRequired=$SignatureRequired; lifecycle=$Lifecycle }
        if($ExpiresUtc){ $record.expiresUtc = $ExpiresUtc }
        @{ schemaVersion='1.0'; policy=@{ edrGuidance='fixture guidance' }; tools=@($record) } |
            ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $script:NTKExternalToolProvenanceManifestPath -Encoding UTF8
    }

    Write-FixtureManifest -Id 'Fixture' -Sha256 $hash
    Assert-Equal $true (Test-NTKExternalToolTrust -ToolId Fixture -Path $toolPath).Trusted 'Valid provenance should pass.'

    Write-FixtureManifest -Id 'Fixture' -Sha256 ('0' * 64)
    Assert-Equal 'hash-mismatch' (Test-NTKExternalToolTrust -ToolId Fixture -Path $toolPath).Status 'Hash mismatch must block.'

    Write-FixtureManifest -Id 'Fixture' -Sha256 $hash -SignatureRequired $true
    function Global:Get-AuthenticodeSignature { [pscustomobject]@{ Status='HashMismatch'; SignerCertificate=$null } }
    Assert-Equal 'signature-invalid' (Test-NTKExternalToolTrust -ToolId Fixture -Path $toolPath).Status 'Signature failure must block.'
    Remove-Item Function:\Get-AuthenticodeSignature -Force

    Write-FixtureManifest -Id 'Fixture' -Sha256 $hash
    Assert-Equal 'missing' (Test-NTKExternalToolTrust -ToolId Fixture -Path (Join-Path $testRoot 'missing.exe')).Status 'Missing tool must be explicit.'

    Write-FixtureManifest -Id 'Fixture' -Sha256 $hash -ExpiresUtc '2020-01-01T00:00:00Z'
    Assert-Equal 'expired' (Test-NTKExternalToolTrust -ToolId Fixture -Path $toolPath).Status 'Expired approval must block.'

    Write-FixtureManifest -Id 'Tracked' -Sha256 $hash
    Assert-Equal 'local-untrusted' (Test-NTKExternalToolTrust -ToolId 'LocallyAdded' -Path $toolPath).Status 'Untracked local tool must be classified.'

    Write-FixtureManifest -Id 'Fixture' -Sha256 $hash -EulaRequired $true
    Assert-Equal 'eula-required' (Test-NTKExternalToolTrust -ToolId Fixture -Path $toolPath -EulaEnforced $false).Status 'Required EULA must be enforced.'

    Write-Host 'TASK-0093 external tool provenance fixtures passed.' -ForegroundColor Green
}
finally {
    if(Test-Path Function:\Get-AuthenticodeSignature){ Remove-Item Function:\Get-AuthenticodeSignature -Force -ErrorAction SilentlyContinue }
    Remove-Item -LiteralPath $testRoot -Recurse -Force -ErrorAction SilentlyContinue
}
