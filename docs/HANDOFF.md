# Current Handoff

## Handoff ID
HANDOFF-0087

## Current Task
TASK-0075-Reporting-Finish-Pass

## Current Owner
Codex

## Next Owner
Codex

## Objective
TASK-0073 and TASK-0074 are complete. Codex may implement TASK-0075 using the normalized ARGUS evidence, diagnostic groups, and cited technician recommendations.

## Source Of Truth
The repository is the source of truth. Chat history, screenshots, and terminal-only notes are not authoritative unless recorded in tracked repository files.

Exactly one task may be Active. `docs/HANDOFF.md` and `docs/TASKS/QUEUE.md` must agree.

## Roles
- ChatGPT is the Project Custodian and architecture/governance owner.
- Codex is the Programmer and implementation agent.
- Codex executes only the approved Active task and reports blockers rather than expanding scope.

## Codex CLI Resume Work Protocol
When the user enters `Resume Work`, Codex must follow `AGENTS.md`, `docs/CODEX-CLI-OPERATING-INSTRUCTIONS.md`, and `PROJECT.md`; rebuild context from tracked files; preserve documented drift; validate; update records; and commit locally. Push only when explicitly requested.

## Current Project State
- TASK-0071 and TASK-0072 completed finish-line planning and ARGUS product design.
- TASK-0081 completed the Task System audit.
- TASK-0082 approved ARGUS normalization implementation.
- TASK-0083 added the repository-resident Codex CLI protocol.
- TASK-0073 completed ARGUS evidence normalization.
- TASK-0074 completed diagnostic grouping and cited technician recommendations.
- TASK-0075 is the single Active task.
- TASK-0076 through TASK-0078, TASK-0084, TASK-0079, and TASK-0080 remain queued in finish-line order.

## TASK-0074 Validation Result
- PowerShell parser validation passed for `ArgusFoundation.ps1`, `ArgusNormalization.ps1`, and `ArgusRecommendations.ps1`.
- The existing AI bundle produced parseable `ARGUS/diagnostic-groups.json` and `ARGUS/recommendations.json` with 13 cited groups and recommendations.
- Synthetic normal, limited/gap-only, and problem-heavy scenarios passed.
- Missing-evidence-only domains emit cited unsupported conclusions and collection guidance.

## Active Task Scope
`TASK-0075-Reporting-Finish-Pass`

Codex should:
- Generate technician-readable and escalation/handoff report outputs from current ARGUS artifacts.
- Include findings, diagnostic groups, recommendations, confidence, citations, and evidence limitations.
- Keep reports useful outside the GUI and validate them against a current bundle.

Codex must not add:
- UI integration.
- Broad AI orchestration.
- HEPHAESTUS collector changes.
- Branding rename execution.

## Audit Counters

| Subsystem | Changes Since Last Audit | Audit Required |
|---|---:|---|
| Repository Governance | 8 / 25 | No |
| Architecture | 3 / 25 | No |
| Documentation | 23 / 25 | No |
| Task System | 4 / 25 | No |
| HEPHAESTUS | 4 / 25 | No |
| ARGUS | 6 / 25 | No |
| Reporting | 1 / 25 | No |
| UI | 21 / 25 | No |
| Plugin Framework | 1 / 25 | No |
| Build System | 15 / 25 | No |
| Validation/Test Framework | 21 / 25 | No |
| Roadmap/Backlog | 11 / 25 | No |

No subsystem is currently at the `25 / 25` audit gate.

## Known Working-Tree Drift
Do not stage or clean unless a focused task explicitly owns it:
- Modified: `App/manifests/custom-tools.json`
- Modified locally: `docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md`
- Untracked: `App/NetworkToolkit/LatencyMon/`
- Untracked: `App/NetworkToolkit/Logs/`
- Untracked: `Set-CodexPermissions.ps1`

The committed ADR-0003 is accepted. The local ADR difference remains unrelated stale drift.

## Blockers
None.

## Recommended Commit Message
```text
TASK-0074: Add ARGUS diagnostic groups and recommendations
```

## Next Bot Prompt
```text
Resume Work. Execute only TASK-0075-Reporting-Finish-Pass. Preserve all documented unrelated drift. Use the completed ARGUS normalization, diagnostic-group, and recommendation artifacts. Validate report generation against a current bundle. Commit locally and do not push unless explicitly requested.
```
