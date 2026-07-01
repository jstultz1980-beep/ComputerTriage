# Roadmap

## Phase 00 - Foundation Zero
Status: Completed

Goal: establish repository source-of-truth documents, handoff protocol, task tracking, decision tracking, and audit counter controls.

Foundation Audit status:
- Completed as `TASK-0011-Foundation-Audit`.
- Reconciled by `REVIEW-0001-Foundation-Audit` on 2026-07-01.
- `TASK-0010-Foundation-Audit` is not valid tracked state because TASK-0010 is already used by the completed drift/status task.

## Phase 01 - HEPHAESTUS Collection Baseline
Status: Active

Goal: ensure the collection workflow is stable, portable, predictable, and validation-ready before local analysis work begins.

Current active task:
- `TASK-0017-Triage-Manual-Run-Validation`

Immediate sequence:
1. Codex completes `TASK-0017-Triage-Manual-Run-Validation` without adding features.
2. ChatGPT creates/designs `TASK-0018-HEPHAESTUS-Local-Analysis-Engine-v1-Design` with ADR coverage.
3. Codex implements only the activated, approved next task after design is complete.

## Phase 02 - HEPHAESTUS Local Analysis Engine v1
Status: Planned

Goal: add deterministic local analysis after collection baseline validation.

Planned capabilities:
- Rule engine.
- Structured findings.
- Event correlation and timeline generation.
- Machine profile generation.
- Evidence quality scoring.
- Security product inventory.
- Driver, storage, Windows Update, network, and domain-health interpretation where evidence exists.
- Local HTML executive report.
- Normalized JSON outputs and schema/capability metadata.

## Phase 03 - ARGUS Foundation
Status: Planned

Build ARGUS only after HEPHAESTUS produces stable normalized outputs and an ADR defines the ARGUS input contract.

## Phase 04 - ARGUS Evidence Normalization
Status: Planned

Add ARGUS-side evidence loading, trust boundaries, and explanation logic after the input contract is approved.

## Phase 05 - Reporting
Status: Planned

Improve technician and executive reporting after deterministic findings and normalized outputs exist.

## Phase 06 - UI Integration
Status: Planned

Add Collect and Analyze workflow integration after collection, local analysis, and reporting contracts are stable.

## Phase 07 - Release Hardening
Status: Planned

Validation, packaging, documentation, and release preparation.
