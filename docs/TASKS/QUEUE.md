# Task Queue

This file is the operational task-state source of truth alongside `docs/HANDOFF.md`.

## Current Rule

Exactly one task may be Active. A Codex `Resume Work` cycle may complete the Active Codex-owned task and activate the next dependency-ready Codex-owned task already ordered below without another user prompt.

When any subsystem reaches `25 / 25`, Codex must automatically create and complete Audit Preparation, then activate a Project Custodian Engineering Audit task before more implementation.

## Active

| Task | Owner | Status | Purpose |
|---|---|---|---|
| `TASK-0111-Long-Path-Mutable-Tree-Cleanup` | Codex | Active | Implement fail-closed, long-path-capable mutable-tree cleanup and reverify the full production image. |

## Ordered Queue

| Order | Task | Owner | Status | Purpose |
|---:|---|---|---|---|
| 1 | `TASK-0080-Release-Candidate-Validation-And-Documentation` | ChatGPT (Project Custodian) | Queued | Make the final release-readiness decision after TASK-0111 passes full-image verification. |

## Recently Completed

| Task | Status | Notes |
|---|---|---|
| `TASK-0100-Performance-Instrumentation-And-Run-Scoped-Observation-Cache` | Complete | Added structured timings, explicit budgets, run-scoped observations/provider health, and cold/warm baselines. |
| `TASK-0099-Repository-Wide-Validation-Foundation` | Complete | Added the canonical 5.1 parser, load, negative-path, package, and regression gate; 17 stages pass. |
| `TASK-0098-Shared-Reporting-And-Run-Index-Contracts` | Complete | Added canonical report metadata and escaping plus immutable run/artifact indexing with explicit stale and missing state. |
| `TASK-0110-Task-System-Consistency-Cleanup` | Complete | Resolved accepted identity, status, Error Handoff, supersession, and punch-list consistency debt. |
| `TASK-0109-Project-Custodian-Task-System-Engineering-Audit` | Complete | Accepted the Task System audit, reset only Task System, recorded six debt dispositions, and activated TASK-0110. |

## Current Decision

- The Project Custodian rejected risk acceptance for the four surviving long-path LibreOffice files.
- TASK-0111 is the sole Active Codex task.
- TASK-0111 must make mutable-tree cleanup long-path capable and fail closed, add focused validation, rebuild the full image, and pass independent verification.
- TASK-0080 remains queued as the final Project Custodian release-readiness boundary.
- No tag, publication, or distribution is authorized until TASK-0080 is accepted.
- Net-new feature work remains deferred.
