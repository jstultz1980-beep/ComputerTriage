function Global:Get-CSIReportFiles {

    if(!(Test-Path $CSIPaths.Exports)){
        return @()
    }

    return Get-ChildItem -Path $CSIPaths.Exports -File -ErrorAction SilentlyContinue |
           Where-Object {$_.Extension -in ".json",".csv",".txt",".log"} |
           Sort-Object LastWriteTime -Descending

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
        Start-Process notepad.exe -ArgumentList "`"$($selected.FullName)`"" | Out-Null

    }
    elseif($action -match "^(d|delete)$"){

        Remove-Item -Path $selected.FullName -Force
        Write-Host "Deleted:" $selected.Name -ForegroundColor Yellow

    }
    else{

        Write-Host "Action not recognized. Use Open or Delete." -ForegroundColor Red

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
    -Name "Report Selector" `
    -Command "Invoke-ReportSelector" `
    -Category "Plugins" `
    -Description "Open or delete saved reports" `
    -Order 91

Register-CSICommand `
    -Name "Create Network Report" `
    -Command "Invoke-NetworkReportExporter" `
    -Category "Plugins" `
    -Description "Scan a CIDR and export a new alive-host report" `
    -Order 92
