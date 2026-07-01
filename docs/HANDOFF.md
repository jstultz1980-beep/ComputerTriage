# Current Handoff

## Handoff ID
HANDOFF-0030

## Current Task
TASK-0018-HEPHAESTUS-Local-Analysis-Engine-v1-Design

## Current Owner
ChatGPT

## Next Owner
Codex

## How The Handoff Process Works
This repository is the source of truth for the project. Chat history is useful context only when the same information has been written into the repository.

Another bot should not rely on memory, screenshots, or prior conversation unless those details are captured in tracked project files.

The handoff process has four core files:
- `PROJECT.md` defines the rules every bot must follow.
- `docs/HANDOFF.md` explains the current project state and contains the exact `Next Bot Prompt` to give another bot.
- `docs/TASKS/QUEUE.md` defines the official task queue and lifecycle.
- The active task file under `docs/TASKS` defines the only work that may be performed.

Work should move through this sequence:
1. Read `PROJECT.md`, the project docs, this handoff, the task queue, and the active task.
2. Perform only the work described by the active task. Do not clean up unrelated files or expand scope unless a task explicitly says to do so.
3. Validate the work using the validation steps in the task.
4. Update the active task file with completion notes and checked acceptance criteria.
5. Update `docs/TASKS/QUEUE.md` if task state changes.
6. Update this handoff with the new project state, validation results, known unrelated working-tree drift, and a fresh `Next Bot Prompt`.
7. Commit the related changes with a commit message that references the task.

The official task lifecycle is `Backlog -> Queued -> Assigned -> Active -> Validation -> Complete -> Archived`. Only one task may be `Active`.

## Objective
TASK-0018 is active. ChatGPT should design HEPHAESTUS Local Analysis Engine v1 before Codex implements anything.

Do not implement application code.
Do not implement ARGUS.
Do not modify HEPHAESTUS collectors.
Do not refactor existing code.
Do not download or install tools.
Do not clean unrelated files.

## Audit State Tracking
Each subsystem has its own change counter.

When any subsystem reaches `10 / 10` recorded subsystem changes, work must pause and a new audit task must be completed before further implementation work continues.

After the audit is completed, the audited subsystem counter resets to `0 / 10` and starts counting again from zero.

Change records are tracked in:

```text
docs/HISTORY/CHANGE-LEDGER.md
```

## Audit Counters

| Subsystem | Changes Since Last Audit | Audit Required |
|---|---:|---|
| Repository Governance | 0 / 10 | No |
| Architecture | 0 / 10 | No |
| Documentation | 1 / 10 | No |
| Task System | 1 / 10 | No |
| HEPHAESTUS | 0 / 10 | No |
| ARGUS | 0 / 10 | No |
| Reporting | 0 / 10 | No |
| UI | 4 / 10 | No |
| Plugin Framework | 1 / 10 | No |
| Build System | 0 / 10 | No |
| Validation/Test Framework | 2 / 10 | No |
| Roadmap/Backlog | 0 / 10 | No |

## Current State
The GitHub remote is configured as `https://github.com/jstultz1980-beep/ComputerTriage.git`. The local `master` branch tracks `origin/master`.

Foundation governance has been reconciled. `docs/HANDOFF.md` and `docs/TASKS/QUEUE.md` agree on exactly one active task.

TASK-0017 completed validation-only work:
- `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -SmokeTest` passed.
- `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -ButtonSmokeTest` passed.
- Strict active-task check found only `TASK-0017` active during validation.
- `App/manifests/custom-tools.json` runtime provenance drift occurred during validation and was reset before commit.
- `App/NetworkToolkit/LatencyMon/` is an untracked local tool folder. It was not staged, deleted, imported, or modified.

The accepted HEPHAESTUS Local Analysis Engine v1 work is approved direction, but implementation is not active. TASK-0018 must define the design, ADR needs, output contracts, and follow-on implementation tasks before Codex changes code.

## Active Task
`TASK-0018-HEPHAESTUS-Local-Analysis-Engine-v1-Design`

Scope:
- Define deterministic local analysis pipeline.
- Define rule-engine responsibilities and initial rules.
- Define normalized JSON, findings, timeline, evidence score, local HTML report, and bundle metadata expectations.
- Define portable-tool orchestration boundaries without downloading or requiring tools.
- Identify required ADRs or create ADR follow-on tasks.
- Produce focused Codex implementation tasks.

## Queued Work
- `TASK-0019-HEPHAESTUS-Local-Analysis-Engine-v1-Implementation` owned by Codex, blocked until TASK-0018 is complete and activated.
- `TASK-0020-ARGUS-Input-Contract-ADR` owned by ChatGPT.

## Completed Work
- Completed TASK-0017 validation.
- Created and activated `docs/TASKS/TASK-0018-HEPHAESTUS-Local-Analysis-Engine-v1-Design.md`.
- Updated `docs/TASKS/QUEUE.md`.
- Updated `docs/HISTORY/CHANGE-LEDGER.md`.
- Updated `docs/HISTORY/CHANGELOG.md`.
- Updated this handoff with the next ChatGPT-owned design task.

## Validation Completed
- Read required startup documents.
- Confirmed handoff and queue agreed on TASK-0017 before validation.
- Ran smoke validation successfully.
- Ran button-smoke validation successfully.
- Ran broad task-reference search.
- Ran strict active-task count check.
- Reset generated `App/manifests/custom-tools.json` drift after validation.
- Confirmed no application code was staged for TASK-0017.
- Confirmed untracked `App/NetworkToolkit/LatencyMon/` remains local drift and was not modified.

## Next Action
ChatGPT executes TASK-0018 design work.

## Blockers
None.

## Notes for Next AI
Known working-tree noise:
- `App/NetworkToolkit/LatencyMon/` is an untracked local tool folder and should not be deleted, imported, or committed unless a future task explicitly handles it.
- Runtime custom-tool provenance migration can add timestamp and package metadata drift to `App/manifests/custom-tools.json` during GUI validation. Reset that runtime drift before committing unless the active task explicitly changes the shipped manifest.

## Next Bot Prompt
Copy and paste the following prompt into another bot when offloading reasoning or review work. Do not create a separate task packet file.

```text
You are assisting with the Computer Triage Toolkit repository.

The repository is the single source of truth. Chat history is not the source of truth. Do not rely on a separate ChatGPT task packet file.

Read these repository files in order:
1. PROJECT.md
2. docs/PROJECT-CHARTER.md
3. docs/ARCHITECTURE.md
4. docs/ROADMAP.md
5. docs/HANDOFF.md
6. docs/TASKS/QUEUE.md
7. docs/TASKS/TASK-0018-HEPHAESTUS-Local-Analysis-Engine-v1-Design.md

Current task state:
- docs/HANDOFF.md and docs/TASKS/QUEUE.md list exactly one Active task.
- Active task: TASK-0018-HEPHAESTUS-Local-Analysis-Engine-v1-Design.
- Owner: ChatGPT.
- Next owner: Codex.
- TASK-0017 validation is complete.
- Smoke and button-smoke validation passed.
- HEPHAESTUS Local Analysis Engine v1 is approved direction, but implementation is not active yet.

Your job:
Complete TASK-0018 design work only.

Scope:
- Design the deterministic HEPHAESTUS Local Analysis Engine v1 pipeline.
- Define rule-engine responsibilities, initial rules, output schemas, evidence scoring, timeline, findings, local HTML report, and bundle metadata.
- Define portable-tool orchestration boundaries without downloading or requiring tools.
- Identify ADRs required before implementation.
- Create focused follow-on implementation tasks for Codex.
- Update docs/TASKS/QUEUE.md and docs/HANDOFF.md so they still agree.

Rules:
- Treat repository files as authoritative.
- Do not implement application code.
- Do not implement ARGUS.
- Do not modify HEPHAESTUS collectors.
- Do not refactor existing code.
- Do not download or install tools.
- Do not clean unrelated files.
- Do not use chat history as source of truth unless the same information exists in the repository.
- Do not create a separate ChatGPT task packet as source of truth.
- When the task is completed, update docs/HANDOFF.md with the next task state and a fresh Next Bot Prompt for Codex.
```
