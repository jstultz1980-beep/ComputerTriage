# Codex CLI Entry Point

ChatGPT is the Project Custodian and architecture/governance owner.
Codex is the Programmer and implementation agent.

The repository is the single source of truth. Chat history is not authoritative unless the same information exists in tracked repository files.

## `Resume Work`

When the user enters `Resume Work`, do all of the following without asking for a separate task prompt:

1. Read `docs/CODEX-CLI-OPERATING-INSTRUCTIONS.md` in full.
2. Follow the required startup sequence in `PROJECT.md`.
3. Verify `docs/HANDOFF.md` and `docs/TASKS/QUEUE.md` agree on exactly one Active task.
4. Read the Active task and every design/ADR/file it references.
5. Check audit counters and stop if any subsystem is at `25 / 25` unless the Active task is the required audit.
6. Preserve all documented unrelated working-tree drift.
7. Execute only the Active task.
8. Validate the work using the task’s required validation plus applicable parser, smoke, button-smoke, fixture, and artifact checks.
9. Update the task, queue, handoff, ledger, changelog, roadmap/backlog, punch list, and build metadata where required.
10. Commit locally. Push only when the user explicitly requests a push or repository rules require it.
11. Report the commit hash, files changed, validation, current Active task, current owner, next owner, and any blockers.

Do not reinterpret `Resume Work` as permission to choose unrelated work, clean drift, bypass an audit gate, or expand scope.

## Authority

- Repository state controls execution.
- ChatGPT controls architecture, governance, task activation, audit decisions, and implementation readiness through tracked repository updates.
- Codex controls implementation details inside the approved Active task, subject to repository architecture and task constraints.
- If instructions conflict, use this precedence:
  1. `PROJECT.md`
  2. `docs/HANDOFF.md` and `docs/TASKS/QUEUE.md`
  3. Active task document
  4. Referenced ADRs/design documents
  5. `docs/CODEX-CLI-OPERATING-INSTRUCTIONS.md`
  6. User’s current request
  7. Chat history

If a conflict cannot be resolved from tracked files, stop and report it to the Project Custodian. Do not invent a resolution.
