# Architecture

## Product Boundary

Computer Triage Toolkit is a portable Windows diagnostic product for one computer at a time. It is not whole-network discovery, SIEM, RMM, asset inventory, compliance, or a general AI-builder platform.

## Canonical Components

- **Toolkit**: the complete portable product.
- **HEPHAESTUS**: evidence collection, normalization, integrity validation, and deterministic local analysis.
- **ARGUS**: cited explanation, prioritization, and technician guidance based on validated evidence and deterministic findings.
- **Operation Controller**: shared owner of process, job, timer, timeout, cancellation, terminal-state, and cleanup lifecycle.
- **Tool Descriptor**: canonical metadata used for tool discovery, display, launch, compatibility, and trust references.
- **Plugin**: isolated optional integration that follows the plugin contract.
- **Run**: one immutable diagnostic execution identified by a validated run ID.
- **Runtime**: writable state, logs, cache, exports, and run artifacts.
- **Report**: technician or executive output derived from one validated run identity.

ARGUS is the only approved analysis and explanation product name.

## Repository Boundaries

```text
C:\Computer_Toolkit
|-- PROJECT.md                 Workflow authority
|-- README.md                  Operator introduction
|-- NetworkToolkit.vbs         Portable launcher
|-- App                        GUI, workflows, tools, plugins, manifests
|-- Core
|   `-- Argus                  ARGUS engine and reusable core logic
|-- Runtime                    Writable state and run artifacts
`-- docs                       Charter, architecture, ADRs, roadmap, tasks, reviews, history
```

Operational scripts and collectors remain under `App/NetworkToolkit` until an active task explicitly moves them.

## Responsibility Boundaries

1. The launcher and GUI orchestrate workflows; they do not own analysis rules, collection logic, or trust decisions.
2. HEPHAESTUS owns collection, evidence normalization, integrity validation, deterministic analysis, and machine-readable outputs.
3. ARGUS consumes validated evidence and deterministic findings. It must cite sources and must not silently replace or rewrite evidence.
4. The Operation Controller owns asynchronous GUI lifecycle behavior.
5. Canonical descriptors and manifests own metadata. Duplicate registries are prohibited.
6. Plugins execute through documented compatibility, lifecycle, isolation, trust, and result contracts.
7. Runtime writes are atomic, concurrency-safe, and separate from immutable shipped program files and defaults.
8. Reports and exports resolve to one validated immutable run identity.
9. Packaging and updates fail closed on missing, corrupt, untrusted, or identity-mismatched managed content.

## Primary Runtime Flow

```text
Technician action
  -> GUI or launcher validation
  -> Operation Controller
  -> collector, tool, or plugin execution
  -> evidence normalization and integrity validation
  -> deterministic HEPHAESTUS findings
  -> ARGUS cited explanation and guidance
  -> run-indexed reports and artifacts
```

## Core Contracts

### Evidence Contract

Collected evidence retains source identity, collection outcome, timestamps, integrity state, and completeness. Partial evidence cannot be represented as complete.

### Operation Contract

Every operation terminates as exactly one of:

- Success
- Partial
- Failed
- Cancelled
- TimedOut

Cancellation and timeout require deterministic cleanup. Failures remain explicit and attributable.

### Tool and Plugin Contract

Tools and plugins use canonical descriptors, validated compatibility, explicit privilege and trust requirements, isolated failures, and canonical operation results. They cannot bypass artifact, provenance, lifecycle, or reporting controls.

### Runtime and Artifact Contract

Shipped program files and defaults are immutable. Writable runtime state is explicit, atomic, concurrency-safe, classified, retained according to policy, and selectively transferable with verification.

### Reporting Contract

Reports use canonical metadata and escaping, identify the originating run, distinguish missing or stale artifacts, and do not infer latest state from ambiguous directory order.

### Package and Update Contract

Build, package, deploy, and update operations verify managed content, destination identity, provenance, and staged integrity before atomic replacement. Failure preserves the existing installation.

## Failure Behavior

- Collection failure records the failed or partial outcome and preserves available evidence.
- Deterministic analysis failure cannot be masked by ARGUS output.
- ARGUS must identify evidence gaps and confidence limits.
- Plugin or external-tool failure is isolated and cannot corrupt the run.
- GUI cancellation, timeout, replacement, or shutdown cleans owned processes, jobs, and timers.
- Runtime write failure preserves the previous valid state.
- Package or update failure preserves the existing installation and immutable defaults.

## Governance References

- Mission, scope, and role authority: `docs/PROJECT-CHARTER.md`
- Workflow authority: `PROJECT.md`
- Current and future sequencing: `docs/ROADMAP.md`
- Operational task state: `docs/TASKS/QUEUE.md`
- Next-agent state and prompt: `docs/HANDOFF.md`
- Detailed architecture decisions: `docs/ADRS`
- Historical chronology: task records and `docs/HISTORY`
