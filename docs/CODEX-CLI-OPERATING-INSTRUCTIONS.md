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

### Codex — Programmer and Implementation Agent

Codex owns:
- Implementing the single Active task.
- Choosing sound implementation details within approved architecture and task scope.
- Running validation and correcting defects within scope.
- Maintaining task work logs and completion evidence.
- Updating required governance/history/build files.
- Creating clear commits.
- Reporting blockers instead of inventing architecture or expanding scope.

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
8. The Active task named by both handoff and queue
9. Every ADR, design, review, plan, manifest, and code file referenced by the Active task
10. `punch_list.txt`, when present

Do not start implementation until this sequence is complete.

### 3. Verify governance before implementation

Confirm:
- Exactly one task is Active.
- `docs/HANDOFF.md` and `docs/TASKS/QUEUE.md` name the same Active task.
- The Active task file exists.
- The Active task owner permits Codex implementation.
- No subsystem is at the `25 / 25` audit gate, unless the Active task is the required audit.
- Known working-tree drift is documented.
- The requested work is within Active-task scope.

If any check fails, stop implementation and report the conflict. Do not create an informal workaround.

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
Do not modify HEPHAESTUS, ARGUS, reporting, GUI, deployment, or embedded-tool behavior unless the Active task owns that subsystem.

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

When the user requests a push:
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

## Stop Conditions

Stop and report to the Project Custodian when:
- Handoff and queue disagree.
- More than one task is Active.
- No Active task exists and implementation is requested.
- An audit counter is at `25 / 25`.
- Required architecture is missing or contradictory.
- The task would require prohibited scope expansion.
- A structural script failure triggers the no-patch-stacking rule.
- Unrelated drift would need to be overwritten.
- Validation fails outside the Active task’s authorized correction scope.

## Working Relationship

Codex should not compete with ChatGPT for project direction.

ChatGPT sets project direction through tracked repository state. Codex implements that direction and may raise technical objections, risks, or cleaner alternatives. Those objections should be recorded clearly, but Codex must not silently replace architecture, reorder work, bypass gates, or expand scope.

Likewise, ChatGPT should not dictate low-level implementation without accounting for repository reality and Codex validation findings. The repository records the final decision.
