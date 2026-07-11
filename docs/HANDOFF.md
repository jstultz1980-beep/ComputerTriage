# Current Handoff

## Handoff ID
HANDOFF-0088

## Current Task
TASK-0076-Analyze-Workflow-UI-Integration

## Current Owner
Codex

## Next Owner
Codex

## Objective
TASK-0075 is complete. Codex may integrate collection, local analysis, ARGUS, and report review into the normal technician GUI workflow under TASK-0076.

## Source Of Truth
The repository is the source of truth. Chat history and terminal-only notes are not authoritative unless recorded in tracked files. Exactly one task may be Active, and the handoff and queue must agree.

## Codex CLI Protocol
On `Resume Work`, follow `AGENTS.md`, `docs/CODEX-CLI-OPERATING-INSTRUCTIONS.md`, `PROJECT.md`, and the non-interruption guardrail. Preserve documented drift, execute only the Active task, validate, update records, and commit locally. Push only when explicitly requested.

## Current Project State
- TASK-0073 completed ARGUS normalization.
- TASK-0074 completed diagnostic grouping and cited recommendations.
- TASK-0075 completed standalone technician and escalation reporting.
- TASK-0076 is the single Active task.
- TASK-0077, TASK-0078, TASK-0084, TASK-0079, and TASK-0080 remain queued in finish-line order.

## TASK-0075 Validation Result
- All four ARGUS PowerShell scripts pass parser validation.
- Current-bundle ARGUS execution generated `technician-report.md` and `escalation-report.md` under `ARGUS/`.
- The technician report contains computer context, recommended actions, confidence, citations, diagnostic themes, and evidence limitations.
- The escalation report contains structured artifact references, cited diagnostic groups, recommendation handoff, and unsupported-conclusion limits.
- Both reports are substantive and contain zero uncited placeholders.

## Active Task Scope
`TASK-0076-Analyze-Workflow-UI-Integration`

Codex should:
- Refine the Analyze page workflow.
- Add normal GUI access to the latest analysis and report outputs.
- Surface limited-evidence and missing-artifact states clearly.
- Preserve existing console commands for advanced use.

Codex must not add:
- New ARGUS reasoning features.
- Broad tab redesign.
- Deployment or packaging changes.

## Audit Counters

| Subsystem | Changes Since Last Audit | Audit Required |
|---|---:|---|
| Repository Governance | 8 / 25 | No |
| Architecture | 3 / 25 | No |
| Documentation | 24 / 25 | No |
| Task System | 5 / 25 | No |
| HEPHAESTUS | 4 / 25 | No |
| ARGUS | 6 / 25 | No |
| Reporting | 2 / 25 | No |
| UI | 21 / 25 | No |
| Plugin Framework | 1 / 25 | No |
| Build System | 16 / 25 | No |
| Validation/Test Framework | 22 / 25 | No |
| Roadmap/Backlog | 12 / 25 | No |

No subsystem is currently at the `25 / 25` audit gate.

## Known Working-Tree Drift
Do not stage or clean unless a focused task explicitly owns it:
- Modified: `App/manifests/custom-tools.json`
- Modified locally: `docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md`
- Untracked: `App/NetworkToolkit/LatencyMon/`
- Untracked: `App/NetworkToolkit/Logs/`
- Untracked: `Set-CodexPermissions.ps1`

The reconciliation safety branch and stash remain available. The committed ADR-0003 is accepted; its local difference remains unrelated stale drift.

## Blockers
None.

## Recommended Commit Message
```text
TASK-0075: Add ARGUS technician and escalation reports
```

## Next Bot Prompt
```text
Resume Work. Execute only TASK-0076-Analyze-Workflow-UI-Integration. Preserve documented unrelated drift. Connect the normal GUI workflow to collection, local analysis, ARGUS, and the latest report outputs; surface limited or missing evidence clearly; run parser, GUI smoke, and button-smoke validation; commit locally; do not push unless explicitly requested.
```
