# Task Queue

This file is the operational task-state source of truth alongside `docs/HANDOFF.md`.

## Current Rule

Exactly one task may be Active. A Codex `Resume Work` cycle may complete the Active Codex-owned task and activate the next dependency-ready Codex-owned task already ordered below without another user prompt.

When any subsystem reaches `25 / 25`, Codex must automatically create and complete Audit Preparation, then activate a Project Custodian Engineering Audit task before more implementation.

## Active

| Task | Owner | Status | Purpose |
|---|---|---|---|
| `TASK-0080-Release-Candidate-Validation-And-Documentation` | Codex | Active | Execute the final release-candidate validation and documentation gate. |

## Ordered Queue

| Order | Task | Owner | Status | Purpose |
|---:|---|---|---|---|
| - | None | - | No task remains queued behind the Active release-candidate gate. |

## Recently Completed

| Task | Status | Notes |
|---|---|---|
| `TASK-0100-Performance-Instrumentation-And-Run-Scoped-Observation-Cache` | Complete | Added structured timings, explicit budgets, run-scoped observations/provider health, and cold/warm baselines. |
| `TASK-0099-Repository-Wide-Validation-Foundation` | Complete | Added the canonical 5.1 parser, load, negative-path, package, artifact, and regression gate; 17 stages pass. |
| `TASK-0098-Shared-Reporting-And-Run-Index-Contracts` | Complete | Added canonical report metadata and escaping plus immutable run/artifact indexing with explicit stale and missing state. |
| `TASK-0110-Task-System-Consistency-Cleanup` | Complete | Resolved accepted identity, status, Error Handoff, supersession, and punch-list consistency debt. |
| `TASK-0109-Project-Custodian-Task-System-Engineering-Audit` | Complete | Accepted the Task System audit, reset only Task System, recorded six debt dispositions, and activated TASK-0110. |
| `TASK-0108-Task-System-Audit-Preparation` | Complete | Prepared Task System threshold evidence, preserved the `25 / 25` counter, and transferred review to TASK-0109. |
| `TASK-0097-Architecture-Terminology-And-Governance-Consolidation` | Complete | Reconciled canonical references, removed stale competing sequence text, and passed all required governance simulations. |
| `TASK-0096-GUI-Background-Operation-Controller-Extraction` | Complete | Added a shared background lifecycle controller and migrated Analyze and Triage with leak and terminal-state validation. |

## Current Decision

- TASK-0100 is complete and the canonical repository validation gate passes 18 stages with zero failures.
- TASK-0080 is the sole Active task and final queued release-candidate gate.
- No implementation task remains queued behind TASK-0080.
- TASK-0109 accepted the TASK-0108 evidence package.
- Only Task System was reset from `25 / 25` to `0 / 25`.
- Net-new feature work remains deferred.
