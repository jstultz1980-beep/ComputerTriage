function Global:Start-CSIToolProcess {

param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath,

    [string[]]$ArgumentList = @(),
    [string]$WorkingDirectory = "",
    [ValidateSet("Normal","Hidden","Minimized","Maximized")]
    [string]$WindowStyle = "Normal",
    [switch]$Elevated,
    [switch]$Wait,
    [switch]$PassThru
)

    if(!$FilePath){
        throw "FilePath is required."
    }

    $cleanArguments = @($ArgumentList | Where-Object { $null -ne $_ -and $_ -ne "" })

    $startInfo = @{
        FilePath = $FilePath
        WindowStyle = $WindowStyle
    }

    if($cleanArguments.Count -gt 0){
        $startInfo.ArgumentList = $cleanArguments
    }

    if($WorkingDirectory){
        $startInfo.WorkingDirectory = $WorkingDirectory
    }

    if($Elevated){
        $startInfo.Verb = "RunAs"
    }

    if($Wait){
        $startInfo.Wait = $true
    }

    if($PassThru){
        $startInfo.PassThru = $true
    }

    Start-Process @startInfo

}

function Global:Join-CSICommandLine {

param([string[]]$Parts = @())

    return (@($Parts | Where-Object { $null -ne $_ -and $_ -ne "" } | ForEach-Object {
        if($_ -match '[\s"]'){
            '"' + ($_.Replace('"','\"')) + '"'
        }
        else{
            $_
        }
    }) -join ' ')

}

function Global:Get-CSITempOutputRoot {

    if($CSIPaths -and $CSIPaths.TempOutputs){
        $root = $CSIPaths.TempOutputs
    }
    elseif($CSIPaths -and $CSIPaths.Data){
        $root = Join-Path $CSIPaths.Data "TempToolOutputs"
    }
    else{
        $root = Join-Path $env:TEMP "CSI-NetworkToolkit\TempToolOutputs"
    }

    if(!(Test-Path $root)){
        New-Item -ItemType Directory -Path $root -Force | Out-Null
    }

    return $root

}

function Global:Clear-CSIOldTempOutputs {

param(
    [int]$KeepCount = 30,
    [int]$MaxAgeDays = 14
)

    $root = Get-CSITempOutputRoot
    $cutoff = (Get-Date).AddDays(-1 * [Math]::Max(1,$MaxAgeDays))
    $folders = @(Get-ChildItem -Path $root -Directory -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending)
    $remove = @()

    if($folders.Count -gt $KeepCount){
        $remove += @($folders | Select-Object -Skip $KeepCount)
    }

    $remove += @($folders | Where-Object { $_.LastWriteTime -lt $cutoff })

    foreach($folder in @($remove | Sort-Object FullName -Unique)){
        Remove-Item -LiteralPath $folder.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }

}

function Global:New-CSITempOutputSession {

param(
    [string]$ToolName = "Tool",
    [int]$KeepCount = 30,
    [int]$MaxAgeDays = 14
)

    Clear-CSIOldTempOutputs -KeepCount $KeepCount -MaxAgeDays $MaxAgeDays

    $root = Get-CSITempOutputRoot
    $safeName = if(Get-Command ConvertTo-CSISafeFileName -ErrorAction SilentlyContinue){
        ConvertTo-CSISafeFileName $ToolName
    }
    else{
        ($ToolName -replace '[^A-Za-z0-9._-]+','_').Trim('_')
    }

    if(!$safeName){
        $safeName = "Tool"
    }

    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $session = Join-Path $root "$stamp-$safeName"
    New-Item -ItemType Directory -Path $session -Force | Out-Null

    return [pscustomobject]@{
        Root       = $root
        Path       = $session
        Transcript = Join-Path $session "console-output.txt"
        Metadata   = Join-Path $session "metadata.json"
        Stamp      = $stamp
        ToolName   = $ToolName
    }

}
