# TASK-0037 - Activity Page Running Tool Tracking

## Status
Active

## Owner
Codex

## Objective
Make the Activity page a compact live view of toolkit-owned running work, including network-related tools.

## Scope
- Add network tools/processes to the Activity page tracking model.
- Reduce the height of the running-program list so the page is not dominated by a long table.
- Make Refresh and Stop controls smaller and cleaner.
- Use the toolkit's modern button/control style instead of default-looking buttons.
- Show only toolkit-owned or toolkit-launched processes unless a user-facing reason exists to show more.
- Avoid continuous polling that causes UI lag or memory growth.

## Out of Scope
- Whole-system task manager replacement.
- Real-time graph/gauge implementation unless already available from existing Activity page work.
- Killing non-toolkit processes.
- Untracked `App/NetworkToolkit/LatencyMon/`.

## Acceptance Criteria
- [x] Activity page includes network visibility in the live status area.
- [ ] Running-program list is shorter and leaves room for other status content.
- [ ] Refresh and Stop controls are compact and visually consistent with the toolkit style.
- [ ] Activity refresh does not freeze the UI.
- [ ] PowerShell parse, smoke, and button-smoke validation pass.

## Work Log

### Entry 001
Author: Codex
Date: 2026-07-02
Files Changed:
- `App/ToolKit-GUI/ToolKit-GUI.ps1`
- `docs/TASKS/TASK-0037-Activity-Page-Running-Tool-Tracking.md`
Validation Performed:
- Parsed `App/ToolKit-GUI/ToolKit-GUI.ps1` with the PowerShell parser.
- Ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -SmokeTest`.
- Ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -ButtonSmokeTest`.
Issues:
- This entry adds the requested Network gauge to the Activity page. The rest of TASK-0037 remains active because compacting the running-process list and controls is still outstanding.

## Current Notes
- Activity now shows CPU, RAM, Disk, and Network gauges.
- The Network gauge uses Windows network-interface performance counters and displays current utilization plus Mbps detail when available.
