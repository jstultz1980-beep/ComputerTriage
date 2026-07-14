# Current Handoff

## Handoff ID
HANDOFF-0119

## Current Task
TASK-0111-Long-Path-Mutable-Tree-Cleanup

## Current Owner
Codex

## Next Owner
ChatGPT (Project Custodian) after TASK-0111 completes, full-image verification passes, and TASK-0080 is reactivated for the final release-readiness decision.

## Objective
Implement fail-closed, long-path-capable mutable-tree cleanup, add focused validation, rebuild the full production image, and pass independent verification.

## Source Of Truth
The repository is authoritative. Exactly one task may be Active, and handoff, queue, and Active task file must agree.

## Current Project State
- TASK-0110 through TASK-0100 are complete.
- TASK-0080 canonical repository validation passed 18 of 18 stages.
- The first full production image built at 6.72 GB across 24,364 files.
- Independent verification rejected four long-path LibreOffice files that survived cleanup under `App\Custom\LibreOfficePortable\Data`.
- The Project Custodian rejected written risk acceptance.
- TASK-0111 is the sole Active Codex remediation task.
- TASK-0080 is queued for the final Project Custodian release-readiness decision after remediation.
- No tag, publication, or distribution is authorized.
- Net-new features, helper frameworks, and native replacements remain deferred.

## Active Task Scope
`TASK-0111-Long-Path-Mutable-Tree-Cleanup`

Codex must implement only the focused package-cleanup remediation defined by TASK-0111. It must preserve unrelated drift, add a long-path fixture, run canonical validation, build a new full image, and run independent verification. Broad packaging redesign and unrelated work are not authorized.

## Audit Counters

| Subsystem | Changes Since Last Audit | Audit Required |
|---|---:|---|
| Repository Governance | 15 / 25 | No |
| Architecture | 19 / 25 | No |
| Documentation | 23 / 25 | No |
| Task System | 5 / 25 | No |
| Evidence Collection and Deterministic Analysis | 10 / 25 | No |
| ARGUS | 10 / 25 | No |
| Reporting | 5 / 25 | No |
| UI | 4 / 25 | No |
| Plugin Framework | 6 / 25 | No |
| Build System | 6 / 25 | No |
| Validation/Test Framework | 13 / 25 | No |
| Roadmap/Backlog | 8 / 25 | No |

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
- `docs/REVIEWS/TASK-0080/RELEASE-CANDIDATE-VALIDATION.md`
- `docs/TASKS/TASK-0111-Long-Path-Mutable-Tree-Cleanup.md`
- `docs/TASKS/TASK-0080-Release-Candidate-Validation-And-Documentation.md`
- `docs/KNOWN-LIMITATIONS.md`
- `docs/REPOSITORY-VALIDATION.md`

## Next Bot Prompt
```text
Resume Work
```
