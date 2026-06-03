# =====================================================================
# Start-NetworkConsole.ps1
# CSI Network Toolkit Console Interface
# =====================================================================

function Global:Start-NetworkConsole {

    while ($true) {

        Clear-Host

        Write-Host ""
        Write-Host "CSI NETWORK TOOLKIT" -ForegroundColor Cyan
        Write-Host "===================" -ForegroundColor DarkCyan
        Write-Host ""

        $commands = Get-CSICommands

        if (!$commands -or $commands.Count -eq 0) {

            Write-Host "No commands registered." -ForegroundColor Yellow
            Write-Host ""
            [void](Read-Host "Press ENTER to exit")
            return
        }

        $menuItems = @()
        $i = 1

        foreach ($cmd in $commands) {

            $menuItems += [pscustomobject]@{
                Number = $i
                Text   = $cmd.Name
                Exit   = $false
            }

            $i++
        }

        $exitNumber = $i
        $rows = [math]::Ceiling($menuItems.Count / 2)
        $leftWidth = 44

        for($row = 0; $row -lt $rows; $row++){

            $left = $menuItems[$row]
            $rightIndex = $row + $rows

            $leftText = ("{0}. {1}" -f $left.Number,$left.Text)

            if($rightIndex -lt $menuItems.Count){

                $right = $menuItems[$rightIndex]
                $rightText = ("{0}. {1}" -f $right.Number,$right.Text)

                Write-Host $leftText.PadRight($leftWidth) -NoNewline
                Write-Host $rightText

            }
            else{

                Write-Host $leftText

            }

        }

        Write-Host ""
        Write-Host ("{0}. Exit" -f $exitNumber) -ForegroundColor Red
        Write-Host ""

        $choice = Read-Host "Select option"

        if(Test-CSIBackCommand $choice){ return }

        if (-not ($choice -as [int])) { continue }

        $choice = [int]$choice

        if ($choice -eq $exitNumber) { return }

        if ($choice -lt 1 -or $choice -gt $commands.Count) { continue }

        $selected = $commands[$choice - 1]
        $skipPause = $false

        if($selected.RequiresAdmin -and !(Test-CSIAdministrator)){

            Write-Host ""
            Write-Host "This tool requires administrator rights." -ForegroundColor Yellow
            Write-Host "Launching elevated PowerShell for:" $selected.Name
            Write-Host ""

            [void](Start-CSIElevatedTool $selected.Name)

            continue

        }

        try {

            Invoke-CSICommand $selected.Name

        }
        catch [System.OperationCanceledException] {

            Write-Host ""
            Write-Host $_.Exception.Message -ForegroundColor Yellow
            $skipPause = $true

        }
        catch {

            Write-Host ""
            Write-Host "Command failed." -ForegroundColor Red
            Write-Host $_

        }

        Write-Host ""

        if(!$skipPause){
            [void](Read-Host "Press ENTER to continue")
        }

    }

}
