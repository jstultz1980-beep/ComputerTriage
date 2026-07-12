# TASK-0086 - Offline Evidence Isolation and Bundle Identity

## Status
Active

## Owner
Codex

## Depends On
TASK-0084 audit completion. Dependency satisfied on 2026-07-12.

## Objective
Ensure deterministic and ARGUS analysis operate on the intended immutable diagnostic run and never silently mix the analysis host’s live data into an offline bundle.

## Findings Addressed
- HF-006
- HF-009
- HF-010
- HF-012
- DEP-014

## Scope
- Add immutable run/bundle identity markers.
- Validate explicit/default bundle roots against the diagnostic contract.
- Separate offline bundle analysis from any live-host mode.
- Remove current-host CIM/environment data from offline analysis.
- Exclude generated `Analysis`, `Metadata`, `ARGUS`, and report outputs from source evidence inventory.
- Make repeated analysis idempotent apart from documented generation timestamps.
- Require ARGUS to use the validated run identity.

## Out Of Scope
- Broad new deterministic rules.
- Recommendation changes except those required to preserve source identity.
- GUI redesign.

## Acceptance Criteria
- [ ] Computer-A fixture analyzed on Computer-B contains no Computer-B identity or health data.
- [ ] Invalid, empty, partial, and unrelated export directories are rejected.
- [ ] Default selection considers only valid bundles.
- [ ] Repeated analysis does not treat generated output as evidence.
- [ ] Run identity is preserved through deterministic and ARGUS artifacts.

## Validation
Use cross-machine, mixed-export, invalid-root, and two-run idempotence fixtures. Run parser, smoke, and button-smoke validation.

## Rollback
Revert only bundle identity/isolation changes and restore the previous explicit analysis path; do not remove audit fixtures.