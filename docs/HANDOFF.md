# Current Handoff

## Handoff ID
HANDOFF-0060

## Current Task
TASK-0040-Software-Inventory-And-Placement-Implementation

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
TASK-0047 completed status-bar indicators and chrome cleanup.

TASK-0044 completed GUI tab performance hardening.

TASK-0053 completed the required Task System counter audit.

TASK-0043 completed the Settings-page client data transfer workflow.

TASK-0051 completed the deployment/update development-file exclusion slice.

Implementation work may continue under the single active task: TASK-0040 Software Inventory And Placement Implementation.

Do not modify ARGUS, HEPHAESTUS, deployment logic, package installation semantics, or unrelated application areas unless the active task explicitly requires it.
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
| Repository Governance | 3 / 10 | No |
| Architecture | 1 / 10 | No |
| Documentation | 8 / 10 | No |
| Task System | 3 / 10 | No |
| HEPHAESTUS | 3 / 10 | No |
| ARGUS | 2 / 10 | No |
| Reporting | 1 / 10 | No |
| UI | 8 / 10 | No |
| Plugin Framework | 1 / 10 | No |
| Build System | 8 / 10 | No |
| Validation/Test Framework | 5 / 10 | No |
| Roadmap/Backlog | 1 / 10 | No |

## Current State
The GitHub remote is configured as `https://github.com/jstultz1980-beep/ComputerTriage.git`. The local `master` branch tracks `origin/master`.

Foundation governance has been reconciled. `docs/HANDOFF.md` and `docs/TASKS/QUEUE.md` agree on exactly one active task.

Recently completed work:
- TASK-0045 completed Print page polish.
- TASK-0050 completed the required Roadmap/Backlog audit after outstanding tasks were consolidated.
- TASK-0046 completed Triage page catalog and bundle cleanup.
- TASK-0052 completed the required Documentation audit after TASK-0046/build metadata updates reached 10/10.
- TASK-0047 completed status-bar Wi-Fi, Wi-Fi page signal, Windows Update service health, and busy indicator clarification.
- TASK-0043 completed Settings-page client data transfer with destination validation, merge confirmation, client-data-only copying, and manifest output.
- TASK-0051 completed shared development-file deployment exclusions and validated fake fresh deployment/update scenarios.

Current active work:
- TASK-0040 is active for Software tab launchable/installable placement and portable-tool classification.

Queued implementation/design work, in recommended order:
- TASK-0040 Software Inventory And Placement Implementation.
- TASK-0033 Tab-By-Tab Direction And Embedding Plan.
- TASK-0021 HEPHAESTUS Rule Catalog Expansion.

## Active Task
`TASK-0040-Software-Inventory-And-Placement-Implementation`

Scope summary:
- Put launchable portable applications at the top of the Software tab.
- Reserve the bottom area for installable programs stored in the toolkit.
- Classify optional portable tools, including LatencyMon.
- Answer whether Registrar Registry Manager can be used portably.
- Remove non-portable tools from launchable triage lists.

## Queued Work
- `TASK-0040-Software-Inventory-And-Placement-Implementation` owned by Codex.
- `TASK-0033-Tab-By-Tab-Direction-And-Embedding-Plan` owned by Codex.
- `TASK-0021-HEPHAESTUS-Rule-Catalog-Expansion` owned by Codex.

## Validation Completed For This Update
- Consolidated outstanding tasks into a smaller logical sequence.
- Completed TASK-0046 Triage Page Catalog And Bundle Cleanup.
- Completed TASK-0052 Documentation Counter Audit and reset only the Documentation counter to `0 / 10`.
- Activated TASK-0044 as the single active task.
- Added TASK-0051 for development-only deployment/update exclusions.
- Added the Build Metadata Rule to `PROJECT.md`.
- Updated `App/manifests/toolkit-version.json` through `App/Update-ToolkitVersion.ps1`.
- PowerShell parser validation passed for:
  - `App/ToolKit-GUI/ToolKit-GUI.ps1`
  - `App/NetworkToolkit/Utilities/TriageService.ps1`
- Direct triage setup validation passed via `TriageService.ps1`.
- GUI smoke test passed via `App/NetworkToolkit.ps1 -SmokeTest`.
- Button smoke test passed via `App/NetworkToolkit.ps1 -ButtonSmokeTest`.
- Activated TASK-0047 for the requested status-bar version/build placement slice.
- Moved toolkit version/build to the bottom-left status bar and removed the duplicate Settings-page version display.
- Updated toolkit build metadata through `App/Update-ToolkitVersion.ps1`.
- PowerShell parser validation, GUI smoke test, and button-smoke test passed for the TASK-0047 slice.
- Fixed header summary clipping so the `Computer` label no longer renders under the title block.
- Reworked Settings and Help as compact dedicated header icon controls.
- Updated `punch_list.txt` with Markdown-style strike-through for completed items.
- Added new punch-list items for first-render tab lag, `NetworkToolkit.vbs` launch delay, and GitHub sync policy.
- Added the GitHub Sync Rule to `PROJECT.md`; routine work should be committed locally but not pushed until the 10-change audit/refactor checkpoint unless explicitly requested.
- Moved queued TASK-0033 ownership from ChatGPT to Codex while ChatGPT is not in use.
- Updated toolkit build metadata through `App/Update-ToolkitVersion.ps1`.
- Added a status-bar Wi-Fi indicator with connected/off/unknown handling.
- Added a compact Wi-Fi signal label to the Wi-Fi page.
- Added a compact Windows Update service-health label to the Windows Update page.
- Clarified the busy progress indicator purpose and prevented Wi-Fi probing from leaking `netsh` exit codes into smoke tests.
- Completed TASK-0047 and activated TASK-0044 as the single active task.
- Read `punch_list.txt` before TASK-0044 work and confirmed items 13 and 14 map to the active performance task.
- Updated `PROJECT.md` so `punch_list.txt` is read before implementation and re-read before completion.
- Deferred normal GUI startup tab construction until after the form shell is shown.
- Deferred startup Wi-Fi probing until after the form is shown.
- Deferred Activity page CIM/process refresh until after the Activity tab paints.
- Added GUI startup shell timing diagnostics.
- Updated `NetworkToolkit.vbs` to use `-NoLogo` and `-NonInteractive` while preserving hidden elevated launch behavior.
- Updated toolkit build metadata through `App/Update-ToolkitVersion.ps1`.
- PowerShell parser validation, GUI smoke test, and button-smoke test passed for the TASK-0044 startup performance slice.
- Punch-list item 27 is covered by active TASK-0044.
- Remaining punch-list items 16-26 and 28 are Windows Update/Wi-Fi/Settings/Triage/header/control-polish follow-ups and should be reconciled after TASK-0044 or at the next audit/task planning checkpoint.
- Added shared slow tab-switch/build diagnostics with status-bar feedback.
- Completed TASK-0044 and marked punch-list items 4, 13, 14, and 27 complete.
- PowerShell parser validation, GUI smoke test, and button-smoke test passed after the final slow-tab diagnostics pass.
- Activated TASK-0053 because the Task System counter reached `10 / 10`.
- Completed TASK-0053 and reset only the Task System counter.
- Activated TASK-0043 as the next implementation task.
- Completed TASK-0043 with a reusable client-data transfer helper and Settings-page transfer workflow.
- Activated TASK-0051 as the next implementation task.
- Completed TASK-0051 with a shared deployment exclusion helper, deployment inventory, and fake deployment/update validation.
- Activated TASK-0040 as the next implementation task.

## Blockers
No audit gate is currently blocking implementation.

Known working-tree drift remains excluded unless a future task explicitly owns it.

## Notes for Next AI
Known working-tree noise:
- `App/NetworkToolkit/LatencyMon/` is an untracked local tool folder and should not be deleted, imported, or committed unless a future task explicitly handles it.
- Runtime custom-tool provenance migration can add timestamp and package metadata drift to `App/manifests/custom-tools.json` during GUI validation. Reset that runtime drift before committing unless the active task explicitly changes the shipped manifest.
- `docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md` has shown local stale/locked drift during ARGUS work. Do not stage it unless a future task explicitly updates the accepted ADR.

GitHub sync note:
- Do not push routine task commits to GitHub unless the user explicitly asks. GitHub sync should happen during the 10-change audit/refactor checkpoint.

## Recommended Commit Message
```text
TASK-0051: Exclude development files from deployment
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
7. docs/TASKS/TASK-0040-Software-Inventory-And-Placement-Implementation.md
8. punch_list.txt if it exists, then reconcile new requests into existing tab-based tasks before changing code.

Current task state:
- docs/HANDOFF.md and docs/TASKS/QUEUE.md list exactly one Active task.
- Active task: TASK-0040-Software-Inventory-And-Placement-Implementation.
- Owner: Codex.
- TASK-0051 completed development-file deployment exclusions and activated TASK-0040.
- Next queued implementation tasks after TASK-0040 are TASK-0033 and TASK-0021.
- `punch_list.txt` must be read after each task so new change requests are consolidated into existing tab-based tasks where possible.
- `punch_list.txt` must also be read before each implementation run so random notes are reconciled into existing tasks before code changes begin.
- Every accepted implementation change must update `App/manifests/toolkit-version.json` using `App/Update-ToolkitVersion.ps1` unless the active task explicitly changes versioning behavior.
- Do not push routine task commits to GitHub unless the user explicitly asks. GitHub sync should happen during the 10-change audit/refactor checkpoint.

Your job:
Execute TASK-0040 only.

Scope:
- Put launchable portable applications at the top of the Software tab.
- Reserve the bottom area for installable programs stored in the toolkit.
- Classify optional portable tools, including LatencyMon, without importing untracked tools unless explicitly in scope.
- Research whether a usable portable edition of Registrar Registry Manager exists.
- Remove non-portable tools from launchable triage lists.
- Keep installable tools visible without implying they are portable launchers.

Do not:
- Modify ARGUS or HEPHAESTUS.
- Change package installation semantics, deployment, or unrelated GUI areas.
- Download or install tools.
- Refactor or modify application code.
- Clean unrelated files.
- Import, delete, or modify untracked App/NetworkToolkit/LatencyMon/ unless a future task explicitly handles it.
- Use chat history as source of truth unless the same information exists in the repository.

Validation expectations:
- Software tab launchable/installable placement is implemented.
- Optional portable tools are classified.
- Registrar Registry Manager portability is answered with source notes.
- Non-portable tools no longer appear as launchable triage tools.
- PowerShell parse, smoke, and button-smoke validation pass.

When done, provide:
- Concise summary of implementation performed.
- Exact files changed.
- Validation performed.
- Test This list for the user.
- Current active task.
- Current owner and next owner.
- Recommended commit message.
```
