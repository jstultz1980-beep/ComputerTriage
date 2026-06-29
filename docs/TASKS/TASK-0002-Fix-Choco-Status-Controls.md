# TASK-0002 - Fix Choco Status Controls

## Status
Completed

## Owner
Codex

## Objective
Fix the Chocolatey tab status frame so it no longer renders broken clipped
button artifacts.

## Scope
Update the Chocolatey page layout in the GUI only.

## Out of Scope
- ARGUS implementation.
- HEPHAESTUS collector changes.
- General theme redesign.
- Chocolatey install, upgrade, or package-management behavior changes.
- Unrelated working-tree changes in runtime manifests or portable tool files.

## Files to Create or Modify
- `App/ToolKit-GUI/ToolKit-GUI.ps1`
- `docs/HANDOFF.md`
- `docs/TASKS/TASK-0002-Fix-Choco-Status-Controls.md`

## Acceptance Criteria
- [ ] The Chocolatey status frame no longer displays clipped button line artifacts.
- [ ] Status text remains visible.
- [ ] Existing Chocolatey actions remain available elsewhere on the page.
- [ ] GUI parse validation passes.
- [ ] GUI button smoke test passes.

## Validation Steps
```powershell
$tokens = $null
$errors = $null
[System.Management.Automation.Language.Parser]::ParseFile(
  'C:\computer_toolkit\App\ToolKit-GUI\ToolKit-GUI.ps1',
  [ref]$tokens,
  [ref]$errors
) | Out-Null
if($errors){ $errors; exit 1 }

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File C:\computer_toolkit\App\ToolKit-GUI\ToolKit-GUI.ps1 `
  -ButtonSmokeTest
```

## Rollback Plan
Revert the Chocolatey page layout change in `App/ToolKit-GUI/ToolKit-GUI.ps1`
and restore the prior handoff/task updates.

## Work Log

### Entry 001
Author: Codex
Date: 2026-06-29
Summary: Created focused task after user reported the Chocolatey status frame
still displayed broken clipped button artifacts.
Files Changed:
- `docs/TASKS/TASK-0002-Fix-Choco-Status-Controls.md`
Validation Performed:
- Pending.
Issues:
- Existing unrelated working-tree changes remain: missing FRST executable,
  modified custom tools manifest, and generated ServiWin config.
Instructions for Next Owner:
- Fix only the Chocolatey status-frame rendering defect.

## Completion Notes
### Completion 001
Author: Codex
Date: 2026-06-29
Summary: Replaced the broken custom rounded buttons in the Chocolatey status
frame with lightweight link labels for `Refresh Status` and `Install
Chocolatey`. This removes the clipped line artifacts while preserving the
actions.
Validation Performed:
- Parsed `App/ToolKit-GUI/ToolKit-GUI.ps1` with the PowerShell parser.
- Ran `ToolKit-GUI.ps1 -ButtonSmokeTest`.
Notes:
- No Chocolatey package-management behavior was changed.
- Unrelated working-tree changes were not staged.
