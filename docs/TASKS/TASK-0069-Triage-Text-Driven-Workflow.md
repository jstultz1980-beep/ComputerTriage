# TASK-0069 - Triage Text Driven Workflow

## Status
Complete

## Owner
Codex

## Purpose
Move the Triage page away from button-driven actions and make the instructional text drive the workflow.

## Scope
- Remove the old visible top action-row Quick Triage, Full Triage, and progress-bar field from the Triage page.
- Make `Quick Triage` and `Full Triage` text in Step 1 clickable action items.
- Keep Cancel Run inside Step 1 and show it only while a triage run is active.
- Convert Step 2 Review actions from buttons to links with explanations.
- Preserve existing triage run, validation, latest-run, and bundle-folder behavior.

## Out Of Scope
- Wi-Fi hardware verification.
- ARGUS or HEPHAESTUS logic.
- Deployment/package semantics.

## Acceptance Criteria
- [x] Triage page has no mysterious top progress field.
- [x] Quick/Full Triage are clickable text actions in Step 1.
- [x] Cancel Run appears at the bottom of Step 1 only while a run is active.
- [x] Step 2 Review uses links, not buttons, with explanations beside/after each link.
- [x] Parser validation passes.
- [x] GUI smoke test passes.
- [x] Button smoke test passes.
- [x] Build metadata is updated.

## Completion Notes
- Removed the old Triage top action buttons and visible progress-bar field.
- Made Quick Triage and Full Triage link-style actions inside Step 1.
- Moved Cancel Run into Step 1 and tied visibility to active triage process state.
- Converted Latest Run, Bundle Folder, and Validate Setup to link-style Review actions with inline explanations.
