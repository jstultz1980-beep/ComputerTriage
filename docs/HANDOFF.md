# Current Handoff

## Handoff ID
HANDOFF-0068

## Current Task
TASK-0056-Triage-Guided-Workflow-Polish

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

TASK-0040 completed the Software tab launchable/installable placement and portable-tool classification slice.

TASK-0033 completed tab-by-tab direction and embedded-tool planning.

TASK-0059 completed the required Documentation and Build System counter audit.

TASK-0054 completed the Directory domain identity and AD health status page.

The audit threshold was raised from 10 changes to 25 changes. TASK-0060 was archived before execution because UI is now `10 / 25`, not at the audit threshold.

`Next 25` is now a project prompt shortcut for reading source-of-truth files, reconciling new punch-list additions into tasks, reordering the queue, completing tasks until the next 25-change audit gate, holding the full user test list until stopped, committing locally, and not pushing unless explicitly requested.

TASK-0061 completed Directory page layout polish.

TASK-0055 completed the shared embedded output pattern and converted Quick Target Checks to use it.

Implementation work may resume under the single active task: TASK-0056 Triage Guided Workflow Polish.

Do not modify ARGUS, HEPHAESTUS, deployment logic, package installation semantics, or unrelated application areas unless the active task explicitly requires it.
Do not download or install tools.
Do not clean unrelated files.
Do not import, delete, or modify untracked `App/NetworkToolkit/LatencyMon/` unless a future task explicitly handles it.

## Audit State Tracking
Each subsystem has its own change counter.

When any subsystem reaches `25 / 25` recorded subsystem changes, work must pause and a new audit task must be completed before further implementation work continues.

Change records are tracked in:

```text
docs/HISTORY/CHANGE-LEDGER.md
```

## Audit Counters

| Subsystem | Changes Since Last Audit | Audit Required |
|---|---:|---|
| Repository Governance | 5 / 25 | No |
| Architecture | 1 / 25 | No |
| Documentation | 3 / 25 | No |
| Task System | 10 / 25 | No |
| HEPHAESTUS | 3 / 25 | No |
| ARGUS | 2 / 25 | No |
| Reporting | 1 / 25 | No |
| UI | 12 / 25 | No |
| Plugin Framework | 1 / 25 | No |
| Build System | 3 / 25 | No |
| Validation/Test Framework | 9 / 25 | No |
| Roadmap/Backlog | 6 / 25 | No |

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
- TASK-0040 completed Software tab launchable/installable placement, Registrar classification, triage manifest cleanup, and LatencyMon classification.
- TASK-0033 completed tab-by-tab direction and embedded-tool planning, created follow-on implementation tasks, and activated the audit gate.
- TASK-0059 completed the required Documentation and Build System counter audit after TASK-0033.
- TASK-0054 completed Directory domain identity and AD health status, then activated the next UI audit gate.
- TASK-0061 completed Directory page layout polish and reconciled new punch-list items into queued tasks.
- TASK-0055 completed the shared embedded output pattern and converted Quick Target Checks to use it.

Current active work:
- TASK-0056 is active for Triage guided workflow polish.

Queued implementation/design work, in recommended order:
- TASK-0057 Wi-Fi And Windows Status Polish.
- TASK-0058 Settings And Control Polish.
- TASK-0062 Computer Data Push Pull.
- TASK-0063 Add Ons Concept.
- TASK-0064 Product Naming Options.
- TASK-0021 HEPHAESTUS Rule Catalog Expansion.

## Active Task
`TASK-0056-Triage-Guided-Workflow-Polish`

Scope summary:
- Keep Quick Triage and Full Triage as the primary actions.
- Remove or de-emphasize Technician Notes.
- Replace catalog-heavy layout with concise workflow instructions.
- Preserve access to latest run and bundle folder.
- Ensure triage bundles remain descriptively named.

## Queued Work
- `TASK-0057-WiFi-And-Windows-Status-Polish` owned by Codex.
- `TASK-0058-Settings-And-Control-Polish` owned by Codex.
- `TASK-0062-Computer-Data-Push-Pull` owned by Codex.
- `TASK-0063-Add-Ons-Concept` owned by Codex.
- `TASK-0064-Product-Naming-Options` owned by Codex.
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
- Completed TASK-0040 with Software tab launchable/installable placement, Registrar classification, triage manifest cleanup, and LatencyMon classification.
- Added `docs/SOFTWARE-TOOL-CLASSIFICATION.md` with source notes for Registrar and triage tool classification.
- Removed Registrar Registry Manager from the Repair-tab launch catalog because only the installer is currently present.
- Removed Sysinternals Suite and WinAudit from the default and current triage manifests.
- Updated toolkit build metadata through `App/Update-ToolkitVersion.ps1`.
- PowerShell parser validation, GUI smoke test, button-smoke test, and triage-manifest validation passed for TASK-0040.
- Activated TASK-0033 as the next implementation task.
- Completed TASK-0033 with a tab-by-tab direction and embedding plan.
- Added `docs/DESIGN/TAB-BY-TAB-EMBEDDING-PLAN.md`.
- Created follow-on tasks TASK-0054 through TASK-0058.
- Created and activated TASK-0059 because Documentation and Build System counters reached `10 / 10`.
- Re-read `punch_list.txt` before completing TASK-0033.
- Completed TASK-0059 and reset only the Documentation and Build System counters.
- Activated TASK-0054 as the next implementation task.
- Consolidated remaining punch-list work into TASK-0055 through TASK-0058 and TASK-0021.
- Completed TASK-0054 Directory Domain Status Page.
- Updated toolkit build metadata through `App/Update-ToolkitVersion.ps1`.
- PowerShell parser validation passed for `App/ToolKit-GUI/ToolKit-GUI.ps1` and `App/NetworkToolkit.ps1`.
- GUI smoke test passed via `App/NetworkToolkit.ps1 -SmokeTest`.
- Button smoke test passed via `App/NetworkToolkit.ps1 -ButtonSmokeTest`.
- Activated TASK-0060 because the UI counter reached `10 / 10`.
- Raised the audit threshold from 10 changes to 25 changes.
- Archived TASK-0060 before execution because UI is now `10 / 25`.
- Added TASK-0061 for Directory page layout feedback from punch-list items 30 and 31.
- Activated TASK-0061 as the next implementation task.
- Added the `Next 25` prompt shortcut rule to `PROJECT.md`.
- Corrected forward-looking audit reset wording to `0 / 25`.
- Reconciled punch-list items 32, 33, and 34 into TASK-0062, TASK-0063, and TASK-0064.
- Completed TASK-0061 Directory Page Layout Polish.
- Marked punch-list items 30 and 31 complete.
- Updated toolkit build metadata through `App/Update-ToolkitVersion.ps1`.
- PowerShell parser validation passed for `App/ToolKit-GUI/ToolKit-GUI.ps1` and `App/NetworkToolkit.ps1`.
- GUI smoke test passed via `App/NetworkToolkit.ps1 -SmokeTest`.
- Button smoke test passed via `App/NetworkToolkit.ps1 -ButtonSmokeTest`.
- Activated TASK-0055 as the next implementation task.
- Completed TASK-0055 Shared Embedded Output Pattern.
- Added reusable embedded command-output helpers and converted Quick Target Checks to use them.
- Updated toolkit build metadata through `App/Update-ToolkitVersion.ps1`.
- PowerShell parser validation passed for `App/ToolKit-GUI/ToolKit-GUI.ps1` and `App/NetworkToolkit.ps1`.
- GUI smoke test passed via `App/NetworkToolkit.ps1 -SmokeTest`.
- Button smoke test passed via `App/NetworkToolkit.ps1 -ButtonSmokeTest`.
- Activated TASK-0056 as the next implementation task.

## Blockers
No active audit gate. Implementation may continue under TASK-0056 only.

Known working-tree drift remains excluded unless a future task explicitly owns it.

## Notes for Next AI
Known working-tree noise:
- `App/NetworkToolkit/LatencyMon/` is an untracked local tool folder and should not be deleted, imported, or committed unless a future task explicitly handles it.
- Runtime custom-tool provenance migration can add timestamp and package metadata drift to `App/manifests/custom-tools.json` during GUI validation. Reset that runtime drift before committing unless the active task explicitly changes the shipped manifest.
- `docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md` has shown local stale/locked drift during ARGUS work. Do not stage it unless a future task explicitly updates the accepted ADR.

GitHub sync note:
- Do not push routine task commits to GitHub unless the user explicitly asks. GitHub sync should happen during the 25-change audit/refactor checkpoint.

## Recommended Commit Message
```text
TASK-0055: Add shared embedded output helper
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
7. docs/TASKS/TASK-0056-Triage-Guided-Workflow-Polish.md
8. punch_list.txt if it exists, then reconcile new requests into existing tab-based tasks before changing code.

Current task state:
- docs/HANDOFF.md and docs/TASKS/QUEUE.md list exactly one Active task.
- Active task: TASK-0056-Triage-Guided-Workflow-Polish.
- Owner: Codex.
- TASK-0054 completed the Directory domain identity and AD health status page.
- Audit threshold is now `25 / 25`; UI is `10 / 25`, so no audit is currently required.
- TASK-0060 was archived before execution because the raised threshold cleared the gate.
- `Next 25` is a project prompt shortcut for source-of-truth startup, punch-list reconciliation, task reordering, implementation through the next 25-change audit gate, deferred user testing, local commits, and no push unless explicitly requested.
- TASK-0061 completed Directory page layout polish.
- New punch-list items 32, 33, and 34 are queued as TASK-0062, TASK-0063, and TASK-0064.
- TASK-0055 completed the shared embedded output pattern and converted Quick Target Checks to use it.
- Next queued implementation tasks after TASK-0056 are TASK-0057, TASK-0058, TASK-0062, TASK-0063, TASK-0064, then TASK-0021.
- `punch_list.txt` must be read after each task so new change requests are consolidated into existing tab-based tasks where possible.
- `punch_list.txt` must also be read before each implementation run so random notes are reconciled into existing tasks before code changes begin.
- Every accepted implementation change must update `App/manifests/toolkit-version.json` using `App/Update-ToolkitVersion.ps1` unless the active task explicitly changes versioning behavior.
- Do not push routine task commits to GitHub unless the user explicitly asks. GitHub sync should happen during the 25-change audit/refactor checkpoint.

Your job:
Execute TASK-0056 only.

Scope:
- Keep Quick Triage and Full Triage as the primary actions.
- Remove or de-emphasize Technician Notes.
- Replace catalog-heavy layout with concise workflow instructions.
- Preserve access to latest run and bundle folder.
- Ensure triage bundles remain descriptively named.

Do not:
- Modify ARGUS or HEPHAESTUS.
- Change package installation semantics, deployment, or unrelated GUI areas.
- Download or install tools.
- Modify unrelated application code.
- Clean unrelated files.
- Import, delete, or modify untracked App/NetworkToolkit/LatencyMon/ unless a future task explicitly handles it.
- Use chat history as source of truth unless the same information exists in the repository.

Validation expectations:
- Triage tab presents a clear run, bundle, submit flow.
- Technician Notes no longer waste page space.
- Tool catalog noise is reduced or hidden from normal workflow.
- Parser, smoke, and button-smoke validation pass.

When done, provide:
- Concise summary of implementation performed.
- Exact files changed.
- Validation performed.
- Test This list for the user.
- Current active task.
- Current owner and next owner.
- Recommended commit message.
```
