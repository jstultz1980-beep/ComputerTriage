# Current Handoff

## Handoff ID
HANDOFF-0032

## Current Task
TASK-0019-HEPHAESTUS-Local-Analysis-Engine-v1-Implementation

## Current Owner
Codex

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

Only one task may be `Active`.

## Objective
TASK-0019 has started but is not complete. A first implementation slice was pushed to GitHub and now needs local validation/correction by Codex.

Do not implement ARGUS.
Do not download or install tools.
Do not clean unrelated files.
Do not import, delete, or modify untracked `App/NetworkToolkit/LatencyMon/` unless a future task explicitly handles it.

## Audit State Tracking
Each subsystem has its own change counter.

When any subsystem reaches `10 / 10` recorded subsystem changes, work must pause and a new audit task must be completed before further implementation work continues.

Change records are tracked in:

```text
docs/HISTORY/CHANGE-LEDGER.md
```

## Audit Counters

| Subsystem | Changes Since Last Audit | Audit Required |
|---|---:|---|
| Repository Governance | 0 / 10 | No |
| Architecture | 1 / 10 | No |
| Documentation | 3 / 10 | No |
| Task System | 2 / 10 | No |
| HEPHAESTUS | 2 / 10 | No |
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
- Created Local Analysis Engine v1 design.
- Created ADRs for HEPHAESTUS local analysis boundary and schema versioning.
- Created proposed ARGUS input contract/trust-model ADR.
- Created TASK-0019 implementation task.

TASK-0019 implementation has started:
- Created `App/NetworkToolkit/Core/LocalAnalysisEngine.ps1`.
- Registered command: `Run Local Analysis`.
- The module creates `Analysis/`, `Analysis/normalized/`, and `Metadata/` under the selected bundle/output root.
- The module writes `findings.json`, `timeline.json`, `evidence-score.json`, `machine-profile.json`, `report.html`, `bundle-capabilities.json`, and `schema-version.json`.
- TASK-0019 remains active because local PowerShell validation has not been run by ChatGPT.

## Active Task
`TASK-0019-HEPHAESTUS-Local-Analysis-Engine-v1-Implementation`

Immediate next work:
1. Pull from `origin/master`.
2. Validate the new Core module parses and loads.
3. Run the existing smoke and button-smoke tests.
4. Run the safe invocation path:
   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -CLI -RunCommand "Run Local Analysis"
   ```
5. Validate generated JSON artifacts parse successfully.
6. Fix any defects found within TASK-0019 scope.
7. Complete TASK-0019 only after validation passes.

## Queued Work
- `TASK-0020-ARGUS-Input-Contract-ADR` owned by ChatGPT.
- `TASK-0021-HEPHAESTUS-Rule-Catalog-Expansion` owned by Codex.
- `TASK-0022-HEPHAESTUS-Portable-Tool-Classification` owned by ChatGPT.

## Validation Completed For This Update
- Read required startup documents from GitHub `master`.
- Confirmed TASK-0019 was active before implementation start.
- Added a new Core module only.
- Did not implement ARGUS.
- Did not download or install tools.
- Did not touch untracked `App/NetworkToolkit/LatencyMon/`.

Local PowerShell validation was not run by ChatGPT for this GitHub update.

## Blockers
- Local validation is still required.

## Notes for Next AI
Known working-tree noise:
- `App/NetworkToolkit/LatencyMon/` is an untracked local tool folder and should not be deleted, imported, or committed unless a future task explicitly handles it.
- Runtime custom-tool provenance migration can add timestamp and package metadata drift to `App/manifests/custom-tools.json` during GUI validation. Reset that runtime drift before committing unless the active task explicitly changes the shipped manifest.

## Recommended Commit Message
```text
TASK-0019: Implement HEPHAESTUS Local Analysis Engine v1 slice
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
- A first implementation slice was pushed, but local validation has not been run.

Your job:
Continue and complete TASK-0019 only.

Scope:
- Pull the latest `origin/master` changes.
- Validate and correct `App/NetworkToolkit/Core/LocalAnalysisEngine.ps1` if needed.
- Run existing smoke and button-smoke validation.
- Run `Run Local Analysis` through the CLI path.
- Validate generated JSON artifacts parse successfully.
- Confirm Analysis and Metadata outputs are created in the bundle/output root.
- Ensure analysis failure does not break collection.
- Update TASK-0019, QUEUE, HANDOFF, CHANGE-LEDGER, and CHANGELOG when TASK-0019 is complete.

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
