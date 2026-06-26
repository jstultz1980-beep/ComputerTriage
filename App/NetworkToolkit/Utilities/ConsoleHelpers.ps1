function Global:Test-NTKBackCommand {

param([string]$Value)

    return ($Value -match "^(b|back|q|quit|exit|menu)$")

}

function Global:Exit-NTKTool {

    throw [System.OperationCanceledException]::new("Returned to toolkit menu.")

}

function Global:Read-NTKInput {

param(
    [string]$Prompt,
    [switch]$AllowEmpty
)

    while($true){

        if([Console]::IsInputRedirected){
            Write-Host "$Prompt [B=Back]"
            $value = [Console]::In.ReadLine()
            if($null -eq $value){
                throw [System.OperationCanceledException]::new('This legacy menu requires a GUI form and cannot accept console input.')
            }
        }
        else{
            $value = Read-Host "$Prompt [B=Back]"
        }

        if(Test-NTKBackCommand $value){
            Exit-NTKTool
        }

        if($AllowEmpty -or $value){
            return $value
        }

        Write-Host "Input is required. Enter B to return to the menu." -ForegroundColor Yellow

    }

}

function Global:Test-NTKKeyEscape {

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

        return (Test-NTKBackCommand ([string]$key.KeyChar))

    }
    catch {
        return $false
    }

}

function Global:Test-NTKAdministrator {

    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)

    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

}

function Global:Start-NTKElevatedTool {

param([string]$CommandName)

    if(!$NTKPaths -or !$NTKPaths.Root){
        Write-Host "Toolkit paths are not loaded." -ForegroundColor Red
        return $false
    }

    $launcher = Join-Path $NTKPaths.Root "NetworkToolkit-Core.ps1"

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

        Start-NTKToolProcess `
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
