# TASK-0043 - Client Data Transfer

## Status
Queued

## Owner
Codex

## Objective
Add a technician-safe way to transfer client diagnostic data from one Network Toolkit copy to another.

## User Need
A technician may collect reports, profiles, bundles, crash evidence, and other client-specific outputs on one toolkit copy, then need to move that data to another toolkit copy without moving application binaries, tools, or unrelated runtime clutter.

## Scope
- Add a Settings-page workflow for transferring client data to another toolkit destination.
- Allow the destination path to be typed directly, not only selected through a browse dialog.
- Validate that the destination appears to be a Network Toolkit copy before copying.
- Transfer client diagnostic data only.
- Preserve source data.
- Avoid copying application/tool binaries.
- Create a transfer manifest that records source path, destination path, timestamp, included folders, copied file count, and copied byte count.
- Require confirmation before merging into a destination that already contains client data.
- Log transfer failures clearly without closing the toolkit.

## Out of Scope
- Updating application code or portable apps as part of the client-data transfer.
- Cleaning source client data.
- Changing deployment/update semantics.

## Acceptance Criteria
- [ ] Settings page exposes a clear client-data transfer action.
- [ ] Destination path can be typed.
- [ ] Transfer excludes app binaries and portable tools.
- [ ] Transfer writes a manifest.
- [ ] Existing destination data is protected by confirmation.
- [ ] Failure paths are logged and surfaced without crashing the GUI.
- [ ] Validation confirms PowerShell parse, GUI smoke, and button-smoke checks pass.
