# Task Queue

This file is the operational task-state source of truth alongside `docs/HANDOFF.md`.

## Current Rule

Exactly one task may be Active during project work. When no engineering task is active, the queue may remain empty at a user-only release or publication boundary.

When any subsystem reaches `25 / 25`, Codex must automatically create and complete Audit Preparation, then activate a Project Custodian Engineering Audit task before more implementation.

## Active

| Task | Owner | Status | Purpose |
|---|---|---|---|
| `TASK-0113-Version-1.0-Release-Publication` | Codex | Active | Execute the explicitly authorized Version 1.0 tag, GitHub Release publication, artifact verification, and release record closeout. |

## Ordered Queue

| Order | Task | Owner | Status | Purpose |
|---:|---|---|---|---|
| _None_ | _None_ | _None_ | No implementation task is queued behind release publication. |

## Recently Completed

| Task | Status | Notes |
|---|---|---|
| `TASK-0080-Release-Candidate-Validation-And-Documentation` | Complete | Project Custodian accepted the verified candidate as release-ready after TASK-0112. |
| `TASK-0112-Cold-Tab-Initialization-Performance-Remediation` | Complete | Added queued warm-up, per-stage timing, and focused cold-tab validation. |
| `TASK-0111-Long-Path-Mutable-Tree-Cleanup` | Complete | Added fail-closed long-path cleanup and independently verified the clean full production image. |
| `TASK-0100-Performance-Instrumentation-And-Run-Scoped-Observation-Cache` | Complete | Added structured timings, explicit budgets, run-scoped observations/provider health, and cold/warm baselines. |
| `TASK-0099-Repository-Wide-Validation-Foundation` | Complete | Added the canonical parser, load, negative-path, package, and regression gate. |
| `TASK-0098-Shared-Reporting-And-Run-Index-Contracts` | Complete | Added canonical report metadata and immutable run/artifact indexing. |
| `TASK-0110-Task-System-Consistency-Cleanup` | Complete | Resolved accepted identity, status, Error Handoff, supersession, and punch-list consistency debt. |

## Current Decision

- The user explicitly authorized Version 1.0 release execution.
- TASK-0113 is the sole Active Codex task.
- Codex must synchronize with the authoritative cloud branch before release execution.
- Tagging, GitHub Release publication, and verified artifact attachment are authorized within TASK-0113.
- New feature work and Version 1.1 planning remain deferred until release publication is closed out.
