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

Register-CSICommand `
    -Name "Service Fingerprinter" `
    -Command "Invoke-ServiceFingerprinter" `
    -Category "Plugins" `
    -Description "Check open TCP ports and capture simple service banners" `
    -Order 42
