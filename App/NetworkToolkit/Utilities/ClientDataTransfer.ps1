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

    $appRoot = Join-Path $DeploymentRoot "App"
    $relativeRoots = @(
        "NetworkToolkit\Data",
        "NetworkToolkit\Exports",
        "NetworkToolkit\Logs",
        "Triage\Runs",
        "Triage\Profiles",
        "logs"
    )

    foreach($relative in $relativeRoots){
        [pscustomobject]@{
            RelativePath = $relative
            SourcePath = Join-Path $appRoot $relative
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
            $files.Add([pscustomobject]@{
                RootRelativePath = $root.RelativePath
                RelativeFilePath = $relativeFile
                FullName = $file.FullName
                Length = [int64]$file.Length
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
        [switch]$Force
    )

    $sourceDeployment = Resolve-NTKDeploymentRoot -Path $SourceRoot
    $destinationDeployment = Resolve-NTKDeploymentRoot -Path $DestinationRoot

    if([System.IO.Path]::GetFullPath($sourceDeployment).TrimEnd('\') -ieq [System.IO.Path]::GetFullPath($destinationDeployment).TrimEnd('\')){
        throw "Source and destination are the same toolkit."
    }

    if((Test-NTKClientDataDestinationHasData -DestinationRoot $destinationDeployment) -and !$Force){
        throw "Destination already contains client data. Re-run with -Force only after technician confirmation."
    }

    $sourceFiles = @(Get-NTKClientDataFileList -DeploymentRoot $sourceDeployment)
    $destinationAppRoot = Join-Path $destinationDeployment "App"
    $copiedFiles = 0
    [int64]$copiedBytes = 0
    $includedRoots = New-Object System.Collections.Generic.List[string]
    $failures = New-Object System.Collections.Generic.List[object]

    foreach($file in $sourceFiles){
        $destinationRoot = Join-Path $destinationAppRoot $file.RootRelativePath
        $destinationPath = Join-Path $destinationRoot $file.RelativeFilePath
        $destinationParent = Split-Path -Parent $destinationPath
        if(!(Test-Path -LiteralPath $destinationParent)){
            New-Item -ItemType Directory -Path $destinationParent -Force | Out-Null
        }

        try {
            Copy-Item -LiteralPath $file.FullName -Destination $destinationPath -Force -ErrorAction Stop
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

    $manifestRoot = Join-Path $destinationAppRoot "NetworkToolkit\Data\ClientDataTransfers"
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
        SourceFileCount = $sourceFiles.Count
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
    }

    $manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $manifestPath -Encoding UTF8

    $manifest | Add-Member -MemberType NoteProperty -Name ManifestPath -Value $manifestPath -Force
    $manifest | Add-Member -MemberType NoteProperty -Name Status -Value $(if($failures.Count -gt 0){"CompletedWithWarnings"}else{"Completed"}) -Force
    return $manifest
}
