# TASK-0084 Technical Debt Register

Status: Complete
Audit owner: ChatGPT

## Priority Debt

| Debt ID | Priority | Area | Description | Disposition |
|---|---|---|---|---|
| TD-001 | Critical | Evidence integrity | Offline bundle analysis can mix current-host and historical bundle evidence. | TASK-0086 |
| TD-002 | High | Evidence parsing | Artifact presence is treated as evidence without reliable parse and semantic validation. | TASK-0087 |
| TD-003 | High | Failure propagation | CLI, startup, collection, ARGUS, and plugin workflows use inconsistent success/failure semantics. | TASK-0088 |
| TD-004 | High | Bundle contract | Bundle identity, collector outcomes, completeness, and integrity are not represented by a trustworthy canonical manifest. | TASK-0089 |
| TD-005 | High | ARGUS correctness | Contract failure, citation durability, domain classification, confidence, and recommendation ordering require correction. | TASK-0090 |
| TD-006 | High | Destructive operations | Print and remote-management changes lack complete transaction, recovery, verification, and rollback behavior. | TASK-0091 |
| TD-007 | High | Packaging/update | Deploy and update workflows can accept partial or inconsistent managed-file states. | TASK-0092 |
| TD-008 | High | External tools | Provenance, version, hash, signature, license, privilege, EDR, and lifecycle controls are incomplete. | TASK-0093 |
| TD-009 | High | Sensitive/runtime data | Sensitive artifacts, retention, transfer, and mutable state handling are insufficiently controlled. | TASK-0094 |
| TD-010 | High | Architecture duplication | Analysis functions, tool metadata, manifests, and status vocabularies have competing sources of truth. | TASK-0095 |
| TD-011 | High | GUI lifecycle | Background process, timer, cancellation, and cleanup behavior is duplicated and leak-prone. | TASK-0096 |
| TD-012 | Medium | Documentation/governance | Architecture, terminology, roadmap, queue, and repeated governance text have drifted. | TASK-0097 |
| TD-013 | Medium | Reporting/run selection | Reports and latest-run pointers lack a shared immutable run index and metadata contract. | TASK-0098 |
| TD-014 | High | Testing | Negative-path, package-integrity, load-completeness, and repository-wide regression gates are incomplete. | TASK-0099 |
| TD-015 | High | Performance | Startup, first-render, repeated provider queries, scans, and lifecycle leaks lack budgets and instrumentation. | TASK-0100 |

## Existing Task Disposition

- TASK-0077 is superseded by TASK-0096 and TASK-0100.
- TASK-0078 is superseded by TASK-0093.
- TASK-0079 is superseded by TASK-0092.
- TASK-0080 remains the final release-candidate validation task after remediation.

## Release Rule

No release candidate may be declared ready while TD-001 through TD-009 or TD-014 remain unresolved or lack a written risk acceptance.