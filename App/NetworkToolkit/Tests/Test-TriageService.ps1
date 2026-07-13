#Requires -Version 5.1

$ErrorActionPreference = "Stop"

$toolkitRoot = Split-Path -Parent $PSScriptRoot
$core = Join-Path $toolkitRoot "NetworkToolkit-Core.ps1"

if(!(Test-Path -LiteralPath $core)){
    throw "NetworkToolkit-Core.ps1 was not found at $core"
}

. $core -NoConsole

$paths = Initialize-NTKTriageStructure
if(!(Test-Path -LiteralPath $paths.Manifest)){
    throw "Triage manifest was not created at $($paths.Manifest)"
}

$manifest = Get-NTKTriageManifest
if(@($manifest.tools).Count -lt 5){
    throw "Triage manifest does not contain the expected tool catalog."
}

$status = @(Get-NTKTriageToolStatus)
if($status.Count -lt 5){
    throw "Triage tool status did not enumerate the manifest tools."
}

$testFolder = Join-Path $paths.Cache ("test-triage-{0}" -f [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $testFolder -Force | Out-Null
try {
    $out = Join-Path $testFolder "echo.txt"
    $command = Invoke-NTKTriageCommand -Name "echo_test" -FilePath "cmd.exe" -Arguments "/c echo triage-ok" -OutputPath $out -TimeoutSeconds 15
    if(!$command.succeeded){
        throw "Triage command runner failed with exit code $($command.exitCode)."
    }
    $text = Get-Content -LiteralPath $out -Raw
    if($text -notmatch "triage-ok"){
        throw "Triage command runner did not capture stdout."
    }

    $nonzero = Invoke-NTKTriageCommand -Name 'nonzero_fixture' -FilePath 'cmd.exe' -Arguments '/c exit 7' -OutputPath (Join-Path $testFolder 'nonzero.txt') -TimeoutSeconds 15
    if($nonzero.succeeded -or $nonzero.exitCode -ne 7){ throw 'Nonzero command outcome was not persisted accurately.' }
    $missing = Invoke-NTKTriageCommand -Name 'missing_fixture' -FilePath (Join-Path $testFolder 'missing.exe') -Arguments '' -OutputPath (Join-Path $testFolder 'missing.txt') -TimeoutSeconds 15
    if($missing.succeeded -or $missing.exitCode -ne -999){ throw 'Missing executable outcome was not persisted accurately.' }
    $collector = Export-NTKTriagePowerShellObject -Name 'failed_collector_fixture' -ScriptBlock { throw 'collector fixture' } -TxtPath (Join-Path $testFolder 'collector.txt') -JsonPath (Join-Path $testFolder 'collector.json')
    if($collector.succeeded -or $collector.error -notmatch 'collector fixture'){ throw 'Failed PowerShell collector outcome was not preserved.' }

    $bundleRoot = Join-Path $testFolder 'bundle-source'
    New-Item -ItemType Directory -Path $bundleRoot -Force | Out-Null
    'fixture' | Set-Content (Join-Path $bundleRoot 'artifact.txt')
    $bundle = Join-Path $testFolder 'fixture.zip'
    Compress-Archive -LiteralPath (Join-Path $bundleRoot 'artifact.txt') -DestinationPath $bundle
    $hash = (Get-FileHash $bundle -Algorithm SHA256).Hash
    [ordered]@{algorithm='SHA256';bundleFileName='fixture.zip';sha256=$hash} | ConvertTo-Json | Set-Content ($bundle + '.sha256.json')
    if(!(Test-NTKDiagnosticBundleIntegrity -BundlePath $bundle).passed){ throw 'Final bundle hash did not validate.' }
    [IO.File]::AppendAllText($bundle,'tamper')
    if((Test-NTKDiagnosticBundleIntegrity -BundlePath $bundle).passed){ throw 'Tampered bundle was accepted.' }

    $validation = Test-NTKTriageSetup
    if(!$validation.passed){
        $failed = @($validation.checks | Where-Object { !$_.passed } | ForEach-Object { $_.name }) -join ", "
        throw "Triage validation failed: $failed"
    }
}
finally {
    Remove-Item -LiteralPath $testFolder -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "Triage service integrity and failure fixtures passed."
