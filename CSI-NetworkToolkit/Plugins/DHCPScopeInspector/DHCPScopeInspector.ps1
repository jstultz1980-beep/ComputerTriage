function Global:Invoke-DHCPScopeInspector {

param(
    [string]$Server,
    [switch]$PassThru
)

    Clear-Host

    Write-Host ""
    Write-Host "DHCP SCOPE INSPECTOR" -ForegroundColor Cyan
    Write-Host "====================" -ForegroundColor DarkCyan
    Write-Host ""

    if(!(Get-Command Get-DhcpServerv4Scope -ErrorAction SilentlyContinue)){

        Write-Host "DHCP Server PowerShell tools are not available." -ForegroundColor Yellow
        Write-Host "Install RSAT DHCP tools to inspect DHCP scopes."
        return

    }

    if(!$Server){
        $Server = Read-CSIInput "DHCP server (blank for local)" -AllowEmpty
    }

    try {

        if($Server){
            $scopes = Get-DhcpServerv4Scope -ComputerName $Server
        }
        else{
            $scopes = Get-DhcpServerv4Scope
        }

    }
    catch {

        Write-Host "Unable to read DHCP scopes." -ForegroundColor Red
        Write-Host $_.Exception.Message
        Write-Host "Specify a DHCP server name if this machine is not the DHCP server." -ForegroundColor Yellow
        return

    }

    if($PassThru){
        return $scopes
    }

    $scopes |
        Select-Object ScopeId,Name,State,StartRange,EndRange,SubnetMask |
        Format-Table -AutoSize

}

Register-CSICommand `
    -Name "DHCP Scope Inspector" `
    -Command "Invoke-DHCPScopeInspector" `
    -Category "Plugins" `
    -Description "Inspect DHCP scopes when RSAT DHCP tools are available" `
    -Order 51 `
    -RequiresAdmin
