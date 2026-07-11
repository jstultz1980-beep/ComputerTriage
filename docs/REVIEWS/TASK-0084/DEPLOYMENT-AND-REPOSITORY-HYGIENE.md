# Deployment and Repository Hygiene Assessment

Task: `TASK-0084-Full-Codebase-Architecture-And-Quality-Audit`
Status: In Progress

## Overall Assessment

The repository has a deliberate portable-package model, shared fresh/update exclusions, runtime-data preservation rules, a production package verifier, and client-data transfer support. These are strong foundations. The primary weaknesses are incomplete payload integrity, destructive in-place changes, source-tree mutation, runtime/client-data co-location, and unclear ownership of generated or locally added tools.

## Findings

### DEP-001 - Production package integrity covers only launchers

Severity: High

`Build-ProductionPackage.ps1` records SHA-256 for four primary launcher/core files. `Test-ProductionPackage.ps1` verifies those hashes and selected required paths.

Not covered:
- plugins
- utilities
- deterministic analysis/rules
- ARGUS modules
- plugin manifests
- custom/triage/tool manifests
- embedded executables
- deployment/update scripts
- report templates/helpers

Impact:
A package can pass with missing or modified operational files.

Recommendation:
Generate a complete managed-file manifest with path, size, SHA-256, type, required/optional classification, and package source.

### DEP-002 - Build mutates source version metadata before package validation

Severity: Medium/High

The production build updates `App/manifests/toolkit-version.json` in the source tree before copy and validation.

Impact:
A failed or abandoned build leaves the source checkout modified and advances build metadata without a valid package.

Recommendation:
Generate package metadata in staging or update source metadata only after successful package validation and intentional commit.

### DEP-003 - Build identity has no commit/source-tree fingerprint

Severity: Medium

`Update-ToolkitVersion.ps1` removes a `Commit` field and uses timestamp-based build numbers.

Impact:
A deployed package cannot be reliably mapped back to the exact source commit or dirty-state status.

Recommendation:
Include Git commit SHA when available, dirty-tree flag, package manifest hash, and build-tool version. Retain timestamp as supplemental metadata.

### DEP-004 - Fresh deployment deletes destination contents before validating a staged replacement

Severity: High

The selected destination folder is cleared, then program files are copied and minimally verified.

Impact:
Interruption or source failure leaves a damaged deployment; mistaken destination selection can delete unrelated files.

Recommendation:
Require a destination identity marker for replacement, stage to a sibling directory, validate fully, then swap or move the old deployment to rollback storage.

### DEP-005 - Update modifies and prunes in place without rollback

Severity: High

The updater migrates legacy layout, copies files, prunes stale program files, removes root artifacts, and verifies a small subset.

Impact:
Partial update, locked files, power interruption, or stale file retention can produce mixed-version execution.

Recommendation:
Use transactional staging and rollback. Do not mark Completed or Current when managed-file reconciliation has failures.

### DEP-006 - Same-build update can mutate the destination

Severity: Medium/High

When source and destination build numbers match, the updater still prunes obsolete files and removes root artifacts.

Impact:
A “Current” operation can change the installation, and prune failures can be hidden in Skipped counts.

Recommendation:
Use distinct `VerifiedCurrent`, `ReconciledWithWarnings`, and `Failed` results. Record every mutation.

### DEP-007 - Runtime and client data are stored inside the application hierarchy

Severity: High

Data, Exports, Logs, tool output, settings, and portable app data live below `App` or the deployment root.

Impact:
Updates, packages, source checkouts, client transfers, and evidence retention must depend on complex exclusions. Runtime mutation of tracked manifests has already created drift.

Recommendation:
Formally define immutable program roots and writable runtime roots. For portable mode, use a dedicated top-level `Runtime` or `ClientData` tree rather than mixing with program files.

### DEP-008 - Runtime manifest mutation creates source and deployment drift

Severity: High

`custom-tools.json` is known to gain provenance/package/timestamp metadata during normal use and repeatedly appears as unrelated drift.

Impact:
Tracked source changes from running the application, accidental commits, merge conflicts, and inconsistent package state.

Recommendation:
Split shipped defaults from runtime-discovered state. Write runtime state to an ignored data file and merge it at load time.

### DEP-009 - Untracked tool and log folders demonstrate ownership ambiguity

Severity: Medium

Known local drift includes:
- `App/NetworkToolkit/LatencyMon/`
- `App/NetworkToolkit/Logs/`
- `Set-CodexPermissions.ps1`

Impact:
It is unclear whether files are source, locally installed tools, runtime output, or operator utilities.

Recommendation:
Classify every root through a repository inventory policy: tracked source, generated runtime, optional local tool, build output, or operator-only script.

### DEP-010 - Recursive removal of folders named `Data` is policy by naming convention

Severity: Medium

Build/deploy cleanup scans custom app trees and removes contents from directories named exactly `Data`.

Impact:
A third-party application may use a `Data` directory for required program assets rather than user state.

Recommendation:
Use per-tool package manifests declaring mutable and immutable paths. Do not infer ownership solely from directory name.

### DEP-011 - Exclusion rules are stronger than verification rules

Severity: Medium/High

The repository carefully excludes runtime/client data but only verifies a narrow list of program files.

Impact:
The package may be clean but incomplete.

Recommendation:
Pair every exclusion policy with a required managed-payload manifest and optional payload classification.

### DEP-012 - Portable tool provenance is not included in package acceptance

Severity: High

Package tests check directories and launcher hashes, not executable hashes/signatures/licenses/expiration.

Impact:
Outdated, replaced, quarantined, or missing tools can ship unnoticed.

Recommendation:
Integrate the external-tool lifecycle manifest into build and package verification.

### DEP-013 - Client data transfer reports partial copies but does not verify destination content

Severity: Medium/High

Copy failures are recorded and status becomes CompletedWithWarnings, but copied files are not hash-verified and available disk space is not preflighted.

Impact:
A transferred client case may be incomplete or corrupt.

Recommendation:
Preflight destination capacity, hash or size/mtime verify copied evidence, and produce a transfer manifest with sensitivity classes.

### DEP-014 - No immutable diagnostic run identity is enforced across copies

Severity: High

Artifacts are primarily located by directory names and “latest” timestamps. Transfer and analysis can change modification times and selection order.

Impact:
Wrong bundle selection and weak provenance.

Recommendation:
Assign immutable run IDs in the collection manifest and require downstream tools to preserve/reference that ID.

### DEP-015 - Repository validation does not currently prove every PowerShell file parses under 5.1

Severity: High

Smoke loading covers files reached by startup, but development scripts, custom apps, nested scripts, and alternate entry points may not all be parsed.

Recommendation:
Add a repository-wide Windows PowerShell 5.1 parser gate with an explicit exclusion list for intentionally non-5.1 assets.

## Positive Controls

- `.git` is excluded from production packages.
- major runtime/client-data roots are excluded or cleared.
- fresh deployment rejects drive roots and source-equals-destination.
- update preserves documented data paths.
- package verifier rejects a source workspace mistaken for a built package.
- client-data transfer refuses an already populated destination unless `-Force` is explicitly used.

## Required Deployment Remediation Order

1. Immutable run ID and full managed-file package manifest.
2. Tool provenance lifecycle manifest.
3. Transactional package/deploy/update staging and rollback.
4. Separate runtime state from tracked program/config defaults.
5. Full package and transfer verification.
6. Repository-wide parser and payload completeness gates.
