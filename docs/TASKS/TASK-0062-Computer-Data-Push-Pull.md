# TASK-0062 - Computer Data Push Pull

## Status
Active

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
- [ ] Technician can choose push or pull direction for computer/client data transfer.
- [ ] Source and destination toolkit paths are validated before transfer.
- [ ] Only diagnostic/client data is transferred.
- [ ] Transfer summary/manifest is available after completion.
- [ ] Parser, smoke, and button-smoke validation pass.
