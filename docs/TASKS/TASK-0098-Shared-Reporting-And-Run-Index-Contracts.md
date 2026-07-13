# TASK-0098 - Shared Reporting and Run Index Contracts

## Status
Complete

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

## Result

- Added one shared PowerShell 5.1 reporting contract for HTML/Markdown escaping, validated metadata, standalone and bundle-derived run identities, and immutable artifact records.
- Indexed Quick Diagnosis, Computer Fingerprint, HEPHAESTUS, ARGUS, Software Key Finder, crash-event, and full-triage report families.
- Changed report discovery and diagnostic-bundle selection to use indexed collection identity time rather than directory modification order.
- Made artifact resolution explicitly return `Available`, `Stale`, or `Missing` from recorded length and SHA-256 evidence.
- Passed report snapshots, escaping fixtures, multiple-run ordering, immutable-conflict, stale/deleted, all repository fixture suites, parser, toolkit smoke, GUI smoke, button-smoke, JSON, and whitespace validation.
