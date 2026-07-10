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
- `TASK-0023-ARGUS-Foundation-Implementation` exists as a focused implementation task.

## Phase 04 - Documentation and Task System Audit Gate
Status: Completed

Goal: complete the required audit because Documentation reached `10 / 10` during TASK-0020.

Completion basis:
- `TASK-0035-Documentation-Task-System-Audit` completed.
- Documentation and Task System counters were audited and reset.
- Implementation gate is cleared.

## Phase 05 - ARGUS Foundation
Status: Completed

Goal: implement the minimal ARGUS foundation slice using accepted ADR-0003.

Current active task:
- None.

TASK-0023 must:
- Load and validate required HEPHAESTUS contract artifacts.
- Produce ARGUS input validation output.
- Produce a small analysis summary that prioritizes deterministic HEPHAESTUS findings.
- Clearly label deterministic evidence, normalized evidence, raw evidence, ARGUS inference, and unsupported conclusions.
- Produce a basic ARGUS report artifact.

Completion basis:
- `TASK-0023-ARGUS-Foundation-Implementation` completed.
- ARGUS Foundation validates required HEPHAESTUS contract artifacts.
- ARGUS Foundation writes `ARGUS/input-validation.json`, `ARGUS/analysis-summary.json`, and `ARGUS/report.md`.
- Validation confirmed JSON outputs parse and deterministic findings are labeled separately from ARGUS inference.

## Phase 06 - HEPHAESTUS Rule Catalog Expansion
Status: Completed

Expand deterministic rule coverage after the v1 vertical slice exists and validates.

Planned future capabilities:
- Broader service, process, driver, storage, Windows Update, network, security-product, domain-health, DFSR, SYSVOL, and GPO interpretation.
- Additional normalized JSON outputs.
- More robust timeline correlation.

Completion basis:
- `TASK-0021-HEPHAESTUS-Rule-Catalog-Expansion` completed the next deterministic rule expansion.
- Added explainable rules for APIPA network evidence, Windows Update service repair signals, endpoint protection disabled signals, stopped automatic services, and domain secure-channel/logon failures.
- Existing HEPHAESTUS output paths remain compatible with ARGUS.

## Phase 07 - ARGUS Evidence Normalization
Status: Planned

Add ARGUS-side evidence loading, trust boundaries, and explanation logic after the foundation implementation is validated.

## Phase 08 - Reporting
Status: Planned

Improve technician and executive reporting after deterministic findings and normalized outputs exist.

## Phase 09 - UI Integration
Status: Active

Add Collect and Analyze workflow integration after collection, local analysis, and reporting contracts are stable.

Current active task:
- None.

Recently completed UI work:
- `TASK-0028-Quick-Dx-Compact-Run-Panel` removed the visible Quick Dx internet target chain and compacted the run panel while preserving the internal fallback target order.
- `TASK-0029-Choco-Page-Layout-Refinement` compacted the Chocolatey status strip and restored readable status action buttons.

Implementation pause:
- TASK-0041 completed the required UI counter audit after TASK-0029. UI implementation may continue under active focused tasks.

Current UI work:
- TASK-0037 completed Activity page network visibility, compact process list, and compact controls.
- TASK-0030 completed Print tab data-path cleanup.
- TASK-0031 completed Triage page simplification.
- TASK-0042 completed the required documentation audit gate after the Documentation counter reached 10/10.
- TASK-0032 completed Computer tab summary redesign.
- TASK-0048 completed the required Task System audit gate after the Task System counter reached 10/10.
- TASK-0038 completed modern control styling for Settings/Help header controls and the crown/elevation icon.
- TASK-0045 completed Print page polish.
- TASK-0049 completed the required UI audit gate after the UI counter reached 10/10.
- TASK-0046 completed Triage page catalog and bundle cleanup.
- TASK-0050 completed the required Roadmap/Backlog audit after outstanding tasks were consolidated.
- TASK-0052 completed the required Documentation audit after TASK-0046/build metadata updates reached 10/10.
- TASK-0047 completed status-bar Wi-Fi signal, Wi-Fi page signal, Windows Update service health, clarified busy chrome, and preserved bottom-left version/build placement.
- TASK-0044 completed GUI startup/tab performance hardening and slow-tab diagnostics.
- TASK-0053 completed the required Task System counter audit and reset only the audited counter.
- TASK-0043 completed technician-safe client diagnostic data transfer between toolkit copies.
- TASK-0051 completed development-only deployment/update exclusions.
- TASK-0040 completed Software tab launchable/installable placement and portable-tool classification.
- TASK-0033 completed tab-by-tab direction and embedded-tool planning.
- TASK-0059 completed the required Documentation and Build System counter audit after TASK-0033.
- TASK-0054 completed Directory domain identity and AD health status.
- The audit threshold was raised from 10 changes to 25 changes, so TASK-0060 was archived before execution.
- TASK-0061 completed Directory page layout polish from the punch list.
- TASK-0055 completed the shared embedded output pattern and converted Quick Target Checks to use it.
- TASK-0056 completed Triage guided workflow polish.
- TASK-0057 completed Wi-Fi and Windows status polish.
- TASK-0058 completed Settings and control polish.
- TASK-0062 completed computer data push/pull.
- TASK-0063 completed Add-Ons concept testing.
- TASK-0064 completed product naming options.
- TASK-0021 completed HEPHAESTUS rule catalog expansion.
- TASK-0065 completed UI regression polish from the latest punch-list additions.
- TASK-0066 completed RapidAssist naming selection.
- TASK-0067 completed UI feedback corrections from user verification.
- TASK-0068 completed Triage instruction and Windows Update LED refinement.
- TASK-0069 completed Triage text-driven workflow refinement.
- Wi-Fi status-bar behavior has been verified on hardware with Wi-Fi.

## Phase 10 - Release Hardening
Status: Planned

Validation, packaging, documentation, and release preparation.
