# TASK-0004 - Handoff Bot Prompt Source Of Truth

## Status
Completed

## Owner
Codex

## Objective
Make `docs/HANDOFF.md` the single source of truth for the prompt that should be
fed to another bot for every next task.

## Scope
Update project governance so there is no separate ChatGPT task packet. The
handoff must include a reusable prompt section that tells another bot what to
read, what rules to follow, and what task to perform next. When a task is
completed, the next-task prompt must be written directly into
`docs/HANDOFF.md`.

## Out of Scope
- Building a GUI export button for ChatGPT packets.
- Creating separate AI packet files.
- Changing diagnostic bundle behavior.
- Modifying toolkit runtime features.
- Cleaning unrelated working-tree changes.

## Files to Create or Modify
- `PROJECT.md`
- `docs/HANDOFF.md`
- `docs/TASKS/TASK-0004-Handoff-Bot-Prompt-Source-Of-Truth.md`

## Acceptance Criteria
- [x] Project rules explicitly state that `docs/HANDOFF.md` contains the
      prompt for the next bot.
- [x] Project rules explicitly prohibit separate ChatGPT task packet files as a
      source of truth.
- [x] `docs/HANDOFF.md` includes a clearly labeled prompt section for the next
      bot.
- [x] The prompt directs the next bot to read repository source-of-truth files,
      not chat history.
- [x] The task document and handoff are updated after validation.

## Validation Steps
```powershell
Select-String -Path C:\computer_toolkit\PROJECT.md,C:\computer_toolkit\docs\HANDOFF.md `
  -Pattern 'Next Bot Prompt','single source of truth','separate ChatGPT task packet'
```

## Rollback Plan
Revert the governance text changes in `PROJECT.md`, `docs/HANDOFF.md`, and this
task document.

## Work Log

### Entry 001
Author: Codex
Date: 2026-06-29
Summary: Created task after user clarified that `docs/HANDOFF.md` must contain
the prompt for any other bot and that no separate ChatGPT task packet should be
used.
Files Changed:
- `docs/TASKS/TASK-0004-Handoff-Bot-Prompt-Source-Of-Truth.md`
Validation Performed:
- Pending.
Issues:
- Existing unrelated working-tree drift remains outside this task:
  `App/manifests/custom-tools.json` and
  `App/Triage/Tools/ServiWin/ServiWin.cfg`.
Instructions for Next Owner:
- Update governance and handoff only.

## Completion Notes
Completed on 2026-06-29 by Codex.

Changes:
- Added a `Handoff Prompt Rule` to `PROJECT.md`.
- Required every completed task to update `docs/HANDOFF.md` with the next
  `Next Bot Prompt`.
- Explicitly prohibited separate ChatGPT task packet files as a source of
  truth.
- Updated `docs/HANDOFF.md` with a canonical prompt for the next bot.

Validation performed:
- Ran the documented `Select-String` validation against `PROJECT.md` and
  `docs/HANDOFF.md`.

Notes:
- No runtime toolkit files were changed.
- Unrelated working-tree drift remains outside this task:
  `App/manifests/custom-tools.json` and
  `App/Triage/Tools/ServiWin/ServiWin.cfg`.
