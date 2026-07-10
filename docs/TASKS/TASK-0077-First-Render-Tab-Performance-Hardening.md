# TASK-0077 - First Render Tab Performance Hardening

## Status
Queued

## Owner
Codex

## Purpose
Measure and reduce remaining first-render tab switching lag.

## Scope
- Capture first-render and repeat-render timings for heavy tabs.
- Identify work that can be deferred until after the tab paints.
- Reduce visible blocking where reasonable.
- Document any remaining acceptable limitation.

## Out Of Scope
- Rewriting the GUI framework.
- Removing required tab content.
- ARGUS or HEPHAESTUS feature work.

## Acceptance Criteria
- [ ] Timing evidence is recorded before and after changes.
- [ ] Worst first-render offenders are identified.
- [ ] At least one meaningful deferral or improvement is implemented, or a clear limitation is documented.
- [ ] GUI smoke and button-smoke validation pass.
