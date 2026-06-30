# DHCP Sleuth

Version: 1.0.0  
Maintainer: Josh Stultz  
Contact: josh@jstultz.net

DHCP Sleuth is a portable PowerShell WinForms utility for DHCP visibility, testing, and controlled lab DHCP service. It is designed to live inside the Computer Toolkit as a standalone custom infrastructure tool.

## What it does

- Monitors DHCP traffic and records packet activity.
- Sends DHCP discovery probes and displays offer details.
- Runs a lab DHCP server for controlled testing.
- Tracks discovered DHCP servers.
- Tracks leases issued by the lab DHCP server.
- Allows selected leases to be deleted and reused.
- Exports collected DHCP data to CSV.
- Saves the last-used theme, DHCP settings, and window size automatically.

## Location

Toolkit path:

```text
C:\computer_toolkit\App\Custom\DHCPSleuth
```

Main script:

```text
C:\computer_toolkit\App\Custom\DHCPSleuth\DHCP-Sleuth.ps1
```

Portable settings file:

```text
C:\computer_toolkit\App\Custom\DHCPSleuth\DHCP-Sleuth.settings.json
```

## Requirements

- Windows PowerShell
- Windows Forms support
- Administrator rights recommended

DHCP listener/server behavior may require elevated permissions because DHCP uses low UDP ports.

## Running

From PowerShell:

```powershell
cd C:\computer_toolkit\App\Custom\DHCPSleuth
.\DHCP-Sleuth.ps1
```

From the Computer Toolkit, launch DHCP Sleuth from the Infrastructure tab.

## Safety notes

Server mode is intended for lab use only. Do not run the lab DHCP server on a production network unless you explicitly intend to provide DHCP replies there.

Monitor Only mode listens and logs DHCP traffic without sending DHCP replies.

Test Network DHCP sends a DHCP discovery probe and reports offer details.

## Settings and portability

DHCP Sleuth stores its portable settings next to the script in:

```text
DHCP-Sleuth.settings.json
```

The JSON file saves:

- selected theme
- IP/CIDR builder values
- DHCP server settings
- lease range
- lease duration
- window size

This keeps the tool portable as long as the whole `DHCPSleuth` folder is copied together.

## Versioning

DHCP Sleuth uses semantic versioning:

```text
MAJOR.MINOR.PATCH
```

- MAJOR: breaking or significant behavior changes
- MINOR: new features
- PATCH: fixes and visual polish

Current production baseline: `1.0.0`

## Files

```text
DHCPSleuth\
  DHCP-Sleuth.ps1
  DHCP-Sleuth.settings.json
  README.md
  VERSION
  assets\
    dhcp-sleuth-magnifier.png
    dhcp-sleuth-magnifier-source.png
```

