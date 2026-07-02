# Current Handoff

## Handoff ID
HANDOFF-0044

## Current Task
TASK-0037-Activity-Page-Running-Tool-Tracking

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
TASK-0041 completed the required UI counter audit. TASK-0037 is now active for Activity page running-tool tracking and compact status work.

Do not modify ARGUS, HEPHAESTUS, deployment logic, package installation semantics, or unrelated application areas unless TASK-0037 explicitly discovers and documents a blocker that requires a new task.
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
| Documentation | 4 / 10 | No |
| Task System | 4 / 10 | No |
| HEPHAESTUS | 3 / 10 | No |
| ARGUS | 2 / 10 | No |
| Reporting | 0 / 10 | No |
| UI | 1 / 10 | No |
| Plugin Framework | 1 / 10 | No |
| Build System | 0 / 10 | No |
| Validation/Test Framework | 3 / 10 | No |
| Roadmap/Backlog | 4 / 10 | No |

## Current State
The GitHub remote is configured as `https://github.com/jstultz1980-beep/ComputerTriage.git`. The local `master` branch tracks `origin/master`.

Foundation governance has been reconciled. `docs/HANDOFF.md` and `docs/TASKS/QUEUE.md` agree on exactly one active task.

Completed work:
- TASK-0017 completed validation-only work.
- TASK-0018 completed HEPHAESTUS Local Analysis Engine v1 design.
- TASK-0019 completed the minimal HEPHAESTUS Local Analysis Engine v1 implementation slice.
- TASK-0020 completed the ARGUS input contract ADR/design gate and accepted ADR-0003.
- TASK-0023 completed the minimal ARGUS foundation slice and generated ARGUS validation, summary, and report artifacts.
- TASK-0024 through TASK-0027 completed focused GUI/UI corrections without changing the ARGUS design gate.
- TASK-0035 completed the documentation/task-system audit gate and reset audited counters.
- TASK-0028 completed focused Quick Dx run-panel cleanup.
- TASK-0029 completed focused Choco page layout refinement.
- TASK-0041 completed the UI counter audit and reset the audited UI counter.
- TASK-0037 is now active for Activity page running-tool tracking.
- TASK-0030 through TASK-0034 remain queued follow-up tasks for UI/workflow cleanup and embedded-tool planning.
- TASK-0036, TASK-0038, TASK-0039, and TASK-0040 remain queued follow-up tasks for page health indicators, modern controls, and Software tab separation.

TASK-0019 validation evidence:
- `Run Local Analysis` completed successfully.
- Bundle root: `C:\Computer_Toolkit\App\NetworkToolkit\Exports\AI-Bundles`.
- Analysis root: `C:\Computer_Toolkit\App\NetworkToolkit\Exports\AI-Bundles\Analysis`.
- Findings: `6`.
- EvidenceScore: `50`.
- Required files existed:
  - `Analysis/findings.json`
  - `Analysis/timeline.json`
  - `Analysis/evidence-score.json`
  - `Analysis/normalized/machine-profile.json`
  - `Analysis/report.html`
  - `Metadata/bundle-capabilities.json`
  - `Metadata/schema-version.json`
- JSON parse checks passed for findings, evidence score, and bundle capabilities.
- Smoke test passed: `Network Toolkit GUI loaded successfully. Commands: 18`.
- Button smoke test passed: `Button smoke test completed. Quick tab: OK`.

TASK-0035 audit findings:
- Documentation/task-state source of truth was consistent before closeout.
- Exactly one task was active before closeout and exactly one task is active after closeout.
- TASK-0020 is complete.
- TASK-0023 was queued during the audit and is now active after the audit gate cleared.
- No ARGUS implementation was added by TASK-0020.
- No HEPHAESTUS code was modified by TASK-0020.
- No application code was modified by TASK-0035.
- Documentation and Task System counters were audited and reset.

TASK-0023 validation evidence:
- `Invoke-ARGUSFoundationAnalysis` completed successfully against `C:\Computer_Toolkit\App\NetworkToolkit\Exports\AI-Bundles`.
- ARGUS output root: `C:\Computer_Toolkit\App\NetworkToolkit\Exports\AI-Bundles\ARGUS`.
- Generated files:
  - `ARGUS/input-validation.json`
  - `ARGUS/analysis-summary.json`
  - `ARGUS/report.md`
- Input validation status was `limited`, which is expected with partial HEPHAESTUS capability coverage.
- Required artifact count: `6`.
- Unsupported area count: `4`.
- Prioritized deterministic findings count: `5`.
- ARGUS inference was explicitly labeled as `argusInference`.
- Parser checks passed for `Core\Argus\ArgusFoundation.ps1` and `App\NetworkToolkit\Core\ArgusFoundationCommand.ps1`.
- Console load passed with exit code `0`.
- Command registry found `Run ARGUS Foundation` with Id `argus-foundation`, Category `Analyze`, Source `ARGUS`, Order `45`.
- CLI smoke run of `Run ARGUS Foundation` completed successfully.

TASK-0028 validation evidence:
- Parsed `App\ToolKit-GUI\ToolKit-GUI.ps1` successfully with the PowerShell parser.
- Confirmed the visible `Internet targets`, `Internet test target`, and `QuickInternetTargetsLabel` UI strings no longer exist in the GUI file.
- Confirmed `Get-GUIQuickDiagnosisTargets` still returns `www.microsoft.com`, `google.com`, `yahoo.com`, and `amazon.com`.
- GUI smoke passed: `Network Toolkit GUI loaded successfully. Commands: 19`.
- Button smoke passed: `Button smoke test completed. Quick tab: OK`.

TASK-0029 validation evidence:
- Parsed `App\ToolKit-GUI\ToolKit-GUI.ps1` successfully with the PowerShell parser.
- GUI smoke passed: `Network Toolkit GUI loaded successfully. Commands: 19`.
- Button smoke passed: `Button smoke test completed. Quick tab: OK`.
- The Choco status area was reduced to a compact strip.
- Choco status actions were restored as compact buttons instead of link-style controls.

TASK-0037 validation evidence:
- Parsed `App\ToolKit-GUI\ToolKit-GUI.ps1` successfully with the PowerShell parser.
- GUI smoke passed: `Network Toolkit GUI loaded successfully. Commands: 19`.
- Button smoke passed: `Button smoke test completed. Quick tab: OK`.
- Activity now shows CPU, RAM, Disk, and Network gauges.
- The Network gauge uses Windows network-interface performance counters and displays Mbps detail when available.

## Active Task
`TASK-0037-Activity-Page-Running-Tool-Tracking`

Scope summary:
- Add and refine Activity page visibility for toolkit-owned running work.
- Network visibility has been added as a live gauge.
- Running-program list height and compact Refresh/Stop controls remain outstanding.
- Keep Activity refresh from causing UI lag or memory growth.

## Queued Work
- `TASK-0021-HEPHAESTUS-Rule-Catalog-Expansion` owned by Codex.
- `TASK-0022-HEPHAESTUS-Portable-Tool-Classification` owned by ChatGPT.
- `TASK-0030-Print-Tab-Data-Path-Cleanup` owned by Codex.
- `TASK-0031-Triage-Page-Simplification` owned by Codex.
- `TASK-0032-Computer-Tab-Summary-Redesign` owned by Codex.
- `TASK-0033-Directory-Tab-Direction-And-Embedding-Plan` owned by ChatGPT.
- `TASK-0034-Embedded-Tool-Experience-Roadmap` owned by ChatGPT.
- `TASK-0036-Page-Health-Indicators` owned by Codex.
- `TASK-0038-Modern-Control-Style-System` owned by Codex.
- `TASK-0039-Software-Tab-Launchable-And-Installable-Inventory` owned by ChatGPT.
- `TASK-0040-Software-Tab-Launchable-And-Installable-Implementation` owned by Codex.

## Validation Completed For This Update
- Completed TASK-0041 UI counter audit and reset the audited UI counter.
- Activated TASK-0037 Activity page running-tool tracking.
- Added a Network gauge to the Activity page.
- Verified `App\ToolKit-GUI\ToolKit-GUI.ps1` parses successfully.
- Verified Network Toolkit GUI smoke test passes.
- Verified Network Toolkit button-smoke test passes and the Quick tab reports OK.
- Updated task, queue, roadmap, changelog, ledger, and handoff.

## Blockers
None for tracked work. TASK-0037 remains active because compacting the running-program list and controls is still outstanding.

## Notes for Next AI
Known working-tree noise:
- `App/NetworkToolkit/LatencyMon/` is an untracked local tool folder and should not be deleted, imported, or committed unless a future task explicitly handles it.
- Runtime custom-tool provenance migration can add timestamp and package metadata drift to `App/manifests/custom-tools.json` during GUI validation. Reset that runtime drift before committing unless the active task explicitly changes the shipped manifest.
- `docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md` has shown local stale/locked drift during ARGUS work. Do not stage it unless a future task explicitly updates the accepted ADR.

## Recommended Commit Message
```text
TASK-0037: Add Activity network gauge
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
7. docs/TASKS/TASK-0037-Activity-Page-Running-Tool-Tracking.md

Current task state:
- docs/HANDOFF.md and docs/TASKS/QUEUE.md list exactly one Active task.
- Active task: TASK-0037-Activity-Page-Running-Tool-Tracking.
- Owner: Codex.
- TASK-0041 UI counter audit is complete and the UI counter has been reset.
- TASK-0037 has partial progress: the Network gauge has been added to the Activity page.
- TASK-0029 Choco page layout refinement is complete.
- TASK-0028 Quick Dx compact run-panel cleanup is complete.
- TASK-0023 ARGUS foundation implementation is complete.
- TASK-0035 audit is complete and the implementation gate is clear.

Your job:
Continue TASK-0037 implementation only.

Scope:
- Continue refining the Activity page.
- Preserve the existing CPU, RAM, Disk, and Network gauges.
- Shorten the running-program list so it does not dominate the page.
- Make Refresh and Stop controls smaller and cleaner.
- Avoid polling changes that introduce lag or memory growth.
- Update docs/TASKS/TASK-0037-Activity-Page-Running-Tool-Tracking.md with work log and completion notes.
- Update docs/TASKS/QUEUE.md and docs/HANDOFF.md so they still agree.
- Update docs/HISTORY/CHANGE-LEDGER.md and docs/HISTORY/CHANGELOG.md if counters change.

Do not:
- Modify ARGUS or HEPHAESTUS.
- Change package installation semantics, deployment, or unrelated GUI areas.
- Download or install tools.
- Refactor unrelated application code.
- Clean unrelated files.
- Import, delete, or modify untracked App/NetworkToolkit/LatencyMon/ unless a future task explicitly handles it.
- Use chat history as source of truth unless the same information exists in the repository.

Validation expectations:
- Activity page keeps CPU, RAM, Disk, and Network gauges visible.
- Running-program list is shorter and leaves room for status content.
- Refresh and Stop controls are compact and visually consistent.
- Activity refresh does not freeze the UI.
- PowerShell parse, smoke, and button-smoke validation pass.

When done, provide:
- Concise summary of implementation performed.
- Exact files changed.
- Validation performed.
- Current active task.
- Current owner and next owner.
- Recommended commit message.
```
