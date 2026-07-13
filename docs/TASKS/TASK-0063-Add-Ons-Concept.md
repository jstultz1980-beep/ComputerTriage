# TASK-0063 - Add Ons Concept

## Status
Complete

## Owner
Codex

## Objective
Prototype a clearer Add-Ons experience for installable programs that are not portable.

## Scope
- Separate installable/non-portable programs from launchable portable applications.
- Test whether Add-Ons should be a tab, popup, or another focused UI surface.
- Preserve the Software tab's launchable/installable placement rules until the new concept proves better.
- Keep current install/extract guidance visible enough for technician use.

## Consolidated Punch-List Mapping
- Punch-list item 33 maps here: installable programs that are not portable should have their own Add-Ons experience, possibly a popup rather than a tab.

## Out of Scope
- Downloading new programs.
- Changing package installation semantics.
- Removing the existing Software tab until a tested replacement is accepted.

## Acceptance Criteria
- [x] Add-Ons concept separates installable/non-portable programs from portable launchers.
- [x] The chosen surface can be tested without disrupting existing Software workflows.
- [x] Current install/extract-needed information remains accessible.
- [x] Parser, smoke, and button-smoke validation pass.

## Completion Notes
- Added a testable Add-Ons popup launched from the Software page.
- The popup shows installable/extract-needed programs separately from launchable portable applications.
- Kept the existing Software page launchable/installable sections intact for comparison.
- Shared safe software resource links between the Software footer and Add-Ons popup.
- Updated toolkit build metadata and validated parser, smoke, and button-smoke checks.
