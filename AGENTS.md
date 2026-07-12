# Codex CLI Entry Point

ChatGPT is the Project Custodian and architecture/governance owner.
Codex is the Programmer and implementation agent.

The repository is the single source of truth. Chat history is not authoritative unless the same information exists in tracked repository files.

## `Resume Work`

When the user enters `Resume Work`, do all of the following without asking for a separate task prompt:

1. Read `docs/CODEX-CLI-OPERATING-INSTRUCTIONS.md` in full.
2. Verify the local checkout is on the intended branch and has a valid `origin` remote.
3. Run `git fetch --prune origin` before trusting any local governance or task state.
4. Compare local `HEAD`, the upstream tracking branch, and `origin/<branch>` using `git status --short --branch`, `git rev-parse HEAD`, `git rev-parse @{u}`, and `git rev-list --left-right --count HEAD...@{u}`.
5. If local is behind and the update is a safe fast-forward, synchronize without overwriting documented drift. If local is ahead, diverged, has no upstream, fetch fails, or synchronization would overwrite work, stop before implementation and use the Error Handoff Procedure.
6. Re-run the comparison and confirm the local checkout matches the authoritative remote branch before reading the Active task. Record the synchronized commit hash in the work log or completion report.
7. Follow the required startup sequence in `PROJECT.md` using the synchronized checkout.
8. Verify `docs/HANDOFF.md` and `docs/TASKS/QUEUE.md` agree on exactly one Active task.
9. Read the Active task and every design/ADR/file it references.
10. Check audit counters. A counter at `25 / 25` blocks the next implementation task, but does not interrupt an Active task already underway.
11. Preserve all documented unrelated working-tree drift.
12. Execute the Active task autonomously within its approved scope.
13. Validate the work using the task’s required validation plus applicable parser, smoke, button-smoke, fixture, and artifact checks.
14. Correct in-scope defects found during implementation or validation without asking for separate permission.
15. Update the task, queue, handoff, ledger, changelog, roadmap/backlog, punch list, and build metadata where required.
16. Commit locally. Push only when the user explicitly requests a push or repository rules require it.
17. Report the synchronized starting commit, resulting commit hash, files changed, validation, current Active task, current owner, next owner, and any blockers.

Do not reinterpret `Resume Work` as permission to choose unrelated work, clean drift, bypass an audit gate, expand scope, or implement from a stale checkout.

## Autonomous Execution Rule

Codex is expected to complete the Active task without asking for permission at every implementation step.

Within the approved Active task, Codex may autonomously:
- Read, create, edit, move, or delete files owned by the task when required by the task and architecture.
- Choose implementation details consistent with repository patterns and ADRs.
- Run commands, tests, fixtures, parser checks, smoke tests, and targeted validation.
- Correct defects caused by or discovered within the task scope.
- Update required task, handoff, queue, history, roadmap, punch-list, and build-metadata files.
- Create the focused local commit required by the task.

Codex must not ask the user or ChatGPT to approve routine edits, command execution, test runs, in-scope defect corrections, documentation updates, or the local task commit.

Ask before proceeding only when:
- The action is destructive outside the Active task’s owned files or data.
- The action would overwrite undocumented user work or unrelated drift.
- The task requires credentials, secrets, licensing acceptance, purchasing, external account changes, or physical/user-only action.
- A material architecture choice is not resolved by tracked files and different choices would significantly change the product.
- The work requires expanding scope into another subsystem or task.
- The user must choose between materially different product behaviors.
- A push, release, deployment, publication, or other externally visible action is required and has not already been explicitly authorized.
- A genuine safety, security, data-loss, or repository-corruption risk exists.

When a reasonable in-scope assumption is needed, make the safest repository-consistent assumption, record it in the task work log, and continue.

## Non-Interruption Guardrail

Read and follow `docs/GOVERNANCE/NON-INTERRUPTION-GUARDRAIL.md`.

Once Codex begins an Active task, ChatGPT must not displace it, insert a new design/audit gate into the middle of it, rewrite its scope, or change its owner merely because the user submits a new request through ChatGPT.

New requests may be recorded for later reconciliation, but the current Active task continues to its normal completion or blocker boundary. If an audit counter reaches `25 / 25` during the task, finish and validate the current task first; the audit becomes the next Active task before further implementation begins.

Only the user’s explicit cancellation/pause, a material safety or security risk, repository corruption, or a genuine blocker in the Active task may stop work immediately.

## Blocked-Error Handoff

Read and follow `docs/ERROR-HANDOFF.md`.

If Codex reaches a genuine blocker or stop condition:
- Do not leave the blocker only in terminal output or chat.
- Write a complete blocker report to `docs/ERROR-HANDOFF.md`.
- Commit the report and push that blocker-report commit to the cloud repository. This limited push is authorized even when normal task commits are local-only.
- Preserve unrelated drift and incomplete implementation work.
- Tell the user the blocker is recorded and pushed, then wait for the Project Custodian.

When the user tells ChatGPT `Address Errors`, the Project Custodian reads the cloud error handoff, remediates the tracked conflict, commits and pushes the resolution, and returns control to Codex through `Resume Work`.

## Authority

- Repository state controls execution.
- ChatGPT controls architecture, governance, task activation, audit decisions, and implementation readiness through tracked repository updates at task boundaries.
- Codex controls implementation details and uninterrupted autonomous execution inside the approved Active task, subject to repository architecture and task constraints.
- If instructions conflict, use this precedence:
  1. `PROJECT.md`
  2. `docs/HANDOFF.md` and `docs/TASKS/QUEUE.md`
  3. Active task document
  4. Referenced ADRs/design documents
  5. `docs/CODEX-CLI-OPERATING-INSTRUCTIONS.md`
  6. User’s current request
  7. Chat history

If a conflict cannot be resolved from tracked files, stop and report it through `docs/ERROR-HANDOFF.md`. Do not invent a resolution.