# TASK-0083 - Codex CLI Resume Work Protocol

## Status
Completed

## Owner
ChatGPT

## Purpose
Create repository-resident operating instructions for Codex CLI so the user can enter `Resume Work` and have Codex rebuild context from the repository, follow the active task, preserve governance, and execute only the work directed by the Project Custodian.

## Scope
- Add a root `AGENTS.md` as the concise Codex CLI entry point.
- Add `docs/CODEX-CLI-OPERATING-INSTRUCTIONS.md` with the complete operating protocol.
- Add a `Resume Work` shortcut rule to `PROJECT.md`.
- Record ChatGPT as Project Custodian and Codex as Programmer/implementation agent.
- Preserve TASK-0073 as the next active implementation task.
- Update handoff, queue/history, audit counters, changelog, and ledger.

## Out Of Scope
- ARGUS implementation.
- HEPHAESTUS changes.
- GUI changes.
- Cleaning known working-tree drift.
- Changing the current TASK-0073 implementation scope.

## Acceptance Criteria
- [x] Root `AGENTS.md` exists.
- [x] Detailed Codex CLI operating instructions exist.
- [x] `PROJECT.md` defines the `Resume Work` shortcut.
- [x] Instructions require repository-first context loading.
- [x] Instructions enforce one active task and audit gates.
- [x] Instructions preserve known unrelated drift.
- [x] TASK-0073 remains the active task after this governance update.
- [x] Handoff and queue agree.

## Validation
- Confirmed no implementation files were changed.
- Confirmed the final active task remains `TASK-0073-ARGUS-Evidence-Normalization-Implementation`.
- Confirmed no subsystem counter reaches `25 / 25`.

## Completion Notes
The repository now contains a durable Codex CLI operating contract. The user may enter `Resume Work`; Codex must read `AGENTS.md`, follow the repository startup sequence, execute only the active task, validate, update governance records, and stop at blockers or audit gates.
