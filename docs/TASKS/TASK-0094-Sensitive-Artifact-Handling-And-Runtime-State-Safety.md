# TASK-0094 - Sensitive Artifact Handling and Runtime State Safety

## Status
Active

## Owner
Codex

## Depends On
TASK-0093.

## Objective
Classify and protect sensitive artifacts, define retention and transfer policy, and make runtime state writes atomic and separate from immutable defaults.

## Findings Addressed
PLG-011 through PLG-015; SEC-005 through SEC-007; DEP-007 through DEP-010 and DEP-013.

## Acceptance Criteria
- Sensitive values are masked by default.
- Reveal/export actions are explicit and auditable.
- Retention and pinning are defined.
- Transfers are selective and verified.
- Runtime writes are atomic and concurrency-safe.
- Runtime state is separated from shipped defaults.

## Validation
Mask/reveal/export, retention, selective transfer, interrupted write, concurrent write, and default/runtime separation fixtures.
