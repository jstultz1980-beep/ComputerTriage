# TASK-0047 - Status Bar Wi-Fi And Chrome Cleanup

## Status
Queued

## Owner
Codex

## Objective
Improve bottom status-bar usefulness and remove or repurpose unclear chrome.

## User Need
The status bar should expose useful live information without mystery UI pieces. Wi-Fi signal strength should be visible there, and the small bottom-right rectangle needs a clear purpose or should be removed.

## Scope
- Determine whether the small rectangle in the bottom-right status area serves a purpose.
- Remove the bottom-right rectangle if it is decorative or unused.
- If it has a real purpose, make that purpose visible and useful.
- Add a compact Wi-Fi signal-strength indicator to the bottom-right status bar area.
- Show both icon-style strength and numerical strength where available.
- Preserve page-level Wi-Fi indicator work already tracked in TASK-0036.

## Out of Scope
- Rewriting Wi-Fi diagnostics.
- Adding continuous polling that could cause memory leaks.
- Reworking the full status bar layout beyond this specific cleanup.

## Acceptance Criteria
- [ ] Bottom-right status-bar rectangle is either removed or has an obvious useful purpose.
- [ ] Wi-Fi signal strength appears in the status bar when Wi-Fi data is available.
- [ ] Unknown or unavailable Wi-Fi status renders neutral/off without errors.
- [ ] Indicator updates do not slow tab switching.
- [ ] PowerShell parse, GUI smoke, and button-smoke validation pass.
