# TASK-0065 - UI Regression Polish

## Status
Completed

## Owner
Codex

## Purpose
Clean up the new visible UI regressions and polish notes from punch-list items 36 through 46.

## Scope
- Make the busy/progress indicator visibly animate when work is running.
- Remove the redundant installable-programs panel from the Software page now that Add-Ons owns that concept.
- Rename Windows Update health to `Windows Update Service Health` and show its state with a three-color LED.
- Require explicit confirmation before running Windows Update repair when repair is not currently indicated.
- Unsmush Directory Domain and Policy actions.
- Widen the Windows Update status message area by moving actions above it.
- Fix the Settings refresh icon presentation.
- Prevent the toolkit size line from wrapping.
- Remove the Wi-Fi page top-right status indicator and keep the status-bar/bottom-page Wi-Fi indicators.
- Bold the Quick Triage instruction step headings.

## Out Of Scope
- Product rename/branding changes.
- ARGUS or HEPHAESTUS logic.
- Deployment/package semantics.
- New Add-Ons architecture beyond removing the redundant Software-page panel.

## Acceptance Criteria
- [x] Punch-list items 36 through 46 are addressed or explicitly documented as not applicable.
- [x] No user-facing test list is requested until this task or the run stops.
- [x] PowerShell parser validation passes for edited scripts.
- [x] GUI smoke test passes.
- [x] Button smoke test passes.
- [x] Build metadata is updated.

## Completion Notes
- Made the status-bar busy progress indicator visibly maintain marquee state while work is active.
- Removed the redundant Software-page installable-programs panel, leaving Add-Ons as the installable/extract-needed surface.
- Reworked Windows Update service health as `Windows Update Service Health` with a colored LED, moved the status message under the action row, and added extra confirmation before repair when repair is not indicated.
- Unsmashed Directory Domain and Policy actions by increasing row height, shortening the first label, and allowing wrapped compact buttons.
- Removed the visible top-right Wi-Fi page indicator while preserving the status-bar LED and bottom Wi-Fi network info.
- Fixed corrupted Wi-Fi/refresh glyph rendering with character-code-based button/indicator text.
- Prevented the toolkit size label from wrapping.
- Bolded the Quick Triage and Full Triage instruction headings.
