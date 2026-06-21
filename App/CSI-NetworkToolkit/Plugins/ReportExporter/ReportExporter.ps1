function Global:Get-CSIReportFiles {

    if(!(Test-Path $CSIPaths.Exports)){
        return @()
    }

    return Get-ChildItem -Path $CSIPaths.Exports -File -ErrorAction SilentlyContinue |
           Where-Object {$_.Extension -in ".html",".htm",".json",".csv",".txt",".log",".xml"} |
           Sort-Object LastWriteTime -Descending

}

function Global:Open-CSIPath {

param([string]$Path)

    if(!$Path -or !(Test-Path $Path)){
        Write-Host "Path not found:" $Path -ForegroundColor Yellow
        return
    }

    Start-CSIToolProcess -FilePath "explorer.exe" -ArgumentList @("`"$Path`"") | Out-Null

}

function Global:Open-CSIOutputFile {

param([string]$Path)

    if(!$Path -or !(Test-Path $Path)){
        Write-Host "File not found:" $Path -ForegroundColor Yellow
        return
    }

    $extension = [System.IO.Path]::GetExtension($Path).ToLowerInvariant()

    if($extension -in ".html",".htm",".pdf"){
        Start-CSIToolProcess -FilePath $Path | Out-Null
    }
    else{
        Start-CSIToolProcess -FilePath "notepad.exe" -ArgumentList @("`"$Path`"") | Out-Null
    }

}

function Global:Get-CSIOutputLocations {

    $locations = @(
        [pscustomobject]@{
            Name = "Exports"
            Path = $CSIPaths.Exports
            Notes = "Quick Diagnosis, triage reports, network reports, CSV/JSON/TXT/HTML exports"
        }
        [pscustomobject]@{
            Name = "Computer Profiles"
            Path = (Join-Path $CSIPaths.Data "ComputerProfiles")
            Notes = "Computer profile JSON and HTML files"
        }
        [pscustomobject]@{
            Name = "Minidumps"
            Path = (Join-Path $CSIPaths.Data "MiniDumps")
            Notes = "Collected minidumps and crash-analysis output"
        }
        [pscustomobject]@{
            Name = "Print Queue Data"
            Path = (Join-Path $CSIPaths.Data "PrintQueues")
            Notes = "Print tool config, logs, and local print utility data"
        }
        [pscustomobject]@{
            Name = "Toolkit Logs"
            Path = $CSIPaths.Logs
            Notes = "Toolkit log files"
        }
        [pscustomobject]@{
            Name = "All Toolkit Data"
            Path = $CSIPaths.Data
            Notes = "All data subfolders"
        }
    )

    return $locations | Where-Object { $_.Path }

}

function Global:Invoke-ReportSelector {

    Clear-Host

    Write-Host ""
    Write-Host "REPORT SELECTOR" -ForegroundColor Cyan
    Write-Host "===============" -ForegroundColor DarkCyan
    Write-Host ""

    $reports = @(Get-CSIReportFiles)

    if($reports.Count -eq 0){

        Write-Host "No reports found." -ForegroundColor Yellow
        Write-Host "Reports are stored in:" $CSIPaths.Exports
        return

    }

    for($i = 0; $i -lt $reports.Count; $i++){

        $report = $reports[$i]

        Write-Host ("{0}. {1}  {2}  {3} KB" -f ($i + 1),$report.Name,$report.LastWriteTime,[math]::Round($report.Length / 1KB,1))

    }

    Write-Host ""

    $choice = Read-CSIInput "Select report"

    if(-not ($choice -as [int])){
        Write-Host "Invalid selection." -ForegroundColor Red
        return
    }

    $index = [int]$choice

    if($index -lt 1 -or $index -gt $reports.Count){
        Write-Host "Invalid selection." -ForegroundColor Red
        return
    }

    $selected = $reports[$index - 1]

    Write-Host ""
    Write-Host "Selected:" $selected.Name
    Write-Host ""

    $action = Read-CSIInput "Open or Delete"

    if($action -match "^(o|open)$"){

        Write-Host "Opening:" $selected.FullName -ForegroundColor Green
        Open-CSIOutputFile -Path $selected.FullName

    }
    elseif($action -match "^(d|delete)$"){

        Remove-Item -Path $selected.FullName -Force
        Write-Host "Deleted:" $selected.Name -ForegroundColor Yellow

    }
    else{

        Write-Host "Action not recognized. Use Open or Delete." -ForegroundColor Red

    }

}

function Global:Invoke-OpenToolkitOutputs {

    while($true){

        Clear-Host

        Write-Host ""
        Write-Host "TOOL OUTPUTS" -ForegroundColor Cyan
        Write-Host "============" -ForegroundColor DarkCyan
        Write-Host ""

        $locations = @(Get-CSIOutputLocations)

        Write-Host "0. Open All Output Folders"

        for($i = 0; $i -lt $locations.Count; $i++){
            $location = $locations[$i]
            $state = if(Test-Path $location.Path){"Ready"}else{"Missing"}
            Write-Host ("{0}. {1}  [{2}]" -f ($i + 1),$location.Name,$state)
            Write-Host ("   {0}" -f $location.Path) -ForegroundColor DarkGray
        }

        Write-Host ""
        Write-Host "R. Recent Export Files"
        Write-Host ""

        $choice = Read-CSIInput "Select output location"

        if($choice -match "^(r|recent)$"){
            Invoke-ReportSelector
            continue
        }

        if($choice -eq "0"){

            foreach($location in $locations | Where-Object { Test-Path $_.Path }){
                Open-CSIPath -Path $location.Path
            }

            Write-Host "Opened all available output folders." -ForegroundColor Green
            return

        }

        if(-not ($choice -as [int])){
            Write-Host "Invalid selection." -ForegroundColor Red
            continue
        }

        $index = [int]$choice

        if($index -lt 1 -or $index -gt $locations.Count){
            Write-Host "Invalid selection." -ForegroundColor Red
            continue
        }

        $selected = $locations[$index - 1]

        if(!(Test-Path $selected.Path)){
            New-Item -ItemType Directory -Path $selected.Path -Force | Out-Null
        }

        Write-Host "Opening:" $selected.Path -ForegroundColor Green
        Open-CSIPath -Path $selected.Path
        return

    }

}

function Global:Invoke-NetworkReportExporter {

param(
    [string]$CIDR,
    [string]$OutputPath,
    [ValidateSet("JSON","CSV")]
    [string]$Format = "JSON"
)

    Clear-Host

    Write-Host ""
    Write-Host "CREATE NETWORK REPORT" -ForegroundColor Cyan
    Write-Host "=====================" -ForegroundColor DarkCyan
    Write-Host ""

    if(!$CIDR){
        $CIDR = Read-CSIInput "CIDR to scan for report"
    }

    if(!$CIDR){

        Write-Host "CIDR is required." -ForegroundColor Red
        return

    }

    if(!$OutputPath){

        $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $extension = if($Format -eq "CSV"){"csv"}else{"json"}
        $OutputPath = Join-Path $CSIPaths.Exports "network-report-$stamp.$extension"

    }

    $alive = Invoke-NetworkScan -CIDR $CIDR -Timeout 500 -Throttle 128 -PassThru

    $report = foreach($ip in $alive){

        [pscustomobject]@{
            Time     = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            CIDR     = $CIDR
            IP       = $ip
            Status   = "Alive"
            Computer = $env:COMPUTERNAME
        }

    }

    if($Format -eq "CSV"){
        $report | Export-Csv -Path $OutputPath -NoTypeInformation
    }
    else{
        $report | ConvertTo-Json | Set-Content -Path $OutputPath -Encoding UTF8
    }

    Write-Host ""
    Write-Host "Exported:" $OutputPath -ForegroundColor Green
    Write-Host "Alive Hosts:" @($alive).Count

}

Register-CSICommand `
    -Name "Open Tool Outputs" `
    -Command "Invoke-OpenToolkitOutputs" `
    -Category "Reports" `
    -Description "Open exports, reports, computer profiles, minidumps, print data, and toolkit logs" `
    -Order 900
