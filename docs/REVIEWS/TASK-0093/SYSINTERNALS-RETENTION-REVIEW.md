# TASK-0093 Sysinternals Retention Review

## Decision

Production packages retain only Sysinternals executables used by the external-tool catalog or Quick Diagnosis: Autoruns/Autorunsc, Coreinfo, Handle, LogonSessions, Process Explorer, Process Monitor, PsExec, PsLoggedon, PsPing, RAMMap, Sigcheck, and TCPView, including required architecture variants and the EULA text.

The full source suite remains untouched in the working repository. Package staging removes all other suite executables using the tracked allowlist in `external-tool-provenance.json` before the managed-file manifest is created.

## Rationale

- Retained tools have an existing diagnostic or operational call site.
- PsExec remains restricted because remote execution commonly triggers EDR; it is never permitted to bypass provenance validation.
- Unused administrative, destructive, persistence, or niche tools do not justify package size, signature/hash maintenance, licensing review, and EDR friction.
- The allowlist makes additions deliberate and reviewable rather than inheriting every file in a downloaded suite.

## Lifecycle and Operations

- Hash and required publisher signature validation occurs before launch.
- Sysinternals EULA acceptance remains explicit in the runtime launch path.
- Unknown local additions are classified `local-untrusted` and blocked.
- Refresh provenance at least every 90 days and immediately when any executable is replaced.
- Never disable endpoint protection globally; any exception must be narrow, documented, and applied only after integrity validation.
