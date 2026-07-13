# Canonical Service and Metadata Contracts

## Analysis Responsibilities

| Component | Canonical responsibility | Must not claim |
|---|---|---|
| Quick Diagnosis | Live interactive snapshot and evidence collection | Authoritative deterministic analysis or ARGUS recommendations |
| HEPHAESTUS Local Analysis | Canonical deterministic normalization, evidence scoring, timeline, capabilities, and findings | AI inference or presentation-only facts |
| ARGUS | Cited grouping, explanation, confidence, and recommendations over validated HEPHAESTUS artifacts | New uncited machine evidence |
| Reporting | Rendering upstream structured results | New diagnostic facts or recommendation logic |

Quick Diagnosis output declares `AnalysisRole=InteractiveSnapshot`, `AuthoritativeDeterministicAnalysis=false`, and the canonical HEPHAESTUS command. Duplicate HEPHAESTUS symbols were removed from `LocalAnalysisEngine.ps1`; `LocalAnalysisRules.ps1` solely owns findings and capability rules.

## Tool Metadata

`Get-NTKCanonicalToolDescriptors` is the normalized read model for tabs, search, launch, validation, and package/trust decisions. Its adapters merge:

- the shipped tool catalog for identity, placement, entry point, privilege, and description;
- runtime custom-tool state for locally installed portable applications;
- external-tool lifecycle/provenance records for trust and package eligibility;
- plugin manifests for discovery and compatibility.

Every descriptor has a stable ID, name, tab, section, kind, entry point, privilege flag, source, and native metadata reference. The GUI registry and header search consume the same descriptor list. Duplicate IDs or missing external provenance fail consistency validation.

## Plugin Contract

Each plugin is a directory discovered without a core edit and must contain `PluginManifest.psd1` with `Name`, `Version`, `Script`, and `Enabled`. Optional `MinToolkitVersion` controls compatibility. Disabled, incompatible, malformed, missing-script, and load-failing plugins are isolated as optional failures; they do not prevent other plugins or required modules from loading. Commands register with plugin source identity while the plugin is loading.

## Manifest Responsibilities

| Manifest | Responsibility |
|---|---|
| Diagnostic collection manifest | Immutable run identity, collector outcomes, and collected artifact claims |
| Evidence artifact record/inventory | Artifact path, type, hash, parser status, source record, and sensitivity |
| Analysis artifact | Derived HEPHAESTUS/ARGUS output with source bundle identity and citations |
| Production package manifest | Complete delivered program-file inventory, size, and SHA-256 integrity |
| External-tool provenance manifest | Acquisition, publisher, hash/signature, licensing, lifecycle, and package eligibility |
| Client transfer manifest | Selection, sensitivity, encryption, source/destination hashes, bundle identity, and failures |
| Runtime artifact metadata | Classification, retention, pinning, and transfer policy for one writable artifact |

These schemas are not interchangeable; a manifest cannot imply a responsibility outside its row.

## Operation States

Service boundaries use the TASK-0088 operation-result states only: `Succeeded`, `SucceededWithWarnings`, `Partial`, `Failed`, `Blocked`, and `Canceled`. Legacy status text may remain only as a compatibility/display field and must be accompanied by canonical `state` and `exitCode` fields.
