# TASK-0040 - Software Tab Launchable And Installable Implementation

## Status
Queued

## Owner
Codex

## Objective
Implement the accepted Software tab separation between launchable apps and toolkit-stored installers.

## Scope
- Put launchable portable applications at the top of the Software tab.
- Reserve the bottom area for installable programs stored in the toolkit.
- Move non-portable tools out of launchable Triage Tool lists after they are classified.
- Preserve safe launch behavior for true portable apps.
- Preserve installable-program visibility without implying they are portable launchers.

## Dependencies
- `TASK-0039-Software-Tab-Launchable-And-Installable-Inventory`

## Out of Scope
- Downloading new apps unless a separate task explicitly approves it.
- Silent installer automation.
- Whole app manifest redesign.
- Untracked `App/NetworkToolkit/LatencyMon/`.

## Acceptance Criteria
- [ ] Software tab is split into launchable and installable areas.
- [ ] Non-portable tools no longer appear as launchable triage tools.
- [ ] Installable tools are clearly labeled as installable.
- [ ] Existing portable launch buttons still work.
- [ ] PowerShell parse, smoke, and button-smoke validation pass.
