# Current Handoff

## Handoff ID
HANDOFF-0096

## Current Task
TASK-0089-Diagnostic-Bundle-Integrity-And-Collection-Contract

## Current Owner
Codex

## Next Owner
ChatGPT at the next Project Custodian Engineering Audit, architecture/governance boundary, blocker, acceptance boundary, or user-only decision.

## Objective
Continue dependency-ordered remediation with TASK-0089 under the autonomous `Resume Work` cycle.

## Source Of Truth
The repository is authoritative. Exactly one task may be Active, and handoff, queue, and Active task file must agree.

## Current Project State
- TASK-0084 audit is complete; repository health remains `52 / 100` pending remediation.
- TASK-0086 completed offline evidence isolation and immutable bundle identity.
- TASK-0087 completed parser-backed evidence quality and source-event-time timeline semantics.
- TASK-0101 completed the Validation/Test Framework threshold audit and reset it to `0 / 25`.
- TASK-0088 completed canonical operation results and failure propagation.
- TASK-0089 is the single Active implementation task.
- Remaining remediation tasks stay queued in dependency order.
- Release candidate remains blocked pending Critical/High remediation.
- `Resume Work` now authorizes continuous Codex execution through dependency-ready Codex tasks.
- At `25 / 25`, Codex automatically completes Audit Preparation, pushes the evidence package, and activates a Project Custodian Engineering Audit task.
- The user tells ChatGPT `Continue` at the Project Custodian boundary; after the decision is pushed, the user tells Codex `Resume Work` and the cycle repeats.

## Autonomous Cycle References
- `PROJECT.md`
- `AGENTS.md`
- `docs/CODEX-CLI-OPERATING-INSTRUCTIONS.md`
- `docs/GOVERNANCE/AUTONOMOUS-WORK-AND-AUDIT-CYCLE.md`
- `docs/REVIEWS/AUDIT-PREPARATION-TEMPLATE.md`

## Active Task Scope
`TASK-0089-Diagnostic-Bundle-Integrity-And-Collection-Contract`

Codex must make bundle identity, integrity, completeness, and collection outcomes trustworthy within TASK-0089 scope.

Codex must read TASK-0089 and its references before implementation and must not merge later ARGUS, transaction, package, or GUI-controller remediations into TASK-0089.

After TASK-0089 completes, Codex must re-read the queue and counters. If no gate or stop condition exists, it must activate the next dependency-ready Codex-owned task and continue without another prompt.

## Audit Counters

| Subsystem | Changes Since Last Audit | Audit Required |
|---|---:|---|
| Repository Governance | 11 / 25 | No |
| Architecture | 7 / 25 | No |
| Documentation | 6 / 25 | No |
| Task System | 12 / 25 | No |
| Evidence Collection and Deterministic Analysis | 7 / 25 | No |
| ARGUS | 9 / 25 | No |
| Reporting | 3 / 25 | No |
| UI | 24 / 25 | No |
| Plugin Framework | 2 / 25 | No |
| Build System | 20 / 25 | No |
| Validation/Test Framework | 1 / 25 | No |
| Roadmap/Backlog | 18 / 25 | No |

No counter currently blocks TASK-0089. UI is at `24 / 25`; any material UI change in TASK-0089 would trigger Audit Preparation at its boundary.

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

## Recommended Commit Message
```text
TASK-0089: Enforce diagnostic bundle integrity and collection contract
```

## Next Bot Prompt
```text
Resume Work. First perform the mandatory repository synchronization procedure and confirm local HEAD matches the authoritative upstream without overwriting preserved drift. Then read PROJECT.md, AGENTS.md, docs/CODEX-CLI-OPERATING-INSTRUCTIONS.md, docs/GOVERNANCE/AUTONOMOUS-WORK-AND-AUDIT-CYCLE.md, the handoff, queue, error handoff, TASK-0089, and all referenced files. Execute TASK-0089 within scope, validate bundle integrity, completeness, partial collection, parser/smoke/button-smoke behavior, update all required records and build metadata, and commit locally. After completion, continue through the autonomous cycle until a gate or stop boundary.
```
