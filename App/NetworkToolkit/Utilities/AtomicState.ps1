function Global:Invoke-NTKFileLock {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][scriptblock]$Action,
        [int]$TimeoutMilliseconds = 10000
    )

    $lockPath = "$Path.lock"
    $parent = Split-Path -Parent $lockPath
    if($parent -and !(Test-Path -LiteralPath $parent)){ New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    $deadline = [datetime]::UtcNow.AddMilliseconds($TimeoutMilliseconds)
    $stream = $null
    while(!$stream){
        try { $stream = [IO.File]::Open($lockPath,[IO.FileMode]::OpenOrCreate,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None) }
        catch {
            if([datetime]::UtcNow -ge $deadline){ throw "Timed out waiting for state lock: $Path" }
            Start-Sleep -Milliseconds 50
        }
    }
    try { & $Action }
    finally { $stream.Dispose(); Remove-Item -LiteralPath $lockPath -Force -ErrorAction SilentlyContinue }
}

function Global:Write-NTKAtomicJson {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][object]$Value,
        [int]$Depth = 20,
        [scriptblock]$BeforeCommit = { param($TemporaryPath) }
    )

    $parent = Split-Path -Parent $Path
    if($parent -and !(Test-Path -LiteralPath $parent)){ New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    $temporaryPath = Join-Path $parent ('.' + [IO.Path]::GetFileName($Path) + '.' + [guid]::NewGuid().ToString('N') + '.tmp')
    $backupPath = "$Path.bak"
    try {
        $json = $Value | ConvertTo-Json -Depth $Depth
        [IO.File]::WriteAllText($temporaryPath,$json,(New-Object Text.UTF8Encoding($false)))
        $null = Get-Content -LiteralPath $temporaryPath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        & $BeforeCommit $temporaryPath
        if(Test-Path -LiteralPath $Path){
            [IO.File]::Replace($temporaryPath,$Path,$backupPath,$true)
        } else {
            [IO.File]::Move($temporaryPath,$Path)
        }
        return $Path
    }
    finally { Remove-Item -LiteralPath $temporaryPath -Force -ErrorAction SilentlyContinue }
}

function Global:Write-NTKLockedJson {
    param([Parameter(Mandatory=$true)][string]$Path,[Parameter(Mandatory=$true)][object]$Value,[int]$Depth=20)
    Invoke-NTKFileLock -Path $Path -Action { Write-NTKAtomicJson -Path $Path -Value $Value -Depth $Depth }
}

function Global:Read-NTKJsonPreservingCorrupt {
    param([Parameter(Mandatory=$true)][string]$Path)
    if(!(Test-Path -LiteralPath $Path -PathType Leaf)){ return $null }
    try { return Get-Content -LiteralPath $Path -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop }
    catch {
        $preserved = "$Path.corrupt-$(Get-Date -Format 'yyyyMMddHHmmssfff')"
        Copy-Item -LiteralPath $Path -Destination $preserved -Force -ErrorAction SilentlyContinue
        throw "State JSON is invalid; original preserved at $preserved. $($_.Exception.Message)"
    }
}
