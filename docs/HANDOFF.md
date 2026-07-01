# Current Handoff

## Handoff ID
HANDOFF-0036

## Current Task
TASK-0020-ARGUS-Input-Contract-ADR

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
TASK-0019 is complete. ChatGPT should now execute TASK-0020 and finalize the ARGUS input contract and evidence trust model before any ARGUS implementation begins.

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
| Documentation | 7 / 10 | No |
| Task System | 6 / 10 | No |
| HEPHAESTUS | 3 / 10 | No |
| ARGUS | 0 / 10 | No |
| Reporting | 0 / 10 | No |
| UI | 7 / 10 | No |
| Plugin Framework | 1 / 10 | No |
| Build System | 0 / 10 | No |
| Validation/Test Framework | 3 / 10 | No |
| Roadmap/Backlog | 1 / 10 | No |

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
`TASK-0020-ARGUS-Input-Contract-ADR`

Scope summary:
- Finalize the ARGUS input contract and evidence trust model.
- Review HEPHAESTUS Local Analysis Engine v1 outputs and existing design/ADR docs.
- Accept, revise, or supersede `docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md`.
- Define ARGUS input artifact priority order.
- Define deterministic evidence versus ARGUS inference trust rules.
- Define missing, partial, and low-quality evidence behavior.
- Create focused follow-on Codex implementation task for ARGUS foundation if appropriate.

## Queued Work
- `TASK-0021-HEPHAESTUS-Rule-Catalog-Expansion` owned by Codex.
- `TASK-0022-HEPHAESTUS-Portable-Tool-Classification` owned by ChatGPT.
- `TASK-0023-ARGUS-Foundation-Implementation` owned by Codex, blocked until TASK-0020 completes and activates a specific scope.

## Validation Completed For This Update
- Completed TASK-0024 without changing the active TASK-0020 ChatGPT design gate.
- Completed TASK-0025 without changing the active TASK-0020 ChatGPT design gate.
- Completed TASK-0026 without changing the active TASK-0020 ChatGPT design gate.
- Parsed `App/ToolKit-GUI/ToolKit-GUI.ps1` successfully with `System.Management.Automation.PSParser`.
- Ran smoke validation: `Network Toolkit GUI loaded successfully. Commands: 18`.
- Ran button-smoke validation: `Button smoke test completed. Quick tab: OK`.
- Reset runtime `App/manifests/custom-tools.json` drift after validation.
- Left untracked `App/NetworkToolkit/LatencyMon/` untouched.
- Updated queue, handoff, changelog, and change ledger.

## Blockers
None.

## Notes for Next AI
Known working-tree noise:
- `App/NetworkToolkit/LatencyMon/` is an untracked local tool folder and should not be deleted, imported, or committed unless a future task explicitly handles it.
- Runtime custom-tool provenance migration can add timestamp and package metadata drift to `App/manifests/custom-tools.json` during GUI validation. Reset that runtime drift before committing unless the active task explicitly changes the shipped manifest.

## Recommended Commit Message
```text
TASK-0026: Use fixed Quick Dx internet targets
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
7. docs/TASKS/TASK-0020-ARGUS-Input-Contract-ADR.md
8. docs/DESIGN/HEPHAESTUS-Local-Analysis-Engine-v1.md
9. docs/ADRS/ADR-0001-HEPHAESTUS-Local-Analysis-Boundary.md
10. docs/ADRS/ADR-0002-Normalized-Output-Schema-Versioning.md
11. docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md

Current task state:
- docs/HANDOFF.md and docs/TASKS/QUEUE.md list exactly one Active task.
- Active task: TASK-0020-ARGUS-Input-Contract-ADR.
- Owner: ChatGPT.
- Next owner: Codex.
- TASK-0019 is complete and validated.
- HEPHAESTUS Local Analysis Engine v1 now produces validated Analysis and Metadata artifacts.

Your job:
Complete TASK-0020 ADR/design work only.

Scope:
- Finalize the ARGUS input contract and evidence trust model.
- Review HEPHAESTUS Local Analysis Engine v1 outputs and existing design/ADR docs.
- Accept, revise, or supersede ADR-0003.
- Define the exact ARGUS input artifact priority order.
- Define deterministic evidence versus ARGUS inference trust rules.
- Define missing, partial, low-quality, and parser-warning evidence behavior.
- Define the first focused ARGUS foundation implementation task for Codex.
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
- ADR-0003 is accepted or superseded.
- ARGUS input priority order is explicit.
- Deterministic-vs-inference trust rules are explicit.
- Missing, partial, and low-quality evidence behavior is explicit.
- Follow-on Codex implementation task is specific and small enough to execute safely.
- No ARGUS code is implemented.
- No HEPHAESTUS code is modified.

When done, provide:
- Concise summary of ADR/design work performed.
- Exact files changed.
- Current active task.
- Current owner and next owner.
- Recommended commit message.
```
