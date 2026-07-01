# Current Handoff

## Handoff ID
HANDOFF-0031

## Current Task
TASK-0019-HEPHAESTUS-Local-Analysis-Engine-v1-Implementation

## Current Owner
Codex

## Next Owner
Codex or ChatGPT depending on TASK-0019 findings

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
TASK-0018 design work is complete. Codex should now implement the focused TASK-0019 minimal vertical slice for HEPHAESTUS Local Analysis Engine v1.

Do not implement ARGUS.
Do not download or install tools.
Do not clean unrelated files.
Do not import, delete, or modify untracked `App/NetworkToolkit/LatencyMon/` unless a future task explicitly handles it.

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
| Architecture | 1 / 10 | No |
| Documentation | 2 / 10 | No |
| Task System | 2 / 10 | No |
| HEPHAESTUS | 1 / 10 | No |
| ARGUS | 0 / 10 | No |
| Reporting | 0 / 10 | No |
| UI | 4 / 10 | No |
| Plugin Framework | 1 / 10 | No |
| Build System | 0 / 10 | No |
| Validation/Test Framework | 2 / 10 | No |
| Roadmap/Backlog | 1 / 10 | No |

## Current State
The GitHub remote is configured as `https://github.com/jstultz1980-beep/ComputerTriage.git`. The local `master` branch tracks `origin/master`.

Foundation governance has been reconciled. `docs/HANDOFF.md` and `docs/TASKS/QUEUE.md` agree on exactly one active task.

TASK-0017 completed validation-only work:
- Smoke validation passed.
- Button-smoke validation passed.
- Runtime `App/manifests/custom-tools.json` drift was reset before commit.
- Untracked `App/NetworkToolkit/LatencyMon/` remained untouched.

TASK-0018 completed design-only work:
- Created `docs/DESIGN/HEPHAESTUS-Local-Analysis-Engine-v1.md`.
- Created `docs/ADRS/ADR-0001-HEPHAESTUS-Local-Analysis-Boundary.md`.
- Created `docs/ADRS/ADR-0002-Normalized-Output-Schema-Versioning.md`.
- Created `docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md` as proposed future ARGUS contract direction.
- Created `docs/TASKS/TASK-0019-HEPHAESTUS-Local-Analysis-Engine-v1-Implementation.md`.
- Updated roadmap, queue, ledger, changelog, and this handoff.

## Active Task
`TASK-0019-HEPHAESTUS-Local-Analysis-Engine-v1-Implementation`

Scope summary:
- Implement the first minimal HEPHAESTUS local analysis vertical slice.
- Create `Analysis/`, `Analysis/normalized/`, and `Metadata/` output folders in the bundle/output root.
- Generate schema/version metadata and bundle capability metadata.
- Generate findings, timeline, evidence score, machine-profile JSON, and local HTML report.
- Add a starter deterministic rule runner and evidence-quality handling.
- Ensure missing optional evidence/tools are marked missing/skipped, not fatal.
- Ensure analysis failure does not break collection.

## Queued Work
- `TASK-0020-ARGUS-Input-Contract-ADR` owned by ChatGPT.
- `TASK-0021-HEPHAESTUS-Rule-Catalog-Expansion` owned by Codex.
- `TASK-0022-HEPHAESTUS-Portable-Tool-Classification` owned by ChatGPT.

## Completed Work
- Completed TASK-0017 validation.
- Completed TASK-0018 design.
- Created TASK-0019 implementation task and made it active.

## Validation Completed For TASK-0018
- Read required startup documents from GitHub `master`.
- Confirmed `docs/HANDOFF.md` and `docs/TASKS/QUEUE.md` listed TASK-0018 active before execution.
- Completed design/ADR/task documentation only.
- Did not modify application code.
- Did not modify HEPHAESTUS collector code.
- Did not implement ARGUS.
- Did not download or install tools.
- Did not clean unrelated files.

Local PowerShell validation was not run by ChatGPT for this design-only GitHub update.

## Next Action
Codex executes TASK-0019 implementation using the TASK-0018 design and ADRs.

## Blockers
None.

## Notes for Next AI
Known working-tree noise:
- `App/NetworkToolkit/LatencyMon/` is an untracked local tool folder and should not be deleted, imported, or committed unless a future task explicitly handles it.
- Runtime custom-tool provenance migration can add timestamp and package metadata drift to `App/manifests/custom-tools.json` during GUI validation. Reset that runtime drift before committing unless the active task explicitly changes the shipped manifest.

## Recommended Commit Message
```text
TASK-0018: Design HEPHAESTUS Local Analysis Engine v1
```

## Next Bot Prompt
Copy and paste the following prompt into Codex. Do not create a separate task packet file.

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
7. docs/TASKS/TASK-0019-HEPHAESTUS-Local-Analysis-Engine-v1-Implementation.md
8. docs/DESIGN/HEPHAESTUS-Local-Analysis-Engine-v1.md
9. docs/ADRS/ADR-0001-HEPHAESTUS-Local-Analysis-Boundary.md
10. docs/ADRS/ADR-0002-Normalized-Output-Schema-Versioning.md
11. docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md

Current task state:
- docs/HANDOFF.md and docs/TASKS/QUEUE.md list exactly one Active task.
- Active task: TASK-0019-HEPHAESTUS-Local-Analysis-Engine-v1-Implementation.
- Owner: Codex.
- TASK-0018 design is complete.
- HEPHAESTUS Local Analysis Engine v1 implementation is now active only for the minimal vertical slice described in TASK-0019.

Your job:
Complete TASK-0019 implementation only.

Scope:
- Implement the minimal Local Analysis Engine v1 vertical slice.
- Create Analysis, Analysis/normalized, and Metadata output folders in the bundle/output root.
- Generate Metadata/schema-version.json and Metadata/bundle-capabilities.json.
- Generate Analysis/findings.json, Analysis/timeline.json, Analysis/evidence-score.json, Analysis/normalized/machine-profile.json, and Analysis/report.html.
- Implement a starter deterministic rule runner and evidence-quality handling.
- Ensure missing optional evidence/tools are recorded as missing/skipped and do not fail collection.
- Ensure analysis failure does not break collection.
- Update docs/TASKS/TASK-0019-HEPHAESTUS-Local-Analysis-Engine-v1-Implementation.md with work log and completion notes.
- Update docs/TASKS/QUEUE.md and docs/HANDOFF.md so they still agree.
- Update docs/HISTORY/CHANGE-LEDGER.md for accepted subsystem changes.

Do not:
- Implement ARGUS.
- Download or install tools.
- Import, delete, or modify untracked App/NetworkToolkit/LatencyMon/ unless a future task explicitly handles it.
- Build a full rule catalog.
- Refactor broad collector or GUI code.
- Perform whole-network analysis.
- Use chat history as source of truth unless the same information exists in the repository.

Validation expectations:
- Existing smoke test passes.
- Button-smoke test passes or any blocker is documented.
- Generated JSON artifacts parse successfully.
- A test bundle contains the required Analysis and Metadata outputs.
- Analysis failure does not break collection.
- No ARGUS implementation is added.

When done, provide:
- Concise summary of implementation performed.
- Exact files changed.
- Validation performed.
- Current active task.
- Current owner and next owner.
- Recommended commit message.
```
