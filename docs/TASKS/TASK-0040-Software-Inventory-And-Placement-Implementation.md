# TASK-0040 - Software Inventory And Placement Implementation

## Status
Completed

## Owner
Codex

## Objective
Classify and implement Software tab placement so portable launchers, installable stored programs, and non-portable candidates are obvious and not duplicated.

## Scope
- Put launchable portable applications at the top of the Software tab.
- Reserve the bottom area for installable programs stored in the toolkit.
- Classify optional portable tools, including whether LatencyMon should be tracked, ignored, or handled separately.
- Research whether a usable portable edition of Registrar Registry Manager exists.
- If Registrar Registry Manager cannot be used portably, list it only as installable or excluded rather than as a launchable toolkit app.
- Move non-portable tools out of launchable Triage Tool lists after classification.
- Preserve safe launch behavior for true portable apps.
- Preserve installable-program visibility without implying they are portable launchers.

## Out of Scope
- Downloading new apps unless a separate task explicitly approves it.
- Silent installer automation.
- Whole app manifest redesign.
- Untracked `App/NetworkToolkit/LatencyMon/`.

## Acceptance Criteria
- [x] Software tab is split into launchable and installable areas.
- [x] Optional portable tools, including LatencyMon, are classified.
- [x] Registrar Registry Manager portability is answered with source notes.
- [x] Non-portable tools no longer appear as launchable triage tools.
- [x] Installable tools are clearly labeled as installable.
- [x] Existing portable launch buttons still work.
- [x] PowerShell parse, smoke, and button-smoke validation pass.

## Work Log

- Split the Software tab into `Launchable Portable Apps` and `Installable Programs Stored In Toolkit`.
- Removed Registrar Registry Manager from the Repair-tab launch catalog because only the installer is currently present.
- Added an installable/extract-needed Registrar Registry Manager entry on the Software tab with a confirmation prompt before launching the installer.
- Removed Sysinternals Suite and WinAudit from the default and current triage manifests.
- Kept LatencyMon classified as optional/manual portable triage tooling.
- Added `docs/SOFTWARE-TOOL-CLASSIFICATION.md` as the source note for Registrar, triage removals, and LatencyMon classification.
- Updated toolkit build metadata.

## Validation

- PowerShell parser validation passed for:
  - `App\ToolKit-GUI\ToolKit-GUI.ps1`
  - `App\NetworkToolkit\Utilities\TriageService.ps1`
  - `App\NetworkToolkit\Config\ToolCatalog.ps1`
- Confirmed current triage manifest no longer contains `sysinternals` or `winaudit`.
- Confirmed LatencyMon remains present as optional/manual triage tooling.
- GUI smoke test passed.
- Button smoke test passed.
