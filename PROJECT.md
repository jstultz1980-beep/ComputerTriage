# Computer Triage Toolkit Project Control

## Source of Truth
The repository is the source of truth. Chat history is not the source of truth.

## Required Startup Sequence
1. Read this file.
2. Read `docs/PROJECT-CHARTER.md`.
3. Read `docs/ARCHITECTURE.md`.
4. Read `docs/ROADMAP.md`.
5. Read `docs/HANDOFF.md`.
6. Read the active task document listed in `docs/HANDOFF.md`.
7. Perform only the work assigned in the active task.
8. Validate the work.
9. Update the active task document.
10. Update `docs/HANDOFF.md`.
11. Commit all related changes.

## Core Rule
No implementation work may begin unless there is an active task document under `docs/TASKS`.

## No Patch Stacking Rule
If a script or implementation develops structural errors, stop patching it. Roll back to the last known-good state and rebuild cleanly from the current repository layout.

## Product
Computer Triage Toolkit.

Primary goal: rapid, portable, single-computer Windows diagnostics, analysis, explanation, and reporting.

## Components
- HEPHAESTUS: evidence collection
- ARGUS: evidence analysis and explanation
- Reporting: technician and executive outputs

## Non-Goals
- Whole-network discovery
- SIEM replacement
- RMM replacement
- Asset inventory platform
- General AI Builder framework
