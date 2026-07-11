# High-Risk Plugin Assessment

Task: `TASK-0084-Full-Codebase-Architecture-And-Quality-Audit`
Status: In Progress

## Scope Reviewed

- Quick Diagnosis
- Windows Health Diagnostics
- Remote Management
- Print Queue Tools
- Standalone Print Spooler Tool
- File Utilities / Robocopy Builder
- External Tool Manager
- Software Key Finder
- Shared process launcher

## Findings

### PLG-001 - Print “Clear All Queues” does not reliably delete queue files but reports success

Severity: High
Location: `App/NetworkToolkit/Plugins/PrintQueues/Print Queue Cleanup/PrinterSpoolerTool.ps1`

Evidence:

```powershell
Remove-Item -LiteralPath "$env:SystemRoot\System32\spool\PRINTERS\*" -Force -ErrorAction SilentlyContinue
```

`-LiteralPath` does not expand `*`. The failure is suppressed, the spooler is restarted, and the UI reports `All queues cleared and spooler restarted.`

Impact:
Technicians can believe the stuck queue was cleared when no files were removed.

Recommendation:
Use a validated directory path and enumerate/remove children explicitly. Record deletion count and failures. Restart the spooler in `finally` and verify it is running before success.

### PLG-002 - Stale-printer cleanup prints completion after per-item failures

Severity: High
Location: `PrintQueues.ps1`

Evidence:
`Remove-StaleLocalPrinterArtifact` catches errors and only writes console text. The parent loop cannot observe failure and always prints `Cleanup complete.`

Impact:
Partial cleanup appears successful; stale drivers/ports/registry entries remain.

Recommendation:
Return structured results per artifact and summarize Completed, Partial, or Failed.

### PLG-003 - Print-spooler destructive operation lacks guaranteed service recovery

Severity: High
Location: `PrinterSpoolerTool.ps1`

Evidence:
The code stops the spooler, attempts deletion, and starts it sequentially without a `finally` block. A terminating error after stop can leave the service stopped.

Impact:
Print service outage after failed repair.

Recommendation:
Capture pre-state, execute cleanup, restore service state in `finally`, and verify service readiness.

### PLG-004 - `SupportsShouldProcess` is declared but not used

Severity: Medium
Location: `PrinterSpoolerTool.ps1`

Evidence:
The script declares `[CmdletBinding(SupportsShouldProcess = $true)]` but destructive functions do not call `$PSCmdlet.ShouldProcess()`.

Impact:
`-WhatIf`/`-Confirm` semantics are implied but ineffective.

Recommendation:
Move destructive operations into advanced functions that correctly implement ShouldProcess, or remove the misleading declaration and rely on explicit UI confirmation.

### PLG-005 - Remote-management enablement is broad, non-transactional, and has no rollback

Severity: High
Location: `RemoteManagement.ps1`

Evidence:
One action:
- Enables PowerShell remoting.
- Sets WinRM and Remote Registry to Automatic.
- Starts services.
- Enables six broad firewall display groups, including File and Printer Sharing, WMI, Event Log, Scheduled Tasks, and Remote Service Management.
- May execute remotely as SYSTEM through PsExec.

No pre-change snapshot or rollback path is recorded.

Impact:
A convenience action materially changes host exposure and security posture. Partial failure can leave an undocumented mixed state.

Recommendation:
Split readiness assessment from enablement. Present an explicit change plan, capture pre-state, apply only selected capabilities, verify each change, and provide rollback.

### PLG-006 - Remote service start attempts can be reported OK after failure

Severity: High
Location: `Get-NTKRemoteManagementEnableBlock`

Evidence:
`Start-Service` uses `-ErrorAction SilentlyContinue`, followed by an unconditional `OK` result stating startup was attempted.

Impact:
WinRM or Remote Registry may remain stopped while the result appears successful.

Recommendation:
Use terminating errors or verify final state before recording OK.

### PLG-007 - External tools execute based on path existence without provenance enforcement

Severity: High
Location: `ExternalToolManager.ps1` and embedded/custom tool directories

Evidence:
The catalog resolves the first existing expected path and launches it, sometimes elevated. No signature, hash, publisher, package manifest, or trusted-source verification is required at launch time.

Impact:
A replaced or tampered executable at an expected path can be executed with administrative rights.

Recommendation:
Add package-level hashes and optional Authenticode publisher checks. Block or warn on mismatch according to tool policy.

### PLG-008 - External tool paths intentionally escape the ExternalTools root

Severity: Medium
Location: `ExternalToolManager.ps1`

Evidence:
Catalog entries include paths such as `..\..\Custom\...` and are joined to the ExternalTools root before resolution.

Impact:
The trust boundary is not actually the ExternalTools directory. Path ownership and packaging rules are harder to reason about.

Recommendation:
Represent each tool with an explicit root classification (`ExternalTools`, `Custom`, system PATH) and reject unexpected traversal.

### PLG-009 - Sysinternals EULA acceptance is automated without an explicit acceptance event

Severity: Medium
Location: `Set-NTKSysinternalsEulaAccepted`, `Add-NTKSysinternalsEulaArgument`

Evidence:
The toolkit creates `EulaAccepted=1` registry values and adds acceptance arguments automatically.

Impact:
The application records legal/tool acceptance without a tracked technician action or acceptance record.

Recommendation:
Document the policy and obtain one explicit toolkit-level acceptance before setting vendor EULA state. Do not silently accept during unrelated diagnostics.

### PLG-010 - Legacy and security-remediation executables are cataloged without lifecycle policy

Severity: High
Location: External Tool catalog

Evidence:
The catalog includes malware scanners, AdwCleaner, ClamWin, Microsoft Safety Scanner, Npcap installer, registry editors, PsExec, and a legacy Junkware Removal Tool entry.

Impact:
Expired signatures, outdated binaries, unsupported tools, licensing restrictions, or EDR classifications can make the portable payload unsafe or unreliable.

Recommendation:
Create a tool lifecycle manifest with source, version, hash, signature, license, update cadence, expiration, usage classification, and package inclusion decision.

### PLG-011 - Software Key Finder writes full sensitive values to plaintext portable storage

Severity: High
Location: `SoftwareKeyFinder.ps1`

Evidence:
Recovered Windows, Office, and application registration values are written in full to an HTML file under `NetworkToolkit\Exports`.

Impact:
The report can be copied, transferred, lost with the USB drive, included in support archives, or accessed by another user.

Recommendation:
Require explicit technician confirmation, default to masked values, provide a reveal/export action, and classify the output as sensitive with restricted retention.

### PLG-012 - Sensitive key reports are outside the current retention patterns

Severity: High
Location: `SoftwareKeyFinder.ps1` and `ReportingRetention.ps1`

Evidence:
Retention patterns cover quick diagnosis, computer profile, full triage, robocopy, DISM, and SFC files. They do not include `software-key-report-*.html`.

Impact:
Full licensing values may remain indefinitely on portable storage.

Recommendation:
Add a short sensitive-report retention class or do not persist unmasked keys by default.

### PLG-013 - Client data transfer copies sensitive reports without classification or encryption

Severity: Medium/High
Location: `ClientDataTransfer.ps1`

Evidence:
The transfer includes the entire Exports, Logs, Triage Runs, Profiles, and Data trees. It distinguishes application code from client data but does not classify sensitive reports within those roots.

Impact:
Software keys, logs, network information, process lists, dumps, and other customer evidence are moved in plaintext.

Recommendation:
Inventory transferred content by sensitivity, provide an exclusion/selection policy, and support encrypted destination or archive workflows where appropriate.

### PLG-014 - Retention protects evidence through unreliable keyword sampling

Severity: High
Location: `ReportingRetention.ps1`

Evidence:
For a directory, only the first ten files at or below 2 MB are scanned for a limited regex. If none match, the directory may be deleted by age/count policy.

Impact:
Critical evidence in the eleventh file, a larger file, JSON field, dump, or different terminology can be deleted. Benign text containing `critical` can also prevent cleanup indefinitely.

Recommendation:
Use explicit case/pin metadata and structured severity fields. Do not infer preservation from a shallow text scan.

### PLG-015 - Computer-state writes are non-atomic and concurrent updates can be lost

Severity: Medium/High
Location: `ComputerState.ps1`

Evidence:
State is read, mutated, and written directly with `Set-Content` to the final path. There is no temp-file swap, lock, generation check, or backup.

Impact:
Process interruption can corrupt JSON; concurrent GUI/tool updates can overwrite each other; parse failure silently falls back to a new document.

Recommendation:
Use atomic temp-write/replace with backup, locking, and schema validation. Preserve corrupt state for diagnosis rather than silently replacing it.

### PLG-016 - Quick Diagnosis duplicates the future-state analysis pipeline

Severity: High
Location: `QuickDiagnosis.ps1`

Evidence:
Quick Diagnosis contains its own:
- evidence collection
- health classification
- deterministic finding creation
- plain-language explanation
- deep-dive correlation
- driver candidate heuristics
- remediation guidance
- HTML report rendering

These responsibilities overlap deterministic analysis, ARGUS grouping/recommendations, and reporting.

Impact:
Two diagnostic truth systems can disagree about severity, confidence, evidence, and recommended action. Fixes must be made in multiple places.

Recommendation:
Define Quick Diagnosis as either a lightweight live collector/view over shared analysis services or a separate explicitly limited product. Move shared rules and explanations behind canonical services over time.

### PLG-017 - Quick Diagnosis “OK” language can exceed evidence strength

Severity: Medium/High
Location: Quick Diagnosis health/report functions

Evidence:
Several successful checks produce statements such as `Error free`, `No blocking issues detected`, or generalized OK explanations after narrow queries. Many underlying command/CIM failures are converted to Info or swallowed.

Impact:
Technicians may interpret a narrow negative check as subsystem health.

Recommendation:
Use `No issue detected by this check` rather than `Error free`, retain check coverage and limitations, and distinguish unavailable from healthy.

### PLG-018 - GUI is a monolithic mutable-state controller

Severity: High
Location: `App/ToolKit-GUI/ToolKit-GUI.ps1`

Evidence:
The approximately 16,941-line script initializes well over one hundred script-scoped controls, processes, timers, caches, jobs, result paths, flags, and layout objects before defining UI behavior.

Impact:
High coupling, difficult lifecycle reasoning, weak test isolation, expensive changes, event/timer leak risk, and accidental cross-tab state interactions.

Recommendation:
Do not rewrite wholesale. Extract one workflow/controller at a time behind stable interfaces, starting with Analyze/Triage async process management and shared status/result handling.

### PLG-019 - GUI duplicates process/timer state for many workflows

Severity: Medium/High
Location: GUI script state initialization and workflow handlers

Evidence:
Separate process, timer, session, result-path, completion, and status variables exist for Quick Diagnosis, toolkit size, update, deployment, triage, public IP, Chocolatey, Windows Update, PsExec, activity refresh, and others.

Impact:
Repeated lifecycle code and inconsistent cancellation/error handling.

Recommendation:
Introduce a generic background-operation controller with explicit states, cancellation, polling, result parsing, cleanup, and UI binding.

### PLG-020 - Robocopy result is displayed but not interpreted

Severity: Medium
Location: `FileUtilities.ps1`

Evidence:
The builder runs `robocopy.exe` and prints `$LASTEXITCODE` without mapping Robocopy’s 0-7 success/warning codes and 8+ failure codes.

Impact:
Technicians must interpret the code manually, and surrounding workflows cannot reliably know success.

Recommendation:
Map exit codes to structured state and summary. Preserve explicit confirmation for `/MIR`.

## Positive Controls Observed

- Print destructive buttons require explicit confirmation.
- Stale printer cleanup distinguishes low and medium risk and requires `CLEAN` confirmation.
- Robocopy `/MIR` is explained and execution requires `RUN`.
- Software Key Finder explicitly states that it does not retrieve passwords or tokens.
- Remote management returns per-step result objects rather than one boolean.
- ARGUS recommendations currently set `safeToAutomate` false.

These controls should be retained while correcting false-success, rollback, and trust issues.
