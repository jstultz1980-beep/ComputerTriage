# TASK-0114 - Performance QA Instrumentation And Settings Dashboard

## Status
Complete

## Owner
Codex

## Depends On
- Published Version 1.0 baseline (`v1.0.0`).
- TASK-0112 cold-tab initialization instrumentation and warm-up behavior.
- TASK-0100 performance telemetry and run-scoped observation cache.

## Objective
Add objective, persistent performance instrumentation for real-world QA and expose the performance dashboard only from the Settings page.

## User Direction
The user is beginning real-world testing and wants an unbiased performance review based on recorded timings rather than subjective impressions. The performance dashboard must be accessible only from the Settings page.

## Scope
- Add launch timing from process start through a clearly defined `ReadyForUser` milestone.
- Record startup stages, including configuration load, manifest load, module/plugin discovery, static UI construction, default-tab readiness, background warm-up start, and background warm-up completion where applicable.
- Reuse and extend existing TASK-0100 and TASK-0112 telemetry rather than creating a competing timing framework.
- Record first-open and warm-open timing for every primary tab.
- Record user-triggered operation timing through the existing operation lifecycle, including queued, started, completed, failed, cancelled, and timed-out states.
- Record process resource snapshots sufficient for QA trend analysis: working set, private memory where available, handle count, thread count, and process CPU time at defined lifecycle points.
- Record external-tool launch latency, execution duration, exit code, timeout, and retry count where the toolkit launches an external executable.
- Store telemetry in a bounded, append-safe, machine-readable format suitable for automated QA analysis.
- Add retention and reset controls so telemetry cannot grow without limit.
- Add a Performance Dashboard that is reachable only from the Settings page; do not add it to primary navigation or normal diagnostic tabs.
- Provide current-run, recent-run, average, best, worst, and regression-oriented summaries for startup, tab navigation, selected operations, and resource use.
- Add export of a QA performance bundle that contains telemetry and environment context without exposing credentials or sensitive diagnostic content.
- Add an automated Performance QA checklist/report that grades measured behavior against documented budgets and clearly distinguishes measured failure, warning, pass, and insufficient-data states.
- Preserve PowerShell 5.1 compatibility, current UI behavior, cancellation semantics, error reporting, and unrelated working-tree drift.

## Required Timing Contract
Each timing event must include, at minimum:

- Schema/version identifier.
- Run identifier.
- UTC timestamp plus local offset.
- Event category and operation name.
- Stage name when applicable.
- Start and end monotonic timing values or an equivalent duration-safe mechanism.
- Duration in milliseconds.
- Outcome: Success, Failure, Cancelled, Timeout, or Skipped.
- Cold/warm state where applicable.
- Thread/context identifier where useful.
- Toolkit version and source commit when available.
- Machine/environment fingerprint suitable for comparison without including secrets.

Wall-clock timestamps must not be used as the sole duration source. Use a monotonic timer such as `System.Diagnostics.Stopwatch` for elapsed time.

## Dashboard Access Rule
- The Performance Dashboard must be opened from the Settings page only.
- It must not appear in the main tab strip, primary navigation, launch screen, or diagnostic workflow menus.
- Settings may contain a clearly labeled button or section such as `Performance & QA`.
- Opening the dashboard must not trigger diagnostic collection or materially delay Settings-page rendering.

## QA Report Requirements
The automated report must cover:

1. Startup and `ReadyForUser` timing.
2. Cold and warm tab navigation.
3. UI responsiveness and operation queue delay.
4. Selected built-in operation duration.
5. External-tool launch and completion timing where exercised.
6. Memory, handle, and thread trends across the session.
7. Shutdown timing and orphan-process checks where measurable.
8. Regression comparison against an accepted baseline or previous runs.
9. Data-quality status and minimum sample-size warnings.
10. A machine-readable result and a technician-readable summary.

## Out Of Scope
- Broad UI redesign.
- New diagnostic features or external tools.
- Uploading telemetry to any cloud service.
- Collecting user content, credentials, report contents, or sensitive diagnostic payloads for performance purposes.
- Changing Version 1.0 release artifacts or the published tag.
- Treating one unusually slow run as proof of a regression without sample context.

## Acceptance Criteria
- [x] Toolkit launch records a complete startup timeline through `ReadyForUser` using monotonic duration measurement.
- [x] Primary-tab first-open and warm-open timings are recorded without duplicate instrumentation or measurable UI regression.
- [x] Existing operation lifecycle timings are normalized into the performance QA dataset.
- [x] External-tool timing is recorded where toolkit-controlled launches occur.
- [x] Resource snapshots are captured at defined points with graceful fallback when a metric is unavailable.
- [x] Telemetry files are append-safe, bounded by retention policy, and recover from a corrupt final record without losing prior valid data.
- [x] No credentials, secrets, raw diagnostic evidence, or user document contents are stored in performance telemetry.
- [x] The Performance Dashboard is accessible only from Settings and nowhere in primary navigation.
- [x] The dashboard loads historical summaries without blocking the UI and supports reset/export with confirmation where destructive.
- [x] Automated QA output includes startup, navigation, operation, resource, regression, and data-quality results.
- [x] Budgets are documented, configurable where appropriate, and do not silently convert missing data into passes.
- [x] Focused telemetry, retention, corruption, dashboard-access, and report-generation tests pass.
- [x] PowerShell 5.1 parser, GUI smoke, button smoke, operation lifecycle, cold-tab, performance/cache, and canonical repository validation pass.
- [x] Technician-visible testing confirms the instrumentation itself does not create noticeable launch or navigation lag.
- [x] Required task, handoff, queue, roadmap, history, counter, and build-metadata records are reconciled.

## Completion Record

- Validation evidence: `docs/REVIEWS/TASK-0114/VALIDATION.md`
- Generated QA bundle: `App/NetworkToolkit/Utilities/Performance.ps1` `Export-NTKPerformanceQABundle`
- Focused validation: parser, GUI smoke, button smoke, operation lifecycle, cold-tab, performance/cache, canonical architecture, and reporting/run-index checks
- Result: TASK-0114 implementation complete; performance QA evidence and shutdown/orphan-process telemetry captured; ready for Project Custodian review

## Required Evidence
- Startup stage timing table from at least five cold launches on the same representative machine.
- Cold/warm tab timing table with sample count, average, median, best, worst, and percentile where practical.
- Instrumentation overhead comparison with telemetry enabled versus disabled or baseline behavior.
- Telemetry schema and representative sanitized sample.
- Retention, append-safety, and corrupt-tail recovery validation.
- Proof that the dashboard is reachable only from Settings.
- Automated QA report sample in machine-readable and technician-readable form.
- Canonical validation result.

## Rollback Plan
Revert TASK-0114 implementation and validation commits, restore the previous settings and telemetry behavior from Git history, preserve collected QA files as non-authoritative evidence unless the user directs otherwise, and leave published `v1.0.0` unchanged.
