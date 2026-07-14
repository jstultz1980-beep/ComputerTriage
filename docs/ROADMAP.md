# Roadmap

## Product Direction

Build a portable Windows toolkit that collects, validates, analyzes, explains, and reports the health of one computer at a time. Deterministic local processing comes first; ARGUS provides cited explanation and technician guidance.

## Current Phase - Version 1.0 Released

Status: Complete. Version 1.0 is published and Project Custodian release closeout is confirmed.

Current Active task:
- None.

Current objective:
- Preserve the published Version 1.0 release record.
- Collect field feedback and defects without changing the released tag.
- Begin no new implementation until the user authorizes a new planning cycle and the Project Custodian sequences the work.

## Completed Release Sequence

1. **TASK-0112 - Cold Tab Initialization Performance Remediation**
   - Completed. The release-blocking cold-tab initialization latency was remediated and validated.
2. **TASK-0080 - Release-Candidate Validation and Documentation**
   - Completed. The Project Custodian accepted the verified candidate as release-ready.
3. **TASK-0113 - Version 1.0 Release Publication**
   - Completed. Release `v1.0.0` was published from accepted commit `38de0b626fe3cadc6848a12b9e40fadfc7006151` with the verified production manifest attached.

## Version 1.0 Acceptance Criteria

- No unresolved Critical findings.
- Every High finding is resolved or explicitly accepted in writing.
- Evidence, result, collection, ARGUS, operation, deployment, tool-trust, sensitive-data, reporting, and run-identity contracts are validated.
- Repository-wide validation gates pass.
- Full production image verification passes with no mutable application data.
- Package/update rollback and external-tool provenance are validated.
- Performance budgets are measured and accepted.
- Technician-visible normal navigation is responsive on representative hardware.
- Known limitations and operational guidance are documented.
- Version 1.0 tag and GitHub Release publication are verified and recorded.

All criteria are accepted for Version 1.0.

## Deferred Work

Net-new features, external-tool helper frameworks, native replacements, and other expansion remain deferred until a new approved planning cycle begins.

## Historical Record

Completed chronology, superseded planning, audit transitions, release evidence, and publication metadata remain in individual task records and `docs/HISTORY` rather than this forward-looking roadmap.
