# TASK-0057 - Wi-Fi And Windows Status Polish

## Status
Queued

## Owner
Codex

## Objective
Complete the requested Wi-Fi and Windows Update status polish from the punch list.

## Scope
- Remove the instruction text from the Windows Update tab.
- Make Windows Update service health indicate when repair is recommended.
- Remove Wi-Fi on/off clutter from the Wi-Fi tab.
- Change the status-bar Wi-Fi display to a grey/green/yellow/red LED indicator.
- Add bottom-of-page Wi-Fi network information when available.
- Remove the redundant `Wi-Fi Tools` label.

## Consolidated Punch-List Mapping
- Punch-list items 16 and 17 map to Windows Update status and repair guidance.
- Punch-list items 18, 19, 20, and 29 map to Wi-Fi status/page polish.

## Out of Scope
- Windows Update install/uninstall semantics.
- Wi-Fi profile backup behavior changes.
- New downloads.

## Acceptance Criteria
- [ ] Windows Update status is compact and actionable.
- [ ] Wi-Fi status bar uses a clear LED indicator.
- [ ] Wi-Fi page shows useful connection information without redundant labels.
- [ ] Parser, smoke, and button-smoke validation pass.
