# TASK-0045 - Print Page Polish

## Status
Queued

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
- [ ] The Print Diagnostics block no longer shows an unnecessary `Printing` subheading.
- [ ] `Find Servers` button text is fully visible.
- [ ] Print page opens without clipping at the toolkit minimum supported window size.
- [ ] PowerShell parse, GUI smoke, and button-smoke validation pass.
