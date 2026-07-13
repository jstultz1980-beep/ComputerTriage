# Task Queue

This file is the operational task-state source of truth alongside `docs/HANDOFF.md`.

## Current Rule

Exactly one task may be Active. A Codex `Resume Work` cycle may complete the Active Codex-owned task and activate the next dependency-ready Codex-owned task already ordered below without another user prompt.

When any subsystem reaches `25 / 25`, Codex must automatically create and complete Audit Preparation, then activate a Project Custodian Engineering Audit task before more implementation.

## Active

| Task | Owner | Status | Purpose |
|---|---|---|---|
| `TASK-0108-Task-System-Audit-Preparation` | Codex | Active | Prepare deterministic Task System threshold evidence without resetting the counter or beginning implementation. |

## Ordered Queue

| Order | Task | Owner | Status | Purpose |
|---:|---|---|---|---|
| 6 | `TASK-0098-Shared-Reporting-And-Run-Index-Contracts` | Codex | Queued | Create shared reporting metadata and immutable run indexing. |
| 7 | `TASK-0099-Repository-Wide-Validation-Foundation` | Codex | Queued | Add repository-wide parser, load, negative-path, package, and regression gates. |
| 8 | `TASK-0100-Performance-Instrumentation-And-Run-Scoped-Observation-Cache` | Codex | Queued | Instrument and reduce startup, first-render, repeated-query, lifecycle, and package hashing costs. |
| 9 | `TASK-0080-Release-Candidate-Validation-And-Documentation` | Codex | Queued | Execute the final release-candidate validation and documentation gate. |

## Recently Completed

| Task | Status | Notes |
|---|---|---|
| `TASK-0097-Architecture-Terminology-And-Governance-Consolidation` | Complete | Reconciled canonical references, removed stale competing sequence text, and passed all required governance simulations. |
| `TASK-0096-GUI-Background-Operation-Controller-Extraction` | Complete | Added a shared background lifecycle controller and migrated Analyze and Triage with leak and terminal-state validation. |
| `TASK-0107-Project-Custodian-Roadmap-Backlog-Engineering-Audit` | Complete | Accepted the roadmap audit, confirmed remaining sequence, clarified TASK-0097 ownership, reset only Roadmap/Backlog, and activated TASK-0096. |
| `TASK-0095-Canonical-Analysis-And-Tool-Metadata-Architecture` | Complete | Reconciled analysis roles, tool descriptors, plugin contracts, manifest roles, and operation states. |
| `TASK-0094-Sensitive-Artifact-Handling-And-Runtime-State-Safety` | Complete | Added masked/audited sensitive actions, explicit retention, selective verified encrypted transfer, atomic state, and Runtime/default separation. |
| `TASK-0105-Project-Custodian-Build-System-Engineering-Audit` | Complete | Accepted the Build System audit, retained TASK-0100 for performance remediation, reset only Build System, and activated TASK-0094. |

## Current Decision

- TASK-0097 is complete and all required terminology and governance simulations passed.
- Task System reached `25 / 25`; TASK-0108 is the sole Active Audit Preparation task.
- TASK-0098 remains queued until Project Custodian Task System audit acceptance.
- The TASK-0097 Project Custodian decision is recorded in `docs/REVIEWS/TASK-0097/PROJECT-CUSTODIAN-DECISION.md`.
- The intended-state architecture and forward-looking roadmap are established.
- Codex is authorized only for focused terminology/reference reconciliation and governance simulation under TASK-0097.
- The remaining order is TASK-0098, TASK-0099, TASK-0100, TASK-0080.
- Net-new feature work remains deferred until release-blocking stabilization, validation, and performance work is complete.
