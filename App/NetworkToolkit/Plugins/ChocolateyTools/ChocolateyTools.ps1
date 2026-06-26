function Global:Get-NTKChocolateyCommand {

    $command = Get-Command choco.exe -ErrorAction SilentlyContinue

    if($command){
        return $command.Source
    }

    $paths = @(
        "$env:ProgramData\chocolatey\bin\choco.exe",
        "$env:ChocolateyInstall\bin\choco.exe"
    )

    foreach($path in $paths){

        if($path -and (Test-Path $path)){
            return $path
        }

    }

    return $null

}

function Global:Invoke-InstallChocolatey {

    Clear-Host

    Write-Host ""
    Write-Host "INSTALL CHOCOLATEY" -ForegroundColor Cyan
    Write-Host "==================" -ForegroundColor DarkCyan
    Write-Host ""

    $existing = Get-NTKChocolateyCommand

    if($existing){

        Write-Host "Chocolatey is already installed:" $existing -ForegroundColor Green
        & $existing --version
        return

    }

    if(!(Test-NTKAdministrator)){

        Write-Host "Chocolatey install requires administrator rights." -ForegroundColor Yellow
        return

    }

    $confirm = Read-NTKInput "Install Chocolatey now? Type Y to continue"

    if($confirm -ne "Y"){

        Write-Host "Chocolatey install cancelled." -ForegroundColor Yellow
        return

    }

    try {

        Set-ExecutionPolicy Bypass -Scope Process -Force
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072

        Write-Host ""
        Write-Host "Downloading and running Chocolatey installer..." -ForegroundColor Cyan
        Write-Host ""

        Invoke-Expression ((New-Object Net.WebClient).DownloadString("https://community.chocolatey.org/install.ps1"))

        $machinePath = [Environment]::GetEnvironmentVariable("Path","Machine")
        $userPath = [Environment]::GetEnvironmentVariable("Path","User")
        $env:Path = "$machinePath;$userPath"

        $installed = Get-NTKChocolateyCommand

        if($installed){

            Write-Host ""
            Write-Host "Chocolatey installed:" $installed -ForegroundColor Green
            & $installed --version

        }
        else{

            Write-Host ""
            Write-Host "Chocolatey installer finished, but choco.exe was not found on PATH." -ForegroundColor Yellow

        }

    }
    catch {

        Write-Host ""
        Write-Host "Chocolatey install failed." -ForegroundColor Red
        Write-Host $_.Exception.Message

    }

}

function Global:Invoke-InstallChocoPackage {

param(
    [string]$Query,
    [switch]$Exact
)

    Clear-Host

    Write-Host ""
    Write-Host "INSTALL CHOCO PACKAGE" -ForegroundColor Cyan
    Write-Host "=====================" -ForegroundColor DarkCyan
    Write-Host ""

    $choco = Get-NTKChocolateyCommand

    if(!$choco){

        Write-Host "Chocolatey is not installed." -ForegroundColor Yellow
        Write-Host "Run Install Chocolatey first."
        return

    }

    if(!$Query){
        $Query = Read-NTKInput "Package search term"
    }

    Write-Host "Searching Chocolatey for:" $Query
    Write-Host ""

    if($Exact){

        $searches = @(
            [pscustomobject]@{
                Match = "Exact"
                Args  = @("search",$Query,"--exact","--limit-output")
            }
        )

    }
    else{

        $searches = @(
            [pscustomobject]@{
                Match = "Exact"
                Args  = @("search",$Query,"--exact","--limit-output")
            },
            [pscustomobject]@{
                Match = "Package ID"
                Args  = @("search",$Query,"--by-id-only","--limit-output","--page-size=20")
            },
            [pscustomobject]@{
                Match = "General"
                Args  = @("search",$Query,"--limit-output","--page-size=20")
            }
        )

    }

    $seen = @{}
    $packages = @()

    foreach($search in $searches){

        $raw = & $choco @($search.Args) 2>&1

        if($LASTEXITCODE -ne 0){
            continue
        }

        foreach($line in $raw){

            if($line -notmatch "\|"){
                continue
            }

            $parts = $line.ToString().Split("|")
            $name = $parts[0]

            if(!$name -or $seen.ContainsKey($name.ToLower())){
                continue
            }

            $seen[$name.ToLower()] = $true

            $packages += [pscustomobject]@{
                Name    = $name
                Version = if($parts.Count -gt 1){$parts[1]}else{""}
                Match   = $search.Match
            }

            if($packages.Count -ge 20){
                break
            }

        }

        if($packages.Count -ge 20){
            break
        }

    }

    if($packages.Count -eq 0){

        Write-Host "No Chocolatey packages found for:" $Query -ForegroundColor Yellow
        return

    }

    for($i = 0; $i -lt $packages.Count; $i++){

        $package = $packages[$i]

        Write-Host ("{0}. {1}  {2}  ({3})" -f ($i + 1),$package.Name,$package.Version,$package.Match)

    }

    Write-Host ""

    $choice = Read-NTKInput "Select package to install"

    if(-not ($choice -as [int])){
        Write-Host "Invalid selection." -ForegroundColor Red
        return
    }

    $index = [int]$choice

    if($index -lt 1 -or $index -gt $packages.Count){
        Write-Host "Invalid selection." -ForegroundColor Red
        return
    }

    $selected = $packages[$index - 1]

    Write-Host ""
    Write-Host "Selected:" $selected.Name $selected.Version
    Write-Host ""

    $confirm = Read-NTKInput "Install this package? Type Y to continue"

    if($confirm -ne "Y"){

        Write-Host "Package install cancelled." -ForegroundColor Yellow
        return

    }

    Write-Host ""
    Write-Host "Installing Chocolatey package:" $selected.Name -ForegroundColor Cyan
    Write-Host ""

    & $choco install $selected.Name -y

    if($LASTEXITCODE -eq 0){
        Write-Host ""
        Write-Host "Package installed:" $selected.Name -ForegroundColor Green
    }
    else{
        Write-Host ""
        Write-Host "Package install failed with exit code:" $LASTEXITCODE -ForegroundColor Red
    }

}
