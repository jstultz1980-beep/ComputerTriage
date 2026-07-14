# Governance Refresh

## Command

`Governance Refresh`

## Purpose

Allow the user to reload governance and workflow changes during an Active Codex task without restarting the task or running the full `Resume Work` startup sequence.

## Required Behavior

When Codex receives `Governance Refresh`, it must:

1. Pause at the next safe interruption point.
2. Preserve all current implementation work and documented working-tree drift.
3. Run:

```powershell
git status --short --branch
git fetch --prune origin
git rev-parse HEAD
git rev-parse @{u}
git rev-list --left-right --count HEAD...@{u}
git merge --ff-only @{u}
git rev-parse HEAD
git rev-parse @{u}
git rev-list --left-right --count HEAD...@{u}
```

4. Confirm local `HEAD` equals `@{u}`, the final comparison is `0 0`, and the commit equals the newest Project Custodian handoff `Current HEAD`.
5. Re-read only:
   - `PROJECT.md`
   - `AGENTS.md`
   - `docs/CODEX-CLI-OPERATING-INSTRUCTIONS.md`
   - `docs/HANDOFF.md`
   - `docs/TASKS/QUEUE.md`
   - `docs/ERROR-HANDOFF.md`
   - files under `docs/GOVERNANCE/`
6. Apply changed governance and workflow rules immediately.
7. Re-read the Active task when refreshed governance changes task state, ownership, scope, or the handoff commit.
8. Verify handoff, queue, and Active task agreement.
9. Resume the same Active task from the safe interruption point only when synchronization and governance verification pass.

A fetch alone is not synchronization. If local `HEAD` remains behind upstream, Codex must not report governance as refreshed and must not resume implementation.

## Prohibited Behavior

`Governance Refresh` must not:

- restart or discard current task work;
- perform a full architecture, roadmap, ADR, or codebase reload unless refreshed governance explicitly requires it;
- change or activate a task by itself;
- clean, reset, restore, rebase, or overwrite unrelated drift;
- create a new implementation scope;
- claim `Repository State Verified: YES` unless `HEAD == @{u}`, comparison is `0 0`, and the handoff commit matches.

## Reporting

Every refresh response must include the symmetric repository-state footer required by `PROJECT.md`, including branch, full HEAD, upstream, comparison, task ownership, verification status, preserved drift, and a current Central Time timestamp.

Codex reports only when refreshed governance changes execution behavior, ownership, task state, required validation, summary format, or creates a stop condition.

If synchronization is unsafe or refreshed governance irreconcilably conflicts with current work, preserve all work and use `docs/ERROR-HANDOFF.md`.
