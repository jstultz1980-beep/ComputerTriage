function ConvertTo-NTKExtendedPath {
    param([Parameter(Mandatory=$true)][string]$Path)

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    if($fullPath.StartsWith('\\?\',[System.StringComparison]::Ordinal)){
        return $fullPath
    }

    if($fullPath.StartsWith('\\',[System.StringComparison]::Ordinal)){
        return '\\?\UNC\' + $fullPath.TrimStart('\')
    }

    return '\\?\' + $fullPath
}

function Remove-NTKMutableTreeEntry {
    param([Parameter(Mandatory=$true)][string]$Path)

    $extendedPath = ConvertTo-NTKExtendedPath -Path $Path

    if([System.IO.File]::Exists($extendedPath)){
        [System.IO.File]::SetAttributes($extendedPath, [System.IO.FileAttributes]::Normal)
        [System.IO.File]::Delete($extendedPath)
        return
    }

    if([System.IO.Directory]::Exists($extendedPath)){
        $children = @([System.IO.Directory]::EnumerateFileSystemEntries($extendedPath))
        foreach($child in $children){
            Remove-NTKMutableTreeEntry -Path $child
        }

        if(@([System.IO.Directory]::EnumerateFileSystemEntries($extendedPath)).Count -gt 0){
            throw "Mutable tree entry is still not empty: $Path"
        }

        [System.IO.Directory]::Delete($extendedPath, $false)
        return
    }

    throw "Mutable tree entry was not found during cleanup: $Path"
}

function Invoke-NTKMutableTreeCleanup {
    param([Parameter(Mandatory=$true)][string]$Path)

    if(!(Test-Path -LiteralPath $Path)){
        return
    }

    $resolvedPath = (Resolve-Path -LiteralPath $Path).Path
    $rootExtendedPath = ConvertTo-NTKExtendedPath -Path $resolvedPath

    foreach($child in @([System.IO.Directory]::EnumerateFileSystemEntries($rootExtendedPath))){
        Remove-NTKMutableTreeEntry -Path $child
    }

    $remainingFiles = @(Get-ChildItem -LiteralPath $resolvedPath -Recurse -File -Force -ErrorAction SilentlyContinue)
    if($remainingFiles.Count -gt 0){
        $firstRemaining = $remainingFiles | Select-Object -First 1
        throw "Mutable tree cleanup failed for $Path; $($remainingFiles.Count) file(s) remain. First remaining file: $($firstRemaining.FullName)"
    }
}
