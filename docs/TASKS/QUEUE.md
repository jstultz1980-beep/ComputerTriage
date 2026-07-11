# Task Queue

This file is the task-state source of truth alongside `docs/HANDOFF.md`.

## Current Rule
Exactly one task may have `Active` status at a time. No implementation work may begin unless the active task exists under `docs/TASKS` and `docs/HANDOFF.md` names the same task.

## Active

| Task | Owner | Status | Purpose |
|---|---|---|---|
| `TASK-0084-Full-Codebase-Architecture-And-Quality-Audit` | ChatGPT | Active | Freeze implementation and perform the complete read-only architecture, code-quality, security, performance, validation, deployment, and governance audit. |

## Queued

| Task | Owner | Status | Purpose |
|---|---|---|---|
| `TASK-0077-First-Render-Tab-Performance-Hardening` | Codex | Queued | Measure and reduce remaining first-render tab switching lag after audit remediation priorities are resolved. |
| `TASK-0078-Embedded-Tool-Trust-And-EDR-Safe-Distribution` | Codex | Queued | Reduce antivirus/EDR friction through provenance, allowlisting guidance, and safe packaging choices. |
| `TASK-0079-Release-Packaging-And-Update-Hardening` | Codex | Queued | Validate portable release, deployment, update, client-data preservation, and release artifact layout. |
| `TASK-0080-Release-Candidate-Validation-And-Documentation` | Codex | Queued | Run final release-candidate validation and produce release-ready docs. |

## Consolidated Plan

The current development freeze sequence is:

1. Complete TASK-0084 full-codebase architecture and quality audit.
2. Create and execute focused remediation tasks for accepted Critical and High findings.
3. Reassess the placement and scope of TASK-0077 and TASK-0078 against audit findings.
4. Harden release packaging/update behavior under TASK-0079.
5. Run release-candidate validation and documentation under TASK-0080.

No implementation task may become Active while TASK-0084 is underway unless the Project Custodian explicitly creates a narrowly scoped audit-support task required to obtain evidence. Audit-support work must not repair application code.

## Recently Completed

| Task | Status | Notes |
|---|---|---|
| `TASK-0073-ARGUS-Evidence-Normalization-Implementation` | Completed | Implemented ARGUS normalization loaders and `ARGUS/normalized-analysis.json`. |
| `TASK-0074-ARGUS-Event-Grouping-And-Recommendations` | Completed | Added cited diagnostic groups, root-cause candidates, and conservative recommendations. |
| `TASK-0075-Reporting-Finish-Pass` | Completed | Added technician and escalation reports with confidence, citations, limitations, and artifact references. |
| `TASK-0076-Analyze-Workflow-UI-Integration` | Completed | Added the guided Analyze workflow and validated parser, smoke, and button-smoke behavior. |
| `TASK-0085-Documentation-Counter-Audit` | Completed | Audited documentation consistency at `25 / 25`, reset only Documentation, and cleared the gate for TASK-0084. |

## Historical Task Records
Historical completed and archived task details remain in the individual task files and repository history. The queue’s operational purpose is to identify the single Active task and the ordered remaining work; it is not the canonical substitute for historical task documents.

## Current Decision
- TASK-0085 is complete.
- Documentation was audited and resets to `0 / 25`.
- The user explicitly selected the already planned TASK-0084 audit at this task boundary.
- TASK-0084 is the only Active task.
- TASK-0077 and all implementation work remain queued during the development freeze.
