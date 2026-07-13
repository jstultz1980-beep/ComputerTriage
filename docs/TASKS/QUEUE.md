# Task Queue

This file is the operational task-state source of truth alongside `docs/HANDOFF.md`.

## Current Rule

Exactly one task may be Active. A Codex `Resume Work` cycle may complete the Active Codex-owned task and activate the next dependency-ready Codex-owned task already ordered below without another user prompt.

When any subsystem reaches `25 / 25`, Codex must automatically create and complete Audit Preparation, then activate a Project Custodian Engineering Audit task before more implementation.

## Active

| Task | Owner | Status | Purpose |
|---|---|---|---|
| `TASK-0110-Task-System-Consistency-Cleanup` | Codex | Active | Resolve accepted Task System identity, status, Error Handoff, and punch-list consistency debt before TASK-0098. |

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
| `TASK-0109-Project-Custodian-Task-System-Engineering-Audit` | Complete | Accepted the Task System audit, reset only Task System, recorded six debt dispositions, and activated TASK-0110. |
| `TASK-0108-Task-System-Audit-Preparation` | Complete | Prepared Task System threshold evidence, preserved the `25 / 25` counter, and transferred review to TASK-0109. |
| `TASK-0097-Architecture-Terminology-And-Governance-Consolidation` | Complete | Reconciled canonical references, removed stale competing sequence text, and passed all required governance simulations. |
| `TASK-0096-GUI-Background-Operation-Controller-Extraction` | Complete | Added a shared background lifecycle controller and migrated Analyze and Triage with leak and terminal-state validation. |

## Current Decision

- TASK-0109 accepted the TASK-0108 evidence package.
- Only Task System was reset from `25 / 25` to `0 / 25`.
- TASK-0110 is the sole Active task and must resolve the accepted Task System consistency debt.
- TASK-0098 remains next after TASK-0110.
- The remaining order is TASK-0110, TASK-0098, TASK-0099, TASK-0100, TASK-0080.
- Net-new feature work remains deferred.
