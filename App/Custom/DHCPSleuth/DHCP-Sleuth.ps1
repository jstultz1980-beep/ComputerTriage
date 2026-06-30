# DHCP-Sleuth.ps1
# DHCP Sleuth - Monitor / Probe / Lab DHCP Server
# Version: 1.0.0
# Author/Maintainer: Josh Stultz <josh@jstultz.net>
# Run as Administrator.
# Server mode is LAB USE ONLY. Monitor/probe modes are passive or limited testing.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

$script:Ui = @{
    App       = [Drawing.Color]::FromArgb(18, 26, 45)
    Header    = [Drawing.Color]::FromArgb(25, 35, 58)
    Card      = [Drawing.Color]::FromArgb(33, 46, 76)
    Input     = [Drawing.Color]::FromArgb(19, 29, 51)
    Button    = [Drawing.Color]::FromArgb(48, 67, 108)
    ButtonHot = [Drawing.Color]::FromArgb(67, 96, 148)
    Accent    = [Drawing.Color]::FromArgb(122, 181, 255)
    Text      = [Drawing.Color]::FromArgb(239, 244, 255)
    Muted     = [Drawing.Color]::FromArgb(166, 183, 211)
}
$script:TabFont = New-Object Drawing.Font("Segoe UI Semibold", 9)
$script:ThemeButtons = @()
$script:StatusBulbs = @{}
$script:ApplyingCidr = $false
$script:ScriptRoot = if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) { (Get-Location).Path } else { $PSScriptRoot }
$script:SettingsPath = Join-Path $script:ScriptRoot "DHCP-Sleuth.settings.json"
$script:MagnifierAssetPath = Join-Path $script:ScriptRoot "assets\dhcp-sleuth-magnifier.png"
$script:AppName = "DHCP Sleuth"
$script:AppVersion = "1.0.0"
$script:AppMaintainer = "Josh Stultz"
$script:AppContact = "josh@jstultz.net"
$script:SelectedTheme = "Nebula"
$script:DefaultWindowSize = [Drawing.Size]::new(1120, 740)
$script:Themes = @{
    "Nebula" = $script:Ui
    "Midnight" = @{
        App=[Drawing.Color]::FromArgb(10,18,37); Header=[Drawing.Color]::FromArgb(13,29,55); Card=[Drawing.Color]::FromArgb(19,42,75); Input=[Drawing.Color]::FromArgb(7,15,31); Button=[Drawing.Color]::FromArgb(25,58,105); ButtonHot=[Drawing.Color]::FromArgb(37,88,151); Accent=[Drawing.Color]::FromArgb(65,203,255); Text=[Drawing.Color]::FromArgb(232,248,255); Muted=[Drawing.Color]::FromArgb(151,193,219)
    }
    "Amethyst" = @{
        App=[Drawing.Color]::FromArgb(27,18,43); Header=[Drawing.Color]::FromArgb(43,27,68); Card=[Drawing.Color]::FromArgb(59,39,90); Input=[Drawing.Color]::FromArgb(22,14,37); Button=[Drawing.Color]::FromArgb(83,55,123); ButtonHot=[Drawing.Color]::FromArgb(113,75,165); Accent=[Drawing.Color]::FromArgb(211,142,255); Text=[Drawing.Color]::FromArgb(250,241,255); Muted=[Drawing.Color]::FromArgb(210,183,231)
    }
    "Ember" = @{
        App=[Drawing.Color]::FromArgb(37,20,18); Header=[Drawing.Color]::FromArgb(59,29,23); Card=[Drawing.Color]::FromArgb(78,40,30); Input=[Drawing.Color]::FromArgb(30,16,15); Button=[Drawing.Color]::FromArgb(113,55,39); ButtonHot=[Drawing.Color]::FromArgb(157,75,48); Accent=[Drawing.Color]::FromArgb(255,174,88); Text=[Drawing.Color]::FromArgb(255,245,235); Muted=[Drawing.Color]::FromArgb(228,190,165)
    }
    "Evergreen" = @{
        App=[Drawing.Color]::FromArgb(13,31,29); Header=[Drawing.Color]::FromArgb(18,48,43); Card=[Drawing.Color]::FromArgb(27,65,57); Input=[Drawing.Color]::FromArgb(9,24,22); Button=[Drawing.Color]::FromArgb(37,91,78); ButtonHot=[Drawing.Color]::FromArgb(51,125,105); Accent=[Drawing.Color]::FromArgb(110,235,191); Text=[Drawing.Color]::FromArgb(235,255,247); Muted=[Drawing.Color]::FromArgb(169,211,196)
    }
    "Carbon" = @{
        App=[Drawing.Color]::FromArgb(27,29,33); Header=[Drawing.Color]::FromArgb(39,42,48); Card=[Drawing.Color]::FromArgb(56,59,66); Input=[Drawing.Color]::FromArgb(20,22,26); Button=[Drawing.Color]::FromArgb(76,80,89); ButtonHot=[Drawing.Color]::FromArgb(103,108,119); Accent=[Drawing.Color]::FromArgb(244,196,77); Text=[Drawing.Color]::FromArgb(247,248,250); Muted=[Drawing.Color]::FromArgb(195,200,208)
    }
    "Arctic" = @{
        App=[Drawing.Color]::FromArgb(222,232,242); Header=[Drawing.Color]::FromArgb(237,245,252); Card=[Drawing.Color]::FromArgb(201,220,237); Input=[Drawing.Color]::FromArgb(248,252,255); Button=[Drawing.Color]::FromArgb(177,207,233); ButtonHot=[Drawing.Color]::FromArgb(145,190,226); Accent=[Drawing.Color]::FromArgb(18,112,186); Text=[Drawing.Color]::FromArgb(24,48,74); Muted=[Drawing.Color]::FromArgb(70,98,125)
    }
    "Oceanic" = @{
        App=[Drawing.Color]::FromArgb(8,31,48); Header=[Drawing.Color]::FromArgb(10,49,72); Card=[Drawing.Color]::FromArgb(16,70,94); Input=[Drawing.Color]::FromArgb(6,24,39); Button=[Drawing.Color]::FromArgb(20,100,130); ButtonHot=[Drawing.Color]::FromArgb(29,137,171); Accent=[Drawing.Color]::FromArgb(92,222,240); Text=[Drawing.Color]::FromArgb(232,253,255); Muted=[Drawing.Color]::FromArgb(161,211,220)
    }
    "Rose Quartz" = @{
        App=[Drawing.Color]::FromArgb(47,30,45); Header=[Drawing.Color]::FromArgb(70,43,65); Card=[Drawing.Color]::FromArgb(92,56,82); Input=[Drawing.Color]::FromArgb(37,23,36); Button=[Drawing.Color]::FromArgb(132,76,112); ButtonHot=[Drawing.Color]::FromArgb(172,98,142); Accent=[Drawing.Color]::FromArgb(255,166,205); Text=[Drawing.Color]::FromArgb(255,242,250); Muted=[Drawing.Color]::FromArgb(229,190,211)
    }
    "Terminal" = @{
        App=[Drawing.Color]::FromArgb(8,19,14); Header=[Drawing.Color]::FromArgb(12,34,23); Card=[Drawing.Color]::FromArgb(18,51,33); Input=[Drawing.Color]::FromArgb(5,14,10); Button=[Drawing.Color]::FromArgb(25,76,45); ButtonHot=[Drawing.Color]::FromArgb(36,111,60); Accent=[Drawing.Color]::FromArgb(104,255,149); Text=[Drawing.Color]::FromArgb(225,255,232); Muted=[Drawing.Color]::FromArgb(162,211,174)
    }
}

$script:Mode = "Stopped"
$script:StopDhcp = $false
$script:Udp = $null
$script:Leases = @{}
$script:History = New-Object System.Collections.ArrayList
$script:Servers = @{}
$script:Stats = @{
    DISCOVER = 0
    OFFER    = 0
    REQUEST  = 0
    ACK      = 0
    NAK      = 0
    DECLINE  = 0
    RELEASE  = 0
    INFORM   = 0
    OTHER    = 0
}
$script:NextInt = 0
$script:StartInt = 0
$script:EndInt = 0
$script:SelectedPacketDetail = ""
$script:OUI = @{
    "00-15-5D" = "Microsoft Hyper-V"
    "00-1A-11" = "Google"
    "00-1B-63" = "Apple"
    "00-1C-B3" = "Apple"
    "00-25-00" = "Apple"
    "28-CF-E9" = "Apple"
    "3C-22-FB" = "Apple"
    "F0-18-98" = "Apple"
    "00-50-56" = "VMware"
    "00-0C-29" = "VMware"
    "00-05-69" = "VMware"
    "08-00-27" = "Oracle VirtualBox"
    "00-1E-4F" = "Dell"
    "B8-CA-3A" = "Dell"
    "18-66-DA" = "Dell"
    "00-25-90" = "Supermicro"
    "00-D0-B7" = "Intel"
    "3C-FD-FE" = "Intel"
    "00-1B-21" = "Intel"
    "00-1D-D8" = "Microsoft"
    "00-0F-B5" = "Cisco"
    "00-1B-54" = "Cisco"
    "00-23-04" = "Cisco"
    "70-CA-9B" = "Cisco"
    "00-11-32" = "Synology"
    "24-5E-BE" = "QNAP"
    "B8-27-EB" = "Raspberry Pi"
    "DC-A6-32" = "Raspberry Pi"
    "E4-5F-01" = "Raspberry Pi"
}

function Convert-IPToInt {
    param([string]$IP)
    $b = [System.Net.IPAddress]::Parse($IP).GetAddressBytes()
    [array]::Reverse($b)
    [BitConverter]::ToUInt32($b, 0)
}

function Convert-IntToIP {
    param([uint32]$Int)
    $b = [BitConverter]::GetBytes($Int)
    [array]::Reverse($b)
    [System.Net.IPAddress]::new($b).ToString()
}

function Get-CidrPrefix {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) { return "" }
    if ($Value -match '/(\d{1,2})(?:\D|$)') { return "/$($matches[1])" }
    return ""
}

function Get-BuilderCidr {
    if ($null -eq $textboxes) { return "" }
    $networkIP = $textboxes["IP Address"].Text.Trim()
    $prefix = Get-CidrPrefix $textboxes["CIDR"].Text
    if ([string]::IsNullOrWhiteSpace($networkIP) -or [string]::IsNullOrWhiteSpace($prefix)) { return "" }
    return "$networkIP$prefix"
}

function Get-CidrDefaults {
    param([string]$Cidr)

    $parts = $Cidr.Trim() -split "/", 2
    if ($parts.Count -ne 2) { throw "CIDR must use IPv4/prefix notation, for example 192.168.50.0/24." }
    $address = [System.Net.IPAddress]::Parse($parts[0].Trim())
    if ($address.AddressFamily -ne [System.Net.Sockets.AddressFamily]::InterNetwork) { throw "CIDR must contain an IPv4 address." }
    [int]$prefix = 0
    if (-not [int]::TryParse($parts[1].Trim(), [ref]$prefix) -or $prefix -lt 0 -or $prefix -gt 30) {
        throw "CIDR prefix must be between /0 and /30."
    }

    $maskBytes = New-Object byte[] 4
    for ($i = 0; $i -lt 4; $i++) {
        $bits = $prefix - ($i * 8)
        if ($bits -ge 8) { $maskBytes[$i] = 255 }
        elseif ($bits -gt 0) { $maskBytes[$i] = [byte](256 - [Math]::Pow(2, 8 - $bits)) }
        else { $maskBytes[$i] = 0 }
    }

    $addressBytes = $address.GetAddressBytes()
    $networkBytes = New-Object byte[] 4
    $broadcastBytes = New-Object byte[] 4
    for ($i = 0; $i -lt 4; $i++) {
        $networkBytes[$i] = $addressBytes[$i] -band $maskBytes[$i]
        $broadcastBytes[$i] = $networkBytes[$i] -bor (255 -bxor $maskBytes[$i])
    }

    $network = ([System.Net.IPAddress]::new($networkBytes)).ToString()
    $mask = ([System.Net.IPAddress]::new($maskBytes)).ToString()
    [uint32]$networkInt = Convert-IPToInt $network
    [uint32]$broadcastInt = Convert-IPToInt (([System.Net.IPAddress]::new($broadcastBytes)).ToString())
    [uint64]$usable = ([uint64]$broadcastInt - [uint64]$networkInt) - 1
    if ($usable -lt 2) { throw "CIDR must provide at least two usable host addresses." }

    [uint32]$serverInt = [uint32]($networkInt + 1)
    [uint32]$lastHostInt = [uint32]($broadcastInt - 1)
    [uint64]$leaseStartOffset = if ($usable -ge 151) { 100 } elseif ($usable -gt 51) { $usable - 50 } else { 2 }
    [uint32]$leaseStartInt = [uint32]([uint64]$networkInt + $leaseStartOffset)
    if ($leaseStartInt -gt $lastHostInt) { $leaseStartInt = $lastHostInt }
    [uint32]$leaseEndInt = [uint32][Math]::Min([uint64]$lastHostInt, ([uint64]$leaseStartInt + 50))

    return [pscustomobject]@{
        Network    = "$network/$prefix"
        SubnetMask = $mask
        ServerIP   = Convert-IntToIP $serverInt
        Router     = Convert-IntToIP $serverInt
        DnsServer  = Convert-IntToIP $serverInt
        LeaseStart = Convert-IntToIP $leaseStartInt
        LeaseEnd   = Convert-IntToIP $leaseEndInt
    }
}

function Update-CidrChoices {
    if ($null -eq $textboxes -or -not ($textboxes["CIDR"] -is [Windows.Forms.ComboBox])) { return }

    $picker = $textboxes["CIDR"]
    $picker.Items.Clear()
    foreach ($prefix in @(8, 16, 20, 22, 23, 24, 25, 26, 27, 28, 29, 30)) {
        try {
            $defaults = Get-CidrDefaults "0.0.0.0/$prefix"
            [void]$picker.Items.Add("/$prefix  |  $($defaults.SubnetMask)")
        } catch {}
    }
}

function Apply-CidrDefaults {
    $cidr = Get-BuilderCidr
    if ($script:ApplyingCidr -or [string]::IsNullOrWhiteSpace($cidr)) { return }
    try {
        $script:ApplyingCidr = $true
        $defaults = Get-CidrDefaults $cidr
        $textboxes["CIDR"].Text = "$(Get-CidrPrefix $defaults.Network)  |  $($defaults.SubnetMask)"
        $textboxes["Server IP"].Text = $defaults.ServerIP
        $textboxes["Subnet Mask"].Text = $defaults.SubnetMask
        $textboxes["Router/Gateway"].Text = $defaults.Router
        $textboxes["DNS Server"].Text = $defaults.DnsServer
        $textboxes["Lease Start"].Text = $defaults.LeaseStart
        $textboxes["Lease End"].Text = $defaults.LeaseEnd
    } catch {
        # A CIDR is often incomplete while it is being typed; retain the user's
        # existing values until it becomes a valid network definition.
    } finally {
        $script:ApplyingCidr = $false
    }
}

function IPBytes {
    param([string]$IP)
    [System.Net.IPAddress]::Parse($IP).GetAddressBytes()
}

function Add-Option {
    param([byte[]]$Packet, [byte]$Code, [byte[]]$Data)
    return $Packet + $Code + [byte]$Data.Length + $Data
}

function Set-RoundedCorners {
    param([System.Windows.Forms.Control]$Control, [int]$Radius = 10)

    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $diameter = $Radius * 2
    $bounds = $Control.ClientRectangle
    $path.AddArc($bounds.X, $bounds.Y, $diameter, $diameter, 180, 90)
    $path.AddArc($bounds.Right - $diameter, $bounds.Y, $diameter, $diameter, 270, 90)
    $path.AddArc($bounds.Right - $diameter, $bounds.Bottom - $diameter, $diameter, $diameter, 0, 90)
    $path.AddArc($bounds.X, $bounds.Bottom - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()
    $Control.Region = New-Object System.Drawing.Region($path)
    $path.Dispose()
}

function Write-Log {
    param([string]$Text)
    if ($null -ne $txtConsole) {
        $txtConsole.AppendText("$(Get-Date -Format 'HH:mm:ss')  $Text`r`n")
        $txtConsole.SelectionStart = $txtConsole.Text.Length
        $txtConsole.ScrollToCaret()
    }
}

function Set-AppStatus {
    param([string]$Status)
    $lblStatus.Text = $Status
    $activeBulb = "Stopped"
    switch ($Status) {
        "STOPPED" { $activeBulb = "Stopped"; $lblStatus.ForeColor = [Drawing.Color]::FromArgb(255, 166, 181) }
        "MONITOR ONLY" { $activeBulb = "Monitor"; $lblStatus.ForeColor = [Drawing.Color]::FromArgb(255, 212, 128) }
        "SERVER ACTIVE" { $activeBulb = "Server"; $lblStatus.ForeColor = [Drawing.Color]::FromArgb(137, 238, 190) }
        default { $lblStatus.ForeColor = $script:Ui.Muted }
    }
    foreach ($name in $script:StatusBulbs.Keys) {
        $bulb = $script:StatusBulbs[$name]
        $bulb.Tag.Active = ($name -eq $activeBulb)
        $bulb.BackColor = $script:Ui.Header
        $bulb.Invalidate()
    }
}

function New-StatusBulb {
    param([Drawing.Color]$Color)

    $bulb = New-Object Windows.Forms.Panel
    $bulb.Size = New-Object Drawing.Size(24,24)
    $bulb.BackColor = $script:Ui.Header
    $bulb.Tag = [pscustomobject]@{ Color = $Color; Active = $false }
    $bulb.Add_Paint({
        param($sender, $e)
        $e.Graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $base = $sender.Tag.Color
        $active = $sender.Tag.Active
        $bounds = New-Object Drawing.Rectangle(4,4,16,16)
        if ($active) {
            foreach ($size in @(23,20,18)) {
                $alpha = if ($size -eq 23) { 28 } elseif ($size -eq 20) { 48 } else { 70 }
                $glow = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb($alpha, $base))
                $offset = [int](($sender.Width - $size) / 2)
                $e.Graphics.FillEllipse($glow, $offset, $offset, $size, $size)
                $glow.Dispose()
            }
        }
        $highlightAmount = if ($active) { 92 } else { 28 }
        $inner = [Drawing.Color]::FromArgb(
            255,
            [Math]::Min(255, $base.R + $highlightAmount),
            [Math]::Min(255, $base.G + $highlightAmount),
            [Math]::Min(255, $base.B + $highlightAmount)
        )
        $outer = if ($active) { $base } else { [Drawing.Color]::FromArgb(90, $base) }
        $lamp = [System.Drawing.Drawing2D.LinearGradientBrush]::new($bounds, $inner, $outer, 45.0)
        $e.Graphics.FillEllipse($lamp, $bounds)
        $lamp.Dispose()
        $rim = New-Object Drawing.Pen([Drawing.Color]::FromArgb(180, 10, 14, 23), 1)
        $e.Graphics.DrawEllipse($rim, $bounds)
        $rim.Dispose()
        if ($active) {
            $highlight = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(190, 255, 255, 255))
            $e.Graphics.FillEllipse($highlight, 8, 7, 5, 4)
            $highlight.Dispose()
        }
    })
    return $bulb
}

function Get-SavedSettings {
    if (-not (Test-Path -LiteralPath $script:SettingsPath)) { return [pscustomobject]@{} }
    try {
        return Get-Content -LiteralPath $script:SettingsPath -Raw | ConvertFrom-Json
    } catch {}
    return [pscustomobject]@{}
}

function Save-SleuthSettings {
    if ($null -eq $textboxes) { return }

    try {
        [ordered]@{
            Theme        = $script:SelectedTheme
            NetworkIP    = $textboxes["IP Address"].Text
            CidrPrefix   = Get-CidrPrefix $textboxes["CIDR"].Text
            CIDR         = Get-BuilderCidr
            ServerIP     = $textboxes["Server IP"].Text
            SubnetMask   = $textboxes["Subnet Mask"].Text
            Router       = $textboxes["Router/Gateway"].Text
            DnsServer    = $textboxes["DNS Server"].Text
            LeaseStart   = $textboxes["Lease Start"].Text
            LeaseEnd     = $textboxes["Lease End"].Text
            LeaseSeconds = $textboxes["Lease Seconds"].Text
            WindowWidth  = [Math]::Max($script:DefaultWindowSize.Width, $form.RestoreBounds.Width)
            WindowHeight = [Math]::Max($script:DefaultWindowSize.Height, $form.RestoreBounds.Height)
        } | ConvertTo-Json | Set-Content -LiteralPath $script:SettingsPath -Encoding UTF8
    } catch {
        Write-Log "Could not save settings: $($_.Exception.Message)"
    }
}

function Restore-DefaultWindowSize {
    $form.WindowState = [Windows.Forms.FormWindowState]::Normal
    $form.Size = $script:DefaultWindowSize
    $form.CenterToScreen()
    Update-ResponsiveLayout
    Save-SleuthSettings
}

function Set-SleuthTheme {
    param([string]$Name, [switch]$Persist)

    if (-not $script:Themes.ContainsKey($Name)) { return }
    $script:Ui = $script:Themes[$Name]
    $script:SelectedTheme = $Name

    $form.BackColor = $script:Ui.App
    $header.BackColor = $script:Ui.Header
    $leftPanel.BackColor = $script:Ui.Card
    $rightPanel.BackColor = $script:Ui.App
    $statsPanel.BackColor = $script:Ui.Card
    $tabDashboard.BackColor = $script:Ui.App
    $tabPackets.BackColor = $script:Ui.App
    $tabLeases.BackColor = $script:Ui.App
    $tabRogue.BackColor = $script:Ui.App
    $tabProbe.BackColor = $script:Ui.App
    $tabSettings.BackColor = $script:Ui.App

    $title.ForeColor = $script:Ui.Text
    $sub.ForeColor = $script:Ui.Muted
    $statusCaption.ForeColor = $script:Ui.Muted
    $configTitle.ForeColor = $script:Ui.Text
    $settingsTitle.ForeColor = $script:Ui.Text
    $settingsHint.ForeColor = $script:Ui.Muted
    $textureNote.ForeColor = $script:Ui.Muted
    $aboutTitle.ForeColor = $script:Ui.Text
    $aboutText.ForeColor = $script:Ui.Muted
    foreach ($control in $leftPanel.Controls) {
        if ($control -is [Windows.Forms.Label] -and $control -ne $configTitle) { $control.ForeColor = $script:Ui.Muted }
    }
    foreach ($label in $statLabels) { $label.ForeColor = $script:Ui.Accent }

    foreach ($textbox in @($textboxes.Values) + @($txtConsole, $txtDetail, $txtProbe)) {
        $textbox.BackColor = $script:Ui.Input
        $textbox.ForeColor = if ($textbox -eq $txtConsole) { $script:Ui.Accent } else { $script:Ui.Text }
    }
    foreach ($button in $script:ActionButtons) {
        $button.BackColor = $script:Ui.Button
        $button.ForeColor = if ($button -eq $btnDeleteLease) { [Drawing.Color]::FromArgb(255, 190, 196) } else { $script:Ui.Muted }
        $button.FlatAppearance.MouseOverBackColor = $script:Ui.ButtonHot
        $button.FlatAppearance.MouseDownBackColor = $script:Ui.Accent
    }
    foreach ($grid in @($gridPackets, $gridLeases, $gridServers)) {
        $grid.BackgroundColor = $script:Ui.Input
        $grid.DefaultCellStyle.BackColor = $script:Ui.Input
        $grid.DefaultCellStyle.ForeColor = $script:Ui.Text
        $grid.DefaultCellStyle.SelectionBackColor = $script:Ui.ButtonHot
        $grid.DefaultCellStyle.SelectionForeColor = $script:Ui.Text
        $grid.ColumnHeadersDefaultCellStyle.BackColor = $script:Ui.Card
        $grid.ColumnHeadersDefaultCellStyle.ForeColor = $script:Ui.Accent
        $grid.GridColor = $script:Ui.Button
    }
    foreach ($themeButton in $script:ThemeButtons) {
        $selected = ($themeButton.Tag -eq $Name)
        $themeButton.FlatAppearance.BorderSize = if ($selected) { 2 } else { 1 }
        $themeButton.FlatAppearance.BorderColor = if ($selected) { $script:Ui.Accent } else { $script:Ui.Button }
    }

    Set-AppStatus $lblStatus.Text.Trim()
    $header.Invalidate()
    $rightPanel.Invalidate()
    if ($Persist) { Save-SleuthSettings }
}

function Get-Vendor {
    param([string]$Mac)
    if ([string]::IsNullOrWhiteSpace($Mac) -or $Mac.Length -lt 8) { return "" }
    $prefix = $Mac.Substring(0,8).ToUpper()
    if ($script:OUI.ContainsKey($prefix)) { return $script:OUI[$prefix] }
    return ""
}

function Get-DhcpTypeName {
    param($Type)
    switch ($Type) {
        1 { "DISCOVER" }
        2 { "OFFER" }
        3 { "REQUEST" }
        4 { "DECLINE" }
        5 { "ACK" }
        6 { "NAK" }
        7 { "RELEASE" }
        8 { "INFORM" }
        default { "TYPE $Type" }
    }
}

function Update-StatsView {
    $lblDiscover.Text = "DISCOVER: $($script:Stats.DISCOVER)"
    $lblOffer.Text    = "OFFER: $($script:Stats.OFFER)"
    $lblRequest.Text  = "REQUEST: $($script:Stats.REQUEST)"
    $lblAck.Text      = "ACK: $($script:Stats.ACK)"
    $lblNak.Text      = "NAK: $($script:Stats.NAK)"
    $lblOther.Text    = "OTHER: $($script:Stats.OTHER)"
}

function Increment-Stat {
    param([string]$TypeName)
    if ($script:Stats.ContainsKey($TypeName)) {
        $script:Stats[$TypeName]++
    } else {
        $script:Stats.OTHER++
    }
    Update-StatsView
}

function Get-DhcpMsgType {
    param([byte[]]$Data)
    $i = 240
    while ($i -lt $Data.Length) {
        $opt = $Data[$i]
        if ($opt -eq 255) { break }
        if ($opt -eq 0) { $i++; continue }
        if (($i + 1) -ge $Data.Length) { break }
        $len = $Data[$i + 1]
        # A DHCP option is code + length + the declared number of value bytes.
        # Do not read a message-type value from a truncated option.
        if (($i + 2 + $len) -gt $Data.Length) { break }
        if ($opt -eq 53) { return $Data[$i + 2] }
        $i += 2 + $len
    }
    return $null
}

function Get-DhcpOptions {
    param([byte[]]$Data)
    $opts = @{}
    $i = 240
    while ($i -lt $Data.Length) {
        $code = $Data[$i]
        if ($code -eq 255) { break }
        if ($code -eq 0) { $i++; continue }
        if (($i + 1) -ge $Data.Length) { break }
        $len = $Data[$i + 1]
        if (($i + 2 + $len) -gt $Data.Length) { break }
        $value = $Data[($i + 2)..($i + 1 + $len)]
        $opts[[int]$code] = [byte[]]$value
        $i += 2 + $len
    }
    return $opts
}

function Convert-OptionIPList {
    param([byte[]]$Bytes)
    if (-not $Bytes -or $Bytes.Length -lt 4) { return "" }
    $ips = @()
    for ($i = 0; $i -lt $Bytes.Length; $i += 4) {
        if (($i + 3) -lt $Bytes.Length) {
            $ips += ([System.Net.IPAddress]::new($Bytes[$i..($i+3)])).ToString()
        }
    }
    return ($ips -join ", ")
}

function Convert-OptionString {
    param([byte[]]$Bytes)
    if (-not $Bytes) { return "" }
    return [Text.Encoding]::ASCII.GetString($Bytes)
}

function Convert-OptionUInt32 {
    param([byte[]]$Bytes)
    if (-not $Bytes -or $Bytes.Length -ne 4) { return "" }
    $b = [byte[]]$Bytes.Clone()
    [array]::Reverse($b)
    return [BitConverter]::ToUInt32($b, 0)
}

function Get-Option82Text {
    param([byte[]]$Bytes)
    if (-not $Bytes) { return "" }
    $parts = @()
    $i = 0
    while ($i -lt $Bytes.Length) {
        if (($i + 1) -ge $Bytes.Length) { break }
        $sub = $Bytes[$i]
        $len = $Bytes[$i + 1]
        if (($i + 2 + $len) -gt $Bytes.Length) { break }
        $value = $Bytes[($i+2)..($i+1+$len)]
        $hex = ($value | ForEach-Object { $_.ToString("X2") }) -join " "
        $ascii = ([Text.Encoding]::ASCII.GetString($value) -replace "[^\x20-\x7E]", ".")
        $name = switch ($sub) { 1 { "Circuit-ID" } 2 { "Remote-ID" } default { "SubOption-$sub" } }
        # Delimit the variable because a colon immediately following a variable
        # name is otherwise parsed as a scoped-variable reference (for example,
        # $global:Name).
        $parts += "${name}: $ascii [$hex]"
        $i += 2 + $len
    }
    return ($parts -join " | ")
}

function Parse-DhcpPacket {
    param([byte[]]$Data, [string]$RemoteAddress)

    $msgType = Get-DhcpMsgType $Data
    $typeName = Get-DhcpTypeName $msgType
    $opts = Get-DhcpOptions $Data

    $mac = ""
    if ($Data.Length -ge 34) {
        $macBytes = $Data[28..33]
        $mac = ($macBytes | ForEach-Object { $_.ToString("X2") }) -join "-"
    }

    $yiaddr = ""
    if ($Data.Length -ge 20) {
        $yiaddr = ([System.Net.IPAddress]::new($Data[16..19])).ToString()
    }

    $requestedIp = if ($opts.ContainsKey(50)) { Convert-OptionIPList $opts[50] } else { "" }
    $serverId    = if ($opts.ContainsKey(54)) { Convert-OptionIPList $opts[54] } else { "" }
    $hostName    = if ($opts.ContainsKey(12)) { Convert-OptionString $opts[12] } else { "" }
    $vendorClass = if ($opts.ContainsKey(60)) { Convert-OptionString $opts[60] } else { "" }
    $userClass   = if ($opts.ContainsKey(77)) { Convert-OptionString $opts[77] } else { "" }
    $mask        = if ($opts.ContainsKey(1))  { Convert-OptionIPList $opts[1] } else { "" }
    $router      = if ($opts.ContainsKey(3))  { Convert-OptionIPList $opts[3] } else { "" }
    $dns         = if ($opts.ContainsKey(6))  { Convert-OptionIPList $opts[6] } else { "" }
    $domain      = if ($opts.ContainsKey(15)) { Convert-OptionString $opts[15] } else { "" }
    $lease       = if ($opts.ContainsKey(51)) { Convert-OptionUInt32 $opts[51] } else { "" }
    $renew       = if ($opts.ContainsKey(58)) { Convert-OptionUInt32 $opts[58] } else { "" }
    $rebind      = if ($opts.ContainsKey(59)) { Convert-OptionUInt32 $opts[59] } else { "" }
    $opt82       = if ($opts.ContainsKey(82)) { Get-Option82Text $opts[82] } else { "" }

    $xid = ""
    if ($Data.Length -ge 8) {
        $xb = [byte[]]$Data[4..7]
        [array]::Reverse($xb)
        $xid = "0x{0:X8}" -f [BitConverter]::ToUInt32($xb,0)
    }

    return [pscustomobject]@{
        Time        = Get-Date
        Type        = $typeName
        TypeCode    = $msgType
        MAC         = $mac
        Vendor      = Get-Vendor $mac
        Hostname    = $hostName
        Remote      = $RemoteAddress
        OfferedIP   = $yiaddr
        RequestedIP = $requestedIp
        ServerID    = $serverId
        Mask        = $mask
        Router      = $router
        DNS         = $dns
        Domain      = $domain
        Lease       = $lease
        Renew       = $renew
        Rebind      = $rebind
        VendorClass = $vendorClass
        UserClass   = $userClass
        Option82    = $opt82
        XID         = $xid
    }
}

function Packet-DetailText {
    param($p)
    # WinForms TextBox expects CRLF.  A here-string preserves the script's line
    # endings, which can be LF-only and therefore renders as one wrapped line.
    $lines = @(
        "Time:          $($p.Time)"
        "Type:          $($p.Type)"
        "Transaction:   $($p.XID)"
        "Client MAC:    $($p.MAC)"
        "Vendor:        $($p.Vendor)"
        "Hostname:      $($p.Hostname)"
        "Remote:        $($p.Remote)"
        "Offered IP:    $($p.OfferedIP)"
        "Requested IP:  $($p.RequestedIP)"
        "Server ID:     $($p.ServerID)"
        "Subnet Mask:   $($p.Mask)"
        "Gateway:       $($p.Router)"
        "DNS Servers:   $($p.DNS)"
        "Domain:        $($p.Domain)"
        "Lease Time:    $($p.Lease)"
        "Renew Time:    $($p.Renew)"
        "Rebind Time:   $($p.Rebind)"
        "Vendor Class:  $($p.VendorClass)"
        "User Class:    $($p.UserClass)"
        "Option 82:     $($p.Option82)"
    )
    return ($lines -join "`r`n")
}

function Add-PacketRow {
    param([string]$Direction, $Packet)

    [void]$gridPackets.Rows.Insert(0,
        $Packet.Time.ToString("HH:mm:ss"),
        $Direction,
        $Packet.Type,
        $Packet.MAC,
        $Packet.Hostname,
        $Packet.RequestedIP,
        $Packet.OfferedIP,
        $Packet.ServerID,
        $Packet.Vendor
    )

    $gridPackets.Rows[0].Tag = Packet-DetailText $Packet

    while ($gridPackets.Rows.Count -gt 1000) {
        $gridPackets.Rows.RemoveAt($gridPackets.Rows.Count - 1)
    }
}

function Refresh-LeaseGrid {
    $gridLeases.Rows.Clear()
    foreach ($mac in $script:Leases.Keys | Sort-Object) {
        $lease = $script:Leases[$mac]
        [void]$gridLeases.Rows.Add(
            $mac,
            $lease.Hostname,
            $lease.IP,
            $lease.Status,
            $lease.Vendor,
            $lease.LastSeen.ToString("yyyy-MM-dd HH:mm:ss")
        )
    }
}

function Refresh-ServerGrid {
    $gridServers.Rows.Clear()
    foreach ($sid in $script:Servers.Keys | Sort-Object) {
        $s = $script:Servers[$sid]
        [void]$gridServers.Rows.Add(
            $sid,
            $s.Remote,
            $s.Offers,
            $s.Acks,
            $s.LastSeen.ToString("yyyy-MM-dd HH:mm:ss")
        )
    }
}

function Track-Server {
    param($Packet)
    $sid = if (-not [string]::IsNullOrWhiteSpace($Packet.ServerID)) { $Packet.ServerID } else { $Packet.Remote }
    if ([string]::IsNullOrWhiteSpace($sid)) { return }

    if (-not $script:Servers.ContainsKey($sid)) {
        $script:Servers[$sid] = [pscustomobject]@{
            Remote   = $Packet.Remote
            Offers   = 0
            Acks     = 0
            LastSeen = Get-Date
        }
    }

    if ($Packet.Type -eq "OFFER") { $script:Servers[$sid].Offers++ }
    if ($Packet.Type -eq "ACK")   { $script:Servers[$sid].Acks++ }
    $script:Servers[$sid].LastSeen = Get-Date
    Refresh-ServerGrid
}

function Track-ClientPacket {
    param($Packet)
    if ([string]::IsNullOrWhiteSpace($Packet.MAC)) { return }

    $ip = ""
    if ($Packet.Type -in @("OFFER","ACK") -and $Packet.OfferedIP -and $Packet.OfferedIP -ne "0.0.0.0") { $ip = $Packet.OfferedIP }
    elseif ($Packet.RequestedIP) { $ip = $Packet.RequestedIP }

    if (-not $script:Leases.ContainsKey($Packet.MAC)) {
        $script:Leases[$Packet.MAC] = [pscustomobject]@{
            IP       = $ip
            Hostname = $Packet.Hostname
            Status   = $Packet.Type
            Vendor   = $Packet.Vendor
            LastSeen = Get-Date
        }
    } else {
        if ($ip) { $script:Leases[$Packet.MAC].IP = $ip }
        if ($Packet.Hostname) { $script:Leases[$Packet.MAC].Hostname = $Packet.Hostname }
        if ($Packet.Vendor) { $script:Leases[$Packet.MAC].Vendor = $Packet.Vendor }
        $script:Leases[$Packet.MAC].Status = $Packet.Type
        $script:Leases[$Packet.MAC].LastSeen = Get-Date
    }

    [void]$script:History.Add([pscustomobject]@{
        Time = $Packet.Time
        MAC = $Packet.MAC
        Hostname = $Packet.Hostname
        IP = $ip
        Type = $Packet.Type
        ServerID = $Packet.ServerID
        Vendor = $Packet.Vendor
    })

    Refresh-LeaseGrid
}

function Get-NextLeaseIP {
    param([string]$Mac, [string]$Hostname)

    if ($script:Leases.ContainsKey($Mac) -and $script:Leases[$Mac].IP) {
        $script:Leases[$Mac].LastSeen = Get-Date
        return $script:Leases[$Mac].IP
    }

    $assignedIPs = @($script:Leases.Values | Where-Object { $_.IP } | ForEach-Object { $_.IP })
    $candidate = $null
    $address = [uint32]$script:NextInt
    $poolSize = ([uint64]$script:EndInt - [uint64]$script:StartInt) + 1
    for ([uint64]$attempt = 0; $attempt -lt $poolSize; $attempt++) {
        $possibleIP = Convert-IntToIP $address
        if ($possibleIP -notin $assignedIPs) {
            $candidate = $address
            break
        }
        if ($address -eq $script:EndInt) { $address = [uint32]$script:StartInt }
        else { $address = [uint32]($address + 1) }
    }
    if ($null -eq $candidate) { throw "Lease pool exhausted." }

    $ip = Convert-IntToIP $candidate
    $script:Leases[$Mac] = [pscustomobject]@{
        IP       = $ip
        Hostname = $Hostname
        Status   = "Offered"
        Vendor   = Get-Vendor $Mac
        LastSeen = Get-Date
    }

    if ($candidate -eq $script:EndInt) { $script:NextInt = [uint32]$script:StartInt }
    else { $script:NextInt = [uint32]($candidate + 1) }
    Refresh-LeaseGrid
    return $ip
}

function Update-LeaseStatus {
    param([string]$Mac, [string]$Status)
    if ($script:Leases.ContainsKey($Mac)) {
        $script:Leases[$Mac].Status = $Status
        $script:Leases[$Mac].LastSeen = Get-Date
        Refresh-LeaseGrid
    }
}

function Remove-SelectedLease {
    if ($gridLeases.SelectedRows.Count -eq 0) {
        Write-Log "Select a lease before deleting it."
        return
    }

    $mac = [string]$gridLeases.SelectedRows[0].Cells[0].Value
    if ([string]::IsNullOrWhiteSpace($mac) -or -not $script:Leases.ContainsKey($mac)) {
        Write-Log "The selected lease is no longer available."
        Refresh-LeaseGrid
        return
    }

    $lease = $script:Leases[$mac]
    $confirm = [Windows.Forms.MessageBox]::Show(
        "Delete the lease for $mac ($($lease.IP))?`r`n`r`nThe address will become available to the lab DHCP server.",
        "Delete DHCP Lease",
        "YesNo",
        "Warning"
    )
    if ($confirm -ne "Yes") { return }

    [void]$script:Leases.Remove($mac)
    Refresh-LeaseGrid
    Write-Log "Deleted lease for $mac ($($lease.IP)); address returned to the pool."
}

function Build-DhcpReply {
    param(
        [byte[]]$Request,
        [byte]$MsgType,
        [string]$OfferIP,
        [string]$ServerIP,
        [string]$SubnetMask,
        [string]$Router,
        [string]$DnsServer,
        [int]$LeaseSecs
    )

    $reply = New-Object byte[] 240
    $reply[0] = 2
    $reply[1] = $Request[1]
    $reply[2] = $Request[2]
    $reply[3] = 0

    [Array]::Copy($Request, 4,  $reply, 4,  4)
    [Array]::Copy($Request, 28, $reply, 28, 16)
    [Array]::Copy((IPBytes $OfferIP),  0, $reply, 16, 4)
    [Array]::Copy((IPBytes $ServerIP), 0, $reply, 20, 4)

    $reply[236] = 99
    $reply[237] = 130
    $reply[238] = 83
    $reply[239] = 99

    $packet = $reply
    $packet = Add-Option $packet 53 ([byte[]]@($MsgType))
    $packet = Add-Option $packet 54 (IPBytes $ServerIP)
    $packet = Add-Option $packet 1  (IPBytes $SubnetMask)
    $packet = Add-Option $packet 3  (IPBytes $Router)
    $packet = Add-Option $packet 6  (IPBytes $DnsServer)

    $lease = [BitConverter]::GetBytes([uint32]$LeaseSecs)
    [array]::Reverse($lease)
    $packet = Add-Option $packet 51 $lease

    $packet += 255
    return [byte[]]$packet
}

function Validate-Config {
    $cidr = Get-BuilderCidr
    $serverIP = $textboxes["Server IP"].Text
    $subnetMask = $textboxes["Subnet Mask"].Text
    $router = $textboxes["Router/Gateway"].Text
    $dns = $textboxes["DNS Server"].Text
    $start = $textboxes["Lease Start"].Text
    $end = $textboxes["Lease End"].Text
    $leaseSecs = [int]$textboxes["Lease Seconds"].Text

    if (-not [string]::IsNullOrWhiteSpace($cidr)) { [void](Get-CidrDefaults $cidr) }
    [void][System.Net.IPAddress]::Parse($serverIP)
    [void][System.Net.IPAddress]::Parse($subnetMask)
    [void][System.Net.IPAddress]::Parse($router)
    [void][System.Net.IPAddress]::Parse($dns)
    [void][System.Net.IPAddress]::Parse($start)
    [void][System.Net.IPAddress]::Parse($end)

    if ($leaseSecs -lt 60) { throw "Lease seconds must be at least 60." }

    $startInt = Convert-IPToInt $start
    $endInt = Convert-IPToInt $end
    if ($startInt -gt $endInt) { throw "Lease Start is higher than Lease End." }

    return @{
        ServerIP   = $serverIP
        CIDR       = $cidr
        SubnetMask = $subnetMask
        Router     = $router
        DnsServer  = $dns
        LeaseStart = $start
        LeaseEnd   = $end
        LeaseSecs  = $leaseSecs
        StartInt   = $startInt
        EndInt     = $endInt
    }
}

function Stop-Listener {
    $script:StopDhcp = $true

    if ($script:Udp) {
        try { $script:Udp.Close() } catch {}
        $script:Udp = $null
    }

    $script:Mode = "Stopped"
    $btnMonitor.Enabled = $true
    $btnStart.Enabled = $true
    $btnStop.Enabled = $false
    $btnTest.Enabled = $true
    $btnSendTest.Enabled = $true
    $btnDhcpProbe.Enabled = $true
    Set-AppStatus "STOPPED"
    Write-Log "Listener stopped."
}

function Start-Listener {
    param([ValidateSet("Monitor", "Server")][string]$Mode)

    try {
        if ($script:Udp) { Stop-Listener }

        $cfg = Validate-Config
        $script:StartInt = $cfg.StartInt
        $script:NextInt = $cfg.StartInt
        $script:EndInt = $cfg.EndInt
        $script:StopDhcp = $false
        $script:Mode = $Mode

        $script:Udp = New-Object System.Net.Sockets.UdpClient
        $script:Udp.Client.SetSocketOption(
            [System.Net.Sockets.SocketOptionLevel]::Socket,
            [System.Net.Sockets.SocketOptionName]::ReuseAddress,
            $true
        )
        $script:Udp.Client.Bind([System.Net.IPEndPoint]::new([System.Net.IPAddress]::Any, 67))
        $script:Udp.EnableBroadcast = $true

        $btnMonitor.Enabled = $false
        $btnStart.Enabled = $false
        $btnStop.Enabled = $true
        $btnTest.Enabled = $false

        if ($Mode -eq "Monitor") {
            Set-AppStatus "MONITOR ONLY"
            Write-Log "Monitor-only mode started on UDP 67. No DHCP replies will be sent."
        } else {
            Set-AppStatus "SERVER ACTIVE"
            Write-Log "DHCP lab server mode started on UDP 67."
            Write-Log "Server IP: $($cfg.ServerIP) | Pool: $($cfg.LeaseStart) - $($cfg.LeaseEnd)"
        }

        while (-not $script:StopDhcp) {
            if (-not $script:Udp) { break }

            if ($script:Udp.Available -eq 0) {
                [Windows.Forms.Application]::DoEvents()
                Start-Sleep -Milliseconds 100
                continue
            }

            $remote = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, 0)
            $data = $script:Udp.Receive([ref]$remote)

            if ($data.Length -lt 240) {
                Write-Log "Received non-DHCP UDP packet from $($remote.Address) Length=$($data.Length)"
                continue
            }

            $pkt = Parse-DhcpPacket -Data $data -RemoteAddress $remote.Address.ToString()
            Increment-Stat $pkt.Type
            Add-PacketRow "IN" $pkt
            Track-ClientPacket $pkt
            if ($pkt.Type -in @("OFFER","ACK","NAK")) { Track-Server $pkt }

            Write-Log "IN  $($pkt.Type) MAC=$($pkt.MAC) Host=$($pkt.Hostname) Req=$($pkt.RequestedIP) Offer=$($pkt.OfferedIP) Server=$($pkt.ServerID)"

            if ($script:Mode -eq "Monitor") {
                [Windows.Forms.Application]::DoEvents()
                continue
            }

            if ($script:Mode -eq "Server") {
                switch ($pkt.Type) {
                    "DISCOVER" {
                        $leaseIP = Get-NextLeaseIP $pkt.MAC $pkt.Hostname
                        Update-LeaseStatus $pkt.MAC "Offered"
                        $reply = Build-DhcpReply -Request $data -MsgType 2 -OfferIP $leaseIP -ServerIP $cfg.ServerIP -SubnetMask $cfg.SubnetMask -Router $cfg.Router -DnsServer $cfg.DnsServer -LeaseSecs $cfg.LeaseSecs
                        $script:Udp.Send($reply, $reply.Length, "255.255.255.255", 68) | Out-Null

                        $outPkt = [pscustomobject]@{
                            Time=Get-Date; Type="OFFER"; TypeCode=2; MAC=$pkt.MAC; Vendor=(Get-Vendor $pkt.MAC); Hostname=$pkt.Hostname; Remote="local"; OfferedIP=$leaseIP; RequestedIP=$pkt.RequestedIP; ServerID=$cfg.ServerIP; Mask=$cfg.SubnetMask; Router=$cfg.Router; DNS=$cfg.DnsServer; Domain=""; Lease=$cfg.LeaseSecs; Renew=""; Rebind=""; VendorClass=""; UserClass=""; Option82=""; XID=$pkt.XID
                        }
                        Increment-Stat "OFFER"
                        Add-PacketRow "OUT" $outPkt
                        Write-Log "OUT OFFER to $($pkt.MAC) for $leaseIP"
                    }
                    "REQUEST" {
                        $leaseIP = Get-NextLeaseIP $pkt.MAC $pkt.Hostname
                        Update-LeaseStatus $pkt.MAC "Acknowledged"
                        $reply = Build-DhcpReply -Request $data -MsgType 5 -OfferIP $leaseIP -ServerIP $cfg.ServerIP -SubnetMask $cfg.SubnetMask -Router $cfg.Router -DnsServer $cfg.DnsServer -LeaseSecs $cfg.LeaseSecs
                        $script:Udp.Send($reply, $reply.Length, "255.255.255.255", 68) | Out-Null

                        $outPkt = [pscustomobject]@{
                            Time=Get-Date; Type="ACK"; TypeCode=5; MAC=$pkt.MAC; Vendor=(Get-Vendor $pkt.MAC); Hostname=$pkt.Hostname; Remote="local"; OfferedIP=$leaseIP; RequestedIP=$pkt.RequestedIP; ServerID=$cfg.ServerIP; Mask=$cfg.SubnetMask; Router=$cfg.Router; DNS=$cfg.DnsServer; Domain=""; Lease=$cfg.LeaseSecs; Renew=""; Rebind=""; VendorClass=""; UserClass=""; Option82=""; XID=$pkt.XID
                        }
                        Increment-Stat "ACK"
                        Add-PacketRow "OUT" $outPkt
                        Write-Log "OUT ACK to $($pkt.MAC) for $leaseIP"
                    }
                    "RELEASE" {
                        Update-LeaseStatus $pkt.MAC "Released"
                    }
                }
            }

            [Windows.Forms.Application]::DoEvents()
        }
    } catch {
        Write-Log "ERROR: $($_.Exception.Message)"
        Write-Log "Run as Administrator. If UDP 67 is already bound, stop the local DHCP Server service or use another machine."
        Stop-Listener
    }
}

function Build-DhcpDiscover {
    $xid = Get-Random -Minimum 100000 -Maximum 999999999
    $mac = [byte[]](0x02, (Get-Random -Minimum 0 -Maximum 255), (Get-Random -Minimum 0 -Maximum 255), (Get-Random -Minimum 0 -Maximum 255), (Get-Random -Minimum 0 -Maximum 255), (Get-Random -Minimum 0 -Maximum 255))
    $packet = New-Object byte[] 240
    $packet[0] = 1
    $packet[1] = 1
    $packet[2] = 6
    $packet[3] = 0

    $xidBytes = [BitConverter]::GetBytes([uint32]$xid)
    [array]::Reverse($xidBytes)
    [Array]::Copy($xidBytes, 0, $packet, 4, 4)

    $packet[10] = 0x80
    $packet[11] = 0x00
    [Array]::Copy($mac, 0, $packet, 28, 6)

    $packet[236] = 99
    $packet[237] = 130
    $packet[238] = 83
    $packet[239] = 99

    $packet = Add-Option $packet 53 ([byte[]]@(1))
    $packet = Add-Option $packet 12 ([Text.Encoding]::ASCII.GetBytes("DHCP-SLEUTH-PROBE"))
    $packet = Add-Option $packet 55 ([byte[]]@(1,3,6,15,51,54,58,59,60,82))
    $packet += 255

    return @{
        Packet = [byte[]]$packet
        Xid = $xid
        Mac = (($mac | ForEach-Object { $_.ToString("X2") }) -join "-")
    }
}

function Test-NetworkDhcpServer {
    Write-Log "Testing network DHCP server with DHCP DISCOVER..."
    Write-Log "Probe uses UDP 68. If Windows DHCP Client owns the port, this may fail."

    $probe = $null
    try {
        $discover = Build-DhcpDiscover
        $probe = New-Object System.Net.Sockets.UdpClient
        $probe.Client.SetSocketOption([System.Net.Sockets.SocketOptionLevel]::Socket,[System.Net.Sockets.SocketOptionName]::ReuseAddress,$true)
        $probe.Client.Bind([System.Net.IPEndPoint]::new([System.Net.IPAddress]::Any, 68))
        $probe.EnableBroadcast = $true

        [void]$probe.Send($discover.Packet, $discover.Packet.Length, "255.255.255.255", 67)
        Write-Log "OUT DISCOVER probe as $($discover.Mac)"

        $deadline = (Get-Date).AddSeconds(8)
        $found = $false
        while ((Get-Date) -lt $deadline) {
            [Windows.Forms.Application]::DoEvents()
            if ($probe.Available -le 0) { Start-Sleep -Milliseconds 100; continue }

            $remote = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, 0)
            $data = $probe.Receive([ref]$remote)
            if ($data.Length -lt 240) { continue }

            $pkt = Parse-DhcpPacket -Data $data -RemoteAddress $remote.Address.ToString()
            Add-PacketRow "IN" $pkt
            Increment-Stat $pkt.Type
            if ($pkt.Type -in @("OFFER","ACK","NAK")) { Track-Server $pkt }

            if ($pkt.Type -eq "OFFER") {
                $txtProbe.Text = Packet-DetailText $pkt
                Write-Log "DHCP OFFER received from $($pkt.ServerID) offering $($pkt.OfferedIP)"
                $found = $true
                break
            }
        }
        if (-not $found) {
            $txtProbe.Text = "No DHCP OFFER received within timeout."
            Write-Log "No DHCP OFFER received within timeout."
        }
    } catch {
        Write-Log "DHCP probe failed: $($_.Exception.Message)"
        $txtProbe.Text = "DHCP probe failed:`r`n$($_.Exception.Message)`r`n`r`nRun as Administrator. Try from a machine/NIC not actively using DHCP if UDP 68 is locked."
    } finally {
        if ($probe) { try { $probe.Close() } catch {} }
    }
}

function Export-CsvFiles {
    $folder = Join-Path $env:USERPROFILE ("Desktop\DHCP-Sleuth-Export-" + (Get-Date -Format "yyyyMMdd-HHmmss"))
    New-Item -Path $folder -ItemType Directory -Force | Out-Null

    $packets = foreach ($row in $gridPackets.Rows) {
        [pscustomobject]@{
            Time = $row.Cells[0].Value
            Direction = $row.Cells[1].Value
            Type = $row.Cells[2].Value
            MAC = $row.Cells[3].Value
            Hostname = $row.Cells[4].Value
            RequestedIP = $row.Cells[5].Value
            OfferedIP = $row.Cells[6].Value
            ServerID = $row.Cells[7].Value
            Vendor = $row.Cells[8].Value
            Detail = $row.Tag
        }
    }
    $leases = foreach ($mac in $script:Leases.Keys) {
        $l = $script:Leases[$mac]
        [pscustomobject]@{ MAC=$mac; Hostname=$l.Hostname; IP=$l.IP; Status=$l.Status; Vendor=$l.Vendor; LastSeen=$l.LastSeen }
    }
    $servers = foreach ($sid in $script:Servers.Keys) {
        $s = $script:Servers[$sid]
        [pscustomobject]@{ ServerID=$sid; Remote=$s.Remote; Offers=$s.Offers; Acks=$s.Acks; LastSeen=$s.LastSeen }
    }

    $packets | Export-Csv -NoTypeInformation -Path (Join-Path $folder "packets.csv")
    $leases  | Export-Csv -NoTypeInformation -Path (Join-Path $folder "leases.csv")
    $servers | Export-Csv -NoTypeInformation -Path (Join-Path $folder "dhcp_servers.csv")
    $script:History | Export-Csv -NoTypeInformation -Path (Join-Path $folder "history.csv")

    Write-Log "Exported CSV files to $folder"
    [System.Diagnostics.Process]::Start("explorer.exe", $folder) | Out-Null
}

function Reset-AllData {
    $txtConsole.Clear()
    $txtProbe.Clear()
    $txtDetail.Clear()
    $gridPackets.Rows.Clear()
    $gridLeases.Rows.Clear()
    $gridServers.Rows.Clear()
    $script:Leases = @{}
    $script:Servers = @{}
    $script:History = New-Object System.Collections.ArrayList
    foreach ($k in @($script:Stats.Keys)) { $script:Stats[$k] = 0 }
    Update-StatsView
    Write-Log "Cleared logs, statistics, leases, and server tracking."
}

# ---------------------- UI ----------------------

$script:SavedSettings = Get-SavedSettings
$form = New-Object Windows.Forms.Form
$form.Text = "$($script:AppName) v$($script:AppVersion)"
$form.AutoScaleMode = [Windows.Forms.AutoScaleMode]::None
$form.MinimumSize = $script:DefaultWindowSize
$savedWidth = $script:SavedSettings.PSObject.Properties["WindowWidth"]
$savedHeight = $script:SavedSettings.PSObject.Properties["WindowHeight"]
if ($null -ne $savedWidth -and $null -ne $savedHeight -and [int]$savedWidth.Value -ge $script:DefaultWindowSize.Width -and [int]$savedHeight.Value -ge $script:DefaultWindowSize.Height) {
    $form.Size = [Drawing.Size]::new([int]$savedWidth.Value, [int]$savedHeight.Value)
} else {
    $form.Size = $script:DefaultWindowSize
}
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [Windows.Forms.FormBorderStyle]::Sizable
$form.MaximizeBox = $true
$form.BackColor = $script:Ui.App
$form.ForeColor = $script:Ui.Text
$form.Font = New-Object Drawing.Font("Segoe UI", 9)

$header = New-Object Windows.Forms.Panel
$header.Location = New-Object Drawing.Point(0,0)
$header.Size = New-Object Drawing.Size(1180,70)
$header.Anchor = [Windows.Forms.AnchorStyles]::Top -bor [Windows.Forms.AnchorStyles]::Left -bor [Windows.Forms.AnchorStyles]::Right
$header.BackColor = $script:Ui.Header
$form.Controls.Add($header)

$header.Add_Paint({
    param($sender, $e)
    $gridPen = New-Object Drawing.Pen([Drawing.Color]::FromArgb(24, $script:Ui.Accent), 1)
    for ($x = 0; $x -lt $sender.Width; $x += 42) { $e.Graphics.DrawLine($gridPen, $x, 0, $x, $sender.Height) }
    for ($y = 0; $y -lt $sender.Height; $y += 18) { $e.Graphics.DrawLine($gridPen, 0, $y, $sender.Width, $y) }
    $gridPen.Dispose()
})

$headerIcon = New-Object Windows.Forms.PictureBox
$headerIcon.Location = New-Object Drawing.Point(18,9)
$headerIcon.Size = New-Object Drawing.Size(52,52)
$headerIcon.SizeMode = "Zoom"
$headerIcon.BackColor = [Drawing.Color]::Transparent
if (Test-Path -LiteralPath $script:MagnifierAssetPath) {
    try { $headerIcon.Image = [Drawing.Image]::FromFile($script:MagnifierAssetPath) } catch {}
}
$header.Controls.Add($headerIcon)

$title = New-Object Windows.Forms.Label
$title.Text = $script:AppName
$title.Font = New-Object Drawing.Font("Bahnschrift SemiLight", 21)
$title.Location = New-Object Drawing.Point(82,15)
$title.Size = New-Object Drawing.Size(225,40)
$title.ForeColor = $script:Ui.Text
$header.Controls.Add($title)

$sub = New-Object Windows.Forms.Label
$sub.Text = "NETWORK MONITOR  |  DHCP PROBE  |  LAB SERVER"
$sub.Font = New-Object Drawing.Font("Segoe UI Semibold", 9)
$sub.Location = New-Object Drawing.Point(325,29)
$sub.Size = New-Object Drawing.Size(360,22)
$sub.ForeColor = $script:Ui.Muted
$header.Controls.Add($sub)

$lblStatus = New-Object Windows.Forms.Label
$lblStatus.Text = "STOPPED"
$lblStatus.Font = New-Object Drawing.Font("Segoe UI Semibold", 8)
$lblStatus.Location = New-Object Drawing.Point(920,41)
$lblStatus.Size = New-Object Drawing.Size(112,18)
$lblStatus.TextAlign = "MiddleRight"
$lblStatus.Anchor = [Windows.Forms.AnchorStyles]::Top -bor [Windows.Forms.AnchorStyles]::Right
$header.Controls.Add($lblStatus)

$statusCaption = New-Object Windows.Forms.Label
$statusCaption.Text = "DHCP STATUS"
$statusCaption.Font = New-Object Drawing.Font("Segoe UI Semibold", 8)
$statusCaption.Location = New-Object Drawing.Point(920,18)
$statusCaption.Size = New-Object Drawing.Size(112,18)
$statusCaption.TextAlign = "MiddleRight"
$statusCaption.Anchor = [Windows.Forms.AnchorStyles]::Top -bor [Windows.Forms.AnchorStyles]::Right
$statusCaption.ForeColor = $script:Ui.Muted
$header.Controls.Add($statusCaption)

$bulbStopped = New-StatusBulb ([Drawing.Color]::FromArgb(238, 83, 98))
$bulbStopped.Location = New-Object Drawing.Point(1045,23)
$bulbStopped.Anchor = [Windows.Forms.AnchorStyles]::Top -bor [Windows.Forms.AnchorStyles]::Right
$bulbMonitor = New-StatusBulb ([Drawing.Color]::FromArgb(250, 182, 67))
$bulbMonitor.Location = New-Object Drawing.Point(1078,23)
$bulbMonitor.Anchor = [Windows.Forms.AnchorStyles]::Top -bor [Windows.Forms.AnchorStyles]::Right
$bulbServer = New-StatusBulb ([Drawing.Color]::FromArgb(68, 210, 142))
$bulbServer.Location = New-Object Drawing.Point(1111,23)
$bulbServer.Anchor = [Windows.Forms.AnchorStyles]::Top -bor [Windows.Forms.AnchorStyles]::Right
$script:StatusBulbs = @{ Stopped=$bulbStopped; Monitor=$bulbMonitor; Server=$bulbServer }
$header.Controls.AddRange(@($bulbStopped, $bulbMonitor, $bulbServer))

$leftPanel = New-Object Windows.Forms.Panel
$leftPanel.Location = New-Object Drawing.Point(15,85)
$workspaceHeight = [Math]::Max(580, $form.ClientSize.Height - 100)
$leftPanel.Size = [Drawing.Size]::new(300, [int]$workspaceHeight)
$leftPanel.Anchor = [Windows.Forms.AnchorStyles]::Top -bor [Windows.Forms.AnchorStyles]::Bottom -bor [Windows.Forms.AnchorStyles]::Left
$leftPanel.BackColor = $script:Ui.Card
Set-RoundedCorners $leftPanel 14
$form.Controls.Add($leftPanel)

$leftPanel.Add_Paint({
    param($sender, $e)
    $gridPen = New-Object Drawing.Pen([Drawing.Color]::FromArgb(20, $script:Ui.Accent), 1)
    for ($x = 0; $x -lt $sender.Width; $x += 34) { $e.Graphics.DrawLine($gridPen, $x, 0, $x, $sender.Height) }
    for ($y = 0; $y -lt $sender.Height; $y += 18) { $e.Graphics.DrawLine($gridPen, 0, $y, $sender.Width, $y) }
    $gridPen.Dispose()
})

$configTitle = New-Object Windows.Forms.Label
$configTitle.Text = "Lab DHCP Server Settings"
$configTitle.Font = New-Object Drawing.Font("Segoe UI Semibold", 11)
$configTitle.Location = New-Object Drawing.Point(15,15)
$configTitle.Size = New-Object Drawing.Size(260,24)
$configTitle.ForeColor = $script:Ui.Text
$leftPanel.Controls.Add($configTitle)

$labels = @("IP Address", "Server IP","Subnet Mask","Router/Gateway","DNS Server","Lease Start","Lease End","Lease Seconds")
$settingKeys = @("NetworkIP", "ServerIP", "SubnetMask", "Router", "DnsServer", "LeaseStart", "LeaseEnd", "LeaseSeconds")
$defaults = @("192.168.50.0", "192.168.50.1","255.255.255.0","192.168.50.1","192.168.50.1","192.168.50.100","192.168.50.150","3600")
for ($i = 0; $i -lt $defaults.Count; $i++) {
    $savedProperty = $script:SavedSettings.PSObject.Properties[$settingKeys[$i]]
    if ($null -ne $savedProperty -and -not [string]::IsNullOrWhiteSpace([string]$savedProperty.Value)) {
        $defaults[$i] = [string]$savedProperty.Value
    }
}
$savedPrefix = "/24"
$savedPrefixProperty = $script:SavedSettings.PSObject.Properties["CidrPrefix"]
if ($null -ne $savedPrefixProperty -and (Get-CidrPrefix ([string]$savedPrefixProperty.Value))) {
    $savedPrefix = Get-CidrPrefix ([string]$savedPrefixProperty.Value)
} elseif ($script:SavedSettings.PSObject.Properties["CIDR"] -and ([string]$script:SavedSettings.CIDR -match '^((?:\d{1,3}\.){3}\d{1,3})/(\d{1,2})')) {
    if (-not $script:SavedSettings.PSObject.Properties["NetworkIP"]) { $defaults[0] = $matches[1] }
    $savedPrefix = "/$($matches[2])"
}
$textboxes = @{}

for ($i=0; $i -lt $labels.Count; $i++) {
    $fieldWidth = if ($i -eq 0) { 105 } else { 260 }
    $lbl = New-Object Windows.Forms.Label
    $lbl.Text = $labels[$i]
    $lbl.Location = New-Object Drawing.Point(15, (40 + ($i*38)))
    $lbl.Size = New-Object Drawing.Size($fieldWidth,18)
    $lbl.ForeColor = $script:Ui.Muted
    $leftPanel.Controls.Add($lbl)

    $txt = New-Object Windows.Forms.TextBox
    $txt.Text = $defaults[$i]
    $txt.Location = New-Object Drawing.Point(15, (57 + ($i*38)))
    $txt.Size = New-Object Drawing.Size($fieldWidth,24)
    $txt.BackColor = $script:Ui.Input
    $txt.ForeColor = $script:Ui.Text
    $txt.Font = New-Object Drawing.Font("Segoe UI", 9)
    $txt.BorderStyle = "FixedSingle"
    $leftPanel.Controls.Add($txt)
    $textboxes[$labels[$i]] = $txt

    if ($i -eq 0) {
        $cidrLabel = New-Object Windows.Forms.Label
        $cidrLabel.Text = "CIDR / Subnet Mask"
        $cidrLabel.Location = New-Object Drawing.Point(130, 40)
        $cidrLabel.Size = New-Object Drawing.Size(145,18)
        $cidrLabel.ForeColor = $script:Ui.Muted
        $leftPanel.Controls.Add($cidrLabel)

        $cidrPicker = New-Object Windows.Forms.ComboBox
        $cidrPicker.Text = $savedPrefix
        $cidrPicker.Location = New-Object Drawing.Point(130, 57)
        $cidrPicker.Size = New-Object Drawing.Size(145,24)
        $cidrPicker.DropDownStyle = "DropDown"
        $cidrPicker.FlatStyle = "Flat"
        $cidrPicker.DropDownWidth = 260
        $cidrPicker.BackColor = $script:Ui.Input
        $cidrPicker.ForeColor = $script:Ui.Text
        $cidrPicker.Font = New-Object Drawing.Font("Segoe UI", 9)
        $leftPanel.Controls.Add($cidrPicker)
        $textboxes["CIDR"] = $cidrPicker
    }
}

function New-SleuthButton {
    param([string]$Text, [int]$X, [int]$Y, [int]$W=260, [int]$H=32)
    $b = New-Object Windows.Forms.Button
    $b.Text = $Text
    $b.Location = New-Object Drawing.Point($X,$Y)
    $b.Size = New-Object Drawing.Size($W,$H)
    $b.FlatStyle = "Flat"
    $b.FlatAppearance.BorderSize = 0
    $b.BackColor = $script:Ui.Button
    $b.ForeColor = $script:Ui.Muted
    $b.Font = New-Object Drawing.Font("Segoe UI Semibold", 9)
    $b.Cursor = [Windows.Forms.Cursors]::Hand
    $b.FlatAppearance.MouseOverBackColor = $script:Ui.ButtonHot
    $b.FlatAppearance.MouseDownBackColor = [Drawing.Color]::FromArgb(62, 94, 145)
    Set-RoundedCorners $b 9
    return $b
}

function Update-ResponsiveLayout {
    if ($null -eq $tabPackets -or $tabPackets.ClientSize.Height -le 0) { return }

    $form.SuspendLayout()
    try {
        $header.Width = [Math]::Max(760, $form.ClientSize.Width)
        $workspaceHeight = [Math]::Max(580, $form.ClientSize.Height - 100)
        $leftPanel.Height = $workspaceHeight
        $rightX = 330
        $rightPanel.Location = [Drawing.Point]::new($rightX, 85)
        $rightPanel.Size = [Drawing.Size]::new(
            [int][Math]::Max(640, $form.ClientSize.Width - $rightX - 15),
            [int]$workspaceHeight
        )

        $statusRight = $header.ClientSize.Width - 24
        $bulbSize = 28
        $bulbGap = 7
        $bulbTop = 22
        $bulbServer.Location = [Drawing.Point]::new([int]($statusRight - $bulbSize), $bulbTop)
        $bulbMonitor.Location = [Drawing.Point]::new([int]($bulbServer.Left - $bulbGap - $bulbSize), $bulbTop)
        $bulbStopped.Location = [Drawing.Point]::new([int]($bulbMonitor.Left - $bulbGap - $bulbSize), $bulbTop)

        $statusLabelWidth = 128
        $statusLabelLeft = [Math]::Max(710, $bulbStopped.Left - $statusLabelWidth - 14)
        $statusCaption.Location = [Drawing.Point]::new([int]$statusLabelLeft, 18)
        $statusCaption.Size = [Drawing.Size]::new($statusLabelWidth, 18)
        $lblStatus.Location = [Drawing.Point]::new([int]$statusLabelLeft, 41)
        $lblStatus.Size = [Drawing.Size]::new($statusLabelWidth, 18)

        $subtitleRightLimit = $statusLabelLeft - 28
        $subtitleWidth = [Math]::Max(260, $subtitleRightLimit - $sub.Left)
        $sub.Size = [Drawing.Size]::new([int]$subtitleWidth, 22)
    } finally {
        $form.ResumeLayout($false)
    }

    $dashboardWidth = [Math]::Max(300, $tabDashboard.ClientSize.Width)
    $dashboardHeight = [Math]::Max(300, $tabDashboard.ClientSize.Height)
    $statsPanel.Size = [Drawing.Size]::new([int]($dashboardWidth - 30), 90)
    $dashboardFooterY = $dashboardHeight - 50
    $txtConsole.Size = [Drawing.Size]::new([int]($dashboardWidth - 30), [int][Math]::Max(180, $dashboardFooterY - 145))
    $btnClear.Location = [Drawing.Point]::new(15, [int]$dashboardFooterY)
    $btnExport.Location = [Drawing.Point]::new(185, [int]$dashboardFooterY)

    $detailHeight = 195
    $detailBottomMargin = 20
    $detailTop = [Math]::Max(225, $tabPackets.ClientSize.Height - $detailHeight - $detailBottomMargin)
    $txtDetail.Location = [Drawing.Point]::new(10, [int]$detailTop)
    $txtDetail.Size = [Drawing.Size]::new([int][Math]::Max(300, $tabPackets.ClientSize.Width - 20), $detailHeight)
    $gridPackets.Size = [Drawing.Size]::new(
        [int][Math]::Max(300, $tabPackets.ClientSize.Width - 20),
        [int][Math]::Max(180, $detailTop - 25)
    )

    $leaseWidth = [Math]::Max(300, $tabLeases.ClientSize.Width)
    $leaseHeight = [Math]::Max(300, $tabLeases.ClientSize.Height)
    $btnDeleteLease.Location = [Drawing.Point]::new(10, [int]($leaseHeight - 44))
    $gridLeases.Size = [Drawing.Size]::new([int]($leaseWidth - 20), [int][Math]::Max(180, $btnDeleteLease.Top - 25))

    $serverWidth = [Math]::Max(300, $tabRogue.ClientSize.Width)
    $serverHeight = [Math]::Max(300, $tabRogue.ClientSize.Height)
    $gridServers.Size = [Drawing.Size]::new([int]($serverWidth - 20), [int]($serverHeight - 20))
    $txtProbe.Size = [Drawing.Size]::new(
        [int][Math]::Max(300, $tabProbe.ClientSize.Width - 20),
        [int][Math]::Max(180, $tabProbe.ClientSize.Height - 20)
    )
}

$btnTest = New-SleuthButton "Test Config" 15 360
$btnMonitor = New-SleuthButton "Start Monitor Only" 15 396
$btnStart = New-SleuthButton "Start DHCP Server" 15 432
$btnStop = New-SleuthButton "Stop Listener" 15 468
$btnSendTest = New-SleuthButton "Send Local Test Packet" 15 504
$btnDhcpProbe = New-SleuthButton "Test Network DHCP" 15 540
$btnStop.Enabled = $false

$leftPanel.Controls.AddRange(@($btnTest,$btnMonitor,$btnStart,$btnStop,$btnSendTest,$btnDhcpProbe))

$rightPanel = New-Object Windows.Forms.TabControl
$rightPanel.Location = New-Object Drawing.Point(330,85)
$rightPanel.Size = [Drawing.Size]::new([int][Math]::Max(640, $form.ClientSize.Width - 345), [int]$workspaceHeight)
$rightPanel.Anchor = [Windows.Forms.AnchorStyles]::Top -bor [Windows.Forms.AnchorStyles]::Bottom -bor [Windows.Forms.AnchorStyles]::Left -bor [Windows.Forms.AnchorStyles]::Right
$rightPanel.BackColor = $script:Ui.App
$rightPanel.ForeColor = $script:Ui.Text
$rightPanel.DrawMode = "OwnerDrawFixed"
$rightPanel.SizeMode = "Fixed"
$rightPanel.ItemSize = New-Object Drawing.Size(104, 31)
$form.Controls.Add($rightPanel)

$tabDashboard = New-Object Windows.Forms.TabPage
$tabDashboard.Text = "Dashboard"
$tabDashboard.BackColor = $script:Ui.App
$rightPanel.TabPages.Add($tabDashboard)

$tabPackets = New-Object Windows.Forms.TabPage
$tabPackets.Text = "Packets"
$tabPackets.BackColor = $script:Ui.App
$rightPanel.TabPages.Add($tabPackets)

$tabLeases = New-Object Windows.Forms.TabPage
$tabLeases.Text = "Leases"
$tabLeases.BackColor = $script:Ui.App
$rightPanel.TabPages.Add($tabLeases)

$tabRogue = New-Object Windows.Forms.TabPage
$tabRogue.Text = "DHCP Servers"
$tabRogue.BackColor = $script:Ui.App
$rightPanel.TabPages.Add($tabRogue)

$tabProbe = New-Object Windows.Forms.TabPage
$tabProbe.Text = "Probe Results"
$tabProbe.BackColor = $script:Ui.App
$rightPanel.TabPages.Add($tabProbe)

$tabSettings = New-Object Windows.Forms.TabPage
$tabSettings.Text = "Settings"
$tabSettings.BackColor = $script:Ui.App
$rightPanel.TabPages.Add($tabSettings)

$rightPanel.Add_DrawItem({
    param($sender, $e)
    $selected = ($e.Index -eq $sender.SelectedIndex)
    $background = if ($selected) { $script:Ui.Card } else { $script:Ui.Header }
    $foreground = if ($selected) { $script:Ui.Accent } else { $script:Ui.Muted }
    $brush = New-Object Drawing.SolidBrush($background)
    $e.Graphics.FillRectangle($brush, $e.Bounds)
    $brush.Dispose()
    if ($selected) {
        $accentBrush = New-Object Drawing.SolidBrush($script:Ui.Accent)
        $e.Graphics.FillRectangle($accentBrush, $e.Bounds.X + 10, $e.Bounds.Bottom - 3, $e.Bounds.Width - 20, 3)
        $accentBrush.Dispose()
    }
    [Windows.Forms.TextRenderer]::DrawText(
        $e.Graphics, $sender.TabPages[$e.Index].Text,
        $script:TabFont, $e.Bounds, $foreground,
        [Windows.Forms.TextFormatFlags]::HorizontalCenter -bor [Windows.Forms.TextFormatFlags]::VerticalCenter
    )
})

$statsPanel = New-Object Windows.Forms.Panel
$statsPanel.Location = New-Object Drawing.Point(15,15)
$statsPanel.Size = New-Object Drawing.Size(785,90)
$statsPanel.BackColor = $script:Ui.Card
Set-RoundedCorners $statsPanel 14
$tabDashboard.Controls.Add($statsPanel)

$lblDiscover = New-Object Windows.Forms.Label
$lblOffer = New-Object Windows.Forms.Label
$lblRequest = New-Object Windows.Forms.Label
$lblAck = New-Object Windows.Forms.Label
$lblNak = New-Object Windows.Forms.Label
$lblOther = New-Object Windows.Forms.Label
$statLabels = @($lblDiscover,$lblOffer,$lblRequest,$lblAck,$lblNak,$lblOther)
$statNames = @("DISCOVER: 0","OFFER: 0","REQUEST: 0","ACK: 0","NAK: 0","OTHER: 0")
for ($i=0; $i -lt $statLabels.Count; $i++) {
    $statLabels[$i].Text = $statNames[$i]
    $statLabels[$i].Location = New-Object Drawing.Point((20 + (($i % 3)*245)), (18 + ([math]::Floor($i/3)*35)))
    $statLabels[$i].Size = New-Object Drawing.Size(220,24)
    $statLabels[$i].Font = New-Object Drawing.Font("Bahnschrift SemiBold", 12)
    $statLabels[$i].ForeColor = $script:Ui.Accent
    $statsPanel.Controls.Add($statLabels[$i])
}

$txtConsole = New-Object Windows.Forms.TextBox
$txtConsole.Multiline = $true
$txtConsole.ScrollBars = "Vertical"
$txtConsole.WordWrap = $true
$txtConsole.Location = New-Object Drawing.Point(15,125)
$txtConsole.Size = New-Object Drawing.Size(785,430)
$txtConsole.ReadOnly = $true
$txtConsole.BackColor = $script:Ui.Input
$txtConsole.ForeColor = [Drawing.Color]::FromArgb(150, 229, 204)
$txtConsole.Font = New-Object Drawing.Font("Consolas", 9)
$tabDashboard.Controls.Add($txtConsole)

$btnClear = New-SleuthButton "Clear All Data" 15 575 160 34
$btnExport = New-SleuthButton "Export CSV" 185 575 160 34
$tabDashboard.Controls.AddRange(@($btnClear,$btnExport))

$gridPackets = New-Object Windows.Forms.DataGridView
$gridPackets.Location = New-Object Drawing.Point(10,10)
$gridPackets.Size = New-Object Drawing.Size(795,395)
$gridPackets.ReadOnly = $true
$gridPackets.AllowUserToAddRows = $false
$gridPackets.AllowUserToDeleteRows = $false
$gridPackets.RowHeadersVisible = $false
$gridPackets.AutoSizeColumnsMode = "Fill"
$gridPackets.SelectionMode = "FullRowSelect"
$gridPackets.BackgroundColor = $script:Ui.Input
$gridPackets.DefaultCellStyle.BackColor = $script:Ui.Input
$gridPackets.DefaultCellStyle.ForeColor = $script:Ui.Text
$gridPackets.DefaultCellStyle.SelectionBackColor = $script:Ui.ButtonHot
$gridPackets.DefaultCellStyle.SelectionForeColor = $script:Ui.Text
$gridPackets.ColumnHeadersDefaultCellStyle.BackColor = $script:Ui.Card
$gridPackets.ColumnHeadersDefaultCellStyle.ForeColor = $script:Ui.Accent
$gridPackets.ColumnHeadersDefaultCellStyle.Font = New-Object Drawing.Font("Segoe UI Semibold", 9)
$gridPackets.BorderStyle = "None"
$gridPackets.CellBorderStyle = "SingleHorizontal"
$gridPackets.GridColor = [Drawing.Color]::FromArgb(34, 46, 72)
$gridPackets.EnableHeadersVisualStyles = $false
foreach ($c in @("Time","Dir","Type","MAC","Hostname","Requested","Offered","Server","Vendor")) {
    [void]$gridPackets.Columns.Add($c,$c)
}
$tabPackets.Controls.Add($gridPackets)

$txtDetail = New-Object Windows.Forms.TextBox
$txtDetail.Multiline = $true
$txtDetail.ScrollBars = "Vertical"
$txtDetail.WordWrap = $true
$txtDetail.Location = New-Object Drawing.Point(10,420)
$txtDetail.Size = New-Object Drawing.Size(795,195)
$txtDetail.ReadOnly = $true
$txtDetail.BackColor = $script:Ui.Input
$txtDetail.ForeColor = $script:Ui.Text
$txtDetail.Font = New-Object Drawing.Font("Consolas", 9)
$tabPackets.Controls.Add($txtDetail)

$gridLeases = New-Object Windows.Forms.DataGridView
$gridLeases.Location = New-Object Drawing.Point(10,10)
$gridLeases.Size = New-Object Drawing.Size(795,545)
$gridLeases.ReadOnly = $true
$gridLeases.AllowUserToAddRows = $false
$gridLeases.AllowUserToDeleteRows = $false
$gridLeases.RowHeadersVisible = $false
$gridLeases.AutoSizeColumnsMode = "Fill"
$gridLeases.SelectionMode = "FullRowSelect"
$gridLeases.BackgroundColor = $script:Ui.Input
$gridLeases.DefaultCellStyle.BackColor = $script:Ui.Input
$gridLeases.DefaultCellStyle.ForeColor = $script:Ui.Text
$gridLeases.DefaultCellStyle.SelectionBackColor = $script:Ui.ButtonHot
$gridLeases.DefaultCellStyle.SelectionForeColor = $script:Ui.Text
$gridLeases.ColumnHeadersDefaultCellStyle.BackColor = $script:Ui.Card
$gridLeases.ColumnHeadersDefaultCellStyle.ForeColor = $script:Ui.Accent
$gridLeases.ColumnHeadersDefaultCellStyle.Font = New-Object Drawing.Font("Segoe UI Semibold", 9)
$gridLeases.BorderStyle = "None"
$gridLeases.CellBorderStyle = "SingleHorizontal"
$gridLeases.GridColor = [Drawing.Color]::FromArgb(34, 46, 72)
$gridLeases.EnableHeadersVisualStyles = $false
foreach ($c in @("MAC","Hostname","IP","Status","Vendor","Last Seen")) {
    [void]$gridLeases.Columns.Add($c,$c)
}
$tabLeases.Controls.Add($gridLeases)

$btnDeleteLease = New-SleuthButton "Delete Selected Lease" 10 570 205 32
$btnDeleteLease.ForeColor = [Drawing.Color]::FromArgb(255, 190, 196)
$tabLeases.Controls.Add($btnDeleteLease)

$gridServers = New-Object Windows.Forms.DataGridView
$gridServers.Location = New-Object Drawing.Point(10,10)
$gridServers.Size = New-Object Drawing.Size(795,605)
$gridServers.ReadOnly = $true
$gridServers.AllowUserToAddRows = $false
$gridServers.AllowUserToDeleteRows = $false
$gridServers.RowHeadersVisible = $false
$gridServers.AutoSizeColumnsMode = "Fill"
$gridServers.SelectionMode = "FullRowSelect"
$gridServers.BackgroundColor = $script:Ui.Input
$gridServers.DefaultCellStyle.BackColor = $script:Ui.Input
$gridServers.DefaultCellStyle.ForeColor = $script:Ui.Text
$gridServers.DefaultCellStyle.SelectionBackColor = $script:Ui.ButtonHot
$gridServers.DefaultCellStyle.SelectionForeColor = $script:Ui.Text
$gridServers.ColumnHeadersDefaultCellStyle.BackColor = $script:Ui.Card
$gridServers.ColumnHeadersDefaultCellStyle.ForeColor = $script:Ui.Accent
$gridServers.ColumnHeadersDefaultCellStyle.Font = New-Object Drawing.Font("Segoe UI Semibold", 9)
$gridServers.BorderStyle = "None"
$gridServers.CellBorderStyle = "SingleHorizontal"
$gridServers.GridColor = [Drawing.Color]::FromArgb(34, 46, 72)
$gridServers.EnableHeadersVisualStyles = $false
foreach ($c in @("DHCP Server ID","Remote IP","Offers","ACKs","Last Seen")) {
    [void]$gridServers.Columns.Add($c,$c)
}
$tabRogue.Controls.Add($gridServers)

$txtProbe = New-Object Windows.Forms.TextBox
$txtProbe.Multiline = $true
$txtProbe.ScrollBars = "Vertical"
$txtProbe.WordWrap = $true
$txtProbe.Location = New-Object Drawing.Point(10,10)
$txtProbe.Size = New-Object Drawing.Size(795,605)
$txtProbe.ReadOnly = $true
$txtProbe.BackColor = $script:Ui.Input
$txtProbe.ForeColor = $script:Ui.Text
$txtProbe.Font = New-Object Drawing.Font("Consolas", 10)
$tabProbe.Controls.Add($txtProbe)

$settingsTitle = New-Object Windows.Forms.Label
$settingsTitle.Text = "Appearance"
$settingsTitle.Font = New-Object Drawing.Font("Bahnschrift SemiLight", 19)
$settingsTitle.Location = New-Object Drawing.Point(22,22)
$settingsTitle.Size = New-Object Drawing.Size(280,34)
$settingsTitle.ForeColor = $script:Ui.Text
$tabSettings.Controls.Add($settingsTitle)

$settingsHint = New-Object Windows.Forms.Label
$settingsHint.Text = "Choose a cockpit skin. Changes are applied immediately."
$settingsHint.Font = New-Object Drawing.Font("Segoe UI", 9)
$settingsHint.Location = New-Object Drawing.Point(24,58)
$settingsHint.Size = New-Object Drawing.Size(440,24)
$settingsHint.ForeColor = $script:Ui.Muted
$tabSettings.Controls.Add($settingsHint)

$themeNames = @("Nebula", "Midnight", "Amethyst", "Ember", "Evergreen", "Carbon", "Arctic", "Oceanic", "Rose Quartz", "Terminal")
for ($i = 0; $i -lt $themeNames.Count; $i++) {
    $themeName = $themeNames[$i]
    $theme = $script:Themes[$themeName]
    $themeButton = New-Object Windows.Forms.Button
    $themeButton.Text = $themeName.ToUpper()
    $themeButton.Tag = $themeName
    $themeButton.Location = New-Object Drawing.Point((24 + (($i % 2) * 250)), (104 + ([math]::Floor($i / 2) * 64)))
    $themeButton.Size = New-Object Drawing.Size(230, 50)
    $themeButton.FlatStyle = "Flat"
    $themeButton.FlatAppearance.BorderSize = 1
    $themeButton.FlatAppearance.BorderColor = $theme.Accent
    $themeButton.FlatAppearance.MouseOverBackColor = $theme.ButtonHot
    $themeButton.BackColor = $theme.Card
    $themeButton.ForeColor = $theme.Text
    $themeButton.Font = New-Object Drawing.Font("Segoe UI Semibold", 10)
    $themeButton.Cursor = [Windows.Forms.Cursors]::Hand
    Set-RoundedCorners $themeButton 12
    $themeButton.Add_Click({ param($sender, $eventArgs) Set-SleuthTheme -Name $sender.Tag -Persist })
    $script:ThemeButtons += $themeButton
    $tabSettings.Controls.Add($themeButton)
}

$textureNote = New-Object Windows.Forms.Label
$textureNote.Text = "The header grid adapts to every theme. Small texture, no disco ball."
$textureNote.Font = New-Object Drawing.Font("Segoe UI", 9, [Drawing.FontStyle]::Italic)
$textureNote.Location = New-Object Drawing.Point(24,442)
$textureNote.Size = New-Object Drawing.Size(500,24)
$textureNote.ForeColor = $script:Ui.Muted
$tabSettings.Controls.Add($textureNote)

$btnRestoreSize = New-SleuthButton "Restore Compact Size" 24 480 230 32
$btnRestoreSize.ForeColor = $script:Ui.Muted
$tabSettings.Controls.Add($btnRestoreSize)

$aboutTitle = New-Object Windows.Forms.Label
$aboutTitle.Text = "About"
$aboutTitle.Font = New-Object Drawing.Font("Segoe UI Semibold", 11)
$aboutTitle.Location = New-Object Drawing.Point(540,104)
$aboutTitle.Size = New-Object Drawing.Size(260,24)
$aboutTitle.ForeColor = $script:Ui.Text
$tabSettings.Controls.Add($aboutTitle)

$aboutText = New-Object Windows.Forms.Label
$aboutText.Text = "$($script:AppName) v$($script:AppVersion)`r`nPortable DHCP monitor, probe, and lab server utility.`r`nMaintainer: $($script:AppMaintainer)`r`nContact: $($script:AppContact)"
$aboutText.Font = New-Object Drawing.Font("Segoe UI", 9)
$aboutText.Location = New-Object Drawing.Point(542,134)
$aboutText.Size = New-Object Drawing.Size(340,92)
$aboutText.ForeColor = $script:Ui.Muted
$tabSettings.Controls.Add($aboutText)

$script:ActionButtons = @($btnTest, $btnMonitor, $btnStart, $btnStop, $btnSendTest, $btnDhcpProbe, $btnClear, $btnExport, $btnDeleteLease, $btnRestoreSize)
$statsPanel.Anchor = [Windows.Forms.AnchorStyles]::Top -bor [Windows.Forms.AnchorStyles]::Left -bor [Windows.Forms.AnchorStyles]::Right
$txtConsole.Anchor = [Windows.Forms.AnchorStyles]::Top -bor [Windows.Forms.AnchorStyles]::Bottom -bor [Windows.Forms.AnchorStyles]::Left -bor [Windows.Forms.AnchorStyles]::Right
$btnClear.Anchor = [Windows.Forms.AnchorStyles]::Bottom -bor [Windows.Forms.AnchorStyles]::Left
$btnExport.Anchor = [Windows.Forms.AnchorStyles]::Bottom -bor [Windows.Forms.AnchorStyles]::Left
$gridPackets.Anchor = [Windows.Forms.AnchorStyles]::Top -bor [Windows.Forms.AnchorStyles]::Left -bor [Windows.Forms.AnchorStyles]::Right
$txtDetail.Anchor = [Windows.Forms.AnchorStyles]::Bottom -bor [Windows.Forms.AnchorStyles]::Left -bor [Windows.Forms.AnchorStyles]::Right
$gridLeases.Anchor = [Windows.Forms.AnchorStyles]::Top -bor [Windows.Forms.AnchorStyles]::Bottom -bor [Windows.Forms.AnchorStyles]::Left -bor [Windows.Forms.AnchorStyles]::Right
$btnDeleteLease.Anchor = [Windows.Forms.AnchorStyles]::Bottom -bor [Windows.Forms.AnchorStyles]::Left
$gridServers.Anchor = [Windows.Forms.AnchorStyles]::Top -bor [Windows.Forms.AnchorStyles]::Bottom -bor [Windows.Forms.AnchorStyles]::Left -bor [Windows.Forms.AnchorStyles]::Right
$txtProbe.Anchor = [Windows.Forms.AnchorStyles]::Top -bor [Windows.Forms.AnchorStyles]::Bottom -bor [Windows.Forms.AnchorStyles]::Left -bor [Windows.Forms.AnchorStyles]::Right
foreach ($button in @($btnTest, $btnMonitor, $btnStart, $btnStop, $btnSendTest, $btnDhcpProbe)) {
    $button.Anchor = [Windows.Forms.AnchorStyles]::Bottom -bor [Windows.Forms.AnchorStyles]::Left
}
$textboxes["CIDR"].Add_TextChanged({ Apply-CidrDefaults })
$textboxes["CIDR"].Add_SelectedIndexChanged({ Apply-CidrDefaults })
$textboxes["IP Address"].Add_TextChanged({ Apply-CidrDefaults })
Update-CidrChoices
Apply-CidrDefaults
foreach ($textbox in $textboxes.Values) {
    $textbox.Add_TextChanged({ Save-SleuthSettings })
}
$initialTheme = "Nebula"
if ($script:SavedSettings.Theme -and $script:Themes.ContainsKey([string]$script:SavedSettings.Theme)) {
    $initialTheme = [string]$script:SavedSettings.Theme
}
Set-SleuthTheme $initialTheme

$gridPackets.Add_SelectionChanged({
    if ($gridPackets.SelectedRows.Count -gt 0) {
        $txtDetail.Text = [string]$gridPackets.SelectedRows[0].Tag
    }
})

$btnTest.Add_Click({
    try {
        $cfg = Validate-Config
        Write-Log "Config OK. ServerIP=$($cfg.ServerIP) Pool=$($cfg.LeaseStart)-$($cfg.LeaseEnd)"
    } catch {
        Write-Log "Config test failed: $($_.Exception.Message)"
    }
})

$btnMonitor.Add_Click({ Start-Listener -Mode Monitor })

$btnStart.Add_Click({
    $confirm = [Windows.Forms.MessageBox]::Show(
        "DHCP Server mode sends OFFER/ACK replies. Only use on an isolated lab network. Continue?",
        "Confirm DHCP Server Mode",
        "YesNo",
        "Warning"
    )
    if ($confirm -eq "Yes") { Start-Listener -Mode Server } else { Write-Log "DHCP Server start cancelled." }
})

$btnStop.Add_Click({ Stop-Listener })

$btnSendTest.Add_Click({
    try {
        $udpTest = New-Object System.Net.Sockets.UdpClient
        $data = [Text.Encoding]::ASCII.GetBytes("DHCP-SLEUTH-TEST")
        [void]$udpTest.Send($data, $data.Length, "127.0.0.1", 67)
        $udpTest.Close()
        Write-Log "Sent local UDP test packet to 127.0.0.1:67"
    } catch {
        Write-Log "Local test packet failed: $($_.Exception.Message)"
    }
})

$btnDhcpProbe.Add_Click({ Test-NetworkDhcpServer })
$btnClear.Add_Click({ Reset-AllData })
$btnExport.Add_Click({ Export-CsvFiles })
$btnDeleteLease.Add_Click({ Remove-SelectedLease })
$btnRestoreSize.Add_Click({ Restore-DefaultWindowSize })

$form.Add_FormClosing({
    $script:StopDhcp = $true
    if ($script:Udp) { try { $script:Udp.Close() } catch {} }
    Save-SleuthSettings
    if ($headerIcon.Image) { try { $headerIcon.Image.Dispose() } catch {} }
})
$form.Add_Resize({ Update-ResponsiveLayout })
$form.Add_ResizeEnd({ Save-SleuthSettings })
$form.Add_Shown({ Update-ResponsiveLayout })
$rightPanel.Add_Resize({ Update-ResponsiveLayout })

Set-AppStatus "STOPPED"
Update-StatsView
Write-Log "DHCP Sleuth opened in stopped state."
Write-Log "Monitor Only listens and logs DHCP traffic without replies."
Write-Log "Test Network DHCP sends a DISCOVER probe and shows OFFER details."
Write-Log "DHCP Server mode is lab-only."

[Windows.Forms.Application]::Run($form)
