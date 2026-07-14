# Current Handoff

## Handoff ID
HANDOFF-0120

## Current Task
TASK-0112-Cold-Tab-Initialization-Performance-Remediation

## Current Owner
Codex

## Next Owner
ChatGPT (Project Custodian) after TASK-0112 completes, its focused and canonical validation passes, and TASK-0080 is reactivated for the final release-readiness decision.

## Objective
Measure and remove repeatable first-open tab latency without shifting expensive work into synchronous application startup.

## Source Of Truth
The repository is authoritative. Exactly one task may be Active, and handoff, queue, and Active task file must agree.

## Current Project State
- TASK-0097 through TASK-0100 are complete.
- TASK-0110 resolved accepted Task System consistency debt.
- TASK-0111 completed fail-closed long-path mutable-tree cleanup and independently verified the clean full production image.
- TASK-0080 canonical repository validation passed 19 of 19 stages.
- Direct technician use identified repeatable lag when selecting a tab that had not been opened since toolkit startup.
- Already initialized tabs are materially faster, indicating cold-tab initialization rather than general sustained UI slowness.
- The Project Custodian rejected broad release readiness until this normal-navigation latency is remediated.
- TASK-0112 is the sole Active Codex task.
- TASK-0080 is queued for the final Project Custodian release-readiness decision after TASK-0112.
- No tag, publication, or distribution is authorized.
- Net-new features, helper frameworks, and native replacements remain deferred.

## Active Task Scope
`TASK-0112-Cold-Tab-Initialization-Performance-Remediation`

Codex must implement only the focused cold-tab performance remediation defined by TASK-0112. It must preserve unrelated drift, instrument first-open and warm navigation, warm lightweight tab UI only after the main window is responsive, keep live collection deferred, prevent duplicate initialization, and run focused plus canonical validation. Broad UI redesign and unrelated work are not authorized.

## Audit Counters

| Subsystem | Changes Since Last Audit | Audit Required |
|---|---:|---|
| Repository Governance | 15 / 25 | No |
| Architecture | 19 / 25 | No |
| Documentation | 23 / 25 | No |
| Task System | 6 / 25 | No |
| Evidence Collection and Deterministic Analysis | 10 / 25 | No |
| ARGUS | 10 / 25 | No |
| Reporting | 5 / 25 | No |
| UI | 5 / 25 | No |
| Plugin Framework | 6 / 25 | No |
| Build System | 6 / 25 | No |
| Validation/Test Framework | 13 / 25 | No |
| Roadmap/Backlog | 9 / 25 | No |

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
- `docs/TASKS/TASK-0112-Cold-Tab-Initialization-Performance-Remediation.md`
- `docs/TASKS/TASK-0080-Release-Candidate-Validation-And-Documentation.md`
- `docs/REVIEWS/TASK-0080/RELEASE-CANDIDATE-VALIDATION.md`
- `docs/TASKS/TASK-0111-Long-Path-Mutable-Tree-Cleanup.md`

## Next Bot Prompt
```text
Resume Work
```
