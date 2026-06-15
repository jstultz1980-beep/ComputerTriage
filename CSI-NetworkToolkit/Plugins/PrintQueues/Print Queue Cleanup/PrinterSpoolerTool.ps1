#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$ToolDataRoot = ''
)

Set-StrictMode -Version Latest

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$script:Credential = $null
$script:PrinterCache = @()
$script:Connected = $false
$script:LastComputer = ''
$script:LastUser = ''
$script:ConnectedComputer = ''
$script:StatusLabel = $null
$script:DiscoveryCompleted = $false

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$DataRoot = if ($ToolDataRoot -and $ToolDataRoot.Trim()) {
    $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ToolDataRoot.Trim())
}
else {
    $ScriptRoot
}
if (-not (Test-Path $DataRoot)) { New-Item -ItemType Directory -Path $DataRoot -Force | Out-Null }

$ConfigPath = Join-Path $DataRoot 'PrintSpoolerTool.ini'
$LogDir = Join-Path $DataRoot 'Logs'
$LogPath = Join-Path $LogDir 'PrintSpoolerTool.log'
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    "{0} [{1}] {2}" -f $timestamp, $env:USERNAME, $Message | Out-File -FilePath $LogPath -Append -Encoding UTF8
}

function Show-ToolMessage {
    param(
        [string]$Message,
        [string]$Title = 'Network Toolkit Print Spooler Tool',
        [System.Windows.Forms.MessageBoxIcon]$Icon = [System.Windows.Forms.MessageBoxIcon]::Information
    )
    [void][System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::OK, $Icon)
}

function Set-Status {
    param([string]$Text, [System.Drawing.Color]$Color = [System.Drawing.Color]::DimGray)
    if ($script:StatusLabel) {
        $script:StatusLabel.Text = $Text
        $script:StatusLabel.ForeColor = $Color
        [System.Windows.Forms.Application]::DoEvents()
    }
    Write-Log $Text
}

function Load-Config {
    if (-not (Test-Path $ConfigPath)) { return }
    foreach ($line in Get-Content -Path $ConfigPath -ErrorAction SilentlyContinue) {
        if ($line -notmatch '=') { continue }
        $key, $value = $line -split '=', 2
        switch ($key) {
            'ComputerName' { $script:LastComputer = $value }
            'Username' { $script:LastUser = $value }
        }
    }
}

function Save-Config {
    @(
        "ComputerName=$($txtComputer.Text.Trim())"
        "Username=$($txtUser.Text.Trim())"
    ) | Set-Content -Path $ConfigPath -Encoding UTF8
}

function Test-IsLocalComputer {
    param([string]$ComputerName)
    if (-not $ComputerName -or $ComputerName.Trim() -in @('.', 'localhost')) { return $true }
    $name = $ComputerName.Trim()
    $localNames = @($env:COMPUTERNAME, "$env:COMPUTERNAME.$env:USERDNSDOMAIN") | Where-Object { $_ }
    return @($localNames | Where-Object { $_ -ieq $name }).Count -gt 0
}

function Test-IsAuthenticationError {
    param([string]$Message)
    return ($Message -match 'Access is denied|Logon failure|authentication|unauthorized|credentials|WinRM cannot process the request')
}

function Get-ToolCredential {
    if ([string]::IsNullOrWhiteSpace($txtUser.Text)) { return $null }
    $script:LastUser = $txtUser.Text.Trim()
    return Get-Credential -UserName $script:LastUser -Message "Enter password for $($script:LastUser)"
}

function Invoke-Target {
    param(
        [Parameter(Mandatory = $true)][scriptblock]$ScriptBlock,
        [object[]]$ArgumentList = @(),
        [string]$ComputerName = '',
        [switch]$NoCredentialPrompt
    )

    $computerName = if ($ComputerName -and $ComputerName.Trim()) { $ComputerName.Trim() } else { $txtComputer.Text.Trim() }
    if (-not $computerName) { throw 'Print server is blank.' }

    if (Test-IsLocalComputer -ComputerName $computerName) {
        return & $ScriptBlock @ArgumentList
    }

    $attempt = 0
    while ($attempt -lt 3) {
        try {
            $attempt++
            $invokeParams = @{
                ComputerName = $computerName
                ScriptBlock = $ScriptBlock
                ErrorAction = 'Stop'
            }
            if ($script:Credential) { $invokeParams.Credential = $script:Credential }
            if ($ArgumentList -and $ArgumentList.Count -gt 0) { $invokeParams.ArgumentList = $ArgumentList }
            Set-Status "Remote call attempt $attempt to $computerName..." ([System.Drawing.Color]::DimGray)
            return Invoke-Command @invokeParams
        }
        catch {
            $message = $_.Exception.Message
            if (-not (Test-IsAuthenticationError -Message $message) -or $attempt -ge 3) {
                throw
            }
            if ($NoCredentialPrompt) { throw }
            Show-ToolMessage -Message "Authentication failed. Enter credentials again.`n`n$message" -Title 'Authentication' -Icon Warning
            $script:Credential = Get-ToolCredential
            if (-not $script:Credential) { throw 'Credential prompt was cancelled.' }
        }
    }
}

function Add-ServerCandidate {
    param([string]$ComputerName)

    if ([string]::IsNullOrWhiteSpace($ComputerName)) { return }
    $candidate = $ComputerName.Trim()
    if (-not $candidate) { return }

    $exists = $false
    foreach ($item in $txtComputer.Items) {
        if ([string]$item -ieq $candidate) {
            $exists = $true
            break
        }
    }
    if (-not $exists) { [void]$txtComputer.Items.Add($candidate) }
}

function Get-PrintServerCandidates {
    $candidates = New-Object System.Collections.Generic.List[string]

    foreach ($candidate in @($script:LastComputer)) {
        if (-not [string]::IsNullOrWhiteSpace($candidate) -and -not $candidates.Contains($candidate.Trim())) {
            [void]$candidates.Add($candidate.Trim())
        }
    }

    try {
        if (Get-Command Get-ADComputer -ErrorAction SilentlyContinue) {
            $adCandidates = @(Get-ADComputer -Filter "OperatingSystem -like '*Server*' -and (Name -like '*print*' -or Name -like '*prn*' -or Name -like '*queue*' -or Description -like '*print*' -or Description -like '*printer*')" -Properties DNSHostName,Description,OperatingSystem -ErrorAction Stop |
                Select-Object -First 12)

            foreach ($server in $adCandidates) {
                $name = if ($server.DNSHostName) { [string]$server.DNSHostName } else { [string]$server.Name }
                if (-not [string]::IsNullOrWhiteSpace($name) -and -not $candidates.Contains($name.Trim())) {
                    [void]$candidates.Add($name.Trim())
                }
            }
        }
    }
    catch {
        Write-Log "Print server AD discovery skipped: $($_.Exception.Message)"
    }

    if (-not [string]::IsNullOrWhiteSpace($env:COMPUTERNAME) -and -not $candidates.Contains($env:COMPUTERNAME.Trim())) {
        [void]$candidates.Add($env:COMPUTERNAME.Trim())
    }

    return @($candidates)
}

function Get-PrinterSummary {
    $includeUnshared = $chkShowAll.Checked
    $data = Invoke-Target {
        param([bool]$IncludeUnshared)

        $printers = @(Get-Printer -ErrorAction Stop)
        if (-not $IncludeUnshared) { $printers = @($printers | Where-Object { $_.Shared }) }

        foreach ($printer in $printers) {
            $jobCount = 0
            if ($printer.PSObject.Properties['JobCount'] -and $null -ne $printer.JobCount) {
                try { $jobCount = [int]$printer.JobCount } catch { $jobCount = 0 }
            }

            [pscustomobject]@{
                DisplayName = if ($printer.ShareName) { $printer.ShareName } else { $printer.Name }
                Name = $printer.Name
                ShareName = $printer.ShareName
                Shared = [bool]$printer.Shared
                JobCount = $jobCount
                Status = [string]$printer.PrinterStatus
                DriverName = $printer.DriverName
                PortName = $printer.PortName
            }
        }
    } -ArgumentList @($includeUnshared)

    $script:PrinterCache = @($data)
    return $script:PrinterCache
}

function Refresh-Grid {
    param(
        [switch]$Silent,
        [switch]$ThrowOnError
    )

    if (-not $script:Connected) {
        if (-not $Silent) { Show-ToolMessage -Message 'Connect to a print server first.' -Icon Warning }
        if ($ThrowOnError) { throw 'Connect to a print server first.' }
        return
    }

    try {
        Set-Status 'Refreshing printer list...' ([System.Drawing.Color]::DimGray)
        $data = @(Get-PrinterSummary)
        $table = New-Object System.Data.DataTable
        foreach ($column in @('DisplayName','Jobs','Status','Shared','Driver','Port','RealName')) {
            [void]$table.Columns.Add($column)
        }

        foreach ($printer in $data) {
            $row = $table.NewRow()
            $row.DisplayName = $printer.DisplayName
            $row.Jobs = $printer.JobCount
            $row.Status = $printer.Status
            $row.Shared = $printer.Shared
            $row.Driver = $printer.DriverName
            $row.Port = $printer.PortName
            $row.RealName = $printer.Name
            $table.Rows.Add($row)
        }

        $grid.DataSource = $null
        $grid.DataSource = $table
        if ($grid.Columns.Contains('RealName')) { $grid.Columns['RealName'].Visible = $false }
        Set-Status "Connected to $script:ConnectedComputer. Printers shown: $($data.Count)." ([System.Drawing.Color]::ForestGreen)
    }
    catch {
        Set-Status 'Refresh failed.' ([System.Drawing.Color]::Firebrick)
        if (-not $Silent) { Show-ToolMessage -Message "Refresh failed:`n$($_.Exception.Message)" -Icon Error }
        if ($ThrowOnError) { throw }
    }
}

function Restart-Spooler {
    Invoke-Target { Restart-Service Spooler -Force -ErrorAction Stop }
    Set-Status 'Spooler restarted.' ([System.Drawing.Color]::ForestGreen)
}

function Clear-AllQueues {
    Invoke-Target {
        Stop-Service Spooler -Force -ErrorAction Stop
        Start-Sleep -Seconds 2
        Remove-Item -LiteralPath "$env:SystemRoot\System32\spool\PRINTERS\*" -Force -ErrorAction SilentlyContinue
        Start-Service Spooler -ErrorAction Stop
    }
    Set-Status 'All queues cleared and spooler restarted.' ([System.Drawing.Color]::ForestGreen)
}

function Clear-PrinterQueue {
    param([Parameter(Mandatory = $true)][string]$PrinterName)

    $message = Invoke-Target {
        param([string]$TargetPrinter)
        $jobs = @(Get-PrintJob -PrinterName $TargetPrinter -ErrorAction Stop)
        foreach ($job in $jobs) {
            Remove-PrintJob -PrinterName $TargetPrinter -ID $job.ID -ErrorAction Stop
        }
        return "Cleared $($jobs.Count) job(s) from $TargetPrinter."
    } -ArgumentList @($PrinterName)

    Set-Status ([string]$message) ([System.Drawing.Color]::ForestGreen)
}

function Set-ConnectedState {
    param([bool]$Connected)
    $script:Connected = $Connected
    $btnRefresh.Enabled = $Connected
    $btnClear.Enabled = $Connected
    $btnRestart.Enabled = $Connected
    $btnFullReset.Enabled = $Connected
}

function Connect-PrintServer {
    param(
        [string]$ComputerName,
        [switch]$PromptForCredentials,
        [switch]$ShowErrors,
        [bool]$SaveTarget = $true
    )

    if ([string]::IsNullOrWhiteSpace($ComputerName)) {
        if ($ShowErrors) { Show-ToolMessage -Message 'Enter a print server.' -Icon Warning }
        return $false
    }

    $target = $ComputerName.Trim()
    $txtComputer.Text = $target
    Add-ServerCandidate -ComputerName $target

    try {
        $script:Credential = $null
        if ($PromptForCredentials -and -not [string]::IsNullOrWhiteSpace($txtUser.Text) -and -not (Test-IsLocalComputer -ComputerName $target)) {
            $script:Credential = Get-ToolCredential
            if (-not $script:Credential) { return $false }
        }

        Set-Status "Connecting to $target..." ([System.Drawing.Color]::DimGray)
        $hostname = Invoke-Target -ComputerName $target -NoCredentialPrompt:(!$PromptForCredentials) -ScriptBlock { hostname }
        $script:ConnectedComputer = ([string]$hostname).Trim()
        if ($SaveTarget) { Save-Config }
        Set-ConnectedState -Connected $true
        Refresh-Grid -Silent:(!$ShowErrors) -ThrowOnError:(!$ShowErrors)
        return $true
    }
    catch {
        Set-ConnectedState -Connected $false
        Set-Status "Connection failed for $target." ([System.Drawing.Color]::Firebrick)
        Write-Log "Connection failed for $target`: $($_.Exception.Message)"
        if ($ShowErrors) { Show-ToolMessage -Message "Connection failed:`n$($_.Exception.Message)" -Icon Error }
        return $false
    }
}

function Start-InitialDiscovery {
    if ($script:DiscoveryCompleted) { return }
    $script:DiscoveryCompleted = $true

    Set-Status 'Finding likely print servers...' ([System.Drawing.Color]::DimGray)
    $candidates = @(Get-PrintServerCandidates)
    foreach ($candidate in $candidates) { Add-ServerCandidate -ComputerName $candidate }

    if ($candidates.Count -eq 0) {
        Set-Status 'No likely print servers found. Type a server name and click Connect.' ([System.Drawing.Color]::DarkGoldenrod)
        return
    }

    foreach ($candidate in $candidates) {
        if (Connect-PrintServer -ComputerName $candidate -SaveTarget:$false) {
            if ($script:PrinterCache.Count -gt 0) {
                Save-Config
                return
            }
            Write-Log "Print server candidate $candidate was reachable but no shared queues were found."
        }
    }

    $txtComputer.Text = $candidates[0]
    Set-Status 'No accessible print server found automatically. Select or type a server and click Connect.' ([System.Drawing.Color]::DarkGoldenrod)
}

Load-Config

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Network Toolkit Print Queue Tool'
$form.Size = New-Object System.Drawing.Size(820, 590)
$form.MinimumSize = New-Object System.Drawing.Size(760, 520)
$form.StartPosition = 'CenterScreen'

$lblComputer = New-Object System.Windows.Forms.Label
$lblComputer.Text = 'Print Server:'
$lblComputer.Location = New-Object System.Drawing.Point(12, 14)
$lblComputer.AutoSize = $true
$form.Controls.Add($lblComputer)

$txtComputer = New-Object System.Windows.Forms.ComboBox
$txtComputer.Location = New-Object System.Drawing.Point(92, 10)
$txtComputer.Size = New-Object System.Drawing.Size(210, 23)
$txtComputer.DropDownStyle = 'DropDown'
$txtComputer.Text = $script:LastComputer
$form.Controls.Add($txtComputer)

$lblUser = New-Object System.Windows.Forms.Label
$lblUser.Text = 'Username:'
$lblUser.Location = New-Object System.Drawing.Point(318, 14)
$lblUser.AutoSize = $true
$form.Controls.Add($lblUser)

$txtUser = New-Object System.Windows.Forms.TextBox
$txtUser.Location = New-Object System.Drawing.Point(390, 10)
$txtUser.Size = New-Object System.Drawing.Size(220, 23)
$txtUser.Text = $script:LastUser
$form.Controls.Add($txtUser)

$chkShowAll = New-Object System.Windows.Forms.CheckBox
$chkShowAll.Text = 'Show unshared printers'
$chkShowAll.Location = New-Object System.Drawing.Point(625, 12)
$chkShowAll.AutoSize = $true
$form.Controls.Add($chkShowAll)

$btnConnect = New-Object System.Windows.Forms.Button
$btnConnect.Text = 'Connect'
$btnConnect.Location = New-Object System.Drawing.Point(12, 42)
$btnConnect.Size = New-Object System.Drawing.Size(90, 30)
$form.Controls.Add($btnConnect)

$btnSave = New-Object System.Windows.Forms.Button
$btnSave.Text = 'Save Target'
$btnSave.Location = New-Object System.Drawing.Point(112, 42)
$btnSave.Size = New-Object System.Drawing.Size(95, 30)
$form.Controls.Add($btnSave)

$btnFind = New-Object System.Windows.Forms.Button
$btnFind.Text = 'Find Servers'
$btnFind.Location = New-Object System.Drawing.Point(217, 42)
$btnFind.Size = New-Object System.Drawing.Size(100, 30)
$form.Controls.Add($btnFind)

$grid = New-Object System.Windows.Forms.DataGridView
$grid.Location = New-Object System.Drawing.Point(12, 84)
$grid.Size = New-Object System.Drawing.Size(780, 330)
$grid.Anchor = 'Top,Bottom,Left,Right'
$grid.ReadOnly = $true
$grid.AutoSizeColumnsMode = 'Fill'
$grid.SelectionMode = 'FullRowSelect'
$grid.MultiSelect = $false
$grid.AllowUserToAddRows = $false
$grid.AllowUserToDeleteRows = $false
$form.Controls.Add($grid)

$btnRefresh = New-Object System.Windows.Forms.Button
$btnRefresh.Text = 'Refresh'
$btnRefresh.Location = New-Object System.Drawing.Point(12, 428)
$btnRefresh.Size = New-Object System.Drawing.Size(100, 32)
$btnRefresh.Anchor = 'Bottom,Left'
$btnRefresh.Enabled = $false
$form.Controls.Add($btnRefresh)

$btnClear = New-Object System.Windows.Forms.Button
$btnClear.Text = 'Clear Selected'
$btnClear.Location = New-Object System.Drawing.Point(122, 428)
$btnClear.Size = New-Object System.Drawing.Size(120, 32)
$btnClear.Anchor = 'Bottom,Left'
$btnClear.Enabled = $false
$form.Controls.Add($btnClear)

$btnRestart = New-Object System.Windows.Forms.Button
$btnRestart.Text = 'Restart Spooler'
$btnRestart.Location = New-Object System.Drawing.Point(252, 428)
$btnRestart.Size = New-Object System.Drawing.Size(120, 32)
$btnRestart.Anchor = 'Bottom,Left'
$btnRestart.Enabled = $false
$form.Controls.Add($btnRestart)

$btnFullReset = New-Object System.Windows.Forms.Button
$btnFullReset.Text = 'Full Spooler Reset'
$btnFullReset.Location = New-Object System.Drawing.Point(382, 428)
$btnFullReset.Size = New-Object System.Drawing.Size(140, 32)
$btnFullReset.Anchor = 'Bottom,Left'
$btnFullReset.Enabled = $false
$form.Controls.Add($btnFullReset)

$script:StatusLabel = New-Object System.Windows.Forms.Label
$script:StatusLabel.Text = "Data folder: $DataRoot"
$script:StatusLabel.Location = New-Object System.Drawing.Point(12, 480)
$script:StatusLabel.Size = New-Object System.Drawing.Size(780, 44)
$script:StatusLabel.Anchor = 'Bottom,Left,Right'
$script:StatusLabel.ForeColor = [System.Drawing.Color]::DimGray
$form.Controls.Add($script:StatusLabel)

$btnSave.Add_Click({
    try {
        Add-ServerCandidate -ComputerName $txtComputer.Text
        Save-Config
        Set-Status 'Target saved.' ([System.Drawing.Color]::ForestGreen)
    }
    catch {
        Show-ToolMessage -Message "Save failed:`n$($_.Exception.Message)" -Icon Error
    }
})

$btnConnect.Add_Click({
    [void](Connect-PrintServer -ComputerName $txtComputer.Text -PromptForCredentials -ShowErrors)
})

$btnFind.Add_Click({
    $script:DiscoveryCompleted = $false
    Start-InitialDiscovery
})

$chkShowAll.Add_CheckedChanged({
    if ($script:Connected) { Refresh-Grid }
})

$btnRefresh.Add_Click({ Refresh-Grid })

$btnClear.Add_Click({
    if ($grid.SelectedRows.Count -eq 0) { return }
    $row = $grid.SelectedRows[0]
    $printerName = [string]$row.Cells['RealName'].Value
    $displayName = [string]$row.Cells['DisplayName'].Value
    if (-not $printerName) {
        Show-ToolMessage -Message 'Unable to resolve selected printer name.' -Icon Warning
        return
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Clear all visible jobs from '$displayName'?`n`nThis modifies the selected print queue.",
        'Confirm Clear Selected Queue',
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )
    if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) { return }

    try {
        Clear-PrinterQueue -PrinterName $printerName
        Refresh-Grid
    }
    catch {
        Set-Status 'Clear selected failed.' ([System.Drawing.Color]::Firebrick)
        Show-ToolMessage -Message "Clear selected failed:`n$($_.Exception.Message)" -Icon Error
    }
})

$btnRestart.Add_Click({
    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Restart the Print Spooler service on '$($txtComputer.Text.Trim())'?",
        'Confirm Restart Spooler',
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )
    if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) { return }

    try {
        Restart-Spooler
        Refresh-Grid
    }
    catch {
        Set-Status 'Restart spooler failed.' ([System.Drawing.Color]::Firebrick)
        Show-ToolMessage -Message "Restart spooler failed:`n$($_.Exception.Message)" -Icon Error
    }
})

$btnFullReset.Add_Click({
    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Clear ALL queues and restart the spooler on '$($txtComputer.Text.Trim())'?`n`nUse only with approval.",
        'Confirm Full Spooler Reset',
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )
    if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) { return }

    try {
        Clear-AllQueues
        Refresh-Grid
    }
    catch {
        Set-Status 'Full spooler reset failed.' ([System.Drawing.Color]::Firebrick)
        Show-ToolMessage -Message "Full spooler reset failed:`n$($_.Exception.Message)" -Icon Error
    }
})

Write-Log 'Print queue tool opened.'
$form.Add_Shown({ Start-InitialDiscovery })
[void]$form.ShowDialog()
