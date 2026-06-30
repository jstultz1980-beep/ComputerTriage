# TASK-0016 - Fix Tool Source Of Truth

## Status
Completed

## Owner
Codex

## Objective
Fix the toolkit tool source-of-truth problem so visible buttons, header search,
and launch actions are generated from one consistent registry path and do not
create duplicate completion dialogs or stale tab mappings.

## Scope
- Identify why repeated `Triage Complete` dialogs appear after tool actions.
- Consolidate GUI tool lookup/search/rendering behavior around one normalized
  registry path.
- Ensure tool definitions are not duplicated between rendered tabs and search
  results.
- Add validation coverage for duplicate tool entries and representative launch
  mappings.

## Out of Scope
- Redesigning the full GUI.
- Moving large numbers of tools between tabs unless required to correct
  source-of-truth behavior.
- Rebuilding the triage engine.

## Files to Create or Modify
- `App/ToolKit-GUI/ToolKit-GUI.ps1`
- `App/NetworkToolkit/Config/ToolCatalog.ps1`
- `docs/HANDOFF.md`
- `docs/HISTORY/CHANGE-LEDGER.md`
- `docs/HISTORY/CHANGELOG.md`
- `docs/TASKS/TASK-0016-Fix-Tool-Source-Of-Truth.md`

## Acceptance Criteria
- [x] Header search and tab rendering use one normalized source for tool
  placement.
- [x] Duplicate tool entries are detected by smoke validation.
- [x] Triage completion dialogs are not repeatedly displayed from one completed
  run.
- [x] GUI smoke tests pass.

## Validation Steps
```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -SmokeTest
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -ButtonSmokeTest
```

## Rollback Plan
Revert the GUI registry/search changes and project tracking updates for this
task.

## Work Log

### Entry 001
Author: Codex
Date: 2026-06-30
Summary: Created task after duplicated `Triage Complete` dialogs exposed that
tool definitions are still not cleanly sourced.
Files Changed:
- `docs/TASKS/TASK-0016-Fix-Tool-Source-Of-Truth.md`
Validation Performed:
- Reviewed required project startup files.
- Confirmed working tree was clean before task creation.
Issues:
- Need to isolate whether duplicate dialogs come from repeated timer callbacks,
  duplicate rendered actions, or both.
Instructions for Next Owner:
- Trace the triage completion timer and the tool registry/rendering paths before
  changing behavior.

### Entry 002
Author: Codex
Date: 2026-06-30
Summary: Centralized GUI tab/search tool lookup through `Get-GUIToolRegistry`
and made triage completion handling single-shot before any completion dialog is
shown.
Files Changed:
- `App/ToolKit-GUI/ToolKit-GUI.ps1`
- `docs/HANDOFF.md`
- `docs/HISTORY/CHANGE-LEDGER.md`
- `docs/HISTORY/CHANGELOG.md`
- `docs/TASKS/TASK-0016-Fix-Tool-Source-Of-Truth.md`
Validation Performed:
- `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -SmokeTest`
- `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -ButtonSmokeTest`
Issues:
- None observed during smoke validation.
Instructions for Next Owner:
- If quick triage is manually tested, verify exactly one completion or result
  warning dialog appears per run.

## Completion Notes
Completed. Visible tab rendering and header search now read from one normalized
GUI tool registry path. Button smoke validation now fails on duplicate registry
or search entries. Triage completion and cancellation now stop/dispose the timer
and mark the run handled before any modal dialog appears, preventing repeated
completion or result-read messages from a single run.
