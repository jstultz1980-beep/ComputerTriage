# TASK-0037 - Activity Page Running Tool Tracking

## Status
Queued

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
- [ ] Activity page includes toolkit-launched network tools in the running-work list.
- [ ] Running-program list is shorter and leaves room for other status content.
- [ ] Refresh and Stop controls are compact and visually consistent with the toolkit style.
- [ ] Activity refresh does not freeze the UI.
- [ ] PowerShell parse, smoke, and button-smoke validation pass.
