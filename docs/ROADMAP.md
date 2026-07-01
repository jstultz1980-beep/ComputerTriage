# Roadmap

## Phase 00 - Foundation Zero
Status: Completed

Goal: establish repository source-of-truth documents, handoff protocol, task tracking, decision tracking, and audit counter controls.

Foundation Audit status:
- Completed as `TASK-0011-Foundation-Audit`.
- Reconciled by `REVIEW-0001-Foundation-Audit` on 2026-07-01.
- `TASK-0010-Foundation-Audit` is not valid active tracked state because TASK-0010 is already used by the completed drift/status task.

## Phase 01 - HEPHAESTUS Collection Baseline
Status: Completed

Goal: ensure the collection workflow is stable, portable, predictable, and validation-ready before local analysis work begins.

Completion basis:
- `TASK-0017-Triage-Manual-Run-Validation` passed smoke and button-smoke validation.
- Runtime drift was documented and excluded from commits.

## Phase 02 - HEPHAESTUS Local Analysis Engine v1
Status: Completed

Goal: add deterministic local analysis after collection baseline validation.

Completion basis:
- `TASK-0018-HEPHAESTUS-Local-Analysis-Engine-v1-Design` completed design and ADR work.
- `TASK-0019-HEPHAESTUS-Local-Analysis-Engine-v1-Implementation` implemented the minimal vertical slice.
- Local validation confirmed required `Analysis` and `Metadata` artifacts exist and JSON parses successfully.
- Smoke and button-smoke tests passed after implementation.

Delivered capabilities:
- Safe CLI command path: `Run Local Analysis`.
- Analysis output folders.
- Schema and bundle capability metadata.
- Findings, timeline, evidence score, and machine-profile JSON outputs.
- Starter deterministic rule runner.
- Evidence-quality handling for missing or failed evidence.
- Local HTML report generated from structured outputs.

## Phase 03 - ARGUS Input Contract
Status: Completed

Goal: finalize the contract ARGUS will use to consume HEPHAESTUS deterministic outputs before ARGUS implementation begins.

Completion basis:
- `TASK-0020-ARGUS-Input-Contract-ADR` completed.
- `docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md` is accepted.
- `TASK-0023-ARGUS-Foundation-Implementation` exists as a focused queued implementation task.

## Phase 04 - Documentation and Task System Audit Gate
Status: Active

Goal: complete the required audit because Documentation reached `10 / 10` during TASK-0020.

Current active task:
- `TASK-0035-Documentation-Task-System-Audit`

Implementation work must not begin until the audit gate clears.

## Phase 05 - HEPHAESTUS Rule Catalog Expansion
Status: Planned

Expand deterministic rule coverage after the v1 vertical slice exists and validates.

Planned future capabilities:
- Broader service, process, driver, storage, Windows Update, network, security-product, domain-health, DFSR, SYSVOL, and GPO interpretation.
- Additional normalized JSON outputs.
- More robust timeline correlation.

## Phase 06 - ARGUS Foundation
Status: Planned

Build ARGUS only after HEPHAESTUS produces stable normalized outputs, the ARGUS input contract is finalized, and the required audit gate clears.

## Phase 07 - ARGUS Evidence Normalization
Status: Planned

Add ARGUS-side evidence loading, trust boundaries, and explanation logic after the input contract is approved and implementation is active.

## Phase 08 - Reporting
Status: Planned

Improve technician and executive reporting after deterministic findings and normalized outputs exist.

## Phase 09 - UI Integration
Status: Planned

Add Collect and Analyze workflow integration after collection, local analysis, and reporting contracts are stable.

## Phase 10 - Release Hardening
Status: Planned

Validation, packaging, documentation, and release preparation.
