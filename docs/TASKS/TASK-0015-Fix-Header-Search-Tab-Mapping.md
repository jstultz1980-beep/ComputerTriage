# TASK-0015 - Fix Header Search Tab Mapping

## Status
Completed

## Owner
Codex

## Objective
Correct the GUI header search box so tool results display and navigate to the
same tab where the tool actually appears.

## Scope
- Trace how header search builds tab labels for catalog, custom, and
  Sysinternals-backed tools.
- Fix mismatches caused by stale placement maps, override handling, or missing
  catalog metadata.
- Add or update smoke-test coverage so representative search results validate
  their expected tabs.

## Out of Scope
- Redesigning the search UI.
- Moving tools between tabs unless required to correct a clearly wrong search
  mapping.
- Reworking the custom tool manifest format.

## Files to Create or Modify
- `App/ToolKit-GUI/ToolKit-GUI.ps1`
- `docs/HANDOFF.md`
- `docs/HISTORY/CHANGE-LEDGER.md`
- `docs/HISTORY/CHANGELOG.md`
- `docs/TASKS/TASK-0015-Fix-Header-Search-Tab-Mapping.md`

## Acceptance Criteria
- [x] Header search results use the same tab labels that the GUI uses for the
  matching tool button.
- [x] Representative catalog, custom, and Sysinternals search results resolve
  to expected tabs.
- [x] GUI smoke tests pass.

## Validation Steps
```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -SmokeTest
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -ButtonSmokeTest
```

## Rollback Plan
Revert search index and validation changes, then reset documentation updates for
this task.

## Work Log

### Entry 001
Author: Codex
Date: 2026-06-30
Summary: Created task after search box showed incorrect tab labels for some
tools.
Files Changed:
- `docs/TASKS/TASK-0015-Fix-Header-Search-Tab-Mapping.md`
Validation Performed:
- Confirmed repository was clean after resetting runtime manifest drift.
Issues:
- Need to identify whether mismatches come from catalog entries, custom-tool
  placement overrides, or Sysinternals placement data.
Instructions for Next Owner:
- Inspect search index construction and compare search labels against actual tab
  placement.

### Entry 002
Author: Codex
Date: 2026-06-30
Summary: Rebuilt header search index from the same tool placement path used by
the visible tabs.
Files Changed:
- `App/NetworkToolkit/Config/ToolCatalog.ps1`
- `App/ToolKit-GUI/ToolKit-GUI.ps1`
Validation Performed:
- Parsed `App/ToolKit-GUI/ToolKit-GUI.ps1`.
- Parsed `App/NetworkToolkit/Config/ToolCatalog.ps1`.
- Ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -SmokeTest`.
- Ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -ButtonSmokeTest`.
- Queried the header search index and confirmed:
  - `Test-NetConnection` maps to `Analyze`.
  - `PsExec Helper` maps to `PsExec`.
  - `DHCP Sleuth` maps to `Infrastructure`.
  - `Autoruns` maps to `Security`.
  - `Process Explorer` maps to `Processes`.
Issues:
- GUI validation still causes runtime provenance drift in
  `App/manifests/custom-tools.json`; reset that drift before committing.
Instructions for Next Owner:
- Continue with the next focused task from `docs/HANDOFF.md`.

## Completion Notes
Header search now builds entries from `Get-GUIToolsForTab` for each searchable
tab, matching the same catalog/custom/Sysinternals placement path used by the
visible tool pages. Sysinternals-only search results now come from the same
standalone Sysinternals filter used by the Sysinternals tab. `PsExec Helper`
was corrected from `Remote` to the dedicated `PsExec` tab.
