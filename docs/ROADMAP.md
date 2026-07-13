# Roadmap

## Product Direction

Build a portable Windows toolkit that collects, validates, analyzes, explains, and reports the health of one computer at a time. Deterministic local processing comes first; ARGUS provides cited explanation and technician guidance.

## Current Phase - Architecture Stabilization

Status: Active

Current Active task:
- `TASK-0100-Performance-Instrumentation-And-Run-Scoped-Observation-Cache`

Current objective:
- Measure startup, first-render, repeated-query, lifecycle, and package hashing costs.
- Add run-scoped observation caching where evidence freshness remains explicit.
- Define and validate cold/warm performance budgets without weakening correctness contracts.

## Remaining Sequence

1. **TASK-0100 - Performance Instrumentation and Run-Scoped Observation Cache**
   - Measure and reduce startup, first-render, repeated-query, lifecycle, and package hashing costs.
2. **TASK-0080 - Release-Candidate Validation and Documentation**
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
