# TASK-0017 - Triage Manual Run Validation

## Status
Completed

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
- [x] Required startup documents are read in order.
- [x] `docs/HANDOFF.md` and `docs/TASKS/QUEUE.md` agree that this is the only Active task.
- [x] Existing validation commands are run or blockers are documented.
- [x] Any runtime/generated drift is documented and excluded from unrelated commits.
- [x] No unrelated application code is changed.
- [x] The task file records validation results and defects.
- [x] Handoff is updated with the next active/queued task decision and a fresh Next Bot Prompt.

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

### Entry 002
Author: Codex
Date: 2026-07-01
Summary: Ran the existing validation paths and recorded runtime drift without
changing application code.
Files Changed:
- `docs/TASKS/TASK-0017-Triage-Manual-Run-Validation.md`
- `docs/TASKS/QUEUE.md`
- `docs/HANDOFF.md`
- `docs/HISTORY/CHANGE-LEDGER.md`
- `docs/HISTORY/CHANGELOG.md`
- `docs/TASKS/TASK-0018-HEPHAESTUS-Local-Analysis-Engine-v1-Design.md`
Validation Performed:
- `git status --short --branch`
- `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -SmokeTest`
- `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -ButtonSmokeTest`
- `rg -n "Status\s*$|Active|TASK-0017|Current Task|Next Bot Prompt" docs`
- Strict active-task check across `docs/TASKS/*.md`
Issues:
- `App/manifests/custom-tools.json` was modified by validation/runtime
  provenance migration and was reset before commit.
- `App/NetworkToolkit/LatencyMon/` is an untracked local tool folder. It was not
  staged, deleted, imported, or modified because tool integration is outside
  this validation task.
- Full interactive GUI/manual technician workflow was not exercised beyond the
  repository's existing smoke and button-smoke validation modes.
Instructions for Next Owner:
- ChatGPT should complete TASK-0018 design/ADR work before Codex implements
  HEPHAESTUS Local Analysis Engine v1.

## Completion Notes
Existing validation paths passed. No application-code defect was fixed in this
task. The next active task is TASK-0018, owned by ChatGPT, to design the
HEPHAESTUS Local Analysis Engine v1 before implementation.
