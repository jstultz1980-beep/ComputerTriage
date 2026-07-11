# Current Handoff

## Handoff ID
HANDOFF-0086

## Current Task
TASK-0074-ARGUS-Event-Grouping-And-Recommendations

## Current Owner
Codex

## Next Owner
Codex

## Objective
TASK-0082 completed the ChatGPT governance and ARGUS architecture review. No blocking findings were identified. TASK-0073 is complete. Codex may now implement TASK-0074 using the approved ARGUS normalized analysis model and accepted ADR-0003.

## Source Of Truth
The repository is the source of truth. Chat history, screenshots, and terminal-only notes are not authoritative unless recorded in tracked repository files.

Exactly one task may be Active. `docs/HANDOFF.md` and `docs/TASKS/QUEUE.md` must agree.

## Roles
- ChatGPT is the Project Custodian and architecture/governance owner.
- Codex is the Programmer and implementation agent.
- ChatGPT controls architecture, governance, task activation, audit decisions, and implementation readiness through tracked repository updates.
- Codex controls implementation details within the approved Active task and must report blockers rather than expanding scope.

## Codex CLI Resume Work Protocol
Repository instruction files:
- `AGENTS.md`
- `docs/CODEX-CLI-OPERATING-INSTRUCTIONS.md`
- `PROJECT.md`

When the user enters `Resume Work`, Codex must rebuild context from tracked files, verify the single Active task and audit gates, preserve documented drift, execute only the Active task, validate, update records, and commit locally. Push only when explicitly requested.

## Current Project State
- TASK-0071 completed the finish-line plan.
- TASK-0072 completed the ARGUS product definition and evidence map.
- TASK-0081 completed the Task System `25 / 25` audit and reset only that counter.
- TASK-0082 completed the ChatGPT governance and architecture review.
- TASK-0083 added the repository-resident Codex CLI `Resume Work` protocol.
- TASK-0073 is complete.
- TASK-0074 is now the single active implementation task.
- TASK-0075 through TASK-0080 remain queued in finish-line order.

## TASK-0073 Validation Result
ChatGPT reviewed:
- `PROJECT.md`
- `docs/PROJECT-CHARTER.md`
- `docs/ARCHITECTURE.md`
- `docs/ROADMAP.md`
- `docs/HANDOFF.md`
- `docs/TASKS/QUEUE.md`
- `docs/HISTORY/CHANGE-LEDGER.md`
- `docs/HISTORY/CHANGELOG.md`
- TASK-0071, TASK-0072, TASK-0073, TASK-0074, TASK-0081, and TASK-0082
- `docs/DESIGN/ARGUS-PRODUCT-DEFINITION-AND-EVIDENCE-MAP.md`
- Accepted ADR-0003

Findings:
- HEPHAESTUS and ARGUS responsibilities are correctly separated.
- HEPHAESTUS collects evidence and performs deterministic local analysis.
- ARGUS consumes deterministic/normalized outputs and produces cited explanations, grouping, and technician guidance.
- The evidence trust order, citation model, confidence language, and unsupported-inference rules are sufficient for first-release implementation.
- TASK-0073 correctly delivered loaders and `ARGUS/normalized-analysis.json`.
- TASK-0074 correctly depends on TASK-0073 and owns grouping/recommendations.
- ADR-0003 remains accepted and does not require replacement before TASK-0073.
- The TASK-0072 product definition is a compatible implementation-level elaboration of ADR-0003.

Decision:
- **TASK-0073 is approved and complete.**
- No corrective architecture task is required first.

## Active Task Scope
`TASK-0074-ARGUS-Event-Grouping-And-Recommendations`

Codex should:
- Turn normalized ARGUS facts into coherent diagnostic groups and technician recommendations.
- Preserve deterministic evidence labels and trust boundaries.
- Consume `ARGUS/normalized-analysis.json` and preserve the deterministic evidence boundary.
- Produce `ARGUS/diagnostic-groups.json` and `ARGUS/recommendations.json`.
- Produce domain, fact, gap, and citation records defined by the TASK-0072 product definition.
- Validate against the existing latest bundle, a synthetic normal bundle, and a synthetic limited/missing-evidence bundle.

Codex must not add:
- Report styling.
- Broad AI orchestration.
- UI integration.
- HEPHAESTUS collector changes.

## Audit Counters

| Subsystem | Changes Since Last Audit | Audit Required |
|---|---:|---|
| Repository Governance | 8 / 25 | No |
| Architecture | 3 / 25 | No |
| Documentation | 22 / 25 | No |
| Task System | 3 / 25 | No |
| HEPHAESTUS | 4 / 25 | No |
| ARGUS | 5 / 25 | No |
| Reporting | 1 / 25 | No |
| UI | 21 / 25 | No |
| Plugin Framework | 1 / 25 | No |
| Build System | 14 / 25 | No |
| Validation/Test Framework | 20 / 25 | No |
| Roadmap/Backlog | 10 / 25 | No |

No subsystem is currently at the `25 / 25` audit gate.

## Known Working-Tree Drift
Do not stage or clean unless a future focused task explicitly owns it:
- Modified: `App/manifests/custom-tools.json`
- Modified locally: `docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md`
- Untracked: `App/NetworkToolkit/LatencyMon/`
- Untracked: `App/NetworkToolkit/Logs/`

The committed ADR-0003 is accepted. The local ADR difference is stale drift and is not part of TASK-0073.

## Blockers
None.

## Recommended Commit Message
```text
You are assisting with the Computer Triage Toolkit repository.

The repository is the single source of truth. Do not rely on chat history unless the same information exists in tracked repository files.

Read these files first:
1. PROJECT.md
2. docs/PROJECT-CHARTER.md
3. docs/ARCHITECTURE.md
4. docs/ROADMAP.md
5. docs/HANDOFF.md
6. docs/TASKS/QUEUE.md
7. docs/TASKS/TASK-0074-ARGUS-Event-Grouping-And-Recommendations.md
8. docs/DESIGN/ARGUS-PRODUCT-DEFINITION-AND-EVIDENCE-MAP.md
9. docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md
10. Core/Argus/ArgusFoundation.ps1
11. Core/Argus/ArgusNormalization.ps1

Current state:
- TASK-0073 is complete.
- TASK-0074 is the only Active task.
- Owner: Codex.
- Next owner: Codex.
- No subsystem is at the 25/25 audit gate.

Complete TASK-0074 only.

Scope:
- Turn normalized ARGUS facts into coherent diagnostic groups and technician recommendations.
- Consume `ARGUS/normalized-analysis.json` from TASK-0073.
- Produce `ARGUS/diagnostic-groups.json` and `ARGUS/recommendations.json`.
- Preserve deterministic evidence labels, confidence language, and citations.
- Represent missing or weak evidence explicitly.
- Validate against the existing latest bundle, a synthetic normal bundle, and a synthetic limited/problem-heavy bundle.
- Update toolkit build metadata for accepted implementation changes.
- Update the task, queue, handoff, ledger, changelog, and roadmap when complete.

Do not:
- Add report styling or UI integration.
- Add broad AI orchestration.
- Modify HEPHAESTUS collectors.
- Stage or clean known unrelated working-tree drift.
- Touch App/NetworkToolkit/LatencyMon/ or App/NetworkToolkit/Logs/.

When complete, provide:
- Commit hash.
- Exact files changed.
- Validation performed.
- Current active task.
- Current owner and next owner.
- Recommended next task.
```

## Next Bot Prompt
Copy and paste the following prompt into Codex:

```text
You are assisting with the Computer Triage Toolkit repository.

The repository is the single source of truth. Do not rely on chat history unless the same information exists in tracked repository files.

Read these files first:
1. PROJECT.md
2. docs/PROJECT-CHARTER.md
3. docs/ARCHITECTURE.md
4. docs/ROADMAP.md
5. docs/HANDOFF.md
6. docs/TASKS/QUEUE.md
7. docs/TASKS/TASK-0074-ARGUS-Event-Grouping-And-Recommendations.md
8. docs/DESIGN/ARGUS-PRODUCT-DEFINITION-AND-EVIDENCE-MAP.md
9. docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md
10. Core/Argus/ArgusFoundation.ps1
11. Core/Argus/ArgusNormalization.ps1

Current state:
- TASK-0073 is complete.
- TASK-0074 is the only Active task.
- Owner: Codex.
- Next owner: Codex.
- No subsystem is at the 25/25 audit gate.

Complete TASK-0074 only.

Scope:
- Turn normalized ARGUS facts into coherent diagnostic groups and technician recommendations.
- Consume `ARGUS/normalized-analysis.json` from TASK-0073.
- Produce `ARGUS/diagnostic-groups.json` and `ARGUS/recommendations.json`.
- Preserve deterministic evidence labels, confidence language, and citations.
- Represent missing or weak evidence explicitly.
- Validate against the existing latest bundle, a synthetic normal bundle, and a synthetic limited/problem-heavy bundle.
- Update toolkit build metadata for accepted implementation changes.
- Update the task, queue, handoff, ledger, changelog, and roadmap when complete.

Do not:
- Add report styling or UI integration.
- Add broad AI orchestration.
- Modify HEPHAESTUS collectors.
- Stage or clean known unrelated working-tree drift.
- Touch App/NetworkToolkit/LatencyMon/ or App/NetworkToolkit/Logs/.

When complete, provide:
- Commit hash.
- Exact files changed.
- Validation performed.
- Current active task.
- Current owner and next owner.
- Recommended next task.
```

