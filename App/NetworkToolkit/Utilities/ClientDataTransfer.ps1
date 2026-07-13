function Resolve-NTKDeploymentRoot {
    param(
        [Parameter(Mandatory=$true)][string]$Path
    )

    $resolved = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
    if((Test-Path -LiteralPath (Join-Path $resolved "NetworkToolkit.vbs") -PathType Leaf) -and
       (Test-Path -LiteralPath (Join-Path $resolved "App\NetworkToolkit\NetworkToolkit-Core.ps1") -PathType Leaf)){
        return $resolved
    }

    if((Split-Path -Leaf $resolved) -eq "App" -and
       (Test-Path -LiteralPath (Join-Path $resolved "NetworkToolkit\NetworkToolkit-Core.ps1") -PathType Leaf)){
        return (Split-Path -Parent $resolved)
    }

    if((Test-Path -LiteralPath (Join-Path $resolved "NetworkToolkit\NetworkToolkit-Core.ps1") -PathType Leaf) -and
       (Test-Path -LiteralPath (Join-Path $resolved "NetworkToolkit.ps1") -PathType Leaf)){
        return (Split-Path -Parent $resolved)
    }

    throw "Destination does not appear to be a Network Toolkit root or App folder: $Path"
}

function Get-NTKClientDataTransferRoots {
    param(
        [Parameter(Mandatory=$true)][string]$DeploymentRoot
    )

    $relativeRoots = @(
        "Runtime\Data",
        "Runtime\Exports",
        "Runtime\Logs",
        "App\Triage\Runs",
        "App\Triage\Profiles",
        "App\logs",
        "App\NetworkToolkit\Data",
        "App\NetworkToolkit\Exports",
        "App\NetworkToolkit\Logs"
    )

    foreach($relative in $relativeRoots){
        [pscustomobject]@{
            RelativePath = $relative
            SourcePath = Join-Path $DeploymentRoot $relative
            DestinationPath = $null
        }
    }
}

function Get-NTKClientDataFileList {
    param(
        [Parameter(Mandatory=$true)][string]$DeploymentRoot
    )

    $roots = @(Get-NTKClientDataTransferRoots -DeploymentRoot $DeploymentRoot)
    $files = New-Object System.Collections.Generic.List[object]

    foreach($root in $roots){
        if(!(Test-Path -LiteralPath $root.SourcePath)){
            continue
        }

        $rootFull = [System.IO.Path]::GetFullPath($root.SourcePath).TrimEnd('\')
        foreach($file in @(Get-ChildItem -LiteralPath $root.SourcePath -Force -Recurse -File -ErrorAction SilentlyContinue)){
            if($file.Name -eq ".gitkeep"){
                continue
            }

            $relativeFile = $file.FullName.Substring($rootFull.Length).TrimStart('\')
            $artifactMetadata = if(Get-Command Get-NTKArtifactMetadata -ErrorAction SilentlyContinue){Get-NTKArtifactMetadata -Path $file.FullName}else{[pscustomobject]@{Classification='ClientEvidence'}}
            $files.Add([pscustomobject]@{
                RootRelativePath = $root.RelativePath
                RelativeFilePath = $relativeFile
                FullName = $file.FullName
                Length = [int64]$file.Length
                Sensitivity = $artifactMetadata.Classification
            }) | Out-Null
        }
    }

    return @($files.ToArray())
}

function Test-NTKClientDataDestinationHasData {
    param(
        [Parameter(Mandatory=$true)][string]$DestinationRoot
    )

    return (@(Get-NTKClientDataFileList -DeploymentRoot $DestinationRoot).Count -gt 0)
}

function Copy-NTKClientData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$SourceRoot,
        [Parameter(Mandatory=$true)][string]$DestinationRoot,
        [switch]$Force,
        [ValidateSet('Operational','ClientEvidence','Sensitive')][string[]]$IncludeSensitivity=@('Operational','ClientEvidence'),
        [switch]$EncryptSensitive,
        [string]$EncryptionPassword=''
    )

    $sourceDeployment = Resolve-NTKDeploymentRoot -Path $SourceRoot
    $destinationDeployment = Resolve-NTKDeploymentRoot -Path $DestinationRoot

    if([System.IO.Path]::GetFullPath($sourceDeployment).TrimEnd('\') -ieq [System.IO.Path]::GetFullPath($destinationDeployment).TrimEnd('\')){
        throw "Source and destination are the same toolkit."
    }

    if((Test-NTKClientDataDestinationHasData -DestinationRoot $destinationDeployment) -and !$Force){
        throw "Destination already contains client data. Re-run with -Force only after technician confirmation."
    }

    if($IncludeSensitivity -contains 'Sensitive' -and !$EncryptSensitive){ throw 'Sensitive transfers require -EncryptSensitive and a password.' }
    if($EncryptSensitive -and [string]::IsNullOrWhiteSpace($EncryptionPassword)){ throw 'EncryptionPassword is required for sensitive transfer.' }
    $allSourceFiles = @(Get-NTKClientDataFileList -DeploymentRoot $sourceDeployment)
    $sourceFiles = @($allSourceFiles | Where-Object { $IncludeSensitivity -contains $_.Sensitivity })
    [int64]$requiredBytes=($sourceFiles|Measure-Object Length -Sum).Sum
    $driveName=[IO.Path]::GetPathRoot($destinationDeployment).TrimEnd('\').TrimEnd(':')
    $drive=Get-PSDrive -Name $driveName -ErrorAction SilentlyContinue
    if($drive -and $drive.Free -lt ($requiredBytes + 10MB)){throw 'Destination does not have enough free space for the selected transfer.'}
    $copiedFiles = 0
    [int64]$copiedBytes = 0
    $includedRoots = New-Object System.Collections.Generic.List[string]
    $failures = New-Object System.Collections.Generic.List[object]
    $verifiedFiles = New-Object System.Collections.Generic.List[object]

    foreach($file in $sourceFiles){
        $destinationRoot = Join-Path $destinationDeployment $file.RootRelativePath
        $destinationPath = Join-Path $destinationRoot $file.RelativeFilePath
        if($file.Sensitivity -eq 'Sensitive'){ $destinationPath += '.ntkenc' }
        $destinationParent = Split-Path -Parent $destinationPath
        if(!(Test-Path -LiteralPath $destinationParent)){
            New-Item -ItemType Directory -Path $destinationParent -Force | Out-Null
        }

        try {
            if($file.Sensitivity -eq 'Sensitive'){
                Protect-NTKTransferFile -Source $file.FullName -Destination $destinationPath -Password $EncryptionPassword | Out-Null
            } else {
                Copy-Item -LiteralPath $file.FullName -Destination $destinationPath -Force -ErrorAction Stop
            }
            $sourceHash=(Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
            $destinationHash=(Get-FileHash -LiteralPath $destinationPath -Algorithm SHA256).Hash
            if($file.Sensitivity -ne 'Sensitive' -and $sourceHash -ne $destinationHash){throw 'Destination hash verification failed.'}
            [void]$verifiedFiles.Add([pscustomobject]@{RelativePath=(Join-Path $file.RootRelativePath $file.RelativeFilePath);Sensitivity=$file.Sensitivity;Encrypted=($file.Sensitivity -eq 'Sensitive');SourceSHA256=$sourceHash;DestinationSHA256=$destinationHash;Verified=$true})
            $copiedFiles++
            $copiedBytes += [int64]$file.Length
            if(!$includedRoots.Contains($file.RootRelativePath)){
                $includedRoots.Add($file.RootRelativePath) | Out-Null
            }
        }
        catch {
            $failures.Add([pscustomobject]@{
                Source = $file.FullName
                Destination = $destinationPath
                Error = $_.Exception.Message
            }) | Out-Null
        }
    }

    $transferredRunIdentities = New-Object System.Collections.Generic.List[object]
    if(Get-Command Resolve-NTKDiagnosticBundle -ErrorAction SilentlyContinue){
        $runRoots = @($sourceFiles | Where-Object { $_.RootRelativePath -eq "App\Triage\Runs" -and $_.RelativeFilePath -match '^[^\\]+\\Metadata\\collection_manifest\.json$' } | ForEach-Object { ($_.RelativeFilePath -split '\\')[0] } | Select-Object -Unique)
        foreach($runName in $runRoots){
            try {
                $sourceRun = Join-Path (Join-Path $sourceDeployment "App\Triage\Runs") $runName
                $destinationRun = Join-Path (Join-Path $destinationDeployment "App\Triage\Runs") $runName
                $sourceIdentity = (Resolve-NTKDiagnosticBundle -BundleRoot $sourceRun).Identity
                $destinationIdentity = (Resolve-NTKDiagnosticBundle -BundleRoot $destinationRun).Identity
                if($sourceIdentity.runId -ne $destinationIdentity.runId -or $sourceIdentity.bundleId -ne $destinationIdentity.bundleId){ throw "Transferred run identity mismatch." }
                [void]$transferredRunIdentities.Add([pscustomobject]@{RunId=$sourceIdentity.runId;BundleId=$sourceIdentity.bundleId;ComputerName=$sourceIdentity.computerName;Verified=$true})
            }
            catch {
                [void]$failures.Add([pscustomobject]@{Source=$runName;Destination=$runName;Error="Run identity verification failed: $($_.Exception.Message)"})
            }
        }
    }

    $manifestRoot = Join-Path $destinationDeployment "Runtime\Data\ClientDataTransfers"
    if(!(Test-Path -LiteralPath $manifestRoot)){
        New-Item -ItemType Directory -Path $manifestRoot -Force | Out-Null
    }

    $timestamp = Get-Date
    $manifestPath = Join-Path $manifestRoot ("client-data-transfer-{0}-{1}.json" -f $env:COMPUTERNAME,$timestamp.ToString("yyyyMMdd-HHmmss"))
    $manifest = [pscustomobject]@{
        TransferType = "ClientDiagnosticData"
        CreatedAt = $timestamp.ToString("o")
        SourceRoot = $sourceDeployment
        DestinationRoot = $destinationDeployment
        IncludedFolders = @($includedRoots.ToArray())
        SourceFileCount = $allSourceFiles.Count
        SelectedFileCount = $sourceFiles.Count
        IncludedSensitivity = @($IncludeSensitivity)
        SensitiveFilesEncrypted = [bool]$EncryptSensitive
        CopiedFileCount = $copiedFiles
        CopiedByteCount = $copiedBytes
        CopiedSizeMB = [math]::Round(($copiedBytes / 1MB),2)
        Excluded = @(
            "Application code",
            "Portable apps and external tools",
            "Custom app binaries",
            "Git metadata",
            "Build and release folders"
        )
        Failures = @($failures.ToArray())
        VerifiedFiles = @($verifiedFiles.ToArray())
        TransferredRunIdentities = @($transferredRunIdentities.ToArray())
    }

    if(Get-Command Write-NTKAtomicJson -ErrorAction SilentlyContinue){Write-NTKAtomicJson -Path $manifestPath -Value $manifest -Depth 8|Out-Null}else{$manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $manifestPath -Encoding UTF8}

    $manifest | Add-Member -MemberType NoteProperty -Name ManifestPath -Value $manifestPath -Force
    $manifest | Add-Member -MemberType NoteProperty -Name Status -Value $(if($failures.Count -gt 0){"CompletedWithWarnings"}else{"Completed"}) -Force
    return $manifest
}
$diagnosticIdentityModule = Join-Path (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))) "Core\Analysis\DiagnosticBundleIdentity.ps1"
if(Test-Path -LiteralPath $diagnosticIdentityModule){ . $diagnosticIdentityModule }
