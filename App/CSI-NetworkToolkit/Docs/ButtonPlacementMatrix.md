# Network Toolkit Button Placement Matrix

Updated: 2026-06-25

Purpose: document the current GUI tab strategy so tool placement stays intuitive, non-redundant, and easy for a technician to navigate. This matrix is intentionally category-focused instead of a stale row-by-row dump of every generated custom app button.

## Placement Principles

- Put tools where a technician would look while troubleshooting, not where the code happens to live.
- Keep Network focused on connectivity and path testing.
- Keep Infrastructure focused on services the computer depends on, especially DHCP, DNS, time, and exposure.
- Put custom portable apps on the functional tab where they are useful, while still listing them in Settings > Toolkit App Manager for management.
- Use Sysinternals as the fallback tab only for tools that do not clearly belong elsewhere.
- Avoid overloading tabs. Split by intent before allowing vertical scrolling to become normal.

## Current Tab Inventory

| Tab | Primary Purpose | Typical Buttons / Tools | Placement Notes |
| --- | --- | --- | --- |
| Quick Diagnosis | One-click walk-up triage and fast target checks. | Quick Diagnosis, Latest Report, quick Ping/TCPing/Tracert/NSLookup/DNS/WHOIS, DISM/SFC repair after review, hardware shortcuts. | This is the first-use tab. It should stay focused and should not become a dumping ground. |
| Computer Info | Saved computer profile selection and profile reports. | View, Take Profile, Delete, Refresh. | This replaces the old fingerprint language. Profiles should include useful latest-state data. |
| Analyze | Evidence collection and Windows health analysis. | Event Log Triage, Service Health, Startup Impact, Windows Update Health, GPResult HTML, hardware health, disk health, driver review, remote management readiness. | Use when Quick Diagnosis flags a problem and the technician needs detail. |
| Windows Update | Windows Update workflow. | Refresh Updates, Download Selected, Install Selected, Uninstall Selected, Repair Windows Update. | Kept separate because update operations are slow and stateful. |
| Hardware | Hardware identity, device, sensor, storage, and driver utilities. | CPU-Z, GPU-Z, HWiNFO, HWMonitor, CrystalDiskInfo, PCI-Z, SSD-Z, Speccy, QuickMemoryTestOK. | VM limitations should be called out in reports and help text. |
| Crash | BSOD, dump, reliability, crash event work. | Minidump Collector, BlueScreenView, Reliability Monitor, Crash Event Summary. | Minidump collection should copy dump files into toolkit data so BlueScreenView can point at them. |
| Processes | Live process, handle, DLL, startup, and resource inspection. | Process Explorer, Process Monitor, RAMMap, System Informer, Autoruns where appropriate, TCPView if connection ownership is the question. | Process Monitor needs clear prompts/filters because it can generate huge output. |
| Network | Connectivity, routing, port, packet loss, and path testing. | Connectivity Triage, Adapter Route Health, Packet Loss Monitor, Live Route Trace, Test-NetConnection, PsPing, WinMTR, TLS Certificate Check. | DHCP tools do not belong here unless they are only quick target connectivity checks. |
| Infrastructure | DHCP, DNS, time, and local exposure checks. | DHCP Sleuth, DHCP Scope Inspector, DHCP Lease / Rogue Check, DNS Diagnostics, Time Sync Health, Reset to Domain Time, Local Exposure Inspector. | DHCP tools are grouped here. This tab was previously labeled Services. |
| Discovery | Finding hosts, subnets, ARP neighbors, services, and wake targets. | Network Discovery, Port and Service Test, Service Fingerprinter, ARP Inventory Exporter, Subnet Calculator, Wake-on-LAN, Wireshark if used for discovery capture. | Discovery scans should use good prompts and avoid freezing the GUI. |
| Remote | Remote access and file transfer. | Launch RDP, WinSCP, PuTTY, KiTTY, mRemoteNG, RustDesk, TightVNC, Enable Remote Management. | Remote management readiness belongs on Analyze; enabling it belongs here because it changes access posture. |
| PsExec | Guided PsExec command builder. | Presets, credential options, interactive/elevated/system flags, captured output. | This gets its own tab because PsExec needs argument prompts and output handling. |
| Directory | Domain, AD, secure channel, and Group Policy checks. | Domain Logon Health, GPO Health, GPResult-related helpers, ADExplorer, ADInsight, ADRestore. | Domain services are infrastructure-adjacent, but technician intent is directory/policy. |
| Security | Malware, persistence, signatures, privacy, hardening. | Microsoft Safety Scanner, Malwarebytes AdwCleaner, ClamWin, Sigcheck, HijackThis, xpy, password tools. | Defender Security Check should sit with malware/security scanners when presented as a security action. |
| Wi-Fi | Wireless-specific checks. | Wi-Fi Issue Scan, Wi-Fi Status, Wi-Fi Profiles, Wi-Fi Networks, Wi-Fi Backup / Restore. | Keep separate from Network because wireless problems have distinct profile/radio/authentication causes. Profile backup/restore belongs here because it is a wireless migration and recovery workflow, not a general network test. |
| Print | Printing and queue maintenance. | Print Queue Maintenance, Print Spooler Triage, Stale Printer Cleanup. | Custom print queue tools belong here. |
| Files | File search, comparison, space, locks, and file-level utilities. | Everything, WizTree, WinDirStat, WinMerge, Kudu, Handle, LockHunter where appropriate. | Cleanup-focused tools can move to Clean Up if the main purpose is removal. |
| Robocopy | Plain-language robocopy builder. | Build, Copy, Preview, Run. | Dedicated tab is justified because the builder is a real workflow, not just a launcher. |
| Software | General portable productivity/support apps. | Firefox Portable, Notepad++, LibreOffice, Draw.io, KompoZer, links to safe software sources. | Do not mix Choco management here. |
| Software Keys | Local product/license key discovery. | Windows/software key discovery GUI. | Keep separate because key discovery is sensitive and distinct from general software management. |
| Clean Up | Cleanup, uninstallers, stale profiles, leftovers. | BleachBit, CCleaner, Bulk Uninstaller, Revo Uninstaller, Wise Registry Cleaner, Profile Cleanup, Recuva if recovery/remediation is needed. | Use careful wording because cleanup tools can remove data. |
| Choco | Chocolatey package workflows. | Install Chocolatey, search packages, install selected, scan installed, upgrade selected/all, uninstall from computer, add to toolbox. | Computer-installed packages and toolkit-installed packages must be clearly distinguished. |
| Sysinternals | Fallback for Sysinternals tools with no better tab. | ShellRunas, portmon, notmyfault, obscure utilities. | If a Sysinternals tool clearly fits a functional tab, place it there instead. |
| Reports | Technician-facing output. | Search, Refresh Reports, Open Selected, Delete Selected, AI bundle/import/final report workflows where available. | Do not list raw logs or JSON noise here. |

## DHCP Decision

DHCP tooling belongs under **Infrastructure**, not Network.

| Tool | Why It Belongs On Infrastructure |
| --- | --- |
| DHCP Sleuth | It investigates DHCP server behavior and rogue responders, not just endpoint reachability. |
| DHCP Scope Inspector | It reviews DHCP scope/lease health where available. |
| DHCP Lease / Rogue Check | It performs a lightweight one-shot DHCP evidence check from the workstation perspective. |

The Network tab should answer "can I reach the target and through what path?" Infrastructure should answer "are the dependency services behaving correctly?"

## Known Documentation Rule

When tab names change in the GUI, update this file, `NetworkToolkitHelp.html`, `ProductionReadiness.md`, and the root `README.md` in the same change.
