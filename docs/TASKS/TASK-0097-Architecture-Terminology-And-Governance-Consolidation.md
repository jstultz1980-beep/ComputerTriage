# TASK-0097 - Architecture, Terminology, and Governance Consolidation

## Status
Active - Codex Support

## Owner
Codex, limited to focused support authorized by the Project Custodian decision.

## Depends On
TASK-0096.

## Objective
Apply the approved intended-state architecture and canonical terminology, simplify roadmap/queue roles, and reduce duplicated governance text without weakening controls.

## Project Custodian Decision

Authoritative decision:
- `docs/REVIEWS/TASK-0097/PROJECT-CUSTODIAN-DECISION.md`

The Project Custodian has completed the architecture, terminology, roadmap, queue, and governance decision portion of this task.

## Findings Addressed
GOV-001 through GOV-006 and related documentation drift.

## Acceptance Criteria
- Architecture documents all runtime boundaries, contracts, flows, and failure behavior.
- Canonical terminology is consistent.
- Roadmap is forward-looking and history remains in task/history records.
- Queue remains operational and concise.
- Governance simulations still pass.

## Authorized Codex Scope

1. Inventory repository terminology and correct only conflicts with the approved decision.
2. Replace stale or duplicated documentation references with authoritative links where safe.
3. Preserve ARGUS as the sole analysis/explanation product name.
4. Preserve product behavior, architecture, task order, governance controls, and documented drift.
5. Run simulated Resume Work, Address Errors, audit-gate, and handoff workflows.
6. Update task, handoff, queue, history, counters, and build metadata only where required by accepted focused changes.
7. Complete TASK-0097 and activate TASK-0098 only after all acceptance criteria pass and no audit gate or blocker intervenes.

## Prohibited Scope

- No application feature work.
- No new architecture or governance.
- No helper framework or native replacement work.
- No task resequencing.
- No cleanup of preserved drift.

## Validation
Repository terminology inventory and simulated Resume Work, Address Errors, audit-gate, and handoff workflows.
