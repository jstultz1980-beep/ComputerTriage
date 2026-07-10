# TASK-0072 - ARGUS Product Definition And Evidence Map

## Status
Completed

## Owner
Codex

## Purpose
Define the finished ARGUS behavior and evidence map before expanding implementation.

## Scope
- Review current ARGUS foundation outputs and ADR-0003.
- Define evidence domains, trust order, citation rules, confidence language, and unsupported-inference behavior.
- Decide whether ADR-0003 status/text must be reconciled now that TASK-0020 marked it accepted.
- Produce an implementation-ready ARGUS normalization plan.

## Out Of Scope
- Implementing new ARGUS loaders or UI.
- Changing HEPHAESTUS collectors.
- Report styling.

## Acceptance Criteria
- [x] ARGUS evidence-domain map exists.
- [x] ARGUS output contract is defined for the next implementation task.
- [x] Confidence and citation rules are documented.
- [x] ADR-0003 status inconsistency is resolved or explicitly queued.

## Completion Notes
- Added `docs/DESIGN/ARGUS-PRODUCT-DEFINITION-AND-EVIDENCE-MAP.md`.
- Defined ARGUS as the cited explanation layer over HEPHAESTUS deterministic outputs, not a general chat or whole-network analysis layer.
- Defined evidence domains, trust order, confidence language, citation schema, unsupported-inference behavior, and the next output contract.
- Scoped TASK-0073 to produce `ARGUS/normalized-analysis.json` and scoped TASK-0074 to consume that model for diagnostic groups and recommendations.
- Confirmed the committed ADR-0003 version is already `Accepted`; the current working-tree ADR difference is known stale local drift and remains unstaged for the audit gate to reconcile deliberately.
