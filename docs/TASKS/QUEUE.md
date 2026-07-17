# Task Queue

This file is the operational task-state source of truth alongside `docs/HANDOFF.md`.

## Current Rule

Exactly one task may be Active during project work. When no engineering task is active, the queue may remain empty at a user-only release or publication boundary.

When any subsystem reaches `25 / 25`, Codex must automatically create and complete Audit Preparation, then activate a Project Custodian Engineering Audit task before more implementation.

## Active

| Task | Owner | Status | Purpose |
|---|---|---|---|
| `TASK-0118-Startup-Warmup-And-Heavy-Tab-Deferral` | Codex | Active | Reduce measured launch latency by replacing eager 27-tab warm-up with bounded idle/on-demand initialization and deferring heavy tabs. |

## Ordered Queue

| Order | Task | Owner | Status | Purpose |
|---:|---|---|---|---|
| _None_ | _None_ | _None_ | _None_ | No additional implementation task is queued behind TASK-0118. |

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

- The live performance audit recorded shell-to-usable-window time of approximately 4.5-4.9 seconds.
- Launch currently schedules 27 tabs for deferred warm-up; this is the primary measured startup bottleneck.
- TASK-0118 is the sole Active task and must extend the existing performance/warm-up contracts.
- Print, Analyze, Directory, and Windows Update are the priority heavy tabs for demand-driven or staged construction.
- The separate deferred-startup `Write-GUILog` defect remains out of scope and requires independent sequencing.
- The published `v1.0.0` release and unrelated drift must remain untouched.
