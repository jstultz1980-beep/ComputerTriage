# HEPHAESTUS Local Analysis Engine v1 Design

Date: 2026-07-01
Task: `TASK-0018-HEPHAESTUS-Local-Analysis-Engine-v1-Design`
Owner: ChatGPT
Status: Approved for implementation task creation

## Purpose

HEPHAESTUS Local Analysis Engine v1 adds deterministic first-pass analysis to the existing evidence collection workflow. The engine should move the toolkit from evidence collection toward actionable single-computer diagnosis without requiring ARGUS or internet access.

The engine must preserve existing collection behavior and existing human-readable evidence outputs while adding structured analysis artifacts that can be consumed by local reports and, later, ARGUS.

## Product Boundary

Computer Triage Toolkit remains focused on one Windows computer at a time.

HEPHAESTUS v1 local analysis is not:

- Whole-network discovery.
- SIEM behavior.
- RMM behavior.
- Asset inventory.
- Compliance reporting.
- AI reasoning.

## Responsibility Boundary

### HEPHAESTUS Owns

- Collecting local evidence.
- Reading collected evidence from the bundle/output folder.
- Normalizing selected evidence into stable JSON.
- Running deterministic rules against normalized and raw evidence.
- Producing structured findings.
- Producing a local timeline.
- Producing evidence completeness and quality scoring.
- Producing a local HTML executive summary.
- Producing metadata describing schema version and analysis capabilities.

### ARGUS Owns Later

- Reading HEPHAESTUS normalized outputs first.
- Treating deterministic findings as grounded evidence, not AI inference.
- Using raw evidence to verify or deepen findings.
- Explaining likely root-cause candidates.
- Prioritizing technician actions.
- Identifying gaps and unsupported conclusions.

ARGUS must not be required for HEPHAESTUS local analysis to run.

## Pipeline

```text
Collect existing evidence
  -> Discover evidence files
  -> Parse supported evidence
  -> Normalize into JSON models
  -> Score evidence completeness and parser quality
  -> Run deterministic rules
  -> Build timeline
  -> Write findings
  -> Write local HTML summary
  -> Write schema/capability metadata
  -> Package bundle
```

## Execution Model

The first implementation should run analysis after collection completes and before final bundle packaging.

Minimum implementation behavior:

1. Create `Analysis/` under the bundle/output root.
2. Create `Analysis/normalized/`.
3. Create `Metadata/` if it does not already exist.
4. Read available evidence files.
5. Mark missing files as skipped or unavailable, not failed.
6. Write JSON artifacts even when partial.
7. Produce a local report even if findings are empty.
8. Never break existing collection when analysis fails.

Parser failures should be captured as analysis warnings and evidence-quality deductions. A parser failure must not stop the entire toolkit.

## Output Artifacts

Target v1 artifacts:

```text
Analysis/findings.json
Analysis/timeline.json
Analysis/evidence-score.json
Analysis/normalized/machine-profile.json
Analysis/normalized/services.json
Analysis/normalized/processes.json
Analysis/normalized/drivers.json
Analysis/normalized/network.json
Analysis/normalized/security-products.json
Analysis/normalized/storage.json
Analysis/normalized/updates.json
Analysis/normalized/domain-health.json
Analysis/normalized/gpo.json
Analysis/report.html
Metadata/bundle-capabilities.json
Metadata/schema-version.json
```

Implementation may begin with a smaller supported subset if the task records unsupported artifacts as `not_implemented` in `bundle-capabilities.json`.

## Schema Rules

All JSON artifacts must include:

```json
{
  "schemaVersion": "1.0",
  "generatedAtUtc": "2026-07-01T00:00:00Z",
  "generator": "HEPHAESTUS Local Analysis Engine",
  "sourceBundle": {
    "computerName": "string-or-null",
    "collectionStartedUtc": "string-or-null",
    "collectionCompletedUtc": "string-or-null"
  }
}
```

Timestamps must be UTC when known. Unknown fields should be `null`, not invented.

## Finding Model

`Analysis/findings.json` should contain:

```json
{
  "schemaVersion": "1.0",
  "generatedAtUtc": "2026-07-01T00:00:00Z",
  "findings": [
    {
      "id": "HEP-FINDING-0001",
      "ruleId": "HEP-RULE-SERVICE-001",
      "title": "string",
      "summary": "string",
      "severity": "critical|high|medium|low|informational",
      "confidence": "confirmed|high|medium|low",
      "category": "security|performance|stability|network|storage|updates|domain|inventory|evidence",
      "status": "active|resolved|not_applicable|unknown",
      "evidence": [
        {
          "artifact": "relative/path/to/source",
          "field": "optional-field-name",
          "value": "observed-value-or-summary"
        }
      ],
      "recommendations": ["string"],
      "tags": ["string"],
      "firstSeenUtc": null,
      "lastSeenUtc": null
    }
  ]
}
```

Severity describes impact. Confidence describes evidence strength. They must be independent.

## Severity Model

- `critical`: immediate outage, data-loss risk, severe security exposure, or system unusable.
- `high`: likely root cause or major degradation needing near-term action.
- `medium`: meaningful issue that may contribute to symptoms.
- `low`: low-risk configuration or maintenance issue.
- `informational`: useful context without a direct problem statement.

## Confidence Model

- `confirmed`: direct evidence supports the finding.
- `high`: multiple signals support the finding.
- `medium`: one strong signal or several weak signals support the finding.
- `low`: possible issue; needs technician verification.

Rules must avoid high confidence when required evidence is missing.

## Rule Engine Design

Rules should be deterministic data checks. Each rule should declare:

- `ruleId`
- `name`
- `description`
- `category`
- `requiredArtifacts`
- `optionalArtifacts`
- `inputs`
- `condition`
- `severityMapping`
- `confidenceMapping`
- `findingTemplate`
- `recommendations`

Rule execution behavior:

1. If required artifacts are missing, emit no normal finding.
2. Missing required evidence may emit an evidence-quality finding.
3. If parsing fails, record parser warning and skip dependent rules.
4. Rules must not mutate collected evidence.
5. Rules must be repeatable against the same bundle.

## Initial Rule Set

The first implementation task should include a small rule set, not the full future scope.

Recommended v1 rules:

### Evidence Quality

- Required evidence missing.
- Evidence file present but parser failed.
- Bundle metadata incomplete.

### Machine Profile

- OS version missing or unsupported by parser.
- System uptime unusually high if uptime evidence exists.
- Pending reboot evidence present if available.

### Storage

- System volume free space below threshold.
- Disk health evidence indicates warning/failure if available.

### Services

- Automatic service not running when evidence clearly supports it.
- Repeated service failure evidence if event data is available.

### Security Products

- No detected AV/EDR/security product from available evidence.
- Multiple active security products if evidence supports conflict risk.

### Network

- No active default gateway from available network evidence.
- DNS configuration missing or suspicious from available adapter evidence.

### Updates

- Pending reboot or update failure signal when evidence exists.
- Last update date stale if evidence exists.

### Domain Health

- Domain joined but domain evidence missing.
- SYSVOL/DFSR/GPO issue only when applicable evidence exists.

## Evidence Score

`Analysis/evidence-score.json` should separate completeness from quality.

Recommended model:

```json
{
  "schemaVersion": "1.0",
  "generatedAtUtc": "2026-07-01T00:00:00Z",
  "overallScore": 0,
  "completenessScore": 0,
  "qualityScore": 0,
  "categories": [
    {
      "category": "machine-profile",
      "expectedArtifacts": 3,
      "presentArtifacts": 2,
      "parsedArtifacts": 2,
      "failedParsers": 0,
      "score": 67,
      "status": "partial"
    }
  ],
  "warnings": []
}
```

Scores are 0 to 100. Scores are not health scores. They describe how much confidence the toolkit should have in the available evidence.

## Timeline Design

`Analysis/timeline.json` should normalize known dated events from supported evidence.

Timeline event model:

```json
{
  "timestampUtc": "2026-07-01T00:00:00Z",
  "source": "relative/source/path",
  "category": "system|service|update|security|network|storage|domain|application",
  "title": "string",
  "details": "string",
  "relatedFindingIds": []
}
```

Unknown or local-only timestamps should be marked with explicit conversion status if conversion is uncertain.

## Local HTML Report

`Analysis/report.html` should be local, self-contained, and generated from structured outputs. It should not require internet access.

Report sections:

1. Executive summary.
2. Evidence quality score.
3. Critical and high findings.
4. Medium and low findings.
5. Machine profile.
6. Security product inventory.
7. Storage summary.
8. Network summary.
9. Update summary.
10. Domain/GPO summary if applicable.
11. Timeline highlights.
12. Missing evidence and parser warnings.

The report must distinguish deterministic findings from technician notes or future AI interpretation.

## Portable Tool Orchestration Boundary

Local Analysis Engine v1 may detect whether optional portable tools are present. It must not download or install them.

Tool state values:

- `available`
- `missing`
- `skipped`
- `ran`
- `failed`
- `not_required`

Missing optional tools must not fail analysis. They should reduce evidence completeness only for categories that depend on them.

## Bundle Capability Metadata

`Metadata/bundle-capabilities.json` should declare what the bundle contains and what the analysis engine can interpret.

Minimum fields:

```json
{
  "schemaVersion": "1.0",
  "generatedAtUtc": "2026-07-01T00:00:00Z",
  "analysisEngineVersion": "1.0.0",
  "capabilities": {
    "machineProfile": "supported",
    "services": "supported",
    "processes": "planned",
    "drivers": "planned",
    "network": "supported",
    "storage": "supported",
    "updates": "supported",
    "domainHealth": "partial",
    "gpo": "partial",
    "localHtmlReport": "supported"
  },
  "tools": []
}
```

`Metadata/schema-version.json` should describe the schema family and compatible consumers.

## Parser Failure Behavior

Parser failures must be recorded as structured warnings:

```json
{
  "artifact": "relative/path",
  "parser": "parser-name",
  "status": "failed",
  "message": "short failure reason"
}
```

Rules depending on failed parsers should be skipped, not guessed.

## Implementation Sequencing

TASK-0019 should implement only a minimal v1 vertical slice:

1. Analysis folder creation.
2. Metadata files.
3. Machine profile normalization.
4. Evidence scoring framework.
5. Findings model and rule runner.
6. Small initial rules for evidence quality, storage, network, updates, and security inventory where evidence exists.
7. Local HTML report generated from structured outputs.
8. Smoke validation that confirms output artifacts are produced.

Do not attempt the full planned artifact list in one implementation task.

## Validation Expectations

Codex should validate with:

- Existing smoke test.
- Existing button-smoke test if applicable.
- A collection or sample bundle run if available.
- JSON parse validation for all generated JSON artifacts.
- Confirmation that analysis failure does not break collection.
- Confirmation that missing optional tools are recorded as skipped/missing, not failures.

## Open Decisions Deferred

- Final schema version compatibility policy after real artifacts exist.
- Whether ARGUS should live under `Core/Argus` or normalized `Core/ARGUS`.
- Long-term rule definition format if rules move from script code into data files.
- Whether LatencyMon should become a supported optional portable tool. The current untracked local folder must remain untouched unless a future task explicitly handles it.
