# TASK-0030 - Print Tab Data Path Cleanup

## Status
Active

## Owner
Codex

## Objective
Remove the visible print queue data-folder path from the Print tab because it does not help technicians during normal use.

## Scope
- Remove the `Data folder:` path display from the Print tab.
- Reclaim the space for more useful print queue controls or diagnostics layout.
- Preserve print queue maintenance behavior and output locations.

## Out of Scope
- Print queue engine changes.
- Print queue standalone tool migration.
- Printer artifact cleanup logic.
- Untracked `App/NetworkToolkit/LatencyMon/`.

## Acceptance Criteria
- [ ] Print tab no longer shows the data-folder path.
- [ ] Existing print buttons still launch the correct actions.
- [ ] Print outputs still save to the current expected toolkit data/output locations.
- [ ] PowerShell parse, smoke, and button-smoke validation pass.
