# Roadmap

## Product Direction

Build a portable Windows toolkit that collects, validates, analyzes, explains, and reports the health of one computer at a time. Deterministic local processing comes first; ARGUS provides cited explanation and technician guidance.

## Current Phase - Release-Candidate Performance Remediation

Status: Active

Current Active task:
- `TASK-0112-Cold-Tab-Initialization-Performance-Remediation`

Current objective:
- Measure first-open latency for every primary tab.
- Warm lightweight tab UI after the main window becomes responsive.
- Keep expensive live data collection deferred until required.
- Prove responsive first selection, one-time initialization, and no lifecycle regressions.

## Remaining Sequence

1. **TASK-0112 - Cold Tab Initialization Performance Remediation**
   - Focused release-blocking usability remediation for repeatable first-open tab lag.
2. **TASK-0080 - Release-Candidate Validation and Documentation**
   - Project Custodian final release-readiness decision after TASK-0112 evidence passes.

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

## Deferred Work

Net-new features, external-tool helper frameworks, native replacements, and other expansion remain deferred until Version 1.0 reaches the original project goal or an active roadmap task explicitly authorizes them.

## Historical Record

Completed chronology, superseded planning, and audit transitions remain in individual task records and `docs/HISTORY` rather than this forward-looking roadmap.
