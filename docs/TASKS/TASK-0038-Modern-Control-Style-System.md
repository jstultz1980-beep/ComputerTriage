# TASK-0038 - Modern Control Style System

## Status
Complete

## Owner
Codex

## Objective
Replace default-looking utility buttons with a consistent, modern toolkit control style.

## Scope
- Define a reusable style/helper for small utility buttons such as Refresh, Stop, View, Open, and similar page actions.
- Redesign the Settings and Help header controls so they no longer look rough or out of place.
- Make the header crown/elevation icon a little smaller and less visually dominant.
- Apply the style to repeated utility buttons across the toolkit.
- Keep buttons compact enough to avoid layout overflow.
- Preserve accessibility:
  - Readable text.
  - Clear hover/focus state.
  - Disabled state that is visually obvious.
- Coordinate with existing theme colors so controls do not become washed out or unreadable.

## Out of Scope
- Full GUI redesign.
- Replacing every launch LED/tool button unless the control shares the same utility-button role.
- Theme-builder redesign.
- Untracked `App/NetworkToolkit/LatencyMon/`.

## Acceptance Criteria
- [x] Refresh/Stop-style controls no longer look like raw default buttons.
- [x] Settings and Help header controls are cleaner, readable, and visually aligned with the rest of the header.
- [x] Header crown/elevation icon is smaller and does not crowd the header controls.
- [x] Repeated utility controls use a shared style path.
- [x] Button text remains readable in all built-in themes.
- [x] No tab layout gains new clipping or forced scrolling from the style change.
- [x] PowerShell parse, smoke, and button-smoke validation pass.

## Work Log
- Converted the Settings header control to a compact gear icon.
- Reduced the Help header control size while preserving the icon-only button behavior.
- Reduced the crown/elevation icon footprint.
- Reworked the crown drawing code so it scales to the smaller control instead of clipping.
- Preserved the existing shared rounded button chrome for header controls and utility buttons.
- Read `punch_list.txt` after the task; no new unmapped items were found.

## Test This
- Open the toolkit and verify the top-right header area is less crowded.
- Confirm the crown is smaller and still clearly indicates elevation.
- Click the gear icon and confirm it opens Settings.
- Click the `?` icon and confirm it opens Help.
- Switch between a light theme and dark theme and confirm these controls remain readable.
