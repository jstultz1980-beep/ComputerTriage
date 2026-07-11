# Security and Trust Assessment

Task: `TASK-0084-Full-Codebase-Architecture-And-Quality-Audit`
Status: In Progress

## Overall Assessment

The toolkit is designed for trusted technicians and intentionally performs privileged diagnostics and repairs. That operating context is legitimate, but the current implementation grants broad privilege early, trusts executable location more than provenance, stores sensitive client evidence in plaintext, and lacks transactional rollback for several system-changing operations.

Security posture: **Needs Remediation before broad distribution**.

## High-Priority Findings

### SEC-001 - Entire application starts elevated by default

Severity: High

The normal VBS launcher uses `runas`, causing every tab, plugin, report action, external tool, and child workflow to begin in an administrative process.

Risk:
- larger impact from script defects or malicious/replaced plugins
- increased impact from path hijacking or argument mistakes
- unnecessary administrative exposure for read-only functions

Recommendation:
Adopt least-privilege startup and elevate only explicitly privileged operations. Maintain an administrator-only fallback mode during transition.

### SEC-002 - Embedded and portable executable trust is path-based

Severity: High

Executable discovery checks expected paths but does not require package hash, Authenticode signature, expected publisher, or package-manifest membership before launch.

Risk:
A replaced executable can be launched, sometimes elevated.

Recommendation:
Generate a complete package manifest with SHA-256 for all managed executables/scripts. Optionally enforce expected signer/publisher for signed vendor tools. Treat locally added custom tools separately.

### SEC-003 - Remote-management enablement broadens exposure without rollback

Severity: High

One action enables remoting services and broad firewall groups, including File and Printer Sharing, WMI, Scheduled Tasks, Event Log, Remote Service Management, and Remote Registry.

Risk:
The host’s remote attack and lateral-movement surface changes materially. Partial failures create undocumented mixed state.

Recommendation:
Capture pre-state, present a change plan, apply capability-specific selections, verify results, and provide rollback.

### SEC-004 - PsExec fallback executes encoded PowerShell as SYSTEM

Severity: High

Remote management can fall back to PsExec with `-s`, `-h`, `ExecutionPolicy Bypass`, and encoded PowerShell.

Risk:
This is powerful and expected to trigger EDR. If target resolution, binary provenance, or command construction is wrong, impact is system-wide.

Recommendation:
Require verified PsExec hash/publisher, explicit technician confirmation, target identity confirmation, operation logging, and no silent fallback for changes.

### SEC-005 - Sensitive licensing values are persisted in plaintext

Severity: High

Software Key Finder writes full values to HTML in the portable Exports tree and displays them in the console.

Risk:
USB loss, shared folders, support bundle inclusion, screen capture, transfer, and over-retention expose customer licensing data.

Recommendation:
Mask by default, reveal only on explicit action, use a sensitive output class with short retention, and support encrypted export when persistence is necessary.

### SEC-006 - Client evidence is transferred as an undifferentiated plaintext set

Severity: Medium/High

ClientDataTransfer copies Data, Exports, Logs, Triage Runs, Profiles, and logs without sensitivity labels or encryption.

Risk:
Network topology, usernames, product keys, dumps, event data, process lists, and report artifacts move together.

Recommendation:
Classify artifacts and allow selective transfer. Warn on sensitive classes and offer encrypted archive/destination workflows.

### SEC-007 - Retention can delete or preserve evidence based on weak content heuristics

Severity: High

The retention engine samples a small number of small files for severity keywords.

Risk:
Important evidence may be deleted; benign content can prevent cleanup. There is no technician pin/case-hold mechanism.

Recommendation:
Use explicit artifact metadata and case retention state. Never infer legal/diagnostic preservation from shallow text search.

### SEC-008 - Automatic EULA acceptance lacks explicit operator record

Severity: Medium

The toolkit creates Sysinternals acceptance values and adds acceptance arguments automatically.

Risk:
The toolkit accepts vendor terms on behalf of the operator without a documented acceptance event.

Recommendation:
Use a one-time explicit toolkit acknowledgment and record the accepted vendor/tool/version policy.

### SEC-009 - Legacy and security tools lack lifecycle controls

Severity: High

The external catalog includes scanners, drivers/installers, registry editors, remote execution tools, and a legacy junkware tool without a tracked expiration/update policy.

Risk:
Outdated binaries, expired definitions, unsupported software, redistribution issues, or changed vendor behavior.

Recommendation:
Maintain source URL, license, version, hash, signature, expiration, last-reviewed date, and permitted use for every distributed tool.

### SEC-010 - Destructive deployment/update lacks destination identity and rollback assurance

Severity: High

Fresh deployment clears a selected destination; update prunes in place. Existing checks prevent drive-root and source/destination equality but do not prove the destination is an existing toolkit-owned folder before destructive operations.

Risk:
Wrong-folder selection, partial update, or interruption can destroy or strand files.

Recommendation:
Use identity markers, staged copy, complete verification, rollback snapshot, and atomic/safe swap.

## Medium Findings

### SEC-011 - ExecutionPolicy Bypass is pervasive

The VBS launcher, plugin-launched PowerShell, and PsExec fallback use `ExecutionPolicy Bypass`.

Assessment:
Execution policy is not a security boundary, but pervasive bypass makes it harder to distinguish trusted toolkit execution from arbitrary script execution and can conflict with customer policy.

Recommendation:
Document the reason, sign first-party scripts where practical, and use the narrowest invocation needed.

### SEC-012 - Logs and state include paths, usernames, targets, and operation details

The toolkit stores diagnostic logs, transfer manifests, computer-state previews, report paths, and remote target data under the portable application tree.

Recommendation:
Classify logs as client data, document retention, and avoid storing credentials or full secrets. Review all log fields for sensitive values.

### SEC-013 - Registry and remote-operation errors are often swallowed

Empty catch blocks and `SilentlyContinue` are common around registry, WMI, scheduled task, EULA, and remote operations.

Risk:
Security posture changes may not be verifiable or auditable.

Recommendation:
Use structured results and a task/run audit log for every modifying action.

### SEC-014 - Custom tool paths can traverse outside the declared root

Relative catalog paths use `..\..\Custom`.

Recommendation:
Use explicit root types and canonical-path containment checks.

### SEC-015 - Credential handling is memory-only but operation logging needs scrutiny

The print tool stores PSCredential in script memory, which is acceptable for a session, and does not persist passwords. However, usernames and remote targets are persisted and all error/log paths should be verified not to serialize credential objects.

## Positive Controls

- Sensitive key finder explicitly excludes passwords/tokens by design.
- Destructive printer and copy actions require explicit confirmation.
- ARGUS recommendations do not auto-remediate.
- Client-data transfer distinguishes program files from data and reports copy failures.
- Deployment/update excludes key runtime/client-data directories.
- Several destructive scripts use `ErrorAction Stop` for critical steps.

## Required Security Remediation Priorities

1. Package/tool provenance and complete payload verification.
2. Offline evidence identity and data integrity.
3. Least privilege and explicit privileged action boundaries.
4. Sensitive artifact classification, masking, retention, and transfer.
5. Transaction/rollback for remote changes, print repairs, deployment, and updates.
6. Structured modifying-operation audit records.
