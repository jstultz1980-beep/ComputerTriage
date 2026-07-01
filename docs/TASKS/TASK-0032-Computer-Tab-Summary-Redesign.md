# TASK-0032 - Computer Tab Summary Redesign

## Status
Queued

## Owner
Codex

## Objective
Redesign the Computer tab around a useful current-computer summary instead of a profile list.

## Scope
- Remove the computer profile list from the Computer tab.
- Give the Current Computer Summary most of the tab.
- Keep a small, obvious button to view/open the latest HTML computer profile report.
- Add more high-value computer details to the summary.
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
- [ ] Computer profile list is removed from the Computer tab.
- [ ] Current Computer Summary uses the available tab space well.
- [ ] Latest HTML profile report is still reachable from a small button.
- [ ] Status-bearing fields have LED-style indicators.
- [ ] Unknown/unscanned indicators render as unlit/off.
- [ ] PowerShell parse, smoke, and button-smoke validation pass.
