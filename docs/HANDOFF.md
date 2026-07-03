# Current Handoff

## Handoff ID
HANDOFF-0048

## Current Task
TASK-0032-Computer-Tab-Summary-Redesign

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

Implementation work may resume under the single active task: TASK-0032 Computer Tab Summary Redesign.

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
| Documentation | 1 / 10 | No |
| Task System | 9 / 10 | No |
| HEPHAESTUS | 3 / 10 | No |
| ARGUS | 2 / 10 | No |
| Reporting | 0 / 10 | No |
| UI | 7 / 10 | No |
| Plugin Framework | 1 / 10 | No |
| Build System | 0 / 10 | No |
| Validation/Test Framework | 3 / 10 | No |
| Roadmap/Backlog | 8 / 10 | No |

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
- TASK-0032 is active for Computer tab summary redesign.

Queued implementation/design work:
- TASK-0021 HEPHAESTUS Rule Catalog Expansion.
- TASK-0022 HEPHAESTUS Portable Tool Classification.
- TASK-0033 Directory Tab Direction And Embedding Plan.
- TASK-0034 Embedded Tool Experience Roadmap.
- TASK-0036 Page Health Indicators.
- TASK-0038 Modern Control Style System.
- TASK-0039 Software Tab Launchable And Installable Inventory.
- TASK-0040 Software Tab Launchable And Installable Implementation.
- TASK-0043 Client Data Transfer.
- TASK-0044 GUI Tab Performance Hardening.
- TASK-0045 Print Page Polish.
- TASK-0046 Triage Page Catalog And Bundle Cleanup.
- TASK-0047 Status Bar Wi-Fi And Chrome Cleanup.

## Active Task
`TASK-0032-Computer-Tab-Summary-Redesign`

Scope summary:
- Replace the computer profile list with a richer current-computer summary.
- Add LED-style status indicators next to status-changing summary items.
- Preserve profile report access without keeping the old profile list as the main Computer tab experience.

## Queued Work
- `TASK-0021-HEPHAESTUS-Rule-Catalog-Expansion` owned by Codex.
- `TASK-0022-HEPHAESTUS-Portable-Tool-Classification` owned by ChatGPT.
- `TASK-0033-Directory-Tab-Direction-And-Embedding-Plan` owned by ChatGPT.
- `TASK-0034-Embedded-Tool-Experience-Roadmap` owned by ChatGPT.
- `TASK-0036-Page-Health-Indicators` owned by Codex.
- `TASK-0038-Modern-Control-Style-System` owned by Codex.
- `TASK-0039-Software-Tab-Launchable-And-Installable-Inventory` owned by ChatGPT.
- `TASK-0040-Software-Tab-Launchable-And-Installable-Implementation` owned by Codex.
- `TASK-0043-Client-Data-Transfer` owned by Codex.
- `TASK-0044-GUI-Tab-Performance-Hardening` owned by Codex.
- `TASK-0045-Print-Page-Polish` owned by Codex.
- `TASK-0046-Triage-Page-Catalog-And-Bundle-Cleanup` owned by Codex.
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
7. docs/TASKS/TASK-0032-Computer-Tab-Summary-Redesign.md

Current task state:
- docs/HANDOFF.md and docs/TASKS/QUEUE.md list exactly one Active task.
- Active task: TASK-0032-Computer-Tab-Summary-Redesign.
- Owner: Codex.
- TASK-0042 completed the Documentation Counter Audit and reset the audited Documentation counter.
- TASK-0043 is queued for client-data transfer between toolkit copies.
- TASK-0044 is queued for Activity first-load and tab-switch performance hardening.
- TASK-0045 through TASK-0047 are queued for Print, Triage, and status-bar cleanup.
- Task System counter is now `9 / 10`; avoid unnecessary task-state churn.

Your job:
Execute TASK-0032 only.

Scope:
- Replace the Computer tab profile list with a current-computer summary.
- Make the current-computer summary larger and more useful.
- Reduce the profile table to approximately three visible rows rather than letting it dominate the tab.
- Preserve a compact action for opening/viewing the HTML profile report.
- Add Green/Yellow/Red LED-style bulbs beside summary fields that can have status.
- Use an unlit/neutral bulb when the area has not been scanned.
- Add more useful top-level computer identity and health information without dumping verbose raw inventory.

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
- Computer tab opens without excessive layout lag or control clipping.

When done, provide:
- Concise summary of implementation performed.
- Exact files changed.
- Validation performed.
- Current active task.
- Current owner and next owner.
- Recommended commit message.
```
