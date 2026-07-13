# Roadmap

## Product Direction
Build a portable Windows toolkit that collects, analyzes, explains, and reports the health of one computer at a time. Deterministic evidence processing comes first; ARGUS provides cited explanation and technician guidance.

## Completed Foundation

- Repository governance and source-of-truth controls.
- Collection baseline and manual-run validation.
- Deterministic local analysis vertical slice and rule expansion.
- ARGUS input contract, normalization, event grouping, recommendations, and reporting.
- Guided Analyze workflow integration.
- TASK-0084 full-codebase architecture and quality audit.

## Current Phase - Architecture Stabilization

Status: Active

Current Active task:
- `TASK-0096-GUI-Background-Operation-Controller-Extraction`

Release-blocking remediation through TASK-0094 is complete. TASK-0095 established canonical analysis, tool-metadata, plugin, manifest, and operation-state contracts. TASK-0106/TASK-0107 completed the Roadmap/Backlog threshold audit and reset only that subsystem.

Required sequence:
1. TASK-0086 Offline Evidence Isolation and Bundle Identity. Complete.
2. TASK-0087 Parser-Backed Evidence Quality and Timeline Semantics. Complete.
3. TASK-0088 Canonical Operation Result and Failure Propagation. Complete.
4. TASK-0089 Diagnostic Bundle Integrity and Collection Contract. Complete.
5. TASK-0090 ARGUS Contract, Citation, and Priority Correctness. Complete.
6. TASK-0091 Print and Remote Change Transaction Safety. Complete.
7. TASK-0092 Transactional Package, Deploy, and Update Integrity. Complete.
8. TASK-0093 External Tool Provenance and Lifecycle Policy. Complete.
9. TASK-0104 / TASK-0105 Build System Audit Preparation and Engineering Audit. Complete.
10. TASK-0094 Sensitive Artifact Handling and Runtime State Safety. Complete.
11. TASK-0095 Canonical Analysis and Tool Metadata Architecture. Complete.
12. TASK-0106 / TASK-0107 Roadmap/Backlog Audit Preparation and Engineering Audit. Complete.
13. TASK-0096 GUI Background Operation Controller Extraction. Active.
14. TASK-0097 Architecture, Terminology, and Governance Consolidation.
15. TASK-0098 Shared Reporting and Run Index Contracts.
16. TASK-0099 Repository-Wide Validation Foundation.
17. TASK-0100 Performance Instrumentation and Run-Scoped Observation Cache.
18. TASK-0080 Release-Candidate Validation and Documentation.

TASK-0097 begins with a Project Custodian architecture/governance decision. Codex support is limited to focused implementation-reference updates explicitly authorized by that decision.

## Release Candidate

Status: Blocked pending stabilization and validation

Release-candidate entry criteria:
- No unresolved Critical findings.
- Every High finding resolved or explicitly accepted in writing.
- Repository-wide validation gates pass.
- Package/update rollback and external-tool provenance are validated.
- Performance budgets are measured and accepted.
- Known limitations and operational guidance are documented.

## Superseded Planning

- TASK-0077 is superseded by TASK-0096 and TASK-0100.
- TASK-0078 is superseded by TASK-0093.
- TASK-0079 is superseded by TASK-0092.

Historical chronology remains in individual task records, `docs/HISTORY/CHANGELOG.md`, and `docs/HISTORY/CHANGE-LEDGER.md`.
