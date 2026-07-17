# TASK-0118 - Startup Warm-Up And Heavy-Tab Deferral

## Status
Active

## Owner
Codex

## Depends On
- TASK-0117 responsive initial layout and DPI remediation.
- TASK-0114 performance QA instrumentation and Settings-only dashboard.
- TASK-0112 cold-tab initialization performance remediation.

## Objective
Reduce measured startup and perceived first-use latency by eliminating the eager launch-time warm-up of 27 tabs and making the heaviest tabs truly demand-driven, while preserving responsive navigation, existing telemetry, PowerShell 5.1 behavior, and the published Version 1.0 baseline.

## Evidence
`docs/REVIEWS/TASK-0117/PERFORMANCE-AUDIT-FINDINGS.md` records:

- shell-to-usable-window time of approximately 4.5-4.9 seconds;
- a launch-time deferred warm-up queue containing 27 tabs;
- materially heavy first renders for Print, Analyze, Directory, and Windows Update;
- deferred tab construction and embedded-script execution as the dominant perceived delay.

## Scope
- Measure and document the current launch, ReadyForUser, queue depth, and first-open baselines before changes.
- Replace eager launch-time warming of all 27 tabs with a bounded policy that prioritizes the visible/default workflow and performs only low-cost idle work when the UI is genuinely idle.
- Make Print, Analyze, Directory, and Windows Update demand-driven or staged so expensive embedded-script work does not run merely because the toolkit launched.
- Preserve safe user-selection priority: selecting an unopened tab must cancel/yield lower-priority warm-up and initialize the selected tab exactly once.
- Reduce avoidable startup log and repaint churn without suppressing warnings or errors.
- Cache only immutable/static metadata and layout calculations where existing contracts permit it; do not cache live diagnostic results.
- Extend the existing TASK-0100, TASK-0112, and TASK-0114 telemetry rather than creating another timing framework.
- Add deterministic validation for queue policy, heavy-tab deferral, one-time initialization, user priority, failure isolation, and measured regression thresholds.
- Update build metadata and required task, evidence, changelog, ledger, roadmap, queue, and handoff records.

## Out Of Scope
- Broad GUI redesign.
- Removing tabs or features.
- Pre-running diagnostics or external tools to disguise latency.
- Changing the published `v1.0.0` tag or release artifacts.
- The separate deferred-startup `Write-GUILog` failure; it remains independently tracked for Project Custodian sequencing.
- Net-new diagnostic features, helper frameworks, or native replacement work.

## Required Design Behavior
1. The main window and default workflow must become usable before nonessential tab work begins.
2. Launch must not enqueue all primary tabs for immediate warm-up.
3. Heavy tabs must not execute embedded scripts, live discovery, or expensive data binding until selected or explicitly requested.
4. Optional idle warm-up must be bounded by tab cost classification, queue depth, UI-idle state, and cancellation/yield behavior.
5. User selection always outranks background warm-up.
6. Controls and handlers are constructed once; revisits must not duplicate initialization.
7. A deferred-tab failure is isolated, logged, and surfaced when relevant without crashing startup.
8. Telemetry must distinguish shell ready, ReadyForUser, idle warm-up, user-selected initialization, and heavy deferred work.

## Acceptance Criteria
- [ ] Baseline and post-change launch evidence are captured using the existing performance telemetry.
- [ ] The launch-time warm-up queue no longer schedules 27 tabs.
- [ ] Print, Analyze, Directory, and Windows Update perform no expensive embedded-script or live-data work solely because the toolkit launched.
- [ ] Default launch and ReadyForUser time improve measurably without increasing first-use failure rates.
- [ ] Selecting an unopened tab during idle warm-up safely prioritizes that tab and initializes it exactly once.
- [ ] Repeated tab navigation produces no duplicate controls, handlers, or background operations.
- [ ] Missing/corrupt telemetry remains warning or insufficient-data, never false PASS.
- [ ] PowerShell 5.1 parser, GUI smoke, button smoke, warm-up, performance QA, lifecycle, focused fixtures, and canonical repository validation pass.
- [ ] The published Version 1.0 release and unrelated drift remain untouched.

## Required Evidence
- Before/after launch and ReadyForUser timing table.
- Before/after launch queue-depth and tab-cost policy evidence.
- First-open and warm-open timings for all primary tabs, highlighting Print, Analyze, Directory, and Windows Update.
- Focused test results for bounded idle warm-up, demand-driven heavy tabs, user priority, one-time initialization, and failure isolation.
- Canonical validation result and technician-visible launch/navigation smoke result.

## Rollback Plan
Revert the focused warm-up policy, heavy-tab deferral, caching, telemetry, and validation changes; restore the TASK-0117 known-good behavior; preserve all unrelated drift; and return the measured failure evidence to the Project Custodian.
