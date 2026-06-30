# TASK-0010 - Classify Drift And Status Report

## Status
Completed

## Owner
Codex

## Objective
Classify the current working-tree drift, delete files that are not needed,
commit/push files that are needed, and provide a full project status report.

## Scope
Review the two current dirty working-tree items:
- `App/manifests/custom-tools.json`
- `App/Triage/Tools/ServiWin/ServiWin.cfg`

Keep only project-needed state. Remove generated/runtime files that should not
be source controlled. Update handoff and this task. Push resulting commits to
GitHub if repository files change.

## Out of Scope
- Toolkit feature implementation.
- Broad cleanup outside the two known dirty files.
- Refactoring runtime manifests beyond classifying this drift.
- Changing GitHub repository settings.

## Files to Create or Modify
- `.gitignore`
- `docs/HANDOFF.md`
- `docs/TASKS/TASK-0010-Classify-Drift-And-Status-Report.md`
- Possibly `App/manifests/custom-tools.json`
- Possibly `App/Triage/Tools/ServiWin/ServiWin.cfg`

## Acceptance Criteria
- [x] `App/manifests/custom-tools.json` is either committed if needed or reset
      if not needed.
- [x] `App/Triage/Tools/ServiWin/ServiWin.cfg` is either committed if needed or
      deleted if generated/runtime-only.
- [x] Working tree is clean after the task.
- [x] Any needed commit is pushed to GitHub.
- [x] Handoff includes the next bot prompt.
- [x] User receives a concise full project status report.

## Validation Steps
```powershell
git status --short --branch
git log --oneline -5
git remote -v
```

## Rollback Plan
If a needed file is removed by mistake, restore it from git history if tracked
or regenerate it from the toolkit/tool that created it.

## Work Log

### Entry 001
Author: Codex
Date: 2026-06-30
Summary: Created task after user instructed Codex to delete unneeded dirty
files, push needed files, create the next task, and provide a full project
status report.
Files Changed:
- `docs/TASKS/TASK-0010-Classify-Drift-And-Status-Report.md`
Validation Performed:
- Pending.
Issues:
- Current dirty files are `App/manifests/custom-tools.json` and
  `App/Triage/Tools/ServiWin/ServiWin.cfg`.
Instructions for Next Owner:
- Classify the dirty files, clean or commit them, update handoff, push if
  needed, and report status.

## Completion Notes
Completed on 2026-06-30 by Codex.

Classification:
- `App/manifests/custom-tools.json` was runtime/toolbox state and was reset to
  the repository version. README guidance says not to commit it unless
  intentionally changing shipped toolbox state.
- `App/Triage/Tools/ServiWin/ServiWin.cfg` was generated NirSoft UI/config
  state and was deleted.
- `.gitignore` now ignores `App/Triage/Tools/ServiWin/ServiWin.cfg` so the
  generated config does not reappear as untracked source drift.

Validation performed:
- Confirmed `App/manifests/custom-tools.json` has no remaining diff.
- Confirmed `App/Triage/Tools/ServiWin/ServiWin.cfg` is absent.
- Ran `git status --short --branch`.
- Ran `git log --oneline -5`.
- Ran `git remote -v`.

Notes:
- No toolkit feature code was changed.
- A full project status report was provided to the user in the task closeout.
