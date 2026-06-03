function Global:Get-CSISubnetInfo {

param([string]$CIDR)

    if($CIDR -notmatch "^([^/]+)/(\d{1,2})$"){
        throw "Invalid CIDR format. Example: 192.168.1.0/24"
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
        $first = $network
        $last = $broadcast
        $usable = [uint64]($broadcast - $network + 1)
    }
    else{
        $first = [uint32]($network + 1)
        $last = [uint32]($broadcast - 1)
        $usable = [uint64]($broadcast - $network - 1)
    }

    return [pscustomobject]@{
        CIDR      = $CIDR
        Network   = Convert-NumberToIP $network
        Broadcast = Convert-NumberToIP $broadcast
        FirstHost = Convert-NumberToIP $first
        LastHost  = Convert-NumberToIP $last
        Prefix    = $prefix
        Mask      = Convert-NumberToIP $mask
        Usable    = $usable
        Start     = [uint64]$network
        End       = [uint64]$broadcast
    }

}

function Global:Invoke-SubnetCalculator {

param(
    [string]$CIDR,
    [string]$CompareCIDR,
    [switch]$PassThru
)

    Clear-Host

    Write-Host ""
    Write-Host "SUBNET CALCULATOR" -ForegroundColor Cyan
    Write-Host "=================" -ForegroundColor DarkCyan
    Write-Host ""

    if(!$CIDR){
        $CIDR = Read-CSIInput "CIDR network"
    }

    try {
        $subnet = Get-CSISubnetInfo $CIDR
    }
    catch {
        Write-Host $_.Exception.Message -ForegroundColor Red
        return
    }

    if(!$PassThru){

        $subnet |
            Select-Object CIDR,Network,Broadcast,FirstHost,LastHost,Mask,Usable |
            Format-Table -AutoSize

    }

    if(!$CompareCIDR){
        $CompareCIDR = Read-CSIInput "Compare overlap with another CIDR (optional)" -AllowEmpty
    }

    if($CompareCIDR){

        try {

            $compare = Get-CSISubnetInfo $CompareCIDR
            $overlaps = ($subnet.Start -le $compare.End -and $compare.Start -le $subnet.End)

            Write-Host ""
            Write-Host "Overlap:" $overlaps

        }
        catch {
            Write-Host $_.Exception.Message -ForegroundColor Red
        }

    }

    if($PassThru){
        return $subnet
    }

}

Register-CSICommand `
    -Name "Subnet Calculator" `
    -Command "Invoke-SubnetCalculator" `
    -Category "Plugins" `
    -Description "Break down CIDR ranges and check overlap" `
    -Order 70
