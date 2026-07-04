# TASK-0047 - Status Bar Indicators And Chrome Cleanup

## Status
Queued

## Owner
Codex

## Objective
Improve bottom status-bar usefulness, add compact live indicators, and remove or repurpose unclear chrome.

## User Need
The status bar should expose useful live information without mystery UI pieces. Wi-Fi signal strength, useful build/version context, and status-worthy page indicators should be visible without adding clutter or new lag.

## Scope
- Determine whether the small rectangle in the bottom-right status area serves a purpose.
- Remove the bottom-right rectangle if it is decorative or unused.
- If it has a real purpose, make that purpose visible and useful.
- Add a compact Wi-Fi signal-strength indicator to the bottom-right status bar area.
- Show both icon-style strength and numerical strength where available.
- Add a compact Windows Update service health indicator to the Windows Update page.
- Add a compact Wi-Fi signal-strength indicator to the Wi-Fi page when that page has a cleaner placement than the status bar alone.
- Move Version and Build information to the bottom-left status bar as small, static text.
- Keep all indicators neutral/off when values are unknown or unavailable.

## Out of Scope
- Rewriting Wi-Fi diagnostics.
- Adding continuous polling that could cause memory leaks.
- Full status-bar redesign beyond this specific cleanup.

## Acceptance Criteria
- [ ] Bottom-right status-bar rectangle is either removed or has an obvious useful purpose.
- [ ] Wi-Fi signal strength appears in the status bar when Wi-Fi data is available.
- [ ] Windows Update page shows a compact Windows Update service health indicator.
- [ ] Wi-Fi page shows compact signal strength if page-level placement is useful.
- [ ] Version and Build appear as small static text in the bottom-left status bar.
- [ ] Unknown or unavailable Wi-Fi status renders neutral/off without errors.
- [ ] Indicator updates do not slow tab switching.
- [ ] PowerShell parse, GUI smoke, and button-smoke validation pass.
