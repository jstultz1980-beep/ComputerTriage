# TASK-0003 - Remove Unsafe FRST Triage Tool

## Status
Completed

## Owner
Codex

## Objective
Remove the unsafe FRST triage tool artifact and prevent the toolkit from
presenting FRST as an installed or runnable bundled tool.

## Scope
Update the toolkit to reflect that `FRST64.exe` was removed because it was
flagged as malicious. Remove or disable FRST references from triage manifests
and any GUI/tool status surfaces that would imply FRST is available in the
toolkit.

## Out of Scope
- Downloading or bundling a replacement FRST executable.
- Adding endpoint-protection bypasses or exclusions.
- General triage redesign.
- ARGUS implementation.
- HEPHAESTUS collector changes unrelated to FRST.
- Runtime custom-tools manifest cleanup unless directly caused by FRST.

## Files to Create or Modify
- `App/manifests/triage-tools.json`
- `App/NetworkToolkit/Utilities/TriageService.ps1`
- `docs/HANDOFF.md`
- `docs/TASKS/TASK-0003-Remove-Unsafe-FRST.md`

## Acceptance Criteria
- [x] FRST is no longer listed as a runnable triage tool.
- [x] The missing/deleted `FRST64.exe` is not staged as an accidental deletion
      unless the task explicitly confirms it is already absent and should stay
      absent.
- [x] Triage manifest parsing still works.
- [x] Toolkit smoke test passes.
- [x] GUI button smoke test passes.
- [x] Task completion notes are updated.

## Validation Steps
```powershell
Get-Content C:\computer_toolkit\App\manifests\triage-tools.json -Raw |
  ConvertFrom-Json | Out-Null

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File C:\computer_toolkit\App\NetworkToolkit\Tests\Test-ToolkitSmoke.ps1

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File C:\computer_toolkit\App\ToolKit-GUI\ToolKit-GUI.ps1 `
  -ButtonSmokeTest
```

## Rollback Plan
Restore FRST manifest entries from the previous commit only if a future task
explicitly approves a safe FRST acquisition and verification workflow.

## Work Log

### Entry 001
Author: Codex
Date: 2026-06-29
Summary: Created task after user confirmed `App/Triage/Tools/FRST/FRST64.exe`
contained a Trojan.
Files Changed:
- `docs/TASKS/TASK-0003-Remove-Unsafe-FRST.md`
Validation Performed:
- Pending.
Issues:
- `FRST64.exe` is already deleted in the working tree.
- `App/manifests/custom-tools.json` remains unrelated runtime drift.
- `App/Triage/Tools/ServiWin/ServiWin.cfg` remains an unrelated generated file.
Instructions for Next Owner:
- Remove FRST from triage metadata and commit the deletion intentionally.

## Completion Notes
Completed on 2026-06-29 by Codex.

Changes:
- Removed FRST from `App/manifests/triage-tools.json`.
- Removed FRST from the default triage manifest in
  `App/NetworkToolkit/Utilities/TriageService.ps1`.
- Confirmed `App/Triage/Tools/FRST/FRST64.exe` was intentionally removed after
  the user reported it was malicious.
- Removed the now-empty `App/Triage/Tools/FRST` folder from the working tree.

Validation performed:
- Parsed `App/manifests/triage-tools.json` with `ConvertFrom-Json`.
- Ran `App/NetworkToolkit/Tests/Test-ToolkitSmoke.ps1`; passed.
- Ran `App/ToolKit-GUI/ToolKit-GUI.ps1 -ButtonSmokeTest`; passed.

Notes:
- `App/ToolKit-GUI/ToolKit-GUI.ps1` still contains `frst` in a generic consent
  guard list, but no manifest/tool surface now presents FRST as installed or
  runnable.
- Unrelated working-tree drift remains outside this task:
  `App/manifests/custom-tools.json` and
  `App/Triage/Tools/ServiWin/ServiWin.cfg`.
