# Non-Interruption Guardrail

## Purpose

Prevent Project Custodian activity from interrupting, displacing, or inserting a new gate into work already being executed by Codex.

## Active Task Lock

Once Codex has begun an Active task, that task is locked until Codex reaches its normal task boundary:

1. Implementation is complete or a genuine implementation blocker is found.
2. Required validation has run.
3. The task work log and completion state are updated.
4. The task changes are committed or the blocker is documented.

ChatGPT must not replace the Active task, change its owner, rewrite its scope, insert a design review, activate an audit, or otherwise stop Codex because the user submitted a new idea through ChatGPT.

## Handling New Requests While Codex Is Working

When the user gives ChatGPT a new feature, audit idea, design request, or governance change while Codex is executing an Active task, ChatGPT may:

- Record the request in a new design, intake, backlog, or queued-task document.
- Identify dependencies and recommend its future position.
- Prepare architecture or acceptance criteria that do not change the current Active task.

ChatGPT must not:

- Change `docs/HANDOFF.md` or `docs/TASKS/QUEUE.md` in a way that removes or displaces Codex's current Active task.
- Turn the new request into an immediate gate.
- Require Codex to stop, restart, rebase its implementation around the new request, or abandon completed work.
- Edit the Active task document while Codex is working unless Codex explicitly reports a blocker and requests a tracked scope decision.

New requests are reconciled at the next task boundary.

## Audit Counter Boundary Rule

Audit counters do not interrupt a task already in progress.

If a subsystem reaches `25 / 25` during an Active task or because ChatGPT records concurrent planning/governance work:

1. The current Active task may finish, validate, and commit.
2. The threshold is recorded as a pending audit requirement.
3. The required audit becomes the next Active task before another implementation task begins.

An audit gate blocks the start of the next implementation task. It does not cut into the middle of work already underway.

## Allowed Immediate Stops

This guardrail does not require Codex to continue unsafe or impossible work. An immediate stop is allowed only when:

- The user explicitly cancels or pauses the current task.
- Continuing risks data loss, credential exposure, destructive behavior, or a material security failure.
- Repository corruption or an irreconcilable source-of-truth conflict makes safe continuation impossible.
- The Active task itself encounters a blocker outside its authorized correction scope.

A new request submitted through ChatGPT is not, by itself, an immediate-stop condition.

## Task Boundary Reconciliation

At the normal completion or blocker boundary, the Project Custodian may:

- Review the completed work.
- Reconcile newly recorded requests.
- Reorder queued work.
- Activate a required audit.
- Activate the next implementation or design task.
- Refresh the handoff and Next Bot Prompt.

## Authority

- Codex owns uninterrupted execution of the current Active task within its approved scope.
- ChatGPT owns future sequencing, architecture, and governance at task boundaries.
- The user may explicitly override the current task at any time.
- The repository remains the source of truth.