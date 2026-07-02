# TASK-0031 - Triage Page Simplification

## Status
Completed

## Owner
Codex

## Objective
Simplify the Triage page so it exposes only the workflows the project owner wants: Quick Triage and Full Triage.

## Scope
- Remove or hide excess triage options from the primary UI.
- Keep only Quick Triage and Full Triage as first-class buttons.
- Reevaluate whether the live triage log should be removed, hidden behind details, or replaced by concise progress/status.
- Remove the live triage log from the normal technician view unless validation proves it is needed for clear progress feedback.
- Keep generated triage outputs and diagnostic bundles intact.
- Keep any advanced/internal collector options available only if needed for maintenance, not as primary technician workflow.

## Out of Scope
- Removing backend triage collectors unless separately approved.
- Changing ARGUS or HEPHAESTUS analysis contracts.
- Changing report schema.
- Untracked `App/NetworkToolkit/LatencyMon/`.

## Acceptance Criteria
- [x] Triage page primary actions are Quick Triage and Full Triage only.
- [x] Live triage log is either removed from the main view or replaced with a concise status/progress display.
- [x] Advanced collector options do not crowd the normal technician workflow.
- [x] Existing quick/full triage workflows still produce their expected outputs.
- [x] PowerShell parse, smoke, and button-smoke validation pass.

## Work Log

### Entry 001
Author: Codex
Date: 2026-07-02
Files Changed:
- `App/ToolKit-GUI/ToolKit-GUI.ps1`
- `docs/TASKS/TASK-0031-Triage-Page-Simplification.md`
- `docs/TASKS/TASK-0032-Computer-Tab-Summary-Redesign.md`
- `docs/TASKS/QUEUE.md`
- `docs/HANDOFF.md`
- `docs/ROADMAP.md`
- `docs/HISTORY/CHANGELOG.md`
- `docs/HISTORY/CHANGE-LEDGER.md`
Validation Performed:
- Confirmed `Build-TriagePage` no longer contains visible `One-Click Triage`, `Crash Triage`, `Collect Selected`, `Open Selected`, or `Live Triage Log` UI text.
- Parsed `App/ToolKit-GUI/ToolKit-GUI.ps1` with the PowerShell parser.
- Ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -SmokeTest`.
- Ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -ButtonSmokeTest`.
- Ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit\Tests\Test-TriageService.ps1`.
Issues:
- Full live Quick/Full collection was not run during validation to avoid generating a fresh diagnostic bundle; the existing triage service smoke test validates manifest creation, tool status enumeration, command capture, and setup validation.

## Completion Notes
- Rebuilt the Triage tab around two primary workflow buttons: `Quick Triage` and `Full Triage`.
- Removed the extra normal-view collector action buttons and live triage log.
- Restored the tool manifest grid as a compact catalog with concise status/progress, output access, and technician guidance.
- Preserved backend advanced functions, generated outputs, diagnostic bundles, and triage service behavior.

### Entry 002
Author: Codex
Date: 2026-07-02
Files Changed:
- `App/ToolKit-GUI/ToolKit-GUI.ps1`
- `docs/TASKS/TASK-0031-Triage-Page-Simplification.md`
- `docs/HANDOFF.md`
- `docs/HISTORY/CHANGELOG.md`
- `docs/HISTORY/CHANGE-LEDGER.md`
Validation Performed:
- Confirmed `Build-TriagePage` includes the compact `Triage Tool Catalog`, `Output And AI Workflow`, `Quick Triage`, `Full Triage`, and AI bundle instruction text.
- Confirmed `Build-TriagePage` still does not expose `One-Click Triage`, `Crash Triage`, `Collect Selected`, `Open Selected`, or `Live Triage Log`.
- Parsed `App/ToolKit-GUI/ToolKit-GUI.ps1` with the PowerShell parser.
- Ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -SmokeTest`.
- Ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -ButtonSmokeTest`.
- Ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit\Tests\Test-TriageService.ps1`.
Issues:
- None.

## Post-Completion Correction Notes
- Restored the Triage tool/app catalog as a compact status table instead of hiding it completely.
- Tightened the Triage page vertical spacing and shortened run-control rows.
- Added a compact instruction area describing the expected workflow: run triage, open the bundle folder, then submit the ZIP bundle to AI with the included prompt.
