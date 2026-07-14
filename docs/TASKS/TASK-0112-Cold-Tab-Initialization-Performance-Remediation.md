# TASK-0112 - Cold Tab Initialization Performance Remediation

## Status
Complete

## Owner
Codex

## Depends On
TASK-0080 release-candidate evidence and Project Custodian disposition.

## Objective
Remove the repeatable first-open lag observed when a toolkit tab is selected for the first time after application startup, without shifting the same delay into synchronous startup.

## User Evidence
The primary observed lag occurs when selecting a tab that has not yet been opened during the current toolkit session. Reopening an already initialized tab is materially faster.

## Scope
- Instrument first-selection initialization time for every primary tab.
- Separate control construction, module/configuration reads, static metadata binding, and live data refresh timings where practical.
- Identify repeated file reads, module loads, icon creation, event registration, or control construction performed during first selection.
- Initialize each tab's lightweight static UI exactly once.
- After the main window becomes responsive, warm unopened tabs one at a time through an idle/background-safe queue.
- Keep expensive live data collection deferred until explicitly required by the selected workflow.
- Cache immutable manifests, tool metadata, static configuration, and reusable visual resources where safe.
- Preserve existing operation lifecycle, cancellation, error reporting, and PowerShell 5.1 behavior.
- Add deterministic cold-tab and warm-tab performance validation.
- Re-run canonical repository validation and technician-visible navigation smoke testing.

## Out Of Scope
- Broad UI redesign.
- New features or tools.
- Pre-running diagnostics or live collection merely to hide latency.
- Increasing synchronous startup time by eagerly running every tab's expensive work.
- Native replacement or helper framework work.
- Release tagging, publication, or distribution.

## Required Design Behavior
1. Show the main window and default tab without waiting for all tabs to initialize.
2. Warm remaining tabs only after the UI is responsive.
3. Warm one tab at a time to avoid CPU, disk, and UI-thread contention.
4. Cancel or yield background warm-up when the user selects a tab, giving that tab priority.
5. Construct controls and register handlers once; revisiting a tab must not duplicate handlers or controls.
6. Dynamic data must refresh according to existing workflow rules, not merely because a tab was warmed.
7. A warm-up failure must be isolated, logged, and surfaced when the affected tab is selected; it must not crash startup.

## Acceptance Criteria
- [x] Per-tab cold and warm timings are recorded with tab identity and initialization stage.
- [x] The default tab remains usable promptly after launch.
- [x] Unopened tabs are warmed after startup without blocking normal UI interaction.
- [x] First manual selection of a successfully warmed tab is visually responsive and does not perform duplicate initialization.
- [x] Selecting a tab before background warm-up completes prioritizes that tab safely.
- [x] Static resources are cached without stale dynamic diagnostic results.
- [x] Event-handler and control duplication checks pass across repeated navigation.
- [x] Existing Analyze, Triage, cancellation, and lifecycle behavior remains intact.
- [x] PowerShell 5.1 parser, GUI smoke, button smoke, focused performance tests, and canonical repository validation pass.
- [x] TASK-0080 is returned to the Project Custodian for the final release-readiness decision.

## Required Evidence
- Before/after cold-tab and warm-tab timing table for all primary tabs.
- Identification of the measured causes of first-open delay.
- Focused validation for warm-up ordering, user-selection priority, one-time initialization, and failure isolation.
- Canonical repository validation result.
- Technician navigation smoke-test result.

## Rollback Plan
Revert the focused tab warm-up, caching, instrumentation, and validation commits; restore the prior lazy tab initialization behavior from Git history; preserve all unrelated drift; and return TASK-0080 to the Project Custodian with the failed performance evidence.

## Completion Result

- Added a reusable cold-tab warm-up controller for queued, one-tab-at-a-time initialization.
- Instrumented tab builds with per-stage timings and background warm-up timings.
- Added focused controller validation for ordering, user priority, duplicate-initialization suppression, and failure isolation.
- Canonical repository validation passed 20 stages with zero failures.
- TASK-0080 returned to the Project Custodian release-readiness boundary.
