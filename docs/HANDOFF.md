# Current Handoff

## Handoff ID
HANDOFF-0054

## Current Task
TASK-0047-Status-Bar-Indicators-And-Chrome-Cleanup

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
TASK-0046 completed the Triage page catalog and bundle cleanup.

TASK-0052 completed the mandatory Documentation Counter Audit after TASK-0046/build metadata documentation reached the Documentation threshold.

Implementation work may resume under the single active task: TASK-0047 Status Bar Indicators And Chrome Cleanup.

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
| Repository Governance | 2 / 10 | No |
| Architecture | 1 / 10 | No |
| Documentation | 2 / 10 | No |
| Task System | 8 / 10 | No |
| HEPHAESTUS | 3 / 10 | No |
| ARGUS | 2 / 10 | No |
| Reporting | 1 / 10 | No |
| UI | 4 / 10 | No |
| Plugin Framework | 1 / 10 | No |
| Build System | 3 / 10 | No |
| Validation/Test Framework | 3 / 10 | No |
| Roadmap/Backlog | 1 / 10 | No |

## Current State
The GitHub remote is configured as `https://github.com/jstultz1980-beep/ComputerTriage.git`. The local `master` branch tracks `origin/master`.

Foundation governance has been reconciled. `docs/HANDOFF.md` and `docs/TASKS/QUEUE.md` agree on exactly one active task.

Recently completed work:
- TASK-0045 completed Print page polish.
- TASK-0050 completed the required Roadmap/Backlog audit after outstanding tasks were consolidated.
- TASK-0046 completed Triage page catalog and bundle cleanup.
- TASK-0052 completed the required Documentation audit after TASK-0046/build metadata updates reached 10/10.

Current active work:
- TASK-0047 is active for status-bar indicators and chrome cleanup.

Queued implementation/design work, in recommended order:
- TASK-0044 GUI Tab Performance Hardening.
- TASK-0043 Client Data Transfer.
- TASK-0051 Development File Deployment Exclusions.
- TASK-0040 Software Inventory And Placement Implementation.
- TASK-0033 Tab-By-Tab Direction And Embedding Plan.
- TASK-0021 HEPHAESTUS Rule Catalog Expansion.

## Active Task
`TASK-0047-Status-Bar-Indicators-And-Chrome-Cleanup`

Scope summary:
- Determine whether the small rectangle in the bottom-right status area serves a purpose.
- Add compact Wi-Fi signal-strength status where available.
- Add compact Windows Update service health on the Windows Update page.
- Keep unknown/unavailable indicators neutral/off.
- Keep indicators lightweight so they do not slow tab switching.
- Version/build placement in the bottom-left status bar is complete.

## Queued Work
- `TASK-0044-GUI-Tab-Performance-Hardening` owned by Codex.
- `TASK-0043-Client-Data-Transfer` owned by Codex.
- `TASK-0051-Development-File-Deployment-Exclusions` owned by Codex.
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
TASK-0047: Fix header chrome and status tracking
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
7. docs/TASKS/TASK-0047-Status-Bar-Indicators-And-Chrome-Cleanup.md
8. punch_list.txt if it exists, then reconcile new requests into existing tab-based tasks before changing code.

Current task state:
- docs/HANDOFF.md and docs/TASKS/QUEUE.md list exactly one Active task.
- Active task: TASK-0047-Status-Bar-Indicators-And-Chrome-Cleanup.
- Owner: Codex.
- TASK-0046 completed the Triage page catalog and bundle cleanup.
- TASK-0052 completed the Documentation Counter Audit and reset the audited Documentation counter.
- Next queued tasks after TASK-0047 are TASK-0044, TASK-0043, TASK-0051, TASK-0040, TASK-0033, and TASK-0021.
- `punch_list.txt` must be read after each task so new change requests are consolidated into existing tab-based tasks where possible.
- Every accepted implementation change must update `App/manifests/toolkit-version.json` using `App/Update-ToolkitVersion.ps1` unless the active task explicitly changes versioning behavior.
- Do not push routine task commits to GitHub unless the user explicitly asks. GitHub sync should happen during the 10-change audit/refactor checkpoint.

Your job:
Execute TASK-0047 only.

Scope:
- Determine whether the small rectangle in the bottom-right status area serves a purpose.
- Remove the bottom-right rectangle if it is decorative or unused; if it has a purpose, make it obvious.
- Add compact Wi-Fi signal strength to the bottom-right status bar area.
- Show both icon-style strength and numerical strength where available.
- Add compact Windows Update service health to the Windows Update page.
- Add compact Wi-Fi signal strength to the Wi-Fi page when useful.
- Keep indicators neutral/off when unknown or unavailable.
- Preserve the completed bottom-left version/build status-bar label.

Do not:
- Modify ARGUS or HEPHAESTUS.
- Change package installation semantics, deployment, or unrelated GUI areas.
- Download or install tools.
- Refactor unrelated application code.
- Clean unrelated files.
- Import, delete, or modify untracked App/NetworkToolkit/LatencyMon/ unless a future task explicitly handles it.
- Use chat history as source of truth unless the same information exists in the repository.

Validation expectations:
- PowerShell parse check passes for the GUI script.
- GUI smoke test passes.
- Button-smoke test passes.
- Bottom-right status-bar rectangle is either removed or has an obvious purpose.
- Wi-Fi signal strength appears in the status bar when available.
- Windows Update page shows compact service health.
- Indicators do not slow tab switching.

When done, provide:
- Concise summary of implementation performed.
- Exact files changed.
- Validation performed.
- Test This list for the user.
- Current active task.
- Current owner and next owner.
- Recommended commit message.
```
