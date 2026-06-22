function Global:Test-CSIBackCommand {

param([string]$Value)

    return ($Value -match "^(b|back|q|quit|exit|menu)$")

}

function Global:Exit-CSITool {

    throw [System.OperationCanceledException]::new("Returned to toolkit menu.")

}

function Global:Read-CSIInput {

param(
    [string]$Prompt,
    [switch]$AllowEmpty
)

    while($true){

        if([Console]::IsInputRedirected){
            Write-Host "$Prompt [B=Back]"
            $value = [Console]::In.ReadLine()
        }
        else{
            $value = Read-Host "$Prompt [B=Back]"
        }

        if(Test-CSIBackCommand $value){
            Exit-CSITool
        }

        if($AllowEmpty -or $value){
            return $value
        }

        Write-Host "Input is required. Enter B to return to the menu." -ForegroundColor Yellow

    }

}

function Global:Test-CSIKeyEscape {

    try {

        if([Console]::IsInputRedirected){
            return $false
        }

        if(![Console]::KeyAvailable){
            return $false
        }

        $key = [Console]::ReadKey($true)

        if($key.Key -eq [ConsoleKey]::Escape){
            return $true
        }

        return (Test-CSIBackCommand ([string]$key.KeyChar))

    }
    catch {
        return $false
    }

}

function Global:Test-CSIAdministrator {

    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)

    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

}

function Global:Start-CSIElevatedTool {

param([string]$CommandName)

    if(!$CSIPaths -or !$CSIPaths.Root){
        Write-Host "Toolkit paths are not loaded." -ForegroundColor Red
        return $false
    }

    $launcher = Join-Path $CSIPaths.Root "CSI-NetworkToolkit.ps1"

    if(!(Test-Path $launcher)){
        Write-Host "Toolkit launcher not found: $launcher" -ForegroundColor Red
        return $false
    }

    $arguments = @(
        "-NoProfile"
        "-ExecutionPolicy"
        "Bypass"
        "-File"
        "`"$launcher`""
        "-RunCommand"
        "`"$CommandName`""
    )

    try {

        Start-CSIToolProcess `
            -FilePath "powershell.exe" `
            -ArgumentList $arguments `
            -Elevated `
            -WindowStyle Normal | Out-Null

        return $true

    }
    catch {

        Write-Host "Elevation was cancelled or failed." -ForegroundColor Yellow
        Write-Host $_.Exception.Message
        return $false

    }

}
