# Task Queue

This file is the task-state source of truth alongside `docs/HANDOFF.md`.

## Current Rule
Exactly one task may have `Active` status at a time. No implementation work may begin unless the active task exists under `docs/TASKS` and `docs/HANDOFF.md` names the same task.

## Active

| Task | Owner | Status | Purpose |
|---|---|---|---|
| `TASK-0063-Add-Ons-Concept` | Codex | Active | Prototype a clearer Add-Ons experience for installable non-portable programs. |

## Queued

| Task | Owner | Status | Purpose |
|---|---|---|---|
| `TASK-0064-Product-Naming-Options` | Codex | Queued | Record five better product-name options before any rename work. |
| `TASK-0021-HEPHAESTUS-Rule-Catalog-Expansion` | Codex | Queued | Expand deterministic rules after the v1 vertical slice exists and validates. |

## Consolidated Plan

The remaining work is intentionally ordered from shared UI foundation to page-specific polish, data movement, Add-Ons concept testing, naming, then analysis-engine depth:

1. `TASK-0056-Triage-Guided-Workflow-Polish` handles punch-list items 24 and 25.
2. `TASK-0057-WiFi-And-Windows-Status-Polish` handles punch-list items 16, 17, 18, 19, 20, and 29.
3. `TASK-0058-Settings-And-Control-Polish` handles punch-list items 21, 22, 23, 26, and 28.
4. `TASK-0062-Computer-Data-Push-Pull` handles punch-list item 32.
5. `TASK-0063-Add-Ons-Concept` handles punch-list item 33.
6. `TASK-0064-Product-Naming-Options` handles punch-list item 34.
7. `TASK-0021-HEPHAESTUS-Rule-Catalog-Expansion` resumes deterministic analysis-rule depth after the current GUI cleanup pass.

## Completed / Historical

| Task | Status | Notes |
|---|---|---|
| `TASK-0010-Classify-Drift-And-Status-Report` | Completed | Historical TASK-0010. This number is already used and must not be reused for Foundation Audit. |
| `TASK-0010-Foundation-Audit` | Archived | Local governance-prep task created from an invalid duplicate TASK-0010 reference; superseded by completed TASK-0011 and REVIEW-0001. |
| `TASK-0011-Foundation-Audit` | Completed | Actual tracked Foundation Audit task. It supersedes the untracked/incorrect `TASK-0010-Foundation-Audit` reference. |
| `TASK-0012-Phase-Transition-Readiness` | Completed | Transitioned from Foundation Zero to Phase 01. |
| `TASK-0013-Header-Tool-Search` | Completed | GUI header tool search. |
| `TASK-0014-DHCP-Sleuth-Restoration` | Completed | DHCP Sleuth restoration per handoff history. |
| `TASK-0015-Header-Search-Tab-Mapping-Correction` | Completed | Search tab mapping correction per handoff history. |
| `TASK-0016-Tool-Source-Of-Truth-Correction` | Completed | GUI tool registry/source-of-truth correction per handoff history. |
| `TASK-0017-Triage-Manual-Run-Validation` | Completed | Existing smoke and button-smoke validation passed; runtime drift was documented and excluded. |
| `TASK-0018-HEPHAESTUS-Local-Analysis-Engine-v1-Design` | Completed | Design, ADRs, and focused TASK-0019 implementation scope completed. |
| `TASK-0019-HEPHAESTUS-Local-Analysis-Engine-v1-Implementation` | Completed | Minimal vertical slice implemented and validated locally; required artifacts generated and smoke tests passed. |
| `TASK-0020-ARGUS-Input-Contract-ADR` | Completed | ADR-0003 accepted; ARGUS input contract, trust model, and focused TASK-0023 implementation scope finalized. |
| `TASK-0023-ARGUS-Foundation-Implementation` | Completed | Minimal ARGUS foundation slice implemented and validated against HEPHAESTUS Local Analysis artifacts. |
| `TASK-0024-Quick-Dx-Layout-Adjustment` | Completed | Adjusted Quick Diagnosis tab layout so Quick Target Checks owns the full left column and Quick Diagnosis controls are compacted into the right column. |
| `TASK-0025-Quick-Dx-Last-Scan-Label-Fix` | Completed | Fixed the clipped Last Quick Diagnosis label in the compact right-column Quick Diagnosis block. |
| `TASK-0026-Quick-Dx-Fixed-Internet-Targets` | Completed | Replaced the editable Quick Diagnosis internet target with a fixed primary/backup target chain. |
| `TASK-0027-GUI-Polish-QuickDx-Header-Choco-Theme` | Completed | Polished Quick Dx spacing, header health badge space, Choco layout, surface gradient/texture, and added Terminal Dark. |
| `TASK-0035-Documentation-Task-System-Audit` | Completed | Audited documentation/task-state consistency, reset audited counters, and cleared the implementation gate. |
| `TASK-0028-Quick-Dx-Compact-Run-Panel` | Completed | Removed the visible Quick Dx internet target chain and compacted the run panel while preserving internal fallback targets. |
| `TASK-0029-Choco-Page-Layout-Refinement` | Completed | Reworked the Choco status area into a compact strip with readable action buttons and preserved existing package-management behavior. |
| `TASK-0041-UI-Counter-Audit` | Completed | Audited recent UI task work, reset the UI counter, and cleared the implementation gate. |
| `TASK-0037-Activity-Page-Running-Tool-Tracking` | Completed | Added Activity Network gauge, fixed-height running-process list, compact controls, and slower refresh interval. |
| `TASK-0030-Print-Tab-Data-Path-Cleanup` | Completed | Removed the visible print queue data-folder path and preserved print queue maintenance output behavior. |
| `TASK-0031-Triage-Page-Simplification` | Completed | Simplified the Triage tab to Quick Triage and Full Triage, removed normal-view advanced collector clutter, and replaced the live log with concise status/output access. |
| `TASK-0032-Computer-Tab-Summary-Redesign` | Completed | Reworked the Computer tab around a richer current-computer summary with LED indicators and a compact profile table. |
| `TASK-0038-Modern-Control-Style-System` | Completed | Cleaned up header Settings/Help controls, reduced the crown/elevation icon, and preserved shared rounded button styling. |
| `TASK-0042-Documentation-Counter-Audit` | Completed | Audited documentation/task-state consistency after the Documentation counter reached 10/10 and reset the audited counter. |
| `TASK-0045-Print-Page-Polish` | Completed | Removed the redundant Print diagnostics subheading and fixed clipped Print Queue discovery controls. |
| `TASK-0046-Triage-Page-Catalog-And-Bundle-Cleanup` | Completed | Simplified the Triage action row, removed visible catalog noise, removed the visible manifest export action, and made bundle names more descriptive. |
| `TASK-0048-Task-System-Counter-Audit` | Completed | Audited task-state consistency after the Task System counter reached 10/10 and reset the audited counter. |
| `TASK-0049-UI-Counter-Audit` | Completed | Audited UI task history after the UI counter reached 10/10 and reset the audited counter. |
| `TASK-0047-Status-Bar-Indicators-And-Chrome-Cleanup` | Completed | Added status-bar Wi-Fi, Wi-Fi page signal, Windows Update service health, clarified busy chrome, and preserved bottom-left version/build. |
| `TASK-0044-GUI-Tab-Performance-Hardening` | Completed | Deferred startup tab construction, deferred Activity refresh, trimmed VBS launch flags, and added slow tab diagnostics. |
| `TASK-0053-Task-System-Counter-Audit` | Completed | Audited task-state consistency after Task System reached 10/10 and reset only the audited counter. |
| `TASK-0043-Client-Data-Transfer` | Completed | Added Settings workflow to validate a destination toolkit, transfer client diagnostic data only, and write a transfer manifest. |
| `TASK-0051-Development-File-Deployment-Exclusions` | Completed | Added shared deployment exclusion policy, documented dev-only files, and validated fake fresh deployment/update exclusions. |
| `TASK-0040-Software-Inventory-And-Placement-Implementation` | Completed | Split Software tab launchable/installable areas, classified Registrar and LatencyMon, and removed non-portable/redundant triage entries. |
| `TASK-0033-Tab-By-Tab-Direction-And-Embedding-Plan` | Completed | Decided Directory/Network/Infrastructure boundaries, selected Quick Target Checks as the preferred embedded-output pattern, and created follow-on implementation tasks. |
| `TASK-0022-HEPHAESTUS-Portable-Tool-Classification` | Archived | Consolidated into `TASK-0040-Software-Inventory-And-Placement-Implementation`. |
| `TASK-0034-Embedded-Tool-Experience-Roadmap` | Archived | Consolidated into `TASK-0033-Tab-By-Tab-Direction-And-Embedding-Plan`. |
| `TASK-0036-Page-Health-Indicators` | Archived | Consolidated into `TASK-0047-Status-Bar-Indicators-And-Chrome-Cleanup`. |
| `TASK-0039-Software-Tab-Launchable-And-Installable-Inventory` | Archived | Consolidated into `TASK-0040-Software-Inventory-And-Placement-Implementation`. |
| `TASK-0050-Roadmap-Backlog-Counter-Audit` | Completed | Audited roadmap/backlog consistency after task consolidation reached 10/10 and reset the audited counter. |
| `TASK-0052-Documentation-Counter-Audit` | Completed | Audited documentation consistency after TASK-0046/build metadata updates reached 10/10 and reset the audited counter. |
| `TASK-0059-Documentation-Build-Counter-Audit` | Completed | Audited TASK-0033 documentation and build metadata changes, reset only the Documentation and Build System counters, and cleared the implementation gate. |
| `TASK-0054-Directory-Domain-Status-Page` | Completed | Added Directory domain identity and AD health status summary with visible Domain Logon Health, GPO Health, and GPResult actions. |
| `TASK-0060-UI-Counter-Audit` | Archived | Superseded before execution when the audit threshold changed from 10 changes to 25 changes. |
| `TASK-0061-Directory-Page-Layout-Polish` | Completed | Compacted the Directory page status area, removed the Directory refresh button, and preserved domain/policy actions. |
| `TASK-0055-Shared-Embedded-Output-Pattern` | Completed | Added shared embedded command-output helpers and converted Quick Target Checks to use them. |
| `TASK-0056-Triage-Guided-Workflow-Polish` | Completed | Replaced the visible Triage catalog/notes area with a guided collect, review, and submit workflow. |
| `TASK-0057-WiFi-And-Windows-Status-Polish` | Completed | Polished Windows Update repair status and Wi-Fi LED/network status presentation. |
| `TASK-0058-Settings-And-Control-Polish` | Completed | Compacted Settings controls, tab strip, header logo, shared buttons, and removed registered-command startup noise. |
| `TASK-0062-Computer-Data-Push-Pull` | Completed | Added Push/Pull direction selection to the technician-safe client/computer data transfer workflow. |

## Reconciliation Decision

`TASK-0010-Foundation-Audit` must not remain active because `TASK-0010` is already occupied by `TASK-0010-Classify-Drift-And-Status-Report`, and the repository contains `TASK-0011-Foundation-Audit` as the completed Foundation Audit task. The current reconciliation does not delete or rename historical task files. The clean source of truth is:

- Historical TASK-0010 remains completed as drift classification/status reporting.
- The invalid duplicate TASK-0010 Foundation Audit prep task is archived.
- Foundation Audit remains completed as TASK-0011.
- Current active task is TASK-0063.
