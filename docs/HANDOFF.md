# Current Handoff

## Handoff ID
HANDOFF-0085

## Current Task
TASK-0073-ARGUS-Evidence-Normalization-Implementation

## Current Owner
Codex

## Next Owner
Codex

## Objective
TASK-0082 completed the ChatGPT governance and ARGUS architecture review. No blocking findings were identified. Codex may now implement TASK-0073 using the approved ARGUS product definition and accepted ADR-0003.

## Source Of Truth
The repository is the source of truth. Chat history, screenshots, and terminal-only notes are not authoritative unless recorded in tracked repository files.

Exactly one task may be Active. `docs/HANDOFF.md` and `docs/TASKS/QUEUE.md` must agree.

## Current Project State
- TASK-0071 completed the finish-line plan.
- TASK-0072 completed the ARGUS product definition and evidence map.
- TASK-0081 completed the Task System `25 / 25` audit and reset only that counter.
- TASK-0082 completed the ChatGPT governance and architecture review.
- TASK-0073 is now the single active implementation task.
- TASK-0074 through TASK-0080 remain queued in finish-line order.

## TASK-0082 Review Decision
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
| Repository Governance | 8 / 25 | No |
| Architecture | 3 / 25 | No |
| Documentation | 21 / 25 | No |
| Task System | 2 / 25 | No |
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
TASK-0082: Complete ChatGPT governance handoff review
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
7. docs/TASKS/TASK-0073-ARGUS-Evidence-Normalization-Implementation.md
8. docs/DESIGN/ARGUS-PRODUCT-DEFINITION-AND-EVIDENCE-MAP.md
9. docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md
10. Core/Argus/ArgusFoundation.ps1

Current state:
- TASK-0082 is complete.
- ChatGPT approved TASK-0073 activation with no blocking architecture findings.
- TASK-0073 is the only Active task.
- Owner: Codex.
- No subsystem is at the 25/25 audit gate.

Complete TASK-0073 only.

Scope:
- Add ARGUS-side structured loaders for selected HEPHAESTUS outputs.
- Preserve existing ARGUS foundation outputs.
- Add ARGUS/normalized-analysis.json.
- Produce domain, fact, gap, and citation records defined in the TASK-0072 product definition.
- Preserve deterministic evidence labels and trust boundaries.
- Represent missing or weak evidence explicitly.
- Validate against the existing latest bundle, a synthetic normal bundle, and a synthetic limited/missing-evidence bundle.
- Update toolkit build metadata for accepted implementation changes.
- Update the task, queue, handoff, ledger, changelog, and roadmap when complete.

Do not:
- Add event grouping or recommendations; those belong to TASK-0074.
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
