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
```

Safely fast-forward when local is behind and preserved drift is not threatened. Stop through Error Handoff when local is ahead, diverged, lacks an upstream, fetch fails, or synchronization cannot be completed safely. Confirm local and remote commit hashes match before trusting governance files.

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

Confirm:

- exactly one Active task;
- handoff and queue agree;
- Active task file exists;
- owner permits Codex work;
- no unresolved blocker;
- known drift is documented;
- work is inside task scope;
- audit counters are below gate, unless the Active task is Audit Preparation.

### 4. Execute and validate

Implement only the Active task. Follow PowerShell 5.1 compatibility, architecture, no-patch-stacking, build metadata, and counter rules.

Run task-required validation plus applicable parser, load, smoke, button-smoke, fixture, JSON/schema, artifact, deployment/update, and build metadata checks. Correct in-scope defects without requesting routine approval.

### 5. Close the task

Update applicable records:

- Active task and work log;
- `docs/TASKS/QUEUE.md`;
- `docs/HANDOFF.md`;
- `docs/HISTORY/CHANGE-LEDGER.md`;
- `docs/HISTORY/CHANGELOG.md`;
- roadmap/backlog;
- `punch_list.txt`;
- toolkit build metadata.

Commit locally with the task ID.

### 6. Continue automatically

After task completion:

1. Re-read counters, queue, handoff, error handoff, and punch list.
2. If a subsystem reached `25 / 25`, follow the Audit Preparation Procedure below.
3. If no gate or stop condition exists, activate the next dependency-ready Codex-owned task already ordered in the queue.
4. Update handoff and queue consistently.
5. Continue implementation without another user prompt.

Codex may not skip dependencies, invent new product direction, reorder ChatGPT-owned architecture work, or activate a ChatGPT-owned implementation/design task.

## Audit Preparation Procedure

When any subsystem reaches `25 / 25` at a task boundary:

1. Do not start another implementation task.
2. Create a focused task file named for the gated subsystem audit preparation.
3. Make it the only Active task, owned by Codex.
4. Use `docs/REVIEWS/AUDIT-PREPARATION-TEMPLATE.md`.
5. Gather the full deterministic evidence package described in `docs/GOVERNANCE/AUTONOMOUS-WORK-AND-AUDIT-CYCLE.md`.
6. Run all relevant executable validation.
7. Record technical-debt candidates, severity, evidence, task recommendations, and required decisions.
8. Mark Audit Preparation complete.
9. Create and activate a focused Project Custodian Engineering Audit task as the only Active task.
10. Do not reset counters or resume implementation.
11. Commit the audit package and transition records.
12. Push the audit package and minimum governance transition to the cloud repository.
13. Report that the audit is ready for Project Custodian review.

A separate user instruction is not required to execute Audit Preparation.

## Project Custodian Boundary

Codex stops when the sole Active task is owned by ChatGPT/Project Custodian. The user then tells ChatGPT `Continue`. After the Project Custodian pushes the decision and activates a Codex task, the user tells Codex `Resume Work` and the cycle repeats.

## User-Only Decisions

Ask the user only for:

- unresolved materially different product behaviors;
- credentials, secrets, purchasing, licensing acceptance, or external-account changes;
- destructive action outside task scope;
- physical or user-only testing/access;
- release, deployment, publication, or production authorization;
- explicit subjective acceptance required by the task.

Routine implementation, refactoring, validation correction, audit recommendations, task consolidation, sequencing, and governance updates do not require the user.

## Preserve Drift

Never stage, clean, restore, reset, or overwrite unrelated drift. Re-read the current drift list from `docs/HANDOFF.md`.

## Push Rules

Normal implementation commits remain local unless explicitly authorized.

Push is required for:

- blocker handoffs;
- completed Audit Preparation package and transition to Project Custodian Engineering Audit;
- explicit user request.

## Error Handoff

Use `docs/ERROR-HANDOFF.md` for synchronization failures, irreconcilable governance conflicts, out-of-scope blockers, structural failure, unrelated-work overwrite risk, security/data-loss risk, or validation failure outside authorized correction scope.

Commit and push the blocker report, then stop at the Project Custodian boundary.

## Completion Reporting

At a stop boundary report:

- synchronized starting commit;
- tasks completed during the cycle;
- resulting commits;
- files changed;
- validation results;
- current Active task;
- current and next owner;
- counters;
- preserved drift;
- blocker, audit, or user-only decision requiring the stop.

The summary must then end with exactly one final operator instruction and no text after it.

For successful completion, Audit Preparation completion, a Project Custodian boundary, or a user-only decision boundary, the exact final line is:

```text
Tell Debbie to continue
```

For a genuine blocker recorded and pushed through `docs/ERROR-HANDOFF.md`, the exact final line is:

```text
Tell Debbie to address errors
```

Do not paraphrase either final line.