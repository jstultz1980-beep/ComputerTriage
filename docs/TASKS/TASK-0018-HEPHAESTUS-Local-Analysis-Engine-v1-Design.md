# TASK-0018 - HEPHAESTUS Local Analysis Engine v1 Design

## Status
Active

## Owner
ChatGPT

## Next Owner
Codex

## Objective
Design HEPHAESTUS Local Analysis Engine v1 before implementation begins.

## Scope
- Define the deterministic local analysis pipeline from collected evidence to
  normalized JSON, findings, timeline, evidence score, and local HTML summary.
- Define rule-engine responsibilities, initial rule set, severity/confidence
  model, and parser failure behavior.
- Define output schemas and bundle metadata/versioning expectations.
- Define how portable tools may be detected and used without requiring internet
  access or failing collection when absent.
- Identify ADRs required before implementation.
- Produce follow-on implementation tasks for Codex.

## Out of Scope
- Implementing HEPHAESTUS analysis code.
- Implementing ARGUS.
- Modifying application code.
- Modifying HEPHAESTUS collectors.
- Downloading or installing tools.
- Refactoring existing code.

## Deliverables
- Design document for HEPHAESTUS Local Analysis Engine v1.
- ADRs or ADR task list for:
  - HEPHAESTUS deterministic local analysis responsibility boundary.
  - Normalized output schema/versioning.
  - ARGUS input contract and evidence trust model.
- Updated `docs/ROADMAP.md` or explicit confirmation that it remains current.
- Follow-on Codex implementation task(s) with clear scope and validation steps.
- Updated `docs/HANDOFF.md` and `docs/TASKS/QUEUE.md`.

## Acceptance Criteria
- [ ] Design document exists.
- [ ] Required ADRs are created or listed as explicit follow-on tasks.
- [ ] Implementation tasks are small enough for Codex to execute safely.
- [ ] No application code is modified.
- [ ] ARGUS is not implemented.
- [ ] HEPHAESTUS collectors are not modified.
- [ ] Handoff and queue identify the next owner and next task.

## Validation Steps
```powershell
git status --short
Test-Path C:\Computer_Toolkit\docs\HANDOFF.md
Test-Path C:\Computer_Toolkit\docs\TASKS\QUEUE.md
Select-String -Path C:\Computer_Toolkit\docs\HANDOFF.md -Pattern "Current Task","Current Owner","Next Owner","Next Bot Prompt"
```

## Rollback Plan
Revert the design, ADR, task, queue, and handoff documentation changes created
by this task.

## Work Log

### Entry 001
Author: Codex
Date: 2026-07-01
Summary: Created and activated this ChatGPT-owned design task after completing
TASK-0017 validation.
Files Changed:
- `docs/TASKS/TASK-0018-HEPHAESTUS-Local-Analysis-Engine-v1-Design.md`
Validation Performed:
- Confirmed TASK-0017 validation passed before activation.
Issues:
- None.
Instructions for Next Owner:
- ChatGPT should produce design/ADR output only. Codex should not implement
  HEPHAESTUS Local Analysis Engine v1 until a focused implementation task is
  created and activated.
