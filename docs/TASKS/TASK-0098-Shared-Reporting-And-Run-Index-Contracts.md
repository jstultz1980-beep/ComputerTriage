# TASK-0098 - Shared Reporting and Run Index Contracts

## Status
Active

## Owner
Codex

## Depends On
TASK-0097.

## Objective
Create shared report metadata and escaping helpers plus an immutable run index that links reports and artifacts by validated run identity.

## Findings Addressed
RED-003, RED-004, RED-011, and inconsistent latest-state/report metadata behavior.

## Acceptance Criteria
- Reports share canonical metadata and escaping behavior.
- Every report resolves to one immutable run identity.
- Latest-run selection uses the run index rather than ambiguous directory order.
- Stale or deleted artifacts are explicit.

## Validation
Report snapshots, escaping fixtures, multiple-run selection, and stale/deleted artifact tests.
