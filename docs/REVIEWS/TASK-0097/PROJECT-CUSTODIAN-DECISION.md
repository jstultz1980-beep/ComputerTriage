# TASK-0097 Project Custodian Decision

## Decision

The Project Custodian accepts the current product direction and fixes the following intended-state model for Version 1.0.

## Product Boundary

Computer Triage Toolkit diagnoses one Windows computer at a time. It is not a network discovery, SIEM, RMM, asset inventory, compliance, or general AI-builder product.

## Canonical Runtime Terms

- **Toolkit**: the complete portable product.
- **HEPHAESTUS**: evidence collection and deterministic local analysis pipeline.
- **ARGUS**: cited explanation, prioritization, and technician-guidance layer operating on validated evidence outputs.
- **Operation Controller**: shared owner of process, job, timer, timeout, cancellation, terminal-state, and cleanup lifecycle.
- **Tool Descriptor**: canonical metadata record used for tool discovery, display, launch, compatibility, and trust references.
- **Plugin**: isolated optional integration that follows the documented plugin contract.
- **Run**: one immutable diagnostic execution identified by a validated run ID.
- **Runtime**: writable state, logs, cache, exports, and run artifacts. Shipped program files and defaults remain immutable.
- **Report**: technician or executive output derived from one validated run identity.

ARGUS remains the only approved analysis/explanation product name. No additional code names are authorized.

## Intended-State Boundaries

1. The launcher and GUI orchestrate workflows but do not own analysis rules, collection logic, or tool trust decisions.
2. HEPHAESTUS owns collection, evidence normalization, deterministic analysis, and machine-readable outputs.
3. ARGUS consumes validated evidence and deterministic findings; it must not silently replace or rewrite source evidence.
4. The Operation Controller owns asynchronous lifecycle behavior for GUI operations.
5. Canonical descriptors and manifests own metadata; duplicate registries are prohibited.
6. Plugins fail independently and cannot bypass operation, trust, artifact, or reporting contracts.
7. Runtime writes are atomic, concurrency-safe, and separated from immutable shipped defaults.
8. Reports and exports resolve to a validated immutable run identity.
9. Packaging and updates fail closed on missing, corrupt, untrusted, or identity-mismatched managed content.

## Primary Flow

```text
Technician action
  -> GUI/launcher validation
  -> Operation Controller
  -> collector/tool/plugin execution
  -> evidence normalization and integrity validation
  -> deterministic HEPHAESTUS findings
  -> ARGUS cited explanation and guidance
  -> run-indexed reports and artifacts
```

## Failure Model

Every operation must terminate as one of: Success, Partial, Failed, Cancelled, or TimedOut. Failures remain explicit and attributable. Partial evidence cannot be presented as complete. Cancellation and timeout require cleanup. Plugin or external-tool failure must not corrupt the run or bypass trust checks. Existing installations and immutable defaults must survive failed package/update operations.

## Governance Consolidation Decision

- `PROJECT.md` remains the workflow authority.
- `docs/PROJECT-CHARTER.md` remains the mission, scope, and role authority.
- `docs/ARCHITECTURE.md` becomes the concise intended-state runtime authority.
- `docs/ROADMAP.md` contains only current and future sequencing; completed chronology belongs in task files and history.
- `docs/TASKS/QUEUE.md` remains the concise operational task-state authority.
- `docs/HANDOFF.md` remains the next-agent state and prompt authority.
- Detailed procedures remain in their focused governance documents and should be referenced rather than duplicated.

## Authorized Codex Support

Codex is authorized to complete TASK-0097 only through focused documentation/reference work:

1. Apply the terminology above where current repository text conflicts.
2. Remove stale historical detail from roadmap/queue only when preserved in task/history records.
3. Replace duplicated governance procedures with links to the authoritative focused document.
4. Do not change application behavior, architecture, feature scope, task order, or product names.
5. Run the terminology inventory and simulated Resume Work, Address Errors, audit-gate, and handoff workflows.
6. Update required task, handoff, history, and counter records and stop at the next Project Custodian/audit boundary or activate TASK-0098 when all TASK-0097 acceptance criteria pass.

## Sequence

The approved sequence remains:

1. TASK-0097 documentation/reference consolidation
2. TASK-0098 shared reporting and run-index contracts
3. TASK-0099 repository-wide validation foundation
4. TASK-0100 performance instrumentation and run-scoped observation cache
5. TASK-0080 release-candidate validation and documentation

No feature expansion, helper framework, or native replacement work is authorized.