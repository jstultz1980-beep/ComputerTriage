function Global:Convert-IPToNumber {

param([string]$IP)

$address = [System.Net.IPAddress]::Parse($IP)

if($address.AddressFamily -ne [System.Net.Sockets.AddressFamily]::InterNetwork){
    throw "IPv4 address required: $IP"
}

$bytes=$address.GetAddressBytes()
[array]::Reverse($bytes)
[BitConverter]::ToUInt32($bytes,0)

}

function Global:Convert-NumberToIP {

param([uint32]$Number)

$bytes=[BitConverter]::GetBytes($Number)
[array]::Reverse($bytes)
([System.Net.IPAddress]::new($bytes)).ToString()

}

function Global:Convert-CIDRToIPs {

param([string]$CIDR)

if($CIDR -notmatch "^([^/]+)/(\d{1,2})$"){
    throw "Invalid CIDR format. Example: 192.168.1.0/24"
}

function Global:Invoke-CSIPingSweep {

param(
    [string[]]$IPAddresses,
    [int]$Timeout = 750,
    [int]$Throttle = 128
)

$alive = @()
$batch = @()

foreach($ip in $IPAddresses){

    $ping = New-Object System.Net.NetworkInformation.Ping

    $batch += [pscustomobject]@{
        IP   = $ip
        Ping = $ping
        Task = $ping.SendPingAsync($ip,$Timeout)
    }

    if($batch.Count -ge $Throttle){

        [void][System.Threading.Tasks.Task]::WaitAll($batch.Task)

        foreach($item in $batch){

            if($item.Task.Result.Status -eq [System.Net.NetworkInformation.IPStatus]::Success){
                $alive += $item.IP
            }

            $item.Ping.Dispose()

        }

        $batch = @()

    }

}

if($batch.Count -gt 0){

    [void][System.Threading.Tasks.Task]::WaitAll($batch.Task)

    foreach($item in $batch){

        if($item.Task.Result.Status -eq [System.Net.NetworkInformation.IPStatus]::Success){
            $alive += $item.IP
        }

        $item.Ping.Dispose()

    }

}

return $alive

}

$baseIP = $matches[1]
$prefix = [int]$matches[2]

if($prefix -lt 0 -or $prefix -gt 32){
    throw "Invalid CIDR prefix. Use a value from 0 through 32."
}

$baseNumber = Convert-IPToNumber $baseIP

if($prefix -eq 0){
    $mask = [uint32]0
}
else{
    $mask = [uint32]([uint32]::MaxValue -shl (32 - $prefix))
}

$network = [uint32]($baseNumber -band $mask)
$broadcast = [uint32]($network -bor (-bnot $mask))

if($prefix -ge 31){
    $start = [uint64]$network
    $end = [uint64]$broadcast
}
else{
    $start = [uint64]([uint32]($network + 1))
    $end = [uint64]([uint32]($broadcast - 1))
}

if(($end - $start + 1) -gt 65536){
    throw "CIDR range too large. Use /16 or smaller."
}

for($number = $start; $number -le $end; $number++){
    Convert-NumberToIP ([uint32]$number)
}

}
