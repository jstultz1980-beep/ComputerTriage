function Global:Invoke-DNSToolkit {

param(
    [string]$Name,
    [string[]]$Servers,
    [switch]$PassThru
)

    Clear-Host

    Write-Host ""
    Write-Host "DNS TOOLKIT" -ForegroundColor Cyan
    Write-Host "===========" -ForegroundColor DarkCyan
    Write-Host ""

    if(!$Name){
        $Name = Read-NTKInput "Host or IP to resolve"
    }

    if(!$Name){

        Write-Host "Host or IP is required." -ForegroundColor Red
        return

    }

    if(!$Servers -or $Servers.Count -eq 0){

        try {
            $Servers = (Get-DnsClientServerAddress -AddressFamily IPv4).ServerAddresses
        }
        catch {
            $Servers = @()
        }

    }

    $results = @()

    if($Name -match "^\d{1,3}(\.\d{1,3}){3}$"){

        try {
            $hostEntry = [System.Net.Dns]::GetHostEntry($Name)

            $results += [pscustomobject]@{
                Query  = $Name
                Server = "System"
                Type   = "PTR"
                Result = $hostEntry.HostName
            }

        }
        catch {

            $results += [pscustomobject]@{
                Query  = $Name
                Server = "System"
                Type   = "PTR"
                Result = "Lookup failed"
            }

        }

    }

    if(Get-Command Resolve-DnsName -ErrorAction SilentlyContinue){

        if(!$Servers -or $Servers.Count -eq 0){
            $Servers = @("System")
        }

        foreach($server in $Servers){

            try {

                if($server -eq "System"){
                    $lookup = Resolve-DnsName -Name $Name -ErrorAction Stop
                }
                else{
                    $lookup = Resolve-DnsName -Name $Name -Server $server -ErrorAction Stop
                }

                foreach($record in $lookup){

                    if($record.IPAddress -or $record.NameHost){

                        $results += [pscustomobject]@{
                            Query  = $Name
                            Server = $server
                            Type   = $record.Type
                            Result = if($record.IPAddress){$record.IPAddress}else{$record.NameHost}
                        }

                    }

                }

            }
            catch {

                $results += [pscustomobject]@{
                    Query  = $Name
                    Server = $server
                    Type   = "Error"
                    Result = $_.Exception.Message
                }

            }

        }

    }
    else{

        try {

            $addresses = [System.Net.Dns]::GetHostAddresses($Name)

            foreach($address in $addresses){

                $results += [pscustomobject]@{
                    Query  = $Name
                    Server = "System"
                    Type   = "A"
                    Result = $address.IPAddressToString
                }

            }

        }
        catch {

            Write-Host "DNS lookup failed." -ForegroundColor Red
            Write-Host $_.Exception.Message
            return

        }

    }

    if($PassThru){
        return $results
    }

    $results | Format-Table -AutoSize

}

function Global:Invoke-DNSDiagnostics {

    while($true){

        Clear-Host

        Write-Host ""
        Write-Host "DNS DIAGNOSTICS" -ForegroundColor Cyan
        Write-Host "===============" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "1. DNS Lookup And Server Compare"
        Write-Host "2. DNS Path Test"
        Write-Host ""

        $choice = Read-NTKInput "Select DNS task"

        switch($choice){
            "1" { Invoke-DNSToolkit }
            "2" { Invoke-DNSPathTest }
            default { Write-Host "Invalid selection." -ForegroundColor Red }
        }

        Write-Host ""
        [void](Read-NTKInput "Press ENTER to continue" -AllowEmpty)

    }

}

Register-NTKCommand `
    -Name "DNS Diagnostics" `
    -Command "Invoke-DNSDiagnostics" `
    -Category "Troubleshooting" `
    -Description "DNS lookup, resolver comparison, cache, hosts file, and reverse lookup checks" `
    -Order 30
