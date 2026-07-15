# Roadmap

## Product Direction

Build a portable Windows toolkit that collects, validates, analyzes, explains, and reports the health of one computer at a time. Deterministic local processing comes first; ARGUS provides cited explanation and technician guidance.

## Current Phase - Project Custodian Performance QA Review

Status: Active.

Current Active task:
- `TASK-0116-Project-Custodian-Documentation-Engineering-Audit`

Current objective:
- Review the completed TASK-0114 implementation evidence and TASK-0115 documentation-audit evidence.
- Decide the Documentation gate and confirm whether any follow-up is warranted.
- Preserve the published `v1.0.0` tag and release artifacts unchanged.

## Current Sequence

1. **Project Custodian Performance QA Review**
   - Review implementation evidence, documentation evidence, and sample data after TASK-0114 completion.
   - Approve the structured field-test checklist and determine whether a maintenance release is warranted.
2. **Next Codex implementation task**
   - No new Codex-owned implementation task is ordered until the review boundary is resolved.

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
