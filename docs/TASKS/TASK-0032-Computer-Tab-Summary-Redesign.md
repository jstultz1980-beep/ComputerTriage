# TASK-0032 - Computer Tab Summary Redesign

## Status
Complete

## Owner
Codex

## Objective
Redesign the Computer tab around a useful current-computer summary, with the profile list reduced to a small supporting area.

## Scope
- Give the Current Computer Summary most of the tab.
- Make the current-computer information section larger and more useful.
- Reduce the profile table to approximately three visible rows.
- Keep a small, obvious button to view/open the latest HTML computer profile report.
- Add more high-value computer details to the summary.
- Leave only a small amount of space for profile report actions and recent profile selection; the summary should be the main experience.
- Add small LED-style indicators beside status-bearing fields:
  - Green for healthy/OK.
  - Yellow for warning/review.
  - Red for critical/problem.
  - Unlit/off when not scanned or unknown.
- Feed indicators from existing profile/quick diagnosis state where available.

## Candidate Summary Fields
- Computer name.
- Domain/workgroup.
- Logged-on user.
- OS/version/build.
- Uptime.
- Pending reboot.
- Disk health/free space.
- Memory.
- CPU/model.
- Virtual/physical indicator.
- Network adapter/IP/DNS/gateway summary.
- Windows Update status.
- Defender/security status.
- Driver/device warnings.
- Recent crash/WER status.
- DISM/SFC follow-up recommendation.

## Out of Scope
- Rewriting the Computer Profile HTML report.
- New deep collectors unless the existing state cannot support a field.
- AI/ARGUS summary integration.
- Untracked `App/NetworkToolkit/LatencyMon/`.

## Acceptance Criteria
- [x] Computer profile table is reduced to approximately three visible rows.
- [x] Current Computer Summary uses the available tab space well.
- [x] Latest HTML profile report is still reachable from a small button.
- [x] The Computer tab shows more useful current-machine detail than the old profile list view.
- [x] Status-bearing fields have LED-style indicators.
- [x] Unknown/unscanned indicators render as unlit/off.
- [x] PowerShell parse, smoke, and button-smoke validation pass.
- [x] User visual validation confirms the Computer tab layout is acceptable at normal and minimum toolkit sizes.

## Work Log
- Reflowed the Computer tab so the Current Computer Summary owns the flexible vertical space.
- Reduced the recent profile table to a small supporting strip with approximately three visible rows.
- Added compact LED-style status indicators for summary fields that can have status.
- Added additional high-value summary fields including last profile time, user, reboot, servicing, Defender, security products, firewall, BitLocker, time source, disk, and network.
- Updated the network summary helper to support the current `NetworkAdapters` profile shape as well as the older `MACs` shape.
- Validated PowerShell parse, GUI smoke, and button-smoke checks.
- Follow-up correction: tightened the visible summary to the highest-signal rows and reserved more fixed height for the recent profile table so the bottom row/header no longer clips at normal toolkit size.

## Test This
- Open the Computer tab at normal toolkit size and verify the summary is the main focus.
- Confirm the recent profile table shows only a few rows and does not dominate the tab.
- Confirm the `View`, `Create Profile`, `Delete`, and `Refresh` buttons still appear and fit.
- Run or refresh a computer profile, then confirm LEDs update meaningfully for health, reboot, servicing, disk, Defender, security, firewall, and network.
- Resize the toolkit to its smallest usable size and verify labels/buttons do not clip badly.
- Confirm the recent profile table header and first few profile rows are fully visible, with no cut-off row at the bottom of the summary area.

## Completion Notes
- User directed work to proceed after the Computer tab implementation pass.
- `punch_list.txt` was read after the task; the only unmapped item was the smaller crown request, which was consolidated into TASK-0038.
