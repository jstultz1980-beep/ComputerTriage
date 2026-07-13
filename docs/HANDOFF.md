# Current Handoff

## Handoff ID
HANDOFF-0116

## Current Task
TASK-0100-Performance-Instrumentation-And-Run-Scoped-Observation-Cache

## Current Owner
Codex

## Next Owner
Codex may activate TASK-0080 after TASK-0100 completes unless an audit, blocker, Project Custodian, or user-only boundary intervenes.

## Objective
Instrument and reduce startup, first-render, repeated-query, lifecycle, and package hashing costs through explicit budgets and run-scoped observation caching.

## Source Of Truth
The repository is authoritative. Exactly one task may be Active, and handoff, queue, and Active task file must agree.

## Current Project State
- TASK-0097 architecture, terminology, roadmap, queue, and governance consolidation is complete.
- TASK-0108 completed Task System Audit Preparation.
- TASK-0109 accepted the evidence package and reset only Task System from `25 / 25` to `0 / 25`.
- The authoritative audit decision is `docs/REVIEWS/TASK-0109/PROJECT-CUSTODIAN-DECISION.md`.
- TASK-0110 resolved the accepted Task System debt and passed all required simulations.
- TASK-0098 completed shared reporting/run-index contracts and passed focused and full regression validation.
- TASK-0099 completed repository-wide parser, load, negative-path, package, and regression gates; all 17 stages pass.
- TASK-0100 is the sole Active Codex task.
- Remaining order: TASK-0100, TASK-0080.
- Net-new features, helper frameworks, and native replacements remain deferred.

## Active Task Scope
`TASK-0100-Performance-Instrumentation-And-Run-Scoped-Observation-Cache`

Codex must implement only the instrumentation, time budgets, repeated-query reduction, lifecycle measurement, package hashing measurement, and run-scoped observation cache defined by TASK-0100 and its referenced findings. No unrelated feature, architecture consolidation, or drift cleanup is authorized.

## Audit Counters

| Subsystem | Changes Since Last Audit | Audit Required |
|---|---:|---|
| Repository Governance | 15 / 25 | No |
| Architecture | 18 / 25 | No |
| Documentation | 21 / 25 | No |
| Task System | 3 / 25 | No |
| Evidence Collection and Deterministic Analysis | 10 / 25 | No |
| ARGUS | 10 / 25 | No |
| Reporting | 5 / 25 | No |
| UI | 3 / 25 | No |
| Plugin Framework | 6 / 25 | No |
| Build System | 5 / 25 | No |
| Validation/Test Framework | 11 / 25 | No |
| Roadmap/Backlog | 6 / 25 | No |

## Known Working-Tree Drift
Do not stage or clean unless a focused task explicitly owns it:
- Modified: `App/manifests/custom-tools.json`
- Modified locally: `docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md`
- Untracked: `App/NetworkToolkit/LatencyMon/`
- Untracked: `App/NetworkToolkit/Logs/`
- Untracked: `Custodian-Audit-20260711-000156.md`
- Untracked: `Project-Custodian-Bridge.ps1`
- Untracked: `Export-ProjectFactoryGovernancePackage.ps1`
- Untracked: `Project-Factory-Governance-Handoff.zip`
- Untracked: `Project-Factory-Lessons-Learned-Handoff.txt`
- Untracked: `Set-CodexPermissions.ps1`

## Blockers
None.

## Decision Reference
- `docs/REVIEWS/TASK-0099/VALIDATION.md`
- `docs/REPOSITORY-VALIDATION.md`
- `App/manifests/repository-validation.json`
- `docs/TASKS/TASK-0099-Repository-Wide-Validation-Foundation.md`
- `docs/TASKS/TASK-0100-Performance-Instrumentation-And-Run-Scoped-Observation-Cache.md`
- `docs/REVIEWS/TASK-0108/TASK-SYSTEM-AUDIT-PREPARATION.md`
- `docs/REVIEWS/TASK-0109/PROJECT-CUSTODIAN-DECISION.md`
- `docs/TASKS/TASK-0109-Project-Custodian-Task-System-Engineering-Audit.md`
- `docs/TASKS/TASK-0110-Task-System-Consistency-Cleanup.md`

## Next Bot Prompt
```text
Resume Work
```
