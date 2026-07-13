# TASK-0091 - Print and Remote Change Transaction Safety

## Status
Active

## Owner
Codex

## Depends On
TASK-0090.

## Objective
Make print and remote-management changes transactional, verifiable, recoverable, and rollback-capable.

## Findings Addressed
PLG-001, PLG-003 through PLG-006.

## Acceptance Criteria
- Pre-state is captured before change.
- Per-step results are structured and verified.
- Spooler recovery is guaranteed or explicitly failed.
- Partial firewall/service changes are detectable.
- Original state can be restored.

## Validation
Locked spool files, partial firewall changes, service-start failure, rollback, and cancellation fixtures.
