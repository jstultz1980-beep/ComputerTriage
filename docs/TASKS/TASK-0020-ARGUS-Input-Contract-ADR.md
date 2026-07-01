# TASK-0020 - ARGUS Input Contract ADR

## Status
Active

## Owner
ChatGPT

## Next Owner
Codex

## Objective
Finalize the ARGUS input contract and evidence trust model now that HEPHAESTUS Local Analysis Engine v1 produces validated normalized outputs.

## Scope
- Review the current HEPHAESTUS Local Analysis Engine v1 outputs and design documents.
- Finalize or replace `docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md`.
- Define the exact ARGUS input artifact priority order.
- Define how ARGUS should consume deterministic findings, normalized JSON, timeline data, evidence-score data, local report data, bundle metadata, and raw evidence.
- Define trust rules for deterministic evidence versus ARGUS inference.
- Define unsupported evidence behavior and required user-facing caveats.
- Define follow-on implementation tasks for Codex.

## Out of Scope
- Implementing ARGUS.
- Modifying HEPHAESTUS collectors.
- Modifying HEPHAESTUS Local Analysis Engine code.
- Refactoring application code.
- Downloading or installing tools.
- Cleaning unrelated files.

## Deliverables
- Updated ADR for ARGUS input contract and evidence trust model.
- Any required supporting design notes if the ADR is not enough.
- Follow-on Codex implementation task for ARGUS foundation, if appropriate.
- Updated `docs/TASKS/QUEUE.md` and `docs/HANDOFF.md`.
- Updated `docs/HISTORY/CHANGE-LEDGER.md` if subsystem counters change.
- Updated `docs/HISTORY/CHANGELOG.md`.

## Acceptance Criteria
- [ ] ADR-0003 is accepted or superseded by a new ADR.
- [ ] ARGUS input priority order is explicit.
- [ ] Deterministic-vs-inference trust rules are explicit.
- [ ] Missing, partial, and low-quality evidence behavior is explicit.
- [ ] Follow-on implementation task is specific and small enough for Codex.
- [ ] No ARGUS code is implemented.
- [ ] No HEPHAESTUS code is modified.
- [ ] Handoff and queue identify the next owner and next active task.

## Validation Steps
```powershell
git status --short
Test-Path C:\Computer_Toolkit\docs\HANDOFF.md
Test-Path C:\Computer_Toolkit\docs\TASKS\QUEUE.md
Select-String -Path C:\Computer_Toolkit\docs\HANDOFF.md -Pattern "Current Task","Current Owner","Next Owner","Next Bot Prompt"
Select-String -Path C:\Computer_Toolkit\docs\TASKS\QUEUE.md -Pattern "Active","TASK-0020"
```

## Rollback Plan
Revert TASK-0020 documentation changes only. Do not revert completed TASK-0019 implementation unless a separate implementation defect task requires it.

## Work Log

### Entry 001
Author: ChatGPT
Date: 2026-07-01
Summary: Created and activated after TASK-0019 local validation completed successfully.
Files Changed:
- `docs/TASKS/TASK-0020-ARGUS-Input-Contract-ADR.md`
Validation Performed:
- TASK-0019 local validation evidence was recorded in the completed TASK-0019 document.
Issues:
- None.
Instructions for Next Owner:
- ChatGPT should perform ADR/design work only. Do not implement ARGUS.
