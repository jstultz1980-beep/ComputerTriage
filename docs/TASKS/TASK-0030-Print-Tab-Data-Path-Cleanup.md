# TASK-0030 - Print Tab Data Path Cleanup

## Status
Complete

## Owner
Codex

## Objective
Remove the visible print queue data-folder path from the Print tab because it does not help technicians during normal use.

## Scope
- Remove the `Data folder:` path display from the Print tab.
- Reclaim the space for more useful print queue controls or diagnostics layout.
- Preserve print queue maintenance behavior and output locations.

## Out of Scope
- Print queue engine changes.
- Print queue standalone tool migration.
- Printer artifact cleanup logic.
- Untracked `App/NetworkToolkit/LatencyMon/`.

## Acceptance Criteria
- [x] Print tab no longer shows the data-folder path.
- [x] Existing print buttons still launch the correct actions.
- [x] Print outputs still save to the current expected toolkit data/output locations.
- [x] PowerShell parse, smoke, and button-smoke validation pass.

## Work Log

### Entry 001
Author: Codex
Date: 2026-07-02
Files Changed:
- `App/ToolKit-GUI/ToolKit-GUI.ps1`
- `docs/TASKS/TASK-0030-Print-Tab-Data-Path-Cleanup.md`
- `docs/TASKS/QUEUE.md`
- `docs/HANDOFF.md`
- `docs/ROADMAP.md`
- `docs/HISTORY/CHANGELOG.md`
- `docs/HISTORY/CHANGE-LEDGER.md`
Validation Performed:
- Confirmed no visible `Data folder:` text remains in `App/ToolKit-GUI/ToolKit-GUI.ps1`.
- Parsed `App/ToolKit-GUI/ToolKit-GUI.ps1` with the PowerShell parser.
- Ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -SmokeTest`.
- Ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -ButtonSmokeTest`.
Issues:
- None.

## Completion Notes
- Removed the visible print queue data-folder path from the Print tab.
- Preserved `Get-GUIPrintQueueDataRoot` and all existing print queue data/output behavior.
- Replaced the dead path display with a technician-facing ready/status message.
