# Current Handoff

## Handoff ID
HANDOFF-0023

## Current Task
None

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
TASK-0013 header tool search is complete. The project is ready for the next
focused task.

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
| Documentation | 2 / 10 | No |
| Task System | 2 / 10 | No |
| HEPHAESTUS | 0 / 10 | No |
| ARGUS | 0 / 10 | No |
| Reporting | 0 / 10 | No |
| UI | 1 / 10 | No |
| Plugin Framework | 0 / 10 | No |
| Build System | 0 / 10 | No |
| Validation/Test Framework | 0 / 10 | No |
| Roadmap/Backlog | 1 / 10 | No |

## Current State
The GitHub remote is configured as `https://github.com/jstultz1980-beep/ComputerTriage.git`. The local `master` branch tracks `origin/master`.

TASK-0011 completed the foundation audit. TASK-0012 completed the phase
transition readiness pass. Runtime-only custom tool manifest drift was reset,
generated third-party `.cfg` files are ignored broadly, task status wording was
normalized, stale architecture root path casing was corrected, and the roadmap
now marks Phase 00 complete with Phase 01 active.

TASK-0013 added a GUI header search box. It autocompletes tool names from the
catalog, mapped Sysinternals tools, and ready custom/toolbox apps. Selecting a
result or pressing Enter navigates to the matching tab without launching the
tool.

No implementation task is active. Create the next focused task before changing
toolkit behavior.

## Completed Work
- Read `PROJECT.md` and required startup documents.
- Created `docs/TASKS/TASK-0011-Foundation-Audit.md`.
- Updated this handoff to make TASK-0011 active.
- Completed TASK-0011 foundation audit.
- Verified GitHub remote and branch tracking.
- Reviewed required startup docs and task list.
- Compared audit counters against `docs/HISTORY/CHANGE-LEDGER.md`.
- Reset runtime-only `App/manifests/custom-tools.json` drift.
- Broadened generated third-party tool config ignore coverage.
- Normalized TASK-0009 status wording.
- Corrected stale architecture root path casing.
- Completed TASK-0012 phase-transition readiness.
- Marked Phase 00 Foundation Zero complete and Phase 01 HEPHAESTUS Collection
  Baseline active.
- Updated audit counters for TASK-0012 documentation, task system, and roadmap
  changes.
- Created TASK-0013 for header tool search.
- Completed TASK-0013 header tool search.
- Added header autocomplete search to `App/ToolKit-GUI/ToolKit-GUI.ps1`.
- Added smoke-test coverage that confirms the search box exists and resolves
  `Test-NetConnection` to the Analyze tab.

## Validation Completed
- Confirmed `master` is aligned with `origin/master` before task creation.
- Confirmed existing task list ended at TASK-0010 before creating TASK-0011.
- Ran `git status --short --branch`.
- Ran `git remote -v`.
- Ran `git log --oneline -12`.
- Reviewed `docs/TASKS/TASK-*.md` status values.
- Reviewed `docs/HISTORY/CHANGE-LEDGER.md` against handoff counters.
- Reviewed `.gitignore` generated/runtime coverage.
- Confirmed task list ended at TASK-0011 before creating TASK-0012.
- Searched live docs for phase-transition references.
- Parsed `App/ToolKit-GUI/ToolKit-GUI.ps1` with `PSParser`.
- Ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -SmokeTest`.
- Ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -ButtonSmokeTest`.

## Next Action
Create the next focused task before implementation. Recommended next task:
`TASK-0014-HEPHAESTUS-Collection-Baseline-Audit`.

## Blockers
None.

## Notes for Next AI
Start with `PROJECT.md`. If no task is active, create a task under
`docs/TASKS` and update this handoff before implementation.

Known working-tree noise:
- None expected after TASK-0013 commit.

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
6. The active task document listed in docs/HANDOFF.md.

Current task state:
- docs/HANDOFF.md lists no active implementation task.
- Audit state tracking is active.
- TASK-0011 foundation audit is complete.
- TASK-0012 phase-transition readiness is complete.
- TASK-0013 header tool search is complete.
- Create the next focused task before implementation. Recommended next task:
  TASK-0014-HEPHAESTUS-Collection-Baseline-Audit.

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
- Do not implement changes until a task file exists and docs/HANDOFF.md lists
  it as active.
- Do not use chat history as source of truth unless the same information exists in the repository.
- Do not create a separate ChatGPT task packet as source of truth.
- When a task is completed, update docs/HANDOFF.md with the next task state and a fresh Next Bot Prompt for the next bot.
```
