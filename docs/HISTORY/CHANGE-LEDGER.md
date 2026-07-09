# Change Ledger

This ledger records accepted engineering changes that increment subsystem audit counters.

A subsystem counter reaching `25 / 25` requires a new audit before additional implementation work continues.

After an audit is completed, the audited subsystem counter resets to `0 / 25` and the audit completion is recorded here.

| Change ID | Date | Task | Subsystem | Counter Change | Description |
|---|---|---|---|---:|---|
| CHG-0001 | 2026-06-30 | TASK-0009 | Repository Governance | +1 | Added audit state tracking rule to `PROJECT.md`, `docs/HANDOFF.md`, and this ledger. |
| CHG-0002 | 2026-06-30 | TASK-0009 | Task System | +1 | Added subsystem change counter process and next-task enforcement to the handoff workflow. |
| CHG-0003 | 2026-06-30 | TASK-0009 | Documentation | +1 | Documented audit counter reset behavior and mandatory audit trigger threshold. |
| CHG-0004 | 2026-06-30 | TASK-0010 | Repository Governance | +1 | Classified runtime drift, reset runtime-only custom tools manifest changes, and ignored generated ServiWin configuration. |
| CHG-0005 | 2026-06-30 | TASK-0010 | Documentation | +1 | Updated task and handoff records with runtime drift cleanup status and project status reporting. |
| CHG-0006 | 2026-06-30 | TASK-0011 | Repository Governance | reset to 0 / 10 | Completed foundation audit, verified GitHub tracking, reset runtime-only manifest drift, and broadened generated tool config ignore coverage. |
| CHG-0007 | 2026-06-30 | TASK-0011 | Documentation | reset to 0 / 10 | Completed foundation audit, corrected stale architecture path casing, and refreshed handoff state. |
| CHG-0008 | 2026-06-30 | TASK-0011 | Task System | reset to 0 / 10 | Completed foundation audit and normalized the TASK-0009 status wording. |
| CHG-0009 | 2026-06-30 | TASK-0012 | Task System | +1 | Created and completed phase-transition readiness task after the foundation audit. |
| CHG-0010 | 2026-06-30 | TASK-0012 | Roadmap/Backlog | +1 | Marked Phase 00 complete and Phase 01 HEPHAESTUS Collection Baseline active. |
| CHG-0011 | 2026-06-30 | TASK-0012 | Documentation | +1 | Refreshed handoff and changelog for post-foundation transition state. |
| CHG-0012 | 2026-06-30 | TASK-0013 | UI | +1 | Added header autocomplete tool search that navigates to the selected tool's tab. |
| CHG-0013 | 2026-06-30 | TASK-0013 | Task System | +1 | Created and completed the header tool search task. |
| CHG-0014 | 2026-06-30 | TASK-0013 | Documentation | +1 | Updated handoff, changelog, and task completion notes for header tool search. |
| CHG-0015 | 2026-06-30 | TASK-0014 | Plugin Framework | +1 | Restored DHCP Sleuth as a tracked standalone toolkit app and registered it in the custom tools manifest. |
| CHG-0016 | 2026-06-30 | TASK-0014 | UI | +1 | Hardened GUI smoke-test cleanup and launcher test-mode singleton handling so validation works while the toolkit is open. |
| CHG-0017 | 2026-06-30 | TASK-0014 | Task System | +1 | Created and completed the DHCP Sleuth restore task. |
| CHG-0018 | 2026-06-30 | TASK-0014 | Documentation | +1 | Updated task, handoff, and changelog records for DHCP Sleuth restoration. |
| CHG-0019 | 2026-06-30 | TASK-0015 | UI | +1 | Rebuilt header search tab mapping from the same tool placement path used by visible tab pages. |
| CHG-0020 | 2026-06-30 | TASK-0015 | Task System | +1 | Created and completed the header search tab mapping correction task. |
| CHG-0021 | 2026-06-30 | TASK-0015 | Documentation | +1 | Updated task, handoff, and changelog records for search tab mapping correction. |
| CHG-0022 | 2026-06-30 | TASK-0016 | UI | +1 | Centralized visible GUI tab tools and header search entries through one normalized tool registry path and hardened triage completion handling. |
| CHG-0023 | 2026-06-30 | TASK-0016 | Validation/Test Framework | +1 | Added button smoke-test checks for duplicate GUI registry and header search entries. |
| CHG-0024 | 2026-06-30 | TASK-0016 | Task System | +1 | Created and completed the tool source-of-truth correction task. |
| CHG-0025 | 2026-06-30 | TASK-0016 | Documentation | +1 | Updated task, handoff, and changelog records for tool source-of-truth correction. |
| CHG-0026 | 2026-07-01 | TASK-0010 | Repository Governance | +1 | Added the official task queue rule and lifecycle reference to `PROJECT.md`. |
| CHG-0027 | 2026-07-01 | TASK-0010 | Documentation | +1 | Added the Prime Directive, governance responsibilities, and handoff updates for the foundation audit. |
| CHG-0028 | 2026-07-01 | TASK-0010 | Task System | +1 | Created `docs/TASKS/QUEUE.md` and activated `TASK-0010-Foundation-Audit` for ChatGPT. |
| CHG-0029 | 2026-07-01 | TASK-0010 | Roadmap/Backlog | +1 | Established the queued-task structure that ChatGPT will use to update the backlog during the foundation audit. |
| CHG-0030 | 2026-07-01 | TASK-0010 / REVIEW-0001 | Repository Governance | reset to 0 / 10 | Reconciled governance source of truth, aligned `docs/TASKS/QUEUE.md` and `docs/HANDOFF.md`, and resolved the invalid duplicate `TASK-0010-Foundation-Audit` active-state reference. |
| CHG-0031 | 2026-07-01 | TASK-0010 / REVIEW-0001 | Task System | reset to 0 / 10 | Established exactly one active task in the queue and handoff: `TASK-0017-Triage-Manual-Run-Validation`. |
| CHG-0032 | 2026-07-01 | TASK-0010 / REVIEW-0001 | Documentation | reset to 0 / 10 | Created `REVIEW-0001-Foundation-Audit` and executive project status report; refreshed handoff. |
| CHG-0033 | 2026-07-01 | TASK-0010 / REVIEW-0001 | Roadmap/Backlog | reset to 0 / 10 | Updated roadmap and backlog/task sequence for validation, HEPHAESTUS Local Analysis Engine design, and later implementation. |
| CHG-0034 | 2026-07-01 | TASK-0017 | Validation/Test Framework | +1 | Ran existing smoke and button-smoke validation paths and recorded runtime drift without application-code changes. |
| CHG-0035 | 2026-07-01 | TASK-0017 | Task System | +1 | Completed TASK-0017 and activated TASK-0018 as the next design gate. |
| CHG-0036 | 2026-07-01 | TASK-0017 | Documentation | +1 | Updated task, queue, handoff, and changelog records for validation completion and next-task handoff. |
| CHG-0037 | 2026-07-01 | TASK-0018 | Architecture | +1 | Defined HEPHAESTUS Local Analysis Engine v1 pipeline, responsibility boundaries, output artifacts, rule engine, and parser failure behavior. |
| CHG-0038 | 2026-07-01 | TASK-0018 | HEPHAESTUS | +1 | Accepted deterministic local analysis as a HEPHAESTUS responsibility before ARGUS interpretation. |
| CHG-0039 | 2026-07-01 | TASK-0018 | Documentation | +1 | Created Local Analysis Engine design document and ADRs. |
| CHG-0040 | 2026-07-01 | TASK-0018 | Task System | +1 | Completed TASK-0018 and activated focused TASK-0019 implementation work for Codex. |
| CHG-0041 | 2026-07-01 | TASK-0018 | Roadmap/Backlog | +1 | Updated roadmap and queued follow-on tasks for implementation, ARGUS contract, rule expansion, and portable-tool classification. |
| CHG-0042 | 2026-07-01 | TASK-0019 | HEPHAESTUS | +1 | Began Local Analysis Engine v1 implementation with a Core module that generates Analysis and Metadata artifacts through a safe CLI command path. |
| CHG-0043 | 2026-07-01 | TASK-0019 | Documentation | +1 | Updated TASK-0019 work log, handoff, changelog, and ledger for implementation-start state and validation requirements. |
| CHG-0044 | 2026-07-01 | TASK-0019 | HEPHAESTUS | +1 | Patched Local Analysis Engine function scope so the registered command remains callable after module import. |
| CHG-0045 | 2026-07-01 | TASK-0019 | Validation/Test Framework | +1 | Validated Local Analysis output artifacts, JSON parse behavior, smoke test, and button-smoke test. |
| CHG-0046 | 2026-07-01 | TASK-0019 | Task System | +1 | Completed TASK-0019 and activated TASK-0020 as the next ChatGPT-owned ADR task. |
| CHG-0047 | 2026-07-01 | TASK-0019 | Documentation | +1 | Recorded TASK-0019 completion, validation evidence, queue state, roadmap state, changelog, and handoff updates. |
| CHG-0048 | 2026-07-01 | TASK-0024 | UI | +1 | Reworked the Quick Diagnosis tab layout so Quick Target Checks owns the full left column and run controls are compacted into the right column. |
| CHG-0049 | 2026-07-01 | TASK-0024 | Task System | +1 | Created and completed a focused Quick Dx layout correction task without changing the active TASK-0020 design-gate scope. |
| CHG-0050 | 2026-07-01 | TASK-0024 | Documentation | +1 | Updated task, queue, handoff, changelog, and ledger records for the Quick Dx layout correction. |
| CHG-0051 | 2026-07-01 | TASK-0025 | UI | +1 | Fixed the clipped Last Quick Diagnosis label in the compact Quick Diagnosis block by giving it a stable visible row. |
| CHG-0052 | 2026-07-01 | TASK-0025 | Task System | +1 | Created and completed a focused Quick Dx last-scan label bugfix task without changing the active TASK-0020 design-gate scope. |
| CHG-0053 | 2026-07-01 | TASK-0025 | Documentation | +1 | Updated task, queue, handoff, changelog, and ledger records for the Quick Dx label clipping fix. |
| CHG-0054 | 2026-07-01 | TASK-0026 | UI | +1 | Replaced the editable Quick Diagnosis internet target with a fixed primary/backup target chain and static display label. |
| CHG-0055 | 2026-07-01 | TASK-0026 | Task System | +1 | Created and completed a focused Quick Dx fixed-target task without changing the active TASK-0020 design-gate scope. |
| CHG-0056 | 2026-07-01 | TASK-0026 | Documentation | +1 | Updated task, queue, handoff, changelog, and ledger records for the fixed Quick Diagnosis internet target chain. |
| CHG-0057 | 2026-07-01 | TASK-0027 | UI | +1 | Polished Quick Dx spacing, restored header health badge room, added Terminal Dark, expanded texture with a gradient, and compacted Choco status placement. |
| CHG-0058 | 2026-07-01 | TASK-0027 | Task System | +1 | Created and completed a focused GUI polish task without changing the active TASK-0020 design-gate scope. |
| CHG-0059 | 2026-07-01 | TASK-0027 | Documentation | +1 | Updated task, queue, handoff, changelog, and ledger records for the GUI polish pass. |
| CHG-0060 | 2026-07-01 | TASK-0028..TASK-0034 | Task System | +1 | Created queued tasks for Quick Dx, Choco, Print, Triage, Computer, Directory, and embedded-tool follow-up work without changing the active TASK-0020 gate. |
| CHG-0061 | 2026-07-01 | TASK-0028..TASK-0034 | Documentation | +1 | Documented requested UI/workflow changes as focused task files and refreshed handoff/changelog records. |
| CHG-0062 | 2026-07-01 | TASK-0028..TASK-0034 | Roadmap/Backlog | +1 | Added a prioritized queued backlog for the newly requested UI cleanup and embedded-tool planning work. |
| CHG-0063 | 2026-07-01 | TASK-0036..TASK-0040 | Task System | +1 | Created queued tasks for page indicators, Activity tracking, modern utility controls, and Software tab inventory/implementation while reconciling TASK-0035 as the active audit gate. |
| CHG-0064 | 2026-07-01 | TASK-0036..TASK-0040 | Documentation | +1 | Documented the newest requested UI/workflow changes and recorded that the Documentation counter is at 10/10. |
| CHG-0065 | 2026-07-01 | TASK-0036..TASK-0040 | Roadmap/Backlog | +1 | Added the newest requested UI/workflow refinements to the queued backlog behind the required audit gate. |
| CHG-0066 | 2026-07-01 | TASK-0020 | ARGUS | +1 | Accepted ADR-0003 and finalized the ARGUS input contract and evidence trust model. |
| CHG-0067 | 2026-07-01 | TASK-0035 | Documentation | reset to 0 / 10 | Completed the required documentation audit gate after the Documentation counter reached 10/10. |
| CHG-0068 | 2026-07-01 | TASK-0035 | Task System | reset to 0 / 10 | Completed the task-state audit, verified one active task, and activated TASK-0023 after the audit gate cleared. |
| CHG-0069 | 2026-07-02 | TASK-0023 | ARGUS | +1 | Implemented ARGUS Foundation contract validation, deterministic finding prioritization, labeled inference, and basic ARGUS output artifacts. |
| CHG-0070 | 2026-07-02 | TASK-0023 | Documentation | +1 | Updated task, queue, roadmap, handoff, changelog, and ledger records for TASK-0023 completion. |
| CHG-0071 | 2026-07-02 | TASK-0023 | Task System | +1 | Completed TASK-0023 and activated TASK-0028 as the next Codex implementation task. |
| CHG-0072 | 2026-07-02 | TASK-0023 | Roadmap/Backlog | +1 | Marked ARGUS Foundation complete and moved the active implementation focus to the queued UI follow-up track. |
| CHG-0073 | 2026-07-02 | TASK-0028 | UI | +1 | Removed the visible Quick Dx internet target chain and compacted the Quick Diagnosis run block while preserving internal fallback targets. |
| CHG-0074 | 2026-07-02 | TASK-0028 | Documentation | +1 | Updated TASK-0028 work log, handoff, changelog, and validation notes for the Quick Dx compact run panel fix. |
| CHG-0075 | 2026-07-02 | TASK-0028 | Task System | +1 | Completed TASK-0028 and activated TASK-0029 as the next focused Codex implementation task. |
| CHG-0076 | 2026-07-02 | TASK-0029 | UI | +1 | Reworked the Chocolatey page status strip into a compact readable area with real status action buttons. |
| CHG-0077 | 2026-07-02 | TASK-0029 | Documentation | +1 | Updated TASK-0029 work log, handoff, changelog, roadmap, and validation notes for the Choco page layout refinement. |
| CHG-0078 | 2026-07-02 | TASK-0029 | Task System | +1 | Completed TASK-0029 and activated TASK-0041 because the UI counter reached the mandatory audit threshold. |
| CHG-0079 | 2026-07-02 | TASK-0041 | UI | reset to 0 / 10 | Completed the required UI counter audit after the UI counter reached 10/10. |
| CHG-0080 | 2026-07-02 | TASK-0037 | UI | +1 | Added a Network gauge to the Activity page alongside CPU, RAM, and Disk gauges. |
| CHG-0081 | 2026-07-02 | TASK-0037 | Documentation | +1 | Updated Activity task, handoff, changelog, and validation notes for the Network gauge addition. |
| CHG-0082 | 2026-07-02 | TASK-0037 | Task System | +1 | Activated TASK-0037 after the UI audit gate cleared and recorded partial Activity page progress. |
| CHG-0083 | 2026-07-02 | TASK-0037 | UI | +1 | Compact Activity page process list, controls, detail panel, and refresh interval. |
| CHG-0084 | 2026-07-02 | TASK-0037 | Documentation | +1 | Updated TASK-0037 completion notes, handoff, changelog, and validation evidence. |
| CHG-0085 | 2026-07-02 | TASK-0037 | Task System | +1 | Completed TASK-0037 and activated TASK-0030 as the next focused GUI task. |
| CHG-0086 | 2026-07-02 | TASK-0030 | UI | +1 | Removed the visible print queue data-folder path from the Print tab and replaced it with a technician-facing status message. |
| CHG-0087 | 2026-07-02 | TASK-0030 | Documentation | +1 | Updated TASK-0030 work log, handoff, changelog, and validation notes for Print tab cleanup. |
| CHG-0088 | 2026-07-02 | TASK-0030 | Task System | +1 | Completed TASK-0030 and activated TASK-0031 as the next focused GUI task. |
| CHG-0089 | 2026-07-02 | TASK-0030 | Roadmap/Backlog | +1 | Updated roadmap current UI focus from Print tab cleanup to Triage page simplification. |
| CHG-0090 | 2026-07-02 | TASK-0031 | UI | +1 | Simplified the Triage page to Quick Triage and Full Triage as the only primary actions and removed normal-view advanced collector clutter. |
| CHG-0091 | 2026-07-02 | TASK-0031 | Documentation | +1 | Updated TASK-0031 work log, handoff, changelog, and validation notes for Triage page simplification. |
| CHG-0092 | 2026-07-02 | TASK-0031 | Task System | +1 | Completed TASK-0031 and activated TASK-0032 as the next focused GUI task. |
| CHG-0093 | 2026-07-02 | TASK-0031 | Roadmap/Backlog | +1 | Updated roadmap current UI focus from Triage page simplification to Computer tab summary redesign. |
| CHG-0094 | 2026-07-02 | TASK-0031 | UI | +1 | Restored the compact Triage tool catalog table, tightened Triage page spacing, and added AI bundle workflow instructions. |
| CHG-0095 | 2026-07-02 | TASK-0031 | Documentation | +1 | Updated TASK-0031 work log, handoff, changelog, and validation notes for the post-completion Triage page correction. |
| CHG-0096 | 2026-07-02 | TASK-0031 | UI | +1 | Removed the Quick Target Checks horizontal scrollbar and opened the triage bundle folder automatically after successful bundle creation. |
| CHG-0097 | 2026-07-02 | TASK-0031/TASK-0034 | Documentation | +1 | Documented the Quick Target Checks correction and added embedded-console pattern unification to the queued embedded-tool roadmap. |
| CHG-0098 | 2026-07-02 | TASK-0037 | UI | +1 | Stopped Activity page performance-counter refreshes when the Activity tab is not selected and added slow tab-switch diagnostics. |
| CHG-0099 | 2026-07-02 | TASK-0037 | Documentation | +1 | Documented the Activity timer performance correction and validation notes. |
| CHG-0100 | 2026-07-02 | TASK-0042 | Task System | +1 | Activated Documentation Counter Audit because the Documentation counter reached 10/10 and returned TASK-0032 to queued status until the audit gate clears. |
| CHG-0101 | 2026-07-03 | TASK-0042 | Documentation | reset to 0 / 10 | Completed the required Documentation Counter Audit and reset only the audited Documentation counter. |
| CHG-0102 | 2026-07-03 | TASK-0042 | Task System | +1 | Completed TASK-0042, reactivated TASK-0032, and added queued follow-up tasks for client-data transfer and GUI tab performance hardening. |
| CHG-0103 | 2026-07-03 | TASK-0042 | Roadmap/Backlog | +1 | Added client-data transfer and GUI tab performance hardening to the implementation backlog. |
| CHG-0104 | 2026-07-03 | TASK-0032/TASK-0045..TASK-0047 | Task System | +1 | Mapped the latest punch-list requests to existing tasks and created focused follow-up tasks for print, triage, and status-bar cleanup. |
| CHG-0105 | 2026-07-03 | TASK-0032/TASK-0045..TASK-0047 | Documentation | +1 | Added the outstanding task audit and updated task scopes for duplicate/refined punch-list items. |
| CHG-0106 | 2026-07-03 | TASK-0032/TASK-0045..TASK-0047 | Roadmap/Backlog | +1 | Added print, triage, and status-bar cleanup work to the queued UI backlog. |
| CHG-0107 | 2026-07-03 | TASK-0032 | UI | +1 | Reworked the Computer tab so the summary owns the page, recent profiles are reduced, and status-bearing fields use LED-style indicators. |
| CHG-0108 | 2026-07-03 | TASK-0032 | Documentation | +1 | Updated TASK-0032 work log, validation notes, changelog, ledger, and handoff for the Computer tab implementation pass. |
| CHG-0109 | 2026-07-03 | TASK-0032 | Task System | +1 | Completed TASK-0032 and activated the required Task System counter audit gate. |
| CHG-0110 | 2026-07-03 | TASK-0048 | Task System | reset to 0 / 10 | Completed the required Task System audit and reset only the audited Task System counter. |
| CHG-0111 | 2026-07-03 | TASK-0048 | Documentation | +1 | Recorded the punch-list reconciliation rule, TASK-0048 audit completion, and next-task handoff. |
| CHG-0112 | 2026-07-03 | TASK-0038 | UI | +1 | Reduced and scaled the header crown/elevation icon and cleaned up the Settings and Help header controls. |
| CHG-0113 | 2026-07-03 | TASK-0038 | Documentation | +1 | Updated TASK-0038 work log, validation notes, changelog, ledger, and handoff. |
| CHG-0114 | 2026-07-03 | TASK-0038 | Task System | +1 | Completed TASK-0038 and activated TASK-0045 as the next tab-based punch-list task. |
| CHG-0115 | 2026-07-03 | TASK-0045 | UI | +1 | Removed the redundant Print Diagnostics section label and fixed clipped Print Queue discovery controls. |
| CHG-0116 | 2026-07-03 | TASK-0045 | Documentation | +1 | Updated TASK-0045 work log, validation notes, changelog, ledger, and handoff. |
| CHG-0117 | 2026-07-03 | TASK-0045 | Task System | +1 | Completed TASK-0045 and activated the required UI counter audit gate. |
| CHG-0118 | 2026-07-03 | TASK-0049 | UI | reset to 0 / 10 | Completed the required UI counter audit and reset only the audited UI counter. |
| CHG-0119 | 2026-07-03 | TASK-0049 | Task System | +1 | Completed TASK-0049 and activated TASK-0046 as the next tab-based punch-list task. |
| CHG-0120 | 2026-07-03 | TASK-0032 | UI | +1 | Tightened the Computer tab summary layout and reserved more height for the recent profile table to prevent bottom-row clipping. |
| CHG-0121 | 2026-07-03 | TASK-0032 | Documentation | +1 | Updated TASK-0032, handoff, changelog, and ledger records for the Computer tab clipping follow-up. |
| CHG-0122 | 2026-07-04 | TASK-0046 / TASK-0050 | Roadmap/Backlog | +1 | Consolidated outstanding queued tasks into a smaller logical sequence and archived duplicate/superseded task entries. |
| CHG-0123 | 2026-07-04 | TASK-0050 | Roadmap/Backlog | reset to 0 / 10 | Completed the required Roadmap/Backlog audit after consolidation reached the counter threshold. |
| CHG-0124 | 2026-07-04 | TASK-0051 | Roadmap/Backlog | +1 | Added development-only file inventory and deployment/update exclusion work to the queued backlog. |
| CHG-0125 | 2026-07-04 | TASK-0046 / TASK-0050 / TASK-0051 | Task System | +3 | Corrected active task status, consolidated queued task state, added missing TASK-0021, completed TASK-0050, and added TASK-0051. |
| CHG-0126 | 2026-07-04 | TASK-0046 / TASK-0050 / TASK-0051 | Documentation | +3 | Updated queue, task files, roadmap, changelog, ledger, and handoff for task consolidation and deployment-exclusion tracking. |
| CHG-0127 | 2026-07-04 | TASK-0046 | UI | +1 | Reworked the Triage tab into a flat action row, removed the large visible status block, and filtered redundant tools from the visible catalog. |
| CHG-0128 | 2026-07-04 | TASK-0046 | Reporting | +1 | Updated triage bundle ZIP names to include run id and triage profile context. |
| CHG-0129 | 2026-07-04 | TASK-0046 | Build System | +1 | Updated toolkit build metadata using `App/Update-ToolkitVersion.ps1`. |
| CHG-0130 | 2026-07-04 | TASK-0046 | Repository Governance | +1 | Added the Build Metadata Rule requiring accepted implementation changes to update the toolkit version manifest before commit. |
| CHG-0131 | 2026-07-04 | TASK-0046 / TASK-0052 | Documentation | +1 | Updated TASK-0046, handoff, roadmap, changelog, and governance documentation for the triage cleanup and build metadata rule. |
| CHG-0132 | 2026-07-04 | TASK-0052 | Documentation | reset to 0 / 10 | Completed the required Documentation Counter Audit and reset only the audited Documentation counter. |
| CHG-0133 | 2026-07-04 | TASK-0046 / TASK-0044 | Task System | +1 | Completed TASK-0046 and activated TASK-0044 as the single active task. |
| CHG-0134 | 2026-07-04 | TASK-0047 | Task System | +1 | Activated TASK-0047 for the requested status-bar version/build placement and returned TASK-0044 to queued status. |
| CHG-0135 | 2026-07-04 | TASK-0047 | UI | +1 | Moved toolkit version/build to a small static bottom-left status-bar label and removed the duplicate Settings-page version display. |
| CHG-0136 | 2026-07-04 | TASK-0047 | Build System | +1 | Updated toolkit build metadata using `App/Update-ToolkitVersion.ps1` for the status-bar version/build change. |
| CHG-0137 | 2026-07-04 | TASK-0047 | Documentation | +1 | Updated TASK-0047, queue, roadmap, handoff, changelog, and ledger records for the status-bar version/build slice. |
| CHG-0138 | 2026-07-04 | TASK-0047 | UI | +1 | Fixed header summary clipping and replaced Settings/Help with compact dedicated header icon controls. |
| CHG-0139 | 2026-07-04 | TASK-0047 / TASK-0044 | Documentation | +1 | Updated punch list, TASK-0047, TASK-0044, handoff, changelog, and ledger for header chrome and performance follow-up notes. |
| CHG-0140 | 2026-07-04 | PROJECT | Repository Governance | +1 | Added the GitHub Sync Rule to defer routine pushes until the 10-change audit/refactor checkpoint unless explicitly requested. |
| CHG-0141 | 2026-07-04 | TASK-0033 | Task System | +1 | Changed queued TASK-0033 ownership from ChatGPT to Codex while ChatGPT is not in use. |
| CHG-0142 | 2026-07-04 | TASK-0047 | Build System | +1 | Updated toolkit build metadata using `App/Update-ToolkitVersion.ps1` for the header chrome and punch-list tracking change. |
| CHG-0143 | 2026-07-04 | TASK-0047 | UI | +1 | Added compact Wi-Fi status-bar/page indicators, Windows Update service health, and clarified the busy progress indicator purpose. |
| CHG-0144 | 2026-07-04 | TASK-0047 | Build System | +1 | Updated toolkit build metadata using `App/Update-ToolkitVersion.ps1` for completed status-bar indicators. |
| CHG-0145 | 2026-07-04 | TASK-0047 | Documentation | +1 | Updated TASK-0047, queue, roadmap, handoff, changelog, and punch-list records for status-indicator completion. |
| CHG-0146 | 2026-07-04 | TASK-0047 / TASK-0044 | Task System | +1 | Completed TASK-0047 and activated TASK-0044 as the next single active task. |
| CHG-0147 | 2026-07-04 | TASK-0044 | UI | +1 | Deferred normal GUI startup tab construction, startup Wi-Fi probing, and Activity page refresh work so the shell and Activity page can paint before expensive work runs. |
| CHG-0148 | 2026-07-04 | PROJECT | Repository Governance | +1 | Updated the required startup sequence so `punch_list.txt` is read before implementation and re-read before completion. |
| CHG-0149 | 2026-07-04 | TASK-0044 | Build System | +1 | Updated toolkit build metadata using `App/Update-ToolkitVersion.ps1` for the GUI startup performance pass. |
| CHG-0150 | 2026-07-04 | TASK-0044 | Documentation | +1 | Updated TASK-0044, handoff, changelog, and ledger records for launch/tab performance hardening progress. |
| CHG-0151 | 2026-07-04 | TASK-0044 | UI | +1 | Added shared slow tab-switch and slow tab-build diagnostics with status-bar feedback. |
| CHG-0152 | 2026-07-04 | TASK-0044 | Build System | +1 | Updated toolkit build metadata using `App/Update-ToolkitVersion.ps1` for completed slow-tab diagnostics. |
| CHG-0153 | 2026-07-04 | TASK-0044 | Documentation | +1 | Updated TASK-0044, punch list, queue, roadmap, handoff, changelog, and ledger records for task completion. |
| CHG-0154 | 2026-07-04 | TASK-0044 / TASK-0053 | Task System | +1 | Completed TASK-0044 and activated TASK-0053 because the Task System counter reached 10/10. |
| CHG-0155 | 2026-07-05 | TASK-0053 | Task System | reset to 0 / 10 | Completed the required Task System counter audit and reset only the audited counter. |
| CHG-0156 | 2026-07-05 | TASK-0053 / TASK-0043 | Task System | +1 | Activated TASK-0043 as the next implementation task after the audit gate cleared. |
| CHG-0157 | 2026-07-05 | TASK-0053 | Documentation | +1 | Updated TASK-0053, queue, roadmap, handoff, changelog, and ledger records for audit completion. |
| CHG-0158 | 2026-07-05 | TASK-0043 | UI | +1 | Added Settings-page client data transfer workflow with typed destination validation, transfer confirmation, and result messaging. |
| CHG-0159 | 2026-07-05 | TASK-0043 | Build System | +1 | Added reusable client-data transfer helper and updated toolkit build metadata using `App/Update-ToolkitVersion.ps1`. |
| CHG-0160 | 2026-07-05 | TASK-0043 | Validation/Test Framework | +1 | Validated parser checks, GUI smoke, button smoke, and fake toolkit transfer manifest generation excluding external-tool binaries. |
| CHG-0161 | 2026-07-05 | TASK-0043 | Documentation | +1 | Updated TASK-0043, queue, roadmap, handoff, changelog, and ledger records for client data transfer completion. |
| CHG-0162 | 2026-07-05 | TASK-0043 / TASK-0051 | Task System | +1 | Completed TASK-0043 and activated TASK-0051 as the next single active task. |
| CHG-0163 | 2026-07-05 | TASK-0051 | Build System | +1 | Added shared deployment/update exclusion helper and updated fresh deployment/update scripts to consume it. |
| CHG-0164 | 2026-07-05 | TASK-0051 | Validation/Test Framework | +1 | Validated parser checks, exclusion policy, fake fresh deployment, and fake toolkit update exclusion behavior. |
| CHG-0165 | 2026-07-05 | TASK-0051 | Documentation | +1 | Added deployment file inventory and updated TASK-0051, queue, roadmap, handoff, changelog, and ledger records. |
| CHG-0166 | 2026-07-05 | TASK-0051 / TASK-0040 | Task System | +1 | Completed TASK-0051 and activated TASK-0040 as the next single active task. |
| CHG-0167 | 2026-07-05 | TASK-0040 | UI | +1 | Split the Software tab into launchable portable apps and installable/extract-needed stored programs. |
| CHG-0168 | 2026-07-05 | TASK-0040 | Build System | +1 | Removed non-portable/redundant triage manifest entries and updated toolkit build metadata using `App/Update-ToolkitVersion.ps1`. |
| CHG-0169 | 2026-07-05 | TASK-0040 | Validation/Test Framework | +1 | Validated parser checks, triage manifest cleanup, GUI smoke, and button-smoke behavior. |
| CHG-0170 | 2026-07-05 | TASK-0040 | Documentation | +1 | Added software tool classification notes and updated TASK-0040, queue, roadmap, changelog, ledger, and handoff records. |
| CHG-0171 | 2026-07-05 | TASK-0040 / TASK-0033 | Task System | +1 | Completed TASK-0040 and activated TASK-0033 as the next single active task. |
| CHG-0172 | 2026-07-05 | TASK-0040 / TASK-0033 | Roadmap/Backlog | +1 | Updated roadmap current UI focus from software inventory placement to tab-by-tab direction and embedding planning. |
| CHG-0173 | 2026-07-05 | TASK-0033 | Documentation | +1 | Added the tab-by-tab embedding plan and completed TASK-0033 documentation deliverables. |
| CHG-0174 | 2026-07-05 | TASK-0033 | Build System | +1 | Updated toolkit build metadata for the completed planning batch. |
| CHG-0175 | 2026-07-05 | TASK-0033 / TASK-0054..TASK-0059 | Task System | +1 | Created follow-on implementation tasks and activated TASK-0059 as the required audit gate. |
| CHG-0176 | 2026-07-05 | TASK-0033 / TASK-0059 | Roadmap/Backlog | +1 | Updated roadmap focus from tab-by-tab planning to the required audit gate and queued implementation sequence. |
| CHG-0177 | 2026-07-05 | TASK-0059 | Documentation | reset to 0 / 10 | Completed the required Documentation counter audit and reset only the audited Documentation counter. |
| CHG-0178 | 2026-07-05 | TASK-0059 | Build System | reset to 0 / 10 | Completed the required Build System counter audit and reset only the audited Build System counter. |
| CHG-0179 | 2026-07-05 | TASK-0059 / TASK-0054 | Task System | +1 | Completed TASK-0059 and activated TASK-0054 as the single active implementation task. |
| CHG-0180 | 2026-07-05 | TASK-0054 | UI | +1 | Reworked the Directory tab into a domain identity and AD health status page with visible domain/policy actions. |
| CHG-0181 | 2026-07-05 | TASK-0054 | Build System | +1 | Updated toolkit build metadata using `App/Update-ToolkitVersion.ps1` for the Directory status page. |
| CHG-0182 | 2026-07-05 | TASK-0054 | Validation/Test Framework | +1 | Validated parser checks, GUI smoke, and button-smoke behavior for the Directory status page. |
| CHG-0183 | 2026-07-05 | TASK-0054 / TASK-0060 | Documentation | +1 | Updated TASK-0054, queued task mapping, handoff, roadmap, changelog, and ledger records for Directory completion and the next audit gate. |
| CHG-0184 | 2026-07-05 | TASK-0054 / TASK-0060 | Task System | +1 | Completed TASK-0054 and activated TASK-0060 because the UI counter reached 10/10. |
| CHG-0185 | 2026-07-05 | PROJECT / TASK-0060 / TASK-0061 | Repository Governance | +1 | Raised the audit gate threshold from 10 changes to 25 changes. |
| CHG-0186 | 2026-07-05 | TASK-0060 / TASK-0061 | Task System | +1 | Archived TASK-0060 because the raised threshold cleared the audit gate and activated TASK-0061 for Directory page layout polish. |
| CHG-0187 | 2026-07-05 | TASK-0061 | Roadmap/Backlog | +1 | Mapped new Directory punch-list feedback into TASK-0061 and moved it before shared embedded-output work. |
| CHG-0188 | 2026-07-09 | PROJECT | Repository Governance | +1 | Added the `Next 25` prompt shortcut rule and corrected the forward-looking audit reset text to `0 / 25`. |
| CHG-0189 | 2026-07-09 | TASK-0061 | UI | +1 | Compacted the Directory page status area into a shorter single-row summary and removed the Directory refresh button. |
| CHG-0190 | 2026-07-09 | TASK-0061 | Build System | +1 | Updated toolkit build metadata using `App/Update-ToolkitVersion.ps1` for Directory layout polish. |
| CHG-0191 | 2026-07-09 | TASK-0061 | Validation/Test Framework | +1 | Validated parser checks, GUI smoke, and button-smoke behavior for Directory layout polish. |
| CHG-0192 | 2026-07-09 | TASK-0061 / TASK-0062..TASK-0064 | Roadmap/Backlog | +1 | Reconciled new punch-list items into queued tasks for computer data transfer, Add-Ons concept testing, and naming options. |
| CHG-0193 | 2026-07-09 | TASK-0061 / TASK-0055 | Documentation | +1 | Updated TASK-0061, queue, roadmap, changelog, ledger, punch list, and handoff records for Directory layout completion. |
| CHG-0194 | 2026-07-09 | TASK-0061 / TASK-0055 | Task System | +1 | Completed TASK-0061 and activated TASK-0055 as the next single active implementation task. |
| CHG-0195 | 2026-07-09 | TASK-0055 | UI | +1 | Added reusable embedded command-output helpers and converted Quick Target Checks to use them. |
| CHG-0196 | 2026-07-09 | TASK-0055 | Build System | +1 | Updated toolkit build metadata using `App/Update-ToolkitVersion.ps1` for the shared embedded output pattern. |
| CHG-0197 | 2026-07-09 | TASK-0055 | Validation/Test Framework | +1 | Validated parser checks, GUI smoke, and button-smoke behavior for the shared embedded output pattern. |
| CHG-0198 | 2026-07-09 | TASK-0055 | Documentation | +1 | Updated TASK-0055, queue, roadmap, changelog, ledger, and handoff records for shared embedded output completion. |
| CHG-0199 | 2026-07-09 | TASK-0055 / TASK-0056 | Task System | +1 | Completed TASK-0055 and activated TASK-0056 as the next single active implementation task. |
| CHG-0200 | 2026-07-09 | TASK-0056 | UI | +1 | Reworked the Triage tab body into guided Collect, Review, and Submit sections while hiding normal-view catalog noise and removing Technician Notes. |
| CHG-0201 | 2026-07-09 | TASK-0056 | Build System | +1 | Updated toolkit build metadata using `App/Update-ToolkitVersion.ps1` for Triage guided workflow polish. |
| CHG-0202 | 2026-07-09 | TASK-0056 | Validation/Test Framework | +1 | Validated parser checks, GUI smoke, and button-smoke behavior for Triage guided workflow polish. |
| CHG-0203 | 2026-07-09 | TASK-0056 | Documentation | +1 | Updated TASK-0056, queue, roadmap, changelog, ledger, punch list, and handoff records for Triage workflow completion. |
| CHG-0204 | 2026-07-09 | TASK-0056 / TASK-0057 | Task System | +1 | Completed TASK-0056 and activated TASK-0057 as the next single active implementation task. |
| CHG-0205 | 2026-07-09 | TASK-0057 | UI | +1 | Polished Windows Update repair status and Wi-Fi LED/network status presentation. |
| CHG-0206 | 2026-07-09 | TASK-0057 | Build System | +1 | Updated toolkit build metadata using `App/Update-ToolkitVersion.ps1` for Wi-Fi and Windows status polish. |
| CHG-0207 | 2026-07-09 | TASK-0057 | Validation/Test Framework | +1 | Validated parser checks, GUI smoke, and button-smoke behavior for Wi-Fi and Windows status polish. |
| CHG-0208 | 2026-07-09 | TASK-0057 | Documentation | +1 | Updated TASK-0057, queue, roadmap, changelog, ledger, punch list, and handoff records for Wi-Fi and Windows status completion. |
| CHG-0209 | 2026-07-09 | TASK-0057 / TASK-0058 | Task System | +1 | Completed TASK-0057 and activated TASK-0058 as the next single active implementation task. |
| CHG-0210 | 2026-07-09 | TASK-0058 | UI | +1 | Compacted shared buttons and tab strip, enlarged the header logo, replaced Settings size refresh with an icon button, and removed registered-command startup noise. |
| CHG-0211 | 2026-07-09 | TASK-0058 | Build System | +1 | Updated toolkit build metadata using `App/Update-ToolkitVersion.ps1` for Settings and control polish. |
| CHG-0212 | 2026-07-09 | TASK-0058 | Validation/Test Framework | +1 | Validated parser checks, GUI smoke, and button-smoke behavior for Settings and control polish. |
| CHG-0213 | 2026-07-09 | TASK-0058 | Documentation | +1 | Updated TASK-0058, queue, roadmap, changelog, ledger, punch list, and handoff records for Settings/control completion. |
| CHG-0214 | 2026-07-09 | TASK-0058 / TASK-0062 | Task System | +1 | Completed TASK-0058 and activated TASK-0062 as the next single active implementation task. |
| CHG-0215 | 2026-07-09 | TASK-0062 | UI | +1 | Reworked Transfer Client Data into a Push/Pull computer-data dialog while preserving the diagnostic-data allow-list and manifest output. |
| CHG-0216 | 2026-07-09 | TASK-0062 | Build System | +1 | Updated toolkit build metadata using `App/Update-ToolkitVersion.ps1` for computer data push/pull. |
| CHG-0217 | 2026-07-09 | TASK-0062 | Validation/Test Framework | +1 | Validated fake push/pull client-data transfers, parser checks, GUI smoke, and button-smoke behavior. |
| CHG-0218 | 2026-07-09 | TASK-0062 | Documentation | +1 | Updated TASK-0062, queue, roadmap, changelog, ledger, punch list, and handoff records for computer data push/pull completion. |
| CHG-0219 | 2026-07-09 | TASK-0062 / TASK-0063 | Task System | +1 | Completed TASK-0062 and activated TASK-0063 as the next single active implementation task. |
| CHG-0220 | 2026-07-09 | TASK-0063 | UI | +1 | Added a testable Add-Ons popup for installable/extract-needed programs while preserving existing Software workflows. |
| CHG-0221 | 2026-07-09 | TASK-0063 | Build System | +1 | Updated toolkit build metadata using `App/Update-ToolkitVersion.ps1` for the Add-Ons concept. |
| CHG-0222 | 2026-07-09 | TASK-0063 | Validation/Test Framework | +1 | Validated parser checks, GUI smoke, and button-smoke behavior for the Add-Ons concept. |
| CHG-0223 | 2026-07-09 | TASK-0063 | Documentation | +1 | Updated TASK-0063, queue, roadmap, changelog, ledger, punch list, and handoff records for Add-Ons concept completion. |
| CHG-0224 | 2026-07-09 | TASK-0063 / TASK-0064 | Task System | +1 | Completed TASK-0063 and activated TASK-0064 as the next single active implementation task. |
