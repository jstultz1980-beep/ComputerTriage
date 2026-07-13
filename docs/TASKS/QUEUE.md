# Task Queue

This file is the operational task-state source of truth alongside `docs/HANDOFF.md`.

## Current Rule

Exactly one task may be Active. A Codex `Resume Work` cycle may complete the Active Codex-owned task and activate the next dependency-ready Codex-owned task already ordered below without another user prompt.

When any subsystem reaches `25 / 25`, Codex must automatically create and complete Audit Preparation, then activate a Project Custodian Engineering Audit task before more implementation.

## Active

| Task | Owner | Status | Purpose |
|---|---|---|---|
| `TASK-0093-External-Tool-Provenance-And-Lifecycle-Policy` | Codex | Active | Enforce provenance, integrity, licensing, privilege, EDR policy, and tool-retention review. |

## Ordered Queue

| Order | Task | Owner | Status | Purpose |
|---:|---|---|---|---|
| 2 | `TASK-0094-Sensitive-Artifact-Handling-And-Runtime-State-Safety` | Codex | Queued | Protect sensitive artifacts and make runtime state atomic and separable from defaults. |
| 3 | `TASK-0095-Canonical-Analysis-And-Tool-Metadata-Architecture` | Codex | Queued | Consolidate analysis/tool metadata sources and verify plugin modularity. |
| 4 | `TASK-0096-GUI-Background-Operation-Controller-Extraction` | Codex | Queued | Centralize process, job, timer, cancellation, and cleanup lifecycle behavior. |
| 5 | `TASK-0097-Architecture-Terminology-And-Governance-Consolidation` | ChatGPT / Codex support | Queued | Normalize intended-state architecture, terminology, roadmap, queue, and governance references. |
| 6 | `TASK-0098-Shared-Reporting-And-Run-Index-Contracts` | Codex | Queued | Create shared reporting metadata and immutable run indexing. |
| 7 | `TASK-0099-Repository-Wide-Validation-Foundation` | Codex | Queued | Add repository-wide parser, load, negative-path, package, and regression gates. |
| 8 | `TASK-0100-Performance-Instrumentation-And-Run-Scoped-Observation-Cache` | Codex | Queued | Instrument and reduce startup, first-render, repeated-query, and lifecycle performance costs. |
| 9 | `TASK-0080-Release-Candidate-Validation-And-Documentation` | Codex | Queued | Execute the final release-candidate validation and documentation gate. |

## Superseded Tasks

- TASK-0077 is superseded by TASK-0096 and TASK-0100.
- TASK-0078 is superseded by TASK-0093.
- TASK-0079 is superseded by TASK-0092.

## Recently Completed

| Task | Status | Notes |
|---|---|---|
| `TASK-0092-Transactional-Package-Deploy-And-Update-Integrity` | Complete | Added managed manifests, staged verification, identity checks, atomic swaps, and rollback. |
| `TASK-0103-Project-Custodian-UI-Engineering-Audit` | Complete | Accepted the UI audit package, retained TASK-0096/TASK-0099 remediation ownership, and reset only UI. |
| `TASK-0102-UI-Audit-Preparation` | Complete | Prepared UI threshold evidence without resetting the counter. |
| `TASK-0091-Print-And-Remote-Change-Transaction-Safety` | Complete | Added verified transactions, rollback, spooler recovery, and remote service/firewall restoration. |
| `TASK-0090-ARGUS-Contract-Citation-And-Priority-Correctness` | Complete | Corrected ARGUS citation identity, classification, priority ordering, evidence-gap isolation, and confidence bounds. |
| `TASK-0089-Diagnostic-Bundle-Integrity-And-Collection-Contract` | Complete | Added final bundle integrity, tamper detection, and complete collector outcomes. |
| `TASK-0088-Canonical-Operation-Results-And-Failure-Propagation` | Complete | Added canonical operation results, deterministic exits, startup classification, partial propagation, and failed-contract handling. |

## Current Decision

- TASK-0103 is complete.
- UI reset from `25 / 25` to `0 / 25`.
- TASK-0092 is complete and TASK-0093 is the only Active task.
- TASK-0096 retains UI lifecycle/controller remediation.
- TASK-0099 retains behavioral and negative-path UI validation remediation.
- Codex is authorized to continue through ordered dependency-ready Codex tasks under one `Resume Work` cycle.
- Net-new feature work remains deferred until release-blocking remediation is complete.
