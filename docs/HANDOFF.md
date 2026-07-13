# Current Handoff

## Handoff ID
HANDOFF-0102

## Current Task
TASK-0092-Transactional-Package-Deploy-And-Update-Integrity

## Current Owner
Codex

## Next Owner
ChatGPT at the next Project Custodian Engineering Audit, architecture/governance boundary, blocker, acceptance boundary, or user-only decision.

## Objective
Resume dependency-ordered remediation with transactional package, deployment, and update integrity.

## Source Of Truth
The repository is authoritative. Exactly one task may be Active, and handoff, queue, and Active task file must agree.

## Current Project State
- TASK-0088 through TASK-0091 are complete.
- TASK-0102 completed UI Audit Preparation.
- TASK-0103 accepted the audit findings, retained TASK-0096 and TASK-0099 as remediation owners, and reset only UI to `0 / 25`.
- TASK-0092 is the single Active Codex task.
- Release candidate remains blocked pending Critical/High remediation.
- `Resume Work` authorizes continuous Codex execution through dependency-ready Codex tasks.
- `Governance Refresh` performs a lightweight safe-point governance reload and resumes the same Active task.
- At `25 / 25`, Codex automatically completes Audit Preparation, pushes the evidence package, and activates a Project Custodian Engineering Audit task.
- Every non-blocked Codex stop-boundary summary must end exactly with `Tell Debbie to continue`.
- Every genuine blocker summary must end exactly with `Tell Debbie to address errors`.

## Active Task Scope
`TASK-0092-Transactional-Package-Deploy-And-Update-Integrity`

Codex must make package, deployment, and update operations complete, atomic, verified, and rollback-capable. It must validate missing/corrupt payloads, locked obsolete files, interrupted updates, wrong destinations, and rollback behavior without expanding into later provenance, sensitive-state, metadata-architecture, or GUI-controller tasks.

## Audit Counters

| Subsystem | Changes Since Last Audit | Audit Required |
|---|---:|---|
| Repository Governance | 13 / 25 | No |
| Architecture | 10 / 25 | No |
| Documentation | 11 / 25 | No |
| Task System | 16 / 25 | No |
| Evidence Collection and Deterministic Analysis | 8 / 25 | No |
| ARGUS | 10 / 25 | No |
| Reporting | 3 / 25 | No |
| UI | 0 / 25 | No |
| Plugin Framework | 3 / 25 | No |
| Build System | 23 / 25 | No |
| Validation/Test Framework | 4 / 25 | No |
| Roadmap/Backlog | 21 / 25 | No |

UI was reset by TASK-0103. No counter currently blocks TASK-0092.

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
- `docs/REVIEWS/TASK-0102/UI-AUDIT-PREPARATION.md`
- `docs/TASKS/TASK-0103-Project-Custodian-UI-Engineering-Audit.md`

## Recommended Commit Message
```text
TASK-0092: Harden package deploy and update integrity
```

## Next Bot Prompt
```text
Resume Work. Synchronize with authoritative `master`, preserve documented drift, and verify handoff/queue agreement. Execute TASK-0092 within scope. Stage and verify payloads before replacement, reject partial reconciliation, validate destination identity, preserve a recoverable prior image, and prove rollback through non-destructive fixtures for missing/corrupt payloads, locked obsolete files, interruption, and wrong destinations. Update required task, queue, handoff, history, counter, punch-list, and build records; commit locally; then continue through the autonomous cycle until the next gate or stop boundary. End any non-blocked stop-boundary summary exactly with `Tell Debbie to continue`.
```
