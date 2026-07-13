# =====================================================================
# ReportingContract.ps1
# Shared report metadata, escaping, and immutable run artifact index
# =====================================================================

$Global:NTKReportingContractDefaultIndexRoot = Join-Path (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))) 'Runtime\Data\RunIndex'

function Global:ConvertTo-NTKReportHtml {
    param([AllowNull()][object]$Value)
    if($null -eq $Value){ return '' }
    return [System.Net.WebUtility]::HtmlEncode([string]$Value)
}

function Global:ConvertTo-NTKReportMarkdown {
    param([AllowNull()][object]$Value,[string]$UnavailableText = 'Not available')
    if($null -eq $Value -or [string]::IsNullOrWhiteSpace([string]$Value)){ return $UnavailableText }
    return ((([string]$Value) -replace "`r?`n", ' ') -replace '\|', '\|').Trim()
}

function Global:Get-NTKRunIndexRoot {
    param([string]$IndexRoot)
    if($IndexRoot){ return [IO.Path]::GetFullPath($IndexRoot) }
    if($Global:NTKPaths -and $Global:NTKPaths.Data){ return Join-Path $Global:NTKPaths.Data 'RunIndex' }
    return $Global:NTKReportingContractDefaultIndexRoot
}

function Global:Get-NTKSha256Text {
    param([Parameter(Mandatory=$true)][string]$Value)
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return (($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($Value)) | ForEach-Object { $_.ToString('x2') }) -join '') }
    finally { $sha.Dispose() }
}

function Global:Get-NTKFileSha256 {
    param([Parameter(Mandatory=$true)][string]$Path)
    $sha = [Security.Cryptography.SHA256]::Create()
    $stream = [IO.File]::OpenRead($Path)
    try { return (($sha.ComputeHash($stream) | ForEach-Object { $_.ToString('x2') }) -join '') }
    finally { $stream.Dispose(); $sha.Dispose() }
}

function Global:Get-NTKReportField {
    param([AllowNull()][object]$InputObject,[Parameter(Mandatory=$true)][string]$Name)
    if($null -eq $InputObject){ return $null }
    if($InputObject -is [Collections.IDictionary] -and $InputObject.Contains($Name)){ return $InputObject[$Name] }
    if($InputObject.PSObject.Properties[$Name]){ return $InputObject.$Name }
    return $null
}

function Global:Test-NTKRunIdentity {
    param([Parameter(Mandatory=$true)][object]$RunIdentity,[switch]$ThrowOnError)
    $errors = New-Object Collections.Generic.List[string]
    foreach($field in @('runId','bundleId','computerName','collectionStartedUtc')){
        if([string]::IsNullOrWhiteSpace([string](Get-NTKReportField -InputObject $RunIdentity -Name $field))){
            [void]$errors.Add("Run identity is missing required field '$field'.")
        }
    }
    $startedUtc = Get-NTKReportField -InputObject $RunIdentity -Name 'collectionStartedUtc'
    if($startedUtc){
        $parsed = [datetimeoffset]::MinValue
        if(![datetimeoffset]::TryParse([string]$startedUtc,[ref]$parsed)){
            [void]$errors.Add('Run identity collectionStartedUtc is invalid.')
        }
    }
    if($errors.Count -and $ThrowOnError){ throw ($errors -join ' ') }
    return [pscustomobject]@{ Valid=($errors.Count -eq 0); Errors=@($errors.ToArray()) }
}

function Global:New-NTKReportMetadata {
    param(
        [Parameter(Mandatory=$true)][string]$ReportType,
        [Parameter(Mandatory=$true)][string]$Title,
        [Parameter(Mandatory=$true)][ValidateSet('html','markdown','json','csv','text','xml')][string]$Format,
        [Parameter(Mandatory=$true)][object]$RunIdentity,
        [string[]]$SourceArtifacts = @(),
        [string[]]$Limitations = @(),
        [datetimeoffset]$GeneratedAtUtc = [datetimeoffset]::UtcNow
    )
    [void](Test-NTKRunIdentity -RunIdentity $RunIdentity -ThrowOnError)
    $runId = Get-NTKReportField -InputObject $RunIdentity -Name 'runId'
    $bundleId = Get-NTKReportField -InputObject $RunIdentity -Name 'bundleId'
    $seed = '{0}|{1}|{2}|{3}' -f $runId,$ReportType,$Format,$GeneratedAtUtc.ToString('o')
    return [pscustomobject][ordered]@{
        schemaVersion = '1.0'
        reportId = 'NTK-REPORT-' + (Get-NTKSha256Text -Value $seed)
        reportType = $ReportType
        title = $Title
        format = $Format
        generatedAtUtc = $GeneratedAtUtc.ToUniversalTime().ToString('o')
        runIdentity = [pscustomobject][ordered]@{
            runId = [string]$runId
            bundleId = [string]$bundleId
            computerName = [string](Get-NTKReportField -InputObject $RunIdentity -Name 'computerName')
            collectionStartedUtc = [string](Get-NTKReportField -InputObject $RunIdentity -Name 'collectionStartedUtc')
        }
        sourceArtifacts = @($SourceArtifacts)
        limitations = @($Limitations)
    }
}

function Global:Resolve-NTKReportRunIdentity {
    param([AllowNull()][object]$InputObject,[string]$ComputerName,[datetimeoffset]$CollectionStartedUtc = [datetimeoffset]::MinValue)
    foreach($propertyName in @('RunIdentity','runIdentity','SourceBundle','sourceBundle')){
        if($InputObject -and $InputObject.PSObject.Properties[$propertyName] -and $InputObject.$propertyName){
            $candidate = $InputObject.$propertyName
            if((Test-NTKRunIdentity -RunIdentity $candidate).Valid){ return $candidate }
        }
    }
    if(!$ComputerName -and $InputObject -and $InputObject.PSObject.Properties['ComputerName']){ $ComputerName = [string]$InputObject.ComputerName }
    if(!$ComputerName){ $ComputerName = if($env:COMPUTERNAME){$env:COMPUTERNAME}else{'UnknownComputer'} }
    if($CollectionStartedUtc -eq [datetimeoffset]::MinValue -and $InputObject){
        foreach($field in @('CollectedAt','CapturedAt','generatedAtUtc')){
            if($InputObject.PSObject.Properties[$field] -and $InputObject.$field){
                $parsed = [datetimeoffset]::MinValue
                if([datetimeoffset]::TryParse([string]$InputObject.$field,[ref]$parsed)){ $CollectionStartedUtc = $parsed; break }
            }
        }
    }
    if($CollectionStartedUtc -eq [datetimeoffset]::MinValue){ $CollectionStartedUtc = [datetimeoffset]::UtcNow }
    $runId = 'NTK-REPORT-RUN-' + [guid]::NewGuid().ToString('N')
    $identity = [pscustomobject][ordered]@{
        schemaVersion = '1.0'
        runId = $runId
        bundleId = 'NTK-STANDALONE-' + (Get-NTKSha256Text -Value ("$runId|$ComputerName|$($CollectionStartedUtc.ToUniversalTime().ToString('o'))"))
        computerName = $ComputerName
        collectionStartedUtc = $CollectionStartedUtc.ToUniversalTime().ToString('o')
        collectionCompletedUtc = [datetimeoffset]::UtcNow.ToString('o')
        bundleRoot = $null
        sourceManifest = $null
    }
    if($InputObject){
        try { $InputObject | Add-Member -NotePropertyName RunIdentity -NotePropertyValue $identity -Force }
        catch { }
    }
    return $identity
}

function Global:Get-NTKRunIndexDirectory {
    param([Parameter(Mandatory=$true)][object]$RunIdentity,[string]$IndexRoot)
    $root = Get-NTKRunIndexRoot -IndexRoot $IndexRoot
    return Join-Path $root (Get-NTKSha256Text -Value ([string](Get-NTKReportField -InputObject $RunIdentity -Name 'runId'))).Substring(0,32)
}

function Global:Write-NTKImmutableJson {
    param([Parameter(Mandatory=$true)][string]$Path,[Parameter(Mandatory=$true)][object]$Value)
    $json = $Value | ConvertTo-Json -Depth 20
    $writeAction = {
        if(Test-Path -LiteralPath $Path -PathType Leaf){
            $existing = (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json) | ConvertTo-Json -Depth 20
            if($existing -ne $json){ throw "Immutable run-index record conflicts with existing record: $Path" }
            return $Path
        }
        $parent = Split-Path -Parent $Path
        if(!(Test-Path -LiteralPath $parent)){ New-Item -ItemType Directory -Path $parent -Force | Out-Null }
        if(Get-Command Write-NTKAtomicJson -ErrorAction SilentlyContinue){ return Write-NTKAtomicJson -Path $Path -Value $Value -Depth 20 }
        $temporary = "$Path.$([guid]::NewGuid().ToString('N')).tmp"
        try {
            [IO.File]::WriteAllText($temporary,$json,(New-Object Text.UTF8Encoding($false)))
            [IO.File]::Move($temporary,$Path)
            return $Path
        }
        finally { Remove-Item -LiteralPath $temporary -Force -ErrorAction SilentlyContinue }
    }
    if(Get-Command Invoke-NTKFileLock -ErrorAction SilentlyContinue){ return Invoke-NTKFileLock -Path $Path -Action $writeAction }
    return & $writeAction
}

function Global:Register-NTKRunIdentity {
    param([Parameter(Mandatory=$true)][object]$RunIdentity,[string]$IndexRoot)
    [void](Test-NTKRunIdentity -RunIdentity $RunIdentity -ThrowOnError)
    $directory = Get-NTKRunIndexDirectory -RunIdentity $RunIdentity -IndexRoot $IndexRoot
    $record = [pscustomobject][ordered]@{
        schemaVersion = '1.0'
        runId = [string](Get-NTKReportField -InputObject $RunIdentity -Name 'runId')
        bundleId = [string](Get-NTKReportField -InputObject $RunIdentity -Name 'bundleId')
        computerName = [string](Get-NTKReportField -InputObject $RunIdentity -Name 'computerName')
        collectionStartedUtc = [string](Get-NTKReportField -InputObject $RunIdentity -Name 'collectionStartedUtc')
        collectionCompletedUtc = Get-NTKReportField -InputObject $RunIdentity -Name 'collectionCompletedUtc'
        bundleRoot = Get-NTKReportField -InputObject $RunIdentity -Name 'bundleRoot'
        sourceManifest = Get-NTKReportField -InputObject $RunIdentity -Name 'sourceManifest'
    }
    return Write-NTKImmutableJson -Path (Join-Path $directory 'identity.json') -Value $record
}

function Global:Register-NTKRunArtifact {
    param(
        [Parameter(Mandatory=$true)][object]$RunIdentity,
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$ArtifactType,
        [Parameter(Mandatory=$true)][object]$ReportMetadata,
        [string]$IndexRoot
    )
    [void](Test-NTKRunIdentity -RunIdentity $RunIdentity -ThrowOnError)
    if(!(Test-Path -LiteralPath $Path -PathType Leaf)){ throw "Cannot index missing artifact: $Path" }
    $runId = Get-NTKReportField -InputObject $RunIdentity -Name 'runId'
    $bundleId = Get-NTKReportField -InputObject $RunIdentity -Name 'bundleId'
    if($ReportMetadata.runIdentity.runId -ne $runId -or $ReportMetadata.runIdentity.bundleId -ne $bundleId){
        throw 'Report metadata does not match the run identity being indexed.'
    }
    [void](Register-NTKRunIdentity -RunIdentity $RunIdentity -IndexRoot $IndexRoot)
    $resolvedPath = (Resolve-Path -LiteralPath $Path).Path
    $fileHash = Get-NTKFileSha256 -Path $resolvedPath
    $artifactId = 'NTK-ARTIFACT-' + (Get-NTKSha256Text -Value ('{0}|{1}|{2}|{3}|{4}' -f $runId,$ArtifactType,$resolvedPath,$fileHash,$ReportMetadata.reportId)).Substring(0,32)
    $record = [pscustomobject][ordered]@{
        schemaVersion = '1.0'
        artifactId = $artifactId
        runId = [string]$runId
        bundleId = [string]$bundleId
        artifactType = $ArtifactType
        path = $resolvedPath
        length = (Get-Item -LiteralPath $resolvedPath).Length
        sha256 = $fileHash
        registeredAtUtc = [string]$ReportMetadata.generatedAtUtc
        reportMetadata = $ReportMetadata
    }
    $directory = Join-Path (Get-NTKRunIndexDirectory -RunIdentity $RunIdentity -IndexRoot $IndexRoot) 'artifacts'
    [void](Write-NTKImmutableJson -Path (Join-Path $directory "$artifactId.json") -Value $record)
    return $record
}

function Global:Get-NTKRunIndex {
    param([string]$IndexRoot)
    $root = Get-NTKRunIndexRoot -IndexRoot $IndexRoot
    if(!(Test-Path -LiteralPath $root -PathType Container)){ return @() }
    return @(Get-ChildItem -LiteralPath $root -Filter identity.json -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
        try { Get-Content -LiteralPath $_.FullName -Raw | ConvertFrom-Json } catch { Write-Warning "Invalid run-index identity ignored: $($_.FullName)" }
    })
}

function Global:Get-NTKLatestRun {
    param([string]$IndexRoot)
    return @(Get-NTKRunIndex -IndexRoot $IndexRoot | Sort-Object @{Expression={[datetimeoffset]$_.collectionStartedUtc};Descending=$true},@{Expression={$_.runId};Descending=$true}) | Select-Object -First 1
}

function Global:Resolve-NTKRunArtifact {
    param([Parameter(Mandatory=$true)][object]$ArtifactRecord)
    $state = 'Available'
    $actualHash = $null
    if(!(Test-Path -LiteralPath $ArtifactRecord.path -PathType Leaf)){ $state = 'Missing' }
    else {
        $file = Get-Item -LiteralPath $ArtifactRecord.path
        $actualHash = Get-NTKFileSha256 -Path $file.FullName
        if($file.Length -ne [long]$ArtifactRecord.length -or $actualHash -ne $ArtifactRecord.sha256){ $state = 'Stale' }
    }
    return [pscustomobject]@{ State=$state; Artifact=$ArtifactRecord; ActualSha256=$actualHash }
}

function Global:Get-NTKRunArtifacts {
    param([Parameter(Mandatory=$true)][string]$RunId,[string]$ArtifactType,[string]$IndexRoot)
    $root = Get-NTKRunIndexRoot -IndexRoot $IndexRoot
    $directory = Join-Path (Join-Path $root (Get-NTKSha256Text -Value $RunId).Substring(0,32)) 'artifacts'
    if(!(Test-Path -LiteralPath $directory -PathType Container)){ return @() }
    $records = @(Get-ChildItem -LiteralPath $directory -Filter '*.json' -File | ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw | ConvertFrom-Json })
    if($ArtifactType){ $records = @($records | Where-Object artifactType -eq $ArtifactType) }
    return @($records | ForEach-Object { Resolve-NTKRunArtifact -ArtifactRecord $_ })
}

function Global:Get-NTKIndexedRunArtifacts {
    param([string]$ArtifactType,[string]$IndexRoot)
    $root = Get-NTKRunIndexRoot -IndexRoot $IndexRoot
    $results = @()
    foreach($identity in @(Get-NTKRunIndex -IndexRoot $root)){
        foreach($resolved in @(Get-NTKRunArtifacts -RunId $identity.runId -ArtifactType $ArtifactType -IndexRoot $root)){
            $results += [pscustomobject]@{
                Identity = $identity
                State = $resolved.State
                Artifact = $resolved.Artifact
                ActualSha256 = $resolved.ActualSha256
            }
        }
    }
    return @($results | Sort-Object @{Expression={[datetimeoffset]$_.Identity.collectionStartedUtc};Descending=$true},@{Expression={$_.Identity.runId};Descending=$true},@{Expression={$_.Artifact.registeredAtUtc};Descending=$true})
}
