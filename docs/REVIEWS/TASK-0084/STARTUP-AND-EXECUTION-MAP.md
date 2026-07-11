# Startup and Execution Map

Task: `TASK-0084-Full-Codebase-Architecture-And-Quality-Audit`
Status: In Progress

## 1. Normal User Launch

```text
NetworkToolkit.vbs
  -> resolves repository/deployment root
  -> resolves App/NetworkToolkit.ps1
  -> ShellExecute powershell.exe with runas
  -> hidden, STA, ExecutionPolicy Bypass

App/NetworkToolkit.ps1
  -> sets ErrorActionPreference Stop
  -> creates per-user mutex unless smoke testing
  -> publishes mutex as global state
  -> routes to:
       GUI: App/ToolKit-GUI/ToolKit-GUI.ps1
       CLI: App/NetworkToolkit/NetworkToolkit-Core.ps1
  -> exits using ambient LASTEXITCODE
  -> releases mutex in finally
```

Primary concerns:
- Normal launch always elevates.
- PowerShell execution policy is bypassed.
- Exit status is not explicitly modeled for PowerShell function failures.
- Mutex ownership is communicated through a global variable.

## 2. CLI/Core Startup

```text
NetworkToolkit-Core.ps1
  -> resolve App/NetworkToolkit root
  -> dot-source Config/ToolkitPaths.ps1
       -> publish Global:NTKPaths and Global:NTKFiles
  -> dot-source Config/CommandRegistry.ps1
       -> publish Global:NTKRegistry
  -> optional dot-source ToolCatalog.ps1
  -> initialize Global:NTKImportFailures
  -> create runtime folders in app tree
  -> initialize Toolkit.log
  -> dot-source Utilities/*.ps1 in filename order
  -> optional retention cleanup by command existence
  -> dot-source Core/*.ps1 in filename order
  -> dot-source Discovery/*.ps1 in filename order
  -> load Plugins/*/PluginManifest.psd1 and plugin script
  -> dot-source UI/*.ps1 in filename order
  -> assert only Start-NetworkConsole exists
  -> invoke named command or interactive console
```

Failure propagation:
- Individual module/plugin load failures are recorded and startup continues.
- Required versus optional modules are not formally declared.
- Missing cleanup helpers are silently skipped.
- Command exceptions are printed and swallowed.
- Process exit code may remain zero.

## 3. GUI Startup

```text
App/ToolKit-GUI/ToolKit-GUI.ps1
  -> consumes same shared module/plugin ecosystem
  -> builds Windows Forms interface
  -> resolves tool catalog and custom-tool manifest
  -> constructs tabs and workflow controls
  -> exposes Collect / Analyze / Review workflow
  -> uses safe/embedded runners for selected commands
  -> opens generated reports and bundle folders
```

Known architecture characteristic:
- The GUI script is approximately 16,941 lines and contains construction, styling, state management, workflow orchestration, status polling, launch behavior, and validation hooks in one file.

Audit focus:
- first-render blocking work
- timers/event-handler lifecycle
- duplicate UI state sources
- exception handling and false-success presentation
- direct process/file-system operations inside event handlers
- callback closure/scope behavior
- safe-runner result interpretation
- smoke-test depth versus real behavior

## 4. Triage Collection Workflow

```text
Invoke-NTKTriageRun
  -> create run folder and child directories
  -> preflight Test-NTKTriageSetup
  -> execute native command plan
  -> execute PowerShell collectors
  -> export event summaries
  -> inventory/copy dumps and selected logs
  -> resolve optional portable tools
  -> run selected/auto-run tools
  -> write command/tool/status artifacts
  -> Invoke-NTKTriageAnalysis
  -> write collection manifest and inventory
  -> create ZIP
  -> calculate ZIP hash
  -> rewrite manifest with hash
  -> recreate ZIP
  -> post-run validation
  -> write validation_summary.txt
  -> return Completed result
```

Confirmed integrity failures:
- Stored ZIP hash describes the pre-rebuild ZIP.
- PowerShell collector failure records are discarded.
- Final PASS lines are hard-coded.
- Completed does not require preflight/post-run success.

## 5. Supplemental AI Collection Workflow

```text
New-NTKAIDiagnosticCollection
  -> create export folder
  -> invoke named collector sections
       -> each section runs commands/CIM/registry/event reads
       -> safe writers return true/false
       -> section wrapper marks Completed unless exception escapes
  -> write section status and artifacts
```

Confirmed status problem:
- Inner command/write failures are frequently discarded, so section status can be Completed with failed or invalid artifacts.

## 6. Deterministic Analysis Workflow

```text
Invoke-HEPHAESTUSLocalAnalysis
  -> choose supplied or latest export directory
  -> create Analysis/normalized and Metadata directories
  -> recursively inventory bundle files
  -> build machine profile using live host CIM/env
  -> score evidence using filename-pattern presence
  -> build timeline using file LastWriteTime
  -> build findings from missing categories, live C: disk state, and first matching evidence text
  -> write schema/capability/findings/timeline/score/profile/report
  -> return Completed
```

Confirmed boundary/integrity failures:
- Offline bundle data is mixed with live analysis-host data.
- Generated output directories enter subsequent inventories.
- Filename match is treated as parsed evidence.
- File timestamps are presented as timeline events.
- Empty or unrelated directories can be selected/created as bundle roots.

## 7. ARGUS Workflow

```text
Invoke-ARGUSFoundationAnalysis
  -> choose supplied or latest export directory
  -> parse required deterministic-analysis artifacts
  -> validate schema/capabilities/required files
  -> build analysis summary
  -> dot-source normalization, recommendation, and reporting modules
  -> build normalized facts/gaps/citations
  -> write normalized-analysis.json
  -> create diagnostic groups and root-cause candidates
  -> create technician recommendations
  -> write foundation report
  -> write technician and escalation reports
  -> return Status Completed
```

Confirmed failure propagation issue:
- Required contract failure still proceeds through normalization, grouping, recommendations, and reporting.
- Final returned status is Completed even when input validation is failed.

## 8. Package Build Workflow

```text
Build-ProductionPackage.ps1
  -> update source toolkit-version manifest
  -> optionally delete existing package root
  -> robocopy App excluding runtime folders
  -> copy VBS launcher
  -> recreate empty runtime folders
  -> recursively clear plugin Logs and Custom/Data contents
  -> remove GUI settings
  -> hash four primary launchers
  -> write ProductionManifest.json and deployment README
  -> optional ZIP
```

Audit concerns:
- Build mutates source metadata.
- Package integrity covers only four launchers, not full managed payload or embedded binaries.
- Recursive Data deletion is name-based rather than manifest-owned.

## 9. Fresh Deployment Workflow

```text
Deploy-NetworkToolkit.ps1
  -> validate source marker
  -> reject drive root and same source/destination
  -> create destination
  -> delete all existing destination contents
  -> copy App with fresh exclusions
  -> clear portable Data folders
  -> copy launcher
  -> verify a small required-file list
  -> write result JSON
```

Audit concerns:
- Destructive deletion occurs before complete staged-image validation.
- No rollback.
- Destination identity protection is limited to not-drive-root and not-source.

## 10. Update Workflow

```text
Update-NetworkToolkit.ps1
  -> resolve source/destination layouts
  -> optionally migrate legacy layout in place
  -> compare version/build
  -> same build: prune obsolete program files and return Current
  -> newer build: robocopy with update exclusions
  -> prune obsolete program/root files
  -> hash-verify five files
  -> copy launcher and remove root artifacts
  -> return Completed
```

Confirmed failure risks:
- Prune failures are counted but do not fail update.
- Verification omits most managed code and embedded payload.
- No transactional staging or rollback.

## 11. Shutdown and Cleanup

Known paths:
- Main launcher releases singleton mutex in finally.
- CLI writes toolkit exit log after console termination.
- Temp/report retention runs opportunistically at startup if helper functions loaded.
- Native child-process cleanup varies by plugin/runner.
- GUI timer and event-handler disposal remains under review.

## Cross-Layer Status Vocabulary Problem

Current layers use overlapping but inconsistent states:

- Completed
- Failed
- FailedNonFatal
- passed
- failed
- limited
- normal
- Current
- Running
- warnings
- boolean succeeded
- hard-coded PASS

There is no single contract defining which states permit downstream analysis, recommendations, UI success, process exit zero, or deployment acceptance.

A shared result model is likely required:

```text
Succeeded
SucceededWithWarnings
Partial
Blocked
Failed
Canceled
```

Each layer should preserve required-stage outcomes, optional gaps, errors, warnings, and source identity without translating failure into Completed.
