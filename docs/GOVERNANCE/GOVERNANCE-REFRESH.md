# Governance Refresh

## Command

`Governance Refresh`

## Purpose

Allow the user to reload governance and workflow changes during an Active Codex task without restarting the task or running the full `Resume Work` startup sequence.

## Required Behavior

When Codex receives `Governance Refresh`, it must:

1. Pause at the next safe interruption point.
2. Preserve all current implementation work and documented working-tree drift.
3. Run `git fetch --prune origin` and compare local `HEAD` with the upstream branch.
4. Safely fast-forward when local is behind and synchronization will not overwrite preserved work.
5. Re-read only:
   - `PROJECT.md`
   - `AGENTS.md`
   - `docs/CODEX-CLI-OPERATING-INSTRUCTIONS.md`
   - `docs/HANDOFF.md`
   - `docs/TASKS/QUEUE.md`
   - `docs/ERROR-HANDOFF.md`
   - files under `docs/GOVERNANCE/`
6. Apply changed governance and workflow rules immediately.
7. Re-read the Active task only when refreshed governance requires task-state or scope verification.
8. Resume the same Active task from the safe interruption point.

## Prohibited Behavior

`Governance Refresh` must not:

- restart or discard current task work;
- perform a full architecture, roadmap, ADR, or codebase reload unless refreshed governance explicitly requires it;
- change or activate a task by itself;
- clean, reset, restore, rebase, or overwrite unrelated drift;
- create a new implementation scope;
- produce a routine completion report when nothing material changed.

## Reporting

Codex reports only when refreshed governance changes execution behavior, ownership, task state, required validation, summary format, or creates a stop condition.

If synchronization is unsafe or refreshed governance irreconcilably conflicts with current work, preserve all work and use `docs/ERROR-HANDOFF.md`.
