# Current Handoff

## Handoff ID
HANDOFF-0086

## Current Task
TASK-0073-ARGUS-Evidence-Normalization-Implementation

## Current Owner
Codex

## Next Owner
Codex

## Objective
Codex may implement TASK-0073 using the approved ARGUS product definition and accepted ADR-0003. The repository now contains a durable Codex CLI operating protocol: the user may enter `Resume Work`, and Codex must rebuild context from tracked repository instructions and execute only the Active task.

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

When the user enters `Resume Work`, Codex must:
1. Read `AGENTS.md` and the detailed CLI operating instructions.
2. Follow the complete startup sequence in `PROJECT.md`.
3. Verify the handoff and queue agree on exactly one Active task.
4. Check audit counters and preserve documented working-tree drift.
5. Read the Active task and all referenced design/ADR/code files.
6. Execute only the Active task.
7. Validate, update required records, commit locally, and report results.
8. Push only when explicitly requested.

`Resume Work` is not permission to clean unrelated drift, bypass an audit gate, select unrelated work, or expand task scope.

## Current Project State
- TASK-0071 completed the finish-line plan.
- TASK-0072 completed the ARGUS product definition and evidence map.
- TASK-0081 completed the Task System `25 / 25` audit and reset only that counter.
- TASK-0082 completed the ChatGPT governance and architecture review and approved TASK-0073.
- TASK-0083 added the repository-resident Codex CLI `Resume Work` protocol.
- TASK-0073 is the single active implementation task.
- TASK-0074 through TASK-0080 remain queued in finish-line order.

## TASK-0082 Review Decision
Findings:
- HEPHAESTUS and ARGUS responsibilities are correctly separated.
- HEPHAESTUS collects evidence and performs deterministic local analysis.
- ARGUS consumes deterministic/normalized outputs and produces cited explanations, grouping, and technician guidance.
- The evidence trust order, citation model, confidence language, and unsupported-inference rules are sufficient for first-release implementation.
- TASK-0073 is correctly limited to loaders and `ARGUS/normalized-analysis.json`.
- TASK-0074 correctly depends on TASK-0073 and owns grouping/recommendations.
- ADR-0003 remains accepted and does not require replacement before TASK-0073.
- The TASK-0072 product definition is a compatible implementation-level elaboration of ADR-0003.

Decision:
- **TASK-0073 is approved and active.**
- No corrective architecture task is required first.

## Active Task Scope
`TASK-0073-ARGUS-Evidence-Normalization-Implementation`

Codex should:
- Add ARGUS-side structured loaders for selected HEPHAESTUS outputs.
- Preserve deterministic evidence labels and trust boundaries.
- Preserve existing `ARGUS/input-validation.json`, `ARGUS/analysis-summary.json`, and `ARGUS/report.md`.
- Add `ARGUS/normalized-analysis.json`.
- Produce domain, fact, gap, and citation records defined by the TASK-0072 product definition.
- Validate against the existing latest bundle, a synthetic normal bundle, and a synthetic limited/missing-evidence bundle.

Codex must not add:
- Event grouping.
- Recommendation generation.
- Report styling.
- Broad AI orchestration.
- UI integration.
- HEPHAESTUS collector changes.

## Audit Counters

| Subsystem | Changes Since Last Audit | Audit Required |
|---|---:|---|
| Repository Governance | 9 / 25 | No |
| Architecture | 3 / 25 | No |
| Documentation | 22 / 25 | No |
| Task System | 3 / 25 | No |
| HEPHAESTUS | 4 / 25 | No |
| ARGUS | 4 / 25 | No |
| Reporting | 1 / 25 | No |
| UI | 21 / 25 | No |
| Plugin Framework | 1 / 25 | No |
| Build System | 13 / 25 | No |
| Validation/Test Framework | 19 / 25 | No |
| Roadmap/Backlog | 9 / 25 | No |

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
TASK-0083: Add Codex CLI Resume Work protocol
```

## Next Bot Prompt
For Codex CLI, the user may now enter:

```text
Resume Work
```

Codex must then follow `AGENTS.md`, `docs/CODEX-CLI-OPERATING-INSTRUCTIONS.md`, and the startup sequence in `PROJECT.md`.

Expanded intent for TASK-0073:

```text
Resume Work. Execute only TASK-0073-ARGUS-Evidence-Normalization-Implementation. Preserve the known working-tree drift. Do not implement TASK-0074 scope. Commit locally and do not push unless explicitly requested.
```
