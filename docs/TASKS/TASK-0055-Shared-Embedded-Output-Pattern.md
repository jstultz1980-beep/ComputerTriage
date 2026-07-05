# TASK-0055 - Shared Embedded Output Pattern

## Status
Queued

## Owner
Codex

## Objective
Create one reusable embedded output pattern for technician-facing command results, based on the Quick Target Checks experience.

## Scope
- Define reusable GUI helpers for compact input row, action buttons, output pane, status updates, and optional output-folder handoff.
- Prefer non-modal success handling.
- Preserve clear error output and tool usage logging.
- Identify first conversion candidates from Analyze, Network, Infrastructure, and Wi-Fi.

## Out of Scope
- Rewriting every console tool in one pass.
- Embedding full external GUI applications.
- ARGUS or HEPHAESTUS changes.

## Acceptance Criteria
- [ ] A shared helper pattern exists for embedded command output.
- [ ] At least one low-risk console-driven tool uses the shared pattern.
- [ ] External GUI tools still launch externally.
- [ ] Parser, smoke, and button-smoke validation pass.
