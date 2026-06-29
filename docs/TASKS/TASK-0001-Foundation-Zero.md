# TASK-0001 - Foundation Zero

## Status
Assigned

## Owner
Codex

## Objective
Create the repository-tracked control documents that allow ChatGPT and Codex to coordinate by reading `PROJECT.md` and `docs/HANDOFF.md`.

## Scope
Create or update only project governance and tracking documentation.

Do not implement ARGUS code in this task.

## Files to Create or Update
- `PROJECT.md`
- `docs/PROJECT-CHARTER.md`
- `docs/ARCHITECTURE.md`
- `docs/ROADMAP.md`
- `docs/BACKLOG.md`
- `docs/HANDOFF.md`
- `docs/TASKS/TASK-0001-Foundation-Zero.md`
- `docs/DECISIONS/ADR-0001-Repository-Is-Source-Of-Truth.md`
- `docs/DECISIONS/ADR-0002-No-Patch-Stacking.md`
- `docs/DECISIONS/ADR-0003-ARGUS-Is-Core-Engine.md`
- `docs/TEMPLATES/TaskTemplate.md`
- `docs/TEMPLATES/ADRTemplate.md`
- `docs/TEMPLATES/ReviewTemplate.md`
- `docs/HISTORY/CHANGELOG.md`

## Acceptance Criteria
- [ ] `PROJECT.md` exists.
- [ ] `docs/HANDOFF.md` identifies active task and next owner.
- [ ] Templates exist.
- [ ] Initial ADRs exist.
- [ ] Task completion notes are updated before commit.
- [ ] Commit message references `TASK-0001`.

## Validation Steps
```powershell
Test-Path .\PROJECT.md
Test-Path .\docs\HANDOFF.md
Test-Path .\docs\TASKS\TASK-0001-Foundation-Zero.md
Test-Path .\docs\DECISIONS\ADR-0001-Repository-Is-Source-Of-Truth.md
Test-Path .\docs\DECISIONS\ADR-0002-No-Patch-Stacking.md
Test-Path .\docs\DECISIONS\ADR-0003-ARGUS-Is-Core-Engine.md
Test-Path .\docs\TEMPLATES\TaskTemplate.md
Test-Path .\docs\TEMPLATES\ADRTemplate.md
Test-Path .\docs\TEMPLATES\ReviewTemplate.md
```

## Work Log

### Entry 001
Author: ChatGPT
Date: 2026-06-29
Summary: Defined Foundation Zero structure, handoff protocol, and initial documentation set.
Instructions for Codex: Apply or verify these files, update this task with completion notes, update `docs/HANDOFF.md`, then commit.

## Completion Notes
Codex must append completion notes here.
