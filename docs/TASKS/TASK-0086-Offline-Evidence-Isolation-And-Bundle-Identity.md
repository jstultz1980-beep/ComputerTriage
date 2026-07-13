# TASK-0086 - Offline Evidence Isolation and Bundle Identity

## Status
Complete

## Owner
Codex

## Depends On
TASK-0084 audit completion. Dependency satisfied on 2026-07-12.

## Objective
Ensure deterministic and ARGUS analysis operate on the intended immutable diagnostic run and never silently mix the analysis host’s live data into an offline bundle.

## Findings Addressed
- HF-006
- HF-009
- HF-010
- HF-012
- DEP-014

## Scope
- Add immutable run/bundle identity markers.
- Validate explicit/default bundle roots against the diagnostic contract.
- Separate offline bundle analysis from any live-host mode.
- Remove current-host CIM/environment data from offline analysis.
- Exclude generated `Analysis`, `Metadata`, `ARGUS`, and report outputs from source evidence inventory.
- Make repeated analysis idempotent apart from documented generation timestamps.
- Require ARGUS to use the validated run identity.

## Out Of Scope
- Broad new deterministic rules.
- Recommendation changes except those required to preserve source identity.
- GUI redesign.

## Acceptance Criteria
- [x] Computer-A fixture analyzed on Computer-B contains no Computer-B identity or health data.
- [x] Invalid, empty, partial, and unrelated export directories are rejected.
- [x] Default selection considers only valid bundles.
- [x] Repeated analysis does not treat generated output as evidence.
- [x] Run identity is preserved through deterministic and ARGUS artifacts.

## Completion Notes
- Added a shared diagnostic bundle validator and deterministic immutable bundle ID derived from collection `runId`, computer identity, and collection start time.
- Removed live-host environment/CIM identity and storage checks from offline deterministic analysis.
- Bound deterministic, ARGUS, HTML/Markdown report, GUI selection, and client-data transfer paths to validated run identity.
- Excluded generated `Analysis`, `Metadata`, `ARGUS`, and report outputs from source evidence inventory.

## Work Log

### Entry 001
Author: Codex
Date: 2026-07-12
Summary: Implemented offline evidence isolation, validated bundle selection, immutable run identity, downstream identity propagation, and transfer verification.
Files Changed:
- `Core/Analysis/DiagnosticBundleIdentity.ps1`
- `App/NetworkToolkit/Core/LocalAnalysisEngine.ps1`
- `App/NetworkToolkit/Core/LocalAnalysisRules.ps1`
- `Core/Argus/ArgusFoundation.ps1`
- `Core/Argus/ArgusReporting.ps1`
- `App/NetworkToolkit/Utilities/ClientDataTransfer.ps1`
- `App/ToolKit-GUI/ToolKit-GUI.ps1`
- `App/NetworkToolkit/Tests/Test-DiagnosticBundleIdentity.ps1`
Validation Performed:
- PowerShell parser validation for every changed script.
- Cross-machine Computer-A fixture on the current host.
- Invalid, empty, partial, unrelated, mixed-export, conflicting-identity, and newest-valid default-selection fixtures.
- Two-run generated-output exclusion and immutable identity checks.
- ARGUS run/bundle identity propagation and report generation.
- Client-data transfer run identity verification.
- GUI smoke and button-smoke tests.
Issues:
- None.
Instructions for Next Owner:
- Execute TASK-0087 parser-backed evidence quality and timeline semantics only.

## Validation
Use cross-machine, mixed-export, invalid-root, and two-run idempotence fixtures. Run parser, smoke, and button-smoke validation.

## Rollback
Revert only bundle identity/isolation changes and restore the previous explicit analysis path; do not remove audit fixtures.
