# ADR-0002 - Normalized Output Schema Versioning

Date: 2026-07-01
Status: Accepted
Task: `TASK-0018-HEPHAESTUS-Local-Analysis-Engine-v1-Design`

## Context

HEPHAESTUS Local Analysis Engine v1 will produce normalized JSON, findings, timelines, evidence scores, report output, and metadata. These outputs need stable contracts so later reporting and ARGUS work can consume them safely.

## Decision

Every generated JSON artifact from Local Analysis Engine v1 must include a top-level `schemaVersion` field.

The v1 schema family starts at:

```text
1.0
```

Required metadata fields for generated JSON artifacts:

- `schemaVersion`
- `generatedAtUtc`
- `generator`
- `sourceBundle`

Bundle-level metadata must include:

- `Metadata/schema-version.json`
- `Metadata/bundle-capabilities.json`

Missing or unsupported sections should be recorded as `planned`, `partial`, `not_implemented`, `missing`, or `skipped`; the engine must not invent values.

## Compatibility Rules

- Additive fields may be introduced in minor schema revisions.
- Breaking changes require a new major schema version.
- Consumers must ignore unknown fields.
- Producers must use `null` for unknown values rather than guessing.
- Parser failures must be recorded as warnings instead of silently omitted.

## Consequences

- Local HTML reports and future ARGUS input handling can rely on explicit version metadata.
- Early implementation can support partial outputs while exposing capability limits clearly.
- Schema versioning becomes part of the validation surface.
