# TASK-0120 - Preserved Drift Inventory And Reconciliation

## Status

Queued

## Owner

Codex

## Objective

Resolve all documented working-tree drift through an evidence-based, item-by-item disposition so the repository can return to a clean, fully explained state without destroying valid local work.

## Scope

Inventory every modified and untracked item listed in the current handoff and any additional drift found at task start. For each item, determine provenance, purpose, relationship to completed or queued work, and the correct repository disposition.

Each item must receive exactly one approved disposition:

1. Commit as valid project work under the correct task and location.
2. Move into the correct repository location and update references.
3. Convert into a documented feature request or future task while preserving the source safely outside the active tree.
4. Archive outside the repository with a recorded destination and checksum when appropriate.
5. Add to `.gitignore` when the content is generated, runtime-only, machine-local, or otherwise intentionally untracked.
6. Delete only after proving the item is obsolete, duplicated, or generated and after preserving a recoverable copy when risk exists.

## Required Review Set

At minimum, review:

- `App/NetworkToolkit/Utilities/GuiTabWarmup.ps1`
- `App/ToolKit-GUI/ToolKit-GUI.ps1`
- `App/manifests/custom-tools.json`
- `docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md`
- `App/NetworkToolkit/LatencyMon/`
- `App/NetworkToolkit/Logs/`
- `App/NetworkToolkit/Tests/Test-GUITabWarmupPolicy.ps1`
- `Custodian-Audit-20260711-000156.md`
- `Export-ProjectFactoryGovernancePackage.ps1`
- `Project-Custodian-Bridge.ps1`
- `Project-Factory-Governance-Handoff.zip`
- `Project-Factory-Lessons-Learned-Handoff.txt`
- `Set-CodexPermissions.ps1`
- any retained synchronization stash associated with HANDOFF-0129

## Constraints

- Do not bulk-stage the working tree.
- Do not discard files solely to obtain a clean status.
- Do not mix unrelated implementation changes into one commit.
- Preserve recoverability until every disposition is accepted.
- Treat binaries, logs, generated archives, credentials, and machine-specific helper scripts as separate risk classes.
- Do not modify the published `v1.0.0` tag or release artifacts.

## Required Evidence

Produce a reconciliation ledger containing:

- path
- tracked or untracked state
- origin or likely creator
- related task or subsystem
- content classification
- security and licensing considerations
- chosen disposition
- destination or commit
- validation performed

## Acceptance Criteria

- Every drift item has a documented and executed disposition.
- The working tree is clean.
- No untracked file remains unexplained.
- Generated/runtime content is covered by an appropriate ignore rule.
- Valid project work is committed under the correct task ownership.
- Archived material has a recorded destination when retained outside the repository.
- The retained safety stash is reviewed and removed only after proving it is redundant.
- `docs/HANDOFF.md` no longer reports `Preserved Drift: Unchanged` as an indefinite exception.
- Focused and canonical validation pass after reconciliation.
