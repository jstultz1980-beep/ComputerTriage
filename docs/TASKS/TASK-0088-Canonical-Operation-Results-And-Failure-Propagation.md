# TASK-0088 - Canonical Operation Results and Failure Propagation

## Status
Complete

## Owner
Codex

## Depends On
TASK-0086 and TASK-0087 contract decisions.

## Objective
Eliminate false-success behavior by introducing one canonical operation-result envelope and preserving required-stage failures through CLI, GUI, collection, analysis, ARGUS, plugins, and process exit codes.

## Findings Addressed
- RUN-002
- RUN-003
- RUN-006
- HF-002
- HF-003
- HF-004
- HF-011
- PLG-002
- PLG-006
- PLG-017
- PLG-020
- RED-008

## Required States
- Succeeded
- SucceededWithWarnings
- Partial
- Failed
- Blocked
- Canceled

## Scope
- Define the result schema and required-stage model.
- Assign deterministic CLI exit codes.
- Classify required and optional startup modules/plugins.
- Fail closed for required startup/input failures.
- Propagate collector, parser, command, and post-validation outcomes.
- Make GUI success text depend on canonical result state.
- Map native command exit codes such as Robocopy correctly.

## Acceptance Criteria
- [x] A thrown CLI command returns nonzero.
- [x] Required module failure prevents normal startup.
- [x] Optional failure produces explicit degraded mode.
- [x] Partial triage does not return plain Completed/PASS.
- [x] Failed ARGUS contract suppresses normal recommendations and reports Failed.
- [x] Plugin action summaries reflect per-step failures.

## Validation
Add negative-path tests for every terminal state, CLI exit-code tests, startup failure fixtures, triage partial fixtures, ARGUS failed-contract fixtures, and GUI result-state assertions.

## Work Log
- Added the canonical `1.0` operation-result envelope with six terminal states and deterministic exit codes.
- Classified startup modules as required/optional, fail closed on required imports, and expose optional degraded mode.
- Propagated canonical results through CLI, triage, HEPHAESTUS, ARGUS, GUI safe-runner status, and multi-step Windows repair summaries.
- Suppressed ARGUS recommendations and returned Failed when the input contract fails.
- Added terminal-state, thrown CLI, analysis success, and ARGUS failed-contract fixtures.
- Parser, focused negative-path, identity, parser-quality, triage, toolkit, GUI smoke, and button-smoke validation passed.
