function Global:Invoke-PortScan {

param(
    [string]$Target,
    [int[]]$Ports = @(22,80,443,445,3389),
    [int]$Timeout = 1000,
    [switch]$PassThru
)

    Clear-Host

    Write-Host ""
    Write-Host "PORT SCANNER" -ForegroundColor Cyan
    Write-Host "============" -ForegroundColor DarkCyan
    Write-Host ""

    if(!$Target){
        $Target = Read-CSIInput "Target host"
    }

    if(!$Target){

        Write-Host "Target host is required." -ForegroundColor Red
        return

    }

    $openPorts = @()

    foreach($port in $Ports){

        if($port -lt 1 -or $port -gt 65535){

            Write-Host "Skipping invalid port: $port" -ForegroundColor Yellow
            continue

        }

        $tcp = New-Object Net.Sockets.TcpClient

        try {

            $connect = $tcp.BeginConnect($Target,$port,$null,$null)

            if($connect.AsyncWaitHandle.WaitOne($Timeout,$false)){

                $tcp.EndConnect($connect)

                Write-Host "Port $port open" -ForegroundColor Green
                $openPorts += $port

            }

        }
        catch {}
        finally {

            $tcp.Close()

        }

    }

    Write-Host ""
    Write-Host "Open Ports:" $openPorts.Count

    if($PassThru){
        return $openPorts
    }

}

Register-CSICommand `
    -Name "Port Scan" `
    -Command "Invoke-PortScan" `
    -Category "Scanning" `
    -Description "Scan common TCP ports on a target host" `
    -Order 40
