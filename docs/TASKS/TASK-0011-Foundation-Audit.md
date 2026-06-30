# TASK-0011 - Foundation Audit

## Status
Assigned

## Owner
Codex

## Objective
Perform a full repository foundation audit before additional feature
implementation continues.

## Scope
Audit the project foundation, source-of-truth documents, task workflow, handoff
process, audit counters, GitHub synchronization, ignored/generated files,
runtime drift, and readiness for the next implementation task.

The audit should verify:
- Repository state and remote tracking.
- Required startup documents.
- Handoff process and `Next Bot Prompt`.
- Task numbering and task completion consistency.
- Audit counter accuracy and change ledger consistency.
- `.gitignore` coverage for generated/runtime files.
- Known runtime drift, including current custom tool manifest changes and
  generated third-party tool config files.
- Whether any source files, docs, or task records are stale or contradictory.

## Out of Scope
- Adding new toolkit features.
- Refactoring GUI or runtime scripts.
- Cleaning or deleting runtime drift without documenting the audit finding and
  recommended action.
- Implementing ARGUS.
- Changing GitHub repository settings.

## Files to Create or Modify
- `docs/HANDOFF.md`
- `docs/TASKS/TASK-0011-Foundation-Audit.md`
- `docs/HISTORY/CHANGE-LEDGER.md`
- Possibly `docs/HISTORY/CHANGELOG.md`
- Possibly `.gitignore`
- Possibly other documentation files if the audit finds stale governance text.

## Acceptance Criteria
- [ ] Repository status and GitHub tracking are verified.
- [ ] Required startup documents are present and internally consistent.
- [ ] `docs/HANDOFF.md` accurately describes the current state and next bot
      prompt.
- [ ] Task list is reviewed for numbering collisions, stale statuses, and
      incomplete completion notes.
- [ ] Audit counters in `docs/HANDOFF.md` are compared against
      `docs/HISTORY/CHANGE-LEDGER.md`.
- [ ] Runtime/generated drift is classified with specific recommendations.
- [ ] `.gitignore` recommendations are documented or applied if clearly safe.
- [ ] Audit findings are recorded in completion notes.
- [ ] Handoff is updated with post-audit state and next recommended task.

## Validation Steps
```powershell
git status --short --branch
git remote -v
git log --oneline -12
Get-ChildItem C:\Computer_Toolkit\docs\TASKS -Filter 'TASK-*.md' |
  Sort-Object Name |
  Select-Object -ExpandProperty Name
Select-String -Path C:\Computer_Toolkit\docs\HANDOFF.md `
  -Pattern 'Audit Counters','Next Bot Prompt','Current Task'
```

## Rollback Plan
Revert audit documentation changes if they misrepresent repository state. Do
not revert unrelated runtime files unless the audit task explicitly classifies
them and records the action.

## Work Log

### Entry 001
Author: Codex
Date: 2026-06-30
Summary: Created task after user requested `TASK-0011-Foundation-Audit`.
Files Changed:
- `docs/TASKS/TASK-0011-Foundation-Audit.md`
Validation Performed:
- Confirmed `master` is aligned with `origin/master`.
- Confirmed current task list ends at `TASK-0010` before creating this task.
Issues:
- Current runtime drift exists and should be classified during the audit:
  `App/manifests/custom-tools.json` and generated config files under
  `App/Triage/Tools/*/*.cfg`.
Instructions for Next Owner:
- Complete the foundation audit before additional feature implementation.

## Completion Notes
Append completion notes here.
