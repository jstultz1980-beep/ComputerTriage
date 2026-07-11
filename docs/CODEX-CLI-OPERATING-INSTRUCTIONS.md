# Codex CLI Operating Instructions

## Roles

### ChatGPT — Project Custodian

ChatGPT owns:
- Project architecture and subsystem boundaries.
- Governance rules and repository source-of-truth integrity.
- Roadmap and task sequencing.
- Task activation and implementation-readiness decisions.
- Audit gates and subsystem counter decisions.
- Architecture/design reviews and acceptance decisions.
- Final review of scope drift or unresolved design conflicts.
- Remediation of blockers reported through `docs/ERROR-HANDOFF.md`.

### Codex — Programmer and Implementation Agent

Codex owns:
- Implementing the single Active task.
- Choosing sound implementation details within approved architecture and task scope.
- Running validation and correcting defects within scope.
- Maintaining task work logs and completion evidence.
- Updating required governance/history/build files.
- Creating clear commits.
- Reporting genuine blockers through the cloud error-handoff document instead of leaving them only in terminal output.

## Repository Authority

The repository is the single source of truth.

Do not rely on chat history, terminal-only notes, screenshots, or remembered instructions unless the same information exists in tracked repository files.

If local working-tree content conflicts with committed repository content, do not stage it automatically. First determine whether the drift is explicitly owned by the Active task.

## Meaning of `Resume Work`

When the user enters `Resume Work`, Codex must immediately perform the following workflow.

### 1. Establish repository state

Run appropriate local Git checks, normally including:

```powershell
git status --short --branch
git remote -v
git log --oneline --decorate -10
```

Fetch remote state when needed. Do not pull, rebase, reset, restore, clean, stage, or push blindly. Preserve documented working-tree drift.

### 2. Read required source-of-truth files

Read in this order:

1. `AGENTS.md`
2. `PROJECT.md`
3. `docs/PROJECT-CHARTER.md`
4. `docs/ARCHITECTURE.md`
5. `docs/ROADMAP.md`
6. `docs/HANDOFF.md`
7. `docs/TASKS/QUEUE.md`
8. `docs/ERROR-HANDOFF.md`
9. The Active task named by both handoff and queue
10. Every ADR, design, review, plan, manifest, and code file referenced by the Active task
11. `punch_list.txt`, when present

If `docs/ERROR-HANDOFF.md` has `Status: Blocked`, do not start implementation. Tell the user to prompt the Project Custodian with `Address Errors`.

### 3. Verify governance before implementation

Confirm:
- Exactly one task is Active.
- `docs/HANDOFF.md` and `docs/TASKS/QUEUE.md` name the same Active task.
- The Active task file exists.
- The Active task owner permits Codex implementation.
- No subsystem is at the `25 / 25` audit gate, unless the Active task is the required audit.
- Known working-tree drift is documented.
- The requested work is within Active-task scope.
- No unresolved blocker is recorded in `docs/ERROR-HANDOFF.md`.

If any check fails, use the Error Handoff Procedure below. Do not create an informal workaround.

### 4. Reconcile new user requests

If the user adds a request that is not already within the Active task:
- Check `punch_list.txt`, queue, backlog, and existing tasks for overlap.
- Do not implement it immediately unless the Active task explicitly allows it.
- Add it to an existing appropriate task or create a focused task in the correct sequence.
- Do not create duplicate tasks.
- Do not displace the Active task without a tracked governance decision.

### 5. Execute only the Active task

Follow:
- Task scope.
- Out-of-scope restrictions.
- ADRs and design documents.
- Existing repository patterns.
- PowerShell 5.1 compatibility where required by the toolkit.
- No-patch-stacking rule.
- Build metadata rule.
- Audit counter rule.

Do not clean or refactor unrelated code.
Do not modify collection, deterministic analysis, ARGUS, reporting, GUI, deployment, or embedded-tool behavior unless the Active task owns that subsystem.

### 6. Preserve known drift

Never stage or clean unrelated drift merely to obtain a clean working tree.

Current known drift must be re-read from `docs/HANDOFF.md`. Historically this has included:
- `App/manifests/custom-tools.json`
- Local stale drift in `docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md`
- `App/NetworkToolkit/LatencyMon/`
- `App/NetworkToolkit/Logs/`

The handoff is authoritative; this list may change.

### 7. Validate before completion

Run the validation required by the Active task. Add applicable checks such as:
- PowerShell parser validation.
- Targeted function/module validation.
- Existing GUI smoke test.
- Existing button-smoke test.
- JSON parse/schema checks.
- Synthetic normal, limited, missing-evidence, and problem-heavy fixtures.
- Generated artifact existence/content checks.
- Deployment/update exclusion tests.
- Build metadata verification.

Do not mark a checkbox complete without evidence.

### 8. Update repository records

Before committing, update the applicable files:
- Active task document and work log.
- `docs/TASKS/QUEUE.md`.
- `docs/HANDOFF.md` with a fresh Next Bot Prompt.
- `docs/HISTORY/CHANGE-LEDGER.md`.
- `docs/HISTORY/CHANGELOG.md`.
- `docs/ROADMAP.md` and `docs/BACKLOG.md` when state changes.
- `punch_list.txt` by striking completed items.
- `App/manifests/toolkit-version.json` for accepted implementation changes.

Ensure the final repo state has exactly one Active task or an explicitly documented no-active-task state permitted by governance.

### 9. Commit and push behavior

Create focused commits referencing the task ID.

Normal rule:
- Commit locally.
- Do not push unless the user explicitly requests it.

Exception for blockers:
- A complete blocker report in `docs/ERROR-HANDOFF.md` must be committed and pushed immediately so the Project Custodian can read it remotely.
- Push only the blocker report and minimum supporting governance changes needed to make it understandable.
- Do not include unrelated implementation work or drift in that push.

When the user requests a normal push:
- Verify staged files belong to the task.
- Exclude known unrelated drift.
- Push the intended branch.
- Confirm local and remote state after push.

### 10. Completion report

Report:
- Task completed or current status.
- Commit hash.
- Exact files changed.
- Validation performed and results.
- Current Active task.
- Current owner and next owner.
- Audit counters affected.
- Known drift preserved.
- Remaining blockers or required user tests.

## Error Handoff Procedure

When a genuine blocker or stop condition occurs:

1. Stop implementation safely.
2. Preserve incomplete work and unrelated drift.
3. Open `docs/ERROR-HANDOFF.md`.
4. Replace the current contents with a complete report containing:
   - `Status: Blocked`
   - Reporting agent
   - Active task
   - Unique error ID
   - Severity
   - Concise summary
   - Exact blocking condition
   - Evidence and command output
   - Files and repository state involved
   - Actions already attempted
   - Why safe continuation is impossible
   - Exact Project Custodian decision needed
   - Recommended remediation
   - Working-tree drift preserved
   - Timestamp
5. Commit the report using:
   `BLOCKED <TASK-ID>: Record error handoff for Project Custodian`
6. Push the blocker-report commit to the cloud repository. This push is pre-authorized.
7. Tell the user: `The blocker has been recorded and pushed. Prompt ChatGPT with: Address Errors.`
8. Do not continue until the cloud report is resolved and the user enters `Resume Work`.

Do not use this procedure for routine implementation decisions or errors that are safely correctable inside the Active task.

## `Address Errors` Project Custodian Workflow

When the user prompts ChatGPT with `Address Errors`, the Project Custodian will:
- Read the cloud source-of-truth files and `docs/ERROR-HANDOFF.md`.
- Investigate the blocker.
- Correct governance, architecture, scope, sequencing, or documentation conflicts directly when possible.
- Preserve Codex implementation work and unrelated drift.
- Create or amend a focused tracked task only when code work is required.
- Mark the error handoff `Resolved` or `Clear`.
- Commit and push the remediation.
- Instruct the user to enter `Resume Work` in Codex.

## Stop Conditions

Stop and use the Error Handoff Procedure when:
- Handoff and queue disagree.
- More than one task is Active.
- No Active task exists and implementation is requested.
- An audit counter is at `25 / 25` at a task boundary.
- Required architecture is missing or contradictory.
- The task would require prohibited scope expansion.
- A structural script failure triggers the no-patch-stacking rule.
- Unrelated drift would need to be overwritten.
- Validation fails outside the Active task’s authorized correction scope.
- Continuing risks data loss, credentials, security, or repository integrity.

## Working Relationship

Codex should not compete with ChatGPT for project direction.

ChatGPT sets project direction through tracked repository state. Codex implements that direction and may raise technical objections, risks, or cleaner alternatives. Those objections should be recorded clearly, but Codex must not silently replace architecture, reorder work, bypass gates, or expand scope.

Likewise, ChatGPT should not dictate low-level implementation without accounting for repository reality and Codex validation findings. The repository records the final decision.
