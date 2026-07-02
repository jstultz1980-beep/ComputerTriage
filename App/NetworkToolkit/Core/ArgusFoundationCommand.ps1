# =====================================================================
# ArgusFoundationCommand.ps1
# Console bridge for Core\Argus foundation implementation
# =====================================================================

$argusModule = Join-Path (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))) "Core\Argus\ArgusFoundation.ps1"

if(Test-Path $argusModule){
    . "$argusModule"
}
else{
    throw "ARGUS foundation module not found: $argusModule"
}

if(Get-Command Register-NTKCommand -ErrorAction SilentlyContinue){
    Register-NTKCommand `
        -Name "Run ARGUS Foundation" `
        -Command "Invoke-ARGUSFoundationAnalysis" `
        -Category "Analyze" `
        -Description "Validate HEPHAESTUS analysis artifacts and produce ARGUS foundation outputs." `
        -Source "ARGUS" `
        -Id "argus-foundation" `
        -Order 45
}
