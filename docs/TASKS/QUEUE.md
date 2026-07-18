# Task Queue

This file is the operational task-state source of truth alongside `docs/HANDOFF.md`.

## Current Rule

Exactly one task may be Active during project work. When no engineering task is active, the queue may remain empty at a user-only release or publication boundary.

When any subsystem reaches `25 / 25`, Codex must automatically create and complete Audit Preparation, then activate a Project Custodian Engineering Audit task before more implementation.

## Active

| Task | Owner | Status | Purpose |
|---|---|---|---|
| `TASK-0119-Deferred-Startup-Logging-Initialization-Error` | Codex | Active | Correct the confirmed deferred-startup `Write-GUILog` initialization/scope failure and preserve actionable fallback diagnostics. |

## Ordered Queue

| Order | Task | Owner | Status | Purpose |
|---:|---|---|---|---|
| 1 | `TASK-0118-Startup-Warmup-And-Heavy-Tab-Deferral` | Codex | Queued | Resume measured startup optimization after the confirmed startup error is corrected. |
| 2 | `TASK-0120-Preserved-Drift-Inventory-And-Reconciliation` | Codex | Queued | Inventory and resolve every modified, untracked, generated, archived, or retained-stash item through an approved disposition and return the repository to a clean state. |

## Recently Completed

| Task | Status | Notes |
|---|---|---|
| `TASK-0117-Responsive-Initial-Layout-And-DPI-Remediation` | Complete | Corrected default-launch clipping, added client-area sizing and deterministic layout-boundary validation. |
| `TASK-0116-Project-Custodian-Documentation-Engineering-Audit` | Complete | Accepted TASK-0115 evidence and reset only Documentation to `0 / 25`. |
| `TASK-0115-Documentation-Audit-Preparation` | Complete | Prepared deterministic documentation-audit evidence for TASK-0114. |
| `TASK-0114-Performance-QA-Instrumentation-And-Settings-Dashboard` | Complete | Added launch-through-ReadyForUser telemetry, resource snapshots, shutdown/orphan checks, Settings-only dashboard reporting, and QA evidence. |
| `TASK-0113-Version-1.0-Release-Publication` | Complete | Published `v1.0.0` from the accepted release commit and recorded release metadata. |
| `TASK-0080-Release-Candidate-Validation-And-Documentation` | Complete | Project Custodian accepted the verified candidate as release-ready. |
| `TASK-0112-Cold-Tab-Initialization-Performance-Remediation` | Complete | Added queued warm-up, per-stage timing, and focused cold-tab validation. |

## Current Decision

- A visible startup error takes priority over performance tuning.
- TASK-0119 is the sole Active task and must identify the actual initialization, scope, or runspace failure rather than suppressing the message.
- TASK-0118 remains authorized and queued immediately behind TASK-0119.
- TASK-0120 is mandatory after TASK-0118 and must eliminate the indefinite preserved-drift exception through item-by-item reconciliation.
- Deferred startup failures must remain visible through a safe fallback path.
- The published `v1.0.0` release must remain untouched.
