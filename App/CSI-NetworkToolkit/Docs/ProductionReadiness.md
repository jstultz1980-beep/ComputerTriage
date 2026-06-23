# Production Readiness

## Full Portable Build

The production package is built with `Build-ProductionPackage.ps1`. It creates a clean `Release\NetworkToolkit-Portable` deployment folder suitable for copying directly to a thumb drive.

Launch the toolkit with `NetworkToolkit.vbs`. After copying the folder to removable media, run `App\Test-ProductionPackage.ps1` from the copied folder to verify the primary launch-file hashes and confirm that no client reports, profiles, state, dumps, or Git metadata were included.

The package builder excludes:

- Git metadata and prior release output
- Toolkit reports, exports, logs, minidumps, temporary sessions, and saved computer state
- Existing GUI settings
- The existing Firefox Portable profile and browser cache

It preserves the full diagnostic payload, including Sysinternals, Wireshark/Npcap, ClamWin definitions, Microsoft Safety Scanner, hardware tools, remote tools, and the bundled .NET runtime.

## Efficiency Findings

The toolkit scripts are intentionally modular. The complete PowerShell code footprint is under 1 MB, while the full portable payload is roughly 4.6 GB. Consolidating scripts into fewer files would save an insignificant amount of space and make the application harder to maintain, so it is not recommended.

The largest payloads are optional applications rather than toolkit code:

| Component | Approximate size | Production role |
| --- | ---: | --- |
| LibreOffice Portable | 888 MB | Office document work; optional for troubleshooting |
| Firefox Portable | 802 MB | Portable browser; optional when the technician has an approved browser |
| Draw.io Portable | 406 MB | Diagramming; optional |
| Kudu Portable | 401 MB | File management; optional |
| Wireshark Portable | 381 MB | Packet capture and protocol inspection |
| Sysinternals | 244 MB | Core diagnosis and administration tools |
| ClamWin definitions | 167 MB | Offline malware signature coverage |
| Microsoft Safety Scanner | 212 MB | On-demand Microsoft malware scan |

## Future Field-Lite Profile

For a smaller emergency drive, create a separate field-lite package rather than deleting tools from the full package. Keep Quick Diagnosis, Sysinternals, hardware tools, Wireshark/Npcap, remote tools, crash tools, repair tools, and security scanners. Make LibreOffice, Firefox, Draw.io, and Kudu optional add-on folders. That reduces size substantially while keeping the main diagnostic workflow intact.

## Client Data Hygiene

After each engagement, use **Settings > Remove Client Data**. The action requires two confirmations, including typing `REMOVE CLIENT DATA`, and removes collected diagnostic artifacts while preserving the applications and technician settings.
