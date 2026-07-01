# TASK-0024 - Quick Dx Layout Adjustment

## Status
Completed

## Owner
Codex

## Objective
Adjust the Quick Diagnosis tab so Quick Target Checks owns the full left column and the Quick Diagnosis run controls are compacted into the right column.

## Scope
- Update only the Quick Diagnosis page layout.
- Keep Quick Target Checks as the primary left-column workspace.
- Move the Internet test target, Quick Dx, latest report, DISM/SFC, and last-scan controls into the right-side Quick Diagnosis block.
- Preserve existing button actions and tool behavior.
- Leave the active TASK-0020 ChatGPT design gate intact after this narrow UI correction.

## Out of Scope
- HEPHAESTUS local analysis implementation.
- ARGUS implementation.
- Diagnostic collector changes.
- Tool downloads, imports, removals, or portable app changes.
- Broad theme redesign or button restyling.
- Untracked `App/NetworkToolkit/LatencyMon/`.

## Acceptance Criteria
- [x] Quick Target Checks fills the left column.
- [x] Quick Diagnosis run controls are compact in the right column.
- [x] Review/shortcuts remain in the right column below Quick Diagnosis.
- [x] Existing Quick Dx, Report, DISM/SFC, target check, and hardware shortcut actions are preserved.
- [x] Main GUI script parses successfully.
- [x] Existing smoke validation passes.
- [x] Existing button-smoke validation passes.
- [x] No ARGUS, HEPHAESTUS, or unrelated tool changes are made.

## Validation
- `powershell.exe -NoProfile -Command "[System.Management.Automation.PSParser]::Tokenize(...)"`
- `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -SmokeTest`
- `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -ButtonSmokeTest`

## Work Log
- 2026-07-01: Reworked `Build-QuickTriagePage` into a two-column layout with Quick Target Checks on the full left column and Quick Diagnosis plus Review/Shortcuts stacked on the right.
