# Computer Triage Toolkit Project Control

## Source of Truth
The repository is the source of truth. Chat history is not the source of truth.

## Handoff Prompt Rule
`docs/HANDOFF.md` is the single source of truth for the prompt that should be
given to another bot. Do not create or rely on a separate ChatGPT task packet as
a source of truth.

Every completed task must update `docs/HANDOFF.md` with a `Next Bot Prompt`
section. That prompt must tell the next bot to read repository files in the
required startup order, follow the active task listed in `docs/HANDOFF.md`, and
ignore chat history unless the same information exists in the repository.

## Prompt Shortcut Rule
When the user prompts exactly or substantially with `Next 25`, treat it as this reusable instruction:

```text
Read the project source-of-truth files first. Check punch_list.txt for new additions, merge any additions into the existing task list or create focused tasks if needed, reorder the task queue into the most logical implementation sequence, then proceed through tasks until the next 25-change audit gate is reached. Do not stop for user testing between tasks. Hold the full "Test This" list until stopped at the audit gate. Commit each completed task locally, but do not push unless explicitly asked.
```

## Codex CLI Resume Work Rule
When the user prompts exactly or substantially with `Resume Work`, Codex CLI must treat it as this reusable instruction:

```text
Read AGENTS.md and docs/CODEX-CLI-OPERATING-INSTRUCTIONS.md, then follow the full repository startup sequence. Verify the handoff and queue agree on exactly one Active task, verify no 25/25 audit gate blocks implementation, preserve all documented unrelated working-tree drift, read the Active task and every referenced design/ADR/file, execute only that task, validate it, update all required governance/history/build records, commit locally, and report the result. Do not push unless explicitly requested.
```

`Resume Work` is not permission to choose unrelated work, bypass audit gates, clean unrelated drift, or expand task scope.

## Required Startup Sequence
1. Read `AGENTS.md` when operating through Codex CLI.
2. Read this file.
3. Read `docs/PROJECT-CHARTER.md`.
4. Read `docs/ARCHITECTURE.md`.
5. Read `docs/ROADMAP.md`.
6. Read `docs/HANDOFF.md`.
7. Read `docs/TASKS/QUEUE.md` and verify it agrees with the handoff.
8. Read the active task document listed in `docs/HANDOFF.md`.
9. Read every ADR, design, plan, review, manifest, and code file referenced by the active task.
10. Read `punch_list.txt` if it exists and reconcile any new change requests into existing tasks or create correctly ordered new tasks without duplicating existing work.
11. Perform only the work assigned in the active task.
12. Validate the work.
13. Re-read `punch_list.txt` before completion and mark completed punch-list items with Markdown-style strike-through.
14. Update the active task document.
15. Update `docs/HANDOFF.md`, including the `Next Bot Prompt` for the next task or for creating the next task from the user's next request.
16. Commit all related changes.

## Core Rule
No implementation work may begin unless there is an active task document under `docs/TASKS`.

## Task Queue Rule
`docs/TASKS/QUEUE.md` is the official task queue.

The official task lifecycle is:

```text
Backlog
↓
Queued
↓
Assigned
↓
Active
↓
Validation
↓
Complete
↓
Archived
```

Only one task may be `Active` at a time.

`docs/HANDOFF.md` must identify the active task and must agree with
`docs/TASKS/QUEUE.md`.

## No Patch Stacking Rule
If a script or implementation develops structural errors, stop patching it. Roll back to the last known-good state and rebuild cleanly from the current repository layout.

## Audit State Tracking Rule
Each subsystem has its own audit change counter in `docs/HANDOFF.md`.

A subsystem change is an accepted engineering change that materially affects that subsystem's behavior, structure, responsibility, interface, documentation, or validation model.

When any subsystem counter reaches `25 / 25`, no new implementation work may begin until a new audit task is completed.

After the audit is completed:
1. The audited subsystem counter resets to `0 / 25`.
2. `docs/HANDOFF.md` is updated.
3. `docs/HISTORY/CHANGE-LEDGER.md` records the audit completion.
4. Normal task work may resume.

Every completed task must update:
- `docs/HANDOFF.md`
- `docs/HISTORY/CHANGE-LEDGER.md` when it records a subsystem change

## Build Metadata Rule
Every accepted implementation change must update `App/manifests/toolkit-version.json` before commit.

Use `App/Update-ToolkitVersion.ps1` unless a task explicitly changes versioning behavior.

The semantic `Version` may remain unchanged for normal task work, but the `Build`,
`SourceUpdatedAt`, and `ReleaseNotes` fields must reflect the committed change.

## GitHub Sync Rule
Normal implementation tasks may be committed locally, but should not be pushed to GitHub unless explicitly requested.

Repository GitHub sync should happen during the 25-change audit/refactor checkpoint, or sooner only when the user asks for a push.

## Product
Computer Triage Toolkit.

Primary goal: rapid, portable, single-computer Windows diagnostics, analysis, explanation, and reporting.

## Components
- HEPHAESTUS: evidence collection and deterministic local analysis
- ARGUS: cited evidence analysis, explanation, grouping, and technician guidance
- Reporting: technician and executive outputs

## Non-Goals
- Whole-network discovery
- SIEM replacement
- RMM replacement
- Asset inventory platform
- General AI Builder framework
