# Task Queue

This file is the operational task-state source of truth alongside `docs/HANDOFF.md`.

## Current Rule

Exactly one task may be Active during project work. When no engineering task is active, the queue may remain empty at a user-only release or publication boundary.

When any subsystem reaches `25 / 25`, Codex must automatically create and complete Audit Preparation, then activate a Project Custodian Engineering Audit task before more implementation.

## Active

| Task | Owner | Status | Purpose |
|---|---|---|---|
| `TASK-0114-Performance-QA-Instrumentation-And-Settings-Dashboard` | Codex | Active | Add objective launch, navigation, operation, external-tool, and resource timing; automate performance QA; expose the dashboard only from Settings. |

## Ordered Queue

| Order | Task | Owner | Status | Purpose |
|---:|---|---|---|---|
| _None_ | _None_ | _None_ | _None_ | No additional implementation task is queued behind TASK-0114. |

## Recently Completed

| Task | Status | Notes |
|---|---|---|
| `TASK-0113-Version-1.0-Release-Publication` | Complete | Published `v1.0.0` from the accepted release commit and recorded the release metadata. |
| `TASK-0080-Release-Candidate-Validation-And-Documentation` | Complete | Project Custodian accepted the verified candidate as release-ready after TASK-0112. |
| `TASK-0112-Cold-Tab-Initialization-Performance-Remediation` | Complete | Added queued warm-up, per-stage timing, and focused cold-tab validation. |
| `TASK-0111-Long-Path-Mutable-Tree-Cleanup` | Complete | Added fail-closed long-path cleanup and independently verified the clean full production image. |
| `TASK-0100-Performance-Instrumentation-And-Run-Scoped-Observation-Cache` | Complete | Added structured timings, explicit budgets, run-scoped observations/provider health, and cold/warm baselines. |
| `TASK-0099-Repository-Wide-Validation-Foundation` | Complete | Added the canonical parser, load, negative-path, package, and regression gate. |
| `TASK-0098-Shared-Reporting-And-Run-Index-Contracts` | Complete | Added canonical report metadata and immutable run/artifact indexing. |
| `TASK-0110-Task-System-Consistency-Cleanup` | Complete | Resolved accepted identity, status, Error Handoff, supersession, and punch-list consistency debt. |

## Current Decision

- Version 1.0 remains published and unchanged.
- The user authorized a focused real-world performance QA instrumentation cycle.
- TASK-0114 is the sole Active Codex task.
- The Performance Dashboard must be accessible only from the Settings page.
- No unrelated feature work, helper framework work, native replacement work, or broad UI redesign is authorized.
