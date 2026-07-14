# Task Queue

This file is the operational task-state source of truth alongside `docs/HANDOFF.md`.

## Current Rule

Exactly one task may be Active. A Codex `Resume Work` cycle may complete the Active Codex-owned task and activate the next dependency-ready Codex-owned task already ordered below without another user prompt.

When any subsystem reaches `25 / 25`, Codex must automatically create and complete Audit Preparation, then activate a Project Custodian Engineering Audit task before more implementation.

## Active

| Task | Owner | Status | Purpose |
|---|---|---|---|
| `TASK-0112-Cold-Tab-Initialization-Performance-Remediation` | Codex | Active | Measure and remove first-open tab latency without shifting expensive work into synchronous startup. |

## Ordered Queue

| Order | Task | Owner | Status | Purpose |
|---:|---|---|---|---|
| 1 | `TASK-0080-Release-Candidate-Validation-And-Documentation` | ChatGPT (Project Custodian) | Queued | Make the final release-readiness decision after TASK-0112 performance evidence passes. |

## Recently Completed

| Task | Status | Notes |
|---|---|---|
| `TASK-0111-Long-Path-Mutable-Tree-Cleanup` | Complete | Added fail-closed long-path cleanup and independently verified the clean full production image. |
| `TASK-0100-Performance-Instrumentation-And-Run-Scoped-Observation-Cache` | Complete | Added structured timings, explicit budgets, run-scoped observations/provider health, and cold/warm baselines. |
| `TASK-0099-Repository-Wide-Validation-Foundation` | Complete | Added the canonical parser, load, negative-path, package, and regression gate. |
| `TASK-0098-Shared-Reporting-And-Run-Index-Contracts` | Complete | Added canonical report metadata and immutable run/artifact indexing. |
| `TASK-0110-Task-System-Consistency-Cleanup` | Complete | Resolved accepted identity, status, Error Handoff, supersession, and punch-list consistency debt. |

## Current Decision

- TASK-0111 completed packaging remediation and the clean full image verifies successfully.
- Direct technician use identified repeatable first-open lag on tabs not previously opened during the current session.
- TASK-0112 is the sole Active Codex task and is release-blocking usability remediation.
- TASK-0080 remains queued for the final Project Custodian release-readiness decision after TASK-0112.
- No tag, publication, or distribution is authorized.
- Net-new feature work remains deferred.
