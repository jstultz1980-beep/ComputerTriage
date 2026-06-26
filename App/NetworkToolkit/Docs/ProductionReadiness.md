# Production Readiness

## Current Portable Layout

The production toolkit root should stay intentionally clean. The only file expected at the portable root is `NetworkToolkit.vbs`, which launches the toolkit without leaving a PowerShell console window behind.

Everything else lives under `App`.

```text
NetworkToolkit\
  NetworkToolkit.vbs
  App\
    NetworkToolkit.ps1
    ToolKit-GUI\
    NetworkToolkit\
    Custom\
    ExternalTools\
    manifests\
```

`App\NetworkToolkit.ps1` is the shared launcher. It opens the GUI by default and opens the console toolkit with `-CLI`.

## Full Portable Build

The production package is built with `Build-ProductionPackage.ps1`. It creates a clean `Release\NetworkToolkit-Portable` deployment folder suitable for copying directly to a thumb drive.

Launch the toolkit with `NetworkToolkit.vbs`. After copying the folder to removable media, run `App\Test-ProductionPackage.ps1` from the copied folder to verify the primary launch-file hashes and confirm that no client reports, profiles, state, dumps, or Git metadata were included.

The package builder excludes:

- Git metadata and prior release output
- Toolkit reports, exports, logs, minidumps, temporary sessions, and saved computer state
- Existing GUI settings
- The existing Firefox Portable profile and browser cache

It preserves the full diagnostic payload, including Sysinternals, Wireshark/Npcap, ClamWin definitions, Microsoft Safety Scanner, hardware tools, remote tools, crash tools, repair tools, and security scanners.

## Update And Deployment Model

The Settings page exposes two different maintenance paths:

- **Update Toolkit** updates an existing destination only when the selected source has a newer toolkit version/build. It updates scripts, GUI files, configuration, docs, and manifests while preserving destination portable apps, custom tools, reports, profiles, logs, GUI settings, and client data.
- **New Toolkit Deployment** copies the toolkit as a fresh deployment for a new destination, such as a new thumb drive.

Version/build metadata is stored in `App\manifests\toolkit-version.json`. Update the source version metadata whenever source code, docs, or shipped configuration changes:

```powershell
.\App\Update-ToolkitVersion.ps1 -ReleaseNotes "Describe the change."
```

The update process intentionally excludes portable applications and runtime client data. Application refresh/upgrade workflows should be handled separately from source-code updates.

## Efficiency Findings

The toolkit scripts are intentionally modular. The PowerShell code footprint is small compared with the bundled tools. Consolidating scripts into fewer files would save an insignificant amount of space and make the application harder to maintain, so it is not recommended.

The largest payloads are optional applications rather than toolkit code:

| Component | Production role |
| --- | --- |
| LibreOffice Portable | Office document work; optional for troubleshooting |
| Firefox Portable | Portable browser; optional when the technician has an approved browser |
| Draw.io Portable | Diagramming; optional |
| Kudu Portable | File management; optional |
| Wireshark Portable | Packet capture and protocol inspection |
| Sysinternals | Core diagnosis and administration tools |
| ClamWin definitions | Offline malware signature coverage |
| Microsoft Safety Scanner | On-demand Microsoft malware scan |

## Future Field-Lite Profile

For a smaller emergency drive, create a separate field-lite package rather than deleting tools from the full package. Keep Quick Diagnosis, Sysinternals, hardware tools, Wireshark/Npcap, remote tools, crash tools, repair tools, and security scanners. Make LibreOffice, Firefox, Draw.io, and Kudu optional add-on folders. That reduces size substantially while keeping the main diagnostic workflow intact.

## Client Data Hygiene

After each engagement, use **Settings > Remove Client Data**. The action requires two confirmations, including typing `REMOVE CLIENT DATA`, and removes collected diagnostic artifacts while preserving the applications and technician settings.

Use **Settings > Remove Client Data** when preparing a clean field copy. The cleanup removes legacy reports, logs, temporary output sessions, minidumps, profiles, computer state, and other troubleshooting artifacts that should not travel between clients.

## Current Tab Organization

The GUI is organized by technician intent rather than by implementation detail:

- **Quick Diagnosis** is the walk-up health check.
- **Computer Info** stores and opens computer profile reports.
- **Analyze** collects Windows health evidence.
- **Windows Update** handles update scan, history, selected download/install/uninstall, and update repair.
- **Hardware**, **Crash**, and **Processes** hold deeper local system tools.
- **Network** is for connectivity, routing, ports, packet loss, and path checks.
- **Infrastructure** is for DHCP, DNS, time, and local exposure checks.
- **Discovery** is for host, subnet, ARP, service, and wake-on-LAN discovery.
- **Remote** and **PsExec** support remote access and execution.
- **Directory**, **Security**, **Wi-Fi**, **Print**, **Files**, **Robocopy**, **Software**, **Software Keys**, **Clean Up**, **Choco**, **Sysinternals**, and **Reports** each group related tools by field workflow. Toolkit app inventory is opened from Settings > Toolkit App Manager.

DHCP tools belong together under **Infrastructure**. DHCP Sleuth is the live standalone monitor/probe utility; DHCP Scope Inspector checks DHCP scope/lease information where available; DHCP Lease / Rogue Check is the lightweight one-shot evidence collector.
