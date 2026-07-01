# TASK-0020 - ARGUS Input Contract ADR

## Status
Completed

## Owner
ChatGPT

## Next Owner
ChatGPT

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

## Acceptance Criteria
- [x] ADR-0003 is accepted or superseded by a new ADR.
- [x] ARGUS input priority order is explicit.
- [x] Deterministic-vs-inference trust rules are explicit.
- [x] Missing, partial, and low-quality evidence behavior is explicit.
- [x] Follow-on implementation task is specific and small enough for Codex.
- [x] No ARGUS code is implemented.
- [x] No HEPHAESTUS code is modified.
- [x] Handoff and queue identify the next owner and next active task.

## Validation Performed
- Read required startup documents and active TASK-0020 materials from GitHub `master`.
- Accepted ADR-0003.
- Created focused TASK-0023 as the queued ARGUS foundation implementation task.
- Created TASK-0035 as the active audit gate because the Documentation counter reached `10 / 10`.
- Confirmed this was documentation/design work only.

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

### Entry 002
Author: ChatGPT
Date: 2026-07-01
Summary: Finalized the ARGUS input contract, accepted ADR-0003, and created the next implementation task as queued work.
Files Changed:
- `docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md`
- `docs/TASKS/TASK-0020-ARGUS-Input-Contract-ADR.md`
- `docs/TASKS/TASK-0023-ARGUS-Foundation-Implementation.md`
- `docs/TASKS/TASK-0035-Documentation-Task-System-Audit.md`
- `docs/TASKS/QUEUE.md`
- `docs/ROADMAP.md`
- `docs/HISTORY/CHANGE-LEDGER.md`
- `docs/HISTORY/CHANGELOG.md`
- `docs/HANDOFF.md`
Validation Performed:
- Confirmed TASK-0020 was active before execution.
- Confirmed no implementation files were changed for this task.
Issues:
- Documentation counter reached audit threshold.
Instructions for Next Owner:
- ChatGPT should complete TASK-0035 audit before implementation work resumes.

## Completion Notes
TASK-0020 is complete. ADR-0003 is accepted. TASK-0023 exists as the focused ARGUS foundation implementation task, but it remains queued behind the required TASK-0035 audit gate.
