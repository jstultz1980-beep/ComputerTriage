# Current Handoff

## Handoff ID
HANDOFF-0103

## Current Task
TASK-0093-External-Tool-Provenance-And-Lifecycle-Policy

## Current Owner
Codex

## Next Owner
ChatGPT at the next Project Custodian Engineering Audit, architecture/governance boundary, blocker, acceptance boundary, or user-only decision.

## Objective
Continue dependency-ordered remediation with external-tool provenance, integrity, licensing, privilege, EDR, and lifecycle policy.

## Source Of Truth
The repository is authoritative. Exactly one task may be Active, and handoff, queue, and Active task file must agree.

## Current Project State
- TASK-0088 through TASK-0091 are complete.
- TASK-0102 completed UI Audit Preparation.
- TASK-0103 accepted the audit findings, retained TASK-0096 and TASK-0099 as remediation owners, and reset only UI to `0 / 25`.
- TASK-0092 completed transactional package, deploy, and update integrity.
- TASK-0093 is the single Active Codex task.
- Release candidate remains blocked pending Critical/High remediation.
- `Resume Work` authorizes continuous Codex execution through dependency-ready Codex tasks.
- `Governance Refresh` performs a lightweight safe-point governance reload and resumes the same Active task.
- At `25 / 25`, Codex automatically completes Audit Preparation, pushes the evidence package, and activates a Project Custodian Engineering Audit task.
- Every non-blocked Codex stop-boundary summary must end exactly with `Tell Debbie to continue`.
- Every genuine blocker summary must end exactly with `Tell Debbie to address errors`.

## Active Task Scope
`TASK-0093-External-Tool-Provenance-And-Lifecycle-Policy`

Codex must enforce external-tool provenance, integrity, licensing, privilege, EDR policy, and complete the tracked tool-retention review without expanding into later sensitive-state, metadata-architecture, or GUI-controller tasks.

## Audit Counters

| Subsystem | Changes Since Last Audit | Audit Required |
|---|---:|---|
| Repository Governance | 13 / 25 | No |
| Architecture | 11 / 25 | No |
| Documentation | 12 / 25 | No |
| Task System | 17 / 25 | No |
| Evidence Collection and Deterministic Analysis | 8 / 25 | No |
| ARGUS | 10 / 25 | No |
| Reporting | 3 / 25 | No |
| UI | 0 / 25 | No |
| Plugin Framework | 3 / 25 | No |
| Build System | 24 / 25 | No |
| Validation/Test Framework | 5 / 25 | No |
| Roadmap/Backlog | 22 / 25 | No |

No counter currently blocks TASK-0093. Build System is at `24 / 25`; if TASK-0093 increments it, Codex must finish TASK-0093 and perform Audit Preparation before further implementation.

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
TASK-0093: Enforce external tool provenance and lifecycle policy
```

## Next Bot Prompt
```text
Resume Work. Synchronize with authoritative `master`, preserve documented drift, and verify handoff/queue agreement. Execute TASK-0093 within scope, including the punch-list Sysinternals retention review; validate provenance, hashes/signatures, licensing, privilege, EDR disposition, lifecycle states, parser, smoke, and button-smoke behavior. Update required records and build metadata, commit locally, and continue through the autonomous cycle until the next gate or stop boundary.
```
