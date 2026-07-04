# TASK-0047 - Status Bar Indicators And Chrome Cleanup

## Status
Active

## Owner
Codex

## Objective
Improve bottom status-bar usefulness, add compact live indicators, and remove or repurpose unclear chrome.

## User Need
The status bar should expose useful live information without mystery UI pieces. Wi-Fi signal strength, useful build/version context, and status-worthy page indicators should be visible without adding clutter or new lag.

## Scope
- Fix header chrome layout where the `Computer` label can be clipped by the title area.
- Replace the Settings and Help header buttons with cleaner compact icon controls.
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
- [x] Header `Computer` label is no longer clipped by the title/logo area.
- [x] Settings and Help header buttons use compact icon styling instead of the generic bulky button style.
- [ ] Bottom-right status-bar rectangle is either removed or has an obvious useful purpose.
- [ ] Wi-Fi signal strength appears in the status bar when Wi-Fi data is available.
- [ ] Windows Update page shows a compact Windows Update service health indicator.
- [ ] Wi-Fi page shows compact signal strength if page-level placement is useful.
- [x] Version and Build appear as small static text in the bottom-left status bar.
- [ ] Unknown or unavailable Wi-Fi status renders neutral/off without errors.
- [ ] Indicator updates do not slow tab switching.
- [x] PowerShell parse, GUI smoke, and button-smoke validation pass for the version/build status-bar slice.

## Progress Notes
- Shifted the header summary panel to the right so the `Computer` label no longer renders under the title block.
- Added dedicated header-icon button chrome and applied it to Settings and Help.
- Reduced the header tools cluster width after converting Settings/Help to compact icon controls.
- Moved toolkit version/build from the Settings-page maintenance block to a static bottom-left `StatusStrip` label.
- Removed the duplicate Settings-page version/build row so Settings keeps the maintenance space for actions and folder links.
- Updated toolkit build metadata with `App/Update-ToolkitVersion.ps1`.

## Validation
- PowerShell parser validation passed for `App/ToolKit-GUI/ToolKit-GUI.ps1`.
- GUI smoke test passed via `App/NetworkToolkit.ps1 -SmokeTest`.
- Button smoke test passed via `App/NetworkToolkit.ps1 -ButtonSmokeTest`.

## Test This
- Launch the toolkit and confirm the header shows the full word `Computer`, not clipped as `omputer`.
- Confirm the Settings and Help buttons look like compact header icons and still open Settings/Help.
- Launch the toolkit and confirm the bottom-left status bar shows `v1.0.0 | build <number>`.
- Open Settings and confirm the old `Toolkit version... Source updated...` text is gone.
- Confirm the Settings maintenance buttons still align and do not look shifted or clipped.
