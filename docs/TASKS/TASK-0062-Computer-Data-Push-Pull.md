# TASK-0062 - Computer Data Push Pull

## Status
Completed

## Owner
Codex

## Objective
Add an option to push or pull collected computer/client data between toolkit copies.

## Scope
- Extend the existing client-data transfer concept into a technician-safe push/pull workflow.
- Preserve source data unless the user explicitly chooses otherwise.
- Validate toolkit destinations and sources before transfer.
- Transfer computer diagnostic/client data only.
- Keep app binaries, portable tools, development files, and deployment/update mechanics out of scope.

## Consolidated Punch-List Mapping
- Punch-list item 32 maps here: add an option to push or pull computer data between toolkits, similar to deployed toolkit update but for computer data.

## Out of Scope
- Changing toolkit update/deployment semantics.
- Syncing application binaries.
- Network discovery or whole-fleet data collection.

## Acceptance Criteria
- [x] Technician can choose push or pull direction for computer/client data transfer.
- [x] Source and destination toolkit paths are validated before transfer.
- [x] Only diagnostic/client data is transferred.
- [x] Transfer summary/manifest is available after completion.
- [x] Parser, smoke, and button-smoke validation pass.

## Completion Notes
- Reworked the Settings client-data transfer dialog into a Push/Pull computer-data workflow.
- Push copies diagnostic/client data from this toolkit to the selected toolkit.
- Pull copies diagnostic/client data from the selected toolkit into this toolkit.
- Preserved the existing allow-listed client-data copy helper, manifest output, source preservation, and merge confirmation.
- Validated fake push and pull transfers, parser checks, GUI smoke, and button-smoke.
