# Redundancy and Conflicting Source-of-Truth Report

Task: `TASK-0084-Full-Codebase-Architecture-And-Quality-Audit`
Status: In Progress

## Executive Assessment

The codebase has grown through additive task work. New functionality was generally introduced without removing or consolidating earlier implementations. This preserved working behavior, but created overlapping analysis engines, repeated report renderers, duplicated state handling, global symbol collisions, and multiple operational catalogs.

The immediate recommendation is **not** a broad rewrite. Critical and High defects should be fixed first; consolidation should follow through narrowly scoped extractions with regression tests.

## Confirmed Redundancies

### RED-001 - Duplicate global deterministic-analysis functions are resolved by filename load order

Severity: High
Locations:
- `App/NetworkToolkit/Core/LocalAnalysisEngine.ps1`
- `App/NetworkToolkit/Core/LocalAnalysisRules.ps1`

Evidence:
Both files define global functions named:
- `New-HEPFindings`
- `New-HEPBundleCapabilities`

Core scripts are dot-sourced in filename order. `LocalAnalysisRules.ps1` therefore silently replaces the implementations loaded from `LocalAnalysisEngine.ps1`.

Impact:
- The active implementation is determined by filesystem/name ordering rather than an explicit module contract.
- Editing the apparently canonical engine implementation may have no runtime effect.
- Renaming or reordering files can change production behavior.
- Tests may exercise a different implementation if files are loaded directly.

Recommendation:
Choose one canonical implementation. Rename override/extension functions explicitly or pass a rule catalog into the engine. Add duplicate-global-function detection to startup validation.

### RED-002 - Three diagnostic reasoning systems overlap

Severity: High
Systems:
1. Quick Diagnosis plugin.
2. Deterministic local analysis engine/rules.
3. ARGUS normalization/grouping/recommendations.

Overlapping responsibilities:
- collection and evidence extraction
- subsystem health classification
- severity selection
- confidence statements
- explanatory text
- recommendation generation
- technician reports

Impact:
The same computer can receive different severity, confidence, and recommendation language depending on which workflow is used.

Recommendation:
Define canonical services and product roles:
- live lightweight checks
- bundle normalization/deterministic rules
- ARGUS synthesis
- report rendering

Migrate one rule/report family at a time. Do not remove Quick Diagnosis until equivalent low-latency behavior exists and regression output is compared.

### RED-003 - Report rendering is duplicated across plugins and core systems

Severity: Medium/High
Examples:
- Quick Diagnosis HTML.
- Computer Fingerprint HTML.
- Deterministic analysis HTML.
- Software Key Finder HTML.
- ARGUS Markdown reports.
- Additional plugin reports.

Repeated concerns:
- HTML/Markdown escaping
- page headers and metadata
- severity badges
- tables
- limitations
- artifact links
- timestamp/computer identity

Impact:
Security fixes, terminology changes, accessibility changes, and style corrections must be repeated. Reports communicate inconsistent confidence and limitations.

Recommendation:
Create small shared render helpers and a common report metadata contract. Keep report-specific layouts separate.

### RED-004 - HTML encoding helpers are repeatedly defined globally

Severity: Medium
Examples:
- `Convert-NTKHtml`
- `ConvertTo-NTKHtmlText`
- `ConvertTo-NTKKeyFinderHtml`
- other report-specific equivalents

Impact:
Global namespace growth and inconsistent behavior/naming.

Recommendation:
Use one shared HTML encoding helper in a reporting utility module and avoid global per-plugin variants.

### RED-005 - Background operation lifecycle is repeated throughout the GUI

Severity: High
Location: `App/ToolKit-GUI/ToolKit-GUI.ps1`

Evidence:
Separate process/timer/session/result/completion variables and handlers exist for:
- Quick Diagnosis
- toolkit size
- update
- deployment
- triage
- public IP
- Chocolatey
- Windows Update
- PsExec
- activity refresh
- asynchronous safe runners

Impact:
Cancellation, polling, cleanup, result parsing, timeout, and UI-state behavior differ by workflow.

Recommendation:
Extract a generic background-operation controller supporting state, process/job ownership, cancellation, timeout, result path, cleanup, and completion callback.

### RED-006 - Tool catalogs exist in multiple forms

Severity: Medium/High
Sources:
- `Config/ToolCatalog.ps1`
- `ExternalToolManager.ps1` catalog
- `custom-tools.json`
- `triage-tools.json`
- plugin manifests
- GUI-specific indexes and search maps

Impact:
The same tool can have inconsistent name, tab, privilege requirement, arguments, location, provenance, or availability across views and workflows.

Recommendation:
Define a normalized tool descriptor schema and adapters for plugin, external, custom, and triage tools. Keep one canonical privilege/provenance field set.

### RED-007 - Path/root detection is reimplemented

Severity: Medium
Examples:
- launcher root detection
- deployment source/destination layout detection
- update layout detection
- client data transfer root detection
- GUI/root path construction
- external/custom tool path traversal

Impact:
Legacy layouts and current layouts can be interpreted differently by different operations.

Recommendation:
Create a read-only deployment-layout resolver returning explicit deployment root, app root, schema/layout version, and identity markers.

### RED-008 - Result/status vocabulary is fragmented

Severity: High
Observed values include:
- `Completed`
- `CompletedWithWarnings`
- `Failed`
- `FailedNonFatal`
- `Current`
- `Running`
- `passed`
- `failed`
- `normal`
- `limited`
- `OK`
- `Warning`
- `Info`
- hard-coded `PASS`
- booleans such as `succeeded`

Impact:
Layers lose failure information or translate partial work into success.

Recommendation:
Adopt a shared operation result envelope with canonical terminal states and stage results.

### RED-009 - Safe filename conversion has multiple fallback implementations

Severity: Low/Medium
Examples:
- `ConvertTo-NTKSafeFileName`
- repeated regex fallbacks in ComputerState, ProcessLauncher, triage, reports, and plugins

Impact:
Different names can resolve to different paths and collision behavior.

Recommendation:
Use a single utility with collision and empty-name behavior documented.

### RED-010 - Process command-line construction is inconsistent

Severity: Medium
Examples:
- `Start-NTKToolProcess` uses structured `ArgumentList`.
- `Join-NTKCommandLine` performs custom quote escaping.
- VBS builds one command string.
- multiple plugins manually embed quoted path strings into argument arrays.
- direct call-operator invocations use arrays.

Impact:
Arguments with quotes, trailing backslashes, ampersands, or special characters may behave differently by path.

Recommendation:
Prefer structured argument arrays and isolate legacy string construction behind tested helpers.

### RED-011 - Computer state and reports duplicate historical snapshots

Severity: Medium
Sources:
- ComputerState JSON.
- ComputerProfiles JSON/HTML.
- Quick Diagnosis reports and embedded state.
- Triage run manifests.
- ARGUS reports.

Impact:
“Latest” status can point to different times or copies; stale paths persist after retention/deletion.

Recommendation:
Introduce immutable run IDs and a run index that links artifacts without duplicating mutable latest-state data.

### RED-012 - Evidence inventory and manifest concepts are duplicated

Severity: Medium/High
Sources:
- triage collection manifest
- bundle capabilities
- evidence score categories
- deterministic inventory
- ARGUS input inventory
- production package manifest
- client transfer manifest

Impact:
Each manifest defines completeness and integrity differently. Some are inventories, some claims, and some partial hashes.

Recommendation:
Define separate schemas for diagnostic run manifest, evidence artifact record, analysis artifact record, and software package manifest.

## Dead or Superseded-Code Risks Requiring Function-Level Verification

The following patterns suggest likely dead/superseded code but should not be removed until caller checks and runtime tests are complete:

- First definitions overridden by duplicate global functions.
- Legacy path migration and root-layout branches.
- Historical plugin launchers now replaced by embedded tabs.
- Old direct report opening functions alongside guided Analyze workflow.
- Compatibility functions retained after catalog/source-of-truth centralization.
- Development-only scripts and scratch files under tracked roots.

## Consolidation Order

1. Fix status/integrity defects without structural redesign.
2. Eliminate duplicate deterministic function definitions.
3. Establish shared result and run identity contracts.
4. Consolidate tool descriptor metadata.
5. Extract GUI background-operation lifecycle.
6. Consolidate report helpers.
7. Reconcile Quick Diagnosis with canonical analysis services.
8. Remove proven dead code only after caller and regression evidence.
