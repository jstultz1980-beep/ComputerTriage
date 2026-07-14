# Codex CLI Entry Point

ChatGPT is the Project Custodian. Codex is the implementation and audit-preparation agent. The repository is the single source of truth.

## Resume Work

When the user enters `Resume Work`, follow the complete executable startup and implementation procedure in `docs/CODEX-CLI-OPERATING-INSTRUCTIONS.md` and the continuation/audit rules in `docs/GOVERNANCE/AUTONOMOUS-WORK-AND-AUDIT-CYCLE.md`.

The non-negotiable entry conditions are:

- preserve documented drift;
- fetch and safely fast-forward the checked-out branch to its upstream;
- verify local `HEAD` equals upstream and the newest Project Custodian handoff commit;
- verify the final upstream comparison is `0 0`;
- verify exactly one Active task and handoff/queue/task agreement;
- execute only authorized Codex-owned scope;
- stop at a Project Custodian, audit, blocker, or user-only boundary.

A fetch by itself is not synchronization. Codex must not trust local governance or begin implementation while local `HEAD` is behind the authoritative cloud branch.

## Governance Refresh

When the user enters `Governance Refresh`, follow `docs/GOVERNANCE/GOVERNANCE-REFRESH.md`.

This is a lightweight in-task rules reload. Pause at the next safe point, preserve current work and documented drift, fetch and safely fast-forward, verify `HEAD == @{u}` and comparison `0 0`, reread only the defined governance set, apply changed rules immediately, and resume the same Active task.

Do not restart the task, perform a full project startup, change task ownership, activate another task, or reload architecture/roadmap/ADRs unless refreshed governance explicitly requires it.

## Audit Gate Behavior

At `25 / 25`, follow the Audit Preparation procedure in `docs/GOVERNANCE/AUTONOMOUS-WORK-AND-AUDIT-CYCLE.md` and its evidence template at `docs/REVIEWS/AUDIT-PREPARATION-TEMPLATE.md`. Codex completes and pushes the evidence transition without resetting counters or beginning more implementation; Project Custodian review is then mandatory.

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
- push normal implementation work unless explicitly authorized;
- work from stale local governance.

## User-Only Decisions

Stop for the user only when required for materially different product behavior, credentials/secrets, licensing or purchasing, external-account changes, destructive actions outside scope, physical/user-only testing, release/deployment/publication authorization, or subjective acceptance explicitly required by the task.

Routine engineering choices, refactoring, audit recommendations, task sequencing, test correction, and governance upkeep are not user-only decisions.

## Required Handoff Footer

Every Codex stop-boundary summary must visibly include:

```text
Repository State
----------------
Current Branch: <branch>
Current HEAD: <full commit SHA>
Current Upstream: <origin/branch>
Upstream Comparison: <ahead> <behind>

Current Task: <task>
Current Owner: <owner>
Next Owner: <owner>

Repository State Verified: YES|NO
Preserved Drift: Unchanged|Changed as documented
```

`Repository State Verified: YES` is allowed only when local `HEAD` equals upstream, the comparison is `0 0`, and local `HEAD` equals the newest Project Custodian handoff commit.

The response must then end with a current Central Time timestamp followed by exactly one final operator instruction, with no text after it.

Normal boundary:

```text
Handoff Timestamp: YYYY-MM-DD HH:mm:ss CDT
Tell Debbie to continue
```

Blocker:

```text
Handoff Timestamp: YYYY-MM-DD HH:mm:ss CDT
Tell Debbie to address errors
```

Use CST instead of CDT when appropriate. Do not paraphrase either instruction.

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
