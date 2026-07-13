# =====================================================================
# DiagnosticBundleIdentity.ps1
# Validated immutable diagnostic run identity and source evidence boundary
# =====================================================================

function Global:Get-NTKDiagnosticManifestPath {
    param([Parameter(Mandatory=$true)][string]$BundleRoot)

    foreach($relative in @("Metadata\collection_manifest.json","collection_manifest.json","Analysis\collection_manifest.json")){
        $candidate = Join-Path $BundleRoot $relative
        if(Test-Path -LiteralPath $candidate -PathType Leaf){ return $candidate }
    }
    return $null
}

function Global:Get-NTKDiagnosticBundleId {
    param([Parameter(Mandatory=$true)][object]$Manifest)

    $canonical = "{0}|{1}|{2}" -f ([string]$Manifest.runId).Trim(),([string]$Manifest.computerName).Trim(),([string]$Manifest.startedUtc).Trim()
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($canonical)
        return "NTK-" + (($sha.ComputeHash($bytes) | ForEach-Object { $_.ToString("x2") }) -join "")
    }
    finally { $sha.Dispose() }
}

function Global:Get-NTKDiagnosticSourceFiles {
    param([Parameter(Mandatory=$true)][string]$BundleRoot)

    $root = [System.IO.Path]::GetFullPath($BundleRoot).TrimEnd('\','/')
    return @(Get-ChildItem -LiteralPath $root -File -Recurse -ErrorAction SilentlyContinue | Where-Object {
        $relative = $_.FullName.Substring($root.Length).TrimStart('\','/')
        $relative -notmatch '^(Analysis|Metadata|ARGUS)([\\/]|$)' -and
        $relative -notmatch '(^|[\\/])(report|technician-report|escalation-report)\.(html?|md|json)$'
    })
}

function Global:Test-NTKDiagnosticBundle {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$BundleRoot,
        [switch]$PassThru
    )

    $errors = New-Object System.Collections.Generic.List[string]
    $manifest = $null
    $manifestPath = $null
    $resolvedRoot = $null

    if(!(Test-Path -LiteralPath $BundleRoot -PathType Container)){
        [void]$errors.Add("Bundle root does not exist or is not a directory.")
    }
    else {
        $resolvedRoot = (Resolve-Path -LiteralPath $BundleRoot).Path
        $manifestPath = Get-NTKDiagnosticManifestPath -BundleRoot $resolvedRoot
        if(!$manifestPath){
            [void]$errors.Add("No collection_manifest.json identity marker was found.")
        }
        else {
            try { $manifest = Get-Content -LiteralPath $manifestPath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop }
            catch { [void]$errors.Add("Collection manifest is not valid JSON: $($_.Exception.Message)") }
        }
    }

    if($manifest){
        foreach($required in @("runId","computerName","startedUtc")){
            if(!$manifest.PSObject.Properties[$required] -or [string]::IsNullOrWhiteSpace([string]$manifest.$required)){
                [void]$errors.Add("Collection manifest is missing required field '$required'.")
            }
        }
        if($manifest.startedUtc){
            $parsed = [datetime]::MinValue
            if(![datetime]::TryParse([string]$manifest.startedUtc,[ref]$parsed)){ [void]$errors.Add("Collection manifest startedUtc is invalid.") }
        }
        if(@(Get-NTKDiagnosticSourceFiles -BundleRoot $resolvedRoot).Count -eq 0){
            [void]$errors.Add("Bundle contains no source evidence outside generated output directories.")
        }
    }

    $valid = ($errors.Count -eq 0)
    $identity = $null
    if($valid){
        $identity = [pscustomobject]@{
            schemaVersion = "1.0"
            runId = [string]$manifest.runId
            bundleId = Get-NTKDiagnosticBundleId -Manifest $manifest
            computerName = [string]$manifest.computerName
            collectionStartedUtc = [string]$manifest.startedUtc
            collectionCompletedUtc = if($manifest.endedUtc){[string]$manifest.endedUtc}else{$null}
            bundleRoot = $resolvedRoot
            sourceManifest = $manifestPath.Substring($resolvedRoot.Length).TrimStart('\','/')
        }
    }

    $result = [pscustomobject]@{ Valid=$valid; BundleRoot=$resolvedRoot; ManifestPath=$manifestPath; Manifest=$manifest; Identity=$identity; Errors=@($errors.ToArray()) }
    if($PassThru){ return $result }
    return $valid
}

function Global:Resolve-NTKDiagnosticBundle {
    param([Parameter(Mandatory=$true)][string]$BundleRoot)
    $result = Test-NTKDiagnosticBundle -BundleRoot $BundleRoot -PassThru
    if(!$result.Valid){ throw "Invalid diagnostic bundle '$BundleRoot': $($result.Errors -join ' ')" }
    return $result
}

function Global:Get-NTKDefaultDiagnosticBundleRoot {
    param([Parameter(Mandatory=$true)][string]$SearchRoot)
    if(!(Test-Path -LiteralPath $SearchRoot -PathType Container)){ throw "Diagnostic bundle search root does not exist: $SearchRoot" }

    $roots = New-Object System.Collections.Generic.List[string]
    foreach($manifest in @(Get-ChildItem -LiteralPath $SearchRoot -Filter "collection_manifest.json" -File -Recurse -ErrorAction SilentlyContinue)){
        $parent = Split-Path -Parent $manifest.DirectoryName
        if($manifest.Directory.Name -notin @("Metadata","Analysis")){ $parent = $manifest.DirectoryName }
        if(!$roots.Contains($parent)){ [void]$roots.Add($parent) }
    }

    $valid = @()
    foreach($root in $roots){
        $candidate = Test-NTKDiagnosticBundle -BundleRoot $root -PassThru
        if($candidate.Valid){
            if(Get-Command Register-NTKRunIdentity -ErrorAction SilentlyContinue){ [void](Register-NTKRunIdentity -RunIdentity $candidate.Identity) }
            $started = [datetime]::MinValue
            [void][datetime]::TryParse($candidate.Identity.collectionStartedUtc,[ref]$started)
            $valid += [pscustomobject]@{ Root=$candidate.BundleRoot; Started=$started; RunId=$candidate.Identity.runId }
        }
    }
    if(Get-Command Get-NTKRunIndex -ErrorAction SilentlyContinue){
        $resolvedSearchRoot = (Resolve-Path -LiteralPath $SearchRoot).Path.TrimEnd('\','/')
        $indexed = @(Get-NTKRunIndex | Where-Object { $_.bundleRoot -and ([IO.Path]::GetFullPath([string]$_.bundleRoot).TrimEnd('\','/')).StartsWith($resolvedSearchRoot,[StringComparison]::OrdinalIgnoreCase) } |
            Sort-Object @{Expression={[datetimeoffset]$_.collectionStartedUtc};Descending=$true},@{Expression={$_.runId};Descending=$true}) | Select-Object -First 1
        if($indexed -and (Test-Path -LiteralPath $indexed.bundleRoot -PathType Container)){ return [string]$indexed.bundleRoot }
    }
    $selected = $valid | Sort-Object Started,RunId -Descending | Select-Object -First 1
    if(!$selected){ throw "No valid diagnostic bundles were found under: $SearchRoot" }
    return $selected.Root
}

function Global:Write-NTKDiagnosticRunIdentity {
    param([Parameter(Mandatory=$true)][object]$BundleValidation)
    if(!$BundleValidation.Valid){ throw "Cannot write identity for an invalid diagnostic bundle." }
    $path = Join-Path $BundleValidation.BundleRoot "Metadata\run-identity.json"
    if(Test-Path -LiteralPath $path){
        $existing = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
        if($existing.runId -ne $BundleValidation.Identity.runId -or $existing.bundleId -ne $BundleValidation.Identity.bundleId){
            throw "Existing run identity conflicts with the validated collection manifest: $path"
        }
        return $path
    }
    $parent = Split-Path -Parent $path
    if(!(Test-Path -LiteralPath $parent)){ New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    $BundleValidation.Identity | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $path -Encoding UTF8
    return $path
}
