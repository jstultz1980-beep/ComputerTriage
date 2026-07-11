# Current Handoff

## Handoff ID
HANDOFF-0090

## Current Task
TASK-0084-Full-Codebase-Architecture-And-Quality-Audit

## Current Owner
ChatGPT

## Next Owner
Codex after audit remediation tasks are created and activated

## Objective
Perform the complete read-only codebase architecture and quality audit under a development freeze. Record evidence-backed findings, create focused remediation tasks, and do not change application code during the initial audit.

## Source Of Truth
The repository is authoritative. Exactly one task may be Active, and `docs/HANDOFF.md`, `docs/TASKS/QUEUE.md`, and the Active task file must agree.

## Current Project State
- TASK-0073 completed ARGUS evidence normalization.
- TASK-0074 completed event grouping and technician recommendations.
- TASK-0075 completed technician and escalation reporting.
- TASK-0076 completed the guided Analyze GUI workflow.
- TASK-0085 completed the mandatory Documentation `25 / 25` audit and reset only Documentation.
- TASK-0084 is now the single Active task.
- Implementation is frozen while TASK-0084 is Active.
- TASK-0077, TASK-0078, TASK-0079, and TASK-0080 remain queued pending audit findings and remediation sequencing.

## Active Task Scope
`TASK-0084-Full-Codebase-Architecture-And-Quality-Audit`

ChatGPT must:
- Inventory the operational repository.
- Trace startup, execution, analysis, reporting, deployment/update, and shutdown flows.
- Identify redundancy, dead code, hidden failures, false-success conditions, unsafe assumptions, architecture drift, security issues, performance risks, testing gaps, deployment drift, and documentation inconsistencies.
- Produce severity-ranked findings with evidence.
- Create focused remediation tasks rather than fixing code during the initial audit.

ChatGPT must not:
- Modify application code.
- Refactor or clean code during the initial audit.
- Add product features.
- Clean unrelated working-tree drift.
- Activate Codex implementation before the audit records the remediation sequence.

Codex is in Engineering Support mode and should not implement changes unless a focused audit-support or remediation task is explicitly activated.

## Audit Counters

| Subsystem | Changes Since Last Audit | Audit Required |
|---|---:|---|
| Repository Governance | 8 / 25 | No |
| Architecture | 3 / 25 | No |
| Documentation | 0 / 25 | No - reset by TASK-0085 |
| Task System | 6 / 25 | No |
| Evidence Collection and Deterministic Analysis | 4 / 25 | No |
| ARGUS | 6 / 25 | No |
| Reporting | 2 / 25 | No |
| UI | 22 / 25 | No |
| Plugin Framework | 1 / 25 | No |
| Build System | 17 / 25 | No |
| Validation/Test Framework | 23 / 25 | No |
| Roadmap/Backlog | 13 / 25 | No |

No counter gate blocks TASK-0084. TASK-0084 is a broader planned engineering audit rather than a single-counter reset.

## Known Working-Tree Drift
Do not stage or clean unless a focused task explicitly owns it:
- Modified: `App/manifests/custom-tools.json`
- Modified locally: `docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md`
- Untracked: `App/NetworkToolkit/LatencyMon/`
- Untracked: `App/NetworkToolkit/Logs/`
- Untracked: `Set-CodexPermissions.ps1`

The reconciliation safety branch remains available. The committed ADR-0003 is accepted; local drift is unrelated to the audit’s tracked baseline.

## Audit Progress
- TASK-0085 documentation consistency gate completed.
- TASK-0084 activated.
- Development freeze established.
- Phase 1 governance and architecture-document review started.
- Initial audit deliverables are being written under `docs/REVIEWS/TASK-0084/`.

## Initial Observations To Investigate
These are not yet final findings:
- The project charter still names HEPHAESTUS even though the user decided to remove non-ARGUS codenames.
- The architecture document is too shallow to describe the implemented collection, deterministic analysis, ARGUS, reporting, deployment, and update boundaries.
- The roadmap contains stale planning language and historical detail that obscures current phase state.
- The queue previously carried an excessive historical table, creating duplication with individual task files and history.

## Blockers
None.

## Recommended Commit Message
```text
TASK-0084: Begin full codebase architecture and quality audit
```

## Next Bot Prompt
For ChatGPT:

```text
Continue TASK-0084. Read the live GitHub repository as the source of truth. Continue the read-only audit, update the tracked audit deliverables, do not modify application code, and create focused remediation tasks only after findings are evidence-backed.
```

For Codex during the freeze:

```text
Development Freeze. TASK-0084 is Active and owned by ChatGPT. Preserve current drift, perform no implementation, and remain in Engineering Support mode until a focused remediation task is activated.
```
