# Current Handoff

## Handoff ID
HANDOFF-0092

## Current Task
TASK-0087-Parser-Backed-Evidence-Quality-And-Timeline

## Current Owner
Codex

## Next Owner
ChatGPT at the next architecture, governance, audit, blocker, or acceptance boundary.

## Objective
TASK-0086 is complete. Make evidence quality reflect real parser and semantic outcomes and ensure timeline artifacts contain source event time rather than file-copy time.

## Source Of Truth
The repository is authoritative. Exactly one task may be Active, and handoff, queue, and Active task file must agree.

## Current Project State
- TASK-0084 audit is complete; repository health remains `52 / 100` pending remediation.
- TASK-0086 completed offline evidence isolation and immutable bundle identity.
- TASK-0087 is the single Active implementation task.
- Remaining remediation tasks stay queued in dependency order.
- Release candidate remains blocked pending Critical/High remediation.

## TASK-0086 Validation Result
- All changed PowerShell files passed parser validation.
- Computer-A fixture analyzed on the current host contained only Computer-A identity.
- Empty, invalid, partial, unrelated, conflicting-identity, and mixed-export cases were rejected or excluded.
- Default selection chose the newest valid collected run, not the newest arbitrary folder.
- Repeated analysis preserved source inventory count and immutable identity.
- ARGUS artifacts and both reports preserved run/bundle identity.
- Client-data transfer verified and recorded copied run identities.
- GUI smoke and button-smoke passed.

## Active Task Scope
`TASK-0087-Parser-Backed-Evidence-Quality-And-Timeline`

Codex must separate discovery, parsing, semantic validation, and coverage; reject invalid structured artifacts; record parser outcomes; replace file-copy chronology with real event semantics; and update downstream ARGUS confidence handling.

Codex must not expand unrelated rules, redesign the GUI, or merge later remediation tasks.

## Audit Counters

| Subsystem | Changes Since Last Audit | Audit Required |
|---|---:|---|
| Repository Governance | 9 / 25 | No |
| Architecture | 5 / 25 | No |
| Documentation | 2 / 25 | No |
| Task System | 8 / 25 | No |
| Evidence Collection and Deterministic Analysis | 5 / 25 | No |
| ARGUS | 7 / 25 | No |
| Reporting | 3 / 25 | No |
| UI | 23 / 25 | No |
| Plugin Framework | 1 / 25 | No |
| Build System | 18 / 25 | No |
| Validation/Test Framework | 24 / 25 | No |
| Roadmap/Backlog | 15 / 25 | No |

No counter gate blocks the already Active TASK-0087. If Validation/Test Framework reaches 25/25 during TASK-0087, finish TASK-0087 and activate its required audit before TASK-0088.

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
TASK-0086: Isolate offline evidence and bind immutable run identity
```

## Next Bot Prompt
```text
Resume Work. Execute only TASK-0087-Parser-Backed-Evidence-Quality-And-Timeline. Preserve documented drift. Validate valid, empty, malformed, truncated, plain-error, and known event/copy timestamp fixtures; run ARGUS confidence regression, parser, smoke, and button-smoke checks; update records and build metadata; commit locally; do not push unless explicitly requested except under the Error Handoff Rule.
```
