# =====================================================================
# ToolKit-GUI.ps1
# Network Toolkit - Technician GUI
# =====================================================================

#Requires -Version 5.1

[CmdletBinding()]
param(
    [switch]$SmokeTest,
    [switch]$ButtonSmokeTest
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
try { Add-Type -AssemblyName Microsoft.VisualBasic -ErrorAction SilentlyContinue } catch {}

$GuiRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$SharedToolkitRoot = Join-Path (Split-Path -Parent $GuiRoot) "CSI-NetworkToolkit"
$ToolkitLauncher = Join-Path $SharedToolkitRoot "CSI-NetworkToolkit.ps1"
$GuiIconPath = Join-Path $GuiRoot "NetworkToolkit.ico"

if(!(Test-Path $ToolkitLauncher)){
    [System.Windows.Forms.MessageBox]::Show(
        "Could not find the shared toolkit launcher:`r`n$ToolkitLauncher",
        "Network Toolkit",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
    exit 1
}

try {
    . "$ToolkitLauncher" -NoConsole
}
catch {
    [System.Windows.Forms.MessageBox]::Show(
        "Could not load the toolkit.`r`n`r`n$($_.Exception.Message)",
        "Network Toolkit",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
    exit 1
}

$script:Commands = @(Get-CSICommands | Where-Object {$_.Name -notin @("File Utilities","Software Utilities")})
$script:Fingerprints = @()
$script:ChocoPackages = @()
$script:ChocoInstalledPackages = @()
$script:Reports = @()
$script:CustomTools = @()
$script:QuickDiagnosisRan = $false
$script:DismSfcRecommended = $false
$script:ToolTip = $null
$script:DashboardLabels = @{}
$script:ExternalToolCache = @{}
$script:TabButtons = @{}
$script:TabBuilders = @{}
$script:BuiltTabs = @{}
$script:StaticTabStrip = $null
$script:GuiSettings = $null
$script:SettingsTabOrderList = $null
$script:SettingsStartupTabCombo = $null
$script:SettingsThemeCombo = $null
$script:SettingsPreviousTheme = "Bright Blue"
$script:PendingCustomTheme = $null
$script:SettingsAutoOpenQuickReportCheck = $null
$script:SettingsRefreshPublicIPCheck = $null
$script:LatestQuickDiagnosisReport = $null
$script:QuickLastDiagnosisLabel = $null
$script:QuickDiagnosisProcess = $null
$script:QuickDiagnosisTimer = $null
$script:LatestComputerProfileCache = $null
$script:LatestComputerProfileCacheTime = [datetime]::MinValue
$script:LogLines = New-Object System.Collections.ArrayList
$script:QuickOutputTimer = $null
$script:QuickOutputProcess = $null
$script:QuickOutputFiles = $null
$script:ChocoDownloadUpgradeAttempted = $false
$script:PublicIPProcess = $null
$script:PublicIPTimer = $null
$script:PublicIPStartedAt = $null
$script:PublicIPQuiet = $false
$script:PublicIPOutputFile = $null
$script:PublicIPScriptFile = $null
$script:ChocoActionJob = $null
$script:ChocoActionTimer = $null
$script:ChocoActionSession = $null
$script:ChocoActionName = ""
$script:ChocoActionPackage = ""
$script:WUPendingGrid = $null
$script:WUInstalledGrid = $null
$script:WUHistoryGrid = $null
$script:WUStatusLabel = $null
$script:WUPendingUpdates = @()
$script:WUInstalledUpdates = @()
$script:WUHistory = @()
$script:WUActionProcess = $null
$script:WUActionTimer = $null
$script:WUActionSession = $null
$script:PsExecProcess = $null
$script:PsExecTimer = $null
$script:PsExecFiles = $null
$script:RootLayout = $null
$script:HeaderPanel = $null
$script:HeaderSummaryPanel = $null
$script:HeaderToolsPanel = $null
$script:HeaderTitleLabel = $null
$script:HeaderSubtitleLabel = $null
$script:AdminStatusLabel = $null
$script:SettingsGearButton = $null
$script:HelpButton = $null
$script:PublicIPRefreshButton = $null
$script:GUITheme = @{
    Header      = [System.Drawing.Color]::FromArgb(22,96,168)
    HeaderPanel = [System.Drawing.Color]::FromArgb(22,96,168)
    HeaderMuted = [System.Drawing.Color]::FromArgb(221,239,255)
    Accent      = [System.Drawing.Color]::FromArgb(36,136,225)
    AccentDark  = [System.Drawing.Color]::FromArgb(18,91,165)
    AccentSoft  = [System.Drawing.Color]::FromArgb(229,243,255)
    Page        = [System.Drawing.Color]::FromArgb(250,252,255)
    Shell       = [System.Drawing.Color]::FromArgb(241,247,252)
    Strip       = [System.Drawing.Color]::FromArgb(232,243,252)
    Text        = [System.Drawing.Color]::FromArgb(31,45,61)
    MutedText   = [System.Drawing.Color]::FromArgb(82,96,112)
    Border      = [System.Drawing.Color]::FromArgb(184,200,214)
    Success     = [System.Drawing.Color]::FromArgb(40,150,95)
    Warning     = [System.Drawing.Color]::FromArgb(220,160,45)
    Danger      = [System.Drawing.Color]::FromArgb(205,75,65)
    Disabled    = [System.Drawing.Color]::FromArgb(213,221,229)
    LogBack     = [System.Drawing.Color]::FromArgb(20,31,44)
    LogFore     = [System.Drawing.Color]::FromArgb(224,235,242)
}

function Get-GUIColorThemeNames {
    return @("Bright Blue","Ocean Teal","Clean Slate","Warm Purple","Fresh Mint","Solar Blue","Soft Graphite","Custom Theme")
}

function ConvertTo-GUIColorHex {
    param([System.Drawing.Color]$Color)

    return "#{0:X2}{1:X2}{2:X2}" -f $Color.R,$Color.G,$Color.B
}

function Get-GUIThemeColorKeys {
    return @(
        "Header",
        "HeaderPanel",
        "HeaderMuted",
        "Accent",
        "AccentDark",
        "AccentSoft",
        "Page",
        "Shell",
        "Strip",
        "Text",
        "MutedText",
        "Border",
        "Success",
        "Warning",
        "Danger",
        "Disabled",
        "LogBack",
        "LogFore"
    )
}

function Get-GUIThemeColorDisplayName {
    param([string]$Key)

    switch($Key){
        "Header" { "Main header background" }
        "HeaderPanel" { "Header computer-info panel" }
        "HeaderMuted" { "Header labels/subtitle text" }
        "Accent" { "Active tab and primary buttons" }
        "AccentDark" { "Header Help/Settings buttons and dark button hover" }
        "AccentSoft" { "Inactive tab and soft button background" }
        "Page" { "Tool page background" }
        "Shell" { "Window outer background" }
        "Strip" { "Tab area background" }
        "Text" { "Main text" }
        "MutedText" { "Secondary and hint text" }
        "Border" { "Group box, tab, and table borders" }
        "Success" { "Healthy status light/text" }
        "Warning" { "Review/pending status light/text" }
        "Danger" { "Critical status and repair warning" }
        "Disabled" { "Disabled controls" }
        "LogBack" { "Live log background" }
        "LogFore" { "Live log text" }
        default { $Key }
    }
}

function ConvertFrom-GUIColorHex {
    param(
        [string]$Hex,
        [System.Drawing.Color]$Fallback
    )

    try {
        if($Hex -match '^#[0-9A-Fa-f]{6}$'){
            return [System.Drawing.ColorTranslator]::FromHtml($Hex)
        }
    }
    catch {}

    return $Fallback
}

function New-GUIColorFromBlend {
    param(
        [System.Drawing.Color]$A,
        [System.Drawing.Color]$B,
        [double]$BWeight = 0.5
    )

    $aWeight = 1 - $BWeight
    return [System.Drawing.Color]::FromArgb(
        [Math]::Min(255,[Math]::Max(0,[int](($A.R * $aWeight) + ($B.R * $BWeight)))),
        [Math]::Min(255,[Math]::Max(0,[int](($A.G * $aWeight) + ($B.G * $BWeight)))),
        [Math]::Min(255,[Math]::Max(0,[int](($A.B * $aWeight) + ($B.B * $BWeight))))
    )
}

function ConvertTo-GUICustomThemeSettings {
    param([hashtable]$Theme)

    $settings = [ordered]@{}
    foreach($key in (Get-GUIThemeColorKeys)){
        if($Theme.ContainsKey($key) -and $Theme[$key] -is [System.Drawing.Color]){
            $settings[$key] = ConvertTo-GUIColorHex $Theme[$key]
        }
    }

    return [pscustomobject]$settings
}

function New-GUICustomThemeFromCoreColors {
    param(
        [System.Drawing.Color]$Header,
        [System.Drawing.Color]$Accent,
        [System.Drawing.Color]$Page,
        [System.Drawing.Color]$Text,
        [System.Drawing.Color]$LogBack
    )

    $white = [System.Drawing.Color]::White
    $black = [System.Drawing.Color]::Black

    return @{
        Header      = $Header
        HeaderPanel = New-GUIColorFromBlend -A $Header -B $white -BWeight 0.10
        HeaderMuted = New-GUIColorFromBlend -A $Header -B $white -BWeight 0.82
        Accent      = $Accent
        AccentDark  = New-GUIColorFromBlend -A $Accent -B $black -BWeight 0.25
        AccentSoft  = New-GUIColorFromBlend -A $Accent -B $white -BWeight 0.86
        Page        = $Page
        Shell       = New-GUIColorFromBlend -A $Page -B $Accent -BWeight 0.05
        Strip       = New-GUIColorFromBlend -A $Page -B $Accent -BWeight 0.10
        Text        = $Text
        MutedText   = New-GUIColorFromBlend -A $Text -B $Page -BWeight 0.35
        Border      = New-GUIColorFromBlend -A $Text -B $Page -BWeight 0.72
        Success     = [System.Drawing.Color]::FromArgb(40,150,95)
        Warning     = [System.Drawing.Color]::FromArgb(220,160,45)
        Danger      = [System.Drawing.Color]::FromArgb(205,75,65)
        Disabled    = New-GUIColorFromBlend -A $Text -B $Page -BWeight 0.82
        LogBack     = $LogBack
        LogFore     = New-GUIColorFromBlend -A $LogBack -B $white -BWeight 0.88
    }
}

function Get-GUICustomTheme {
    $base = Get-GUIColorTheme -Name "Bright Blue"
    $source = $null

    if($script:PendingCustomTheme){
        $source = $script:PendingCustomTheme
    }
    elseif($script:GuiSettings -and $script:GuiSettings.PSObject.Properties.Name -contains "customTheme"){
        $source = $script:GuiSettings.customTheme
    }

    if(!$source){
        return $base
    }

    $header = ConvertFrom-GUIColorHex -Hex $source.Header -Fallback $base.Header
    $accent = ConvertFrom-GUIColorHex -Hex $source.Accent -Fallback $base.Accent
    $page = ConvertFrom-GUIColorHex -Hex $source.Page -Fallback $base.Page
    $text = ConvertFrom-GUIColorHex -Hex $source.Text -Fallback $base.Text
    $logBack = ConvertFrom-GUIColorHex -Hex $source.LogBack -Fallback $base.LogBack

    $theme = New-GUICustomThemeFromCoreColors -Header $header -Accent $accent -Page $page -Text $text -LogBack $logBack

    foreach($key in (Get-GUIThemeColorKeys)){
        if($source.PSObject.Properties.Name -contains $key){
            $theme[$key] = ConvertFrom-GUIColorHex -Hex $source.$key -Fallback $theme[$key]
        }
    }

    return $theme
}

function Show-GUIColorPicker {
    param(
        [string]$Title,
        [System.Drawing.Color]$InitialColor
    )

    $dialog = New-Object System.Windows.Forms.ColorDialog
    $dialog.FullOpen = $true
    $dialog.AnyColor = $true
    $dialog.SolidColorOnly = $false
    $dialog.Color = $InitialColor

    $result = $dialog.ShowDialog()
    if($result -eq [System.Windows.Forms.DialogResult]::OK){
        return $dialog.Color
    }

    return $null
}

function Invoke-GUICustomThemePicker {
    $current = Get-GUICustomTheme
    $originalTheme = @{}
    foreach($key in (Get-GUIThemeColorKeys)){
        $originalTheme[$key] = $script:GUITheme[$key]
    }

    $working = @{}
    foreach($key in (Get-GUIThemeColorKeys)){
        $working[$key] = $current[$key]
    }

    $editor = New-Object System.Windows.Forms.Form
    $editor.Text = "Custom Theme Builder"
    $editor.StartPosition = "CenterParent"
    $editor.Size = New-Object System.Drawing.Size(860,650)
    $editor.MinimumSize = New-Object System.Drawing.Size(760,560)
    $editor.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9.5)
    $editor.BackColor = [System.Drawing.Color]::FromArgb(247,250,253)

    $root = New-Object System.Windows.Forms.TableLayoutPanel
    $root.Dock = "Fill"
    $root.ColumnCount = 2
    $root.RowCount = 2
    $root.Padding = New-Object System.Windows.Forms.Padding(14)
    $root.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,55))) | Out-Null
    $root.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,45))) | Out-Null
    $root.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $root.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,52))) | Out-Null
    $editor.Controls.Add($root)

    $scroll = New-Object System.Windows.Forms.Panel
    $scroll.Dock = "Fill"
    $scroll.AutoScroll = $true
    $scroll.BackColor = [System.Drawing.Color]::White
    $scroll.Padding = New-Object System.Windows.Forms.Padding(10)
    $root.Controls.Add($scroll,0,0)

    $colorTable = New-Object System.Windows.Forms.TableLayoutPanel
    $colorTable.Dock = "Top"
    $colorTable.AutoSize = $true
    $colorTable.ColumnCount = 3
    $colorTable.RowCount = 0
    $colorTable.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,54))) | Out-Null
    $colorTable.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,96))) | Out-Null
    $colorTable.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,82))) | Out-Null
    $scroll.Controls.Add($colorTable)

    $preview = New-Object System.Windows.Forms.Panel
    $preview.Dock = "Fill"
    $preview.BackColor = [System.Drawing.Color]::White
    $preview.Padding = New-Object System.Windows.Forms.Padding(10)
    $root.Controls.Add($preview,1,0)

    $previewLayout = New-Object System.Windows.Forms.TableLayoutPanel
    $previewLayout.Dock = "Fill"
    $previewLayout.RowCount = 6
    $previewLayout.ColumnCount = 1
    $previewLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,82))) | Out-Null
    $previewLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,56))) | Out-Null
    $previewLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,78))) | Out-Null
    $previewLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,80))) | Out-Null
    $previewLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $previewLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,36))) | Out-Null
    $preview.Controls.Add($previewLayout)

    $previewHeader = New-Object System.Windows.Forms.Panel
    $previewHeader.Dock = "Fill"
    $previewLayout.Controls.Add($previewHeader,0,0)

    $previewTitle = New-Object System.Windows.Forms.Label
    $previewTitle.Text = "Network Toolkit"
    $previewTitle.Location = New-Object System.Drawing.Point(14,12)
    $previewTitle.Size = New-Object System.Drawing.Size(210,28)
    $previewTitle.Font = New-Object System.Drawing.Font("Segoe UI Semilight",16,[System.Drawing.FontStyle]::Bold)
    $previewHeader.Controls.Add($previewTitle)

    $previewSubtitle = New-Object System.Windows.Forms.Label
    $previewSubtitle.Text = "Portable technician console"
    $previewSubtitle.Location = New-Object System.Drawing.Point(16,44)
    $previewSubtitle.Size = New-Object System.Drawing.Size(210,22)
    $previewHeader.Controls.Add($previewSubtitle)

    $previewStatus = New-Object System.Windows.Forms.Label
    $previewStatus.Text = "Running elevated"
    $previewStatus.Anchor = "Top,Right"
    $previewStatus.Location = New-Object System.Drawing.Point(214,20)
    $previewStatus.Size = New-Object System.Drawing.Size(128,24)
    $previewStatus.TextAlign = "MiddleRight"
    $previewHeader.Controls.Add($previewStatus)

    $previewStrip = New-Object System.Windows.Forms.FlowLayoutPanel
    $previewStrip.Dock = "Fill"
    $previewStrip.Padding = New-Object System.Windows.Forms.Padding(5,9,5,5)
    $previewLayout.Controls.Add($previewStrip,0,1)

    $previewActiveTab = New-Object System.Windows.Forms.Button
    $previewActiveTab.Text = "Quick Diagnosis"
    $previewActiveTab.Size = New-Object System.Drawing.Size(132,30)
    $previewStrip.Controls.Add($previewActiveTab)

    $previewTab = New-Object System.Windows.Forms.Button
    $previewTab.Text = "Network"
    $previewTab.Size = New-Object System.Drawing.Size(118,30)
    $previewStrip.Controls.Add($previewTab)

    $previewBody = New-Object System.Windows.Forms.Panel
    $previewBody.Dock = "Fill"
    $previewBody.Padding = New-Object System.Windows.Forms.Padding(12)
    $previewLayout.Controls.Add($previewBody,0,2)

    $previewLabel = New-Object System.Windows.Forms.Label
    $previewLabel.Text = "Preview text and normal page background"
    $previewLabel.Location = New-Object System.Drawing.Point(12,12)
    $previewLabel.Size = New-Object System.Drawing.Size(300,24)
    $previewBody.Controls.Add($previewLabel)

    $previewPrimary = New-Object System.Windows.Forms.Button
    $previewPrimary.Text = "Primary Button"
    $previewPrimary.Location = New-Object System.Drawing.Point(12,42)
    $previewPrimary.Size = New-Object System.Drawing.Size(130,30)
    $previewBody.Controls.Add($previewPrimary)

    $previewSoft = New-Object System.Windows.Forms.Button
    $previewSoft.Text = "Soft Button"
    $previewSoft.Location = New-Object System.Drawing.Point(152,42)
    $previewSoft.Size = New-Object System.Drawing.Size(120,30)
    $previewBody.Controls.Add($previewSoft)

    $previewStates = New-Object System.Windows.Forms.FlowLayoutPanel
    $previewStates.Dock = "Fill"
    $previewStates.Padding = New-Object System.Windows.Forms.Padding(6,8,6,6)
    $previewLayout.Controls.Add($previewStates,0,3)

    $stateOk = New-Object System.Windows.Forms.Label
    $stateOk.Text = "Healthy"
    $stateOk.AutoSize = $false
    $stateOk.Size = New-Object System.Drawing.Size(90,26)
    $stateOk.TextAlign = "MiddleCenter"
    $previewStates.Controls.Add($stateOk)

    $stateWarn = New-Object System.Windows.Forms.Label
    $stateWarn.Text = "Review"
    $stateWarn.AutoSize = $false
    $stateWarn.Size = New-Object System.Drawing.Size(90,26)
    $stateWarn.TextAlign = "MiddleCenter"
    $previewStates.Controls.Add($stateWarn)

    $stateBad = New-Object System.Windows.Forms.Label
    $stateBad.Text = "Critical"
    $stateBad.AutoSize = $false
    $stateBad.Size = New-Object System.Drawing.Size(90,26)
    $stateBad.TextAlign = "MiddleCenter"
    $previewStates.Controls.Add($stateBad)

    $previewLog = New-Object System.Windows.Forms.TextBox
    $previewLog.Dock = "Fill"
    $previewLog.Multiline = $true
    $previewLog.ReadOnly = $true
    $previewLog.Text = "[12:00:00] Live log preview`r`n[12:00:01] Tool completed successfully"
    $previewLog.Font = New-Object System.Drawing.Font("Consolas",9)
    $previewLayout.Controls.Add($previewLog,0,4)

    $previewFooter = New-Object System.Windows.Forms.Label
    $previewFooter.Text = "Changes preview live. Click Save Theme when it looks right."
    $previewFooter.Dock = "Fill"
    $previewFooter.TextAlign = "MiddleLeft"
    $previewLayout.Controls.Add($previewFooter,0,5)

    $swatches = @{}
    $hexLabels = @{}

    $applyPreview = {
        $theme = @{}
        foreach($key in (Get-GUIThemeColorKeys)){
            $theme[$key] = $working[$key]
        }

        $script:PendingCustomTheme = ConvertTo-GUICustomThemeSettings $theme
        $script:GUITheme = $theme
        Apply-GUIThemeRuntime

        $editor.BackColor = $theme.Shell
        $scroll.BackColor = $theme.Page
        $colorTable.BackColor = $theme.Page
        $preview.BackColor = $theme.Shell
        $previewHeader.BackColor = $theme.Header
        $previewTitle.ForeColor = [System.Drawing.Color]::White
        $previewSubtitle.ForeColor = $theme.HeaderMuted
        $previewStatus.ForeColor = $theme.Success
        $previewStrip.BackColor = $theme.Strip
        $previewActiveTab.BackColor = $theme.Accent
        $previewActiveTab.ForeColor = [System.Drawing.Color]::White
        $previewTab.BackColor = $theme.Page
        $previewTab.ForeColor = $theme.Text
        $previewBody.BackColor = $theme.Page
        $previewLabel.ForeColor = $theme.Text
        $previewPrimary.BackColor = $theme.Accent
        $previewPrimary.ForeColor = [System.Drawing.Color]::White
        $previewSoft.BackColor = $theme.AccentSoft
        $previewSoft.ForeColor = $theme.Text
        $previewStates.BackColor = $theme.Page
        $stateOk.BackColor = $theme.Success
        $stateWarn.BackColor = $theme.Warning
        $stateBad.BackColor = $theme.Danger
        foreach($state in @($stateOk,$stateWarn,$stateBad)){ $state.ForeColor = [System.Drawing.Color]::White }
        $previewLog.BackColor = $theme.LogBack
        $previewLog.ForeColor = $theme.LogFore
        $previewFooter.ForeColor = $theme.MutedText
    }

    $row = 0
    foreach($key in (Get-GUIThemeColorKeys)){
        $colorTable.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,34))) | Out-Null

        $label = New-Object System.Windows.Forms.Label
        $label.Text = Get-GUIThemeColorDisplayName -Key $key
        $label.Dock = "Fill"
        $label.TextAlign = "MiddleLeft"
        $label.ForeColor = $current.Text
        $colorTable.Controls.Add($label,0,$row)

        $swatch = New-Object System.Windows.Forms.Button
        $swatch.Text = ""
        $swatch.Tag = $key
        $swatch.Dock = "Fill"
        $swatch.Margin = New-Object System.Windows.Forms.Padding(4)
        $swatch.BackColor = $working[$key]
        $swatch.FlatStyle = "Flat"
        $swatch.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(170,180,190)
        $swatch.Add_Click({
            param($sender,$eventArgs)
            $themeKey = [string]$sender.Tag
            $picked = Show-GUIColorPicker -Title (Get-GUIThemeColorDisplayName -Key $themeKey) -InitialColor $working[$themeKey]
            if($picked){
                $working[$themeKey] = $picked
                $sender.BackColor = $picked
                if($hexLabels.ContainsKey($themeKey)){
                    $hexLabels[$themeKey].Text = ConvertTo-GUIColorHex $picked
                }
                & $applyPreview
            }
        })
        $colorTable.Controls.Add($swatch,1,$row)
        $swatches[$key] = $swatch

        $hex = New-Object System.Windows.Forms.Label
        $hex.Text = ConvertTo-GUIColorHex $working[$key]
        $hex.Dock = "Fill"
        $hex.TextAlign = "MiddleLeft"
        $hex.Font = New-Object System.Drawing.Font("Consolas",8.5)
        $hex.ForeColor = $current.MutedText
        $colorTable.Controls.Add($hex,2,$row)
        $hexLabels[$key] = $hex

        $row++
    }

    $buttons = New-Object System.Windows.Forms.FlowLayoutPanel
    $buttons.Dock = "Fill"
    $buttons.FlowDirection = "RightToLeft"
    $buttons.Padding = New-Object System.Windows.Forms.Padding(0,8,0,0)
    $root.Controls.Add($buttons,0,1)
    $root.SetColumnSpan($buttons,2)

    $save = New-GUIButton "Save Theme" { }
    $save.Width = 130
    $save.Add_Click({ $editor.DialogResult = [System.Windows.Forms.DialogResult]::OK; $editor.Close() })
    $buttons.Controls.Add($save) | Out-Null

    $cancel = New-GUIButton "Cancel" { }
    $cancel.Width = 110
    $cancel.Add_Click({ $editor.DialogResult = [System.Windows.Forms.DialogResult]::Cancel; $editor.Close() })
    $buttons.Controls.Add($cancel) | Out-Null

    $reset = New-GUIButton "Start From Bright Blue" { }
    $reset.Width = 170
    $reset.Add_Click({
        $base = Get-GUIColorTheme -Name "Bright Blue"
        foreach($key in (Get-GUIThemeColorKeys)){
            $working[$key] = $base[$key]
            if($swatches.ContainsKey($key)){ $swatches[$key].BackColor = $working[$key] }
            if($hexLabels.ContainsKey($key)){ $hexLabels[$key].Text = ConvertTo-GUIColorHex $working[$key] }
        }
        & $applyPreview
    })
    $buttons.Controls.Add($reset) | Out-Null

    & $applyPreview

    $result = if($script:Form -and !$script:Form.IsDisposed){
        $editor.ShowDialog($script:Form)
    }
    else{
        $editor.ShowDialog()
    }

    if($result -eq [System.Windows.Forms.DialogResult]::OK){
        return ConvertTo-GUICustomThemeSettings $working
    }

    $script:PendingCustomTheme = $null
    $script:GUITheme = $originalTheme
    Apply-GUIThemeRuntime
    return $null
}

function Get-GUIColorTheme {
    param([string]$Name)

    if($Name -eq "Custom Theme"){
        return Get-GUICustomTheme
    }

    switch($Name){
        "Ocean Teal" {
            return @{
                Header      = [System.Drawing.Color]::FromArgb(14,111,122)
                HeaderPanel = [System.Drawing.Color]::FromArgb(19,127,139)
                HeaderMuted = [System.Drawing.Color]::FromArgb(215,247,248)
                Accent      = [System.Drawing.Color]::FromArgb(24,157,169)
                AccentDark  = [System.Drawing.Color]::FromArgb(11,99,108)
                AccentSoft  = [System.Drawing.Color]::FromArgb(226,249,250)
                Page        = [System.Drawing.Color]::FromArgb(250,254,254)
                Shell       = [System.Drawing.Color]::FromArgb(240,250,251)
                Strip       = [System.Drawing.Color]::FromArgb(225,246,248)
                Text        = [System.Drawing.Color]::FromArgb(28,47,56)
                MutedText   = [System.Drawing.Color]::FromArgb(78,98,108)
                Border      = [System.Drawing.Color]::FromArgb(176,207,213)
                Success     = [System.Drawing.Color]::FromArgb(37,151,105)
                Warning     = [System.Drawing.Color]::FromArgb(218,157,43)
                Danger      = [System.Drawing.Color]::FromArgb(203,74,66)
                Disabled    = [System.Drawing.Color]::FromArgb(214,225,229)
                LogBack     = [System.Drawing.Color]::FromArgb(18,35,42)
                LogFore     = [System.Drawing.Color]::FromArgb(226,241,242)
            }
        }
        "Clean Slate" {
            return @{
                Header      = [System.Drawing.Color]::FromArgb(54,76,112)
                HeaderPanel = [System.Drawing.Color]::FromArgb(65,91,132)
                HeaderMuted = [System.Drawing.Color]::FromArgb(224,234,248)
                Accent      = [System.Drawing.Color]::FromArgb(91,132,190)
                AccentDark  = [System.Drawing.Color]::FromArgb(47,73,112)
                AccentSoft  = [System.Drawing.Color]::FromArgb(233,241,252)
                Page        = [System.Drawing.Color]::FromArgb(251,252,255)
                Shell       = [System.Drawing.Color]::FromArgb(243,247,252)
                Strip       = [System.Drawing.Color]::FromArgb(232,240,249)
                Text        = [System.Drawing.Color]::FromArgb(32,43,58)
                MutedText   = [System.Drawing.Color]::FromArgb(84,98,116)
                Border      = [System.Drawing.Color]::FromArgb(185,199,216)
                Success     = [System.Drawing.Color]::FromArgb(45,147,99)
                Warning     = [System.Drawing.Color]::FromArgb(212,150,40)
                Danger      = [System.Drawing.Color]::FromArgb(198,70,68)
                Disabled    = [System.Drawing.Color]::FromArgb(214,222,231)
                LogBack     = [System.Drawing.Color]::FromArgb(22,30,42)
                LogFore     = [System.Drawing.Color]::FromArgb(226,235,244)
            }
        }
        "Warm Purple" {
            return @{
                Header      = [System.Drawing.Color]::FromArgb(92,67,151)
                HeaderPanel = [System.Drawing.Color]::FromArgb(105,78,169)
                HeaderMuted = [System.Drawing.Color]::FromArgb(239,232,255)
                Accent      = [System.Drawing.Color]::FromArgb(133,92,210)
                AccentDark  = [System.Drawing.Color]::FromArgb(79,57,135)
                AccentSoft  = [System.Drawing.Color]::FromArgb(244,239,255)
                Page        = [System.Drawing.Color]::FromArgb(253,251,255)
                Shell       = [System.Drawing.Color]::FromArgb(248,244,255)
                Strip       = [System.Drawing.Color]::FromArgb(239,232,253)
                Text        = [System.Drawing.Color]::FromArgb(45,38,62)
                MutedText   = [System.Drawing.Color]::FromArgb(92,82,112)
                Border      = [System.Drawing.Color]::FromArgb(203,190,225)
                Success     = [System.Drawing.Color]::FromArgb(45,146,103)
                Warning     = [System.Drawing.Color]::FromArgb(218,158,42)
                Danger      = [System.Drawing.Color]::FromArgb(202,73,76)
                Disabled    = [System.Drawing.Color]::FromArgb(224,218,233)
                LogBack     = [System.Drawing.Color]::FromArgb(32,26,45)
                LogFore     = [System.Drawing.Color]::FromArgb(239,233,248)
            }
        }
        "Fresh Mint" {
            return @{
                Header      = [System.Drawing.Color]::FromArgb(18,116,104)
                HeaderPanel = [System.Drawing.Color]::FromArgb(27,139,124)
                HeaderMuted = [System.Drawing.Color]::FromArgb(226,255,247)
                Accent      = [System.Drawing.Color]::FromArgb(39,176,146)
                AccentDark  = [System.Drawing.Color]::FromArgb(13,93,84)
                AccentSoft  = [System.Drawing.Color]::FromArgb(226,250,244)
                Page        = [System.Drawing.Color]::FromArgb(252,255,253)
                Shell       = [System.Drawing.Color]::FromArgb(240,252,248)
                Strip       = [System.Drawing.Color]::FromArgb(226,248,242)
                Text        = [System.Drawing.Color]::FromArgb(25,50,49)
                MutedText   = [System.Drawing.Color]::FromArgb(73,104,100)
                Border      = [System.Drawing.Color]::FromArgb(174,215,207)
                Success     = [System.Drawing.Color]::FromArgb(28,145,96)
                Warning     = [System.Drawing.Color]::FromArgb(222,157,42)
                Danger      = [System.Drawing.Color]::FromArgb(204,70,67)
                Disabled    = [System.Drawing.Color]::FromArgb(216,230,226)
                LogBack     = [System.Drawing.Color]::FromArgb(20,38,38)
                LogFore     = [System.Drawing.Color]::FromArgb(227,247,243)
            }
        }
        "Solar Blue" {
            return @{
                Header      = [System.Drawing.Color]::FromArgb(16,92,174)
                HeaderPanel = [System.Drawing.Color]::FromArgb(27,116,205)
                HeaderMuted = [System.Drawing.Color]::FromArgb(232,246,255)
                Accent      = [System.Drawing.Color]::FromArgb(33,151,231)
                AccentDark  = [System.Drawing.Color]::FromArgb(13,76,148)
                AccentSoft  = [System.Drawing.Color]::FromArgb(229,246,255)
                Page        = [System.Drawing.Color]::FromArgb(253,254,255)
                Shell       = [System.Drawing.Color]::FromArgb(239,248,255)
                Strip       = [System.Drawing.Color]::FromArgb(225,243,255)
                Text        = [System.Drawing.Color]::FromArgb(25,43,62)
                MutedText   = [System.Drawing.Color]::FromArgb(74,94,118)
                Border      = [System.Drawing.Color]::FromArgb(170,205,229)
                Success     = [System.Drawing.Color]::FromArgb(40,151,103)
                Warning     = [System.Drawing.Color]::FromArgb(225,154,35)
                Danger      = [System.Drawing.Color]::FromArgb(205,68,72)
                Disabled    = [System.Drawing.Color]::FromArgb(215,228,238)
                LogBack     = [System.Drawing.Color]::FromArgb(18,33,51)
                LogFore     = [System.Drawing.Color]::FromArgb(228,241,252)
            }
        }
        "Soft Graphite" {
            return @{
                Header      = [System.Drawing.Color]::FromArgb(52,67,78)
                HeaderPanel = [System.Drawing.Color]::FromArgb(67,87,101)
                HeaderMuted = [System.Drawing.Color]::FromArgb(235,243,246)
                Accent      = [System.Drawing.Color]::FromArgb(78,148,178)
                AccentDark  = [System.Drawing.Color]::FromArgb(42,92,114)
                AccentSoft  = [System.Drawing.Color]::FromArgb(232,244,249)
                Page        = [System.Drawing.Color]::FromArgb(253,253,252)
                Shell       = [System.Drawing.Color]::FromArgb(244,248,249)
                Strip       = [System.Drawing.Color]::FromArgb(233,242,246)
                Text        = [System.Drawing.Color]::FromArgb(34,43,49)
                MutedText   = [System.Drawing.Color]::FromArgb(82,96,105)
                Border      = [System.Drawing.Color]::FromArgb(187,203,211)
                Success     = [System.Drawing.Color]::FromArgb(45,145,103)
                Warning     = [System.Drawing.Color]::FromArgb(215,151,39)
                Danger      = [System.Drawing.Color]::FromArgb(198,73,72)
                Disabled    = [System.Drawing.Color]::FromArgb(218,225,229)
                LogBack     = [System.Drawing.Color]::FromArgb(24,31,36)
                LogFore     = [System.Drawing.Color]::FromArgb(232,239,242)
            }
        }
        default {
            return @{
                Header      = [System.Drawing.Color]::FromArgb(22,96,168)
                HeaderPanel = [System.Drawing.Color]::FromArgb(22,96,168)
                HeaderMuted = [System.Drawing.Color]::FromArgb(221,239,255)
                Accent      = [System.Drawing.Color]::FromArgb(36,136,225)
                AccentDark  = [System.Drawing.Color]::FromArgb(18,91,165)
                AccentSoft  = [System.Drawing.Color]::FromArgb(229,243,255)
                Page        = [System.Drawing.Color]::FromArgb(250,252,255)
                Shell       = [System.Drawing.Color]::FromArgb(241,247,252)
                Strip       = [System.Drawing.Color]::FromArgb(232,243,252)
                Text        = [System.Drawing.Color]::FromArgb(31,45,61)
                MutedText   = [System.Drawing.Color]::FromArgb(82,96,112)
                Border      = [System.Drawing.Color]::FromArgb(184,200,214)
                Success     = [System.Drawing.Color]::FromArgb(40,150,95)
                Warning     = [System.Drawing.Color]::FromArgb(220,160,45)
                Danger      = [System.Drawing.Color]::FromArgb(205,75,65)
                Disabled    = [System.Drawing.Color]::FromArgb(213,221,229)
                LogBack     = [System.Drawing.Color]::FromArgb(20,31,44)
                LogFore     = [System.Drawing.Color]::FromArgb(224,235,242)
            }
        }
    }
}

function Set-GUIColorTheme {
    param([string]$Name)

    if((Get-GUIColorThemeNames) -notcontains $Name){
        $Name = "Bright Blue"
    }

    $script:GUITheme = Get-GUIColorTheme -Name $Name
}

function New-GUIRoundedRegion {
    param(
        [int]$Width,
        [int]$Height,
        [int]$Radius = 8
    )

    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $diameter = [Math]::Max(2,($Radius * 2))
    $rect = New-Object System.Drawing.Rectangle(0,0,[Math]::Max(1,$Width),[Math]::Max(1,$Height))

    if($diameter -ge $rect.Width -or $diameter -ge $rect.Height){
        $path.AddEllipse($rect)
    }
    else{
        $path.AddArc($rect.X,$rect.Y,$diameter,$diameter,180,90)
        $path.AddArc(($rect.Right - $diameter - 1),$rect.Y,$diameter,$diameter,270,90)
        $path.AddArc(($rect.Right - $diameter - 1),($rect.Bottom - $diameter - 1),$diameter,$diameter,0,90)
        $path.AddArc($rect.X,($rect.Bottom - $diameter - 1),$diameter,$diameter,90,90)
        $path.CloseFigure()
    }

    return New-Object System.Drawing.Region($path)
}

function Set-GUIRoundedCorners {
    param(
        [System.Windows.Forms.Control]$Control,
        [int]$Radius = 8
    )

    if(!$Control){
        return
    }

    $roundedRadius = $Radius
    $apply = {
        param($sender,$eventArgs)
        if($sender -and !$sender.IsDisposed -and $sender.Width -gt 0 -and $sender.Height -gt 0){
            if($sender.Region){ $sender.Region.Dispose() }

            $path = New-Object System.Drawing.Drawing2D.GraphicsPath
            $diameter = [Math]::Max(2,($roundedRadius * 2))
            $rect = New-Object System.Drawing.Rectangle(0,0,[Math]::Max(1,$sender.Width),[Math]::Max(1,$sender.Height))

            if($diameter -ge $rect.Width -or $diameter -ge $rect.Height){
                $path.AddEllipse($rect)
            }
            else{
                $path.AddArc($rect.X,$rect.Y,$diameter,$diameter,180,90)
                $path.AddArc(($rect.Right - $diameter - 1),$rect.Y,$diameter,$diameter,270,90)
                $path.AddArc(($rect.Right - $diameter - 1),($rect.Bottom - $diameter - 1),$diameter,$diameter,0,90)
                $path.AddArc($rect.X,($rect.Bottom - $diameter - 1),$diameter,$diameter,90,90)
                $path.CloseFigure()
            }

            $sender.Region = New-Object System.Drawing.Region($path)
        }
    }.GetNewClosure()

    $Control.Add_Resize($apply)
    & $apply $Control $null
}

function Set-GUIButtonChrome {
    param(
        [System.Windows.Forms.Button]$Button,
        [switch]$Compact,
        [switch]$Subtle
    )

    if(!$Button){
        return
    }

    $Button.FlatStyle = "Flat"
    $Button.UseVisualStyleBackColor = $false
    $Button.Cursor = [System.Windows.Forms.Cursors]::Hand
    $Button.Font = if($Compact){
        New-Object System.Drawing.Font("Segoe UI",8.5,[System.Drawing.FontStyle]::Bold)
    }
    else{
        New-Object System.Drawing.Font("Segoe UI",9.25,[System.Drawing.FontStyle]::Regular)
    }
    $Button.FlatAppearance.BorderSize = 0
    $Button.FlatAppearance.MouseOverBackColor = if($Subtle){$script:GUITheme.HeaderMuted}else{$script:GUITheme.AccentDark}
    $Button.FlatAppearance.MouseDownBackColor = $script:GUITheme.AccentDark
    $Button.BackColor = if($Subtle){$script:GUITheme.AccentSoft}else{$script:GUITheme.Accent}
    $Button.ForeColor = if($Subtle){$script:GUITheme.Text}else{[System.Drawing.Color]::White}

    Set-GUIRoundedCorners -Control $Button -Radius $(if($Compact){7}else{10})
}

function Set-GUITabButtonChrome {
    param(
        [System.Windows.Forms.Button]$Button,
        [bool]$Selected = $false
    )

    if(!$Button){
        return
    }

    $Button.FlatStyle = "Flat"
    $Button.UseVisualStyleBackColor = $false
    $Button.Cursor = [System.Windows.Forms.Cursors]::Hand
    $Button.Font = New-Object System.Drawing.Font("Segoe UI",9,[System.Drawing.FontStyle]::Regular)
    $Button.FlatAppearance.BorderSize = 1
    $Button.FlatAppearance.BorderColor = if($Selected){$script:GUITheme.AccentDark}else{$script:GUITheme.Border}
    $Button.FlatAppearance.MouseOverBackColor = if($Selected){$script:GUITheme.AccentDark}else{$script:GUITheme.HeaderMuted}
    $Button.FlatAppearance.MouseDownBackColor = $script:GUITheme.AccentDark
    $Button.BackColor = if($Selected){$script:GUITheme.Accent}else{$script:GUITheme.Page}
    $Button.ForeColor = if($Selected){[System.Drawing.Color]::White}else{$script:GUITheme.Text}
    Set-GUIRoundedCorners -Control $Button -Radius 7
}

function Apply-GUIThemeToControl {
    param([System.Windows.Forms.Control]$Control)

    if(!$Control -or $Control.IsDisposed){
        return
    }

    if($Control -eq $script:HeaderPanel -or $Control -eq $script:HeaderSummaryPanel -or $Control -eq $script:HealthStatusLight){
        return
    }

    if($Control -is [System.Windows.Forms.Button]){
        Set-GUIButtonChrome -Button $Control
    }
    elseif($Control -is [System.Windows.Forms.TabPage]){
        $Control.BackColor = $script:GUITheme.Page
    }
    elseif($Control -is [System.Windows.Forms.GroupBox]){
        $Control.BackColor = $script:GUITheme.Page
        $Control.ForeColor = $script:GUITheme.Text
    }
    elseif($Control -is [System.Windows.Forms.Label] -or $Control -is [System.Windows.Forms.CheckBox]){
        $Control.ForeColor = $script:GUITheme.Text
    }
    elseif($Control -is [System.Windows.Forms.TextBox] -or $Control -is [System.Windows.Forms.ComboBox] -or $Control -is [System.Windows.Forms.ListBox]){
        $Control.BackColor = [System.Drawing.Color]::White
        $Control.ForeColor = $script:GUITheme.Text
    }
    elseif($Control -is [System.Windows.Forms.DataGridView]){
        $Control.BackgroundColor = [System.Drawing.Color]::White
        $Control.GridColor = $script:GUITheme.Border
        $Control.ForeColor = $script:GUITheme.Text
    }
    elseif($Control -is [System.Windows.Forms.Panel] -or $Control -is [System.Windows.Forms.TableLayoutPanel] -or $Control -is [System.Windows.Forms.FlowLayoutPanel]){
        $Control.BackColor = $script:GUITheme.Page
    }

    foreach($child in $Control.Controls){
        Apply-GUIThemeToControl -Control $child
    }
}

function Apply-GUIThemeRuntime {
    if($script:Form -and !$script:Form.IsDisposed){
        $script:Form.BackColor = $script:GUITheme.Shell
        Apply-GUIThemeToControl -Control $script:Form
    }

    if($script:RootLayout -and !$script:RootLayout.IsDisposed){
        $script:RootLayout.BackColor = $script:GUITheme.Page
    }

    if($script:HeaderPanel -and !$script:HeaderPanel.IsDisposed){
        $script:HeaderPanel.BackColor = $script:GUITheme.Header
    }

    if($script:HeaderSummaryPanel -and !$script:HeaderSummaryPanel.IsDisposed){
        $script:HeaderSummaryPanel.BackColor = $script:GUITheme.HeaderPanel
    }

    if($script:HeaderToolsPanel -and !$script:HeaderToolsPanel.IsDisposed){
        $script:HeaderToolsPanel.BackColor = $script:GUITheme.HeaderPanel
    }

    if($script:HeaderTitleLabel -and !$script:HeaderTitleLabel.IsDisposed){
        $script:HeaderTitleLabel.ForeColor = [System.Drawing.Color]::White
    }

    if($script:HeaderSubtitleLabel -and !$script:HeaderSubtitleLabel.IsDisposed){
        $script:HeaderSubtitleLabel.ForeColor = $script:GUITheme.HeaderMuted
    }

    if($script:AdminStatusLabel -and !$script:AdminStatusLabel.IsDisposed){
        $script:AdminStatusLabel.ForeColor = if(Test-GUIAdministrator){[System.Drawing.Color]::FromArgb(170,230,205)}else{[System.Drawing.Color]::FromArgb(250,215,135)}
    }

    foreach($headerButton in @($script:SettingsGearButton,$script:HelpButton)){
        if($headerButton -and !$headerButton.IsDisposed){
            $headerButton.BackColor = $script:GUITheme.AccentDark
            $headerButton.ForeColor = [System.Drawing.Color]::White
        }
    }

    foreach($key in @($script:DashboardLabels.Keys)){
        $label = $script:DashboardLabels[$key]
        if($label -and !$label.IsDisposed){
            $label.ForeColor = [System.Drawing.Color]::White
        }
    }

    if($script:PublicIPRefreshButton -and !$script:PublicIPRefreshButton.IsDisposed){
        $script:PublicIPRefreshButton.BackColor = $script:GUITheme.AccentDark
        $script:PublicIPRefreshButton.ForeColor = [System.Drawing.Color]::White
    }

    if($script:StaticTabStrip -and !$script:StaticTabStrip.IsDisposed){
        $script:StaticTabStrip.BackColor = $script:GUITheme.Strip
    }

    if($script:LogBox -and !$script:LogBox.IsDisposed){
        $script:LogBox.BackColor = $script:GUITheme.LogBack
        $script:LogBox.ForeColor = $script:GUITheme.LogFore
    }

    if($script:QuickOutputBox -and !$script:QuickOutputBox.IsDisposed){
        $script:QuickOutputBox.BackColor = $script:GUITheme.LogBack
        $script:QuickOutputBox.ForeColor = $script:GUITheme.LogFore
    }

    if($script:QuickLastDiagnosisLabel -and !$script:QuickLastDiagnosisLabel.IsDisposed){
        $script:QuickLastDiagnosisLabel.ForeColor = $script:GUITheme.MutedText
    }

    Update-GUIComputerHealthLight

    if($script:MainTabs){
        foreach($page in $script:MainTabs.TabPages){
            $page.BackColor = $script:GUITheme.Page
        }
    }

    Update-GUIStaticTabStripSelection
}

function Test-GUIAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Update-GUILiveLogScreen {
    if(!$script:LogBox -or $script:LogBox.IsDisposed){
        return
    }

    try {
        $script:LogBox.Lines = [string[]]$script:LogLines
        $script:LogBox.SelectionStart = $script:LogBox.TextLength
        $script:LogBox.ScrollToCaret()
        $script:LogBox.Refresh()
    }
    catch {
    }
}

function Add-GUILog {
    param([string]$Message)

    $line = "[{0}] {1}" -f (Get-Date -Format "HH:mm:ss"),$Message

    if($null -ne $script:LogLines){
        [void]$script:LogLines.Add($line)

        while($script:LogLines.Count -gt 500){
            $script:LogLines.RemoveAt(0)
        }
    }

    if($script:LogBox -and !$script:LogBox.IsDisposed){
        try {
            $script:LogBox.AppendText($line + [Environment]::NewLine)
            $script:LogBox.SelectionStart = $script:LogBox.TextLength
            $script:LogBox.ScrollToCaret()
            $script:LogBox.Refresh()
        }
        catch {
            Update-GUILiveLogScreen
        }
    }

    if($script:StatusLabel -and !$script:StatusLabel.IsDisposed){
        $script:StatusLabel.Text = $Message
    }

    try {
        [System.Windows.Forms.Application]::DoEvents()
    }
    catch {
    }
}

function Write-GUIToolUsageLog {
    param(
        [string]$Tool,
        [string]$Action,
        [string]$Detail = "",
        [string]$Level = "INFO"
    )

    try {
        $root = Join-Path $CSIPaths.Logs "ToolUsage"
        if(!(Test-Path $root)){
            New-Item -ItemType Directory -Path $root -Force | Out-Null
        }

        $safeTool = if(Get-Command ConvertTo-CSISafeFileName -ErrorAction SilentlyContinue){ ConvertTo-CSISafeFileName $Tool }else{ $Tool -replace '[^A-Za-z0-9._-]+','_' }
        $logPath = Join-Path $root "$safeTool.log"
        $line = "{0}`t{1}`t{2}`t{3}`t{4}" -f (Get-Date -Format "s"),$Level,$Tool,$Action,($Detail -replace "\r?\n"," ")
        Add-Content -Path $logPath -Value $line -Encoding UTF8

        $logItem = Get-Item -LiteralPath $logPath -ErrorAction SilentlyContinue
        if($logItem -and $logItem.Length -gt 65536){
            $recent = Get-Content -Path $logPath -Tail 200 -ErrorAction SilentlyContinue
            Set-Content -Path $logPath -Value $recent -Encoding UTF8
        }
    }
    catch {
    }
}

function Invoke-GUISafely {
    param(
        [string]$Tool,
        [scriptblock]$Action
    )

    try {
        Write-GUIToolUsageLog -Tool $Tool -Action "Start"
        & $Action
        Write-GUIToolUsageLog -Tool $Tool -Action "Completed"
    }
    catch {
        Write-GUIToolUsageLog -Tool $Tool -Action "Failed" -Detail $_.Exception.Message -Level "ERROR"
        Add-GUILog "$Tool failed: $($_.Exception.Message)"
        [System.Windows.Forms.MessageBox]::Show(
            "$Tool failed.`r`n`r`n$($_.Exception.Message)",
            "Network Toolkit",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
    }
}

function Register-GUIExceptionHandlers {
    try {
        [System.Windows.Forms.Application]::SetUnhandledExceptionMode([System.Windows.Forms.UnhandledExceptionMode]::CatchException)
        [System.Windows.Forms.Application]::add_ThreadException({
            param($sender,$eventArgs)
            $message = if($eventArgs.Exception){$eventArgs.Exception.Message}else{"Unknown GUI exception"}
            Add-GUILog "GUI recovered from an unexpected error: $message"
            Write-GUIToolUsageLog -Tool "GUI" -Action "UnhandledThreadException" -Detail $message -Level "ERROR"
            [System.Windows.Forms.MessageBox]::Show(
                "The toolkit caught an unexpected GUI error and kept running.`r`n`r`n$message",
                "Network Toolkit",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            ) | Out-Null
        })
    }
    catch {
        Add-GUILog "Could not register GUI exception handler: $($_.Exception.Message)"
    }
}

function Get-GUIPrivateIPSummary {
    try {
        $addresses = @(
            Get-CimInstance Win32_NetworkAdapterConfiguration -Filter "IPEnabled=True" -ErrorAction Stop |
                ForEach-Object {
                    $ipv4 = @($_.IPAddress | Where-Object { $_ -match "^\d{1,3}(\.\d{1,3}){3}$" })
                    if($ipv4.Count -gt 0){
                        ($ipv4 -join ", ")
                    }
                }
        )

        if($addresses.Count -gt 0){
            return ($addresses -join "  |  ")
        }
    }
    catch {}

    try {
        $addresses = @(
            Get-NetIPConfiguration -ErrorAction Stop |
                Where-Object { $_.IPv4Address -and $_.NetAdapter.Status -eq "Up" } |
                ForEach-Object {
                    ($_.IPv4Address.IPAddress -join ", ")
                }
        )

        if($addresses.Count -gt 0){
            return ($addresses -join "  |  ")
        }
    }
    catch {}

    return "Not detected"
}

function Get-GUIPublicIPSummary {
    try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

    $endpoints = @(
        "https://api.ipify.org",
        "https://checkip.amazonaws.com",
        "https://icanhazip.com",
        "https://ipv4.icanhazip.com",
        "http://ipinfo.io/ip"
    )

    foreach($endpoint in $endpoints){
        try {
            $request = [System.Net.WebRequest]::Create($endpoint)
            $request.Timeout = 5000
            $request.UserAgent = "NetworkToolkit"

            if([System.Net.WebRequest]::DefaultWebProxy){
                $request.Proxy = [System.Net.WebRequest]::DefaultWebProxy
                $request.Proxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
            }

            $response = $request.GetResponse()
            try {
                $reader = New-Object System.IO.StreamReader($response.GetResponseStream())
                $value = $reader.ReadToEnd().Trim()
            }
            finally {
                if($reader){ $reader.Dispose() }
                if($response){ $response.Dispose() }
            }

            if($value -match '^\d{1,3}(\.\d{1,3}){3}$'){
                return $value
            }
        }
        catch {}
    }

    try {
        $response = Invoke-RestMethod -Uri "https://ifconfig.me/ip" -TimeoutSec 5 -ErrorAction Stop

        if($response){
            return ([string]$response).Trim()
        }
    }
    catch {}

    try {
        $lookup = nslookup myip.opendns.com resolver1.opendns.com 2>$null
        $matches = @($lookup | Select-String -Pattern 'Address:\s+(\d{1,3}(\.\d{1,3}){3})')
        if($matches.Count -gt 1){
            return $matches[-1].Matches[0].Groups[1].Value
        }
    }
    catch {}

    return "Unavailable"
}

function Update-GUIPublicIPSummaryAsync {
    param([switch]$Quiet)

    if(!$script:DashboardLabels -or !$script:DashboardLabels.ContainsKey("PublicIP")){
        return
    }

    if($script:PublicIPTimer){
        try {
            $script:PublicIPTimer.Stop()
            $script:PublicIPTimer.Dispose()
        }
        catch {}
        $script:PublicIPTimer = $null
    }

    if($script:PublicIPProcess -and !$script:PublicIPProcess.HasExited){
        try {
            $script:PublicIPProcess.Kill()
        }
        catch {}
        $script:PublicIPProcess = $null
    }

    $script:PublicIPStartedAt = Get-Date
    $script:PublicIPQuiet = [bool]$Quiet

    $label = $script:DashboardLabels["PublicIP"]
    if($label -and !$label.IsDisposed){
        $label.SuspendLayout()
        $label.Text = "Checking..."
        $label.ResumeLayout()
    }

    try {
        $sessionRoot = Join-Path (Get-CSITempOutputRoot) "_PublicIP"
        if(!(Test-Path $sessionRoot)){
            New-Item -ItemType Directory -Path $sessionRoot -Force | Out-Null
        }

        $token = "{0}-{1}" -f (Get-Date -Format "yyyyMMdd-HHmmss-fff"),([guid]::NewGuid().ToString("N").Substring(0,8))
        $script:PublicIPOutputFile = Join-Path $sessionRoot "public-ip-$token.out.txt"
        $script:PublicIPScriptFile = Join-Path $sessionRoot "public-ip-$token.ps1"

        $lookupScript = @'
$ErrorActionPreference = "SilentlyContinue"
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

$endpoints = @(
    "https://api.ipify.org",
    "https://checkip.amazonaws.com",
    "https://icanhazip.com",
    "https://ipv4.icanhazip.com",
    "http://ipinfo.io/ip",
    "https://ifconfig.me/ip"
)

foreach($endpoint in $endpoints){
    try {
        $request = [System.Net.WebRequest]::Create($endpoint)
        $request.Timeout = 5000
        $request.UserAgent = "NetworkToolkit"

        if([System.Net.WebRequest]::DefaultWebProxy){
            $request.Proxy = [System.Net.WebRequest]::DefaultWebProxy
            $request.Proxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
        }

        $response = $request.GetResponse()
        try {
            $reader = New-Object System.IO.StreamReader($response.GetResponseStream())
            $value = $reader.ReadToEnd().Trim()
        }
        finally {
            if($reader){ $reader.Dispose() }
            if($response){ $response.Dispose() }
        }

        if($value -match '^\d{1,3}(\.\d{1,3}){3}$'){
            $value
            exit 0
        }
    }
    catch {}
}

try {
    $lookup = nslookup myip.opendns.com resolver1.opendns.com 2>$null
    $matches = @($lookup | Select-String -Pattern 'Address:\s+(\d{1,3}(\.\d{1,3}){3})')
    if($matches.Count -gt 1){
        $matches[-1].Matches[0].Groups[1].Value
        exit 0
    }
}
catch {}

"Unavailable"
exit 2
'@

        Set-Content -Path $script:PublicIPScriptFile -Value $lookupScript -Encoding UTF8

        $script:PublicIPProcess = Start-Process `
            -FilePath "powershell.exe" `
            -ArgumentList @("-NoProfile","-ExecutionPolicy","Bypass","-File",$script:PublicIPScriptFile) `
            -WindowStyle Hidden `
            -RedirectStandardOutput $script:PublicIPOutputFile `
            -PassThru
    }
    catch {
        if($label -and !$label.IsDisposed){
            $label.Text = "Unavailable"
        }
        if(!$script:PublicIPQuiet){
            Add-GUILog "Public IP lookup failed: $($_.Exception.Message)"
        }
        return
    }

    $script:PublicIPTimer = New-Object System.Windows.Forms.Timer
    $script:PublicIPTimer.Interval = 500
    $script:PublicIPTimer.Add_Tick({
        try {
            if(!$script:PublicIPProcess){
                return
            }

            $startTime = if($script:PublicIPStartedAt -is [datetime]){ $script:PublicIPStartedAt } else { (Get-Date).AddSeconds(-30) }
            $elapsed = New-TimeSpan -Start $startTime -End (Get-Date)
            $timedOut = $elapsed.TotalSeconds -gt 25

            if(!$script:PublicIPProcess.HasExited -and !$timedOut){
                return
            }

            if($timedOut -and !$script:PublicIPProcess.HasExited){
                try { $script:PublicIPProcess.Kill() } catch {}
            }

            $value = "Unavailable"
            if($script:PublicIPOutputFile -and (Test-Path $script:PublicIPOutputFile)){
                $result = @(Get-Content -Path $script:PublicIPOutputFile -ErrorAction SilentlyContinue | Where-Object { $_ -and $_.Trim() })
                if($result.Count -gt 0){
                    $candidate = [string]$result[0]
                    if($candidate -match '^\d{1,3}(\.\d{1,3}){3}$'){
                        $value = $candidate
                    }
                }
            }

            if($script:PublicIPTimer){
                $script:PublicIPTimer.Stop()
                $script:PublicIPTimer.Dispose()
                $script:PublicIPTimer = $null
            }

            $script:PublicIPProcess = $null

            if($script:DashboardLabels -and $script:DashboardLabels.ContainsKey("PublicIP")){
                $ipLabel = $script:DashboardLabels["PublicIP"]
                if($ipLabel -and !$ipLabel.IsDisposed){
                    $ipLabel.SuspendLayout()
                    $ipLabel.Text = $value
                    $ipLabel.ResumeLayout()
                }
            }

            if(!$script:PublicIPQuiet){
                if($timedOut){
                    Add-GUILog "Public IP lookup timed out."
                }
                else{
                    Add-GUILog "Public IP: $value"
                }
            }
        }
        catch {
            try {
                if($script:PublicIPTimer){
                    $script:PublicIPTimer.Stop()
                    $script:PublicIPTimer.Dispose()
                    $script:PublicIPTimer = $null
                }
                if($script:PublicIPProcess -and !$script:PublicIPProcess.HasExited){
                    $script:PublicIPProcess.Kill()
                }
                $script:PublicIPProcess = $null
            }
            catch {}

            if(!$script:PublicIPQuiet){
                Add-GUILog "Public IP refresh failed: $($_.Exception.Message)"
            }
        }
    })
    $script:PublicIPTimer.Start()
}

function Get-GUILatestQuickDiagnosisReport {
    try {
        $reports = @(Get-ChildItem -Path $CSIPaths.Exports -Filter "quick-diagnosis*.html" -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending)
        if($reports.Count -gt 0){
            return $reports[0].FullName
        }
    }
    catch {}

    return $null
}

function Open-GUILatestQuickDiagnosisReport {
    $report = Get-GUILatestQuickDiagnosisReport

    if(!$report){
        [System.Windows.Forms.MessageBox]::Show(
            "No Quick Diagnosis HTML report was found yet.",
            "Quick Diagnosis Report",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null
        return
    }

    Start-CSIToolProcess -FilePath $report | Out-Null
    Add-GUILog "Opened Quick Diagnosis report: $report"
}

function Get-GUILastQuickDiagnosisInfo {
    $computerName = if($env:COMPUTERNAME){$env:COMPUTERNAME}else{"UnknownComputer"}

    try {
        if(Get-Command Read-CSIComputerState -ErrorAction SilentlyContinue){
            $state = Read-CSIComputerState -ComputerName $computerName
            $capturedAt = ""
            $reportPath = ""

            if($state -is [System.Collections.IDictionary]){
                if($state.Contains("LastQuickDiagnosisAt")){ $capturedAt = [string]$state["LastQuickDiagnosisAt"] }
                if($state.Contains("LastQuickDiagnosisReportPath")){ $reportPath = [string]$state["LastQuickDiagnosisReportPath"] }

                if(!$capturedAt -and $state.Contains("Sections") -and ($state["Sections"] -is [System.Collections.IDictionary]) -and $state["Sections"].Contains("QuickDiagnosis")){
                    $quick = $state["Sections"]["QuickDiagnosis"]
                    if($quick -is [System.Collections.IDictionary] -and $quick.Contains("Data")){
                        $data = $quick["Data"]
                        if($data -is [System.Collections.IDictionary]){
                            if($data.Contains("CapturedAt")){ $capturedAt = [string]$data["CapturedAt"] }
                            if(!$reportPath -and $data.Contains("ReportPath")){ $reportPath = [string]$data["ReportPath"] }
                        }
                    }
                }
            }

            if($capturedAt){
                return [pscustomobject]@{
                    CapturedAt = $capturedAt
                    ReportPath = $reportPath
                }
            }
        }
    }
    catch {}

    $latestReport = Get-GUILatestQuickDiagnosisReport
    if($latestReport -and (Test-Path $latestReport)){
        try {
            $item = Get-Item -Path $latestReport -ErrorAction Stop
            return [pscustomobject]@{
                CapturedAt = $item.LastWriteTime.ToString("s")
                ReportPath = $item.FullName
            }
        }
        catch {}
    }

    return [pscustomobject]@{
        CapturedAt = ""
        ReportPath = ""
    }
}

function Format-GUILastQuickDiagnosisText {
    param([object]$Info)

    if(!$Info -or !$Info.CapturedAt){
        return "Last Quick Diagnosis: not run for this computer yet"
    }

    try {
        $date = [datetime]$Info.CapturedAt
        return ("Last Quick Diagnosis: {0:g}" -f $date)
    }
    catch {
        return "Last Quick Diagnosis: $($Info.CapturedAt)"
    }
}

function Refresh-GUILastQuickDiagnosisLabel {
    if(!$script:QuickLastDiagnosisLabel -or $script:QuickLastDiagnosisLabel.IsDisposed){
        return
    }

    $info = Get-GUILastQuickDiagnosisInfo
    $script:QuickLastDiagnosisLabel.Text = Format-GUILastQuickDiagnosisText -Info $info
}

function ConvertTo-GUIBoolean {
    param(
        [object]$Value,
        [bool]$Default = $false
    )

    if($null -eq $Value){
        return $Default
    }

    if($Value -is [bool]){
        return $Value
    }

    if($Value -is [string]){
        $text = $Value.Trim()
        if($text -match '^(?i:true|yes|y|1)$'){ return $true }
        if($text -match '^(?i:false|no|n|0|none|)$'){ return $false }
        return $Default
    }

    if($Value -is [int] -or $Value -is [long] -or $Value -is [double]){
        return ([double]$Value -ne 0)
    }

    try {
        return [System.Convert]::ToBoolean($Value)
    }
    catch {
        return $Default
    }
}

function Get-GUIComputerHealthSummary {
    param([object]$Profile)

    $level = "Unknown"
    $detail = "Run Quick Diagnosis"
    $color = [System.Drawing.Color]::FromArgb(150,160,165)

    if($Profile){
        $issues = @()
        if($Profile.ServicingHealth -and (ConvertTo-GUIBoolean $Profile.ServicingHealth.FollowUpDismSfc)){ $issues += "DISM/SFC follow-up" }
        if($Profile.PendingReboot -and (ConvertTo-GUIBoolean $Profile.PendingReboot.Pending)){ $issues += "pending reboot" }
        if($Profile.Disks){
            foreach($disk in @($Profile.Disks)){
                if($disk.SizeGB -and $disk.FreeGB){
                    $freePct = [math]::Round((([double]$disk.FreeGB / [double]$disk.SizeGB) * 100),1)
                    if($freePct -lt 10){ $issues += "low disk space" }
                }
            }
        }

        if($issues.Count -eq 0){
            $level = "Healthy"
            $detail = "No major profile issues"
            $color = [System.Drawing.Color]::FromArgb(40,150,95)
        }
        elseif($issues.Count -le 2){
            $level = "Review"
            $detail = ($issues -join ", ")
            $color = [System.Drawing.Color]::FromArgb(225,170,45)
        }
        else{
            $level = "Needs Attention"
            $detail = ($issues -join ", ")
            $color = [System.Drawing.Color]::FromArgb(205,70,55)
        }
    }

    return [pscustomobject]@{
        Level = $level
        Detail = $detail
        Color = $color
        Text = "$level - $detail"
    }
}

function Get-GUIComputerHealthSummaryText {
    param([object]$Profile)

    return (Get-GUIComputerHealthSummary -Profile $Profile).Text
}

function Format-GUIEmptyValue {
    param(
        [object]$Value,
        [string]$Fallback = "Unknown"
    )

    if($null -eq $Value){
        return $Fallback
    }

    $text = [string]$Value
    if([string]::IsNullOrWhiteSpace($text)){
        return $Fallback
    }

    return $text.Trim()
}

function Format-GUIProfileDateTime {
    param(
        [object]$Value,
        [string]$Fallback = "Unknown"
    )

    if($null -eq $Value){
        return $Fallback
    }

    try {
        return ("{0:g}" -f ([datetime]$Value))
    }
    catch {
        return (Format-GUIEmptyValue -Value $Value -Fallback $Fallback)
    }
}

function Get-GUIPrimaryDiskSummary {
    param([object]$Profile)

    if(!$Profile -or !$Profile.Disks){
        return "Unknown"
    }

    $disk = @($Profile.Disks | Sort-Object {
        if($_.DeviceID -eq "C:"){0}else{1}
    }) | Select-Object -First 1

    if(!$disk){
        return "Unknown"
    }

    $name = Format-GUIEmptyValue -Value $disk.DeviceID -Fallback "Disk"
    if($disk.SizeGB -and $disk.FreeGB){
        $pct = if([double]$disk.SizeGB -gt 0){ [math]::Round(([double]$disk.FreeGB / [double]$disk.SizeGB) * 100,0) }else{ 0 }
        return ("{0} {1:N1} GB free of {2:N1} GB ({3}%)" -f $name,[double]$disk.FreeGB,[double]$disk.SizeGB,$pct)
    }

    return $name
}

function Get-GUIPrimaryAdapterSummary {
    param([object]$Profile)

    $adapter = $null
    if($Profile -and $Profile.MACs){
        $adapter = @($Profile.MACs | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1)
    }

    if($adapter){
        $name = Format-GUIEmptyValue -Value $adapter.Name -Fallback "Adapter"
        $speed = Format-GUIEmptyValue -Value $adapter.LinkSpeed -Fallback ""
        if($speed){
            return "$name ($speed)"
        }
        return $name
    }

    $ip = Get-GUIPrivateIPSummary
    if($ip -and $ip -ne "Unavailable"){
        return $ip
    }

    return "Unknown"
}

function Get-GUIQuickDiagnosisSummaryValue {
    $lastQuick = Format-GUILastQuickDiagnosisText -Info (Get-GUILastQuickDiagnosisInfo)
    return ($lastQuick -replace '^Last Quick Diagnosis:\s*','')
}

function Update-GUIComputerHealthLight {
    if(!$script:HealthStatusLight -or !$script:HealthStatusLabel){
        return
    }

    $summary = Get-GUIComputerHealthSummary -Profile (Get-GUILatestComputerProfile)

    $script:HealthStatusLight.BackColor = $summary.Color
    $script:HealthStatusLabel.Text = $summary.Text
}

function Invoke-GUIQuickPing {
    $target = Get-GUIQuickTarget
    if(!$target){
        return
    }

    Start-GUIQuickEmbeddedCommand -Title "Ping $target" -Command ("ping.exe -n 4 " + (ConvertTo-GUICommandToken $target))
}

function Get-GUIQuickTarget {
    $target = if($script:QuickPingBox){$script:QuickPingBox.Text.Trim()}else{""}

    if(!$target){
        Add-GUILog "Enter a target host, IP, or domain first."
        return ""
    }

    return $target
}

function Get-GUIQuickPort {
    $raw = if($script:QuickPortBox){$script:QuickPortBox.Text.Trim()}else{""}

    if(!$raw){
        return $null
    }

    $port = 0
    if(![int]::TryParse($raw,[ref]$port) -or $port -lt 1 -or $port -gt 65535){
        Add-GUILog "Enter a valid TCP port from 1 to 65535."
        return $null
    }

    return $port
}

function Set-GUIQuickOutput {
    param(
        [string]$Title,
        [string]$Text
    )

    if(!$script:QuickOutputBox){
        return
    }

    $stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $script:QuickOutputBox.Text = "[$stamp] $Title`r`n" + ("=" * [Math]::Min(70,[Math]::Max(10,$Title.Length))) + "`r`n`r`n" + $Text.Trim()
    $script:QuickOutputBox.SelectionStart = $script:QuickOutputBox.TextLength
    $script:QuickOutputBox.ScrollToCaret()
}

function Start-GUIQuickEmbeddedCommand {
    param(
        [string]$Title,
        [string]$Command
    )

    if(!$Command){
        return
    }

    if($script:QuickOutputTimer){
        try {
            $script:QuickOutputTimer.Stop()
            $script:QuickOutputTimer.Dispose()
        }
        catch {}
        $script:QuickOutputTimer = $null
    }

    if($script:QuickOutputProcess -and !$script:QuickOutputProcess.HasExited){
        $choice = [System.Windows.Forms.MessageBox]::Show(
            "A quick target check is still running. Stop it and run the new check?",
            "Quick Target Checks",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )

        if($choice -ne [System.Windows.Forms.DialogResult]::Yes){
            Add-GUILog "Quick target check still running."
            return
        }

        try { $script:QuickOutputProcess.Kill() } catch {}
    }

    $sessionRoot = Join-Path (Get-CSITempOutputRoot) "_QuickChecks"
    if(!(Test-Path $sessionRoot)){
        New-Item -ItemType Directory -Path $sessionRoot -Force | Out-Null
    }

    $token = "{0}-{1}" -f (Get-Date -Format "yyyyMMdd-HHmmss"),($Title -replace '[^A-Za-z0-9._-]+','_')
    $stdout = Join-Path $sessionRoot "$token.out.txt"
    $stderr = Join-Path $sessionRoot "$token.err.txt"

    Set-GUIQuickOutput -Title $Title -Text "Running..."
    Add-GUILog "Running quick check: $Title"

    try {
        $process = Start-Process `
            -FilePath "cmd.exe" `
            -ArgumentList @("/d","/c",$Command) `
            -WindowStyle Hidden `
            -RedirectStandardOutput $stdout `
            -RedirectStandardError $stderr `
            -PassThru

        $script:QuickOutputProcess = $process
        $script:QuickOutputFiles = @{
            Title = $Title
            StdOut = $stdout
            StdErr = $stderr
        }

        $timer = New-Object System.Windows.Forms.Timer
        $timer.Interval = 500
        $timer.Add_Tick({
            if(!$script:QuickOutputProcess){
                $script:QuickOutputTimer.Stop()
                $script:QuickOutputTimer.Dispose()
                $script:QuickOutputTimer = $null
                return
            }

            if($script:QuickOutputProcess.HasExited){
                $script:QuickOutputTimer.Stop()
                $script:QuickOutputTimer.Dispose()
                $script:QuickOutputTimer = $null

                $outText = if(Test-Path $script:QuickOutputFiles.StdOut){ Get-Content -Raw -Path $script:QuickOutputFiles.StdOut -ErrorAction SilentlyContinue }else{ "" }
                $errText = if(Test-Path $script:QuickOutputFiles.StdErr){ Get-Content -Raw -Path $script:QuickOutputFiles.StdErr -ErrorAction SilentlyContinue }else{ "" }
                $exitCode = $script:QuickOutputProcess.ExitCode
                $combined = @(
                    if($outText){ $outText.TrimEnd() }
                    if($errText){ "ERROR OUTPUT:`r`n" + $errText.TrimEnd() }
                    "Exit code: $exitCode"
                ) -join "`r`n`r`n"

                Set-GUIQuickOutput -Title $script:QuickOutputFiles.Title -Text $combined
                Add-GUILog "Quick check completed: $($script:QuickOutputFiles.Title)"
                $script:QuickOutputProcess = $null
                $script:QuickOutputFiles = $null
            }
        })

        $script:QuickOutputTimer = $timer
        $timer.Start()
    }
    catch {
        Set-GUIQuickOutput -Title $Title -Text "Failed to start.`r`n`r`n$($_.Exception.Message)"
        Add-GUILog "Quick check failed to start: $($_.Exception.Message)"
    }
}

function Invoke-GUIQuickTcping {
    $target = Get-GUIQuickTarget
    if(!$target){
        return
    }

    $port = Get-GUIQuickPort
    if(!$port){
        Set-GUIQuickOutput -Title "TCPing" -Text "Enter a TCP port before running TCPing."
        return
    }

    $safeTarget = $target.Replace("'","''")
    $command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -Command `"Test-NetConnection -ComputerName '$safeTarget' -Port $port -InformationLevel Detailed | Format-List | Out-String`""
    Start-GUIQuickEmbeddedCommand -Title "TCPing $target`:$port" -Command $command
}

function Invoke-GUIQuickTracert {
    $target = Get-GUIQuickTarget
    if(!$target){
        return
    }

    Start-GUIQuickEmbeddedCommand -Title "Tracert $target" -Command ("tracert.exe -d " + (ConvertTo-GUICommandToken $target))
}

function Invoke-GUIQuickWhois {
    $target = Get-GUIQuickTarget
    if(!$target){
        return
    }

    $whoisPath = $null
    foreach($candidate in @(
        (Join-Path $SharedToolkitRoot "ExternalTools\Sysinternals\whois64.exe"),
        (Join-Path $SharedToolkitRoot "ExternalTools\Sysinternals\whois.exe")
    )){
        if(Test-Path $candidate){
            $whoisPath = (Resolve-Path $candidate).Path
            break
        }
    }

    if($whoisPath){
        $command = (ConvertTo-GUICommandToken $whoisPath) + " -accepteula " + (ConvertTo-GUICommandToken $target)
        Start-GUIQuickEmbeddedCommand -Title "WHOIS $target" -Command $command
        return
    }

    Set-GUIQuickOutput -Title "WHOIS $target" -Text "Sysinternals WHOIS was not found. Launching WhoDat instead."
    Add-GUILog "Sysinternals WHOIS was not found. Launching WhoDat instead."
    Start-GUIExternalToolById -Id "WhoDat"
}

function Invoke-GUIQuickNslookup {
    $target = Get-GUIQuickTarget
    if(!$target){
        return
    }

    Start-GUIQuickEmbeddedCommand -Title "NSLookup $target" -Command ("nslookup.exe " + (ConvertTo-GUICommandToken $target))
}

function Invoke-GUIQuickDnsRecordLookup {
    $target = Get-GUIQuickTarget
    if(!$target){
        return
    }

    $recordType = if($script:QuickRecordTypeBox -and $script:QuickRecordTypeBox.SelectedItem){
        [string]$script:QuickRecordTypeBox.SelectedItem
    }
    else{
        "A"
    }

    Start-GUIQuickEmbeddedCommand -Title "DNS $recordType $target" -Command ("nslookup.exe -type=$recordType " + (ConvertTo-GUICommandToken $target))
}

function Get-GUILatestComputerProfile {
    try {
        if($script:LatestComputerProfileCache -and ((Get-Date) - $script:LatestComputerProfileCacheTime).TotalSeconds -lt 15){
            return $script:LatestComputerProfileCache
        }

        $profiles = @(Get-CSIStoredFingerprints)

        if($profiles.Count -eq 0){
            $script:LatestComputerProfileCache = $null
            $script:LatestComputerProfileCacheTime = Get-Date
            return $null
        }

        $latest = $profiles |
            Sort-Object {
                try { [datetime]$_.CapturedAt } catch { [datetime]::MinValue }
            } -Descending |
            Select-Object -First 1

        if($latest -and (Test-Path $latest.Path)){
            $script:LatestComputerProfileCache = Get-Content -Raw -Path $latest.Path | ConvertFrom-Json
            $script:LatestComputerProfileCacheTime = Get-Date
            return $script:LatestComputerProfileCache
        }
    }
    catch {
    }

    return $null
}

function Refresh-GUIDismSfcState {
    $profile = Get-GUILatestComputerProfile
    $needsRepair = $false

    if($profile -and $profile.ServicingHealth){
        $needsRepair = [bool]$profile.ServicingHealth.FollowUpDismSfc
    }

    $script:QuickDiagnosisRan = [bool]$profile
    $script:DismSfcRecommended = $needsRepair

    if($script:DismRepairButton){
        if($needsRepair){
            $script:DismRepairButton.BackColor = $script:GUITheme.Danger
            $script:DismRepairButton.ForeColor = [System.Drawing.Color]::White
        }
        else{
            $script:DismRepairButton.BackColor = $script:GUITheme.Disabled
            $script:DismRepairButton.ForeColor = $script:GUITheme.MutedText
        }
    }

    if($script:DismRepairNoteLabel){
        if($needsRepair){
            $script:DismRepairNoteLabel.Text = "Quick Diagnosis indicates DISM/SFC follow-up may be needed."
        }
        elseif($profile){
            $script:DismRepairNoteLabel.Text = "Latest computer profile does not indicate DISM/SFC follow-up."
        }
        else{
            $script:DismRepairNoteLabel.Text = "Run Quick Diagnosis first. Override is available if symptoms justify it."
        }
    }
}

function Get-GUIDashboardInfo {
    $computer = $env:COMPUTERNAME
    $domain = ""

    try {
        $system = Get-CimInstance Win32_ComputerSystem -ErrorAction Stop
        $domain = $system.Domain
    }
    catch {
        $domain = $env:USERDOMAIN
    }

    return [pscustomobject]@{
        ComputerName = $computer
        Domain       = $domain
        PrivateIP    = Get-GUIPrivateIPSummary
        PublicIP     = "Checking..."
    }
}

function Get-SelectedCommand {
    if(!$script:CommandList -or $script:CommandList.SelectedIndex -lt 0){
        return $null
    }

    $index = $script:CommandList.SelectedIndex

    if($index -ge $script:Commands.Count){
        return $null
    }

    return $script:Commands[$index]
}

function Update-SelectedCommandDetails {
    $command = Get-SelectedCommand

    if(!$script:DescriptionBox){
        return
    }

    if(!$command){
        $script:DescriptionBox.Text = ""
        return
    }

    $admin = if($command.RequiresAdmin){"Yes"}else{"No"}

    $script:DescriptionBox.Text = @"
Name: $($command.Name)
Category: $($command.Category)
Source: $($command.Source)
Requires Admin: $admin

$($command.Description)
"@
}

function Start-SelectedCommand {
    $command = Get-SelectedCommand

    if(!$command){
        Add-GUILog "Select a tool first."
        return
    }

    if($command.Command){
        Start-GUIToolkitFunctionConsole -FunctionName $command.Command -DisplayName $command.Name -RequiresAdmin:([bool]$command.RequiresAdmin)
    }
    else{
        Add-GUILog "Command has no registered function: $($command.Name)"
    }
}

function Start-GUICommandByName {
    param(
        [string]$Name,
        [System.Diagnostics.ProcessWindowStyle]$WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Normal
    )

    $command = Get-CSICommands | Where-Object {$_.Name -eq $Name} | Select-Object -First 1

    if(!$command){
        Add-GUILog "Command not found: $Name"
        return
    }

    if($command.Command){
        Start-GUIToolkitFunctionConsole -FunctionName $command.Command -DisplayName $command.Name -RequiresAdmin:([bool]$command.RequiresAdmin)
    }
    else{
        Add-GUILog "Command has no registered function: $Name"
    }
}

function Start-GUIToolkitFunctionConsole {
    param(
        [string]$FunctionName,
        [string]$DisplayName = "",
        [switch]$RequiresAdmin
    )

    $toolLabel = if($DisplayName){$DisplayName}else{$FunctionName}
    $session = New-CSITempOutputSession -ToolName $toolLabel
    $runnerPath = Join-Path $session.Path "run-tool.ps1"

    $commandText = @"
try {
    `$ErrorActionPreference = "Continue"
    . "$ToolkitLauncher" -NoConsole
    if(!(Get-Command "$($FunctionName.Replace('"','\"'))" -ErrorAction SilentlyContinue)){
        throw "Toolkit function not found after module load: $($FunctionName.Replace('"','\"'))"
    }
    `$metadata = [pscustomobject]@{
        Tool = "$($toolLabel.Replace('"','\"'))"
        Function = "$($FunctionName.Replace('"','\"'))"
        StartedAt = (Get-Date).ToString("s")
        CompletedAt = ""
        Status = "Running"
        ErrorCount = 0
        ComputerName = `$env:COMPUTERNAME
        UserName = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    }
    `$metadata | ConvertTo-Json -Depth 4 | Set-Content -Path "$($session.Metadata)" -Encoding UTF8
    Start-Transcript -Path "$($session.Transcript)" -Force | Out-Null
    Write-Host ""
    Write-Host "Running: $($toolLabel.Replace('"','\"'))" -ForegroundColor Cyan
    Write-Host "Output session: $($session.Path)" -ForegroundColor DarkCyan
    Write-Host ""
    $FunctionName
    `$metadata.CompletedAt = (Get-Date).ToString("s")
    `$metadata.Status = "Completed"
}
catch [System.OperationCanceledException] {
    Write-Host ""
    Write-Host `$_.Exception.Message -ForegroundColor Yellow
    `$metadata.CompletedAt = (Get-Date).ToString("s")
    `$metadata.Status = "Cancelled"
}
catch {
    Write-Host ""
    Write-Host "Command failed." -ForegroundColor Red
    Write-Host `$_
    if(`$metadata){
        `$metadata.CompletedAt = (Get-Date).ToString("s")
        `$metadata.Status = "Error"
        `$metadata.LastError = `$_.Exception.Message
    }
}
finally {
    try { Stop-Transcript | Out-Null } catch {}
    try {
        if(Test-Path "$($session.Transcript)"){
            `$transcriptText = Get-Content -Raw -Path "$($session.Transcript)" -ErrorAction SilentlyContinue
            `$errorMatches = @([regex]::Matches([string]`$transcriptText,'(?im)\b(error|exception|failed|cannot find|not recognized)\b'))
            if(`$metadata){
                `$metadata.ErrorCount = `$errorMatches.Count
                if(`$metadata.Status -eq "Completed" -and `$errorMatches.Count -gt 0){
                    `$metadata.Status = "CompletedWithWarnings"
                }
            }
        }
        if(`$metadata){
            `$metadata | ConvertTo-Json -Depth 6 | Set-Content -Path "$($session.Metadata)" -Encoding UTF8
        }
    }
    catch {}
    try {
        if(Get-Command Set-CSIComputerStateToolOutput -ErrorAction SilentlyContinue){
            `$stateArgs = @{
                ToolName = "$($toolLabel.Replace('"','\"'))"
                SessionPath = "$($session.Path)"
                TranscriptPath = "$($session.Transcript)"
                MetadataPath = "$($session.Metadata)"
                ComputerName = `$env:COMPUTERNAME
            }
            [void](Set-CSIComputerStateToolOutput @stateArgs)
        }
    }
    catch {}
    Write-Host ""
    Write-Host "Output saved to:" -ForegroundColor Green
    Write-Host "$($session.Path)"
    Write-Host ""
    [void](Read-Host "Press ENTER to close")
}
"@

    try {
        $commandText | Set-Content -Path $runnerPath -Encoding UTF8

        Start-CSIToolProcess `
            -FilePath "powershell.exe" `
            -ArgumentList @("-NoProfile","-ExecutionPolicy","Bypass","-File","`"$runnerPath`"") `
            -WorkingDirectory $SharedToolkitRoot `
            -WindowStyle Normal `
            -Elevated:($RequiresAdmin -and !(Test-GUIAdministrator)) | Out-Null

        Add-GUILog "Launched: $toolLabel"
        Add-GUILog "Temp output session: $($session.Path)"
    }
    catch {
        Add-GUILog "Failed to launch ${toolLabel}: $($_.Exception.Message)"
    }
}

function Start-GUIExternalToolById {
    param([string]$Id)

    Start-GUIExternalFileTool -Id $Id
}

function Invoke-GUINamedAction {
    param([string]$Action)

    switch($Action){
        "Start-GUIDismSfcRepairPath" { Start-GUIDismSfcRepairPath; break }
        "Start-GUIPrintQueueMaintenance" { Start-GUIPrintQueueMaintenance; break }
        "Start-GUIFirefoxPortable" { Start-GUIFirefoxPortable; break }
        "Start-GUIBulkUninstaller" { Start-GUIBulkUninstaller; break }
        "Start-GUILaunchRDP" { Start-GUILaunchRDP; break }
        "Start-GUIMinidumpCollector" { Start-GUIMinidumpCollector; break }
        "Start-GUIGPResultReport" { Start-GUIGPResultReport; break }
        "Start-GUIReliabilityMonitor" { Start-GUIReliabilityMonitor; break }
        "Start-GUIPsExecHelper" { Start-GUIPsExecHelper; break }
        "Open-GUIOutputsFolder" { Open-GUIFolder $CSIPaths.Exports; break }
        "Open-GUITempOutputsFolder" { Open-GUIFolder (Get-CSITempOutputRoot); break }
        "Open-GUIDataFolder" { Open-GUIFolder $CSIPaths.Data; break }
        "Open-GUILogsFolder" { Open-GUIFolder $CSIPaths.Logs; break }
        "Open-GUIToolkitFolder" { Open-GUIFolder $CSIPaths.Root; break }
        default { Add-GUILog "Unknown GUI action: $Action"; break }
    }
}

function Start-GUIGPResultReport {
    try {
        $session = New-CSITempOutputSession -ToolName "Group Policy HTML Report"
        $shortRoot = Join-Path $env:TEMP "NT-GPResult"
        if(!(Test-Path $shortRoot)){
            New-Item -ItemType Directory -Path $shortRoot -Force | Out-Null
        }

        $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $shortReportPath = Join-Path $shortRoot "gp.html"
        $reportPath = Join-Path $session.Path ("gpresult-{0}-{1}.html" -f $env:COMPUTERNAME,$stamp)
        $runnerPath = Join-Path $session.Path "run-gpresult.ps1"

        $commandText = @"
try {
    `$ErrorActionPreference = "Stop"
    if(Test-Path "$shortReportPath"){
        Remove-Item -LiteralPath "$shortReportPath" -Force -ErrorAction SilentlyContinue
    }
    gpresult.exe /h "$shortReportPath" /f
    if(Test-Path "$shortReportPath"){
        Copy-Item -LiteralPath "$shortReportPath" -Destination "$reportPath" -Force
        Start-Process "$reportPath"
    }
    else{
        Write-Host "gpresult completed, but the HTML report was not created." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "gpresult failed." -ForegroundColor Red
    Write-Host `$_.Exception.Message
}
finally {
    Write-Host ""
    Write-Host "Report path:" "$reportPath"
    Write-Host ""
    [void](Read-Host "Press ENTER to close")
}
"@

        $commandText | Set-Content -Path $runnerPath -Encoding UTF8
        Start-CSIToolProcess `
            -FilePath "powershell.exe" `
            -ArgumentList @("-NoProfile","-ExecutionPolicy","Bypass","-File","`"$runnerPath`"") `
            -WorkingDirectory $SharedToolkitRoot `
            -WindowStyle Normal | Out-Null

        Add-GUILog "Launched gpresult HTML report. Output session: $($session.Path)"
        Write-GUIToolUsageLog -Tool "Group Policy HTML Report" -Action "Launch" -Detail $reportPath
    }
    catch {
        Add-GUILog "Failed to launch gpresult report: $($_.Exception.Message)"
    }
}

function Start-GUIReliabilityMonitor {
    try {
        Start-CSIToolProcess -FilePath "perfmon.exe" -ArgumentList @("/rel") -WindowStyle Normal | Out-Null
        Add-GUILog "Launched Reliability Monitor."
        Write-GUIToolUsageLog -Tool "Reliability Monitor" -Action "Launch" -Detail "perfmon.exe /rel"
    }
    catch {
        Add-GUILog "Failed to launch Reliability Monitor: $($_.Exception.Message)"
    }
}

function Start-GUIMinidumpCollector {
    try {
        $commandText = ". `"$ToolkitLauncher`" -NoConsole; Invoke-MinidumpCollectorAnalyzer -CollectAll"

        Start-CSIToolProcess `
            -FilePath "powershell.exe" `
            -ArgumentList @("-NoProfile","-ExecutionPolicy","Bypass","-Command",$commandText) `
            -WorkingDirectory $SharedToolkitRoot `
            -WindowStyle Normal | Out-Null

        Add-GUILog "Launched Minidump Collector. Collections are saved under Data\\MiniDumps."
    }
    catch {
        Add-GUILog "Failed to launch Minidump Collector: $($_.Exception.Message)"
    }
}

function Start-GUILaunchRDP {
    $mstsc = Join-Path $env:SystemRoot "System32\mstsc.exe"

    if(!(Test-Path $mstsc)){
        Add-GUILog "Remote Desktop Connection was not found: $mstsc"
        [System.Windows.Forms.MessageBox]::Show(
            "Remote Desktop Connection was not found on this computer.`r`n`r`nExpected path:`r`n$mstsc",
            "RDP Not Found",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return
    }

    try {
        Start-Process -FilePath $mstsc -ErrorAction Stop | Out-Null
        Add-GUILog "Launched: Remote Desktop Connection"
        Write-GUIToolUsageLog -Tool "Launch RDP" -Action "Launch" -Detail $mstsc
    }
    catch {
        Add-GUILog "Failed to launch Remote Desktop Connection: $($_.Exception.Message)"
        Write-GUIToolUsageLog -Tool "Launch RDP" -Action "Failed" -Detail $_.Exception.Message -Level "ERROR"
        [System.Windows.Forms.MessageBox]::Show(
            "Could not launch Remote Desktop Connection.`r`n`r`n$($_.Exception.Message)",
            "RDP Launch Failed",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
}

function Start-GUIPrintQueueMaintenance {
    $toolPath = Join-Path $CSIPaths.Plugins "PrintQueues\Print Queue Cleanup\PrinterSpoolerTool.ps1"

    if(!(Test-Path $toolPath)){
        Add-GUILog "Print Queue Maintenance tool not found: $toolPath"
        [System.Windows.Forms.MessageBox]::Show(
            "The Print Queue Maintenance tool was not found.`r`n`r`n$toolPath",
            "Tool Not Found",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return
    }

    $dataRoot = Join-Path $CSIPaths.Data "PrintQueueTools"
    if(!(Test-Path $dataRoot)){
        New-Item -ItemType Directory -Path $dataRoot -Force | Out-Null
    }

    try {
        Start-CSIToolProcess `
            -FilePath "powershell.exe" `
            -ArgumentList @("-NoProfile","-WindowStyle","Hidden","-ExecutionPolicy","Bypass","-STA","-File","`"$toolPath`"","-ToolDataRoot","`"$dataRoot`"") `
            -WorkingDirectory (Split-Path -Parent $toolPath) `
            -WindowStyle Normal | Out-Null

        Add-GUILog "Launched Print Queue Maintenance."
    }
    catch {
        Add-GUILog "Failed to launch Print Queue Maintenance: $($_.Exception.Message)"
    }
}

function Get-GUISysinternalsRoot {
    return (Join-Path (Get-CSIExternalToolRoot) "Sysinternals")
}

function ConvertTo-GUISysinternalsBaseName {
    param([string]$Name)

    return ($Name -replace "(?i)64$","")
}

function Get-GUISysinternalsCategory {
    param([string]$BaseName)

    $name = $BaseName.ToLowerInvariant()

    if($name -in @("procexp","procmon","autoruns","autorunsc","listdlls","handle","loadord","loadordc","pslist","pskill","pssuspend","procdump")){
        return "Process And Startup"
    }

    if($name -in @("tcpview","tcpvcon","psping","whois","psfile","psloggedon")){
        return "Network"
    }

    if($name -in @("psexec","psgetsid","psinfo","psloglist","pspasswd","psservice","psshutdown")){
        return "PsTools"
    }

    if($name -in @("du","disk2vhd","diskext","diskmon","diskview","ntfsinfo","contig","sdelete","streams","sync","volumeid","pendmoves","movefile","junction","findlinks")){
        return "Disk And File"
    }

    if($name -in @("accesschk","accessenum","shareenum","sigcheck","sysmon","regdelnull","regjump","autologon","logonsessions")){
        return "Security And Registry"
    }

    if($name -in @("adexplorer","adinsight","adrestore")){
        return "Active Directory"
    }

    if($name -in @("rammap","vmmap","coreinfo","coreinfoex","clockres","cacheset","dbgview","livekd","winobj","bginfo","rdcman","desktops","zoomit")){
        return "System Inspection"
    }

    if($name -in @("notmyfault","notmyfaultc","testlimit","cpustres")){
        return "Stress And Caution"
    }

    return "Other"
}

function Test-GUISysinternalsConsoleTool {
    param([string]$BaseName)

    $consoleTools = @(
        "accesschk","adrestore","autorunsc","clockres","contig","coreinfo","coreinfoex",
        "du","efsdump","findlinks","handle","hex2dec","junction","ldmdump","listdlls",
        "livekd","logonsessions","movefile","ntfsinfo","pendmoves","pipelist","procdump",
        "psexec","psfile","psgetsid","psinfo","pskill","pslist","psloggedon","psloglist",
        "pspasswd","psping","psservice","psshutdown","pssuspend","regdelnull","ru",
        "sdelete","sigcheck","streams","strings","sync","sysmon","tcpvcon","testlimit",
        "volumeid","whois"
    )

    return $consoleTools -contains $BaseName.ToLowerInvariant()
}

function Test-GUISysinternalsRiskyTool {
    param([string]$BaseName)

    return @("notmyfault","notmyfaultc","testlimit","cpustres","sdelete","psshutdown","pskill","pssuspend","shellrunas","ctrl2cap","volumeid","movefile","sysmon","pspasswd") -contains $BaseName.ToLowerInvariant()
}

function Get-GUISysinternalsDescription {
    param(
        [string]$BaseName,
        [string]$FileName,
        [string]$Category,
        [bool]$Console,
        [bool]$Risky
    )

    $key = $BaseName.ToLowerInvariant()
    $descriptions = @{
        "accesschk" = "Checks file, folder, registry, service, and object permissions for access issues."
        "accessenum" = "Shows where permissions differ under a folder or registry path."
        "adexplorer" = "Browses Active Directory and can save snapshots for offline comparison."
        "adinsight" = "Traces LDAP calls from applications during Active Directory troubleshooting."
        "adrestore" = "Finds and can restore deleted Active Directory objects."
        "autoruns" = "Shows nearly every auto-start location for malware, bloat, and startup troubleshooting."
        "autorunsc" = "Command-line autoruns inventory for startup entries and persistence checks."
        "bginfo" = "Displays system identity details on the desktop for quick workstation labeling."
        "cacheset" = "Views and adjusts Windows file system cache working set values."
        "clockres" = "Shows system clock resolution, useful for timing and performance troubleshooting."
        "contig" = "Defragments individual files without running a full volume defrag."
        "coreinfo" = "Reports CPU topology, virtualization support, and processor feature flags."
        "coreinfoex" = "Extended CPU feature and topology reporting."
        "cpustres" = "Creates CPU load for testing cooling, stability, and monitoring behavior."
        "dbgview" = "Captures debug output from applications, drivers, and the kernel."
        "desktops" = "Creates multiple Windows desktop sessions for separating workspaces."
        "disk2vhd" = "Creates VHD/VHDX images from physical disks for capture or migration."
        "diskext" = "Maps volume extents to physical disk offsets."
        "diskmon" = "Shows live physical disk activity."
        "diskview" = "Visualizes disk cluster usage for file placement review."
        "du" = "Command-line disk usage by folder for finding space consumption quickly."
        "efsdump" = "Lists Encrypting File System information for encrypted files."
        "findlinks" = "Finds hard links that reference the same file data."
        "handle" = "Finds which process has a file, folder, registry key, or object open."
        "hex2dec" = "Converts hexadecimal and decimal values."
        "junction" = "Lists or manages NTFS junctions and reparse points."
        "ldmdump" = "Dumps Logical Disk Manager database information."
        "listdlls" = "Lists DLLs loaded by processes to troubleshoot modules and versions."
        "livekd" = "Runs kernel debugger analysis against a live system or dump source."
        "loadord" = "Shows driver and service load order."
        "loadordc" = "Command-line driver and service load order view."
        "logonsessions" = "Lists active logon sessions and associated processes."
        "movefile" = "Schedules file move/delete operations for the next reboot."
        "notmyfault" = "Crash and hang test utility for validating dump collection and recovery behavior."
        "notmyfaultc" = "Command-line crash and hang test utility."
        "ntfsinfo" = "Shows NTFS volume metadata such as MFT and cluster details."
        "pendmoves" = "Shows pending file rename/delete operations scheduled for reboot."
        "pipelist" = "Lists named pipes on the local computer."
        "procdump" = "Captures process dumps based on CPU, memory, hang, exception, or manual triggers."
        "procexp" = "Advanced Task Manager for process trees, handles, DLLs, signatures, and performance."
        "procmon" = "Live file, registry, process, thread, and network event trace."
        "psexec" = "Runs processes locally or remotely for admin troubleshooting."
        "psfile" = "Shows files opened remotely through file shares."
        "psgetsid" = "Translates account names and SIDs."
        "psinfo" = "Shows local or remote system inventory and uptime details."
        "pskill" = "Terminates local or remote processes."
        "pslist" = "Lists local or remote process and thread details."
        "psloggedon" = "Shows locally and remotely logged-on users."
        "psloglist" = "Dumps local or remote event logs."
        "pspasswd" = "Changes local or remote account passwords."
        "psping" = "Tests ICMP/TCP latency, packet loss, and bandwidth."
        "psservice" = "Views and controls local or remote Windows services."
        "psshutdown" = "Shuts down, reboots, logs off, or locks local or remote computers."
        "pssuspend" = "Suspends or resumes local or remote processes."
        "rammap" = "Breaks down physical memory usage and standby cache behavior."
        "rdcman" = "Manages groups of Remote Desktop connections."
        "regdelnull" = "Finds and deletes registry keys with embedded null characters."
        "regjump" = "Opens Registry Editor directly to a selected registry path."
        "sdelete" = "Securely deletes files or wipes free space."
        "shareenum" = "Enumerates network shares and share permissions."
        "sigcheck" = "Checks file signatures, versions, hashes, unsigned files, and VirusTotal lookups."
        "streams" = "Lists or removes NTFS alternate data streams."
        "strings" = "Extracts printable strings from binaries or other files."
        "sync" = "Flushes cached file system data to disk."
        "sysmon" = "Installs or controls Sysmon event collection."
        "tcpvcon" = "Command-line TCP/UDP endpoint viewer."
        "tcpview" = "Live TCP/UDP endpoint viewer with owning processes."
        "testlimit" = "Stress-tests memory, handles, processes, threads, and other limits."
        "vmmap" = "Shows detailed process virtual and physical memory usage."
        "volumeid" = "Changes FAT or NTFS volume serial numbers."
        "whois" = "Looks up domain registration and ownership records."
        "winobj" = "Browses the Windows Object Manager namespace."
        "zoomit" = "Screen zoom, annotation, and timer utility for demos and support."
    }

    if($descriptions.ContainsKey($key)){
        $description = $descriptions[$key]
    }
    else{
        switch($Category){
            "Process And Startup" { $description = "Process, startup, module, or dump troubleshooting utility."; break }
            "Network" { $description = "Network visibility or connectivity troubleshooting utility."; break }
            "PsTools" { $description = "PsTools remote administration and troubleshooting utility."; break }
            "Disk And File" { $description = "Disk, file system, or storage troubleshooting utility."; break }
            "Security And Registry" { $description = "Security, signature, permission, or registry troubleshooting utility."; break }
            "Active Directory" { $description = "Active Directory inspection or recovery utility."; break }
            "System Inspection" { $description = "System inspection, memory, driver, or debugging utility."; break }
            "Stress And Caution" { $description = "Stress or crash testing utility. Use only when you intend to test failure behavior."; break }
            default { $description = "Launches $FileName from the local Sysinternals folder."; break }
        }
    }

    if($Risky){
        $description += " Caution: this can change state, stress the computer, delete data, or reboot/shut down systems."
    }

    return $description
}

function Get-GUISysinternalsTools {
    $root = Get-GUISysinternalsRoot

    if(!(Test-Path $root)){
        return @()
    }

    $files = @(Get-ChildItem -Path $root -Filter "*.exe" -File -ErrorAction SilentlyContinue)
    $groups = $files | Group-Object { ConvertTo-GUISysinternalsBaseName $_.BaseName }
    $tools = @()

    foreach($group in $groups){
        $preferred = $group.Group |
            Sort-Object @{Expression={ if($_.BaseName -match "64$"){0}else{1} }},Name |
            Select-Object -First 1

        $base = ConvertTo-GUISysinternalsBaseName $preferred.BaseName

        $tools += [pscustomobject]@{
            Name = $base
            DisplayName = $base
            Path = $preferred.FullName
            FileName = $preferred.Name
            Category = Get-GUISysinternalsCategory -BaseName $base
            Console = Test-GUISysinternalsConsoleTool -BaseName $base
            Risky = Test-GUISysinternalsRiskyTool -BaseName $base
        }
    }

    return $tools | Sort-Object Category,DisplayName
}

function Read-GUISysinternalsInput {
    param(
        [string]$Title,
        [string]$Prompt,
        [string]$Default = "",
        [switch]$UseDefaultWhenBlank
    )

    $value = [Microsoft.VisualBasic.Interaction]::InputBox($Prompt,$Title,$Default)

    if([string]::IsNullOrWhiteSpace($value)){
        if($UseDefaultWhenBlank -and ![string]::IsNullOrWhiteSpace($Default)){
            return $Default
        }

        return $null
    }

    return $value.Trim()
}

function New-GUISysinternalsOutputPath {
    param([string]$ToolName)

    $session = New-CSITempOutputSession -ToolName "Sysinternals-$ToolName"
    return $session.Path
}

function ConvertFrom-GUICommandLine {
    param([string]$CommandLine)

    if([string]::IsNullOrWhiteSpace($CommandLine)){
        return @()
    }

    $tokens = New-Object System.Collections.ArrayList
    $current = New-Object System.Text.StringBuilder
    $inQuotes = $false

    foreach($ch in $CommandLine.ToCharArray()){
        if($ch -eq '"'){
            $inQuotes = !$inQuotes
            continue
        }

        if([char]::IsWhiteSpace($ch) -and !$inQuotes){
            if($current.Length -gt 0){
                [void]$tokens.Add($current.ToString())
                [void]$current.Clear()
            }
            continue
        }

        [void]$current.Append($ch)
    }

    if($current.Length -gt 0){
        [void]$tokens.Add($current.ToString())
    }

    return @($tokens)
}

function Get-GUISysinternalsLaunchSpec {
    param(
        [string]$BaseName,
        [bool]$Console,
        [bool]$Risky
    )

    $name = $BaseName.ToLowerInvariant()
    $common = "-accepteula"
    $specs = @{
        "accesschk" = @{ Args="$common Everyone C:\"; Notes="Review effective access. Replace Everyone and C:\ with a user/group and file, folder, registry, service, or object path."; Example="Administrators C:\Windows" }
        "accessenum" = @{ Args=""; Notes="GUI permissions enumeration tool. Launch empty for normal interactive use."; Example="" }
        "adexplorer" = @{ Args=""; Notes="GUI Active Directory browser. Launch empty for normal interactive use."; Example="" }
        "adinsight" = @{ Args=""; Notes="GUI LDAP tracing tool. Launch empty for normal interactive use."; Example="" }
        "adrestore" = @{ Args="$common"; Notes="Lists deleted Active Directory objects. Add an object name to filter results."; Example="deletedUserName" }
        "autologon" = @{ Args=""; Notes="GUI automatic logon configuration tool. Launch empty for the interactive form."; Example="" }
        "autoruns" = @{ Args=""; Notes="GUI autoruns viewer. Launches without arguments; EULA acceptance is handled automatically."; Example="" }
        "autorunsc" = @{ Args="$common -a * -ct"; Notes="Exports all autorun locations in tab-delimited text."; Example="-a * -ct" }
        "bginfo" = @{ Args=""; Notes="Desktop system information overlay. Add a .bgi config path if you have one."; Example='"C:\Path\config.bgi" /timer:0' }
        "cacheset" = @{ Args=""; Notes="GUI file cache working-set utility. Launch empty for normal interactive use."; Example="" }
        "clockres" = @{ Args="$common"; Notes="Shows system clock resolution."; Example="" }
        "contig" = @{ Args="$common -a C:\"; Notes="Analyzes fragmentation only. Remove -a only if you intend to defragment a file."; Example="-a C:\Path\File.ext" }
        "coreinfo" = @{ Args="$common"; Notes="Shows CPU topology and feature flags."; Example="-v" }
        "coreinfoex" = @{ Args="$common"; Notes="Shows extended CPU topology and feature flags."; Example="" }
        "cpustres" = @{ Args=""; Notes="GUI CPU stress utility. Launch empty and configure load interactively."; Example="" }
        "ctrl2cap" = @{ Args=""; Notes="Keyboard driver utility. Use Usage first; install/uninstall changes system state."; Example="/install" }
        "dbgview" = @{ Args="$common"; Notes="GUI debug output viewer. Launches normally with EULA accepted."; Example="/k" }
        "desktops" = @{ Args=""; Notes="GUI virtual desktop utility. Launch empty for normal interactive use."; Example="" }
        "disk2vhd" = @{ Args="$common"; Notes="GUI disk-to-VHD capture tool. Launch empty or pass source/destination when scripted."; Example='"C: D:" "D:\capture.vhdx"' }
        "diskext" = @{ Args="$common"; Notes="Shows disk extent mappings."; Example="" }
        "diskmon" = @{ Args="$common"; Notes="GUI disk activity monitor. Launch empty for live disk activity."; Example="" }
        "diskview" = @{ Args="$common"; Notes="GUI disk cluster viewer. Launch empty for normal interactive use."; Example="" }
        "du" = @{ Args="$common -l 2 C:\"; Notes="Shows folder disk usage. Change the path and depth as needed."; Example="-l 3 C:\Users" }
        "efsdump" = @{ Args="$common C:\"; Notes="Lists EFS metadata for encrypted files under a path."; Example="C:\Users" }
        "findlinks" = @{ Args="$common"; Notes="Provide a file path to find hard links to the same data."; Example="C:\Path\File.ext" }
        "handle" = @{ Args="$common C:\Windows"; Notes="Search for a file, folder, registry key, process, or handle string."; Example="-p explorer.exe" }
        "hex2dec" = @{ Args="0x2A"; Notes="Converts hexadecimal and decimal values."; Example="42" }
        "junction" = @{ Args="$common -s C:\"; Notes="Scans for junctions/reparse points under a path."; Example="-s C:\Users" }
        "ldmdump" = @{ Args="$common"; Notes="Dumps Logical Disk Manager metadata."; Example="" }
        "listdlls" = @{ Args="$common"; Notes="Lists DLLs for all processes. Add a process name or PID to narrow it."; Example="explorer.exe" }
        "livekd" = @{ Args="$common"; Notes="Starts live kernel debugging. Advanced tool; review usage if unsure."; Example="-k" }
        "loadord" = @{ Args="$common"; Notes="GUI driver/service load order viewer. Launch empty for normal interactive use."; Example="" }
        "loadordc" = @{ Args="$common"; Notes="Command-line driver/service load order viewer."; Example="" }
        "logonsessions" = @{ Args="$common -p"; Notes="Lists logon sessions and associated processes."; Example="-p" }
        "movefile" = @{ Args="$common"; Notes="Schedules a file move/delete at next boot. Requires source and destination."; Example="C:\temp\old.txt C:\temp\new.txt" }
        "notmyfault" = @{ Args=""; Notes="GUI crash/hang test utility. Launch empty only when intentionally testing dump capture."; Example="" }
        "notmyfaultc" = @{ Args="$common"; Notes="Crash/hang test utility. Use Usage first unless intentionally testing dump capture."; Example="" }
        "ntfsinfo" = @{ Args="$common C:"; Notes="Shows NTFS metadata for a volume."; Example="D:" }
        "pendmoves" = @{ Args="$common"; Notes="Shows file move/delete operations pending reboot."; Example="" }
        "pipelist" = @{ Args="$common"; Notes="Lists named pipes on the local computer."; Example="" }
        "procdump" = @{ Args="$common -ma explorer.exe"; Notes="Captures a full dump. Replace explorer.exe with a process name or PID."; Example="-ma notepad.exe" }
        "procexp" = @{ Args="$common"; Notes="GUI process explorer. Launches normally with EULA accepted."; Example="/t" }
        "procmon" = @{ Args="$common"; Notes="GUI process monitor. Launches normally with EULA accepted."; Example="/BackingFile C:\Temp\trace.pml" }
        "psexec" = @{ Args="$common . cmd.exe"; Notes="Runs a command locally or remotely. Use . for local or \\computer for remote."; Example="\\server01 cmd.exe" }
        "psfile" = @{ Args="$common ."; Notes="Shows files opened remotely through shares. Use . or \\computer."; Example="\\server01" }
        "psgetsid" = @{ Args="$common %USERNAME%"; Notes="Translates account names and SIDs."; Example="DOMAIN\User" }
        "psinfo" = @{ Args="$common ."; Notes="Shows system inventory. Use . or \\computer."; Example="\\server01" }
        "pskill" = @{ Args="$common"; Notes="Terminates a process. Enter a PID or process name only when you intend to kill it."; Example="notepad.exe" }
        "pslist" = @{ Args="$common ."; Notes="Lists processes. Use . or \\computer."; Example="-t ." }
        "psloggedon" = @{ Args="$common ."; Notes="Shows logged-on users. Use . or \\computer."; Example="\\server01" }
        "psloglist" = @{ Args="$common . system -n 25"; Notes="Shows recent event log entries. Change computer, log, and count as needed."; Example=". application -n 50" }
        "pspasswd" = @{ Args="$common"; Notes="Changes a password. Use only when intentionally resetting credentials."; Example="\\server01 userName *" }
        "psping" = @{ Args="$common www.microsoft.com:443"; Notes="Tests ICMP/TCP latency. Use host or host:port."; Example="-n 10 server01:443" }
        "psservice" = @{ Args="$common . query"; Notes="Queries or controls services. Use . or \\computer."; Example="\\server01 query spooler" }
        "psshutdown" = @{ Args="$common"; Notes="Shutdown/reboot/logoff tool. Use only with deliberate action flags."; Example="-r -t 60 \\server01" }
        "pssuspend" = @{ Args="$common"; Notes="Suspends or resumes a process. Enter PID/name only when deliberate."; Example="notepad.exe" }
        "regdelnull" = @{ Args="$common -s HKLM"; Notes="Finds registry keys with embedded null characters. Delete only if intended."; Example="-s HKCU" }
        "regjump" = @{ Args="HKLM\Software"; Notes="Opens Registry Editor directly to a selected path."; Example="HKLM\System\CurrentControlSet\Services" }
        "rammap" = @{ Args="$common"; Notes="GUI physical memory analysis tool. Launches normally with EULA accepted."; Example="" }
        "rdcman" = @{ Args=""; Notes="Remote Desktop Connection Manager. Launch empty or pass an .rdg file."; Example='"C:\Path\servers.rdg"' }
        "ru" = @{ Args="$common"; Notes="Registry usage utility. Review usage if unsure."; Example="" }
        "sdelete" = @{ Args="$common"; Notes="Secure delete/wipe tool. Destructive. Enter target only when intended."; Example="-p 1 C:\temp\file.txt" }
        "shareenum" = @{ Args=""; Notes="GUI share enumeration tool. Launch empty for normal interactive use."; Example="" }
        "shellrunas" = @{ Args=""; Notes="ShellRunas installs/removes Explorer shell integration or runs a command as another user. Use Usage to review switches."; Example="/reg" }
        "sigcheck" = @{ Args="$common -a -h C:\Windows\System32"; Notes="Checks file signatures, versions, and hashes."; Example="-u -e C:\Windows\System32" }
        "streams" = @{ Args="$common -s C:\"; Notes="Lists alternate data streams. Add -d only if you intend to delete streams."; Example="-s C:\Users" }
        "strings" = @{ Args="$common"; Notes="Extracts printable strings. Enter a file path to inspect."; Example="C:\Windows\System32\notepad.exe" }
        "sync" = @{ Args="$common"; Notes="Flushes cached file system data to disk."; Example="-r" }
        "sysmon" = @{ Args="$common"; Notes="Installs or controls Sysmon. Use Usage unless you have a config ready."; Example="-i sysmonconfig.xml" }
        "tcpvcon" = @{ Args="$common -a"; Notes="Command-line TCPView. Shows all endpoints."; Example="-a -c" }
        "tcpview" = @{ Args="$common"; Notes="GUI TCP/UDP endpoint viewer. Launches normally with EULA accepted."; Example="" }
        "testlimit" = @{ Args="$common"; Notes="Stress/limit test tool. Use Usage first unless intentionally testing limits."; Example="-d 1024" }
        "vmmap" = @{ Args="$common"; Notes="GUI process memory map. Launch empty, or pass a PID/process name if desired."; Example="notepad.exe" }
        "volumeid" = @{ Args="$common"; Notes="Changes a volume serial number. Requires drive and new ID."; Example="C: 1234-5678" }
        "whois" = @{ Args="$common microsoft.com"; Notes="Looks up domain or public IP registration."; Example="contoso.com" }
        "winobj" = @{ Args="$common"; Notes="GUI Object Manager namespace browser. Launches normally with EULA accepted."; Example="" }
        "zoomit" = @{ Args="$common"; Notes="Screen zoom and annotation utility. Launches normally with EULA accepted."; Example="" }
    }

    if($specs.ContainsKey($name)){
        $spec = $specs[$name]
    }
    elseif($Console){
        $spec = @{ Args=$common; Notes="Console tool. Edit arguments before launch, or click Usage to view available switches."; Example="" }
    }
    else{
        $spec = @{ Args=""; Notes="GUI tool. It usually launches without arguments. Add optional arguments only if needed."; Example="" }
    }

    return [pscustomobject]@{
        Args = [string]$spec.Args
        Notes = [string]$spec.Notes
        Example = [string]$spec.Example
        Risky = $Risky
    }
}

function Show-GUISysinternalsLaunchHelper {
    param(
        [string]$DisplayName,
        [string]$BaseName,
        [string]$Description,
        [bool]$Console,
        [bool]$Risky
    )

    $spec = Get-GUISysinternalsLaunchSpec -BaseName $BaseName -Console $Console -Risky $Risky

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Launch $DisplayName"
    $form.StartPosition = "CenterParent"
    $form.Size = New-Object System.Drawing.Size(660,360)
    $form.MinimumSize = New-Object System.Drawing.Size(620,330)
    $form.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9.5)
    $form.BackColor = $script:GUITheme.Page

    $layout = New-Object System.Windows.Forms.TableLayoutPanel
    $layout.Dock = "Fill"
    $layout.ColumnCount = 1
    $layout.RowCount = 5
    $layout.Padding = New-Object System.Windows.Forms.Padding(14)
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,72))) | Out-Null
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,34))) | Out-Null
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,74))) | Out-Null
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,48))) | Out-Null
    $form.Controls.Add($layout)

    $desc = New-Object System.Windows.Forms.Label
    $desc.Dock = "Fill"
    $desc.Text = "$DisplayName`r`n$Description"
    $desc.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10)
    $desc.ForeColor = $script:GUITheme.Text
    $layout.Controls.Add($desc,0,0)

    $argLabel = New-Object System.Windows.Forms.Label
    $argLabel.Dock = "Fill"
    $argLabel.Text = "Launch arguments"
    $argLabel.TextAlign = "BottomLeft"
    $argLabel.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9,[System.Drawing.FontStyle]::Bold)
    $layout.Controls.Add($argLabel,0,1)

    $argBox = New-Object System.Windows.Forms.TextBox
    $argBox.Dock = "Fill"
    $argBox.Multiline = $true
    $argBox.ScrollBars = "Vertical"
    $argBox.Font = New-Object System.Drawing.Font("Consolas",9)
    $argBox.Text = $spec.Args
    $layout.Controls.Add($argBox,0,2)

    $notes = New-Object System.Windows.Forms.Label
    $notes.Dock = "Fill"
    $notes.Text = $spec.Notes
    if($spec.Example){
        $notes.Text += "`r`nExample: $($spec.Example)"
    }
    if($Risky){
        $notes.Text += "`r`nCaution: this tool can change system state."
        $notes.ForeColor = $script:GUITheme.Danger
    }
    else{
        $notes.ForeColor = $script:GUITheme.MutedText
    }
    $layout.Controls.Add($notes,0,3)

    $buttons = New-Object System.Windows.Forms.FlowLayoutPanel
    $buttons.Dock = "Fill"
    $buttons.FlowDirection = "RightToLeft"
    $layout.Controls.Add($buttons,0,4)

    $result = [pscustomobject]@{ Mode="Cancel"; Args=@() }

    foreach($buttonDef in @(
        @{ Text="Launch"; Mode="Launch"; Width=90 },
        @{ Text="Usage / Help"; Mode="Help"; Width=112 },
        @{ Text="Cancel"; Mode="Cancel"; Width=90 }
    )){
        $button = New-Object System.Windows.Forms.Button
        $button.Text = $buttonDef.Text
        $button.Width = $buttonDef.Width
        $button.Height = 30
        $button.Tag = $buttonDef.Mode
        $button.Margin = New-Object System.Windows.Forms.Padding(6)
        $button.Add_Click({
            param($sender,$eventArgs)
            $script:SysinternalsLaunchDialogResult = [pscustomobject]@{
                Mode = [string]$sender.Tag
                Args = @(ConvertFrom-GUICommandLine $argBox.Text)
            }
            $form.DialogResult = [System.Windows.Forms.DialogResult]::OK
            $form.Close()
        })
        [void]$buttons.Controls.Add($button)
    }

    $script:SysinternalsLaunchDialogResult = $result
    [void]$form.ShowDialog($script:Form)
    $result = $script:SysinternalsLaunchDialogResult
    Remove-Variable -Name SysinternalsLaunchDialogResult -Scope Script -ErrorAction SilentlyContinue
    $form.Dispose()

    return $result
}

function Start-GUISysinternalsTool {
    param(
        [string]$Path,
        [string]$DisplayName,
        [bool]$Console,
        [bool]$Risky
    )

    if(!(Test-Path $Path)){
        Add-GUILog "Sysinternals tool not found: $DisplayName"
        return
    }

    try {
        $baseName = ConvertTo-GUISysinternalsBaseName ([IO.Path]::GetFileNameWithoutExtension($Path))
        if(Get-Command Set-CSISysinternalsEulaAccepted -ErrorAction SilentlyContinue){
            Set-CSISysinternalsEulaAccepted -Path $Path
        }

        $category = Get-GUISysinternalsCategory -BaseName $baseName
        $description = Get-GUISysinternalsDescription `
            -BaseName $baseName `
            -FileName ([IO.Path]::GetFileName($Path)) `
            -Category $category `
            -Console $Console `
            -Risky $Risky

        $launchPlan = Show-GUISysinternalsLaunchHelper `
            -DisplayName $DisplayName `
            -BaseName $baseName `
            -Description $description `
            -Console $Console `
            -Risky $Risky

        if(!$launchPlan -or $launchPlan.Mode -eq "Cancel"){
            Add-GUILog "Cancelled Sysinternals tool: $DisplayName"
            return
        }

        $args = @($launchPlan.Args)

        if($launchPlan.Mode -eq "Help"){
            $args = @()
        }
        elseif($Console -and (Get-Command Add-CSISysinternalsEulaArgument -ErrorAction SilentlyContinue)){
            $args = @(Add-CSISysinternalsEulaArgument -Path $Path -Arguments $args)
        }

        if($Risky -and $launchPlan.Mode -eq "Launch"){
            $confirm = [System.Windows.Forms.MessageBox]::Show(
                "$DisplayName can change system state, stress the computer, delete data, or shut down/reboot systems.`r`n`r`nLaunch with the selected arguments?",
                "Sysinternals Caution",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )

            if($confirm -ne [System.Windows.Forms.DialogResult]::Yes){
                Add-GUILog "Cancelled Sysinternals tool: $DisplayName"
                return
            }
        }

        if($Console -or $launchPlan.Mode -eq "Help"){
            $commandParts = @((ConvertTo-GUICommandToken $Path))
            if($args.Count -gt 0){
                $commandParts += @($args | ForEach-Object { ConvertTo-GUICommandToken $_ })
            }
            $commandLine = $commandParts -join " "
            Start-CSIToolProcess -FilePath "cmd.exe" -ArgumentList @("/k",$commandLine) -WorkingDirectory (Split-Path -Parent $Path) -WindowStyle Normal | Out-Null
        }
        else{
            Start-CSIToolProcess -FilePath $Path -ArgumentList $args -WorkingDirectory (Split-Path -Parent $Path) -WindowStyle Normal | Out-Null
        }

        Add-GUILog "Launched Sysinternals: $DisplayName"
    }
    catch {
        Add-GUILog "Failed to launch Sysinternals ${DisplayName}: $($_.Exception.Message)"
    }
}

function Start-GUIQuickDiagnosis {
    $target = "www.microsoft.com"

    if($script:QuickTargetBox -and $script:QuickTargetBox.Text.Trim()){
        $target = $script:QuickTargetBox.Text.Trim()
    }

    $commandText = ". `"$ToolkitLauncher`" -NoConsole; Invoke-QuickDiagnosis -Target `"$target`""

    try {
        if($script:QuickLastDiagnosisLabel -and !$script:QuickLastDiagnosisLabel.IsDisposed){
            $script:QuickLastDiagnosisLabel.Text = "Last Quick Diagnosis: running now..."
        }

        if($script:QuickDiagnosisTimer){
            try {
                $script:QuickDiagnosisTimer.Stop()
                $script:QuickDiagnosisTimer.Dispose()
            }
            catch {}
            $script:QuickDiagnosisTimer = $null
        }

        $script:QuickDiagnosisProcess = Start-CSIToolProcess `
            -FilePath "powershell.exe" `
            -ArgumentList @("-NoProfile","-ExecutionPolicy","Bypass","-Command",$commandText) `
            -WorkingDirectory $SharedToolkitRoot `
            -WindowStyle Hidden `
            -PassThru

        Add-GUILog "Quick Diagnosis started for target: $target"
        Write-GUIToolUsageLog -Tool "Quick Diagnosis" -Action "Started" -Detail "Target=$target"

        $timer = New-Object System.Windows.Forms.Timer
        $timer.Interval = 2000
        $timer.Add_Tick({
            if(!$script:QuickDiagnosisProcess){
                $script:QuickDiagnosisTimer.Stop()
                $script:QuickDiagnosisTimer.Dispose()
                $script:QuickDiagnosisTimer = $null
                Refresh-GUILastQuickDiagnosisLabel
                return
            }

            if($script:QuickDiagnosisProcess.HasExited){
                $exitCode = $script:QuickDiagnosisProcess.ExitCode
                $script:QuickDiagnosisTimer.Stop()
                $script:QuickDiagnosisTimer.Dispose()
                $script:QuickDiagnosisTimer = $null
                $script:QuickDiagnosisProcess = $null
                $script:LatestComputerProfileCache = $null
                $script:LatestComputerProfileCacheTime = [datetime]::MinValue
                Refresh-Fingerprints -Quiet
                Refresh-GUIDismSfcState
                Update-GUIComputerHealthLight
                $script:LatestQuickDiagnosisReport = Get-GUILatestQuickDiagnosisReport
                Refresh-GUILastQuickDiagnosisLabel
                if($exitCode -eq 0){
                    Add-GUILog "Quick Diagnosis completed. Computer profile state refreshed."
                }
                else{
                    Add-GUILog "Quick Diagnosis ended with exit code $exitCode. The last completed scan timestamp has been restored."
                }

                if($script:GuiSettings -and [bool]$script:GuiSettings.autoOpenQuickDiagnosisReport){
                    Open-GUILatestQuickDiagnosisReport
                }
            }
        })
        $script:QuickDiagnosisTimer = $timer
        $script:QuickDiagnosisTimer.Start()

        [System.Windows.Forms.MessageBox]::Show(
            "Quick Diagnosis is running. Use Open Latest Report when it completes.",
            "Quick Diagnosis",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null
    }
    catch {
        Add-GUILog "Failed to start Quick Diagnosis: $($_.Exception.Message)"
    }
}

function Start-GUIDismSfcRepairPath {
    if(!$script:DismSfcRecommended){
        $override = [System.Windows.Forms.MessageBox]::Show(
            "Quick Diagnosis has not indicated that DISM/SFC repair is needed.`r`n`r`nRun the repair path anyway?",
            "Override DISM/SFC Gate",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )

        if($override -ne [System.Windows.Forms.DialogResult]::Yes){
            Add-GUILog "DISM/SFC repair path override cancelled."
            return
        }
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Run DISM CheckHealth, ScanHealth, RestoreHealth, and SFC /scannow now? This can take a while.",
        "DISM/SFC Repair Path",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )

    if($confirm -ne [System.Windows.Forms.DialogResult]::Yes){
        Add-GUILog "DISM/SFC repair path cancelled."
        return
    }

    Start-GUICommandByName -Name "DISM/SFC Repair Path"
}

function Start-ToolkitConsole {
    try {
        Start-CSIToolProcess `
            -FilePath "powershell.exe" `
            -ArgumentList @("-NoProfile","-ExecutionPolicy","Bypass","-File","`"$ToolkitLauncher`"") `
            -WorkingDirectory $SharedToolkitRoot `
            -WindowStyle Normal | Out-Null

        Add-GUILog "Opened full console toolkit."
    }
    catch {
        Add-GUILog "Failed to open console toolkit: $($_.Exception.Message)"
    }
}

function Open-GUIFolder {
    param([string]$Path)

    if(!(Test-Path $Path)){
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }

    Start-CSIToolProcess -FilePath "explorer.exe" -ArgumentList @("`"$Path`"") | Out-Null
    Add-GUILog "Opened folder: $Path"
}

function Open-GUIHelpFile {
    if($CSIFiles.HelpFile -and (Test-Path $CSIFiles.HelpFile)){
        Start-CSIToolProcess -FilePath $CSIFiles.HelpFile | Out-Null
    }
    else{
        Add-GUILog "Help file not found."
    }
}

function Open-GUISettingsPage {
    if(!$script:MainTabs){
        return
    }

    $settingsPage = $script:MainTabs.TabPages | Where-Object { $_.Text -eq "Settings" } | Select-Object -First 1
    if($settingsPage){
        $script:MainTabs.SelectedTab = $settingsPage
        Build-GUITabIfNeeded -Page $settingsPage
        Update-GUIStaticTabStripSelection
    }
}

function Resolve-GUIToolkitPath {
    param([string]$Path)

    if(!$Path){
        return ""
    }

    if([IO.Path]::IsPathRooted($Path)){
        return $Path
    }

    return Join-Path (Split-Path -Parent $SharedToolkitRoot) ($Path.TrimStart(".","\","/"))
}

function Test-GUIFileContainsAsciiPattern {
    param(
        [string]$Path,
        [string]$Pattern
    )

    if(!$Path -or !(Test-Path $Path) -or !$Pattern){
        return $false
    }

    $stream = $null
    try {
        $stream = [System.IO.File]::Open($Path,[System.IO.FileMode]::Open,[System.IO.FileAccess]::Read,[System.IO.FileShare]::ReadWrite)
        $buffer = New-Object byte[] 1048576
        while(($read = $stream.Read($buffer,0,$buffer.Length)) -gt 0){
            $text = [System.Text.Encoding]::ASCII.GetString($buffer,0,$read)
            if($text -match $Pattern){
                return $true
            }
        }
    }
    catch {
        return $false
    }
    finally {
        if($stream){
            $stream.Dispose()
        }
    }

    return $false
}

function Test-GUIInstallerExecutable {
    param(
        [string]$Path,
        [switch]$DeepScan
    )

    if(!$Path){
        return $false
    }

    $extension = [System.IO.Path]::GetExtension($Path).ToLowerInvariant()
    if($extension -match '^\.(msi|msix|msixbundle|appx|appxbundle)$'){
        return $true
    }

    if($extension -ne ".exe" -or !(Test-Path $Path)){
        return $false
    }

    $file = Get-Item -LiteralPath $Path -ErrorAction SilentlyContinue
    if(!$file){
        return $false
    }

    $nameText = "$($file.Name) $($file.BaseName)"
    if($nameText -match '(?i)(^|[-_.\s])(setup|installer|install|bootstrapper|websetup)([-_.\s]|$)'){
        return $true
    }

    $versionInfo = $file.VersionInfo
    $metadataText = @(
        $versionInfo.FileDescription
        $versionInfo.ProductName
        $versionInfo.OriginalFilename
        $versionInfo.InternalName
        $versionInfo.Comments
    ) -join " "

    if($metadataText -match '(?i)(setup|installer|installation wizard|installshield|inno setup|nullsoft|nsis|wix toolset)'){
        return $true
    }

    if($metadataText -match '(?i)(portable|launcher)'){
        return $false
    }

    if(!$DeepScan){
        return $false
    }

    return Test-GUIFileContainsAsciiPattern -Path $Path -Pattern '(?i)(Nullsoft Install System|NSIS Error|Inno Setup|InstallShield Wizard|Choose Install Location|Destination Folder)'
}

function Get-GUICustomTools {
    $tools = @()

    if($CSIFiles.CustomTools -and (Test-Path $CSIFiles.CustomTools)){
        try {
            $manifest = Get-Content -Raw -Path $CSIFiles.CustomTools | ConvertFrom-Json

            foreach($tool in @($manifest.tools)){
                $launchPath = Resolve-GUIToolkitPath $tool.launchPath
                $status = if(Test-Path $launchPath){
                    if(Test-GUIInstallerExecutable -Path $launchPath){"Installer - not portable"}else{"Ready"}
                }
                else{
                    "Missing"
                }

                $tools += [pscustomobject]@{
                    Name = $tool.name
                    Source = $tool.source
                    Version = $tool.version
                    LaunchPath = $launchPath
                    Arguments = $tool.arguments
                    TabOverride = $tool.tabOverride
                    Folder = if($tool.installPath){Resolve-GUIToolkitPath $tool.installPath}else{Split-Path -Parent $launchPath}
                    Status = $status
                }
            }
        }
        catch {
            Add-GUILog "Custom tools manifest could not be read: $($_.Exception.Message)"
        }
    }

    return @($tools | Sort-Object Name)
}

function Refresh-GUICustomTools {
    if(!$script:CustomGrid){
        return
    }

    $script:CustomTools = @(Get-GUICustomTools)
    $script:CustomGrid.Rows.Clear()

    foreach($tool in $script:CustomTools){
        $placement = Get-GUICustomToolPlacement -Tool $tool
        $tabText = if($tool.TabOverride){"$($placement.Tab) (override)"}else{$placement.Tab}
        $rowIndex = $script:CustomGrid.Rows.Add($tool.Name,$tool.Source,$tool.Version,$tool.Status,$tabText)
        $script:CustomGrid.Rows[$rowIndex].Tag = $tool
    }

    Add-GUILog ("Custom tools loaded: {0}" -f $script:CustomTools.Count)
}

function ConvertTo-GUIRelativeToolkitPath {
    param([string]$Path)

    $toolkitBase = Split-Path -Parent $SharedToolkitRoot
    try {
        $baseUri = [Uri]((Resolve-Path $toolkitBase).Path.TrimEnd("\") + "\")
        $pathUri = [Uri]((Resolve-Path $Path).Path)
        return ".\" + ([Uri]::UnescapeDataString($baseUri.MakeRelativeUri($pathUri).ToString()) -replace "/","\")
    }
    catch {
        return $Path
    }
}

function Update-GUICustomToolsManifestEntry {
    param(
        [string]$Name,
        [string]$Version = "",
        [string]$LaunchPath,
        [string]$InstallPath,
        [string]$Source = "Chocolatey",
        [string]$Arguments = "",
        [string]$TabOverride = $null
    )

    if(!$CSIFiles.CustomTools){
        return
    }

    if(!(Test-Path $CSIPaths.Manifests)){
        New-Item -ItemType Directory -Path $CSIPaths.Manifests -Force | Out-Null
    }

    $manifest = [pscustomobject]@{ tools = @() }

    if(Test-Path $CSIFiles.CustomTools){
        try {
            $manifest = Get-Content -Raw -Path $CSIFiles.CustomTools | ConvertFrom-Json
        }
        catch {
            $manifest = [pscustomobject]@{ tools = @() }
        }
    }

    $relativeLaunch = ConvertTo-GUIRelativeToolkitPath $LaunchPath
    $existingEntry = @($manifest.tools | Where-Object {
        $_.name -eq $Name -or $_.launchPath -eq $relativeLaunch
    } | Select-Object -First 1)

    if($null -eq $TabOverride -and $existingEntry.Count -gt 0 -and $existingEntry[0].PSObject.Properties.Name -contains "tabOverride"){
        $TabOverride = [string]$existingEntry[0].tabOverride
    }

    $existing = @($manifest.tools | Where-Object {
        $_.name -ne $Name -and $_.launchPath -ne $relativeLaunch
    })
    $entry = [pscustomobject]@{
        name = $Name
        source = $Source
        version = $Version
        launchPath = $relativeLaunch
        installPath = ConvertTo-GUIRelativeToolkitPath $InstallPath
        arguments = $Arguments
        tabOverride = $TabOverride
    }

    $manifest = [pscustomobject]@{ tools = @($existing + $entry | Sort-Object name) }
    $manifest | ConvertTo-Json -Depth 6 | Set-Content -Path $CSIFiles.CustomTools -Encoding UTF8
}

function Remove-GUICustomToolsManifestEntry {
    param([string]$Name)

    if(!$Name -or !$CSIFiles.CustomTools -or !(Test-Path $CSIFiles.CustomTools)){
        return
    }

    try {
        $manifest = Get-Content -Raw -Path $CSIFiles.CustomTools | ConvertFrom-Json
        $manifest = [pscustomobject]@{
            tools = @($manifest.tools | Where-Object { $_.name -ne $Name } | Sort-Object name)
        }
        $manifest | ConvertTo-Json -Depth 6 | Set-Content -Path $CSIFiles.CustomTools -Encoding UTF8
    }
    catch {
        Add-GUILog "Could not update custom tools manifest: $($_.Exception.Message)"
    }
}

function Set-GUICustomToolsManifestTabOverride {
    param(
        [string]$Name,
        [string]$TabOverride
    )

    if(!$Name -or !$CSIFiles.CustomTools -or !(Test-Path $CSIFiles.CustomTools)){
        return
    }

    try {
        $manifest = Get-Content -Raw -Path $CSIFiles.CustomTools | ConvertFrom-Json
        foreach($tool in @($manifest.tools)){
            if($tool.name -eq $Name){
                if($tool.PSObject.Properties.Name -contains "tabOverride"){
                    $tool.tabOverride = $TabOverride
                }
                else{
                    Add-Member -InputObject $tool -MemberType NoteProperty -Name tabOverride -Value $TabOverride -Force
                }
            }
        }

        $manifest | ConvertTo-Json -Depth 6 | Set-Content -Path $CSIFiles.CustomTools -Encoding UTF8
    }
    catch {
        Add-GUILog "Could not update custom tool tab placement: $($_.Exception.Message)"
    }
}

function Set-GUICustomToolsManifestName {
    param(
        [string]$CurrentName,
        [string]$NewName
    )

    if(!$CurrentName -or [string]::IsNullOrWhiteSpace($NewName) -or !$CSIFiles.CustomTools -or !(Test-Path $CSIFiles.CustomTools)){
        return
    }

    try {
        $manifest = Get-Content -Raw -Path $CSIFiles.CustomTools | ConvertFrom-Json
        foreach($tool in @($manifest.tools)){
            if($tool.name -eq $CurrentName){
                $tool.name = $NewName.Trim()
            }
        }

        $manifest = [pscustomobject]@{ tools = @($manifest.tools | Sort-Object name) }
        $manifest | ConvertTo-Json -Depth 6 | Set-Content -Path $CSIFiles.CustomTools -Encoding UTF8
    }
    catch {
        Add-GUILog "Could not rename custom tool: $($_.Exception.Message)"
    }
}

function Get-SelectedGUICustomTool {
    if(!$script:CustomGrid -or $script:CustomGrid.SelectedRows.Count -eq 0){
        return $null
    }

    return $script:CustomGrid.SelectedRows[0].Tag
}

function Start-SelectedGUICustomTool {
    $tool = Get-SelectedGUICustomTool

    if(!$tool){
        Add-GUILog "Select a custom tool first."
        return
    }

    Start-GUICustomTool -Tool $tool
}

function Set-SelectedGUICustomToolTab {
    $tool = Get-SelectedGUICustomTool

    if(!$tool){
        Add-GUILog "Select a custom tool first."
        return
    }

    $tabs = @("Auto") + @("Analyze","Apps","Choco","Clean Up","Computer Info","Crash","Directory","Discovery","Files","Hardware","Network","Print","Processes","PsExec","Quick Diagnosis","Remote","Repair","Reports","Robocopy","Security","Services","Software","Sysinternals","Wi-Fi","Windows Update" | Sort-Object)

    $dialog = New-Object System.Windows.Forms.Form
    $dialog.Text = "Set Custom Tool Tab Placement"
    $dialog.StartPosition = "CenterParent"
    $dialog.Width = 380
    $dialog.Height = 160
    $dialog.FormBorderStyle = "FixedDialog"
    $dialog.MaximizeBox = $false
    $dialog.MinimizeBox = $false

    $layout = New-Object System.Windows.Forms.TableLayoutPanel
    $layout.Dock = "Fill"
    $layout.Padding = New-Object System.Windows.Forms.Padding(12)
    $layout.RowCount = 3
    $layout.ColumnCount = 1
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,32))) | Out-Null
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,34))) | Out-Null
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,44))) | Out-Null
    $dialog.Controls.Add($layout)

    $label = New-GUILabel "Place '$($tool.Name)' on this tab:"
    $layout.Controls.Add($label,0,0)

    $combo = New-Object System.Windows.Forms.ComboBox
    $combo.DropDownStyle = "DropDownList"
    $combo.Dock = "Fill"
    $combo.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9)
    foreach($tab in $tabs){ [void]$combo.Items.Add($tab) }
    $current = if($tool.TabOverride){$tool.TabOverride}else{"Auto"}
    $combo.SelectedItem = if($tabs -contains $current){$current}else{"Auto"}
    $layout.Controls.Add($combo,0,1)

    $buttons = New-Object System.Windows.Forms.FlowLayoutPanel
    $buttons.Dock = "Fill"
    $buttons.FlowDirection = "RightToLeft"
    $layout.Controls.Add($buttons,0,2)

    $ok = New-Object System.Windows.Forms.Button
    $ok.Text = "Save"
    $ok.Width = 90
    $ok.DialogResult = [System.Windows.Forms.DialogResult]::OK
    [void]$buttons.Controls.Add($ok)

    $cancel = New-Object System.Windows.Forms.Button
    $cancel.Text = "Cancel"
    $cancel.Width = 90
    $cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    [void]$buttons.Controls.Add($cancel)

    $dialog.AcceptButton = $ok
    $dialog.CancelButton = $cancel

    if($dialog.ShowDialog($script:Form) -eq [System.Windows.Forms.DialogResult]::OK){
        $selected = [string]$combo.SelectedItem
        $override = if($selected -eq "Auto"){""}else{$selected}
        Set-GUICustomToolsManifestTabOverride -Name $tool.Name -TabOverride $override
        Add-GUILog "Updated tab placement for $($tool.Name): $selected"
        Refresh-GUICustomTools
        Refresh-GUICustomToolTabs
    }
}

function Rename-SelectedGUICustomTool {
    $tool = Get-SelectedGUICustomTool

    if(!$tool){
        Add-GUILog "Select a custom tool first."
        return
    }

    $dialog = New-Object System.Windows.Forms.Form
    $dialog.Text = "Rename Toolkit App"
    $dialog.StartPosition = "CenterParent"
    $dialog.Width = 420
    $dialog.Height = 170
    $dialog.FormBorderStyle = "FixedDialog"
    $dialog.MaximizeBox = $false
    $dialog.MinimizeBox = $false

    $layout = New-Object System.Windows.Forms.TableLayoutPanel
    $layout.Dock = "Fill"
    $layout.Padding = New-Object System.Windows.Forms.Padding(12)
    $layout.RowCount = 3
    $layout.ColumnCount = 1
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,32))) | Out-Null
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,34))) | Out-Null
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,44))) | Out-Null
    $dialog.Controls.Add($layout)

    $layout.Controls.Add((New-GUILabel "Display name:"),0,0)

    $nameBox = New-GUITextBox $tool.Name
    $layout.Controls.Add($nameBox,0,1)

    $buttons = New-Object System.Windows.Forms.FlowLayoutPanel
    $buttons.Dock = "Fill"
    $buttons.FlowDirection = "RightToLeft"
    $layout.Controls.Add($buttons,0,2)

    $ok = New-GUIButton "Save" { }
    $ok.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $ok.Width = 90
    [void]$buttons.Controls.Add($ok)

    $cancel = New-GUIButton "Cancel" { }
    $cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $cancel.Width = 90
    [void]$buttons.Controls.Add($cancel)

    $dialog.AcceptButton = $ok
    $dialog.CancelButton = $cancel

    if($dialog.ShowDialog($script:Form) -eq [System.Windows.Forms.DialogResult]::OK){
        $newName = $nameBox.Text.Trim()
        if([string]::IsNullOrWhiteSpace($newName)){
            Add-GUILog "Custom tool rename cancelled: name cannot be blank."
            return
        }

        Set-GUICustomToolsManifestName -CurrentName $tool.Name -NewName $newName
        Add-GUILog "Renamed toolkit app '$($tool.Name)' to '$newName'."
        Refresh-GUICustomTools
        Refresh-GUICustomToolTabs
    }
}

function Get-GUICustomToolByLaunchPath {
    param([string]$LaunchPath)

    $resolved = Resolve-GUIToolkitPath $LaunchPath
    return @(Get-GUICustomTools | Where-Object {
        $_.LaunchPath -and $_.LaunchPath.Equals($resolved,[System.StringComparison]::OrdinalIgnoreCase)
    } | Select-Object -First 1)
}

function Get-GUICustomToolByName {
    param([string]$Name)

    if(!$Name){
        return $null
    }

    return @(Get-GUICustomTools | Where-Object {
        $_.Name -and $_.Name.Equals($Name,[System.StringComparison]::OrdinalIgnoreCase)
    } | Select-Object -First 1)
}

function Start-GUICustomToolByName {
    param([string]$Name)

    $tool = Get-GUICustomToolByName -Name $Name
    if(!$tool){
        Add-GUILog "Custom tool is not installed in the toolkit: $Name"
        return
    }

    Start-GUICustomTool -Tool $tool
}

function Start-GUICustomToolByLaunchPath {
    param([string]$LaunchPath)

    $tool = Get-GUICustomToolByLaunchPath -LaunchPath $LaunchPath
    if(!$tool){
        Add-GUILog "Custom tool is no longer registered: $LaunchPath"
        return
    }

    Start-GUICustomTool -Tool $tool
}

function Test-GUIRequiresBundledDotNet {
    param([string]$LaunchPath)

    if(!$LaunchPath -or !(Test-Path $LaunchPath)){
        return $false
    }

    $folder = Split-Path -Parent $LaunchPath
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($LaunchPath)
    $runtimeConfig = Join-Path $folder "$baseName.runtimeconfig.json"

    if(Test-Path $runtimeConfig){
        return $true
    }

    return @(Get-ChildItem -Path $folder -Filter *.runtimeconfig.json -File -ErrorAction SilentlyContinue).Count -gt 0
}

function Start-GUIDotNetPortableProcess {
    param(
        [string]$FilePath,
        [string[]]$ArgumentList = @(),
        [string]$WorkingDirectory = ""
    )

    $dotNetRoot = Join-Path $CSIPaths.Root "ExternalTools\DotNet"
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $FilePath
    $startInfo.WorkingDirectory = if($WorkingDirectory){$WorkingDirectory}else{Split-Path -Parent $FilePath}
    $startInfo.UseShellExecute = $false

    foreach($arg in @($ArgumentList | Where-Object { $null -ne $_ -and $_ -ne "" })){
        [void]$startInfo.ArgumentList.Add($arg)
    }

    if(Test-Path (Join-Path $dotNetRoot "dotnet.exe")){
        $startInfo.EnvironmentVariables["DOTNET_ROOT"] = $dotNetRoot
        $startInfo.EnvironmentVariables["DOTNET_ROOT_X64"] = $dotNetRoot
        $startInfo.EnvironmentVariables["DOTNET_ROOT_X86"] = $dotNetRoot
        $startInfo.EnvironmentVariables["DOTNET_MULTILEVEL_LOOKUP"] = "0"
        $startInfo.EnvironmentVariables["PATH"] = "$dotNetRoot;$($startInfo.EnvironmentVariables["PATH"])"
    }

    [System.Diagnostics.Process]::Start($startInfo) | Out-Null
}

function Start-GUICustomPowerShellTool {
    param([pscustomobject]$Tool)

    $toolLabel = if($Tool.Name){[string]$Tool.Name}else{"PowerShell Tool"}
    $scriptPath = [string]$Tool.LaunchPath
    $workingFolder = Split-Path -Parent $scriptPath
    $session = New-CSITempOutputSession -ToolName $toolLabel
    $runnerPath = Join-Path $session.Path "run-custom-powershell-tool.ps1"
    $argsPath = Join-Path $session.Path "arguments.json"
    $arguments = @()

    if($Tool.Arguments){
        $arguments = @([string]$Tool.Arguments)
    }

    $arguments | ConvertTo-Json -Depth 3 | Set-Content -Path $argsPath -Encoding UTF8

    $commandText = @"
`$ErrorActionPreference = "Continue"
`$metadata = [ordered]@{
    Tool = "$($toolLabel.Replace('"','\"'))"
    ScriptPath = "$($scriptPath.Replace('"','\"'))"
    StartedAt = (Get-Date).ToString("s")
    CompletedAt = ""
    Status = "Running"
    ErrorCount = 0
    ComputerName = `$env:COMPUTERNAME
    UserName = [Security.Principal.WindowsIdentity]::GetCurrent().Name
}

try {
    . "$ToolkitLauncher" -NoConsole
    `$metadata | ConvertTo-Json -Depth 6 | Set-Content -Path "$($session.Metadata)" -Encoding UTF8
    Start-Transcript -Path "$($session.Transcript)" -Force | Out-Null
    Set-Location -LiteralPath "$($workingFolder.Replace('"','\"'))"
    Write-Host ""
    Write-Host "Running: $($toolLabel.Replace('"','\"'))" -ForegroundColor Cyan
    Write-Host "Script : $($scriptPath.Replace('"','\"'))" -ForegroundColor DarkCyan
    Write-Host "Output : $($session.Path)" -ForegroundColor DarkCyan
    Write-Host ""

    `$toolArgs = @()
    try {
        `$rawArgs = Get-Content -Raw -Path "$argsPath" -ErrorAction Stop | ConvertFrom-Json
        if(`$rawArgs){ `$toolArgs = @(`$rawArgs) }
    }
    catch {}

    if(`$toolArgs.Count -gt 0){
        & "$($scriptPath.Replace('"','\"'))" @toolArgs
    }
    else{
        & "$($scriptPath.Replace('"','\"'))"
    }

    `$metadata.Status = "Completed"
    `$metadata.CompletedAt = (Get-Date).ToString("s")
}
catch {
    Write-Host ""
    Write-Host "PowerShell script app failed." -ForegroundColor Red
    Write-Host `$_.Exception.Message -ForegroundColor Red
    `$metadata.Status = "Error"
    `$metadata.LastError = `$_.Exception.Message
    `$metadata.CompletedAt = (Get-Date).ToString("s")
}
finally {
    try { Stop-Transcript | Out-Null } catch {}
    try {
        if(Test-Path "$($session.Transcript)"){
            `$transcriptText = Get-Content -Raw -Path "$($session.Transcript)" -ErrorAction SilentlyContinue
            `$errorMatches = @([regex]::Matches([string]`$transcriptText,'(?im)\b(error|exception|failed|cannot find|not recognized|access denied)\b'))
            `$metadata.ErrorCount = `$errorMatches.Count
            if(`$metadata.Status -eq "Completed" -and `$errorMatches.Count -gt 0){
                `$metadata.Status = "CompletedWithWarnings"
            }
        }

        `$metadata | ConvertTo-Json -Depth 6 | Set-Content -Path "$($session.Metadata)" -Encoding UTF8

        if(Get-Command Set-CSIComputerStateToolOutput -ErrorAction SilentlyContinue){
            `$stateArgs = @{
                ToolName = "$($toolLabel.Replace('"','\"'))"
                SessionPath = "$($session.Path)"
                TranscriptPath = "$($session.Transcript)"
                MetadataPath = "$($session.Metadata)"
                ComputerName = `$env:COMPUTERNAME
            }
            [void](Set-CSIComputerStateToolOutput @stateArgs)
        }
    }
    catch {}

    Write-Host ""
    Write-Host "Output saved to:" -ForegroundColor Green
    Write-Host "$($session.Path)"
    Write-Host ""
    [void](Read-Host "Press ENTER to close")
}
"@

    $commandText | Set-Content -Path $runnerPath -Encoding UTF8

    Start-CSIToolProcess `
        -FilePath "powershell.exe" `
        -ArgumentList @("-NoProfile","-STA","-ExecutionPolicy","Bypass","-File","`"$runnerPath`"") `
        -WorkingDirectory $workingFolder `
        -WindowStyle Normal | Out-Null

    Add-GUILog "Launched PowerShell script app: $toolLabel"
    Add-GUILog "Temp output session: $($session.Path)"
}

function Start-GUICustomTool {
    param([pscustomobject]$Tool)

    if(!$Tool){
        Add-GUILog "No custom tool was selected."
        return
    }

    if(!(Test-Path $Tool.LaunchPath)){
        Add-GUILog "Custom tool missing and will not launch: $($Tool.Name)"
        Write-GUIToolUsageLog -Tool $Tool.Name -Action "Missing" -Detail $Tool.LaunchPath -Level "ERROR"
        return
    }

    if(Test-GUIInstallerExecutable -Path $Tool.LaunchPath -DeepScan){
        Add-GUILog "Blocked installer-style custom tool: $($Tool.Name)"
        Write-GUIToolUsageLog -Tool $Tool.Name -Action "BlockedInstaller" -Detail $Tool.LaunchPath -Level "WARN"
        [System.Windows.Forms.MessageBox]::Show(
            "$($Tool.Name) points to an installer, not a portable runnable app.`r`n`r`nThe toolkit blocked it so it does not install software onto the workstation. Remove or replace this entry with a portable executable.",
            "Installer Blocked",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return
    }

    $args = @()
    if($Tool.Arguments){
        $args = @($Tool.Arguments)
    }

    $folder = Split-Path -Parent $Tool.LaunchPath
    $extension = [System.IO.Path]::GetExtension($Tool.LaunchPath).ToLowerInvariant()

    if($Tool.LaunchPath -match '(?i)\\BulkUninstaller\\BCUninstaller\.exe$'){
        Start-GUIBulkUninstaller
    }
    elseif($extension -eq ".ps1"){
        Start-GUICustomPowerShellTool -Tool $Tool
    }
    elseif($extension -eq ".bat" -or $extension -eq ".cmd"){
        Start-CSIToolProcess -FilePath "cmd.exe" -ArgumentList (@("/k","`"$($Tool.LaunchPath)`"") + $args) -WorkingDirectory $folder -WindowStyle Normal | Out-Null
    }
    elseif(Test-GUIRequiresBundledDotNet -LaunchPath $Tool.LaunchPath){
        Start-GUIDotNetPortableProcess -FilePath $Tool.LaunchPath -ArgumentList $args -WorkingDirectory $folder
    }
    else {
        Start-CSIToolProcess -FilePath $Tool.LaunchPath -ArgumentList $args -WorkingDirectory $folder -WindowStyle Normal | Out-Null
    }

    Add-GUILog "Launched custom tool: $($Tool.Name)"
    Write-GUIToolUsageLog -Tool $Tool.Name -Action "Launch" -Detail $Tool.LaunchPath
}

function Start-GUIFirefoxPortable {
    $firefoxPath = Join-Path $CSIPaths.Custom "FirefoxPortable\FirefoxPortable.exe"

    if(!(Test-Path $firefoxPath)){
        Add-GUILog "Firefox Portable is not installed in the toolkit: $firefoxPath"
        [System.Windows.Forms.MessageBox]::Show(
            "Firefox Portable was not found in the toolkit.`r`n`r`nExpected path:`r`n$firefoxPath",
            "Firefox Portable Missing",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return
    }

    Start-CSIToolProcess `
        -FilePath $firefoxPath `
        -WorkingDirectory (Split-Path -Parent $firefoxPath) `
        -WindowStyle Normal | Out-Null

    Add-GUILog "Launched Firefox Portable."
    Write-GUIToolUsageLog -Tool "Firefox Portable" -Action "Launch" -Detail $firefoxPath
}

function Start-GUIBulkUninstaller {
    $bcuPath = Join-Path $CSIPaths.Custom "BulkUninstaller\BCUninstaller.exe"
    $dotNetRoot = Join-Path $CSIPaths.Root "ExternalTools\DotNet"

    if(!(Test-Path $bcuPath)){
        Add-GUILog "Bulk Uninstaller is not installed in the toolkit: $bcuPath"
        [System.Windows.Forms.MessageBox]::Show(
            "Bulk Uninstaller was not found in the toolkit.`r`n`r`nExpected path:`r`n$bcuPath",
            "Bulk Uninstaller Missing",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return
    }

    try {
        $startInfo = New-Object System.Diagnostics.ProcessStartInfo
        $startInfo.FileName = $bcuPath
        $startInfo.WorkingDirectory = Split-Path -Parent $bcuPath
        $startInfo.UseShellExecute = $false

        if(Test-Path (Join-Path $dotNetRoot "dotnet.exe")){
            $startInfo.EnvironmentVariables["DOTNET_ROOT"] = $dotNetRoot
            $startInfo.EnvironmentVariables["DOTNET_ROOT_X64"] = $dotNetRoot
            $startInfo.EnvironmentVariables["DOTNET_ROOT_X86"] = $dotNetRoot
            $startInfo.EnvironmentVariables["DOTNET_MULTILEVEL_LOOKUP"] = "0"
            $startInfo.EnvironmentVariables["PATH"] = "$dotNetRoot;$($startInfo.EnvironmentVariables["PATH"])"
        }

        [System.Diagnostics.Process]::Start($startInfo) | Out-Null
    }
    catch {
        Add-GUILog "Failed to launch Bulk Uninstaller: $($_.Exception.Message)"
        [System.Windows.Forms.MessageBox]::Show(
            "Bulk Uninstaller failed to launch.`r`n`r`n$($_.Exception.Message)",
            "Bulk Uninstaller",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
        return
    }

    Add-GUILog "Launched Bulk Uninstaller."
    Write-GUIToolUsageLog -Tool "Bulk Uninstaller" -Action "Launch" -Detail $bcuPath
}

function Open-SelectedGUICustomToolFolder {
    $tool = Get-SelectedGUICustomTool

    if(!$tool){
        Add-GUILog "Select a custom tool first."
        return
    }

    Open-GUIFolder $tool.Folder
}

function Remove-SelectedGUICustomTool {
    $tool = Get-SelectedGUICustomTool

    if(!$tool){
        Add-GUILog "Select a custom tool first."
        return
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Remove '$($tool.Name)' from the toolbox?`r`n`r`nThis removes its manifest entry and can delete its Custom folder.",
        "Remove Custom Tool",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )

    if($confirm -ne [System.Windows.Forms.DialogResult]::Yes){
        return
    }

    try {
        Remove-GUICustomToolsManifestEntry -Name $tool.Name

        $folder = $tool.Folder
        if($folder -and (Test-Path $folder) -and $folder.StartsWith($CSIPaths.Custom,[System.StringComparison]::OrdinalIgnoreCase)){
            $deleteFolder = [System.Windows.Forms.MessageBox]::Show(
                "Delete the toolbox folder too?`r`n`r`n$folder",
                "Delete Custom Tool Files",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Question
            )

            if($deleteFolder -eq [System.Windows.Forms.DialogResult]::Yes){
                Remove-Item -LiteralPath $folder -Recurse -Force -ErrorAction SilentlyContinue
            }
        }

        Refresh-GUICustomTools
        Refresh-GUICustomToolTabs
        Add-GUILog "Removed custom tool: $($tool.Name)"
    }
    catch {
        Add-GUILog "Failed to remove custom tool: $($_.Exception.Message)"
    }
}

function Get-SelectedFingerprint {
    if(!$script:FingerprintGrid -or $script:FingerprintGrid.SelectedRows.Count -eq 0){
        return $null
    }

    $row = $script:FingerprintGrid.SelectedRows[0]

    if($row.Tag){
        return $row.Tag
    }

    $index = $row.Index

    if($index -ge 0 -and $index -lt $script:Fingerprints.Count){
        return $script:Fingerprints[$index]
    }

    return $null
}

function Refresh-Fingerprints {
    param([switch]$Quiet)

    if(!$script:FingerprintGrid){
        return
    }

    $script:Fingerprints = @(Get-CSIStoredFingerprints)

    $script:FingerprintGrid.Rows.Clear()
    $script:FingerprintGrid.Columns.Clear()

    [void]$script:FingerprintGrid.Columns.Add("ComputerName","Computer")
    [void]$script:FingerprintGrid.Columns.Add("CapturedAt","Captured")
    [void]$script:FingerprintGrid.Columns.Add("UserName","User")
    [void]$script:FingerprintGrid.Columns.Add("Domain","Domain")

    foreach($fingerprint in $script:Fingerprints){
        $rowIndex = $script:FingerprintGrid.Rows.Add(
            $fingerprint.ComputerName,
            $fingerprint.CapturedAt,
            $fingerprint.UserName,
            $fingerprint.Domain
        )

        $script:FingerprintGrid.Rows[$rowIndex].Tag = $fingerprint
    }

    foreach($column in $script:FingerprintGrid.Columns){
        $column.AutoSizeMode = "Fill"
    }

    if($script:FingerprintGrid.Rows.Count -gt 0){
        $script:FingerprintGrid.Rows[0].Selected = $true
    }

    if(!$Quiet){
        Add-GUILog ("Computer profiles loaded: {0}" -f $script:Fingerprints.Count)
    }
}

function Open-SelectedFingerprintReport {
    $fingerprint = Get-SelectedFingerprint

    if(!$fingerprint){
        Add-GUILog "Select a computer profile first."
        return
    }

    Open-CSIComputerFingerprintReport -Path $fingerprint.Path
    Add-GUILog "Opened computer profile report: $($fingerprint.ComputerName)"
}

function Delete-SelectedFingerprint {
    $fingerprint = Get-SelectedFingerprint

    if(!$fingerprint){
        Add-GUILog "Select a computer profile first."
        return
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Delete computer profile for $($fingerprint.ComputerName)?",
        "Delete Computer Profile",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )

    if($confirm -ne [System.Windows.Forms.DialogResult]::Yes){
        Add-GUILog "Delete cancelled."
        return
    }

    $htmlPath = [IO.Path]::ChangeExtension($fingerprint.Path, ".html")

    Remove-Item -Path $fingerprint.Path -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $htmlPath -Force -ErrorAction SilentlyContinue

    Add-GUILog "Deleted computer profile: $($fingerprint.ComputerName)"
    Refresh-Fingerprints
}

function Take-FingerprintFromGUI {
    Start-GUIQuickDiagnosis
}

function Get-GUIChocoPath {
    $choco = Get-CSIChocolateyCommand

    if($script:ChocoStatusLabel){
        if($choco){
            $script:ChocoStatusLabel.Text = "Chocolatey ready: $choco"
            $script:ChocoStatusLabel.ForeColor = $script:GUITheme.Success
        }
        else{
            $script:ChocoStatusLabel.Text = "Chocolatey is not installed or not on PATH."
            $script:ChocoStatusLabel.ForeColor = $script:GUITheme.Warning
        }
    }

    return $choco
}

function Refresh-GUIChocoStatus {
    [void](Get-GUIChocoPath)
    Add-GUILog "Refreshed Chocolatey status."
}

function Start-GUIChocolateyInstall {
    $existing = Get-GUIChocoPath

    if($existing){
        [System.Windows.Forms.MessageBox]::Show(
            "Chocolatey is already installed.`r`n`r`n$existing",
            "Chocolatey Ready",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null
        return
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Install Chocolatey now? This requires administrator rights and downloads the official installer from community.chocolatey.org.",
        "Install Chocolatey",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    if($confirm -ne [System.Windows.Forms.DialogResult]::Yes){
        Add-GUILog "Chocolatey install cancelled."
        return
    }

    $installCommand = @"
try {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Host ''
    Write-Host 'Chocolatey install command finished.'
}
catch {
    Write-Host ''
    Write-Host 'Chocolatey install failed.' -ForegroundColor Red
    Write-Host `$_.Exception.Message
}
finally {
    Write-Host ''
    Read-Host 'Press ENTER to close'
}
"@

    try {
        Start-CSIToolProcess `
            -FilePath "powershell.exe" `
            -ArgumentList @("-NoProfile","-ExecutionPolicy","Bypass","-Command",$installCommand) `
            -WindowStyle Normal `
            -Elevated:(!(Test-GUIAdministrator)) | Out-Null
        Add-GUILog "Started Chocolatey installer."
    }
    catch {
        Add-GUILog "Failed to start Chocolatey installer: $($_.Exception.Message)"
    }
}

function Search-GUIChocoPackages {
    $query = if($script:ChocoSearchBox){$script:ChocoSearchBox.Text.Trim()}else{""}

    if(!$query){
        Add-GUILog "Enter a Chocolatey package search term."
        return
    }

    $choco = Get-GUIChocoPath

    if(!$choco){
        Add-GUILog "Chocolatey is not installed."
        return
    }

    try {
        Add-GUILog "Searching Chocolatey for: $query"

        $raw = & $choco search $query --limit-output --page-size=30 2>&1
        $packages = @()

        foreach($line in $raw){
            if($line -notmatch "\|"){
                continue
            }

            $parts = $line.ToString().Split("|")
            $packages += [pscustomobject]@{
                Name = $parts[0]
                Version = if($parts.Count -gt 1){$parts[1]}else{""}
            }
        }

        $script:ChocoPackages = @($packages)
        $script:ChocoGrid.Rows.Clear()

        foreach($package in $script:ChocoPackages){
            $rowIndex = $script:ChocoGrid.Rows.Add($package.Name,$package.Version)
            $script:ChocoGrid.Rows[$rowIndex].Tag = $package
        }

        Add-GUILog ("Chocolatey packages found: {0}" -f $script:ChocoPackages.Count)
    }
    catch {
        Add-GUILog "Chocolatey search failed: $($_.Exception.Message)"
    }
}

function Refresh-GUIChocoInstalledPackages {
    $choco = Get-GUIChocoPath

    if(!$choco){
        Add-GUILog "Chocolatey is not installed."
        return
    }

    try {
        Add-GUILog "Scanning installed Chocolatey packages..."
        $raw = & $choco list --local-only --limit-output 2>&1
        $installed = @()

        foreach($line in $raw){
            if($line -notmatch "\|"){
                continue
            }

            $parts = $line.ToString().Split("|")
            $installed += [pscustomobject]@{
                Name = $parts[0]
                Version = if($parts.Count -gt 1){$parts[1]}else{""}
                Available = ""
            }
        }

        $outdatedRaw = & $choco outdated --limit-output 2>&1

        foreach($line in $outdatedRaw){
            if($line -notmatch "\|"){
                continue
            }

            $parts = $line.ToString().Split("|")
            $packageName = $parts[0]
            $available = if($parts.Count -gt 2){$parts[2]}else{""}
            $match = $installed | Where-Object { $_.Name -eq $packageName } | Select-Object -First 1

            if($match){
                $match.Available = $available
            }
        }

        $script:ChocoInstalledPackages = @($installed | Sort-Object Name)

        if($script:ChocoInstalledGrid){
            $script:ChocoInstalledGrid.Rows.Clear()

            foreach($package in $script:ChocoInstalledPackages){
                $state = if($package.Available){"Update available"}else{"Current"}
                $rowIndex = $script:ChocoInstalledGrid.Rows.Add($package.Name,$package.Version,$package.Available,$state)
                $script:ChocoInstalledGrid.Rows[$rowIndex].Tag = $package
            }
        }

        Add-GUILog ("Installed Chocolatey packages: {0}" -f $script:ChocoInstalledPackages.Count)
    }
    catch {
        Add-GUILog "Chocolatey installed-package scan failed: $($_.Exception.Message)"
    }
}

function Get-SelectedGUIChocoInstalledPackage {
    if(!$script:ChocoInstalledGrid -or $script:ChocoInstalledGrid.SelectedRows.Count -eq 0){
        return $null
    }

    return $script:ChocoInstalledGrid.SelectedRows[0].Tag
}

function Test-GUIChocoPackageInstalled {
    param([string]$PackageName)

    $choco = Get-GUIChocoPath
    if(!$choco -or !$PackageName){
        return $false
    }

    try {
        $raw = & $choco list --local-only --exact $PackageName --limit-output 2>$null
        $escaped = [regex]::Escape($PackageName)
        return [bool](@($raw | Where-Object { $_ -match "^$escaped\|" }).Count)
    }
    catch {
        return $false
    }
}

function Start-GUIChocoAction {
    param(
        [string]$PackageName,
        [ValidateSet("install","upgrade","uninstall")]
        [string]$Action
    )

    $choco = Get-GUIChocoPath

    if(!$choco){
        Add-GUILog "Chocolatey is not installed."
        return
    }

    if(!(Test-GUIAdministrator)){
        [System.Windows.Forms.MessageBox]::Show(
            "Chocolatey computer package actions need the toolkit running elevated.`r`n`r`nRestart the toolkit as administrator, then try again.",
            "Elevation Required",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        Add-GUILog "Chocolatey $Action requires elevated toolkit session."
        return
    }

    if($script:ChocoActionJob -and $script:ChocoActionJob.State -notin @("Completed","Failed","Stopped")){
        [System.Windows.Forms.MessageBox]::Show(
            "A Chocolatey action is already running:`r`n`r`n$($script:ChocoActionName) $($script:ChocoActionPackage)",
            "Chocolatey Busy",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null
        return
    }

    if($script:ChocoActionTimer){
        try {
            $script:ChocoActionTimer.Stop()
            $script:ChocoActionTimer.Dispose()
        }
        catch {}
        $script:ChocoActionTimer = $null
    }

    if($script:ChocoActionJob){
        try {
            Remove-Job -Job $script:ChocoActionJob -Force -ErrorAction SilentlyContinue
        }
        catch {}
        $script:ChocoActionJob = $null
    }

    $session = New-CSITempOutputSession -ToolName "Chocolatey-$Action-$PackageName"
    $script:ChocoActionSession = $session
    $script:ChocoActionName = $Action
    $script:ChocoActionPackage = $PackageName

    try {
        $script:ChocoActionJob = Start-Job -ArgumentList $choco,$Action,$PackageName,$session.Transcript,$session.Path -ScriptBlock {
            param(
                [string]$ChocoPath,
                [string]$JobAction,
                [string]$JobPackage,
                [string]$TranscriptPath,
                [string]$SessionPath
            )

            $started = Get-Date
            $output = @()
            $exitCode = 9999
            $errorText = ""

            try {
                $output += "Chocolatey $JobAction`: $JobPackage"
                $output += "Started: $($started.ToString('s'))"
                $output += ""
                $output += (& $ChocoPath $JobAction $JobPackage --yes --no-progress 2>&1 | ForEach-Object { $_.ToString() })
                $exitCode = $LASTEXITCODE
                $output += ""
                $output += "Finished: $((Get-Date).ToString('s'))"
                $output += "ExitCode: $exitCode"
            }
            catch {
                $errorText = $_.Exception.Message
                $output += ""
                $output += "ERROR: $errorText"
            }

            try {
                $output | Set-Content -Path $TranscriptPath -Encoding UTF8
            }
            catch {}

            [pscustomobject]@{
                Action = $JobAction
                Package = $JobPackage
                ExitCode = $exitCode
                Error = $errorText
                Transcript = $TranscriptPath
                Session = $SessionPath
            }
        }

        $script:ChocoActionTimer = New-Object System.Windows.Forms.Timer
        $script:ChocoActionTimer.Interval = 1000
        $script:ChocoActionTimer.Add_Tick({
            try {
                if(!$script:ChocoActionJob){
                    return
                }

                if($script:ChocoActionJob.State -notin @("Completed","Failed","Stopped")){
                    return
                }

                $result = $null
                if($script:ChocoActionJob.State -eq "Completed"){
                    $result = @(Receive-Job -Job $script:ChocoActionJob -ErrorAction SilentlyContinue | Select-Object -Last 1)
                }

                try {
                    Remove-Job -Job $script:ChocoActionJob -Force -ErrorAction SilentlyContinue
                }
                catch {}
                $script:ChocoActionJob = $null

                if($script:ChocoActionTimer){
                    $script:ChocoActionTimer.Stop()
                    $script:ChocoActionTimer.Dispose()
                    $script:ChocoActionTimer = $null
                }

                if($result){
                    if($result.ExitCode -eq 0){
                        Add-GUILog "Chocolatey $($result.Action) completed: $($result.Package)"
                    }
                    else{
                        Add-GUILog "Chocolatey $($result.Action) finished with exit code $($result.ExitCode): $($result.Package)"
                    }
                }
                else{
                    Add-GUILog "Chocolatey $($script:ChocoActionName) did not return a result: $($script:ChocoActionPackage)"
                }

                Refresh-GUIChocoInstalledPackages
            }
            catch {
                Add-GUILog "Chocolatey action monitor failed: $($_.Exception.Message)"
                try {
                    if($script:ChocoActionTimer){
                        $script:ChocoActionTimer.Stop()
                        $script:ChocoActionTimer.Dispose()
                        $script:ChocoActionTimer = $null
                    }
                }
                catch {}
            }
        })
        $script:ChocoActionTimer.Start()

        Add-GUILog "Started Chocolatey $Action in background: $PackageName"
        Write-GUIToolUsageLog -Tool "Chocolatey" -Action $Action -Detail $PackageName
    }
    catch {
        Add-GUILog "Failed to start Chocolatey $Action for ${PackageName}: $($_.Exception.Message)"
        Write-GUIToolUsageLog -Tool "Chocolatey" -Action "$Action-start-failed" -Detail $_.Exception.Message -Level "ERROR"
        [System.Windows.Forms.MessageBox]::Show(
            "Could not start Chocolatey $Action for '$PackageName'.`r`n`r`n$($_.Exception.Message)",
            "Chocolatey Action Failed",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
}

function Get-SelectedGUIChocoPackage {
    if(!$script:ChocoGrid -or $script:ChocoGrid.SelectedRows.Count -eq 0){
        return $null
    }

    return $script:ChocoGrid.SelectedRows[0].Tag
}

function Test-GUIChocoPackagePortable {
    param([pscustomobject]$Package)

    if(!$Package){
        return $false
    }

    if($Package.Name -match '(?i)(portable|\\.portable|portableapps)'){
        return $true
    }

    $choco = Get-GUIChocoPath
    if(!$choco){
        return $false
    }

    try {
        $info = (& $choco info $Package.Name 2>&1) -join " "
        return ($info -match '(?i)\bportable\b|portableapps|standalone|no install required')
    }
    catch {
        return $false
    }
}

function Get-GUIChocoPackageInfoText {
    param([string]$PackageName)

    $choco = Get-GUIChocoPath
    if(!$choco -or !$PackageName){
        return ""
    }

    try {
        return ((& $choco info $PackageName 2>&1) -join "`n")
    }
    catch {
        return ""
    }
}

function Get-GUIChocoPortableInstallArguments {
    param([pscustomobject]$Package)

    $args = @("install",$Package.Name,"--yes","--no-progress")
    $info = Get-GUIChocoPackageInfoText -PackageName $Package.Name

    if($info -match '(?i)--params\s+["'']?/Portable' -or $info -match '(?i)\s/Portable\s'){
        $args += @("--params","/Portable")
    }

    return $args
}

function Test-GUIChocoDownloadCommand {
    param([string]$ChocoPath)

    if(!$ChocoPath){
        return $false
    }

    try {
        $output = & $ChocoPath download --help 2>&1
        $text = ($output | Out-String)
        return ($LASTEXITCODE -eq 0 -and $text -notmatch "Could not find a command registered")
    }
    catch {
        return $false
    }
}

function Update-GUIChocolateyForDownloadCommand {
    param(
        [string]$ChocoPath,
        [pscustomobject]$Session
    )

    if($script:ChocoDownloadUpgradeAttempted){
        return
    }

    $script:ChocoDownloadUpgradeAttempted = $true

    if(!(Test-GUIAdministrator)){
        Add-GUILog "Chocolatey download command is unavailable. Skipping Chocolatey self-upgrade because the GUI is not elevated."
        return
    }

    Add-GUILog "Chocolatey download command is unavailable. Attempting Chocolatey self-upgrade first."
    $upgradeOutput = & $ChocoPath upgrade chocolatey --yes --no-progress 2>&1
    $upgradeExitCode = $LASTEXITCODE

    if($Session -and $Session.Transcript){
        Add-Content -Path $Session.Transcript -Encoding UTF8 -Value ""
        Add-Content -Path $Session.Transcript -Encoding UTF8 -Value "Chocolatey self-upgrade for download command"
        Add-Content -Path $Session.Transcript -Encoding UTF8 -Value ($upgradeOutput | Out-String)
    }

    if($upgradeExitCode -eq 0){
        Add-GUILog "Chocolatey self-upgrade completed. Rechecking download command."
    }
    else{
        Add-GUILog "Chocolatey self-upgrade returned exit code $upgradeExitCode. Falling back to direct package extraction."
    }
}

function Save-GUIChocoPackageViaChocoDownload {
    param(
        [pscustomobject]$Package,
        [pscustomobject]$Session
    )

    $choco = Get-GUIChocoPath
    if(!$choco){
        throw "Chocolatey is not installed."
    }

    if(!(Test-GUIChocoDownloadCommand -ChocoPath $choco)){
        Update-GUIChocolateyForDownloadCommand -ChocoPath $choco -Session $Session
    }

    if(!(Test-GUIChocoDownloadCommand -ChocoPath $choco)){
        throw "Chocolatey download command is not available."
    }

    $downloadRoot = Join-Path $Session.Path "choco-download-command"
    New-Item -ItemType Directory -Path $downloadRoot -Force | Out-Null

    $args = @("download",$Package.Name,"--output-directory",$downloadRoot,"--yes","--no-progress")
    if($Package.Version){
        $args += @("--version",$Package.Version)
    }

    Add-GUILog "Downloading package with Chocolatey download command: $($Package.Name)"
    $output = & $choco @args 2>&1
    $exitCode = $LASTEXITCODE

    if($Session -and $Session.Transcript){
        Add-Content -Path $Session.Transcript -Encoding UTF8 -Value ""
        Add-Content -Path $Session.Transcript -Encoding UTF8 -Value "Chocolatey download command: $($args -join ' ')"
        Add-Content -Path $Session.Transcript -Encoding UTF8 -Value ($output | Out-String)
    }

    if($exitCode -ne 0){
        $tail = (($output | Select-Object -Last 8) -join "`r`n").Trim()
        throw "Chocolatey download command failed with exit code $exitCode.`r`n$tail"
    }

    $nupkg = Get-ChildItem -Path $downloadRoot -Filter "*.nupkg" -Recurse -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if(!$nupkg){
        throw "Chocolatey download command completed but no .nupkg was found."
    }

    $extractRoot = Join-Path $Session.Path "package-expanded"
    New-Item -ItemType Directory -Path $extractRoot -Force | Out-Null
    Expand-Archive -Path $nupkg.FullName -DestinationPath $extractRoot -Force

    return [pscustomobject]@{
        PackagePath = $nupkg.FullName
        ExtractRoot = $extractRoot
    }
}

function Save-GUIChocoPackageToTemp {
    param(
        [pscustomobject]$Package,
        [pscustomobject]$Session
    )

    if(!$Package -or !$Package.Name){
        throw "No Chocolatey package was selected."
    }

    if(!$Session -or !$Session.Path){
        throw "No temp output session is available for package download."
    }

    try {
        return Save-GUIChocoPackageViaChocoDownload -Package $Package -Session $Session
    }
    catch {
        Add-GUILog "Chocolatey download command path unavailable: $($_.Exception.Message)"
        if($Session -and $Session.Transcript){
            Add-Content -Path $Session.Transcript -Encoding UTF8 -Value ""
            Add-Content -Path $Session.Transcript -Encoding UTF8 -Value "Chocolatey download command fallback: $($_.Exception.Message)"
        }
    }

    $packageRoot = Join-Path $Session.Path "package-download"
    $extractRoot = Join-Path $Session.Path "package-expanded"
    New-Item -ItemType Directory -Path $packageRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $extractRoot -Force | Out-Null

    $safePackageName = ($Package.Name -replace '[^A-Za-z0-9._-]+','_').Trim('_')
    if(!$safePackageName){
        $safePackageName = "package"
    }

    $nupkgPath = Join-Path $packageRoot "$safePackageName.nupkg"
    $encodedName = [System.Uri]::EscapeDataString($Package.Name)
    $packageUris = New-Object System.Collections.ArrayList

    if($Package.Version){
        [void]$packageUris.Add("https://community.chocolatey.org/api/v2/package/$encodedName/$($Package.Version)")
    }
    [void]$packageUris.Add("https://community.chocolatey.org/api/v2/package/$encodedName")

    $downloadErrors = New-Object System.Collections.ArrayList

    foreach($uri in $packageUris){
        try {
            Add-GUILog "Downloading Chocolatey package payload: $($Package.Name)"
            Invoke-WebRequest -Uri $uri -OutFile $nupkgPath -UseBasicParsing -TimeoutSec 45 -ErrorAction Stop

            if((Test-Path $nupkgPath) -and ((Get-Item $nupkgPath).Length -gt 0)){
                Add-Content -Path $Session.Transcript -Encoding UTF8 -Value "Downloaded package: $uri"
                break
            }
        }
        catch {
            [void]$downloadErrors.Add("$uri - $($_.Exception.Message)")
        }
    }

    if(!(Test-Path $nupkgPath) -or ((Get-Item $nupkgPath).Length -eq 0)){
        throw "Could not download the Chocolatey package without installing it.`r`n$($downloadErrors -join "`r`n")"
    }

    try {
        Expand-Archive -Path $nupkgPath -DestinationPath $extractRoot -Force
    }
    catch {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($nupkgPath,$extractRoot)
    }

    return [pscustomobject]@{
        PackagePath = $nupkgPath
        ExtractRoot = $extractRoot
    }
}

function Get-GUIChocoPackageExtractCandidateRoots {
    param([string]$ExtractRoot)

    if(!$ExtractRoot -or !(Test-Path $ExtractRoot)){
        return @()
    }

    $roots = New-Object System.Collections.ArrayList

    foreach($relative in @("tools","content","lib","")){
        $path = if($relative){ Join-Path $ExtractRoot $relative } else { $ExtractRoot }
        if(Test-Path $path){
            [void]$roots.Add($path)
        }
    }

    Get-ChildItem -Path $ExtractRoot -Directory -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match '(?i)^(tools?|app|bin|portable|content)$' } |
        ForEach-Object { [void]$roots.Add($_.FullName) }

    return @($roots | Sort-Object -Unique)
}

function Expand-GUIChocoPackagePayloadArchives {
    param(
        [string]$ExtractRoot,
        [pscustomobject]$Session
    )

    if(!$ExtractRoot -or !(Test-Path $ExtractRoot)){
        return @()
    }

    $expandedRoots = New-Object System.Collections.ArrayList
    $archiveRoot = Join-Path $ExtractRoot "_toolkit-expanded-payloads"
    $archives = @(
        Get-ChildItem -Path $ExtractRoot -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Extension -match '(?i)^\.(zip|7z)$' }
    )

    foreach($archive in $archives){
        try {
            $targetName = ($archive.BaseName -replace '[^A-Za-z0-9._-]+','_').Trim('_')
            if(!$targetName){
                $targetName = "payload"
            }

            $target = Join-Path $archiveRoot $targetName
            New-Item -ItemType Directory -Path $target -Force | Out-Null

            if($archive.Extension -ieq ".zip"){
                Expand-Archive -Path $archive.FullName -DestinationPath $target -Force
                [void]$expandedRoots.Add($target)
                if($Session -and $Session.Transcript){
                    Add-Content -Path $Session.Transcript -Encoding UTF8 -Value "Expanded package payload archive: $($archive.FullName)"
                }
            }
            elseif($archive.Extension -ieq ".7z"){
                $sevenZip = Get-Command 7z.exe -ErrorAction SilentlyContinue
                if($sevenZip){
                    & $sevenZip.Source x "-o$target" -y $archive.FullName | Out-Null
                    [void]$expandedRoots.Add($target)
                    if($Session -and $Session.Transcript){
                        Add-Content -Path $Session.Transcript -Encoding UTF8 -Value "Expanded package payload archive: $($archive.FullName)"
                    }
                }
            }
        }
        catch {
            if($Session -and $Session.Transcript){
                Add-Content -Path $Session.Transcript -Encoding UTF8 -Value "Could not expand payload archive $($archive.FullName): $($_.Exception.Message)"
            }
        }
    }

    return @($expandedRoots | Sort-Object -Unique)
}

function Get-GUIChocoPackagePayloadHints {
    param([string]$ExtractRoot)

    $hints = New-Object System.Collections.ArrayList

    if(!$ExtractRoot -or !(Test-Path $ExtractRoot)){
        return @()
    }

    $scripts = @(
        Get-ChildItem -Path $ExtractRoot -Recurse -File -Include "*.ps1" -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match '(?i)chocolateyinstall|install' }
    )

    foreach($script in $scripts){
        try {
            $text = Get-Content -Raw -Path $script.FullName -ErrorAction Stop
            $urls = @([regex]::Matches($text,'(?im)^\s*\$url(?:32|64)?\s*=\s*[''"](?<url>https?://[^''"]+)[''"]') | ForEach-Object { $_.Groups["url"].Value })

            if($urls.Count -eq 0){
                $urls = @([regex]::Matches($text,'https?://[^\s''")]+') | ForEach-Object { $_.Value })
            }

            $checksums = @([regex]::Matches($text,'(?im)^\s*\$checksum(?:32|64)?\s*=\s*[''"](?<hash>[A-Fa-f0-9]{32,128})[''"]') | ForEach-Object { $_.Groups["hash"].Value })

            foreach($url in @($urls | Select-Object -Unique)){
                [void]$hints.Add([pscustomobject]@{
                    Script = $script.FullName
                    Url = $url
                    Checksum = if($checksums.Count -gt 0){$checksums[0]}else{""}
                })
            }
        }
        catch {}
    }

    return @($hints)
}

function Write-GUIChocoPackageAnalysis {
    param(
        [string]$ExtractRoot,
        [pscustomobject]$Session
    )

    if(!$Session -or !$Session.Path){
        return $null
    }

    $analysisPath = Join-Path $Session.Path "package-analysis.txt"
    $files = @(Get-ChildItem -Path $ExtractRoot -Recurse -File -ErrorAction SilentlyContinue)
    $exeCount = @($files | Where-Object { $_.Extension -ieq ".exe" }).Count
    $nuspecs = @($files | Where-Object { $_.Extension -ieq ".nuspec" })
    $scripts = @($files | Where-Object { $_.Extension -ieq ".ps1" })
    $archives = @($files | Where-Object { $_.Extension -match '(?i)^\.(zip|7z)$' })
    $hints = @(Get-GUIChocoPackagePayloadHints -ExtractRoot $ExtractRoot)

    $lines = New-Object System.Collections.ArrayList
    [void]$lines.Add("Chocolatey package analysis")
    [void]$lines.Add("===========================")
    [void]$lines.Add("Expanded package: $ExtractRoot")
    [void]$lines.Add("Files: $($files.Count)")
    [void]$lines.Add("EXE files: $exeCount")
    [void]$lines.Add("NUSPEC files: $($nuspecs.Count)")
    [void]$lines.Add("PowerShell install scripts: $($scripts.Count)")
    [void]$lines.Add("Embedded archives: $($archives.Count)")
    [void]$lines.Add("")

    if($exeCount -eq 0 -and $scripts.Count -gt 0){
        [void]$lines.Add("Finding: this looks like a Chocolatey wrapper/recipe package.")
        [void]$lines.Add("The package does not carry a runnable EXE directly. The install script probably downloads or creates the app during install.")
        [void]$lines.Add("")
    }

    if($nuspecs.Count -gt 0){
        [void]$lines.Add("NUSPEC:")
        foreach($nuspec in $nuspecs){
            [void]$lines.Add("  $($nuspec.FullName)")
        }
        [void]$lines.Add("")
    }

    if($scripts.Count -gt 0){
        [void]$lines.Add("Install scripts:")
        foreach($script in $scripts){
            [void]$lines.Add("  $($script.FullName)")
        }
        [void]$lines.Add("")
    }

    if($hints.Count -gt 0){
        [void]$lines.Add("Payload URLs found in scripts:")
        foreach($hint in $hints){
            [void]$lines.Add("  $($hint.Url)")
            if($hint.Checksum){
                [void]$lines.Add("    Checksum: $($hint.Checksum)")
            }
        }
        [void]$lines.Add("")
    }

    $lines | Set-Content -Path $analysisPath -Encoding UTF8

    if($Session.Transcript){
        Add-Content -Path $Session.Transcript -Encoding UTF8 -Value ""
        Add-Content -Path $Session.Transcript -Encoding UTF8 -Value "Package analysis written to: $analysisPath"
    }

    return $analysisPath
}

function Expand-GUIChocoExternalPayloads {
    param(
        [string]$ExtractRoot,
        [pscustomobject]$Session
    )

    $expandedRoots = New-Object System.Collections.ArrayList
    $hints = @(Get-GUIChocoPackagePayloadHints -ExtractRoot $ExtractRoot)

    if($hints.Count -eq 0){
        return @()
    }

    $payloadRoot = Join-Path $Session.Path "external-payloads"
    New-Item -ItemType Directory -Path $payloadRoot -Force | Out-Null

    foreach($hint in $hints){
        try {
            $fileName = [IO.Path]::GetFileName(([Uri]$hint.Url).AbsolutePath)
            if(!$fileName){
                $fileName = "payload.bin"
            }

            $downloadPath = Join-Path $payloadRoot $fileName
            Add-GUILog "Downloading package payload from install script: $fileName"
            Invoke-WebRequest -Uri $hint.Url -OutFile $downloadPath -UseBasicParsing -TimeoutSec 90 -ErrorAction Stop

            if($hint.Checksum){
                $hash = (Get-FileHash -Path $downloadPath -Algorithm SHA256).Hash.ToLowerInvariant()
                if($hash -ne $hint.Checksum.ToLowerInvariant()){
                    throw "Downloaded payload checksum did not match. Expected $($hint.Checksum), got $hash."
                }
            }

            if($downloadPath -match '(?i)\.zip$'){
                $target = Join-Path $payloadRoot (($fileName -replace '\.zip$','') -replace '[^A-Za-z0-9._-]+','_')
                New-Item -ItemType Directory -Path $target -Force | Out-Null
                Expand-Archive -Path $downloadPath -DestinationPath $target -Force
                [void]$expandedRoots.Add($target)
            }
            elseif($downloadPath -match '(?i)\.exe$'){
                [void]$expandedRoots.Add($payloadRoot)
            }

            if($Session.Transcript){
                Add-Content -Path $Session.Transcript -Encoding UTF8 -Value "Downloaded external payload: $($hint.Url)"
            }
        }
        catch {
            if($Session.Transcript){
                Add-Content -Path $Session.Transcript -Encoding UTF8 -Value "Could not download external payload $($hint.Url): $($_.Exception.Message)"
            }
            Add-GUILog "Could not download package payload: $($_.Exception.Message)"
        }
    }

    return @($expandedRoots | Sort-Object -Unique)
}

function Get-GUIChocoLibCandidateRoots {
    param([string]$PackageName)

    $roots = New-Object System.Collections.ArrayList
    $libRoot = Join-Path $env:ProgramData "chocolatey\lib"

    foreach($name in @($PackageName, ($PackageName -replace '(?i)\.portable$','')) | Where-Object { $_ } | Select-Object -Unique){
        $direct = Join-Path $libRoot $name
        if(Test-Path $direct){
            [void]$roots.Add($direct)
        }
    }

    if(Test-Path $libRoot){
        $base = ($PackageName -replace '(?i)\.portable$','')
        Get-ChildItem -Path $libRoot -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -eq $PackageName -or $_.Name -eq $base -or $_.Name -like "$base*" } |
            ForEach-Object { [void]$roots.Add($_.FullName) }
    }

    return @($roots | Sort-Object -Unique)
}

function Get-GUIInstalledAppCandidateRoots {
    param([string]$PackageName)

    $roots = New-Object System.Collections.ArrayList
    $base = (($PackageName -replace '(?i)\.portable$','') -replace '[^A-Za-z0-9]+','').ToLowerInvariant()

    if(!$base){
        return @()
    }

    foreach($programRoot in @($env:ProgramFiles, ${env:ProgramFiles(x86)}, "$env:LOCALAPPDATA\Programs") | Where-Object { $_ -and (Test-Path $_) } | Select-Object -Unique){
        Get-ChildItem -Path $programRoot -Directory -ErrorAction SilentlyContinue |
            Where-Object {
                $folderKey = ($_.Name -replace '[^A-Za-z0-9]+','').ToLowerInvariant()
                $folderKey -eq $base -or $folderKey -like "$base*" -or $base -like "$folderKey*"
            } |
            ForEach-Object { [void]$roots.Add($_.FullName) }
    }

    return @($roots | Sort-Object -Unique)
}

function Get-GUIExternalPayloadChecksumArgument {
    param([pscustomobject]$Session)

    if(!$Session -or !$Session.Path){
        return @()
    }

    $payloadRoot = Join-Path $Session.Path "external-payloads"
    if(!(Test-Path $payloadRoot)){
        return @()
    }

    $payload = @(Get-ChildItem -Path $payloadRoot -Recurse -File -Include *.exe,*.msi -ErrorAction SilentlyContinue |
        Sort-Object Length -Descending |
        Select-Object -First 1)

    if($payload.Count -eq 0){
        return @()
    }

    $hash = (Get-FileHash -Path $payload[0].FullName -Algorithm SHA256).Hash
    return @("--checksum",$hash,"--checksum64",$hash)
}

function Get-GUIBestToolboxExecutable {
    param(
        [string]$Root,
        [string]$PackageName = ""
    )

    if(!(Test-Path $Root)){
        return $null
    }

    $executables = @(
        Get-ChildItem -Path $Root -Recurse -Filter *.exe -File -ErrorAction SilentlyContinue |
            Where-Object {
                $_.Name -notmatch '(?i)(unins|uninstall|setup|install|update|crashreport|helper|elevate|shimgen|hookldr|hookloader)' -and
                !(Test-GUIInstallerExecutable -Path $_.FullName -DeepScan)
            }
    )

    if($executables.Count -eq 0){
        return $null
    }

    $baseNeedle = (($PackageName -replace '(?i)\.portable$','') -replace '[^A-Za-z0-9]+','').ToLowerInvariant()
    $preferred = $executables |
        Sort-Object @{Expression={
                        $base = ($_.BaseName -replace '[^A-Za-z0-9]+','').ToLowerInvariant()
                        $metadata = "$($_.Name) $($_.VersionInfo.FileDescription) $($_.VersionInfo.ProductName)"
                        if($baseNeedle -and $base -eq $baseNeedle){0}
                        elseif($metadata -match '(?i)(viewer|client|portable|launcher)'){1}
                        elseif($baseNeedle -and $base -like "$baseNeedle*"){2}
                        elseif($_.BaseName -match '(?i)(portable|64|x64)'){3}
                        elseif($metadata -match '(?i)(server|service|daemon|hook|loader|agent|tray)'){8}
                        else{4}
                    }},
                    @{Expression={ if($_.DirectoryName -match '(?i)\\tools?$'){0}else{1} }},
                    @{Expression={ $_.FullName.Length }} |
        Select-Object -First 1

    return $preferred
}

function Add-SelectedChocoPackageToToolbox {
    $package = Get-SelectedGUIChocoPackage

    if(!$package){
        Add-GUILog "Select a Chocolatey package first."
        return
    }

    $choco = Get-GUIChocoPath
    if(!$choco){
        Add-GUILog "Chocolatey is not installed."
        return
    }

    $overrideNonPortable = $false
    if(!(Test-GUIChocoPackagePortable -Package $package)){
        $portableChoice = [System.Windows.Forms.MessageBox]::Show(
            "$($package.Name) does not look like a portable package.`r`n`r`nYes: search Chocolatey for portable variants.`r`nNo: try to add this package anyway.`r`nCancel: stop.",
            "Portable Package Check",
            [System.Windows.Forms.MessageBoxButtons]::YesNoCancel,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )

        if($portableChoice -eq [System.Windows.Forms.DialogResult]::Yes){
            $script:ChocoSearchBox.Text = "$($package.Name) portable"
            Search-GUIChocoPackages
            return
        }

        if($portableChoice -eq [System.Windows.Forms.DialogResult]::Cancel){
            Add-GUILog "Add to toolbox cancelled during portable package check."
            return
        }

        $overrideNonPortable = $true
        Add-GUILog "Portable check override approved for: $($package.Name)"
    }

    if(!$CSIPaths.Custom -or !(Test-Path $CSIPaths.Custom)){
        New-Item -ItemType Directory -Path $CSIPaths.Custom -Force | Out-Null
    }

    $safeName = ($package.Name -replace '[^A-Za-z0-9._-]+','_').Trim('_')
    if(!$safeName){
        $safeName = $package.Name
    }

    $dest = Join-Path $CSIPaths.Custom $safeName
    $destExisted = Test-Path $dest

    if($destExisted){
        $overwrite = [System.Windows.Forms.MessageBox]::Show(
            "$($package.Name) already exists in the Custom toolbox folder.`r`n`r`nReplace/update it?",
            "Update Toolbox Tool",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )

        if($overwrite -ne [System.Windows.Forms.DialogResult]::Yes){
            return
        }
    }

    $overrideNotice = ""
    if($overrideNonPortable){
        $overrideNotice = "`r`n`r`nWarning: this package did not advertise itself as portable. The toolkit will try it, then roll back copied files and temporary Chocolatey installs if the attempt fails."
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Add '$($package.Name)' to the portable toolbox?`r`n`r`nThe package will be installed/downloaded, copied into .\Custom\$safeName, registered, and the Custom tab will refresh.$overrideNotice",
        "Add To Toolbox",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    if($confirm -ne [System.Windows.Forms.DialogResult]::Yes){
        return
    }

    $oldCursor = $script:Form.Cursor
    $script:Form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    $backupDest = $null
    $session = $null
    $installedBefore = $false
    $cleanupPackageName = $package.Name
    $chocoInstallSucceeded = $false
    $manifestUpdated = $false
    $usedMachineInstallFallback = $false

    try {
        if($destExisted){
            $backupDest = Join-Path $CSIPaths.Custom ("{0}.rollback-{1}" -f $safeName,(Get-Date -Format "yyyyMMddHHmmss"))
            Move-Item -LiteralPath $dest -Destination $backupDest -Force
            Add-GUILog "Existing toolbox copy backed up for rollback: $safeName"
        }

        $session = New-CSITempOutputSession -ToolName "Choco-AddToToolbox-$($package.Name)"

        Add-GUILog "Adding Chocolatey package to toolbox without machine install: $($package.Name)"
        $downloadedPackage = Save-GUIChocoPackageToTemp -Package $package -Session $session
        $analysisPath = Write-GUIChocoPackageAnalysis -ExtractRoot $downloadedPackage.ExtractRoot -Session $session
        $candidateRoots = @(Get-GUIChocoPackageExtractCandidateRoots -ExtractRoot $downloadedPackage.ExtractRoot)
        $candidateRoots += @(Expand-GUIChocoPackagePayloadArchives -ExtractRoot $downloadedPackage.ExtractRoot -Session $session)
        $candidateRoots += @(Expand-GUIChocoExternalPayloads -ExtractRoot $downloadedPackage.ExtractRoot -Session $session)
        $candidateRoots = @($candidateRoots | Sort-Object -Unique)
        $bestExe = $null

        foreach($root in $candidateRoots){
            $bestExe = Get-GUIBestToolboxExecutable -Root $root -PackageName $package.Name
            if($bestExe){
                break
            }
        }

        if(!$bestExe){
            $analysisNote = if($analysisPath){"`r`n`r`nPackage analysis:`r`n$analysisPath"}else{""}
            $fallbackChoice = [System.Windows.Forms.MessageBox]::Show(
                "The Chocolatey package downloaded successfully, but no runnable EXE was found inside the package payload.`r`n`r`nSome packages only contain .nuspec metadata and install scripts that download the app during install. The toolkit checked for script payload URLs and did not find a usable EXE yet.$analysisNote`r`n`r`nTemporarily install this package on the computer, copy the app into the toolbox, and uninstall it afterward?",
                "Machine Install Fallback",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )

            if($fallbackChoice -ne [System.Windows.Forms.DialogResult]::Yes){
                throw "No runnable executable was found in the downloaded package. Package analysis: $analysisPath"
            }

            if(!(Test-GUIAdministrator)){
                throw "Machine install fallback needs the GUI running elevated so Chocolatey can install package files temporarily."
            }

            $usedMachineInstallFallback = $true
            $installedBefore = Test-GUIChocoPackageInstalled -PackageName $package.Name

            Add-GUILog "Using temporary machine install fallback for: $($package.Name)"
            $installArgs = Get-GUIChocoPortableInstallArguments -Package $package
            $installOutput = & $choco @installArgs 2>&1
            $installExitCode = $LASTEXITCODE
            Add-Content -Path $session.Transcript -Encoding UTF8 -Value ""
            Add-Content -Path $session.Transcript -Encoding UTF8 -Value "Machine install fallback: $($package.Name)"
            Add-Content -Path $session.Transcript -Encoding UTF8 -Value ($installOutput | Out-String)

            if($installExitCode -ne 0 -and (($installOutput | Out-String) -match '(?i)hashes do not match|checksum')){
                $checksumArgs = @(Get-GUIExternalPayloadChecksumArgument -Session $session)
                if($checksumArgs.Count -gt 0){
                    Add-GUILog "Retrying fallback install with verified downloaded payload checksum: $($package.Name)"
                    $installOutput = & $choco @($installArgs + $checksumArgs) 2>&1
                    $installExitCode = $LASTEXITCODE
                    Add-Content -Path $session.Transcript -Encoding UTF8 -Value ""
                    Add-Content -Path $session.Transcript -Encoding UTF8 -Value "Machine install fallback retry with downloaded payload checksum: $($package.Name)"
                    Add-Content -Path $session.Transcript -Encoding UTF8 -Value ($installOutput | Out-String)
                }
            }

            if($installExitCode -ne 0){
                $tail = (($installOutput | Select-Object -Last 8) -join "`r`n").Trim()
                throw "Chocolatey fallback install failed with exit code $installExitCode.`r`n$tail"
            }
            $chocoInstallSucceeded = $true

            $candidateRoots = @(Get-GUIChocoLibCandidateRoots -PackageName $package.Name)
            $candidateRoots += @(Get-GUIInstalledAppCandidateRoots -PackageName $package.Name)
            $candidateRoots = @($candidateRoots | Sort-Object -Unique)
            foreach($root in $candidateRoots){
                $bestExe = Get-GUIBestToolboxExecutable -Root $root -PackageName $package.Name
                if($bestExe){
                    break
                }
            }

            if(!$bestExe -and $package.Name -match '(?i)\.portable$'){
                $baseName = $package.Name -replace '(?i)\.portable$',''
                $baseInfo = Get-GUIChocoPackageInfoText -PackageName $baseName

                if($baseInfo -match '(?i)\s/Portable\s|--params\s+["'']?/Portable'){
                    Add-GUILog "No executable found for $($package.Name). Trying $baseName with portable parameters."
                    $basePackage = [pscustomobject]@{ Name = $baseName; Version = $package.Version }
                    $baseInstalledBefore = Test-GUIChocoPackageInstalled -PackageName $baseName
                    $baseArgs = Get-GUIChocoPortableInstallArguments -Package $basePackage
                    $baseOutput = & $choco @baseArgs 2>&1
                    $baseExitCode = $LASTEXITCODE
                    Add-Content -Path $session.Transcript -Encoding UTF8 -Value ""
                    Add-Content -Path $session.Transcript -Encoding UTF8 -Value "Fallback install: $baseName"
                    Add-Content -Path $session.Transcript -Encoding UTF8 -Value ($baseOutput | Out-String)

                    if($baseExitCode -eq 0){
                        $cleanupPackageName = $baseName
                        $installedBefore = $baseInstalledBefore
                        $chocoInstallSucceeded = $true
                        $candidateRoots = @(Get-GUIChocoLibCandidateRoots -PackageName $baseName)
                        $candidateRoots += @(Get-GUIInstalledAppCandidateRoots -PackageName $baseName)
                        $candidateRoots = @($candidateRoots | Sort-Object -Unique)
                        foreach($root in $candidateRoots){
                            $bestExe = Get-GUIBestToolboxExecutable -Root $root -PackageName $baseName
                            if($bestExe){
                                break
                            }
                        }
                    }
                }
            }
        }

        if(!$bestExe){
            throw "No runnable executable was found after Chocolatey processed the package."
        }

        $sourceFolder = $bestExe.DirectoryName
        New-Item -ItemType Directory -Path $dest -Force | Out-Null
        Copy-Item -Path (Join-Path $sourceFolder "*") -Destination $dest -Recurse -Force

        $launchExe = Get-GUIBestToolboxExecutable -Root $dest -PackageName $package.Name
        if(!$launchExe){
            throw "The package copied into Custom, but no launchable executable was found."
        }

        if(Test-GUIInstallerExecutable -Path $launchExe.FullName -DeepScan){
            throw "The package copied into Custom, but the selected executable is an installer rather than a portable app."
        }

        Update-GUICustomToolsManifestEntry `
            -Name $package.Name `
            -Version $package.Version `
            -LaunchPath $launchExe.FullName `
            -InstallPath $dest `
            -Source "Chocolatey Toolbox"
        $manifestUpdated = $true

        Refresh-GUICustomTools
        Refresh-GUICustomToolTabs
        if($usedMachineInstallFallback -and !$installedBefore -and $cleanupPackageName){
            Add-GUILog "Cleaning temporary Chocolatey package install from computer: $cleanupPackageName"
            $cleanupOutput = & $choco uninstall $cleanupPackageName --yes --no-progress 2>&1
            Add-Content -Path $session.Transcript -Encoding UTF8 -Value ""
            Add-Content -Path $session.Transcript -Encoding UTF8 -Value "Cleanup uninstall: $cleanupPackageName"
            Add-Content -Path $session.Transcript -Encoding UTF8 -Value ($cleanupOutput | Out-String)
            Refresh-GUIChocoInstalledPackages
        }

        if($backupDest -and (Test-Path $backupDest)){
            Remove-Item -LiteralPath $backupDest -Recurse -Force -ErrorAction SilentlyContinue
        }

        Add-GUILog "Added to toolbox: $($package.Name)"

        [System.Windows.Forms.MessageBox]::Show(
            "$($package.Name) was added to the Custom toolbox and is ready to launch.",
            "Added To Toolbox",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null
    }
    catch {
        Add-GUILog "Rolling back toolbox add attempt for: $($package.Name)"

        if($manifestUpdated){
            Remove-GUICustomToolsManifestEntry -Name $package.Name
        }

        if(Test-Path $dest){
            Remove-Item -LiteralPath $dest -Recurse -Force -ErrorAction SilentlyContinue
        }

        if($backupDest -and (Test-Path $backupDest)){
            Move-Item -LiteralPath $backupDest -Destination $dest -Force
            Add-GUILog "Restored previous toolbox copy: $safeName"
        }

        if($chocoInstallSucceeded -and !$installedBefore -and $cleanupPackageName){
            try {
                Add-GUILog "Cleaning failed temporary Chocolatey install: $cleanupPackageName"
                $rollbackOutput = & $choco uninstall $cleanupPackageName --yes --no-progress 2>&1
                if($session -and $session.Transcript){
                    Add-Content -Path $session.Transcript -Encoding UTF8 -Value ""
                    Add-Content -Path $session.Transcript -Encoding UTF8 -Value "Rollback uninstall: $cleanupPackageName"
                    Add-Content -Path $session.Transcript -Encoding UTF8 -Value ($rollbackOutput | Out-String)
                }
                Refresh-GUIChocoInstalledPackages
            }
            catch {
                Add-GUILog "Rollback uninstall failed: $($_.Exception.Message)"
            }
        }

        Refresh-GUICustomTools
        Refresh-GUICustomToolTabs
        Add-GUILog "Add to toolbox failed: $($_.Exception.Message)"
        [System.Windows.Forms.MessageBox]::Show(
            "Could not add $($package.Name) to the toolbox.`r`n`r`nRollback cleanup was attempted so the Custom toolbox stays clean.`r`n`r`n$($_.Exception.Message)",
            "Add To Toolbox Failed",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
    finally {
        $script:Form.Cursor = $oldCursor
    }
}

function Install-SelectedGUIChocoPackage {
    $package = Get-SelectedGUIChocoPackage

    if(!$package){
        Add-GUILog "Select a Chocolatey package first."
        return
    }

    $choco = Get-GUIChocoPath

    if(!$choco){
        Add-GUILog "Chocolatey is not installed."
        return
    }

    if(($script:ChocoInstalledPackages | Where-Object { $_.Name -eq $package.Name } | Select-Object -First 1) -or (& $choco list --local-only --exact $package.Name --limit-output 2>$null)){
        [System.Windows.Forms.MessageBox]::Show(
            "$($package.Name) is already installed by Chocolatey.`r`n`r`nUse the Installed Packages section to upgrade or uninstall it.",
            "Package Already Installed",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null
        Add-GUILog "Chocolatey package already installed: $($package.Name)"
        Refresh-GUIChocoInstalledPackages
        return
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Install Chocolatey package '$($package.Name)'?",
        "Install Package",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    if($confirm -ne [System.Windows.Forms.DialogResult]::Yes){
        Add-GUILog "Package install cancelled."
        return
    }

    try {
        Start-GUIChocoAction -PackageName $package.Name -Action install
    }
    catch {
        Add-GUILog "Failed to start package install: $($_.Exception.Message)"
    }
}

function Upgrade-SelectedGUIChocoPackage {
    $package = Get-SelectedGUIChocoInstalledPackage

    if(!$package){
        Add-GUILog "Select an installed Chocolatey package first."
        return
    }

    Start-GUIChocoAction -PackageName $package.Name -Action upgrade
}

function Upgrade-AllGUIChocoPackages {
    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Upgrade all Chocolatey packages installed on this computer?",
        "Upgrade All Chocolatey Packages",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )

    if($confirm -ne [System.Windows.Forms.DialogResult]::Yes){
        Add-GUILog "Chocolatey upgrade all cancelled."
        return
    }

    Start-GUIChocoAction -PackageName "all" -Action upgrade
}

function Uninstall-SelectedGUIChocoPackage {
    $package = Get-SelectedGUIChocoInstalledPackage

    if(!$package){
        Add-GUILog "Select an installed Chocolatey package first."
        return
    }

    if($package.Name -eq "chocolatey"){
        $selfConfirm = [System.Windows.Forms.MessageBox]::Show(
            "You selected the Chocolatey package itself.`r`n`r`nUninstalling Chocolatey will remove the package manager this tab depends on. Continue anyway?",
            "Uninstall Chocolatey?",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )

        if($selfConfirm -ne [System.Windows.Forms.DialogResult]::Yes){
            Add-GUILog "Chocolatey self-uninstall cancelled."
            return
        }
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Uninstall Chocolatey package '$($package.Name)' from this computer?`r`n`r`nThis does not remove tools copied into the portable toolkit Custom folder.",
        "Uninstall From Computer",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )

    if($confirm -eq [System.Windows.Forms.DialogResult]::Yes){
        Start-GUIChocoAction -PackageName $package.Name -Action uninstall
    }
}

function ConvertTo-GUICommandToken {
    param([string]$Value)

    if($Value -match "^/"){
        return $Value
    }

    if($Value -match "\s"){
        return "`"$Value`""
    }

    return $Value
}

function Split-GUICommandLine {
    param([string]$CommandLine)

    $items = New-Object System.Collections.ArrayList
    if([string]::IsNullOrWhiteSpace($CommandLine)){
        return @()
    }

    $current = New-Object System.Text.StringBuilder
    $inQuotes = $false

    foreach($char in $CommandLine.ToCharArray()){
        if($char -eq '"'){
            $inQuotes = !$inQuotes
            continue
        }

        if([char]::IsWhiteSpace($char) -and !$inQuotes){
            if($current.Length -gt 0){
                [void]$items.Add($current.ToString())
                [void]$current.Clear()
            }
            continue
        }

        [void]$current.Append($char)
    }

    if($current.Length -gt 0){
        [void]$items.Add($current.ToString())
    }

    return @($items)
}

function Get-GUIPsExecTool {
    $tool = Resolve-CSIExternalTool -Id "PsExec"

    if(!$tool -or !$tool.Found){
        throw "PsExec was not found under ExternalTools\Sysinternals."
    }

    if(Get-Command Set-CSISysinternalsEulaAccepted -ErrorAction SilentlyContinue){
        Set-CSISysinternalsEulaAccepted -Path $tool.Path
    }

    return $tool
}

function Get-GUIPsExecArgumentList {
    $tool = Get-GUIPsExecTool
    $arguments = @()

    if($script:PsExecAcceptEulaCheck -and $script:PsExecAcceptEulaCheck.Checked){
        $arguments += "-accepteula"
    }

    $targets = if($script:PsExecTargetBox){ $script:PsExecTargetBox.Text.Trim() }else{ "" }
    if($targets){
        $targetItems = @($targets -split '[,;]' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
        foreach($target in $targetItems){
            if($target -match '^@'){
                $arguments += $target
            }
            elseif($target -match '^\\\\'){
                $arguments += $target
            }
            elseif($target -eq "." -or $target -eq "localhost" -or $target -eq $env:COMPUTERNAME){
                $arguments += "\\$env:COMPUTERNAME"
            }
            else{
                $arguments += "\\$target"
            }
        }
    }

    $timeout = if($script:PsExecTimeoutBox){ $script:PsExecTimeoutBox.Text.Trim() }else{ "" }
    if($timeout){
        $timeoutNumber = 0
        if(![int]::TryParse($timeout,[ref]$timeoutNumber) -or $timeoutNumber -lt 1){
            throw "Connection timeout must be a whole number of seconds."
        }
        $arguments += "-n"
        $arguments += [string]$timeoutNumber
    }

    $user = if($script:PsExecUserBox){ $script:PsExecUserBox.Text.Trim() }else{ "" }
    if($user){
        $arguments += "-u"
        $arguments += $user

        $password = if($script:PsExecPasswordBox){ $script:PsExecPasswordBox.Text }else{ "" }
        if($password){
            $arguments += "-p"
            $arguments += $password
        }
    }

    if($script:PsExecElevatedCheck -and $script:PsExecElevatedCheck.Checked){ $arguments += "-h" }
    if($script:PsExecSystemCheck -and $script:PsExecSystemCheck.Checked){ $arguments += "-s" }
    if($script:PsExecDontLoadProfileCheck -and $script:PsExecDontLoadProfileCheck.Checked){ $arguments += "-e" }

    if($script:PsExecInteractiveCheck -and $script:PsExecInteractiveCheck.Checked){
        $arguments += "-i"
        $session = if($script:PsExecSessionBox){ $script:PsExecSessionBox.Text.Trim() }else{ "" }
        if($session){
            $sessionNumber = 0
            if(![int]::TryParse($session,[ref]$sessionNumber) -or $sessionNumber -lt 0){
                throw "Interactive session must be a whole number."
            }
            $arguments += [string]$sessionNumber
        }
    }

    if($script:PsExecDontWaitCheck -and $script:PsExecDontWaitCheck.Checked){ $arguments += "-d" }

    $workingDir = if($script:PsExecWorkingDirBox){ $script:PsExecWorkingDirBox.Text.Trim() }else{ "" }
    if($workingDir){
        $arguments += "-w"
        $arguments += $workingDir
    }

    $serviceName = if($script:PsExecServiceNameBox){ $script:PsExecServiceNameBox.Text.Trim() }else{ "" }
    if($serviceName){
        $arguments += "-r"
        $arguments += $serviceName
    }

    $command = if($script:PsExecCommandBox){ $script:PsExecCommandBox.Text.Trim() }else{ "" }
    if(!$command){
        throw "Enter the command you want PsExec to run."
    }

    $commandParts = @(Split-GUICommandLine -CommandLine $command)
    if($commandParts.Count -eq 0){
        throw "Enter the command you want PsExec to run."
    }

    $arguments += $commandParts

    if(Get-Command Add-CSISysinternalsEulaArgument -ErrorAction SilentlyContinue){
        $arguments = @(Add-CSISysinternalsEulaArgument -Path $tool.Path -Arguments $arguments)
    }

    return [pscustomobject]@{
        Tool = $tool
        Arguments = @($arguments | Where-Object { $null -ne $_ -and $_ -ne "" })
    }
}

function Get-GUIPsExecCommandLine {
    $plan = Get-GUIPsExecArgumentList
    $parts = @($plan.Tool.Path) + @($plan.Arguments)

    if(Get-Command Join-CSICommandLine -ErrorAction SilentlyContinue){
        return Join-CSICommandLine -Parts $parts
    }

    return (($parts | ForEach-Object { ConvertTo-GUICommandToken $_ }) -join " ")
}

function Update-GUIPsExecCommandPreview {
    try {
        $commandLine = Get-GUIPsExecCommandLine
        if($script:PsExecCommandPreviewBox){
            $script:PsExecCommandPreviewBox.Text = $commandLine
        }
        Add-GUILog "Built PsExec command."
        return $commandLine
    }
    catch {
        if($script:PsExecCommandPreviewBox){
            $script:PsExecCommandPreviewBox.Text = ""
        }
        Add-GUILog "PsExec builder: $($_.Exception.Message)"
        return $null
    }
}

function Copy-GUIPsExecCommand {
    $commandLine = Update-GUIPsExecCommandPreview
    if(!$commandLine){
        return
    }

    Set-Clipboard -Value $commandLine
    Add-GUILog "Copied PsExec command to clipboard."
}

function Set-GUIPsExecOutput {
    param(
        [string]$Title,
        [string]$Text
    )

    if(!$script:PsExecOutputBox){
        return
    }

    $stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $script:PsExecOutputBox.Text = "[$stamp] $Title`r`n" + ("=" * [Math]::Min(80,[Math]::Max(10,$Title.Length))) + "`r`n`r`n" + $Text.Trim()
    $script:PsExecOutputBox.SelectionStart = $script:PsExecOutputBox.TextLength
    $script:PsExecOutputBox.ScrollToCaret()
}

function Stop-GUIPsExecCommand {
    if($script:PsExecProcess -and !$script:PsExecProcess.HasExited){
        try {
            $script:PsExecProcess.Kill()
            Add-GUILog "Stopped PsExec command."
            Set-GUIPsExecOutput -Title "PsExec" -Text "Stopped by technician."
        }
        catch {
            Add-GUILog "Failed to stop PsExec command: $($_.Exception.Message)"
        }
    }
}

function Start-GUIPsExecCaptured {
    $plan = Get-GUIPsExecArgumentList
    $tool = $plan.Tool
    $arguments = @($plan.Arguments)

    if($script:PsExecProcess -and !$script:PsExecProcess.HasExited){
        $choice = [System.Windows.Forms.MessageBox]::Show(
            "A PsExec command is still running. Stop it and run the new command?",
            "PsExec Helper",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )

        if($choice -ne [System.Windows.Forms.DialogResult]::Yes){
            Add-GUILog "PsExec command still running."
            return
        }

        Stop-GUIPsExecCommand
    }

    if($script:PsExecTimer){
        try {
            $script:PsExecTimer.Stop()
            $script:PsExecTimer.Dispose()
        }
        catch {}
        $script:PsExecTimer = $null
    }

    $session = New-CSITempOutputSession -ToolName "PsExec Helper"
    $stdout = Join-Path $session.Path "psexec-output.txt"
    $stderr = Join-Path $session.Path "psexec-error.txt"
    $metadata = [pscustomobject]@{
        CapturedAt = (Get-Date).ToString("s")
        Tool = "PsExec"
        Path = $tool.Path
        Arguments = $arguments
        CommandLine = Get-GUIPsExecCommandLine
    }
    $metadata | ConvertTo-Json -Depth 6 | Set-Content -Path $session.Metadata -Encoding UTF8

    Set-GUIPsExecOutput -Title "PsExec" -Text "Running...`r`n`r`nOutput folder:`r`n$($session.Path)"
    Add-GUILog "Running PsExec command with captured output."

    try {
        $process = Start-Process `
            -FilePath $tool.Path `
            -ArgumentList $arguments `
            -WorkingDirectory (Split-Path -Parent $tool.Path) `
            -WindowStyle Hidden `
            -RedirectStandardOutput $stdout `
            -RedirectStandardError $stderr `
            -PassThru

        $script:PsExecProcess = $process
        $script:PsExecFiles = @{
            Session = $session
            StdOut = $stdout
            StdErr = $stderr
        }

        $timer = New-Object System.Windows.Forms.Timer
        $timer.Interval = 500
        $timer.Add_Tick({
            if(!$script:PsExecProcess){
                $script:PsExecTimer.Stop()
                $script:PsExecTimer.Dispose()
                $script:PsExecTimer = $null
                return
            }

            if($script:PsExecProcess.HasExited){
                $script:PsExecTimer.Stop()
                $script:PsExecTimer.Dispose()
                $script:PsExecTimer = $null

                $outText = if(Test-Path $script:PsExecFiles.StdOut){ Get-Content -Raw -Path $script:PsExecFiles.StdOut -ErrorAction SilentlyContinue }else{ "" }
                $errText = if(Test-Path $script:PsExecFiles.StdErr){ Get-Content -Raw -Path $script:PsExecFiles.StdErr -ErrorAction SilentlyContinue }else{ "" }
                $exitCode = $script:PsExecProcess.ExitCode
                $combined = @(
                    if($outText){ $outText.TrimEnd() }
                    if($errText){ "ERROR OUTPUT:`r`n" + $errText.TrimEnd() }
                    "Exit code: $exitCode"
                    "Output folder: $($script:PsExecFiles.Session.Path)"
                ) -join "`r`n`r`n"

                Set-GUIPsExecOutput -Title "PsExec Complete" -Text $combined
                Add-GUILog "PsExec command completed with exit code $exitCode."
                Write-GUIToolUsageLog -Tool "PsExec Helper" -Action "Completed" -Detail "ExitCode=$exitCode; Output=$($script:PsExecFiles.Session.Path)"
                $script:PsExecProcess = $null
                $script:PsExecFiles = $null
            }
        })

        $script:PsExecTimer = $timer
        $timer.Start()
    }
    catch {
        Set-GUIPsExecOutput -Title "PsExec Failed" -Text $_.Exception.Message
        Add-GUILog "Failed to start PsExec: $($_.Exception.Message)"
        Write-GUIToolUsageLog -Tool "PsExec Helper" -Action "Failed" -Detail $_.Exception.Message -Level "ERROR"
    }
}

function Start-GUIPsExecConsole {
    $plan = Get-GUIPsExecArgumentList
    $commandLine = Get-GUIPsExecCommandLine
    $consoleTool = [pscustomobject]@{
        Path = "cmd.exe"
        RequiresAdmin = [bool]$plan.Tool.RequiresAdmin
    }

    Start-CSIExternalProcess -Tool $consoleTool -Arguments @("/k",$commandLine)
    Add-GUILog "Opened PsExec console."
}

function Start-GUIPsExecHelper {
    if(!$script:MainTabs){
        return
    }

    $page = $script:MainTabs.TabPages | Where-Object { $_.Text -eq "PsExec" } | Select-Object -First 1
    if($page){
        $script:MainTabs.SelectedTab = $page
        Build-GUITabIfNeeded -Page $page
        Update-GUIStaticTabStripSelection
    }
}

function Get-GUIRobocopyPlan {
    if(!$script:RobocopySourceBox -or !$script:RobocopyDestinationBox){
        return $null
    }

    $source = $script:RobocopySourceBox.Text.Trim()
    $destination = $script:RobocopyDestinationBox.Text.Trim()

    if(!$source -or !$destination){
        throw "Source and destination are required."
    }

    $patternInput = $script:RobocopyPatternBox.Text.Trim()
    $filePatterns = @("*.*")

    if($patternInput){
        $filePatterns = @($patternInput -split "," | ForEach-Object {$_.Trim()} | Where-Object {$_})
    }

    $switches = @()
    $reasons = @()

    switch($script:RobocopyCopyTypeBox.SelectedItem){
        "Mirror destination to source" {
            $switches += "/MIR"
            $reasons += "Mirrors the destination to match the source, including deletes."
        }
        "Unreliable network copy" {
            $switches += "/E"
            $switches += "/Z"
            $reasons += "Copies all folders and uses restartable mode for interrupted network copies."
        }
        "Permission-preserving migration" {
            $switches += "/E"
            $reasons += "Copies all folders and prepares for security-preserving migration."
        }
        default {
            $switches += "/E"
            $reasons += "Copies all subfolders, including empty folders."
        }
    }

    switch($script:RobocopyMetadataBox.SelectedItem){
        "Preserve NTFS permissions" {
            $switches += "/COPY:DATS"
            $switches += "/DCOPY:DAT"
            $switches += "/SECFIX"
            $reasons += "Preserves NTFS security and fixes skipped-file security."
        }
        "Full owner and audit migration" {
            $switches += "/COPYALL"
            $switches += "/DCOPY:DAT"
            $switches += "/SECFIX"
            $reasons += "Copies all available metadata including owner and audit information."
        }
        default {
            $switches += "/COPY:DAT"
            $switches += "/DCOPY:DAT"
            $reasons += "Copies data, attributes, and timestamps."
        }
    }

    switch($script:RobocopyRetryBox.SelectedItem){
        "Balanced" {
            $switches += "/R:3"
            $switches += "/W:5"
            $reasons += "Retries failed files three times with a five-second wait."
        }
        "Patient migration" {
            $switches += "/R:10"
            $switches += "/W:10"
            if($switches -notcontains "/Z"){
                $switches += "/Z"
            }
            $reasons += "Retries longer and uses restartable mode."
        }
        default {
            $switches += "/R:1"
            $switches += "/W:1"
            $reasons += "Fails quickly so troubleshooting is not held up by locked files."
        }
    }

    switch($script:RobocopyThreadsBox.SelectedItem){
        "Gentle" { $switches += "/MT:4" }
        "Fast" { $switches += "/MT:32" }
        default { $switches += "/MT:16" }
    }

    if($script:RobocopyNasCheck.Checked){
        $switches += "/FFT"
        $reasons += "Allows two-second timestamp tolerance for NAS and non-Windows shares."
    }

    if($script:RobocopyNoProgressCheck.Checked){
        $switches += "/NP"
    }

    $excludeFiles = @($script:RobocopyExcludeFilesBox.Text -split "," | ForEach-Object {$_.Trim()} | Where-Object {$_})
    if($excludeFiles.Count -gt 0){
        $switches += "/XF"
        $switches += $excludeFiles
    }

    $excludeFolders = @($script:RobocopyExcludeFoldersBox.Text -split "," | ForEach-Object {$_.Trim()} | Where-Object {$_})
    if($excludeFolders.Count -gt 0){
        $switches += "/XD"
        $switches += $excludeFolders
    }

    if($script:RobocopyLogCheck.Checked){
        if(!(Test-Path $CSIPaths.Exports)){
            New-Item -ItemType Directory -Path $CSIPaths.Exports -Force | Out-Null
        }

        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $logPath = Join-Path $CSIPaths.Exports "robocopy-$timestamp.log"
        $switches += "/TEE"
        $switches += "/LOG:`"$logPath`""
        $reasons += "Writes a robocopy log to the toolkit Outputs folder."
    }

    $command = Format-CSIRobocopyCommand `
        -Source $source `
        -Destination $destination `
        -FilePatterns $filePatterns `
        -Switches $switches

    return [pscustomobject]@{
        Command = $command
        Reasons = $reasons
    }
}

function Update-GUIRobocopyCommand {
    try {
        $plan = Get-GUIRobocopyPlan
        $text = $plan.Command

        if($plan.Reasons.Count -gt 0){
            $text += [Environment]::NewLine
            $text += [Environment]::NewLine
            $text += "Why these switches:"
            foreach($reason in $plan.Reasons){
                $text += [Environment]::NewLine + "- " + $reason
            }
        }

        $script:RobocopyCommandBox.Text = $text
        Add-GUILog "Built robocopy command."
        return $plan
    }
    catch {
        $script:RobocopyCommandBox.Text = ""
        Add-GUILog "Robocopy builder: $($_.Exception.Message)"
        return $null
    }
}

function Copy-GUIRobocopyCommand {
    $plan = Update-GUIRobocopyCommand

    if(!$plan){
        return
    }

    Set-Clipboard -Value $plan.Command
    Add-GUILog "Copied robocopy command to clipboard."
}

function Start-GUIRobocopyCommand {
    param([switch]$Preview)

    $plan = Update-GUIRobocopyCommand

    if(!$plan){
        return
    }

    $command = $plan.Command

    if($Preview -and $command -notmatch "\s/L(\s|$)"){
        $command += " /L"
    }

    if(!$Preview){
        $confirm = [System.Windows.Forms.MessageBox]::Show(
            "Run this robocopy command now?",
            "Run Robocopy",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )

        if($confirm -ne [System.Windows.Forms.DialogResult]::Yes){
            Add-GUILog "Robocopy run cancelled."
            return
        }
    }

    Start-CSIToolProcess -FilePath "cmd.exe" -ArgumentList @("/k",$command) -WindowStyle Normal | Out-Null

    if($Preview){
        Add-GUILog "Started robocopy preview."
    }
    else{
        Add-GUILog "Started robocopy copy."
    }
}

function Start-GUIExternalFileTool {
    param([string]$Id)

    try {
        $tool = Resolve-CSIExternalTool -Id $Id

        if(!$tool -or !$tool.Found){
            Add-GUILog "External tool not found: $Id"
            return
        }

        $arguments = @($tool.Arguments | Where-Object {$null -ne $_ -and $_ -ne ""})

        if(Get-Command Set-CSISysinternalsEulaAccepted -ErrorAction SilentlyContinue){
            Set-CSISysinternalsEulaAccepted -Path $tool.Path
        }

        if($tool.Console -and (Get-Command Add-CSISysinternalsEulaArgument -ErrorAction SilentlyContinue)){
            $arguments = @(Add-CSISysinternalsEulaArgument -Path $tool.Path -Arguments $arguments)
        }

        # Autoruns is a GUI-only launcher in this toolkit. It does not accept
        # the generic Sysinternals EULA switch as a normal GUI argument.
        if($Id -eq "Autoruns"){
            $arguments = @()
        }

        if($Id -eq "Handle"){
            $searchText = $script:HandleSearchBox.Text.Trim()

            if($searchText){
                $arguments += $searchText
            }
        }

        if($Id -eq "BlueScreenView"){
            $latestDumpCollection = $null
            if(Get-Command Get-CSILatestMinidumpCollection -ErrorAction SilentlyContinue){
                $latestDumpCollection = Get-CSILatestMinidumpCollection
            }

            if($latestDumpCollection -and (Test-Path $latestDumpCollection)){
                $arguments += @("/MiniDumpFolder",$latestDumpCollection)
                Add-GUILog "BlueScreenView using latest minidump collection: $latestDumpCollection"
            }
            else{
                Add-GUILog "No collected minidump folder found yet. Run Minidump Collector first for best BlueScreenView results."
            }
        }

        if($tool.Console){
            $escapedArguments = @($arguments | ForEach-Object { ConvertTo-GUICommandToken $_ })
            $commandLine = "`"$($tool.Path)`""

            if($escapedArguments.Count -gt 0){
                $commandLine += " " + ($escapedArguments -join " ")
            }

            $consoleTool = [pscustomobject]@{
                Path = "cmd.exe"
                RequiresAdmin = $tool.RequiresAdmin
            }

            Start-CSIExternalProcess -Tool $consoleTool -Arguments @("/k",$commandLine)
        }
        else{
            Start-CSIExternalProcess -Tool $tool -Arguments $arguments
        }

        Add-GUILog "Launched: $($tool.Name)"
    }
    catch {
        Add-GUILog "Failed to launch ${Id}: $($_.Exception.Message)"
    }
}

function Build-FingerprintPage {
    param([System.Windows.Forms.TabPage]$Page)

    $layout = New-Object System.Windows.Forms.TableLayoutPanel
    $layout.Dock = "Fill"
    $layout.RowCount = 3
    $layout.ColumnCount = 1
    $layout.Padding = New-Object System.Windows.Forms.Padding(10)
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,184))) | Out-Null
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,48))) | Out-Null
    $Page.Controls.Add($layout)

    $summaryGroup = New-Object System.Windows.Forms.GroupBox
    $summaryGroup.Text = "Current Computer Summary"
    $summaryGroup.Dock = "Fill"
    $summaryGroup.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $layout.Controls.Add($summaryGroup,0,0)

    $summary = New-Object System.Windows.Forms.TableLayoutPanel
    $summary.Dock = "Fill"
    $summary.ColumnCount = 6
    $summary.RowCount = 5
    $summary.Padding = New-Object System.Windows.Forms.Padding(12)
    for($i=0; $i -lt 3; $i++){
        $summary.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,118))) | Out-Null
        $summary.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,33.33))) | Out-Null
    }
    for($i=0; $i -lt 5; $i++){
        $summary.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,20))) | Out-Null
    }
    $summaryGroup.Controls.Add($summary)

    $profile = Get-GUILatestComputerProfile
    $pendingText = if($profile -and $profile.PendingReboot -and (ConvertTo-GUIBoolean $profile.PendingReboot.Pending)){"Pending reboot"}else{"No pending reboot"}
    $healthText = if($profile){ Get-GUIComputerHealthSummaryText -Profile $profile }else{ "No profile yet" }
    $osText = if($profile){ "{0} build {1}" -f (Format-GUIEmptyValue $profile.OS),(Format-GUIEmptyValue $profile.OSBuild) }else{ "No profile yet" }
    $modelText = if($profile){ "{0} {1}" -f (Format-GUIEmptyValue $profile.Manufacturer),(Format-GUIEmptyValue $profile.Model) }else{ "No profile yet" }
    $cpuText = if($profile){ "{0} ({1}C/{2}T)" -f (Format-GUIEmptyValue $profile.CPU),(Format-GUIEmptyValue $profile.Cores),(Format-GUIEmptyValue $profile.LogicalProcessors) }else{ "No profile yet" }
    $memoryText = if($profile -and $profile.MemoryGB){ "{0:N1} GB" -f [double]$profile.MemoryGB }else{ "Unknown" }
    $uptimeText = if($profile -and $profile.UptimeDays -ne $null){ "{0:N2} days" -f [double]$profile.UptimeDays }else{ "Unknown" }
    $lastBootText = if($profile){ Format-GUIProfileDateTime -Value $profile.LastBoot }else{ "Unknown" }
    $servicingText = if($profile -and $profile.ServicingHealth){
        if(ConvertTo-GUIBoolean $profile.ServicingHealth.FollowUpDismSfc){"DISM/SFC follow-up"}else{"No repair flagged"}
    }else{
        "Unknown"
    }
    $summaryItems = @(
        @{ Label="Computer"; Value=$env:COMPUTERNAME },
        @{ Label="Domain"; Value=(Get-GUIDashboardInfo).Domain },
        @{ Label="Serial"; Value=$(if($profile){Format-GUIEmptyValue $profile.SerialNumber}else{"Unknown"}) },
        @{ Label="Health"; Value=$healthText },
        @{ Label="Quick Diag"; Value=Get-GUIQuickDiagnosisSummaryValue },
        @{ Label="Reboot"; Value=$pendingText },
        @{ Label="OS"; Value=$osText },
        @{ Label="PowerShell"; Value=$(if($profile){Format-GUIEmptyValue $profile.PowerShell}else{$PSVersionTable.PSVersion.ToString()}) },
        @{ Label="Servicing"; Value=$servicingText },
        @{ Label="Model"; Value=$modelText },
        @{ Label="CPU"; Value=$cpuText },
        @{ Label="Memory"; Value=$memoryText },
        @{ Label="Disk"; Value=Get-GUIPrimaryDiskSummary -Profile $profile },
        @{ Label="Network"; Value=Get-GUIPrimaryAdapterSummary -Profile $profile },
        @{ Label="Boot/Uptime"; Value="$lastBootText / $uptimeText" }
    )

    $cellIndex = 0
    foreach($item in $summaryItems){
        $label = New-Object System.Windows.Forms.Label
        $label.Text = $item.Label
        $label.Dock = "Fill"
        $label.AutoEllipsis = $true
        $label.TextAlign = "MiddleLeft"
        $label.Font = New-Object System.Drawing.Font("Segoe UI Semilight",8.75,[System.Drawing.FontStyle]::Bold)
        $label.ForeColor = $script:GUITheme.MutedText

        $value = New-Object System.Windows.Forms.Label
        $value.Text = [string]$item.Value
        $value.Dock = "Fill"
        $value.AutoEllipsis = $true
        $value.TextAlign = "MiddleLeft"
        $value.Font = New-Object System.Drawing.Font("Segoe UI",8.75)
        $value.ForeColor = $script:GUITheme.Text

        $row = [math]::Floor($cellIndex / 3)
        $column = ($cellIndex % 3) * 2
        $summary.Controls.Add($label,$column,$row)
        $summary.Controls.Add($value,($column + 1),$row)
        if($script:ToolTip){
            $script:ToolTip.SetToolTip($value,[string]$item.Value)
        }
        $cellIndex++
    }

    $script:FingerprintGrid = New-Object System.Windows.Forms.DataGridView
    $FingerprintGrid.Dock = "Fill"
    $FingerprintGrid.ReadOnly = $true
    $FingerprintGrid.AllowUserToAddRows = $false
    $FingerprintGrid.AllowUserToDeleteRows = $false
    $FingerprintGrid.RowHeadersVisible = $false
    $FingerprintGrid.MultiSelect = $false
    $FingerprintGrid.SelectionMode = "FullRowSelect"
    $FingerprintGrid.AutoSizeColumnsMode = "Fill"
    $FingerprintGrid.BackgroundColor = [System.Drawing.Color]::White
    $FingerprintGrid.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10)
    $layout.Controls.Add($FingerprintGrid,0,1)

    $buttons = New-Object System.Windows.Forms.FlowLayoutPanel
    $buttons.Dock = "Fill"
    $buttons.FlowDirection = "LeftToRight"
    $layout.Controls.Add($buttons,0,2)

    foreach($buttonDef in @(
        @{ Text = "Open HTML Report"; Action = { Open-SelectedFingerprintReport } },
        @{ Text = "Create Profile"; Action = { Take-FingerprintFromGUI } },
        @{ Text = "Delete"; Action = { Delete-SelectedFingerprint } },
        @{ Text = "Refresh"; Action = { Refresh-Fingerprints } }
    )){
        $button = New-Object System.Windows.Forms.Button
        $button.Text = $buttonDef.Text
        $button.Tag = $buttonDef.Action
        $button.Width = 160
        $button.Height = 32
        $button.Margin = New-Object System.Windows.Forms.Padding(6)
        $button.Add_Click({
            param($sender,$eventArgs)
            & $sender.Tag
        })
        [void]$buttons.Controls.Add($button)
    }

    $FingerprintGrid.Add_CellDoubleClick({ Open-SelectedFingerprintReport })
}

function Build-QuickTriagePage {
    param([System.Windows.Forms.TabPage]$Page)

    $layout = New-Object System.Windows.Forms.TableLayoutPanel
    $layout.Dock = "Fill"
    $layout.ColumnCount = 1
    $layout.RowCount = 2
    $layout.Padding = New-Object System.Windows.Forms.Padding(16)
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,82))) | Out-Null
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $Page.Controls.Add($layout)

    $runGroup = New-Object System.Windows.Forms.GroupBox
    $runGroup.Text = "Quick Diagnosis"
    $runGroup.Dock = "Fill"
    $runGroup.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $layout.Controls.Add($runGroup,0,0)

    $runPanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $runPanel.Dock = "Fill"
    $runPanel.Padding = New-Object System.Windows.Forms.Padding(10)
    $runGroup.Controls.Add($runPanel)

    $targetLabel = New-GUILabel "Internet test target"
    $targetLabel.Dock = "None"
    $targetLabel.Width = 130
    $targetLabel.Height = 30
    $targetLabel.Margin = New-Object System.Windows.Forms.Padding(3,7,6,3)
    [void]$runPanel.Controls.Add($targetLabel)

    $script:QuickTargetBox = New-GUITextBox "www.microsoft.com"
    $QuickTargetBox.Dock = "None"
    $QuickTargetBox.Width = 260
    $QuickTargetBox.Height = 26
    $QuickTargetBox.Margin = New-Object System.Windows.Forms.Padding(3,8,10,3)
    [void]$runPanel.Controls.Add($QuickTargetBox)

    $script:QuickRunButton = New-GUIButton "Run Quick Diagnosis" { Start-GUIQuickDiagnosis }
    $QuickRunButton.Width = 190
    [void]$runPanel.Controls.Add($QuickRunButton)

    $reportButton = New-GUIButton "Open Latest Report" { Open-GUILatestQuickDiagnosisReport }
    $reportButton.Width = 160
    [void]$runPanel.Controls.Add($reportButton)

    $script:QuickLastDiagnosisLabel = New-Object System.Windows.Forms.Label
    $QuickLastDiagnosisLabel.Width = 310
    $QuickLastDiagnosisLabel.Height = 30
    $QuickLastDiagnosisLabel.TextAlign = "MiddleLeft"
    $QuickLastDiagnosisLabel.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9)
    $QuickLastDiagnosisLabel.ForeColor = $script:GUITheme.MutedText
    $QuickLastDiagnosisLabel.Margin = New-Object System.Windows.Forms.Padding(12,7,3,3)
    [void]$runPanel.Controls.Add($QuickLastDiagnosisLabel)
    Refresh-GUILastQuickDiagnosisLabel

    $lowerLayout = New-Object System.Windows.Forms.TableLayoutPanel
    $lowerLayout.Dock = "Fill"
    $lowerLayout.ColumnCount = 2
    $lowerLayout.RowCount = 1
    $lowerLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,58))) | Out-Null
    $lowerLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,42))) | Out-Null
    $lowerLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $layout.Controls.Add($lowerLayout,0,1)

    $statusGroup = New-Object System.Windows.Forms.GroupBox
    $statusGroup.Text = "Quick Target Checks"
    $statusGroup.Dock = "Fill"
    $statusGroup.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $lowerLayout.Controls.Add($statusGroup,0,0)

    $statusLayout = New-Object System.Windows.Forms.TableLayoutPanel
    $statusLayout.Dock = "Fill"
    $statusLayout.ColumnCount = 1
    $statusLayout.RowCount = 4
    $statusLayout.Padding = New-Object System.Windows.Forms.Padding(12)
    $statusLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $statusLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,46))) | Out-Null
    $statusLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,48))) | Out-Null
    $statusLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,48))) | Out-Null
    $statusLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $statusGroup.Controls.Add($statusLayout)

    $healthPanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $healthPanel.Dock = "Fill"
    $healthPanel.FlowDirection = "LeftToRight"
    $statusLayout.Controls.Add($healthPanel,0,0)

    $script:HealthStatusLight = New-Object System.Windows.Forms.Panel
    $HealthStatusLight.Width = 24
    $HealthStatusLight.Height = 24
    $HealthStatusLight.Margin = New-Object System.Windows.Forms.Padding(4,8,8,4)
    [void]$healthPanel.Controls.Add($HealthStatusLight)

    $script:HealthStatusLabel = New-Object System.Windows.Forms.Label
    $HealthStatusLabel.Width = 430
    $HealthStatusLabel.Height = 36
    $HealthStatusLabel.TextAlign = "MiddleLeft"
    $HealthStatusLabel.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9)
    [void]$healthPanel.Controls.Add($HealthStatusLabel)

    $targetPanel = New-Object System.Windows.Forms.TableLayoutPanel
    $targetPanel.Dock = "Fill"
    $targetPanel.ColumnCount = 6
    $targetPanel.RowCount = 1
    $targetPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,58))) | Out-Null
    $targetPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $targetPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,46))) | Out-Null
    $targetPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,70))) | Out-Null
    $targetPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,58))) | Out-Null
    $targetPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,86))) | Out-Null
    $statusLayout.Controls.Add($targetPanel,0,1)

    $targetLabel = New-GUILabel "Target"
    $targetLabel.Dock = "Fill"
    $targetPanel.Controls.Add($targetLabel,0,0)

    $script:QuickPingBox = New-GUITextBox "10.10.10.1"
    $QuickPingBox.Dock = "Fill"
    $QuickPingBox.Height = 26
    $QuickPingBox.Margin = New-Object System.Windows.Forms.Padding(3,8,10,3)
    [void]$targetPanel.Controls.Add($QuickPingBox,1,0)

    $portLabel = New-GUILabel "Port"
    $portLabel.Dock = "Fill"
    $targetPanel.Controls.Add($portLabel,2,0)

    $script:QuickPortBox = New-GUITextBox "443"
    $QuickPortBox.Dock = "Fill"
    $QuickPortBox.Height = 26
    $QuickPortBox.Margin = New-Object System.Windows.Forms.Padding(3,8,3,3)
    [void]$targetPanel.Controls.Add($QuickPortBox,3,0)

    $recordLabel = New-GUILabel "Record"
    $recordLabel.Dock = "Fill"
    $targetPanel.Controls.Add($recordLabel,4,0)

    $script:QuickRecordTypeBox = New-Object System.Windows.Forms.ComboBox
    $QuickRecordTypeBox.Dock = "Fill"
    $QuickRecordTypeBox.DropDownStyle = "DropDownList"
    $QuickRecordTypeBox.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9)
    $QuickRecordTypeBox.Margin = New-Object System.Windows.Forms.Padding(3,8,3,3)
    Add-GUIComboItems -ComboBox $QuickRecordTypeBox -Items @("A","AAAA","CNAME","MX","TXT","NS","SOA","PTR","SRV")
    $targetPanel.Controls.Add($QuickRecordTypeBox,5,0)

    $actionPanel = New-Object System.Windows.Forms.TableLayoutPanel
    $actionPanel.Dock = "Fill"
    $actionPanel.ColumnCount = 6
    $actionPanel.RowCount = 1
    for($i = 0; $i -lt 6; $i++){
        $actionPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,(100 / 6)))) | Out-Null
    }
    $statusLayout.Controls.Add($actionPanel,0,2)

    foreach($buttonDef in @(
        @{ Text="Ping"; Action={ Invoke-GUIQuickPing } },
        @{ Text="TCPing"; Action={ Invoke-GUIQuickTcping } },
        @{ Text="Tracert"; Action={ Invoke-GUIQuickTracert } },
        @{ Text="NSLookup"; Action={ Invoke-GUIQuickNslookup } },
        @{ Text="DNS Lookup"; Action={ Invoke-GUIQuickDnsRecordLookup } },
        @{ Text="WHOIS"; Action={ Invoke-GUIQuickWhois } }
    )){
        $button = New-GUIButton $buttonDef.Text $buttonDef.Action
        $button.Dock = "Fill"
        $button.Width = 0
        [void]$actionPanel.Controls.Add($button)
    }

    $script:QuickOutputBox = New-Object System.Windows.Forms.TextBox
    $QuickOutputBox.Dock = "Fill"
    $QuickOutputBox.Multiline = $true
    $QuickOutputBox.ReadOnly = $true
    $QuickOutputBox.ScrollBars = "Both"
    $QuickOutputBox.WordWrap = $false
    $QuickOutputBox.Font = New-Object System.Drawing.Font("Consolas",9)
    $QuickOutputBox.BackColor = $script:GUITheme.LogBack
    $QuickOutputBox.ForeColor = $script:GUITheme.LogFore
    $QuickOutputBox.Text = "Quick target check output will appear here."
    $statusLayout.Controls.Add($QuickOutputBox,0,3)
    Update-GUIComputerHealthLight

    $repairGroup = New-Object System.Windows.Forms.GroupBox
    $repairGroup.Text = "Repair After Review"
    $repairGroup.Dock = "Fill"
    $repairGroup.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $lowerLayout.Controls.Add($repairGroup,1,0)

    $repairPanel = New-Object System.Windows.Forms.TableLayoutPanel
    $repairPanel.Dock = "Fill"
    $repairPanel.Padding = New-Object System.Windows.Forms.Padding(10)
    $repairPanel.ColumnCount = 1
    $repairPanel.RowCount = 3
    $repairPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,70))) | Out-Null
    $repairPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,48))) | Out-Null
    $repairPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $repairGroup.Controls.Add($repairPanel)

    $script:DismRepairNoteLabel = New-Object System.Windows.Forms.Label
    $repairNote = $script:DismRepairNoteLabel
    $repairNote.Text = "Run Quick Diagnosis first. Override is available if symptoms justify it."
    $repairNote.Dock = "Fill"
    $repairNote.TextAlign = "MiddleLeft"
    $repairNote.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9)
    [void]$repairPanel.Controls.Add($repairNote,0,0)

    $script:DismRepairButton = New-GUIButton "Run DISM/SFC Repair Path" { Start-GUIDismSfcRepairPath }
    $DismRepairButton.Dock = "Fill"
    [void]$repairPanel.Controls.Add($DismRepairButton,0,1)

    $hardwareShortcuts = New-Object System.Windows.Forms.GroupBox
    $hardwareShortcuts.Text = "Hardware Shortcuts"
    $hardwareShortcuts.Dock = "Fill"
    $hardwareShortcuts.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9.5,[System.Drawing.FontStyle]::Bold)
    $repairPanel.Controls.Add($hardwareShortcuts,0,2)

    $hardwareShortcutPanel = New-Object System.Windows.Forms.TableLayoutPanel
    $hardwareShortcutPanel.Dock = "Top"
    $hardwareShortcutPanel.AutoSize = $true
    $hardwareShortcutPanel.ColumnCount = 2
    $hardwareShortcutPanel.RowCount = 0
    $hardwareShortcutPanel.Padding = New-Object System.Windows.Forms.Padding(8)
    $hardwareShortcuts.Controls.Add($hardwareShortcutPanel)

    $quickHardwareTools = @(
        @{ Text="CPU-Z"; Action={ Start-GUICustomToolByName -Name "CPU-Z" }; Tip="Open CPU-Z for CPU, memory, motherboard, and platform details." },
        @{ Text="GPU-Z"; Action={ Start-GUICustomToolByName -Name "GPU-Z" }; Tip="Open GPU-Z for graphics adapter, driver, and sensor details." },
        @{ Text="HWMonitor"; Action={ Start-GUICustomToolByName -Name "HWMonitor" }; Tip="Open HWMonitor for temperatures, voltage, and fan sensor checks." },
        @{ Text="CrystalDiskInfo"; Action={ Start-GUIExternalToolById -Id "CrystalDiskInfo" }; Tip="Open CrystalDiskInfo for SMART and drive health details." },
        @{ Text="HWiNFO"; Action={ Start-GUIExternalToolById -Id "HWiNFO" }; Tip="Open HWiNFO for detailed hardware inventory and sensor review." }
    )

    for($i = 0; $i -lt 2; $i++){
        $hardwareShortcutPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    }

    $shortcutRow = 0
    $shortcutCol = 0
    foreach($toolDef in $quickHardwareTools){
        if($shortcutCol -eq 0){
            $hardwareShortcutPanel.RowCount = $hardwareShortcutPanel.RowCount + 1
            $hardwareShortcutPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,38))) | Out-Null
        }

        $button = New-GUIButton $toolDef.Text $toolDef.Action
        $button.Dock = "Fill"
        $button.Width = 0
        $button.Margin = New-Object System.Windows.Forms.Padding(4)
        if($script:ToolTip){ $script:ToolTip.SetToolTip($button,$toolDef.Tip) }
        [void]$hardwareShortcutPanel.Controls.Add($button,$shortcutCol,$shortcutRow)

        $shortcutCol = ($shortcutCol + 1) % 2
        if($shortcutCol -eq 0){ $shortcutRow++ }
    }

    Refresh-GUIDismSfcState
}

function Add-GUIHeaderComputerSummary {
    param([System.Windows.Forms.Panel]$Header)

    $dashboard = Get-GUIDashboardInfo

    $summary = New-Object System.Windows.Forms.TableLayoutPanel
    $summary.Location = New-Object System.Drawing.Point(360,10)
    $summary.Size = New-Object System.Drawing.Size(670,58)
    $summary.Anchor = "Top,Left,Right"
    $summary.ColumnCount = 4
    $summary.RowCount = 2
    $summary.BackColor = $script:GUITheme.HeaderPanel
    $script:HeaderSummaryPanel = $summary
    $summary.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $summary.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $summary.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,88))) | Out-Null
    $summary.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $summary.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,78))) | Out-Null
    $summary.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $Header.Controls.Add($summary)

    foreach($cell in @(
        @{R=0;C=0;Text="Computer";Bold=$true;Key=""},
        @{R=0;C=1;Text=$dashboard.ComputerName;Key="ComputerName"},
        @{R=0;C=2;Text="Domain";Bold=$true;Key=""},
        @{R=0;C=3;Text=$dashboard.Domain;Key="Domain"},
        @{R=1;C=0;Text="Private IP";Bold=$true;Key=""},
        @{R=1;C=1;Text=$dashboard.PrivateIP;Key="PrivateIP"},
        @{R=1;C=2;Text="Public IP";Bold=$true;Key="PublicIPLabel"},
        @{R=1;C=3;Text=$dashboard.PublicIP;Key="PublicIP"}
    )){
        $label = New-Object System.Windows.Forms.Label
        $label.Text = $cell.Text
        $label.Dock = "Fill"
        $label.TextAlign = "MiddleLeft"
        $label.AutoEllipsis = $true
        $label.ForeColor = if($cell.Bold){$script:GUITheme.HeaderMuted}else{[System.Drawing.Color]::White}
        $label.Font = if($cell.Bold){New-Object System.Drawing.Font("Segoe UI Semilight",9.5,[System.Drawing.FontStyle]::Bold)}else{New-Object System.Drawing.Font("Segoe UI Semilight",9.5)}
        $summary.Controls.Add($label,$cell.C,$cell.R)

        if($cell.Span){
            $summary.SetColumnSpan($label,$cell.Span)
        }

        if($cell.Key){
            $script:DashboardLabels[$cell.Key] = $label
        }

        if($cell.Key -eq "PublicIP" -or $cell.Key -eq "PublicIPLabel"){
            $label.Cursor = [System.Windows.Forms.Cursors]::Hand
            $label.Add_Click({
                param($sender,$eventArgs)
                try {
                    if($script:DashboardLabels.ContainsKey("PublicIP")){
                        $script:DashboardLabels["PublicIP"].Text = "Refreshing..."
                    }
                }
                catch {}
                Update-GUIPublicIPSummaryAsync -Quiet
            })
            if($script:ToolTip){
                $script:ToolTip.SetToolTip($label,"Click to refresh the public IP lookup.")
            }
        }
    }

    $script:PublicIPRefreshButton = $null

    $refreshPublicIPOnLaunch = $true
    if($script:GuiSettings -and $script:GuiSettings.PSObject.Properties.Name -contains "refreshPublicIPOnLaunch"){
        $refreshPublicIPOnLaunch = [bool]$script:GuiSettings.refreshPublicIPOnLaunch
    }

    if($refreshPublicIPOnLaunch){
        Update-GUIPublicIPSummaryAsync -Quiet
    }
}

function Update-GUIStaticTabStripSelection {
    if(!$script:MainTabs -or !$script:TabButtons){
        return
    }

    foreach($entry in $script:TabButtons.GetEnumerator()){
        $button = $entry.Value
        $selected = ($script:MainTabs.SelectedTab -and $script:MainTabs.SelectedTab.Text -eq $entry.Key)
        Set-GUITabButtonChrome -Button $button -Selected $selected
    }
}

function Register-GUITabBuilder {
    param(
        [System.Windows.Forms.TabPage]$Page,
        [scriptblock]$Builder
    )

    if(!$Page -or !$Builder){
        return
    }

    $script:TabBuilders[$Page.Text] = @{
        Page = $Page
        Builder = $Builder
    }
}

function Build-GUITabIfNeeded {
    param([System.Windows.Forms.TabPage]$Page)

    if(!$Page){
        return
    }

    if($script:BuiltTabs.ContainsKey($Page.Text)){
        return
    }

    if(!$script:TabBuilders.ContainsKey($Page.Text)){
        $script:BuiltTabs[$Page.Text] = $true
        return
    }

    $entry = $script:TabBuilders[$Page.Text]
    $Page.SuspendLayout()

    try {
        & $entry.Builder $Page
        $script:BuiltTabs[$Page.Text] = $true
        Set-GUIFallbackButtonToolTips
    }
    catch {
        Add-GUILog "Failed to build $($Page.Text) tab: $($_.Exception.Message)"
        $label = New-Object System.Windows.Forms.Label
        $label.Dock = "Fill"
        $label.TextAlign = "MiddleCenter"
        $label.Font = New-Object System.Drawing.Font("Segoe UI Semilight",11)
        $label.ForeColor = $script:GUITheme.Danger
        $label.Text = "This tab failed to load.`r`n`r`n$($_.Exception.Message)"
        $Page.Controls.Clear()
        $Page.Controls.Add($label)
        $script:BuiltTabs[$Page.Text] = $true
    }
    finally {
        $Page.ResumeLayout()
    }
}

function Refresh-GUICustomToolTabs {
    $customToolTabs = @("Quick Diagnosis","Analyze","Windows Update","Hardware","Crash","Processes","Network","Remote","PsExec","Services","Repair","Directory","Security","Wi-Fi","Print","Files","Discovery","Robocopy","Software","Clean Up","Apps")

    if(!$script:MainTabs){
        return
    }

    foreach($tabName in $customToolTabs){
        if(!$script:BuiltTabs.ContainsKey($tabName)){
            continue
        }

        $tab = $script:MainTabs.TabPages | Where-Object { $_.Text -eq $tabName } | Select-Object -First 1
        if(!$tab){
            continue
        }

        $tab.Controls.Clear()
        $script:BuiltTabs.Remove($tabName)

        if($script:MainTabs.SelectedTab -and $script:MainTabs.SelectedTab.Text -eq $tabName){
            Build-GUITabIfNeeded -Page $tab
        }
    }
}

function Add-GUIStaticTabStrip {
    param(
        [System.Windows.Forms.FlowLayoutPanel]$Strip,
        [System.Windows.Forms.TabControl]$Tabs
    )

    $script:TabButtons = @{}
    $Strip.Controls.Clear()

    foreach($page in $Tabs.TabPages){
        if($page.Text -eq "Settings"){
            continue
        }

        $button = New-Object System.Windows.Forms.Button
        $button.Text = $page.Text
        $button.Tag = $page
        $button.Width = 132
        $button.Height = 28
        $button.Margin = New-Object System.Windows.Forms.Padding(4,4,4,4)
        Set-GUITabButtonChrome -Button $button -Selected:$false
        $button.Add_Click({
            param($sender,$eventArgs)
            $script:MainTabs.SelectedTab = $sender.Tag
            Build-GUITabIfNeeded -Page $sender.Tag
            Update-GUIStaticTabStripSelection
        })
        [void]$Strip.Controls.Add($button)
        $script:TabButtons[$page.Text] = $button
    }

    Update-GUIStaticTabStripSelection
}

function Add-GUIComboItems {
    param(
        [System.Windows.Forms.ComboBox]$ComboBox,
        [string[]]$Items,
        [int]$SelectedIndex = 0
    )

    foreach($item in $Items){
        [void]$ComboBox.Items.Add($item)
    }

    if($ComboBox.Items.Count -gt $SelectedIndex){
        $ComboBox.SelectedIndex = $SelectedIndex
    }
}

function Get-GUIDefaultTabOrder {
    return @(
        "Quick Diagnosis",
        "Analyze",
        "Windows Update",
        "Hardware",
        "Crash",
        "Processes",
        "Network",
        "Remote",
        "PsExec",
        "Services",
        "Repair",
        "Directory",
        "Security",
        "Wi-Fi",
        "Print",
        "Files",
        "Discovery",
        "Robocopy",
        "Software",
        "Clean Up",
        "Apps",
        "Choco",
        "Sysinternals",
        "Computer Info",
        "Reports",
        "Live Log"
    )
}

function Get-GUISettingsPath {
    if($CSIFiles -and $CSIFiles.PSObject.Properties.Name -contains "GuiSettings" -and $CSIFiles.GuiSettings){
        return $CSIFiles.GuiSettings
    }

    return Join-Path $CSIPaths.Manifests "gui-settings.json"
}

function Get-GUIDefaultSettings {
    $defaultTheme = Get-GUIColorTheme -Name "Bright Blue"

    [pscustomobject]@{
        tabOrder = @(Get-GUIDefaultTabOrder)
        startupTab = "Quick Diagnosis"
        colorTheme = "Bright Blue"
        customTheme = ConvertTo-GUICustomThemeSettings $defaultTheme
        autoOpenQuickDiagnosisReport = $false
        refreshPublicIPOnLaunch = $true
    }
}

function Get-GUISettings {
    $path = Get-GUISettingsPath
    $default = Get-GUIDefaultSettings

    if(Test-Path $path){
        try {
            $settings = Get-Content -Raw -Path $path | ConvertFrom-Json
            if($settings.PSObject.Properties.Name -notcontains "tabOrder" -or @($settings.tabOrder).Count -eq 0){
                $settings | Add-Member -MemberType NoteProperty -Name tabOrder -Value $default.tabOrder -Force
            }
            if($settings.PSObject.Properties.Name -notcontains "startupTab" -or !$settings.startupTab){
                $settings | Add-Member -MemberType NoteProperty -Name startupTab -Value $default.startupTab -Force
            }
            if($settings.PSObject.Properties.Name -notcontains "colorTheme" -or !$settings.colorTheme){
                $settings | Add-Member -MemberType NoteProperty -Name colorTheme -Value $default.colorTheme -Force
            }
            if($settings.PSObject.Properties.Name -notcontains "customTheme" -or !$settings.customTheme){
                $settings | Add-Member -MemberType NoteProperty -Name customTheme -Value $default.customTheme -Force
            }
            if($settings.PSObject.Properties.Name -notcontains "autoOpenQuickDiagnosisReport"){
                $settings | Add-Member -MemberType NoteProperty -Name autoOpenQuickDiagnosisReport -Value $default.autoOpenQuickDiagnosisReport -Force
            }
            if($settings.PSObject.Properties.Name -notcontains "refreshPublicIPOnLaunch"){
                $settings | Add-Member -MemberType NoteProperty -Name refreshPublicIPOnLaunch -Value $default.refreshPublicIPOnLaunch -Force
            }
            return $settings
        }
        catch {
            Add-GUILog "GUI settings could not be read. Using defaults: $($_.Exception.Message)"
        }
    }

    return $default
}

function Save-GUISettings {
    param([pscustomobject]$Settings)

    $path = Get-GUISettingsPath
    if(!(Test-Path $CSIPaths.Manifests)){
        New-Item -ItemType Directory -Path $CSIPaths.Manifests -Force | Out-Null
    }

    $Settings | ConvertTo-Json -Depth 6 | Set-Content -Path $path -Encoding UTF8
    $script:GuiSettings = $Settings
}

function Get-GUIOrderedTabNames {
    param([string[]]$AvailableTabs)

    $settings = if($script:GuiSettings){$script:GuiSettings}else{Get-GUISettings}
    $ordered = New-Object System.Collections.Generic.List[string]

    foreach($name in @($settings.tabOrder)){
        if($name -eq "Windows"){
            $name = "Analyze"
        }
        elseif($name -eq "Custom"){
            $name = "Apps"
        }

        if($name -eq "Settings"){
            continue
        }

        if($AvailableTabs -contains $name -and !$ordered.Contains($name)){
            [void]$ordered.Add($name)
        }
    }

    if($AvailableTabs -contains "Windows Update" -and !$ordered.Contains("Windows Update")){
        $insertIndex = $ordered.IndexOf("Analyze")
        if($insertIndex -ge 0){
            $ordered.Insert(($insertIndex + 1),"Windows Update")
        }
    }

    foreach($name in $AvailableTabs){
        if(!$ordered.Contains($name)){
            [void]$ordered.Add($name)
        }
    }

    return [string[]]$ordered
}

function Apply-GUITabOrder {
    param(
        [System.Windows.Forms.TabControl]$Tabs,
        [string[]]$Order
    )

    if(!$Tabs -or !$Order){
        return
    }

    $selectedName = if($Tabs.SelectedTab){$Tabs.SelectedTab.Text}else{""}
    $pagesByName = @{}

    foreach($page in @($Tabs.TabPages)){
        $pagesByName[$page.Text] = $page
    }

    $Tabs.SuspendLayout()
    try {
        $Tabs.TabPages.Clear()

        foreach($name in $Order){
            if($pagesByName.ContainsKey($name)){
                [void]$Tabs.TabPages.Add($pagesByName[$name])
            }
        }

        foreach($name in ($pagesByName.Keys | Sort-Object)){
            if($Order -notcontains $name){
                [void]$Tabs.TabPages.Add($pagesByName[$name])
            }
        }

        if($selectedName -and $pagesByName.ContainsKey($selectedName)){
            $Tabs.SelectedTab = $pagesByName[$selectedName]
        }
    }
    finally {
        $Tabs.ResumeLayout()
    }
}

function New-GUILabel {
    param([string]$Text)

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Text
    $label.Dock = "Fill"
    $label.TextAlign = "MiddleLeft"
    $label.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9)
    return $label
}

function New-GUITextBox {
    param([string]$Text = "")

    $box = New-Object System.Windows.Forms.TextBox
    $box.Dock = "Fill"
    $box.Text = $Text
    $box.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9)
    return $box
}

function New-GUIButton {
    param(
        [string]$Text,
        [scriptblock]$Action
    )

    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Tag = $Action
    $button.Width = 150
    $button.Height = 32
    $button.Margin = New-Object System.Windows.Forms.Padding(5)
    $button.TextAlign = "MiddleCenter"
    Set-GUIButtonChrome -Button $button
    $button.Add_Click({
        param($sender,$eventArgs)
        Invoke-GUISafely -Tool $sender.Text -Action $sender.Tag
    })
    return $button
}

function New-GUIToolButton {
    param(
        [string]$Text,
        [string]$FunctionName
    )

    return New-GUIButton -Text $Text -Action ([scriptblock]::Create("Start-GUIToolkitFunctionConsole -FunctionName '$FunctionName'"))
}

function New-GUIExternalToolButton {
    param(
        [string]$Text,
        [string]$ToolId
    )

    return New-GUIButton -Text $Text -Action ([scriptblock]::Create("Start-GUIExternalToolById -Id '$ToolId'"))
}

function New-GUIToolItem {
    param(
        [string]$Text,
        [string]$Description,
        [string]$Section = "",
        [string]$FunctionName = "",
        [string]$External = "",
        [scriptblock]$Action = $null,
        [string]$ActionName = "",
        [bool]$RequiresAdmin = $false
    )

    return [pscustomobject]@{
        Text        = $Text
        Description = $Description
        Section     = $Section
        Function    = $FunctionName
        External    = $External
        ActionName  = $ActionName
        Action      = $Action
        RequiresAdmin = $RequiresAdmin
    }
}

function Get-GUIToolAction {
    param([pscustomobject]$Tool)

    if($Tool.Action){
        return $Tool.Action
    }

    if($Tool.External){
        return [scriptblock]::Create("Start-GUIExternalToolById -Id '$($Tool.External)'")
    }

    if($Tool.ActionName){
        return [scriptblock]::Create("Invoke-GUINamedAction -Action '$($Tool.ActionName)'")
    }

    $functionName = $Tool.Function.Replace("'","''")
    $displayName = $Tool.Text.Replace("'","''")
    $requiresAdmin = if($Tool.RequiresAdmin){"`$true"}else{"`$false"}
    return [scriptblock]::Create("Start-GUIToolkitFunctionConsole -FunctionName '$functionName' -DisplayName '$displayName' -RequiresAdmin:$requiresAdmin")
}

function Get-GUICatalogTools {
    param([string]$Tab)

    if(!(Get-Command Get-CSIToolCatalog -ErrorAction SilentlyContinue)){
        return @()
    }

    return @(Get-CSIToolCatalog | Where-Object { $_.Tab -eq $Tab } | ForEach-Object {
        New-GUIToolItem `
            -Text $_.Text `
            -Description $_.Description `
            -Section $_.Section `
            -FunctionName $_.Function `
            -External $_.External `
            -ActionName $_.Action `
            -RequiresAdmin ([bool]$_.RequiresAdmin)
    })
}

function Get-GUICustomToolPlacement {
    param([pscustomobject]$Tool)

    $key = (($Tool.Name,([System.IO.Path]::GetFileNameWithoutExtension($Tool.LaunchPath)) -join " ") -replace '[^A-Za-z0-9]+','').ToLowerInvariant()

    $map = @{
        "bleachbitbleachbit" = @{ Tab = "Clean Up"; Section = "Disk Cleanup"; Description = "Clean temporary files, browser caches, and application leftovers." }
        "bleachbitportablebleachbit" = @{ Tab = "Clean Up"; Section = "Disk Cleanup"; Description = "Clean temporary files, browser caches, and application leftovers." }
        "ccleanerccleaner" = @{ Tab = "Clean Up"; Section = "Disk Cleanup"; Description = "Run CCleaner for temporary-file and application cleanup checks." }
        "ccleanerportableccleaner" = @{ Tab = "Clean Up"; Section = "Disk Cleanup"; Description = "Run CCleaner for temporary-file and application cleanup checks." }
        "cpuzcpuz" = @{ Tab = "Hardware"; Section = "Hardware Inspection"; Description = "Inspect CPU, memory, motherboard, and platform details." }
        "cpuzportablecpuz" = @{ Tab = "Hardware"; Section = "Hardware Inspection"; Description = "Inspect CPU, memory, motherboard, and platform details." }
        "fastresolverfastresolver" = @{ Tab = "Network"; Section = "Name Resolution"; Description = "Quickly resolve hostnames and IP addresses across a range." }
        "fastresolverportablefastresolver" = @{ Tab = "Network"; Section = "Name Resolution"; Description = "Quickly resolve hostnames and IP addresses across a range." }
        "firefoxportablefirefoxportable" = @{ Tab = "Software"; Section = "Portable Browser"; Description = "Open the toolkit-contained Firefox browser profile." }
        "gpuzgpuz2690" = @{ Tab = "Hardware"; Section = "Hardware Inspection"; Description = "Inspect GPU model, drivers, sensors, and graphics capabilities." }
        "hwmonitorhwmonitorportable" = @{ Tab = "Hardware"; Section = "Hardware Inspection"; Description = "View live hardware voltages, temperatures, fans, and sensor values." }
        "hwmonitorportablehwmonitorportable" = @{ Tab = "Hardware"; Section = "Hardware Inspection"; Description = "View live hardware voltages, temperatures, fans, and sensor values." }
        "kittykitty" = @{ Tab = "Remote"; Section = "Remote Access"; Description = "Open KiTTY for SSH and Telnet sessions." }
        "libreofficelibreofficeportable" = @{ Tab = "Software"; Section = "Office And Documents"; Description = "Open LibreOffice Portable for documents, spreadsheets, and presentations." }
        "libreofficeportablelibreofficeportable" = @{ Tab = "Software"; Section = "Office And Documents"; Description = "Open LibreOffice Portable for documents, spreadsheets, and presentations." }
        "lockhunterlockhunter" = @{ Tab = "Clean Up"; Section = "Locked Files"; Description = "Find and release file or folder locks that block delete, rename, or move operations." }
        "pcizpciz" = @{ Tab = "Hardware"; Section = "Hardware Inspection"; Description = "Identify PCI devices and driver/vendor details." }
        "puttyputty" = @{ Tab = "Remote"; Section = "Remote Access"; Description = "Open PuTTY for SSH, Telnet, serial, and raw TCP sessions." }
        "pwgenpwgenportable" = @{ Tab = "Security"; Section = "Password Tools"; Description = "Generate strong random passwords from a portable utility." }
        "pwgenportablepwgenportable" = @{ Tab = "Security"; Section = "Password Tools"; Description = "Generate strong random passwords from a portable utility." }
        "quickmemorytestokquickmemorytestokportable" = @{ Tab = "Hardware"; Section = "Hardware Testing"; Description = "Run a quick memory stress and validation test." }
        "quickmemorytestokportablequickmemorytestokportable" = @{ Tab = "Hardware"; Section = "Hardware Testing"; Description = "Run a quick memory stress and validation test." }
        "revouninstallerrevouninstallerportable" = @{ Tab = "Clean Up"; Section = "Uninstall And Leftovers"; Description = "Remove installed programs and scan for leftovers." }
        "revouninstallerportablerevouninstallerportable" = @{ Tab = "Clean Up"; Section = "Uninstall And Leftovers"; Description = "Remove installed programs and scan for leftovers." }
        "rustdeskrustdeskqs" = @{ Tab = "Remote"; Section = "Remote Access"; Description = "Launch RustDesk quick support for remote control sessions." }
        "rustdeskportablerustdeskqs" = @{ Tab = "Remote"; Section = "Remote Access"; Description = "Launch RustDesk quick support for remote control sessions." }
        "ssdzssdzportable" = @{ Tab = "Hardware"; Section = "Storage"; Description = "Inspect SSD identity, SMART data, and storage health details." }
        "ssdzportablessdzportable" = @{ Tab = "Hardware"; Section = "Storage"; Description = "Inspect SSD identity, SMART data, and storage health details." }
        "whatchangedwhatchangedportable" = @{ Tab = "Discovery"; Section = "Change Tracking"; Description = "Snapshot and compare file and registry changes." }
        "whatchangedportablewhatchangedportable" = @{ Tab = "Discovery"; Section = "Change Tracking"; Description = "Snapshot and compare file and registry changes." }
        "winmtrwinmtr64" = @{ Tab = "Network"; Section = "Path Testing"; Description = "Trace route quality and packet loss over time." }
        "winmtrreduxwinmtr64" = @{ Tab = "Network"; Section = "Path Testing"; Description = "Trace route quality and packet loss over time." }
        "winscpwinscp" = @{ Tab = "Remote"; Section = "File Transfer"; Description = "Open WinSCP for SFTP, SCP, FTP, and WebDAV transfers." }
        "winscpportablewinscp" = @{ Tab = "Remote"; Section = "File Transfer"; Description = "Open WinSCP for SFTP, SCP, FTP, and WebDAV transfers." }
        "wiseregistrycleanerwiseregistrycleanerportable" = @{ Tab = "Clean Up"; Section = "Registry Cleanup"; Description = "Review registry cleanup findings before making changes." }
        "wiseregistrycleanerportablewiseregistrycleanerportable" = @{ Tab = "Clean Up"; Section = "Registry Cleanup"; Description = "Review registry cleanup findings before making changes." }
        "xpyxpyportable" = @{ Tab = "Security"; Section = "Privacy And Hardening"; Description = "Review Windows privacy and hardening settings." }
        "xpyportablexpyportable" = @{ Tab = "Security"; Section = "Privacy And Hardening"; Description = "Review Windows privacy and hardening settings." }
        "bulkuninstallerbcuninstaller" = @{ Tab = "Clean Up"; Section = "Uninstall And Leftovers"; Description = "Open Bulk Uninstaller with the bundled .NET runtime." }
        "profilecleanuptoolkitmultiproftoolv5" = @{ Tab = "Clean Up"; Section = "Profile Cleanup"; Description = "Inspect and clean stale Windows user profiles. Use carefully; profile deletion is destructive." }
        "hijackthishijackthisportable" = @{ Tab = "Security"; Section = "Security Inspection"; Description = "Run HijackThis to inspect browser helpers, startup entries, services, and persistence points." }
        "hijackthisportablehijackthisportable" = @{ Tab = "Security"; Section = "Security Inspection"; Description = "Run HijackThis to inspect browser helpers, startup entries, services, and persistence points." }
        "mremotengmremoteng" = @{ Tab = "Remote"; Section = "Remote Access"; Description = "Open mRemoteNG for tabbed RDP, VNC, SSH, Telnet, and multi-protocol remote sessions." }
        "mremotengportablemremoteng" = @{ Tab = "Remote"; Section = "Remote Access"; Description = "Open mRemoteNG for tabbed RDP, VNC, SSH, Telnet, and multi-protocol remote sessions." }
        "speccyspeccy64" = @{ Tab = "Hardware"; Section = "Hardware Inspection"; Description = "Open Speccy for a quick computer hardware and operating system inventory." }
        "speccyportablespeccy64" = @{ Tab = "Hardware"; Section = "Hardware Inspection"; Description = "Open Speccy for a quick computer hardware and operating system inventory." }
        "tigervncviewervncviewer64" = @{ Tab = "Remote"; Section = "Remote Access"; Description = "Open TigerVNC Viewer for direct VNC connections to systems running a VNC server." }
        "tigervncvncviewer64" = @{ Tab = "Remote"; Section = "Remote Access"; Description = "Open TigerVNC Viewer for direct VNC connections to systems running a VNC server." }
        "tightvnctvnviewer" = @{ Tab = "Remote"; Section = "Remote Access"; Description = "Open TightVNC Viewer for direct VNC connections to systems running a VNC server." }
        "tightvncviewertvnviewer" = @{ Tab = "Remote"; Section = "Remote Access"; Description = "Open TightVNC Viewer for direct VNC connections to systems running a VNC server." }
    }

    $placement = $null
    if($map.ContainsKey($key)){
        $placement = [pscustomobject]$map[$key]
    }
    else{
        $placement = [pscustomobject]@{
            Tab = "Apps"
            Section = "Toolkit Apps"
            Description = "Launch this toolkit-installed portable application."
        }
    }

    if($Tool.PSObject.Properties.Name -contains "TabOverride" -and $Tool.TabOverride){
        $override = [string]$Tool.TabOverride
        if($override -eq "Custom"){ $override = "Apps" }
        $placement.Tab = $override
    }

    return $placement
}

function Get-GUICustomTabItems {
    param(
        [string]$Tab,
        [object[]]$ExistingTools = @()
    )

    $existingNames = @{}
    foreach($existing in @($ExistingTools)){
        if($existing.Text){
            $existingNames[$existing.Text.ToLowerInvariant()] = $true
        }
    }

    $items = @()
    foreach($tool in @(Get-GUICustomTools | Where-Object { $_.Status -eq "Ready" })){
        $placement = Get-GUICustomToolPlacement -Tool $tool
        if($placement.Tab -ne $Tab){
            continue
        }

        if($existingNames.ContainsKey($tool.Name.ToLowerInvariant())){
            continue
        }

        $launchPath = $tool.LaunchPath.Replace("'","''")
        $items += New-GUIToolItem `
            -Text $tool.Name `
            -Description $placement.Description `
            -Section $placement.Section `
            -Action ([scriptblock]::Create("Start-GUICustomToolByLaunchPath -LaunchPath '$launchPath'"))
    }

    return $items
}

function Build-GUICatalogToolsPage {
    param(
        [System.Windows.Forms.TabPage]$Page,
        [string]$Tab,
        [string]$Title
    )

    $tools = @(Get-GUICatalogTools -Tab $Tab)
    $tools += @(Get-GUIMappedSysinternalsItems -Tab $Tab)
    $tools += @(Get-GUICustomTabItems -Tab $Tab -ExistingTools $tools)
    Add-GUICompactToolGrid -Page $Page -Title $Title -Tools $tools -Columns 4
}

function Get-GUIToolsForTab {
    param([string]$Tab)

    $tools = @(Get-GUICatalogTools -Tab $Tab)
    $tools += @(Get-GUIMappedSysinternalsItems -Tab $Tab)
    $tools += @(Get-GUICustomTabItems -Tab $Tab -ExistingTools $tools)
    return @($tools)
}

function Set-GUIToolSection {
    param(
        [pscustomobject]$Tool,
        [string]$Section
    )

    if($Tool.PSObject.Properties["Section"]){
        $Tool.Section = $Section
    }
    else {
        Add-Member -InputObject $Tool -MemberType NoteProperty -Name Section -Value $Section -Force
    }
}

function Build-GUIOptimizedToolPage {
    param(
        [System.Windows.Forms.TabPage]$Page,
        [string]$Tab,
        [string]$Title,
        [hashtable]$SectionMap,
        [string[]]$SectionOrder
    )

    $tools = @(Get-GUIToolsForTab -Tab $Tab)

    foreach($tool in $tools){
        $key = ($tool.Text -replace '[^A-Za-z0-9]+','').ToLowerInvariant()
        if($SectionMap.ContainsKey($key)){
            Set-GUIToolSection -Tool $tool -Section $SectionMap[$key]
        }
    }

    $orderLookup = @{}
    for($i = 0; $i -lt $SectionOrder.Count; $i++){
        $orderLookup[$SectionOrder[$i]] = $i
    }

    $tools = @($tools | Sort-Object `
        @{Expression={ if($orderLookup.ContainsKey($_.Section)){ $orderLookup[$_.Section] } else { 99 } }},
        @{Expression={ $_.Text }})

    Add-GUICompactToolGrid -Page $Page -Title $Title -Tools $tools -Columns 4
}

function Get-GUIMappedSysinternalsItems {
    param([string]$Tab)

    $categoryMap = @{
        "Processes" = @("Process And Startup")
        "Network" = @("Network")
        "Directory" = @("Active Directory")
    }

    if(!$categoryMap.ContainsKey($Tab)){
        return @()
    }

    $alreadyCataloged = @("procexp","procmon","autoruns","rammap","tcpview","psping","psexec","handle","sigcheck")
    $categories = $categoryMap[$Tab]
    $items = @()

    foreach($tool in @(Get-GUISysinternalsTools | Where-Object { $categories -contains $_.Category -and $alreadyCataloged -notcontains $_.Name.ToLowerInvariant() })){
        $path = $tool.Path.Replace("'","''")
        $name = $tool.DisplayName.Replace("'","''")
        $console = if($tool.Console){"`$true"}else{"`$false"}
        $risky = if($tool.Risky){"`$true"}else{"`$false"}
        $description = Get-GUISysinternalsDescription -BaseName $tool.Name -FileName $tool.FileName -Category $tool.Category -Console $tool.Console -Risky $tool.Risky

        $items += New-GUIToolItem `
            -Text $tool.DisplayName `
            -Description $description `
            -Section "Sysinternals" `
            -Action ([scriptblock]::Create("Start-GUISysinternalsTool -Path '$path' -DisplayName '$name' -Console $console -Risky $risky"))
    }

    return $items
}

function New-GUICompactToolControl {
    param([pscustomobject]$Tool)

    $panel = New-Object System.Windows.Forms.Panel
    $panel.Dock = "Fill"
    $panel.Margin = New-Object System.Windows.Forms.Padding(4)
    $panel.Height = 30

    $button = New-Object System.Windows.Forms.Button
    $button.Text = ">"
    $button.Tag = (Get-GUIToolAction -Tool $Tool)
    $button.Location = New-Object System.Drawing.Point(0,2)
    $button.Size = New-Object System.Drawing.Size(26,26)
    Set-GUIButtonChrome -Button $button -Compact
    $button.Add_Click({
        param($sender,$eventArgs)
        Invoke-GUISafely -Tool $sender.Parent.Controls[1].Text -Action $sender.Tag
    })
    $panel.Controls.Add($button)

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Tool.Text
    $label.Tag = $button.Tag
    $label.Location = New-Object System.Drawing.Point(34,4)
    $label.Size = New-Object System.Drawing.Size(220,22)
    $label.Anchor = "Top,Left,Right"
    $label.Font = New-Object System.Drawing.Font("Segoe UI",9)
    $label.TextAlign = "MiddleLeft"
    $label.AutoEllipsis = $true
    $label.Cursor = [System.Windows.Forms.Cursors]::Hand
    $label.Add_Click({
        param($sender,$eventArgs)
        Invoke-GUISafely -Tool $sender.Text -Action $sender.Tag
    })
    $panel.Controls.Add($label)

    if($script:ToolTip){
        $tip = if($Tool.Description){$Tool.Description}else{$Tool.Text}
        $script:ToolTip.SetToolTip($button,$tip)
        $script:ToolTip.SetToolTip($label,$tip)
        $script:ToolTip.SetToolTip($panel,$tip)
    }

    return $panel
}

function Add-GUICompactToolGrid {
    param(
        [System.Windows.Forms.Control]$Page,
        [string]$Title,
        [object[]]$Tools,
        [int]$Columns = 3
    )

    $group = New-Object System.Windows.Forms.GroupBox
    $group.Text = $Title
    $group.Dock = "Fill"
    $group.Padding = New-Object System.Windows.Forms.Padding(10)
    $group.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $group.BackColor = $script:GUITheme.Page
    $Page.Controls.Add($group)

    $scroll = New-Object System.Windows.Forms.Panel
    $scroll.Dock = "Fill"
    $scroll.AutoScroll = $true
    $scroll.BackColor = $script:GUITheme.Page
    $group.Controls.Add($scroll)

    $layout = New-Object System.Windows.Forms.TableLayoutPanel
    $layout.Dock = "Top"
    $layout.AutoSize = $true
    $layout.AutoSizeMode = "GrowAndShrink"
    $layout.ColumnCount = $Columns
    $layout.RowCount = 0
    $layout.Padding = New-Object System.Windows.Forms.Padding(4)
    $layout.Width = 1180
    $scroll.Controls.Add($layout)
    $scroll.Add_Resize({
        if($layout){
            $layout.Width = [Math]::Max(720,($scroll.ClientSize.Width - 18))
        }
    })

    for($i = 0; $i -lt $Columns; $i++){
        $layout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,(100 / $Columns)))) | Out-Null
    }

    $row = -1
    $col = 0
    $currentSection = $null

    foreach($tool in $Tools){
        if($tool.Section -and $tool.Section -ne $currentSection){
            $currentSection = $tool.Section
            $row++
            $col = 0
            $layout.RowCount = $layout.RowCount + 1
            $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,28))) | Out-Null

            $sectionLabel = New-Object System.Windows.Forms.Label
            $sectionLabel.Text = $currentSection
            $sectionLabel.Dock = "Fill"
            $sectionLabel.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9.5,[System.Drawing.FontStyle]::Bold)
            $sectionLabel.ForeColor = $script:GUITheme.AccentDark
            $sectionLabel.TextAlign = "MiddleLeft"
            $layout.Controls.Add($sectionLabel,0,$row)
            $layout.SetColumnSpan($sectionLabel,$Columns)
        }

        if($col -eq 0){
            $row++
            $layout.RowCount = $layout.RowCount + 1
            $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,36))) | Out-Null
        }

        $layout.Controls.Add((New-GUICompactToolControl -Tool $tool),$col,$row)
        $col = ($col + 1) % $Columns
    }

    if($layout.RowCount -eq 0){
        $layout.RowCount = 1
        $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    }
}

function Add-GUIToolButtonGroup {
    param(
        [System.Windows.Forms.Control]$Parent,
        [string]$Title,
        [object[]]$Buttons
    )

    $group = New-Object System.Windows.Forms.GroupBox
    $group.Text = $Title
    $group.Dock = "Fill"
    $group.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)

    $buttonRows = [math]::Ceiling([math]::Max(1,$Buttons.Count) / 4)
    $groupHeight = [math]::Max(132,44 + ($buttonRows * 54))
    $row = $Parent.RowCount
    $Parent.RowCount = $Parent.RowCount + 1
    $Parent.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,$groupHeight))) | Out-Null
    $Parent.Controls.Add($group,0,$row)

    $panel = New-Object System.Windows.Forms.FlowLayoutPanel
    $panel.Dock = "Fill"
    $panel.FlowDirection = "LeftToRight"
    $panel.WrapContents = $true
    $panel.Padding = New-Object System.Windows.Forms.Padding(10)
    $group.Controls.Add($panel)

    foreach($buttonInfo in $Buttons){
        if($buttonInfo.External){
            $button = New-GUIExternalToolButton -Text $buttonInfo.Text -ToolId $buttonInfo.External
        }
        elseif($buttonInfo.Action){
            $button = New-GUIButton -Text $buttonInfo.Text -Action $buttonInfo.Action
        }
        else{
            $button = New-GUIToolButton -Text $buttonInfo.Text -FunctionName $buttonInfo.Function
        }

        [void]$panel.Controls.Add($button)
    }
}

function New-GUIToolTab {
    param([System.Windows.Forms.TabPage]$Page)

    $scroll = New-Object System.Windows.Forms.Panel
    $scroll.Dock = "Fill"
    $scroll.AutoScroll = $true
    $Page.Controls.Add($scroll)

    $stack = New-Object System.Windows.Forms.TableLayoutPanel
    $stack.Dock = "Top"
    $stack.AutoSize = $true
    $stack.ColumnCount = 1
    $stack.RowCount = 0
    $stack.Padding = New-Object System.Windows.Forms.Padding(10)
    $stack.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $scroll.Controls.Add($stack)

    return $stack
}

function Get-GUIWUResultText {
    param([int]$Code)

    switch($Code){
        0 { "Not Started" }
        1 { "In Progress" }
        2 { "Succeeded" }
        3 { "Succeeded With Errors" }
        4 { "Failed" }
        5 { "Aborted" }
        default { "Unknown ($Code)" }
    }
}

function Get-GUIWUOperationText {
    param([int]$Code)

    switch($Code){
        1 { "Installation" }
        2 { "Uninstallation" }
        default { "Other ($Code)" }
    }
}

function New-GUIWUUpdateSession {
    try {
        return New-Object -ComObject Microsoft.Update.Session
    }
    catch {
        throw "Windows Update Agent is not available: $($_.Exception.Message)"
    }
}

function Get-GUISelectedGridTag {
    param([System.Windows.Forms.DataGridView]$Grid)

    if(!$Grid -or $Grid.SelectedRows.Count -eq 0){
        return $null
    }

    return $Grid.SelectedRows[0].Tag
}

function Set-GUIWUStatus {
    param([string]$Text)

    if($script:WUStatusLabel -and !$script:WUStatusLabel.IsDisposed){
        $script:WUStatusLabel.Text = $Text
    }

    Add-GUILog $Text
    [System.Windows.Forms.Application]::DoEvents()
}

function New-GUIWUGrid {
    $grid = New-Object System.Windows.Forms.DataGridView
    $grid.Dock = "Fill"
    $grid.ReadOnly = $true
    $grid.AllowUserToAddRows = $false
    $grid.AllowUserToDeleteRows = $false
    $grid.RowHeadersVisible = $false
    $grid.MultiSelect = $true
    $grid.SelectionMode = "FullRowSelect"
    $grid.AutoSizeColumnsMode = "Fill"
    $grid.BackgroundColor = [System.Drawing.Color]::White
    $grid.Font = New-Object System.Drawing.Font("Segoe UI",9)
    return $grid
}

function Get-GUISelectedGridTags {
    param([System.Windows.Forms.DataGridView]$Grid)

    if(!$Grid -or $Grid.SelectedRows.Count -eq 0){
        return @()
    }

    return @($Grid.SelectedRows | ForEach-Object { $_.Tag } | Where-Object { $_ })
}

function Get-GUIWindowsUpdateRebootPendingText {
    try {
        if(Get-Command Get-CSIPendingRebootState -ErrorAction SilentlyContinue){
            $pending = Get-CSIPendingRebootState
            if($pending -and $pending.Pending){
                return "Reboot pending"
            }
        }
    }
    catch {}

    return "No reboot pending"
}

function Start-GUIWindowsUpdateBackgroundAction {
    param(
        [ValidateSet("Download","Install","Uninstall")]
        [string]$Action,
        [object[]]$Updates
    )

    if($script:WUActionProcess -and !$script:WUActionProcess.HasExited){
        [System.Windows.Forms.MessageBox]::Show("A Windows Update action is already running. Wait for it to finish before starting another one.","Windows Update",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
        return
    }

    $titles = @($Updates | ForEach-Object { [string]$_.Title } | Where-Object { $_ } | Select-Object -Unique)
    if($titles.Count -eq 0){
        Set-GUIWUStatus "No Windows Update rows were selected."
        return
    }

    $session = New-CSITempOutputSession -ToolName "Windows Update $Action"
    $titlesPath = Join-Path $session.Path "selected-updates.json"
    $resultPath = Join-Path $session.Path "windows-update-result.json"
    $runnerPath = Join-Path $session.Path "run-windows-update-action.ps1"
    $titles | ConvertTo-Json -Depth 3 | Set-Content -Path $titlesPath -Encoding UTF8

    $installedSearch = if($Action -eq "Uninstall"){"IsInstalled=1"}else{"IsInstalled=0 and IsHidden=0"}
    $scriptText = @"
`$ErrorActionPreference = "Stop"
`$status = [ordered]@{
    Action = "$Action"
    StartedAt = (Get-Date).ToString("s")
    CompletedAt = ""
    Result = "Running"
    RebootRequired = `$false
    Updates = @()
    Error = ""
}
try {
    `$titles = @(Get-Content -Raw -Path "$titlesPath" | ConvertFrom-Json)
    `$session = New-Object -ComObject Microsoft.Update.Session
    `$searcher = `$session.CreateUpdateSearcher()
    `$result = `$searcher.Search("$installedSearch")
    `$collection = New-Object -ComObject Microsoft.Update.UpdateColl
    for(`$i = 0; `$i -lt `$result.Updates.Count; `$i++){
        `$update = `$result.Updates.Item(`$i)
        if(`$titles -contains `$update.Title){
            if("$Action" -ne "Uninstall" -and !`$update.EulaAccepted){ `$update.AcceptEula() }
            [void]`$collection.Add(`$update)
            `$status.Updates += `$update.Title
        }
    }
    if(`$collection.Count -eq 0){
        throw "Selected update(s) were not found during the background Windows Update search."
    }
    if("$Action" -eq "Download"){
        `$downloader = `$session.CreateUpdateDownloader()
        `$downloader.Updates = `$collection
        `$operationResult = `$downloader.Download()
    }
    elseif("$Action" -eq "Install"){
        `$downloader = `$session.CreateUpdateDownloader()
        `$downloader.Updates = `$collection
        `$downloadResult = `$downloader.Download()
        `$installer = `$session.CreateUpdateInstaller()
        `$installer.Updates = `$collection
        `$operationResult = `$installer.Install()
        `$status.RebootRequired = [bool]`$operationResult.RebootRequired
    }
    else{
        `$installer = `$session.CreateUpdateInstaller()
        `$installer.Updates = `$collection
        `$operationResult = `$installer.Uninstall()
        `$status.RebootRequired = [bool]`$operationResult.RebootRequired
    }
    `$status.ResultCode = [int]`$operationResult.ResultCode
    `$status.Result = "Completed"
}
catch {
    `$status.Result = "Error"
    `$status.Error = `$_.Exception.Message
}
finally {
    `$status.CompletedAt = (Get-Date).ToString("s")
    `$status | ConvertTo-Json -Depth 6 | Set-Content -Path "$resultPath" -Encoding UTF8
}
"@

    $scriptText | Set-Content -Path $runnerPath -Encoding UTF8

    try {
        $process = Start-CSIToolProcess `
            -FilePath "powershell.exe" `
            -ArgumentList @("-NoProfile","-ExecutionPolicy","Bypass","-File","`"$runnerPath`"") `
            -WorkingDirectory $SharedToolkitRoot `
            -WindowStyle Hidden `
            -PassThru

        $script:WUActionProcess = $process
        $script:WUActionSession = [pscustomobject]@{
            Action = $Action
            ResultPath = $resultPath
            SessionPath = $session.Path
        }
        Set-GUIWUStatus ("Windows Update {0} started in the background for {1} update(s)." -f $Action.ToLowerInvariant(),$titles.Count)

        if($script:WUActionTimer){
            try { $script:WUActionTimer.Stop(); $script:WUActionTimer.Dispose() } catch {}
        }

        $timer = New-Object System.Windows.Forms.Timer
        $timer.Interval = 2500
        $timer.Add_Tick({
            if(!$script:WUActionProcess){
                return
            }

            if($script:WUActionProcess.HasExited){
                $script:WUActionTimer.Stop()
                $script:WUActionTimer.Dispose()
                $script:WUActionTimer = $null
                $sessionInfo = $script:WUActionSession
                $script:WUActionProcess = $null
                $script:WUActionSession = $null

                try {
                    $result = Get-Content -Raw -Path $sessionInfo.ResultPath -ErrorAction Stop | ConvertFrom-Json
                    if($result.Result -eq "Completed"){
                        Set-GUIWUStatus ("Windows Update {0} completed. Updates: {1}. Reboot required: {2}" -f $sessionInfo.Action.ToLowerInvariant(),@($result.Updates).Count,$result.RebootRequired)
                        [System.Windows.Forms.MessageBox]::Show("Windows Update $($sessionInfo.Action) completed.`r`nUpdates processed: $(@($result.Updates).Count)`r`nReboot required: $($result.RebootRequired)","Windows Update",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
                        Refresh-GUIWindowsUpdateData
                    }
                    else{
                        Set-GUIWUStatus "Windows Update $($sessionInfo.Action.ToLowerInvariant()) failed: $($result.Error)"
                        [System.Windows.Forms.MessageBox]::Show("Windows Update $($sessionInfo.Action) failed.`r`n`r`n$($result.Error)","Windows Update",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
                    }
                }
                catch {
                    Set-GUIWUStatus "Windows Update action ended, but the result file could not be read: $($_.Exception.Message)"
                }
            }
        })
        $script:WUActionTimer = $timer
        $timer.Start()
    }
    catch {
        Set-GUIWUStatus "Could not start Windows Update background action: $($_.Exception.Message)"
    }
}

function Refresh-GUIWindowsUpdateData {
    $oldCursor = if($script:Form){$script:Form.Cursor}else{$null}

    try {
        if($script:Form){ $script:Form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor }
        Set-GUIWUStatus "Windows Update scan started..."

        $session = New-GUIWUUpdateSession
        $searcher = $session.CreateUpdateSearcher()

        $script:WUPendingUpdates = @()
        $script:WUInstalledUpdates = @()
        $script:WUHistory = @()

        if($script:WUPendingGrid){ $script:WUPendingGrid.Rows.Clear() }
        if($script:WUInstalledGrid){ $script:WUInstalledGrid.Rows.Clear() }
        if($script:WUHistoryGrid){ $script:WUHistoryGrid.Rows.Clear() }

        Set-GUIWUStatus "Scanning for pending Windows updates..."
        $pendingResult = $searcher.Search("IsInstalled=0 and IsHidden=0")
        for($i = 0; $i -lt $pendingResult.Updates.Count; $i++){
            $update = $pendingResult.Updates.Item($i)
            $script:WUPendingUpdates += $update
            if($script:WUPendingGrid){
                $kb = @($update.KBArticleIDs) -join ","
                $sizeMB = if($update.MaxDownloadSize -gt 0){[math]::Round($update.MaxDownloadSize / 1MB,1)}else{0}
                $row = $script:WUPendingGrid.Rows.Add($update.Title,$kb,$update.MsrcSeverity,$sizeMB,$update.IsDownloaded,$update.RebootRequired)
                $script:WUPendingGrid.Rows[$row].Tag = $update
            }
        }

        Set-GUIWUStatus "Scanning installed updates that Windows says are removable..."
        $rebootPendingText = Get-GUIWindowsUpdateRebootPendingText
        $installedResult = $searcher.Search("IsInstalled=1")
        for($i = 0; $i -lt $installedResult.Updates.Count; $i++){
            $update = $installedResult.Updates.Item($i)
            if($update.IsUninstallable){
                $script:WUInstalledUpdates += $update
                if($script:WUInstalledGrid){
                    $kb = @($update.KBArticleIDs) -join ","
                    $row = $script:WUInstalledGrid.Rows.Add($update.Title,$kb,$update.MsrcSeverity,$update.IsUninstallable,$rebootPendingText)
                    $script:WUInstalledGrid.Rows[$row].Tag = $update
                }
            }
        }

        Set-GUIWUStatus "Loading recent Windows Update history..."
        $historyCount = $searcher.GetTotalHistoryCount()
        $take = [Math]::Min(80,$historyCount)
        if($take -gt 0){
            $history = $searcher.QueryHistory(0,$take)
            for($i = 0; $i -lt $history.Count; $i++){
                $entry = $history.Item($i)
                $script:WUHistory += $entry
                if($script:WUHistoryGrid){
                    $row = $script:WUHistoryGrid.Rows.Add(
                        $entry.Date,
                        (Get-GUIWUOperationText -Code ([int]$entry.Operation)),
                        (Get-GUIWUResultText -Code ([int]$entry.ResultCode)),
                        $entry.Title,
                        $entry.SupportUrl
                    )
                    $script:WUHistoryGrid.Rows[$row].Tag = $entry
                }
            }
        }

        Set-GUIWUStatus ("Windows Update ready. Pending: {0}; removable installed: {1}; history: {2}; {3}" -f $script:WUPendingUpdates.Count,$script:WUInstalledUpdates.Count,$script:WUHistory.Count,(Get-GUIWindowsUpdateRebootPendingText))
    }
    catch {
        Set-GUIWUStatus "Windows Update scan failed: $($_.Exception.Message)"
        [System.Windows.Forms.MessageBox]::Show("Windows Update scan failed.`r`n`r`n$($_.Exception.Message)","Windows Update",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
    }
    finally {
        if($script:Form -and $oldCursor){ $script:Form.Cursor = $oldCursor }
    }
}

function Install-SelectedGUIWindowsUpdate {
    $updates = @(Get-GUISelectedGridTags -Grid $script:WUPendingGrid)
    if($updates.Count -eq 0){
        [System.Windows.Forms.MessageBox]::Show("Select a pending update first.","Windows Update",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
        return
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show("Install the selected update(s) in the background?`r`n`r`nCount: $($updates.Count)","Install Windows Update",[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Question)
    if($confirm -ne [System.Windows.Forms.DialogResult]::Yes){
        Set-GUIWUStatus "Windows Update install cancelled."
        return
    }

    Start-GUIWindowsUpdateBackgroundAction -Action Install -Updates $updates
}

function Download-SelectedGUIWindowsUpdate {
    $updates = @(Get-GUISelectedGridTags -Grid $script:WUPendingGrid)
    if($updates.Count -eq 0){
        [System.Windows.Forms.MessageBox]::Show("Select a pending update first.","Windows Update",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
        return
    }

    $updates = @($updates | Where-Object { -not $_.IsDownloaded })
    if($updates.Count -eq 0){
        Set-GUIWUStatus "Selected update(s) are already downloaded."
        [System.Windows.Forms.MessageBox]::Show("The selected update(s) are already downloaded.","Windows Update",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
        return
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show("Download the selected update(s) without installing?`r`n`r`nCount: $($updates.Count)","Download Windows Update",[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Question)
    if($confirm -ne [System.Windows.Forms.DialogResult]::Yes){
        Set-GUIWUStatus "Windows Update download cancelled."
        return
    }

    Write-GUIToolUsageLog -Tool "Windows Update" -Action "DownloadOnly" -Detail ("Count={0}" -f $updates.Count)
    Start-GUIWindowsUpdateBackgroundAction -Action Download -Updates $updates
}

function Uninstall-SelectedGUIWindowsUpdate {
    $updates = @(Get-GUISelectedGridTags -Grid $script:WUInstalledGrid)
    if($updates.Count -eq 0){
        [System.Windows.Forms.MessageBox]::Show("Select an uninstallable installed update first.","Windows Update",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
        return
    }

    $updates = @($updates | Where-Object { $_.IsUninstallable })
    if($updates.Count -eq 0){
        [System.Windows.Forms.MessageBox]::Show("Windows does not report this update as uninstallable.","Windows Update",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Warning) | Out-Null
        return
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show("Uninstall the selected update(s) in the background?`r`n`r`nCount: $($updates.Count)","Uninstall Windows Update",[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Warning)
    if($confirm -ne [System.Windows.Forms.DialogResult]::Yes){
        Set-GUIWUStatus "Windows Update uninstall cancelled."
        return
    }

    Start-GUIWindowsUpdateBackgroundAction -Action Uninstall -Updates $updates
}

function Invoke-GUIWindowsUpdateRepairStep {
    param(
        [string]$Name,
        [scriptblock]$Action,
        [System.Collections.ArrayList]$Log
    )

    Set-GUIWUStatus "Repair Windows Update: $Name"

    try {
        & $Action
        [void]$Log.Add("[OK] $Name")
        Write-GUIToolUsageLog -Tool "Windows Update Repair" -Action $Name -Detail "OK"
    }
    catch {
        $message = $_.Exception.Message
        [void]$Log.Add("[WARN] $Name - $message")
        Write-GUIToolUsageLog -Tool "Windows Update Repair" -Action $Name -Detail $message -Level "WARN"
    }
}

function Invoke-GUIWindowsUpdateRepair {
    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Repair Windows Update now?`r`n`r`nThis will stop Windows Update services, rename the update download/cache folders, reset common update network settings, restart services, and then rescan updates.`r`n`r`nIt will not install updates.",
        "Repair Windows Update",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )

    if($confirm -ne [System.Windows.Forms.DialogResult]::Yes){
        Set-GUIWUStatus "Windows Update repair cancelled."
        return
    }

    if(!(Test-GUIAdministrator)){
        [System.Windows.Forms.MessageBox]::Show("Repair Windows Update requires the toolkit to be running elevated.","Windows Update",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Warning) | Out-Null
        Set-GUIWUStatus "Repair Windows Update requires elevation."
        return
    }

    $oldCursor = if($script:Form){$script:Form.Cursor}else{$null}
    $log = New-Object System.Collections.ArrayList
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $sessionPath = if($CSIPaths -and $CSIPaths.TempOutputs){
        Join-Path $CSIPaths.TempOutputs "$stamp-Windows Update Repair"
    }
    else{
        Join-Path $env:TEMP "$stamp-Windows Update Repair"
    }

    try {
        if($script:Form){ $script:Form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor }
        New-Item -ItemType Directory -Path $sessionPath -Force | Out-Null

        [void]$log.Add("Windows Update Repair")
        [void]$log.Add("=====================")
        [void]$log.Add("Started: $(Get-Date -Format s)")
        [void]$log.Add("Computer: $env:COMPUTERNAME")
        [void]$log.Add("")

        $services = @("UsoSvc","wuauserv","bits","cryptsvc","msiserver")
        foreach($service in $services){
            Invoke-GUIWindowsUpdateRepairStep -Name "Stop service $service" -Log $log -Action {
                $svc = Get-Service -Name $service -ErrorAction Stop
                if($svc.Status -ne "Stopped"){
                    Stop-Service -Name $service -Force -ErrorAction Stop
                    $svc.WaitForStatus("Stopped","00:00:20")
                }
            }.GetNewClosure()
        }

        Invoke-GUIWindowsUpdateRepairStep -Name "Clear BITS queue for current user" -Log $log -Action {
            if(Get-Command Get-BitsTransfer -ErrorAction SilentlyContinue){
                Get-BitsTransfer -AllUsers -ErrorAction SilentlyContinue | Remove-BitsTransfer -Confirm:$false -ErrorAction SilentlyContinue
            }
        }

        Invoke-GUIWindowsUpdateRepairStep -Name "Rename SoftwareDistribution cache" -Log $log -Action {
            $path = Join-Path $env:windir "SoftwareDistribution"
            if(Test-Path $path){
                $backup = "$path.bak-$stamp"
                Rename-Item -LiteralPath $path -NewName (Split-Path -Leaf $backup) -ErrorAction Stop
            }
        }

        Invoke-GUIWindowsUpdateRepairStep -Name "Rename Catroot2 catalog cache" -Log $log -Action {
            $path = Join-Path $env:windir "System32\catroot2"
            if(Test-Path $path){
                $backup = "$path.bak-$stamp"
                Rename-Item -LiteralPath $path -NewName (Split-Path -Leaf $backup) -ErrorAction Stop
            }
        }

        Invoke-GUIWindowsUpdateRepairStep -Name "Reset WinHTTP proxy" -Log $log -Action {
            $output = @(netsh winhttp reset proxy 2>&1 | ForEach-Object { $_.ToString() })
            [void]$log.Add(($output -join " "))
        }

        Invoke-GUIWindowsUpdateRepairStep -Name "Reset Winsock catalog" -Log $log -Action {
            $output = @(netsh winsock reset 2>&1 | ForEach-Object { $_.ToString() })
            [void]$log.Add(($output -join " "))
        }

        Invoke-GUIWindowsUpdateRepairStep -Name "Reset BITS service descriptor" -Log $log -Action {
            $output = @(sc.exe sdset bits "D:(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)" 2>&1 | ForEach-Object { $_.ToString() })
            [void]$log.Add(($output -join " "))
        }

        Invoke-GUIWindowsUpdateRepairStep -Name "Reset Windows Update service descriptor" -Log $log -Action {
            $output = @(sc.exe sdset wuauserv "D:(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)" 2>&1 | ForEach-Object { $_.ToString() })
            [void]$log.Add(($output -join " "))
        }

        foreach($service in @("cryptsvc","bits","wuauserv","UsoSvc")){
            Invoke-GUIWindowsUpdateRepairStep -Name "Start service $service" -Log $log -Action {
                $svc = Get-Service -Name $service -ErrorAction Stop
                if($svc.Status -ne "Running"){
                    Start-Service -Name $service -ErrorAction Stop
                    $svc.WaitForStatus("Running","00:00:20")
                }
            }.GetNewClosure()
        }

        [void]$log.Add("")
        [void]$log.Add("Completed: $(Get-Date -Format s)")
        $logPath = Join-Path $sessionPath "windows-update-repair.txt"
        $log | Set-Content -Path $logPath -Encoding UTF8

        Set-GUIWUStatus "Windows Update repair completed. Rescanning updates..."
        Write-GUIToolUsageLog -Tool "Windows Update Repair" -Action "Completed" -Detail $logPath

        [System.Windows.Forms.MessageBox]::Show("Windows Update repair completed.`r`n`r`nA reboot may be needed if Winsock was reset or services were busy.`r`n`r`nRepair log:`r`n$logPath","Windows Update",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
        Refresh-GUIWindowsUpdateData
    }
    catch {
        $message = $_.Exception.Message
        [void]$log.Add("[ERROR] $message")
        if(!(Test-Path $sessionPath)){ New-Item -ItemType Directory -Path $sessionPath -Force | Out-Null }
        $logPath = Join-Path $sessionPath "windows-update-repair.txt"
        $log | Set-Content -Path $logPath -Encoding UTF8
        Set-GUIWUStatus "Windows Update repair failed: $message"
        Write-GUIToolUsageLog -Tool "Windows Update Repair" -Action "Failed" -Detail $message -Level "ERROR"
        [System.Windows.Forms.MessageBox]::Show("Windows Update repair failed.`r`n`r`n$message`r`n`r`nRepair log:`r`n$logPath","Windows Update",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
    }
    finally {
        if($script:Form -and $oldCursor){ $script:Form.Cursor = $oldCursor }
    }
}

function Build-WindowsUpdatePage {
    param([System.Windows.Forms.TabPage]$Page)

    $layout = New-Object System.Windows.Forms.TableLayoutPanel
    $layout.Dock = "Fill"
    $layout.ColumnCount = 2
    $layout.RowCount = 3
    $layout.Padding = New-Object System.Windows.Forms.Padding(12)
    $layout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $layout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,54))) | Out-Null
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,52))) | Out-Null
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,48))) | Out-Null
    $Page.Controls.Add($layout)

    $top = New-Object System.Windows.Forms.TableLayoutPanel
    $top.Dock = "Fill"
    $top.Padding = New-Object System.Windows.Forms.Padding(4)
    $top.ColumnCount = 3
    $top.RowCount = 1
    $top.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::AutoSize))) | Out-Null
    $top.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $top.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::AutoSize))) | Out-Null
    $layout.Controls.Add($top,0,0)
    $layout.SetColumnSpan($top,2)

    $leftActions = New-Object System.Windows.Forms.FlowLayoutPanel
    $leftActions.Dock = "Fill"
    $leftActions.AutoSize = $true
    $leftActions.WrapContents = $false
    $leftActions.FlowDirection = "LeftToRight"
    $leftActions.Margin = New-Object System.Windows.Forms.Padding(0)
    $leftActions.Padding = New-Object System.Windows.Forms.Padding(0)
    [void]$top.Controls.Add($leftActions,0,0)

    [void]$leftActions.Controls.Add((New-GUIButton "Refresh Updates" { Refresh-GUIWindowsUpdateData }))
    [void]$leftActions.Controls.Add((New-GUIButton "Download Selected" { Download-SelectedGUIWindowsUpdate }))
    [void]$leftActions.Controls.Add((New-GUIButton "Install Selected" { Install-SelectedGUIWindowsUpdate }))
    [void]$leftActions.Controls.Add((New-GUIButton "Uninstall Selected" { Uninstall-SelectedGUIWindowsUpdate }))

    $script:WUStatusLabel = New-Object System.Windows.Forms.Label
    $WUStatusLabel.Text = "Click Refresh Updates to scan Windows Update."
    $WUStatusLabel.Dock = "Fill"
    $WUStatusLabel.Height = 34
    $WUStatusLabel.Margin = New-Object System.Windows.Forms.Padding(12,8,3,3)
    $WUStatusLabel.TextAlign = "MiddleLeft"
    $WUStatusLabel.Font = New-Object System.Drawing.Font("Segoe UI",9.5)
    $WUStatusLabel.ForeColor = $script:GUITheme.MutedText
    [void]$top.Controls.Add($WUStatusLabel,1,0)

    $repairButton = New-GUIButton "Repair Windows Update" { Invoke-GUIWindowsUpdateRepair }
    $repairButton.Width = 180
    $repairButton.Margin = New-Object System.Windows.Forms.Padding(8,5,0,5)
    Set-GUIButtonChrome -Button $repairButton -Subtle
    [void]$top.Controls.Add($repairButton,2,0)

    $pendingGroup = New-Object System.Windows.Forms.GroupBox
    $pendingGroup.Text = "Pending Updates"
    $pendingGroup.Dock = "Fill"
    $pendingGroup.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $layout.Controls.Add($pendingGroup,0,1)

    $script:WUPendingGrid = New-GUIWUGrid
    [void]$WUPendingGrid.Columns.Add("Title","Title")
    [void]$WUPendingGrid.Columns.Add("KB","KB")
    [void]$WUPendingGrid.Columns.Add("Severity","Severity")
    [void]$WUPendingGrid.Columns.Add("Size","Size MB")
    [void]$WUPendingGrid.Columns.Add("Downloaded","Downloaded")
    [void]$WUPendingGrid.Columns.Add("Reboot","Reboot")
    $pendingGroup.Controls.Add($WUPendingGrid)

    $installedGroup = New-Object System.Windows.Forms.GroupBox
    $installedGroup.Text = "Installed Updates Windows Reports As Removable"
    $installedGroup.Dock = "Fill"
    $installedGroup.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $layout.Controls.Add($installedGroup,1,1)

    $script:WUInstalledGrid = New-GUIWUGrid
    [void]$WUInstalledGrid.Columns.Add("Title","Title")
    [void]$WUInstalledGrid.Columns.Add("KB","KB")
    [void]$WUInstalledGrid.Columns.Add("Severity","Severity")
    [void]$WUInstalledGrid.Columns.Add("Uninstallable","Uninstallable")
    [void]$WUInstalledGrid.Columns.Add("SystemRebootPending","System Reboot Pending")
    $installedGroup.Controls.Add($WUInstalledGrid)

    $historyGroup = New-Object System.Windows.Forms.GroupBox
    $historyGroup.Text = "Recent Windows Update History"
    $historyGroup.Dock = "Fill"
    $historyGroup.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $layout.Controls.Add($historyGroup,0,2)
    $layout.SetColumnSpan($historyGroup,2)

    $script:WUHistoryGrid = New-GUIWUGrid
    [void]$WUHistoryGrid.Columns.Add("Date","Date")
    [void]$WUHistoryGrid.Columns.Add("Operation","Operation")
    [void]$WUHistoryGrid.Columns.Add("Result","Result")
    [void]$WUHistoryGrid.Columns.Add("Title","Title")
    [void]$WUHistoryGrid.Columns.Add("SupportUrl","Support URL")
    $historyGroup.Controls.Add($WUHistoryGrid)
}

function Build-WindowsToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Analyze" -Title "Analysis Tools"
}

function Build-ProcessesToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Processes" -Title "Process Tools"
}

function Build-RepairToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Repair" -Title "Repair Tools"
}

function Build-DirectoryToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Directory" -Title "Directory Tools"
}

function Build-HardwareToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    $sectionMap = @{
        "hardwarehealth" = "Health And Diagnostics"
        "diskhealth" = "Health And Diagnostics"
        "resourcehotspots" = "Health And Diagnostics"
        "minidumpcollector" = "Crash And Dumps"
        "bluescreenview" = "Crash And Dumps"
        "crystaldiskinfo" = "Storage And Disk"
        "ssdz" = "Storage And Disk"
        "hwinfo" = "Inspection Utilities"
        "hwmonitor" = "Inspection Utilities"
        "cpuz" = "Inspection Utilities"
        "gpuz" = "Inspection Utilities"
        "pciz" = "Inspection Utilities"
        "quickmemorytestok" = "Inspection Utilities"
    }

    Build-GUIOptimizedToolPage `
        -Page $Page `
        -Tab "Hardware" `
        -Title "Hardware Tools" `
        -SectionMap $sectionMap `
        -SectionOrder @("Health And Diagnostics","Storage And Disk","Crash And Dumps","Inspection Utilities","Sysinternals")
}

function Build-DiskToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Disk" -Title "Disk Tools"
}

function Build-CrashToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Crash" -Title "Crash Tools"
}

function Build-SecurityToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    $sectionMap = @{
        "defendersecuritycheck" = "Malware And Adware Scanners"
        "microsoftsafetyscanner" = "Malware And Adware Scanners"
        "malwarebytesadwcleaner" = "Malware And Adware Scanners"
        "clamwinportable" = "Malware And Adware Scanners"
        "hijackthis" = "Security Inspection"
        "autoruns" = "Security Inspection"
        "sigcheck" = "Security Inspection"
        "pwgen" = "Password Tools"
        "xpy" = "Privacy And Hardening"
    }

    Build-GUIOptimizedToolPage `
        -Page $Page `
        -Tab "Security" `
        -Title "Security Tools" `
        -SectionMap $sectionMap `
        -SectionOrder @("Malware And Adware Scanners","Security Inspection","Password Tools","Privacy And Hardening","Sysinternals")
}

function Build-NetworkToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Network" -Title "Network Tools"
}

function Build-RemoteToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Remote" -Title "Remote Tools"
}

function Build-CaptureToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Capture" -Title "Packet Capture Tools"
}

function Build-DiscoveryToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Discovery" -Title "Discovery Tools"
}

function Build-InfrastructureToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Infrastructure" -Title "Infrastructure Tools"
}

function Build-WiFiToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Wi-Fi" -Title "Wi-Fi Tools"
}

function Build-PrintToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Print" -Title "Print Tools"
}

function Build-ReportsPage {
    param([System.Windows.Forms.TabPage]$Page)

    $layout = New-Object System.Windows.Forms.TableLayoutPanel
    $layout.Dock = "Fill"
    $layout.RowCount = 3
    $layout.ColumnCount = 1
    $layout.Padding = New-Object System.Windows.Forms.Padding(10)
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,56))) | Out-Null
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,52))) | Out-Null
    $Page.Controls.Add($layout)

    $filterPanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $filterPanel.Dock = "Fill"
    $filterPanel.Padding = New-Object System.Windows.Forms.Padding(8)
    $layout.Controls.Add($filterPanel,0,0)

    $filterLabel = New-GUILabel "Report type"
    $filterLabel.Dock = "None"
    $filterLabel.Width = 80
    $filterLabel.Height = 28
    [void]$filterPanel.Controls.Add($filterLabel)

    $script:ReportTypeBox = New-Object System.Windows.Forms.ComboBox
    $ReportTypeBox.DropDownStyle = "DropDownList"
    $ReportTypeBox.Width = 190
    Add-GUIComboItems -ComboBox $ReportTypeBox -Items @("All","Quick Diagnosis","Computer Profiles","Crash Events","Discovery Exports","Repair And Triage","Minidumps")
    $ReportTypeBox.Add_SelectedIndexChanged({ Refresh-GUIReports })
    [void]$filterPanel.Controls.Add($ReportTypeBox)

    $script:ReportSearchBox = New-GUITextBox
    $ReportSearchBox.Dock = "None"
    $ReportSearchBox.Width = 260
    $ReportSearchBox.Margin = New-Object System.Windows.Forms.Padding(14,4,6,4)
    [void]$filterPanel.Controls.Add($ReportSearchBox)

    [void]$filterPanel.Controls.Add((New-GUIButton "Search" { Refresh-GUIReports }))
    [void]$filterPanel.Controls.Add((New-GUIButton "Refresh Reports" { Refresh-GUIReports }))

    $script:ReportsGrid = New-Object System.Windows.Forms.DataGridView
    $ReportsGrid.Dock = "Fill"
    $ReportsGrid.ReadOnly = $true
    $ReportsGrid.AllowUserToAddRows = $false
    $ReportsGrid.AllowUserToDeleteRows = $false
    $ReportsGrid.RowHeadersVisible = $false
    $ReportsGrid.MultiSelect = $false
    $ReportsGrid.SelectionMode = "FullRowSelect"
    $ReportsGrid.AutoSizeColumnsMode = "Fill"
    $ReportsGrid.BackgroundColor = [System.Drawing.Color]::White
    [void]$ReportsGrid.Columns.Add("Type","Type")
    [void]$ReportsGrid.Columns.Add("Name","Name")
    [void]$ReportsGrid.Columns.Add("Modified","Modified")
    [void]$ReportsGrid.Columns.Add("Path","Path")
    $layout.Controls.Add($ReportsGrid,0,1)

    $buttons = New-Object System.Windows.Forms.FlowLayoutPanel
    $buttons.Dock = "Fill"
    $buttons.Padding = New-Object System.Windows.Forms.Padding(8)
    $layout.Controls.Add($buttons,0,2)

    [void]$buttons.Controls.Add((New-GUIButton "Open Selected" { Open-SelectedGUIReport }))
    [void]$buttons.Controls.Add((New-GUIButton "Open Location" { Open-SelectedGUIReportLocation }))
    [void]$buttons.Controls.Add((New-GUIButton "Delete Selected" { Delete-SelectedGUIReport }))
    [void]$buttons.Controls.Add((New-GUIButton "Open Help" { Open-GUIHelpFile }))

    $ReportsGrid.Add_CellDoubleClick({ Open-SelectedGUIReport })
    Refresh-GUIReports
}

function Get-GUIReportItems {
    $items = @()
    $roots = @(
        @{ Type="Quick Diagnosis"; Path=$CSIPaths.Exports; Pattern="quick-diagnosis*.html" },
        @{ Type="Crash Events"; Path=$CSIPaths.Exports; Pattern="crash-event-summary*.html" },
        @{ Type="Computer Profiles"; Path=(Get-CSIFingerprintPath); Pattern="*.html" },
        @{ Type="Computer Profiles"; Path=(Get-CSIFingerprintPath); Pattern="*.json" },
        @{ Type="Minidumps"; Path=(Join-Path $CSIPaths.Data "MiniDumps"); Pattern="*" },
        @{ Type="Discovery Exports"; Path=$CSIPaths.Exports; Pattern="*inventory*.csv" },
        @{ Type="Discovery Exports"; Path=$CSIPaths.Exports; Pattern="*network*.csv" },
        @{ Type="Discovery Exports"; Path=$CSIPaths.Exports; Pattern="*network*.json" },
        @{ Type="Discovery Exports"; Path=$CSIPaths.Exports; Pattern="*discovery*.txt" },
        @{ Type="Repair And Triage"; Path=$CSIPaths.Exports; Pattern="full-triage*.txt" },
        @{ Type="Repair And Triage"; Path=$CSIPaths.Exports; Pattern="full-triage*.json" },
        @{ Type="Repair And Triage"; Path=$CSIPaths.Exports; Pattern="dism*.log" },
        @{ Type="Repair And Triage"; Path=$CSIPaths.Exports; Pattern="sfc*.log" }
    )

    foreach($root in $roots){
        if(!(Test-Path $root.Path)){
            continue
        }

        $items += Get-ChildItem -Path $root.Path -Filter $root.Pattern -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -ne ".gitkeep" } |
            ForEach-Object {
                [pscustomobject]@{
                    Type = $root.Type
                    Name = $_.Name
                    Modified = $_.LastWriteTime
                    Path = $_.FullName
                    IsDirectory = $_.PSIsContainer
                }
            }
    }

    return @($items | Sort-Object Modified -Descending -Unique)
}

function Refresh-GUIReports {
    if(!$script:ReportsGrid){
        return
    }

    $type = if($script:ReportTypeBox){[string]$script:ReportTypeBox.SelectedItem}else{"All"}
    $search = if($script:ReportSearchBox){$script:ReportSearchBox.Text.Trim()}else{""}
    $reports = @(Get-GUIReportItems)

    if($type -and $type -ne "All"){
        $reports = @($reports | Where-Object { $_.Type -eq $type })
    }

    if($search){
        $reports = @($reports | Where-Object { $_.Name -like "*$search*" -or $_.Path -like "*$search*" })
    }

    $script:Reports = $reports
    $script:ReportsGrid.Rows.Clear()

    foreach($report in $reports){
        $rowIndex = $script:ReportsGrid.Rows.Add($report.Type,$report.Name,$report.Modified.ToString("yyyy-MM-dd HH:mm:ss"),$report.Path)
        $script:ReportsGrid.Rows[$rowIndex].Tag = $report
    }

    Add-GUILog ("Reports loaded: {0}" -f $reports.Count)
}

function Get-SelectedGUIReport {
    if(!$script:ReportsGrid -or $script:ReportsGrid.SelectedRows.Count -eq 0){
        return $null
    }

    return $script:ReportsGrid.SelectedRows[0].Tag
}

function Open-SelectedGUIReport {
    $report = Get-SelectedGUIReport

    if(!$report){
        Add-GUILog "Select a report first."
        return
    }

    if($report.IsDirectory){
        Open-GUIFolder $report.Path
    }
    else{
        Open-CSIOutputFile -Path $report.Path
    }
}

function Open-SelectedGUIReportLocation {
    $report = Get-SelectedGUIReport

    if(!$report){
        Add-GUILog "Select a report first."
        return
    }

    $location = if($report.IsDirectory){$report.Path}else{Split-Path -Parent $report.Path}
    Open-GUIFolder $location
}

function Delete-SelectedGUIReport {
    $report = Get-SelectedGUIReport

    if(!$report){
        Add-GUILog "Select a report first."
        return
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Delete this item?`r`n`r`n$($report.Path)",
        "Delete Report",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )

    if($confirm -eq [System.Windows.Forms.DialogResult]::Yes){
        Remove-Item -LiteralPath $report.Path -Recurse:$report.IsDirectory -Force -ErrorAction SilentlyContinue
        Refresh-GUIReports
    }
}

function Build-SysinternalsPage {
    param(
        [System.Windows.Forms.TabPage]$Page,
        [string[]]$Categories,
        [string]$Title = "Sysinternals",
        [int]$Columns = 3
    )

    $catalogSysinternalsBases = @(
        "procexp",
        "procmon",
        "autoruns",
        "rammap",
        "tcpview",
        "psping",
        "psexec",
        "handle",
        "sigcheck"
    )

    $mappedCategories = @("Process And Startup","System Inspection","Network","PsTools","Active Directory","Disk And File","Security And Registry")
    $tools = @(Get-GUISysinternalsTools | Where-Object { $catalogSysinternalsBases -notcontains $_.Name.ToLowerInvariant() -and $mappedCategories -notcontains $_.Category })

    if($tools.Count -eq 0){
        $note = New-Object System.Windows.Forms.Label
        $note.Dock = "Fill"
        $note.TextAlign = "MiddleCenter"
        $note.Font = New-Object System.Drawing.Font("Segoe UI Semilight",11)
        $note.ForeColor = $script:GUITheme.MutedText
        $note.Text = "All detected Sysinternals tools are already grouped on the tabs where they fit best."
        $Page.Controls.Add($note)
        return
    }

    if($Categories -and $Categories.Count -gt 0){
        $tools = @($tools | Where-Object { $Categories -contains $_.Category })
    }

    $items = @()

    foreach($tool in $tools){
        $path = $tool.Path.Replace("'","''")
        $name = $tool.DisplayName.Replace("'","''")
        $console = if($tool.Console){"`$true"}else{"`$false"}
        $risky = if($tool.Risky){"`$true"}else{"`$false"}
        $description = Get-GUISysinternalsDescription `
            -BaseName $tool.Name `
            -FileName $tool.FileName `
            -Category $tool.Category `
            -Console $tool.Console `
            -Risky $tool.Risky

        $items += New-GUIToolItem `
            -Text $tool.DisplayName `
            -Description $description `
            -Section $tool.Category `
            -Action ([scriptblock]::Create("Start-GUISysinternalsTool -Path '$path' -DisplayName '$name' -Console $console -Risky $risky"))
    }

    Add-GUICompactToolGrid -Page $Page -Title $Title -Tools $items -Columns $Columns
}

function Build-RobocopyPage {
    param([System.Windows.Forms.TabPage]$Page)

    $layout = New-Object System.Windows.Forms.TableLayoutPanel
    $layout.Dock = "Fill"
    $layout.RowCount = 1
    $layout.ColumnCount = 1
    $layout.Padding = New-Object System.Windows.Forms.Padding(10)
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $Page.Controls.Add($layout)

    $robocopyGroup = New-Object System.Windows.Forms.GroupBox
    $robocopyGroup.Text = "Robocopy Builder"
    $robocopyGroup.Dock = "Fill"
    $robocopyGroup.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $layout.Controls.Add($robocopyGroup,0,0)

    $builder = New-Object System.Windows.Forms.TableLayoutPanel
    $builder.Dock = "Fill"
    $builder.ColumnCount = 4
    $builder.RowCount = 8
    $builder.Padding = New-Object System.Windows.Forms.Padding(10)
    $builder.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,120))) | Out-Null
    $builder.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $builder.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,120))) | Out-Null
    $builder.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $builder.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,34))) | Out-Null
    $builder.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,34))) | Out-Null
    $builder.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,34))) | Out-Null
    $builder.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,34))) | Out-Null
    $builder.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,34))) | Out-Null
    $builder.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,34))) | Out-Null
    $builder.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,46))) | Out-Null
    $builder.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $robocopyGroup.Controls.Add($builder)

    $script:RobocopySourceBox = New-GUITextBox
    $script:RobocopyDestinationBox = New-GUITextBox
    $script:RobocopyPatternBox = New-GUITextBox "*.*"
    $script:RobocopyExcludeFilesBox = New-GUITextBox
    $script:RobocopyExcludeFoldersBox = New-GUITextBox

    $builder.Controls.Add((New-GUILabel "Source"),0,0)
    $builder.Controls.Add($RobocopySourceBox,1,0)
    $builder.Controls.Add((New-GUILabel "Destination"),2,0)
    $builder.Controls.Add($RobocopyDestinationBox,3,0)

    $builder.Controls.Add((New-GUILabel "File patterns"),0,1)
    $builder.Controls.Add($RobocopyPatternBox,1,1)
    $builder.Controls.Add((New-GUILabel "Exclude files"),2,1)
    $builder.Controls.Add($RobocopyExcludeFilesBox,3,1)

    $script:RobocopyCopyTypeBox = New-Object System.Windows.Forms.ComboBox
    $RobocopyCopyTypeBox.Dock = "Fill"
    $RobocopyCopyTypeBox.DropDownStyle = "DropDownList"
    Add-GUIComboItems -ComboBox $RobocopyCopyTypeBox -Items @("Normal folder copy","Mirror destination to source","Unreliable network copy","Permission-preserving migration")

    $script:RobocopyMetadataBox = New-Object System.Windows.Forms.ComboBox
    $RobocopyMetadataBox.Dock = "Fill"
    $RobocopyMetadataBox.DropDownStyle = "DropDownList"
    Add-GUIComboItems -ComboBox $RobocopyMetadataBox -Items @("Normal data, attributes, timestamps","Preserve NTFS permissions","Full owner and audit migration")

    $builder.Controls.Add((New-GUILabel "Copy type"),0,2)
    $builder.Controls.Add($RobocopyCopyTypeBox,1,2)
    $builder.Controls.Add((New-GUILabel "Metadata"),2,2)
    $builder.Controls.Add($RobocopyMetadataBox,3,2)

    $script:RobocopyRetryBox = New-Object System.Windows.Forms.ComboBox
    $RobocopyRetryBox.Dock = "Fill"
    $RobocopyRetryBox.DropDownStyle = "DropDownList"
    Add-GUIComboItems -ComboBox $RobocopyRetryBox -Items @("Fast troubleshooting","Balanced","Patient migration")

    $script:RobocopyThreadsBox = New-Object System.Windows.Forms.ComboBox
    $RobocopyThreadsBox.Dock = "Fill"
    $RobocopyThreadsBox.DropDownStyle = "DropDownList"
    Add-GUIComboItems -ComboBox $RobocopyThreadsBox -Items @("Gentle","Normal","Fast") -SelectedIndex 1

    $builder.Controls.Add((New-GUILabel "Retry"),0,3)
    $builder.Controls.Add($RobocopyRetryBox,1,3)
    $builder.Controls.Add((New-GUILabel "Threads"),2,3)
    $builder.Controls.Add($RobocopyThreadsBox,3,3)

    $builder.Controls.Add((New-GUILabel "Exclude folders"),0,4)
    $builder.Controls.Add($RobocopyExcludeFoldersBox,1,4)

    $options = New-Object System.Windows.Forms.FlowLayoutPanel
    $options.Dock = "Fill"
    $options.FlowDirection = "LeftToRight"
    $builder.SetColumnSpan($options,2)
    $builder.Controls.Add($options,2,4)

    $script:RobocopyNasCheck = New-Object System.Windows.Forms.CheckBox
    $RobocopyNasCheck.Text = "NAS/Linux timestamps"
    $RobocopyNasCheck.AutoSize = $true
    $RobocopyNasCheck.Margin = New-Object System.Windows.Forms.Padding(4,7,12,4)
    [void]$options.Controls.Add($RobocopyNasCheck)

    $script:RobocopyNoProgressCheck = New-Object System.Windows.Forms.CheckBox
    $RobocopyNoProgressCheck.Text = "Cleaner output"
    $RobocopyNoProgressCheck.AutoSize = $true
    $RobocopyNoProgressCheck.Checked = $true
    $RobocopyNoProgressCheck.Margin = New-Object System.Windows.Forms.Padding(4,7,12,4)
    [void]$options.Controls.Add($RobocopyNoProgressCheck)

    $script:RobocopyLogCheck = New-Object System.Windows.Forms.CheckBox
    $RobocopyLogCheck.Text = "Log to Outputs"
    $RobocopyLogCheck.AutoSize = $true
    $RobocopyLogCheck.Checked = $true
    $RobocopyLogCheck.Margin = New-Object System.Windows.Forms.Padding(4,7,12,4)
    [void]$options.Controls.Add($RobocopyLogCheck)

    $actions = New-Object System.Windows.Forms.FlowLayoutPanel
    $actions.Dock = "Fill"
    $actions.FlowDirection = "LeftToRight"
    $builder.SetColumnSpan($actions,4)
    $builder.Controls.Add($actions,0,6)

    foreach($button in @(
        (New-GUIButton "Build Command" { Update-GUIRobocopyCommand | Out-Null }),
        (New-GUIButton "Copy Command" { Copy-GUIRobocopyCommand }),
        (New-GUIButton "Preview Only" { Start-GUIRobocopyCommand -Preview }),
        (New-GUIButton "Run Copy" { Start-GUIRobocopyCommand })
    )){
        [void]$actions.Controls.Add($button)
    }

    $script:RobocopyCommandBox = New-Object System.Windows.Forms.TextBox
    $RobocopyCommandBox.Dock = "Fill"
    $RobocopyCommandBox.Multiline = $true
    $RobocopyCommandBox.ReadOnly = $true
    $RobocopyCommandBox.ScrollBars = "Vertical"
    $RobocopyCommandBox.Font = New-Object System.Drawing.Font("Consolas",9)
    $builder.SetColumnSpan($RobocopyCommandBox,4)
    $builder.Controls.Add($RobocopyCommandBox,0,7)
}

function Build-PsExecPage {
    param([System.Windows.Forms.TabPage]$Page)

    $layout = New-Object System.Windows.Forms.TableLayoutPanel
    $layout.Dock = "Fill"
    $layout.RowCount = 1
    $layout.ColumnCount = 1
    $layout.Padding = New-Object System.Windows.Forms.Padding(10)
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $Page.Controls.Add($layout)

    $group = New-Object System.Windows.Forms.GroupBox
    $group.Text = "PsExec Helper"
    $group.Dock = "Fill"
    $group.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $layout.Controls.Add($group,0,0)

    $builder = New-Object System.Windows.Forms.TableLayoutPanel
    $builder.Dock = "Fill"
    $builder.ColumnCount = 4
    $builder.RowCount = 11
    $builder.Padding = New-Object System.Windows.Forms.Padding(12)
    $builder.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,128))) | Out-Null
    $builder.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $builder.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,128))) | Out-Null
    $builder.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    foreach($height in @(34,34,34,34,34,34,40,44,76)){
        $builder.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,$height))) | Out-Null
    }
    $builder.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $builder.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,4))) | Out-Null
    $group.Controls.Add($builder)

    $script:PsExecTargetBox = New-GUITextBox
    $script:PsExecCommandBox = New-GUITextBox "cmd.exe /c hostname && whoami"
    $script:PsExecUserBox = New-GUITextBox
    $script:PsExecPasswordBox = New-GUITextBox
    $PsExecPasswordBox.UseSystemPasswordChar = $true
    $script:PsExecTimeoutBox = New-GUITextBox "10"
    $script:PsExecSessionBox = New-GUITextBox
    $script:PsExecWorkingDirBox = New-GUITextBox
    $script:PsExecServiceNameBox = New-GUITextBox

    $builder.Controls.Add((New-GUILabel "Target(s)"),0,0)
    $builder.Controls.Add($PsExecTargetBox,1,0)
    $builder.Controls.Add((New-GUILabel "Timeout"),2,0)
    $builder.Controls.Add($PsExecTimeoutBox,3,0)

    $targetHint = New-GUILabel "Blank = local. Use SERVER01, \\SERVER01, comma-separated targets, or @C:\targets.txt."
    $targetHint.ForeColor = $script:GUITheme.MutedText
    $builder.SetColumnSpan($targetHint,4)
    $builder.Controls.Add($targetHint,0,1)

    $presetBox = New-Object System.Windows.Forms.ComboBox
    $presetBox.Dock = "Fill"
    $presetBox.DropDownStyle = "DropDownList"
    Add-GUIComboItems -ComboBox $presetBox -Items @(
        "Custom command",
        "Remote command prompt",
        "PowerShell prompt",
        "Computer name and user",
        "IP configuration",
        "Group Policy update",
        "Restart remote computer",
        "List sessions"
    )
    $presetBox.Add_SelectedIndexChanged({
        switch([string]$this.SelectedItem){
            "Remote command prompt" { $script:PsExecCommandBox.Text = "cmd.exe" }
            "PowerShell prompt" { $script:PsExecCommandBox.Text = "powershell.exe -NoExit" }
            "Computer name and user" { $script:PsExecCommandBox.Text = "cmd.exe /c hostname && whoami" }
            "IP configuration" { $script:PsExecCommandBox.Text = "cmd.exe /c ipconfig /all" }
            "Group Policy update" { $script:PsExecCommandBox.Text = "cmd.exe /c gpupdate /force" }
            "Restart remote computer" { $script:PsExecCommandBox.Text = "shutdown.exe /r /t 0" }
            "List sessions" { $script:PsExecCommandBox.Text = "query.exe session" }
        }
        Update-GUIPsExecCommandPreview | Out-Null
    })

    $builder.Controls.Add((New-GUILabel "Preset"),0,2)
    $builder.Controls.Add($presetBox,1,2)
    $builder.Controls.Add((New-GUILabel "Command"),2,2)
    $builder.Controls.Add($PsExecCommandBox,3,2)

    $builder.Controls.Add((New-GUILabel "Username"),0,3)
    $builder.Controls.Add($PsExecUserBox,1,3)
    $builder.Controls.Add((New-GUILabel "Password"),2,3)
    $builder.Controls.Add($PsExecPasswordBox,3,3)

    $builder.Controls.Add((New-GUILabel "Working dir"),0,4)
    $builder.Controls.Add($PsExecWorkingDirBox,1,4)
    $builder.Controls.Add((New-GUILabel "Service name"),2,4)
    $builder.Controls.Add($PsExecServiceNameBox,3,4)

    $builder.Controls.Add((New-GUILabel "Session"),0,5)
    $builder.Controls.Add($PsExecSessionBox,1,5)

    $options = New-Object System.Windows.Forms.FlowLayoutPanel
    $options.Dock = "Fill"
    $options.FlowDirection = "LeftToRight"
    $options.WrapContents = $true
    $builder.SetColumnSpan($options,2)
    $builder.Controls.Add($options,2,5)

    $script:PsExecAcceptEulaCheck = New-Object System.Windows.Forms.CheckBox
    $PsExecAcceptEulaCheck.Text = "Accept EULA"
    $PsExecAcceptEulaCheck.Checked = $true
    $PsExecAcceptEulaCheck.AutoSize = $true

    $script:PsExecElevatedCheck = New-Object System.Windows.Forms.CheckBox
    $PsExecElevatedCheck.Text = "Elevated token"
    $PsExecElevatedCheck.Checked = $true
    $PsExecElevatedCheck.AutoSize = $true

    $script:PsExecSystemCheck = New-Object System.Windows.Forms.CheckBox
    $PsExecSystemCheck.Text = "Run as SYSTEM"
    $PsExecSystemCheck.AutoSize = $true

    $script:PsExecInteractiveCheck = New-Object System.Windows.Forms.CheckBox
    $PsExecInteractiveCheck.Text = "Interactive"
    $PsExecInteractiveCheck.AutoSize = $true

    $script:PsExecDontWaitCheck = New-Object System.Windows.Forms.CheckBox
    $PsExecDontWaitCheck.Text = "Do not wait"
    $PsExecDontWaitCheck.AutoSize = $true

    $script:PsExecDontLoadProfileCheck = New-Object System.Windows.Forms.CheckBox
    $PsExecDontLoadProfileCheck.Text = "Skip profile"
    $PsExecDontLoadProfileCheck.AutoSize = $true

    foreach($check in @($PsExecAcceptEulaCheck,$PsExecElevatedCheck,$PsExecSystemCheck,$PsExecInteractiveCheck,$PsExecDontWaitCheck,$PsExecDontLoadProfileCheck)){
        $check.Margin = New-Object System.Windows.Forms.Padding(4,7,12,4)
        $check.Add_CheckedChanged({ Update-GUIPsExecCommandPreview | Out-Null })
        [void]$options.Controls.Add($check)
    }

    foreach($box in @($PsExecTargetBox,$PsExecCommandBox,$PsExecUserBox,$PsExecPasswordBox,$PsExecTimeoutBox,$PsExecSessionBox,$PsExecWorkingDirBox,$PsExecServiceNameBox)){
        $box.Add_TextChanged({ Update-GUIPsExecCommandPreview | Out-Null })
    }

    $actions = New-Object System.Windows.Forms.FlowLayoutPanel
    $actions.Dock = "Fill"
    $actions.FlowDirection = "LeftToRight"
    $builder.SetColumnSpan($actions,4)
    $builder.Controls.Add($actions,0,6)

    foreach($button in @(
        (New-GUIButton "Build Command" { Update-GUIPsExecCommandPreview | Out-Null }),
        (New-GUIButton "Copy Command" { Copy-GUIPsExecCommand }),
        (New-GUIButton "Run Captured" { Start-GUIPsExecCaptured }),
        (New-GUIButton "Open Console" { Start-GUIPsExecConsole }),
        (New-GUIButton "Stop" { Stop-GUIPsExecCommand })
    )){
        [void]$actions.Controls.Add($button)
    }

    $script:PsExecCommandPreviewBox = New-Object System.Windows.Forms.TextBox
    $PsExecCommandPreviewBox.Dock = "Fill"
    $PsExecCommandPreviewBox.Multiline = $true
    $PsExecCommandPreviewBox.ReadOnly = $true
    $PsExecCommandPreviewBox.ScrollBars = "Vertical"
    $PsExecCommandPreviewBox.Font = New-Object System.Drawing.Font("Consolas",9)
    $builder.SetColumnSpan($PsExecCommandPreviewBox,4)
    $builder.Controls.Add($PsExecCommandPreviewBox,0,8)

    $script:PsExecOutputBox = New-Object System.Windows.Forms.TextBox
    $PsExecOutputBox.Dock = "Fill"
    $PsExecOutputBox.Multiline = $true
    $PsExecOutputBox.ReadOnly = $true
    $PsExecOutputBox.ScrollBars = "Both"
    $PsExecOutputBox.WordWrap = $false
    $PsExecOutputBox.Font = New-Object System.Drawing.Font("Consolas",9)
    $PsExecOutputBox.BackColor = $script:GUITheme.LogBack
    $PsExecOutputBox.ForeColor = $script:GUITheme.LogFore
    $builder.SetColumnSpan($PsExecOutputBox,4)
    $builder.Controls.Add($PsExecOutputBox,0,9)

    if($script:ToolTip){
        $script:ToolTip.SetToolTip($PsExecTargetBox,"Enter one or more remote computers. Blank runs against the local computer.")
        $script:ToolTip.SetToolTip($PsExecCommandBox,"Enter the full command PsExec should run, such as cmd.exe /c ipconfig /all.")
        $script:ToolTip.SetToolTip($PsExecUserBox,"Optional DOMAIN\user or local account for remote execution.")
        $script:ToolTip.SetToolTip($PsExecPasswordBox,"Optional password. Leave blank to be prompted by PsExec or use current credentials.")
        $script:ToolTip.SetToolTip($PsExecElevatedCheck,"Adds -h so the remote process uses an elevated token when available.")
        $script:ToolTip.SetToolTip($PsExecSystemCheck,"Adds -s to run as LocalSystem on the target.")
        $script:ToolTip.SetToolTip($PsExecInteractiveCheck,"Adds -i to interact with a target session. Usually only for visible GUI testing.")
        $script:ToolTip.SetToolTip($PsExecDontWaitCheck,"Adds -d so PsExec starts the command and returns without waiting.")
    }

    Update-GUIPsExecCommandPreview | Out-Null
    Set-GUIPsExecOutput -Title "PsExec Helper" -Text "Build a command, then use Run Captured for output here or Open Console for interactive commands."
}

function Build-FileToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    Build-GUICatalogToolsPage -Page $Page -Tab "Files" -Title "File Tools"
}

function Build-ChocolateyPage {
    param([System.Windows.Forms.TabPage]$Page)

    $layout = New-Object System.Windows.Forms.TableLayoutPanel
    $layout.Dock = "Fill"
    $layout.RowCount = 2
    $layout.ColumnCount = 2
    $layout.Padding = New-Object System.Windows.Forms.Padding(10)
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,124))) | Out-Null
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $layout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $layout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $Page.Controls.Add($layout)

    $chocoTop = New-Object System.Windows.Forms.GroupBox
    $chocoTop.Text = "Chocolatey"
    $chocoTop.Dock = "Fill"
    $chocoTop.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $layout.Controls.Add($chocoTop,0,0)

    $topPanel = New-Object System.Windows.Forms.TableLayoutPanel
    $topPanel.Dock = "Fill"
    $topPanel.Padding = New-Object System.Windows.Forms.Padding(10)
    $topPanel.ColumnCount = 3
    $topPanel.RowCount = 2
    $topPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,34))) | Out-Null
    $topPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,33))) | Out-Null
    $topPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,33))) | Out-Null
    $topPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $topPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,42))) | Out-Null
    $chocoTop.Controls.Add($topPanel)

    $script:ChocoStatusLabel = New-Object System.Windows.Forms.Label
    $ChocoStatusLabel.Dock = "Fill"
    $ChocoStatusLabel.TextAlign = "MiddleLeft"
    $ChocoStatusLabel.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9)
    [void]$topPanel.Controls.Add($ChocoStatusLabel,0,0)
    $topPanel.SetColumnSpan($ChocoStatusLabel,3)

    [void]$topPanel.Controls.Add((New-GUIButton "Refresh Status" { Refresh-GUIChocoStatus }),0,1)
    [void]$topPanel.Controls.Add((New-GUIButton "Install Chocolatey" { Start-GUIChocolateyInstall }),1,1)
    [void]$topPanel.Controls.Add((New-GUIButton "Scan Installed" { Refresh-GUIChocoInstalledPackages }),2,1)

    $guidanceGroup = New-Object System.Windows.Forms.GroupBox
    $guidanceGroup.Text = "Add Choco Packages To This Toolkit"
    $guidanceGroup.Dock = "Fill"
    $guidanceGroup.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $layout.Controls.Add($guidanceGroup,1,0)

    $guidance = New-Object System.Windows.Forms.Label
    $guidance.Dock = "Fill"
    $guidance.Padding = New-Object System.Windows.Forms.Padding(10,6,10,6)
    $guidance.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9)
    $guidance.TextAlign = "MiddleLeft"
    $guidance.Text = "Use Add to Toolbox for portable utilities. The toolkit tries Chocolatey's download command first, then package extraction, and only asks for a temporary computer install as a last resort. Tools copied into .\Custom are managed on the Apps tab."
    $guidanceGroup.Controls.Add($guidance)

    $searchGroup = New-Object System.Windows.Forms.GroupBox
    $searchGroup.Text = "Install Chocolatey Packages"
    $searchGroup.Dock = "Fill"
    $searchGroup.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $layout.Controls.Add($searchGroup,0,1)

    $searchLayout = New-Object System.Windows.Forms.TableLayoutPanel
    $searchLayout.Dock = "Fill"
    $searchLayout.RowCount = 3
    $searchLayout.ColumnCount = 1
    $searchLayout.Padding = New-Object System.Windows.Forms.Padding(10)
    $searchLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,44))) | Out-Null
    $searchLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $searchLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,46))) | Out-Null
    $searchGroup.Controls.Add($searchLayout)

    $searchPanel = New-Object System.Windows.Forms.TableLayoutPanel
    $searchPanel.Dock = "Fill"
    $searchPanel.ColumnCount = 3
    $searchPanel.RowCount = 1
    $searchPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,82))) | Out-Null
    $searchPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $searchPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,150))) | Out-Null
    $searchLayout.Controls.Add($searchPanel,0,0)

    $searchLabel = New-GUILabel "Search term"
    $searchLabel.Dock = "None"
    $searchLabel.Width = 82
    $searchLabel.Height = 30
    $searchLabel.Margin = New-Object System.Windows.Forms.Padding(3,7,6,3)
    [void]$searchPanel.Controls.Add($searchLabel,0,0)

    $script:ChocoSearchBox = New-GUITextBox
    $ChocoSearchBox.Dock = "Fill"
    $ChocoSearchBox.Height = 26
    $ChocoSearchBox.Margin = New-Object System.Windows.Forms.Padding(3,8,10,3)
    [void]$searchPanel.Controls.Add($ChocoSearchBox,1,0)

    [void]$searchPanel.Controls.Add((New-GUIButton "Search Packages" { Search-GUIChocoPackages }),2,0)

    $script:ChocoGrid = New-Object System.Windows.Forms.DataGridView
    $ChocoGrid.Dock = "Fill"
    $ChocoGrid.ReadOnly = $true
    $ChocoGrid.AllowUserToAddRows = $false
    $ChocoGrid.AllowUserToDeleteRows = $false
    $ChocoGrid.RowHeadersVisible = $false
    $ChocoGrid.MultiSelect = $false
    $ChocoGrid.SelectionMode = "FullRowSelect"
    $ChocoGrid.AutoSizeColumnsMode = "Fill"
    $ChocoGrid.BackgroundColor = [System.Drawing.Color]::White
    [void]$ChocoGrid.Columns.Add("Name","Package")
    [void]$ChocoGrid.Columns.Add("Version","Version")
    $searchLayout.Controls.Add($ChocoGrid,0,1)

    $installPanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $installPanel.Dock = "Fill"
    $searchLayout.Controls.Add($installPanel,0,2)

    [void]$installPanel.Controls.Add((New-GUIButton "Install Selected" { Install-SelectedGUIChocoPackage }))
    $addToolboxButton = New-GUIButton "Add to Toolbox" { Add-SelectedChocoPackageToToolbox }
    $addToolboxButton.Width = 150
    [void]$installPanel.Controls.Add($addToolboxButton)

    $installedGroup = New-Object System.Windows.Forms.GroupBox
    $installedGroup.Text = "Computer Installed Chocolatey Packages"
    $installedGroup.Dock = "Fill"
    $installedGroup.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $layout.Controls.Add($installedGroup,1,1)

    $installedLayout = New-Object System.Windows.Forms.TableLayoutPanel
    $installedLayout.Dock = "Fill"
    $installedLayout.RowCount = 2
    $installedLayout.ColumnCount = 1
    $installedLayout.Padding = New-Object System.Windows.Forms.Padding(10)
    $installedLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $installedLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,84))) | Out-Null
    $installedGroup.Controls.Add($installedLayout)

    $script:ChocoInstalledGrid = New-Object System.Windows.Forms.DataGridView
    $ChocoInstalledGrid.Dock = "Fill"
    $ChocoInstalledGrid.ReadOnly = $true
    $ChocoInstalledGrid.AllowUserToAddRows = $false
    $ChocoInstalledGrid.AllowUserToDeleteRows = $false
    $ChocoInstalledGrid.RowHeadersVisible = $false
    $ChocoInstalledGrid.MultiSelect = $false
    $ChocoInstalledGrid.SelectionMode = "FullRowSelect"
    $ChocoInstalledGrid.AutoSizeColumnsMode = "Fill"
    $ChocoInstalledGrid.BackgroundColor = [System.Drawing.Color]::White
    [void]$ChocoInstalledGrid.Columns.Add("Name","Package")
    [void]$ChocoInstalledGrid.Columns.Add("Version","Installed")
    [void]$ChocoInstalledGrid.Columns.Add("Available","Available")
    [void]$ChocoInstalledGrid.Columns.Add("State","State")
    $installedLayout.Controls.Add($ChocoInstalledGrid,0,0)

    $installedButtons = New-Object System.Windows.Forms.TableLayoutPanel
    $installedButtons.Dock = "Fill"
    $installedButtons.ColumnCount = 2
    $installedButtons.RowCount = 2
    $installedButtons.Padding = New-Object System.Windows.Forms.Padding(4)
    $installedButtons.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $installedButtons.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $installedButtons.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $installedButtons.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $installedLayout.Controls.Add($installedButtons,0,1)

    $refreshComputerButton = New-GUIButton "Refresh Computer List" { Refresh-GUIChocoInstalledPackages }
    $refreshComputerButton.Dock = "Fill"
    $refreshComputerButton.Width = 0
    [void]$installedButtons.Controls.Add($refreshComputerButton,0,0)

    $upgradeAllButton = New-GUIButton "Upgrade All" { Upgrade-AllGUIChocoPackages }
    $upgradeAllButton.Dock = "Fill"
    $upgradeAllButton.Width = 0
    [void]$installedButtons.Controls.Add($upgradeAllButton,1,0)

    $upgradeSelectedButton = New-GUIButton "Upgrade Selected" { Upgrade-SelectedGUIChocoPackage }
    $upgradeSelectedButton.Dock = "Fill"
    $upgradeSelectedButton.Width = 0
    [void]$installedButtons.Controls.Add($upgradeSelectedButton,0,1)

    $uninstallComputerButton = New-GUIButton "Uninstall From Computer" { Uninstall-SelectedGUIChocoPackage }
    $uninstallComputerButton.Dock = "Fill"
    $uninstallComputerButton.Width = 0
    [void]$installedButtons.Controls.Add($uninstallComputerButton,1,1)

    Refresh-GUIChocoStatus
}

function Build-SoftwareToolsPage {
    param([System.Windows.Forms.TabPage]$Page)
    $sectionMap = @{
        "notepad" = "Everyday Tools"
        "firefoxportable" = "Everyday Tools"
        "libreoffice" = "Everyday Tools"
        "drawio" = "Everyday Tools"
        "kompozer" = "Everyday Tools"
    }

    Build-GUIOptimizedToolPage `
        -Page $Page `
        -Tab "Software" `
        -Title "Software Tools" `
        -SectionMap $sectionMap `
        -SectionOrder @("Everyday Tools")
}

function Build-CleanupToolsPage {
    param([System.Windows.Forms.TabPage]$Page)

    $sectionMap = @{
        "bleachbit" = "Disk Cleanup"
        "ccleaner" = "Disk Cleanup"
        "wiseregistrycleaner" = "Registry Cleanup"
        "bulkuninstaller" = "Uninstall And Leftovers"
        "revouninstaller" = "Uninstall And Leftovers"
        "lockhunter" = "Locked Files"
    }

    Build-GUIOptimizedToolPage `
        -Page $Page `
        -Tab "Clean Up" `
        -Title "Clean Up Tools" `
        -SectionMap $sectionMap `
        -SectionOrder @("Disk Cleanup","Registry Cleanup","Uninstall And Leftovers","Locked Files")
}

function Build-CustomToolsPage {
    param([System.Windows.Forms.TabPage]$Page)

    $layout = New-Object System.Windows.Forms.TableLayoutPanel
    $layout.Dock = "Fill"
    $layout.RowCount = 2
    $layout.ColumnCount = 1
    $layout.Padding = New-Object System.Windows.Forms.Padding(10)
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,52))) | Out-Null
    $Page.Controls.Add($layout)

    $script:CustomGrid = New-Object System.Windows.Forms.DataGridView
    $CustomGrid.Dock = "Fill"
    $CustomGrid.ReadOnly = $true
    $CustomGrid.AllowUserToAddRows = $false
    $CustomGrid.AllowUserToDeleteRows = $false
    $CustomGrid.RowHeadersVisible = $false
    $CustomGrid.MultiSelect = $false
    $CustomGrid.SelectionMode = "FullRowSelect"
    $CustomGrid.AutoSizeColumnsMode = "Fill"
    $CustomGrid.BackgroundColor = [System.Drawing.Color]::White
    [void]$CustomGrid.Columns.Add("Name","Name")
    [void]$CustomGrid.Columns.Add("Source","Source")
    [void]$CustomGrid.Columns.Add("Version","Version")
    [void]$CustomGrid.Columns.Add("Status","Status")
    [void]$CustomGrid.Columns.Add("Tab","Tab Placement")
    $CustomGrid.Columns["Name"].FillWeight = 28
    $CustomGrid.Columns["Source"].FillWeight = 22
    $CustomGrid.Columns["Version"].FillWeight = 12
    $CustomGrid.Columns["Status"].FillWeight = 12
    $CustomGrid.Columns["Tab"].FillWeight = 26
    $layout.Controls.Add($CustomGrid,0,0)

    $buttons = New-Object System.Windows.Forms.FlowLayoutPanel
    $buttons.Dock = "Fill"
    $buttons.Padding = New-Object System.Windows.Forms.Padding(8)
    $layout.Controls.Add($buttons,0,1)
    [void]$buttons.Controls.Add((New-GUIButton "Launch Toolkit Tool" { Start-SelectedGUICustomTool }))
    [void]$buttons.Controls.Add((New-GUIButton "Rename" { Rename-SelectedGUICustomTool }))
    [void]$buttons.Controls.Add((New-GUIButton "Set Tab Placement" { Set-SelectedGUICustomToolTab }))
    $removeToolkitButton = New-GUIButton "Remove From Toolkit" { Remove-SelectedGUICustomTool }
    $removeToolkitButton.Width = 180
    [void]$buttons.Controls.Add($removeToolkitButton)
    [void]$buttons.Controls.Add((New-GUIButton "Open Location" { Open-SelectedGUICustomToolFolder }))
    [void]$buttons.Controls.Add((New-GUIButton "Refresh Toolkit Tools" { Refresh-GUICustomTools; Refresh-GUICustomToolTabs }))

    $CustomGrid.Add_CellDoubleClick({ Start-SelectedGUICustomTool })
    Refresh-GUICustomTools
}

function Build-LiveLogPage {
    param([System.Windows.Forms.TabPage]$Page)

    $layout = New-Object System.Windows.Forms.TableLayoutPanel
    $layout.Dock = "Fill"
    $layout.RowCount = 2
    $layout.ColumnCount = 1
    $layout.Padding = New-Object System.Windows.Forms.Padding(10)
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,52))) | Out-Null
    $Page.Controls.Add($layout)

    $script:LogBox = New-Object System.Windows.Forms.TextBox
    $LogBox.Dock = "Fill"
    $LogBox.Multiline = $true
    $LogBox.ReadOnly = $true
    $LogBox.ScrollBars = "Vertical"
    $LogBox.Font = New-Object System.Drawing.Font("Consolas",9)
    $LogBox.BackColor = $script:GUITheme.LogBack
    $LogBox.ForeColor = $script:GUITheme.LogFore
    $layout.Controls.Add($LogBox,0,0)

    Update-GUILiveLogScreen

    $buttons = New-Object System.Windows.Forms.FlowLayoutPanel
    $buttons.Dock = "Fill"
    $buttons.Padding = New-Object System.Windows.Forms.Padding(8)
    $layout.Controls.Add($buttons,0,1)

    [void]$buttons.Controls.Add((New-GUIButton "Clear Log" { if($script:LogLines){ $script:LogLines.Clear() }; if($script:LogBox -and !$script:LogBox.IsDisposed){ $script:LogBox.Clear() }; Add-GUILog "Live log cleared." }))
    [void]$buttons.Controls.Add((New-GUIButton "Copy Log" { if($script:LogBox){ [System.Windows.Forms.Clipboard]::SetText($script:LogBox.Text); Add-GUILog "Live log copied to clipboard." } }))
}

function Move-GUISettingsSelectedTab {
    param([int]$Offset)

    $list = $script:SettingsTabOrderList
    if(!$list -or $list.SelectedIndex -lt 0){
        return
    }

    $oldIndex = $list.SelectedIndex
    $newIndex = $oldIndex + $Offset
    if($newIndex -lt 0 -or $newIndex -ge $list.Items.Count){
        return
    }

    $item = $list.Items[$oldIndex]
    $list.Items.RemoveAt($oldIndex)
    $list.Items.Insert($newIndex,$item)
    $list.SelectedIndex = $newIndex
}

function Reset-GUISettingsPageDefaults {
    $defaults = Get-GUIDefaultSettings

    if($script:SettingsTabOrderList){
        $script:SettingsTabOrderList.Items.Clear()
        foreach($tab in $defaults.tabOrder){
            [void]$script:SettingsTabOrderList.Items.Add($tab)
        }
    }

    if($script:SettingsStartupTabCombo){
        $script:SettingsStartupTabCombo.SelectedItem = $defaults.startupTab
    }

    if($script:SettingsThemeCombo){
        $script:PendingCustomTheme = $null
        $script:SettingsThemeCombo.SelectedItem = $defaults.colorTheme
        $script:SettingsPreviousTheme = $defaults.colorTheme
    }

    if($script:SettingsAutoOpenQuickReportCheck){
        $script:SettingsAutoOpenQuickReportCheck.Checked = [bool]$defaults.autoOpenQuickDiagnosisReport
    }

    if($script:SettingsRefreshPublicIPCheck){
        $script:SettingsRefreshPublicIPCheck.Checked = [bool]$defaults.refreshPublicIPOnLaunch
    }
}

function Save-GUISettingsFromPage {
    if(!$script:SettingsTabOrderList){
        return
    }

    $order = @()
    foreach($item in $script:SettingsTabOrderList.Items){
        $order += [string]$item
    }

    $startup = if($script:SettingsStartupTabCombo -and $script:SettingsStartupTabCombo.SelectedItem){
        [string]$script:SettingsStartupTabCombo.SelectedItem
    }
    else{
        "Quick Diagnosis"
    }

    $theme = if($script:SettingsThemeCombo -and $script:SettingsThemeCombo.SelectedItem){
        [string]$script:SettingsThemeCombo.SelectedItem
    }
    else{
        "Bright Blue"
    }

    $customTheme = if($script:PendingCustomTheme){
        $script:PendingCustomTheme
    }
    elseif($script:GuiSettings -and $script:GuiSettings.PSObject.Properties.Name -contains "customTheme" -and $script:GuiSettings.customTheme){
        $script:GuiSettings.customTheme
    }
    else{
        (Get-GUIDefaultSettings).customTheme
    }

    $settings = [pscustomobject]@{
        tabOrder = $order
        startupTab = $startup
        colorTheme = $theme
        customTheme = $customTheme
        autoOpenQuickDiagnosisReport = if($script:SettingsAutoOpenQuickReportCheck){[bool]$script:SettingsAutoOpenQuickReportCheck.Checked}else{$false}
        refreshPublicIPOnLaunch = if($script:SettingsRefreshPublicIPCheck){[bool]$script:SettingsRefreshPublicIPCheck.Checked}else{$true}
    }

    Save-GUISettings -Settings $settings
    Set-GUIColorTheme -Name $theme
    Apply-GUIThemeRuntime

    if($script:MainTabs){
        Apply-GUITabOrder -Tabs $script:MainTabs -Order $order
    }

    if($script:StaticTabStrip -and $script:MainTabs){
        Add-GUIStaticTabStrip -Strip $script:StaticTabStrip -Tabs $script:MainTabs
    }

    Apply-GUIThemeRuntime
    Add-GUILog "Settings applied and saved."
}

function Get-GUIClientDataTargets {
    $targets = @($CSIPaths.Exports,$CSIPaths.Data)

    # A few plugins maintain their own logs outside the central Logs folder.
    $targets += @(
        (Join-Path $CSIPaths.Root "Plugins\PrintQueues\Logs"),
        (Join-Path $CSIPaths.Root "Plugins\PrintQueues\Print Queue Cleanup\Logs")
    )

    $targets += @(Get-ChildItem -Path $CSIPaths.Root -Directory -Recurse -Filter "Logs" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName)
    return @($targets | Where-Object { $_ -and (Test-Path $_) } | Sort-Object -Unique)
}

function Get-GUIClientDataSummary {
    $files = @()
    foreach($target in Get-GUIClientDataTargets){
        $files += @(Get-ChildItem -LiteralPath $target -Force -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne ".gitkeep" })
    }

    return [pscustomobject]@{
        FileCount = @($files).Count
        SizeMB = [math]::Round((@($files | Measure-Object -Property Length -Sum).Sum / 1MB),2)
    }
}

function Confirm-GUIClientDataRemoval {
    param([pscustomobject]$Summary)

    $firstConfirmation = [System.Windows.Forms.MessageBox]::Show(
        "This removes collected client diagnostic data from this toolkit.`r`n`r`nIncluded: reports, exports, saved computer profiles and state, minidump collections, temporary tool output, print data, and toolkit/plugin logs.`r`n`r`nDetected now: $($Summary.FileCount) file(s), $($Summary.SizeMB) MB.`r`n`r`nToolkit applications, custom tools, settings, package manifests, and help files are preserved.`r`n`r`nContinue to the final confirmation?",
        "Remove Client Data - First Confirmation",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )

    if($firstConfirmation -ne [System.Windows.Forms.DialogResult]::Yes){
        return $false
    }

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Remove Client Data - Final Confirmation"
    $form.StartPosition = "CenterParent"
    $form.Size = New-Object System.Drawing.Size(590,245)
    $form.MinimumSize = New-Object System.Drawing.Size(590,245)
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.Font = New-Object System.Drawing.Font("Segoe UI",9.5)
    $form.BackColor = $script:GUITheme.Page

    $message = New-Object System.Windows.Forms.Label
    $message.Location = New-Object System.Drawing.Point(20,18)
    $message.Size = New-Object System.Drawing.Size(540,92)
    $message.Text = "Final confirmation: this permanently removes all collected client diagnostic data from the toolkit.`r`n`r`nType REMOVE CLIENT DATA exactly to continue."
    $message.ForeColor = $script:GUITheme.Text
    $form.Controls.Add($message)

    $entry = New-Object System.Windows.Forms.TextBox
    $entry.Location = New-Object System.Drawing.Point(20,122)
    $entry.Size = New-Object System.Drawing.Size(540,27)
    $entry.CharacterCasing = "Upper"
    $form.Controls.Add($entry)

    $cancel = New-Object System.Windows.Forms.Button
    $cancel.Text = "Cancel"
    $cancel.Location = New-Object System.Drawing.Point(360,165)
    $cancel.Size = New-Object System.Drawing.Size(95,34)
    $cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.Controls.Add($cancel)

    $remove = New-Object System.Windows.Forms.Button
    $remove.Text = "Remove Data"
    $remove.Location = New-Object System.Drawing.Point(465,165)
    $remove.Size = New-Object System.Drawing.Size(95,34)
    $remove.Enabled = $false
    $remove.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.Controls.Add($remove)

    $entry.Add_TextChanged({ $remove.Enabled = $entry.Text.Trim() -eq "REMOVE CLIENT DATA" })
    $form.AcceptButton = $remove
    $form.CancelButton = $cancel
    $result = $form.ShowDialog($script:Form)
    $form.Dispose()
    return $result -eq [System.Windows.Forms.DialogResult]::OK
}

function Clear-GUIClientDataTarget {
    param([string]$Path)

    $removed = 0
    foreach($item in @(Get-ChildItem -LiteralPath $Path -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne ".gitkeep" })){
        Remove-Item -LiteralPath $item.FullName -Recurse -Force -ErrorAction Stop
        $removed++
    }
    return $removed
}

function Invoke-GUIRemoveClientData {
    $summary = Get-GUIClientDataSummary
    if(!(Confirm-GUIClientDataRemoval -Summary $summary)){
        Add-GUILog "Client data removal cancelled."
        return
    }

    $removedTargets = 0
    $failures = @()
    foreach($target in Get-GUIClientDataTargets){
        try {
            $removedTargets += Clear-GUIClientDataTarget -Path $target
        }
        catch {
            $failures += "${target}: $($_.Exception.Message)"
        }
    }

    $script:LatestComputerProfileCache = $null
    $script:LatestComputerProfileCacheTime = [datetime]::MinValue
    $script:LatestQuickDiagnosisReport = $null
    $script:QuickDiagnosisRan = $false
    $script:DismSfcRecommended = $false
    $script:LogLines = New-Object System.Collections.ArrayList
    Refresh-Fingerprints -Quiet
    Refresh-GUILastQuickDiagnosisLabel
    Refresh-GUIDismSfcState
    Update-GUIComputerHealthLight
    Refresh-GUIReports

    $message = "Removed client data from $removedTargets top-level item(s). Toolkit apps, settings, package manifests, and custom tool definitions were preserved."
    if($failures.Count -gt 0){
        $message += "`r`n`r`nSome items could not be removed:`r`n" + ($failures -join "`r`n")
    }

    Add-GUILog "Client data removal completed."
    $messageIcon = if($failures.Count -gt 0){[System.Windows.Forms.MessageBoxIcon]::Warning}else{[System.Windows.Forms.MessageBoxIcon]::Information}
    [System.Windows.Forms.MessageBox]::Show(
        $message,
        "Client Data Removed",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        $messageIcon
    ) | Out-Null
}

function Build-SettingsPage {
    param([System.Windows.Forms.TabPage]$Page)

    $settings = if($script:GuiSettings){$script:GuiSettings}else{Get-GUISettings}
    $availableTabs = @()
    if($script:MainTabs){
        foreach($tab in $script:MainTabs.TabPages){
            if($tab.Text -ne "Settings"){
                $availableTabs += [string]$tab.Text
            }
        }
    }
    else{
        $availableTabs = @(Get-GUIDefaultTabOrder)
    }

    $orderedTabs = Get-GUIOrderedTabNames -AvailableTabs $availableTabs

    $layout = New-Object System.Windows.Forms.TableLayoutPanel
    $layout.Dock = "Fill"
    $layout.ColumnCount = 4
    $layout.RowCount = 1
    $layout.Padding = New-Object System.Windows.Forms.Padding(16)
    $layout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,400))) | Out-Null
    $layout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,72))) | Out-Null
    $layout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,500))) | Out-Null
    $layout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $Page.Controls.Add($layout)

    $orderGroup = New-Object System.Windows.Forms.GroupBox
    $orderGroup.Text = "Tab Order"
    $orderGroup.Dock = "Fill"
    $orderGroup.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $layout.Controls.Add($orderGroup,0,0)

    $orderLayout = New-Object System.Windows.Forms.TableLayoutPanel
    $orderLayout.Dock = "Fill"
    $orderLayout.RowCount = 2
    $orderLayout.ColumnCount = 2
    $orderLayout.Padding = New-Object System.Windows.Forms.Padding(10)
    $orderLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $orderLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,116))) | Out-Null
    $orderLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $orderLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,42))) | Out-Null
    $orderGroup.Controls.Add($orderLayout)

    $script:SettingsTabOrderList = New-Object System.Windows.Forms.ListBox
    $SettingsTabOrderList.Dock = "Fill"
    $SettingsTabOrderList.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10)
    foreach($tab in $orderedTabs){
        [void]$SettingsTabOrderList.Items.Add($tab)
    }
    if($SettingsTabOrderList.Items.Count -gt 0){
        $SettingsTabOrderList.SelectedIndex = 0
    }
    $orderLayout.Controls.Add($SettingsTabOrderList,0,0)

    $moveButtons = New-Object System.Windows.Forms.FlowLayoutPanel
    $moveButtons.Dock = "Fill"
    $moveButtons.FlowDirection = "TopDown"
    $moveButtons.WrapContents = $false
    $moveButtons.Padding = New-Object System.Windows.Forms.Padding(6,2,0,0)
    $orderLayout.Controls.Add($moveButtons,1,0)
    $moveUpButton = New-GUIButton "Move Up" { Move-GUISettingsSelectedTab -Offset -1 }
    $moveUpButton.Width = 100
    $moveUpButton.Height = 34
    $moveUpButton.Margin = New-Object System.Windows.Forms.Padding(4,4,4,8)
    [void]$moveButtons.Controls.Add($moveUpButton)
    $moveDownButton = New-GUIButton "Move Down" { Move-GUISettingsSelectedTab -Offset 1 }
    $moveDownButton.Width = 100
    $moveDownButton.Height = 34
    $moveDownButton.Margin = New-Object System.Windows.Forms.Padding(4,4,4,4)
    [void]$moveButtons.Controls.Add($moveDownButton)

    $orderHint = New-Object System.Windows.Forms.Label
    $orderHint.Dock = "Fill"
    $orderHint.TextAlign = "MiddleLeft"
    $orderHint.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9)
    $orderHint.ForeColor = $script:GUITheme.MutedText
    $orderHint.Text = "Move tabs, then Apply Settings."
    $orderLayout.Controls.Add($orderHint,0,1)

    $rightPanel = New-Object System.Windows.Forms.GroupBox
    $rightPanel.Text = "Startup And Layout"
    $rightPanel.Dock = "Fill"
    $rightPanel.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $layout.Controls.Add($rightPanel,2,0)

    $rightLayout = New-Object System.Windows.Forms.TableLayoutPanel
    $rightLayout.Dock = "Fill"
    $rightLayout.RowCount = 11
    $rightLayout.ColumnCount = 2
    $rightLayout.Padding = New-Object System.Windows.Forms.Padding(12)
    $rightLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,150))) | Out-Null
    $rightLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $rightLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,28))) | Out-Null
    $rightLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,40))) | Out-Null
    $rightLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,28))) | Out-Null
    $rightLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,40))) | Out-Null
    $rightLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,34))) | Out-Null
    $rightLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,34))) | Out-Null
    $rightLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,48))) | Out-Null
    $rightLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,62))) | Out-Null
    $rightLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,28))) | Out-Null
    $rightLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,86))) | Out-Null
    $rightLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $rightPanel.Controls.Add($rightLayout)

    $rightLayout.Controls.Add((New-GUILabel "Startup tab"),0,0)
    $rightLayout.SetColumnSpan($rightLayout.GetControlFromPosition(0,0),2)

    $script:SettingsStartupTabCombo = New-Object System.Windows.Forms.ComboBox
    $SettingsStartupTabCombo.Dock = "Fill"
    $SettingsStartupTabCombo.DropDownStyle = "DropDownList"
    $SettingsStartupTabCombo.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9.5)
    foreach($tab in $orderedTabs){
        [void]$SettingsStartupTabCombo.Items.Add($tab)
    }
    $startup = if($settings.startupTab -and $orderedTabs -contains $settings.startupTab){$settings.startupTab}else{"Quick Diagnosis"}
    $SettingsStartupTabCombo.SelectedItem = $startup
    $rightLayout.Controls.Add($SettingsStartupTabCombo,0,1)
    $rightLayout.SetColumnSpan($SettingsStartupTabCombo,2)

    $rightLayout.Controls.Add((New-GUILabel "Color theme"),0,2)
    $rightLayout.SetColumnSpan($rightLayout.GetControlFromPosition(0,2),2)

    $script:SettingsThemeCombo = New-Object System.Windows.Forms.ComboBox
    $SettingsThemeCombo.Dock = "Fill"
    $SettingsThemeCombo.DropDownStyle = "DropDownList"
    $SettingsThemeCombo.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9.5)
    foreach($themeName in (Get-GUIColorThemeNames)){
        [void]$SettingsThemeCombo.Items.Add($themeName)
    }
    $selectedTheme = if($settings.colorTheme -and (Get-GUIColorThemeNames) -contains $settings.colorTheme){$settings.colorTheme}else{"Bright Blue"}
    $SettingsThemeCombo.SelectedItem = $selectedTheme
    $script:SettingsPreviousTheme = $selectedTheme
    $SettingsThemeCombo.Add_SelectedIndexChanged({
        if(!$script:SettingsThemeCombo -or !$script:SettingsThemeCombo.SelectedItem){
            return
        }

        $selected = [string]$script:SettingsThemeCombo.SelectedItem
        if($selected -eq "Custom Theme"){
            $customTheme = Invoke-GUICustomThemePicker
            if($customTheme){
                $script:PendingCustomTheme = $customTheme
                $script:SettingsPreviousTheme = "Custom Theme"
                Add-GUILog "Custom theme colors selected. Click Apply Settings to save them."
            }
            else{
                $fallback = if($script:SettingsPreviousTheme){$script:SettingsPreviousTheme}else{"Bright Blue"}
                $script:SettingsThemeCombo.SelectedItem = $fallback
                Add-GUILog "Custom theme selection cancelled."
            }
        }
        else{
            $script:SettingsPreviousTheme = $selected
        }
    })
    $rightLayout.Controls.Add($SettingsThemeCombo,0,3)
    $rightLayout.SetColumnSpan($SettingsThemeCombo,2)

    $script:SettingsAutoOpenQuickReportCheck = New-Object System.Windows.Forms.CheckBox
    $SettingsAutoOpenQuickReportCheck.Dock = "Fill"
    $SettingsAutoOpenQuickReportCheck.Text = "Open Quick Diagnosis report when finished"
    $SettingsAutoOpenQuickReportCheck.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9.5)
    $SettingsAutoOpenQuickReportCheck.Checked = [bool]$settings.autoOpenQuickDiagnosisReport
    $rightLayout.Controls.Add($SettingsAutoOpenQuickReportCheck,0,4)
    $rightLayout.SetColumnSpan($SettingsAutoOpenQuickReportCheck,2)

    $script:SettingsRefreshPublicIPCheck = New-Object System.Windows.Forms.CheckBox
    $SettingsRefreshPublicIPCheck.Dock = "Fill"
    $SettingsRefreshPublicIPCheck.Text = "Refresh public IP when the toolkit opens"
    $SettingsRefreshPublicIPCheck.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9.5)
    $SettingsRefreshPublicIPCheck.Checked = [bool]$settings.refreshPublicIPOnLaunch
    $rightLayout.Controls.Add($SettingsRefreshPublicIPCheck,0,5)
    $rightLayout.SetColumnSpan($SettingsRefreshPublicIPCheck,2)

    $buttonPanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $buttonPanel.Dock = "Fill"
    $buttonPanel.FlowDirection = "LeftToRight"
    $buttonPanel.Padding = New-Object System.Windows.Forms.Padding(0,6,0,0)
    $rightLayout.Controls.Add($buttonPanel,0,6)
    $rightLayout.SetColumnSpan($buttonPanel,2)
    $applyButton = New-GUIButton "Apply Settings" { Save-GUISettingsFromPage }
    $applyButton.Width = 150
    [void]$buttonPanel.Controls.Add($applyButton)
    $resetButton = New-GUIButton "Reset Defaults" { Reset-GUISettingsPageDefaults }
    $resetButton.Width = 140
    [void]$buttonPanel.Controls.Add($resetButton)

    $dataRemovalPanel = New-Object System.Windows.Forms.TableLayoutPanel
    $dataRemovalPanel.Dock = "Fill"
    $dataRemovalPanel.ColumnCount = 2
    $dataRemovalPanel.Padding = New-Object System.Windows.Forms.Padding(0,6,0,0)
    $dataRemovalPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $dataRemovalPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,174))) | Out-Null
    $rightLayout.Controls.Add($dataRemovalPanel,0,7)
    $rightLayout.SetColumnSpan($dataRemovalPanel,2)

    $dataRemovalHint = New-GUILabel "Client diagnostic data"
    $dataRemovalHint.Dock = "Fill"
    $dataRemovalHint.TextAlign = "MiddleLeft"
    $dataRemovalHint.ForeColor = $script:GUITheme.MutedText
    [void]$dataRemovalPanel.Controls.Add($dataRemovalHint,0,0)

    $sanitizeButton = New-GUIButton "Remove Client Data" { Invoke-GUIRemoveClientData }
    $sanitizeButton.Dock = "Fill"
    $sanitizeButton.Width = 0
    [void]$dataRemovalPanel.Controls.Add($sanitizeButton,1,0)

    $foldersLabel = New-GUILabel "Toolkit folders"
    $rightLayout.Controls.Add($foldersLabel,0,8)
    $rightLayout.SetColumnSpan($foldersLabel,2)

    $folderPanel = New-Object System.Windows.Forms.TableLayoutPanel
    $folderPanel.Dock = "Fill"
    $folderPanel.ColumnCount = 2
    $folderPanel.RowCount = 2
    $folderPanel.Padding = New-Object System.Windows.Forms.Padding(0,4,0,0)
    $folderPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $folderPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $folderPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $folderPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,50))) | Out-Null
    $rightLayout.Controls.Add($folderPanel,0,9)
    $rightLayout.SetColumnSpan($folderPanel,2)

    $logsButton = New-GUIButton "Open Logs" { Open-GUIFolder $CSIPaths.Logs }
    $logsButton.Dock = "Fill"
    $logsButton.Width = 0
    $folderPanel.Controls.Add($logsButton,0,0)

    $reportsButton = New-GUIButton "Open Reports" { Open-GUIFolder $CSIPaths.Exports }
    $reportsButton.Dock = "Fill"
    $reportsButton.Width = 0
    $folderPanel.Controls.Add($reportsButton,1,0)

    $tempButton = New-GUIButton "Open Temp Outputs" { Open-GUIFolder (Get-CSITempOutputRoot) }
    $tempButton.Dock = "Fill"
    $tempButton.Width = 0
    $folderPanel.Controls.Add($tempButton,0,1)

    $dataButton = New-GUIButton "Open Data" { Open-GUIFolder $CSIPaths.Data }
    $dataButton.Dock = "Fill"
    $dataButton.Width = 0
    $folderPanel.Controls.Add($dataButton,1,1)
}

function Set-GUIFallbackButtonToolTips {
    if(!$script:ToolTip -or !$script:Form){
        return
    }

    $tooltips = @{
        "Run Quick Diagnosis" = "Run the primary health check and create a technician-ready HTML report."
        "Run DISM/SFC Repair Path" = "Start the Windows image and system file repair workflow after reviewing diagnosis results."
        "Open HTML Report" = "Open the selected computer profile report in the default browser."
        "Create Profile" = "Run Quick Diagnosis and save a fresh computer profile with the report."
        "Delete" = "Delete the selected saved computer profile record and related report files."
        "Refresh" = "Reload the list with the latest available computer profiles."
        "Build Command" = "Generate a robocopy command from the selected source, destination, and options."
        "Copy Command" = "Copy the generated robocopy command to the clipboard."
        "Preview Only" = "Run robocopy in list-only mode so you can review what would copy."
        "Run Copy" = "Start the generated robocopy job with the selected options."
        "Open WizTree" = "Launch WizTree for fast disk space analysis."
        "Everything" = "Launch Everything for instant local filename search."
        "WinDirStat" = "Launch WinDirStat to visualize disk usage and large folders."
        "WinMerge" = "Launch WinMerge to compare and merge files or folders."
        "Kudu" = "Launch Kudu as a portable file manager."
        "Refresh Status" = "Check whether Chocolatey is installed and ready to use."
        "Install Chocolatey" = "Install Chocolatey so packages can be added from this toolkit."
        "Search Packages" = "Search Chocolatey for package names matching the entered term."
        "Install Selected" = "Install the selected Chocolatey package."
        "Apply Settings" = "Apply and save Settings tab choices to the portable toolkit drive."
        "Reset Defaults" = "Restore the default Settings tab choices. Click Apply Settings to save them."
        "Remove Client Data" = "Permanently remove collected client reports, profiles, diagnostic output, dumps, and logs after two confirmations."
        "Open Logs" = "Open the toolkit log folder for troubleshooting GUI and tool launch issues."
        "Open Reports" = "Open exported technician reports."
        "Open Temp Outputs" = "Open temporary tool output sessions."
        "Open Data" = "Open toolkit data such as computer profiles and working files."
        "Set Tab Placement" = "Choose which main toolkit tab this custom tool should appear on."
        "Notepad++" = "Open Notepad++ for logs, scripts, configs, and quick text edits."
        "Draw.io" = "Open Draw.io for network diagrams, flowcharts, and troubleshooting visuals."
        "KompoZer" = "Open KompoZer for quick HTML or report edits."
        "Open Console" = "Open the original command-line toolkit."
    }

    $pending = New-Object System.Collections.ArrayList
    [void]$pending.Add($script:Form)

    while($pending.Count -gt 0){
        $current = $pending[0]
        $pending.RemoveAt(0)

        if($current -is [System.Windows.Forms.Button]){
            $existing = $script:ToolTip.GetToolTip($current)

            if([string]::IsNullOrWhiteSpace($existing)){
                $text = [string]$current.Text

                if($tooltips.ContainsKey($text)){
                    $script:ToolTip.SetToolTip($current,$tooltips[$text])
                }
                elseif(![string]::IsNullOrWhiteSpace($text) -and $text -ne ">"){
                    $script:ToolTip.SetToolTip($current,"Run $text.")
                }
            }
        }

        foreach($child in $current.Controls){
            [void]$pending.Add($child)
        }
    }
}

function Build-Form {
    $script:GuiSettings = Get-GUISettings
    Set-GUIColorTheme -Name $script:GuiSettings.colorTheme

    $script:Form = New-Object System.Windows.Forms.Form
    $Form.Text = "Network Toolkit"
    $Form.StartPosition = "CenterScreen"
    $Form.MinimumSize = New-Object System.Drawing.Size(1280,720)
    $Form.Size = New-Object System.Drawing.Size(1480,820)
    $Form.ShowIcon = $true
    $Form.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9.5)
    $Form.BackColor = $script:GUITheme.Shell

    if(Test-Path $GuiIconPath){
        $Form.Icon = New-Object System.Drawing.Icon($GuiIconPath)
    }

    $root = New-Object System.Windows.Forms.TableLayoutPanel
    $root.Dock = "Fill"
    $root.RowCount = 4
    $root.ColumnCount = 1
    $root.Padding = New-Object System.Windows.Forms.Padding(10)
    $root.BackColor = $script:GUITheme.Page
    $script:RootLayout = $root
    $root.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,86))) | Out-Null
    $root.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,118))) | Out-Null
    $root.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,100))) | Out-Null
    $root.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute,26))) | Out-Null
    $Form.Controls.Add($root)

    if(!$script:ToolTip){
        $script:ToolTip = New-Object System.Windows.Forms.ToolTip
        $script:ToolTip.AutoPopDelay = 12000
        $script:ToolTip.InitialDelay = 400
        $script:ToolTip.ReshowDelay = 150
        $script:ToolTip.ShowAlways = $true
    }

    $header = New-Object System.Windows.Forms.Panel
    $header.Dock = "Fill"
    $header.BackColor = $script:GUITheme.Header
    $script:HeaderPanel = $header
    $root.Controls.Add($header,0,0)

    $logo = New-Object System.Windows.Forms.PictureBox
    $logo.Location = New-Object System.Drawing.Point(12,13)
    $logo.Size = New-Object System.Drawing.Size(52,52)
    $logo.SizeMode = "Zoom"
    $logoPath = Join-Path $GuiRoot "NetworkToolkit.png"
    if(Test-Path $logoPath){
        $logo.Image = [System.Drawing.Image]::FromFile($logoPath)
    }
    $header.Controls.Add($logo)

    $headerTools = New-Object System.Windows.Forms.Panel
    $headerTools.Anchor = "Top,Right"
    $headerTools.Location = New-Object System.Drawing.Point(1070,14)
    $headerTools.Size = New-Object System.Drawing.Size(322,42)
    $headerTools.BackColor = $script:GUITheme.HeaderPanel
    $script:HeaderToolsPanel = $headerTools
    Set-GUIRoundedCorners -Control $headerTools -Radius 12
    $header.Controls.Add($headerTools)

    $settingsGear = New-Object System.Windows.Forms.Button
    $settingsGear.Text = [string][char]0x2699
    $settingsGear.Location = New-Object System.Drawing.Point(185,7)
    $settingsGear.Size = New-Object System.Drawing.Size(30,28)
    $settingsGear.Font = New-Object System.Drawing.Font("Segoe UI Symbol",10,[System.Drawing.FontStyle]::Bold)
    Set-GUIButtonChrome -Button $settingsGear
    $settingsGear.BackColor = $script:GUITheme.AccentDark
    $settingsGear.Add_Click({ Open-GUISettingsPage })
    $script:SettingsGearButton = $settingsGear
    $headerTools.Controls.Add($settingsGear)
    if($script:ToolTip){ $script:ToolTip.SetToolTip($settingsGear,"Open toolkit settings.") }

    $title = New-Object System.Windows.Forms.Label
    $title.Text = "Network Toolkit"
    $title.Location = New-Object System.Drawing.Point(76,14)
    $title.Size = New-Object System.Drawing.Size(270,30)
    $title.Font = New-Object System.Drawing.Font("Segoe UI Semilight",18,[System.Drawing.FontStyle]::Bold)
    $title.ForeColor = [System.Drawing.Color]::White
    $script:HeaderTitleLabel = $title
    $header.Controls.Add($title)

    $subtitle = New-Object System.Windows.Forms.Label
    $subtitle.Text = "Portable technician console"
    $subtitle.Location = New-Object System.Drawing.Point(80,46)
    $subtitle.Size = New-Object System.Drawing.Size(235,20)
    $subtitle.Font = New-Object System.Drawing.Font("Segoe UI Semilight",9.5)
    $subtitle.ForeColor = $script:GUITheme.HeaderMuted
    $script:HeaderSubtitleLabel = $subtitle
    $header.Controls.Add($subtitle)

    $admin = New-Object System.Windows.Forms.Label
    $admin.Text = if(Test-GUIAdministrator){"Running elevated"}else{"Not elevated"}
    $admin.Location = New-Object System.Drawing.Point(10,9)
    $admin.Size = New-Object System.Drawing.Size(166,24)
    $admin.TextAlign = "MiddleRight"
    $admin.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10,[System.Drawing.FontStyle]::Bold)
    $admin.ForeColor = if(Test-GUIAdministrator){[System.Drawing.Color]::FromArgb(170,230,205)}else{[System.Drawing.Color]::FromArgb(250,215,135)}
    $script:AdminStatusLabel = $admin
    $headerTools.Controls.Add($admin)

    $helpButton = New-Object System.Windows.Forms.Button
    $helpButton.Text = "Help"
    $helpButton.Location = New-Object System.Drawing.Point(226,7)
    $helpButton.Size = New-Object System.Drawing.Size(84,28)
    Set-GUIButtonChrome -Button $helpButton
    $helpButton.BackColor = $script:GUITheme.AccentDark
    $helpButton.Add_Click({ Open-GUIHelpFile })
    $script:HelpButton = $helpButton
    $headerTools.Controls.Add($helpButton)
    if($script:ToolTip){ $script:ToolTip.SetToolTip($helpButton,"Open the Network Toolkit help guide.") }

    Add-GUIHeaderComputerSummary -Header $header

    $tabStrip = New-Object System.Windows.Forms.FlowLayoutPanel
    $tabStrip.Dock = "Fill"
    $tabStrip.WrapContents = $true
    $tabStrip.AutoScroll = $false
    $tabStrip.Padding = New-Object System.Windows.Forms.Padding(0,6,0,8)
    $tabStrip.BackColor = $script:GUITheme.Strip
    $script:StaticTabStrip = $tabStrip
    $root.Controls.Add($tabStrip,0,1)

    $tabs = New-Object System.Windows.Forms.TabControl
    $tabs.Dock = "Fill"
    $tabs.Font = New-Object System.Drawing.Font("Segoe UI Semilight",10)
    $tabs.Multiline = $false
    $tabs.SizeMode = "Fixed"
    $tabs.ItemSize = New-Object System.Drawing.Size(1,1)
    $tabs.Appearance = [System.Windows.Forms.TabAppearance]::FlatButtons
    $script:MainTabs = $tabs
    $root.Controls.Add($tabs,0,2)

    $quickPage = New-Object System.Windows.Forms.TabPage
    $quickPage.Text = "Quick Diagnosis"
    $tabs.TabPages.Add($quickPage) | Out-Null

    $analyzePage = New-Object System.Windows.Forms.TabPage
    $analyzePage.Text = "Analyze"
    $tabs.TabPages.Add($analyzePage) | Out-Null

    $windowsUpdatePage = New-Object System.Windows.Forms.TabPage
    $windowsUpdatePage.Text = "Windows Update"
    $tabs.TabPages.Add($windowsUpdatePage) | Out-Null

    $hardwarePage = New-Object System.Windows.Forms.TabPage
    $hardwarePage.Text = "Hardware"
    $tabs.TabPages.Add($hardwarePage) | Out-Null

    $crashPage = New-Object System.Windows.Forms.TabPage
    $crashPage.Text = "Crash"
    $tabs.TabPages.Add($crashPage) | Out-Null

    $processesPage = New-Object System.Windows.Forms.TabPage
    $processesPage.Text = "Processes"
    $tabs.TabPages.Add($processesPage) | Out-Null

    $networkPage = New-Object System.Windows.Forms.TabPage
    $networkPage.Text = "Network"
    $tabs.TabPages.Add($networkPage) | Out-Null

    $remotePage = New-Object System.Windows.Forms.TabPage
    $remotePage.Text = "Remote"
    $tabs.TabPages.Add($remotePage) | Out-Null

    $psExecPage = New-Object System.Windows.Forms.TabPage
    $psExecPage.Text = "PsExec"
    $tabs.TabPages.Add($psExecPage) | Out-Null

    $infrastructurePage = New-Object System.Windows.Forms.TabPage
    $infrastructurePage.Text = "Services"
    $tabs.TabPages.Add($infrastructurePage) | Out-Null

    $repairPage = New-Object System.Windows.Forms.TabPage
    $repairPage.Text = "Repair"
    $tabs.TabPages.Add($repairPage) | Out-Null

    $directoryPage = New-Object System.Windows.Forms.TabPage
    $directoryPage.Text = "Directory"
    $tabs.TabPages.Add($directoryPage) | Out-Null

    $securityPage = New-Object System.Windows.Forms.TabPage
    $securityPage.Text = "Security"
    $tabs.TabPages.Add($securityPage) | Out-Null

    $wifiPage = New-Object System.Windows.Forms.TabPage
    $wifiPage.Text = "Wi-Fi"
    $tabs.TabPages.Add($wifiPage) | Out-Null

    $printPage = New-Object System.Windows.Forms.TabPage
    $printPage.Text = "Print"
    $tabs.TabPages.Add($printPage) | Out-Null

    $filesPage = New-Object System.Windows.Forms.TabPage
    $filesPage.Text = "Files"
    $tabs.TabPages.Add($filesPage) | Out-Null

    $discoveryPage = New-Object System.Windows.Forms.TabPage
    $discoveryPage.Text = "Discovery"
    $tabs.TabPages.Add($discoveryPage) | Out-Null

    $robocopyPage = New-Object System.Windows.Forms.TabPage
    $robocopyPage.Text = "Robocopy"
    $tabs.TabPages.Add($robocopyPage) | Out-Null

    $softwarePage = New-Object System.Windows.Forms.TabPage
    $softwarePage.Text = "Software"
    $tabs.TabPages.Add($softwarePage) | Out-Null

    $cleanupPage = New-Object System.Windows.Forms.TabPage
    $cleanupPage.Text = "Clean Up"
    $tabs.TabPages.Add($cleanupPage) | Out-Null

    $customPage = New-Object System.Windows.Forms.TabPage
    $customPage.Text = "Apps"
    $tabs.TabPages.Add($customPage) | Out-Null

    $chocolateyPage = New-Object System.Windows.Forms.TabPage
    $chocolateyPage.Text = "Choco"
    $tabs.TabPages.Add($chocolateyPage) | Out-Null

    $sysinternalsPage = New-Object System.Windows.Forms.TabPage
    $sysinternalsPage.Text = "Sysinternals"
    $tabs.TabPages.Add($sysinternalsPage) | Out-Null

    $fingerprintPage = New-Object System.Windows.Forms.TabPage
    $fingerprintPage.Text = "Computer Info"
    $tabs.TabPages.Add($fingerprintPage) | Out-Null

    $reportsPage = New-Object System.Windows.Forms.TabPage
    $reportsPage.Text = "Reports"
    $tabs.TabPages.Add($reportsPage) | Out-Null

    $settingsPage = New-Object System.Windows.Forms.TabPage
    $settingsPage.Text = "Settings"
    $tabs.TabPages.Add($settingsPage) | Out-Null

    $liveLogPage = New-Object System.Windows.Forms.TabPage
    $liveLogPage.Text = "Live Log"
    $tabs.TabPages.Add($liveLogPage) | Out-Null

    $availableTabs = @()
    foreach($page in $tabs.TabPages){
        $availableTabs += [string]$page.Text
    }
    $orderedTabs = Get-GUIOrderedTabNames -AvailableTabs $availableTabs
    Apply-GUITabOrder -Tabs $tabs -Order $orderedTabs

    foreach($page in $tabs.TabPages){
        $page.UseVisualStyleBackColor = $false
        $page.BackColor = $script:GUITheme.Page
    }

    Add-GUIStaticTabStrip -Strip $tabStrip -Tabs $tabs
    $tabs.Add_SelectedIndexChanged({
        Build-GUITabIfNeeded -Page $script:MainTabs.SelectedTab
        Update-GUIStaticTabStripSelection
    })

    $script:RunButton = New-GUIButton "Run Quick Diagnosis" { Start-GUIQuickDiagnosis }

    $consoleButton = New-Object System.Windows.Forms.Button
    $consoleButton.Text = "Open Console"
    $consoleButton.Width = 130
    $consoleButton.Height = 32
    $consoleButton.Add_Click({ Start-ToolkitConsole })

    $status = New-Object System.Windows.Forms.StatusStrip
    $script:StatusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
    $StatusLabel.Text = "Ready"
    $status.Items.Add($StatusLabel) | Out-Null
    $root.Controls.Add($status,0,3)

    if(!$script:ToolTip){
        $script:ToolTip = New-Object System.Windows.Forms.ToolTip
        $script:ToolTip.AutoPopDelay = 12000
        $script:ToolTip.InitialDelay = 400
        $script:ToolTip.ReshowDelay = 150
        $script:ToolTip.ShowAlways = $true
    }

    Register-GUITabBuilder -Page $quickPage -Builder { param($Page) Build-QuickTriagePage -Page $Page }
    Register-GUITabBuilder -Page $analyzePage -Builder { param($Page) Build-WindowsToolsPage -Page $Page }
    Register-GUITabBuilder -Page $windowsUpdatePage -Builder { param($Page) Build-WindowsUpdatePage -Page $Page }
    Register-GUITabBuilder -Page $hardwarePage -Builder { param($Page) Build-HardwareToolsPage -Page $Page }
    Register-GUITabBuilder -Page $crashPage -Builder { param($Page) Build-CrashToolsPage -Page $Page }
    Register-GUITabBuilder -Page $processesPage -Builder { param($Page) Build-ProcessesToolsPage -Page $Page }
    Register-GUITabBuilder -Page $securityPage -Builder { param($Page) Build-SecurityToolsPage -Page $Page }
    Register-GUITabBuilder -Page $networkPage -Builder { param($Page) Build-NetworkToolsPage -Page $Page }
    Register-GUITabBuilder -Page $remotePage -Builder { param($Page) Build-RemoteToolsPage -Page $Page }
    Register-GUITabBuilder -Page $psExecPage -Builder { param($Page) Build-PsExecPage -Page $Page }
    Register-GUITabBuilder -Page $discoveryPage -Builder { param($Page) Build-DiscoveryToolsPage -Page $Page }
    Register-GUITabBuilder -Page $infrastructurePage -Builder { param($Page) Build-InfrastructureToolsPage -Page $Page }
    Register-GUITabBuilder -Page $repairPage -Builder { param($Page) Build-RepairToolsPage -Page $Page }
    Register-GUITabBuilder -Page $directoryPage -Builder { param($Page) Build-DirectoryToolsPage -Page $Page }
    Register-GUITabBuilder -Page $wifiPage -Builder { param($Page) Build-WiFiToolsPage -Page $Page }
    Register-GUITabBuilder -Page $printPage -Builder { param($Page) Build-PrintToolsPage -Page $Page }
    Register-GUITabBuilder -Page $filesPage -Builder { param($Page) Build-FileToolsPage -Page $Page }
    Register-GUITabBuilder -Page $robocopyPage -Builder { param($Page) Build-RobocopyPage -Page $Page }
    Register-GUITabBuilder -Page $softwarePage -Builder { param($Page) Build-SoftwareToolsPage -Page $Page }
    Register-GUITabBuilder -Page $cleanupPage -Builder { param($Page) Build-CleanupToolsPage -Page $Page }
    Register-GUITabBuilder -Page $customPage -Builder { param($Page) Build-CustomToolsPage -Page $Page }
    Register-GUITabBuilder -Page $chocolateyPage -Builder { param($Page) Build-ChocolateyPage -Page $Page }
    Register-GUITabBuilder -Page $sysinternalsPage -Builder { param($Page) Build-SysinternalsPage -Page $Page -Title "Sysinternals Tools" -Categories @("Process And Startup","System Inspection","Network","PsTools","Disk And File","Security And Registry","Active Directory","Stress And Caution","Other") -Columns 3 }
    Register-GUITabBuilder -Page $fingerprintPage -Builder { param($Page) Build-FingerprintPage -Page $Page; Refresh-Fingerprints -Quiet }
    Register-GUITabBuilder -Page $reportsPage -Builder { param($Page) Build-ReportsPage -Page $Page }
    Register-GUITabBuilder -Page $settingsPage -Builder { param($Page) Build-SettingsPage -Page $Page }
    Register-GUITabBuilder -Page $liveLogPage -Builder { param($Page) Build-LiveLogPage -Page $Page }

    $startupTab = if($script:GuiSettings -and $script:GuiSettings.startupTab){[string]$script:GuiSettings.startupTab}else{"Quick Diagnosis"}
    $startupPage = $script:MainTabs.TabPages | Where-Object { $_.Text -eq $startupTab } | Select-Object -First 1
    if(!$startupPage){
        $startupPage = $quickPage
    }

    $script:MainTabs.SelectedTab = $startupPage
    Build-GUITabIfNeeded -Page $startupPage
    Update-GUIStaticTabStripSelection
}

Register-GUIExceptionHandlers
Build-Form
Add-GUILog "Loaded GUI launcher from $GuiRoot"
Add-GUILog "Using shared toolkit from $SharedToolkitRoot"
Add-GUILog ("Registered commands: {0}" -f $script:Commands.Count)

if($SmokeTest){
    Write-Host "Network Toolkit GUI loaded successfully."
    Write-Host "Commands:" $script:Commands.Count
    return
}

if($ButtonSmokeTest){
    if($script:Commands.Count -lt 1){
        Write-Host "No commands loaded."
        exit 1
    }

    if(!$script:QuickRunButton){
        Write-Host "Quick Diagnosis button missing."
        exit 1
    }

    foreach($tab in $script:MainTabs.TabPages){
        Build-GUITabIfNeeded -Page $tab
    }

    if(!$script:RobocopySourceBox -or !$script:RobocopyDestinationBox){
        Write-Host "Robocopy tab missing."
        exit 1
    }

    if(!$script:ChocoGrid -or !$script:ChocoSearchBox){
        Write-Host "Chocolatey tab missing."
        exit 1
    }

    $knownGuiActions = @(
        "Start-GUIDismSfcRepairPath",
        "Start-GUIPrintQueueMaintenance",
        "Start-GUIFirefoxPortable",
        "Start-GUIBulkUninstaller",
        "Start-GUILaunchRDP",
        "Start-GUIMinidumpCollector",
        "Start-GUIGPResultReport",
        "Start-GUIReliabilityMonitor",
        "Start-GUIPsExecHelper",
        "Open-GUIOutputsFolder",
        "Open-GUITempOutputsFolder",
        "Open-GUIDataFolder",
        "Open-GUILogsFolder",
        "Open-GUIToolkitFolder"
    )

    $unknownActions = @(
        Get-CSIToolCatalog |
            Where-Object { $_.Action -and $knownGuiActions -notcontains $_.Action } |
            Select-Object -ExpandProperty Action -Unique
    )

    if($unknownActions.Count -gt 0){
        Write-Host ("Unknown GUI catalog actions: {0}" -f ($unknownActions -join ", "))
        exit 1
    }

    foreach($tabName in @("Quick Diagnosis","Analyze","Windows Update","Hardware","Crash","Processes","Network","Remote","PsExec","Services","Repair","Directory","Security","Wi-Fi","Print","Files","Discovery","Robocopy","Software","Clean Up","Apps","Choco","Sysinternals","Computer Info","Reports","Settings","Live Log")){
        $tab = $script:MainTabs.TabPages | Where-Object {$_.Text -eq $tabName} | Select-Object -First 1

        if(!$tab){
            Write-Host "Tab missing: $tabName"
            exit 1
        }

        $pending = New-Object System.Collections.ArrayList
        [void]$pending.Add($tab)
        $buttons = @()

        while($pending.Count -gt 0){
            $current = $pending[0]
            $pending.RemoveAt(0)

            if($current -is [System.Windows.Forms.Button]){
                $buttons += $current
            }

            foreach($child in $current.Controls){
                [void]$pending.Add($child)
            }
        }

        if($buttons.Count -lt 1){
            Write-Host "No buttons found on tab: $tabName"
            exit 1
        }
    }

    $script:RobocopySourceBox.Text = "C:\Source Folder"
    $script:RobocopyDestinationBox.Text = "D:\Destination Folder"
    $plan = Update-GUIRobocopyCommand

    if(!$plan -or $plan.Command -notmatch "robocopy.exe"){
        Write-Host "Robocopy builder smoke test failed."
        exit 1
    }

    Write-Host "Button smoke test completed."
    Write-Host "Quick tab: OK"
    Write-Host "Robocopy:" $plan.Command
    Write-Host "Software tab: OK"
    return
}

[void]$Form.ShowDialog()
