# Current Handoff

## Handoff ID
HANDOFF-0029

## Current Task
`TASK-0017-Triage-Manual-Run-Validation`

## Current Owner
Codex

## Next Owner
Codex

## Source of Truth
The repository is the source of truth. Chat history is not authoritative unless the same information exists in tracked repository files.

Startup order remains defined by `PROJECT.md`:
1. `PROJECT.md`
2. `docs/PROJECT-CHARTER.md`
3. `docs/ARCHITECTURE.md`
4. `docs/ROADMAP.md`
5. `docs/HANDOFF.md`
6. `docs/TASKS/QUEUE.md`
7. The active task document listed here and in the queue

## Current Project State
Foundation governance has been reconciled.

`TASK-0010-Foundation-Audit` is not valid tracked task state because `TASK-0010` is already used by completed historical task `TASK-0010-Classify-Drift-And-Status-Report`. The actual tracked Foundation Audit is `TASK-0011-Foundation-Audit`, and it is completed.

`docs/TASKS/QUEUE.md` now exists and agrees with this handoff. Exactly one task is active:

```text
TASK-0017-Triage-Manual-Run-Validation
```

Phase 00 Foundation Zero is complete. Phase 01 HEPHAESTUS Collection Baseline is active. HEPHAESTUS Local Analysis Engine v1 remains approved direction but is not active implementation work.

## What Changed
- Created `docs/TASKS/QUEUE.md` as the task queue/source-of-truth companion to this handoff.
- Created `docs/TASKS/TASK-0017-Triage-Manual-Run-Validation.md` as the single active task.
- Created `docs/REVIEWS/REVIEW-0001-Foundation-Audit.md`.
- Created `docs/REVIEWS/EXECUTIVE-PROJECT-STATUS.md`.
- Updated `docs/ROADMAP.md` with the reconciled task sequence.
- Updated `docs/HISTORY/CHANGE-LEDGER.md` with audit reset entries.
- Updated this handoff with current owner, next owner, active task, counters, drift, validation, and next prompt.

No application code changed. No HEPHAESTUS collector code changed. No ARGUS implementation was added. No unrelated files were cleaned.

## Audit State Tracking
Each subsystem has its own change counter. When any subsystem reaches `10 / 10`, work must pause and a new audit task must be completed before implementation continues.

Change records are tracked in:

```text
docs/HISTORY/CHANGE-LEDGER.md
```

## Audit Counters

| Subsystem | Changes Since Last Audit | Audit Required |
|---|---:|---|
| Repository Governance | 0 / 10 | No |
| Architecture | 0 / 10 | No |
| Documentation | 0 / 10 | No |
| Task System | 0 / 10 | No |
| HEPHAESTUS | 0 / 10 | No |
| ARGUS | 0 / 10 | No |
| Reporting | 0 / 10 | No |
| UI | 4 / 10 | No |
| Plugin Framework | 1 / 10 | No |
| Build System | 0 / 10 | No |
| Validation/Test Framework | 1 / 10 | No |
| Roadmap/Backlog | 0 / 10 | No |

## Known Drift
- Historical chat/request state referenced `TASK-0010-Foundation-Audit` and an existing `docs/TASKS/QUEUE.md`. The tracked repository did not support that state. This handoff and queue now supersede that drift.
- Historical task files are preserved. Do not delete or rename them unless a future governance task explicitly allows it.
- Runtime custom-tool provenance migration can add timestamp/package metadata drift to `App/manifests/custom-tools.json` during GUI validation. Reset runtime drift before committing unless the active task explicitly changes shipped manifest state.

## Validation Performed
- Confirmed `PROJECT.md` still defines startup rules and source-of-truth behavior.
- Confirmed `docs/PROJECT-CHARTER.md`, `docs/ARCHITECTURE.md`, `docs/ROADMAP.md`, and `docs/HANDOFF.md` exist.
- Confirmed `docs/TASKS/QUEUE.md` was missing and created it.
- Confirmed `TASK-0010-Foundation-Audit.md` was not tracked.
- Confirmed `TASK-0010-Classify-Drift-And-Status-Report.md` exists and is completed.
- Confirmed `TASK-0011-Foundation-Audit.md` exists and is completed.
- Created the Foundation Audit review artifact.
- Updated queue and handoff so both identify exactly one active task.
- Updated roadmap/backlog sequence.
- Updated change ledger with audited counter resets.

Local command validation was not performed in this ChatGPT GitHub-only update.

## Active / Queued / Complete / Archived

### Active
- `TASK-0017-Triage-Manual-Run-Validation` - Owner: Codex

### Queued
- `TASK-0018-HEPHAESTUS-Local-Analysis-Engine-v1-Design` - Owner: ChatGPT
- `TASK-0019-HEPHAESTUS-Local-Analysis-Engine-v1-Implementation` - Owner: Codex, only after design is complete and activated
- `TASK-0020-ARGUS-Input-Contract-ADR` - Owner: ChatGPT

### Complete / Historical
- `TASK-0010-Classify-Drift-And-Status-Report`
- `TASK-0011-Foundation-Audit`
- `TASK-0012-Phase-Transition-Readiness`
- `TASK-0013-Header-Tool-Search`
- `TASK-0014-DHCP-Sleuth-Restoration`
- `TASK-0015-Header-Search-Tab-Mapping-Correction`
- `TASK-0016-Tool-Source-Of-Truth-Correction`

### Archived
- None during this reconciliation.

## Missing ADRs / Next ADR Work
- ADR for task queue and single-active-task source of truth.
- ADR for HEPHAESTUS deterministic local analysis responsibility boundary.
- ADR for ARGUS input contract and evidence trust model.
- ADR for normalized analysis output schema versioning.

## Next Action
Codex should complete `TASK-0017-Triage-Manual-Run-Validation` next. This is validation work only. Codex must not implement new toolkit/application work, ARGUS, HEPHAESTUS collector changes, refactoring, or unrelated cleanup during this task.

## Recommended Commit Message
```text
TASK-0010: Reconcile governance and complete Foundation Audit
```

## Next Bot Prompt
Copy and paste the following prompt into Codex. Do not create a separate task packet file.

```text
You are assisting with the Computer Triage Toolkit repository.

The repository is the single source of truth. Chat history is not authoritative unless the same information exists in tracked repository files.

Read these files in order:
1. PROJECT.md
2. docs/PROJECT-CHARTER.md
3. docs/ARCHITECTURE.md
4. docs/ROADMAP.md
5. docs/HANDOFF.md
6. docs/TASKS/QUEUE.md
7. docs/TASKS/TASK-0017-Triage-Manual-Run-Validation.md

Current task state:
- docs/HANDOFF.md and docs/TASKS/QUEUE.md list exactly one Active task.
- Active task: TASK-0017-Triage-Manual-Run-Validation.
- Owner: Codex.
- TASK-0010-Foundation-Audit is not valid tracked state. TASK-0010 is already used by completed historical task TASK-0010-Classify-Drift-And-Status-Report.
- Foundation Audit is complete as TASK-0011-Foundation-Audit and REVIEW-0001-Foundation-Audit.

Your job:
Complete TASK-0017-Triage-Manual-Run-Validation only.

Scope:
- Validate the existing toolkit workflow from the current repository state.
- Run existing startup/smoke/manual validation paths already present in the repo.
- Record validation results, defects, and runtime/generated drift.
- Update docs/TASKS/TASK-0017-Triage-Manual-Run-Validation.md with work log and completion notes.
- Update docs/TASKS/QUEUE.md and docs/HANDOFF.md so they still agree.
- Update docs/HISTORY/CHANGE-LEDGER.md only if an accepted subsystem change occurs.

Do not:
- Implement application code.
- Implement ARGUS.
- Modify HEPHAESTUS collectors.
- Refactor code.
- Clean unrelated files.
- Create a separate ChatGPT task packet file.
- Rely on chat history as source of truth.

Validation expectations:
- Verify PROJECT.md still defines startup rules.
- Verify docs/TASKS/QUEUE.md exists.
- Verify docs/HANDOFF.md and docs/TASKS/QUEUE.md agree.
- Verify exactly one task is Active.
- Run or document blockers for the existing toolkit validation commands in TASK-0017.
- Confirm no application code changed unless a new focused task is created and activated first.

When done, provide:
- Concise summary of validation performed.
- Exact files changed.
- Current active task.
- Current owner and next owner.
- Recommended commit message.
```
