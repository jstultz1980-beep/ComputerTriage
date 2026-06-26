# Network Toolkit

Portable Windows technician toolkit for live workstation, server, and network troubleshooting.

Network Toolkit is designed for the common field scenario: walk up to an unknown computer, plug in a prepared drive, launch one tool, run a quick diagnosis, and leave with a readable report that explains what looks broken and what to check next.

The GUI is the primary technician experience. The console toolkit is still preserved for command-line use, scripting, remote shells, and older plugin workflows that have not yet become full GUI pages.

## Current Status

| Item | Current behavior |
| --- | --- |
| Product name | Network Toolkit |
| Primary launcher | `NetworkToolkit.vbs` |
| Main app folder | `App` |
| GUI entry point | `App\NetworkToolkit.ps1` |
| Console entry point | `App\NetworkToolkit.ps1 -CLI` |
| Version metadata | `App\manifests\toolkit-version.json` |
| Main help file | `App\CSI-NetworkToolkit\Docs\NetworkToolkitHelp.html` |
| Production readiness notes | `App\CSI-NetworkToolkit\Docs\ProductionReadiness.md` |
| Button/category matrix | `App\CSI-NetworkToolkit\Docs\ButtonPlacementMatrix.md` |

## Design Goals

Network Toolkit should be:

- **Fast to start using:** a technician should not need to know every tool before running Quick Diagnosis.
- **Useful live:** the toolkit should expose current computer and network problems, not become a history database.
- **Report driven:** Quick Diagnosis and Computer Info should produce professional reports that guide the next action.
- **Portable:** the toolkit should work from a thumb drive and keep its own tools close by.
- **Cleanable:** client data must be removable without damaging the toolkit.
- **Organized by intent:** tabs should match how a technician thinks during troubleshooting.
- **Conservative with repairs:** discovery and repair are separated so the technician sees evidence before changing system state.

## Launching

### Normal GUI Launch

From the portable root, run:

```text
NetworkToolkit.vbs
```

This is the expected production launch path. It starts the toolkit without leaving a PowerShell console window open in the background.

### Direct PowerShell Launch

From the portable root:

```powershell
.\App\NetworkToolkit.ps1
```

Use this when debugging startup behavior or when you want to see PowerShell errors directly.

### Console Toolkit

From the portable root:

```powershell
.\App\NetworkToolkit.ps1 -CLI
```

Use console mode for remote shells, low-bandwidth sessions, or fallback troubleshooting when the GUI cannot load.

### Developer Smoke Tests

```powershell
.\App\NetworkToolkit.ps1 -SmokeTest
.\App\NetworkToolkit.ps1 -ButtonSmokeTest
```

`-SmokeTest` verifies that the GUI can load. `-ButtonSmokeTest` builds the tab pages and checks that expected button surfaces exist.

## Folder Layout

The root folder is intentionally sparse. The only file that should normally live in the portable root is `NetworkToolkit.vbs`.

```text
NetworkToolkit\
  NetworkToolkit.vbs
  App\
    NetworkToolkit.ps1
    Build-ProductionPackage.ps1
    Deploy-NetworkToolkit.ps1
    Test-ProductionPackage.ps1
    Update-NetworkToolkit.ps1
    Update-ToolkitVersion.ps1
    ToolKit-GUI\
    CSI-NetworkToolkit\
    Custom\
    ExternalTools\
    manifests\
```

### Important Paths

| Path | Purpose |
| --- | --- |
| `NetworkToolkit.vbs` | Root launcher used by technicians. |
| `App\NetworkToolkit.ps1` | Shared launcher for GUI and CLI. |
| `App\ToolKit-GUI` | Windows Forms GUI code, icon, and logo assets. |
| `App\CSI-NetworkToolkit` | Shared toolkit backend, plugins, docs, reports, logs, data, and utilities. |
| `App\CSI-NetworkToolkit\Config` | Toolkit path/configuration and GUI tool catalog. |
| `App\CSI-NetworkToolkit\Core` | Core network scan/ping/port scan functions. |
| `App\CSI-NetworkToolkit\Discovery` | Network topology and neighbor discovery functions. |
| `App\CSI-NetworkToolkit\Plugins` | Console and GUI-backed feature modules. |
| `App\CSI-NetworkToolkit\Utilities` | Shared helpers for logging, retention, launch, state, reporting, and AI bundles. |
| `App\CSI-NetworkToolkit\Docs` | Help, readiness notes, and placement matrix. |
| `App\CSI-NetworkToolkit\Exports` | Technician-facing reports. Runtime/client data. |
| `App\CSI-NetworkToolkit\Logs` | Toolkit and tool usage logs. Runtime/client data. |
| `App\CSI-NetworkToolkit\Data` | Computer profiles, computer state, minidumps, and temp output sessions. Runtime/client data. |
| `App\Custom` | Toolkit-installed portable apps and migrated standalone tools. |
| `App\ExternalTools` | Bundled third-party tools managed outside the custom manifest. |
| `App\manifests\toolkit-version.json` | Source version/build metadata used by the updater. |
| `App\manifests\custom-tools.json` | Runtime/toolbox app registry. Usually not committed as source. |

## Main Technician Workflow

1. Launch `NetworkToolkit.vbs`.
2. Confirm the header shows the expected computer, domain/workgroup, private IP, public IP, and elevation state.
3. Run **Quick Diagnosis**.
4. Review the generated HTML report.
5. Follow the report's evidence and remediation checklist.
6. Use the relevant tab for deeper troubleshooting.
7. Export or bundle reports if escalation is needed.
8. Use **Settings > Remove Client Data** when the engagement is complete.

## Header Behavior

The header is meant to give the technician the most important context before any tool is launched.

| Header item | Purpose |
| --- | --- |
| Logo/title | Identifies the toolkit instance. |
| Computer | Shows the local computer name. |
| Domain | Shows the domain or workgroup. |
| Private IP | Shows the current private IP. Adapter names may be omitted or shortened in tight layouts. |
| Public IP | Shows detected egress IP. The label/value can be clicked to retry lookup. |
| Elevation status | Shows whether the toolkit is running elevated. |
| Gear icon | Opens Settings. |
| Help button | Opens the HTML help file. |

## Tab Guide

Tabs are organized by what the technician is trying to accomplish.

### Quick Diagnosis

The first tab and the normal starting point.

Use it to:

- Run the one-click computer health check.
- Generate the Quick Diagnosis HTML report.
- Generate or refresh the Computer Profile.
- Run quick target checks such as Ping, TCPing, Tracert, NSLookup, DNS record lookup, and WHOIS.
- Launch a few high-value hardware shortcuts.
- Run DISM/SFC repair only after review or with explicit override.

Quick Diagnosis should stay focused. Do not keep adding every useful tool here. If a tool is not part of the first-pass walk-up workflow, put it on the appropriate deeper tab.

### Computer Info

Computer Info is the evolved replacement for the old fingerprint workflow.

Use it to:

- View saved computer profiles.
- Create a current computer profile.
- Delete old profiles.
- Refresh the profile list.

Computer Profile reports should give a fuller picture than Quick Diagnosis. Quick Diagnosis should summarize issues; Computer Profile can include expandable detail.

### Analyze

Analyze is for evidence gathering.

Typical tools:

- Event Log Triage
- Service Health
- Startup Impact
- Windows Update Health
- Group Policy HTML Report
- Hardware Health
- Disk Health
- Driver update/review tools
- Remote management readiness checks

Use Analyze when Quick Diagnosis says there is a problem and you need the supporting evidence.

### Windows Update

Windows Update has its own tab because update workflows are slow, stateful, and potentially disruptive.

Use it to:

- Scan pending updates.
- Review recent update history.
- Download selected updates without installing.
- Install selected updates.
- Uninstall removable installed updates.
- Repair Windows Update components.
- Check reboot-pending state.

Repair Windows Update should not be the first step on every computer. Use it when scans fail, updates are stuck, or evidence points to damaged update components.

### Hardware

Hardware is for device, driver, storage, sensor, and hardware identity tools.

Typical tools:

- CPU-Z
- GPU-Z
- HWiNFO
- HWMonitor
- CrystalDiskInfo
- PCI-Z
- SSD-Z
- Speccy
- QuickMemoryTestOK

Virtual machines may hide or abstract physical hardware. If CrystalDiskInfo, SMART, GPU, or sensor checks are limited inside a VM, check the hypervisor host or storage platform as well.

### Crash

Crash is for BSOD, minidump, WER, reliability, and unexpected reboot work.

Typical workflow:

1. Run Minidump Collector.
2. Open collected dumps with BlueScreenView.
3. Review Crash Event Summary.
4. Review Reliability Monitor.
5. Compare timestamps with driver events and Windows Update history.

Minidump collection should copy dump files into toolkit data so BlueScreenView can be pointed at the collection folder.

### Processes

Processes is for process, handle, DLL, startup, and resource activity inspection.

Typical tools:

- Process Explorer
- Process Monitor
- RAMMap
- System Informer
- TCPView when connection ownership is the question
- Autoruns when startup/persistence is the question

Process Monitor can generate huge logs quickly. Filter first, reproduce the issue, then stop capture.

### Network

Network is for endpoint connectivity and path testing.

Typical tools:

- Connectivity Triage
- Adapter Route Health
- Packet Loss Monitor
- Live Route Trace
- Test-NetConnection
- PsPing
- WinMTR
- TLS Certificate Check
- Port reachability checks

Network should answer: "Can I reach the target, on what port, through what path, and with what loss/latency?"

### Infrastructure

Infrastructure is for services the computer depends on.

Typical tools:

- DHCP Sleuth
- DHCP Scope Inspector
- DHCP Lease / Rogue Check
- DNS Diagnostics
- Time Sync Health
- Reset to Domain Time
- Local Exposure Inspector

DHCP tools belong together here. DHCP is not just connectivity; it is a provider/service behavior problem. The Network tab stays cleaner when DHCP, DNS, time, and exposure checks are grouped as infrastructure.

### Discovery

Discovery is for finding things.

Typical tools:

- Network Discovery
- Port and Service Test
- Service Fingerprinter
- ARP Inventory Exporter
- Subnet Calculator
- Wake-on-LAN

Discovery tools should prompt clearly and avoid locking the GUI while scanning.

### Remote

Remote is for initiating or enabling remote access.

Typical tools:

- Launch RDP
- WinSCP
- PuTTY
- KiTTY
- mRemoteNG
- RustDesk
- TightVNC
- Enable Remote Management

Readiness checks belong on Analyze. Actions that enable or initiate remote access belong on Remote.

### PsExec

PsExec has its own tab because it needs guided arguments and better output handling.

Use it to:

- Build PsExec commands.
- Choose target and credentials.
- Pick interactive/elevated/system options.
- Run captured output when possible.
- Open an interactive console when required.

### Directory

Directory is for domain, Active Directory, secure channel, and Group Policy work.

Typical tools:

- Domain Logon Health
- GPO Health
- Group Policy reports
- ADExplorer
- ADInsight
- ADRestore

### Security

Security is for malware, persistence, signatures, privacy, and hardening.

Typical tools:

- Microsoft Safety Scanner
- Malwarebytes AdwCleaner
- ClamWin
- Autoruns
- Sigcheck
- HijackThis
- xpy
- password generation utilities

### Wi-Fi

Wi-Fi remains separate from Network because wireless failures have distinct causes.

Typical tools:

- Wi-Fi Issue Scan
- Wi-Fi Status
- Wi-Fi Profiles
- Wi-Fi Networks
- Wi-Fi Backup / Restore

Wi-Fi Backup / Restore consolidates the old separate export/import scripts into one workflow. It exports saved wireless profiles to the toolkit data store under the current computer name, imports profile XML files back onto a workstation, and can open the backup folder for review. Exported profile XML may include saved Wi-Fi keys in clear text, so handle these files as client-sensitive data and remove them with the toolkit sanitization process when they are no longer needed.

### Print

Print is for printer, spooler, queue, and stale printer artifact work.

Typical tools:

- Print Queue Maintenance
- Print Spooler Triage
- Stale Printer Cleanup

### Files

Files is for file search, disk usage, comparison, and file-level tools.

Typical tools:

- Everything
- WizTree
- WinDirStat
- WinMerge
- Kudu
- Handle
- file lock utilities where appropriate

Cleanup/removal-first tools should live on Clean Up instead.

### Robocopy

Robocopy is a guided command builder.

Use it to:

- Choose source and destination.
- Answer plain-language copy questions.
- Generate switches.
- Preview the command.
- Run or copy the command.

### Software

Software is for general portable support applications that are not primarily diagnostic, cleanup, security, or repair tools.

Typical tools:

- Firefox Portable
- Notepad++
- LibreOffice
- Draw.io
- KompoZer
- safe download links

Chocolatey management does not belong here.

### Software Keys

Software Keys is for local license/product key discovery.

Treat output from this tab as confidential. Remove client data when finished.

### Clean Up

Clean Up is for removal, leftovers, stale profiles, disk cleanup, registry cleanup, and recovery tools.

Typical tools:

- BleachBit
- CCleaner
- Bulk Uninstaller
- Revo Uninstaller
- Wise Registry Cleaner
- Profile Cleanup
- Recuva when recovery/remediation is the purpose

Cleanup tools can remove customer data. Confirm scope before running destructive actions.

### Toolkit App Manager

Toolkit app management is opened from **Settings > Toolkit App Manager**.

Use it to:

- Launch a toolkit-installed app.
- Rename the display name.
- Set tab placement.
- Remove an app from the toolkit.
- Refresh the app list.
- Check and apply updates for Chocolatey-backed portable toolkit apps.

The manager is one inventory for toolkit-contained apps. Functional app buttons should also appear on the tab where a technician would naturally look for them.

### Choco

Choco is for Chocolatey workflows.

Use it to:

- Install Chocolatey.
- Search packages.
- Install packages on the current computer.
- View installed computer packages.
- Upgrade selected/all computer packages.
- Uninstall packages from the computer.
- Add portable-compatible packages into the toolkit.

Important distinction:

- **Installed Chocolatey Packages** means packages installed on the current computer.
- **Toolkit App Manager** means tools installed into the portable toolkit and managed from Settings.

### Sysinternals

Sysinternals is the fallback tab for Sysinternals tools that do not clearly belong elsewhere.

If a Sysinternals tool clearly fits a functional tab, place it there instead.

### Reports

Reports is for technician-facing outputs, not raw logs or JSON noise.

Use it to:

- Search reports.
- Refresh report list.
- Open selected report.
- Delete selected report.
- Work with AI analysis bundle/import/final-report flows where available.

Logs are accessed from Settings.

## Reports And Data

Runtime output is useful during troubleshooting but must be treated as client data.

| Location | Contains |
| --- | --- |
| `App\CSI-NetworkToolkit\Exports` | HTML/TXT/CSV reports intended for technicians. |
| `App\CSI-NetworkToolkit\Data\ComputerProfiles` | Saved computer profile JSON/HTML. |
| `App\CSI-NetworkToolkit\Data\ComputerState` | Latest known state per computer. |
| `App\CSI-NetworkToolkit\Data\MiniDumps` | Collected crash dump files. |
| `App\CSI-NetworkToolkit\Data\TempToolOutputs` | Per-tool output sessions. |
| `App\CSI-NetworkToolkit\Logs` | Toolkit logs and tool usage logs. |

Use **Settings > Remove Client Data** after an engagement or when preparing a clean field copy. This cleanup is intentionally double-confirmed because it removes reports, profiles, logs, temp output sessions, minidumps, and computer state.

## AI Analysis Bundle Workflow

The AI bundle workflow packages the latest useful reports for the current computer and includes a prompt for external AI review.

Preferred model:

1. Toolkit creates the bundle.
2. Technician uploads the bundle to ChatGPT or another approved assistant.
3. Assistant returns structured JSON findings.
4. Toolkit imports the JSON.
5. Toolkit generates the final HTML report using its own template.

This keeps formatting, branding, and report storage controlled by the toolkit instead of depending on the assistant to produce final HTML directly.

## Updating The Toolkit

The source version/build metadata lives in:

```text
App\manifests\toolkit-version.json
```

Update it whenever source code, docs, shipped configuration, or GUI behavior changes:

```powershell
.\App\Update-ToolkitVersion.ps1 -ReleaseNotes "Describe the change."
```

The Settings page contains:

| Button | Purpose |
| --- | --- |
| Update Toolkit | Updates an existing destination when the source version/build is newer. |
| New Toolkit Deployment | Copies the toolkit as a fresh deployment to a new destination. |

Update Toolkit preserves destination runtime data, custom apps, portable apps, GUI settings, reports, logs, and profiles. Application payload updates are intentionally separate from source-code updates.

## Building A Production Package

From the source root:

```powershell
.\App\Build-ProductionPackage.ps1
```

Verify a copied package:

```powershell
.\App\Test-ProductionPackage.ps1
```

The production package should not include Git metadata, prior release output, old reports, old profiles, temp sessions, logs, minidumps, or client state.

## Maintainer Rules

- Keep `NetworkToolkit.vbs` as the only normal file in the portable root.
- Keep source code and shipped docs under `App`.
- Keep portable apps under `App\Custom` or `App\ExternalTools`.
- Do not commit client diagnostic data.
- Do not commit `App\manifests\custom-tools.json` unless intentionally changing shipped toolbox state.
- Bump `toolkit-version.json` after source/doc changes.
- Run smoke tests before committing GUI or catalog changes.
- Deploy to the active test copy after committed source changes when validating field behavior.
- Keep tab labels, help docs, README, production readiness notes, and placement matrix in sync.
- Prefer clear GUI prompts over launching blank consoles.
- Console-backed tools must keep output visible and write enough usage log detail to troubleshoot failures.
- Do not let tabs require vertical scrolling as a normal state at the minimum launch size.

## Common Troubleshooting

### Toolkit Does Not Launch

1. Run `.\App\NetworkToolkit.ps1` directly from PowerShell.
2. Check whether PowerShell execution policy or antivirus blocked a script.
3. Confirm `App\ToolKit-GUI\ToolKit-GUI.ps1` exists.
4. Confirm `App\CSI-NetworkToolkit\CSI-NetworkToolkit.ps1` exists.
5. Run `.\App\NetworkToolkit.ps1 -SmokeTest`.

### A Button Does Nothing

1. Check the status bar.
2. Open Settings, then Live Log.
3. Open Settings, then Logs.
4. Confirm the backing app exists in `App\Custom` or `App\ExternalTools`.
5. Confirm the app has a valid launch path in Settings > Toolkit App Manager.
6. Retry elevated if the tool requires admin rights.

### A Console Tool Closes Too Fast

Console-backed tools should run through the safe embedded runner or pause before exit. If a tool closes immediately, inspect the ToolUsage log and the temp output session for that run.

### Public IP Does Not Populate

Click the Public IP label/value to retry. If it remains unavailable, check DNS, HTTPS outbound access, proxy/firewall inspection, and whether the machine has internet access.

### Chocolatey Toolkit Install Confusion

Chocolatey can install packages on the current computer or help import portable tools into the toolkit. These are different workflows. Computer-installed packages belong in the Choco installed package list. Toolkit-installed apps are managed from Settings > Toolkit App Manager.

### DHCP Tool Confusion

All DHCP tools belong under Infrastructure.

- Use **DHCP Sleuth** for live monitoring/probing and rogue server investigation.
- Use **DHCP Scope Inspector** for DHCP scope/lease review.
- Use **DHCP Lease / Rogue Check** for a quick one-shot workstation-side evidence check.

## Current Active Development Notes

- The GUI is still being refined from the original console toolkit.
- Some console-backed tools still need richer GUI wrappers.
- Sysinternals tools should eventually receive helper prompts for required arguments.
- Computer Profile and Quick Diagnosis should keep improving around evidence, specific recommendations, and AI-assisted final reporting.
