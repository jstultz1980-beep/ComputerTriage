# TASK-0067 - UI Feedback Corrections

## Status
Complete

## Owner
Codex

## Purpose
Correct the UI polish items that did not match the requested behavior after TASK-0065 testing.

## Scope
- Make the status-bar working indicator visibly animate while keeping `Working` and the rotating indicator in fixed horizontal positions.
- Restore and widen the Windows Update status message below the button row.
- Make Windows Update Service Health visibly indicate state.
- Replace the Settings toolkit-size refresh button with an inline icon immediately to the right of the size text.
- Keep toolkit size on one line without wrapping.
- Make only the Triage instruction headings bold, not the whole paragraph.
- Keep Wi-Fi changes deferred for testing on a computer with Wi-Fi.

## Out Of Scope
- Product rename implementation.
- ARGUS or HEPHAESTUS logic.
- Deployment/package semantics.
- Wi-Fi behavior changes beyond preserving existing status-bar code.

## Acceptance Criteria
- [x] Status-bar activity indicator is visible and fixed-position during background work.
- [x] Windows Update status text is visible below the action row and spans the available width.
- [x] Windows Update Service Health displays a clear colored state indicator.
- [x] Toolkit size and refresh icon are inline, with no button chrome and no wrapping.
- [x] Triage instruction headings are bold while body copy remains regular weight.
- [x] Parser validation passes.
- [x] GUI smoke test passes.
- [x] Button smoke test passes.
- [x] Build metadata is updated.

## Completion Notes
- Replaced the blank status-bar progress box with fixed-width `Working` and spinner labels.
- Increased the Windows Update header row so the status message remains visible below the action buttons.
- Added explicit Windows Update Service Health state text beside the colored LED.
- Replaced the Settings refresh button with an inline clickable refresh icon next to the toolkit-size text.
- Split Triage instructions into separate heading/body controls so only headings are bold.
- Left Wi-Fi hardware behavior for follow-up verification on a computer with Wi-Fi.
