function Global:Invoke-ServiceFingerprinter {

param(
    [string]$Target,
    [int[]]$Ports = @(21,22,25,80,110,143,443,3389),
    [int]$Timeout = 1000,
    [switch]$PassThru
)

    Clear-Host

    Write-Host ""
    Write-Host "SERVICE FINGERPRINTER" -ForegroundColor Cyan
    Write-Host "=====================" -ForegroundColor DarkCyan
    Write-Host ""

    if(!$Target){
        $Target = Read-CSIInput "Target host"
    }

    if(!$Target){

        Write-Host "Target host is required." -ForegroundColor Red
        return

    }

    $results = @()

    foreach($port in $Ports){

        if($port -lt 1 -or $port -gt 65535){
            continue
        }

        $tcp = New-Object Net.Sockets.TcpClient
        $open = $false
        $banner = ""

        try {

            $connect = $tcp.BeginConnect($Target,$port,$null,$null)

            if($connect.AsyncWaitHandle.WaitOne($Timeout,$false)){

                $tcp.EndConnect($connect)
                $open = $true

                $stream = $tcp.GetStream()
                $stream.ReadTimeout = $Timeout
                $stream.WriteTimeout = $Timeout

                if($port -eq 80){

                    $bytes = [Text.Encoding]::ASCII.GetBytes("HEAD / HTTP/1.0`r`nHost: $Target`r`n`r`n")
                    $stream.Write($bytes,0,$bytes.Length)

                }

                if($stream.DataAvailable -or $port -eq 80){

                    $buffer = New-Object byte[] 256
                    $read = $stream.Read($buffer,0,$buffer.Length)

                    if($read -gt 0){
                        $banner = ([Text.Encoding]::ASCII.GetString($buffer,0,$read)).Trim()
                    }

                }

            }

        }
        catch {}
        finally {
            $tcp.Close()
        }

        $results += [pscustomobject]@{
            Target = $Target
            Port   = $port
            Open   = $open
            Banner = $banner
        }

    }

    if($PassThru){
        return $results
    }

    $results | Format-Table -Wrap -AutoSize

}

function Global:Invoke-PortAndServiceTest {

    while($true){

        Clear-Host

        Write-Host ""
        Write-Host "PORT AND SERVICE TEST" -ForegroundColor Cyan
        Write-Host "=====================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "1. Common Port Scan"
        Write-Host "2. Port Reachability Matrix"
        Write-Host "3. Service Banner Check"
        Write-Host "4. TLS Certificate Check"
        Write-Host ""

        $choice = Read-CSIInput "Select port task"

        switch($choice){
            "1" { Invoke-PortScan }
            "2" { Invoke-PortReachabilityMatrix }
            "3" { Invoke-ServiceFingerprinter }
            "4" { Invoke-TLSCertificateCheck }
            default { Write-Host "Invalid selection." -ForegroundColor Red }
        }

        Write-Host ""
        [void](Read-Host "Press ENTER to continue")

    }

}

Register-CSICommand `
    -Name "Port And Service Test" `
    -Command "Invoke-PortAndServiceTest" `
    -Category "Troubleshooting" `
    -Description "Port scan, reachability profiles, service banners, and TLS certificate checks" `
    -Order 40
