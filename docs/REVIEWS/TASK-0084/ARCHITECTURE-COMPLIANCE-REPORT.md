# Architecture Compliance Report

Task: `TASK-0084-Full-Codebase-Architecture-And-Quality-Audit`
Status: In Progress

## Intended High-Level Architecture

The current intended product flow is:

```text
Evidence Collection
  -> Evidence Normalization
  -> Deterministic Analysis
  -> ARGUS correlation/explanation/recommendations
  -> Technician and escalation reporting
  -> GUI workflow and artifact review
```

Supporting surfaces:
- tool/plugin execution
- runtime state and retention
- package/build/deployment/update
- validation and governance

## Overall Assessment

The high-level product direction is sound, but implementation boundaries are incomplete. ARGUS is reasonably separated from direct system collection, yet its inputs are not currently trustworthy enough to support the confidence model. Quick Diagnosis remains a parallel diagnostic stack. The GUI is both presentation and application controller. Deployment/update and runtime-data boundaries are insufficiently formalized.

Architecture compliance rating: **Needs Remediation**.

## Boundary Assessment

### Evidence Collection

Expected responsibility:
- collect raw or structured observations
- record success, failure, source identity, timestamp, and provenance
- avoid diagnosis beyond collection status

Observed drift:
- AI collector section status can claim Completed after failed artifact creation.
- collector writers can create invalid JSON/CSV files containing text errors.
- Quick Diagnosis performs collection and diagnosis in one plugin.
- collection manifest integrity is incorrect.

Decision:
Collection cannot yet serve as a dependable contract.

### Evidence Normalization

Expected responsibility:
- parse bundle-contained evidence
- produce schema-versioned, source-linked structured facts
- never introduce live-host data into offline analysis

Observed drift:
- current deterministic analysis is called local analysis but mixes runtime host CIM/environment into an arbitrary bundle.
- evidence quality is inferred from names rather than parsing.
- generated output is included on subsequent inventories.
- only machine profile is normalized; most domain data remains findings/timeline text.

Decision:
The implemented “normalization” boundary is incomplete and violated by host contamination.

### Deterministic Analysis

Expected responsibility:
- apply reproducible rules to normalized/bundle evidence
- cite observations
- emit deterministic derived assertions

Observed drift:
- duplicate function definitions mean rule implementation is selected by load order.
- some findings depend on live host state rather than the evidence bundle.
- rules often search the first matching text file by broad regex.
- missing evidence and actual fault findings share the same findings stream.

Decision:
The deterministic layer requires contract and isolation remediation before expanding rules.

### ARGUS

Expected responsibility:
- validate input contract
- preserve evidence hierarchy
- normalize cited facts/gaps
- group related findings/events
- produce conservative, confidence-conditioned recommendations
- clearly separate inference and unsupported claims

Positive compliance:
- ARGUS does not directly query the operating system.
- artifacts retain `deterministicFinding`, `normalizedEvidence`, and inference labels.
- citations contain source type, artifact, pointer, field, observed value, and trust rank.
- recommendations set `safeToAutomate = false`.
- reports include limitations and evidence references.

Observed drift and defects:

#### ARG-001 - Required contract failures are not fail-closed
Severity: High

ARGUS records failed validation but continues and returns Completed. This violates the accepted contract’s required-input boundary.

#### ARG-002 - Citation identity is not durable
Severity: Medium/High

Citations have no stable citation ID, run/bundle ID, content hash, source record ID, observation timestamp, or rule version. `observedValue` is stringified, losing type.

Impact:
Citations cannot reliably prove they still refer to the same immutable evidence after files are regenerated or transferred.

Recommendation:
Add run identity, artifact hash, stable record/reference ID, typed value, and rule metadata where relevant.

#### ARG-003 - Domain assignment uses fragile substring matching
Severity: Medium

`Get-ARGUSFindingDomain` matches escaped tokens against title/category/tags. Short/general tokens such as `dc` and `service` can match unrelated words.

Recommendation:
Use canonical finding categories/tags and exact normalized tokens; fallback heuristics should record ambiguity.

#### ARG-004 - Deterministic findings are also converted into gap records
Severity: Medium/High

For every deterministic finding, normalization adds a gap whose reason is the finding statement and whose blocked conclusions are root-cause certainty and strong remediation claims.

Impact:
Actual detected issues and missing evidence are conflated. Gap counts become inflated and semantically unclear.

Recommendation:
Represent uncertainty/limitation on the fact or finding. Reserve gap records for missing, failed, partial, contradictory, or unsupported evidence.

#### ARG-005 - Recommendation ordering uses the wrong ranking vocabulary
Severity: High

Recommendations have priority values such as `urgent`, `high`, `normal`, `low`, and `evidence-needed`. Sorting calls the severity-rank function, which recognizes critical/high/medium/low/informational. Urgent, normal, and evidence-needed therefore share the default rank.

Impact:
The technician recommendation order is not deterministic according to the declared priority model.

Recommendation:
Add a dedicated priority rank function and tests covering all allowed values.

#### ARG-006 - Confidence amplifies upstream untrusted claims
Severity: High

ARGUS marks schema and evidence-quality facts confirmed, machine-profile fields high confidence, and timeline events medium confidence. The current upstream machine profile, score, and timeline are not reliable.

Recommendation:
Repair upstream contracts first. ARGUS should also record producer version and validation provenance rather than trusting artifact presence alone.

#### ARG-007 - Trust rank and ADR language need reconciliation
Severity: Medium

The code assigns ranks:
1 schema metadata
2 capability metadata
3 evidence quality
4 deterministic finding
5 timeline
6 normalized evidence
7 raw evidence
8 inference

This mirrors the original linear trust order, but processing authority, evidence reliability, and derivation level are different concepts. A normalized observation should not automatically rank below a deterministic derived assertion merely because of a number.

Recommendation:
Keep trust/source class as categorical metadata. Define compatibility, evidence quality, observation provenance, derivation, and inference support separately.

Decision:
ARGUS’s product boundary is largely correct, but input validation, citation durability, ordering, and semantic model defects are High priority.

### Reporting

Expected responsibility:
- render structured artifacts
- avoid creating new facts
- preserve confidence, citations, gaps, and failure mode

Observed drift:
- ARGUS reporting largely renders upstream structures correctly.
- multiple independent report systems create inconsistent language and styles.
- reports may present upstream false-success or contaminated evidence without additional validation.
- sensitive key reports lack retention classification.

Decision:
Reporting is structurally acceptable but cannot compensate for upstream truth defects.

### GUI

Expected responsibility:
- coordinate workflows
- communicate state and limitations
- avoid embedding diagnostic business logic where possible

Observed drift:
- monolithic script contains state, workflow orchestration, report discovery, process lifecycle, layout, settings, tool search, diagnostic logic, and result interpretation.
- separate background workflows duplicate process/timer management.
- GUI can display “Complete” results returned by layers that lost failure state.

Decision:
GUI is operational but violates separation of concerns. Remediation should be incremental.

### Tool and Plugin Framework

Expected responsibility:
- discover tools through canonical metadata
- enforce privilege, trust, provenance, and launch policy
- isolate plugin failures

Observed drift:
- multiple catalogs and manifests.
- path-existence trust.
- catalog paths escape the declared root.
- no required/optional plugin contract.
- global function namespace collisions.

Decision:
Framework requires normalized descriptors and trust enforcement.

### Runtime Data and Deployment

Expected responsibility:
- distinguish immutable program payload from writable client/runtime data
- preserve data during updates
- validate full package image
- support rollback

Observed drift:
- writable runtime state is under the application tree.
- source checkout is routinely mutated.
- update/deployment operate destructively in place.
- package verification covers only selected files.

Decision:
The portable model is reasonable, but program/data ownership and update transaction boundaries are under-specified.

## Required Architecture Remediation Sequence

1. Repair evidence identity, offline isolation, parser-backed quality, and run status.
2. Make ARGUS fail closed and correct citation/priority semantics.
3. Establish a shared result envelope and immutable run identity.
4. Repair destructive tool/update operations.
5. Define canonical subsystem and tool metadata contracts.
6. Expand architecture documentation to match implementation.
7. Consolidate overlapping diagnostic/report paths incrementally.
8. Extract GUI workflow controllers only after service contracts stabilize.
