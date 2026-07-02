# Current Handoff

## Handoff ID
HANDOFF-0040

## Current Task
TASK-0023-ARGUS-Foundation-Implementation

## Current Owner
Codex

## Next Owner
ChatGPT or Codex depending on TASK-0023 findings

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
TASK-0035 completed the documentation/task-system audit gate. Codex should now execute TASK-0023 and implement the minimal ARGUS foundation slice using accepted ADR-0003.

Do not modify HEPHAESTUS code unless TASK-0023 explicitly discovers and documents a blocker that requires a new task.
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
| Documentation | 0 / 10 | No |
| Task System | 0 / 10 | No |
| HEPHAESTUS | 3 / 10 | No |
| ARGUS | 1 / 10 | No |
| Reporting | 0 / 10 | No |
| UI | 8 / 10 | No |
| Plugin Framework | 1 / 10 | No |
| Build System | 0 / 10 | No |
| Validation/Test Framework | 3 / 10 | No |
| Roadmap/Backlog | 3 / 10 | No |

## Current State
The GitHub remote is configured as `https://github.com/jstultz1980-beep/ComputerTriage.git`. The local `master` branch tracks `origin/master`.

Foundation governance has been reconciled. `docs/HANDOFF.md` and `docs/TASKS/QUEUE.md` agree on exactly one active task.

Completed work:
- TASK-0017 completed validation-only work.
- TASK-0018 completed HEPHAESTUS Local Analysis Engine v1 design.
- TASK-0019 completed the minimal HEPHAESTUS Local Analysis Engine v1 implementation slice.
- TASK-0020 completed the ARGUS input contract ADR/design gate and accepted ADR-0003.
- TASK-0024 through TASK-0027 completed focused GUI/UI corrections without changing the ARGUS design gate.
- TASK-0028 through TASK-0034 were created as queued follow-up tasks for UI/workflow cleanup and embedded-tool planning.
- TASK-0035 completed the documentation/task-system audit gate and reset audited counters.
- TASK-0036 through TASK-0040 remain queued follow-up tasks for page health indicators, Activity tracking, modern controls, and Software tab separation.

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

## Active Task
`TASK-0023-ARGUS-Foundation-Implementation`

Scope summary:
- Implement the first ARGUS foundation slice using accepted ADR-0003.
- Load and validate required HEPHAESTUS contract artifacts.
- Produce ARGUS input validation output.
- Produce a small analysis summary that prioritizes deterministic HEPHAESTUS findings.
- Clearly label deterministic evidence, normalized evidence, raw evidence, ARGUS inference, and unsupported conclusions.
- Produce a basic ARGUS report artifact.

## Queued Work
- `TASK-0021-HEPHAESTUS-Rule-Catalog-Expansion` owned by Codex.
- `TASK-0022-HEPHAESTUS-Portable-Tool-Classification` owned by ChatGPT.
- `TASK-0028-Quick-Dx-Compact-Run-Panel` owned by Codex.
- `TASK-0029-Choco-Page-Layout-Refinement` owned by Codex.
- `TASK-0030-Print-Tab-Data-Path-Cleanup` owned by Codex.
- `TASK-0031-Triage-Page-Simplification` owned by Codex.
- `TASK-0032-Computer-Tab-Summary-Redesign` owned by Codex.
- `TASK-0033-Directory-Tab-Direction-And-Embedding-Plan` owned by ChatGPT.
- `TASK-0034-Embedded-Tool-Experience-Roadmap` owned by ChatGPT.
- `TASK-0036-Page-Health-Indicators` owned by Codex.
- `TASK-0037-Activity-Page-Running-Tool-Tracking` owned by Codex.
- `TASK-0038-Modern-Control-Style-System` owned by Codex.
- `TASK-0039-Software-Tab-Launchable-And-Installable-Inventory` owned by ChatGPT.
- `TASK-0040-Software-Tab-Launchable-And-Installable-Implementation` owned by Codex.

## Validation Completed For This Update
- Completed TASK-0035 audit/governance work only.
- Verified the repository source-of-truth task state was consistent.
- Verified TASK-0020 is complete.
- Verified TASK-0023 existed and was queued before activation.
- Verified no ARGUS implementation was added by TASK-0020.
- Verified no HEPHAESTUS code was modified by TASK-0020.
- Reset audited Documentation and Task System counters after ledger entries.
- Updated task, queue, roadmap, changelog, ledger, and handoff.

## Blockers
None. The audit gate is cleared.

## Notes for Next AI
Known working-tree noise:
- `App/NetworkToolkit/LatencyMon/` is an untracked local tool folder and should not be deleted, imported, or committed unless a future task explicitly handles it.
- Runtime custom-tool provenance migration can add timestamp and package metadata drift to `App/manifests/custom-tools.json` during GUI validation. Reset that runtime drift before committing unless the active task explicitly changes the shipped manifest.

## Recommended Commit Message
```text
TASK-0035: Complete documentation and task system audit
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
7. docs/TASKS/TASK-0023-ARGUS-Foundation-Implementation.md
8. docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md
9. docs/DESIGN/HEPHAESTUS-Local-Analysis-Engine-v1.md

Current task state:
- docs/HANDOFF.md and docs/TASKS/QUEUE.md list exactly one Active task.
- Active task: TASK-0023-ARGUS-Foundation-Implementation.
- Owner: Codex.
- TASK-0035 audit is complete and the implementation gate is clear.
- TASK-0020 ARGUS input contract ADR/design work is complete.
- ADR-0003 is accepted.
- HEPHAESTUS Local Analysis Engine v1 produces validated Analysis and Metadata artifacts.

Your job:
Complete TASK-0023 implementation only.

Scope:
- Implement the minimal ARGUS foundation slice using ADR-0003.
- Create the approved ARGUS foundation location under the existing architecture.
- Load and validate required HEPHAESTUS contract artifacts:
  - Metadata/schema-version.json
  - Metadata/bundle-capabilities.json
  - Analysis/evidence-score.json
  - Analysis/findings.json
  - Analysis/timeline.json
  - Analysis/normalized/machine-profile.json
- Produce ARGUS input validation output.
- Produce a small analysis summary that prioritizes deterministic HEPHAESTUS findings.
- Clearly label deterministic evidence, normalized evidence, raw evidence, ARGUS inference, and unsupported conclusions.
- Produce a basic ARGUS report artifact.
- Update docs/TASKS/TASK-0023-ARGUS-Foundation-Implementation.md with work log and completion notes.
- Update docs/TASKS/QUEUE.md and docs/HANDOFF.md so they still agree.
- Update docs/HISTORY/CHANGE-LEDGER.md and docs/HISTORY/CHANGELOG.md if counters change.

Do not:
- Modify HEPHAESTUS collectors.
- Modify HEPHAESTUS Local Analysis Engine unless a blocker is documented and a new task is created.
- Download or install tools.
- Refactor unrelated application code.
- Clean unrelated files.
- Import, delete, or modify untracked App/NetworkToolkit/LatencyMon/ unless a future task explicitly handles it.
- Use chat history as source of truth unless the same information exists in the repository.

Validation expectations:
- ARGUS loads required HEPHAESTUS contract artifacts.
- ARGUS validates schema and capability metadata before interpretation.
- ARGUS reads evidence-score data and applies evidence-quality caveats.
- ARGUS prioritizes deterministic HEPHAESTUS findings without silently overriding them.
- ARGUS labels inference separately from deterministic evidence.
- Missing or unsupported evidence is called out explicitly.
- Required ARGUS output artifacts are generated and parse where applicable.
- No HEPHAESTUS code is modified unless a new task authorizes it.

When done, provide:
- Concise summary of implementation performed.
- Exact files changed.
- Validation performed.
- Current active task.
- Current owner and next owner.
- Recommended commit message.
```
