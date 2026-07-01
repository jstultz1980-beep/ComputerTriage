# Current Handoff

## Handoff ID
HANDOFF-0029

## Current Task
TASK-0017-Triage-Manual-Run-Validation

## Current Owner
Codex

## Next Owner
Codex

## Governance Reconciliation Status
Foundation governance has been reconciled.

`TASK-0010-Foundation-Audit` is not valid active task state because `TASK-0010` is already used by completed historical task `TASK-0010-Classify-Drift-And-Status-Report`. The actual tracked Foundation Audit is `TASK-0011-Foundation-Audit`, and it is completed. The duplicate local `TASK-0010-Foundation-Audit.md` task file is archived for traceability.

`docs/TASKS/QUEUE.md` now exists and agrees with this handoff. Exactly one task is active:

```text
TASK-0017-Triage-Manual-Run-Validation
```

No application code changed. No HEPHAESTUS collector code changed. No ARGUS implementation was added. No unrelated files were cleaned.

## How The Handoff Process Works
This repository is the source of truth for the project. Chat history is useful context only when the same information has been written into the repository.

Another bot should not rely on memory, screenshots, or prior conversation unless those details are captured in tracked project files.

The handoff process has four core files:
- `PROJECT.md` defines the rules every bot must follow.
- `docs/HANDOFF.md` explains the current project state and contains the exact `Next Bot Prompt` to give another bot.
- `docs/TASKS/QUEUE.md` defines the official task queue and lifecycle.
- The active task file under `docs/TASKS` defines the only work that may be performed.

Work should move through this sequence:
1. Read `PROJECT.md`, the project docs, this handoff, the task queue, and the active task.
2. Perform only the work described by the active task. Do not clean up unrelated files or expand scope unless a task explicitly says to do so.
3. Validate the work using the validation steps in the task.
4. Update the active task file with completion notes and checked acceptance criteria.
5. Update `docs/TASKS/QUEUE.md` if task state changes.
6. Update this handoff with the new project state, validation results, known unrelated working-tree drift, and a fresh `Next Bot Prompt`.
7. Commit the related changes with a commit message that references the task.

The official task lifecycle is `Backlog -> Queued -> Assigned -> Active -> Validation -> Complete -> Archived`. Only one task may be `Active`.

## Objective
TASK-0017 is active. Codex should validate the existing toolkit workflow from the current repository state without adding features, refactoring code, implementing ARGUS, or modifying HEPHAESTUS collectors.

## Audit State Tracking
Each subsystem has its own change counter.

When any subsystem reaches `10 / 10` recorded subsystem changes, work must pause and a new audit task must be completed before further implementation work continues.

After the audit is completed, the audited subsystem counter resets to `0 / 10` and starts counting again from zero.

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

## Current State
The GitHub remote is configured as `https://github.com/jstultz1980-beep/ComputerTriage.git`. The local `master` branch tracks `origin/master`.

TASK-0011 completed the valid tracked Foundation Audit. REVIEW-0001 reconciled later task-state drift and reset audited governance, documentation, task-system, and roadmap/backlog counters.

TASK-0016 completed the GUI tool source-of-truth correction. Visible tab rendering and header search now read from `Get-GUIToolRegistry`, duplicate registry/search entries are checked during button smoke validation, and triage completion handling is single-shot so one completed run cannot produce repeated completion or result-read dialogs.

The accepted HEPHAESTUS Local Analysis Engine v1 work is approved direction, but it is not the active implementation task. HEPHAESTUS analysis implementation must wait until TASK-0018 design/ADR work is complete and a focused implementation task is activated.

## Active Task
`TASK-0017-Triage-Manual-Run-Validation`

Scope:
- Validate the existing startup, smoke, and manual validation paths already present.
- Confirm runtime/generated drift is classified and not committed unless required.
- Record defects and next recommended tasks.
- Do not implement new features.

## Queued Work
- `TASK-0018-HEPHAESTUS-Local-Analysis-Engine-v1-Design` owned by ChatGPT.
- `TASK-0019-HEPHAESTUS-Local-Analysis-Engine-v1-Implementation` owned by Codex, blocked until TASK-0018 is complete and activated.
- `TASK-0020-ARGUS-Input-Contract-ADR` owned by ChatGPT.

## Completed Work
- Created `docs/TASKS/QUEUE.md`.
- Created and activated `docs/TASKS/TASK-0017-Triage-Manual-Run-Validation.md`.
- Created `docs/REVIEWS/REVIEW-0001-Foundation-Audit.md`.
- Created `docs/REVIEWS/EXECUTIVE-PROJECT-STATUS.md`.
- Updated `docs/ROADMAP.md` with the validation-first and design-before-implementation sequence.
- Archived the duplicate local `docs/TASKS/TASK-0010-Foundation-Audit.md`.
- Updated `docs/HISTORY/CHANGE-LEDGER.md` with audited counter resets.
- Updated `docs/HISTORY/CHANGELOG.md`.
- Reconciled this handoff with `docs/TASKS/QUEUE.md`.

## Validation Completed
- Confirmed `PROJECT.md` still defines startup rules.
- Confirmed `docs/TASKS/QUEUE.md` exists.
- Confirmed `docs/HANDOFF.md` and `docs/TASKS/QUEUE.md` agree.
- Confirmed exactly one task is Active: `TASK-0017-Triage-Manual-Run-Validation`.
- Confirmed Foundation Audit review exists.
- Confirmed roadmap/backlog reflects the next task sequence.
- Confirmed no application code changed.
- Confirmed no HEPHAESTUS code changed.
- Confirmed no ARGUS implementation was added.
- Confirmed no unrelated files were cleaned.

## Next Action
Codex should complete `TASK-0017-Triage-Manual-Run-Validation` next. This is validation work only.

Do not implement application code.
Do not implement ARGUS.
Do not modify HEPHAESTUS collectors.
Do not refactor code.
Do not clean unrelated files.

Recommended commit message for this reconciliation:

```text
TASK-0010: Reconcile governance and complete Foundation Audit
```

## Blockers
None.

## Notes for Next AI
Known working-tree noise:
- Runtime custom-tool provenance migration can add timestamp and package metadata drift to `App/manifests/custom-tools.json` during GUI validation. Reset that runtime drift before committing unless the active task explicitly changes the shipped manifest.

## Next Bot Prompt
Copy and paste the following prompt into another bot when offloading reasoning or review work. Do not create a separate task packet file.

```text
You are assisting with the Computer Triage Toolkit repository.

The repository is the single source of truth. Chat history is not the source of truth. Do not rely on a separate ChatGPT task packet file.

Read these repository files in order:
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
- Audit state tracking is active.
- TASK-0010-Foundation-Audit is not valid active tracked state. TASK-0010 is already used by completed historical task TASK-0010-Classify-Drift-And-Status-Report.
- Foundation Audit is complete as TASK-0011-Foundation-Audit and REVIEW-0001-Foundation-Audit.
- TASK-0012 phase-transition readiness is complete.
- TASK-0013 header tool search is complete.
- TASK-0014 DHCP Sleuth restoration is complete.
- TASK-0015 header search tab mapping correction is complete.
- TASK-0016 tool source-of-truth correction is complete.

Your job:
Complete TASK-0017-Triage-Manual-Run-Validation only.

Scope:
- Validate the existing toolkit workflow from the current repository state.
- Run existing startup/smoke/manual validation paths already present in the repo.
- Record validation results, defects, and runtime/generated drift.
- Update docs/TASKS/TASK-0017-Triage-Manual-Run-Validation.md with work log and completion notes.
- Update docs/TASKS/QUEUE.md and docs/HANDOFF.md so they still agree.
- Update docs/HISTORY/CHANGE-LEDGER.md only if an accepted subsystem change occurs.

Accepted HEPHAESTUS direction:
- HEPHAESTUS should evolve from a collector-first bundle builder into a collector + deterministic local analysis platform.
- That implementation is not active yet.
- TASK-0018 should design the Local Analysis Engine before Codex implements it.

Rules:
- Treat repository files as authoritative.
- Do not implement application code during TASK-0017.
- Do not implement ARGUS.
- Do not modify HEPHAESTUS collectors.
- Do not refactor existing code.
- Do not clean unrelated files.
- Do not use chat history as source of truth unless the same information exists in the repository.
- Do not create a separate ChatGPT task packet as source of truth.
- When a task is completed, update docs/HANDOFF.md with the next task state and a fresh Next Bot Prompt for the next bot.
```
