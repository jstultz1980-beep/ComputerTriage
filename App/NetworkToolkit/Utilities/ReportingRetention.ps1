function Global:Test-NTKOutputHasSevereEvidence {

param([string]$Path)

    if(!$Path -or !(Test-Path $Path)){
        return $false
    }

    $patterns = '(?i)(critical|fatal|bugcheck|corruption detected|predicted failure|immediate attention|restorehealth failed|sfc.*could not repair|failed permanently)'

    try {
        if((Get-Item -LiteralPath $Path -ErrorAction Stop).PSIsContainer){
            $files = @(Get-ChildItem -LiteralPath $Path -File -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Length -le 2MB } | Select-Object -First 10)
            foreach($file in $files){
                if(Select-String -LiteralPath $file.FullName -Pattern $patterns -Quiet -ErrorAction SilentlyContinue){
                    return $true
                }
            }
        }
        else{
            $item = Get-Item -LiteralPath $Path -ErrorAction Stop
            if($item.Length -le 3MB){
                return [bool](Select-String -LiteralPath $Path -Pattern $patterns -Quiet -ErrorAction SilentlyContinue)
            }
        }
    }
    catch {
        if(Get-Command Write-NTKWarning -ErrorAction SilentlyContinue){
            Write-NTKWarning -Component 'Retention' -Message ("Could not inspect {0} for severe evidence: {1}" -f $Path,$_.Exception.Message)
        }
    }

    return $false
}

function Global:Clear-NTKOutputQuota {

param(
    [string]$Path,
    [string]$Pattern = "*",
    [int]$KeepCount = 8,
    [int]$MaxAgeDays = 21,
    [switch]$Directory
)

    if(!$Path -or !(Test-Path $Path)){
        return
    }

    $cutoff = (Get-Date).AddDays(-1 * [Math]::Max(1,$MaxAgeDays))
    if($Directory){
        $items = @(Get-ChildItem -Path $Path -Directory -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending)
    }
    else{
        $items = @(Get-ChildItem -Path $Path -File -Filter $Pattern -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending)
    }

    $remove = @()
    if($items.Count -gt $KeepCount){
        $remove += @($items | Select-Object -Skip $KeepCount)
    }

    $remove += @($items | Where-Object { $_.LastWriteTime -lt $cutoff })

    foreach($item in @($remove | Sort-Object FullName -Unique)){
        if(Test-NTKOutputHasSevereEvidence -Path $item.FullName){
            continue
        }

        try {
            Remove-Item -LiteralPath $item.FullName -Recurse:$Directory -Force -ErrorAction Stop
        }
        catch {
            if(Get-Command Write-NTKWarning -ErrorAction SilentlyContinue){
                Write-NTKWarning -Component 'Retention' -Message ("Could not remove {0}: {1}" -f $item.FullName,$_.Exception.Message)
            }
        }
    }
}

function Global:Clear-NTKReportAndLogQuota {

param(
    [int]$ReportKeepCount = 6,
    [int]$LogKeepCount = 10,
    [int]$TempKeepCount = 12,
    [int]$MaxAgeDays = 21
)

    if($NTKPaths -and $NTKPaths.Exports){
        foreach($pattern in @(
            "quick-diagnosis*.html",
            "computer-profile*.html",
            "computer-profile*.json",
            "full-triage*.json",
            "full-triage*.txt",
            "robocopy*.log",
            "dism*.log",
            "sfc*.log"
        )){
            Clear-NTKOutputQuota -Path $NTKPaths.Exports -Pattern $pattern -KeepCount $ReportKeepCount -MaxAgeDays $MaxAgeDays
        }
    }

    if($NTKPaths -and $NTKPaths.Logs){
        Clear-NTKOutputQuota -Path $NTKPaths.Logs -Pattern "*.log" -KeepCount $LogKeepCount -MaxAgeDays $MaxAgeDays
        $usage = Join-Path $NTKPaths.Logs "ToolUsage"
        if(Test-Path $usage){
            foreach($toolFolder in @(Get-ChildItem -LiteralPath $usage -File -Filter "*.log" -ErrorAction SilentlyContinue | Group-Object BaseName)){
                $files = @($toolFolder.Group | Sort-Object LastWriteTime -Descending)
                foreach($file in @($files | Select-Object -Skip $LogKeepCount)){
                    if(!(Test-NTKOutputHasSevereEvidence -Path $file.FullName)){
                        try {
                            Remove-Item -LiteralPath $file.FullName -Force -ErrorAction Stop
                        }
                        catch {
                            if(Get-Command Write-NTKWarning -ErrorAction SilentlyContinue){
                                Write-NTKWarning -Component 'Retention' -Message ("Could not remove {0}: {1}" -f $file.FullName,$_.Exception.Message)
                            }
                        }
                    }
                }
            }
        }
    }

    if(Get-Command Clear-NTKOldTempOutputs -ErrorAction SilentlyContinue){
        Clear-NTKOldTempOutputs -KeepCount $TempKeepCount -MaxAgeDays ([Math]::Min($MaxAgeDays,14))
    }
}
