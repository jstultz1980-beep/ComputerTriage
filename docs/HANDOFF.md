# Current Handoff

## Handoff ID
HANDOFF-0018

## Current Task
None.

## Current Owner
Codex

## Next Owner
Codex or another bot using the prompt below.

## How The Handoff Process Works
This repository is the source of truth for the project. Chat history is useful context only when the same information has been written into the repository.

Another bot should not rely on memory, screenshots, or prior conversation unless those details are captured in tracked project files.

The handoff process has three core files:
- `PROJECT.md` defines the rules every bot must follow.
- `docs/HANDOFF.md` explains the current project state and contains the exact `Next Bot Prompt` to give another bot.
- The active task file under `docs/TASKS` defines the only work that may be performed.

Work should move through this sequence:
1. Read `PROJECT.md`, the project docs, this handoff, and the active task.
2. If no active task exists, create a focused task under `docs/TASKS` and make it active in this handoff before implementation begins.
3. Perform only the work described by the active task. Do not clean up unrelated files or expand scope unless a task explicitly says to do so.
4. Validate the work using the validation steps in the task.
5. Update the task file with completion notes and checked acceptance criteria.
6. Update this handoff with the new project state, validation results, known unrelated working-tree drift, and a fresh `Next Bot Prompt`.
7. Commit the related changes with a commit message that references the task.

The `Next Bot Prompt` section is the text to copy into ChatGPT or another bot. It replaces any separate ChatGPT task packet. After every completed task, that prompt must be rewritten so the next bot starts from the repository state, not from chat history.

## Objective
TASK-0010 is complete. Runtime drift was classified and cleaned, and the generated ServiWin config is now ignored.

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
| Repository Governance | 2 / 10 | No |
| Architecture | 0 / 10 | No |
| Documentation | 2 / 10 | No |
| Task System | 1 / 10 | No |
| HEPHAESTUS | 0 / 10 | No |
| ARGUS | 0 / 10 | No |
| Reporting | 0 / 10 | No |
| UI | 0 / 10 | No |
| Plugin Framework | 0 / 10 | No |
| Build System | 0 / 10 | No |
| Validation/Test Framework | 0 / 10 | No |
| Roadmap/Backlog | 0 / 10 | No |

## Current State
The GitHub remote is configured as `https://github.com/jstultz1980-beep/ComputerTriage.git`. The local `master` branch tracks `origin/master`.

`App/manifests/custom-tools.json` was reset to the repository version because its dirty state was runtime/toolbox state. `App/Triage/Tools/ServiWin/ServiWin.cfg` was generated NirSoft UI/config state; it was deleted and added to `.gitignore`.

No implementation task is currently active.

## Completed Work
- Read `PROJECT.md` and required startup documents.
- Integrated upstream TASK-0009 audit-state tracking changes before pushing.
- Renumbered the runtime drift cleanup task to `docs/TASKS/TASK-0010-Classify-Drift-And-Status-Report.md` to avoid colliding with upstream TASK-0009.
- Reset runtime drift in `App/manifests/custom-tools.json`.
- Deleted generated `App/Triage/Tools/ServiWin/ServiWin.cfg`.
- Added `.gitignore` entry for the generated ServiWin config.
- Updated `docs/HISTORY/CHANGE-LEDGER.md` for TASK-0010.

## Validation Completed
- Confirmed `App/manifests/custom-tools.json` has no remaining diff.
- Confirmed `App/Triage/Tools/ServiWin/ServiWin.cfg` is absent.
- Ran `git status --short --branch`, `git log --oneline -5`, and `git remote -v`.
- Integrated remote `origin/master` without force pushing.

## Next Action
Create a new focused task under `docs/TASKS` before doing any further implementation work.

Recommended next task:

```text
docs/TASKS/TASK-0011-Foundation-Audit.md
```

Purpose: perform a full repository foundation audit before ARGUS implementation continues.

## Blockers
None.

## Notes for Next AI
Start with `PROJECT.md`. Do not implement without a new active task document.

Known working-tree noise:
- None expected.

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
6. The active task document listed in docs/HANDOFF.md, if one exists.

Current task state:
- docs/HANDOFF.md currently lists no active task.
- TASK-0010 is complete.
- Audit state tracking is active.
- Before implementation work begins, create or request a focused task document under docs/TASKS and make it active in docs/HANDOFF.md.
- Recommended next task: TASK-0011-Foundation-Audit.md.

Audit counter rule:
- Each subsystem has a change counter in docs/HANDOFF.md.
- Every accepted subsystem change must be recorded in docs/HISTORY/CHANGE-LEDGER.md.
- If any subsystem reaches 10 / 10 changes, a new audit is mandatory before further implementation work.
- After the audit is completed, the audited subsystem counter resets to 0 / 10.

Repository remote:
- origin is https://github.com/jstultz1980-beep/ComputerTriage.git.
- master tracks origin/master.

Rules:
- Treat repository files as authoritative.
- Do not use chat history as source of truth unless the same information exists in the repository.
- Do not create a separate ChatGPT task packet as source of truth.
- When a task is completed, update docs/HANDOFF.md with the next task state and a fresh Next Bot Prompt for the next bot.
```
