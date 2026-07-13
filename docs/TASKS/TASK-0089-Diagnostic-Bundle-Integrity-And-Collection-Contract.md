# TASK-0089 - Diagnostic Bundle Integrity and Collection Contract

## Status
Complete

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
- [x] Recorded final bundle hash validates the delivered ZIP.
- [x] Tampering is detected.
- [x] Every collector outcome is persisted.
- [x] Section status cannot be Completed when a required inner operation failed.
- [x] Manifest and capability metadata agree.

## Validation
Run timeout, nonzero-exit, missing executable, failed PowerShell collector, write failure, partial collection, final hash, and tamper fixtures.

## Work Log
- Replaced the self-referential embedded ZIP hash with a final sidecar SHA-256 record.
- Added reusable delivered-bundle verification and tamper detection.
- Persisted command, PowerShell collector, and portable-tool outcomes plus capability completeness in the run manifest.
- Made collector section status derive from inner boolean/canonical operation outcomes.
- Added nonzero, missing executable, failed collector, final hash, tamper, and inner-section failure fixtures.
- Parser, targeted integrity, parser-quality, toolkit, GUI smoke, and button-smoke validation passed.
