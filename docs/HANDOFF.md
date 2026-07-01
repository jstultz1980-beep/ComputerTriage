# Current Handoff

## Handoff ID
HANDOFF-0028

## Current Task
None

## Current Owner
Codex

## Next Owner
Codex or another bot using the prompt below.

## How The Handoff Process Works
This repository is the source of truth for the project. Chat history is useful context only when the same information has been written into the repository.

Another bot should not rely on memory, screenshots, or prior conversation unless those details are captured in tracked project files.

The handoff process has three core files:
- `PROJECT.md` defines the rules every bot must follow.
- `docs/HANDOFF.md` explains the current project state and contains the exact `Next Bot Prompt` to give another bot.
- The active task file under `docs/TASKS` defines the only work that may be performed.

Work should move through this sequence:
1. Read `PROJECT.md`, the project docs, this handoff, and the active task.
2. If no active task exists, create a focused task under `docs/TASKS` and make it active in this handoff before implementation begins.
3. Perform only the work described by the active task. Do not clean up unrelated files or expand scope unless a task explicitly says to do so.
4. Validate the work using the validation steps in the task.
5. Update the task file with completion notes and checked acceptance criteria.
6. Update this handoff with the new project state, validation results, known unrelated working-tree drift, and a fresh `Next Bot Prompt`.
7. Commit the related changes with a commit message that references the task.

The `Next Bot Prompt` section is the text to copy into ChatGPT or another bot. It replaces any separate ChatGPT task packet. After every completed task, that prompt must be rewritten so the next bot starts from the repository state, not from chat history.

## Objective
TASK-0016 tool source-of-truth correction is complete. The project is ready for
the next focused task.

An accepted HEPHAESTUS direction update is now captured in this handoff:
HEPHAESTUS should evolve from a collector-first bundle builder into a
collector plus deterministic local analysis platform. The next major HEPHAESTUS
milestone should be a focused Local Analysis Engine v1 task, but no
implementation should start until a task file exists and this handoff lists that
task as active.

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
| Documentation | 5 / 10 | No |
| Task System | 5 / 10 | No |
| HEPHAESTUS | 0 / 10 | No |
| ARGUS | 0 / 10 | No |
| Reporting | 0 / 10 | No |
| UI | 4 / 10 | No |
| Plugin Framework | 1 / 10 | No |
| Build System | 0 / 10 | No |
| Validation/Test Framework | 1 / 10 | No |
| Roadmap/Backlog | 1 / 10 | No |

## Current State
The GitHub remote is configured as `https://github.com/jstultz1980-beep/ComputerTriage.git`. The local `master` branch tracks `origin/master`.

TASK-0011 completed the foundation audit. TASK-0012 completed the phase
transition readiness pass. Runtime-only custom tool manifest drift was reset,
generated third-party `.cfg` files are ignored broadly, task status wording was
normalized, stale architecture root path casing was corrected, and the roadmap
now marks Phase 00 complete with Phase 01 active.

TASK-0013 added a GUI header search box. It autocompletes tool names from the
catalog, mapped Sysinternals tools, and ready custom/toolbox apps. Selecting a
result or pressing Enter navigates to the matching tab without launching the
tool.

TASK-0014 restored DHCP Sleuth. The tool had disappeared because `App/Custom/*`
ignored the standalone app folder and the tracked custom tools manifest did not
register it. DHCP Sleuth is now tracked under `App/Custom/DHCPSleuth`, its
mutable `DHCP-Sleuth.settings.json` remains ignored, and the manifest registers
it as a standalone GUI app on the Infrastructure tab.

TASK-0014 also hardened validation-only launch behavior: `App/NetworkToolkit.ps1`
now bypasses the single-instance mutex for `-SmokeTest` and `-ButtonSmokeTest`,
and `App/ToolKit-GUI/ToolKit-GUI.ps1` disposes the test form and stops all
known GUI timers during smoke-test cleanup.

TASK-0015 corrected header search tab mapping. Search results now come from the
same `Get-GUIToolsForTab` path used by visible tab pages, and the standalone
Sysinternals search entries share the Sysinternals page filter. `PsExec Helper`
now maps to the dedicated `PsExec` tab instead of `Remote`.

TASK-0016 completed the GUI tool source-of-truth correction. Visible tab
rendering and header search now read from `Get-GUIToolRegistry`, duplicate
registry/search entries are checked during button smoke validation, and triage
completion handling is single-shot so one completed run cannot produce repeated
completion or result-read dialogs.

## Accepted HEPHAESTUS Direction Update

The accepted product direction is to transition HEPHAESTUS from a diagnostic
evidence collector into a collector plus deterministic local analysis platform.

The intended pipeline is:

```text
Collect
  ↓
Analyze locally with deterministic rules
  ↓
Generate structured findings
  ↓
Generate a local executive report
  ↓
Package bundle
  ↓
ARGUS / AI interpretation
```

HEPHAESTUS should perform the first-pass deterministic analysis. ARGUS should
consume the resulting structured findings, timelines, evidence scores, and
normalized JSON artifacts, then provide higher-level interpretation,
prioritization, and recommendations.

The next major HEPHAESTUS milestone should be:

```text
Local Analysis Engine v1
```

No implementation for this milestone should begin until a focused task exists
under `docs/TASKS` and `docs/HANDOFF.md` lists that task as active.

### Approved Local Analysis Engine Scope

When a task is created for Local Analysis Engine v1, it should cover these
approved capabilities unless the task intentionally narrows scope:

- Deterministic rule engine.
- Structured findings with severity, confidence, evidence, recommendations,
  category, source files, and related tags.
- Event correlation and timeline generation.
- Machine profile generation.
- Evidence quality and completeness scoring.
- Security product inventory.
- Driver intelligence.
- Storage analysis.
- Windows Update and servicing analysis.
- AD, DFSR, SYSVOL, and Group Policy interpretation when applicable.
- Network intelligence.
- Process pressure and leak candidate detection.
- Local HTML executive report generation.
- Normalized JSON outputs for major collector categories.
- Bundle capability and schema version metadata.
- Portable tool orchestrator framework with absent tools marked as skipped, not
  failed.

### Approved Normalized Output Direction

Future HEPHAESTUS work should preserve existing human-readable TXT/CSV outputs
while adding normalized JSON for analysis. Target artifacts include:

```text
Analysis/findings.json
Analysis/timeline.json
Analysis/evidence-score.json
Analysis/normalized/machine-profile.json
Analysis/normalized/services.json
Analysis/normalized/processes.json
Analysis/normalized/drivers.json
Analysis/normalized/network.json
Analysis/normalized/security-products.json
Analysis/normalized/storage.json
Analysis/normalized/updates.json
Analysis/normalized/domain-health.json
Analysis/normalized/gpo.json
Analysis/normalized/hyperv.json
Metadata/bundle-capabilities.json
Metadata/schema-version.json
```

### HEPHAESTUS / ARGUS Responsibility Boundary

HEPHAESTUS responsibilities:

- Collect evidence.
- Normalize evidence.
- Run deterministic checks.
- Produce local findings.
- Produce local timeline.
- Produce evidence score.
- Produce local HTML report.
- Package the bundle and embedded AI prompt.

ARGUS responsibilities:

- Read machine profile, findings, timeline, evidence score, and normalized JSON
  first.
- Use raw evidence to verify or deepen findings.
- Distinguish deterministic findings from AI inference.
- Explain likely root cause candidates.
- Prioritize next actions.
- Identify missing evidence.
- Avoid unsupported conclusions.

## Completed Work
- Read `PROJECT.md` and required startup documents.
- Created `docs/TASKS/TASK-0011-Foundation-Audit.md`.
- Updated this handoff to make TASK-0011 active.
- Completed TASK-0011 foundation audit.
- Verified GitHub remote and branch tracking.
- Reviewed required startup docs and task list.
- Compared audit counters against `docs/HISTORY/CHANGE-LEDGER.md`.
- Reset runtime-only `App/manifests/custom-tools.json` drift.
- Broadened generated third-party tool config ignore coverage.
- Normalized TASK-0009 status wording.
- Corrected stale architecture root path casing.
- Completed TASK-0012 phase-transition readiness.
- Marked Phase 00 Foundation Zero complete and Phase 01 HEPHAESTUS Collection
  Baseline active.
- Updated audit counters for TASK-0012 documentation, task system, and roadmap
  changes.
- Created TASK-0013 for header tool search.
- Completed TASK-0013 header tool search.
- Added header autocomplete search to `App/ToolKit-GUI/ToolKit-GUI.ps1`.
- Added smoke-test coverage that confirms the search box exists and resolves
  `Test-NetConnection` to the Analyze tab.
- Created TASK-0014 for DHCP Sleuth restoration.
- Completed TASK-0014 DHCP Sleuth restoration.
- Added tracked DHCP Sleuth standalone app files under `App/Custom/DHCPSleuth`.
- Registered DHCP Sleuth in `App/manifests/custom-tools.json` for the
  Infrastructure tab with standalone GUI launch behavior.
- Added `App/.gitignore` exceptions for DHCP Sleuth while keeping
  `DHCP-Sleuth.settings.json` ignored.
- Hardened smoke-test lifecycle cleanup and test-mode singleton bypass.
- Created TASK-0015 for header search tab mapping correction.
- Completed TASK-0015 header search tab mapping correction.
- Rebuilt header search indexing from visible tab tool placement.
- Corrected `PsExec Helper` catalog placement to `PsExec`.
- Added button smoke-test assertions for representative header search mappings.
- Created TASK-0016 for tool source-of-truth correction.
- Completed TASK-0016 tool source-of-truth correction.
- Added `Get-GUIToolRegistry` as the normalized GUI registry path for rendered
  tab tools and header search.
- Added button smoke-test duplicate detection for GUI registry and search
  entries.
- Hardened triage completion/cancellation timer handling to prevent repeated
  modal dialogs or repeated result-read log spam from one run.
- Captured the accepted HEPHAESTUS Local Analysis Engine direction in this
  handoff for future task creation.

## Validation Completed
- Confirmed `master` is aligned with `origin/master` before task creation.
- Confirmed existing task list ended at TASK-0010 before creating TASK-0011.
- Ran `git status --short --branch`.
- Ran `git remote -v`.
- Ran `git log --oneline -12`.
- Reviewed `docs/TASKS/TASK-*.md` status values.
- Reviewed `docs/HISTORY/CHANGE-LEDGER.md` against handoff counters.
- Reviewed `.gitignore` generated/runtime coverage.
- Confirmed task list ended at TASK-0011 before creating TASK-0012.
- Searched live docs for phase-transition references.
- Parsed `App/ToolKit-GUI/ToolKit-GUI.ps1` with `PSParser`.
- Ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -SmokeTest`.
- Ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -ButtonSmokeTest`.
- Confirmed `App/Custom/DHCPSleuth/DHCP-Sleuth.settings.json` is ignored.
- Parsed `App/NetworkToolkit.ps1`.
- Parsed `App/ToolKit-GUI/ToolKit-GUI.ps1`.
- Re-ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -SmokeTest`.
- Re-ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -ButtonSmokeTest`.
- Parsed `App/NetworkToolkit/Config/ToolCatalog.ps1`.
- Parsed `App/ToolKit-GUI/ToolKit-GUI.ps1`.
- Ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -SmokeTest`.
- Ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -ButtonSmokeTest`.
- Queried the header search index and confirmed `Test-NetConnection`,
  `PsExec Helper`, `DHCP Sleuth`, `Autoruns`, and `Process Explorer` resolve to
  their expected tabs.
- Ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -SmokeTest`.
- Ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -ButtonSmokeTest`.
- Reset runtime-only `App/manifests/custom-tools.json` drift after validation.
- GitHub update only: fetched and updated `docs/HANDOFF.md` to record accepted
  HEPHAESTUS Local Analysis Engine direction. No local validation was run by
  ChatGPT for this documentation-only update.

## Next Action
Create the next focused task before implementation. Recommended next task:
`TASK-0017-Triage-Manual-Run-Validation`.

The accepted HEPHAESTUS Local Analysis Engine v1 work is approved direction, but
should be started only after a focused task is created and activated. If the
project owner chooses to prioritize HEPHAESTUS analysis work next instead of the
manual run validation task, create a focused task such as
`TASK-0017-HEPHAESTUS-Local-Analysis-Engine-v1` and make it active in this
handoff before implementation.

## Blockers
None.

## Notes for Next AI
Start with `PROJECT.md`. If no task is active, create a task under
`docs/TASKS` and update this handoff before implementation.

Known working-tree noise:
- Runtime custom-tool provenance migration can add timestamp and package
  metadata drift to `App/manifests/custom-tools.json` during GUI validation.
  Reset that runtime drift before committing unless the active task explicitly
  changes the shipped manifest.

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
6. The active task document listed in docs/HANDOFF.md.

Current task state:
- docs/HANDOFF.md lists no active implementation task.
- Audit state tracking is active.
- TASK-0011 foundation audit is complete.
- TASK-0012 phase-transition readiness is complete.
- TASK-0013 header tool search is complete.
- TASK-0014 DHCP Sleuth restoration is complete.
- TASK-0015 header search tab mapping correction is complete.
- TASK-0016 tool source-of-truth correction is complete.
- Create the next focused task before implementation. Recommended next task:
  TASK-0017-Triage-Manual-Run-Validation.

Accepted HEPHAESTUS direction:
- HEPHAESTUS should evolve from a collector-first bundle builder into a
  collector plus deterministic local analysis platform.
- The approved pipeline is Collect -> Analyze locally -> Generate structured
  findings -> Generate local executive report -> Package bundle -> ARGUS / AI
  interpretation.
- The next major HEPHAESTUS milestone should be Local Analysis Engine v1.
- Local Analysis Engine v1 should include deterministic findings, a rule engine,
  event correlation/timeline generation, machine profile, evidence scoring,
  security inventory, driver intelligence, storage analysis, Windows Update
  analysis, AD/DFSR/GPO interpretation where applicable, network intelligence,
  normalized JSON outputs, bundle capability/schema metadata, and a local HTML
  executive report.
- Do not implement this work until a focused task file exists and
  docs/HANDOFF.md lists that task as active.

Audit counter rule:
- Each subsystem has a change counter in docs/HANDOFF.md.
- Every accepted subsystem change must be recorded in docs/HISTORY/CHANGE-LEDGER.md.
- If any subsystem reaches 10 / 10 changes, a new audit is mandatory before further implementation work.
- After the audit is completed, the audited subsystem counter resets to 0 / 10.

Repository remote:
- origin is https://github.com/jstultz1980-beep/ComputerTriage.git.
- master tracks origin/master.

Rules:
- Treat repository files as authoritative.
- Do not implement changes until a task file exists and docs/HANDOFF.md lists it as active.
- Do not use chat history as source of truth unless the same information exists in the repository.
- Do not create a separate ChatGPT task packet as source of truth.
- When a task is completed, update docs/HANDOFF.md with the next task state and a fresh Next Bot Prompt for the next bot.
```
