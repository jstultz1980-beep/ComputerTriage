function Global:Read-NTKRobocopyChoice {

param(
    [string]$Prompt,
    [string[]]$ValidChoices
)

    while($true){

        $choice = Read-NTKInput $Prompt

        if($ValidChoices -contains $choice){
            return $choice
        }

        Write-Host "Invalid selection." -ForegroundColor Red

    }

}

function Global:Add-NTKRobocopySwitch {

param(
    [ref]$Switches,
    [ref]$Explanations,
    [string]$Switch,
    [string]$Explanation
)

    if($Switches.Value -notcontains $Switch){
        $Switches.Value += $Switch
        $Explanations.Value += [pscustomobject]@{
            Switch = $Switch
            Reason = $Explanation
        }
    }

}

function Global:Format-NTKRobocopyCommand {

param(
    [string]$Source,
    [string]$Destination,
    [string[]]$FilePatterns,
    [string[]]$Switches
)

    function Format-Token {
        param([string]$Value)

        if($Value -match "^/"){
            return $Value
        }

        if($Value -match "\s"){
            return "`"$Value`""
        }

        return $Value
    }

    $parts = @(
        "robocopy.exe"
        "`"$Source`""
        "`"$Destination`""
    )

    foreach($pattern in $FilePatterns){
        $parts += "`"$pattern`""
    }

    foreach($switch in $Switches){
        $parts += Format-Token $switch
    }

    return ($parts -join " ")

}

function Global:Invoke-RobocopyBuilder {

    Clear-Host

    Write-Host ""
    Write-Host "ROBOCOPY BUILDER" -ForegroundColor Cyan
    Write-Host "================" -ForegroundColor DarkCyan
    Write-Host ""

    $source = Read-NTKInput "Where are you copying FROM"
    $destination = Read-NTKInput "Where are you copying TO"
    $patternInput = Read-NTKInput "What files should be copied? Blank means everything" -AllowEmpty

    $filePatterns = @("*.*")

    if($patternInput){
        $filePatterns = @($patternInput -split "," | ForEach-Object {$_.Trim()} | Where-Object {$_})
    }

    $switches = @()
    $explanations = @()

    Write-Host ""
    Write-Host "What kind of copy is this?"
    Write-Host "1. Normal folder copy"
    Write-Host "2. Make destination match source exactly"
    Write-Host "3. Large or unreliable network copy"
    Write-Host "4. Permission-preserving migration"
    Write-Host ""

    $copyType = Read-NTKRobocopyChoice "Select copy type" @("1","2","3","4")

    if($copyType -eq "2"){

        Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/MIR" "Mirrors the source to the destination, including deleting destination files that no longer exist in the source."

    }
    else{

        Write-Host ""
        Write-Host "Should empty folders be included?"
        Write-Host "1. Yes, include all subfolders"
        Write-Host "2. No, only copy folders that contain files"
        Write-Host ""

        $emptyFolders = Read-NTKRobocopyChoice "Select folder behavior" @("1","2")

        if($emptyFolders -eq "1"){
            Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/E" "Copies subfolders, including empty folders."
        }
        else{
            Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/S" "Copies subfolders, but skips empty folders."
        }

    }

    if($copyType -eq "3"){
        Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/Z" "Uses restartable mode for interrupted network copies."
    }

    Write-Host ""
    Write-Host "How should file metadata be handled?"
    Write-Host "1. Normal data, attributes, and timestamps"
    Write-Host "2. Also preserve NTFS permissions"
    Write-Host "3. Full migration metadata including owner and audit info"
    Write-Host ""

    $metadata = Read-NTKRobocopyChoice "Select metadata behavior" @("1","2","3")

    switch($metadata){
        "1" {
            Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/COPY:DAT" "Copies file data, attributes, and timestamps."
            Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/DCOPY:DAT" "Copies directory data, attributes, and timestamps."
        }
        "2" {
            Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/COPY:DATS" "Copies file data, attributes, timestamps, and NTFS security."
            Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/DCOPY:DAT" "Copies directory data, attributes, and timestamps."
            Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/SECFIX" "Fixes file security on skipped files as well as copied files."
        }
        "3" {
            Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/COPYALL" "Copies all file metadata: data, attributes, timestamps, security, owner, and audit info."
            Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/DCOPY:DAT" "Copies directory data, attributes, and timestamps."
            Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/SECFIX" "Fixes file security on skipped files as well as copied files."
        }
    }

    Write-Host ""
    Write-Host "Is either side a NAS, Linux share, or older file server?"
    Write-Host "1. No"
    Write-Host "2. Yes"
    Write-Host ""

    $nas = Read-NTKRobocopyChoice "Select timestamp behavior" @("1","2")

    if($nas -eq "2"){
        Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/FFT" "Allows two-second timestamp tolerance for NAS and non-Windows file systems."
    }

    Write-Host ""
    Write-Host "How hard should robocopy retry locked or busy files?"
    Write-Host "1. Fast troubleshooting, do not wait long"
    Write-Host "2. Balanced"
    Write-Host "3. Patient migration"
    Write-Host ""

    $retry = Read-NTKRobocopyChoice "Select retry behavior" @("1","2","3")

    switch($retry){
        "1" {
            Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/R:1" "Retries failed copies once."
            Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/W:1" "Waits one second between retries."
        }
        "2" {
            Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/R:3" "Retries failed copies three times."
            Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/W:5" "Waits five seconds between retries."
        }
        "3" {
            Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/R:10" "Retries failed copies ten times."
            Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/W:10" "Waits ten seconds between retries."
            Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/Z" "Uses restartable mode for interrupted network copies."
        }
    }

    Write-Host ""
    Write-Host "How many copy threads should be used?"
    Write-Host "1. Gentle"
    Write-Host "2. Normal"
    Write-Host "3. Fast"
    Write-Host ""

    $threads = Read-NTKRobocopyChoice "Select speed" @("1","2","3")

    switch($threads){
        "1" { Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/MT:4" "Uses four copy threads to reduce load." }
        "2" { Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/MT:16" "Uses sixteen copy threads for a balanced copy speed." }
        "3" { Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/MT:32" "Uses thirty-two copy threads for faster copies on capable systems." }
    }

    $excludeFiles = Read-NTKInput "File names or patterns to exclude, comma separated" -AllowEmpty
    $excludeDirs = Read-NTKInput "Folder names to exclude, comma separated" -AllowEmpty

    if($excludeFiles){
        Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/XF" "Excludes matching file names or patterns."
        $switches += @($excludeFiles -split "," | ForEach-Object {$_.Trim()} | Where-Object {$_})
    }

    if($excludeDirs){
        Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/XD" "Excludes matching folder names."
        $switches += @($excludeDirs -split "," | ForEach-Object {$_.Trim()} | Where-Object {$_})
    }

    Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/TEE" "Shows output in the console even if logging is added later."
    Add-NTKRobocopySwitch ([ref]$switches) ([ref]$explanations) "/NP" "Hides per-file progress percentages to keep output readable."

    $command = Format-NTKRobocopyCommand `
        -Source $source `
        -Destination $destination `
        -FilePatterns $filePatterns `
        -Switches $switches

    Clear-Host

    Write-Host ""
    Write-Host "ROBOCOPY COMMAND" -ForegroundColor Cyan
    Write-Host "================" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host $command -ForegroundColor Green
    Write-Host ""
    Write-Host "Switches"
    Write-Host "--------"
    $explanations | Format-Table -Wrap -AutoSize

    Write-Host ""
    Write-Host "Actions"
    Write-Host "1. Preview only"
    Write-Host "2. Run copy"
    Write-Host "3. Copy command to clipboard"
    Write-Host "4. Done"
    Write-Host ""

    $action = Read-NTKRobocopyChoice "Select action" @("1","2","3","4")

    if($action -eq "1"){
        Write-Host ""
        Write-Host "Preview mode. No files will be copied." -ForegroundColor Yellow
        & robocopy.exe $source $destination @filePatterns @switches /L
    }
    elseif($action -eq "2"){
        Write-Host ""
        Write-Host "Robocopy is about to run." -ForegroundColor Yellow
        $confirm = Read-NTKInput "Type RUN to continue"

        if($confirm -eq "RUN"){
            & robocopy.exe $source $destination @filePatterns @switches
            Write-Host ""
            Write-Host "Robocopy exit code:" $LASTEXITCODE
        }
        else{
            Write-Host "Copy cancelled." -ForegroundColor Yellow
        }
    }
    elseif($action -eq "3"){
        if(Get-Command Set-Clipboard -ErrorAction SilentlyContinue){
            $command | Set-Clipboard
            Write-Host "Command copied to clipboard." -ForegroundColor Green
        }
        else{
            Write-Host "Clipboard support is not available in this session." -ForegroundColor Yellow
        }
    }

}

function Global:Invoke-FileUtilities {

    while($true){

        Clear-Host

        Write-Host ""
        Write-Host "FILE UTILITIES" -ForegroundColor Cyan
        Write-Host "==============" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "1. Robocopy Builder"
        Write-Host "2. WizTree"
        Write-Host "3. Handle"
        Write-Host ""

        $choice = Read-NTKInput "Select file utility"

        switch($choice){
            "1" { Invoke-RobocopyBuilder }
            "2" { Invoke-NTKExternalTool -Id "WizTree" }
            "3" { Invoke-NTKExternalTool -Id "Handle" }
            default { Write-Host "Invalid selection." -ForegroundColor Red }
        }

        Write-Host ""
        [void](Read-NTKInput "Press ENTER to continue" -AllowEmpty)

    }

}

Register-NTKCommand `
    -Name "File Utilities" `
    -Command "Invoke-FileUtilities" `
    -Category "Utilities" `
    -Description "Robocopy builder, disk usage, and locked-file helpers" `
    -Order 75
