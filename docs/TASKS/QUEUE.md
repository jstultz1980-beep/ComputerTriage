# Task Queue

This file is the task-state source of truth alongside `docs/HANDOFF.md`.

## Current Rule
Exactly one task may have `Active` status at a time. No implementation work may begin unless the active task exists under `docs/TASKS` and `docs/HANDOFF.md` names the same task.

## Active

| Task | Owner | Status | Purpose |
|---|---|---|---|
| `TASK-0101-Validation-Test-Framework-Counter-Audit` | Codex | Active | Audit the validation/test framework at its required 25-change threshold. |

## Ordered Queue

| Order | Task | Owner | Status | Purpose |
|---:|---|---|---|---|
| 1 | `TASK-0088-Canonical-Operation-Result-And-Failure-Propagation` | Codex | Queued | Establish one result envelope and eliminate false success after the required TASK-0101 audit. |
| 2 | `TASK-0089-Diagnostic-Bundle-Integrity-And-Collection-Contract` | Codex | Queued | Make bundle identity, integrity, completeness, and collector outcomes trustworthy. |
| 3 | `TASK-0090-ARGUS-Contract-Citation-And-Priority-Correctness` | Codex | Queued | Make ARGUS fail closed and correct citation, classification, confidence, and priority behavior. |
| 4 | `TASK-0091-Print-And-Remote-Change-Transaction-Safety` | Codex | Queued | Add verification, recovery, and rollback to destructive repair operations. |
| 5 | `TASK-0092-Transactional-Package-Deploy-And-Update-Integrity` | Codex | Queued | Make package, deployment, and update operations complete and rollback-capable. |
| 6 | `TASK-0093-External-Tool-Provenance-And-Lifecycle-Policy` | Codex | Queued | Enforce provenance, integrity, licensing, privilege, and EDR policy for external tools. |
| 7 | `TASK-0094-Sensitive-Artifact-Handling-And-Runtime-State-Safety` | Codex | Queued | Protect sensitive artifacts and make runtime state atomic and separable from defaults. |
| 8 | `TASK-0095-Canonical-Analysis-And-Tool-Metadata-Architecture` | Codex | Queued | Consolidate duplicate analysis, tool metadata, manifest, and status sources of truth. |
| 9 | `TASK-0096-GUI-Background-Operation-Controller-Extraction` | Codex | Queued | Centralize process, job, timer, cancellation, and cleanup lifecycle behavior. |
| 10 | `TASK-0097-Architecture-Terminology-And-Governance-Consolidation` | ChatGPT / Codex support | Queued | Normalize intended-state architecture, terminology, roadmap, queue, and governance references. |
| 11 | `TASK-0098-Shared-Reporting-And-Run-Index-Contracts` | Codex | Queued | Create shared reporting metadata and immutable run indexing. |
| 12 | `TASK-0099-Repository-Wide-Validation-Foundation` | Codex | Queued | Add repository-wide parser, load, negative-path, package, and regression gates. |
| 13 | `TASK-0100-Performance-Instrumentation-And-Run-Scoped-Observation-Cache` | Codex | Queued | Instrument and reduce startup, first-render, repeated-query, and lifecycle performance costs. |
| 14 | `TASK-0080-Release-Candidate-Validation-And-Documentation` | Codex | Queued | Execute the final release-candidate validation and documentation gate. |

## Superseded Tasks

- `TASK-0077-First-Render-Tab-Performance-Hardening` is superseded by TASK-0096 and TASK-0100.
- `TASK-0078-Embedded-Tool-Trust-And-EDR-Safe-Distribution` is superseded by TASK-0093.
- `TASK-0079-Release-Packaging-And-Update-Hardening` is superseded by TASK-0092.

## Recently Completed

| Task | Status | Notes |
|---|---|---|
| `TASK-0087-Parser-Backed-Evidence-Quality-And-Timeline` | Complete | Added parser-backed evidence quality, structured export errors, source-event-time timeline semantics, and ARGUS confidence handling. |
| `TASK-0084-Full-Codebase-Architecture-And-Quality-Audit` | Complete | Completed the full engineering audit, findings and debt registers, repository health and executive reports, release-readiness assessment, and dependency-ordered remediation sequence. |
| `TASK-0085-Documentation-Counter-Audit` | Complete | Audited Documentation at `25 / 25` and reset only Documentation. |
| `TASK-0086-Offline-Evidence-Isolation-And-Bundle-Identity` | Completed | Added validated immutable run identity, offline evidence isolation, generated-output exclusion, and identity propagation through ARGUS/reports/transfers. |

## Current Decision

- TASK-0084 is closed.
- TASK-0086 is complete.
- TASK-0087 is complete and TASK-0101 is the only Active task.
- TASK-0101 is the required Validation/Test Framework threshold audit before TASK-0088.
- Critical and High findings are mapped to remediation tasks or documented disposition.
- Net-new feature work remains deferred until the release-blocking remediation sequence is complete.
