# Task Queue

This file is the operational task-state source of truth alongside `docs/HANDOFF.md`.

## Current Rule

Exactly one task may be Active. A Codex `Resume Work` cycle may complete the Active Codex-owned task and activate the next dependency-ready Codex-owned task already ordered below without another user prompt.

When any subsystem reaches `25 / 25`, Codex must automatically create and complete Audit Preparation, then activate a Project Custodian Engineering Audit task before more implementation.

## Active

| Task | Owner | Status | Purpose |
|---|---|---|---|
| `TASK-0080-Release-Candidate-Validation-And-Documentation` | ChatGPT (Project Custodian) | Active | Make the final release-readiness decision after the TASK-0112 remediation passes full-image verification. |

## Ordered Queue

| Order | Task | Owner | Status | Purpose |
|---:|---|---|---|---|
| _None_ | _None_ | _None_ | _None_ | No queued task remains behind the active Project Custodian decision. |

## Recently Completed

| Task | Status | Notes |
|---|---|---|
| `TASK-0112-Cold-Tab-Initialization-Performance-Remediation` | Complete | Added queued warm-up, per-stage timing, and focused cold-tab validation. |
| `TASK-0111-Long-Path-Mutable-Tree-Cleanup` | Complete | Added fail-closed long-path cleanup and independently verified the clean full production image. |
| `TASK-0100-Performance-Instrumentation-And-Run-Scoped-Observation-Cache` | Complete | Added structured timings, explicit budgets, run-scoped observations/provider health, and cold/warm baselines. |
| `TASK-0099-Repository-Wide-Validation-Foundation` | Complete | Added the canonical parser, load, negative-path, package, and regression gate. |
| `TASK-0098-Shared-Reporting-And-Run-Index-Contracts` | Complete | Added canonical report metadata and immutable run/artifact indexing. |
| `TASK-0110-Task-System-Consistency-Cleanup` | Complete | Resolved accepted identity, status, Error Handoff, supersession, and punch-list consistency debt. |

## Current Decision

- TASK-0112 completed the cold-tab initialization performance remediation and the clean full image still verifies successfully.
- TASK-0080 is the sole Active Project Custodian task.
- The Project Custodian must decide final release readiness from the verified evidence set.
- No tag, publication, or distribution is authorized.
- Net-new feature work remains deferred.
