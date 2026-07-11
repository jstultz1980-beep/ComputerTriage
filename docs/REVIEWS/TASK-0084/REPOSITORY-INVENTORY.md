# Operational Repository Inventory

Task: `TASK-0084-Full-Codebase-Architecture-And-Quality-Audit`
Status: In Progress
Baseline: current tracked `master`

## Scale Summary

The current repository is approximately 260 commits beyond its initial baseline and contains a large PowerShell application surface:

- One VBScript elevated launcher.
- Two primary PowerShell entry paths.
- One approximately 16,941-line Windows Forms GUI.
- A central command registry and tool catalog.
- Deterministic analysis engine and rule catalog.
- Four ARGUS modules.
- More than twenty plugins/custom applications.
- Multiple deployment, update, package, version, and test scripts.
- Numerous embedded third-party executables.
- Extensive task/governance documentation.

## 1. Primary Entry Points

| Path | Purpose | Owner | Inputs | Outputs / Side Effects | Status |
|---|---|---|---|---|---|
| `NetworkToolkit.vbs` | User-facing double-click launcher | Launcher | Forwarded CLI arguments | Starts elevated hidden PowerShell process | Operational; High privilege finding RUN-001 |
| `App/NetworkToolkit.ps1` | Single PowerShell dispatcher | Orchestration | `-CLI`, `-RunCommand`, smoke switches | Mutex, routes to CLI core or GUI | Operational |
| `App/NetworkToolkit/NetworkToolkit-Core.ps1` | CLI/runtime loader and console command host | Orchestration | command name, no-console mode | Loads modules/plugins, creates runtime dirs/logs, invokes command | Operational; partial-load and exit-code findings |
| `App/ToolKit-GUI/ToolKit-GUI.ps1` | Main Windows Forms UI | UI | smoke/button-smoke switches | Constructs UI, runs workflows, launches tools | Operational; very high complexity surface |
| `App/NetworkToolkit/UI/Start-NetworkConsole.ps1` | Interactive console entry | UI/CLI | registered commands | Text console workflow | Operational |

## 2. Runtime Configuration and Registries

| Path | Purpose | Side Effects / Risks |
|---|---|---|
| `App/NetworkToolkit/Config/ToolkitPaths.ps1` | Resolves application, runtime, manifest, and custom paths | Publishes global mutable path objects; runtime data lives under app tree |
| `App/NetworkToolkit/Config/CommandRegistry.ps1` | Registers and invokes commands | Global registry; later duplicate replaces earlier entry |
| `App/NetworkToolkit/Config/ToolCatalog.ps1` | Canonical GUI/tool placement catalog | Used by GUI/search/smoke validation |
| `App/NetworkToolkit/Config/ToolkitManifest.psd1` | Product/module metadata | Static metadata; requires consistency review |
| `App/manifests/custom-tools.json` | Portable/custom tool source of truth | Known runtime/local drift |
| `App/manifests/triage-tools.json` | Triage tool definitions | May be regenerated from code defaults |
| `App/manifests/toolkit-version.json` | Build/update comparison metadata | Mutated by build/version workflow |
| `App/manifests/gui-settings.json` | User GUI preferences | Runtime-only; excluded from packages/updates |

## 3. Deterministic Analysis

| Path | Purpose | Inputs | Outputs | Status / Findings |
|---|---|---|---|---|
| `App/NetworkToolkit/Core/LocalAnalysisEngine.ps1` | Deterministic bundle analysis | Bundle directory and current runtime computer | Findings, timeline, evidence score, machine profile, capability/schema metadata, HTML report | Operational; Critical cross-machine contamination and multiple High integrity findings |
| `App/NetworkToolkit/Core/LocalAnalysisRules.ps1` | Rule catalog override/expansion | Inventory plus selected raw text artifacts | Deterministic findings | Operational; text/regex-driven and live CIM dependency |
| `App/NetworkToolkit/Core/ArgusFoundationCommand.ps1` | Registers ARGUS command in toolkit | CLI/GUI command | Calls Core ARGUS foundation | Operational |

## 4. ARGUS

| Path | Purpose | Inputs | Outputs | Status / Findings |
|---|---|---|---|---|
| `Core/Argus/ArgusFoundation.ps1` | Contract loading, validation, summary, orchestration | Deterministic analysis artifacts | Input validation, analysis summary, normalized analysis, groups, recommendations, reports | Operational; continues on failed required contract and returns Completed |
| `Core/Argus/ArgusNormalization.ps1` | Builds fact, gap, domain, and citation model | Parsed deterministic/normalized artifacts | `normalized-analysis.json` | Operational; citation and domain-mapping review ongoing |
| `Core/Argus/ArgusRecommendations.ps1` | Groups facts/gaps and emits technician guidance | Normalized analysis | Diagnostic groups and recommendations | Operational; conservative automation flag; confidence propagation review ongoing |
| `Core/Argus/ArgusReporting.ps1` | Technician and escalation Markdown reports | ARGUS structured artifacts | `technician-report.md`, `escalation-report.md` | Operational; relies on upstream truthfulness |

## 5. Collection and Triage Utilities

| Path | Purpose | Major Side Effects | Status / Findings |
|---|---|---|---|
| `App/NetworkToolkit/Utilities/TriageService.ps1` | Full/quick/crash triage, external tools, bundle generation | Runs system commands, CIM, event reads, copies dumps/logs, creates ZIP | Operational; stale bundle hash, hard-coded PASS, discarded collector failures |
| `App/NetworkToolkit/Utilities/AIBundleCollector.ps1` | Supplemental broad evidence collection | Reads registry/services/drivers/events/network/domain data; writes many artifacts | Operational; false Completed status and invalid structured artifact behavior |
| `App/NetworkToolkit/Utilities/ComputerState.ps1` | Current computer state/profile support | Reads and writes computer state | Operational; detailed review pending |
| `App/NetworkToolkit/Utilities/ComputerState.ps1` | Computer profile/state persistence | Runtime data mutation | Operational |
| `App/NetworkToolkit/Utilities/ClientDataTransfer.ps1` | Transfer technician/client data between toolkit copies | Copies runtime data | Operational; boundary/security review pending |
| `App/NetworkToolkit/Utilities/ProcessLauncher.ps1` | Shared process launch/temp session helper | Starts native processes, creates/deletes temp output | Operational; quoting and retention review pending |
| `App/NetworkToolkit/Utilities/ReportingRetention.ps1` | Report/log/temp quotas | Deletes aged runtime files | Operational; partial failure reporting review pending |
| `App/NetworkToolkit/Utilities/Logging.ps1` | Shared logging | Writes logs | Operational |
| `App/NetworkToolkit/Utilities/ConsoleHelpers.ps1` | Console input/output helpers | Console state | Operational |
| `App/NetworkToolkit/Utilities/Convert-IPFunctions.ps1` | IP/CIDR conversion helpers | None expected | Operational |

## 6. Core/Discovery Commands

| Path | Purpose | Status |
|---|---|---|
| `App/NetworkToolkit/Core/Invoke-NetworkPingUtility.ps1` | CIDR ping utility | Operational |
| `App/NetworkToolkit/Core/Invoke-NetworkScan.ps1` | Local network scan | Operational |
| `App/NetworkToolkit/Core/Invoke-PortScan.ps1` | Port scan | Operational |
| `App/NetworkToolkit/Discovery/Get-NetworkNeighbors.ps1` | Neighbor discovery | Operational |
| `App/NetworkToolkit/Discovery/Get-NetworkTopology.ps1` | Local topology discovery | Operational |

## 7. Plugins

| Plugin | Main Path | Approximate Size / Complexity | Purpose | Audit Priority |
|---|---|---:|---|---|
| ARP Inventory Exporter | `Plugins/ARPInventoryExporter/ARPInventoryExporter.ps1` | Small | Export ARP inventory | Medium |
| Chocolatey Tools | `Plugins/ChocolateyTools/ChocolateyTools.ps1` | 268 lines | Package status/actions | Medium; privileged/process actions |
| Computer Fingerprint | `Plugins/ComputerFingerprint/ComputerFingerprint.ps1` | 1,027 lines | Capture/compare computer profile | High |
| DHCP Diagnostics | `Plugins/DHCPDiagnostics/DHCPDiagnostics.ps1` | 921 lines | DHCP diagnostics | High |
| DHCP Scope Inspector | `Plugins/DHCPScopeInspector/DHCPScopeInspector.ps1` | Small | DHCP scope inspection | Medium |
| DNS Toolkit | `Plugins/DNSToolkit/DNSToolkit.ps1` | Medium | DNS diagnostics | Medium |
| External Tool Manager | `Plugins/ExternalToolManager/ExternalToolManager.ps1` | 794 lines | Tool discovery/configuration | High; provenance and manifest mutation |
| File Utilities | `Plugins/FileUtilities/FileUtilities.ps1` | 331 lines | File operations | High; destructive operations |
| Live Troubleshooting | `Plugins/LiveTroubleshooting/LiveTroubleshooting.ps1` | 659 lines | Live monitoring/actions | High; timers/process/network activity |
| Network Diagnostics | `Plugins/NetworkDiagnostics/NetworkDiagnostics.ps1` | Small | Network command grouping | Medium |
| Print Queues | `Plugins/PrintQueues/PrintQueues.ps1` | 426 lines | Printer diagnostics/actions | High; spooler changes |
| Print Spooler Tool | `Plugins/PrintQueues/Print Queue Cleanup/PrinterSpoolerTool.ps1` | 575 lines | Spooler repair/cleanup | High; destructive/admin actions |
| Quick Diagnosis | `Plugins/QuickDiagnosis/QuickDiagnosis.ps1` | 2,451 lines | Rapid diagnostic report/workflow | Very High; large multi-responsibility component |
| Remote Management | `Plugins/RemoteManagement/RemoteManagement.ps1` | 528 lines | Enable/test remote management | Very High; firewall/service/security changes |
| Report Exporter | `Plugins/ReportExporter/ReportExporter.ps1` | 293 lines | Report export | Medium |
| Service Fingerprinter | `Plugins/ServiceFingerprinter/ServiceFingerprinter.ps1` | Small | Service inventory | Medium |
| Software Key Finder | `Plugins/SoftwareKeyFinder/SoftwareKeyFinder.ps1` | 271 lines | Product-key discovery | High; sensitive data |
| Subnet Calculator | `Plugins/SubnetCalculator/SubnetCalculator.ps1` | Small | Calculation | Low |
| Tool Groups | `Plugins/ToolGroups/ToolGroups.ps1` | 172 lines | Grouped launcher/catalog | Medium |
| Wake-on-LAN | `Plugins/WakeOnLANTool/WakeOnLANTool.ps1` | Small | Magic packet sender | Low/Medium |
| Wi-Fi Diagnostics | `Plugins/WiFiDiagnostics/WiFiDiagnostics.ps1` | 247 lines | Wi-Fi state/reporting | Medium |
| Windows Health Diagnostics | `Plugins/WindowsHealthDiagnostics/WindowsHealthDiagnostics.ps1` | 1,447 lines | Windows health/repair actions | Very High; multi-step privileged repairs |

Each plugin also has a `PluginManifest.psd1` where present. Plugin manifests and script existence are processed dynamically at startup.

## 8. Custom Applications

| Path | Purpose | Size / Status |
|---|---|---|
| `App/Custom/DHCPSleuth/DHCP-Sleuth.ps1` | Standalone DHCP server/client diagnostic application | Approximately 1,828 lines; high-complexity standalone app |
| `App/Custom/DHCPSleuth/README.md` | Usage/documentation | Tracked |
| `App/Custom/DHCPSleuth/VERSION` | App version | Tracked |

Additional portable applications may exist under `App/Custom` and are cataloged by `custom-tools.json`; runtime profiles under `Data` are excluded from production packaging.

## 9. Deployment, Update, Build, and Versioning

| Path | Purpose | Destructive / Mutating Behavior | Status / Findings |
|---|---|---|---|
| `App/Build-ProductionPackage.ps1` | Build clean portable folder/ZIP | Updates source build metadata, deletes existing package with `-Force`, strips runtime Data/Logs | Operational; incomplete integrity manifest |
| `App/Deploy-NetworkToolkit.ps1` | Fresh deployment | Clears selected destination folder | Operational; no transaction/rollback |
| `App/Update-NetworkToolkit.ps1` | In-place update/migration/pruning | Moves legacy layout, copies, prunes stale files/root artifacts | Operational; partial prune can report success; narrow verification |
| `App/DeploymentExclusions.ps1` | Shared fresh/update exclusion policy | Defines preserved/excluded paths | Operational |
| `App/Update-ToolkitVersion.ps1` | Build metadata update | Mutates `toolkit-version.json` | Operational; full review pending |
| `App/Test-ProductionPackage.ps1` | Package verification | Creates/inspects test package | Operational; full review pending |

## 10. Tests and Validation Entry Points

| Path | Coverage | Limitations Identified |
|---|---|---|
| `App/NetworkToolkit/Tests/Test-ToolkitSmoke.ps1` | Loader, catalog entries, duplicate IDs, selected required commands | Does not assert import failure list is empty or negative/failure paths |
| `App/NetworkToolkit/Tests/Test-TriageService.ps1` | Manifest creation, status enumeration, one successful `cmd.exe` command, setup validation | Does not run full triage or test partial/failure states |
| `App/Test-ProductionPackage.ps1` | Production package behavior | Detailed review pending |
| GUI `-SmokeTest` | GUI load | Does not by itself prove workflows |
| GUI `-ButtonSmokeTest` | Control existence/callback wiring and selected resolved state | Requires deeper review for behavioral assertions |

## 11. Embedded Third-Party Tools

Tracked embedded executables include, at minimum:

- NirSoft AppCrashView.
- CurrPorts.
- DriverView.
- EventLogChannelsView.
- FullEventLogView.
- NetworkInterfacesView.
- ServiWin.
- USBDeview.
- ESET SysInspector binary.
- MiTeC executables.
- LatencyMon.

Other portable tools may be installed under `App/Custom` or `App/NetworkToolkit/ExternalTools` and referenced by manifests.

Audit requirements:
- Hash/provenance inventory.
- License and redistribution review.
- Architecture/bitness check.
- EDR/allowlisting guidance.
- Package inclusion/exclusion classification.
- No evasion or binary renaming strategy.

## 12. Documentation and Governance

Primary operational governance files:

- `PROJECT.md`
- `AGENTS.md`
- `docs/CODEX-CLI-OPERATING-INSTRUCTIONS.md`
- `docs/GOVERNANCE/NON-INTERRUPTION-GUARDRAIL.md`
- `docs/HANDOFF.md`
- `docs/TASKS/QUEUE.md`
- `docs/ERROR-HANDOFF.md`
- `docs/HISTORY/CHANGE-LEDGER.md`
- `docs/HISTORY/CHANGELOG.md`
- ADRs, design docs, task files, reviews, roadmap, finish plan, and deployment inventory.

## Inventory Status

The primary operational surface is now inventoried. Remaining inventory work is to:

- Add exact function-level callers/dependencies for the GUI and highest-priority plugins.
- Verify current tracked embedded-tool versions/hashes from manifests.
- Reconcile all documentation-only legacy files and stale worklog files.
- Identify orphaned scripts not referenced by launchers, catalogs, manifests, tests, or deployment files.
