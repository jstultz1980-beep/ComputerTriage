# Roadmap

## Product Direction

Build a portable Windows toolkit that collects, validates, analyzes, explains, and reports the health of one computer at a time. Deterministic local processing comes first; ARGUS provides cited explanation and technician guidance.

## Current Phase - Architecture Stabilization

Status: Active

Current Active task:
- `TASK-0098-Shared-Reporting-And-Run-Index-Contracts`

Current objective:
- Establish canonical report metadata and escaping behavior.
- Add immutable run indexing for report and artifact resolution.
- Make latest, stale, and deleted artifact state explicit.

## Remaining Sequence

1. **TASK-0098 - Shared Reporting and Run Index Contracts**
   - Establish canonical report metadata, escaping, and immutable run identity resolution.
2. **TASK-0099 - Repository-Wide Validation Foundation**
   - Add parser, load, negative-path, package, and regression gates after contracts stabilize.
3. **TASK-0100 - Performance Instrumentation and Run-Scoped Observation Cache**
   - Measure and reduce startup, first-render, repeated-query, lifecycle, and package hashing costs.
4. **TASK-0080 - Release-Candidate Validation and Documentation**
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
