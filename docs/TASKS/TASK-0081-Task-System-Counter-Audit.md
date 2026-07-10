# TASK-0081 - Task System Counter Audit

## Status
Active

## Owner
Codex

## Purpose
Audit task-state consistency because the Task System counter reached the `25 / 25` gate after TASK-0072.

## Scope
- Verify `docs/HANDOFF.md` and `docs/TASKS/QUEUE.md` agree on exactly one active task.
- Verify TASK-0072 is completed and TASK-0073 remains queued behind this audit gate.
- Verify queued TASK-0073 through TASK-0080 still match the finish-line plan.
- Reconcile known task/governance drift notes, including the stale local ADR-0003 working-tree drift, without accidentally staging unrelated runtime files.
- Reset only the audited Task System counter if the audit passes.

## Out Of Scope
- ARGUS implementation.
- HEPHAESTUS changes.
- GUI changes.
- Deployment/package changes.
- Cleaning unrelated runtime logs or importing untracked tools.

## Acceptance Criteria
- [ ] Queue and handoff agree on the single active audit task.
- [ ] Completed and queued task states are internally consistent.
- [ ] Task System counter is reset only after the audit is complete.
- [ ] Known unrelated drift remains excluded or is reconciled under explicit audit scope.
