# TASK-0051 - Development File Deployment Exclusions

## Status
Complete

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
- [x] Development-only file/folder inventory exists.
- [x] Fresh deployment excludes development-only files.
- [x] Toolkit update excludes development-only files.
- [x] Runtime-required files are not excluded.
- [x] Validation covers deployment/update exclusion behavior without requiring a live production push.

## Implementation Notes
- Added `docs/DEPLOYMENT-FILE-INVENTORY.md` to document runtime-required files, client data, destination-preserved runtime state, and development-only files.
- Added `App/DeploymentExclusions.ps1` as the shared deployment/update exclusion policy.
- Updated `App/Deploy-NetworkToolkit.ps1` to consume the shared helper for fresh deployment exclusions.
- Updated `App/Update-NetworkToolkit.ps1` to consume the shared helper for update exclusions and destination prune behavior.
- Excluded development-only scripts and test folders from deployed runtime copies while preserving technician state and client data.

## Validation
- Parser validation passed for `DeploymentExclusions.ps1`, `Deploy-NetworkToolkit.ps1`, and `Update-NetworkToolkit.ps1`.
- Shared exclusion helper policy validation passed.
- Fake fresh deployment validation confirmed development/client data exclusions and required runtime inclusions.
- Fake toolkit update validation confirmed dev-only destination files are pruned while client data, custom tools, preserved manifests, and runtime helper remain.
