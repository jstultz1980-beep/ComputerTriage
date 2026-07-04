# TASK-0046 - Triage Page Catalog And Bundle Cleanup

## Status
Complete

## Owner
Codex

## Objective
Make the Triage page simpler, remove redundant catalog noise, and improve bundle identification.

## User Need
The Triage page should guide a technician through Quick Triage or Full Triage without extra clutter. The tool catalog should only list tools that matter there, and generated bundles should be easier to identify later.

## Scope
- Move `Quick Triage` and `Full Triage` buttons out of the surrounding box and place them across the top of the tab.
- Remove the visible status block from the Triage page and push that information into the status bar.
- Remove Sysinternals entries from the Triage tool catalog.
- Make WinAudit work if it can run portably; otherwise remove it from the Triage tool catalog.
- Remove catalog applications that already live elsewhere in the toolkit.
- Document or remove the `Export Manifest` action after determining whether it is still useful.
- Make triage bundle names more descriptive for easier identification.

## Out of Scope
- Changing HEPHAESTUS collection semantics.
- Rewriting the triage runner.
- Removing generated manifest artifacts that are still required by ARGUS or reporting.

## Acceptance Criteria
- [x] Triage primary actions are top-level controls, not boxed inside a status area.
- [x] Triage status is surfaced through the status bar instead of a large page block.
- [x] Sysinternals tools are no longer listed in the Triage tool catalog.
- [x] WinAudit is either working as a portable triage tool or removed from the catalog.
- [x] Tools already represented elsewhere are removed from the Triage catalog.
- [x] `Export Manifest` has a clear retained purpose or is removed from the visible UI.
- [x] Triage bundle names include enough context to identify computer, triage type, and timestamp.
- [x] PowerShell parse, GUI smoke, button-smoke, and triage service validation pass.

## Completion Notes
- Reworked the Triage tab top area into a flat action row with `Quick Triage`, `Full Triage`, `Cancel Run`, status text, and a compact progress bar.
- Removed the large visible status block from the page.
- Removed the visible `Export Manifest` action from the technician workflow. The manifest export helper remains available internally for future support/debug workflows.
- Filtered the technician-facing Triage catalog so Sysinternals, WinAudit, and launcher tools already represented on other tabs are not shown as primary Triage-page tools.
- Updated generated triage ZIP names to include the run id and triage profile, for example `COMPUTER_2026-07-04_153000_Quick_DiagnosticBundle.zip`.
- Updated toolkit build metadata through `App/Update-ToolkitVersion.ps1`.

## Validation
- PowerShell parser validation passed for:
  - `App/ToolKit-GUI/ToolKit-GUI.ps1`
  - `App/NetworkToolkit/Utilities/TriageService.ps1`
- Direct triage setup validation passed via `TriageService.ps1`.
- GUI smoke test passed via `App/NetworkToolkit.ps1 -SmokeTest`.
- Button smoke test passed via `App/NetworkToolkit.ps1 -ButtonSmokeTest`.

## Test This
- Open the Triage tab and confirm `Quick Triage`, `Full Triage`, and `Cancel Run` appear across the top without a large boxed Status section.
- Confirm the Triage catalog no longer lists Sysinternals Suite or WinAudit.
- Run a Quick Triage and confirm the status appears in the bottom status bar and the bundle folder opens when complete.
- Confirm the created ZIP filename includes the computer/run id and `Quick` or `Full`.
