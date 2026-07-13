# TASK-0089 - Diagnostic Bundle Integrity and Collection Contract

## Status
Active

## Owner
Codex

## Depends On
TASK-0086 through TASK-0088.

## Objective
Create a trustworthy diagnostic run manifest and bundle integrity model with accurate per-collector and per-artifact outcomes.

## Findings Addressed
- HF-001
- HF-003
- HF-004
- collection-manifest completeness defects

## Scope
- Replace the invalid self-referential ZIP hash design.
- Use a sidecar final ZIP hash or canonical content-manifest hash.
- Record every command and PowerShell collector result.
- Distinguish required, optional, skipped, failed, partial, and successful artifacts.
- Ensure section status is derived from inner operation results.
- Link bundle identity, run identity, tool version, and producer version.

## Acceptance Criteria
- [ ] Recorded final bundle hash validates the delivered ZIP.
- [ ] Tampering is detected.
- [ ] Every collector outcome is persisted.
- [ ] Section status cannot be Completed when a required inner operation failed.
- [ ] Manifest and capability metadata agree.

## Validation
Run timeout, nonzero-exit, missing executable, failed PowerShell collector, write failure, partial collection, final hash, and tamper fixtures.
