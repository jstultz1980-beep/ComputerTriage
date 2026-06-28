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

    $validation = Test-NTKTriageSetup
    if(!$validation.passed){
        $failed = @($validation.checks | Where-Object { !$_.passed } | ForEach-Object { $_.name }) -join ", "
        throw "Triage validation failed: $failed"
    }
}
finally {
    Remove-Item -LiteralPath $testFolder -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "Triage service smoke test passed."
