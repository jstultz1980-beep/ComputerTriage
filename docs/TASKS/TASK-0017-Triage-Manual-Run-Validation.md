# TASK-0017 - Triage Manual Run Validation

## Status
Active

## Owner
Codex

## Objective
Validate the existing toolkit workflow from the current repository state without adding features or refactoring code.

## Scope
- Run the existing startup, smoke, and manual validation paths that are already present.
- Confirm the GUI launches in validation mode.
- Confirm existing button smoke coverage still passes.
- Confirm runtime/generated drift is classified and not committed unless the task explicitly requires it.
- Record defects and next recommended tasks.

## Out of Scope
- Adding application features.
- Refactoring GUI, HEPHAESTUS collectors, ARGUS, or plugin code.
- Implementing Local Analysis Engine v1.
- Cleaning unrelated files.
- Creating a separate ChatGPT task packet file.

## Files to Create or Modify
- `docs/TASKS/TASK-0017-Triage-Manual-Run-Validation.md`
- `docs/HANDOFF.md`
- `docs/TASKS/QUEUE.md`
- `docs/HISTORY/CHANGE-LEDGER.md` only if the task accepts a subsystem change
- `docs/HISTORY/CHANGELOG.md` if project history is updated

Application files should not change unless validation exposes a blocking defect and a new focused task is created before implementation.

## Acceptance Criteria
- [ ] Required startup documents are read in order.
- [ ] `docs/HANDOFF.md` and `docs/TASKS/QUEUE.md` agree that this is the only Active task.
- [ ] Existing validation commands are run or blockers are documented.
- [ ] Any runtime/generated drift is documented and excluded from unrelated commits.
- [ ] No unrelated application code is changed.
- [ ] The task file records validation results and defects.
- [ ] Handoff is updated with the next active/queued task decision and a fresh Next Bot Prompt.

## Suggested Validation Steps
```powershell
git status --short --branch
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -SmokeTest
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -ButtonSmokeTest
rg -n "Status\s*$|Active|TASK-0017|Current Task|Next Bot Prompt" docs
```

## Rollback Plan
Revert only this task's documentation updates if the validation task state was recorded incorrectly. Do not revert unrelated runtime files.

## Work Log

### Entry 001
Author: ChatGPT
Date: 2026-07-01
Summary: Created as the single active follow-on task during governance reconciliation and Foundation Audit reset.
Files Changed:
- `docs/TASKS/TASK-0017-Triage-Manual-Run-Validation.md`
Validation Performed:
- Repository files were reviewed through GitHub source-of-truth reads.
Issues:
- No local command execution was available in this ChatGPT GitHub-only update.
Instructions for Next Owner:
- Codex must validate the existing toolkit only. Do not implement new features until validation is complete and the next task is activated.
