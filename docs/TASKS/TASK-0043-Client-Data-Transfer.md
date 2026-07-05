# TASK-0043 - Client Data Transfer

## Status
Complete

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
- [x] Settings page exposes a clear client-data transfer action.
- [x] Destination path can be typed.
- [x] Transfer excludes app binaries and portable tools.
- [x] Transfer writes a manifest.
- [x] Existing destination data is protected by confirmation.
- [x] Failure paths are logged and surfaced without crashing the GUI.
- [x] Validation confirms PowerShell parse, GUI smoke, and button-smoke checks pass.

## Implementation Notes
- Added `App/NetworkToolkit/Utilities/ClientDataTransfer.ps1` as the reusable client-data transfer backend.
- Added a Settings-page `Transfer Client Data` action with typed destination entry, optional browse, validation, merge confirmation, manifest output, GUI logging, and tool usage logging.
- Transfer scope is limited to client diagnostic data roots such as NetworkToolkit Data, Exports, Logs, Triage Runs, Triage Profiles, and app logs.
- Application code, portable apps, external tools, custom tool binaries, Git metadata, and build/release folders are excluded.

## Validation
- PowerShell parser check passed for `App/ToolKit-GUI/ToolKit-GUI.ps1`.
- PowerShell parser check passed for `App/NetworkToolkit/Utilities/ClientDataTransfer.ps1`.
- Local fake toolkit transfer validation copied client data, created a manifest, and confirmed a fake external-tool binary was not copied.
- GUI smoke test passed.
- Button smoke test passed.
