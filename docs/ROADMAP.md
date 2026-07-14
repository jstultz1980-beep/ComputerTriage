# Roadmap

## Product Direction

Build a portable Windows toolkit that collects, validates, analyzes, explains, and reports the health of one computer at a time. Deterministic local processing comes first; ARGUS provides cited explanation and technician guidance.

## Current Phase - Real-World Performance QA Instrumentation

Status: Active.

Current Active task:
- `TASK-0114-Performance-QA-Instrumentation-And-Settings-Dashboard`

Current objective:
- Add objective launch, navigation, operation, external-tool, and resource timing for field QA.
- Automate performance review from recorded telemetry rather than subjective impressions.
- Add a Performance Dashboard accessible only from the Settings page.
- Preserve the published `v1.0.0` tag and release artifacts unchanged.

## Current Sequence

1. **TASK-0114 - Performance QA Instrumentation and Settings Dashboard**
   - Extend the existing performance telemetry rather than create a competing framework.
   - Record launch through `ReadyForUser`, cold/warm navigation, operation lifecycle, external-tool timing, and resource trends.
   - Add bounded storage, automated QA reporting, export, and a Settings-only dashboard.
   - Validate instrumentation overhead and PowerShell 5.1 compatibility.
2. **Project Custodian Performance QA Review**
   - Review implementation evidence and real-world sample data after TASK-0114 completes.
   - Approve the structured field-test checklist and determine whether a maintenance release is warranted.

## Version 1.0 Baseline

- `v1.0.0` is published from accepted commit `38de0b626fe3cadc6848a12b9e40fadfc7006151`.
- The release record and verified manifest remain authoritative.
- TASK-0114 changes are post-release development and must not alter the existing tag.

## Performance QA Direction

- Measured data takes precedence over subjective impressions.
- Elapsed duration must use monotonic timing.
- Missing or insufficient data must not be graded as a pass.
- Performance telemetry must not contain credentials, secrets, raw diagnostic evidence, or user document contents.
- Dashboard access is restricted to the Settings page and must not expand primary navigation.
- Instrumentation must be low overhead, bounded, append-safe, and suitable for regression comparison.

## Deferred Work

Net-new diagnostic features, external-tool helper frameworks, native replacements, and unrelated expansion remain deferred until TASK-0114 completes and the next planning cycle is approved.

## Historical Record

Completed chronology, superseded planning, audit transitions, release evidence, and publication metadata remain in individual task records and `docs/HISTORY` rather than this forward-looking roadmap.
