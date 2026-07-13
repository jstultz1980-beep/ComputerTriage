# TASK-0058 - Settings And Control Polish

## Status
Complete

## Owner
Codex

## Objective
Tighten remaining general GUI control polish items from the punch list.

## Scope
- Change Refresh Size on Settings to a circular-arrow control.
- Make tab ordering more compact and slick.
- Remove Registered Commands display.
- Make logo slightly larger without breaking header layout.
- Reduce button font and physical button size where it improves layout.

## Consolidated Punch-List Mapping
- Punch-list item 21 maps to the Settings refresh-size icon control.
- Punch-list item 22 maps to compact tab ordering.
- Punch-list item 23 maps to removing Registered Commands from normal display.
- Punch-list item 26 maps to header logo sizing.
- Punch-list item 28 maps to smaller button fonts and physical button sizing.

## Out of Scope
- Full theme redesign.
- Replacing every tab layout.
- ARGUS or HEPHAESTUS changes.

## Acceptance Criteria
- [x] Settings controls are more compact and visually consistent.
- [x] Registered Commands is no longer shown in the main status bar.
- [x] Header logo is easier to recognize.
- [x] Shared button sizing is improved without clipping labels.
- [x] Parser, smoke, and button-smoke validation pass.

## Completion Notes
- Replaced Settings `Refresh Size` text with a compact circular-arrow icon button and tooltip.
- Reduced shared button and tab button font/spacing metrics.
- Changed the static tab strip from three rows to two compact rows with shorter tab labels.
- Increased the header logo from 52px to 62px and shifted title/subtitle text to preserve spacing.
- Removed the normal startup live-log line that displayed the registered command count.
- Updated toolkit build metadata and validated parser, smoke, and button-smoke checks.
