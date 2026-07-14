# TASK-0080 Release-Candidate Validation

Date: 2026-07-13
Source HEAD: `dee9e2337d3f593d7198993f58fb1724d1e39096`
Disposition owner: Project Custodian

## Recommendation

Do not tag, publish, or distribute Version 1.0 from this evidence set. The repository-wide gate passed, but the independently verified full portable image failed the clean-package contract because four long-path LibreOffice files remained under a mutable `Data` tree.

## Canonical Repository Gate

Command:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File App\Test-Repository.ps1 -ResultPath Runtime\Logs\Validation\task-0080-repository-validation.json
```

Result: Passed, 18 passed and 0 failed, in 64.6 seconds.

Coverage included:

- all 84 tracked PowerShell files parsed with Windows PowerShell 5.1;
- toolkit/plugin load and canonical architecture;
- GUI smoke and button smoke;
- triage, bundle identity, parser-backed evidence, HEPHAESTUS, and ARGUS;
- reporting/run index and sensitive artifact safety;
- operation lifecycle and change transactions;
- deployment integrity, external-tool provenance, and package positive/tamper fixtures;
- performance budgets and run-scoped observation/provider behavior.

## Full Production Image

Build command:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File App\Build-ProductionPackage.ps1 -DestinationRoot Runtime\ReleaseCandidate\TASK-0080 -PackageName NetworkToolkit-Portable-RC -Force
```

Build result: Completed.

| Property | Value |
|---|---:|
| Package size | 6.72 GB |
| Total bytes | 7,214,424,777 |
| File count | 24,364 |
| Managed-file count | 24,343 |
| Build duration | approximately 14 minutes 53 seconds |
| Manifest SHA-256 | `E9BC3D74C622BC0A01602203270EC6E50795301E74BA1A0A0C7E153536D60701` |

Independent verification command:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File App\Test-ProductionPackage.ps1 -PackageRoot Runtime\ReleaseCandidate\TASK-0080\NetworkToolkit-Portable-RC
```

Verification result: Failed after approximately 3 minutes 19 seconds with one finding:

```text
Portable app data is present in App\Custom\LibreOfficePortable\Data (4 file(s)).
```

The four survivors are `OptionsDialog.xcu` files in long `settings\user\extensions\bundled\registry\...\lu*.tmp` paths. The mutable-path manifest correctly lists `Custom\LibreOfficePortable\Data`; the package builder uses `Remove-Item -Recurse -Force -ErrorAction SilentlyContinue`, which does not remove these legacy-length paths and does not fail the build. The final managed manifest includes the survivors, so all other integrity checks complete and the clean-data check is the only verifier failure.

Repository governance required preserving documented unrelated working-tree drift, including the local custom-tool manifest and payload additions. The builder packages the current payload, so this generated image is evidence for the full build/verification path and is not an approved publication artifact tied exclusively to the recorded source commit.

## Closeout Rerun

After documentation and build-metadata reconciliation, the first canonical closeout run passed 17 stages and exceeded one internal GUI timing budget in the performance fixture. The focused performance fixture immediately passed in isolation with 5,417 ms cold and 5,456 ms warm GUI startup. A complete canonical rerun then passed all 18 stages with zero failures. The isolated pass and successful full rerun indicate transient workstation contention following the large package hashing workload rather than a reproducible functional regression.

## Acceptance Reconciliation

- Parser validation: Passed.
- GUI smoke and button smoke: Passed.
- Triage, local analysis, ARGUS, reporting, deployment, update/integrity, and compact positive/tamper package validation: Passed.
- Full production package build: Completed.
- Full production package verification: Failed the clean-package contract.
- Quick-start, production-readiness, release notes, known limitations, handoff, and build metadata: Updated.

## Project Custodian Decision

Date: 2026-07-14
Decision: Focused remediation required. Risk acceptance is rejected.

Reasoning:

- The failed cleanup violates an explicit release contract rather than a cosmetic preference.
- The builder currently suppresses cleanup errors and can produce a package that appears successful while retaining mutable application state.
- The defect is deterministic, bounded, and directly remediable without architecture expansion.
- Publishing with the defect would weaken package integrity and repeatability at the final release boundary.

Authorized action:

- Activate `TASK-0111-Long-Path-Mutable-Tree-Cleanup` for Codex.
- Implement fail-closed, long-path-capable cleanup.
- Add a focused long-path fixture.
- Rerun canonical validation, full build, and independent full-image verification.
- Return `TASK-0080` to the Project Custodian only after verification passes.

Publication, GitHub release creation, tagging, and distribution remain unauthorized.
