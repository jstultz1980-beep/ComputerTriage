# TASK-0045 - Print Page Polish

## Status
Complete

## Owner
Codex

## Objective
Clean up the Print page layout and fix obvious print-tool presentation defects.

## User Need
The Print page should be easy to scan during troubleshooting. Current issues include unnecessary subheadings and clipped button text.

## Scope
- Remove the `Printing` subheading from the Print Diagnostics block.
- Fix the `Find Servers` button so text is not clipped at the top or bottom.
- Preserve print queue maintenance behavior.
- Preserve print diagnostics and cleanup behavior.

## Out of Scope
- Rewriting print discovery logic unless required to fix button wiring.
- Replacing the embedded Print Queue Maintenance tool.
- Changing report/output locations.

## Acceptance Criteria
- [x] The Print Diagnostics block no longer shows an unnecessary `Printing` subheading.
- [x] `Find Servers` button text is fully visible.
- [x] Print page opens without clipping at the toolkit minimum supported window size.
- [x] PowerShell parse, GUI smoke, and button-smoke validation pass.

## Work Log
- Added an optional compact-tool-grid switch to hide section headers.
- Used that switch on the Print Diagnostics And Cleanup block so the redundant `Printing` subheading is removed.
- Gave the Print Queue top row and `Find Servers` button more room to prevent vertical text clipping.
- Read `punch_list.txt` after the task; no new unmapped items were found.

## Test This
- Open the Print tab and confirm the Print Diagnostics block does not show a `Printing` subheading.
- Confirm `Find Servers` text is fully visible.
- Click `Find Servers` and confirm it still attempts discovery.
- Confirm `Connect`, `Refresh`, `Clear Selected`, `Restart Spooler`, `Full Reset`, `Save Target`, and `Standalone` still fit.
