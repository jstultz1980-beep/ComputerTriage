# Current Handoff

## Handoff ID
HANDOFF-0016

## Current Task
None.

## Current Owner
Codex

## Next Owner
Codex or another bot using the prompt below.

## How The Handoff Process Works
This repository is the source of truth for the project. Chat history is useful
context only when the same information has been written into the repository.
Another bot should not rely on memory, screenshots, or prior conversation
unless those details are captured in tracked project files.

The handoff process has three core files:
- `PROJECT.md` defines the rules every bot must follow.
- `docs/HANDOFF.md` explains the current project state and contains the exact
  `Next Bot Prompt` to give another bot.
- The active task file under `docs/TASKS` defines the only work that may be
  performed.

Work should move through this sequence:
1. Read `PROJECT.md`, the project docs, this handoff, and the active task.
2. If no active task exists, create a focused task under `docs/TASKS` and make
   it active in this handoff before implementation begins.
3. Perform only the work described by the active task. Do not clean up unrelated
   files or expand scope unless a task explicitly says to do so.
4. Validate the work using the validation steps in the task.
5. Update the task file with completion notes and checked acceptance criteria.
6. Update this handoff with the new project state, validation results, known
   unrelated working-tree drift, and a fresh `Next Bot Prompt`.
7. Commit the related changes with a commit message that references the task.

The `Next Bot Prompt` section is the text to copy into ChatGPT or another bot.
It replaces any separate ChatGPT task packet. After every completed task, that
prompt must be rewritten so the next bot starts from the repository state, not
from chat history.

## Objective
TASK-0008 is complete. The local `master` branch has been pushed to GitHub and
tracks `origin/master`.

## Current State
The GitHub remote is configured as
`https://github.com/jstultz1980-beep/ComputerTriage.git`. The local `master`
branch tracks `origin/master`.

## Completed Work
- Read `PROJECT.md` and required startup documents.
- Created and completed `docs/TASKS/TASK-0008-Push-To-GitHub.md`.
- Confirmed `origin` points to the requested GitHub repository.
- Pushed `master` to `origin/master`.
- Set upstream tracking for `master`.

## Validation Completed
- `git remote -v` showed `origin` for fetch and push.
- `git push -u origin master` succeeded.
- Push output confirmed `master -> master` and upstream tracking was set.

## Next Action
Create a new task under `docs/TASKS` before doing any further implementation
work.

## Blockers
None.

## Notes for Next AI
Start with `PROJECT.md`. Do not implement without a new active task document.

Unrelated working-tree noise remains and was intentionally not included in
TASK-0008:
- `App/manifests/custom-tools.json` modified
- `App/Triage/Tools/ServiWin/ServiWin.cfg` untracked

## Next Bot Prompt
Copy and paste the following prompt into another bot when offloading reasoning
or review work. Do not create a separate task packet file.

```text
You are assisting with the Computer Triage Toolkit repository.

The repository is the single source of truth. Chat history is not the source of
truth. Do not rely on a separate ChatGPT task packet file.

Read these repository files in order:
1. PROJECT.md
2. docs/PROJECT-CHARTER.md
3. docs/ARCHITECTURE.md
4. docs/ROADMAP.md
5. docs/HANDOFF.md
6. The active task document listed in docs/HANDOFF.md, if one exists.

Current task state:
- docs/HANDOFF.md currently lists no active task.
- Before implementation work begins, create or request a focused task document
  under docs/TASKS and make it active in docs/HANDOFF.md.
- Keep all recommendations and changes scoped to that active task.

Repository remote:
- origin is https://github.com/jstultz1980-beep/ComputerTriage.git.
- master tracks origin/master.

Rules:
- Treat repository files as authoritative.
- Do not use chat history as source of truth unless the same information exists
  in the repository.
- Do not create a separate ChatGPT task packet as source of truth.
- When a task is completed, update docs/HANDOFF.md with the next task state and
  a fresh Next Bot Prompt for the next bot.
```
