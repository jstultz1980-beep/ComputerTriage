# Codex CLI Operating Instructions

## Roles

### ChatGPT — Project Custodian
Owns architecture, governance, roadmap and sequencing, audit decisions, counter resets, remediation disposition, release readiness, blocker resolution, and acceptance boundaries.

### Codex — Implementation and Audit Preparation Agent
Owns implementation of Codex-owned Active tasks, validation, in-scope corrections, task closeout records, local commits, continuous queue progression, and deterministic audit evidence gathering.

## Repository Authority

The repository is the single source of truth. Do not rely on chat history or terminal-only notes unless tracked.

## Resume Work Workflow

When the user enters `Resume Work`, Codex must begin a continuous execution cycle.

### 1. Synchronize before reading task state

Run:

```powershell
git status --short --branch
git remote -v
git fetch --prune origin
git rev-parse HEAD
git rev-parse @{u}
git rev-list --left-right --count HEAD...@{u}
git merge --ff-only @{u}
git rev-parse HEAD
git rev-parse @{u}
git rev-list --left-right --count HEAD...@{u}
```

A fetch alone is not synchronization. Codex must safely fast-forward when local is behind and preserved drift is not threatened.

Before trusting governance, confirm:

- local `HEAD` equals `@{u}`;
- the final comparison is `0 0`;
- local `HEAD` equals the `Current HEAD` in the newest Project Custodian handoff;
- the checked-out branch equals the handoff `Current Branch`;
- preserved drift remains intact.

Codex may read cloud-hosted governance directly only when the connector returns that exact branch and commit. Stop through Error Handoff when local is ahead, diverged, lacks an upstream, fetch fails, fast-forward is unsafe, or the handoff commit cannot be matched.

### 2. Read source-of-truth files

Read in order:

1. `AGENTS.md`
2. `PROJECT.md`
3. `docs/GOVERNANCE/AUTONOMOUS-WORK-AND-AUDIT-CYCLE.md`
4. `docs/PROJECT-CHARTER.md`
5. `docs/ARCHITECTURE.md`
6. `docs/ROADMAP.md`
7. `docs/HANDOFF.md`
8. `docs/TASKS/QUEUE.md`
9. `docs/ERROR-HANDOFF.md`
10. Active task and all referenced files
11. `punch_list.txt`

### 3. Verify governance

Confirm exactly one Active task, handoff/queue agreement, an existing Active task file, permitted ownership, no unresolved blocker, documented drift, in-scope work, counters below gate unless the Active task is Audit Preparation, and synchronized repository state.

### 4. Execute and validate

Implement only the Active task. Follow PowerShell 5.1 compatibility, architecture, no-patch-stacking, build metadata, and counter rules.

Run task-required validation plus applicable parser, load, smoke, button-smoke, fixture, JSON/schema, artifact, deployment/update, and build metadata checks. Correct in-scope defects without requesting routine approval.

### 5. Close the task

Update applicable task, queue, handoff, ledger, changelog, roadmap/backlog, punch-list, and build-metadata records. Commit locally with the task ID.

### 6. Continue automatically

After task completion, reread counters, queue, handoff, error handoff, and punch list. If a subsystem reached `25 / 25`, follow Audit Preparation. Otherwise activate the next dependency-ready Codex-owned queued task and continue without another prompt.

Codex may not skip dependencies, invent product direction, reorder ChatGPT-owned architecture work, activate a ChatGPT-owned implementation/design task, or proceed from stale governance.

## Governance Refresh Workflow

When the user enters `Governance Refresh`, Codex must follow `docs/GOVERNANCE/GOVERNANCE-REFRESH.md` instead of restarting the full `Resume Work` workflow.

1. Pause at the next safe interruption point.
2. Preserve current task work and documented drift.
3. Fetch, safely fast-forward, and verify `HEAD == @{u}` with comparison `0 0`.
4. Confirm the resulting commit equals the newest Project Custodian handoff commit.
5. Reread only the governance set defined in the policy.
6. Apply changed governance immediately.
7. Recheck handoff, queue, Active task, and ownership.
8. Resume the same Active task from the interruption point only after verification passes.

Do not restart the task, repeat completed work, perform a full architecture/roadmap/ADR reload, change task state by itself, or clean unrelated drift. Unsafe synchronization or irreconcilable governance conflict uses Error Handoff.

## Audit Preparation Procedure

When any subsystem reaches `25 / 25` at a task boundary:

1. Do not start another implementation task.
2. Create a focused Audit Preparation task owned by Codex.
3. Use `docs/REVIEWS/AUDIT-PREPARATION-TEMPLATE.md`.
4. Gather the deterministic evidence package required by the autonomous-cycle policy.
5. Run relevant executable validation.
6. Record technical debt, severity, evidence, recommendations, and required decisions.
7. Mark Audit Preparation complete.
8. Activate a Project Custodian Engineering Audit task as the only Active task.
9. Do not reset counters or resume implementation.
10. Commit and push the audit package and transition records.

## Project Custodian Boundary

Codex stops when the sole Active task is owned by ChatGPT/Project Custodian. The user then tells ChatGPT `Continue`. After the Project Custodian pushes the decision and activates a Codex task, the user tells Codex `Resume Work`.

Codex must synchronize to the exact branch and `Current HEAD` reported by the Project Custodian before reading the new task state or resuming work.

## User-Only Decisions

Ask the user only for unresolved materially different product behavior, credentials/secrets, purchasing/licensing, external-account changes, destructive action outside scope, physical/user-only access/testing, release/deployment/publication authorization, or explicit subjective acceptance.

Routine implementation, refactoring, validation correction, audit recommendations, task consolidation, sequencing, and governance updates do not require the user.

## Preserve Drift

Never stage, clean, restore, reset, or overwrite unrelated drift. Reread the current drift list from `docs/HANDOFF.md`.

## Push Rules

Normal implementation commits remain local unless explicitly authorized. Push is required for blocker handoffs, completed Audit Preparation packages and transitions, and explicit user requests.

## Error Handoff

Use `docs/ERROR-HANDOFF.md` for synchronization failures, irreconcilable governance conflicts, out-of-scope blockers, structural failure, unrelated-work overwrite risk, security/data-loss risk, or validation failure outside authorized correction scope.

Commit and push the blocker report, then stop at the Project Custodian boundary.

## Completion Reporting

At every stop boundary, report synchronized starting commit, tasks completed, resulting commits, files changed, validation, current/next owner, counters, preserved drift, reason for stopping, and this visible footer:

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

`Repository State Verified: YES` is allowed only when local `HEAD` equals upstream, the comparison is `0 0`, and local `HEAD` equals the newest Project Custodian handoff commit. If verification is `NO`, state the reason and do not claim implementation authority.

The visible chat response must end with a current `America/Chicago` timestamp followed by exactly one final operator instruction, with no text after it.

For a non-blocked stop boundary:

```text
Handoff Timestamp: YYYY-MM-DD HH:mm:ss CDT
Tell Debbie to continue
```

For a genuine blocker recorded and pushed through `docs/ERROR-HANDOFF.md`:

```text
Handoff Timestamp: YYYY-MM-DD HH:mm:ss CDT
Tell Debbie to address errors
```

Use CST instead of CDT when appropriate. Do not paraphrase either final instruction.
