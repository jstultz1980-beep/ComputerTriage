# Autonomous Work and Audit Cycle

## Purpose

A single `Resume Work` instruction should allow Codex to continue through dependency-ready implementation tasks until a genuine stop boundary is reached.

## Continuous Codex Execution

After mandatory repository synchronization, Codex must:

1. Execute the single Active Codex-owned task.
2. Validate and correct in-scope defects.
3. Update required task, queue, handoff, history, counter, punch-list, and build records.
4. Commit the completed task locally.
5. Reconcile new punch-list items without interrupting dependency order.
6. If no stop condition exists, activate the next dependency-ready Codex-owned task already ordered in `docs/TASKS/QUEUE.md`.
7. Continue without another user prompt.

Codex may not invent product direction, reorder architecture work, bypass dependencies, activate a ChatGPT-owned task, or expand task scope.

## Audit Gate

Counters measure material accepted subsystem changes. When any counter reaches `25 / 25` at a task boundary:

- Codex must not begin another implementation task.
- Codex must automatically create and activate a focused Audit Preparation task.
- No additional user prompt is required.

A combined Audit Preparation task is allowed only when multiple gated subsystems have substantially overlapping evidence and decisions.

## Audit Preparation — Codex

Codex must complete the audit task autonomously using `docs/REVIEWS/AUDIT-PREPARATION-TEMPLATE.md`.

The audit package must include:

- synchronized starting and ending commits;
- exact task/change range since the prior audit;
- counter and queue reconciliation;
- parser, build, smoke, regression, fixture, and artifact validation results as applicable;
- architecture and dependency observations;
- duplicate, dead, superseded, or conflicting implementation candidates;
- false-success and failure-propagation observations;
- security, privilege, sensitive-data, deployment, update, and provenance observations;
- performance observations;
- documentation, ADR, roadmap, queue, and handoff consistency;
- technical-debt candidates with severity and evidence;
- recommended remediation tasks, merges, removals, and dependency order;
- unresolved items classified as Project Custodian decisions or user-only decisions.

Codex gathers evidence and recommends dispositions. Codex must not reset counters, approve release readiness, or resume implementation after audit preparation.

At audit completion Codex must:

1. Mark the Audit Preparation task complete.
2. Activate a Project Custodian Engineering Audit task as the sole Active task.
3. Update handoff and queue.
4. Commit and push the audit package and minimum governance transition to the cloud repository.
5. Report that Project Custodian review is required.
6. End the report with the exact final line `Tell Debbie to continue`.

## Engineering Audit — Project Custodian

When the user tells ChatGPT `Continue`, the Project Custodian must:

1. Synchronize to the cloud repository and read the audit package.
2. Verify evidence and resolve architecture, governance, sequencing, debt, and release-readiness decisions.
3. Create, merge, remove, reorder, or disposition tasks as justified.
4. Reset only audited counters.
5. Close the Engineering Audit task.
6. Activate exactly one dependency-ready Codex task.
7. Commit and push the governance decision.
8. Return the next instruction: `Resume Work`.

The Project Custodian should decide autonomously whenever repository evidence and established product direction are sufficient.

## User-Only Stop Conditions

The cycle should stop for the user only when a decision cannot safely be made by the Project Custodian, including:

- materially different product behaviors with no established preference;
- purchasing, licensing acceptance, credentials, secrets, or external-account changes;
- destructive action outside repository/task scope;
- physical testing or access only the user can perform;
- release, deployment, publication, or production action without prior authorization;
- explicit user acceptance where the task requires subjective product judgment.

Routine implementation choices, audit findings, task ordering, refactoring choices, test corrections, and governance maintenance are not user-only decisions.

## Other Stop Conditions

Codex must also stop for:

- unsafe repository divergence or synchronization failure;
- a genuine blocker outside active-task correction scope;
- data-loss, credential, security, or repository-corruption risk;
- handoff/queue conflict that cannot be safely reconciled from tracked evidence.

These use `docs/ERROR-HANDOFF.md` and the existing `Address Errors` workflow.

## Mandatory Closing Instruction

Every Codex stop-boundary summary must end with exactly one final operator instruction and no text after it.

For every non-blocked stop boundary, including successful cycle completion, Audit Preparation completion, a Project Custodian boundary, or a user-only decision boundary, use exactly:

```text
Tell Debbie to continue
```

For a genuine blocker recorded and pushed through `docs/ERROR-HANDOFF.md`, use exactly:

```text
Tell Debbie to address errors
```

Neither instruction may be paraphrased.