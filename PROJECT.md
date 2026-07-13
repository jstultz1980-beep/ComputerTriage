# Computer Triage Toolkit Project Control

## Source of Truth
The repository is the source of truth. Chat history is not authoritative.

## Roles

ChatGPT is the Project Custodian and owns architecture, governance, audit decisions, roadmap and task sequencing, blocker resolution, release readiness, and acceptance boundaries.

Codex is the implementation and audit-preparation agent. Codex owns implementation, validation, focused corrections, task closeout records, local commits, and deterministic audit evidence gathering.

The user owns product direction and decisions that cannot safely be made from established repository evidence or prior product direction.

## Handoff Prompt Rule
`docs/HANDOFF.md` is the single source of truth for the next-bot prompt. Every completed task must update it.

## Resume Work Rule

When the user prompts `Resume Work`, Codex must follow `AGENTS.md`, `docs/CODEX-CLI-OPERATING-INSTRUCTIONS.md`, and `docs/GOVERNANCE/AUTONOMOUS-WORK-AND-AUDIT-CYCLE.md`.

The instruction authorizes one continuous execution cycle:

1. Synchronize the local checkout with the authoritative remote without overwriting preserved drift.
2. Execute the single Active Codex-owned task.
3. Validate, correct in-scope defects, update required records, and commit locally.
4. Reconcile punch-list additions.
5. If no gate or stop condition exists, activate the next dependency-ready Codex-owned task already ordered in `docs/TASKS/QUEUE.md`.
6. Continue without another user prompt.
7. When a subsystem reaches `25 / 25`, automatically create and complete an Audit Preparation task before any further implementation.
8. Push the completed audit package and activate a Project Custodian Engineering Audit task.
9. Stop for the Project Custodian, a genuine blocker, or a user-only decision.

`Resume Work` does not authorize unrelated work, architecture invention, dependency bypass, destructive cleanup, stale-checkout implementation, or activation of ChatGPT-owned work.

## Governance Refresh Rule

When the user prompts `Governance Refresh`, Codex must follow `docs/GOVERNANCE/GOVERNANCE-REFRESH.md`.

This command is a lightweight in-task rules reload. Codex pauses at the next safe point, preserves current work and documented drift, fetches and safely synchronizes with the authoritative remote, rereads only the defined governance set, applies changed workflow rules immediately, and resumes the same Active task.

`Governance Refresh` must not restart the task, perform a full project startup, reload architecture/roadmap/ADRs unless required by refreshed governance, clean drift, discard changes, or activate another task. Unsafe synchronization or irreconcilable governance conflict uses the Error Handoff Procedure.

## Project Custodian Continue Rule

When the user tells ChatGPT `Continue`, the Project Custodian must read the current cloud handoff, queue, error handoff, active task, and any audit package.

The Project Custodian should act autonomously on architecture, governance, remediation sequencing, task consolidation, counter resets, and implementation readiness whenever repository evidence is sufficient. It should stop for the user only when a product, licensing, credential, physical-access, destructive, release, or subjective acceptance decision genuinely requires the user.

After an Engineering Audit, the Project Custodian activates exactly one dependency-ready Codex task, commits and pushes the decision, and returns `Resume Work` as the next instruction.

## Completion Prompt Rule

Every stop-boundary summary from Codex or the Project Custodian must include a handoff timestamp immediately before the final operator instruction.

The timestamp format is:

```text
Handoff Timestamp: YYYY-MM-DDTHH:mm:ssZ
```

Use current UTC time when the message is sent. Do not copy an older repository timestamp into a new chat response.

When both the Debbie and Sampson chats are idle, the handoff with the newest timestamp identifies the current turn. If chat timestamps conflict with the repository, the repository remains authoritative.

For a normal Codex-to-Project-Custodian handoff, the final two lines must be:

```text
Handoff Timestamp: YYYY-MM-DDTHH:mm:ssZ
Tell Debbie to continue
```

For a genuine blocker recorded through `docs/ERROR-HANDOFF.md`, the final two lines must be:

```text
Handoff Timestamp: YYYY-MM-DDTHH:mm:ssZ
Tell Debbie to address errors
```

For a normal Project-Custodian-to-Codex handoff, the final two lines must be:

```text
Handoff Timestamp: YYYY-MM-DDTHH:mm:ssZ
Resume Work
```

The operator instruction must remain the final line, with no text after it. These instructions are mandatory and must not be paraphrased.

## Address Errors Rule

When the user prompts `Address Errors`, ChatGPT reads the cloud source-of-truth files and `docs/ERROR-HANDOFF.md`, resolves governance/architecture/scope/sequencing conflicts where possible, preserves Codex work and unrelated drift, commits and pushes the resolution, and returns control through `Resume Work`.

## Error Handoff Rule

A blocker must never exist only in terminal output or chat. Codex must record a complete blocker in `docs/ERROR-HANDOFF.md`, commit it, and push the minimum blocker handoff so the Project Custodian can act.

## Non-Interruption Rule

Once Codex begins an Active task, that task remains locked until normal completion or a genuine blocker boundary. New requests are recorded for later reconciliation and do not interrupt active implementation.

If a counter reaches `25 / 25` during an Active task, Codex finishes and validates that task. The Audit Preparation task becomes next before more implementation.

## Required Startup Sequence

1. Read `AGENTS.md` when operating through Codex CLI.
2. Synchronize and verify local/remote repository state.
3. Read this file.
4. Read `docs/PROJECT-CHARTER.md`.
5. Read `docs/ARCHITECTURE.md`.
6. Read `docs/ROADMAP.md`.
7. Read `docs/HANDOFF.md`.
8. Read `docs/TASKS/QUEUE.md` and verify agreement.
9. Read `docs/ERROR-HANDOFF.md`.
10. Read the Active task and every referenced ADR, design, review, plan, manifest, and code file.
11. Read `punch_list.txt` when present.
12. Follow the autonomous cycle or the active Project Custodian boundary.

## Task System

`docs/TASKS/QUEUE.md` is the operational queue. Exactly one task may be Active.

Lifecycle:

```text
Backlog -> Queued -> Assigned -> Active -> Validation -> Complete -> Archived
```

Implementation requires an Active task file under `docs/TASKS`.

## Audit State Tracking

Each subsystem has a material-change counter in `docs/HANDOFF.md` and `docs/HISTORY/CHANGE-LEDGER.md`.

When a counter reaches `25 / 25` at a task boundary:

1. Codex automatically creates and executes an Audit Preparation task.
2. Codex uses `docs/REVIEWS/AUDIT-PREPARATION-TEMPLATE.md`.
3. Codex gathers deterministic evidence and recommendations.
4. Codex does not reset counters or resume implementation.
5. Codex activates a Project Custodian Engineering Audit task and pushes the audit package.
6. The Project Custodian reviews evidence, makes final decisions, resets only audited counters, and activates the next implementation task.

Routine bookkeeping does not increment counters unless it materially changes subsystem behavior, structure, responsibility, interface, documentation, or validation.

## No Patch Stacking Rule

If a script or implementation develops structural errors, stop patching it. Return to the last known-good state and rebuild cleanly within task scope.

## Build Metadata Rule

Every accepted implementation change must update `App/manifests/toolkit-version.json`, normally through `App/Update-ToolkitVersion.ps1`.

## GitHub Sync Rule

Normal implementation commits remain local unless the user explicitly requests a push or repository rules require it.

Required cloud pushes:

- blocker handoffs;
- completed Audit Preparation packages and transition to Project Custodian Engineering Audit;
- Project Custodian governance, audit, and blocker resolutions;
- explicit user-requested synchronization.

## Product

Computer Triage Toolkit provides rapid, portable, single-computer Windows diagnostics, deterministic analysis, ARGUS explanation and guidance, and technician/executive reporting.

## Non-Goals

- Whole-network discovery
- SIEM replacement
- RMM replacement
- Asset inventory platform
- General AI-builder framework