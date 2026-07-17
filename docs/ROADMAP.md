# Roadmap

## Product Direction

Build a portable Windows toolkit that collects, validates, analyzes, explains, and reports the health of one computer at a time. Deterministic local processing comes first; ARGUS provides cited explanation and technician guidance.

## Current Phase - Version 1.0 Field-Test Performance Maintenance

Status: Active.

Current Active task:
- `TASK-0118-Startup-Warmup-And-Heavy-Tab-Deferral`

Current objective:
- Reduce the measured 4.5-4.9 second shell-to-usable-window time.
- Replace eager 27-tab launch warm-up with bounded idle/on-demand initialization.
- Make Print, Analyze, Directory, and Windows Update truly deferred or staged.
- Preserve the published `v1.0.0` tag and release artifacts unchanged.

## Current Sequence

1. **TASK-0118 - Startup Warm-Up And Heavy-Tab Deferral**
   - Capture baseline and post-change evidence through the existing performance telemetry.
   - Eliminate eager launch warming of all 27 tabs.
   - Defer expensive embedded-script and live-data work until the associated workflow is selected.
   - Preserve user-selection priority, one-time initialization, failure isolation, and responsive navigation.
2. **Separate deferred-startup defect triage**
   - The `Write-GUILog` deferred-startup failure remains outside TASK-0118 and requires its own tracked disposition.
3. **Continue structured field testing**
   - Confirmed defects become focused maintenance tasks.
   - Enhancements remain Feature Requests for a later planning cycle.

## Version 1.0 Baseline

- `v1.0.0` is published from accepted commit `38de0b626fe3cadc6848a12b9e40fadfc7006151`.
- The release record and verified manifest remain authoritative.
- TASK-0114 and later maintenance work are post-release development and must not alter the existing tag.

## Field-Test Direction

- Real-world measured evidence takes precedence over subjective impressions.
- Launch and ReadyForUser timing must use the existing monotonic telemetry.
- Launch must not perform expensive work for tabs the technician may never open.
- Heavy tabs must be demand-driven or staged without hiding failures or changing workflow semantics.
- The Performance Dashboard remains restricted to the Settings page.
- Missing or insufficient performance data must not be graded as PASS.
- Confirmed release defects remain isolated into focused maintenance tasks.

## Deferred Work

Net-new diagnostic features, external-tool helper frameworks, native replacements, broad UI redesign, and unrelated expansion remain deferred. The `Write-GUILog` startup defect is deferred only from TASK-0118, not dismissed.

## Historical Record

Completed chronology, superseded planning, audit transitions, release evidence, publication metadata, and field-test remediation evidence remain in individual task records and `docs/HISTORY` rather than this forward-looking roadmap.
