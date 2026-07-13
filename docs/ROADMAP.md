# Roadmap

## Product Direction

Build a portable Windows toolkit that collects, validates, analyzes, explains, and reports the health of one computer at a time. Deterministic local processing comes first; ARGUS provides cited explanation and technician guidance.

## Current Phase - Release-Candidate Validation

Status: Active

Current Active task:
- `TASK-0080-Release-Candidate-Validation-And-Documentation`

Current objective:
- Execute the canonical repository and production-package gates.
- Reconcile operational, troubleshooting, limitation, and release-readiness documentation.
- Produce the final Project Custodian release decision evidence package.

## Remaining Sequence

1. **TASK-0080 - Release-Candidate Validation and Documentation**
   - Execute final validation, operational documentation, and release-readiness review.

## Release-Candidate Entry Criteria

- No unresolved Critical findings.
- Every High finding is resolved or explicitly accepted in writing.
- Evidence, result, collection, ARGUS, operation, deployment, tool-trust, sensitive-data, reporting, and run-identity contracts are validated.
- Repository-wide validation gates pass.
- Package/update rollback and external-tool provenance are validated.
- Performance budgets are measured and accepted.
- Known limitations and operational guidance are documented.

## Deferred Work

Net-new features, external-tool helper frameworks, native replacements, and other expansion remain deferred until Version 1.0 reaches the original project goal or an active roadmap task explicitly authorizes them.

## Historical Record

Completed chronology, superseded planning, and audit transitions remain in individual task records and `docs/HISTORY` rather than this forward-looking roadmap.
