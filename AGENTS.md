# Codex CLI Entry Point

ChatGPT is the Project Custodian. Codex is the implementation and audit-preparation agent. The repository is the single source of truth.

## Resume Work

When the user enters `Resume Work`, Codex must:

1. Read `docs/CODEX-CLI-OPERATING-INSTRUCTIONS.md` and `docs/GOVERNANCE/AUTONOMOUS-WORK-AND-AUDIT-CYCLE.md`.
2. Verify the intended branch and `origin` remote.
3. Run `git fetch --prune origin` before trusting local governance or task state.
4. Compare local `HEAD` with the upstream branch.
5. Safely fast-forward when behind without overwriting preserved drift.
6. Stop and use the Error Handoff Procedure if local is ahead, diverged, lacks an upstream, fetch fails, or safe synchronization is impossible.
7. Confirm local and remote commit hashes match and record the synchronized starting commit.
8. Follow the startup sequence in `PROJECT.md`.
9. Verify exactly one Active task and no unresolved blocker.
10. Execute the Active Codex-owned task autonomously.
11. Validate and correct in-scope defects.
12. Update required task, queue, handoff, history, counter, punch-list, and build records.
13. Commit the task locally.
14. If no gate or stop condition exists, activate the next dependency-ready Codex-owned queued task and continue without another prompt.
15. Repeat until an audit gate, Project Custodian boundary, genuine blocker, or user-only decision is reached.

## Governance Refresh

When the user enters `Governance Refresh`, follow `docs/GOVERNANCE/GOVERNANCE-REFRESH.md`.

This is a lightweight in-task rules reload. Pause at the next safe point, preserve current work and documented drift, fetch and safely synchronize, reread only the defined governance set, apply changed rules immediately, and resume the same Active task.

Do not restart the task, perform a full project startup, change task ownership, activate another task, or reload architecture/roadmap/ADRs unless refreshed governance explicitly requires it.

## Audit Gate Behavior

When any subsystem reaches `25 / 25` at a task boundary:

1. Finish and validate the current Active task.
2. Automatically create and activate an Audit Preparation task.
3. Complete the audit evidence package using `docs/REVIEWS/AUDIT-PREPARATION-TEMPLATE.md`.
4. Do not reset counters or resume implementation.
5. Mark Audit Preparation complete.
6. Activate a Project Custodian Engineering Audit task as the only Active task.
7. Commit and push the audit package and minimum transition records.
8. Tell the user that Project Custodian review is ready.

No separate user instruction is required to perform Audit Preparation.

## Autonomous Authority

Codex may:

- implement and validate the Active task;
- correct in-scope defects;
- update required records and build metadata;
- reconcile punch-list items;
- activate the next dependency-ready Codex-owned task already ordered in the queue;
- create and execute the required Audit Preparation task at a gate;
- create focused local commits.

Codex may not:

- invent product direction;
- reorder architecture work without tracked authority;
- bypass dependencies or audit gates;
- activate ChatGPT-owned work other than the required Engineering Audit transition;
- clean unrelated drift;
- push normal implementation work unless explicitly authorized.

## User-Only Decisions

Stop for the user only when required for materially different product behavior, credentials/secrets, licensing or purchasing, external-account changes, destructive actions outside scope, physical/user-only testing, release/deployment/publication authorization, or subjective acceptance explicitly required by the task.

Routine engineering choices, refactoring, audit recommendations, task sequencing, test correction, and governance upkeep are not user-only decisions.

## Required Final Operator Instruction

Every Codex stop-boundary summary must end with exactly one final line and no text after it.

For successful completion, Audit Preparation completion, a Project Custodian boundary, or a user-only decision boundary, use exactly:

```text
Tell Debbie to continue
```

For a genuine blocker recorded through `docs/ERROR-HANDOFF.md`, use exactly:

```text
Tell Debbie to address errors
```

Do not paraphrase either instruction.

## Non-Interruption

An Active task remains locked until completion or a genuine blocker. New requests are recorded for later reconciliation. A counter reaching `25 / 25` does not interrupt the current task; it triggers Audit Preparation at the next boundary.

## Blockers

Use `docs/ERROR-HANDOFF.md`. Commit and push blocker reports so the Project Custodian can resolve them through `Address Errors`.

## Instruction Precedence

1. `PROJECT.md`
2. `docs/HANDOFF.md` and `docs/TASKS/QUEUE.md`
3. Active task document
4. Referenced ADRs/designs/reviews
5. `docs/CODEX-CLI-OPERATING-INSTRUCTIONS.md`
6. User request
7. Chat history
