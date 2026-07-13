# TASK-0071 - Finish Line Project Plan

## Status
Complete

## Owner
Codex

## Purpose
Create an actionable finish-line roadmap so the project can move from punch-list cleanup to release completion without drifting.

## Scope
- Assess the current roadmap, task queue, backlog, and handoff state.
- Clarify that ARGUS has a foundation slice but still needs product-level planning and implementation depth.
- Define the remaining release phases and ordered task queue.
- Capture known non-immediate work:
  - First-render tab switching lag.
  - Antivirus/EDR false-positive handling for embedded tools.
- Reconcile the post-TASK-0070 GitHub sync state in handoff documentation.

## Out Of Scope
- Implementing ARGUS.
- Changing GUI behavior.
- Attempting to hide tools from antivirus or EDR products.
- Downloading, installing, packing, encrypting, obfuscating, or otherwise changing embedded tools.
- Cleaning unrelated runtime drift.

## Acceptance Criteria
- [x] A finish-line roadmap exists in repository documentation.
- [x] `docs/ROADMAP.md` reflects the remaining phases and near-release focus.
- [x] `docs/TASKS/QUEUE.md` contains an ordered queue for the remaining project work.
- [x] ARGUS remaining work is explicit and no longer just a vague future phase.
- [x] EDR/antivirus handling is framed as trust, provenance, signing, allowlisting, optional packaging, and false-positive reduction rather than evasion.
- [x] Handoff state reflects the GitHub sync already performed after TASK-0070.

## Completion Notes
- Added `docs/PROJECT-FINISH-PLAN.md`.
- Replaced the stale completed-task-only consolidated plan with a release-focused queued task sequence.
- Added queued tasks TASK-0072 through TASK-0080 to carry ARGUS, reporting, UI integration, performance, EDR-safe tooling, packaging, and release-candidate validation.
- Recorded that local and GitHub were synced after TASK-0070.
