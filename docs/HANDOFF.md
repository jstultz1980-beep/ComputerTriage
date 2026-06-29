# Current Handoff

## Handoff ID
HANDOFF-0008

## Current Task
None.

## Current Owner
Codex

## Next Owner
Codex or another bot using the prompt below.

## Objective
TASK-0004 is complete. `docs/HANDOFF.md` is now the single source of truth for
the prompt that should be given to another bot.

## Current State
The project governance now requires every completed task to update this file
with a `Next Bot Prompt` section. There should be no separate ChatGPT task
packet file used as a source of truth. If work needs to be offloaded to another
bot, copy the prompt from this handoff.

## Completed Work
- Read `PROJECT.md` and required startup documents.
- Created and completed
  `docs/TASKS/TASK-0004-Handoff-Bot-Prompt-Source-Of-Truth.md`.
- Updated `PROJECT.md` with the handoff prompt rule.
- Updated this handoff with the canonical next-bot prompt.

## Validation Completed
- Confirmed `PROJECT.md` and `docs/HANDOFF.md` contain `Next Bot Prompt`.
- Confirmed `PROJECT.md` states the repository is the single source of truth.
- Confirmed `PROJECT.md` prohibits a separate ChatGPT task packet as a source
  of truth.

## Next Action
Create a new task under `docs/TASKS` before doing any further implementation
work.

## Blockers
None.

## Notes for Next AI
Start with `PROJECT.md`. Do not implement without a new active task document.

Unrelated working-tree noise remains and was intentionally not included in
TASK-0004:
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

Rules:
- Treat repository files as authoritative.
- Do not use chat history as source of truth unless the same information exists
  in the repository.
- Do not create a separate ChatGPT task packet as source of truth.
- When a task is completed, update docs/HANDOFF.md with the next task state and
  a fresh Next Bot Prompt for the next bot.
```
