# TASK-0076 - Analyze Workflow UI Integration

## Status
Complete

## Owner
Codex

## Purpose
Connect collection, local analysis, ARGUS, and reports into a normal technician workflow.

## Scope
- Refine the Analyze page workflow.
- Add normal GUI access to latest analysis and report outputs.
- Surface limited-evidence and missing-artifact states clearly.
- Preserve existing console commands for advanced use.

## Out Of Scope
- New ARGUS reasoning features.
- Broad tab redesign.
- Deployment/package changes.

## Acceptance Criteria
- [x] Analyze workflow can run or open the expected analysis/report outputs.
- [x] Missing/limited evidence states are visible and understandable.
- [x] Normal use does not require console commands.
- [x] GUI smoke and button-smoke validation pass.

## Completion Notes
The Analyze page now provides a guided Collect, Analyze, Review workflow. Complete Analysis runs HEPHAESTUS and ARGUS through the embedded safe runner; direct actions open the local, technician, and escalation reports or latest bundle; status text distinguishes missing local analysis, missing ARGUS output, valid output, and limited evidence.

## Work Log

### Entry 001
Author: Codex
Date: 2026-07-10
Summary: Replaced the generic-only Analyze page with a guided workflow while preserving advanced analysis tools below it.
Files Changed:
- `App/ToolKit-GUI/ToolKit-GUI.ps1`
- `docs/TASKS/TASK-0076-Analyze-Workflow-UI-Integration.md`
Validation Performed:
- GUI PowerShell parser validation.
- GUI smoke test.
- Button-smoke test including all Analyze workflow controls and resolved status text.
- Current bundle status resolved as limited mode with reports available.
Issues:
- The first nested catalog composition used a TabPage-only helper and failed button-smoke; it was replaced with the control-compatible compact grid helper.
Instructions for Next Owner:
- Complete TASK-0085 Documentation Counter Audit before starting TASK-0077.
