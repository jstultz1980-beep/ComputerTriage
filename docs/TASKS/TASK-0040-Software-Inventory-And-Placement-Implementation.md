# TASK-0040 - Software Inventory And Placement Implementation

## Status
Queued

## Owner
Codex

## Objective
Classify and implement Software tab placement so portable launchers, installable stored programs, and non-portable candidates are obvious and not duplicated.

## Scope
- Put launchable portable applications at the top of the Software tab.
- Reserve the bottom area for installable programs stored in the toolkit.
- Classify optional portable tools, including whether LatencyMon should be tracked, ignored, or handled separately.
- Research whether a usable portable edition of Registrar Registry Manager exists.
- If Registrar Registry Manager cannot be used portably, list it only as installable or excluded rather than as a launchable toolkit app.
- Move non-portable tools out of launchable Triage Tool lists after classification.
- Preserve safe launch behavior for true portable apps.
- Preserve installable-program visibility without implying they are portable launchers.

## Out of Scope
- Downloading new apps unless a separate task explicitly approves it.
- Silent installer automation.
- Whole app manifest redesign.
- Untracked `App/NetworkToolkit/LatencyMon/`.

## Acceptance Criteria
- [ ] Software tab is split into launchable and installable areas.
- [ ] Optional portable tools, including LatencyMon, are classified.
- [ ] Registrar Registry Manager portability is answered with source notes.
- [ ] Non-portable tools no longer appear as launchable triage tools.
- [ ] Installable tools are clearly labeled as installable.
- [ ] Existing portable launch buttons still work.
- [ ] PowerShell parse, smoke, and button-smoke validation pass.
