# Repository Validation

## Canonical entry point

Run the complete gate from the repository root with Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File App\Test-Repository.ps1
```

Use `-ResultPath <path>` to write the versioned JSON result envelope. The runner returns process exit code `0` only when every declared gate passes; a parser, coverage, fixture, timeout, or child-process failure returns `1`.

## Validation manifest

`App/manifests/repository-validation.json` is the source of truth for ordered validation stages, required coverage domains, negative-path coverage, and explicit PowerShell parser exclusions.

The runner rejects:

- missing required or negative-path coverage;
- duplicate stage IDs;
- stage paths that are not tracked PowerShell files;
- tracked `App/NetworkToolkit/Tests/Test-*.ps1` fixtures omitted from the manifest;
- parser exclusions that do not identify tracked files.

Parser exclusions are exceptional and must be explicit. The current exclusion list is empty.

## Gates

The validation sequence performs:

1. A parser pass over every tracked `.ps1` file using the Windows PowerShell 5.1 parser.
2. Isolated-process execution of all tracked fixture suites.
3. Toolkit load validation that fails on any required/optional import failure or degraded startup.
4. CLI, collection, deterministic analysis, ARGUS, report, artifact, sensitive-state, transaction, provenance, and lifecycle negative paths.
5. Production-package positive and tamper fixtures using the real managed-file verifier.
6. GUI and button smoke validation.

Each child stage has a bounded timeout and captured stdout/stderr. Stages run sequentially so GUI smoke and button-smoke do not interfere with one another.

## Adding validation

Add a focused `Test-*.ps1` fixture, declare it in the manifest with its coverage domains and negative-path status, then run the canonical entry point. A newly tracked fixture that is not declared causes the suite to fail before execution.
