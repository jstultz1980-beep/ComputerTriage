# TASK-0028 - Quick Dx Compact Run Panel

## Status
Completed

## Owner
Codex

## Objective
Remove the visible fixed internet target list from the Quick Dx page and compact the Quick Diagnosis run block so the right column breathes again.

## Scope
- Keep the hard-coded Quick Diagnosis internet target chain internally.
- Remove the displayed internet target chain from the Quick Diagnosis block.
- Keep only the meaningful action controls: Quick Dx, Report, DISM/SFC, and last-scan status if it fits cleanly.
- Preserve the separate editable Quick Target Checks target field.
- Prevent Hardware Shortcuts from being pushed down or crowded.

## Out of Scope
- Changing Quick Diagnosis collector logic beyond target display/selection plumbing.
- Report content changes.
- Theme redesign.
- Choco, Print, Triage, Computer, or Directory tab changes.
- Untracked `App/NetworkToolkit/LatencyMon/`.

## Acceptance Criteria
- [x] No internet target list is displayed on the Quick Dx page.
- [x] Quick Diagnosis still uses the hard-coded target chain in this order: `www.microsoft.com`, `google.com`, `yahoo.com`, `amazon.com`.
- [x] Quick Diagnosis stops at the first successful target.
- [x] Quick Dx run block no longer clips labels or pushes Review/Shortcuts down.
- [x] Hardware Shortcuts remain fully visible at the minimum supported toolkit size.
- [x] PowerShell parse, smoke, and button-smoke validation pass.

## Work Log

### Entry 001
Author: Codex
Date: 2026-07-02
Files Changed:
- `App/ToolKit-GUI/ToolKit-GUI.ps1`
- `docs/TASKS/TASK-0028-Quick-Dx-Compact-Run-Panel.md`
- `docs/TASKS/QUEUE.md`
- `docs/HANDOFF.md`
- `docs/HISTORY/CHANGE-LEDGER.md`
- `docs/HISTORY/CHANGELOG.md`
- `docs/ROADMAP.md`
Validation Performed:
- Parsed `App/ToolKit-GUI/ToolKit-GUI.ps1` with the PowerShell parser.
- Confirmed visible `Internet targets`, `Internet test target`, and `QuickInternetTargetsLabel` strings no longer exist in the GUI file.
- Confirmed `Get-GUIQuickDiagnosisTargets` still returns `www.microsoft.com`, `google.com`, `yahoo.com`, and `amazon.com`.
- Ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -SmokeTest`.
- Ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -ButtonSmokeTest`.
Issues:
- Existing local working-tree noise remains outside this task: runtime drift in `App/manifests/custom-tools.json`, local ADR drift in `docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md`, and untracked `App/NetworkToolkit/LatencyMon/`.

## Completion Notes
- Removed the visible fixed internet target chain from the Quick Dx run block.
- Kept the hard-coded target chain internal to Quick Diagnosis.
- Reduced the Quick Diagnosis run block to a compact two-row layout containing action buttons and last-scan status.
- Preserved Quick Target Checks and Hardware Shortcuts without changing collector/report behavior.
