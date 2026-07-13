# Current Handoff

## Handoff ID
HANDOFF-0108

## Current Task
TASK-0096-GUI-Background-Operation-Controller-Extraction

## Current Owner
Codex

## Next Owner
ChatGPT (Project Custodian) when TASK-0097 becomes active or an audit/blocker boundary is reached.

## Objective
Create one reusable controller for GUI background processes, jobs, timers, cancellation, timeout, completion, and cleanup; migrate Analyze and Triage first.

## Source Of Truth
The repository is authoritative. Exactly one task may be Active, and handoff, queue, and Active task file must agree.

## Current Project State
- TASK-0107 completed the Roadmap/Backlog Engineering Audit.
- The TASK-0106 evidence package was accepted.
- Only Roadmap/Backlog was reset from `25 / 25` to `0 / 25`.
- Remaining sequence confirmed: TASK-0096, TASK-0097, TASK-0098, TASK-0099, TASK-0100, TASK-0080.
- TASK-0097 begins with a Project Custodian architecture/governance decision; Codex support is limited to focused implementation-reference updates authorized by that decision.
- TASK-0096 is the single Active Codex task.
- Release candidate remains blocked pending stabilization, validation, and performance gates.
- `Resume Work` authorizes continuous Codex execution through dependency-ready Codex tasks, but Codex must stop when TASK-0097 becomes active because it is a Project Custodian boundary.
- `Governance Refresh` performs a lightweight safe-point governance reload and resumes the same Active task.
- At `25 / 25`, Codex automatically completes Audit Preparation, pushes the evidence package, and activates a Project Custodian Engineering Audit task.
- Every non-blocked Codex stop-boundary summary must end exactly with `Tell Debbie to continue`.
- Every genuine blocker summary must end exactly with `Tell Debbie to address errors`.

## Active Task Scope
`TASK-0096-GUI-Background-Operation-Controller-Extraction`

Codex must implement only the shared GUI background operation lifecycle controller and migrate Analyze and Triage within the task acceptance criteria. No unrelated architecture, governance, helper framework, native replacement, or feature expansion is authorized.

## Audit Counters

| Subsystem | Changes Since Last Audit | Audit Required |
|---|---:|---|
| Repository Governance | 13 / 25 | No |
| Architecture | 14 / 25 | No |
| Documentation | 15 / 25 | No |
| Task System | 22 / 25 | No |
| Evidence Collection and Deterministic Analysis | 10 / 25 | No |
| ARGUS | 10 / 25 | No |
| Reporting | 4 / 25 | No |
| UI | 2 / 25 | No |
| Plugin Framework | 6 / 25 | No |
| Build System | 2 / 25 | No |
| Validation/Test Framework | 8 / 25 | No |
| Roadmap/Backlog | 0 / 25 | No |

## Known Working-Tree Drift
Do not stage or clean unless a focused task explicitly owns it:
- Modified: `App/manifests/custom-tools.json`
- Modified locally: `docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md`
- Untracked: `App/NetworkToolkit/LatencyMon/`
- Untracked: `App/NetworkToolkit/Logs/`
- Untracked: `Custodian-Audit-20260711-000156.md`
- Untracked: `Project-Custodian-Bridge.ps1`
- Untracked: `Set-CodexPermissions.ps1`

## Blockers
None.

## Audit Decision Reference
- `docs/REVIEWS/TASK-0106/ROADMAP-BACKLOG-AUDIT-PREPARATION.md`
- `docs/TASKS/TASK-0107-Project-Custodian-Roadmap-Backlog-Engineering-Audit.md`

## Next Bot Prompt
```text
Resume Work
```
