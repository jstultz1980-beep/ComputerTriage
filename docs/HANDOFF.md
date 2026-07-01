# Current Handoff

## Handoff ID
HANDOFF-0039

## Current Task
TASK-0035-Documentation-Task-System-Audit

## Current Owner
ChatGPT

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
TASK-0020 completed the ARGUS input contract ADR/design gate. TASK-0035 is now the active audit gate because documentation/task-state work pushed the Documentation counter to `10 / 10`.

Do not implement ARGUS.
Do not modify HEPHAESTUS code.
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
| Documentation | 10 / 10 | Yes |
| Task System | 9 / 10 | No |
| HEPHAESTUS | 3 / 10 | No |
| ARGUS | 0 / 10 | No |
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
- TASK-0024 completed a focused Quick Dx layout correction requested by the project owner. Quick Target Checks now owns the full left column, while Quick Diagnosis run controls and Review/Shortcuts are stacked in the right column.
- TASK-0025 fixed the clipped Last Quick Diagnosis label inside the compact right-column Quick Diagnosis block.
- TASK-0026 removed the editable Quick Diagnosis internet target and replaced it with a fixed primary/backup target chain: `www.microsoft.com`, `google.com`, `yahoo.com`, and `amazon.com`.
- TASK-0027 completed a focused GUI polish pass for Quick Dx right-column spacing, header health badge space, Terminal Dark theme, gradient/texture surfaces, and compact Choco status placement.
- TASK-0028 through TASK-0034 were created as queued follow-up tasks for the project owner's newly requested UI/workflow cleanup items. No application code was changed in that task-creation update.
- TASK-0020 completed the ARGUS input contract ADR/design gate and created the focused TASK-0023 ARGUS foundation implementation task.
- TASK-0035 is active because the Documentation counter reached `10 / 10`.
- TASK-0036 through TASK-0040 were created as queued follow-up tasks for page health indicators, Activity page tracking, modern utility-button styling, and Software tab launchable/installable separation.

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

## Active Task
`TASK-0035-Documentation-Task-System-Audit`

Scope summary:
- Audit documentation and task-state consistency after the Documentation counter reached `10 / 10`.
- Verify `docs/HANDOFF.md` and `docs/TASKS/QUEUE.md` agree.
- Verify exactly one task is Active.
- Verify TASK-0020 is complete and TASK-0023 remains queued.
- Reset audited counters only after audit completion and ledger entry.

## Queued Work
- `TASK-0021-HEPHAESTUS-Rule-Catalog-Expansion` owned by Codex.
- `TASK-0022-HEPHAESTUS-Portable-Tool-Classification` owned by ChatGPT.
- `TASK-0023-ARGUS-Foundation-Implementation` owned by Codex, blocked until TASK-0035 audit completes and activates a specific scope.
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
- Completed TASK-0024 without changing the active TASK-0020 ChatGPT design gate.
- Completed TASK-0025 without changing the active TASK-0020 ChatGPT design gate.
- Completed TASK-0026 without changing the active TASK-0020 ChatGPT design gate.
- Completed TASK-0027 without changing the active TASK-0020 ChatGPT design gate.
- Created queued TASK-0028 through TASK-0034 without changing the active TASK-0020 ChatGPT design gate.
- Reconciled TASK-0020/TASK-0035 state so `docs/HANDOFF.md`, `docs/TASKS/QUEUE.md`, and task files agree that TASK-0035 is Active.
- Created queued TASK-0036 through TASK-0040 for the newly requested page indicators, Activity page, button style, and Software tab inventory/implementation work.
- Verified no application code changed in the task-creation update.
- Reset runtime `App/manifests/custom-tools.json` drift after validation.
- Left untracked `App/NetworkToolkit/LatencyMon/` untouched.
- Updated queue, handoff, changelog, and change ledger.

## Blockers
Documentation counter is at `10 / 10`. No new implementation work should begin until `TASK-0035-Documentation-Task-System-Audit` is completed and the audited counter reset is recorded.

## Notes for Next AI
Known working-tree noise:
- `App/NetworkToolkit/LatencyMon/` is an untracked local tool folder and should not be deleted, imported, or committed unless a future task explicitly handles it.
- Runtime custom-tool provenance migration can add timestamp and package metadata drift to `App/manifests/custom-tools.json` during GUI validation. Reset that runtime drift before committing unless the active task explicitly changes the shipped manifest.

## Recommended Commit Message
```text
TASK-0036-0040: Queue indicators activity and software tasks
```

## Next Bot Prompt
Copy and paste the following prompt into ChatGPT. Do not create a separate task packet file.

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
7. docs/TASKS/TASK-0035-Documentation-Task-System-Audit.md
8. docs/TASKS/TASK-0020-ARGUS-Input-Contract-ADR.md
9. docs/DESIGN/HEPHAESTUS-Local-Analysis-Engine-v1.md
10. docs/ADRS/ADR-0001-HEPHAESTUS-Local-Analysis-Boundary.md
11. docs/ADRS/ADR-0002-Normalized-Output-Schema-Versioning.md
12. docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md

Current task state:
- docs/HANDOFF.md and docs/TASKS/QUEUE.md list exactly one Active task.
- Active task: TASK-0035-Documentation-Task-System-Audit.
- Owner: ChatGPT.
- Next owner: Codex.
- TASK-0019 is complete and validated.
- HEPHAESTUS Local Analysis Engine v1 now produces validated Analysis and Metadata artifacts.
- TASK-0020 ARGUS input contract ADR/design work is complete.
- Documentation counter is at 10/10, so implementation work is blocked until TASK-0035 completes.
- TASK-0036 through TASK-0040 are queued for follow-up UI/workflow refinements requested by the project owner.

Your job:
Complete TASK-0035 audit/governance work only.

Scope:
- Audit current documentation and task-state consistency.
- Verify docs/HANDOFF.md and docs/TASKS/QUEUE.md agree.
- Verify exactly one task is Active.
- Verify TASK-0020 is complete and TASK-0023 remains queued.
- Verify no ARGUS implementation was added by TASK-0020.
- Verify no HEPHAESTUS code was modified by TASK-0020.
- Reset audited counters only after audit completion and ledger entry.
- Update docs/TASKS/QUEUE.md and docs/HANDOFF.md so they still agree.
- Update docs/HISTORY/CHANGE-LEDGER.md and docs/HISTORY/CHANGELOG.md if counters change.

Do not:
- Implement ARGUS.
- Modify HEPHAESTUS code.
- Modify application code.
- Download or install tools.
- Clean unrelated files.
- Import, delete, or modify untracked App/NetworkToolkit/LatencyMon/ unless a future task explicitly handles it.
- Use chat history as source of truth unless the same information exists in the repository.

Validation expectations:
- Documentation/task-state source of truth is consistent.
- Exactly one task is Active.
- TASK-0020 is complete.
- TASK-0023 remains queued and is not implemented.
- Audit findings are recorded.
- Required counters are reset only if audited.
- No ARGUS code is implemented.
- No HEPHAESTUS code is modified.

When done, provide:
- Concise summary of ADR/design work performed.
- Exact files changed.
- Current active task.
- Current owner and next owner.
- Recommended commit message.
```
