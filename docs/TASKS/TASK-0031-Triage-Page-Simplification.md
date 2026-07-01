# TASK-0031 - Triage Page Simplification

## Status
Queued

## Owner
Codex

## Objective
Simplify the Triage page so it exposes only the workflows the project owner wants: Quick Triage and Full Triage.

## Scope
- Remove or hide excess triage options from the primary UI.
- Keep only Quick Triage and Full Triage as first-class buttons.
- Reevaluate whether the live triage log should be removed, hidden behind details, or replaced by concise progress/status.
- Keep generated triage outputs and diagnostic bundles intact.
- Keep any advanced/internal collector options available only if needed for maintenance, not as primary technician workflow.

## Out of Scope
- Removing backend triage collectors unless separately approved.
- Changing ARGUS or HEPHAESTUS analysis contracts.
- Changing report schema.
- Untracked `App/NetworkToolkit/LatencyMon/`.

## Acceptance Criteria
- [ ] Triage page primary actions are Quick Triage and Full Triage only.
- [ ] Live triage log is either removed from the main view or replaced with a concise status/progress display.
- [ ] Existing quick/full triage workflows still produce their expected outputs.
- [ ] PowerShell parse, smoke, and button-smoke validation pass.
