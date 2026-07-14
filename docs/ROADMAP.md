# Roadmap

## Product Direction

Build a portable Windows toolkit that collects, validates, analyzes, explains, and reports the health of one computer at a time. Deterministic local processing comes first; ARGUS provides cited explanation and technician guidance.

## Current Phase - Version 1.0 Release Closeout

Status: Version 1.0 is published; awaiting Project Custodian closeout confirmation.

Current Active task:
- None.

Current objective:
- Preserve the published Version 1.0 release record.
- Await Project Custodian closeout confirmation.
- Begin no new implementation until closeout and any required audit work are complete.

## Completed Release Sequence

1. **TASK-0112 - Cold Tab Initialization Performance Remediation**
   - Completed. The release-blocking cold-tab initialization latency was remediated and validated.
2. **TASK-0080 - Release-Candidate Validation and Documentation**
   - Completed. The Project Custodian accepted the verified candidate as release-ready.

## Release-Candidate Entry Criteria

- No unresolved Critical findings.
- Every High finding is resolved or explicitly accepted in writing.
- Evidence, result, collection, ARGUS, operation, deployment, tool-trust, sensitive-data, reporting, and run-identity contracts are validated.
- Repository-wide validation gates pass.
- Full production image verification passes with no mutable application data.
- Package/update rollback and external-tool provenance are validated.
- Performance budgets are measured and accepted.
- Technician-visible normal navigation is responsive on representative hardware.
- Known limitations and operational guidance are documented.

All entry criteria are accepted for Version 1.0 engineering readiness.

## Deferred Work

Net-new features, external-tool helper frameworks, native replacements, and other expansion remain deferred until a new approved planning cycle begins.

## Historical Record

Completed chronology, superseded planning, and audit transitions remain in individual task records and `docs/HISTORY` rather than this forward-looking roadmap.
