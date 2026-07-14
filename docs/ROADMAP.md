# Roadmap

## Product Direction

Build a portable Windows toolkit that collects, validates, analyzes, explains, and reports the health of one computer at a time. Deterministic local processing comes first; ARGUS provides cited explanation and technician guidance.

## Current Phase - Release-Candidate Remediation

Status: Active

Current Active task:
- `TASK-0111-Long-Path-Mutable-Tree-Cleanup`

Current objective:
- Make declared mutable-tree cleanup long-path capable and fail closed.
- Add focused regression coverage for the LibreOffice long-path condition.
- Build and independently verify a clean full production image.

## Remaining Sequence

1. **TASK-0111 - Long-Path Mutable Tree Cleanup**
   - Resolve the release-blocking package-cleanup defect and produce passing full-image verification evidence.
2. **TASK-0080 - Release-Candidate Validation and Documentation**
   - Project Custodian final release-readiness decision after remediation.

## Release-Candidate Entry Criteria

- No unresolved Critical findings.
- Every High finding is resolved or explicitly accepted in writing.
- Evidence, result, collection, ARGUS, operation, deployment, tool-trust, sensitive-data, reporting, and run-identity contracts are validated.
- Repository-wide validation gates pass.
- Full production image verification passes with no mutable application data.
- Package/update rollback and external-tool provenance are validated.
- Performance budgets are measured and accepted.
- Known limitations and operational guidance are documented.

## Deferred Work

Net-new features, external-tool helper frameworks, native replacements, and other expansion remain deferred until Version 1.0 reaches the original project goal or an active roadmap task explicitly authorizes them.

## Historical Record

Completed chronology, superseded planning, and audit transitions remain in individual task records and `docs/HISTORY` rather than this forward-looking roadmap.
