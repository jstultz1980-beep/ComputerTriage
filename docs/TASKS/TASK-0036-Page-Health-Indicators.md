# TASK-0036 - Page Health Indicators

## Status
Queued

## Owner
Codex

## Objective
Add small, useful live health indicators to pages where a technician benefits from immediate status without running a full report.

## Scope
- Add a Windows Update service health indicator to the Windows Update page.
- Add a Wi-Fi signal strength indicator to the Wi-Fi page.
- Render Wi-Fi strength with:
  - A small Wi-Fi icon that changes based on strength.
  - A numerical signal value.
  - Compact placement in the upper-right corner of the page or near the header controls if that layout is cleaner.
- Use Green/Yellow/Red or equivalent status treatment consistently with the Computer tab LED language.
- Leave indicators unlit/neutral when the value has not been scanned.
- Avoid blocking page navigation while indicators refresh.

## Out of Scope
- Rewriting Windows Update installation logic.
- Rewriting Wi-Fi diagnostics.
- New background polling loops that could create memory leaks.
- Untracked `App/NetworkToolkit/LatencyMon/`.

## Acceptance Criteria
- [ ] Windows Update page shows a compact Windows Update service health indicator.
- [ ] Wi-Fi page shows a compact signal-strength icon and numerical value.
- [ ] Indicator states are visually consistent with the Computer tab LED model.
- [ ] Unknown/unscanned values render neutral/off.
- [ ] Indicators do not noticeably slow page switching.
- [ ] PowerShell parse, smoke, and button-smoke validation pass.
