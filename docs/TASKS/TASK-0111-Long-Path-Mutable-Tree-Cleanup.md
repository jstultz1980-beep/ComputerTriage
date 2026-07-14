# TASK-0111 - Long-Path Mutable Tree Cleanup

## Status
Complete

## Owner
Codex

## Depends On
TASK-0080 release-candidate evidence and Project Custodian disposition.

## Objective
Make production-package mutable-tree cleanup long-path capable and fail closed so no portable application data survives under declared mutable paths.

## Scope
- Replace the current silent `Remove-Item -Recurse -Force -ErrorAction SilentlyContinue` cleanup behavior with a deterministic long-path-capable cleanup path.
- Fail the package build when any declared mutable tree cannot be fully removed.
- Add a focused fixture that reproduces the long LibreOffice `OptionsDialog.xcu` path condition.
- Rebuild the full production image and run independent verification.
- Preserve all unrelated working-tree drift.

## Out Of Scope
- New features.
- Tool additions or removals.
- Broad packaging redesign.
- Risk acceptance in place of remediation.
- Tagging, publishing, or distributing Version 1.0.

## Acceptance Criteria
- [x] Declared mutable trees are removed even when paths exceed legacy Win32 length limits.
- [x] Cleanup failures stop the package build with an explicit error.
- [x] Focused long-path cleanup fixture passes.
- [x] Canonical repository validation passes.
- [x] A new full production image builds successfully.
- [x] Independent full-image verification reports no mutable application data.
- [x] TASK-0080 is returned to the Project Custodian for the final release-readiness decision.

## Required Records
- Update task, queue, handoff, ledger, changelog, roadmap, release-candidate evidence, and build metadata as applicable.

## Completion Result

- The package builder now uses fail-closed long-path cleanup for declared mutable trees and nested Logs folders.
- The focused cleanup fixture reproduces the long-path LibreOffice `OptionsDialog.xcu` condition and validates the failure path.
- The canonical repository gate passed 19 stages with zero failures.
- A new 6.73 GB production image built successfully across 24,362 files.
- Independent verification passed with no mutable application data remaining.
- TASK-0080 returned to the Project Custodian as the sole Active release-readiness boundary.

## Rollback Plan
Revert the focused cleanup implementation and fixture commits, restore the prior package builder from Git history, and return TASK-0080 to the Project Custodian with the failed remediation evidence. Do not accept or publish the affected package.
