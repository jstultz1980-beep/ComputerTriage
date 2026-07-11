# Hidden Failure and False-Success Report

Task: `TASK-0084-Full-Codebase-Architecture-And-Quality-Audit`
Status: In Progress
Auditor: ChatGPT

## Executive Finding

The most consequential pattern found so far is not obvious crashes. It is **successful-looking completion after incomplete, failed, stale, or misattributed work**.

The toolkit often preserves forward progress by catching errors, but multiple paths do not propagate degraded state to the caller, process exit code, generated report, or technician-facing status. This can produce trustworthy-looking artifacts from untrustworthy inputs.

## Confirmed Findings

### HF-001 - Final diagnostic ZIP hash is stale by construction

Severity: High
Location: `App/NetworkToolkit/Utilities/TriageService.ps1`, bundle creation sequence

Evidence:
1. The ZIP is created.
2. SHA-256 is calculated from that ZIP.
3. The hash is written into `collection_manifest.json`.
4. The ZIP is recreated to include the updated manifest.

The stored hash therefore describes the first ZIP, not the final ZIP delivered to the technician.

Failure mode:
The bundle’s internal integrity claim cannot validate the final bundle.

Impact:
Any later integrity, provenance, transfer, or audit check using `bundleSha256` will fail or provide false assurance.

Recommendation:
Do not place a self-hash inside the archive it hashes. Write a sidecar hash outside the ZIP, or define a canonical content-manifest hash that excludes its own hash field.

Required validation:
- Generate bundle.
- Compare recorded hash with final ZIP hash.
- Verify tamper detection.
- Verify repeatable canonical-content hash if that design is selected.

### HF-002 - Triage validation summary hard-codes PASS states

Severity: High
Location: `App/NetworkToolkit/Utilities/TriageService.ps1`, final validation summary

Evidence:
The report writes literal values:
- `Collection: PASS`
- `Local analysis: PASS`
- `Bundle creation: PASS`

These lines are not derived from collector results, command failures, warnings, analysis status, or post-run validation.

The returned result is also `status="Completed"` even when `preflight.passed` or `post.passed` is false.

Failure mode:
A technician sees PASS/Completed while commands, collectors, tools, validation checks, or bundle contents failed.

Impact:
False confidence in diagnostic completeness and downstream ARGUS conclusions.

Recommendation:
Create an explicit run-state model: Passed, CompletedWithWarnings, Partial, Failed. Derive each validation line from recorded evidence. A failed required stage must prevent a plain Completed status.

Required validation:
Fixtures for failed command, failed PowerShell collector, missing required file, unreadable ZIP, post-run failure, and successful run.

### HF-003 - PowerShell collector failures are discarded from run status

Severity: High
Location: `App/NetworkToolkit/Utilities/TriageService.ps1`

Evidence:
`Export-NTKTriagePowerShellObject` returns a structured success/failure record, but the main run calls it through `[void](...)` and does not add failures to the warning collection or result status.

Failure mode:
Important evidence such as services, processes, adapters, TCP connections, physical disks, and signed drivers can fail without affecting the final Completed status.

Impact:
Missing evidence may be interpreted as no issue or may not reduce evidence quality.

Recommendation:
Collect and persist every PowerShell collector result. Feed failures into warnings, evidence scoring, capability status, and final run state.

Required validation:
Mock each collector failure individually and in combination; verify warnings, capability metadata, evidence score, and UI status.

### HF-004 - AI collector marks sections Completed when inner commands or writes fail

Severity: High
Location: `App/NetworkToolkit/Utilities/AIBundleCollector.ps1`

Evidence:
- `Invoke-NTKSafeTextCommand` returns false on timeout or nonzero exit.
- `Export-NTKSafeJson` and `Export-NTKSafeCsv` return false on write/serialization failure.
- Many section bodies discard those return values with `Out-Null`.
- `Invoke-NTKCollectorSection` marks a section Completed whenever the scriptblock does not throw.

Failure mode:
Section status says Completed although one or all section artifacts failed.

Impact:
The collection status file is not a reliable completeness contract.

Recommendation:
Require sections to return a structured result containing state, required artifact outcomes, warnings, and detail. A false inner result must produce Partial or Failed.

Required validation:
Command timeout, missing executable, access denied, JSON serialization failure, and disk-write failure fixtures.

### HF-005 - Files with JSON or CSV extensions may contain plain error text

Severity: High
Location: `Export-NTKSafeJson` and `Export-NTKSafeCsv`

Evidence:
On failure, both functions write `ERROR: <message>` directly to the target `.json` or `.csv` path.

Failure mode:
The artifact exists but violates its declared format.

Impact:
Existence checks pass; later parsers fail; inventory may count the file as evidence; operators may assume structured data exists.

Recommendation:
Do not write invalid content under a structured-data extension. Write a valid error envelope for JSON, a separate `.error.txt`, or omit the artifact and record the failure in capability/status metadata.

Required validation:
Force serialization and write failures; assert structured artifacts either parse or are absent with an explicit error record.

### HF-006 - Local deterministic analysis can describe the wrong computer

Severity: Critical
Location: `App/NetworkToolkit/Core/LocalAnalysisEngine.ps1` and `LocalAnalysisRules.ps1`

Evidence:
The analysis accepts a bundle root but obtains machine identity, OS, manufacturer, model, system-drive free space, user, and domain from the **current runtime computer** through environment variables and CIM.

Failure mode:
When a bundle from Computer A is analyzed on technician Computer B, output can attribute Computer B’s identity, OS, hardware, and C: free-space finding to Computer A’s evidence bundle.

Impact:
Cross-machine evidence contamination, incorrect high-severity findings, misleading reports, and invalid ARGUS citations.

Recommendation:
Offline bundle analysis must consume bundle-contained evidence only. Runtime checks must be explicitly separated into a live-analysis mode and labeled with the runtime machine identity. Refuse silent mixing.

Required validation:
Analyze a fixture bundle whose computer identity and disk state differ from the host. Assert no host values enter offline artifacts.

### HF-007 - Evidence score claims artifacts were parsed when only filenames matched

Severity: High
Location: `New-HEPEvidenceScore` in `LocalAnalysisEngine.ps1`

Evidence:
Category presence is determined by filename/path regex. When a match exists, the output sets:
- `presentArtifacts = 1`
- `parsedArtifacts = 1`
- `failedParsers = 0`
- `score = 100`

No parser runs and content validity is not checked.

Failure mode:
Empty, malformed, unrelated, stale, or plain-error files receive full category quality credit.

Impact:
ARGUS confidence conditioning is based on an inflated evidence score.

Recommendation:
Separate discovery, format validation, parsing, semantic validation, and coverage. Compute quality from parser outcomes rather than filename matches.

Required validation:
Empty, invalid JSON, `ERROR:` text, unrelated matching filename, truncated file, and valid fixture cases.

### HF-008 - Deterministic timeline is file metadata, not an event timeline

Severity: High
Location: `New-HEPTimeline` in `LocalAnalysisEngine.ps1`

Evidence:
Timeline entries are generated from the 25 most recently modified files and titled `Evidence artifact present`. The timestamp is the artifact file’s `LastWriteTimeUtc`, not an event occurrence time.

Failure mode:
File copy/export time can be interpreted as diagnostic event time.

Impact:
ARGUS grouping and technicians may infer sequence or causality from collection timestamps.

Recommendation:
Rename this artifact to evidence inventory chronology or populate a true event timeline from structured event sources. Never mix file metadata and observed event timestamps without type labels.

Required validation:
Fixture with known event timestamps and later file-copy timestamps; verify correct temporal semantics.

### HF-009 - Local analysis can select or create an invalid bundle automatically

Severity: High
Location: `Get-HEPDefaultBundleRoot` and `Invoke-HEPHAESTUSLocalAnalysis`

Evidence:
The default root is simply the most recently modified directory under Exports. If none exists, the engine creates an empty analysis directory and processes it.

Failure mode:
A temp/export folder, incomplete run, report folder, or empty directory becomes the evidence bundle.

Impact:
Successful-looking analysis of the wrong or nonexistent evidence set.

Recommendation:
Require bundle identity markers and validate the contract before analysis. Never create an empty evidence bundle as a fallback for an analysis command.

Required validation:
Exports containing unrelated directories, partial runs, empty directories, multiple valid bundles, and explicit invalid paths.

### HF-010 - Re-running analysis contaminates its own evidence inventory

Severity: High
Location: `Get-HEPEvidenceInventory` and `Invoke-HEPHAESTUSLocalAnalysis`

Evidence:
The recursive inventory includes files under `Analysis`, `Metadata`, and `ARGUS`. Those outputs are written into the same bundle root and included on subsequent runs.

Failure mode:
Repeated runs change completeness scores and timeline entries because prior generated outputs become apparent evidence.

Impact:
Non-idempotent analysis, self-referential evidence, and inconsistent results from the same original bundle.

Recommendation:
Exclude generated analysis/report directories from raw evidence inventory or use immutable source/evidence directories.

Required validation:
Run analysis twice on unchanged input and compare all deterministic outputs except generation timestamps.

### HF-011 - ARGUS continues after failed required input validation and reports Completed

Severity: High
Location: `Core/Argus/ArgusFoundation.ps1`

Evidence:
- Required artifact or schema failures produce validation status `failed`.
- Mode is still set to `limited`.
- Normalization, grouping, recommendations, and reports are still generated.
- The final returned object always uses `Status = "Completed"`.

Failure mode:
ARGUS outputs can appear complete after the required contract failed.

Impact:
Technicians and GUI workflow may open recommendations generated from missing or unsupported required inputs.

Recommendation:
Define fail-closed contract behavior. A failed required contract should return Failed, suppress normal recommendations, and generate only a validation/error report. Limited mode should be reserved for optional gaps.

Required validation:
Missing schema, unsupported schema, malformed findings, missing machine profile, and optional-capability-gap cases.

### HF-012 - ARGUS may analyze the wrong export directory by default

Severity: High
Location: `Get-ARGUSDefaultBundleRoot`

Evidence:
ARGUS selects the most recently modified directory under Exports without validating bundle identity or required artifact presence before selection.

Failure mode:
A later unrelated export becomes the default ARGUS target.

Impact:
Wrong-case reports and confusion about which machine/run was analyzed.

Recommendation:
Select only directories satisfying the bundle contract, prefer an explicitly supplied run identifier, and surface the chosen source prominently before processing.

Required validation:
Mixed export directory fixture and deterministic selection tests.

### HF-013 - Update can complete after obsolete-file pruning failures

Severity: High
Location: `App/Update-NetworkToolkit.ps1`

Evidence:
Prune deletion failures increment `Skipped` but do not fail the update. The updater can return `Completed` or `Current` while stale program files remain.

Failure mode:
Old code and new code coexist after update.

Impact:
Load-order conflicts, obsolete plugin execution, inconsistent behavior, and difficult rollback.

Recommendation:
Classify skipped removals. Any skipped executable, script, module, manifest, or plugin file should make the update Partial/Failed and identify the exact path.

Required validation:
Locked obsolete script/plugin and access-denied fixtures.

### HF-014 - Update verification covers only five files

Severity: High
Location: `Test-NetworkToolkitCopy` in `App/Update-NetworkToolkit.ps1`

Evidence:
Only the launcher, deployment exclusion helper, GUI script, core script, and version manifest are hash-compared.

Failure mode:
Missing or corrupt plugins, utilities, ARGUS modules, deterministic rules, manifests, reports, and embedded-tool metadata do not fail verification.

Impact:
Updater can report success with an operationally incomplete installation.

Recommendation:
Use a signed or hashed package manifest covering every managed program file. Verify required and optional payload classifications after copy.

Required validation:
Delete/corrupt representative plugin, ARGUS module, rule file, utility, and manifest before verification.

### HF-015 - Update and fresh deployment are destructive without transaction or rollback

Severity: High
Location: `Deploy-NetworkToolkit.ps1` and `Update-NetworkToolkit.ps1`

Evidence:
- Fresh deployment clears all contents of the selected destination folder.
- Update moves legacy layouts, copies files, prunes roots, and removes artifacts in place.
- No complete staging, atomic swap, or rollback is implemented.

Failure mode:
Interruption, access denial, bad source, or wrong destination can leave a partially removed or partially updated toolkit.

Impact:
Loss of local program files or unintended files in a mistakenly selected dedicated folder.

Recommendation:
Stage to a sibling directory, validate the complete image, preserve a rollback snapshot, then swap. Require a destination identity marker before destructive update; fresh deployment should use explicit confirmation and empty/new-folder safeguards.

Required validation:
Power interruption simulation, locked files, invalid source, wrong destination, rollback, and preserved client-data tests.

## Current Risk Pattern

The same design tendency recurs across collection, deterministic analysis, ARGUS, and update logic:

1. Catch errors to keep the workflow moving.
2. Write some artifact or warning.
3. Continue downstream processing.
4. Return Completed or PASS.

The remediation strategy should introduce a shared result-state vocabulary and make degraded state impossible to lose between layers.
