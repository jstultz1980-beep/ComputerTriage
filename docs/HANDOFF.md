# Current Handoff

## Handoff ID
HANDOFF-0063

## Current Task
TASK-0054-Directory-Domain-Status-Page

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

Implementation work may resume under the single active task: TASK-0054 Directory Domain Status Page.

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
| Documentation | 0 / 10 | No |
| Task System | 6 / 10 | No |
| HEPHAESTUS | 3 / 10 | No |
| ARGUS | 2 / 10 | No |
| Reporting | 1 / 10 | No |
| UI | 9 / 10 | No |
| Plugin Framework | 1 / 10 | No |
| Build System | 0 / 10 | No |
| Validation/Test Framework | 6 / 10 | No |
| Roadmap/Backlog | 3 / 10 | No |

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

Current active work:
- TASK-0054 is active for Directory domain identity and AD health status.

Queued implementation/design work, in recommended order:
- TASK-0055 Shared Embedded Output Pattern.
- TASK-0056 Triage Guided Workflow Polish.
- TASK-0057 Wi-Fi And Windows Status Polish.
- TASK-0058 Settings And Control Polish.
- TASK-0021 HEPHAESTUS Rule Catalog Expansion.

## Active Task
`TASK-0054-Directory-Domain-Status-Page`

Scope summary:
- Turn the Directory tab into an Active Directory and domain identity status page instead of a simple launcher page.
- Show domain join state, current domain, logon DC, secure channel status, and AD site when available.
- Add DNS SRV domain-controller lookup status.
- Keep GPO report access visible.
- Avoid duplicating generic Network or Infrastructure troubleshooting.
- Reuse existing Domain Logon Health and GPO Health logic where practical.

## Queued Work
- `TASK-0055-Shared-Embedded-Output-Pattern` owned by Codex.
- `TASK-0056-Triage-Guided-Workflow-Polish` owned by Codex.
- `TASK-0057-WiFi-And-Windows-Status-Polish` owned by Codex.
- `TASK-0058-Settings-And-Control-Polish` owned by Codex.
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

## Blockers
No active audit gate. Implementation may continue under TASK-0054 only.

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
TASK-0059: Complete documentation and build audit
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
7. docs/TASKS/TASK-0054-Directory-Domain-Status-Page.md
8. punch_list.txt if it exists, then reconcile new requests into existing tab-based tasks before changing code.

Current task state:
- docs/HANDOFF.md and docs/TASKS/QUEUE.md list exactly one Active task.
- Active task: TASK-0054-Directory-Domain-Status-Page.
- Owner: Codex.
- TASK-0059 completed the required Documentation and Build System counter audit after TASK-0033.
- Documentation and Build System counters were reset to `0 / 10`.
- Next queued implementation tasks after TASK-0054 are TASK-0055 through TASK-0058, then TASK-0021.
- `punch_list.txt` must be read after each task so new change requests are consolidated into existing tab-based tasks where possible.
- `punch_list.txt` must also be read before each implementation run so random notes are reconciled into existing tasks before code changes begin.
- Every accepted implementation change must update `App/manifests/toolkit-version.json` using `App/Update-ToolkitVersion.ps1` unless the active task explicitly changes versioning behavior.
- Do not push routine task commits to GitHub unless the user explicitly asks. GitHub sync should happen during the 10-change audit/refactor checkpoint.

Your job:
Execute TASK-0054 only.

Scope:
- Turn the Directory tab into an Active Directory and domain identity status page instead of a simple launcher page.
- Show domain join state, current domain, logon DC, secure channel status, and AD site when available.
- Add DNS SRV domain-controller lookup status.
- Keep GPO report access visible.
- Avoid duplicating generic Network or Infrastructure troubleshooting.
- Reuse existing Domain Logon Health and GPO Health logic where practical.

Do not:
- Modify ARGUS or HEPHAESTUS.
- Change package installation semantics, deployment, or unrelated GUI areas.
- Download or install tools.
- Modify unrelated application code.
- Clean unrelated files.
- Import, delete, or modify untracked App/NetworkToolkit/LatencyMon/ unless a future task explicitly handles it.
- Use chat history as source of truth unless the same information exists in the repository.

Validation expectations:
- Directory has a clear AD/domain status summary.
- Directory does not duplicate Network or Infrastructure checks.
- Domain Logon Health and GPO Health remain available.
- Status failures are visible without opening an external console.
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
