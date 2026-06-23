function Global:Invoke-PrintSpoolerTriage {

    Clear-Host

    Write-Host ""
    Write-Host "PRINT AND SPOOLER TRIAGE" -ForegroundColor Cyan
    Write-Host "------------------------" -ForegroundColor DarkCyan

    Get-Service Spooler -ErrorAction SilentlyContinue |
        Select-Object Name,Status,StartType |
        Format-Table -AutoSize

    if(Get-Command Get-Printer -ErrorAction SilentlyContinue){

        Write-Host ""
        Write-Host "Printers"
        Write-Host "--------"
        Get-Printer |
            Select-Object Name,ShareName,PrinterStatus,JobCount,DriverName,PortName |
            Format-Table -Wrap -AutoSize

    }

    if(Get-Command Get-PrintJob -ErrorAction SilentlyContinue){

        Write-Host ""
        Write-Host "Queued Jobs"
        Write-Host "-----------"

        $jobs = Get-Printer | ForEach-Object {
            try {
                Get-PrintJob -PrinterName $_.Name -ErrorAction Stop |
                    Select-Object @{Name="Printer";Expression={$_.PrinterName}},ID,JobStatus,SubmittedTime,DocumentName
            }
            catch {}
        }

        if($jobs){
            $jobs | Format-Table -Wrap -AutoSize
        }
        else{
            Write-Host "No queued print jobs found." -ForegroundColor Green
        }

    }

}

function Global:Invoke-PrintQueueTools {

    while($true){

        Clear-Host

        Write-Host ""
        Write-Host "PRINT QUEUE TOOLS" -ForegroundColor Cyan
        Write-Host "=================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "1. Launch Print Queue Maintenance"
        Write-Host "2. Print And Spooler Triage"
        Write-Host "3. Stale Local Printer Cleanup"
        Write-Host ""

        $choice = Read-CSIInput "Select print task"

        switch($choice){

            "1" {

                $toolPath = Join-Path $CSIPaths.Plugins "PrintQueues\Print Queue Cleanup\PrinterSpoolerTool.ps1"

                if(!(Test-Path $toolPath)){
                    Write-Host "Print queue maintenance tool not found:" $toolPath -ForegroundColor Red
                    break
                }

                $dataRoot = Join-Path $CSIPaths.Data "PrintQueues"

                if(!(Test-Path $dataRoot)){
                    New-Item -ItemType Directory -Path $dataRoot -Force | Out-Null
                }

                Start-CSIToolProcess `
                    -FilePath "powershell.exe" `
                    -ArgumentList @(
                        "-NoProfile"
                        "-ExecutionPolicy"
                        "Bypass"
                        "-STA"
                        "-File"
                        "`"$toolPath`""
                        "-ToolDataRoot"
                        "`"$dataRoot`""
                    ) `
                    -WindowStyle Normal | Out-Null

                Write-Host "Print queue maintenance tool launched." -ForegroundColor Green

            }

            "2" { Invoke-PrintSpoolerTriage }
            "3" { Invoke-StaleLocalPrinterCleanup }
            default { Write-Host "Invalid selection." -ForegroundColor Red }

        }

        Write-Host ""
        [void](Read-CSIInput "Press ENTER to continue" -AllowEmpty)

    }

}

function Global:Get-StaleLocalPrinterArtifacts {

    $artifacts = @()
    $printers = @()

    if(Get-Command Get-Printer -ErrorAction SilentlyContinue){
        try {
            $printers = @(Get-Printer -ErrorAction Stop)
        }
        catch {
            Write-Host "Unable to read installed printers." -ForegroundColor Yellow
            Write-Host $_.Exception.Message
        }
    }
    else{
        Write-Host "Get-Printer is not available on this system." -ForegroundColor Yellow
        return @()
    }

    $activePrinterNames = @($printers | ForEach-Object {$_.Name})
    $activeDrivers = @($printers | Where-Object {$_.DriverName} | ForEach-Object {$_.DriverName} | Select-Object -Unique)
    $activePorts = @($printers | Where-Object {$_.PortName} | ForEach-Object {$_.PortName} | Select-Object -Unique)

    $protectedDrivers = @(
        "Microsoft Print To PDF"
        "Microsoft XPS Document Writer"
        "Microsoft enhanced Point and Print compatibility driver"
        "Microsoft IPP Class Driver"
        "Microsoft Shared Fax Driver"
        "Microsoft Virtual Print Class Driver"
        "Remote Desktop Easy Print"
        "Send To Microsoft OneNote"
        "Universal Print Class Driver"
        "Fax"
    )

    $protectedPortPatterns = @(
        "^PORTPROMPT:$"
        "^FILE:$"
        "^NUL:$"
        "^SHRFAX:$"
        "^TS\d+$"
        "^COM\d+:$"
        "^LPT\d+:$"
    )

    if(Get-Command Get-PrinterPort -ErrorAction SilentlyContinue){

        try {

            $ports = @(Get-PrinterPort -ErrorAction Stop)

            foreach($port in $ports){

                $isProtected = $false

                foreach($pattern in $protectedPortPatterns){
                    if($port.Name -match $pattern){
                        $isProtected = $true
                    }
                }

                if($isProtected){
                    continue
                }

                if($activePorts -notcontains $port.Name){

                    $artifacts += [pscustomobject]@{
                        Type   = "Unused Port"
                        Name   = $port.Name
                        Detail = if($port.PrinterHostAddress){"Host $($port.PrinterHostAddress)"}else{"Not referenced by installed printers"}
                        Risk   = "Low"
                        Path   = $port.Name
                    }

                }

            }

        }
        catch {
            Write-Host "Unable to read printer ports." -ForegroundColor Yellow
        }

    }

    if(Get-Command Get-PrinterDriver -ErrorAction SilentlyContinue){

        try {

            $drivers = @(Get-PrinterDriver -ErrorAction Stop)

            foreach($driver in $drivers){

                if($protectedDrivers -contains $driver.Name){
                    continue
                }

                if($activeDrivers -notcontains $driver.Name){

                    $artifacts += [pscustomobject]@{
                        Type   = "Unused Driver"
                        Name   = $driver.Name
                        Detail = if($driver.Manufacturer){"Manufacturer $($driver.Manufacturer)"}else{"Not referenced by installed printers"}
                        Risk   = "Medium"
                        Path   = $driver.Name
                    }

                }

            }

        }
        catch {
            Write-Host "Unable to read printer drivers." -ForegroundColor Yellow
        }

    }

    $deviceKey = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Devices"

    if(Test-Path $deviceKey){

        try {

            $deviceProperties = Get-ItemProperty -Path $deviceKey -ErrorAction Stop

            foreach($property in $deviceProperties.PSObject.Properties){

                if($property.Name -like "PS*"){
                    continue
                }

                if($activePrinterNames -notcontains $property.Name){

                    $artifacts += [pscustomobject]@{
                        Type   = "Stale User Device"
                        Name   = $property.Name
                        Detail = [string]$property.Value
                        Risk   = "Low"
                        Path   = $deviceKey
                    }

                }

            }

        }
        catch {}

    }

    $connectionRoot = "HKCU:\Printers\Connections"

    if(Test-Path $connectionRoot){

        try {

            foreach($connection in Get-ChildItem -Path $connectionRoot -ErrorAction Stop){

                $parts = $connection.PSChildName -split ","
                $connectionName = if($parts.Count -ge 4){"\\$($parts[2])\$($parts[3])"}else{$connection.PSChildName}

                if($activePrinterNames -notcontains $connectionName -and $activePrinterNames -notcontains $connection.PSChildName){

                    $artifacts += [pscustomobject]@{
                        Type   = "Stale Connection Registry"
                        Name   = $connectionName
                        Detail = $connection.Name
                        Risk   = "Medium"
                        Path   = $connection.PSPath
                    }

                }

            }

        }
        catch {}

    }

    return $artifacts

}

function Global:Remove-StaleLocalPrinterArtifact {

param([pscustomobject]$Artifact)

    try {

        switch($Artifact.Type){

            "Unused Port" {
                Remove-PrinterPort -Name $Artifact.Name -ErrorAction Stop
                Write-Host "Removed port:" $Artifact.Name -ForegroundColor Green
            }

            "Unused Driver" {
                Remove-PrinterDriver -Name $Artifact.Name -ErrorAction Stop
                Write-Host "Removed driver:" $Artifact.Name -ForegroundColor Green
            }

            "Stale User Device" {
                Remove-ItemProperty -Path $Artifact.Path -Name $Artifact.Name -ErrorAction Stop
                Write-Host "Removed user device entry:" $Artifact.Name -ForegroundColor Green
            }

            "Stale Connection Registry" {
                Remove-Item -Path $Artifact.Path -Recurse -Force -ErrorAction Stop
                Write-Host "Removed connection registry entry:" $Artifact.Name -ForegroundColor Green
            }

        }

    }
    catch {
        Write-Host "Unable to remove $($Artifact.Type): $($Artifact.Name)" -ForegroundColor Red
        Write-Host $_.Exception.Message
    }

}

function Global:Invoke-StaleLocalPrinterCleanup {

    Clear-Host

    Write-Host ""
    Write-Host "STALE LOCAL PRINTER CLEANUP" -ForegroundColor Cyan
    Write-Host "===========================" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "This scans for printer ports, drivers, and current-user printer registry entries"
    Write-Host "that are not referenced by installed printer objects."
    Write-Host ""

    $artifacts = @(Get-StaleLocalPrinterArtifacts)

    if($artifacts.Count -eq 0){
        Write-Host "No stale local printer artifacts found." -ForegroundColor Green
        return
    }

    for($i = 0; $i -lt $artifacts.Count; $i++){

        $item = $artifacts[$i]
        Write-Host ("{0}. [{1}] {2} - {3}" -f ($i + 1),$item.Risk,$item.Type,$item.Name)
        Write-Host ("   {0}" -f $item.Detail) -ForegroundColor DarkGray

    }

    Write-Host ""
    Write-Host "Cleanup options: A=all low-risk items, number=single item, comma list=selected items"
    Write-Host "Medium-risk items require explicit numeric selection."
    Write-Host ""

    $choice = Read-CSIInput "Items to clean"

    $selected = @()

    if($choice -match "^(a|all)$"){
        $selected = @($artifacts | Where-Object {$_.Risk -eq "Low"})
    }
    else{

        $numbers = @($choice -split "," | ForEach-Object {$_.Trim()} | Where-Object {$_ -as [int]})

        foreach($number in $numbers){

            $index = [int]$number

            if($index -ge 1 -and $index -le $artifacts.Count){
                $selected += $artifacts[$index - 1]
            }

        }

    }

    if($selected.Count -eq 0){
        Write-Host "No valid cleanup items selected." -ForegroundColor Yellow
        return
    }

    Write-Host ""
    Write-Host "Selected items:"
    $selected | Select-Object Type,Name,Risk,Detail | Format-Table -Wrap -AutoSize

    Write-Host ""
    $confirm = Read-CSIInput "Type CLEAN to remove selected artifacts"

    if($confirm -ne "CLEAN"){
        Write-Host "Cleanup cancelled." -ForegroundColor Yellow
        return
    }

    foreach($item in $selected){
        Remove-StaleLocalPrinterArtifact -Artifact $item
    }

    Write-Host ""
    Write-Host "Cleanup complete. Re-run the scan to confirm remaining artifacts." -ForegroundColor Green

}

Register-CSICommand `
    -Name "Print Queue Tools" `
    -Command "Invoke-PrintQueueTools" `
    -Category "Troubleshooting" `
    -Description "Print queue maintenance, spooler triage, and stale local printer cleanup" `
    -Order 54 `
    -RequiresAdmin
