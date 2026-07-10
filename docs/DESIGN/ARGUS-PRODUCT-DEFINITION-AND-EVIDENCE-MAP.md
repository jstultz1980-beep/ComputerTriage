# ARGUS Product Definition And Evidence Map

Date: 2026-07-10
Task: `TASK-0072-ARGUS-Product-Definition-And-Evidence-Map`
Status: Approved for implementation task creation

## Product Role
ARGUS is the analysis and explanation layer for one computer at a time.

HEPHAESTUS collects and produces deterministic local analysis. ARGUS consumes those outputs, organizes the evidence into technician-usable explanations, and produces cited recommendations. ARGUS must not become a general AI chat surface, whole-network analyzer, or raw-log dumping ground.

## Current ARGUS State
The existing ARGUS foundation slice already:

- Loads and validates required HEPHAESTUS contract artifacts.
- Reads evidence quality, findings, timeline, and machine profile.
- Produces `ARGUS/input-validation.json`.
- Produces `ARGUS/analysis-summary.json`.
- Produces `ARGUS/report.md`.
- Labels deterministic findings separately from ARGUS inference.

That foundation is intentionally thin. It validates the contract and summarizes deterministic findings, but it does not yet normalize multiple evidence domains, group symptoms, or produce durable technician recommendations.

## Evidence Trust Order
ARGUS must keep the ADR-0003 trust order:

1. Schema and capability metadata.
2. Evidence score and parser warnings.
3. Deterministic HEPHAESTUS findings.
4. Normalized JSON evidence.
5. Timeline entries.
6. Raw evidence files.
7. ARGUS inference.

ARGUS may explain, group, prioritize, or challenge deterministic findings, but it may not silently override them. Any disagreement must cite conflicting evidence and be labeled as interpretation.

## Evidence Domains

| Domain | Primary Inputs | Current Support | ARGUS Use | Conclusions Allowed |
|---|---|---|---|---|
| Contract metadata | `Metadata/schema-version.json`, `Metadata/bundle-capabilities.json` | Supported | Decide normal vs limited mode and supported domains. | Whether ARGUS can analyze normally, partially, or only validate inputs. |
| Evidence quality | `Analysis/evidence-score.json` | Supported | Scale confidence and expose missing/parser-limited evidence. | Confidence caveats and missing-evidence warnings. |
| Deterministic findings | `Analysis/findings.json` | Supported | Primary problem statements and recommendations. | Prioritization, grouping, and technician action framing. |
| Timeline | `Analysis/timeline.json` | Supported, basic | Sequence evidence and support event grouping. | Temporal context only; no causality without supporting findings. |
| Machine profile | `Analysis/normalized/machine-profile.json` | Supported | Identify computer, OS, domain, vendor/model context. | Environment context, not health conclusions by itself. |
| Storage | `Analysis/findings.json`, future `Analysis/normalized/storage.json`, raw storage evidence | Partial | Explain low-space or disk-health findings. | Storage-health recommendations only when deterministic finding or normalized evidence exists. |
| Network | `Analysis/findings.json`, future `Analysis/normalized/network.json`, raw network evidence | Partial | Explain DHCP/APIPA/DNS/default-gateway findings. | Network path recommendations only when supported by finding or normalized evidence. |
| Updates | `Analysis/findings.json`, future `Analysis/normalized/updates.json`, raw update evidence | Partial | Explain Windows Update service or pending update issues. | Update repair/install recommendations with service/pending evidence. |
| Security products | `Analysis/findings.json`, future `Analysis/normalized/security-products.json`, raw Defender/AV evidence | Partial | Explain endpoint protection state and trust caveats. | Security posture recommendations only from explicit evidence. |
| Services | `Analysis/findings.json`, future `Analysis/normalized/services.json`, raw service evidence | Partial | Explain stopped automatic service findings. | Service dependency and restart guidance when finding exists. |
| Domain health | `Analysis/findings.json`, future `Analysis/normalized/domain-health.json`, raw domain evidence | Partial | Explain trust/logon/DC path issues. | Domain recommendations when domain evidence exists. |
| GPO | future `Analysis/normalized/gpo.json`, raw GPResult/GPO evidence | Partial/planned | Explain policy processing if evidence exists. | GPO conclusions only when specific GPO evidence exists. |
| Processes | future `Analysis/normalized/processes.json`, raw process evidence | Planned | Later performance/security context. | No first-release conclusions unless implemented. |
| Drivers | future `Analysis/normalized/drivers.json`, raw driver evidence | Planned | Later stability/performance context. | No first-release conclusions unless implemented. |
| Raw evidence | original bundle files | Verification only | Verify or enrich cited claims. | Never primary source when deterministic/normalized evidence exists. |

## ARGUS Output Contract
TASK-0073 should preserve existing ARGUS foundation outputs and add a normalized intermediate model.

Required first-release ARGUS output set:

```text
ARGUS/input-validation.json
ARGUS/analysis-summary.json
ARGUS/normalized-analysis.json
ARGUS/report.md
```

Planned TASK-0074 output additions:

```text
ARGUS/diagnostic-groups.json
ARGUS/recommendations.json
```

Reporting tasks may later create:

```text
ARGUS/technician-report.md
ARGUS/escalation-report.md
ARGUS/report.html
```

## Normalized Analysis Model
`ARGUS/normalized-analysis.json` should contain:

- `schemaVersion`
- `generatedAtUtc`
- `generator`
- `artifactType`
- `sourceBundle`
- `inputValidationStatus`
- `inputValidationMode`
- `evidenceQuality`
- `domains`
- `facts`
- `gaps`
- `citations`

Domain records should include:

- `domain`
- `capabilityStatus`
- `supportLevel`
- `primaryArtifacts`
- `normalizedArtifacts`
- `rawEvidencePatterns`
- `allowedConclusionLevel`
- `missingEvidenceImpact`

Fact records should include:

- `id`
- `domain`
- `label`
- `statement`
- `severity`
- `confidence`
- `sourceKind`
- `citations`
- `limitations`

Gap records should include:

- `domain`
- `artifact`
- `reason`
- `blockedConclusions`
- `recommendedCollection`

## Citation Model
Every ARGUS fact, recommendation, diagnostic group, or disagreement must include citations.

Citation fields:

- `sourceType`: `metadata`, `evidenceQuality`, `deterministicFinding`, `normalizedEvidence`, `timelineEvent`, or `rawEvidence`.
- `artifact`: relative path such as `Analysis/findings.json`.
- `jsonPointer`: optional pointer when citing JSON.
- `field`: optional field name.
- `observedValue`: concise observed value or summary.
- `trustRank`: numeric trust rank from the ARGUS trust order.

Human reports may show citations in shorter language, but the machine-readable outputs must retain structured citation data.

## Confidence Language
ARGUS confidence must combine evidence quality, source type, and support count.

Recommended first-release bands:

- `confirmed`: deterministic finding or direct normalized evidence with high-quality supporting data.
- `high`: deterministic finding plus another supporting source, or high-quality normalized evidence.
- `medium`: one strong source or multiple partial sources.
- `low`: weak, partial, or missing evidence affects the conclusion.
- `unsupported`: evidence is missing, capability is not supported, or the claim would require guessing.

ARGUS language rules:

- Use `is indicated` only for `confirmed` or `high`.
- Use `is likely` only for `high` or better and with citations.
- Use `may be contributing` for `medium`.
- Use `could be checked` for `low`.
- Use `cannot determine` for `unsupported`.
- Do not use absolute root-cause language unless evidence is `confirmed` and no key contradictory evidence exists.

## Unsupported Inference Rules
ARGUS must emit `unsupported` entries when:

- A capability is `planned`, `missing`, `skipped`, or `not_implemented`.
- Evidence quality is too low for a domain.
- Parser warnings affect a conclusion.
- A report claim would require raw evidence that is absent.
- A conclusion would require multi-machine or network-wide context.

Unsupported entries are not failures. They are part of the product: they tell the technician what ARGUS cannot honestly know.

## TASK-0073 Implementation Plan
TASK-0073 should:

1. Keep existing `ARGUS/input-validation.json`, `ARGUS/analysis-summary.json`, and `ARGUS/report.md`.
2. Add `ARGUS/normalized-analysis.json`.
3. Build structured domain records for the supported and partial domains in this document.
4. Convert deterministic findings into cited ARGUS fact records.
5. Convert evidence-score categories and warnings into gap records.
6. Include machine profile and timeline facts when available.
7. Validate against:
   - Existing latest bundle.
   - Synthetic normal bundle.
   - Synthetic limited/missing-evidence bundle.

TASK-0073 must not add event grouping, recommendation generation, report styling, or UI work.

## TASK-0074 Implementation Plan
TASK-0074 should consume `ARGUS/normalized-analysis.json` and produce:

- `ARGUS/diagnostic-groups.json`
- `ARGUS/recommendations.json`

Diagnostic groups should cluster facts by:

- Domain.
- Shared evidence.
- Timeline proximity when known.
- Technician action area.

Recommendations should include:

- `id`
- `title`
- `priority`
- `confidence`
- `action`
- `why`
- `citations`
- `blockedByMissingEvidence`
- `safeToAutomate`

First-release recommendations should be conservative. They should guide a technician, not silently remediate.

## ADR-0003 Status Decision
The committed repository version of ADR-0003 is already `Accepted` and matches TASK-0020 history.

The working tree currently contains known stale local drift in `docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md` that shows older proposed wording. TASK-0072 does not stage that file. The next audit gate should explicitly reconcile that local drift by either resetting it to the committed accepted version or intentionally updating it under a dedicated ADR/governance scope.

## Non-Goals
ARGUS first-release work must not:

- Invent missing evidence.
- Hide uncertainty.
- Perform whole-network reasoning.
- Act as a general chat assistant.
- Modify HEPHAESTUS collectors.
- Download or install tools.
- Remediate automatically.
- Use raw evidence as the primary contract when deterministic and normalized artifacts exist.
