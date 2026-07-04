# Current Handoff

## Handoff ID
HANDOFF-0050

## Current Task
TASK-0046-Triage-Page-Catalog-And-Bundle-Cleanup

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
TASK-0042 completed the mandatory Documentation Counter Audit after the Documentation counter reached `10 / 10`.

Implementation work may resume under the single active task: TASK-0046 Triage Page Catalog And Bundle Cleanup.

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
| Repository Governance | 0 / 10 | No |
| Architecture | 1 / 10 | No |
| Documentation | 6 / 10 | No |
| Task System | 2 / 10 | No |
| HEPHAESTUS | 3 / 10 | No |
| ARGUS | 2 / 10 | No |
| Reporting | 0 / 10 | No |
| UI | 1 / 10 | No |
| Plugin Framework | 1 / 10 | No |
| Build System | 0 / 10 | No |
| Validation/Test Framework | 3 / 10 | No |
| Roadmap/Backlog | 9 / 10 | No |

## Current State
The GitHub remote is configured as `https://github.com/jstultz1980-beep/ComputerTriage.git`. The local `master` branch tracks `origin/master`.

Foundation governance has been reconciled. `docs/HANDOFF.md` and `docs/TASKS/QUEUE.md` agree on exactly one active task.

Recently completed work:
- TASK-0028 completed focused Quick Dx run-panel cleanup.
- TASK-0029 completed focused Choco page layout refinement.
- TASK-0041 completed the UI counter audit and reset the audited UI counter.
- TASK-0037 completed Activity page running-tool tracking.
- TASK-0030 completed Print tab data-path cleanup.
- TASK-0031 completed Triage page simplification.
- TASK-0042 completed the mandatory Documentation Counter Audit and reset the audited Documentation counter.

Current active work:
- TASK-0046 is active for Triage page catalog and bundle cleanup.

Queued implementation/design work:
- TASK-0021 HEPHAESTUS Rule Catalog Expansion.
- TASK-0022 HEPHAESTUS Portable Tool Classification.
- TASK-0033 Directory Tab Direction And Embedding Plan.
- TASK-0034 Embedded Tool Experience Roadmap.
- TASK-0036 Page Health Indicators.
- TASK-0039 Software Tab Launchable And Installable Inventory.
- TASK-0040 Software Tab Launchable And Installable Implementation.
- TASK-0043 Client Data Transfer.
- TASK-0044 GUI Tab Performance Hardening.
- TASK-0045 Print Page Polish.
- TASK-0047 Status Bar Wi-Fi And Chrome Cleanup.

## Active Task
`TASK-0046-Triage-Page-Catalog-And-Bundle-Cleanup`

Scope summary:
- Move `Quick Triage` and `Full Triage` buttons out of the surrounding box and place them across the top of the tab.
- Move visible triage status into the status bar instead of a large page block.
- Clean the Triage tool catalog by removing Sysinternals, duplicate apps, and non-working/non-portable WinAudit if necessary.
- Decide whether `Export Manifest` should remain visible.
- Make triage bundle names more descriptive.

## Queued Work
- `TASK-0021-HEPHAESTUS-Rule-Catalog-Expansion` owned by Codex.
- `TASK-0022-HEPHAESTUS-Portable-Tool-Classification` owned by ChatGPT.
- `TASK-0033-Directory-Tab-Direction-And-Embedding-Plan` owned by ChatGPT.
- `TASK-0034-Embedded-Tool-Experience-Roadmap` owned by ChatGPT.
- `TASK-0036-Page-Health-Indicators` owned by Codex.
- `TASK-0039-Software-Tab-Launchable-And-Installable-Inventory` owned by ChatGPT.
- `TASK-0040-Software-Tab-Launchable-And-Installable-Implementation` owned by Codex.
- `TASK-0043-Client-Data-Transfer` owned by Codex.
- `TASK-0044-GUI-Tab-Performance-Hardening` owned by Codex.
- `TASK-0045-Print-Page-Polish` owned by Codex.
- `TASK-0047-Status-Bar-WiFi-And-Chrome-Cleanup` owned by Codex.

## Validation Completed For This Update
- Completed TASK-0042 Documentation Counter Audit.
- Verified `docs/HANDOFF.md` and `docs/TASKS/QUEUE.md` had exactly one active task before audit closeout.
- Reset only the Documentation counter to `0 / 10`.
- Reactivated TASK-0032 as the next focused implementation task.
- Added TASK-0043 for client-data transfer between toolkit copies.
- Added TASK-0044 for Activity first-load and tab-switch performance hardening.
- Added the 2026-07-03 outstanding task audit for the latest punch-list.
- Updated TASK-0032 with the refined Computer tab layout request.
- Updated TASK-0038 with Settings/Help header-control cleanup.
- Updated TASK-0044 with the first-time Activity tab lag report.
- Added TASK-0045 for Print page polish.
- Added TASK-0046 for Triage page catalog and bundle cleanup.
- Added TASK-0047 for status-bar Wi-Fi and bottom-right chrome cleanup.
- Implemented the TASK-0032 Computer tab summary redesign pass.
- Validated GUI PowerShell parse, toolkit smoke, and button-smoke checks.
- Read `punch_list.txt` after TASK-0032.
- Consolidated the smaller-crown request into TASK-0038.
- Completed TASK-0032 and the mandatory TASK-0048 Task System Counter Audit.
- Reset only the Task System counter.
- Activated TASK-0038 as the next implementation task.
- Completed TASK-0038 Modern Control Style System.
- Completed TASK-0045 Print Page Polish.
- Completed TASK-0049 UI Counter Audit and reset only the UI counter.
- Activated TASK-0046 as the next implementation task.
- Applied a TASK-0032 follow-up correction so the Computer tab profile strip no longer clips below the summary.
- Updated task, queue, roadmap, changelog, ledger, and handoff.

## Blockers
No audit gate is currently blocking implementation. Known working-tree drift remains excluded unless a future task explicitly owns it.

## Notes for Next AI
Known working-tree noise:
- `App/NetworkToolkit/LatencyMon/` is an untracked local tool folder and should not be deleted, imported, or committed unless a future task explicitly handles it.
- Runtime custom-tool provenance migration can add timestamp and package metadata drift to `App/manifests/custom-tools.json` during GUI validation. Reset that runtime drift before committing unless the active task explicitly changes the shipped manifest.
- `docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md` has shown local stale/locked drift during ARGUS work. Do not stage it unless a future task explicitly updates the accepted ADR.

## Recommended Commit Message
```text
TASK-0042: Complete documentation counter audit
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
7. docs/TASKS/TASK-0046-Triage-Page-Catalog-And-Bundle-Cleanup.md
8. punch_list.txt if it exists, then reconcile new requests into existing tab-based tasks before changing code.

Current task state:
- docs/HANDOFF.md and docs/TASKS/QUEUE.md list exactly one Active task.
- Active task: TASK-0046-Triage-Page-Catalog-And-Bundle-Cleanup.
- Owner: Codex.
- TASK-0032 completed the Computer tab summary redesign.
- TASK-0048 completed the Task System Counter Audit and reset the audited Task System counter.
- TASK-0038 completed header/control cleanup.
- TASK-0045 completed Print page polish.
- TASK-0049 completed the UI Counter Audit and reset the audited UI counter.
- TASK-0043 is queued for client-data transfer between toolkit copies.
- TASK-0044 is queued for Activity first-load and tab-switch performance hardening.
- TASK-0045 through TASK-0047 are queued for Print, Triage, and status-bar cleanup.
- `punch_list.txt` must be read after each task so new change requests are consolidated into existing tab-based tasks where possible.

Your job:
Execute TASK-0046 only.

Scope:
- Move Quick Triage and Full Triage out of the surrounding box and place them across the top of the tab.
- Remove the visible Triage status block and surface that status in the status bar instead.
- Remove Sysinternals entries from the Triage tool catalog.
- Make WinAudit work if it can run portably; otherwise remove it from the Triage tool catalog.
- Remove catalog applications that already live elsewhere in the toolkit.
- Decide whether Export Manifest is still useful; keep it only if the UI clearly explains its purpose.
- Make triage bundle names more descriptive for easier identification.

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
- Triage tab primary actions are top-level controls, not boxed inside a status area.
- Triage status is visible through the status bar.
- Triage catalog no longer lists Sysinternals or tools already represented elsewhere.
- WinAudit is either functional as a portable triage tool or removed.
- Triage bundle names include computer, triage type, and timestamp context.
- PowerShell parse, GUI smoke, button-smoke, and triage service validation pass.

When done, provide:
- Concise summary of implementation performed.
- Exact files changed.
- Validation performed.
- Current active task.
- Current owner and next owner.
- Recommended commit message.
```
