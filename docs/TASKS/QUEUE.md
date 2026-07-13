# Task Queue

This file is the operational task-state source of truth alongside `docs/HANDOFF.md`.

## Current Rule

Exactly one task may be Active. A Codex `Resume Work` cycle may complete the Active Codex-owned task and activate the next dependency-ready Codex-owned task already ordered below without another user prompt.

When any subsystem reaches `25 / 25`, Codex must automatically create and complete Audit Preparation, then activate a Project Custodian Engineering Audit task before more implementation.

## Active

| Task | Owner | Status | Purpose |
|---|---|---|---|
| `TASK-0089-Diagnostic-Bundle-Integrity-And-Collection-Contract` | Codex | Active | Make bundle identity, integrity, completeness, and collector outcomes trustworthy. |

## Ordered Queue

| Order | Task | Owner | Status | Purpose |
|---:|---|---|---|---|
| 1 | `TASK-0090-ARGUS-Contract-Citation-And-Priority-Correctness` | Codex | Queued | Make ARGUS fail closed and correct citation, classification, confidence, and priority behavior. |
| 2 | `TASK-0091-Print-And-Remote-Change-Transaction-Safety` | Codex | Queued | Add verification, recovery, and rollback to destructive repair operations. |
| 3 | `TASK-0092-Transactional-Package-Deploy-And-Update-Integrity` | Codex | Queued | Make package, deployment, and update operations complete and rollback-capable. |
| 4 | `TASK-0093-External-Tool-Provenance-And-Lifecycle-Policy` | Codex | Queued | Enforce provenance, integrity, licensing, privilege, EDR policy, and tool-retention review. |
| 5 | `TASK-0094-Sensitive-Artifact-Handling-And-Runtime-State-Safety` | Codex | Queued | Protect sensitive artifacts and make runtime state atomic and separable from defaults. |
| 6 | `TASK-0095-Canonical-Analysis-And-Tool-Metadata-Architecture` | Codex | Queued | Consolidate analysis/tool metadata sources and verify plugin modularity. |
| 7 | `TASK-0096-GUI-Background-Operation-Controller-Extraction` | Codex | Queued | Centralize process, job, timer, cancellation, and cleanup lifecycle behavior. |
| 8 | `TASK-0097-Architecture-Terminology-And-Governance-Consolidation` | ChatGPT / Codex support | Queued | Normalize intended-state architecture, terminology, roadmap, queue, and governance references. |
| 9 | `TASK-0098-Shared-Reporting-And-Run-Index-Contracts` | Codex | Queued | Create shared reporting metadata and immutable run indexing. |
| 10 | `TASK-0099-Repository-Wide-Validation-Foundation` | Codex | Queued | Add repository-wide parser, load, negative-path, package, and regression gates. |
| 11 | `TASK-0100-Performance-Instrumentation-And-Run-Scoped-Observation-Cache` | Codex | Queued | Instrument and reduce startup, first-render, repeated-query, and lifecycle performance costs. |
| 12 | `TASK-0080-Release-Candidate-Validation-And-Documentation` | Codex | Queued | Execute the final release-candidate validation and documentation gate. |

## Superseded Tasks

- TASK-0077 is superseded by TASK-0096 and TASK-0100.
- TASK-0078 is superseded by TASK-0093.
- TASK-0079 is superseded by TASK-0092.

## Recently Completed

| Task | Status | Notes |
|---|---|---|
| `TASK-0088-Canonical-Operation-Results-And-Failure-Propagation` | Complete | Added canonical results, deterministic exits, startup failure classification, partial propagation, ARGUS suppression, and GUI/plugin outcome handling. |
| `TASK-0101-Validation-Test-Framework-Counter-Audit` | Complete | Audited executable validation and reset only Validation/Test Framework. |
| `TASK-0087-Parser-Backed-Evidence-Quality-And-Timeline` | Complete | Added parser-backed evidence quality and source-event-time semantics. |
| `TASK-0086-Offline-Evidence-Isolation-And-Bundle-Identity` | Complete | Added immutable run identity and offline evidence isolation. |
| `TASK-0084-Full-Codebase-Architecture-And-Quality-Audit` | Complete | Completed the full engineering audit and remediation sequence. |
| `TASK-0085-Documentation-Counter-Audit` | Complete | Audited and reset Documentation. |

## Current Decision

- TASK-0088 is complete and TASK-0089 is the only Active task.
- Codex is authorized to continue through ordered dependency-ready Codex tasks under one `Resume Work` cycle.
- Audit Preparation occurs automatically at `25 / 25`.
- Project Custodian review follows each Audit Preparation package.
- Net-new feature work remains deferred until release-blocking remediation is complete.
