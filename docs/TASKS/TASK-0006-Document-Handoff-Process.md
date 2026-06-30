# TASK-0006 - Document Handoff Process

## Status
Completed

## Owner
Codex

## Objective
Add a clear explanation of the project handoff process to `docs/HANDOFF.md` so
ChatGPT or another bot can read it and understand how work is coordinated.

## Scope
Document how the handoff file, active task file, source-of-truth rule, next bot
prompt, validation, and commits fit together.

## Out of Scope
- Changing toolkit runtime code.
- Pushing to GitHub.
- Creating a separate ChatGPT packet.
- Cleaning unrelated working-tree drift.

## Files to Create or Modify
- `docs/HANDOFF.md`
- `docs/TASKS/TASK-0006-Document-Handoff-Process.md`

## Acceptance Criteria
- [x] `docs/HANDOFF.md` explains the handoff process in plain language.
- [x] The explanation tells ChatGPT to use repository files instead of chat
      history.
- [x] The explanation describes how active tasks are created, performed,
      validated, completed, and handed off.
- [x] The explanation states that `Next Bot Prompt` is the text to give another
      bot.
- [x] Task completion notes are updated.

## Validation Steps
```powershell
Select-String -Path C:\Computer_Toolkit\docs\HANDOFF.md `
  -Pattern 'How The Handoff Process Works','Next Bot Prompt','active task','source of truth'
```

## Rollback Plan
Revert the handoff and task document changes.

## Work Log

### Entry 001
Author: Codex
Date: 2026-06-30
Summary: Created task after user requested a handoff-process explanation
inside `docs/HANDOFF.md`.
Files Changed:
- `docs/TASKS/TASK-0006-Document-Handoff-Process.md`
Validation Performed:
- Pending.
Issues:
- Existing unrelated working-tree drift remains outside this task:
  `App/manifests/custom-tools.json` and
  `App/Triage/Tools/ServiWin/ServiWin.cfg`.
Instructions for Next Owner:
- Update `docs/HANDOFF.md` only for process explanation, then complete this
  task and commit docs.

## Completion Notes
Completed on 2026-06-30 by Codex.

Changes:
- Added `How The Handoff Process Works` to `docs/HANDOFF.md`.
- Explained the relationship between `PROJECT.md`, `docs/HANDOFF.md`, and the
  active task document.
- Documented the task lifecycle from reading source-of-truth files through
  validation, handoff update, and commit.
- Clarified that `Next Bot Prompt` is the text to copy into ChatGPT or another
  bot and replaces any separate ChatGPT task packet.

Validation performed:
- Ran the documented `Select-String` validation against `docs/HANDOFF.md`.

Notes:
- No runtime toolkit files were changed.
- Unrelated working-tree drift remains outside this task:
  `App/manifests/custom-tools.json` and
  `App/Triage/Tools/ServiWin/ServiWin.cfg`.
