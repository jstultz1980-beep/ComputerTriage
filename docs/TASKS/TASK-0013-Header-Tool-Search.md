# TASK-0013 - Header Tool Search

## Status
Completed

## Owner
Codex

## Objective
Add a header search box to the GUI that lets a technician type a tool name,
autocomplete matching tools, and navigate directly to the tab where that tool
lives.

## Scope
- Add a compact search control to the GUI header.
- Populate search suggestions from the existing tool catalog and custom tools.
- Navigate to the proper tab when a tool is selected or submitted.
- Keep the search control visually aligned with the existing header layout.
- Validate with smoke tests.

## Out of Scope
- Reworking the tab system.
- Launching tools directly from search.
- Changing tool placement.
- Refactoring unrelated GUI layout.

## Files to Create or Modify
- `App/ToolKit-GUI/ToolKit-GUI.ps1`
- `docs/HANDOFF.md`
- `docs/HISTORY/CHANGE-LEDGER.md`
- `docs/HISTORY/CHANGELOG.md`
- `docs/TASKS/TASK-0013-Header-Tool-Search.md`

## Acceptance Criteria
- [x] Header includes a search box.
- [x] Search box autocompletes tool names while typing.
- [x] Selecting a search result navigates to the correct tab.
- [x] Pressing Enter with a typed exact or partial match navigates to the best match.
- [x] The search index includes catalog tools and custom/toolbox tools where possible.
- [x] Smoke tests pass.

## Validation Steps
```powershell
git status --short --branch
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -SmokeTest
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -ButtonSmokeTest
```

## Rollback Plan
Revert this task's changes to `ToolKit-GUI.ps1` and the project tracking docs.

## Work Log

### Entry 001
Author: Codex
Date: 2026-06-30
Summary: Created task for header tool search.
Files Changed:
- `docs/TASKS/TASK-0013-Header-Tool-Search.md`
Validation Performed:
- Confirmed repository was clean and TASK-0013 did not already exist.
Issues:
- None.
Instructions for Next Owner:
- Implement the GUI search box using the existing tool catalog where possible.

### Entry 002
Author: Codex
Date: 2026-06-30
Summary: Implemented header tool search and autocomplete navigation.
Files Changed:
- `App/ToolKit-GUI/ToolKit-GUI.ps1`
- `docs/TASKS/TASK-0013-Header-Tool-Search.md`
- `docs/HANDOFF.md`
- `docs/HISTORY/CHANGE-LEDGER.md`
- `docs/HISTORY/CHANGELOG.md`
Validation Performed:
- Parsed `App/ToolKit-GUI/ToolKit-GUI.ps1` with `PSParser`.
- Ran `NetworkToolkit.ps1 -SmokeTest`.
- Ran `NetworkToolkit.ps1 -ButtonSmokeTest`.
Issues:
- Running GUI smoke and button smoke in parallel can leave the button test
  waiting. Running the button smoke test by itself completed successfully.
Instructions for Next Owner:
- Create the next focused task before changing HEPHAESTUS collection behavior.

## Completion Notes
Added a compact autocomplete search box to the GUI header. The search index
includes tool catalog entries, mapped Sysinternals tools, and ready custom
toolbox apps. Selecting a result or pressing Enter with an exact or partial
match navigates to the matching tab without launching the tool.
