# TASK-0007 - Activity Resource Gauges

## Status
Completed

## Owner
Codex

## Objective
Add compact speedometer-style resource gauges to the Activity page for CPU,
RAM, and disk usage.

## Scope
Enhance the existing GUI Activity page with lightweight real-time visual gauges
above the toolkit process table. Gauges should help identify runaway toolkit or
PowerShell activity without turning the page into a broad system monitor.

## Out of Scope
- Rebuilding the Activity page from scratch.
- Adding network throughput or broad performance dashboards.
- Changing toolkit process launch behavior.
- Cleaning unrelated working-tree drift.

## Files to Create or Modify
- `App/ToolKit-GUI/ToolKit-GUI.ps1`
- `docs/HANDOFF.md`
- `docs/TASKS/TASK-0007-Activity-Resource-Gauges.md`

## Acceptance Criteria
- [x] Activity page displays compact CPU, RAM, and disk usage gauges.
- [x] Gauges refresh automatically with the existing activity refresh timer.
- [x] Gauge collection is lightweight and does not block the GUI.
- [x] Existing toolkit process table and stop/refresh actions remain available.
- [x] GUI parser validation passes.
- [x] GUI button smoke test passes.
- [x] Task completion notes are updated.

## Validation Steps
```powershell
$tokens = $null
$errors = $null
[System.Management.Automation.Language.Parser]::ParseFile(
  'C:\Computer_Toolkit\App\ToolKit-GUI\ToolKit-GUI.ps1',
  [ref]$tokens,
  [ref]$errors
) | Out-Null
if($errors){ $errors; exit 1 }

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File C:\Computer_Toolkit\App\ToolKit-GUI\ToolKit-GUI.ps1 `
  -ButtonSmokeTest
```

## Rollback Plan
Remove the Activity gauge controls/functions from `App/ToolKit-GUI/ToolKit-GUI.ps1`
and restore the previous handoff/task state.

## Work Log

### Entry 001
Author: Codex
Date: 2026-06-30
Summary: Created task after user approved compact CPU, RAM, and disk
speedometer-style gauges for the Activity page.
Files Changed:
- `docs/TASKS/TASK-0007-Activity-Resource-Gauges.md`
Validation Performed:
- Pending.
Issues:
- Existing unrelated working-tree drift remains outside this task:
  `App/manifests/custom-tools.json` and
  `App/Triage/Tools/ServiWin/ServiWin.cfg`.
Instructions for Next Owner:
- Enhance only the existing Activity page and validate the GUI.

## Completion Notes
Completed on 2026-06-30 by Codex.

Changes:
- Added compact owner-drawn gauge panels to the Activity page for CPU, RAM,
  and disk active time.
- Added lightweight resource sampling through local CIM performance classes.
- Wired gauge refresh into the existing Activity page refresh timer.
- Preserved the existing toolkit process table plus `Refresh Now` and
  `Stop Selected` actions.

Validation performed:
- Parsed `App/ToolKit-GUI/ToolKit-GUI.ps1` with the PowerShell parser.
- Ran `App/ToolKit-GUI/ToolKit-GUI.ps1 -ButtonSmokeTest`.
- Confirmed the Activity gauge functions and labels exist in the GUI script.

Notes:
- No runtime tool manifests were intentionally changed.
- Unrelated working-tree drift remains outside this task:
  `App/manifests/custom-tools.json` and
  `App/Triage/Tools/ServiWin/ServiWin.cfg`.
