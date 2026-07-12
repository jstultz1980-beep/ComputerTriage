# Current Handoff

## Handoff ID
HANDOFF-0092

## Current Task
TASK-0086-Offline-Evidence-Isolation-And-Bundle-Identity

## Current Owner
Codex

## Next Owner
ChatGPT at the next architecture, governance, audit, blocker, or acceptance boundary.

## Objective
Eliminate cross-machine evidence contamination and bind deterministic analysis, ARGUS, reports, and transfer behavior to one validated immutable diagnostic run identity.

## Source Of Truth
The repository is authoritative. Exactly one task may be Active, and `docs/HANDOFF.md`, `docs/TASKS/QUEUE.md`, and the Active task file must agree.

## Current Project State
- TASK-0084 Full Codebase Architecture and Quality Audit is complete.
- Repository health score is `52 / 100`.
- Release readiness is `Not Ready for Release Candidate`.
- Every Critical and High finding has a remediation task or documented disposition.
- TASK-0086 is the single Active implementation task.
- TASK-0077, TASK-0078, and TASK-0079 are superseded by focused audit-remediation tasks.
- TASK-0080 remains the final release-candidate validation and documentation gate.
- `Resume Work` now requires a mandatory fetch, upstream comparison, and verified local/remote synchronization before task execution.

## Active Task Scope
`TASK-0086-Offline-Evidence-Isolation-And-Bundle-Identity`

Codex must:
- Add immutable run/bundle identity.
- Validate explicit and default bundle roots.
- Separate offline bundle analysis from live-host observation.
- Prevent current-host data from contaminating offline analysis.
- Exclude generated analysis/report artifacts from source evidence.
- Preserve run identity through deterministic analysis, ARGUS, reporting, and transfer paths.
- Validate cross-machine and repeated-run behavior.

Codex must not:
- Expand the rule catalog.
- Redesign the GUI.
- Merge unrelated audit remediations into TASK-0086.
- Clean unrelated working-tree drift.

## Audit Counters

| Subsystem | Changes Since Last Audit | Audit Required |
|---|---:|---|
| Repository Governance | 10 / 25 | No |
| Architecture | 4 / 25 | No |
| Documentation | 1 / 25 | No |
| Task System | 7 / 25 | No |
| Evidence Collection and Deterministic Analysis | 4 / 25 | No |
| ARGUS | 6 / 25 | No |
| Reporting | 2 / 25 | No |
| UI | 22 / 25 | No |
| Plugin Framework | 1 / 25 | No |
| Build System | 17 / 25 | No |
| Validation/Test Framework | 23 / 25 | No |
| Roadmap/Backlog | 14 / 25 | No |

TASK-0084 was a broad planned audit and did not reset subsystem counters. Closeout governance records incremented only the materially changed governance/task/roadmap/documentation categories shown above.

## Known Working-Tree Drift
Do not stage or clean unless a focused task explicitly owns it:
- Modified: `App/manifests/custom-tools.json`
- Modified locally: `docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md`
- Untracked: `App/NetworkToolkit/LatencyMon/`
- Untracked: `App/NetworkToolkit/Logs/`
- Untracked: `Set-CodexPermissions.ps1`

## Blockers
None recorded in the cloud repository.

## Audit Closeout References
- `docs/REVIEWS/TASK-0084/FINDINGS-REGISTER.md`
- `docs/REVIEWS/TASK-0084/TECHNICAL-DEBT-REGISTER.md`
- `docs/REVIEWS/TASK-0084/REPOSITORY-HEALTH-ASSESSMENT.md`
- `docs/REVIEWS/TASK-0084/EXECUTIVE-ENGINEERING-REPORT.md`
- `docs/REVIEWS/TASK-0084/RELEASE-READINESS-ASSESSMENT.md`
- `docs/REVIEWS/TASK-0084/REMEDIATION-BACKLOG.md`

## Recommended Commit Message

```text
TASK-0086: Isolate offline evidence and bind immutable run identity
```

## Next Bot Prompt

```text
Run the mandatory Resume Work synchronization procedure first: read AGENTS.md and docs/CODEX-CLI-OPERATING-INSTRUCTIONS.md, run `git fetch --prune origin`, verify the intended branch and upstream, compare local HEAD with the upstream branch, safely fast-forward when behind, and confirm the local and remote commit hashes match before trusting local governance or task files. If the branch is ahead, diverged, has no upstream, fetch fails, or synchronization would overwrite preserved work, stop before implementation and use the Error Handoff Procedure. After synchronization, follow the complete repository startup sequence. Verify TASK-0086 is the only Active task. Preserve all documented unrelated drift. Execute only TASK-0086-Offline-Evidence-Isolation-And-Bundle-Identity. Validate cross-machine evidence isolation, explicit/default bundle validation, generated-output exclusion, immutable run identity propagation, repeated-run idempotence, parser behavior, smoke tests, and button-smoke tests. Update the task, handoff, queue, changelog, change ledger, and build metadata as required. Commit locally. Do not push unless explicitly requested, except under the Error Handoff Rule.
```
