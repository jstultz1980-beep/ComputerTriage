# TASK-0056 - Triage Guided Workflow Polish

## Status
Complete

## Owner
Codex

## Objective
Make the Triage tab guide a junior technician through the intended collection workflow without extra catalog clutter.

## Scope
- Keep Quick Triage and Full Triage as the primary actions.
- Remove or de-emphasize Technician Notes.
- Replace catalog-heavy layout with concise workflow instructions.
- Preserve access to latest run and bundle folder.
- Ensure triage bundles remain descriptively named.

## Consolidated Punch-List Mapping
- Punch-list item 24 maps here: guide the user through the triage process on the page.
- Punch-list item 25 maps here: remove Technician Notes from the normal Triage workflow.

## Out of Scope
- Changing collection semantics.
- New triage tools or downloads.
- ARGUS or HEPHAESTUS changes.

## Acceptance Criteria
- [x] Triage tab presents a clear run, bundle, submit flow.
- [x] Technician Notes no longer waste page space.
- [x] Tool catalog noise is reduced or hidden from normal workflow.
- [x] Parser, smoke, and button-smoke validation pass.

## Completion Notes
- Replaced the visible catalog-first Triage page body with `Collect`, `Review`, and `Submit` workflow sections.
- Kept Quick Triage, Full Triage, Cancel Run, status text, and progress at the top of the tab.
- Preserved Latest Run, Bundle Folder, and Validate Setup access.
- Removed the visible Technician Notes area and kept the backing catalog grid hidden for existing status refresh plumbing.
- Updated toolkit build metadata and validated parser, smoke, and button-smoke checks.
