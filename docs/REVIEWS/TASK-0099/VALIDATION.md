# TASK-0099 Validation

## Canonical invocation

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File App\Test-Repository.ps1 -ResultPath <temporary-result-path>
```

Environment: Windows PowerShell `5.1.26100.32995`.

## Final result

- Overall: Passed.
- Gates passed: 17.
- Gates failed: 0.
- Tracked PowerShell files parsed: 82.
- Parser exclusions: 0.

## Gates

- Repository-wide PowerShell 5.1 parser.
- ARGUS correctness.
- Background-operation lifecycle and leak behavior.
- Canonical analysis/tool/plugin architecture.
- Change transactions and rollback.
- Deployment and managed-file integrity.
- Diagnostic bundle identity and deterministic rerun behavior.
- External-tool provenance.
- CLI operation results and ARGUS fail-closed behavior.
- Parser-backed evidence quality.
- Reporting and immutable run-index state.
- Sensitive artifact and atomic runtime state.
- Complete toolkit/module/plugin load smoke.
- Triage command, collector, bundle hash, and tamper behavior.
- Production-package valid/tampered payload verification.
- GUI smoke.
- Button-smoke.

## Contract checks

The validation manifest rejects missing required coverage, missing required negative-path coverage, duplicate stage IDs, untracked stage scripts, undeclared tracked fixture scripts, and invalid parser exclusions. Every child stage runs in an isolated Windows PowerShell process with bounded timeout and captured output.

No audit counter reached `25 / 25`; TASK-0100 may be activated.
