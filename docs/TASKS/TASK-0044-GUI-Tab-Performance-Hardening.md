# TASK-0044 - GUI Tab Performance Hardening

## Status
Complete

## Owner
Codex

## Objective
Reduce the first-open Activity tab lag and remaining tab-to-tab navigation lag.

## User Need
The Activity tab renders faster than most pages after the first load, but the first visit still lags. Moving between tabs is improved but still noticeably slow. The toolkit should feel responsive during live troubleshooting.

## Scope
- Profile `NetworkToolkit.vbs` launch delay before the PowerShell GUI appears.
- Reduce launcher overhead where possible without reintroducing console popups.
- Confirm tabs are not unnecessarily built during launch; defer tab page construction until first selection where practical.
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
- [x] `NetworkToolkit.vbs` launch delay is measured and the slowest step is identified or improved.
- [x] Tabs are not prebuilt during launch unless required for startup correctness.
- [x] First Activity tab load is measurably faster or the blocking operation is identified and isolated.
- [x] Tab-switch diagnostics identify any tab taking longer than the slow-switch threshold.
- [x] Activity refresh does not run while another tab is selected.
- [x] Missing or slow counters do not freeze the GUI.
- [x] Validation confirms PowerShell parse, GUI smoke, and button-smoke checks pass.

## Progress Notes
- Read `punch_list.txt` before implementation. Items 13 and 14 are already covered by this active task.
- Added a normal-launch deferred startup path: the form shell can paint first, then the selected startup tab builds on a short one-shot timer.
- Kept smoke and button-smoke validation synchronous so tests still confirm the startup tab can build correctly.
- Added a loading placeholder for deferred startup tabs.
- Deferred Wi-Fi probing until after the form is shown so `netsh wlan show interfaces` does not block initial shell paint.
- Deferred Activity page CIM/process refresh until after the Activity page paints.
- Added cleanup for startup and initial Activity one-shot timers.
- Added GUI startup shell timing to the diagnostic log.
- Updated `NetworkToolkit.vbs` to launch PowerShell with `-NoLogo` and `-NonInteractive` while keeping hidden elevated startup behavior.
- Punch-list item 27 is also covered by this active performance task.
- Remaining punch-list items 16-26 and 28 are Windows Update/Wi-Fi/Settings/Triage/header/control-polish follow-ups and should be handled after this performance task or reconciled into the next status-indicator/layout task/audit cycle.
- Added a shared slow-tab diagnostic helper that logs `SlowTabSwitch` with source, elapsed time, control count, built state, and threshold.
- Added `SlowTabBuild` diagnostics when first-load construction exceeds the slow-tab threshold.
- Slow tab switches and slow first-build events now update the status bar with the affected tab and elapsed milliseconds.
- Completed TASK-0044. Completing this task brings the Task System counter to `10 / 10`, so TASK-0053 Task System Counter Audit is required before further implementation.

## Validation
- PowerShell parser validation passed for `App/ToolKit-GUI/ToolKit-GUI.ps1`.
- GUI smoke test passed via `App/NetworkToolkit.ps1 -SmokeTest`.
- Button smoke test passed via `App/NetworkToolkit.ps1 -ButtonSmokeTest`.
- Smoke-path baseline measured around 6-7 seconds in this environment; normal launch now defers startup tab and Wi-Fi work until after the shell is shown.
- PowerShell parser, GUI smoke, and button-smoke validation passed after the final slow-tab diagnostics pass.

## Test This
- Launch with `NetworkToolkit.vbs` and confirm the main shell appears sooner, even if the first tab says it is loading briefly.
- Open Activity for the first time and confirm the page appears before gauges/processes populate.
- Switch away from Activity and confirm gauges stop refreshing until Activity is selected again.
- Confirm normal tab switching still builds tabs on first selection and then reopens quickly.
- Confirm there is no console popup from the VBS launcher.
