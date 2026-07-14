# Task Queue

This file is the operational task-state source of truth alongside `docs/HANDOFF.md`.

## Current Rule

Exactly one task may be Active. A Codex `Resume Work` cycle may complete the Active Codex-owned task and activate the next dependency-ready Codex-owned task already ordered below without another user prompt.

When any subsystem reaches `25 / 25`, Codex must automatically create and complete Audit Preparation, then activate a Project Custodian Engineering Audit task before more implementation.

## Active

| Task | Owner | Status | Purpose |
|---|---|---|---|
| `TASK-0080-Release-Candidate-Validation-And-Documentation` | ChatGPT (Project Custodian) | Active | Make the final release-readiness decision after the TASK-0111 remediation passes full-image verification. |

## Ordered Queue

| Order | Task | Owner | Status | Purpose |
|---:|---|---|---|---|
| _None_ | _None_ | _None_ | _None_ | No queued task remains behind the active Project Custodian decision. |

## Recently Completed

| Task | Status | Notes |
|---|---|---|
| `TASK-0100-Performance-Instrumentation-And-Run-Scoped-Observation-Cache` | Complete | Added structured timings, explicit budgets, run-scoped observations/provider health, and cold/warm baselines. |
| `TASK-0099-Repository-Wide-Validation-Foundation` | Complete | Added the canonical 5.1 parser, load, negative-path, package, and regression gate; 17 stages pass. |
| `TASK-0098-Shared-Reporting-And-Run-Index-Contracts` | Complete | Added canonical report metadata and escaping plus immutable run/artifact indexing with explicit stale and missing state. |
| `TASK-0110-Task-System-Consistency-Cleanup` | Complete | Resolved accepted identity, status, Error Handoff, supersession, and punch-list consistency debt. |
| `TASK-0109-Project-Custodian-Task-System-Engineering-Audit` | Complete | Accepted the Task System audit, reset only Task System, recorded six debt dispositions, and activated TASK-0110. |

## Current Decision

- TASK-0111 completed the long-path mutable-tree cleanup remediation and verified the clean full production image.
- TASK-0080 is the sole Active Project Custodian task.
- The Project Custodian must decide final release readiness from the verified evidence set.
- No tag, publication, or distribution is authorized until TASK-0080 is accepted.
- Net-new feature work remains deferred.
