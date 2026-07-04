# TASK-0051 - Development File Deployment Exclusions

## Status
Queued

## Owner
Codex

## Objective
Inventory files and folders that are only needed for development, then exclude them from fresh toolkit deployment and deployed toolkit updates.

## User Need
Production thumb-drive deployments and destination updates should carry the technician runtime, tools, help, manifests, and required scripts, but should not copy development-only files that waste space or create confusion.

## Scope
- Inventory repository files and folders that are development-only.
- Document what is runtime-required versus development-only.
- Update fresh deployment logic to exclude development-only files.
- Update deployed toolkit update logic to exclude development-only files.
- Preserve source repository files; exclusions apply to deployment/update output only.
- Make exclusions explicit and maintainable, preferably in one shared helper/list.
- Validate that deployment/update does not remove required runtime files.

## Out of Scope
- Deleting source development files.
- Removing portable apps or technician tools.
- Changing client-data transfer semantics.
- Full packaging redesign.

## Acceptance Criteria
- [ ] Development-only file/folder inventory exists.
- [ ] Fresh deployment excludes development-only files.
- [ ] Toolkit update excludes development-only files.
- [ ] Runtime-required files are not excluded.
- [ ] Validation covers deployment/update exclusion behavior without requiring a live production push.
