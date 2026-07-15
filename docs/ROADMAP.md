# Roadmap

## Product Direction

Build a portable Windows toolkit that collects, validates, analyzes, explains, and reports the health of one computer at a time. Deterministic local processing comes first; ARGUS provides cited explanation and technician guidance.

## Current Phase - Version 1.0 Field-Test Maintenance

Status: Active.

Current Active task:
- `TASK-0117-Responsive-Initial-Layout-And-DPI-Remediation`

Current objective:
- Correct the default-launch right-side clipping found during real-world testing.
- Add deterministic layout-boundary validation and verify supported resolution/scaling behavior.
- Preserve the published `v1.0.0` tag and release artifacts unchanged.

## Current Sequence

1. **TASK-0117 - Responsive Initial Layout And DPI Remediation**
   - Correct horizontal overflow without broad UI redesign.
   - Validate default launch, resizing, representative resolution, and DPI scaling.
2. **Separate deferred-startup defect triage**
   - The `Write-GUILog` deferred-startup failure is not part of TASK-0117 and requires its own tracked disposition.
3. **Continue structured field testing**
   - Confirmed defects become focused maintenance tasks.
   - Enhancements remain Feature Requests for a later planning cycle.

## Version 1.0 Baseline

- `v1.0.0` is published from accepted commit `38de0b626fe3cadc6848a12b9e40fadfc7006151`.
- The release record and verified manifest remain authoritative.
- TASK-0114 and later maintenance work are post-release development and must not alter the existing tag.

## Field-Test Direction

- Real-world evidence takes precedence over assumptions from automated smoke tests.
- Confirmed release defects are isolated into focused maintenance tasks.
- Layout fixes must preserve feature access and existing visual hierarchy.
- Horizontal clipping, overlap, inaccessible controls, and unsupported DPI assumptions are release-quality defects.
- The Performance Dashboard remains restricted to the Settings page.
- Measured performance data remains the basis for performance QA decisions.

## Deferred Work

Net-new diagnostic features, external-tool helper frameworks, native replacements, broad UI redesign, and unrelated expansion remain deferred. The `Write-GUILog` startup defect is deferred only from TASK-0117, not dismissed.

## Historical Record

Completed chronology, superseded planning, audit transitions, release evidence, publication metadata, and field-test remediation evidence remain in individual task records and `docs/HISTORY` rather than this forward-looking roadmap.
