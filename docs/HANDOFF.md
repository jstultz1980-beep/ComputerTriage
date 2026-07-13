# Current Handoff

## Handoff ID
HANDOFF-0096

## Current Task
TASK-0088-Canonical-Operation-Results-And-Failure-Propagation

## Current Owner
Codex

## Next Owner
ChatGPT at the next Project Custodian Engineering Audit, architecture/governance boundary, blocker, acceptance boundary, or user-only decision.

## Objective
Continue dependency-ordered remediation beginning with TASK-0088 under the autonomous `Resume Work` cycle.

## Source Of Truth
The repository is authoritative. Exactly one task may be Active, and handoff, queue, and Active task file must agree.

## Current Project State
- TASK-0084 audit is complete; repository health remains `52 / 100` pending remediation.
- TASK-0086 completed offline evidence isolation and immutable bundle identity.
- TASK-0087 completed parser-backed evidence quality and source-event-time timeline semantics.
- TASK-0101 completed the Validation/Test Framework threshold audit and reset it to `0 / 25`.
- TASK-0088 is the single Active implementation task.
- Remaining remediation tasks stay queued in dependency order.
- Release candidate remains blocked pending Critical/High remediation.
- `Resume Work` authorizes continuous Codex execution through dependency-ready Codex tasks.
- At `25 / 25`, Codex automatically completes Audit Preparation, pushes the evidence package, and activates a Project Custodian Engineering Audit task.
- Every non-blocked Codex stop-boundary summary must end exactly with `Tell Debbie to continue`.
- Every genuine blocker summary must end exactly with `Tell Debbie to address errors`.

## Autonomous Cycle References
- `PROJECT.md`
- `AGENTS.md`
- `docs/CODEX-CLI-OPERATING-INSTRUCTIONS.md`
- `docs/GOVERNANCE/AUTONOMOUS-WORK-AND-AUDIT-CYCLE.md`
- `docs/REVIEWS/AUDIT-PREPARATION-TEMPLATE.md`

## Active Task Scope
`TASK-0088-Canonical-Operation-Results-And-Failure-Propagation`

Codex must establish one canonical operation-result envelope and propagate failure, cancellation, partial completion, warnings, and exit semantics through the task-owned execution paths.

Codex must read TASK-0088 and its references before implementation and must not merge later collection, ARGUS, transaction, package, or GUI-controller remediations into TASK-0088.

After TASK-0088 completes, Codex must re-read the queue and counters. If no gate or stop condition exists, it must activate the next dependency-ready Codex-owned task and continue without another prompt.

## Audit Counters

| Subsystem | Changes Since Last Audit | Audit Required |
|---|---:|---|
| Repository Governance | 12 / 25 | No |
| Architecture | 6 / 25 | No |
| Documentation | 6 / 25 | No |
| Task System | 11 / 25 | No |
| Evidence Collection and Deterministic Analysis | 6 / 25 | No |
| ARGUS | 8 / 25 | No |
| Reporting | 3 / 25 | No |
| UI | 23 / 25 | No |
| Plugin Framework | 1 / 25 | No |
| Build System | 19 / 25 | No |
| Validation/Test Framework | 0 / 25 | No |
| Roadmap/Backlog | 17 / 25 | No |

No counter currently blocks TASK-0088. When any counter reaches `25 / 25` at a task boundary, Codex automatically performs Audit Preparation before further implementation.

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
TASK-0088: Establish canonical operation results and failure propagation
```

## Next Bot Prompt
```text
Resume Work. First perform the mandatory repository synchronization procedure and confirm local HEAD matches the authoritative upstream without overwriting preserved drift. Then read PROJECT.md, AGENTS.md, docs/CODEX-CLI-OPERATING-INSTRUCTIONS.md, docs/GOVERNANCE/AUTONOMOUS-WORK-AND-AUDIT-CYCLE.md, the handoff, queue, error handoff, TASK-0088, and all referenced files. Execute TASK-0088 within scope, validate negative paths plus parser/smoke/button-smoke behavior, update all required records and build metadata, and commit locally. After completion, re-read the queue, counters, punch list, and blockers. If no stop condition exists, activate the next dependency-ready Codex-owned task and continue automatically. Repeat until a counter reaches 25 / 25, a Project Custodian-owned task becomes Active, a genuine blocker occurs, or a user-only decision is unavoidable. At a 25 / 25 gate, automatically create and complete Audit Preparation using the tracked template, push the audit package and transition records, activate a Project Custodian Engineering Audit task, and stop. Do not push normal implementation commits unless explicitly authorized; audit packages and blocker handoffs must be pushed as required. Every non-blocked stop-boundary summary must end with the exact final line `Tell Debbie to continue`. Every genuine blocker summary must end with the exact final line `Tell Debbie to address errors`. Do not add text after the final operator instruction.
```