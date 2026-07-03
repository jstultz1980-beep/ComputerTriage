# TASK-0044 - GUI Tab Performance Hardening

## Status
Queued

## Owner
Codex

## Objective
Reduce the first-open Activity tab lag and remaining tab-to-tab navigation lag.

## User Need
The Activity tab renders faster than most pages after the first load, but the first visit still lags. Moving between tabs is improved but still noticeably slow. The toolkit should feel responsive during live troubleshooting.

## Scope
- Profile first-load cost for the Activity page.
- Specifically address the first-time Activity tab lag reported during testing.
- Profile tab-switch cost across high-lag tabs.
- Ensure timers, background refreshes, WMI calls, performance counters, and discovery refreshes only run when needed.
- Defer expensive page population until visible and cache safe static UI where practical.
- Preserve live gauge behavior on the Activity tab.
- Add or improve diagnostics for slow tab changes so future lag has useful evidence.
- Keep the GUI stable if performance counters are missing or slow.

## Out of Scope
- Full GUI redesign.
- Replacing the Windows Forms framework.
- Changing diagnostic collection behavior unrelated to page rendering.

## Acceptance Criteria
- [ ] First Activity tab load is measurably faster or the blocking operation is identified and isolated.
- [ ] Tab-switch diagnostics identify any tab taking longer than the slow-switch threshold.
- [ ] Activity refresh does not run while another tab is selected.
- [ ] Missing or slow counters do not freeze the GUI.
- [ ] Validation confirms PowerShell parse, GUI smoke, and button-smoke checks pass.
