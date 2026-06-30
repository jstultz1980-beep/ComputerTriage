# Current Handoff

## Handoff ID
HANDOFF-0019

## Current Task
`docs/TASKS/TASK-0011-Foundation-Audit.md`

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
TASK-0011 is active. Perform a full repository foundation audit before
additional feature implementation continues.

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

TASK-0011 should audit repository foundation, task flow, handoff accuracy,
audit counters, generated/runtime drift, GitHub sync, and readiness for the
next implementation task.

## Completed Work
- Read `PROJECT.md` and required startup documents.
- Created `docs/TASKS/TASK-0011-Foundation-Audit.md`.
- Updated this handoff to make TASK-0011 active.

## Validation Completed
- Confirmed `master` is aligned with `origin/master` before task creation.
- Confirmed existing task list ended at TASK-0010 before creating TASK-0011.

## Next Action
Complete `docs/TASKS/TASK-0011-Foundation-Audit.md`.

## Blockers
None for TASK-0011.

## Notes for Next AI
Start with `PROJECT.md`. Keep scope limited to TASK-0011.

Known working-tree noise:
- `App/manifests/custom-tools.json` modified
- `App/Triage/Tools/AppCrashView/AppCrashView.cfg` untracked
- `App/Triage/Tools/CurrPorts/cports.cfg` untracked
- `App/Triage/Tools/DriverView/DriverView.cfg` untracked
- `App/Triage/Tools/EventLogChannelsView/EventLogChannelsView.cfg` untracked
- `App/Triage/Tools/FullEventLogView/FullEventLogView.cfg` untracked
- `App/Triage/Tools/NetworkInterfacesView/NetworkInterfacesView.cfg` untracked
- `App/Triage/Tools/USBDeview/USBDeview.cfg` untracked

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
- docs/HANDOFF.md lists TASK-0011 as active.
- Audit state tracking is active.
- Complete TASK-0011 before additional feature implementation.

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
- Keep changes scoped to TASK-0011.
- Do not use chat history as source of truth unless the same information exists in the repository.
- Do not create a separate ChatGPT task packet as source of truth.
- When a task is completed, update docs/HANDOFF.md with the next task state and a fresh Next Bot Prompt for the next bot.
```
